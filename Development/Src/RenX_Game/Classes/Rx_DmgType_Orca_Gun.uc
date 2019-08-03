class Rx_DmgType_Orca_Gun extends Rx_DmgType_Bullet;

defaultproperties
{
    KillStatsName=KILLS_ORCA
    DeathStatsName=DEATHS_ORCA
    SuicideStatsName=SUICIDES_ORCA

    // DamageWeaponClass=class'RenX_Game.Rx_Vehicle_Humvee_Weapon' // need to set this if we want to have weapon killicons
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.185
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1
    bBulletHit=True
    KDamageImpulse=200
    bCausesBloodSplatterDecals=false
    CustomTauntIndex=10
    lightArmorDmgScaling=0.185
    BuildingDamageScaling=0.185
	MCTDamageScaling=0.75
	MineDamageScaling=1.0
	

	IconTextureName="T_DeathIcon_Orca"
	IconTexture=Texture2D'RX_VH_Orca.UI.T_DeathIcon_Orca'
}