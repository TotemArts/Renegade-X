class Rx_DmgType_TiberiumFlechetteRifle extends Rx_DmgType_Tiberium;

defaultproperties
{
    KillStatsName=KILLS_TiberiumFlechetteRifle
    DeathStatsName=DEATHS_TiberiumFlechetteRifle
    SuicideStatsName=SUICIDES_TiberiumFlechetteRifle

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.1
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.2
    BuildingDamageScaling=0.1
	MCTDamageScaling=5.0
    
    bPiercesArmor=false
	
	BleedDamageFactor=0.25
	BleedCount=5
	
	KDamageImpulse=100
	KDeathUpKick=50
	
	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=2.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0

	IconTextureName="RenXHud_I112"
	IconTexture=Texture2D'RX_WP_TiberiumFlechetteRifle.UI.T_WeaponIcon_TiberiumFlechetteRifle'
	
}