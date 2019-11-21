class Rx_DmgType_TiberiumFlechetteRifle extends Rx_DmgType_Tiberium;

defaultproperties
{
    KillStatsName=KILLS_TiberiumFlechetteRifle
    DeathStatsName=DEATHS_TiberiumFlechetteRifle
    SuicideStatsName=SUICIDES_TiberiumFlechetteRifle

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.0493827161
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.0987654321
    BuildingDamageScaling=0.0493827161
	MCTDamageScaling=5.0
    
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.3     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.70	//Kevlar (General rule is 25% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
    bPiercesArmor=false
	
	BleedDamageFactor=0.10 //0.25
	BleedCount=5
	
	KDamageImpulse=100
	KDeathUpKick=50
	
	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=2.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0

	IconTextureName="RenXHud_I112"
	IconTexture=Texture2D'RX_WP_TiberiumFlechetteRifle.UI.T_WeaponIcon_TiberiumFlechetteRifle'
	bUnsourcedDamage=false
}