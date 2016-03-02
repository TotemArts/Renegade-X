class Rx_DmgType_FlakCannon_Alt extends Rx_DmgType_FlakCannon;

defaultproperties
{
    VehicleDamageScaling=0.1			// 1.2
    VehicleMomentumScaling=0.21
    lightArmorDmgScaling=0.21			// 2.5
    BuildingDamageScaling=0.2
	MCTDamageScaling=2.0 //20 damage in a full clip
	MineDamageScaling=2.0
		////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.3    //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.7	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	
	AlwaysGibDamageThreshold=98
	bNeverGibs=true
	
	BleedDamageFactor=0.2
	BleedCount=4
}