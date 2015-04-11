class Rx_VehRolloutNode extends NavigationPoint
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
	//Begin Object Class=SpriteComponent Name=SpriteY ObjName=SpriteY
	// Sprite=Texture2D'EngineResources.S_Pickup'
	//End Object
	//Components(0)=SpriteY

	bVehicleDestination = true;
	bCanWalkOnToReach = false;
	bNotBased=true
	//bHidden=true

	TeamNum = 0 // proper team needs to be assigned in the Editor!
}
