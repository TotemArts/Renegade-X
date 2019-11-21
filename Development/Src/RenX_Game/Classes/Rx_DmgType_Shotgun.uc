class Rx_DmgType_Shotgun extends Rx_DmgType_Bullet;

defaultproperties
{
    KillStatsName=KILLS_SHOTGUN
    DeathStatsName=DEATHS_SHOTGUN
    SuicideStatsName=SUICIDES_SHOTGUN

//    DamageWeaponClass=class'Rx_Weapon_Shotgun'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.01f
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025

    CustomTauntIndex=10
    lightArmorDmgScaling=0.1333333
    BuildingDamageScaling=0.0013333333
	MCTDamageScaling=150.0
	MineDamageScaling=1.0

	
	KDamageImpulse=6000
	KDeathUpKick=200

	IconTextureName="T_WeaponIcon_Shotgun"
	IconTexture=Texture2D'RX_WP_Shotgun.UI.T_WeaponIcon_Shotgun'
}