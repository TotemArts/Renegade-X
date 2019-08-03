/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_RadarScan extends Rx_CommanderSupport_BeaconInfo; 



//Do some beacon specific area affect
static function DoAreaEffect(Actor CallingActor, vector L, byte T)
{
	local Pawn TargetActor;
	//local Pawn P; 
	
	super.DoAreaEffect(CallingActor, L,T);
	
	foreach CallingActor.CollidingActors(class'Pawn',TargetActor, default.AOE_Radius, CallingActor.location)
	{
		if(Rx_PRI(TargetActor.PlayerReplicationInfo) == none && Rx_DefencePri(TargetActor.PlayerReplicationInfo) == none) continue; 
		
		if(TargetActor.GetTeamNum() != 0) 
		{
			if(Rx_Vehicle(TargetActor) != none) Rx_Vehicle(TargetActor).SetSpotted(60.0); 
			else
			if(Rx_Pawn(TargetActor) != none && Rx_Pawn(TargetActor).PlayerReplicationInfo != none ) Rx_PRI(Rx_Pawn(TargetActor).PlayerReplicationInfo).SetSpotted(60.0); 
			
			 SetPlayerCommandSpotted(TargetActor.PlayerReplicationInfo.playerID, CallingActor); //Rx_Vehicle(TargetActor).SetSpotted(60.0); 
			
		}
	}
}

static function SetPlayerCommandSpotted(int playerID, Actor CallingActor) //Use Defence_ID for RX_Defences, since they don't have player IDs
{
	local int i;

	//loginternal("server Command spotted"$playerID);
	
	for (i = 0; i < CallingActor.WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(Rx_Pri(CallingActor.WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (CallingActor.WorldInfo.GRI.PRIArray[i].PlayerID == playerID)
			{
				Rx_Pri(CallingActor.WorldInfo.GRI.PRIArray[i]).SetAsTarget(1);
				return;
			}
		}
		else
		if(Rx_DefencePri(CallingActor.WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (Rx_DefencePri(CallingActor.WorldInfo.GRI.PRIArray[i]).Defence_ID == playerID)
			{
				Rx_DefencePri(CallingActor.WorldInfo.GRI.PRIArray[i]).SetAsTarget(1);
				return;
			}
		}
		else
		continue; 
	}
}

static function bool IsEntryVectorClear(vector BeaconVector, rotator BeaconRotation, Actor TraceActor)
{

	return true; 

}

DefaultProperties
{
SpawnedVehicle(0) = none

SupportPayload = none
SupportSpawnLocation = (X=0, Y=0, Z=0)

bAffectArea = true
AOE_Radius = 3500 //5000
FireSoundCue = SoundCue'RX_SoundEffects.SFX.S_RadarBuzz_Cue'

VerticalClearanceNeeded = 0

EntryAngleLengthRequirment 	= 0 
EntryAngleRotation 			= (Pitch=0, Roll=0, Yaw=32768) //Most support powers come from behind their rotation
EntryAngleStartLocation 	= (X=0, Y=0, Z=0)

AbilityCallTime 	= 2.0
LingerTime			= 0.5
bPlayWarningSiren 	= false
bBroadcastToEnemy 	= true

PowerName			= "RADAR SCAN"
CPCost				= 100 //200
}