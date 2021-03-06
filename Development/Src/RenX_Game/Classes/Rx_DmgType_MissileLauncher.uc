class Rx_DmgType_MissileLauncher extends Rx_DmgType_Explosive;

defaultproperties
{
    KillStatsName=KILLS_MISSILELAUNCHER
    DeathStatsName=DEATHS_MISSILELAUNCHER
    SuicideStatsName=SUICIDES_MISSILELAUNCHER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.80 //0.65
	NodeDamageScaling=0.5
    VehicleMomentumScaling=0.5
	MineDamageScaling=2.0

    CustomTauntIndex=10
    lightArmorDmgScaling=0.90 //0.75
    AircraftDamageScaling=0.90 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
    BuildingDamageScaling=1.5
	
	AlwaysGibDamageThreshold=99
	bNeverGibs=false
	
	KDamageImpulse=15000
	KDeathUpKick=500

	IconTextureName="T_WeaponIcon_MissileLauncher"
	IconTexture=Texture2D'RX_WP_MissileLauncher.UI.T_WeaponIcon_MissileLauncher'
}