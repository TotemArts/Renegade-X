class Rx_DmgType_EMPGrenade extends Rx_DmgType_EMP;

defaultproperties
{
    KillStatsName=KILLS_EMPGRENADE
    DeathStatsName=DEATHS_EMPGRENADE
    SuicideStatsName=SUICIDES_EMPGRENADE

    //DamageWeaponClass=class'Rx_Weapon_EMPGrenade'
    DamageWeaponFireMode=0

    VehicleMomentumScaling=1.0
    VehicleDamageScaling=0.0 //6.0
    NodeDamageScaling=1.1
    bThrowRagdoll=true
    CustomTauntIndex=7
    lightArmorDmgScaling=0.0 //6.0
    BuildingDamageScaling=0.0 //6.0
    AlwaysGibDamageThreshold=200
    bNeverGibs=false
	
	KDamageImpulse=10000
	KDeathUpKick=2000
	
	BleedDamageFactor=0.1
	BleedCount=10
	
	IconTexture=Texture2D'RX_WP_EMPGrenade.UI.T_WeaponIcon_EMPGrenade'
}