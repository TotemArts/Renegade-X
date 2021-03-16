/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_SmokeDrop extends Rx_CommanderSupport_BeaconInfo; //I mean... it 'was' a missile, but you get the point 

var const int MaxSupportVehicles;

static function bool bCanFire(Rx_Controller C, optional bool bPlayFailMessage = true){

		local Rx_CommanderSupport_SmokeBomb SV;
		local int SVCount;
		
		foreach C.WorldInfo.AllActors(class'Rx_CommanderSupport_SmokeBomb', SV)
		{
			if (SV.GetTeamNum() != C.GetTeamNum())
				continue;

			SVCount++;
		}

		if (SVCount >= default.MaxSupportVehicles)
		{
			if (bPlayFailMessage)
				C.CTextMessage("Concurrent Smoke Airstrike Limit Reached"); 
			return false; 
		}
		
		return true; 
}

DefaultProperties
{
	SpawnedVehicle(0) = class'Rx_SupportVehicle_A10'
	SpawnedVehicle(1) = class'Rx_SupportVehicle_MIG35'

	SupportPayload = class'Rx_CommanderSupport_SmokeBomb'
	SupportSpawnLocation = (X=0, Y=0, Z=10000)

	VerticalClearanceNeeded = 8000

	MaxSupportVehicles = 3

	EntryAngleLengthRequirment 	= 6200 //For the A10, this is roughly the distance of the waypoint where it actually drops its payloads. 
	EntryAngleRotation 			= (Pitch=10000, Roll=0, Yaw=32768) //Most support powers come from behind their rotation -- A10 drops at roughly 68 degrees 
	EntryAngleStartLocation 	= (X=0, Y=0, Z=+500) //Don't just let small obstructions stand in the way

	AbilityCallTime 	= 1
	LingerTime			= 3
	bPlayWarningSiren 	= false
	bBroadcastToEnemy 	= true

	PowerName			= "AIR-STRIKE [SMOKE]"
	CPCost				= 200 //300
}