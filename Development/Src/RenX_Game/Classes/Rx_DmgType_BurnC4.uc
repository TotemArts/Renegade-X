class Rx_DmgType_BurnC4 extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_FLAMETHROWER
    DeathStatsName=DEATHS_FLAMETHROWER
    SuicideStatsName=SUICIDES_FLAMETHROWER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.33
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.33
    BuildingDamageScaling=0.25
	
	DamageBodyMatColor=(R=50,G=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	bUseTearOffMomentum=false
	
	BleedDamageFactor=0.1
	BleedCount=8
	
	KDamageImpulse=100
	KDeathUpKick=50
	
	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=0.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0
}