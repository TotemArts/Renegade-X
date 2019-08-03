/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo extends Object; 

var array< class<Rx_SupportVehicle> > 	SpawnedVehicle; //Usually a Chinook or something
var class<Actor>				SupportPayload; //What will the support vehicle be carrying
var vector						SupportSpawnLocation; //Relative to the beacon itself 
var bool						bAffectArea;
var int							AOE_Radius;

var float 						AbilityCallTime; //Time till ability is actually brought to the map. [Seconds]
var float						LingerTime; 	//Time to hang around after calling the ability	
var bool 						bPlayWarningSiren, bBroadcastToEnemy, bBroadcastToTeam ; //Self explanatory
var string 						PowerName; //Name of this ability
var int							CPCost;

var int							VerticalClearanceNeeded; //Vertical Clearance needed to place this beacon


/**In relation to where the beacon is being placed, should we start an 'acceptable angle' trace from right on the location, or modify it slightly*/
var vector						EntryAngleStartLocation; 
var rotator						EntryAngleRotation; //Entry angle's relative rotation to the entry point 
var int							EntryAngleLengthRequirment; //How far do we need to trace to find where the actual entry angle is ? 

var SoundCue					FireSoundCue;				//Usually only used for AOE beacon effects					
var int							MaxCastRange;
var ParticleSystem				Emitter_BeaconTemplate;

static function bool IsEntryVectorClear(vector BeaconVector, rotator BeaconRotation, Actor TraceActor)
{

	local vector	EntryVector, StartVector;

	StartVector = BeaconVector+default.EntryAngleStartLocation;

	EntryVector = StartVector + vector(BeaconRotation+default.EntryAngleRotation) * default.EntryAngleLengthRequirment ;

	return (TraceActor.FastTrace(StartVector, EntryVector));  

}

static function vector GetEntryVector(vector StartVector, rotator StartRotation)
{
	local vector	EntryVector;

	StartVector = StartVector+default.EntryAngleStartLocation;

	EntryVector = StartVector + vector(StartRotation+default.EntryAngleRotation) * default.EntryAngleLengthRequirment ;	

	return EntryVector; 
}

static function class<Rx_SupportVehicle> GetSupportVehicleClass(byte TeamIndex)
{
	if(default.SpawnedVehicle.Length > 1 && !(TeamIndex >= default.SpawnedVehicle.Length) ) 
	{
		return default.SpawnedVehicle[TeamIndex]; 
	}
	else
	if(default.SpawnedVehicle.Length == 1) return default.SpawnedVehicle[0]; 
}

//Do some beacon specific area affect
static function DoAreaEffect(Actor CallingActor, vector L, byte T)
{
	if(default.FireSoundCue != none) CallingActor.PlaySound(default.FireSoundCue); 
}

static function bool bCanFire(Rx_Controller C, optional bool bPlayFailMessage = true){
	return true; 
}

DefaultProperties
{
	SpawnedVehicle(0) = class'Rx_SupportVehicle_DropoffChinook'

	SupportPayload = class 'Rx_Vehicle_Humvee'
	SupportSpawnLocation = (X=0, Y=0, Z=100)

	bAffectArea = false

	VerticalClearanceNeeded = 99999

	EntryAngleLengthRequirment 	= 0 
	EntryAngleRotation 			= (Pitch=0, Roll=0, Yaw=32768) //Most support powers come from behind their rotation
	EntryAngleStartLocation 	= (X=0, Y=0, Z=0)

	MaxCastRange		= 99999
	AbilityCallTime 	= 5
	LingerTime			= 5

	bPlayWarningSiren 	= false
	bBroadcastToEnemy 	= false
	bBroadcastToTeam	= true

	PowerName			= "Support Power"

	AOE_Radius = 1500 //Never 0 
}