class TS_Vehicle_Wolverine_DmgType extends Rx_DmgType_Bullet;

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
    lightArmorDmgScaling=0.33 //0.2
	AircraftDamageScaling=0.5 //0.45 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour. As a rule, this should only be a SIGNIFICANT change when the weapon is very hard to hit with (E.G Tanks/Non hit-scan weapons)
    BuildingDamageScaling=0.2
	MineDamageScaling=1.0
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.4//1.3     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.80 //0.70	//Kevlar (General rule is 25% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.1  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.

	
    AlwaysGibDamageThreshold=15
	bCausesBloodSplatterDecals = true
	bNeverGibs=false
	
	KDamageImpulse=8000
	KDeathUpKick=200

	IconTextureName="T_DeathIcon_Wolverine"
	IconTexture=Texture2D'TS_VH_Wolverine.Materials.T_DeathIcon_Wolverine'
}