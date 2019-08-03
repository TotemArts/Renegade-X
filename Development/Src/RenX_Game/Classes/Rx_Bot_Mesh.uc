/*********************************************************
*
* File: RxBot.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/
class Rx_Bot_Mesh extends Rx_Bot
	dependson(Rx_NavUtils);


var vector NavMoveTarget; // Vector for a movetarget. 
var dynamicanchor DynA; // Dynamic Anchor. A navigation anchor(navigationpoint/actor) that is dynamic created, and will self destroy when not referenced anymore.
var array<vector> NavMoveTargetsList; // A list of movetargets. Used mainly for getting alt move locations if original location is blocked.


var transient vector LastMovePoint, IntermediatePoint, FallbackDest;
var transient int NumMovePointFails;
var int MaxMovePointFails;
/** is this AI on 'final approach' ( i.e. moving directly to it's end-goal destination )*/
var bool bFinalApproach;
/** TRUE when we are trying to get back on the mesh */
var bool bFallbackMoveToMesh,bIntermediateMoveError;
/** storage of initial desired move location */
var transient vector InitialFinalDestination;
/** location of MoveToActor last time we did pathfinding */
var BasedPosition LastMoveTargetPathLocation;
var float GoalDistance;
var transient array<vector> MovePointsList;


/** Relative locations within target's bounding cylinder to try to aim at when failed to aim at the target's location. */
	

function bool ShouldUpdateBreadCrumbs()
{
	return true;
}

function Tick( float DeltaTime )
{
	Super.Tick(DeltaTime);

	if( ShouldUpdateBreadCrumbs() )
	{
		NavigationHandle.UpdateBreadCrumbs(Pawn.Location);
	}


	//NavigationHandle.DrawBreadCrumbs();
}

event bool GeneratePathToActor( Actor Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	return class'Rx_NavUtils'.static.NavMeshFindPathToActor(pawn, Goal, WithinDistance, bAllowPartialPath);
}

event bool GeneratePathToLocation( Vector Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	return class'Rx_NavUtils'.static.NavMeshFindPathToLocation(pawn, Goal, WithinDistance, bAllowPartialPath);
}

state Dead
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Dead: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state CustomAction
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:CustomAction: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state EnteringVehicle
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:EnteringVehicle: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state Fallback
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Fallback: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state FindAir
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:FindAir: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state Frozen
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Frozen: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state FrozenMovement
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:FrozenMovement: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state Hunting
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Hunting: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// If no enemy, or I should see him but don't, then give up
		if ( (Enemy == None) || (Enemy.Health <= 0) || (Enemy.IsInvisible() && (WorldInfo.TimeSeconds - LastSeenTime > Skill)) )
		{
			LoseEnemy();
			WhatToDoNext();
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;

		if ( class'Rx_navutils'.static.GateDirectMoveTowardCheck(pawn,Enemy.Location ))
		{
			BlockedPath = None;
			if ( (LostContact(5) && (((Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) < 0))
				&& LoseEnemy() )
			{
				WhatToDoNext();
				return;
			}
			SetDestinationPosition( Enemy.Location );
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		
		if (BlockedPath != None || Rx_SquadAI(Squad).BeDevious(Enemy))
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if (  (class'Rx_navutils'.static.GateActorReachable(pawn, Enemy)))
				{
					// todo
					for ( i=0; i<RouteCache.Length; i++ )
					{
						if ( RouteCache[i] == None )
							break;
						else if ( Enemy.Controller.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = RouteCache[i];
							break;
						}
					}
					bForceRefreshRoute = true;
				}
				else if ( CanStakeOut() )
				{
					GoalString = "Stakeout from hunt";
					GotoState('StakeOut');
					return;
				}
				else if ( LoseEnemy() )
				{
					WhatToDoNext();
					return;
				}
				else
				{
					GoalString = "Retreat from hunt";
					DoRetreat();
					return;
				}
			}
			// control path weights
			if ( BlockedPath != None )
			{
				BlockedPath.TransientCost = 5000;
			}
		}
		if (!bDirectHunt)
		{
			Rx_SquadAI(Squad).MarkHuntingSpots(self);
		}
		if ( FindBestPathToward(Enemy, true, true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

		MoveTarget = None;
		if ( !bEnemyInfoValid && LoseEnemy() )
		{
			WhatToDoNext();
			return;
		}

		SetDestinationPosition( LastSeeingPos );
		bEnemyInfoValid = false;
		if ( FastTrace(Enemy.Location, ViewSpot)
			&& VSize(Pawn.Location - GetDestinationPosition()) > Pawn.CylinderComponent.CollisionRadius )
			{
				SeePlayer(Enemy);
				return;
			}

		posZ = LastSeenPos.Z + Pawn.GetCollisionHeight() - Enemy.GetCollisionHeight();
		nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CylinderComponent.CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			SetDestinationPosition( nextSpot );
		else if ( bCanSeeLastSeen )
		{
			Dir = Pawn.Location - LastSeenPos;
			Dir.Z = 0;
			if ( VSize(Dir) < Pawn.GetCollisionRadius() )
			{
				GoalString = "Stakeout 3 from hunt";
				GotoState('StakeOut');
				return;
			}
			SetDestinationPosition( LastSeenPos );
		}
		else
		{
			SetDestinationPosition( LastSeenPos );
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
				{
					if ( Pawn.Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else if ( (Pawn.Physics == PHYS_Flying) && LoseEnemy() )
				{
					WhatToDoNext();
					return;
				}
				else
				{
					GoalString = "Stakeout 2 from hunt";
					GotoState('StakeOut');
					return;
				}
			}
		}
	}
}

state InQueue
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:InQueue: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state LeavingVehicle
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:LeavingVehicle: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state MoveToGoal
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:MoveToGoal: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state MoveToGoalNoEnemy
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:MoveToGoalNoEnemy: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state MoveToGoalWithEnemy
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:MoveToGoalWithEnemy: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state Retreating
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Retreating: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state RoundEnded
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:RoundEnded: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state StakeOut
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:StakeOut: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state Startled
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Startled: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state TacticalMove
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:TacticalMove: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}

TacticalTick:
	Sleep(0.02);
Begin:
	if ( Enemy == None )
	{
		sleep(0.01);
		Goto('FinishedStrafe');
	}
	if (Pawn.Physics == PHYS_Falling)
	{
		//If the bot is an engineer and have more pressing duty....

		if (HasRepairGun() && GetNearbyDeployables(true) != None && CanAttack(DetectedDeployable))
		{	
			SwitchToBestWeapon();
			FireWeaponAt(DetectedDeployable);
		}			
		else if (HasRepairGun() && DefendedBuildingNeedsHealing() && CanAttack(CurrentBO.myBuilding))
		{
			SwitchToBestWeapon();
			Focus = CurrentBO.myBuilding.GetMCT();
		}
		else		
			Focus = Enemy;
			
		SetDestinationPosition( Enemy.Location );
		WaitForLanding();
	}
	if ( Enemy == None )
		Goto('FinishedStrafe');
	PickDestination();

DoMove:
	if ( FocusOnLeader(false) )
		MoveTo(GetDestinationPosition(), Focus);
	else if ( !Pawn.bCanStrafe )
	{
		StopFiring();
		MoveTo(GetDestinationPosition());
	}
	else
	{
DoStrafeMove:
		MoveTo(GetDestinationPosition(), Enemy);
	}
	if (Rx_Weapon_RepairGun(Pawn.Weapon) == None && bForcedDirection && (WorldInfo.TimeSeconds - StartTacticalTime < 0.2) )
	{
		if ( !Pawn.HasRangedAttack() || Skill > 2 + 3 * FRand() )
		{
			bMustCharge = true;
			LatentWhatToDoNext();
		}
		GoalString = "RangedAttack from failed tactical";
		DoRangedAttackOn(Enemy);
	}
	if ( (Enemy == None) || LineOfSightTo(Enemy) || !FastTrace(Enemy.Location, LastSeeingPos) || (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon) )
		Goto('FinishedStrafe');

RecoverEnemy:
	GoalString = "Recover Enemy";
	HidingSpot = Pawn.Location;
	StopFiring();
	Sleep(0.1 + 0.2 * FRand());
	SetDestinationPosition( LastSeeingPos + 4 * Pawn.GetCollisionRadius() * Normal(LastSeeingPos - Pawn.Location) );
	MoveTo(GetDestinationPosition(), Enemy);

	if (Rx_Weapon_RepairGun(Pawn.Weapon) == None && FireWeaponAt(Enemy))
	{
		Pawn.Acceleration = vect(0,0,0);
		if (Pawn.Weapon != None && UTWeapon(Pawn.Weapon).GetDamageRadius() > 0)
		{
			StopFiring();
			Sleep(0.05);
		}
		else
			Sleep(0.1 + 0.3 * FRand() + 0.06 * (7 - FMin(7,Skill)));
		if ( (FRand() + 0.3 > Aggression) )
		{
			Enable('EnemyNotVisible');
			SetDestinationPosition( HidingSpot + 4 * Pawn.GetCollisionRadius() * Normal(HidingSpot - Pawn.Location) );
			Goto('DoMove');
		}
	}
	else if (Rx_Weapon_RepairGun(Pawn.Weapon) != None)
	{
		if(GetNearbyDeployables(true) != None && CanAttack(DetectedDeployable))
			FireWeaponAt(DetectedDeployable);
		else if (DefendedBuildingNeedsHealing() && CanAttack(CurrentBO.myBuilding))
		{
			Focus = CurrentBO.myBuilding.GetMCT();

			if(CanAttack(CurrentBO.myBuilding.GetMCT()))
				FireWeaponAt(CurrentBO.myBuilding.GetMCT());
			else
				FireWeaponAt(CurrentBO.myBuilding);
		}
	}
FinishedStrafe:

	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN TACTICAL MOVE!");

}

state VehicleCharging
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:VehicleCharging: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

state WaitingForLanding
{
	function BeginState(name PreviousStateName)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:WaitingForLanding: Start",,'DevAI');
		super.BeginState(PreviousStateName);
	}
}

function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle;
	local bool bFarAway, bOldForcedCharge;

	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		`log("HERE 3 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);

	if(Enemy != None && Enemy.Health > 0 && bCanPlayEnemySpotted)
	{
		DetermineEnemySpotBroadcast();
	}

	if ( Vehicle(Pawn) != None )
	{
		VehicleFightEnemy(bCanCharge, EnemyStrength);
		return;
	}

	if(Skill > 4 && FRand()*Skill > 2)
		SmokeOutOn(Enemy);

	if ( Pawn.IsInPain() && FindInventoryGoal(0.0) && !bInfiltrating)
	{
	        GoalString = "Fallback out of pain volume " $ RouteGoal $ " hidden " $ RouteGoal.bHidden;
	        GotoState('FallBack');
	        return;
	}
	if ( (Enemy == FailedHuntEnemy) && (WorldInfo.TimeSeconds == FailedHuntTime) )
	{
		if(!bInfiltrating || CurrentBO == None)
		{
			GoalString = "FAILED HUNT - HANG OUT";
			if ( LineOfSightTo(Enemy) )
				bCanCharge = false;
			else
			{
				WanderOrCamp();
				return;
			}
		}
		else if (LoseEnemy())
		{
			`log(GetHumanReadableName() @ "tries to return to Rush state...");
			GoalString = "CONTINUE INFILTRATION";
			if(FindInfiltrationPath())
				return;
		}
	}

	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle + UTWeapon(Pawn.Weapon).SuggestAttackStyle();
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle - 0.5 * EnemyStrength
				+ FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));
	if ( UTWeapon(Enemy.Weapon) != None )
		Aggression += 2 * UTWeapon(Enemy.Weapon).SuggestDefenseStyle();
	if ( enemyDist > MAXSTAKEOUTDIST )
		Aggression += 0.5;
	if (Squad != None)
	{
		UTSquadAI(Squad).ModifyAggression(self, Aggression);
	}
	if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
	{
		if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE)
			Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
		else if ( (Skill < 4) && (enemyDist > 0.65 * MAXSTAKEOUTDIST) )
		{
			bFarAway = true;
			Aggression += 0.5;
		}
		else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.GetCollisionHeight()) // below enemy
			Aggression += CombatStyle;
	}

	if (!Pawn.CanAttack(Enemy))
	{
		if(bInfiltrating && CurrentBO != None && LoseEnemy() && FindInfiltrationPath())
		{
			GoalString = "CONTINUE INFILTRATION";
			return;
		}
		if ( UTSquadAI(Squad).MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		if ( !bCanCharge )
		{
			GoalString = "Stake Out - no charge";
			DoStakeOut();
		}
		else if ( UTSquadAI(Squad).IsDefending(self) && LostContact(4) && ClearShot(LastSeenPos, false) )
		{
			GoalString = "Stake Out "$LastSeenPos;
			DoStakeOut();
		}
		else if ( (((Aggression < 1) && !LostContact(3+2*FRand())) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
			DoStakeOut();
		}
		else if ( Skill + Tactics >= 3.5 + FRand() && !LostContact(1) && VSize(Enemy.Location - Pawn.Location) < MAXSTAKEOUTDIST &&
			Pawn.Weapon != None && Pawn.Weapon.AIRating > 0.5 && !Pawn.Weapon.bMeleeWeapon &&
			FRand() < 0.75 && !LineOfSightTo(Enemy) && !Enemy.LineOfSightTo(Pawn) &&
			(Squad == None || !UTSquadAI(Squad).HasOtherVisibleEnemy(self)) )
		{
			GoalString = "Stake Out 3";
			DoStakeOut();
		}
		else
		{
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	// see enemy - decide whether to charge it or strafe around/stand and fire
	BlockedPath = None;
	Focus = Enemy;

	if(IsRushing() && bInfiltrating && CurrentBO != None)
	{
		GoalString = "CONTINUE INFILTRATION";
		if(!IsInRushState() && FindInfiltrationPath())
			return;
	}
	if( Pawn.Weapon.bMeleeWeapon || (bCanCharge && bOldForcedCharge) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}
	if ( Pawn.RecommendLongRangedAttack() )
	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge && (Skill < 5) && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{
		GoalString = "Charge closer";
		DoCharge();
		return;
	}

	if ( UTWeapon(Pawn.Weapon).RecommendRangedAttack() || IsSniping() || ((FRand() > 0.17 * (skill + Tactics - 1)) && !DefendMelee(enemyDist)) )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge )
	{
		if ( Aggression > 1 )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}
	GoalString = "Do tactical move";
	if ( !UTWeapon(Pawn.Weapon).bRecommendSplashDamage && (FRand() < 0.7) && (3*Jumpiness + FRand()*Skill > 3) )
	{
		GetAxes(Pawn.Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else
			TryToDuck(Y, false);
	}
	DoTacticalMove();
}

function VehicleFightEnemy(bool bCanCharge, float EnemyStrength)
{
	local UTVehicle V;

	V = UTVehicle(Pawn);
	if (V != None && V.bShouldLeaveForCombat)
	{
		LeaveVehicle(true);
		return;
	}
	if(IsRushing() && Rx_SquadAI(Squad).CurrentTactics != None && Rx_SquadAI(Squad).bTacticsCommenced && Rx_SquadAI(Squad).CurrentTactics.bIsRush)
	{
		if(CanAttack(Enemy) && (!IsInRushState() || !IsInState('VehicleRushEnemy')))
				GoToState('VehicleRushEnemy');
		return;
	}
	if ((Pawn.bStationary || (UTWeaponPawn(Pawn) != None) || V.bKeyVehicle ) && CanAttack(Enemy))
	{
		if ( !LineOfSightTo(Enemy) )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else
		{
			DoRangedAttackOn(Enemy);
		}
		return;
	}

	if ( !bFrustrated && Pawn.HasRangedAttack() && Pawn.TooCloseToAttack(Enemy) )
	{
		GoalString = "Retreat";
		DoRetreat();
		return;
	}
	if ( (Enemy == FailedHuntEnemy && WorldInfo.TimeSeconds == FailedHuntTime) || V.bKeyVehicle )
	{
		GoalString = "FAILED HUNT - HANG OUT";
		if ( Pawn.HasRangedAttack() && LineOfSightTo(Enemy) )
			DoRangedAttackOn(Enemy);
		else
			WanderOrCamp();
		return;
	}
	if ( !LineOfSightTo(Enemy) )
	{
		if ( UTSquadAI(Squad).MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		if ( !bCanCharge || (UTSquadAI(Squad).IsDefending(self) && LostContact(4)) )
		{
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else if ( ((Aggression < 1) && !LostContact(3+2*FRand()) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
			DoStakeOut();
		}
		else
		{
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	BlockedPath = None;
	Focus = Enemy;

	if ( V.RecommendCharge(self, Enemy) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}

	if ( Pawn.bCanFly && !Enemy.bCanFly && (Pawn.Weapon == None || VSize(Pawn.Location - Enemy.Location) < Pawn.Weapon.MaxRange()) &&
		(FRand() < 0.17 * (skill + Tactics - 1)) )
	{
		GoalString = "Do tactical move";
		DoTacticalMove();
		return;
	}

	if ( Pawn.RecommendLongRangedAttack() )
	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}
	GoalString = "Charge";
	DoCharge();
}

state Charging
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function MayFall(bool bFloor, vector FloorNormal)
	{
		if ( MoveTarget != Enemy )
			return;

		Pawn.bCanJump = ActorReachable(Enemy);
		if ( !Pawn.bCanJump )
			MoveTimer = -1.0;
	}

	function bool TryToDuck(vector duckDir, bool bReversed)
	{
		if ( !Pawn.bCanStrafe )
			return false;
		if ( FRand() < 0.6 )
			return Global.TryToDuck(duckDir, bReversed);
		if ( MoveTarget == Enemy )
			return TryStrafe(duckDir);
		return false;
	}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		local vector sideDir;

		if ( Enemy == None || FRand() * Damage < 0.15 * CombatStyle * Pawn.Health )
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
		if ( (Pawn.Velocity Dot sidedir) > 0 )
			sidedir *= -1;

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{
		local vector extent, hitLoc, hitNorm;
		local actor hitActor;

		Extent = Pawn.GetCollisionRadius() * vect(1,1,0);
		Extent.Z = Pawn.GetCollisionHeight();
		HitActor = Trace(HitLoc, HitNorm, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLoc, HitNorm, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		}
		if (HitActor != None)
			return false;

		if ( Pawn.Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLoc, HitNorm, Pawn.Location + MINSTRAFEDIST * sideDir - Pawn.MaxStepHeight * vect(0,0,1), Pawn.Location + MINSTRAFEDIST * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		SetDestinationPosition( Pawn.Location + 2 * MINSTRAFEDIST * sideDir );
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}

	function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		local float pick;
		local vector sideDir;
		local bool bWasOnGround;

		Global.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		LastUnderFire = WorldInfo.TimeSeconds;

		bWasOnGround = (Pawn.Physics == PHYS_Walking);
		if ( Pawn.health <= 0 )
			return;
		if ( StrafeFromDamage(damage, damageType, true) )
			return;
		else if ( bWasOnGround && (MoveTarget == Enemy) &&
					(Pawn.Physics == PHYS_Falling) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Pawn.Velocity += pick * Pawn.GroundSpeed * 0.7 * sideDir;
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}

	event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		if ( (Other == Enemy)
			&& (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && (FRand() > 0.4 + 0.1 * skill) )
		{
			DoRangedAttackOn(Enemy);
			return false;
		}
		return Global.NotifyBump(Other,HitNormal);
	}

	function Timer()
	{
		Focus = Enemy;
		TimedFireWeaponAtEnemy();
	}

	function EnemyNotVisible()
	{
		WhatToDoNext();
	}

	function EndState(Name NextStateName)
	{
		if ( (Pawn != None) && Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
	}

Begin:
	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Charging: Start",,'DevAI');
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		SetDestinationPosition( Enemy.Location );
		WaitForLanding();
	}
	if ( Enemy == None )
		LatentWhatToDoNext();
	if ( !FindBestPathToward(Enemy, false,true) )
		DoTacticalMove();
Moving:
	if ( Pawn.Weapon.bMeleeWeapon ) // FIXME HACK
		FireWeaponAt(Enemy);
	//if(class'Rx_NavUtils'.static.GateDirectMoveTowardCheck(pawn,MoveTarget))
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

/**
 * Simple scripted movement state, attempts to pathfind to ScriptedMoveTarget and
 * returns execution to previous state upon either success/failure.
 */
state ScriptedMove
{

	final function float GetMoveDestinationOffset()
	{
		// return a negative destination offset so we get closer to our points (yay)
		if( bFinalApproach )
		{
			return GoalDistance;
		}
		else
		{
			return (0-pawn.GetCollisionRadius());
		}
	}

	final function bool GetNextMove(out vector loc)
	{
		local float neededDist;

		`LogRx("(" $ name $ ")" @GetPackageName()@GetFuncName()@"Getting Next Move location. I'm at:"@Location);

		neededDist = pawn.GetCollisionRadius() * 0.1f;
		`LogRx("(" $ name $ ")" @GetPackageName()@GetFuncName()@`showvar(neededDist));
		if(navigationhandle.GetNextMoveLocation(loc, pawn.GetCollisionRadius()))
		{
			
			`LogRx("(" $ name $ ")" @GetPackageName()@GetFuncName()@"Distance to returned location"@ VSize(loc-Location));

			`LogRx("(" $ name $ ")" @GetPackageName()@GetFuncName()@"Returning getnextmovelocation result");
			
			drawdebugline(Location, loc, 0,255,0, true);
			drawdebugsphere(loc, 16, 20, 0,255,0, true);
			
			return true;
		}
		else
			return false;
	}

CheckMove:
	//debug
	`LogRx("(" $ Pawn.name $ ")"@GetPackageName()@GetFuncName()@"CHECKMOVE TAG");

	if( class'Rx_NavUtils'.static.HasReachedGoal(pawn, ScriptedMoveTarget, GoalDistance, bFinalApproach) )
	{
		Goto( 'ReachedGoal' );
	}

Begin:
	`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" BEGIN TAG"@GetStateName());

	drawdebugline(pawn.Location,  ScriptedMoveTarget.Location, 255,255,0, true);
	drawdebugsphere(ScriptedMoveTarget.Location, 16, 20, 255,255,0, true);

	bIntermediateMoveError = false;

	InitialFinalDestination = ScriptedMoveTarget.GetDestination(self);

	if( bFallbackMoveToMesh )
	{
		`LogRx("(" $ Pawn.name $ ")" @GetPackageName()@GetFuncName()@"Going into breadcrumb fallback state to get back onto navmesh CurLoc:"@Pawn.Location);
		GotoState('Fallback_Breadcrumbs');
	}
	if( !NavigationHandle.ComputeValidFinalDestination(InitialFinalDestination) )
		
	{
		`LogRx("(" $ Pawn.name $ ")" @GetPackageName()@GetFuncName()@"ABORTING! Final destination"@InitialFinalDestination@"is not reachable! (ComputeValidFinalDestination returned FALSE)");
		GotoState('DelayFailure');
	}
	else if( !NavigationHandle.SetFinalDestination(InitialFinalDestination) )
	{
		`LogRx("(" $ Pawn.name $ ")" @GetPackageName()@GetFuncName()@"ABORTING! Final destination"@InitialFinalDestination@"is not reachable! (SetFinalDestination returned FALSE)");
		GotoState('DelayFailure');
	}

	drawdebugline(pawn.Location, BP2Vect(NavigationHandle.FinalDestination), 255,0,0, true);
	drawdebugsphere(BP2Vect(NavigationHandle.FinalDestination), 16, 20, 255,0,0, true);

	navigationhandle.bDebugConstraintsAndGoalEvals = true;
	//navigationhandle.bUltraVerbosePathDebugging = true;
	//navigationhandle.bVisualPathDebugging = true;

	if( NavigationHandle.PointReachable(BP2Vect(NavigationHandle.FinalDestination)) )
	{
		`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" ScriptedMoveTarget is directly reachable");
		IntermediatePoint = BP2Vect(NavigationHandle.FinalDestination);
	}
	else
	{
		if( !GeneratePathToLocation( BP2Vect(NavigationHandle.FinalDestination),GoalDistance, false ) )
		{
			//debug
			`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Couldn't generate path to location"@BP2Vect(NavigationHandle.FinalDestination)@"from"@Pawn.Location);
			`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@`ShowVar(navigationhandle.LastPathError));

			`LogRx("Retrying with mega debug on");
			NavigationHandle.bDebugConstraintsAndGoalEvals = TRUE;
			//NavigationHandle.bUltraVerbosePathDebugging = TRUE;
			GeneratePathToLocation( BP2Vect(NavigationHandle.FinalDestination),GoalDistance, TRUE );
			Sleep(1.0f);
			Goto( 'FailedMove' );
		}

		//debug
		`LogRx( "(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Generated path..." );
		`LogRx( "(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Found path!" @ `showvar(BP2Vect(NavigationHandle.FinalDestination)), 'Move' );

		navigationhandle.DrawPathCache(,True);

		//IntermediatePoint = navigationhandle.GetFirstMoveLocation();

		if( !GetNextMove( IntermediatePoint) )		
		{
			//debug
			`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Generated path, but couldn't retrieve next move location?");

			Goto( 'FailedMove' );
		}
	}

	if( ScriptedMoveTarget != None )
	{
		Vect2BP(LastMoveTargetPathLocation, ScriptedMoveTarget.Location);
	}

	while( TRUE )
	{
		if(bIntermediateMoveError)
			Goto('Begin');
		else
			`LogRx( "(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Still moving to"@IntermediatePoint );

		bFinalApproach = VSizeSq(IntermediatePoint - BP2Vect(NavigationHandle.FinalDestination)) < 1.0;
		
		`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Calling MoveTo -- "@IntermediatePoint);
		// if on our final move to an Actor, send it in directly so we account for any movement it does
		if( (bFinalApproach) && ScriptedMoveTarget != None )
		{
			`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@"  - Final approach to" @ ScriptedMoveTarget $ ", using MoveToward()");
			Vect2BP(LastMoveTargetPathLocation, ScriptedMoveTarget.GetDestination(self));
			NavigationHandle.SetFinalDestination(ScriptedMoveTarget.GetDestination(self));
			//if(Scriptedmovetarget.bStatic)
				//MoveToDirectNonPathPos(ScriptedMoveTarget.Location, ScriptedFocus, GetMoveDestinationOffset(), false);
			//else
				MoveToward(scriptedmovetarget, ScriptedFocus, GetMoveDestinationOffset(), FALSE);
		}
		else
		{
			// if we weren't given a focus, default to looking where we're going
			SetFocalPoint(IntermediatePoint);

			if(!navigationhandle.SuggestMovePreparation(IntermediatePoint, self)) //if true, the edge will handle the move for us.
			{
				drawdebugline(pawn.Location, IntermediatePoint, 127,255,0, true);
				drawdebugsphere(IntermediatePoint, 16, 20, 127,255,0, true);

				// use a negative offset so we get closer to our points!
				`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" MoveTo -- "@IntermediatePoint);
				//SanitiseNextPath(IntermediatePoint);
				MoveTo(IntermediatePoint, ScriptedFocus, GetMoveDestinationOffset());
			}
		}
		`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" MoveTo Finished -- "@IntermediatePoint);

// 				if( bReevaluatePath )
// 				{
// 					ReEvaluatePath();
// 				}

		if( class'Rx_NavUtils'.static.HasReachedGoal(pawn, ScriptedMoveTarget, GoalDistance, bFinalApproach) )
		{
			`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@"HasReachedGoal() returned true");
			Goto( 'CheckMove' );
		}
		// if we are moving towards a moving target, repath every time we successfully reach the next node
		// as that Pawn's movement may cause the best path to change
		else if( ScriptedMoveTarget != None &&
			VSize(ScriptedMoveTarget.Location - BP2Vect(LastMoveTargetPathLocation)) > 512.0 )
		{
			Vect2BP(LastMoveTargetPathLocation, ScriptedMoveTarget.location);
			`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Repathing because target moved:" @ ScriptedMoveTarget);
			Goto('CheckMove');
		}
		else if( !GetNextMove(IntermediatePoint) )
		{
			`LogRx( "(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Couldn't get next move location" );
			if (!bFinalApproach && ((ScriptedMoveTarget != None) ? /*NavigationHandle.*/ActorReachable(ScriptedMoveTarget) : /*NavigationHandle.*/PointReachable(BP2Vect(NavigationHandle.FinalDestination))))
			{
				`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@"Target is directly reachable; try direct move");
				IntermediatePoint =((ScriptedMoveTarget != None) ? ScriptedMoveTarget.location : BP2Vect(NavigationHandle.FinalDestination));
				Sleep(RandRange(0.1,0.175));
			}
			else
			{
				Sleep(0.1f);
				`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" GetNextMoveLocation returned false, and finaldest is not directly reachable");

				Goto('FailedMove');
			}
		}
		else
		{
			if(VSize(IntermediatePoint-LastMovePoint) < (Pawn.GetCollisionRadius() * 0.1f) )
			{
				NumMovePointFails++;

				DrawDebugBox(Pawn.Location, vect(2,2,2) * NumMovePointFails, 255, 255, 255, true );
				`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" WARNING: Got same move location... something's wrong?!"@`showvar(LastMovePoint)@`showvar(IntermediatePoint)@"Delta"@VSize(LastMovePoint-IntermediatePoint)@"ChkDist"@(Pawn.GetCollisionRadius() * 0.1f));
			}
			else
			{
				NumMovePointFails=0;
			}
			LastMovePoint = IntermediatePoint;

			if(NumMovePointFails >= MaxMovePointFails && MaxMovePointFails >= 0)
			{
				`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" ERROR: Got same move location 5x in a row.. something's wrong! bailing from this move");
				Goto('FailedMove');
			}
			else
			{
				//debug
				`LogRx( "(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" NextMove"@IntermediatePoint@`showvar(NumMovePointFails) );
			}
		}
	}

	//debug
	`LogRx( "(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Reached end of move loop??" );

	Goto( 'CheckMove' );	

FailedMove:

	`LogRx( "(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Failed move.  Now ZeroMovementVariables" );

	drawdebugline(pawn.Location, ScriptedMoveTarget.Location,255,0,0,true);
	drawdebugline(pawn.Location, BP2Vect(NavigationHandle.FinalDestination),0,0,255,true);

	MoveTo(Pawn.Location);
	Pawn.ZeroMovementVariables();
	GotoState('DelayFailure');

ReachedGoal:
	//debug
	`LogRx("(" $ Pawn.name $ ")" @ GetPackageName()@GetFuncName()@" Reached move point:"@BP2Vect(NavigationHandle.FinalDestination)@VSize(Pawn.Location-BP2Vect(NavigationHandle.FinalDestination)));

	navigationhandle.ClearConstraints();
	navigationhandle.PathCache_Empty();

	Popstate();
}

state DelayFailure
{
	function bool HandlePathObstruction(Actor BlockedBy);
	
Begin:
	Sleep( 0.5f );

}

 /* this state will follow our breadcrumbs backward until we are back in the mesh, and then transition back to moving, or go to other fallback states
 * if we run out of breadcrumbs and are not yet back in the mesh
 */
state Fallback_Breadcrumbs
{

	function bool ShouldUpdateBreadCrumbs()
	{
		return false;
	}

	function bool HandlePathObstruction(Actor BlockedBy)
	{
		Pawn.SetLocation(IntermediatePoint);
		MoveTimer=-1;
		GotoState('Fallback_Breadcrumbs','Begin');
		return true;
	}

Begin:
`LogRx("trying to move back along breadcrumb path");
	if( NavigationHandle.GetNextBreadCrumb(IntermediatePoint) )
	{
		`LogRx("Moving to breadcrumb pos:"$IntermediatePoint);
// 		GameAIOwner.DrawDebugLine(Pawn.Location,IntermediatePoint,255,0,0,TRUE);
// 		GameAIOwner.DrawDebugLine(IntermediatePoint+vect(0,0,100),IntermediatePoint,255,0,0,TRUE);

		MoveToDirectNonPathPos(IntermediatePoint);

		if( !NavigationHandle.IsAnchorInescapable() )
		{
			GotoState('ScriptedMove');
		}
		Sleep(0.1);
		Goto('Begin');
	}
	else if( !NavigationHandle.IsAnchorInescapable())
	{
		GotoState('ScriptedMove','Begin');
	}
	else
	{
		GotoState('Fallback_FindNearbyMeshPoint');
	}

}

state Fallback_FindNearbyMeshPoint
{
	function bool FindAPointWhereICanMoveTo( out Vector out_FallbackDest, float Inradius, optional float minRadius=0, optional float entityRadius = 32, optional bool bDirectOnly=true, optional int MaxPoints=-1,optional float ValidHitBoxSize)
	{
		local Vector Retval;
		local array<vector> poses;
//		local int i;
		local vector extent;
		local vector validhitbox;

		Extent.X = entityRadius;
		Extent.Y = entityRadius;
		Extent.Z = entityRadius;

		validhitbox = vect(1,1,1) * ValidHitBoxSize;
		NavigationHandle.GetValidPositionsForBox(Pawn.Location,Inradius,Extent,bDirectOnly,poses,MaxPoints,minRadius,validhitbox);
// 		for(i=0;i<Poses.length;++i)
// 		{
// 			DrawDebugStar(poses[i],55.f,255,255,0,TRUE);
// 			if(i < poses.length-1 )
// 			{
// 				DrawDebugLine(poses[i],poses[i+1],255,255,0,TRUE);
// 			}
// 		}

		if( poses.length > 0)
		{
			Retval = Poses[Rand(Poses.Length)];

			// if for some reason we have a 0,0,0 vect that is never going to be correct
			if( VSize(Retval) == 0.0f )
			{
				out_FallbackDest = vect(0,0,0);
				return FALSE;
			}

			`LogRx( `showvar(Retval) );
			out_FallbackDest = Retval;
			return TRUE;
		}

		out_FallbackDest = vect(0,0,0);
		return FALSE;
	}


	function bool ShouldUpdateBreadCrumbs()
	{
		return false;
	}

Begin:

	`LogRx( "Fallback! We now try MoveTo directly to a point that is avail to us" );

			
	if( !FindAPointWhereICanMoveTo( FallbackDest, 2048 ) )
	{
		pawn.Destroy();
	}
	else
	{
		MoveToDirectNonPathPos( FallbackDest );
		Sleep( 0.5f );

		if( bFallbackMoveToMesh )
		{
			GotoState('DelaySuccess');
		}
		else
		{
			GotoState('ScriptedMove','Begin');
		}
	}
}


function bool ShouldFireAgain()
{
	local Rx_Weapon_Reloadable RxWeap;
	local float Rand;

	RxWeap = Rx_Weapon_Reloadable(Pawn.Weapon);
	if( RxWeap != none )
	{
		if( RxWeap.CurrentlyReloading )
		{
			if(Pawn.IsFiring())
				StopFiring();
			return false;
		}
		if(RxWeap.RecoilSpreadIncreasePerShot != 0.0) {
			if(Enemy != None && RxWeap.Recoilspread > 0.0 && VSize(Enemy.location - Pawn.location) > 200) {
				Rand = FRand();
				if(Rand < 0.1 || (Rand > 0.6 && RxWeap.CurrentSpread >= RxWeap.MaxSpread)) {
					if(Pawn.IsFiring())
						StopFiring();
					return false;
				}
			}
		}
	} else if(Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon) != None && Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon).CurrentlyReloading)
	{
		if(Pawn.IsFiring())
			StopFiring();
		return false;	
	}
	return super.ShouldFireAgain();
}

event NotifyFallingHitWall( vector HitNormal, actor HitActor)
{
	bNotifyFallingHitWall = false;
}

function bool TryWallDodge(vector HitNormal, actor HitActor)
{
	// no wall dodging in our game
}

function ResetSkill()
{
	super.ResetSkill();
	DodgeToGoalPct = 0; // since our dodges dont get you to a goal faster the bots should not try to do that
}

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local Rx_Pawn rxPawn;
	if(Rx_Pawn(Pawn) != None) {
		rxPawn = Rx_Pawn(Pawn);
		if(rxPawn.bDodging || !rxPawn.bDodgeCapable || rxPawn.Physics != Phys_Walking) {
			if ( Stopped() )
				GotoState('TacticalMove');
			return false;
		}
	}
	return super.TryToDuck(duckDir, bReversed);
}

function bool CanImpactJump() {
	return false;
}

function TimedFireWeaponAtFocus()
{
	bResetCombatTimer = false;
	if (Focus == None || FireWeaponAt(Focus))
	{
		if (!bResetCombatTimer)
		{
			SetCombatTimer();
		}
	}
	else if (!bResetCombatTimer)
	{
		SetTimer(0.1, true);
	}
}

state RangedAttack
{
	
	function bool WeaponFireAgain(bool bFinishedFire)
	{
		local bool ret;
		ret = global.WeaponFireAgain(bFinishedFire);
		if(!ret && UTVehicle(Pawn) != None && !bPreparingMove 
			&& NavigationPoint(RouteGoal) != None 
			&& (WorldInfo.TimeSeconds - lastFindStrafeDestTime > 1 + Rand(2))
			&& (Pawn.ReachedDestination(RouteGoal) 
				|| (Pawn.Acceleration == vect(0,0,0) 
					&& Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon) != None
					&& !Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon).CurrentlyReloading 
					&& VSize(pawn.Velocity) < 5.0 
					&& MoveTimer < 23))) 
		{
			if (FindStrafeDest())
			{
				GotoState(,'FindStrafeDest');
			}			
		}
		return ret;
	}

    function StopFiring()
    {
		if ( !(Pawn != None && Focus != None && Pawn(Focus) != None && Pawn(Focus).Health <= 0)
					 && Pawn.RecommendLongRangedAttack() && Pawn.IsFiring() ) {
            return;
        }
        Global.StopFiring();
        if ( bHasFired )
        {
            if ( IsSniping() && !WorldInfo.bUseConsoleInput )
            {
                Pawn.bWantsToCrouch = (Skill > 2);
            }
            else
            {
                bHasFired = false;
                WhatToDoNext();
            }
        }
    }
	
	function bool FindStrafeDestForHealingPlayer() {
		local float Dist;
		local int Start, i;
		local NavigationPoint Nav;
		local Rx_Weapon RxWeap;

		if (!Pawn.bCanStrafe || Pawn.Weapon == None)
		{
			return false;
		}

		RxWeap = Rx_Weapon(Pawn.Weapon);
		// get on path network if not already
		if (!Pawn.ValidAnchor())
		{
			Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
			if (Pawn.Anchor == None)
			{
				// can't get on path network
				return false;
			}
			else
			{
				if (Dist > Pawn.CylinderComponent.CollisionRadius)
				{
					if ( RxWeap.CanAttackFromPosition(Pawn.Anchor.location, Focus) )
					{
						if(Pawn.Anchor != MoveTarget)
							MoveTarget = Pawn.Anchor;
						return true;
					}
					else
					{
						// can't shoot target from best anchor
						return false;
					}
				}
			}
		}
		else if (Pawn.Anchor.PathList.length > 0)
		{
			// pick a random point linked to anchor that we can shoot target from
			Start = Rand(Pawn.Anchor.PathList.length);
			i = Start;
			do
			{
				if (!Pawn.Anchor.PathList[i].IsBlockedFor(Pawn))
				{
					Nav = Pawn.Anchor.PathList[i].GetEnd();
					if (Nav != Focus && !Nav.bSpecialMove && !Nav.IsA('Teleporter'))
					{
						// allow points within range, that aren't significantly backtracking unless allowed,
						// and that we can still hit target from
						Dist = VSize(Nav.Location - Focus.Location);
						if ( RxWeap.CanAttackFromPosition(Nav.location, Focus) )
						{
							if(Pawn.Anchor != Nav)
								MoveTarget = Nav;
							return true;
						}
					}
				}
				i++;
				if (i == Pawn.Anchor.PathList.length)
				{
					i = 0;
				}
			} until (i == Start);
		}

		return false;
	}
	
	
	function bool FindStrafeDest()
	{
		local float Dist, TargetDist, MaxRange;
		local int Start, i;
		local bool bAllowBackwards;
		local NavigationPoint Nav;
		local UTWeapon UTWeap;
		local bool bOkStrafeSpot;
		
		lastFindStrafeDestTime = WorldInfo.TimeSeconds;
		if(Vehicle(Pawn) == None) {
			return super.FindStrafeDest();
		}
		if(Vehicle(Pawn) != None) {
			StrafingAbility = 1;	
		} else if(IsHealing(false)) {
			return FindStrafeDestForHealingPlayer();
		} else {
			return super.FindStrafeDest();
		}
		if (!Pawn.bCanStrafe || Pawn.Weapon == None || Skill + StrafingAbility < 1.5 + 3.5 * FRand())
		{
			// can't strafe, no weapon to check distance with or not skilled enough
			return false;
		}

		UTWeap = UTWeapon(Pawn.Weapon);
		MaxRange = (UTWeap != None ? UTWeap.GetOptimalRangeFor(Focus) : Pawn.Weapon.MaxRange());
		// get on path network if not already
		if (!Pawn.ValidAnchor())
		{
			Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
			if (Pawn.Anchor == None)
			{
				// can't get on path network
				return false;
			}
			else
			{
				Dist = VSize(Pawn.Anchor.Location - Focus.Location);
				bOkStrafeSpot = Dist <= MaxRange;
				if(bOkStrafeSpot) {
					bOkStrafeSpot = FastTrace(Focus.Location, Pawn.Anchor.Location);
				}
				if(bOkStrafeSpot && UTVehicle(Pawn) != None) {
					if(VolumePathNode(Pawn.Anchor) != None && !UTVehicle(Pawn).bCanFly) {
						bOkStrafeSpot = false;
					} else {
						bOkStrafeSpot = NavBlockedByVeh(Pawn.Anchor);
					}
				}
				if (bOkStrafeSpot )
				{
					if(Pawn.Anchor != MoveTarget)
						MoveTarget = Pawn.Anchor;
					return true;
				}
				else
				{
					// can't shoot target from best anchor
					//`log("Failed to move cause Anchor failed. Have"@Pawn.Anchor.PathList.length@"Paths"); 
				}
			}
		} 
		
		if (Pawn.Anchor.PathList.length > 0)
		{
			TargetDist = VSize(Focus.Location - Pawn.Location);
			// consider backstep opposed to always charging if enemy objective, depending on combat style and weapon
			if (!WorldInfo.GRI.OnSameTeam(Focus, self))
			{
				bAllowBackwards = (CombatStyle + (UTWeap != None ? UTWeap.SuggestAttackStyle() : 0.0) <= 0.0);
				//bAllowBackwards = false;
				//loginternal(bAllowBackwards);
			}
			// pick a random point linked to anchor that we can shoot target from
			Start = Rand(Pawn.Anchor.PathList.length);
			i = Start;
			do
			{
				if (!Pawn.Anchor.PathList[i].IsBlockedFor(Pawn))
				{
					Nav = Pawn.Anchor.PathList[i].GetEnd();
					if (Nav != Focus && !Nav.bSpecialMove && !Nav.IsA('Teleporter'))
					{
						// allow points within range, that aren't significantly backtracking unless allowed,
						// and that we can still hit target from
						Dist = VSize(Nav.Location - Focus.Location);
						
						//======================
						bOkStrafeSpot = FastTrace(Focus.Location, Nav.Location);
						bOkStrafeSpot = !Nav.bBlocked;
						if(bOkStrafeSpot && Rx_BuildingObjective(Squad.SquadObjective) == None && NavCanBeHitByAO(Nav)) {
							bOkStrafeSpot = false;	
						}
						
						if(bOkStrafeSpot && UTVehicle(Pawn) != None) {
							if(VolumePathNode(Nav) != None && !UTVehicle(Pawn).bCanFly) {
								bOkStrafeSpot = false;
							} else {							
								bOkStrafeSpot = NavBlockedByVeh(Nav);
							}
						}
						if ( (Dist <= MaxRange || Dist < TargetDist) && (bAllowBackwards || Dist <= TargetDist + 100.0) &&
							bOkStrafeSpot )
						{
							if(Pawn.Anchor != Nav)
								MoveTarget = Nav;
							return true;
						}
					}
				}
				i++;
				if (i == Pawn.Anchor.PathList.length)
				{
					i = 0;
				}
			} until (i == Start);
		}

		return false;
	}

Begin:
	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:RangedAttack: Start",,'DevAI');
	bHasFired = false;
	
	if(Focus != Enemy && Rx_Vehicle(Focus) != None && !Rx_Vehicle(Focus).NeedsHealing() && isHealing(true)) {
		sleep(0.2);
		SetCombatTimer();
        StopFiring();
		LatentWhatToDoNext();
	}
	
	if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon 
			|| (Rx_Weapon_RepairGun(Pawn.Weapon) == None && IsHealing(true)) )
		SwitchToBestWeapon();		
	GoalString = GoalString@"Ranged attack";
	Sleep(0.0);
	if ( (Focus == None) || Focus.bDeleteMe )
		LatentWhatToDoNext();
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( Pawn.NeedToTurn(GetFocalPoint()) )
	{
		FinishRotation();
	}
	bHasFired = true;
	if(CantAttackCheckCount > 10) {
		CantAttackCheckCount = 0;
	} else {
		if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
		else if (Focus != None && (Rx_Building(Focus) != None || UTVehicle(Focus) != None)) 
			TimedFireWeaponAtFocus();
		else
			FireWeaponAt(Focus);	
	}	
	Sleep(0.1);
	if ( ((Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon) || (Focus == None) || ((Focus != Enemy) 
			&& (UTGameObjective(Focus) == None) 
			&& (Rx_Building(Focus) == None)
			&& (Enemy != None) && LineOfSightTo(Enemy)) )
		LatentWhatToDoNext();
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if (FindStrafeDest())
	{
FindStrafeDest:	
		GoalString = GoalString $ ", strafe to" @ MoveTarget;
		if(UTVehicle(Pawn) != None) {
				//if(class'Rx_NavUtils'.static.GateDirectMoveTowardCheck(pawn, MoveTarget))
					MoveToward(MoveTarget, Focus,, false, false);
		} else {
			if(class'Rx_NavUtils'.static.GateDirectMoveTowardCheck(pawn, MoveTarget.Location))
				MoveToward(MoveTarget, Focus,, true, false);
		}
		StopMovement();
	}
	else
	{
		Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	}
LatentWhatToDoNextRangedAttack:	
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
	GoalString = "STUCK IN RANGEDATTACK!";
}

function MoveToDefensePoint()
{	
	if(DetectedDeployable != None || DefendedBuildingNeedsHealing())
		GotoState('Defending', 'Begin');
	else
		GoToState('Patrolling','Begin');
}

state Defending
{
	function BeginState(Name PreviousStateName)
	{
		bShortCamp = (Vehicle(Pawn) == None);
		super.BeginState(PreviousStateName);
		
	}

	event WhatToDoNext() 
	{
		if(IsHealing(true) && DefendedBuildingNeedsHealing() && HasRepairGun(true)) 
		{

			if(UTVehicle(Pawn) != None && Enemy == None && CurrentBO.IsCritical()) 
			{
				UTVehicle(Pawn).DriverLeave(false);
			}
		} 

		Global.WhatToDoNext();

	}	
	function SetRouteGoal()
	{		
		local bool bCanDetour;
		local Rx_SquadAI UTSquad;

		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Defending.SetRouteGoal(): Start" ,,'DevAI');

		bShortCamp = (Vehicle(Pawn) == None);
		UTSquad = Rx_SquadAI(Squad);

		if (DefensePoint == None || UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag )
		{
			// if in good position, tend to stay there
			if ( (WorldInfo.TimeSeconds - FMax(LastSeenTime, AcquireTime) < 5.0 || FRand() < 0.85)
				&& DefensivePosition != None && Pawn.ReachedDestination(DefensivePosition)
				&& UTSquad.AcceptableDefensivePosition(DefensivePosition, self) )
			{
				CampTime = 3;
				GotoState('Defending','Pausing');
			}
			DefensivePosition = UTSquad.FindDefensivePositionFor(self);
			if ( DefensivePosition == None )
			{
				RouteGoal = UTSquad.FormationCenter(self);
			}
			else
			{
				RouteGoal = DefensivePosition;
			}
		}
		else
			RouteGoal = DefensePoint;

		if ( RouteGoal != None )
		{
			bCanDetour = (Vehicle(Pawn) == None) || (UTVehicle_Hoverboard(Pawn) != None);
			If(class'Rx_NavUtils'.static.GateDirectMoveTowardCheck(pawn, RouteGoal.Location))
				MoveTarget = RouteGoal;
			else
			{
				If(!class'Rx_NavUtils'.static.NavMeshFindPathToActor(pawn, RouteGoal) && (FindPathToward(RouteGoal, bCanDetour) == none))
				{
					if ( (DefensePoint != None) && (UTHoldSpot(DefensePoint) == None) )
						FreePoint();
					DefensivePosition = UTSquad.FindDefensivePositionFor(self);
					if ( DefensivePosition == None )
					{
						RouteGoal = UTSquad.FormationCenter(self);
					}
					else
					{
						RouteGoal = DefensivePosition;
					}

					If(!class'Rx_NavUtils'.static.NavMeshFindPathToActor(pawn, RouteGoal) && (FindPathToward(RouteGoal, bCanDetour) == none))
					{
						CampTime = 3;
						GotoState('Defending','Pausing');
					}
				}
			}
		}

		Focus = RouteGoal;
		MoveTarget = RouteGoal;
	}	

	function FindPathToBeacon()
	{
		local Actor NextMoveTarget;

		if(RouteGoal == DetectedDeployable && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
			return;


		bShortCamp = (Vehicle(Pawn) == None);
			
		RouteGoal = DetectedDeployable;

	NavigationHandle.SetFinalDestination(RouteGoal.Location);

		class'Rx_NavUtils'.static.GatePathFindActor(pawn, RouteGoal, NextMoveTarget);
			
		if(NextMoveTarget == None && !CanAttack(RouteGoal))
		{
			if(NavigationHandle.ActorReachable(RouteGoal))
				NextMoveTarget = RouteGoal;
			else
			{
				NextMoveTarget = FindRandomDest();
				if(NextMovetarget != None)
					NextMovetarget = RouteCache[0];
			}
		}

		MoveTarget = NextMoveTarget;
	
	}

	function FindPathToBuilding() 
	{
		local Actor NextMoveTarget;
		local Actor AttackTarget;

		if(RouteGoal == CurrentBO.InfiltrationPoint && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
			return;

		RouteGoal = CurrentBO.InfiltrationPoint;

		NavigationHandle.SetFinalDestination(RouteGoal.Location);

		class'Rx_NavUtils'.static.GatePathFindActor(pawn, RouteGoal, NextMoveTarget);

		AttackTarget = CurrentBO.myBuilding.GetMCT();
			
			if(NextMoveTarget == None && AttackTarget != None && !CanAttack(AttackTarget))
			{
				if(NavigationHandle.ActorReachable(RouteGoal))
					NextMoveTarget = RouteGoal;
				else
				{
					NextMoveTarget = FindRandomDest();
					if(NextMovetarget != None)
						NextMoveTarget = RouteCache[0];
				}
			}

		MoveTarget = NextMoveTarget;

	}

Begin:

//	`log("Defending Begin"); 
	WaitForLanding();

//	if(HasRepairGun(false) && (GetNearbyDeployables(true) != None))
//		GoTo('Healing');

	SwitchToBestWeapon();
	// Report problem!!

	if(GetNearbyDeployables(false) != None)
	{
		Focus = DetectedDeployable;

		if(!CanHeal(DetectedDeployable))
			FindPathToBeacon();
		else
			GoTo('Healing');


		GoalString @= "Problem detected - Beacon/C4!";
	}
	else if (DefendedBuildingNeedsHealing())
	{
		Focus = CurrentBO.MyBuilding.GetMCT();
		if(CurrentBO.MyBuilding != None && !CurrentBO.bAlreadyReported)
		{
			CurrentBO.AIReported();
			BroadcastBuildingSpotMessages(CurrentBO.MyBuilding);
		}

		if(!CanHeal(Focus) || !HasRepairGun())
			FindPathToBuilding();

		else
			GoTo('Healing');

	}
	else
	{
		GoToState('Patrolling');
		Focus = None;
	}


MoveToHeal:


	MoveToward(MoveTarget,Focus,,ShouldStrafeTo(MoveTarget));

	if(DetectedDeployable != None && CanAttack(DetectedDeployable))
	{
		Focus = DetectedDeployable;
		FireWeaponAt(Focus);
	}

	else if (CurrentBO.myBuilding != None && CanAttack(CurrentBO.myBuilding))
	{
		Focus = CurrentBO.myBuilding.GetMCT();
		FireWeaponAt(Focus);
	}
	

	GoalString = "Moving to healing point";

	LatentWhatToDoNext();

	if(HasRepairGun() && Focus != None && CanHeal(Focus) && VSize(Focus.Location - Pawn.Location) <= 400)
	{
Healing:
	
		StopMovement();	

		SwitchToBestWeapon();

		GoalString @= "- Repairing....";

		While((Focus == CurrentBO.myBuilding.GetMCT() && DefendedBuildingNeedsHealing()) || (DetectedDeployable != None && Focus == DetectedDeployable))
		{
			if(Enemy != None && LineOfSightTo(Enemy))
			{
				DoTacticalMove();
				break;
			}

			FireWeaponAt(Focus);

			Sleep(2);
			if(!HasRepairGun())
				break;
		}
	}
DoneHealing:	
	if(bIsEmergencyRepairer && !DefendedBuildingNeedsHealing())
	{
		OurTeamAI.PutOnOffense(self);
		EmergencyRepairStopped();
	}

	Sleep(1.5);
	LatentWhatToDoNext();
		


}

state Patrolling extends Defending
{
Begin:

	WaitForLanding();
	CampTime = bShortCamp ? 0.3 : 3.0;
	bShortCamp = false;

//	if(HasRepairGun(false) && (GetNearbyDeployables(true) != None))
//		GoTo('Healing');

	if(PTTask == "")
	{
		SetRouteGoal();
	}

	else
	{
		Sleep(1.0);
		LatentWhatToDoNext();
	}


	if(!Pawn.ReachedDestination(RouteGoal)) 
	{
Moving:
//	`log("Defending Moving"); 

		GoalString = "Patrolling";

		if(GetOrders() != 'DEFEND')
			Goalstring @= "- from WanderOrCamp";
		

		Pawn.bWantsToCrouch = false;
		if (HasRepairGun() && (GetNearbyDeployables(true) != None || DefendedBuildingNeedsHealing()))
		{
			GoToState('Defending');
		}
		else
		{
			MoveTo(MoveTarget.Location,Focus);
		}
	}

	LatentWhatToDoNext();

Pausing:

	GoalString = "Holding Position";
	

	if (UTVehicle(Pawn) != None && UTVehicle(Pawn).bShouldLeaveForCombat)
	{
		UTVehicle(Pawn).DriverLeave(false);
	}

	StopMovement();
	Pawn.bWantsToCrouch = IsSniping() && !WorldInfo.bUseConsoleInput;

	if(!HasRepairGun() && Enemy != None && LineOfSightTo(Enemy))
	{
		ChooseAttackMode();
	}
	else if ( DefensePoint != None)
	{
		if ( Pawn.ReachedDestination(DefensePoint) )
		{
			Focus = None;
			SetFocalPoint( Pawn.Location + vector(DefensePoint.Rotation) * 1000.0 );

			SuggestDefenseRotation();
		}
	}
	else if ( (DefensivePosition != None) && Pawn.ReachedDestination(DefensivePosition) && PTTask == "" )
	{
			SuggestDefenseRotation();
	}
	SwitchToBestWeapon();
	Sleep(0.5);
	if (UTWeapon(Pawn.Weapon) != None && UTWeapon(Pawn.Weapon).ShouldFireWithoutTarget())
		Pawn.BotFire(false);
	Sleep(FMax(0.1,CampTime - 0.5));	

	LatentWhatToDoNext();
}

function bool AssignSquadResponsibility()
{

	local Rx_Weapon_DeployedActor DA;

	if(Rx_Vehicle(Pawn) != None && Enemy != None && !Rx_Vehicle(Pawn).ValidEnemyForVehicle(Enemy)) 
	{
		//loginternal("LoseEnemy");
		Enemy = None;
		//LoseEnemy();
	}

	if(DetectedDeployable != None || GetNearbyDeployables(false) != None)	
	{
		if(Rx_Weapon_DeployedBeacon(DetectedDeployable) != None || (Rx_Weapon_DeployedC4(DetectedDeployable) != None && Rx_BuildingAttachment_MCT(DetectedDeployable.Base) != None && Rx_BuildingAttachment_MCT(DetectedDeployable.Base).GetTeamNum() == GetTeamNum()))
			OurTeamAI.WarnBotsForDeployables(DetectedDeployable,Self);

		BroadcastDeployableSpotMessage(DetectedDeployable);
	}	
	if(class'Rx_Weapon_Deployable'.static.DeployablesNearby(Pawn, Pawn.Location, 500,DA) 
		&& Rx_Weapon_DeployedBeacon(DA) != None && DA.GetTeamNum() == GetTeamNum())
	{
		HoldPosition();
		return true;
	}


	if(BaughtVehicleIndex != -1) 
	{
		if(GoToBaughtVehicle()) 
		{
			return true;
		}
	}
	if(bOnboardForTactics && !ReviewTactics())	
	{
		return true;
	}
	if(Vehicle(Pawn) == None && LastVehicle == None && !Rx_Game(WorldInfo.Game).GetPurchaseSystem().AreVehiclesDisabled(GetTeamNum(), None) && BaughtVehicle == None)
	{
		if(TryBuyingNewTank())
			return true;
	} 

    if(bStrafingDisabled && Pawn.Anchor == None) 
    {
    	return false;
    }	

	
	if(UTVehicle(Pawn) == None && HasRepairGun() && !bInfiltrating) 
	{
		if(!DefendedBuildingNeedsHealing() && PTTask == "" && Rx_SquadAI(Squad).Size > 3 
			&& Rx_SquadAI(Squad).GetEngiNumber()/Rx_SquadAI(Squad).Size > Rx_SquadAI(Squad).RepairerRatio)
			RebuyDefense();

		else if(RepairCloseVehicles()) 
		{
			return true;		
		}
	}
	return Rx_SquadAI_Mesh(Squad).AssignSquadResponsibilityRx(self);
}

function bool GoToBaughtVehicle() 
{
	local Actor BO;

	if(Squad != None && BaughtVehicle != None) 
	{
		if(Rx_SquadAi(Squad).GotoVehicle(BaughtVehicle, self))
			return true;
	}
	
	BO = FindNearestFactory();
	
	if(BO == none)
		return false;

	FindVehicleWaitingSpot(BO);

	return true;
}

function FindVehicleWaitingSpot(Actor FactorySpot)
{
	local Actor BestPath;

	//Check if previous Route Goal is already close enough

	if(FactorySpot == None || (RouteGoal != None && (VSize(RouteGoal.Location - FactorySpot.Location) <= 1000 || RouteGoal == Pawn.Anchor)))
	{
		if(!Pawn.ReachedDestination(MoveTarget))
		{
			GoToState('WaitingForVehicle');
			return;
		}
	}
	else
	{
		class'Rx_NavUtils'.static.GatePathFindActor(pawn, FactorySpot, BestPath);

		if(BestPath == None)
		{
			RouteGoal = Pawn.Anchor;
		}
		else
			RouteGoal = FactorySpot;
	}

	if(Pawn.ReachedDestination(RouteGoal))
	{	
		GoToState('WaitingForVehicle','Waiting');
		return;
	}

	if(NavigationHandle.ActorReachable(RouteGoal))
		MoveTarget = RouteGoal;
	else
		MoveTarget = FindPathToward(RouteGoal,true);

	GoToState('WaitingForVehicle');
}

State WaitingForVehicle extends MoveToGoal
{

Begin :
	SwitchToBestWeapon();

	WaitForLanding();
	
	if(RouteGoal != None && !Pawn.ReachedDestination(RouteGoal))
	{
		MoveTo(MoveTarget.Location,FaceActor(1),GetDesiredOffset());
		GoalString = "Moving to Vehicle Position";
	}
	else
	{
Waiting:
		StopMovement();
		GoalString = "Standby for Vehicle";
	}

	if(Squad != None && BaughtVehicle != None) 
	{
		Rx_SquadAi(Squad).GotoVehicle(BaughtVehicle, self);
	}

	sleep(1.0);
	LatentWhatToDoNext();

}

function bool RepairCloseVehicles() {
	local float NewDist,BestDist;
	local UTVehicle V,VehToHeal;
	local bool bVisible, bDefending, bShouldRepVehs;
	local int BuildingHealtDiff;
	
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local actor HitActor;
	local float TraceDist;	
		
	bShouldRepVehs = true;
	if(GetOrders() == 'DEFEND') {
		bDefending = true;
		if(Squad != None && Rx_BuildingObjective(Squad.SquadObjective) != None 
			&& Rx_BuildingObjective(Squad.SquadObjective).NeedsHealing()) {
			BuildingHealtDiff = Rx_BuildingObjective(Squad.SquadObjective).HealthDiff();
			if(BuildingHealtDiff >= 500 || Rx_BuildingObjective(Squad.SquadObjective).bUnderAttack) {
				bShouldRepVehs = false;	
			}	
		}
	}
	
	VehToHeal = None;
	if(bShouldRepVehs) {
		for ( V=UTGame(WorldInfo.Game).VehicleList; V!=None; V=V.NextVehicle )
		{
			if(VehToHeal != None && Rx_Vehicle_Harvester(V) != None)
				continue; // prefer non harvesters
			if(V.GetTeamNum() != GetTeamNum()) {
				continue;
			}
			if(bDefending 
				&& VSize(V.location - Rx_BuildingObjective(Squad.SquadObjective).GetShootTarget(self).location) > 2500 ) {
				continue;
			}
			
			NewDist = VSize(Pawn.Location - V.Location);
			if (BestDist == 0.0 || NewDist < BestDist 
				|| (Rx_Vehicle_Harvester(VehToHeal) != None && Rx_Vehicle_Harvester(V) == None) )
			{
				bVisible = V.FastTrace(V.Location, Pawn.Location + Pawn.GetCollisionHeight() * vect(0,0,1));
				if(!bVisible) {
					continue;
				}
				if(V.Health >= V.HealthMax) {
					if(bDefending) {
						continue;
					} else {
						NewDist *= 3;
					}
				}					
				if (BestDist == 0.0 || NewDist < BestDist || (Rx_Vehicle_Harvester(VehToHeal) != None && Rx_Vehicle_Harvester(V) == None)) {
				
					TraceDist = 1.5 * V.GetCollisionHeight();
					HitActor = Trace(HitLocation, HitNormal, V.Location - TraceDist*vect(0,0,1), V.Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);				
					if(HitActor != None && HitActor.isA('Rx_Volume_Tiberium')) {
						continue; // dont heal it when its on tiberium
					}
				
					VehToHeal = V;
					BestDist = NewDist;
				}
			}
		}		
		
		if(VehToHeal != None) {
			if (!Pawn.CanAttack(VehToHeal)) {
				RouteGoal = VehToHeal;
				if(FindBestPathToward(VehToHeal, false, false)) {
					GoalString = self$"moving closer to "$VehToHeal$" for healing";
					if(StartMoveToward(VehToHeal)) {
						return true;
					}
				} else {
					return false;
				}
			} else {
				DoRangedAttackOn(VehToHeal);
				return true;
			}
		}
	}
	return false;		
}

function LookarroundWhileWaitingInAreaTimer() 
{
	local int i,j;
	local NavigationPoint Nav,PickedFocusNav;
	local array<NavigationPoint> out_NavList;
	local UTGameObjective CurrentSO;
	local Rx_ObservedPoint ObservePoint;
	
	if(Pawn == None) {
		return;
	}
	if(FRand() < 0.7 || !Pawn.ValidAnchor() || Pawn.Anchor == None || Pawn.Anchor.PathList.length == 0) {

		
		/**
		if(ClosestNextRO == None) {
			ClosestNextRO = Rx_TeamAI(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).GetClosestNextAreaObjective(self,true);
		}
		if(ClosestNextRO != None)
			ClosestObjective = ClosestNextRO;
		else {
			if(ClosestEnemyBO == None) {
				ClosestEnemyBO = Rx_TeamAI(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).GetClosestEnemyBuildingObjective(self);
			}
			ClosestObjective = ClosestEnemyBO;
		}
		*/
		
		if(Squad != None)
			CurrentSO = UTGameObjective(Squad.SquadObjective);
		if(Rx_AreaObjective(CurrentSO) == None) {
			return;
		}	
		
		if(GetTeamNum() == TEAM_GDI) {
			if(Rx_AreaObjective(CurrentSO).ObservePointsGDI.length > 0) {
				i = Rand(Rx_AreaObjective(CurrentSO).ObservePointsGDI.length);
				ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsGDI[i];
				if(ObservePoint.Importance < 1.0 && Rx_AreaObjective(CurrentSO).ObservePointsGDI.length > 1
						&& FRand() > ObservePoint.Importance) {
					if(Rx_AreaObjective(CurrentSO).ObservePointsGDI.length-1 > i) {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsGDI[i+1];
					} else {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsGDI[i-1];
					}
				}
			}
		} else {
			if(Rx_AreaObjective(CurrentSO).ObservePointsNod.length > 0) {
				i = Rand(Rx_AreaObjective(CurrentSO).ObservePointsNod.length);
				ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsNod[i];
				if(ObservePoint.Importance < 1.0 && Rx_AreaObjective(CurrentSO).ObservePointsNod.length > 1
						&& FRand() > ObservePoint.Importance) {
					if(Rx_AreaObjective(CurrentSO).ObservePointsNod.length-1 > i) {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsNod[i+1];
					} else {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsNod[i-1];
					}
				}
			}
		}
		
		
		if(ObservePoint != None) {
			class'NavigationPoint'.static.GetAllNavInRadius(Pawn,Pawn.location,1600.0,out_NavList);
			i = Rand(out_NavList.length);
			Foreach out_NavList(Nav) {
				if(j++ >= i) {
					if(VSize(Nav.location - Pawn.location) >= 800 && FastTrace(Nav.location, Pawn.location)
							&& class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint) > 0.3) {
						//DrawDebugLine(Pawn.location,Nav.location,0,0,255,true);
						//loginternal(class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint));
						//DrawDebugSphere(Pawn.location,1600,10,0,0,255,true);
						PickedFocusNav = Nav;
						break;	
					}
				}
			}
			if(PickedFocusNav == None && i > 0) {
				j = 0;
				Foreach out_NavList(Nav) {
					if(j++ < i) {
						if(VSize(Nav.location - Pawn.location) >= 800 && FastTrace(Nav.location, Pawn.location)
								&& class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint) > 0.3) {
							PickedFocusNav = Nav;
							//DrawDebugLine(Pawn.location,Nav.location,0,0,255,true);
							//loginternal(class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint));
							//DrawDebugSphere(Pawn.location,1600,10,0,0,255,true);
							//DebugFreezeGame(Pawn); 						
							break;	
						}
					}
				}			
			}
		} 
	}
	
	if(PickedFocusNav == None) {
		if(Pawn.Anchor != None) {
			i = Rand(Pawn.Anchor.PathList.length);
			PickedFocusNav = Pawn.Anchor.PathList[i].GetEnd();
		}
	}
	if(PickedFocusNav != None) {
		Focus = PickedFocusNav;	
	}
	SetTimer(1.0 + Rand(5),false,'LookarroundWhileWaitingInAreaTimer');
}

/**
function DoCharge()
{
	if(Rx_Vehicle(Pawn) != None && !Rx_Vehicle(Pawn).ValidEnemyForVehicle(Enemy)) {
		//loginternal("LoseEnemy");
		InvalidEnemy = Enemy; 
		LoseEnemy();
		ExecuteWhatToDoNext();
		return;	
	}
	super.DoCharge();
}
*/

auto state Roaming
{
	ignores EnemyNotVisible;

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

Begin:
	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming: Start",,'DevAI');
	SwitchToBestWeapon();
	WaitForLanding();
	if ( Pawn.bCanPickupInventory && (UTPickupFactory(MoveTarget) != None) && (UTSquadAI(Squad).PriorityObjective(self) == 0) && (Vehicle(Pawn) == None)
		&& UTPickupFactory(MoveTarget).ShouldCamp(self, 5) )
	{
		CampTime = MoveTarget.LatentFloat;
		GoalString = "Short wait for inventory "$MoveTarget;
		GotoState('Defending','Pausing');
	}

	switch(class'Rx_NavUtils'.static.GateMoveHelper(pawn, NavMoveTarget, MoveTarget, true, true, true))
	{
		case EMoveHelperResult_NavMeshMove:
		case EMoveHelperResult_NavMeshAlternativeMove:
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming.GateMoveHelper: NavMesh move to:" @ NavMoveTarget,,'DevAI');
			//class'actor'.static.DrawDebugLine(pawn.Location, NavMoveTarget, 0,255, 0, true);
			//class'actor'.static.DrawDebugSphere(NavMoveTarget, 16,20,0,255,0,true);
			MoveTo(NavMoveTarget, FaceActor(1),(GetDesiredOffset()/2),false);
			break;
		case EMoveHelperResult_WayPointMove:
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming.GateMoveHelper: Waypoint move to:" @ MoveTarget,,'DevAI');
			MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget),false);
			break;
		case EMoveHelperResult_DirectlyReachable:
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming.GateMoveHelper: Directly Reachable:" @ MoveTarget,,'DevAI');
			MoveToDirectNonPathPos(MoveTarget.Location,FaceActor(1),,false);
			break;
		case EMoveHelperResult_Error:
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming.GateMoveHelper: Error in move to:" @ MoveTarget,,'DevAI');
			break;
		case EMoveHelperResult_NavMeshAuto:
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming.GateMoveHelper: NavMesh moved us automatically towards:" @ MoveTarget,,'DevAI');
			break;
		case EMoveHelperResult_CollidingPawn:
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming: Moving.GateMoveHelper: Colliding Pawn:" @ MoveTarget,,'DevAI');
			break;
		default:
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:Roaming.GateMoveHelper: Unknown result for:" @ MoveTarget,,'DevAI');
			break;
	};

DoneRoaming:
	WaitForLanding();
	LatentWhatToDoNext();
	if(!IsTimerActive('WaitAtAreaTimer')) {
		GoalString = "STUCK IN ROAMING";
		if ( bSoaking )
			SoakStop("STUCK IN ROAMING!");
	}
}

state GetOutOfBuilding
{
	function Actor GetNearestNav()
	{
		local array<NavigationPoint> NavList;
		local NavigationPoint Nav;	
		local float Dist;	

		NavList = GetNearNavPoints();
		Foreach NavList(Nav) {
			Dist = VSize(Nav.location - Pawn.location);
			if(Dist > 30 && FastTrace(Nav.location - Pawn.location) && (NavigationHandle.ActorReachable(nav) || ActorReachable(Nav))) {
				return Nav;
			} 
		}
		return None;
	}

	function array<NavigationPoint> GetNearNavPoints()
	{
		local array<NavigationPoint> out_NavList;
		class'NavigationPoint'.static.GetAllNavInRadius(Pawn,Pawn.location,2000,out_NavList);
		return out_navlist;
	}

	function actor GetNavPathOut()
	{
		local array<NavigationPoint> NavList;
		local NavigationPoint Nav;
		local array<BiasedGoalActor> ActorList;
		local BiasedGoalActor NavActor;
		local actor outDestActor;

		if(Navigationhandle.FindPylon())
		{
			NavList = GetNearNavPoints();

			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: Nearby Nav points count:" @ NavList.Length,,'DevAI');
			
			foreach NavList(nav){
				if(nav.IsA('Rx_BuildingObjective'))
				{
					outDestActor = Nav;
					if(class'Rx_navutils'.static.GateDirectMoveTowardCheck(pawn, outDestActor.Location))
					{
						`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: Nearby Nav point directly accessable",,'DevAI');
						return nav;
					}

					NavActor.Goal = nav;
					ActorList.Additem(navactor);
				}
			}

			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: Nearby Rx_BuildingObjective points count:" @ ActorList.Length,,'DevAI');
			if(class'Rx_NavUtils'.static.NavMeshGetClosestActor(pawn, ActorList, outDestActor))
			{
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: NavMeshGetClosestActor returned success." ,,'DevAI');
				navigationhandle.SetFinalDestination(outdestactor.Location);
			}
			else 
			{
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: NavMeshGetClosestActor returned failure:" @ navigationhandle.LastPathError ,,'DevAI');
				return none;
			}			
		}
		
		Return outDestActor;
	}

Begin:
	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: Start",,'DevAI');

	if(!isinbuilding())
	{
		bStrafingDisabled = false; 
		LatentWhatToDoNext();
	}


	tempactor = none;
	tempactor = GetNavPathOut(); // The closest Rx_BuildingObjective actor

	if(tempactor != none)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: Found Closest Rx_BuildingObjective point:" @ tempactor,,'DevAI');
		class'Rx_NavUtils'.static.NavMeshFindPathToActor(pawn, tempactor);
	}

	If(!navigationhandle.FindPylon() && tempactor == none)
		tempactor = GetNearestNav();

	if(tempActor != None)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding: tempactor:" @ tempactor,,'DevAI');

		switch(class'Rx_NavUtils'.static.GateMoveHelper(pawn, NavMoveTarget, tempactor, true, true, true))
		{
			case EMoveHelperResult_NavMeshMove:
			case EMoveHelperResult_NavMeshAlternativeMove:
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding.GateMoveHelper: NavMesh move to:" @ NavMoveTarget,,'DevAI');
				MoveTo(NavMoveTarget, FaceActor(1),(GetDesiredOffset()/2),false);
				break;
			case EMoveHelperResult_WayPointMove:
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding.GateMoveHelper: Waypoint move to:" @ tempactor,,'DevAI');
				MoveToward(tempActor,FaceActor(1),(GetDesiredOffset()/2),ShouldStrafeTo(MoveTarget),false);
				break;
			case EMoveHelperResult_DirectlyReachable:
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding.GateMoveHelper: Directly Reachable:" @ tempActor,,'DevAI');
				MoveToDirectNonPathPos(tempActor.Location,FaceActor(1),,false);
				break;
			case EMoveHelperResult_Error:
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding.GateMoveHelper: Error in move to:" @ tempactor,,'DevAI');
				break;
			case EMoveHelperResult_NavMeshAuto:
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding.GateMoveHelper: NavMesh moved us automatically towards:" @ tempactor,,'DevAI');
				break;
			case EMoveHelperResult_CollidingPawn:
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding:GateMoveHelper: Colliding Pawn:" @ tempactor,,'DevAI');
				break;
			default:
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding.GateMoveHelper: Unknown result for:" @ tempactor,,'DevAI');
				break;
		};
	}
	else
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot:GetOutOfBuilding.GateMoveHelper: tempActor is none, doing random jumps",,'DevAI');
		DoRandomJumps();
	}

	LatentWhatToDoNext();
}

protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;

	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.ExecuteWhatToDoNext: Start",,'DevAI');

	if(LastO != Squad.SquadObjective)
	{
		LastO = UTGameObjective(Squad.SquadObjective);
		CurrentBO = Rx_BuildingObjective(LastO);
	}

	if(CurrentBO == None || RouteGoal != CurrentBO.InfiltrationPoint)
		bInfiltrating = false;

	if (Pawn == None)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.ExecuteWhatToDoNext: pawn got destroyed between WhatToDoNext() and now - abort",,'DevAI');
		// pawn got destroyed between WhatToDoNext() and now - abort
		return;
	}
	bHasFired = false;
	GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;
	// if we don't have a squad, try to find one
	//@fixme FIXME: doesn't work for FFA gametypes
	if (Squad == None && PlayerReplicationInfo != None && UTTeamInfo(PlayerReplicationInfo.Team) != None)
	{
		UTTeamInfo(PlayerReplicationInfo.Team).SetBotOrders(self);
	}
	SwitchToBestWeapon();

	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.ExecuteWhatToDoNext: Waiting to land",,'DevAI');
		return;
	}
	if ( (StartleActor != None) && !StartleActor.bDeleteMe )
	{
		StartleActor.GetBoundingCylinder(StartleRadius, StartleHeight);
		if ( VSize(StartleActor.Location - Pawn.Location) < StartleRadius  )
		{
			Startle(StartleActor);
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.ExecuteWhatToDoNext: Startling",,'DevAI');
			return;
		}
	}
	bIgnoreEnemyChange = true;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
	if ( Enemy == None || !IdealToAttack(Enemy))
		UTSquadAI(Squad).FindNewEnemyFor(self,false);
	else if ( !Rx_SquadAI(Squad).MustKeepEnemy(Enemy) && !LineOfSightTo(Enemy) )
	{
		// decide if should lose enemy
		if ( Rx_SquadAI(Squad).IsDefending(self) )
		{
			if ( LostContact(4) )
				LoseEnemy();
		}
		else if ( LostContact(7) )
			LoseEnemy();
	}

	bIgnoreEnemyChange = false;

	if(PTTask == "" && PTQueue.Length > 0)
	{
		PTTask = PTQueue[0];
		PTQueue.Remove(0,1);
	}

	if (AssessPurchasing())
	{
		return;
	}

	if ( AssignSquadResponsibility() )
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.ExecuteWhatToDoNext: AssignSquadResponsibility() returned true",,'DevAI');
		return;
	}
	if ( ShouldDefendPosition() )
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.ExecuteWhatToDoNext: ShouldDefendPosition() is true",,'DevAI');
		return;
	}
	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		if (Pawn.FindAnchorFailedTime == WorldInfo.TimeSeconds)
		{
			`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.ExecuteWhatToDoNext: Couldnt find anchor",,'DevAI');
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

function bool ShouldDefendPosition()
{
	local bool bShouldI;

	if(GetOrders() != 'DEFEND')
		return false;

	if(GetNearbyDeployables(false) != None)
	{
		bShouldI=true;
	}

	else if ( ((DefensePoint != None) || CurrentBO != None) && (Enemy == None))
	{
		bShouldI=true;
	}

	else if(Enemy != None)
	{
		bShouldI=true;
	}

	if(bShouldI)
		MoveToDefensePoint();

	return bShouldI;
}

/*
function WanderOrCamp()
{
	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.WanderOrCamp: Start",,'DevAI');
	if(bStrafingDisabled) {
		GotoState('GetOutOfBuilding', 'Begin');
	} else {
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.WanderOrCamp: Calling Super",,'DevAI');
		super.WanderOrCamp();
	}
}
*/

function SetAttractionState()
{
	if(Vehicle(RouteGoal) != None)
	{
		GoToState('Roaming','Begin');
	}

	else if(PTTask != "" && CanBuyCurrentPTTask())
	{
		GoToState('Roaming','Begin');
	}
	else if(RouteGoal == Rx_SquadAI(Squad).SquadLeader)
	{
		GoToState('Roaming','Begin');
	}
	else if(bInfiltrating)
	{
		if(Enemy != None && (Rx_Pawn_SBH(Pawn) == None || Rx_SquadAI(Squad).IsStealthDiscovered()))
			GoToState('RushEnemy','Moving');
		else
			GoToState('Rush','Moving');
	}
	else if(Vehicle(Pawn) != None && Rx_SquadAI(Squad).CurrentTactics != None && Rx_SquadAI(Squad).CurrentTactics.bIsRush)
	{
		if((VehicleShouldAttackEnemyInRush()) && (Rx_Vehicle_StealthTank(Pawn) == None || Rx_SquadAI(Squad).IsStealthDiscovered()))
			GoToState('VehicleRushEnemy','Moving');
		else
			GoToState('VehicleRush','Moving');
	}
	else if(GetOrders() == 'DEFEND')
		GoToState('Patrolling');
	else if(MoveTarget != None)
		Super.SetAttractionState();
	else
		HoldPosition();

}

function WanderOrCamp()
{

	if(bInfiltrating && CurrentBO != None)
	{
		DoRandomJumps();
		if(Enemy == None)
		{
			if(FindInfiltrationPath())
				return;
			else
				FindRoamDest();
		}	
	}
	else if(GetOrders() == 'DEFEND')
		MoveToDefensePoint();
	else if(IsInState('Roaming'))
		FindRoamDest();	
	else
		GoToState('Roaming');
}

function bool FindDestinationToPT(Actor PTPoint)
{
	local actor BestPath;
	local Rx_Building B;

	if(PTPoint == None || ((Vehicle(Pawn) != None || BaughtVehicle != None || BaughtVehicleIndex != -1 || LastVehicle != None) && Left(PTTask, 11) == "Buy Vehicle"))
		return false;

	if(GetOrders() == 'DEFEND' && PTTask == "Refill")					// Check if any of these situations is not worth refilling 
	{
		if(IsInBuilding(B) && B.GetTeamNum() == GetTeamNum() && B.myObjective != None && B.myObjective.IsCritical())
			return false;

		if(DetectedDeployable != None)
			return false;
	}

	if(PTTask == "" || PTTask == "Refill")
	{
		if(!RetreatToPTNecessary() || (bInfiltrating && RouteGoal != None && VSize(PTPoint.Location-Pawn.Location)*2 > VSize(RouteGoal.Location-Pawn.Location)))
		{
			PTTask = "";
			return false;
		}
		else if (PTTask == "")
		{
			if (PTQueue.Length > 0)
			{
				PTTask = PTQueue[0];
				PTQueue.Remove(0,1);
			}
			else
				PTTask = "Refill";
		}
	}

	if(PTPoint == None)
	{
		if (bSoaking)
		{
			SoakStop("NO PATH AVAILABLE!!!");
		}
	}

	if(Pawn.ReachedDestination(PTPoint))
	{
		GoalString @= "- Arrived at PT";
		ProcessPurchaseOrder();
		return false;
	}

	if(RouteGoal == PTPoint && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
	{
		SetAttractionState();
		return true;
	}

	Navigationhandle.SetFinalDestination(RouteGoal.Location);

	if(RouteGoal != PTPoint)
		RouteGoal = PTPoint;

	class'Rx_NavUtils'.static.GatePathFindActor(pawn, RouteGoal, BestPath);

	GoalString @= "- Finding Path";

	if(BestPath == None)
	{
		if(NavigationHandle.ActorReachable(RouteGoal))
			BestPath = RouteGoal;
		else
		{
			BestPath = FindRandomDest();
			if(BestPath != None)
				BestPath = RouteCache[0];
		}

		if(BestPath == None)
		{
			GoalString @= "ERROR FINDING PATH TO PURCHASE TERMINAL";
			DoRandomJumps();
			SetAttractionState();
			return false;
		}

	}
	MoveTarget = BestPath;


	SetAttractionState();
	return true;
}

function bool FindInfiltrationPath()
{
	local actor BestPath, InfilPoint;


	if(CurrentBO == None)
	{
		GoalString @= "- Building Objective not found";
		return false;
	}

	if(Vehicle(Pawn) != None || (LastVehicle != None && LastVehicle.bOkAgainstBuildings))
		return FindVehicleAssaultPath();

	InfilPoint = CurrentBO.myBuilding.GetMCT();

	if(InfilPoint == None)
	{
		GoalString @= "- building is missing MCT, failure";
		return False;
	}

	if(RouteGoal == InfilPoint && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
	{
		SetAttractionState();
		return true;
	}
	
	if(RouteGoal != InfilPoint)
		RouteGoal = InfilPoint;
	
	NavigationHandle.SetFinalDestination(RouteGoal.Location);

	class'Rx_NavUtils'.static.GatePathFindActor(pawn, RouteGoal, BestPath);

	if(BestPath == None)
	{
		BestPath = FindRandomDest();
		if(BestPath != None)
			BestPath = RouteCache[0];

		if(BestPath == None)
		{
			GoalString = "ERROR FINDING PATH TO INFILTRATION POINT";
			DoRandomJumps();
			return false;
		}
		else		
	}

	MoveTarget = BestPath;

	SetAttractionState();
	return true;

}

function bool FindVehicleAssaultPath()
{
	local actor BestPath, BuildingPoint;
	local vector Dummy1,Dummy2;


	if(CurrentBO == None)
	{
		GoalString @= "- Building Objective not found";
		return false;
	}

	if(Vehicle(Pawn) == None)
	{
		if(LastVehicle != None && !IsInState('DeployingBeacon'))
		{
			if(LastVehicle.Driver == None)
				Rx_SquadAI(Squad).GoToVehicle(LastVehicle,self);
			else
			{
				LastVehicle = None;
				return FindInfiltrationPath();
			}
		}
		else
		{
			return FindInfiltrationPath();
		}
	}


	BuildingPoint = CurrentBO;

	if(RouteGoal == BuildingPoint && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
	{
		SetAttractionState();
		return true;
	}

	if(RouteGoal == BuildingPoint && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
	{
		SetAttractionState();
		return true;
	}

	if(RouteGoal != BuildingPoint || VSize(Rx_BuildingObjective(BuildingPoint).myBuilding.Location - BuildingPoint.Location) > 200 || (RouteGoal != BuildingPoint && Trace(Dummy1, Dummy2, CurrentBO.myBuilding.location, RouteGoal.location) == None))
		RouteGoal = BuildingPoint;

	NavigationHandle.SetFinalDestination(RouteGoal.Location);
	
	class'Rx_NavUtils'.static.GatePathFindActor(pawn, RouteGoal, BestPath);

	if(BestPath == None)
	{
		BestPath = FindRandomDest();


		if(BestPath == None)
		{
			GoalString = "ERROR FINDING PATH TO INFILTRATION POINT";
			DoRandomJumps();
			SetAttractionState();
			return false;
		}
		else
			BestPath = RouteCache[0];		
	}

	MoveTarget = BestPath;

	SetAttractionState();
	return true;

}

state Rush extends MoveToGoal
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

	if(CurrentBO != None && CanAttack(CurrentBO.myBuilding.GetMCT()))
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
			AssaultMCT();
	}
	else if (CurrentBO != None && !CanAttack(CurrentBO.myBuilding.GetMCT()))
	{
		if(LastVehicle != None && LastVehicle.Driver == None)
		{
			Rx_SquadAI(Squad).GoToVehicle(LastVehicle,Self);
		}
	}

	MoveTo(MoveTarget.Location,FaceActor(1),GetDesiredOffset());

	if(HasABeacon() && VSize(CurrentBO.myBuilding.Location - Pawn.Location) < 300)
	{
		`log(GetHumanReadableName()@"is attempting to plant a Beacon");
		GoToState('DeployingBeacon');
		Sleep(2.0);
	}

	LatentWhatToDoNext();

}

state RushEnemy extends MoveToGoalWithEnemy
{

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

	singular function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
	{
		if (Focus == KilledPawn && Killed != self)
		{
			WhatToDoNext();
		}
		Global.NotifyKilled(Killer, Killed, KilledPawn,damageType);
	}

	function Timer()
	{
		if ( (Pawn.Weapon != None) && Rx_Weapon_TimedC4(Pawn.Weapon) != None)
		{
			SetCombatTimer();
			StopFiring();
					// if blew self up, return
					if ( (Pawn == None) || (Pawn.Health <= 0) )
						return;
			WhatToDoNext();
		}
		else if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
	}

Begin:
	WaitForLanding();


Moving:

	SwitchToBestWeapon();

	WaitForLanding();

	MoveTo(MoveTarget.Location,FaceActor(1),GetDesiredOffset());


	if(CanAttack(CurrentBO.myBuilding.GetMCT()) && (Enemy == None || Rx_Weapon_TimedC4(Pawn.Weapon) != None))
		AssaultMCT();

	else if(Enemy != None && CanAttack(Enemy))
	{
		Focus = Enemy;
		ChooseAttackMode();
	} 
	else
	{
		StopFiring();
		GoToState('Rush','Begin');
	}

	GoalString = "Infiltrating"@CurrentBO.myBuilding.GetBuildingName()@" - Enemy Engaged";

	LatentWhatToDoNext();
}

state VehicleRush extends MoveToGoal
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


	if(LineOfSightTo(CurrentBO.myBuilding))
		BroadcastBuildingSpotMessages(CurrentBO.myBuilding);

Moving:
	SwitchToBestWeapon();
	WaitForLanding();
	if(Vehicle(Pawn) != None)
		GoalString = "Charging with Vehicle towards "@CurrentBO.myBuilding.GetBuildingName();
	else if(LastVehicle != None && LastVehicle.Driver != None)
		Rx_SquadAI(Squad).GoToVehicle(LastVehicle,Self);	
	else
	{
		LastVehicle = None;
		GoToState('Rush');
	}
	if(RouteGoal != None && Pawn.ReachedDestination(RouteGoal) && !Rx_Vehicle(Pawn).bOkAgainstBuildings)
	{
		LastVehicle = Rx_Vehicle(Pawn);
		LeaveVehicle(true);
		GoToState('Infiltrating');
		LatentWhatToDoNext();
	}

	if(CanAttack(CurrentBO.myBuilding) && (Enemy == None || !CanAttack(Enemy)))
	{
		if(IsRushing() && Rx_SquadAI(Squad).bTacticsCommenced)
			FireWeaponAt(CurrentBO.myBuilding);
		else
			DoRangedAttackOn(CurrentBO.MyBuilding);
	}	
	else if (Enemy != None && VehicleShouldAttackEnemyInRush())
	{
		sleep(0.1);
		ChooseAttackMode();
	}

	MoveTo(MoveTarget.Location,FaceActor(1),GetDesiredOffset());

	if((Enemy == None || VSize(Enemy.Location - Pawn.Location) > 500) && HasABeacon() && VSize(CurrentBO.myBuilding.Location - Pawn.Location) < 300)
	{
		`log(GetHumanReadableName()@"is attempting to plant a Beacon");
		GoToState('DeployingBeacon');
		Sleep(2.0);
	}

	LatentWhatToDoNext();

}

state VehicleRushEnemy extends MoveToGoalWithEnemy
{

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

	singular function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
	{
		if (Focus == KilledPawn && Killed != self)
		{
			WhatToDoNext();
		}
		Global.NotifyKilled(Killer, Killed, KilledPawn,damageType);
	}

	function Timer()
	{
		if ( (Pawn.Weapon != None) && Rx_Weapon_TimedC4(Pawn.Weapon) != None)
		{
			SetCombatTimer();
			StopFiring();
					// if blew self up, return
					if ( (Pawn == None) || (Pawn.Health <= 0) )
						return;
			WhatToDoNext();
		}
		else if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
	}

Begin:

	SwitchToBestWeapon();

	WaitForLanding();

Moving:

	SwitchToBestWeapon();

	WaitForLanding();

	if(Vehicle(Pawn) == None && LastVehicle != None)
	{
		if(LastVehicle.Driver == None)
			Rx_SquadAI(Squad).GoToVehicle(LastVehicle,Self);
		else
		{
			LastVehicle = None;
			GoToState('RushEnemy');
		}
	}

	MoveTo(MoveTarget.Location,FaceActor(1),GetDesiredOffset());


	if(CanAttack(CurrentBO.myBuilding) && (Enemy == None || !CanAttack(Enemy)))
	{
		if(Rx_SquadAI(Squad).CurrentTactics != None && Rx_SquadAI(Squad).CurrentTactics.bIsRush && Rx_SquadAI(Squad).bTacticsCommenced)
			FireWeaponAt(CurrentBO.myBuilding);
		else
			DoRangedAttackOn(CurrentBO.MyBuilding);
	}

	else if(Enemy != None && CanAttack(Enemy))
	{
		Focus = Enemy;
		if(IsRushing())
			FireWeaponAt(Enemy);
		else
			ChooseAttackMode();
	} 
	else
	{
		StopFiring();
		GoToState('VehicleRush','Begin');
	}

	GoalString = "Charging with Vehicle towards "@CurrentBO.myBuilding.GetBuildingName()@" - Enemy Engaged";

	LatentWhatToDoNext();
}

function bool FindRoamDest()
{
	local actor BestPath;

	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.FindRoamDest: Start",,'DevAI');
	/**
	if ( Pawn.FindAnchorFailedTime == WorldInfo.TimeSeconds )
	{
		// if we have no anchor, there is no point in doing this because it will fail
		return false;
	}
	*/
	NumRandomJumps = 0;
	GoalString @= "- Find roam dest "$WorldInfo.TimeSeconds;
	if (RouteGoal != None && Pawn.Anchor != RouteGoal && !Pawn.ReachedDestination(RouteGoal))
		class'Rx_NavUtils'.static.GatePathFindActor(pawn, RouteGoal, BestPath);

	// find random NavigationPoint to roam to
	if (BestPath == None)
	{
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.FindRoamDest: BestPath == none",,'DevAI');

		if(navigationhandle.FindPylon())
		{
			NavMoveTarget = class'Rx_NavUtils'.static.NavMeshGetRandomLocationFromActor(pawn, pawn.Location, 5000, 100);
			If(NavMoveTarget != vect(0,0,0))
			{
				RouteGoal = spawn(class'dynamicanchor',,, NavMoveTarget);
				class'Rx_NavUtils'.static.NavMeshFindPathToActor(Pawn, RouteGoal,,, true);
				class'Rx_NavUtils'.static.NavMeshGetNextMoveLocation(pawn, NavMoveTarget);
				BestPath = spawn(class'dynamicanchor',,, NavMoveTarget);
			}
		}
		else
		{
			routegoal = FindRandomDest();
		
			if ( RouteGoal == None )
			{
				`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.FindRoamDest: Could not get random destination",,'DevAI');
				GoalString = "Failed to find roam dest";
				if ( bSoaking && (Physics != PHYS_Falling) )
				{
					SoakStop("COULDN'T FIND ROAM DESTINATION");
				}
				FreePoint();
				return false;
			}
			BestPath = RouteCache[0];
		}			
	}
	MoveTarget = BestPath;
	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.FindRoamDest: Set MoveTarget to:" @ MoveTarget.Location,,'DevAI');
	SetAttractionState();
	return true;
}


Event bool NotifyBump(Actor Other, Vector HitNormal)
{

	`log("(" $ pawn.GetHumanReadableName() @ pawn.Name $ ")" @ "Rx_Bot.NotifyBump: Got bumping notification for:" @ Other.GetHumanReadableName() @ other.Name,,'DevAI');

	if(Vehicle(Other) != none)
		AdjustAround(Pawn(Other));

	return super.NotifyBump(other, hitnormal);
/*

	local actor Veh;
	local bool bTouching;

	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.NotifyBump: Got bumping notification for:" @ Other.GetHumanReadableName(),,'DevAI');

	sleep(0.5);

	Foreach TouchingActors(class'Rx_vehicle', Veh) {
		bTouching = true;
		break;
	}

	if(bTouching)
	{
		StopMovement();
		Sleep(2);
	}

	LatentWhatToDoNext();*/
}

function bool SetRouteToGoal(Actor A)
{
	if (Pawn.bStationary)
		return false;

	RouteGoal = A;
	FindBestPathToward(A,false,true);
	return StartMoveToward(A);
}

function bool StartMoveToward(Actor O)
{
	if ( MoveTarget == None )
	{
		if ( (O == Enemy) && (O != None) )
		{
			FailedHuntTime = WorldInfo.TimeSeconds;
			FailedHuntEnemy = Enemy;
		}
		if ( bSoaking && (Pawn.Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND ROUTE TO "$O.GetHumanReadableName());
		GoalString = "No path to "$O.GetHumanReadableName()@"("$O$")";
		`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.StartMoveToward: Couldnt find route to:" @O.GetHumanReadableName(),,'DevAI');
	}
	else
		SetAttractionState();

	`log("(" $ pawn.GetHumanReadableName() @ pawn.name $ ")" @ "Rx_Bot.StartMoveToward: Finishing, MoveTarget is:" @MoveTarget.GetHumanReadableName(),,'DevAI');
	return ( MoveTarget != None );
}


/* FindBestPathToward()
Assumes the desired destination is not directly reachable.
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
	if ( !bCheckedReach && class'Rx_navutils'.static.GateDirectMoveTowardCheck(pawn, a.Location) )
		MoveTarget = A;
	else
		class'Rx_NavUtils'.static.GatePathFindActor(pawn, A, MoveTarget,, (bAllowDetour && Pawn.bCanPickupInventory && (Vehicle(Pawn) == None) && (NavigationPoint(A) != None) && !bForceNoDetours));

	if ( MoveTarget != None )
	{
		return true;
	}
	else
	{
		if (A == Enemy && A != None)
		{
			if (Pawn.Physics == PHYS_Flying)
			{
				LoseEnemy();
			}
			else
			{
				FailedHuntTime = WorldInfo.TimeSeconds;
				FailedHuntEnemy = Enemy;
			}
		}
		if ( bSoaking && (Physics != PHYS_Falling) )
		{
			SoakStop("COULDN'T FIND BEST PATH TO "$A);
		}
	}
	return false;
}

function bool TraceActorsRx(pawn InPawn, Vector Loc)
{
	local actor hitactor;
	local vector hitloc, hitnorm;

	hitactor = InPawn.Controller.Trace(hitLoc, hitNorm, Loc,, true, InPawn.GetCollisionExtent());
	if(hitactor != none)
		return false;

	return true;
}

function bool IsInRushState()
{
	return (IsInState('Rush') || IsInState('RushEnemy') || IsInState('VehicleRush') || IsInState('VehicleRushEnemy'));
}

function bool DoEmergencyRepair()
{
	local class<Rx_FamilyInfo> FI;

	if(Skill > 3)
		return false;

	FI = class<Rx_FamilyInfo>(Rx_Pawn(Pawn).CurrCharClassInfo);

	// Check if we've bought something too valuable to get back
	if((!HasRepairGun() && GetCredits() < FI.static.Cost(Rx_PRI(PlayerReplicationInfo)) * 1.5) || BaughtVehicle != None)
		return false;

	if(HasRepairGun(true))
	{
		bIsEmergencyRepairer = true;

		OurTeamAI.PutOnDefense(Self);
		GoToState('Defending');
		return true;
	}
	return false;
}

function EmergencyRepairStopped()
{
	local class<Rx_FamilyInfo> FI;

	bIsEmergencyRepairer = false;

	FI = class<Rx_FamilyInfo>(Rx_Pawn(Pawn).CurrCharClassInfo);

	if(FI.static.Cost(Rx_PRI(PlayerReplicationInfo)) != 0)
	{
		if(GetCredits() > 500)
			PTTask = "Random Buy Vehicle";
	}
	else 
	{
		if(Rand(10) > 4)
			PTTask = "Rebuy Char";
	}

}


function MoveAwayFrom(Controller C)
{
	GoalString = "MOVE AWAY FROM/ "$GoalString;
	GotoState('Patrolling');
	ClearPathFor(C);
}


DefaultProperties
{
	bExecutingWhatToDoNext = true;
}

 
