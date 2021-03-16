class Rx_Building_VehicleFactory_Internals extends Rx_Building_Team_Internals
abstract;

reliable server function RestoreMe(optional PlayerReplicationInfo Restorer)
{
	if (bDestroyed)
	{
		switch (TeamID)
		{
			case TEAM_GDI:
				Rx_Game(WorldInfo.Game).GetVehicleManager().GDIAdditionalAirdropProductionDelay = 0;
				Rx_Game(WorldInfo.Game).GetVehicleManager().bGDIIsUsingAirdrops = false;
			break;

			case TEAM_NOD:
				Rx_Game(WorldInfo.Game).GetVehicleManager().NodAdditionalAirdropProductionDelay = 0;
				Rx_Game(WorldInfo.Game).GetVehicleManager().bNodIsUsingAirdrops = false;
			break;
		}
	}

	super.RestoreMe(Restorer);
}