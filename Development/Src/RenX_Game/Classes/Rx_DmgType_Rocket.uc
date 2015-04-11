class Rx_DmgType_Rocket extends UTDmgType_Rocket;

defaultproperties
{
    KillStatsName=KILLS_ROCKETLAUNCHER
    DeathStatsName=DEATHS_ROCKETLAUNCHER
    SuicideStatsName=SUICIDES_ROCKETLAUNCHER

    // DamageWeaponClass=class'Rx_Weapon_RocketLauncher_Gunner'
    DamageWeaponFireMode=0
    
    VehicleMomentumScaling=0.025
    VehicleDamageScaling=0.44
    NodeDamageScaling=1.1
    bThrowRagdoll=true
    CustomTauntIndex=7
    bBulletHit=false
    bCausesBloodSplatterDecals=false
    AlwaysGibDamageThreshold=99
    bNeverGibs=false
	
	KDamageImpulse=15000
	KDeathUpKick=1000
}