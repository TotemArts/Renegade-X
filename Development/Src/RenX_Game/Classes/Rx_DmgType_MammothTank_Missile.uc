class Rx_DmgType_MammothTank_Missile extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_MAMMOTHTANK
    DeathStatsName=DEATHS_MAMMOTHTANK
    SuicideStatsName=SUICIDES_MAMMOTHTANK

    VehicleDamageScaling=0.75
	lightArmorDmgScaling=0.75
    BuildingDamageScaling=1.5f
	AircraftDamageScaling=-1 //Ummm, Laser Rifle is OP as crap already vs. light vehicles. Seriously, how does Nod EVER lose the field when the SBH is this powerful?? Ignorant SBHs... that's how.
	MineDamageScaling=1.0

	IconTextureName="T_DeathIcon_MammothTank"
	IconTexture=Texture2D'RX_VH_MammothTank.UI.T_DeathIcon_MammothTank'

}