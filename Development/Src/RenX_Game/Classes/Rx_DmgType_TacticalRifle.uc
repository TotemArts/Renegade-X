class Rx_DmgType_TacticalRifle extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_TACTICALRIFLE
    DeathStatsName=DEATHS_TACTICALRIFLE
    SuicideStatsName=SUICIDES_TACTICALRIFLE

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.1 //0.375
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=false

    CustomTauntIndex=10
    lightArmorDmgScaling=0.3//0.375
	AircraftDamageScaling=0.5 //Better, but still just barely able to 1-clip an Apache... and the projectile is dodgeable. Patch can't be good at EVERYTHING
    
	BuildingDamageScaling=0.4
	MCTDamageScaling=2.0
	
	MineDamageScaling=2.0
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.3    //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.7	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	
	AlwaysGibDamageThreshold=98
	bNeverGibs=True
	
	BleedDamageFactor=0.2
	BleedCount=4
	
	KDamageImpulse=5000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_TacticalRifle";
	IconTexture=Texture2D'RX_WP_TacticalRifle.UI.T_WeaponIcon_TacticalRifle'
}