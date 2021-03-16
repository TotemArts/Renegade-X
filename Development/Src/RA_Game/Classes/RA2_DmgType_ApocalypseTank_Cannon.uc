/*********************************************************
*
* File: RA2_DmgType_ApocalypseTank_Cannon.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class RA2_DmgType_ApocalypseTank_Cannon extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_APOCALYPSETANK
    DeathStatsName=DEATHS_APOCALYPSETANK
    SuicideStatsName=SUICIDES_APOCALYPSETANK

    VehicleDamageScaling=1.3//0.8
	lightArmorDmgScaling=1.3//0.8
    BuildingDamageScaling=2.1 //2.04//1.36f

	IconTextureName="T_VehicleIcon_ApocalypseTank"
	IconTexture=Texture2D'RA2_VH_ApocalypseTank.Textures.T_DeathIcon_ApocalypseTank'
	
}