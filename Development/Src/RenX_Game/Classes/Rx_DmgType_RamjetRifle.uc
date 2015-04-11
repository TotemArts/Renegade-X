class Rx_DmgType_RamjetRifle extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_RAMJETRIFLE
    DeathStatsName=DEATHS_RAMJETRIFLE
    SuicideStatsName=SUICIDES_RAMJETRIFLE

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.083			// 15hp
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=0.25			// 45hp
    BuildingDamageScaling=0.009
	MineDamageScaling=2.0
	
	KDamageImpulse=20000
	KDeathUpKick=100

	IconTextureName="T_WeaponIcon_Ramjet"
}