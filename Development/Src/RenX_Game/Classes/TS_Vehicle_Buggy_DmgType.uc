class TS_Vehicle_Buggy_DmgType extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_BUGGY
    DeathStatsName=DEATHS_BUGGY
    SuicideStatsName=SUICIDES_BUGGY

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.18//0.11
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=0.2//0.16
	AircraftDamageScaling=0.4//0.30 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
    BuildingDamageScaling=0.15
	MineDamageScaling=1.0
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.3     //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.8	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
    AlwaysGibDamageThreshold=19
	bNeverGibs=false
	
	KDamageImpulse=8000
	KDeathUpKick=200

	IconTextureName="T_DeathIcon_Apache"
	IconTexture=Texture2D'TS_VH_Buggy.Materials.T_DeathIcon_Buggy'
}