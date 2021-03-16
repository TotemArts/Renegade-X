class S_Building_GDI_VehicleFactory extends Rx_Building_GDI_VehicleFactory;

simulated function PostBeginPlay()
{
    local Vector loc;
    local Rotator rot;	
	super.PostBeginPlay();
	if(WorldInfo.Netmode != NM_Client) {
		BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_Dropoff', loc, rot);
		`log("VEH SPAWN IS AT"@loc@rot);
		S_VehicleManager(S_Game(WorldInfo.Game).GetVehicleManager()).Set_GDI_ProductionPlace(loc, rot);
	}
}