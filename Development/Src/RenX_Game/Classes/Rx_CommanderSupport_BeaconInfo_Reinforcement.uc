class Rx_CommanderSupport_BeaconInfo_Reinforcement extends Rx_CommanderSupport_BeaconInfo;

DefaultProperties
{
	SpawnedVehicle(0) = class'Rx_SupportVehicle_ReinforcementChinook'
	SupportPayload = class'Rx_CommanderSupport_ReinforcementContainer'
	SupportSpawnLocation = (X=0, Y=0, Z=100)

	AbilityCallTime 	= 5
	LingerTime			= 15
	bPlayWarningSiren 	= false
	bBroadcastToEnemy 	= false

	PowerName			= "Reinforcement Support"
	CPCost				= 800
}