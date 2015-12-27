class Rx_DmgType_RamjetRifle extends Rx_DmgType;

defaultproperties
{
    KillStatsName=KILLS_RAMJETRIFLE
    DeathStatsName=DEATHS_RAMJETRIFLE
    SuicideStatsName=SUICIDES_RAMJETRIFLE

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.055			// 10hp
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=0.30 //0.25			// 45hp				0.33			// 60hp
    BuildingDamageScaling=0.009
	MCTDamageScaling=100.0
	MineDamageScaling=2.0
	
	KDamageImpulse=20000
	KDeathUpKick=100

	IconTextureName="T_WeaponIcon_Ramjet"
	IconTexture=Texture2D'RX_WP_Ramjet.UI.T_WeaponIcon_Ramjet'
}