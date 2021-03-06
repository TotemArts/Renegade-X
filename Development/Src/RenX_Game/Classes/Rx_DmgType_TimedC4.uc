class Rx_DmgType_TimedC4 extends Rx_DmgType_Explosive;

defaultproperties
{
    KillStatsName=KILLS_TIMEDC4
    DeathStatsName=DEATHS_TIMEDC4
    SuicideStatsName=SUICIDES_TIMEDC4

    DamageWeaponFireMode=2
    VehicleDamageScaling=1.0
    NodeDamageScaling=1.0
    VehicleMomentumScaling=1.0

    CustomTauntIndex=10
    lightArmorDmgScaling=1.0
    BuildingDamageScaling=1.0
	AircraftDamageScaling=1.25 //Used so it will kill a 500hp Chinook
    MCTDamageScaling=4.0 //1600 
	MineDamageScaling=2.0
	
    AlwaysGibDamageThreshold=99
	bNeverGibs=false
	
	KDamageImpulse=10000
	KDeathUpKick=2000

	IconTextureName="T_WeaponIcon_TimedC4"
	IconTexture=Texture2D'RX_WP_TimedC4.UI.T_WeaponIcon_TimedC4'
}