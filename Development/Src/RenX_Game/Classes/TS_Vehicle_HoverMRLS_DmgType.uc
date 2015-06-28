class TS_Vehicle_HoverMRLS_DmgType extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_MRLS
    DeathStatsName=DEATHS_MRLS
    SuicideStatsName=SUICIDES_MRLS

    VehicleDamageScaling=0.48
	lightArmorDmgScaling=0.48
    BuildingDamageScaling=0.96f
	MineDamageScaling=2.0

	IconTextureName="T_DeathIcon_MRLS"
	IconTexture=Texture2D'TS_VH_HoverMRLS.Materials.T_DeathIcon_HoverMRLS'
}