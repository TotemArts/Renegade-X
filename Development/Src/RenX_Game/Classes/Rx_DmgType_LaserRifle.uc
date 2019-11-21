class Rx_DmgType_LaserRifle extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_LASERRIFLE
    DeathStatsName=DEATHS_LASERRIFLE
    SuicideStatsName=SUICIDES_LASERRIFLE
//0.6
//    DamageWeaponClass=class'Rx_Weapon_LaserRifle'
    DamageWeaponFireMode=2
    VehicleDamageScaling=0.168 //0.1848
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

    CustomTauntIndex=10
    lightArmorDmgScaling=0.2496 //0.27456
	AircraftDamageScaling=0.242 //0.2662 //Ummm, Laser Rifle is OP as crap already vs. light vehicles. Seriously, how does Nod EVER lose the field when the SBH is this powerful?? Ignorant SBHs... that's how.
    BuildingDamageScaling=0.1824 //0.20064
	MCTDamageScaling=3.0
	MineDamageScaling=2.0
	
	BleedDamageFactor=0.1
	BleedCount=5

	IconTextureName="T_WeaponIcon_LaserRifle"
	IconTexture=Texture2D'RX_WP_LaserRifle.UI.T_WeaponIcon_LaserRifle'
	bUnsourcedDamage=false
}