class Rx_DmgType_TacticalRifleGrenade extends Rx_DmgType_TacticalRifle;

defaultproperties
{
    
    VehicleDamageScaling=0.30

    CustomTauntIndex=10
    lightArmorDmgScaling=0.40//0.375
	AircraftDamageScaling=0.5 //Better, but still just barely able to 1-clip an Apache... and the projectile is dodgeable. Patch can't be good at EVERYTHING
    
	BuildingDamageScaling=1.0
	MCTDamageScaling=2.5
	
	MineDamageScaling=2.0
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.8   //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	
	AlwaysGibDamageThreshold=98
	bNeverGibs=False
	
	BleedDamageFactor=0.075
	BleedCount=5
	
	KDamageImpulse=5000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_TacticalRifle";
	IconTexture=Texture2D'RX_WP_TacticalRifle.UI.T_WeaponIcon_TacticalRifle'
}