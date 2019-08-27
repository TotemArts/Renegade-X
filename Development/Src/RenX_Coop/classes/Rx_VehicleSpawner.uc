class Rx_VehicleSpawner extends Actor
	ClassGroup(Cooperative)	
	placeable;

var Rx_VehicleSpawnerManager Manager;
var bool bReadyToSpawn;
var(Display) SkeletalMeshComponent Mesh;

function ProcessQueue()
{
	SetTimer(3.0, false, 'SpawnVehicle');
}

function SpawnVehicle()
{
	Manager.SpawnVehicleAtSpawnPoint();
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=SVehicleMesh
		CollideActors=false
		AlwaysLoadOnClient=false
		AlwaysLoadOnServer=false
		bUpdateSkelWhenNotRendered=false
        LightEnvironment=MyLightEnvironment
		SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_VH_Mammoth'
		Translation=(X=-40.0,Y=0.0,Z=-70.0)
	End Object
	Components.Add(SVehicleMesh)
	Mesh = SVehicleMesh

	bHidden = true

	bReadyToSpawn = true

}