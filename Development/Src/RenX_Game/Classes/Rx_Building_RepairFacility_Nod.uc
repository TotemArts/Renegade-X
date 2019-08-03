class Rx_Building_RepairFacility_Nod extends Rx_Building_RepairFacility
	placeable;

simulated function String GetHumanReadableName()
{
	return "Nod Repair Facility";
}

defaultproperties
{
   TeamID = TEAM_NOD
   BuildingInternalsClass = Rx_Building_RepairFacility_Nod_Internals

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'RX_BU_RepairPad.Mesh.SM_RepairPad_Nod'
	End Object
}