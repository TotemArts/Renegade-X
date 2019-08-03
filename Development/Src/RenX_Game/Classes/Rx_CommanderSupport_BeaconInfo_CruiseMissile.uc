/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_CruiseMissile extends Rx_CommanderSupport_BeaconInfo; 

static function bool bCanFire(Rx_Controller C, optional bool bPlayFailMessage = true){

		local Rx_SupportVehicle_CruiseMissile CM;
		
		foreach C.WorldInfo.AllActors(class'Rx_SupportVehicle_CruiseMissile', CM)
		{
			if(CM.GetTeamNum() != C.GetTeamNum())
				continue;
			
			if(bPlayFailMessage)
				C.CTextMessage("Cruise Missile Already In Flight"); 
			return false; 
		}
		
		return true; 
}

DefaultProperties
{
	SpawnedVehicle(0) = class'Rx_SupportVehicle_CruiseMissile'
	SupportPayload = none
	SupportSpawnLocation = (X=0, Y=0, Z=10000)

	EntryAngleLengthRequirment 	= 6200 //For the A10, this is roughly the distance of the waypoint where it actually drops its payloads. 
	EntryAngleRotation 			= (Pitch=7000, Roll=0, Yaw=32768) //Most support powers come from behind their rotation -- A10 drops at roughly 68 degrees 
	EntryAngleStartLocation 	= (X=0, Y=0, Z=+500) //Don't just let small obstructions stand in the way


	AbilityCallTime 	= 1
	LingerTime			= 3 //15
	bPlayWarningSiren 	= true
	bBroadcastToEnemy 	= true

	PowerName			= "CRUISE MISSILE"
	CPCost				= 800 //1000 //1200
}