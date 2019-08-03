/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_HumveeDrop extends Rx_CommanderSupport_BeaconInfo; 

DefaultProperties
{
SpawnedVehicle(0) = class'Rx_SupportVehicle_DropoffChinook'
SupportPayload = class'Rx_Vehicle_Humvee'
SupportSpawnLocation = (X=0, Y=0, Z=100)

AbilityCallTime 	= 5
LingerTime			= 15
bPlayWarningSiren 	= false
bBroadcastToEnemy 	= false

PowerName			= "Humvee Drop"
CPCost				= 1000
}