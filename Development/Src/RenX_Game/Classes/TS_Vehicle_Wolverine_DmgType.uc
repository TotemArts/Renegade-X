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
	AircraftDamageScaling=0.45 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour. As a rule, this should only be a SIGNIFICANT change when the weapon is very hard to hit with (E.G Tanks/Non hit-scan weapons)
    BuildingDamageScaling=0.2
	MineDamageScaling=1.0
	
    AlwaysGibDamageThreshold=19
	bNeverGibs=false
	
	KDamageImpulse=8000
	KDeathUpKick=200

	IconTextureName="T_DeathIcon_Wolverine"
	IconTexture=Texture2D'TS_VH_Wolverine.Materials.T_DeathIcon_Wolverine'
}