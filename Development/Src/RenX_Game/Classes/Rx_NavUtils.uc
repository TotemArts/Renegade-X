class Rx_NavUtils extends Object;

enum EMoveHelperResult {
	EMoveHelperResult_NavMeshMove<DisplayName=NavMesh Move>, //Move to next point in navmesh path.
	EMoveHelperResult_WayPointMove<DisplayName=Waypoint Move>, //Move via waypoints.
	EMoveHelperResult_NavMeshAlternativeMove<DisplayName=NavMesh Alt Move>, //Next point in path is not accessible, NextMoveVector is an alternative location to move to via navmesh.
	EMoveHelperResult_Error<DisplayName=Error>, //Could not find any good alternative locations.
	EMoveHelperResult_DirectlyReachable<DisplayName=Directly Reachable>, //Supplied actor is directly reachable.
	EMoveHelperResult_NavMeshAuto<DisplayName=NavMesh Success>, //NavMesh moved us automatically.
	EMoveHelperResult_CollidingPawn<DisplayName=Has Colliding Pawn>, // There are pawns at the given location.
};

static function SetSearchExtentModifier(pawn InPawn)
{
	local float fNewRad;
	local vector vect;

	InPawn.controller.NavMeshPath_SearchExtent_Modifier = Vect(0,0,0);

	InPawn.controller.navigationhandle.PopulatePathfindingParamCache();
	`Log("(" $ InPawn.name $ ")" @GetFuncName()@"Before modifier:"@`showvar(InPawn.controller.NavMeshPath_SearchExtent_Modifier));
	fNewRad = Rx_Vehicle(InPawn).GetCollisionRadius() - InPawn.controller.navigationhandle.CachedPathParams.SearchExtent.Y;
	vect.X = fNewRad;
	vect.Y = fNewRad;
	vect.Z = InPawn.GetCollisionHeight() - InPawn.controller.navigationhandle.CachedPathParams.SearchExtent.Z;
	InPawn.controller.NavMeshPath_SearchExtent_Modifier = vect;
	`Log("(" $ InPawn.name $ ")" @GetFuncName()@"After modifier:"@`showvar(InPawn.controller.NavMeshPath_SearchExtent_Modifier));
}

static function bool HasReachedGoal(pawn InPawn, Actor Goal, float GoalDistance, bool bFinalApproach)
{
	if( InPawn == None )
	{
		return FALSE;
	}

	`Log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.HasReachedGoal:"@`ShowVar(bFinalApproach)@Goal@`ShowVar(InPawn.Location)@`ShowVar(Goal.Location)@"FinalDestination:"@class'actor'.static.BP2Vect(InPawn.Controller.NavigationHandle.FinalDestination)@"Dist pawn2goal:"@VSize(InPawn.Location-Goal.Location));
	if(bFinalApproach && Goal != None)
	{
		return InPawn.ReachedDestination(Goal);
	}

	if( class'actor'.static.BP2Vect(InPawn.Controller.NavigationHandle.FinalDestination) != vect(0,0,0) )
	{
		if( VSize(class'actor'.static.BP2Vect(InPawn.Controller.NavigationHandle.FinalDestination)-InPawn.Location) < GoalDistance )
		{
			return TRUE;
		}
		return InPawn.ReachedPoint( class'actor'.static.BP2Vect(InPawn.Controller.NavigationHandle.FinalDestination), None );
	}

    return FALSE;
}
/**
 * Generates the path to the given actor. Path is stored in the handle. Returns true if search is successful.
 * @param InPawn The pawn we are trying to move.
 * @param DestActor The actor we are trying to get to.
 * @param WithinDistance Limit search to this distance.
 * @param bAllowPartialPath Dont require the paths to reach the actor.
 * @param bWeightPartialByDist Shorter paths are better when using partial paths.
 * @return Returns true if search is successful.
 */
static function bool NavMeshFindPathToActor(pawn InPawn, Actor DestActor, optional float WithinDistance, optional bool bAllowPartialPath, optional bool bWeightPartialByDist)
{
	local bool bResult;

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshFindPathToActor(): Setting up search for:" @ DestActor,true,'DevPath');

	if (InPawn.Controller.NavigationHandle == None)
	{
		InPawn.controller.InitNavigationHandle();
	}

	SetSearchExtentModifier(InPawn);

	`Log("(" $ InPawn.name $ ")" @GetFuncName()@" Size"@`Showvar(InPawn.CylinderComponent.CollisionRadius) @ InPawn.GetCollisionRadius()@InPawn.GetCollisionExtent()@InPawn.controller.navigationhandle.CachedPathParams.SearchExtent@InPawn.controller.navigationhandle.CachedPathParams.MaxHoverDistance);

	// Clear cache and constraints (ignore recycling for the moment)
	InPawn.controller.NavigationHandle.PathConstraintList = none;
	InPawn.controller.NavigationHandle.PathGoalList = none;

	// Create constraints
	class'NavMeshPath_Toward'.static.TowardGoal (InPawn.controller.NavigationHandle, DestActor);
	class'NavMeshGoal_At'.static.AtActor (InPawn.controller.NavigationHandle, DestActor, WithinDistance, bAllowPartialPath, bWeightPartialByDist);

	// Find path
	bResult = InPawn.controller.NavigationHandle.FindPath();
	`Log("(" $ InPawn.name $ ")" @GetFuncName()@" Size"@`Showvar(InPawn.CylinderComponent.CollisionRadius) @ InPawn.GetCollisionRadius()@InPawn.GetCollisionExtent()@InPawn.controller.navigationhandle.CachedPathParams.SearchExtent@InPawn.controller.navigationhandle.CachedPathParams.MaxHoverDistance);

	InPawn.controller.NavMeshPath_SearchExtent_Modifier = vect(0,0,0);

	return bResult;
}

/**
 * Generates the path to the given location. Path is stored in the handle. Returns true if search is successful.
 * @param InPawn The pawn we are trying to move.
 * @param DestVector The vector/location we are trying to get to.
 * @param WithinDistance Limit search to this distance.
 * @param bAllowPartialPath Dont require the paths to reach the actor.
 * @param bWeightPartialByDist Shorter paths are better when using partial paths.
 * @return Returns true if search is successful.
 */
static function bool NavMeshFindPathToLocation(pawn InPawn, Vector DestVector, optional float WithinDistance, optional bool bAllowPartialPath, optional bool bWeightPartialByDist)
{
	local bool bResult;

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshFindPathToLocation(): Setting up search for:" @ DestVector,true,'DevPath');

	if (InPawn.controller.NavigationHandle == None)
	{
		InPawn.controller.InitNavigationHandle();
	}

	SetSearchExtentModifier(InPawn);

	`Log("(" $ InPawn.name $ ")" @GetFuncName()@" Size"@`Showvar(InPawn.CylinderComponent.CollisionRadius) @ InPawn.GetCollisionRadius()@InPawn.GetCollisionExtent()@InPawn.controller.navigationhandle.CachedPathParams.SearchExtent@InPawn.controller.navigationhandle.CachedPathParams.MaxHoverDistance);

	// Clear cache and constraints (ignore recycling for the moment)
	InPawn.controller.NavigationHandle.PathConstraintList = none;
	InPawn.controller.NavigationHandle.PathGoalList = none;

	// Create constraints
	class'NavMeshPath_Toward'.static.TowardPoint (InPawn.controller.NavigationHandle, DestVector);
	class'NavMeshGoal_At'.static.AtLocation (InPawn.controller.NavigationHandle, DestVector, WithinDistance, bAllowPartialPath, bWeightPartialByDist);

	// Find path
	bResult = InPawn.controller.NavigationHandle.FindPath();
	`Log("(" $ InPawn.name $ ")" @GetFuncName()@" Size"@`Showvar(InPawn.CylinderComponent.CollisionRadius) @ InPawn.GetCollisionRadius()@InPawn.GetCollisionExtent()@InPawn.controller.navigationhandle.CachedPathParams.SearchExtent@InPawn.controller.navigationhandle.CachedPathParams.MaxHoverDistance);
	
	InPawn.controller.NavMeshPath_SearchExtent_Modifier = vect(0,0,0);

	return bResult;
}

/**
 * Generates a path to a random location. Path is stored in the handle. Returns the random location we found.
 * @param InPawn The pawn we are trying to move.
 * @param TestLocation The center of the location we are find a random point from.
 * @param fMaxDistance Returned location must be this close to the TestLocation.
 * @param fMinDistance Returned location must be this far away from the TestLocation.
 * @param bInSoft Allow paths beyond max distance.
 * @param InSoftStartPenalty Weight on paths that are past max distance
 * @param bOnlyTossOutSpecsThatLeave When InSoft is false, Should path points outside the scope be thrown out.
 * @return The random location we found.
 */
static function vector NavMeshGetRandomLocationFromActor(pawn InPawn, vector TestLocation, optional float fMaxDistance, optional float fMinDistance, optional bool bInSoft, optional float InSoftStartPenalty, optional bool bOnlyTossOutSpecsThatLeave)
{
	local vector OutVector;

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetRandomLocationFromActor(): Setting up search for random location. MaxDistance:" @ fMaxDistance @ "MinDistance:" @ fMinDistance @ "bInSoft:" @ bInSoft @ "InSoftStartPenalty:" @ InSoftStartPenalty @ "bOnlyTossOutSpecsThatLeave:" @ bOnlyTossOutSpecsThatLeave,true,'DevPath');
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetRandomLocationFromActor(): Current location:" @ InPawn.Location,true,'DevPath');
	
	InPawn.Controller.NavigationHandle.ClearConstraints();
	InPawn.Controller.NavigationHandle.PathGoalList = none;


	class'NavMeshPath_WithinDistanceEnvelope'.static.StayWithinEnvelopeToLoc(InPawn.Controller.NavigationHandle, TestLocation, fMaxDistance,fMinDistance, bInSoft, InSoftStartPenalty, bOnlyTossOutSpecsThatLeave);
	class'NavMeshGoal_Random'.static.FindRandom(InPawn.Controller.NavigationHandle);

	if(!NavMeshGeneratePathTo(InPawn))
		return OutVector;

	OutVector = InPawn.Controller.NavigationHandle.PathCache_GetGoalPoint();
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetRandomLocationFromActor(): NavMesh Goal:" @ InPawn.Controller.NavigationHandle.FinalDestination.Position,true,'DevPath');

	Return OutVector;
}

/**
 * Generates a path to a random location around a vector. Path is stored in the handle. Returns the random location we found.
 * @param InPawn The pawn we are trying to move.
 * @param fMaxDistance Returned location must be this close to the vector.
 * @param fMinDistance Returned location must be this far away from the vector.
 * @param bInSoft Allow paths beyond max distance.
 * @param InSoftStartPenalty Weight on paths that are past max distance
 * @param bOnlyTossOutSpecsThatLeave When InSoft is false, Should path points outside the scope be thrown out.
 * @return The random location we found.
 */
static function vector NavMeshGetRandomLocationFromVector(Pawn InPawn, vector InVector, optional float fMaxDistance, optional float fMinDistance, optional bool bInSoft, optional float InSoftStartPenalty, optional bool bOnlyTossOutSpecsThatLeave)
{
	local vector OutVector;

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetRandomLocationFromVector(): Setting up search for random location. MaxDistance:" @ fMaxDistance @ "MinDistance:" @ fMinDistance @ "bInSoft:" @ bInSoft @ "InSoftStartPenalty:" @ InSoftStartPenalty @ "bOnlyTossOutSpecsThatLeave:" @ bOnlyTossOutSpecsThatLeave,true,'DevPath');

	InPawn.Controller.NavigationHandle.ClearConstraints();
	InPawn.Controller.NavigationHandle.PathGoalList = none;

	class'NavMeshPath_WithinDistanceEnvelope'.static.StayWithinEnvelopeToLoc(InPawn.Controller.NavigationHandle, InVector, fMaxDistance,0, bInSoft, InSoftStartPenalty, bOnlyTossOutSpecsThatLeave);
	class'NavMeshGoal_Random'.static.FindRandom(InPawn.Controller.NavigationHandle, fMinDistance);

	if(!NavMeshGeneratePathTo(InPawn))
		return OutVector;
	
	NavMeshGetNextMoveLocation(InPawn, OutVector);
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetRandomLocationFromVector(): NavMesh Goal:" @ InPawn.Controller.NavigationHandle.FinalDestination.Position,true,'DevPath');
	
	Return OutVector;
}

/**
 * Finds the closest actor. This will generate a path to the centre of the poly the actor is in.
 * If you want to go directly to the actor, use the out_destActor and call navigationhandle.SetFinalDestination() to the actors location. Path is stored in the handle.
 * @param InPawn The pawn we are trying to move.
 * @param GoalList The list of actors the find which is the closest.
 * @param out_DestActor The closest of the actors, use this to find the exact position of the actor.
 * @return Did we find an actor.
 */
static function bool NavMeshGetClosestActor(Pawn InPawn, out array<BiasedGoalActor> GoalList, optional out actor out_DestActor)
{
	InPawn.Controller.NavigationHandle.ClearConstraints();
	InPawn.Controller.NavigationHandle.PathGoalList = none;
	
	class'NavMeshGoal_ClosestActorInList'.static.ClosestActorInList(InPawn.Controller.NavigationHandle, GoalList);

	if(!NavMeshGeneratePathTo(InPawn, out_DestActor))
		return false;
	
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetClosestActor(): Found closest Actor:" @ out_DestActor @ "Location:" @ out_DestActor.Location,true,'DevPath');

	Return true;
}

/**
 * Will perform the common tasks for moving a pawn along the navmesh.
 * @param InPawn The pawn we are trying to move.
 * @param OutVector Vector we should move to ourselves if false is returned. The vector that should be feed into MoveTo().
 * @return Did we auto move (true), or do we need to manually move (false).
 */
static function EMoveHelperResult NavMeshMoveHelper(Pawn InPawn, out Vector OutVector, optional bool bCreateAltLocation)
{
	local array<vector> AltLocations;

	if(NavMeshGetNextMoveLocation(InPawn, OutVector))
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshMoveHelper(): Next Nav Point:" @ OutVector,true,'DevPath');		
		InPawn.Controller.NavigationHandle.GetCurrentEdgeDebugText();
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshMoveHelper(): Edge Type:" @ string(GetEnum(Enum'ENavMeshEdgeType', InPawn.Controller.NavigationHandle.GetCurrentEdgeType())),true,'DevPath');		

		if(bCreateAltLocation)
			if(CheckForPawnsAtLocation(InPawn, OutVector))
				if(GenerateAlternativeLocations(InPawn, OutVector, AltLocations))
				{
					FindGoodLocFromList(InPawn, AltLocations, OutVector);
					Return EMoveHelperResult.EMoveHelperResult_NavMeshAlternativeMove;
				}
			
		// Will automatically move our pawn if needed, otherwise provides the vector to move to.
		if(!InPawn.Controller.NavigationHandle.SuggestMovePreparation(OutVector, InPawn.Controller))
		{
			Return EMoveHelperResult.EMoveHelperResult_NavMeshMove;
		}
		Return EMoveHelperResult.EMoveHelperResult_NavMeshAuto;
	} else 
	{
		OutVector = NavMeshGetFirstMoveLocation(InPawn);
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshMoveHelper(): Got first move location due to nextmovelocation error, which can sometimes be expected",true,'DevPath');
	}

	Return EMoveHelperResult.EMoveHelperResult_Error;
}

/**
 * Will work out what needs to be done to move to an actor.
 * Does not do any actual path searches.
 * @param InPawn The pawn we are trying to move.
 * @param NextMoveLocation The location of the next move point in our path. Used to feed MoveTo().
 * @param TestActor The actor to be used for when bCheckDirectReach is set.
 * @param bCheckForPawns Checks if there are pawns at the next move point.
 * @param bAllowAlts Allow an alt location to be supplied if original is unfit.
 * @return MoveHelperResult. See Enum list for details.
 */
static function EMoveHelperResult GateMoveHelper(Pawn InPawn, out vector NextMoveLocation, optional actor TestActor, optional bool bCheckDirectReach, optional bool bCheckForPawns, optional bool bAllowAlts)
{
	local bool bInNavMesh, bHasCollidingPawn;
	local pawn collidingActor;
	local array<vector> arAltLocs;
	local actor hitActor;
	local vector hitLoc, hitNorm;

	bInNavMesh = InPawn.Controller.navigationhandle.FindPylon();

	if(bCheckDirectReach && TestActor != none)
	{	
		If(GateDirectMoveTowardCheck(InPawn, TestActor.Location))
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): DirectMoveTowardsCheck returned true",true,'DevPath');
			Return EMoveHelperResult.EMoveHelperResult_DirectlyReachable;
		} else 
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): DirectMoveTowardsCheck returned false",true,'DevPath');
	}

	if(!bInNavMesh)
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): We are not in a navmesh. Returning waypointmove result.",true,'DevPath');
		Return EMoveHelperResult.EMoveHelperResult_WayPointMove;
	}

	if(InPawn.Controller.NavigationHandle.GetPathCacheLength() == 0)
	{
		NextMoveLocation = NavMeshGetFirstMoveLocation(InPawn);
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): PathCache is 0, used GetFirstMoveLocation(). Returned vector:" @ NextMoveLocation,true,'DevPath');
	}
	Else
	{
		if(!InPawn.Controller.NavigationHandle.GetNextMoveLocation(NextMoveLocation, InPawn.GetCollisionRadius()))
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): GetNextMoveLocation returned false",true,'DevPath');
			Return EMoveHelperResult.EMoveHelperResult_Error;
		}
		else
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): GetNextMoveLocation returned true. Returned vector:" @ NextMoveLocation,true,'DevPath');
		}
	}


	if(bCheckForPawns)
	{
		hitactor = InPawn.Controller.Trace(hitLoc, hitNorm, NextMoveLocation,, true, InPawn.GetCollisionExtent());
		if(hitActor != none)
			bHasCollidingPawn = true;

		foreach InPawn.CollidingActors(class'pawn', collidingActor, InPawn.GetCollisionRadius(), NextMoveLocation) {
			bHasCollidingPawn = true;
		}

		if(bHasCollidingPawn)
		{
			if(!bAllowAlts)
				return EMoveHelperResult.EMoveHelperResult_CollidingPawn;
			else
			{
				class'NavigationHandle'.static.GetValidPositionsForBox(NextMoveLocation, (InPawn.GetCollisionRadius() * 4), InPawn.GetCollisionExtent(), true, arAltLocs, 4, InPawn.GetCollisionRadius());
				NextMoveLocation = ArAltLocs[Rand((ArAltLocs.Length - 1))];
				`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): Returning alt location:" @ NextMoveLocation,true,'DevPath');
				Return EMoveHelperResult.EMoveHelperResult_NavMeshAlternativeMove;
			}
		}
	}

	if(!InPawn.Controller.NavigationHandle.SuggestMovePreparation(NextMoveLocation, InPawn.Controller))
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): SuggestMovePreparation returned false. We need to move to the point ourselves. Returned vector:" @ NextMoveLocation,true,'DevPath' );
		Return EMoveHelperResult.EMoveHelperResult_NavMeshMove;
	}
	else
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveHelper(): SuggestMovePreparation returned true. Edge is handling movement for us.",true,'DevPath');
		Return EMoveHelperResult.EMoveHelperResult_NavMeshAuto;
	}
}

static function bool GateActorReachable(pawn InPawn, actor InActor)
{
	local EMoveHelperResult result;
	result = GatePathFindActor(InPawn, InActor);
	if(result == EMoveHelperResult.EMoveHelperResult_Error)
		return false;
	return true;
}

static function EMoveHelperResult GateMoveToActor(pawn InPawn, actor DestActor, out actor OutActor, out vector OutVector, optional bool bCanDetour, optional bool PointCheck)
{
	local EMoveHelperResult result;

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveToActor(): Start",true,'DevPath');

	result = GatePathFindActor(InPawn, DestActor, OutActor, OutVector, bCanDetour, PointCheck);
	
	if(OutVector != vect(0,0,0))
		InPawn.controller.navigationhandle.SetFinalDestination(OutVector);

	switch(result)
	{
		case EMoveHelperResult_DirectlyReachable:
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveToActor(): Directly Reachable",true,'DevPath');
			return result;
		case EMoveHelperResult.EMoveHelperResult_NavMeshMove:
			result = GateMoveHelper(InPawn, OutVector,, false, false, PointCheck);
			OutVector = class'navigationhandle'.static.MoveToDesiredHeightAboveMesh(OutVector, (InPawn.GetCollisionHeight()/2));
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveToActor(): Navmesh Move",true,'DevPath');
			break;
		case EMoveHelperResult.EMoveHelperResult_WayPointMove:
			OutActor = InPawn.Controller.FindPathToward(DestActor, bCanDetour);
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveToActor(): Waypoint Move",true,'DevPath');
			return result;
		case EMoveHelperResult.EMoveHelperResult_Error:
			if(InPawn.Controller.NavigationHandle.FindPylon())
			{
				InPawn.Controller.NavigationHandle.GetValidatedAnchorPosition(OutVector);
				return EMoveHelperResult.EMoveHelperResult_NavMeshAlternativeMove;
			}
			else
				return result;
		default:
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveToActor(): Error",true,'DevPath');
			return EMoveHelperResult.EMoveHelperResult_Error;
	}

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GateMoveToActor(): Returning" @ result,true,'DevPath');
	return result;
}

/**
 * Chooses the correct action to use based on if we are in a navmesh or not. Returns the next actor(navigation point) we should move to on our journey.
 * @param InPawn The pawn we are trying to move.
 * @param DestActor The actor we are trying to move to.
 * @param OutActor The actor we should move to on our journey.
 * @param bCanDetour Used by waypoint pathfind.
 * @return The EMoveHelperResult.
 */
static function EMoveHelperResult GatePathFindActor(pawn InPawn, actor DestActor, optional out actor OutActor, optional out vector OutVector, optional bool bCanDetour, optional bool PointCheck)
{
	local vector NavMoveTarget;
	local array<vector> altLocations;

	NavMoveTarget = DestActor.Location;

	if(!GatePointCheck(InPawn, NavMoveTarget))
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GatePathFindActor(): Generating Alt locations" @ DestActor,true,'DevPath');
		if(GenerateAlternativeLocations(InPawn, DestActor.Location, altLocations,, 1))
				NavMoveTarget = altLocations[0];
	}

	if(GateDirectMoveTowardCheck(InPawn, DestActor.Location))
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GatePathFindActor(): Can move directly to" @ DestActor,true,'DevPath');
		OutActor = DestActor;
		return EMoveHelperResult.EMoveHelperResult_DirectlyReachable;
	}

	if(InPawn.Controller.NavigationHandle.FindPylon())
	{
		if(NavMeshFindPathToLocation(InPawn, NavMoveTarget))
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GatePathFindActor(): Getting Navmesh move location" @ DestActor,true,'DevPath');
			 NavMeshGetNextMoveLocation(InPawn,OutVector);
			 OutActor = InPawn.spawn(class'dynamicanchor',,, OutVector);
			 return EMoveHelperResult.EMoveHelperResult_NavMeshMove;
		}
	}
	else
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GatePathFindActor(): Using waypoint pathfinding to" @ DestActor,true,'DevPath');
		OutActor = InPawn.controller.FindPathToward(DestActor, bCanDetour);
		return EMoveHelperResult.EMoveHelperResult_WayPointMove;
	}

	Return EMoveHelperResult.EMoveHelperResult_Error;
}

/**
 * Chooses the correct action to use based on if we are in a navmesh or not. Returns the next actor(navigation point) we should move to on our journey.
 * @param InPawn The pawn we are trying to move.
 * @param DestLocation The location we are trying to move to.
 * @return The actor we should move to next on our journey.
 */
static function vector GatePathFindLocation(pawn InPawn, vector DestLocation)
{
	if(InPawn.Controller.NavigationHandle.FindPylon())
	{
		if(NavMeshFindPathToLocation(InPawn, DestLocation))
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GatePathFindLocation(): Found NavMesh path to" @ DestLocation,true,'DevPath');
			return(NavMeshGetFirstMoveLocation(InPawn));
		}
	}
	else
	{   
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GatePathFindLocation(): Found Waypoint path to" @ DestLocation,true,'DevPath');
		return(InPawn.Controller.FindPathTo(DestLocation).Location);
	}
}

/**
 * Checks if we can get to the supplied actor. Returns true if the actor is good to move to.
 * @param InPawn The pawn we are trying to move.
 * @param DestVector The location we are trying to move to.
 * @return Can we move to the location.
 */
static function bool GateDirectMoveTowardCheck(pawn InPawn, Vector DestVector)
{		
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.DirectMoveTowardCheck(): Start." @ DestVector,true,'DevPath');

	If(InPawn.Controller.NavigationHandle.FindPylon())
	{
		if(NavMeshDirectLocationCheck(InPawn, DestVector))
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.DirectMoveTowardCheck(): NavMeshDirectLocationCheck() Returned true." @ "Location:" @ DestVector,true,'DevPath');
			return true;
		}
	}
	else // Use more traditional method to see if location is reachable.
	{
		
		if(InPawn.Controller.PointReachable(DestVector))
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.DirectMoveTowardCheck(): Pawn.Controller.ActorReachable returned true." @ "Location:" @ DestVector,true,'DevPath');
			return true;
		}
	}
	
	//If we reach here, it means every test has failed.
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.DirectMoveTowardCheck(): Is NOT directly reachable:" @ DestVector,true,'DevPath');
	return false;
}
/**
 * Checks if a location can fit the pawn.
 * @param InPawn The pawn we are checking for
 * @param InVector The location we are checking
 * @return True if the location can fit the pawn.
*/
static function bool GatePointCheck(Pawn InPawn, Vector InVector)
{
	local bool result; 
	If(InPawn.Controller.NavigationHandle.FindPylon())
	{
		result = InPawn.Controller.NavigationHandle.PointCheck(InVector, InPawn.GetCollisionExtent());
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GatePointCheck(): Result:" @ result,true,'DevPath');
		return result;
	}
	else
		return true; //Non-navmesh option not avalaible, so return true.
}

/**
 * Checks if we can get to the supplied location via NavMesh. Returns false if NavMesh reports a hit against obstacle mesh.
 * @param InPawn The pawn we are trying to move.
 * @param InVector The vector we are trying to move to.
 * @return Can we move to the location.
*/
static function bool NavMeshDirectLocationCheck(pawn InPawn, vector InVector)
{
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshDirectLocationCheck(): Checking location:" @ InVector,true,'DevPath');
	If(InPawn.Controller.NavigationHandle.PointReachable(InVector))
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshDirectLocationCheck(): PointReachable reports location good.",true,'DevPath');
		return true;
	}

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshDirectLocationCheck(): PointReachable reports location bad.",true,'DevPath');
	return false;
}

/**
 * Looks for pawns at the provided location. Returns true if pawns found.
 * @param InPawn The pawn we are trying to move.
 * @param InVector The vector we are trying to move to.
 * @return Pawns were found.
 */
Static function bool CheckForPawnsAtLocation(pawn InPawn, vector InVector, optional float fRadius)
{
	local pawn out_Actor;

	if(fRadius == 0)
		fRadius = InPawn.GetCollisionRadius();

	//Lets find if there is an pawn at the location we are trying to reach.
	foreach InPawn.CollidingActors(class'pawn', out_Actor, fRadius, InVector)
	{
		`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.CheckForPawnsAtLocation(): Following pawn is in the way:" @ out_Actor @ out_actor.GetHumanReadableName() @ "Location:" @ out_Actor.Location,true,'DevPath');
		Return true;
	}

	return false;
}

/**
 * Generates a list of alternative locations around giving location.
 * @param InPawn The pawn we are trying to move.
 * @param OutVectors An array of vectors that are good alternitive locations to move to.
 * @param AltLocSearchRadius How far should we search from the given actor to find good alternitive locations.
 * @param MaxAltLocations How many alternitive locations should we try to find.
 * @return Can we move to the location.
 */
Static function bool GenerateAlternativeLocations(pawn InPawn, vector InVector, out array<vector> OutVectors, optional float AltLocSearchRadius=400, optional int MaxAltLocations=4)
{
	OutVectors.Length = 0;
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GenerateAlternativeLocations(): Generating alt locations around target. Count:" @ MaxAltLocations,true,'DevPath');
	class'navigationhandle'.static.GetValidPositionsForBox(InVector, AltLocSearchRadius, InPawn.GetCollisionExtent(), true, OutVectors, MaxAltLocations);

	If(OutVectors.Length == 0)
	{
		class'navigationhandle'.static.GetValidPositionsForBox(InPawn.Location, AltLocSearchRadius, InPawn.GetCollisionExtent(), true, OutVectors, MaxAltLocations);
		if(OutVectors.Length == 0)
		{
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GenerateAlternativeLocations(): Complete failure. No good alt loc's around target or pawn, tried around pawn and got #" $ OutVectors.Length @ "locations",true,'DevPath');
			return false; // We couldnt generate alt locations at either the target, or the pawn.
		} else {
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GenerateAlternativeLocations(): Last ditch recovery succeeded. No good alt loc's around target, found #" $ OutVectors.Length @ "locations around pawn.",true,'DevPath');
			return true; // Could not find alt location around target, but could around the pawn.
		}
	}
	
	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.GenerateAlternativeLocations(): Generated list of alt locations around target. Count:" @ OutVectors.Length,true,'DevPath');
	return true; // Found alt locations around target.
}

static function vector GenerateSingleAlternativeLocation(pawn InPawn, vector InVector)
{
	local array<vector> altVectors;
	GenerateAlternativeLocations(InPawn, InVector, altVectors);
	return altVectors[0];
}

/**
 * Find good alternitive locations from a supplied list. Returns true if we found a good location.
 * @param InPawn The pawn we are trying to move.
 * @param VectorList An array of vectors that are possible alternitive locations to move to.
 * @param OutVector The good location we found to move to.
 * @return did we find a good location.
 */
static function bool FindGoodLocFromList(Pawn InPawn, array<vector> VectorList, out vector OutVector)
{
	local vector tempVector;
	local int count;

	ForEach VectorList(tempVector, count)		{
		If(NavMeshDirectLocationCheck(InPawn, tempVector))
		{
			OutVector = tempVector;
			return true;
		}
		else
			`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.FindGoodLocFromList(): LocationCheck Alt location #" $ count @ "also blocked. Loc:" @ tempVector,true,'DevPath');
	}
	return false;
}

static function bool NavMeshFixLost(pawn InPawn, out vector OutVector)
{
	if(InPawn.Controller.NavigationHandle.GetValidatedAnchorPosition(OutVector))
	{
		OutVector = Normal(VRand()) * InPawn.GetCollisionRadius();
		return true;
	}
	return false;
}

/**
 * Gets the next location to move to on our navmesh journey.
 * @param InPawn The pawn we are trying to move.
 * @param Out_Vector The location to move to.
 * @return did we find get a location.
 */
static function bool NavMeshGetNextMoveLocation(Pawn InPawn, out vector out_vector)
{
	if(!InPawn.Controller.NavigationHandle.GetNextMoveLocation(out_vector, InPawn.GetCollisionRadius()))
	{
		switch(InPawn.Controller.NavigationHandle.LastPathError)
		{
			default:
				`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetNextMoveLocation(): GetNextMoveLocation Error:" @ InPawn.Controller.NavigationHandle.LastPathError,true,'DevPath');
				return false;
		}
	}

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetNextMoveLocation(): NavMoveTarget:" @ out_vector,true,'DevPath');
	return true;
}

/**
 * Gets the first location to move to on our navmesh journey.
 * @param InPawn The pawn we are trying to move.
 * @return The first location to move to.
 */
static function vector NavMeshGetFirstMoveLocation(Pawn InPawn)
{
	local vector NavMoveTarget;

	NavMoveTarget = InPawn.Controller.NavigationHandle.GetFirstMoveLocation();

	if(NavMoveTarget == Vect(0,0,0))
	{
		switch(InPawn.Controller.NavigationHandle.LastPathError)
		{
			default:
				`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetFirstMoveLocation(): GetFirstMoveLocation Error:" @ InPawn.Controller.NavigationHandle.LastPathError,true,'DevPath');
				break;
		}
	}

	`log("(" $ InPawn.GetHumanReadableName()  @ InPawn.Name $ ")" @ "Rx_NavUtils.NavMeshGetFirstMoveLocation(): NavMoveTarget:" @ NavMoveTarget,true,'DevPath');
	return NavMoveTarget;
}

/**
 * Performs the search on the navmesh. Requires Constraints and Goals list to already be setup.
 * @param p The pawn we are trying to move.
 * @param Out_DestActor The Actor the search goal returns.
 * @return did we find a goal.
 */
static function bool NavMeshGeneratePathTo(pawn p, optional out actor out_DestActor)
{
	if (p.Controller.NavigationHandle == None)
		return false;

	if(!p.Controller.NavigationHandle.FindPylon())
	{
		`log("(" $ p.GetHumanReadableName() $ ")" @ "Rx_NavUtils.NavMeshGeneratePathTo(): Could not find pylon for this area.",true,'DevPath');
		return false;
	}

	p.Controller.NavigationHandle.bDebugConstraintsAndGoalEvals = true;
	//p.Controller.NavigationHandle.bVisualPathDebugging = true;
   
	return p.Controller.NavigationHandle.FindPath(out_DestActor);
}




DefaultProperties
{
}
