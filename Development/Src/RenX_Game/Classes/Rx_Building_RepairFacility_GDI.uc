class Rx_Building_RepairFacility_GDI extends Rx_Building_GDI_RepairFactory
	placeable;

simulated function String GetHumanReadableName()
{
	return "Repair Facility";
}

defaultproperties
{
   TeamID = TEAM_GDI
   BuildingInternalsClass = Rx_Building_RepairFacility_GDI_Internals

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'RX_BU_RepairPad.Mesh.SM_RepairPad'
	End Object
}
