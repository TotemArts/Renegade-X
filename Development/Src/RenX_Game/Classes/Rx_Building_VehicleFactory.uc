class Rx_Building_VehicleFactory extends Rx_Building
	implements(RxIfc_FactoryVehicle)
	abstract;

var bool bSpawnsC130;
var name VehicleSpawnSocket;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(WorldInfo.Netmode != NM_Client) 
	{
		SetupVehicleManagerSpawnPoint();
	}
}

function SetupVehicleManagerSpawnPoint()
{
    local Vector loc;
    local Rotator rot;

	BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, loc, rot);
	Rx_Game(WorldInfo.Game).GetVehicleManager().Set_NOD_ProductionPlace(loc, rot);
}

function bool SpawnsC130()
{
	return bSpawnsC130;
}

function GetVehicleSpawnPoint(out Vector Loc, out Rotator Rot)
{
	BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation(VehicleSpawnSocket,Loc,Rot);
}

simulated function bool CanProduceThisVehicle(class<Rx_Vehicle> Veh)
{
	return true;
}

DefaultProperties
{
	bSpawnsC130 = false
	myBuildingType=BT_Veh

	VehicleSpawnSocket = Veh_Spawn

	SupportedEvents.Add(class'Rx_SeqEvent_FactoryEvent')

	IconTexture=Texture2D'RenxHud.T_BuildingIcon_Vehicle_Normal'

}
