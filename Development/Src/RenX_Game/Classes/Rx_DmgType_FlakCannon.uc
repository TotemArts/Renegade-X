class Rx_DmgType_FlakCannon extends Rx_DmgType_Burn;

defaultproperties
{
    KillStatsName=KILLS_FLAKCANNON
    DeathStatsName=DEATHS_FLAKCANNON
    SuicideStatsName=SUICIDES_FLAKCANNON

    DamageWeaponFireMode=2
    VehicleDamageScaling=0.42
    NodeDamageScaling=0.5
    VehicleMomentumScaling=0.5

    CustomTauntIndex=10
    lightArmorDmgScaling=0.42
    BuildingDamageScaling=0.42
	MCTDamageScaling=3.5 //22 Damage
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 0.7   //FLAK infantry armour (Standard rule is explosive weapons does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties)
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
	
	MineDamageScaling=2.0
	
    AlwaysGibDamageThreshold=98
	bNeverGibs=true
	
	BleedDamageFactor=0.1
	BleedCount=4

	IconTextureName="T_WeaponIcon_FlakCannon"
	IconTexture=Texture2D'RX_WP_FlakCannon.UI.T_WeaponIcon_FlakCannon'
}