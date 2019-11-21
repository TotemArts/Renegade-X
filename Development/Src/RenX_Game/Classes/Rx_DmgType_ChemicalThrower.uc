class Rx_DmgType_ChemicalThrower extends Rx_DmgType_Tiberium;

defaultproperties
{
    KillStatsName=KILLS_CHEMICALTHROWER
    DeathStatsName=DEATHS_CHEMICALTHROWER
    SuicideStatsName=SUICIDES_CHEMICALTHROWER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.2475 //0.3 //0.25 //0.335						// 2.64 hp per shot
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.28875 //0.35		// 0.495		// 3.96 hp per shot
    BuildingDamageScaling=0.4125 //0.5 //0.33		// 0.495		// 3.96 hp per shot
	MCTDamageScaling=2.0 //2.45 //2.8 //3.0
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.0  //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	
	MineDamageScaling=2.0
    
    bPiercesArmor=false
	
	BleedDamageFactor=0.10 //0.45
	BleedCount=3
	
	KDamageImpulse=100
	KDeathUpKick=50
	
	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=2.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0

	IconTextureName="T_WeaponIcon_ChemicalThrower"
	IconTexture=Texture2D'RX_WP_ChemicalThrower.UI.T_WeaponIcon_ChemicalThrower'
	
	bUnsourcedDamage=false
}