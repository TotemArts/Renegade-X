class Rx_Building_RepairFacility extends Rx_Building
abstract;

simulated function String GetHumanReadableName()
{
	return "Repair Facility";
}

simulated function bool IsEffectedByEMP()
{
	return false;
}

simulated function bool IsBasicOnly()
{
	return true;
}

simulated function bool IsTouchingOnly()
{
	return false;
}

DefaultProperties
{
    BuildingInternalsClass = Rx_Building_RepairFacility_Internals
    myBuildingType=BT_Rep
    TeamID = TEAM_UNOWNED

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'RX_BU_RepairPad.Mesh.SM_RepairPad'
	End Object
    
    Begin Object Name=PT_Screens
        StaticMesh = None
    End Object

    Begin Object Name=Static_Exterior
        StaticMesh = None
    End Object

    Begin Object Name=Static_Interior_Complex
        StaticMesh = None
    End Object
}