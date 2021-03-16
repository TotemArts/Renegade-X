class S_Building_RepairFacility_BH extends Rx_Building_Nod_RepairFactory
	placeable;

simulated function String GetHumanReadableName()
{
	return "Repair Facility";
}

defaultproperties
{
   TeamID = TEAM_GDI
   BuildingInternalsClass = S_Building_RepairFacility_BH_Internals
   GDIColor = "#3260FF"

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'S_BU_RepairPad.Mesh.SM_RepairPad_BH'
	End Object
}