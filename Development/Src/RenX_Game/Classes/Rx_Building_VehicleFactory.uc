class Rx_Building_VehicleFactory extends Rx_Building
	abstract;

var bool SpawnsC130;
var name VehicleSpawnSocket;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(WorldInfo.Netmode != NM_Client) 
	{
		GetVehicleSpawnPoint();
	}
}

function GetVehicleSpawnPoint()
{
    local Vector loc;
    local Rotator rot;

	BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, loc, rot);
	Rx_Game(WorldInfo.Game).GetVehicleManager().Set_NOD_ProductionPlace(loc, rot);
}

DefaultProperties
{
	SpawnsC130 = false
	myBuildingType=BT_Veh

	VehicleSpawnSocket = Veh_Spawn

	SupportedEvents.Add(class'Rx_SeqEvent_FactoryEvent')

	IconTexture=Texture2D'RenxHud.T_BuildingIcon_Vehicle_Normal'

}
