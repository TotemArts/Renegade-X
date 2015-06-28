class Rx_DmgType_TacticalRifle extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_TACTICALRIFLE
    DeathStatsName=DEATHS_TACTICALRIFLE
    SuicideStatsName=SUICIDES_TACTICALRIFLE

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.375
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=false

    CustomTauntIndex=10
    lightArmorDmgScaling=0.375
    BuildingDamageScaling=0.4
	MineDamageScaling=2.0
	
	AlwaysGibDamageThreshold=98
	bNeverGibs=True
	
	BleedDamageFactor=0.2
	BleedCount=4
	
	KDamageImpulse=5000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_TacticalRifle";
	IconTexture=Texture2D'RX_WP_TacticalRifle.UI.T_WeaponIcon_TacticalRifle'
}