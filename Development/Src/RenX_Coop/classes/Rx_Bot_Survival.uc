class Rx_Bot_Survival extends Rx_Bot_Scripted;

var bool bFocusOnEnemy;
var bool bIsBoss;

function RxInitialize(float InSkill, const out CharacterInfo BotInfo, UTTeamInfo BotTeam)
{

	Skill = FClamp(InSkill, 0, 7);

	bCanTalk = false;

	Aggressiveness = FClamp(BotInfo.AIData.Aggressiveness, 0, 1);
	BaseAggressiveness = Aggressiveness;
	Accuracy = FClamp(BotInfo.AIData.Accuracy, -5, 5);
	StrafingAbility = FClamp(BotInfo.AIData.StrafingAbility, -5, 5);
	CombatStyle = FClamp(BotInfo.AIData.CombatStyle, -1, 1);
	Jumpiness = FClamp(BotInfo.AIData.Jumpiness, -1, 1);
	Tactics = FClamp(BotInfo.AIData.Tactics, -5, 5);
	ReactionTime = FClamp(BotInfo.AIData.ReactionTime, -5, 5);

	ResetSkill();
	//super.Initialize(4.0, BotInfo);

//	setStrafingDisabled(true);
	SetTimer(0.5,true,'ConsiderStartSprintTimer');

	if(OurTeamAI == None)
		OurTeamAI = Rx_TeamAI(BotTeam.AI);

	bFocusOnEnemy = FRand() > 0.25;

}

function InitPlayerReplicationInfo()
{
	if(PlayerReplicationInfo != none)
	{
		CleanupPRI();
	}
	PlayerReplicationInfo = Spawn(class'Rx_ScriptedBotPRI_Survival', self);

	if (PlayerReplicationInfo != none) 
	{
		if(GetTeamNum() == 0)
			PlayerReplicationInfo.SetPlayerName("A GDI Soldier");

		else
			PlayerReplicationInfo.SetPlayerName("A Nod Soldier");

		PlayerReplicationInfo.SetPlayerTeam(WorldInfo.GRI.Teams[GetTeamNum()]);
	}

//	SetTimer(0.05, false, 'CheckRadarVisibility'); 	
}

protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;


	if (Pawn == None)
	{
		// pawn got destroyed between WhatToDoNext() and now - abort
		return;
	}

	if(LastO != Squad.SquadObjective)
	{
		LastO = UTGameObjective(Squad.SquadObjective);
		CurrentBO = Rx_BuildingObjective(LastO);
	}

	if(CurrentBO == None || RouteGoal != CurrentBO.InfiltrationPoint)
		bInfiltrating = false;


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
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None) || Enemy.GetTeamNum() == GetTeamNum()) )
		LoseEnemy();
	if(Squad != None)
	{
		if ( Enemy == None )
			UTSquadAI(Squad).FindNewEnemyFor(self,false);
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

		if(Rx_SquadAI(Squad).SquadLeader != Self && Rx_SquadAI(Squad).TellBotToFollow(Self,Rx_SquadAI(Squad).SquadLeader))
			return;
		else
			WanderOrCamp();
	}

		
}

function bool AssignSquadResponsibility()
{
	if(Rx_BuildingObjective(Squad.SquadObjective) != None)
	{
		if(Enemy == None || !bFocusOnEnemy)
			return Rx_BuildingObjective(Squad.SquadObjective).TellBotHowToDisable(Self);
		
		return false;
	}
}

function bool ShouldSurviveVehicleDeath()
{
	return false;
}

state Rush
{
	ignores EnemyNotVisible;

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

Begin:

	if(CurrentBO != None && LineOfSightTo(CurrentBO.myBuilding))
		BroadcastBuildingSpotMessages(CurrentBO.myBuilding);

Moving:
	SwitchToBestWeapon();
	WaitForLanding();
	if(bInfiltrating)
	{
		if(CurrentBO != None)
			GoalString = "Infiltrating"@CurrentBO.myBuilding.GetBuildingName();	
		else
			GoalString = "Infiltrating.... "@Squad.SquadObjective$"...?";	
	}

	if(CurrentBO != None && CurrentBO.myBuilding.GetMCT() != None && CanAttack(CurrentBO.myBuilding.GetMCT()))
	{
		if(Enemy != None && !HasC4() && CanAttack(Enemy) && Rand(10) > 10 - (Skill))
		{
			if(LastVehicle != None && LastVehicle.Driver == None)
			{
				Rx_SquadAI(Squad).GoToVehicle(LastVehicle,Self);
			}
			else
			{
				sleep(0.1);
				LastVehicle = None;
				ChooseAttackMode();
			}
		}
		else
		{
			Focus = CurrentBO.myBuilding.GetMCT();
			AssaultMCT();
		}
	}
	else if (CurrentBO != None && ( CurrentBO.myBuilding.GetMCT() == None || !CanAttack(CurrentBO.myBuilding.GetMCT())))
	{
		if(LastVehicle != None && LastVehicle.Driver == None)
		{
			Rx_SquadAI(Squad).GoToVehicle(LastVehicle,Self);
		}
		else if(Rx_Weapon(Pawn.Weapon).bOkAgainstBuildings && CanAttack(CurrentBO.myBuilding))
		{
			Focus = CurrentBO.myBuilding;
			FireWeaponAt(CurrentBO.myBuilding);
		}
		else if (Enemy == None)
		{
			Focus = CurrentBO.myBuilding;
		}
	}

	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));



	if(HasABeacon() && VSizeSq(CurrentBO.myBuilding.Location - Pawn.Location) < 90000)
	{
//		`log(GetHumanReadableName()@"is attempting to plant a Beacon");
		GoToState('DeployingBeacon');
		Sleep(2.0);
	}

	LatentWhatToDoNext();

}