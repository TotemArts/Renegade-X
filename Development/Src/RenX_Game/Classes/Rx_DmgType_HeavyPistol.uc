class Rx_DmgType_HeavyPistol extends Rx_DmgType_Bullet;

defaultproperties
{
    KillStatsName=KILLS_HEAVYPISTOL
    DeathStatsName=DEATHS_HEAVYPISTOL
    SuicideStatsName=SUICIDES_HEAVYPISTOL

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.075
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=false

		////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.1     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.70	//Kevlar (General rule is 25% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
    CustomTauntIndex=10
    lightArmorDmgScaling=0.1875
    BuildingDamageScaling=0.075
	MCTDamageScaling=5.0
	MineDamageScaling=2.0
	
	
	AlwaysGibDamageThreshold=98
	bNeverGibs=True
	
	//BleedDamageFactor=0.2
	//BleedCount=4
	
	KDamageImpulse=5000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_HeavyPistol";
	IconTexture=Texture2D'RX_WP_Pistol.UI.T_WeaponIcon_HeavyPistol'
}