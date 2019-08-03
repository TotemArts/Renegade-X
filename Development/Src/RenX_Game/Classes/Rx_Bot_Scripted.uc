/////////////////////////////////////////////
//
//	"Scripted Bot" by Handepsilon
//	NPC that looks like PC, only a bit more potato than RenX's first bot :D
//	Mappers can use this bot to emulate some SP/Co-op feel
//
/////////////////////////////////////////////

class Rx_Bot_Scripted extends Rx_Bot_Waypoints;


// Patrol Script Objective
var Rx_ScriptedObj_PatrolPoint PatrolTask;
var int PatrolNumber;

function InitPlayerReplicationInfo()
{
	if(PlayerReplicationInfo != none)
	{
		CleanupPRI();
	}
	PlayerReplicationInfo = Spawn(class'Rx_PRI', self);

	if (PlayerReplicationInfo != none) {
		PlayerReplicationInfo.SetPlayerTeam(WorldInfo.GRI.Teams[Owner.GetTeamNum()]);
	}
	SetTimer(0.05, false, 'CheckRadarVisibility'); 	
}

function RxInitialize(float InSkill, const out CharacterInfo BotInfo, UTTeamInfo BotTeam)
{
	local UTPlayerReplicationInfo PRI;

	Skill = FClamp(InSkill, 0, 7);


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

	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);

	if(Rx_TeamInfo(BotTeam).GetTeamName() == "GDI")
		PRI.CharClassInfo = CharInfoClass.static.FindFamilyInfo("GDI");
	else
		PRI.CharClassInfo = CharInfoClass.static.FindFamilyInfo("Nod");


//	setStrafingDisabled(true);
	SetTimer(0.5,true,'ConsiderStartSprintTimer');

	if(OurTeamAI == None)
		OurTeamAI = Rx_TeamAI(BotTeam.AI);

}

protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;


	if (Pawn == None)
	{
		// pawn got destroyed between WhatToDoNext() and now - abort
		return;
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
		if ( VSize(StartleActor.Location - Pawn.Location) < StartleRadius  )
		{
			Startle(StartleActor);
			return;
		}
	}
	bIgnoreEnemyChange = true;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
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

function ForceAssignObjective(UTGameObjective O)
{
	UTSquadAI(Squad).SetObjective(O,true);
}

function bool AssignSquadResponsibility ()
{

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

	return UTSquadAI(Squad).AssignSquadResponsibility(self);	

}

function bool StartPatrol()
{
	if(FindPatrolPath())
	{
		GoToState('Patrolling');
		return true;
	}

	return false;

}

function bool FindPatrolPath()
{
	local Actor BestPath;

	if(Enemy != None)
		return false;

	if(RouteGoal == None)
		return false;

	if(Pawn.ReachedDestination(RouteGoal))
	{
		if(PatrolNumber < PatrolTask.PatrolPoints.Length)
			PatrolNumber += 1;
		else
			PatrolNumber = 0;

		RouteGoal = PatrolTask.PatrolPoints[PatrolNumber];
	}

	if(!Pawn.ReachedDestination(MoveTarget))
		return true;

	BestPath = FindPathToward(RouteGoal);

	if(BestPath == None)
		BestPath = FindRandomDest();

	MoveTarget = BestPath;


}

state Patrolling
{


Begin:
	SwitchToBestWeapon();
	WaitForLanding();

	GoalString = "Patrolling to"@MoveTarget;

	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget),PatrolTask.bWalkingPatrol);

	LatentWhatToDoNext();
}

state Dead
{
	function BeginState(Name PreviousStateName)
	{
		Destroy();
	}
}

DefaultProperties
{
}
