class Rx_DmgType_A10_Missile extends Rx_DmgType_Explosive;

defaultproperties
{
    KillStatsName=KILLS_ARTILLERY
    DeathStatsName=DEATHS_ARTILLERY
    SuicideStatsName=SUICIDES_ARTILLERY

    VehicleDamageScaling=1.0
	lightArmorDmgScaling=1.0
    BuildingDamageScaling=0.05f
	MineDamageScaling=2.0
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.70     //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more) May change for certain weapons however.
	Inf_KevlarDamageScaling = 1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.1  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	IconTextureName="T_WeaponIcon_A10"
	IconTexture=Texture2D'RX_VH_A-10.UI.T_DeathIcon_A10'
}