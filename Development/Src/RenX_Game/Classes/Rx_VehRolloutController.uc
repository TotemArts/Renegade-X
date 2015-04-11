class Rx_VehRolloutController extends AIController;

var byte TeamNum;
var array<Rx_VehRolloutNode> rolloutNodes;
var Rx_VehRolloutPendingNode rolloutPendingNode;
var bool bParkingNodeReachable;
var Pawn driver;
var Vehicle vehicleTemp;
var int i;
var UTVehicle shouldWaitVehicle;

event SetTeam(int inTeamIdx)
{
    TeamNum = inTeamIdx;
}

function GetRolloutNodes()
{
	local Rx_VehRolloutPendingNode navPoint;
	local Rx_VehRolloutNode parkingNode;
	
	foreach WorldInfo.AllNavigationPoints(class'Rx_VehRolloutNode',parkingNode) {
		if(parkingNode.ScriptGetTeamNum() == TeamNum) 
		{
			rolloutNodes.AddItem(parkingNode);
		}
	}
	ForEach WorldInfo.AllNavigationPoints(class'Rx_VehRolloutPendingNode',navPoint)
	{
		if(navPoint.ScriptGetTeamNum() == TeamNum) 
		{
			rolloutPendingNode = navPoint;
		}
	}
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
						ScriptedMoveTarget = rolloutNodes[i];				
						break;
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
