class Rx_DmgType_Orca_Missile extends Rx_DmgType_Explosive;

defaultproperties
{
    KillStatsName=KILLS_ORCAMISSILE
    DeathStatsName=DEATHS_ORCAMISSILE
    SuicideStatsName=SUICIDES_ORCAMISSILE

    DamageWeaponFireMode=2
    VehicleDamageScaling=1.0
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025
    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=1.0
    BuildingDamageScaling=1.75
	MCTDamageScaling=3.0
	MineDamageScaling=2.0
	
    AlwaysGibDamageThreshold=99
	bNeverGibs=false
	
	KDamageImpulse=20000
	KDeathUpKick=500
	
	IconTextureName="T_DeathIcon_Orca"
	IconTexture=Texture2D'RX_VH_Orca.UI.T_DeathIcon_Orca'
}