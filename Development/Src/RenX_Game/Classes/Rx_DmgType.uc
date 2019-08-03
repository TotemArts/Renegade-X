class Rx_DmgType extends UTDamageType;

var float lightArmorDmgScaling;
var float BuildingDamageScaling;
var float AircraftDamageScaling;
var float MCTDamageScaling;
var float MineDamageScaling;
var float Inf_FLAKDamageScaling;
var float Inf_KevlarDamageScaling;
var float Inf_LazarusDamageScaling;
var float Inf_NoArmourDamageScaling;

/**@Shahman: Deprecated. Please use IconTexture to load the DmgIcon*/
var string IconTextureName;

var Texture2D IconTexture;

var bool bUnsourcedDamage;

static function float VehicleDamageScalingFor(Vehicle V)
{
	//Light Armor
    if ( (Rx_Vehicle(V) != None) && Rx_Vehicle(V).hasLightArmor() )
        return default.lightArmorDmgScaling;

	//Aircraft Specific. If there is no special scaling for this weapon (A value of 0 or below), just use the light armor stat
	if ( (Rx_Vehicle(V) != None) && Rx_Vehicle(V).hasAircraftArmor() )
	{
     
		if(default.AircraftDamageScaling > 0) 
			return default.AircraftDamageScaling;
		else
			return default.lightArmorDmgScaling; 
		
	}
	
    return Default.VehicleDamageScaling;
}

//Never had a function to call this directly
static function float LightVehicleDamageScalingFor()
{
        return default.lightArmorDmgScaling;
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

/////////Infantry Armor/////////
static function float KevlarDamageScalingFor() //Damage mod for infantry with kevlar armor -Yosh 
{
	return Default.Inf_KevlarDamageScaling;
}

static function float FLAKDamageScalingFor() //Damage mod for infantry with FLAK armor -Yosh  
{
	return Default.Inf_FLAKDamageScaling;
}

static function float LazarusDamageScalingFor() ////Damage mod for infantry with Lazarus armor (the SBH) -Yosh  
{
	return Default.Inf_LazarusDamageScaling;
}

static function float NoArmourDamageScalingFor() ////Damage mod for infantry with no armor [Just necessary for weapons that get their overall infantry damage reduced] -Yosh  
{
	return Default.Inf_NoArmourDamageScaling;
}

static function bool IsUnsourcedDamage() ////HANDEPSILON - Whether to flare the entire indicator or not
{	
	return Default.bUnsourcedDamage;
}

defaultproperties
{
	MCTDamageScaling=2.0 // stacks with BuildingDamageScaling
	MineDamageScaling=0.5
	BuildingDamageScaling=1.0
    lightArmorDmgScaling=1.0
    VehicleDamageScaling=1.0
	AircraftDamageScaling=-1.0 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 1.0     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 1.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 1.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	Inf_NoArmourDamageScaling = 1.0 //Damage modifier for no armour
	
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