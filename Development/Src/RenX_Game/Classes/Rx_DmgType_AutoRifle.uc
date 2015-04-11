class Rx_DmgType_AutoRifle extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_AUTORIFLE
    DeathStatsName=DEATHS_AUTORIFLE
    SuicideStatsName=SUICIDES_AUTORIFLE

    // DamageWeaponClass=class'RxWeapon_AutoRifle' // need to set this if we want to have weapon killicons
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.08f
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    CustomTauntIndex=10
    lightArmorDmgScaling=0.2333331
    BuildingDamageScaling=0.0035
	
	DeathAnim=H_M_Death_CrotchShot
	KDamageImpulse=3000
	KDeathUpKick=500

	IconTextureName="T_WeaponIcon_AutoRifle"
}