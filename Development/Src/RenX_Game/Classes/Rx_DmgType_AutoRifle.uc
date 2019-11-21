class Rx_DmgType_AutoRifle extends Rx_DmgType_Bullet;

defaultproperties
{
    KillStatsName=KILLS_AUTORIFLE
    DeathStatsName=DEATHS_AUTORIFLE
    SuicideStatsName=SUICIDES_AUTORIFLE

    // DamageWeaponClass=class'RxWeapon_AutoRifle' // need to set this if we want to have weapon killicons
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.04 //0.08f
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    CustomTauntIndex=10
    lightArmorDmgScaling=0.11666655 //0.2333331
	AircraftDamageScaling=0.175 //0.35
    BuildingDamageScaling=0.00175 //0.0035
	MCTDamageScaling=150.0
	
	DeathAnim=H_M_Death_CrotchShot
	KDamageImpulse=3000
	KDeathUpKick=500

	IconTextureName="T_WeaponIcon_AutoRifle"
	IconTexture=Texture2D'RX_WP_AutoRifle.UI.T_WeaponIcon_AutoRifle'
}