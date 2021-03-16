class Rx_Building_Refinery_Internals extends Rx_Building_Team_Internals;

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{
	local bool bRefDestroyed;
	
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if(GetHealth() <= 0) 
	{
		bRefDestroyed = Rx_Game(WorldInfo.Game).AreTeamRefineriesDestroyed(GetTeamNum());

		if(bRefDestroyed)
		{
			if(GetTeamNum() == TEAM_GDI) 
				Rx_Game(WorldInfo.Game).GetVehicleManager().SetGDIRefDestroyed(true);
			else 
				Rx_Game(WorldInfo.Game).GetVehicleManager().SetNodRefDestroyed(true);
		}
	}
}

function HarvesterAirdropTimer()
{
	RxIfc_Refinery(BuildingVisuals).RequestHarvester();
}

reliable server function RestoreMe(optional PlayerReplicationInfo Restorer)
{
	if (bDestroyed)
	{
		switch (GetTeamNum())
		{
			case TEAM_GDI:
				Rx_Game(WorldInfo.Game).GetVehicleManager().bGDIRefDestroyed = false;
			break;
	
			case TEAM_NOD:
				Rx_Game(WorldInfo.Game).GetVehicleManager().bNodRefDestroyed = false;
			break;
		}
	
		RxIfc_Refinery(BuildingVisuals).RequestHarvester();	
	}

	super.RestoreMe(Restorer);
}

DefaultProperties
{
	AttachmentClasses.Add(Rx_BuildingAttachment_RefGarageDoor)
	AttachmentClasses.Add(Rx_BuildingAttachment_RefDockingStation)
}
