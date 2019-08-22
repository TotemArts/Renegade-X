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
class Rx_SquadAI_Mesh extends Rx_SquadAI;

var float VehicleFormationSize;
const RX_NEAROBJECTIVEDIST = 3500.0;

/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(UTBot B, Actor O)
{
	local Vehicle V;
	local UTGameObjective Objective;
	local int i, RouteIndex;
	local float GatherWaitTime;
	local UTBot M;
	local bool bDoneGathering;
	local NavigationPoint N;
	local dynamicanchor DynA;

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
			if(b.Pawn.Controller.NavigationHandle.FindPylon())
			{
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:FindPathToObjective: Found Pylon",,'DevAI');
				b.Pawn.Controller.Navigationhandle.ClearConstraints();
				b.Pawn.Controller.NavigationHandle.PathGoalList = none;
				b.Pawn.Controller.NavigationHandle.bDebugConstraintsAndGoalEvals = true;

				class'NavMeshPath_WithinDistanceEnvelope'.static.StayWithinEnvelopeToLoc(b.Pawn.Controller.NavigationHandle, b.pawn.Location, 1000.0f, 50.0f, false);
				class'NavMeshGoal_Random'.static.FindRandom(b.Pawn.Controller.NavigationHandle);

				if(b.Pawn.Controller.NavigationHandle.FindPath())
				{
					DynA = Spawn(class'dynamicanchor',,,b.Pawn.Controller.navigationhandle.GetFirstMoveLocation());
					B.MoveTarget = DynA;
				}
			}else{
				B.FindRandomDest();
				B.MoveTarget = B.RouteCache[0];
			}
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
		return Rx_Bot(B).SetRouteToGoal(O);

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

function NavigationPoint FindDefensivePositionFor(UTBot B)
{
	local PathNode N;
	local NavigationPoint Best;
	local int Num;
	local float CurrentRating, BestRating;
	local Actor Center;
	local vector DestVector;

	Center = FormationCenter(B);
	if (Center == None)
	{
		Center = B.Pawn;
	}

	DestVector = class'Rx_NavUtils'.static.NavMeshGetRandomLocationFromVector(b.Pawn, center.Location, GetMaxDefenseDistanceFrom(Center, B));

	if(DestVector != vect(0,0,0))
		Best = spawn(class'dynamicanchor',,, DestVector);
	else
	{
		foreach WorldInfo.RadiusNavigationPoints(class'PathNode', N, Center.Location, GetMaxDefenseDistanceFrom(Center, B))
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
	}

	return Best;
}

function bool AssignSquadResponsibilityRx(Rx_Bot_Mesh B)
{
	// set up route cache if pending
	if ( PendingSquadRouteMaker == B )
	{
		SetAlternatePathTo(SquadObjective, B);
	}

	// set new defense script
	if (GetOrders() == 'Defend' && !B.Pawn.bStationary )
		SetDefenseScriptFor(B);
	else if ( (B.DefensePoint != None) && (UTHoldSpot(B.DefensePoint) == None) )
		B.FreePoint();

	if ( bAddTransientCosts )
		AddTransientCosts(B,1);
	// check for major game objective responsibility
	if ( CheckSquadObjectivesRx(B) )
	{
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:AssignSquadResponsibilityRx: CheckSquadObjectives() returned true.",,'DevAI');
		return true;
	}

	if ( B.Enemy == None && !B.Pawn.bStationary )
	{
		// suggest inventory hunt
		// FIXME - don't load up on unnecessary ammo in DM
		if ( B.FindInventoryGoal(0) )
		{
			B.SetAttractionState();
			`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:AssignSquadResponsibilityRx: FindInventoryGoal() returned true.",,'DevAI');
			return true;
		}

		// roam around level?
		if ( ((B == SquadLeader) && bRoamingSquad) || (GetOrders() == 'Freelance') )
		{
			`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:AssignSquadResponsibilityRx: Will roam around level.",,'DevAI');
			return B.FindRoamDest();
		}
	}
	`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:AssignSquadResponsibilityRx: Returning false.",,'DevAI');
	return false;
}

function bool CheckSquadObjectivesRx(Rx_Bot_Mesh B)
{
	local Actor DesiredPosition;
	local bool bInPosition;
	local Vehicle V;
	local Rx_GameObjective RxObjective;
	local vector DesiredLocation;
	local Float Dist;

	if (WorldInfo.TimeSeconds - B.Pawn.CreationTime < 5.0 && B.NeedWeapon() && B.FindInventoryGoal(0.0004))
	{
		B.GoalString = "Need weapon or ammo";
		B.NoVehicleGoal = B.RouteGoal;
		B.SetAttractionState();
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning after its before 5 seconds in game & setting Need weapon or ammo.",,'DevAI');
		return true;
	}
	if (CheckVehicle(B))
	{
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning after CheckVehicle() returned true.",,'DevAI');
		return true;
	}
	if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
	{
		B.GoalString = "Need weapon or ammo";
		B.NoVehicleGoal = B.RouteGoal;
		B.SetAttractionState();
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning after setting Need weapon or ammo.",,'DevAI');
		return true;
	}

	if ( (PlayerController(SquadLeader) != None) && (SquadLeader.Pawn != None) )
	{
		if ( UTHoldSpot(B.DefensePoint) == None )
		{
			// attack objective if close by
			if ( OverrideFollowPlayer(B) )
			{
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning after defencing point is none & overriding player and attacking objective close by.",,'DevAI');
				return true;
			}

			// follow human leader
			`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning after defence point is none & settings follow squad leader.",,'DevAI');
			return TellBotToFollow(B,SquadLeader);
		}
		// hold position as ordered (position specified by DefensePoint)
	}

	if ( B.Pawn.bStationary && Vehicle(B.Pawn) != None)
	{
		if ( UTHoldSpot(B.DefensePoint) != None )
		{
			if ( UTHoldSpot(B.DefensePoint).HoldVehicle != B.Pawn && UTHoldSpot(B.DefensePoint).HoldVehicle != B.Pawn.GetVehicleBase() )
			{
				B.LeaveVehicle(true);
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning after in vech & spot is a defensepoint & not to hold vech & getting out of vech .",,'DevAI');
				return true;
			}
		}
	}
	V = Vehicle(B.Pawn);

	RxObjective = Rx_GameObjective(SquadObjective);
	if ( B.DefensePoint != None )
	{
		DesiredPosition = B.DefensePoint.GetMoveTarget();
		bInPosition = (B.Pawn == DesiredPosition) || B.Pawn.ReachedDestination(DesiredPosition);
		if ( bInPosition && (Vehicle(DesiredPosition) != None) )
		{
			if (V != None && B.Pawn != DesiredPosition && B.Pawn.GetVehicleBase() != DesiredPosition)
			{
				B.LeaveVehicle(true);
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after defensepoint is NOT none, & in desired position with vech & leaving vech.",,'DevAI');
				return true;
			}
			if (V == None)
			{
				B.EnterVehicle(Vehicle(DesiredPosition));
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after defensepoint is NOT none, & in desired position with vech as desired position & entering vech.",,'DevAI');
				return true;
			}
		}
		if (B.ShouldDefendPosition())
		{
			`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after defense point is NOT none & ShouldDefendPosition() returned true.",,'DevAI');
			return true;
		}
	}
	else if ( SquadObjective == None )
	{
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TellBotToFollow() result after sqaudobjective is none & setting to follow squadleader.",,'DevAI');
		return TellBotToFollow(B,SquadLeader);
	}
	else if ( GetOrders() == 'Freelance' && (UTVehicle(B.Pawn) == None || !UTVehicle(B.Pawn).bKeyVehicle) )
	{
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning FALSE after sqaudobjective is NOT none & orders are freelance & IN or getting vech",,'DevAI');
		return false;
	}
	else
	{
		if ( RxObjective.DefenderTeamIndex != Team.TeamIndex )
		{
			if ( RxObjective.bIsDisabled )
			{
				B.GoalString = "Objective already disabled";
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning FALSE after sqaudobjective is already disabled.",,'DevAI');
				return false;
			}
			B.GoalString = "Disable Objective "$SquadObjective;
			`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TellBotHowToDisable() result after setting bot to disable squadobjective.",,'DevAI');
			return RxObjective.TellBotHowToDisable(B);
		}
		if (B.DefensivePosition != None && AcceptableDefensivePosition(B.DefensivePosition, B))
		{
			DesiredPosition = B.DefensivePosition;
		}
		else if (RxObjective.bBlocked)
		{
			DesiredPosition = FindDefensivePositionFor(B);
		}
		else
		{
			DesiredPosition = RxObjective;
		}
		if(DesiredPosition == RxObjective) {
			DesiredLocation = Rx_BuildingObjective(RxObjective).GetShootTarget(B).location;
		} else {
			DesiredLocation = DesiredPosition.location;
		} 
		bInPosition = ( VSizeSq(DesiredLocation - B.Pawn.Location) < Square(RX_NEAROBJECTIVEDIST) &&
				(B.LineOfSightTo(Rx_BuildingObjective(RxObjective).GetShootTarget(B)) || (RxObjective.bHasAlternateTargetLocation && B.LineOfSightTo(Rx_BuildingObjective(RxObjective).GetShootTarget(B),, true))) );
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
				if(!B.HasRepairGun()) {
					B.FightEnemy(BotsEnemyIsCloserToObjective(B), 0); 
					`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after enemy is NOT none, and is better to attack enemy then get objective.",,'DevAI');
					return true;	
				} else if(Dist < 6760000 && (SquadObjective == None || Rx_BuildingObjective(SquadObjective) == None 
							|| !Rx_BuildingObjective(SquadObjective).NeedsHealing() 
							|| Rx_BuildingObjective(SquadObjective).KillEnemyFirstBeforeHealing(B))) {
					B.FightEnemy(false, 0);
					`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after enemy is NOT none, and has bo objective and enemy is close & setting to fight enemy.",,'DevAI');
					return true;	
				}
			}
		}
	}
	if ( bInPosition )
	{
		B.GoalString = "Near defense position" @ DesiredPosition;
		if ( !B.bInitLifeMessage )
		{
			B.bInitLifeMessage = true;
			B.SendMessage(None, 'INPOSITION', 25);
		}

		if ( B.DefensePoint != None )
		{
			`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after inposition is true, & has defencepoint & setting movetodefensepoint.",,'DevAI');
			B.MoveToDefensePoint();
		}
		else
		{
			if ( RxObjective.TellBotHowToHeal(B) )
			{
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after inposition is true, & dfencepoint is none, and objective.tellbothowtoheal returns true.",,'DevAI');
				return true;
			}

			if (B.Enemy != None && (B.LineOfSightTo(B.Enemy) || WorldInfo.TimeSeconds - B.LastSeenTime < 3))
			{
				B.FightEnemy(false, 0);
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after inposition is true & not in defense point & setting to fight enemy.",,'DevAI');
				return true;
			}

			B.WanderOrCamp();
		}
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after inposition is true, and other havnt returned.",,'DevAI');
		return true;
	}

	if (B.Pawn.bStationary )
	{
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning FALSE after pawn is stationary.",,'DevAI');
		return false;
	}

	B.GoalString = "Follow path to "$DesiredPosition;
	if (DesiredPosition == RxObjective && RxObjective.bAllowOnlyShootable)
	{
		if (class'Rx_navutils'.static.GateDirectMoveTowardCheck(b.Pawn,RxObjective.Location))
		{
			B.MoveTarget = RxObjective;
		}
		else
		{
			RxObjective.MarkShootSpotsFor(B.Pawn);
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
	{
		`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after going to desiredposition"@DesiredPosition,,'DevAI');
		return true;
	}

	if ( (B.DefensePoint != None) && (DesiredPosition == B.DefensePoint) )
	{
		B.FreePoint();
		if ( (RxObjective != None) && (VSizeSq(B.Pawn.Location - RxObjective.Location) > 1440000) )
		{
			B.FindBestPathToward(RxObjective,false,true);
			if ( B.StartMoveToward(RxObjective) )
				`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning TRUE after defensepoint is NOT none and distance to obj"@RxObjective@" is > 1200 & going to obj",,'DevAI');
				return true;
		}
	}
	`log("(" $ b.pawn.GetHumanReadableName() @ b.pawn.Name $ ")" @ "Rx_SquadAI:CheckSquadObjectivesRx: Returning FALSE after didnt find task.",,'DevAI');
	return false;
}

function bool BotsEnemyIsCloserToObjective(UTBot B) {
	if(SquadObjective != None 
		&& VSizeSq(B.location - Rx_BuildingObjective(SquadObjective).GetShootTarget(B).location) 
			> VSizeSq(B.Enemy.location - Rx_BuildingObjective(SquadObjective).GetShootTarget(B).location)) {
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
			else if ( VSizeSq(SquadLeader.Pawn.Velocity) > Square(SquadLeader.Pawn.WalkingPct * SquadLeader.Pawn.GroundSpeed) ) {
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
	local Actor MCT;
	local Vector HitLoc,HitNormal;
	//local vector out_HitLocation;
	//local vector out_HitNormal;	
	local Rx_Building Building;

	MCTReachMod = 0.5;

	if(!Center.IsA('Rx_BuildingObjective')) {
		if (N.bDestinationOnly || N.IsA('Teleporter') || N.IsA('PortalMarker') || (N.bFlyingPreferred && !CurrentBot.Pawn.bCanFly))
			//(!FastTrace(N.Location, Center.GetTargetLocation()) && (!Center.bHasAlternateTargetLocation || !FastTrace(N.Location, Center.GetTargetLocation(, true)))))
			return -1.0;
	} else 	
	{
		Building = Rx_BuildingObjective(Center).myBuilding;
		Dist = VSize(N.Location - Building.GetTargetLocation());
		MCT = Building.GetMCT();

		if(Rx_BuildingObjective(Center).IsCritical())
		{
			if(Trace(HitLoc, HitNormal, MCT.Location, N.Location) != MCT)
				MCTReachMod = 1;	// Prioritize the points in which bots can fire on MCT
		}
		/**
		if (Dist > CurrentBot.Pawn.Weapon.MaxRange())
		{
			if(Building != Trace( out_HitLocation, out_HitNormal, Building.GetTargetLocation(), N.Location)) {
				return -1.0;
			}
			Dist = VSize(N.Location - out_HitLocation);
			if(Dist > CurrentBot.Pawn.Weapon.MaxRange() - 50) {
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

	if(Center.IsA('Rx_BuildingObjective')) {
		Dist = VSize(N.Location - Building.GetTargetLocation());
	} else {
		Dist = VSize(N.Location - Center.Location);
	}
	if (Dist < 400.0)
	{
		return (0.00025 * Dist);
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
			`log("Rx_SquadAI_Waypoints: Charging!"); 
			B.GoalString = "Charge";
			B.DoCharge();
			return true;
		}
		//If Bot is not in a vehicle, but has a route to a vehicle and isn't stuck?
		if ( (Vehicle(B.Pawn) == None) && (Vehicle(B.RouteGoal) != None) && (NavigationPoint(B.Movetarget) != None) ) {
			if ( VSizeSq(B.Pawn.Location - B.RouteGoal.Location) < Square(B.Pawn.GetCollisionRadius() + Vehicle(B.RouteGoal).GetCollisionRadius() + B.Pawn.VehicleCheckRadius * 1.5) ) {
				`log("Rx_SquadAI_Waypoints: RouteGoal!"); 
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
				`log("Rx_SquadAI_Waypoints: Consider to heal Vehicle before getting in!"); 
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
		BestDist = MaxVehicleDist(B.Pawn);
		if ( SquadVehicle == None ) {
			for ( S=SquadMembers; S!=None; S=S.NextSquadMember ) {
				V = UTVehicle(S.Pawn);
				if ( V != None && VSizeSq(V.Location - B.Pawn.Location) < Square(BestDist) && V.OpenPositionFor(B.Pawn) &&
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
			if ( V != None && !V.Occupied() && VSizeSq(V.Location - B.Pawn.Location) < Square(BestDist) && V.OpenPositionFor(B.Pawn) &&
				(V.NoPassengerObjective == None || V.NoPassengerObjective != SquadObjective) &&
				(V.bCanCarryFlag || !UTPlayerReplicationInfo(B.PlayerReplicationInfo).bHasFlag) )
			{
				SquadVehicle = V;
			}
		}

		// check if bot is already heading towards a vehicle
		if (SquadVehicle == None) {
			V = UTVehicle(B.RouteGoal);
			if (V != None && !V.Occupied() && VSizeSq(V.Location - B.Pawn.Location) < Square(BestDist * 1.2) && VehicleDesireability(V, B) > 0.0)
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
	local Actor BestEntry, BestPath;

	if(Rx_Vehicle(squadVehicle).buyerPri != None && Rx_Vehicle(squadVehicle).buyerPri != B.PlayerReplicationInfo)
	{
		`log("(" $ B.GetHumanReadableName() @ b.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): Was not buyer of vehicle",,'DevAI');
		return false;
	}

	BestEntry = SquadVehicle.GetMoveTargetFor(B.Pawn);

	if ( (SquadVehicle.bHasCustomEntryRadius && SquadVehicle.InCustomEntryRadius(B.Pawn)) ||
		B.Pawn.ReachedDestination(BestEntry) )
	{
		if (Vehicle(B.Pawn) != None)
		{
			`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): At Vehicle; Was already inside a vehicle, getting out.",,'DevAI');
			B.LeaveVehicle(true);
			return true;
		}
		`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): At Vehicle; Going to enter vehicle",,'DevAI');
		B.EnterVehicle(SquadVehicle);
		return true;
	}

	if ( B.ActorReachable(BestEntry) )
	{
		if (Vehicle(B.Pawn) != None)
		{
			`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): Vehicle reachable; Was already inside a vehicle, getting out.",,'DevAI');
			B.LeaveVehicle(true);
			return true;
		}
		B.RouteGoal = SquadVehicle;
		B.MoveTarget = BestEntry;
		SquadVehicle.SetReservation(B);
		B.GoalString = "Go to vehicle 1 "$BestEntry$" to "$Squadvehicle;
		B.SetAttractionState();
		`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): Vehicle reachable; Set as destination, and Set attraction state. BestEntry:" @ BestEntry.Location,,'DevAI');
		return true;
	}

	class'Rx_navutils'.static.GatePathFindActor(b.Pawn, BestEntry, BestPath);
	if ( BestPath != None )
	{
		B.RouteGoal = SquadVehicle;
		SquadVehicle.SetReservation(B);
		B.MoveTarget = BestPath;
		B.GoalString = "Go to vehicle 2 through "$BestPath$" to "$Squadvehicle;
		B.SetAttractionState();
		`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): Found path to vehicle; Set as destination, and Set attraction state.",,'DevAI');
		return true;
	}

	if ( (VSizeSq(BestEntry.Location - B.Pawn.Location) < 1440000)
		&& B.LineOfSightTo(BestEntry) )
	{
		if (Vehicle(B.Pawn) != None)
		{
			B.LeaveVehicle(true);
			`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): Has LOS to vehile; Was already inside a vehicle, getting out.",,'DevAI');
			return true;
		}
		B.RouteGoal = SquadVehicle;
		SquadVehicle.SetReservation(B);
		B.MoveTarget = BestEntry;
		B.GoalString = "Go to vehicle 3 "$BestEntry$" to "$Squadvehicle;
		B.SetAttractionState();
		`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): Has LOS to vehile; Set as destination, and Set attraction state.",,'DevAI');
		return true;
	}

	`log("(" $ B.GetHumanReadableName() @ B.name $ ")" @ "Rx_SqaudAI:GotoVehicle(): End of function, returning false.",,'DevAI');
	return false;
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
			ret += (Square(class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius) - Dist) / Square(class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius);
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
	
	bRet = super.ValidEnemy(NewEnemy);

	// if upper logic says yes, check for spy
	if (bRet && Rx_Pawn(NewEnemy) != none && Rx_Pawn(NewEnemy).isSpy())
	{
		// look for a bot that is near the spy, if so add as enemy
		// TODO: if player spots spy, bots should add spy as enemy too
		for	( M = SquadMembers; M != None; M = M.NextSquadMember )
		{
			if (VSizeSq(NewEnemy.Location - M.Pawn.Location) <= Square(class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius))
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
	} else {
		super.SetObjective(O,bForceUpdate);
	}
}

function bool TellBotToFollow(UTBot B, Controller C)
{
	local Pawn Leader;
	local UTGameObjective O, Best;
	local float NewDist, BestDist;
	local UTTeamAI TeamAI;

	if(C != None && UTPlayercontroller(C) == None && Rx_Vehicle(B.Pawn) != None && Rx_Vehicle(C.Pawn) == None) {
		return false;
	}		

	if ( (C == None) || C.bDeleteMe )
	{
		PickNewLeader();
		C = SquadLeader;
	}

	if ( B == C )
		return false;

	B.GoalString = "Follow Leader";
	Leader = C.Pawn;
	if ( Leader == None )
		return false;

	if ( CloseToLeader(B.Pawn) )
	{
		if ( !B.bInitLifeMessage )
		{
			B.bInitLifeMessage = true;
		  	B.SendMessage(SquadLeader.PlayerReplicationInfo, 'GOTYOURBACK', 10);
		}
		if ( B.Enemy == None )
		{
			// look for destroyable objective
			TeamAI = UTTeamInfo(Team).AI;
			for ( O=TeamAI.Objectives; O!=None; O=O.NextObjective )
			{
				if ( !O.bIsDisabled && O.Shootable()
					&& ((Best == None) || (Best.DefensePriority < O.DefensePriority)) )
				{
					NewDist = VSizeSq(B.Pawn.Location - O.Location);
					if ( ((Best == None) || (NewDist < BestDist)) && B.LineOfSightTo(O) )
					{
						Best = O;
						BestDist = NewDist;
					}
				}
			}
			if ( Best != None )
			{
				if (Best.DefenderTeamIndex != Team.TeamIndex)
				{
					if (Best.TellBotHowToDisable(B))
						return true;
				}
				else if ( (BestDist < 1600) && Best.TellBotHowToHeal(B) )
				{
					return true;
				}
			}

			if ( B.FindInventoryGoal(0.0004) )
			{
				B.SetAttractionState();
				return true;
			}
			B.WanderOrCamp();
			return true;
		}
		else if ( (UTWeapon(B.Pawn.Weapon) != None) && UTWeapon(B.Pawn.Weapon).FocusOnLeader(false) )
		{
			B.FightEnemy(false,0);
			return true;
		}
		return false;
	}
	else if ( Rx_Bot(B).SetRouteToGoal(Leader) )
		return true;
	else
	{
		B.GoalString = "Can't reach leader";
		return false;
	}
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
	if ( PickedObjective.Shootable() && B.LineOfSightTo(PickedObjective) )
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


DefaultProperties
{
	 MaxSquadSize=5 // counts only for Attack and Freelance Squads ! Defense Squads have no limit.
	 bRoamingSquad=true
	 bShouldUseGatherPoints=true	 
	 FormationSize=1100.0
	 VehicleFormationSize=2500.0
	 MaxSquadRoutes=5
}
