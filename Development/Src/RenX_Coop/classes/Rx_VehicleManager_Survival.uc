class Rx_VehicleManager_Survival extends Rx_VehicleManager_Coop;

function bool QueueVehicle(class<Rx_Vehicle> inVehicleClass, Rx_PRI Buyer, int VehicleID)
{
	if(VehicleSpawnerManagers.Length > 0)
		return Super.QueueVehicle(inVehicleClass, Buyer, VehicleID);

	return Super(Rx_VehicleManager).QueueVehicle(inVehicleClass, Buyer, VehicleID);
}

function bool IsAllowedToQueueUpAnotherVehicle(Rx_PRI Buyer)
{
	if(VehicleSpawnerManagers.Length > 0)
		return super.IsAllowedToQueueUpAnotherVehicle(Buyer);

	return Super(Rx_VehicleManager).IsAllowedToQueueUpAnotherVehicle(Buyer);
}