class Rx_DmgType_TiberiumAutoRifle extends Rx_DmgType_Tiberium;

defaultproperties
{
    KillStatsName=KILLS_TiberiumAutoRifle
    DeathStatsName=DEATHS_TiberiumAutoRifle
    SuicideStatsName=SUICIDES_TiberiumAutoRifle

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.32
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.32
    BuildingDamageScaling=0.1
    
    bPiercesArmor=false
	
	BleedDamageFactor=0.3
	BleedCount=5
	
	KDamageImpulse=100
	KDeathUpKick=50
	
	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=2.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0

	IconTextureName="RenXHud_I110"
}