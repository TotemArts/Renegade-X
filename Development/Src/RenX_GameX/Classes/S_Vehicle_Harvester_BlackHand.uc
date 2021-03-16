class S_Vehicle_Harvester_BlackHand extends Rx_Vehicle_Harvester
    placeable;

simulated event PostBeginPlay()
{	
	super.PostBeginPlay();
	MaterialInstanceConstant(Mesh.GetMaterial(0)).SetTextureParameterValue('Camo', Texture2D'S_VehicleCamos.Vehicle.T_Camo_Nod_Default');
}

DefaultProperties
{
	HarvyMessageClass = class'S_Message_Harvester'
	TeamNum = 0
}
