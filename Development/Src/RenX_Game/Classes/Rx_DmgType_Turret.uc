class Rx_DmgType_Turret extends Rx_DmgType_MediumTank;

DefaultProperties
{

	VehicleDamageScaling= 1.15 //0.8
	lightArmorDmgScaling=1.15 //0.8
   
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.30  //0.50     //FLAK infantry armour (Standard rule is splash damage does  50% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.0 //0.80  //1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties) - EDIT: 20% - EDIT2 : Applied penalty to Kevlar infantry against splash damage, now that there's a NONE armour category
	Inf_LazarusDamageScaling = 0.80 //1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	Inf_NoArmourDamageScaling = 1.2 //Damage modifier for no armour

	IconTextureName="T_DeathIcon_Turret"
	IconTexture=Texture2D'RX_DEF_Turret.UI.T_DeathIcon_Turret'
}
