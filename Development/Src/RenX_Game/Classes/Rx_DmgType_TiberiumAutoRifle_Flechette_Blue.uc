class Rx_DmgType_TiberiumAutoRifle_Flechette_Blue extends Rx_DmgType_TiberiumAutoRifle_Blue ;

defaultproperties
{
    KillStatsName=KILLS_TiberiumAutoRifle
    DeathStatsName=DEATHS_TiberiumAutoRifle
    SuicideStatsName=SUICIDES_TiberiumAutoRifle

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.0789743589 //0.0733333333
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.157948718 //0.1466666667
	AircraftDamageScaling= 0.2764102564 //0.2566666667 //Low flying aircraft be damned. 
    BuildingDamageScaling= 0.2764102564 //0.2566666667 //0.0073333333
	MCTDamageScaling=2.5
	MineDamageScaling=1.0
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.1    //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.90 //0.70 //0.80	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
    bPiercesArmor=false
	bCausesBleed=true
	
	BleedDamageFactor=0.05
	BleedCount=5

	IconTextureName="T_WeaponIcon_TiberiumAutoRifle"
	IconTexture=Texture2D'RX_WP_TiberiumAutoRifle.UI.T_WeaponIcon_TiberiumAutoRifle'
}