class Rx_Bot_Scripted_Customizeable extends Rx_Bot_Scripted;


// Patrol Script Objective
var Rx_ScriptedBotSpawner MySpawner;
var Rx_ScriptedObj_PatrolPoint PatrolTask;
var UTGameObjective MyObjective;


protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;


	if (Pawn == None)
	{
		// pawn got destroyed between WhatToDoNext() and now - abort
		return;
	}

	if(Pawn.GetTeamNum() != GetTeamNum())
	{
		if(Rx_Pawn_Scripted(Pawn) != None)
			Rx_Pawn_Scripted(Pawn).TeamNum = GetTeamNum();
	}

	if(MySpawner != None)
	{
		if(MySpawner.Skill != Skill)
		{
			Skill = MySpawner.Skill;
			ResetSkill();
		}

		SpeedModifier = MySpawner.SpeedModifier;
		DamageDealtModifier = MySpawner.DamageDealtModifier;
		DamageTakenModifier = MySpawner.DamageTakenModifier;
		bGodMode = MySpawner.bInvulnerableBots;
		bDriverSurvives = MySpawner.bDriverSurvives;
	}
	if(Rx_Pawn_Scripted(Pawn) != None && Rx_Pawn_Scripted(Pawn).ScriptedSpeedModifier != SpeedModifier)
	{
		Rx_Pawn_Scripted(Pawn).ScriptedSpeedModifier = SpeedModifier;
	}

	if(Vehicle(Pawn) == None && BoundVehicle != None)
	{
		if(BoundVehicle.Health > 0 && BoundVehicle.DriverEnter(Pawn))
		{
			RouteGoal = None;
			MoveTarget = None;
			if(Rx_Vehicle(Pawn) != None)
				Rx_Vehicle(Pawn).UpdateThrottleAndTorqueVars();
		}
		else if(BoundVehicle.Health <= 0)
		{
			BoundVehicle = None;
		}

	}
	if(Rx_Pawn(Pawn) != None) 
	{
		if(Rx_ScriptedObj_PatrolPoint(MyObjective) != None && Rx_ScriptedObj_PatrolPoint(MyObjective).bWalkingPatrol)
		{
			ClearTimer('ConsiderStartSprintTimer');
			Rx_Pawn(Pawn).SetGroundSpeed(Rx_Pawn(Pawn).WalkingSpeed);
		}
		else
		{
			SetTimer(0.5,true,'ConsiderStartSprintTimer');
			Rx_Pawn(Pawn).SetGroundSpeed(Rx_Pawn(Pawn).RunningSpeed);
		}
	}

	bHasFired = false;
	GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;
	// if we don't have a squad, try to find one
	//@fixme FIXME: doesn't work for FFA gametypes
	if (Squad == None && PlayerReplicationInfo != None && UTTeamInfo(PlayerReplicationInfo.Team) != None)
	{
		GoalString @= "SQUAD MISSING";
	}

	SwitchToBestWeapon();

	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (StartleActor != None) && !StartleActor.bDeleteMe )
	{
		StartleActor.GetBoundingCylinder(StartleRadius, StartleHeight);
		if ( VSizeSq(StartleActor.Location - Pawn.Location) < Square(StartleRadius)  )
		{
			Startle(StartleActor);
			return;
		}
	}
	bIgnoreEnemyChange = true;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
	if(Squad != None)
	{
		if ( Enemy == None || !UTSquadAI(Squad).ValidEnemy(Enemy))
		{
			Enemy = None;
			UTSquadAI(Squad).FindNewEnemyFor(self,false);
		}
		else if ( !UTSquadAI(Squad).MustKeepEnemy(Enemy) && !LineOfSightTo(Enemy) )
		{
			// decide if should lose enemy
			if ( UTSquadAI(Squad).IsDefending(self) )
			{
				if ( LostContact(4) )
					LoseEnemy();
			}
			else if ( LostContact(7) )
				LoseEnemy();
		}
	}
	bIgnoreEnemyChange = false;

	// Objective logic
	if ( AssignSquadResponsibility() )
	{
		return;
	}

	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		if (Pawn.FindAnchorFailedTime == WorldInfo.TimeSeconds)
		{
			// we failed the above actions because we couldn't find an anchor.
			GoalString = "No anchor" @ WorldInfo.TimeSeconds;
			if (Pawn.LastValidAnchorTime > 5.0)
			{
				if (bSoaking)
				{
					SoakStop("NO PATH AVAILABLE!!!");
				}
				if ( (NumRandomJumps > 4) || PhysicsVolume.bWaterVolume )
				{
					// can't suicide during physics tick, delay it
					Pawn.SetTimer(0.01, false, 'Suicide');
					return;
				}
				else
				{
					// jump
					NumRandomJumps++;
					if (!Pawn.IsA('Vehicle') && Pawn.Physics != PHYS_Falling && Pawn.DoJump(false))
					{
						Pawn.SetPhysics(PHYS_Falling);
						Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
						Pawn.Velocity.Z = Pawn.JumpZ;
					}
				}
			}
		}

		GoalString @= "- Wander or Camp at" @ WorldInfo.TimeSeconds;
		bShortCamp = false;
		WanderOrCamp();
	}

		
}


function bool AssignSquadResponsibility ()
{

	if(Rx_ScriptedObj(MyObjective) != None && Rx_ScriptedObj(MyObjective).DoTaskFor(Self))
		return true;

	if(MySpawner != None && MySpawner.DoTaskFor(Self))
		return true;

	if(Rx_Vehicle(Pawn) != None && Enemy != None && !Rx_Vehicle(Pawn).ValidEnemyForVehicle(Enemy)) 
	{
		//loginternal("LoseEnemy");
		Enemy = None;
		//LoseEnemy();
	}	

	if(UTVehicle(Pawn) == None && HasRepairGun()) 
	{
		if(RepairCloseVehicles()) 
		{
			return true;		
		}
	}

	if ( LastAttractCheck == WorldInfo.TimeSeconds )
		return false;
	LastAttractCheck = WorldInfo.TimeSeconds;

	if(Squad != None)
		return UTSquadAI(Squad).AssignSquadResponsibility(self);	

	else
		return false;

}


function ForceAssignObjective(UTGameObjective O)
{
	if(Squad != None)
		UTSquadAI(Squad).SetObjective(O,true);
	else
		MyObjective = O;

	if(Rx_ScriptedObj(O) != None)
		Rx_ScriptedObj(O).DoTaskFor(Self);
}


state Patrolling
{


Begin:
	if(Enemy != None && LineOfSightTo(Enemy))
	{
		if(Rx_Vehicle(Pawn) == None)
			ChooseAttackMode();

		else
			TimedFireWeaponAtEnemy();

		Focus = Enemy;
	}
	else
		Focus = MoveTarget;

	SwitchToBestWeapon();
	WaitForLanding();

	GoalString = "Patrolling to"@MoveTarget;

	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));

	sleep(0.1);
	LatentWhatToDoNext();
}

state Roaming
{
	ignores EnemyNotVisible;

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

Begin:

	SwitchToBestWeapon();

	WaitForLanding();

	if(Enemy != None)
	{
		TimedFireWeaponAtEnemy();
	}


	if(MoveTarget != None)
		MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	else
		Sleep(1.0);

	sleep(0.1);
	LatentWhatToDoNext();

	if(!IsTimerActive('WaitAtAreaTimer')) 
	{
		GoalString @= "- STUCK IN ROAMING";
		if ( bSoaking )
			SoakStop("STUCK IN ROAMING!");
		

	}
}

state WaitForTactics
{

Begin :
	WaitForLanding();
	SwitchToBestWeapon();

	GoalString = "Holding Position";

	StopMovement();

	if(Enemy != None)
	{
		Focus = Enemy;

		if(Rx_ScriptedObj_HoldPosition(MyObjective) != None && Rx_ScriptedObj_HoldPosition(MyObjective).bRootPawn)
			DoRangedAttackOn(Enemy);
		else
			ChooseAttackMode();
	}


	Sleep(1.0);
	LatentWhatToDoNext();

}

