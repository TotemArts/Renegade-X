class S_Vehicle_LightTank extends Rx_Vehicle_LightTank
    placeable;

simulated event PostBeginPlay()
{	
	super.PostBeginPlay();
	MaterialInstanceConstant(Mesh.GetMaterial(0)).SetTextureParameterValue('Camo', Texture2D'S_VehicleCamos.Vehicle.T_Camo_Nod_Default');
}
