class Rx_DmgType_TiberiumAutoRifle_Flechette_Blue extends Rx_DmgType_TiberiumAutoRifle_Blue ;

defaultproperties
{
    KillStatsName=KILLS_TiberiumAutoRifle
    DeathStatsName=DEATHS_TiberiumAutoRifle
    SuicideStatsName=SUICIDES_TiberiumAutoRifle

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.1
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.2
	AircraftDamageScaling=0.6 //Low flying aircraft be damned. 
    BuildingDamageScaling=0.01
	MCTDamageScaling=2.5
	MineDamageScaling=1.0
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.3    //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.7	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
    bPiercesArmor=false
	
	BleedDamageFactor=0
	BleedCount=0

	IconTextureName="T_WeaponIcon_TiberiumAutoRifle"
	IconTexture=Texture2D'RX_WP_TiberiumAutoRifle.UI.T_WeaponIcon_TiberiumAutoRifle'
}