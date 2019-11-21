class Rx_DmgType_MarksmanRifle extends Rx_DmgType_Bullet;

defaultproperties
{
    KillStatsName=KILLS_AUTORIFLE
    DeathStatsName=DEATHS_AUTORIFLE
    SuicideStatsName=SUICIDES_AUTORIFLE
	//0.625
    // DamageWeaponClass=class'RxWeapon_AutoRifle' // need to set this if we want to have weapon killicons
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.004375f
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    CustomTauntIndex=10
    lightArmorDmgScaling=0.09375
    BuildingDamageScaling=0.0021875
	MCTDamageScaling=150.0
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.15     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.85	//Kevlar (General rule is 25% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	DeathAnim=H_M_Death_CrotchShot
	KDamageImpulse=3000
	KDeathUpKick=500

	IconTextureName="T_WeaponIcon_MarksmanRifle"
	IconTexture=Texture2D'RX_WP_SniperRifle.UI.T_WeaponIcon_MarksmanRifle'
}