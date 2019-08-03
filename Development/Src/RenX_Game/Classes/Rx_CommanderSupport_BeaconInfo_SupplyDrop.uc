/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_SupplyDrop extends Rx_CommanderSupport_BeaconInfo; 

DefaultProperties
{
SpawnedVehicle(0) = class'Rx_SupportVehicle_DropoffChinook'
SupportPayload = class'Rx_CommanderSupport_SupplyPallet'
SupportSpawnLocation = (X=0, Y=0, Z=20000)

EntryAngleLengthRequirment 	= 6200 //For the A10, this is roughly the distance of the waypoint where it actually drops its payloads. 
EntryAngleRotation 			= (Pitch=16384, Roll=0, Yaw=32768) //Most support powers come from behind their rotation -- A10 drops at roughly 68 degrees 
EntryAngleStartLocation 	= (X=0, Y=0, Z=+100) //Don't just let small obstructions stand in the way

AbilityCallTime 	= 5
LingerTime			= 15
bPlayWarningSiren 	= false
bBroadcastToEnemy 	= false

PowerName			= "SUPPLY CRATE"
CPCost				= 300
}