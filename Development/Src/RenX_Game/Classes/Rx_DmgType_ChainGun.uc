class Rx_DmgType_ChainGun extends Rx_DmgType_Bullet;

DefaultProperties
{
	KillStatsName=KILLS_CHAINGUN
    DeathStatsName=DEATHS_CHAINGUN
    SuicideStatsName=SUICIDES_CHAINGUN

    // DamageWeaponClass=class'RxWeapon_AutoRifle' // need to set this if we want to have weapon killicons
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.03f
    NodeDamageScaling=0.25
    VehicleMomentumScaling=0.1
    CustomTauntIndex=10
    lightArmorDmgScaling=0.125//0.2333331
	AircraftDamageScaling=0.275 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
    BuildingDamageScaling=0.00175
	MCTDamageScaling=150.0
	
	MineDamageScaling=2.0
	
	DeathAnim=H_M_Death_CrotchShot
	KDamageImpulse=3000
	KDeathUpKick=500

	IconTextureName="T_WeaponIcon_Chaingun"
	IconTexture=Texture2D'RX_WP_ChainGun.UI.T_WeaponIcon_Chaingun'
}
