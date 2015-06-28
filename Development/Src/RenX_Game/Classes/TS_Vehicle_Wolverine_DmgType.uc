class TS_Vehicle_Wolverine_DmgType extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_WOLVERINE
    DeathStatsName=DEATHS_WOLVERINE
    SuicideStatsName=SUICIDES_WOLVERINE

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.17
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.01
    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=0.2
    BuildingDamageScaling=0.2
	MineDamageScaling=1.0
	
    AlwaysGibDamageThreshold=19
	bNeverGibs=false
	
	KDamageImpulse=8000
	KDeathUpKick=200

	IconTextureName="T_DeathIcon_Wolverine"
	IconTexture=Texture2D'TS_VH_Wolverine.Materials.T_DeathIcon_Wolverine'
}