/*********************************************************
*
* File: Rx_CharInfo_Singleplayer.uc
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
class Rx_SquadAI_Waypoints extends Rx_SquadAI;

var float VehicleFormationSize;

const RX_NEAROBJECTIVEDIST = 3500.0;



function bool CheckSquadObjectives(UTBot B)
{
	local Actor DesiredPosition;
	local bool bInPosition;
	local Vehicle V;
	local UTGameObjective UTObjective;
	local vector DesiredLocation;
	local Float Dist;


	if(Rx_Weapon_DeployedActor(B.Focus) != None && Rx_Bot(B).IsHealing(false) && Rx_Bot(B).IsInState('Defending'))		// Handepsilon - To prevent the ADHD tendencies when repping Beacon etc.
		return true;

	if (GetOrders() != 'DEFEND' && CheckVehicle(B))
		return true;

	if ( (PlayerController(SquadLeader) != None) && (SquadLeader.Pawn != None) )
	{
		if ( UTHoldSpot(B.DefensePoint) == None )
		{
			// attack objective if close by
			if ( OverrideFollowPlayer(B) )
				return true;

			// follow human leader
			return TellBotToFollow(B,SquadLeader);
		}
		// hold position as ordered (position specified by DefensePoint)
	}

/*	
	if (Vehicle(B.Pawn) != None  && B.Pawn.bStationary)
	{
		if ( UTHoldSpot(B.DefensePoint) != None )
		{
			if ( UTHoldSpot(B.DefensePoint).HoldVehicle != B.Pawn && UTHoldSpot(B.DefensePoint).HoldVehicle != B.Pawn.GetVehicleBase() )
			{
				B.LeaveVehicle(true);
				return true;
			}
		}
	}
*/
	V = Vehicle(B.Pawn);

	UTObjective = UTGameObjective(SquadObjective);

	if(Rx_Bot(B).DefendedBuildingNeedsHealing())
	{
		UTObjective.TellBotHowToHeal(B);
		return true;
	}

	if ( B.DefensePoint != None )
	{
		DesiredPosition = B.DefensePoint.GetMoveTarget();
		bInPosition = (B.Pawn == DesiredPosition) || B.Pawn.ReachedDestination(DesiredPosition);
		if ( bInPosition && (Vehicle(DesiredPosition) != None) )
		{
			if (V != None && B.Pawn != DesiredPosition && B.Pawn.GetVehicleBase() != DesiredPosition)
			{
				B.LeaveVehicle(true);
				return true;
			}
			if (V == None)
			{
				B.EnterVehicle(Vehicle(DesiredPosition));
				return true;
			}
		}
		if (B.ShouldDefendPosition())
		{
			return true;
		}
	}
	else if ( SquadObjective == None )
		return TellBotToFollow(B,SquadLeader);
	else if ( GetOrders() == 'FREELANCE' && (UTVehicle(B.Pawn) == None || !UTVehicle(B.Pawn).bKeyVehicle) )
	{
		return false;
	}
	else
	{
		if ( UTObjective.DefenderTeamIndex != Team.TeamIndex )
		{
			if ( UTObjective.bIsDisabled )
			{
				B.GoalString = "Objective already disabled";
				return false;
			}
			B.GoalString = "Disable Objective "$SquadObjective;
			return UTObjective.TellBotHowToDisable(B);
		}
		if (B.DefensivePosition != None && AcceptableDefensivePosition(B.DefensivePosition, B))
		{
			DesiredPosition = B.DefensivePosition;
		}
		else if (UTObjective.bBlocked)
		{
			DesiredPosition = FindDefensivePositionFor(B);
		}
		else
		{
			DesiredPosition = UTObjective;
		}
		if(DesiredPosition == UTObjective) 
		{
			DesiredLocation = Rx_BuildingObjective(UTObjective).GetInfiltrationPoint().location;
		} 
		else 
		{
			DesiredLocation = DesiredPosition.location;
		} 
		bInPosition = ( VSizeSq(DesiredLocation - B.Pawn.Location) < Square(RX_NEAROBJECTIVEDIST) &&
				(B.LineOfSightTo(Rx_BuildingObjective(UTObjective).myBuilding) || (UTObjective.bHasAlternateTargetLocation && B.LineOfSightTo(Rx_BuildingObjective(UTObjective).myBuilding,, true))) );
	}

	if ( B.Enemy != None )
	{
		if ( B.LostContact(5) )
			B.LoseEnemy();
		if ( B.Enemy != None )
		{
			if ( B.LineOfSightTo(B.Enemy) || (WorldInfo.TimeSeconds - B.LastSeenTime < 3 && (SquadObjective == None || !UTGameObjective(SquadObjective).TeamLink(Team.TeamIndex))) 
				&& (UTVehicle(B.Pawn) == None || !UTVehicle(B.Pawn).bKeyVehicle) )
			{
				Dist = VSizeSq(B.location - B.Enemy.location);
				if(!Rx_Bot(B).HasRepairGun()) 
				{
					B.FightEnemy(BotsEnemyIsCloserToObjective(B), 0); 
					return true;	
				} 
				else if(Dist < 6760000 && (SquadObjective == None || Rx_BuildingObjective(SquadObjective) == None 
							|| !Rx_BuildingObjective(SquadObjective).NeedsHealing() 
							|| Rx_BuildingObjective(SquadObjective).KillEnemyFirstBeforeHealing(B))) 
				{
					B.FightEnemy(false, 0);
					return true;	
				}
			}
		}
	}



	if ( bInPosition )
	{
		B.GoalString = "Near defense position" @ DesiredPosition;

		if ( B.DefensePoint != None )
			B.MoveToDefensePoint();
		else
		{
			if ( UTObjective.TellBotHowToHeal(B) )
			{
				return true;
			}

			if (B.Enemy != None && (B.LineOfSightTo(B.Enemy) || WorldInfo.TimeSeconds - B.LastSeenTime < 3))
			{
				B.FightEnemy(false, 0);
				return true;
			}

			B.WanderOrCamp();
		}
		return true;
	}

	if (B.Pawn.bStationary && !Rx_Bot(B).IsInState('WaitForTactics'))
		return false;

	B.GoalString = "Follow path to "$DesiredPosition;
	if (DesiredPosition == UTObjective && UTObjective.bAllowOnlyShootable)
	{
		if (B.ActorReachable(UTObjective))
		{
			B.MoveTarget = UTObjective;
		}
		else
		{
			UTObjective.MarkShootSpotsFor(B.Pawn);
			// make sure Anchor wasn't marked, because if it was acceptable we wouldn't have reached this code
			if (B.Pawn.Anchor != None)
			{
				B.Pawn.Anchor.bTransientEndPoint = false;
			}
			B.FindBestPathToward(DesiredPosition, true, true);
		}
	}
	else
	{
		B.FindBestPathToward(DesiredPosition, false, true);
	}
	if ( B.StartMoveToward(DesiredPosition) )
		return true;

	if ( (B.DefensePoint != None) && (DesiredPosition == B.DefensePoint) )
	{
		B.FreePoint();
		if ( (UTObjective != None) && (VSizeSq(B.Pawn.Location - UTObjective.Location) > 1440000) )
		{
			B.FindBestPathToward(UTObjective,false,true);
			if ( B.StartMoveToward(UTObjective) )
				return true;
		}
	}
	return false;
}

function NavigationPoint FindDefensivePositionFor(UTBot B)
{
	local PathNode N, Best;
	local int Num;
	local float CurrentRating, BestRating;
	local Actor Center;

	if(Rx_BuildingObjective(SquadObjective) != None) 
	{
		if(Rx_BuildingObjective(SquadObjective).IsCritical()) 
		{
			Center = Rx_BuildingObjective(SquadObjective).myBuilding.GetMCT();
		}
		if(Rx_BuildingObjective(SquadObjective).GetInfiltrationPoint() != None && Rx_BuildingObjective(SquadObjective).NeedsHealing())
		{
			return Rx_BuildingObjective(SquadObjective).GetInfiltrationPoint();
		}
		if(Center != None) 
		{
			foreach WorldInfo.RadiusNavigationPoints(class'PathNode', N, Center.Location, 2500)
			{
				CurrentRating = RateDefensivePosition(N, B, Center);
				if (CurrentRating > BestRating)
				{
					BestRating = CurrentRating;
					Best = N;
					Num = 1;
				}
				else if ( CurrentRating == BestRating )
				{
					Num++;
					if ( (Best == None) || (Rand(Num) == 0) )
					{
						Best = N;
					}
				}
			}
			return Best;
		}
	} 
	else 
	{
		return super.FindDefensivePositionFor(B);
	}
	return None;
}

function bool BotsEnemyIsCloserToObjective(UTBot B) 
{
	if(SquadObjective != None && VSizeSq(B.location - Rx_BuildingObjective(SquadObjective).GetInfiltrationPoint().location) 
			> VSizeSq(B.Enemy.location - Rx_BuildingObjective(SquadObjective).GetInfiltrationPoint().location)) 
	{
		return true;
	}
	return false;
}

function bool CloseToLeader(Pawn P)
{
	local bool ret;
	local float dist;
	
	ret = super.CloseToLeader(P);
	if(ret) {
		return true;
	}
	if(Vehicle(P) == None) {
		return false;
	} 
	
	dist = VSizeSq(P.Location - SquadLeader.Pawn.Location);
	if ( dist > Square(FormationSize) ) {
		if(dist <= Square(VehicleFormationSize)) {
			return true;
		} else { // then its not the distance so check the other stuff again
			if ( PhysicsVolume.bWaterVolume ) { // check if leader is moving away
				if ( VSizeSq(SquadLeader.Pawn.Velocity) > 0 )
					return false;
			}
			else if ( VSizeSq(SquadLeader.Pawn.Velocity) > Square(SquadLeader.Pawn.WalkingPct * SquadLeader.Pawn.GroundSpeed )) {
				return false;
			}
		
			return ( P.Controller.LineOfSightTo(SquadLeader.Pawn) );	
		}
	}
	return false;
}

function float RateDefensivePosition(NavigationPoint N, UTBot CurrentBot, Actor Center)
{
	local float Rating, Dist, MCTReachMod;
	local UTBot B;
	local int i;
	local ReachSpec ReverseSpec;
	local bool bNeedSpecialMove;
	local UTPawn P;
	//local vector out_HitLocation;
	//local vector out_HitNormal;	
	local Rx_Building Building;
	local Actor MCT;
	local Vector HitLoc,HitNormal;

	MCTReachMod = 0.5;

	if(!Center.IsA('Rx_BuildingObjective')) 
	{
		if (N.bDestinationOnly || N.IsA('Teleporter') || N.IsA('PortalMarker') || (N.bFlyingPreferred && !CurrentBot.Pawn.bCanFly))
			//(!FastTrace(N.Location, Center.GetTargetLocation()) && (!Center.bHasAlternateTargetLocation || !FastTrace(N.Location, Center.GetTargetLocation(, true)))))
			return -1.0;
	} 
	else 
	{
		Building = Rx_BuildingObjective(Center).myBuilding;
		Dist = VSizeSq(N.Location - Building.GetTargetLocation());
		MCT = Building.GetMCT();

		if(Rx_BuildingObjective(Center).IsCritical())
		{
			if(Trace(HitLoc, HitNormal, MCT.Location, N.Location) != MCT)
				MCTReachMod = 1;	// Prioritize the points in which bots can fire on MCT
		}
		/**
		if (Dist > Square(CurrentBot.Pawn.Weapon.MaxRange()))
		{
			if(Building != Trace( out_HitLocation, out_HitNormal, Building.GetTargetLocation(), N.Location)) {
				return -1.0;
			}
			Dist = VSizeSq(N.Location - out_HitLocation);
			if(Dist > Square(CurrentBot.Pawn.Weapon.MaxRange() - 50)) {
				return -1.0; 
			}
		}
		*/
	}

	// if bot can't double jump, disregard points only reachable by that method
	P = UTPawn(CurrentBot.Pawn);
	if ( P == None || !P.bCanDoubleJump )
	{
		bNeedSpecialMove = true;
		for (i = 0; i < N.PathList.length; i++)
		{
			if (N.PathList[i].GetEnd() != None)
			{
				ReverseSpec = N.PathList[i].GetEnd().GetReachSpecTo(N);
				if ( ReverseSpec != None &&
					!ReverseSpec.IsBlockedFor(P) &&
					((ReverseSpec.reachFlags & 16) == 0 || (P != None && P.bCanDoubleJump)) )
				{
					bNeedSpecialMove = false;
					break;
				}
			}
		}
		if (bNeedSpecialMove)
		{
			return -1.0;
		}
	}

	// make sure no squadmate using this point, and adjust rating based on proximity
	Rating = 1;
	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
	{
		if ( B != CurrentBot )
		{
			if ( (B.DefensePoint == N) || (B.DefensivePosition == N) )
			{
				return -1;
			}
			else if ( B.Pawn != None )
			{
				Rating *= 0.002*VSize(B.Pawn.Location - N.Location);
			}
		}
	}

	if(Center.IsA('Rx_BuildingObjective')) 
	{
		Dist = VSizeSq(N.Location - Building.GetTargetLocation());
	} 
	else 
	{
		Dist = VSize(N.Location - Center.Location);
	}
	if (Dist < 160000.0 || (Center.IsA('Rx_BuildingObjective') && Dist < 4000000))
	{
		return (0.00025 * Sqrt(Dist) * MCTReachMod);
	}

	return (Rating * MCTReachMod);
}

/** Dont enter vehicle when Bot should heal building instead */
function bool CheckVehicle(UTBot B) 
{
	//	Handepsilon - These locals came from the UTSquadAI's function. Left unchanged so that it's not a pain to replace and stuff
	local UTVehicle V, SquadVehicle;
	local Vehicle BotVehicle;
	local float NewDist, BestDist, NewRating, BestRating, BaseRadius;
	local UTBot S;
	local PlayerController PC;
	local bool bSkip, bVisible;
	local UTSquadAI Squad;
	local UTTeamAI TeamAI;

	if(SquadObjective != None && Rx_BuildingObjective(SquadObjective) != None 
			&& Rx_Bot(B).HasRepairGun() 
			&& Rx_BuildingObjective(SquadObjective).NeedsHealing() 
			&& !Rx_BuildingObjective(SquadObjective).KillEnemyFirstBeforeHealing(B)) {
		return false;
	} 
	else 
	{
	/** The rest of this is copied and retweaked from UTSquad AI */
		if ( UTHoldSpot(B.DefensePoint) != None ) {
			return false;
		}

		if (B.NoVehicleGoal != None)
		{
			// if NoVehicleGoal is a flag, use its Anchor instead as RouteGoal is usually a NavigationPoint
			if (B.NoVehicleGoal.IsA('UTCarriedObject'))
			{
				B.NoVehicleGoal = UTCarriedObject(B.NoVehicleGoal).LastAnchor;
			}
			// if the bot's current goal is the NoVehicleGoal
			// or NoVehicleGoal is our SquadObjective and the bot's current goal is towards our SquadObjective
			if ( Vehicle(B.Pawn) == None &&
				(B.RouteGoal == B.NoVehicleGoal || (B.NoVehicleGoal == SquadObjective && IsOnPathToSquadObjective(B.RouteGoal))) )
			{
				// don't use a vehicle to get to this goal
				return false;
			}
			else
			{
				B.NoVehicleGoal = None;
			}
		}
		// don't mess with vehicles when on mover that is still moving
		if (B.PendingMover != None && !IsZero(B.PendingMover.Velocity))
		{
			return false;
		}
		//If Bot is in a vehicle and is in a criticalChargeAttack, then continue charging and return.
		if ( UTVehicle(B.Pawn) != None && UTVehicle(B.Pawn).CriticalChargeAttack(B) )
		{
//			`log("Rx_SquadAI_Waypoints: Charging!"); 
			B.GoalString = "Charge";
			B.DoCharge();
			return true;
		}
		//If Bot is not in a vehicle, but has a route to a vehicle and isn't stuck?
		if ( (Vehicle(B.Pawn) == None) && (Vehicle(B.RouteGoal) != None) && (NavigationPoint(B.Movetarget) != None) ) {
			if ( VSizeSq(B.Pawn.Location - B.RouteGoal.Location) < Square(B.Pawn.GetCollisionRadius() + Vehicle(B.RouteGoal).GetCollisionRadius() + B.Pawn.VehicleCheckRadius * 1.5 )) {
//				`log("Rx_SquadAI_Waypoints: RouteGoal!"); 
				B.MoveTarget = B.RouteGoal;
			}
		}
		V = UTVehicle(B.MoveTarget);
		//Bot isn't a vehicle, Vehicle exists, 
		if (Vehicle(B.Pawn) == None && V != None && V.Health > 0 && !V.bDeleteMe) 
		{
			if (V.PlayerStartTime > WorldInfo.TimeSeconds) 
			{
				ForEach LocalPlayerControllers(class'PlayerController', PC)
				{
					if ( (PC.PlayerReplicationInfo.Team == Team) && (PC.Pawn != None) && ((Vehicle(PC.Pawn) == None) || (UTVehicle_Hoverboard(PC.Pawn) != None)) ) {
						bSkip = true;
						break;
					}
				}
			}
			if (!bSkip)
			{
				// `log("Rx_SquadAI_Waypoints: Consider to heal Vehicle before getting in!"); 
				//consider healing vehicle before getting in
				if (V.Health < V.HealthMax && WorldInfo.Game.bTeamGame && (B.Enemy == None || !B.LineOfSightTo(B.Enemy)) && B.CanAttack(V))
				{
					if (V.TeamLink(Team.TeamIndex))
					{
						if (UTWeapon(B.Pawn.Weapon) != None && UTWeapon(B.Pawn.Weapon).CanHeal(V))
						{
							B.GoalString = "Heal "$V;
							B.LastCanAttackCheckTime = WorldInfo.TimeSeconds;
							B.DoRangedAttackOn(V);
							return true;
						}
						else
						{
							B.SwitchToBestWeapon();
							if (UTWeapon(B.Pawn.InvManager.PendingWeapon) != None && UTWeapon(B.Pawn.InvManager.PendingWeapon).CanHeal(V))
							{
								B.GoalString = "Heal "$V;
								B.LastCanAttackCheckTime = WorldInfo.TimeSeconds;
								B.DoRangedAttackOn(V);
								return true;
							}
						}
					}
				}
				if ( V.GetVehicleBase() != None )
					BaseRadius = V.GetVehicleBase().GetCollisionRadius();
				else
					BaseRadius = V.GetCollisionRadius();
				if ( VSizeSq(B.Pawn.Location - V.Location) < Square(B.Pawn.GetCollisionRadius() + BaseRadius + B.Pawn.VehicleCheckRadius) ||
					(V.bHasCustomEntryRadius && V.InCustomEntryRadius(B.Pawn)) ||
					B.Pawn.ReachedDestination(V) )
				{
					B.EnterVehicle(V);
					return true;
				}
			}
		}
		if ( B.LastSearchTime == WorldInfo.TimeSeconds ) {
			return false;
		}

		BotVehicle = Vehicle(B.Pawn);
		if (BotVehicle != None) 
		{
			if (!NeverBail(BotVehicle)) 
			{
				if(B.Enemy != None && B.CanAttack(B.Enemy) && !V.ShouldLeaveForCombat(B))
				{
					// Don't risk vehicle being stolen even if stuck if there's an enemy
					return true;
				}

				else if (BotVehicle.StuckCount > 3) 
				{
					// vehicle is stuck
					if (BotVehicle.IsA('UTVehicle')) {
						UTVehicle(BotVehicle).VehicleLostTime = WorldInfo.TimeSeconds + 20;
					}
					B.LeaveVehicle(true);
					return true;
				} 
				else 
				{
					V = UTVehicle(BotVehicle);
					if (V == None) {
						V = UTVehicle(BotVehicle.GetVehicleBase());
					}
					if (V != None && B.Enemy != None && V.ShouldLeaveForCombat(B) && B.LineOfSightTo(B.Enemy)) {
						B.LeaveVehicle(true);
						return true;
					}
				}
			}
			// if in passenger seat of a multi-person vehicle, get out if no driver
			V = UTVehicle(BotVehicle.GetVehicleBase());
			if ( V != None ) {
				if ( V.Driver == None && (SquadLeader == B || SquadLeader.RouteGoal == None || SquadLeader.RouteGoal != V) && !V.IsDriverSeat(BotVehicle) ) {
					B.LeaveVehicle(true);
					return true;
				}
				return false;
			}

			V = UTVehicle(BotVehicle);

			if (V == None || !V.bShouldLeaveForCombat) {
				return false;
			}
		}

		// check squadleader vehicle
		V = UTVehicle(SquadLeader.Pawn);
		if ( V != None && VSizeSq(V.Location - B.Pawn.Location) < 16000000.0 && V.OpenPositionFor(B.Pawn) &&
			(V.NoPassengerObjective == None || V.NoPassengerObjective != SquadObjective) &&
			(V.bCanCarryFlag || !UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag) )
		{
			SquadVehicle = V;
		}
		else if ( PlayerController(SquadLeader) != None ) {
			`log("Rx_SquadAI_Waypoints: CheckHoverboard!");
			return CheckHoverboard(B);
		}

		// check other squadmember vehicle
		BestDist = Square(MaxVehicleDist(B.Pawn));
		if ( SquadVehicle == None ) {
			for ( S=SquadMembers; S!=None; S=S.NextSquadMember ) {
				V = UTVehicle(S.Pawn);
				if ( V != None && VSizeSq(V.Location - B.Pawn.Location) < BestDist && V.OpenPositionFor(B.Pawn) &&
					(V.NoPassengerObjective == None || V.NoPassengerObjective != SquadObjective) &&
					(V.bCanCarryFlag || !UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag) )
				{
					SquadVehicle = V;
					break;
				}
			}
		}

		// check vehicle squad leader is heading towards
		if (SquadVehicle == None) {
			V = UTVehicle(SquadLeader.RouteGoal);
			if ( V != None && !V.Occupied() && VSizeSq(V.Location - B.Pawn.Location) < BestDist && V.OpenPositionFor(B.Pawn) &&
				(V.NoPassengerObjective == None || V.NoPassengerObjective != SquadObjective) &&
				(V.bCanCarryFlag || !UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag) )
			{
				SquadVehicle = V;
			}
		}

		// check if bot is already heading towards a vehicle
		if (SquadVehicle == None) {
			V = UTVehicle(B.RouteGoal);
			if (V != None && !V.Occupied() && VSizeSq(V.Location - B.Pawn.Location) < BestDist * 1.44 && VehicleDesireability(V, B) > 0.0)
			{
				SquadVehicle = V;
			}
		}

		// check if other squad has key vehicle
		if (SquadVehicle == None && Team != None) {
			TeamAI = UTTeamInfo(Team).AI;
			for ( Squad = TeamAI.Squads; Squad != None; Squad = Squad.NextSquad )
			{
				if (Squad.SquadLeader != None)
				{
					V = UTVehicle(Squad.SquadLeader.Pawn);
					if ( V != None && V.bKeyVehicle && V.NoPassengerObjective != Squad.SquadObjective &&
						VSizeSq(V.Location - B.Pawn.Location) < 16000000.0 &&
						(Squad.GetOrders() == GetOrders() || PlayerController(Squad.SquadLeader) != None) &&
						V.OpenPositionFor(B.Pawn) && V.NumPassengers() < Team.Size / 2 )
					{
						SquadVehicle = V;
						break;
					}
				}
			}
		}

		// see if should let human player get it instead
		if ( (SquadVehicle != None) && (SquadVehicle.PlayerStartTime > WorldInfo.TimeSeconds) ) {
			ForEach LocalPlayerControllers(class'PlayerController', PC) {
				if ( (PC.PlayerReplicationInfo.Team == Team) && (PC.Pawn != None) && (Vehicle(PC.Pawn) == None) ) {
					SquadVehicle = None;
					break;
				}
			}
		}

		if ( SquadVehicle == None ) 
		{
			// look for nearby vehicle
			GetOrders();
			for ( V=UTGame(WorldInfo.Game).VehicleList; V!=None; V=V.NextVehicle ) 
			{
				if(Rx_Defence(V) != None)
					continue;

				NewDist = VSizeSq(B.Pawn.Location - V.Location);
				if (NewDist < BestDist) 
				{
					bVisible = V.FastTrace(V.Location, B.Pawn.Location + B.Pawn.GetCollisionHeight() * vect(0,0,1));
					if (!bVisible) 
					{
						NewDist *= 1.5;
					}
					if (NewDist < BestDist) 
					{
						NewRating = VehicleDesireability(V, B);
						
						if (NewRating > 0.0) 
						{
							NewRating += BestDist / NewDist * 0.01;
							if ( NewRating > BestRating &&
								( V.bTeamLocked || V.bKeyVehicle || bVisible ||
									(V.ParentFactory != None && VSizeSq(V.Location - V.ParentFactory.Location) < Square(V.GetCollisionRadius())) ) )
							{
								SquadVehicle = V;
								BestRating = NewRating;
							}
						}
					}
				}
			}
		}

		if (SquadVehicle == None) 
		{
			return false; //No Hoverboard for you lol
		}

		return GotoVehicle(SquadVehicle, B);		
	}
}


function bool ShouldUseAlternatePaths()
{
	local Rx_BuildingObjective BuildingObjective;
	local bool ret;

	// use alternate paths only when attacking active enemy objective
	BuildingObjective = Rx_BuildingObjective(SquadObjective);
	ret = (BuildingObjective != None && BuildingObjective.DefenderTeamIndex != Team.TeamIndex && !BuildingObjective.bIsDisabled);
	return ret;
}

/** @return the maximum distance a bot should be from the given Actor it wants to defend */
function float GetMaxDefenseDistanceFrom(Actor Center, UTBot B)
{
	return (Pawn(Center) != None ? FormationSize : RX_NEAROBJECTIVEDIST);
}

function bool CheckHoverboard(UTBot B) 
{
	return false;
}

function bool GotoVehicle(UTVehicle SquadVehicle, UTBot B) 
{
	if(Rx_Vehicle(squadVehicle).buyerPri != None && Rx_Vehicle(squadVehicle).buyerPri != B.PlayerReplicationInfo) 
	{
		return false;
	}
	else if (Rx_Defence(SquadVehicle) != None)
	{
		return false;
	} 
	else 
	{
		return super.GotoVehicle(SquadVehicle, B);
	}

}

/** @return whether bot should continue along its path on foot or stay in its current vehicle */
function bool AllowContinueOnFoot(UTBot B, UTVehicle V)
{
	return false;
	/**
	if ( V.Health > 0.2*V.Default.Health ) {
		return false;
	}
	return super.AllowContinueOnFoot(B,V);
	*/
}

/**
function bool SetEnemy( UTBot B, Pawn NewEnemy )
{
	local bool ret;
	if(super.SetEnemy(B,NewEnemy)) {
		if(Rx_Vehicle(B.Pawn) != None) {
			ret = Rx_Vehicle(B.Pawn).ValidEnemyForVehicle(NewEnemy); 
		} else {
			ret = true;
		}
	}
	if(ret) {
		Rx_Bot(B).InvalidEnemy = None;		
	}
	return ret;
}
*/

function float AssessThreat( UTBot B, Pawn NewThreat, bool bThreatVisible )
{
	local float ret, Dist;

	ret = super.AssessThreat(B,NewThreat,bThreatVisible);
	if(Rx_Vehicle(B.Pawn) != None && !Rx_Vehicle(B.Pawn).ValidEnemyForVehicle(NewThreat)) {
		ret -= 20;	
	} 

	// higher threat when a spy is getting close 
	// TODO: when getting out of range bot should still have some kind of threat value to spy
	if (Rx_Pawn(NewThreat) != none && Rx_Pawn(NewThreat).isSpy())
	{
		Dist = VSizeSq(NewThreat.Location - B.Pawn.Location);
		if (Dist <= Square(class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius) && bThreatVisible)
		{
			ret += (class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius - Sqrt(Dist)) / class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius;
		}
		else
		{
			ret -= 10;
		}
	}
	return ret;	
}


function bool ValidEnemy(Pawn NewEnemy)
{
	local bool bRet;
	local UTBot M;
	local float SpyTrackRadius;
	
	bRet = super.ValidEnemy(NewEnemy);
	SpyTrackRadius = class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius / 2;

	// if upper logic says yes, check for spy
	if (bRet && Rx_Pawn(NewEnemy) != none && Rx_Pawn(NewEnemy).isSpy())
	{					
		// look for a bot that is near the spy, if so add as enemy
		// TODO: if player spots spy, bots should add spy as enemy too
		for	( M = SquadMembers; M != None; M = M.NextSquadMember )
		{										
			if (VSizeSq(NewEnemy.Location - M.Pawn.Location) <= Square(SpyTrackRadius))
			{
				return true;
			}
		}
		return false;
	}
	return bRet;
}

function SetObjective(UTGameObjective O, bool bForceUpdate)
{
	if(Rx_AreaObjective(O) != None) {
		if ( SquadObjective == O )
		{
			if ( SquadObjective == None )
				return;
			if ( Rx_AreaObjective(O).TeamSquads[GetTeamNum()] == None )
				Rx_AreaObjective(O).TeamSquads[GetTeamNum()] = self;
			if ( !bForceUpdate )
				return;
		}
		else
		{
			if ( Rx_AreaObjective(O).TeamSquads[GetTeamNum()] == None )
				Rx_AreaObjective(O).TeamSquads[GetTeamNum()] = self;			
			bForceNetUpdate = TRUE;
			SquadObjective = O;
		}	
	} 
	else 
	{
		super.SetObjective(O,bForceUpdate);
	}
}

function bool TellBotToFollow(UTBot B, Controller C)
{
	if(C != None && UTPlayercontroller(C) == None && Rx_Vehicle(B.Pawn) != None && Rx_Vehicle(C.Pawn) == None) {
		return false;
	}
	return super.TellBotToFollow(B,C);
}

function bool OverrideFollowPlayer(UTBot B)
{
	local UTGameObjective PickedObjective;
	local UTTeamAI TeamAI;
	
	TeamAI = UTTeamInfo(Team).AI;
	PickedObjective = TeamAI.GetPriorityAttackObjectiveFor(self, B);
	if ( (PickedObjective == None) )
		return false;

	if(Rx_BuildingObjective(PickedObjective) == None && UTPlayerController(SquadLeader) != None) {
		return false; // follow player until enemy base is reached	
	}
		
	if ( PickedObjective.BotNearObjective(B) )
	{
		if ( PickedObjective.DefenderTeamIndex == Team.TeamIndex )
		{
			return PickedObjective.TellBotHowToHeal(B);
		}
		else
			return PickedObjective.TellBotHowToDisable(B);
	}
	if ( PickedObjective.DefenderTeamIndex == Team.TeamIndex )
		return false;
	if ( PickedObjective.Shootable() )
		if( Rx_BuildingObjective(PickedObjective) != None && PickedObjective.DefenderTeamIndex != B.GetTeamNum())
			return PickedObjective.TellBotHowToDisable(B);
	return false;
}

function bool NeverBail(Pawn P)
{
	local bool ret;
	
	ret = super.NeverBail(P);
	if(!ret && Vehicle(P).StuckCount <= 3)
	{
		ret=true;
	}
	return ret;
}

function bool IsOnPathToSquadObjective(Actor Goal)
{
	local NavigationPoint Nav;
	local UTGameObjective UTObjective;

	if (Goal == SquadObjective)
	{
		return true;
	}
	else
	{
		Nav = NavigationPoint(Goal);
		if (Nav != None)
		{
			UTObjective = UTGameObjective(SquadObjective);

			if(Rx_BuildingObjective(SquadObjective) != None)
			{
				if(Nav == Rx_BuildingObjective(SquadObjective).GetInfiltrationPoint())
					return true;
				If(Goal == Rx_BuildingObjective(SquadObjective).myBuilding.GetMCT())
					return true;

			}

			if ( UTObjective.VehicleParkingSpots.Find(Nav) != INDEX_NONE ||
				(UTObjective.Shootable() && UTObjective.ShootSpots.Find(Nav) != INDEX_NONE) ||
				(UTObjective == RouteObjective && ObjectiveRouteCache.Find(Nav) != INDEX_NONE) )
			{
				return true;
			}
		}
	}

	return false;
}

/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(UTBot B, Actor O)
{
	local Vehicle V;
	local UTGameObjective Objective;
	local Rx_BuildingObjective BO;
	local int i, RouteIndex;
	local float GatherWaitTime;
	local UTBot M;
	local bool bDoneGathering;
	local NavigationPoint N;

	if ( O == None )
	{
		O = SquadObjective;
		if ( O == None )
		{
			B.GoalString = "No SquadObjective";
			return false;
		}
	}

	Objective = UTGameObjective(O);

	if (Objective != None)
	{
		BO = Rx_BuildingObjective(O);

		if (B.Pawn.bStationary )
		{
			V = B.Pawn.GetVehicleBase();
			if ( V == None )
			{
				V = Vehicle(B.Pawn);
				if (V == None)
				{
					return false;
				}
			}
			if (Objective.ReachedParkingSpot(V))
			{
				LeaveVehicleAtParkingSpot(B, O);
				return true;
			}
			else
			{
				return false;
			}
		}
	 	else if (Vehicle(B.Pawn) != None)
		{
			if (Objective.ReachedParkingSpot(B.Pawn))
			{
				LeaveVehicleAtParkingSpot(B, O);
				return true;
			}
		}
	}

	if (UTVehicle(B.Pawn) != None && MustCompleteOnFoot(O, B.Pawn))
	{
		if (VSizeSq(O.Location - B.Pawn.Location) <= Square(B.Pawn.GetCollisionRadius()))
		{
			// too close, vehicle is covering the objective, back up
			N = NavigationPoint(O);
			if (N != None)
			{
				for (i = 0; i < N.PathList.length; i++)
				{
					if (N.PathList[i].GetEnd() != None)
					{
						N.PathList[i].GetEnd().bTransientEndPoint = true;
					}
				}
			}
			B.FindRandomDest();
			B.MoveTarget = B.RouteCache[0];
			B.SetAttractionState();
			return true;
		}
		else if ( UTVehicle(B.Pawn).bKeyVehicle && CloseEnoughToObjective(B, O) )
			{
				return false;
			}
		else if (LeaveVehicleToReachObjective(B, O))
		{
			return true;
		}
	}

	// if we should use parking spots, but haven't reached any of them, mark them as endpoints for pathfinding to the objective
	if (Vehicle(B.Pawn) != None && Objective != None)
	{
		for (i = 0; i < Objective.VehicleParkingSpots.length; i++)
		{
			Objective.VehicleParkingSpots[i].bTransientEndPoint = true;
		}
	}

	if ( (O != RouteObjective) || ((UTVehicle(B.Pawn) != None) && UTVehicle(B.Pawn).ImportantVehicle()) )
	{
		if(BO != None && Vehicle(B.Pawn) == None)
		{
			if(Rx_Bot(B) != None && Rx_Bot(B).bInfiltrating && Rx_Bot(B).LineOfSightTo(BO.myBuilding.GetMCT()))
				return B.SetRouteToGoal(BO.myBuilding.GetMCT());

			return B.SetRouteToGoal(BO.GetInfiltrationPoint());
		}
		else
			return B.SetRouteToGoal(O);
	}

	// see if we should wait for some more friendlies to catch up
	if (!B.bUsePreviousSquadRoute && !B.bFinalStretch && bShouldUseGatherPoints)
	{
		if (!B.bReachedGatherPoint && (B.Enemy == None || B.LostContact(1)) && B.Pawn.ValidAnchor())
		{
			RouteIndex = ObjectiveRouteCache.Find(B.Pawn.Anchor);
			if (RouteIndex != INDEX_NONE && RouteIndex > ObjectiveRouteCache.length * 0.7)
			{
				B.bReachedGatherPoint = true;
				B.GatherTime = WorldInfo.TimeSeconds;
			}
		}
		if (B.bReachedGatherPoint)
		{
			GatherWaitTime = (B.Enemy == None || !B.LineOfSightTo(B.Enemy)) ? 8.0 : 3.0;
			bDoneGathering = true;
			if (WorldInfo.TimeSeconds - B.GatherTime <= GatherWaitTime)
			{
				for (M = SquadMembers; M != None; M = M.NextSquadMember)
				{
					if (!M.bReachedGatherPoint && !M.bFinalStretch && M.Pawn != None && !M.Pawn.bStationary)
					{
						bDoneGathering = false;
						break;
					}
				}
			}
			if (bDoneGathering)
			{
				for (M = SquadMembers; M != None; M = M.NextSquadMember)
				{
					M.bFinalStretch = true;
				}
			}
			else
			{
				if (B.Enemy != None)
				{
					if (B.LostContact(7.0))
					{
						B.LoseEnemy();
					}
					if (B.Enemy != None)
					{
						B.FightEnemy(false, 0.0);
						return true;
					}
				}
				B.GoalString = "Wait for more friendly attackers before continuing on path to" @ O;
				B.WanderOrCamp();
				return true;
			}
		}
	}

	B.MoveTarget = B.FindPathToSquadRoute(B.Pawn.bCanPickupInventory && (Vehicle(B.Pawn) == None)&& !B.bForceNoDetours);
	return B.StartMoveToward(O);
}

/** checks if the bot's vehicle is close enough to leave and proceed on foot
 * (assumes the objective cannot be completed while inside a vehicle)
 * @return true if the bot left the vehicle and is continuing on foot, false if it did nothing
 */
function bool LeaveVehicleToReachObjective(UTBot B, Actor O)
{
	local Vehicle OldVehicle;
	local Rx_BuildingObjective BO;

	if (CloseEnoughToObjective(B, O))
	{
		OldVehicle = Vehicle(B.Pawn);
		B.MoveTarget = None;
		B.DirectionHint = Normal(O.Location - OldVehicle.Location);
		B.NoVehicleGoal = O;

		BO = Rx_BuildingObjective(O);

		if(BO != None)
			B.RouteGoal = BO.GetInfiltrationPoint();
		else
			B.RouteGoal = O;

		B.LeaveVehicle(true);
		return true;
	}

	return false;
}



DefaultProperties
{
	 MaxSquadSize=5 // counts only for Attack and Freelance Squads ! Defense Squads have no limit.
	 bRoamingSquad=true
	 bShouldUseGatherPoints=true	 
	 FormationSize=1100.0
	 VehicleFormationSize=2500.0
	 MaxSquadRoutes=5
}
