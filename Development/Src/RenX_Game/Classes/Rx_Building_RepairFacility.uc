class Rx_Building_RepairFacility extends Rx_Building
abstract;

var(RenX_Buildings) int RepairRate; // The amount of healing per 0.1 seconds. (RepairRate * 10 = repair per second)
var(RenX_Buildings) int RepairDistance; // How far the repair pad will repair from the center (don't change unless you scale it for some reason)

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
    TeamID = TEAM_UNOWNED
    bSignificant = false

    // The distance to check for applicable vehicles to be repaired on each pad
	RepairDistance = 450

	// How much HP to repair the vehicle per 0.1 second when power is online. RepairRate * 10 = Repair Per Second
	RepairRate = 7

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