class Rx_DmgType_CruiseMissile extends Rx_DmgType_Explosive;

defaultproperties
{
	MCTDamageScaling=4.0 // You know what? Go for it... try to hit the MCT with a cruise missile
	MineDamageScaling=0.5
	BuildingDamageScaling=0.6 //0.5 //0.30 Removed the ability to kill through buildings, upped building damage 
    lightArmorDmgScaling=0.8 //0.40 //0.35
    VehicleDamageScaling=0.8 //0.40 //0.35
	AircraftDamageScaling=1.0 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.0     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	Inf_NoArmourDamageScaling = 1.0 //Damage modifier for no armour
	
    GibPerterbation=0.15
    AlwaysGibDamageThreshold=50.0
    bNeverGibs=false
	bThrowRagdoll=true
    bBulletHit=false
    bCausesBloodSplatterDecals=true
    bCausesBlood=true
	GibTrail=ParticleSystem'RX_CH_Gibs.Effects.P_BloodTrail'
	
	KDamageImpulse=3000
	KDeathUpKick=200

	IconTexture=Texture2D'RenX_AssetBase.DeathIcons.T_DeathIcon_CruiseMissile'
} 