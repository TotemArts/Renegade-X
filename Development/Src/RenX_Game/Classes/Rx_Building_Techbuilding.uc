class Rx_Building_Techbuilding extends Rx_Building;

var(TechBuilding) byte StartingTeam;

simulated function byte ScriptGetTeamNum() 
{
	if(Rx_Building_TechBuilding_Internals(BuildingInternals) == None)
		return 255;

	return Rx_Building_TechBuilding_Internals(BuildingInternals).ReplicatedTeamID; 
}

simulated function byte GetTeamNum() 
{
	if(Rx_Building_TechBuilding_Internals(BuildingInternals) == None)
		return 255;
	
	return Rx_Building_TechBuilding_Internals(BuildingInternals).ReplicatedTeamID;
}

simulated function bool IsEffectedByEMP()
{
	return false;
}

simulated function BuildingInternalsReplicated()
{
	super.BuildingInternalsReplicated();
	
	if(Rx_Building_TechBuilding_Internals(BuildingInternals) != none)
		Rx_Building_TechBuilding_Internals(BuildingInternals).AddToGRIArray();  
}

//RxIfc_Targetable
simulated function bool GetUseBuildingArmour(){return false;} //Stupid legacy function to determine if we use building armour when drawing.
simulated function bool GetShouldShowHealth(){return false;}

defaultproperties
{
	myBuildingType=BT_Neutral
	HealthMax				= 400

	StartingTeam = 255;

	SupportedEvents.Empty
	SupportedEvents.Add(class'Rx_SeqEvent_TechCapture')

	IconTexture = Texture2D'RenxHud.T_Tech_EMP' //just random stuff...
}