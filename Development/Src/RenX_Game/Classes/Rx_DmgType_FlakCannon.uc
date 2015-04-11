class Rx_DmgType_FlakCannon extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_FLAKCANNON
    DeathStatsName=DEATHS_FLAKCANNON
    SuicideStatsName=SUICIDES_FLAKCANNON

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.42
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.5

    CustomTauntIndex=10
    lightArmorDmgScaling=0.42
    BuildingDamageScaling=0.42
	MineDamageScaling=2.0
	
    AlwaysGibDamageThreshold=98
	bNeverGibs=true
	
	BleedDamageFactor=0.1
	BleedCount=4

	IconTextureName="T_WeaponIcon_FlakCannon"
}