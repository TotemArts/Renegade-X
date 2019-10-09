class Rx_DmgType_Kamikaze extends Rx_DmgType_Explosive;

defaultproperties
{
    KillStatsName=KILLS_KAMIKAZE
    DeathStatsName=DEATHS_KAMIKAZE
    SuicideStatsName=SUICIDES_KAMIKAZE

    //DamageWeaponClass=class'Rx_Weapon_GrenadeLauncher'
    DamageWeaponFireMode=0

    VehicleMomentumScaling=0.025
    VehicleDamageScaling=0.36

   // Inf_FLAKDamageScaling = 0.50     //FLAK infantry armour (Standard rule is splash damage does  50% less, while gun damage does 30% more)
    Inf_KevlarDamageScaling = 0.90   //Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
    Inf_LazarusDamageScaling = 0.90  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
    Inf_NoArmourDamageScaling = 0.90 //Damage modifier for no armour

    NodeDamageScaling=1.1
    bThrowRagdoll=true
    CustomTauntIndex=7
    lightArmorDmgScaling=0.36
    BuildingDamageScaling=0.8
	MCTDamageScaling=1.33 //1.75 //2.5
	MineDamageScaling=2.0
	
	
    AlwaysGibDamageThreshold=1
	bCausesBloodSplatterDecals = true
	bNeverGibs=false
	
	KDamageImpulse=10000
	KDeathUpKick=2000

	//IconTextureName="T_WeaponIcon_GrenadeLauncher"
	//IconTexture=Texture2D'RX_WP_GrenadeLauncher.UI.T_WeaponIcon_GrenadeLauncher'
}