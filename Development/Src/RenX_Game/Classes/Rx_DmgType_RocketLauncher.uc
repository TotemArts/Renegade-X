class Rx_DmgType_RocketLauncher extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_ROCKETLAUNCHER
    DeathStatsName=DEATHS_ROCKETLAUNCHER
    SuicideStatsName=SUICIDES_ROCKETLAUNCHER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.834 //0.75
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025

    CustomTauntIndex=10
    lightArmorDmgScaling=1.0005
	AircraftDamageScaling=1.5 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour./Again, weapons that are actually difficult to hit with should see the larger bonuses, as opposed to giving huge bonuses to weapons that are hit-scan
    BuildingDamageScaling=1.225
	MineDamageScaling=2.0
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.70     //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.20 //1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	Inf_NoArmourDamageScaling = 1.2 //Damage modifier for no armour
	
    AlwaysGibDamageThreshold=99
    bNeverGibs=false
	
	KDamageImpulse=15000
	KDeathUpKick=1000

	IconTextureName="T_WeaponIcon_RocketLauncher"
	IconTexture=Texture2D'RX_WP_RocketLauncher.UI.T_WeaponIcon_RocketLauncher'
}