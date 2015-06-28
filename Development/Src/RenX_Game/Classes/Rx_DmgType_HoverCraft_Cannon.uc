class Rx_DmgType_HoverCraft_Cannon extends Rx_DmgType_Shell;

defaultproperties
{
    KillStatsName=KILLS_HOVERCRAFT
    DeathStatsName=DEATHS_HOVERCRAFT
    SuicideStatsName=SUICIDES_HOVERCRAFT

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.76
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.025
    bBulletHit=True

    CustomTauntIndex=10
    lightArmorDmgScaling=0.76
    BuildingDamageScaling=1.52
	MineDamageScaling=2.0
	
    AlwaysGibDamageThreshold=30
	bNeverGibs=false
	
	KDamageImpulse=15000
	KDeathUpKick=300

	IconTextureName="T_DeathIcon_HoverCraft"
	IconTexture=Texture2D'RX_VH_HoverCraft.UI.T_DeathIcon_HoverCraft'
}