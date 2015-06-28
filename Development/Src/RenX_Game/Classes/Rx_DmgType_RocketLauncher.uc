class Rx_DmgType_RocketLauncher extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_ROCKETLAUNCHER
    DeathStatsName=DEATHS_ROCKETLAUNCHER
    SuicideStatsName=SUICIDES_ROCKETLAUNCHER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.75
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025

    CustomTauntIndex=10
    lightArmorDmgScaling=1.0005
    BuildingDamageScaling=1.225
	MineDamageScaling=2.0
    AlwaysGibDamageThreshold=99
    bNeverGibs=false
	
	KDamageImpulse=15000
	KDeathUpKick=1000

	IconTextureName="T_WeaponIcon_RocketLauncher"
	IconTexture=Texture2D'RX_WP_RocketLauncher.UI.T_WeaponIcon_RocketLauncher'
}