class Rx_DmgType_Shell extends Rx_DmgType_Explosive;		// Rx_DmgType_Burn;

defaultproperties
{
    DamageWeaponClass=none
    DamageWeaponFireMode=0

    VehicleMomentumScaling=0.025
    VehicleDamageScaling=0.83		// 0.85
	lightArmorDmgScaling=0.83		// 0.85
	AircraftDamageScaling=1.4 		//This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
    BuildingDamageScaling=1.66		// 0.85
	MCTDamageScaling=4.0
	MineDamageScaling=2.0
	
    AlwaysGibDamageThreshold=99
    bNeverGibs=false
	
	KDamageImpulse=20000
	KDeathUpKick=500
/*	
	DamageBodyMatColor=(R=50,G=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	bUseTearOffMomentum=false
	
	BleedDamageFactor=0.1
	BleedCount=5

	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=0.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0
*/
}