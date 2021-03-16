class Rx_Building_InfantryFactory extends Rx_Building
	implements(RxIfc_FactoryInfantry)
	abstract;

simulated function bool IsOperational()
{
	return (!IsDestroyed());
}

DefaultProperties
{
	myBuildingType=BT_Inf

		IconTexture=Texture2D'RenxHud.T_BuildingIcon_Character_Normal'
}
