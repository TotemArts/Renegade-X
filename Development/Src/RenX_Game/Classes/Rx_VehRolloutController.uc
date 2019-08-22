class Rx_VehRolloutController extends AIController;

var byte TeamNum;
var array<Rx_VehRolloutNode> rolloutNodes;
var Rx_VehRolloutPendingNode rolloutPendingNode;
var bool bParkingNodeReachable;
var Pawn driver;
var Vehicle vehicleTemp;
var int i;
var float DistToBuyerMax;
var float DistToBuyer;
var UTVehicle shouldWaitVehicle;

event SetTeam(int inTeamIdx)
{
    TeamNum = inTeamIdx;
}

function GetRolloutNodes()
{
	local Rx_VehRolloutPendingNode navPoint,BestPoint;
	local Rx_VehRolloutNode parkingNode;
	local float Dist,BestDist;

	ForEach WorldInfo.AllNavigationPoints(class'Rx_VehRolloutNode',parkingNode) {
		if(parkingNode.ScriptGetTeamNum() == TeamNum && Rx_HelipadVehRolloutNode(parkingNode) == None)
		{
			rolloutNodes.AddItem(parkingNode);
		}
	}
	ForEach WorldInfo.AllNavigationPoints(class'Rx_VehRolloutPendingNode',navPoint)
	{
		if(navPoint.ScriptGetTeamNum() == TeamNum && Rx_HelipadVehRolloutPendingNode(navPoint) == None)
		{
			Dist = VSizeSq(navPoint.Location - Controller(Rx_Vehicle(Pawn).buyerPri.Owner).Pawn.Location);
			if(BestPoint == None || BestDist > Dist)
			{
				BestPoint = navPoint;
				BestDist = Dist;
			}
		}
	}
	if(BestPoint != None)
		rolloutPendingNode = BestPoint;

}

auto state Idle
{
}

state RolloutMove
{
Begin:
	if (rolloutPendingNode == none)
	{
		GetRolloutNodes();
		if (rolloutPendingNode == none) // fix where server crashes if no park nodes in map
			GotoState('leaveVehicle');
	}

	UTVehicle(Pawn).bAllowedExit = false; // prevent dummy drivers from walking
	UTVehicle(Pawn).bBlocksNavigation = true;
	while (Pawn != None && !Pawn.ReachedDestination(rolloutPendingNode)) {
		MoveToward(rolloutPendingNode, rolloutPendingNode);
	}
	ScriptedMoveTarget = none;
	DistToBuyerMax = 0.0;
	while (Pawn != None) {
		if(ScriptedMoveTarget == none) {

			// pick a random parkingspot among the not-blocked spots
			while(rolloutNodes.Length > 0) {
				i = Round(RandRange(0,rolloutNodes.Length-1));
				if (ActorReachable(rolloutNodes[i]))
				{
					bParkingNodeReachable = true;
					ForEach OverlappingActors(class'Vehicle', vehicleTemp, 40.0, rolloutNodes[i].Location) {
						bParkingNodeReachable = false;
						break;
					}
					if(bParkingNodeReachable) {										
						DistToBuyer = VSizeSq(rolloutNodes[i].Location - Controller(Rx_Vehicle(Pawn).buyerPri.Owner).Pawn.Location);
						if(DistToBuyerMax == 0.0 || DistToBuyer < DistToBuyerMax)
						{
							ScriptedMoveTarget = rolloutNodes[i];	
							DistToBuyerMax = DistToBuyer;		
						}
					}
				}
				rolloutNodes.Remove(i,1);
			}

		}
		if(ScriptedMoveTarget != none) {
			if(!Pawn.ReachedDestination(ScriptedMoveTarget)) {
				MoveToward(ScriptedMoveTarget,ScriptedMoveTarget);
			} else {
				GotoState('leaveVehicle');
			}
		} else {
			GotoState('leaveVehicle');
		}
	}
}

state leaveVehicle
{
	event BeginState(Name PreviousStateName)
	{
		UTVehicle(Pawn).bAllowedExit = true;
		driver = UTVehicle(Pawn).Driver;
		UTVehicle(Pawn).DriverLeave(true);
		driver.Destroy();
		Destroy();
	}
}

function ResetVehStationary() {
	shouldWaitVehicle.bStationary = false;
}

function setShouldWait(UTVehicle shouldWaitVeh){
	SetTimer(1,false,'ResetVehStationary');
	shouldWaitVehicle = shouldWaitVeh;
}


defaultproperties
{
	bIsPlayer = false
}
