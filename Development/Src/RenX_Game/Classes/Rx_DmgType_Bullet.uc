class Rx_DmgType_Bullet extends Rx_DmgType;

defaultproperties
{
	MCTDamageScaling=2.0 // stacks with BuildingDamageScaling
	MineDamageScaling=0.5
	BuildingDamageScaling=1.0
    lightArmorDmgScaling=1.0
    VehicleDamageScaling=1.0
	AircraftDamageScaling=-1.0 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.3     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 0.70	//Kevlar (General rule is 25% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	
    GibPerterbation=0.15
    AlwaysGibDamageThreshold=0
	RewardAnnouncementSwitch=0
    bNeverGibs=true 
	bThrowRagdoll=true
    bBulletHit=false
    bCausesBloodSplatterDecals=false
    bCausesBlood=true
	GibTrail=ParticleSystem'RX_CH_Gibs.Effects.P_BloodTrail'
	
	KDamageImpulse=3000
	KDeathUpKick=200

	IconTexture=Texture2D'RenX_AssetBase.DeathIcons.T_DeathIcon_GenericSkull'
} 