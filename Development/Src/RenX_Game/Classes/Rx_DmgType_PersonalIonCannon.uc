class Rx_DmgType_PersonalIonCannon extends Rx_DmgType_Electric;

defaultproperties
{
    KillStatsName=KILLS_PERSONALIONCANNON
    DeathStatsName=DEATHS_PERSONALIONCANNON
    SuicideStatsName=SUICIDES_PERSONALIONCANNON

//    DamageWeaponClass=class'Rx_Weapon_PersonalIonCannon'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.428
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025

    CustomTauntIndex=10
    lightArmorDmgScaling=0.5
    BuildingDamageScaling=0.4
	MineDamageScaling=2.0
	
	BleedDamageFactor=0.01
	BleedCount=8
	
	KDamageImpulse=20000
	KDeathUpKick=100

	IconTextureName="T_WeaponIcon_PersonalIonCannon"
	IconTexture=Texture2D'RX_WP_PersonalIonCannon.UI.T_WeaponIcon_PersonalIonCannon'
}