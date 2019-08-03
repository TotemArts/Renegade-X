class Rx_Building_CommCentre extends Rx_Building_Techbuilding
   placeable;

simulated function String GetHumanReadableName()
{
	return "Communications Center";
}

defaultproperties
{
	
	BuildingInternalsClass  = Rx_Building_CommCentre_Internals

    Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'RX_BU_CommCentre.Meshes.SM_CommCentre_Frame'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'RX_BU_CommCentre.Meshes.SM_CommCentre_Details'
    End Object
}