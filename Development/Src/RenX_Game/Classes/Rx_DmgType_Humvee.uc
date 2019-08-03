class Rx_DmgType_Humvee extends Rx_DmgType_VehicleMG;

DefaultProperties
{
	
	lightArmorDmgScaling=0.25 //0.2
    VehicleDamageScaling=0.05 //0.15
	AircraftDamageScaling=0.33 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
	
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.5//1.3     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.85 //0.70	//Kevlar (General rule is 25% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.

	IconTextureName="T_DeathIcon_Humvee"
	IconTexture=Texture2D'RX_VH_Humvee.UI.T_DeathIcon_Humvee'
}

