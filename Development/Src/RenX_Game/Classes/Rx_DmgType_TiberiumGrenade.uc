class Rx_DmgType_TiberiumGrenade extends Rx_DmgType_Tiberium;

DefaultProperties
{

VehicleDamageScaling=0.5 //0.15
lightArmorDmgScaling=1.0 //0.15

////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.70 //0.9    //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.3 //0.9	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.3 //0.9  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	Inf_NoArmourDamageScaling = 1.3
bPiercesArmor = false
BleedDamageFactor=0.05
BleedCount=5
bUnsourcedDamage=false
}