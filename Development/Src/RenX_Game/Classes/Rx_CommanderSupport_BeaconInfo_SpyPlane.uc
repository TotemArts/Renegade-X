/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_SpyPlane extends Rx_CommanderSupport_BeaconInfo; 

DefaultProperties
{
	//Should be Nod only
	SpawnedVehicle(0) = class'Rx_SupportVehicle_A10'
	SpawnedVehicle(1) = class'Rx_SupportVehicle_MIG35_SpyPlane' 

	SupportPayload = class'Rx_CommanderSupport_SpyCamera'
	SupportSpawnLocation = (X=0, Y=0, Z=10000)

	VerticalClearanceNeeded = 8000

	EntryAngleLengthRequirment 	= 6200 //For the A10, this is roughly the distance of the waypoint where it actually drops its payloads. 
	EntryAngleRotation 			= (Pitch=10000, Roll=0, Yaw=32768) //Most support powers come from behind their rotation -- A10 drops at roughly 68 degrees 
	EntryAngleStartLocation 	= (X=0, Y=0, Z=+500) //Don't just let small obstructions stand in the way

	AbilityCallTime 	= 1.0
	LingerTime			= 2.0
	bPlayWarningSiren 	= false
	bBroadcastToEnemy 	= true

	PowerName			= "Scout Plane"
	CPCost				= 150 //200
}