class Rx_DmgType extends UTDamageType;

var float lightArmorDmgScaling;
var float BuildingDamageScaling;
var float AircraftDamageScaling;
var float MCTDamageScaling;
var float MineDamageScaling;

/**@Shahman: Deprecated. Please use IconTexture to load the DmgIcon*/
var string IconTextureName;

var Texture2D IconTexture;

static function float VehicleDamageScalingFor(Vehicle V)
{
	//Light Armor
    if ( (Rx_Vehicle(V) != None) && Rx_Vehicle(V).hasLightArmor() )
        return default.lightArmorDmgScaling;

	//Aircraft Specific. If there is no special scaling for this weapon (A value of 0 or below), just use the light armor stat
	if ( (Rx_Vehicle(V) != None) && Rx_Vehicle(V).hasAircraftArmor() )
	{
     
		if(default.AircraftDamageScaling > 0) return default.AircraftDamageScaling;
		else
		return default.lightArmorDmgScaling; 
		
	}
	
    return Default.VehicleDamageScaling;
}

static function float BuildingDamageScalingFor()
{
	return Default.BuildingDamageScaling;
}

static function float AircraftDamageScalingFor() //Added Exception for Aircraft so certain weapons could be adjusted without making them better/worse vs. all light vehicles. -Yosh 
{
	return Default.AircraftDamageScaling;
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
	AircraftDamageScaling=-1.0 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
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