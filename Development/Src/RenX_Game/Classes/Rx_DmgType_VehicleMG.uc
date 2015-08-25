class Rx_DmgType_VehicleMG extends Rx_DmgType;

DefaultProperties
{
	KillStatsName=KILLS_APC
    DeathStatsName=DEATHS_APC
    SuicideStatsName=SUICIDES_APC

    // DamageWeaponClass=class'Rx_Vehicle_APC_Nod_Weapon' // need to set this if we want to have weapon killicons
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.15
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=True
    KDamageImpulse=200
    bCausesBloodSplatterDecals=false
    CustomTauntIndex=10
    lightArmorDmgScaling=0.2
	AircraftDamageScaling=0.33 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
    BuildingDamageScaling=0.01
}
