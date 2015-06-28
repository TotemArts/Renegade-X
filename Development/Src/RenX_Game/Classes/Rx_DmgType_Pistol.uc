class Rx_DmgType_Pistol extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_PISTOL
    DeathStatsName=DEATHS_PISTOL
    SuicideStatsName=SUICIDES_PISTOL

//    DamageWeaponClass=class'Rx_Weapon_Pistol'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.016f
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.16
    BuildingDamageScaling=0.002
	
	KDamageImpulse=1000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_Pistol"
	IconTexture=Texture2D'RX_WP_Pistol.UI.T_WeaponIcon_Pistol'
}