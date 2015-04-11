class Rx_DmgType_ChemicalThrower extends Rx_DmgType_Tiberium;

defaultproperties
{
    KillStatsName=KILLS_CHEMICALTHROWER
    DeathStatsName=DEATHS_CHEMICALTHROWER
    SuicideStatsName=SUICIDES_CHEMICALTHROWER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.335						// 2.64 hp per shot
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.35		// 0.495		// 3.96 hp per shot
    BuildingDamageScaling=0.33		// 0.495		// 3.96 hp per shot
	MineDamageScaling=2.0
    
    bPiercesArmor=false
	
	BleedDamageFactor=0.45
	BleedCount=5
	
	KDamageImpulse=100
	KDeathUpKick=50
	
	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=2.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0

	IconTextureName="T_WeaponIcon_ChemicalThrower"
}