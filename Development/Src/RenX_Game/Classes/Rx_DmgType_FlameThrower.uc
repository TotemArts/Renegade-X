class Rx_DmgType_FlameThrower extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_FLAMETHROWER
    DeathStatsName=DEATHS_FLAMETHROWER
    SuicideStatsName=SUICIDES_FLAMETHROWER

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.3		// 1.65 hp per shot
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.1

	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.9   //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.9	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 0.9  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	
    CustomTauntIndex=10
    lightArmorDmgScaling=0.3		// 2.64 hp per shot
    BuildingDamageScaling=0.4 //0.2	// 2.00 hp per shot
	MCTDamageScaling=3.0
	MineDamageScaling=2.0
	
	DamageBodyMatColor=(R=50,G=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	bUseTearOffMomentum=false
	
	BleedDamageFactor=0.2
	BleedCount=5
	
	KDamageImpulse=100
	KDeathUpKick=50
	
	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=0.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0

	IconTextureName="T_WeaponIcon_FlameThrower"
	IconTexture=Texture2D'RX_WP_FlameThrower.UI.T_WeaponIcon_FlameThrower'
}