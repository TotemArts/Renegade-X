class TS_Vehicle_TickTank_DmgType extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_TICKTANK
    DeathStatsName=DEATHS_TICKTANK
    SuicideStatsName=SUICIDES_TICKTANK

    VehicleDamageScaling=0.8
	lightArmorDmgScaling=0.8
    BuildingDamageScaling=1.32f

	IconTextureName="T_DeathIcon_Titan"
	IconTexture=Texture2D'TS_VH_TickTank.Materials.T_DeathIcon_TickTank'
}