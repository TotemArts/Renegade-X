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
class Rx_SquadAI extends UTSquadAI;

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

	if (WorldInfo.TimeSeconds - B.Pawn.CreationTime < 5.0 && B.NeedWeapon() && B.FindInventoryGoal(0.0004))
	{
		B.GoalString = "Need weapon or ammo";
		B.NoVehicleGoal = B.RouteGoal;
		B.SetAttractionState();
		return true;
	}
	if (CheckVehicle(B))
		return true;
	if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
	{
		B.GoalString = "Need weapon or ammo";
		B.NoVehicleGoal = B.RouteGoal;
		B.SetAttractionState();
		return true;
	}

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

	if ( B.Pawn.bStationary && Vehicle(B.Pawn) != None)
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
	V = Vehicle(B.Pawn);

	UTObjective = UTGameObjective(SquadObjective);
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
	else if ( GetOrders() == 'Freelance' && (UTVehicle(B.Pawn) == None || !UTVehicle(B.Pawn).bKeyVehicle) )
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
		if(DesiredPosition == UTObjective) {
			DesiredLocation = Rx_BuildingObjective(UTObjective).GetShootTarget().location;
		} else {
			DesiredLocation = DesiredPosition.location;
		} 
		bInPosition = ( VSize(DesiredLocation - B.Pawn.Location) < RX_NEAROBJECTIVEDIST &&
				(B.LineOfSightTo(Rx_BuildingObjective(UTObjective).GetShootTarget()) || (UTObjective.bHasAlternateTargetLocation && B.LineOfSightTo(Rx_BuildingObjective(UTObjective).GetShootTarget(),, true))) );
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
				Dist = VSize(B.location - B.Enemy.location);
				if(!Rx_Bot(B).HasRepairGun()) {
					B.FightEnemy(BotsEnemyIsCloserToObjective(B), 0); 
					return true;	
				} else if(Dist < 2600 && (SquadObjective == None || Rx_BuildingObjective(SquadObjective) == None 
							|| !Rx_BuildingObjective(SquadObjective).NeedsHealing() 
							|| Rx_BuildingObjective(SquadObjective).KillEnemyFirstBeforeHealing(B))) {
					B.FightEnemy(false, 0);
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
			B.MoveToDefensePoint();
		else
		{
			if ( UTObjective.TellBotHowToHeal(B) )
				return true;

			if (B.Enemy != None && (B.LineOfSightTo(B.Enemy) || WorldInfo.TimeSeconds - B.LastSeenTime < 3))
			{
				B.FightEnemy(false, 0);
				return true;
			}

			B.WanderOrCamp();
		}
		return true;
	}

	if (B.Pawn.bStationary )
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
		if ( (UTObjective != None) && (VSize(B.Pawn.Location - UTObjective.Location) > 1200) )
		{
			B.FindBestPathToward(UTObjective,false,true);
			if ( B.StartMoveToward(UTObjective) )
				return true;
		}
	}
	return false;
}

function bool BotsEnemyIsCloserToObjective(UTBot B) {
	if(SquadObjective != None 
		&& VSize(B.location - Rx_BuildingObjective(SquadObjective).GetShootTarget().location) 
			> VSize(B.Enemy.location - Rx_BuildingObjective(SquadObjective).GetShootTarget().location)) {
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
	
	dist = VSize(P.Location - SquadLeader.Pawn.Location);
	if ( dist > FormationSize ) {
		if(dist <= VehicleFormationSize) {
			return true;
		} else { // then its not the distance so check the other stuff again
			if ( PhysicsVolume.bWaterVolume ) { // check if leader is moving away
				if ( VSize(SquadLeader.Pawn.Velocity) > 0 )
					return false;
			}
			else if ( VSize(SquadLeader.Pawn.Velocity) > SquadLeader.Pawn.WalkingPct * SquadLeader.Pawn.GroundSpeed ) {
				return false;
			}
		
			return ( P.Controller.LineOfSightTo(SquadLeader.Pawn) );	
		}
	}
	return false;
}

function float RateDefensivePosition(NavigationPoint N, UTBot CurrentBot, Actor Center)
{
	local float Rating, Dist;
	local UTBot B;
	local int i;
	local ReachSpec ReverseSpec;
	local bool bNeedSpecialMove;
	local UTPawn P;
	//local vector out_HitLocation;
	//local vector out_HitNormal;	
	local Rx_Building Building;

	if(!Center.IsA('Rx_BuildingObjective')) {
		if (N.bDestinationOnly || N.IsA('Teleporter') || N.IsA('PortalMarker') || (N.bFlyingPreferred && !CurrentBot.Pawn.bCanFly))
			//(!FastTrace(N.Location, Center.GetTargetLocation()) && (!Center.bHasAlternateTargetLocation || !FastTrace(N.Location, Center.GetTargetLocation(, true)))))
			return -1.0;
	} else {
		Building = Rx_BuildingObjective(Center).myBuilding;
		Dist = VSize(N.Location - Building.GetTargetLocation());
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

	return Rating;
}

/** Dont enter vehicle when Bot should heal building instead */
function bool CheckVehicle(UTBot B)
{
	if(SquadObjective != None && Rx_BuildingObjective(SquadObjective) != None 
			&& Rx_Bot(B).HasRepairGun() 
			&& Rx_BuildingObjective(SquadObjective).NeedsHealing() 
			&& !Rx_BuildingObjective(SquadObjective).KillEnemyFirstBeforeHealing(B)) {
			return false;
	} else {
		return super.CheckVehicle(B);
	}
}

function float VehicleDesireability(UTVehicle V, UTBot B)
{
	if(Rx_Vehicle(V) != None && Rx_Vehicle(V).bDriverLocked) {
		return 0;
	}
	return super.VehicleDesireability(V,B);
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
	if(Rx_Vehicle(squadVehicle).buyerPri != None && Rx_Vehicle(squadVehicle).buyerPri != B.PlayerReplicationInfo) {
		return false;
	} else {
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
		Dist = VSize(NewThreat.Location - B.Pawn.Location);
		if (Dist <= class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius && bThreatVisible)
		{
			ret += (class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius - Dist) / class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius;
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
			if (VSize(NewEnemy.Location - M.Pawn.Location) <= class'Rx_Hud_PlayerNames'.default.EnemyDisplayNamesRadius)
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
	 MaxSquadSize=2 // counts only for Attack and Freelance Squads ! Defense Squads have no limit.
	 bRoamingSquad=true
	 bShouldUseGatherPoints=true	 
	 FormationSize=1100.0
	 VehicleFormationSize=2500.0
	 MaxSquadRoutes=5
}
