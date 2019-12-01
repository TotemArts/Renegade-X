class Rx_VehicleManager_Coop extends Rx_VehicleManager;

struct VQueueElementCoop
{
   var Rx_PRI Buyer;
   var class<Rx_Vehicle> VehClass;
   var int VehicleID;
   var Rx_VehicleSpawnerManager Manager;
};

var array<VQueueElementCoop>    GDI_QueueCoop, NOD_QueueCoop;

var Array<Rx_VehicleSpawnerManager> VehicleSpawnerManagers;

function bool QueueVehicle(class<Rx_Vehicle> inVehicleClass, Rx_PRI Buyer, int VehicleID)
{
	local VQueueElementCoop NewQueueElement;
	
	if(!IsAllowedToQueueUpAnotherVehicle(Buyer)) 
	{
		return false;
	}
	
	NewQueueElement.Buyer = Buyer;
	NewQueueElement.VehClass = inVehicleClass;
	NewQueueElement.VehicleID = VehicleID;
	NewQueueElement.Manager = GetNearestProductionCoop(Buyer, Buyer.GetTeamNum());
	
	if(Buyer.GetTeamNum() == TEAM_NOD) 
	{
		NOD_QueueCoop.AddItem(NewQueueElement);
		  
		NewQueueElement.Manager.InitializeSpawn(Self);

		if( !ClassIsChildOf(inVehicleClass, class'Rx_Vehicle_Harvester') )
		{
			Rx_TeamInfo(Teams[Buyer.GetTeamNum()]).IncreaseVehicleCount();
		}
		ConstructionWarn(0);
		
	} 
	else if(Buyer.GetTeamNum() == TEAM_GDI)
	{
		GDI_QueueCoop.AddItem(NewQueueElement);
  
		NewQueueElement.Manager.InitializeSpawn(Self);
 
		if( !ClassIsChildOf(inVehicleClass, class'Rx_Vehicle_Harvester') )
		{
			Rx_TeamInfo(Teams[Buyer.GetTeamNum()]).IncreaseVehicleCount();
		}		
		ConstructionWarn(1);		
	}
	
	
	return true;
}

function SpawnGDIVehicle(Rx_VehicleSpawner Spawner)
{
	local Actor Veh;
	
	if(GDI_QueueCoop.Length > 0)
	{
		Veh = SpawnVehicleCoop(GDI_QueueCoop[0], Spawner, TEAM_GDI);
		if(Veh != None) 
		{
			GDI_QueueCoop.Remove(0, 1);
			if (GDI_QueueCoop.Length > 0)
			{
				SetTimer(4.5f,false,'DelayedGDIConstructionWarn');
			}
		}
	}
}

function SpawnNodVehicle(Rx_VehicleSpawner Spawner)
{
	local Actor Veh;
	
	if(NOD_QueueCoop.Length > 0) 
	{
		Veh = SpawnVehicleCoop(NOD_QueueCoop[0], Spawner, TEAM_NOD);
		if(Veh != None) 
		{
			NOD_QueueCoop.Remove(0, 1);
			if (NOD_QueueCoop.Length > 0)
			{
				SetTimer(4.5f,false,'DelayedNodConstructionWarn');
			}
		}
	}
}

function bool IsAllowedToQueueUpAnotherVehicle(Rx_PRI Buyer)
{
	local int Count, I;
	
	if(Buyer.GetTeamNum() == TEAM_NOD) 
	{
		for (I = 0; I < NOD_QueueCoop.Length; I++)
		{
			if (NOD_QueueCoop[I].Buyer == Buyer) 
				Count++;
		}
	} 
	else if(Buyer.GetTeamNum() == TEAM_GDI) 
	{
		for (I = 0; I < GDI_QueueCoop.Length; I++)
		{
			if (GDI_QueueCoop[I].Buyer == Buyer) 
				Count++;
		}
	}
   
	return Count < Buyer.MyVehicleLimitInQueue && CheckVehicleLimit(Buyer.GetTeamNum());
}

function Rx_VehicleSpawnerManager GetNearestProductionCoop(Rx_PRI Buyer, optional byte TeamNum)
{
	local float BestDist,CurDist;
	local Rx_VehicleSpawnerManager BestFactory,CurFactory;
	local Vector PointLoc;

	if(Buyer == None) // Probably Harvy
	{
		if(TeamNum == TEAM_GDI)
			PointLoc = GDITibPoint.Location;
		else
			PointLoc = NodTibPoint.Location;
	}
	else
		PointLoc = Controller(Buyer.Owner).Pawn.Location;

	foreach VehicleSpawnerManagers(CurFactory)
	{
		if(!CurFactory.bEnabled || CurFactory.Team != TeamNum)
			continue;

		if(BestFactory == None)
		{
			BestDist = VSizeSq(PointLoc - CurFactory.location);
			BestFactory = CurFactory;
		}
		else
		{
			CurDist = VSizeSq(PointLoc - CurFactory.location);
			if(BestDist > CurDist)
			{
				BestDist = CurDist;
				BestFactory = CurFactory;
			}
		}
	}	

	if(BestFactory != None)
		return BestFactory;

	`warn(Self@"Failed to find a viable manager!");
		return None;

}

function Actor SpawnVehicleCoop(VQueueElementCoop VehToSpawn, Rx_VehicleSpawner Spawner, optional byte TeamNum = -1)
{

	local Rx_Vehicle Veh;
	local Vector Loc;
	local Rotator Rot;
   
	if (TeamNum < 0)
		TeamNum = VehToSpawn.Buyer.GetTeamNum();

	Spawner.GetSpawnerLocAndRot(Loc,Rot);
	  
	Veh = Spawn(VehToSpawn.VehClass,,, Loc,Rot,,true);
  
	if (Veh != none )
	{
		lastSpawnedVehicle = Veh;
		//Veh.PlaySpawnEffect();
     
		if(VehToSpawn.Buyer != None) 
		{
			`LogRxPub("GAME" `s "Purchase;" `s "vehicle" `s VehToSpawn.VehClass.name `s "by" `s `PlayerLog(VehToSpawn.Buyer));
			if (Rx_Controller(VehToSpawn.Buyer.Owner) != None)
				Rx_Controller(VehToSpawn.Buyer.Owner).clientmessage("Your vehicle '"$veh.GetHumanReadableName()$"' is ready!", 'Vehicle');
		}
		else
			`LogRxPub("GAME" `s "Spawn;" `s "vehicle" `s class'Rx_Game'.static.GetTeamName(TeamNum) $ "," $ VehToSpawn.VehClass.name);
     
		InitVehicle(Veh,TeamNum,VehToSpawn.Buyer,VehToSpawn.VehicleID,Veh.Location);
		return Veh;
	}

	return None;
}