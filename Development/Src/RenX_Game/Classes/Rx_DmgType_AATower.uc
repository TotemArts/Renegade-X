class Rx_DmgType_AATower extends Rx_DmgType_MRLS;

DefaultProperties
{
	IconTextureName="T_DeathIcon_AATower"
	IconTexture=Texture2D'RX_DEF_CeilingTurret.UI.T_DeathIcon_AATower'
	VehicleDamageScaling=0.75
	lightArmorDmgScaling=1.0
	AircraftDamageScaling=1.0 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
}
