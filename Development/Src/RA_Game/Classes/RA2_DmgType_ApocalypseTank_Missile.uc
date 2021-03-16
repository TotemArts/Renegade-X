/*********************************************************
*
* File: RA2_DmgType_ApocalypseTank_Missile.uc
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
class RA2_DmgType_ApocalypseTank_Missile extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_APOCALYPSETANK
    DeathStatsName=DEATHS_APOCALYPSETANK
    SuicideStatsName=SUICIDES_APOCALYPSETANK

    VehicleDamageScaling=0.75
	lightArmorDmgScaling=0.75
    BuildingDamageScaling=1.5f
	AircraftDamageScaling=-1 //Ummm, Laser Rifle is OP as crap already vs. light vehicles. Seriously, how does Nod EVER lose the field when the SBH is this powerful?? Ignorant SBHs... that's how.
	MineDamageScaling=1.0

	IconTextureName="T_VehicleIcon_ApocalypseTank"
	IconTexture=Texture2D'RA2_VH_ApocalypseTank.Textures.T_DeathIcon_ApocalypseTank'

}