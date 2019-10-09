/////////////////////////////////////////////
//
//	"Scripted Bot" by Handepsilon
//	NPC that looks like PC, only a bit more potato than RenX's first bot :D
//	Mappers can use this bot to emulate some SP/Co-op feel
//
/////////////////////////////////////////////

class Rx_Bot_Scripted extends Rx_Bot_Waypoints;


// Patrol Script Objective
var Rx_ScriptedBotSpawner MySpawner;
var Rx_ScriptedObj_PatrolPoint PatrolTask;
var int PatrolNumber;
var UTGameObjective MyObjective;
var Rx_Vehicle BoundVehicle;
var Rx_TeamInfo AssignedTeam;
var byte VRank;

function InitPlayerReplicationInfo()
{
	if(PlayerReplicationInfo != none)
	{
		CleanupPRI();
	}
	PlayerReplicationInfo = Spawn(class'Rx_PRI', self);
	Rx_PRI(PlayerReplicationInfo).bIsScripted = true;

	if (PlayerReplicationInfo != none && MySpawner != None) {
		PlayerReplicationInfo.SetPlayerTeam(WorldInfo.GRI.Teams[MySpawner.TeamIndex]);
	}
	SetTimer(0.05, false, 'CheckRadarVisibility'); 	
}

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

	if(Rx_TeamInfo(BotTeam).GetTeamName() == "GDI")
		Rx_Pawn(Pawn).CurrCharClassInfo = CharInfoClass.static.FindFamilyInfo("GDI");
	else
		Rx_Pawn(Pawn).CurrCharClassInfo = CharInfoClass.static.FindFamilyInfo("Nod");


//	setStrafingDisabled(true);
	SetTimer(0.5,true,'ConsiderStartSprintTimer');

	if(OurTeamAI == None)
		OurTeamAI = Rx_TeamAI(BotTeam.AI);

}
function ToggleBotVoice();



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
		Rx_Pawn_Scripted(Pawn).TeamNum = GetTeamNum();
	}

	if(MySpawner != None)
	{
		if(MySpawner.Skill != Skill)
		{
			Skill = MySpawner.Skill;
			ResetSkill();
		}


		bGodMode = MySpawner.bInvulnerableBots;
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
		bShortCamp = UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag;
		WanderOrCamp();
	}

		
}

function class<UTFamilyInfo> BotBuy(Rx_Bot Bot, bool bJustRespawned, optional string SpecificOrder)
{
	return Rx_PRI(PlayerReplicationInfo).CharClassInfo;
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

function Actor FaceActor(float StrafingModifier)
{
	if(Enemy != None)
		return Enemy;
	else if(Focus != None)
		return Focus;

	return MoveTarget;
}

function float GetDesiredOffset()
{
	if(Squad != None)
		return Super.GetDesiredOffset();

	else
		return 0.0;
}

function PawnDied(Pawn inPawn)
{
	local int idx;

	if ( inPawn != Pawn )
	{	// if that's not our current pawn, leave
		return;
	}

	// abort any latent actions
	TriggerEventClass(class'SeqEvent_Death',self);
	for (idx = 0; idx < LatentActions.Length; idx++)
	{
		if (LatentActions[idx] != None)
		{
			LatentActions[idx].AbortFor(self);
		}
	}
	LatentActions.Length = 0;

	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.UnPossessed();
	}
	Pawn = None;

	if(MySpawner != None)
	{
		MySpawner.NotifyPawnDeath(Self);
	}		
	Destroy();
}


// PRI Replacement functions

function SetChar(class<Rx_FamilyInfo> newFamily, optional bool isFreeClass)
{
  	Rx_Pawn_Scripted(Pawn).SetChar(newFamily, isFreeClass);
}

simulated function byte GetTeamNum()
{
	return AssignedTeam.TeamIndex;
}

function bool HasRepairGun(optional bool bMandatory)
{
	local class<UTFamilyInfo> FamInfo;

	FamInfo = Rx_Pawn_Scripted(Pawn).CurrCharClassInfo;

	if( Rx_Game(WorldInfo.Game).PurchaseSystem.DoesHaveRepairGun( FamInfo ) ) 
	{
		return true;
	}

	return false;
	
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	if(Rx_Pawn_Scripted(inPawn) != None)
		Rx_Pawn_Scripted(inPawn).TeamNum == GetTeamNum();

	super.Possess(inPawn, bVehicleTransition);
	SetRadarVisibility(RadarVisibility);
}

function ChooseAttackMode()
{
	local float EnemyStrength, WeaponRating, RetreatThreshold;

	
	if(!IsInState('Defending') && Rx_Pawn_SBH(Pawn) != None && !Rx_SquadAI(Squad).IsStealthDiscovered())
		return;

	if(Enemy != None && GetOrders() == 'Attack' && CurrentBO == None) 
	{
		if(GetTeamNum() == TEAM_GDI) 
		{
			if(Obelisk == None) 
				GetObelisk();

			if(Obelisk != None) 
			{
				if(RetreatToAvoidAO(Obelisk.location)) 
					return;
			}
		} 

		else if(GetTeamNum() == TEAM_NOD) 
		{
			if(AGT == None) 
				GetAGT();

			if(AGT != None) 
			{
				if(RetreatToAvoidAO(AGT.location)) 
				{
					return;
				}
			}
		}
	}

	GoalString = " ChooseAttackMode last seen "$(WorldInfo.TimeSeconds - LastSeenTime);
	// should I run away?
	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		`log("HERE 1 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);
	EnemyStrength = RelativeStrength(Enemy);
	if ( EnemyStrength > RetreatThreshold && (AssignedTeam != None) && (FRand() < 0.25)
		&& (WorldInfo.TimeSeconds - LastInjuredVoiceMessageTime > 45.0) )
	{
		LastInjuredVoiceMessageTime = WorldInfo.TimeSeconds;
		SendMessage(None, 'INJURED', 35);
	}
	if ( Vehicle(Pawn) != None )
	{
		VehicleFightEnemy(true, EnemyStrength);
		return;
	}
	if ( !bFrustrated && !UTSquadAI(Squad).MustKeepEnemy(Enemy) )
	{
		RetreatThreshold = Aggressiveness;
		if ( UTWeapon(Pawn.Weapon).CurrentRating > 0.5 )
			RetreatThreshold = RetreatThreshold + 0.35 - skill * 0.05;
		if ( EnemyStrength > RetreatThreshold )
		{
			GoalString = "Retreat";
			if ( (AssignedTeam != None) && (FRand() < 0.05)
				&& (WorldInfo.TimeSeconds - LastInjuredVoiceMessageTime > 45.0) )
			{
				LastInjuredVoiceMessageTime = WorldInfo.TimeSeconds;
				SendMessage(None, 'INJURED', 35);
			}
			DoRetreat();
			return;
		}
	}

	if ( (UTSquadAI(Squad).PriorityObjective(self) == 0) && (Skill + Tactics > 2) && ((EnemyStrength > -0.3) || (Pawn.Weapon.AIRating < 0.5)) )
	{
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			if ( EnemyStrength > 0.3 )
				WeaponRating = 0;
			else
				WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/2000;
		}
		else if ( EnemyStrength > 0.3 )
			WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/2000;
		else
			WeaponRating = UTWeapon(Pawn.Weapon).CurrentRating/1000;

		// fallback to better pickup?
		if ( FindInventoryGoal(WeaponRating) )
		{
			if ( PickupFactory(RouteGoal) == None )
				GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
			else
				GoalString = "Fallback to better pickup " $ RouteGoal $ " hidden " $ RouteGoal.bHidden;
			GotoState('FallBack');
			return;
		}
	}

	GoalString = "ChooseAttackMode FightEnemy";
	FightEnemy(true, EnemyStrength);
}

DefaultProperties
{
	bCanTalk = false;
	bIsPlayer = false;
}
