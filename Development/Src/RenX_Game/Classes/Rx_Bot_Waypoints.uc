/*********************************************************
*
* File: Rx_Bot_Waypoint.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
* The waypoint version of the bot, aka the regular one
* The class contains all logic that involves moving around the map
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/
class Rx_Bot_Waypoints extends Rx_Bot;


var float LastObjectiveReconsideration, NextVehicleAssaultPathRecalc;


/*
*	THE HEART AND SOUL OF THE BOT DECISION MAKING
*
*	To trigger this event, use either WhatToDoNext or (if in a State) LatentWhatToDoNext
*	If the bot freezes, chances are that this event is not being called or all the decisions have failed to meet criteria.
*
*/
protected event ExecuteWhatToDoNext()
{
	local float StartleRadius, StartleHeight;

//	local Rx_Building B;

	if(LastO != Squad.SquadObjective)
	{
		LastO = UTGameObjective(Squad.SquadObjective);
		CurrentBO = Rx_BuildingObjective(LastO);
	}

	if(CurrentBO == None || RouteGoal != CurrentBO.InfiltrationPoint)
		bInfiltrating = false;

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
		UTTeamInfo(PlayerReplicationInfo.Team).SetBotOrders(self);
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

	if ( Enemy == None || !IdealToAttack(Enemy))
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

	if(PTTask == "" && PTQueue.Length > 0)
	{
		PTTask = PTQueue[0];
		PTQueue.Remove(0,1);
	}

	

	/* 	
	**	This is the heart of our bot's decision making.
	**	Any new logic that bot needs to consider must go here. The functions handle the state changes etc.
	*/

	// Purchase Task Logic - Called when there's a purchase demand for the bot
	if (AssessPurchasing())
	{
		return;
	}

	// Emergency Repair Logic
//	if (GetOrders() != 'DEFEND' && IsInBuilding(B) && B.GetTeamNum() == GetTeamNum() 
//		&& B.myObjective != None && B.myObjective.IsCritical() && DoEmergencyRepair())
//	{
//		return;
//	}

	// Objective logic
	if ( AssignSquadResponsibility() )
	{
		return;
	}

	// Defense Logic
	if ( ShouldDefendPosition() )
	{
		return;
	}

	/*
	**	
	** Decision making logic ends here
	*/


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

		// Generally we'll want to avoid reaching to this point.

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

event WhatToDoNext()
{
	if (bExecutingWhatToDoNext)
	{
//		`Log("WhatToDoNext loop:" @ GetHumanReadableName());
		// ScriptTrace();
	}
	if (Pawn == None)
	{
		`Warn(GetHumanReadableName() @ "WhatToDoNext with no pawn");
		return;
	}

	if (Enemy == None || Enemy.bDeleteMe || Enemy.Health <= 0)
	{
		if (!bSpawnedByKismet && UTGame(WorldInfo.Game).TooManyBots(self))
		{
			if ( Pawn != None )
			{
				if ( (Vehicle(Pawn) != None) && (Vehicle(Pawn).Driver != None) )
					Vehicle(Pawn).Driver.KilledBy(Vehicle(Pawn).Driver);
				else
				{
					Pawn.Health = 0;
					Pawn.Died( self, class'DmgType_Suicided', Pawn.Location );
				}
			}
			Destroy();
			return;
		}
		BlockedPath = None;
		bFrustrated = false;
		if (Focus == None || (Pawn(Focus) != None && Pawn(Focus).Health <= 0))
		{
			StopFiring();
			// if blew self up, return
			if ( (Pawn == None) || (Pawn.Health <= 0) )
				return;
		}
	}

	RetaskTime = 0.0;
	DecisionComponent.bTriggered = true;
}

/** Relative locations within target's bounding cylinder to try to aim at when failed to aim at the target's location. */

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
		if(RxWeap.RecoilSpreadIncreasePerShot != 0.0) 
		{
			if(Enemy != None && RxWeap.Recoilspread > 0.0 && VSizeSq(Enemy.location - Pawn.location) > 40000) 
			{
				Rand = FRand();
				if(Rand < 0.1 || (Rand > 0.6 && RxWeap.CurrentSpread >= RxWeap.MaxSpread)) 
				{
					if(Pawn.IsFiring())
						StopFiring();
					return false;
				}
			}
		}
	} 
	else if(Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon) != None && Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon).CurrentlyReloading)
	{
		if(Pawn.IsFiring())
			StopFiring();
		return false;	
	}
	else if(Rx_Weapon_RepairGun(Pawn.Weapon) != None && (Focus.GetTeamNum() == GetTeamNum() || Focus == DetectedDeployable))
		return true;

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
					&& VSizeSq(pawn.Velocity) < 25.0 
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
	
	function bool FindStrafeDestForHealingPlayer() 
	{
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
				Dist = VSizeSq(Pawn.Anchor.Location - Focus.Location);
				bOkStrafeSpot = Dist <= Square(MaxRange);
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
			TargetDist = VSizeSq(Focus.Location - Pawn.Location);
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
						Dist = VSizeSq(Nav.Location - Focus.Location);
						
						//======================
						bOkStrafeSpot = FastTrace(Focus.Location, Nav.Location);
						bOkStrafeSpot = !Nav.bBlocked;
						if(bOkStrafeSpot && CurrentBO == None && NavCanBeHitByAO(Nav)) {
							bOkStrafeSpot = false;	
						}
						
						if(bOkStrafeSpot && UTVehicle(Pawn) != None) {
							if(VolumePathNode(Nav) != None && !UTVehicle(Pawn).bCanFly) {
								bOkStrafeSpot = false;
							} else {							
								bOkStrafeSpot = NavBlockedByVeh(Nav);
							}
						}
						if ( (Dist <= Square(MaxRange) || Dist < TargetDist) && (bAllowBackwards || Dist <= TargetDist + 10000.0) &&
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
	GoalString = "Ranged attack";
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
			MoveToward(MoveTarget, Focus,, false, false);
		} else {
			MoveToward(MoveTarget, Focus,, true, false);
		}
		StopMovement();
	}
	else
	{
		Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	}
LatentWhatToDoNextRangedAttack:
	if(bInfiltrating && Enemy == None)
		FindInfiltrationPath();

	else
		GoTo('Begin');

	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
	GoalString = "STUCK IN RANGEDATTACK!";

}

function bool IsInRushState()
{
	return (IsInState('Rush') || IsInState('RushEnemy') || IsInState('VehicleRush') || IsInState('VehicleRushEnemy'));
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


function MoveToDefensePoint()
{	
	if(GetNearbyDeployables(false) != None || DefendedBuildingNeedsHealing())
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
	
	function FindPathToBeacon()
	{
		local Actor NextMoveTarget;

		if(RouteGoal == DetectedDeployable && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
			return;


		bShortCamp = (Vehicle(Pawn) == None);
			
		RouteGoal = DetectedDeployable;

		NextMoveTarget = FindPathToward(RouteGoal, bShortCamp);
			
		if(NextMoveTarget == None && !CanAttack(RouteGoal))
		{
			if(ActorReachable(RouteGoal))
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

		NextMoveTarget = FindPathToward(RouteGoal, bShortCamp);
		AttackTarget = CurrentBO.myBuilding.GetMCT();
			
			if(NextMoveTarget == None && AttackTarget != None && !CanAttack(AttackTarget))
			{
				if(ActorReachable(RouteGoal))
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

	if(GetNearbyDeployables(true) != None)
	{
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

	MoveToward(MoveTarget,Focus,GetDesiredOffset(),ShouldStrafeTo(MoveTarget));

	GoalString = "Moving to healing point";

	LatentWhatToDoNext();

	if(HasRepairGun() && Focus != None && CanHeal(Focus))
	{
Healing:
	
		StopMovement();	

		SwitchToBestWeapon();

		GoalString @= "- Repairing....";

		While((Focus == CurrentBO.myBuilding.GetMCT() && DefendedBuildingNeedsHealing()) || (GetNearbyDeployables(false) != None && Focus == DetectedDeployable))
		{

			if(Enemy != None && Vehicle(Enemy) == None && LineOfSightTo(Enemy))
			{
				if(CanAttack(Focus))
					DoTacticalMove();
			}

			FireWeaponAt(Focus);

			Sleep(2);
			if(!HasRepairGun())
				break;
		}
	}
DoneHealing:	


	Sleep(1.5);
	LatentWhatToDoNext();
		


}

state Patrolling extends Defending
{
	function SetRouteGoal()
	{
		local Actor NextMoveTarget;
		local bool bCanDetour;
		local UTSquadAI UTSquad;

		UTSquad = UTSquadAI(Squad);

		if (DefensePoint == None || UTPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag )
		{
			// if in good position, tend to stay there
			if ( (WorldInfo.TimeSeconds - FMax(LastSeenTime, AcquireTime) < 5.0 || FRand() < 0.85)
				&& DefensivePosition != None && Pawn.ReachedDestination(DefensivePosition)
				&& UTSquad.AcceptableDefensivePosition(DefensivePosition, self) )
			{
				CampTime = 3;
				GotoState('Patrolling','Pausing');
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
			if ( ActorReachable(RouteGoal) )
				NextMovetarget = RouteGoal;
			else
				NextMoveTarget = FindPathToward(RouteGoal, bCanDetour);
			if ( NextMoveTarget == None )
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
				NextMoveTarget = FindPathToward(RouteGoal, bCanDetour);
			}
		}
		if ( NextMoveTarget == None )
		{
			CampTime = 3;
			GotoState('Patrolling','Pausing');
		}
		Focus = NextMoveTarget;
		MoveTarget = NextMoveTarget;
	}

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

	if(!HasRepairGun() && Enemy != None && LineOfSightTo(Enemy))
	{
		ChooseAttackMode();
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
			MoveToward(MoveTarget,Focus,,ShouldStrafeTo(MoveTarget));
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


	if ( DefensePoint != None)
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
	{
		FindVehicleWaitingSpot(Pawn.Anchor);
		return true;
	}

	FindVehicleWaitingSpot(BO);

	return true;
}

function FindVehicleWaitingSpot(Actor FactorySpot)
{
	local Actor BestPath;
	local NavigationPoint N;

	//Check if previous Route Goal is already close enough

	if(Enemy != None && CanAttack(Enemy))
	{
		ChooseAttackMode();
		return;
	}

	if(FactorySpot == None || (RouteGoal != None && (VSizeSq(RouteGoal.Location - FactorySpot.Location) <= 1000000 || RouteGoal == Pawn.Anchor)))
	{
		if(!Pawn.ReachedDestination(MoveTarget))
		{
			GoToState('WaitingForVehicle');
			return;
		}
	}
	else
	{
		foreach WorldInfo.RadiusNavigationPoints(class'NavigationPoint',N,FactorySpot.Location,1000.F)
		{
			BestPath = FindPathToward(N,true);
			if(BestPath != None)
				Break;
		}

		if(BestPath == None)
		{
			RouteGoal = Pawn.Anchor;
		}
		else
			RouteGoal = N;
	}

	if(Pawn.ReachedDestination(RouteGoal))
	{	
		GoToState('WaitingForVehicle','Waiting');
		return;
	}

	if(ActorReachable(RouteGoal))
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
		MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
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


function bool RepairCloseVehicles() 
{
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
		if(Squad != None && CurrentBO != None 
			&& CurrentBO.NeedsHealing()) {
			BuildingHealtDiff = CurrentBO.HealthDiff();
			if(BuildingHealtDiff >= 500 || CurrentBO.bUnderAttack) {
				bShouldRepVehs = false;	
			}	
		}
	}
	else if(Rx_SquadAI(Squad).CurrentTactics != None)
		bShouldRepVehs = false;
	
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
				&& VSizeSq(V.location - CurrentBO.GetShootTarget(self).location) > 6250000 ) {
				continue;
			}
			
			NewDist = VSizeSq(Pawn.Location - V.Location);
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
				
				if(ObservePoint == none) //TODO: Figure out why they actually find NONE in that array
					return; 
				
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
				
				if(ObservePoint == none) //TODO: Figure out why they actually find NONE in that array
					return; 
				
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
					if(VSizeSq(Nav.location - Pawn.location) >= 640000 && FastTrace(Nav.location, Pawn.location)
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
						if(VSizeSq(Nav.location - Pawn.location) >= 640000 && FastTrace(Nav.location, Pawn.location)
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

		if(GetNearbyDeployables(false) != None)
			return false;
	}

	if(PTTask == "" || PTTask == "Refill")
	{
		if(!RetreatToPTNecessary() || (bInfiltrating && RouteGoal != None && VSizeSq(PTPoint.Location-Pawn.Location)*2 > VSizeSq(RouteGoal.Location-Pawn.Location)))
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

	if(RouteGoal != PTPoint)
		RouteGoal = PTPoint;

	BestPath = FindPathToward(PTPoint,false);

	GoalString @= "- Finding Path";

	if(BestPath == None)
	{
		if(ActorReachable(RouteGoal))
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

//Consult Rx_Bot for the new purchase logic

function bool FindInfiltrationPath()
{
	local actor BestPath, InfilPoint;
	local vector Dummy1,Dummy2;


	if(CurrentBO == None)
	{
		GoalString @= "- Building Objective not found";
		return false;
	}

	if(Vehicle(Pawn) != None || (LastVehicle != None && LastVehicle.bOkAgainstBuildings))
		return FindVehicleAssaultPath();

	InfilPoint = CurrentBO.InfiltrationPoint;

	if(InfilPoint == None)
	{
		GoalString @= "- pathway to building not found";
		return False;
	}

	if(RouteGoal == InfilPoint && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
	{
		SetAttractionState();
		return true;
	}
	else if(RouteGoal != InfilPoint)
		RouteGoal = InfilPoint;

	if(HasRepairGun() || Rx_Pawn_SBH(Pawn) != None)
		SetInfantryAvoidedPath();
	
	BestPath = FindPathToward(InfilPoint,true);

	if (VSizeSq(CurrentBO.myBuilding.GetMCT().location - Pawn.location) < 250000
		&&  Trace(Dummy1, Dummy2, CurrentBO.myBuilding.GetMCT().location, Pawn.location) == CurrentBO.myBuilding.GetMCT())
	{
		BestPath = CurrentBO.myBuilding.GetMCT();
		RouteGoal = BestPath;
	}

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


	if(NextVehicleAssaultPathRecalc < WorldInfo.TimeSeconds)
	{
		NextVehicleAssaultPathRecalc = WorldInfo.TimeSeconds + 20.0; 
		BuildingPoint = CurrentBO.myBuilding.FindAttackPointsFor(Self);
	}
	else
	{
		BuildingPoint = RouteGoal;
	}

	if(RouteGoal == BuildingPoint && MoveTarget != None && !Pawn.ReachedDestination(MoveTarget))
	{
		SetAttractionState();
		return true;
	}

	RouteGoal = BuildingPoint;
	
	if(Rx_Pawn(Enemy) != None && (VSizeSq(Pawn.Location - BuildingPoint.Location) <= 4000000 || CanAttack(CurrentBO.myBuilding)) && Trace(Dummy1, Dummy2, CurrentBO.myBuilding.location, Enemy.location) == CurrentBO.myBuilding)
	{
		RouteGoal = Enemy;
		BestPath = FindPathToward(Enemy,true);		
	}
	else
		BestPath = FindPathToward(BuildingPoint,true,,true);

	if (BestPath == None && Trace(Dummy1, Dummy2, CurrentBO.myBuilding.location, Pawn.location) == CurrentBO.myBuilding)
	{
		BestPath = CurrentBO.myBuilding;
		RouteGoal = BestPath;
	}

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
//			`log(GetHumanReadableName() @ "tries to return to Rush state...");
			GoalString = "CONTINUE INFILTRATION";
			if(FindInfiltrationPath())
				return;
		}
	}

	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSizeSq(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle + UTWeapon(Pawn.Weapon).SuggestAttackStyle();
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle - 0.5 * EnemyStrength
				+ FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));
	if ( UTWeapon(Enemy.Weapon) != None )
		Aggression += 2 * UTWeapon(Enemy.Weapon).SuggestDefenseStyle();
	if ( enemyDist > Square(MAXSTAKEOUTDIST) )
		Aggression += 0.5;
	if (Squad != None)
	{
		UTSquadAI(Squad).ModifyAggression(self, Aggression);
	}
	if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
	{
		if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE)
			Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
		else if ( (Skill < 4) && (enemyDist > Square(0.65 * MAXSTAKEOUTDIST)) )
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
		else if ( Skill + Tactics >= 3.5 + FRand() && !LostContact(1) && VSizeSq(Enemy.Location - Pawn.Location) < Square(MAXSTAKEOUTDIST) &&
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

function bool DefendMelee(float Dist)
{
	return ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon && (Dist < 1000) );
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

	if ( Pawn.bCanFly && !Enemy.bCanFly && (Pawn.Weapon == None || VSizeSq(Pawn.Location - Enemy.Location) < Square(Pawn.Weapon.MaxRange())) &&
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

	if ( Pawn.bCanPickupInventory && (UTPickupFactory(MoveTarget) != None) && (UTSquadAI(Squad).PriorityObjective(self) == 0) && (Vehicle(Pawn) == None)
		&& UTPickupFactory(MoveTarget).ShouldCamp(self, 5) )
	{
		CampTime = MoveTarget.LatentFloat;
		GoalString = "Short wait for inventory "$MoveTarget;
		GotoState('Patrolling','Pausing');
	}

	if(Vehicle(RouteGoal) != None)
	{
		GoalString = "Trying to board" @ RouteGoal.GetHumanReadableName();
	}
	else if(PlayerStart(RouteGoal) != None && PTTask != "")
	{
		GoalString = "Going towards Purchase Terminal";

		if(Vehicle(Pawn) != None && Enemy == None && VSizeSq(RouteGoal.Location - Pawn.Location) <= 562500)
			LeaveVehicle(true);
	}

	if(MoveTarget != None)
		MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	else
		Sleep(1.0);

DoneRoaming:
	WaitForLanding();

	if(GetOrders() == 'DEFEND' && PTTask == "")
		MoveToDefensePoint();

	LatentWhatToDoNext();

	if(!IsTimerActive('WaitAtAreaTimer')) 
	{
		GoalString @= "- STUCK IN ROAMING";
		if ( bSoaking )
			SoakStop("STUCK IN ROAMING!");
		

	}
}

State Fallback
{

	event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		local Pawn P;
		local UTVehicle V;

		if ( (Vehicle(Other) != None) && (Vehicle(Pawn) == None) )
		{
			if ( Other == RouteGoal || (Vehicle(RouteGoal) != None && Other == Vehicle(RouteGoal).GetVehicleBase()) )
			{
				V = UTVehicle(RouteGoal);
				if ( V != None )
				{
					V.TryToDrive(Pawn);
					if (Vehicle(Pawn) != None)
					{
						UTSquadAI(Squad).BotEnteredVehicle(self);
						WhatToDoNext();
					}
				}
				return true;
			}
		}

		// temporarily disable bump notifications to avoid getting overwhelmed by them
		Disable('NotifyBump');
		settimer(1.0, false, 'EnableBumps');

		if ( MoveTarget == Other )
		{
			if ( MoveTarget == Enemy && Pawn.HasRangedAttack() )
			{
				TimedFireWeaponAtEnemy();
				DoRangedAttackOn(Enemy);
			}
			return false;
		}

		P = Pawn(Other);
		if ( (P == None) || (P.Controller == None) )
			return false;

		if (PTTask == "" && (RouteCache.Length > 0) && !WorldInfo.GRI.OnSameTeam(self,P.Controller) && (MoveTarget == RouteCache[0]) && (RouteCache.Length > 1) && P.ReachedDestination(MoveTarget) )
		{
			MoveTimer = VSize(RouteCache[1].Location - Pawn.Location) / Pawn.GroundSpeed * Pawn.DesiredSpeed + 1;
			MoveTarget = RouteCache[1];
		}

		UTSquadAI(Squad).SetEnemy(self,P);
		if ( Enemy == Other )
		{
			Focus = Enemy;
			TimedFireWeaponAtEnemy();
		}

		if ( CheckPathToGoalAround(P) )
			return false;

		AdjustAround(P);
		return false;
	}

Begin:
	WaitForLanding();

Moving:
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN FALLBACK!");
	goalstring = goalstring$" STUCK IN FALLBACK!";
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
		{
			Focus = CurrentBO.myBuilding.GetMCT();
			AssaultMCT();
		}
	}
	else if (CurrentBO != None && !CanAttack(CurrentBO.myBuilding.GetMCT()))
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
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));


	if(CanAttack(CurrentBO.myBuilding.GetMCT()) && (Enemy == None || Rx_Weapon_TimedC4(Pawn.Weapon) != None))
		AssaultMCT();

	else if(Enemy != None && CanAttack(Enemy))
	{
		Focus = Enemy;
		ChooseAttackMode();
	} 
	else if(Rx_Weapon(Pawn.Weapon).bOkAgainstBuildings && CanAttack(CurrentBO.myBuilding))
	{
		Focus = CurrentBO.myBuilding;
		FireWeaponAt(CurrentBO.myBuilding);
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
	if(Rx_Vehicle(Pawn).bOkAgainstBuildings && LastObjectiveReconsideration < WorldInfo.TimeSeconds - 20.0)
		VehicleReconsiderObjective();


	if(!CanAttack(CurrentBO.myBuilding)) 
		MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	else if(CanAttack(CurrentBO.myBuilding) && (Enemy == None || !CanAttack(Enemy)))
	{
		if(IsRushing() && Rx_SquadAI(Squad).bTacticsCommenced)
			FireWeaponAt(CurrentBO.myBuilding);
		else
			DoRangedAttackOn(CurrentBO.MyBuilding);
	}	
	if (Enemy != None && VehicleShouldAttackEnemyInRush())
	{
		sleep(0.1);
		ChooseAttackMode();
	}

	if((Enemy == None || VSizeSq(Enemy.Location - Pawn.Location) > 250000) && HasABeacon() && VSizeSq(CurrentBO.myBuilding.Location - Pawn.Location) < 90000)
	{
//		`log(GetHumanReadableName()@"is attempting to plant a Beacon");
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

	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));


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

function VehicleReconsiderObjective()
{
	local Rx_Building B;
	local UTGameObjective O;

	LastObjectiveReconsideration = WorldInfo.TimeSeconds;

	for (O = OurTeamAI.Objectives; O != None; O = O.NextObjective)
	{
		if(Rx_BuildingObjective(O) != None)
		{
			B = Rx_BuildingObjective(O).myBuilding;
			if(B.GetTeamNum() != GetTeamNum() && CanAttack(B))
			{
				OurTeamAI.PutOnOffenseAttackO(Self,O);
				CurrentBO = Rx_BuildingObjective(O);
				return;
			}
		}
	}
}

State TacticalMove
{

	function Timer()
	{
		if (GetOrders() == 'DEFEND' && HasRepairGun())
		{
			if(GetNearbyDeployables(true) != None && CanAttack(DetectedDeployable))
			{	
				if(Enemy != None && CanAttack(Enemy) && VSizeSq(DetectedDeployable.Location - Enemy.Location) <= 160000)
				{
					Focus = Enemy;
				}
				else
					Focus = DetectedDeployable;

			}			
			else if (DefendedBuildingNeedsHealing() && CanAttack(CurrentBO.myBuilding.GetMCT()))
			{
				if(Enemy != None && CanAttack(Enemy) && Enemy.Controller.LineOfSightTo(CurrentBO.myBuilding.GetMCT()))
				{
					Focus = Enemy;
				}
				else
					Focus = CurrentBO.myBuilding.GetMCT();
			}
		}
		if (Enemy != None && Focus == Enemy && !bNotifyApex )
			TimedFireWeaponAtEnemy();
		
		else if (Focus != None)
			TimedFireWeaponAtFocus();

		else
			SetCombatTimer();
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

			
		SetDestinationPosition( Enemy.Location );
		WaitForLanding();
	}




	//If the bot is an engineer and have more pressing duty....



	SwitchToBestWeapon();

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

			MoveTo(GetDestinationPosition(), Focus);
	}

	FireWeaponAt(Focus);

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
		{
			FireWeaponAt(DetectedDeployable);
		}
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



/*
state GetOutOfBuilding
{

	function Actor GetNearestNav()
	{
		local array<NavigationPoint> out_NavList;
		local NavigationPoint Nav;	
		local float Dist;	
		class'NavigationPoint'.static.GetAllNavInRadius(Pawn,Pawn.location,200,out_NavList);
		Foreach out_NavList(Nav) {
			Dist = VSizeSq(Nav.location - Pawn.location);
			if(Dist > 900 && FastTrace(Nav.location - Pawn.location) && ActorReachable(Nav)) {
				return Nav;
			} 
//			
//			else {
//				return FindPathTowardNearest(class'Rx_DoorMarker');
//			}
			
		}
		return None;
	}


Begin:
	if(IsInBuilding())
		GoTo('GoOut');
	else
	{
		setStrafingDisabled(false);
		LatentWhatToDoNext();
	}

GoOut:
	tempActor = GetNearestNav();
	if(tempActor != None) {
		MoveToward(tempActor,tempActor,, false, false);
	} else {
		DoRandomJumps();
	}
	LatentWhatToDoNext();
}
*/

/*End modifier functions*/

state RoundEnded
{

}

/* Path Cost Modifier functions*/

function SetInfantryAvoidedPath()
{
	local Pawn E;
	local NavigationPoint N;
	local ReachSpec R;
	local Float Distance;

	if(Pawn.Anchor == None || Pawn.Anchor.PathList.Length <= 0)
		return;

	foreach WorldInfo.AllPawns(class'Pawn', E, Pawn.Location, 5000)
	{
		if(E.GetTeamNum() == GetTeamNum() || E.GetTeamNum() == 255) //ignore allies/neutrals
			continue;

		foreach Pawn.Anchor.PathList(R)
		{
			N = R.GetEnd();

			Distance = VSizeSq(N.Location - E.Location);

			if(Distance <= 4000000 && FastTrace(N.Location, E.Location))
				N.TransientCost = 8000000 - (Distance * 2);
		}
	}
}

/* End Path Cost Modifier functions*/

DefaultProperties
{

}

 
