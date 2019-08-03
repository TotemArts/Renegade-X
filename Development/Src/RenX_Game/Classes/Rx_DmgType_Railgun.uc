class Rx_DmgType_Railgun extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_RAILGUN
    DeathStatsName=DEATHS_RAILGUN
    SuicideStatsName=SUICIDES_RAILGUN

//    DamageWeaponClass=class'Rx_Weapon_LaserRifle'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.5 //0.428
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025

    CustomTauntIndex=10
    lightArmorDmgScaling=0.55
    BuildingDamageScaling=0.4
	MCTDamageScaling=6.0
	MineDamageScaling=2.0

	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.90 //0.95     //FLAK infantry armour (Standard rule is splash damage does  50% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.90 //0.95	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties) - EDIT: 20% -Remotes OP 
	Inf_LazarusDamageScaling = 0.90 //0.95  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	Inf_NoArmourDamageScaling = 0.90
	
	BleedDamageFactor=0.01
	BleedCount=8
	
	KDamageImpulse=20000
	KDeathUpKick=100

	IconTextureName="T_WeaponIcon_Railgun"
	IconTexture=Texture2D'RX_WP_Railgun.UI.T_WeaponIcon_Railgun'
}