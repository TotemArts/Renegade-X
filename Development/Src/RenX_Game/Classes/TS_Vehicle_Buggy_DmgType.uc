class TS_Vehicle_Buggy_DmgType extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_BUGGY
    DeathStatsName=DEATHS_BUGGY
    SuicideStatsName=SUICIDES_BUGGY

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.135
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=0.17
	AircraftDamageScaling=0.30 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
    BuildingDamageScaling=0.15
	MineDamageScaling=1.0
	
    AlwaysGibDamageThreshold=19
	bNeverGibs=false
	
	KDamageImpulse=8000
	KDeathUpKick=200

	IconTextureName="T_DeathIcon_Apache"
	IconTexture=Texture2D'TS_VH_Buggy.Materials.T_DeathIcon_Buggy'
}