class Rx_VehicleSpawner extends Actor
	ClassGroup(Cooperative)	
	placeable;

var Rx_VehicleSpawnerManager Manager;
var bool bReadyToSpawn;
var(Spawner) float CooldownAfterSpawn;


function ProcessQueue()
{
	SetTimer(3.0, false, 'SpawnVehicle');
	bReadyToSpawn = false;
}

function SpawnVehicle()
{
	Manager.SpawnVehicleAtSpawnPoint(Self);
	SetTimer(CooldownAfterSpawn, false, 'SetToReady');
}

function SetToReady()
{
	bReadyToSpawn = true;
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	bHidden = true

	bReadyToSpawn = true



}