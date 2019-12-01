class Rx_Building_Techbuilding extends Rx_Building;

simulated function byte ScriptGetTeamNum() 
{
	return Rx_Building_TechBuilding_Internals(BuildingInternals).ReplicatedTeamID; 
}

simulated function byte GetTeamNum() 
{
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

defaultproperties
{
	myBuildingType=BT_Neutral
	HealthMax				= 400

	SupportedEvents.Empty
	SupportedEvents.Add(class'Rx_SeqEvent_TechCapture')

	IconTexture = Texture2D'RenxHud.T_Tech_EMP' //just random stuff...
}