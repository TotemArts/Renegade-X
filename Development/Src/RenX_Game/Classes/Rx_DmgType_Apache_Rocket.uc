class Rx_DmgType_Apache_Rocket extends Rx_DmgType_Explosive;

defaultproperties
{
    KillStatsName=KILLS_APACHEROCKET
    DeathStatsName=DEATHS_APACHEROCKET
    SuicideStatsName=SUICIDES_APACHEROCKET

    DamageWeaponFireMode=2
    VehicleDamageScaling=1.0
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025
	

    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=1.0
    BuildingDamageScaling=1.75
	MCTDamageScaling=3.0
	MineDamageScaling=2.0
	
	
    AlwaysGibDamageThreshold=30
	bNeverGibs=false
	
	KDamageImpulse=15000
	KDeathUpKick=300

	IconTextureName="T_DeathIcon_Apache"
	IconTexture=Texture2D'RX_VH_Apache.UI.T_DeathIcon_Apache'
}