class Rx_VehicleSpawner_Building extends Rx_VehicleSpawner;

var() float ProcessTime;
var() Name SocketName;
var() Rx_Building FactoryBuilding;
var() bool bSpawnC130;

function ProcessQueue()
{
	if(bSpawnC130)
	{
		if(ProcessTime <= 5.5)
			SpawnC130OnBuilding();
		else
			SetTimer(ProcessTime - 5.5, false, 'SpawnC130OnBuilding');
	}
	
	SetTimer(Max(ProcessTime, 5.5), false, 'SpawnVehicle');
	bReadyToSpawn = false;
}

function GetSpawnerLocAndRot(out Vector Loc, out Rotator Rot)
{
	FactoryBuilding.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation(SocketName,Loc,Rot);
}

function SpawnC130OnBuilding() 
{
	local vector loc;
	local rotator C130Rot;

	GetSpawnerLocAndRot(Loc,C130Rot);
	
	loc.z -= 100;
	C130Rot.yaw += 32768; 
	if ( Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset > 0 )
		loc.z += Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset;

	   		Spawn(class'Rx_C130',,,loc,C130Rot,,true);

}

DefaultProperties
{
	SocketName = Veh_Spawn
}