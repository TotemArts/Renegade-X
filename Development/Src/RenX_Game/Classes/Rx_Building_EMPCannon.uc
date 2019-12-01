class Rx_Building_EMPCannon extends Rx_Building_Techbuilding 
placeable;

simulated function String GetHumanReadableName()
{
	return "Electromagnetic Pulse Cannon";
}

defaultproperties
{
	
	BuildingInternalsClass  = Rx_Building_EMPCannon_Internals

    Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'RX_BU_EMPCannon.Mesh.EMPCannonBase'
    End Object

    /**Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'RX_BU_CommCentre.Meshes.SM_CommCentre_Details'
    End Object*/

    IconTexture = Texture2D'RenxHud.T_Tech_EMP'
}