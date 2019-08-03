class Rx_DmgType_SAMSite extends Rx_DmgType_MRLS;

DefaultProperties
{
	IconTextureName="T_DeathIcon_SAMSite"
	IconTexture=Texture2D'RX_DEF_SamSite.UI.T_DeathIcon_SAMSite'
	
	VehicleDamageScaling=0.5 //0.001 //0.25 //0.1875
    VehicleMomentumScaling=1.0
    lightArmorDmgScaling=1.0
	AircraftDamageScaling=1.0 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour. (Seriously... they did like 40 damage per 2 rockets? That's not even significant enough to deter a SINGLE aircraft)
}
