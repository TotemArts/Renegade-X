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

defaultproperties
{
	HealthMax				= 400
}