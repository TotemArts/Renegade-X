class Rx_Building_Refinery_Internals extends Rx_Building_Team_Internals;

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{
	local Rx_Vehicle_Harvester harv;
	local bool bRefDestroyed;
	
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if(GetHealth() <= 0) 
	{
		bRefDestroyed = Rx_Game(WorldInfo.Game).AreTeamRefineriesDestroyed(GetTeamNum());

		ForEach DynamicActors(class'Rx_Vehicle_Harvester',harv)
		{
			if ( harv != None && harv.GetTeamNum() == GetTeamNum())
			{
				if(bRefDestroyed || (Rx_Building_Refinery(BuildingVisuals) != None && Rx_Building_Refinery(BuildingVisuals).DockedHarvester == harv.Controller))
				{
					harv.TakeDamage(10000,None,vect(0,0,0),vect(0,0,0),class'Rx_DmgType');
				}
				else
				{
					Rx_Game(WorldInfo.Game).ReassignHarvester(Harv);
				}
			}
		}
		if(bRefDestroyed)
		{
			if(GetTeamNum() == TEAM_GDI) 
				Rx_Game(WorldInfo.Game).GetVehicleManager().SetGDIRefDestroyed(true);
			else 
				Rx_Game(WorldInfo.Game).GetVehicleManager().SetNodRefDestroyed(true);
		}
	}
}

DefaultProperties
{
	AttachmentClasses.Add(Rx_BuildingAttachment_RefGarageDoor)
	AttachmentClasses.Add(Rx_BuildingAttachment_RefDockingStation)
}
