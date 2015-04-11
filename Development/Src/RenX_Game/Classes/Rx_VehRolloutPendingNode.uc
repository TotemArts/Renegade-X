class Rx_VehRolloutPendingNode extends NavigationPoint
   placeable;

var() byte TeamNum;


simulated event byte ScriptGetTeamNum ( ) 
{
   return TeamNum;
}

function bool IsAvailableTo(Actor chkActor)
{
	// todo: only make this available to vehicles that come out of AS/WF
	return true;
}


defaultproperties
{

	bVehicleDestination = false;
	bNotBased=true;

	TeamNum = 0 // proper team needs to be assigned in the Editor!
}
