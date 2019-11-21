class Rx_DmgType_Pistol extends Rx_DmgType_Bullet;

defaultproperties
{
    KillStatsName=KILLS_PISTOL
    DeathStatsName=DEATHS_PISTOL
    SuicideStatsName=SUICIDES_PISTOL

	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.1     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.70	//Kevlar (General rule is 25% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	
//    DamageWeaponClass=class'Rx_Weapon_Pistol'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.008f
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.08
    BuildingDamageScaling=0.001
	MCTDamageScaling=100.0
	
	KDamageImpulse=1000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_Pistol"
	IconTexture=Texture2D'RX_WP_Pistol.UI.T_WeaponIcon_Pistol'
}