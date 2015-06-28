class TS_Vehicle_ReconBike_DmgType extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_RECONBIKE
    DeathStatsName=DEATHS_RECONBIKE
    SuicideStatsName=SUICIDES_RECONBIKE

    VehicleDamageScaling=0.48
	lightArmorDmgScaling=0.48
    BuildingDamageScaling=0.96f
	MineDamageScaling=2.0

	IconTextureName="T_DeathIcon_ReconBike"
	IconTexture=Texture2D'TS_VH_ReconBike.Materials.T_DeathIcon_ReconBike'
}