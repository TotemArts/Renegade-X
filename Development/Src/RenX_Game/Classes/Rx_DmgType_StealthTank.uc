class Rx_DmgType_StealthTank extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_STEALTHTANK
    DeathStatsName=DEATHS_STEALTHTANK
    SuicideStatsName=SUICIDES_STEALTHTANK

    VehicleDamageScaling=1.0
	lightArmorDmgScaling=1.0
	AircraftDamageScaling=-1 //Ummm, Laser Rifle is OP as crap already vs. light vehicles. Seriously, how does Nod EVER lose the field when the SBH is this powerful?? Ignorant SBHs... that's how.
    BuildingDamageScaling=1.9f
	MCTDamageScaling=2.5
	
	
	AlwaysGibDamageThreshold=35

	IconTextureName="T_DeathIcon_StealthTank"
	IconTexture=Texture2D'RX_VH_StealthTank.UI.T_DeathIcon_StealthTank'
}