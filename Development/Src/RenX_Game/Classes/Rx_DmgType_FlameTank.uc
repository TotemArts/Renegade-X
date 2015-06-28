class Rx_DmgType_FlameTank extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_FLAMETHROWER
    DeathStatsName=DEATHS_FLAMETHROWER
    SuicideStatsName=SUICIDES_FLAMETHROWER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.7893
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    KDamageImpulse=200
    CustomTauntIndex=10
    lightArmorDmgScaling=0.9285
    BuildingDamageScaling=0.8357
	MineDamageScaling=2.0
	
	DamageBodyMatColor=(R=50,G=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	bUseTearOffMomentum=false
	
	BleedDamageFactor=0.2
	BleedCount=8

	IconTextureName="T_DeathIcon_FlameTank"
	IconTexture=Texture2D'RX_VH_FlameTank.UI.T_DeathIcon_FlameTank'
}