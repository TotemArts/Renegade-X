class Rx_DmgType_LaserChainGun extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_LASERCHAINGUN
    DeathStatsName=DEATHS_LASERCHAINGUN
    SuicideStatsName=SUICIDES_LASERCHAINGUN

//    DamageWeaponClass=class'Rx_Weapon_LaserRifle'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.1875
	
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.1875
	AircraftDamageScaling=0.3 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour. Can just barely 1-clip an Orca if you land everything
    BuildingDamageScaling=0.25
	MCTDamageScaling=2.5
	
	MineDamageScaling=2.0
	
	BleedDamageFactor=0.2
	BleedCount=5

	IconTextureName="T_WeaponIcon_LaserChainGun"
	IconTexture=Texture2D'RX_WP_LaserChaingun.UI.T_WeaponIcon_LaserChainGun'
}