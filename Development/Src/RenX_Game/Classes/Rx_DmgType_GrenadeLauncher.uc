class Rx_DmgType_GrenadeLauncher extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_GRENADELAUNCHER
    DeathStatsName=DEATHS_GRENADELAUNCHER
    SuicideStatsName=SUICIDES_GRENADELAUNCHER

    //DamageWeaponClass=class'Rx_Weapon_GrenadeLauncher'
    DamageWeaponFireMode=0

    VehicleMomentumScaling=0.025
    VehicleDamageScaling=0.36
    NodeDamageScaling=1.1
    bThrowRagdoll=true
    CustomTauntIndex=7
    lightArmorDmgScaling=0.36
    BuildingDamageScaling=0.8
	MineDamageScaling=2.0
    AlwaysGibDamageThreshold=99
    bNeverGibs=false
	
	KDamageImpulse=10000
	KDeathUpKick=2000

	IconTextureName="T_WeaponIcon_GrenadeLauncher"
}