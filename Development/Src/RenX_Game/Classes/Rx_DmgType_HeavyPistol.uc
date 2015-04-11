class Rx_DmgType_HeavyPistol extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_HEAVYPISTOL
    DeathStatsName=DEATHS_HEAVYPISTOL
    SuicideStatsName=SUICIDES_HEAVYPISTOL

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.45
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=false

    CustomTauntIndex=10
    lightArmorDmgScaling=0.45
    BuildingDamageScaling=0.1
	MineDamageScaling=2.0
	
	AlwaysGibDamageThreshold=98
	bNeverGibs=True
	
	BleedDamageFactor=0.2
	BleedCount=4
	
	KDamageImpulse=5000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_HeavyPistol";
}