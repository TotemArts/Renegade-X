class Rx_Bot_Survival extends Rx_Bot_Scripted;

var float DamageTakenModifier;
var float DamageDealtModifier;
var bool bFocusOnEnemy;

function RxInitialize(float InSkill, const out CharacterInfo BotInfo, UTTeamInfo BotTeam)
{
	local UTPlayerReplicationInfo PRI;

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

	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);

	if(Rx_TeamInfo(BotTeam).GetTeamName() == "GDI")
		PRI.CharClassInfo = CharInfoClass.static.FindFamilyInfo("GDI");
	else
		PRI.CharClassInfo = CharInfoClass.static.FindFamilyInfo("Nod");


//	setStrafingDisabled(true);
	SetTimer(0.5,true,'ConsiderStartSprintTimer');

	if(OurTeamAI == None)
		OurTeamAI = Rx_TeamAI(BotTeam.AI);

	bFocusOnEnemy = FRand() > 0.25;

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
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
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
		bShortCamp = UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag;

		if(Rx_SquadAI(Squad).SquadLeader != Self)
			Rx_SquadAI(Squad).TellBotToFollow(Self,Rx_SquadAI(Squad).SquadLeader);
		else
			WanderOrCamp();
	}

		
}

function PawnDied(Pawn inPawn)
{
	if(inPawn == Pawn)
	{
		if(Rx_Game_Survival(WorldInfo.Game) != None)
		{
			Rx_Game_Survival(WorldInfo.Game).NotifyEnemyDeath(Self);
		}
	}

	Super.PawnDied(inPawn);
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