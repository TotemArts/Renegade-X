class Rx_DmgType_Apache_Gun extends Rx_DmgType; //Explodes... but also is supposed to be good vs. infantry, so 1.0 across the board.

defaultproperties
{
    KillStatsName=KILLS_APACHEGUN
    DeathStatsName=DEATHS_APACHEGUN
    SuicideStatsName=SUICIDES_APACHEGUN

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.185
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

	bBulletHit=True

	
	
    CustomTauntIndex=10
    lightArmorDmgScaling=0.185
    BuildingDamageScaling=0.185
	MCTDamageScaling=0.75
	MineDamageScaling=1.0
	
    AlwaysGibDamageThreshold=19
	bNeverGibs=false
	
	KDamageImpulse=8000
	KDeathUpKick=200

	IconTextureName="T_DeathIcon_Apache"
	IconTexture=Texture2D'RX_VH_Apache.UI.T_DeathIcon_Apache'
}