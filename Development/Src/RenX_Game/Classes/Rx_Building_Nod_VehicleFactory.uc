class Rx_Building_Nod_VehicleFactory extends Rx_Building_VehicleFactory
	abstract;

simulated function PostBeginPlay()
{
    local Vector loc;
    local Rotator rot;	
	super.PostBeginPlay();
	if(WorldInfo.Netmode != NM_Client) {
		BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_DropOff', loc, rot);
		Rx_Game(WorldInfo.Game).GetVehicleManager().Set_NOD_ProductionPlace(loc, rot);
	}
}

DefaultProperties
{
	TeamID = TEAM_NOD
}
