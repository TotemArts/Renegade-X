class Rx_DmgType extends UTDamageType;

var float lightArmorDmgScaling;
var float BuildingDamageScaling;
var float MCTDamageScaling;
var float MineDamageScaling;

/**@Shahman: Deprecated. Please use IconTexture to load the DmgIcon*/
var string IconTextureName;

var Texture2D IconTexture;

static function float VehicleDamageScalingFor(Vehicle V)
{
    if ( (Rx_Vehicle(V) != None) && Rx_Vehicle(V).hasLightArmor() )
        return default.lightArmorDmgScaling;

    return Default.VehicleDamageScaling;
}

static function float BuildingDamageScalingFor()
{
	return Default.BuildingDamageScaling;
}

static function float MCTDamageScalingFor()
{
	return Default.MCTDamageScaling;
}

static function float MineDamageScalingFor()
{
	return Default.MineDamageScaling;
}

defaultproperties
{
	MCTDamageScaling=2.0 // stacks with BuildingDamageScaling
	MineDamageScaling=0.5
	BuildingDamageScaling=1.0
    lightArmorDmgScaling=1.0
    VehicleDamageScaling=1.0
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