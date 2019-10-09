class Rx_Vehicle_ReconBike_DmgType extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_ATTACKCYCLE
    DeathStatsName=DEATHS_ATTACKCYCLE
    SuicideStatsName=SUICIDES_ATTACKCYCLE

    VehicleDamageScaling=1.0
	lightArmorDmgScaling=1.0
	AircraftDamageScaling=1.0
    BuildingDamageScaling=0.96f
	MineDamageScaling=2.0

	IconTextureName="T_DeathIcon_ReconBike"
	IconTexture=Texture2D'RX_VH_ReconBike.UI.T_DeathIcon_ReconBike'
}