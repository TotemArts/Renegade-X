class Rx_DmgType_TiberiumAutoRifle_Blue extends Rx_DmgType_Tiberium_Blue;

defaultproperties
{
    KillStatsName=KILLS_TiberiumAutoRifle
    DeathStatsName=DEATHS_TiberiumAutoRifle
    SuicideStatsName=SUICIDES_TiberiumAutoRifle

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.45
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling= 0.45 //0.4
	AircraftDamageScaling= 0.7 //0.6 //Low flying aircraft be damned. 
    BuildingDamageScaling= 0.5 //0.4
	MCTDamageScaling= 3.0 //2.5 
	MineDamageScaling=1.0
	
	
    bPiercesArmor=false
	
	BleedDamageFactor=0.1
	BleedCount=5

	IconTextureName="T_WeaponIcon_TiberiumAutoRifle"
	IconTexture=Texture2D'RX_WP_TiberiumAutoRifle.UI.T_WeaponIcon_TiberiumAutoRifle'
	bUnsourcedDamage=false
}