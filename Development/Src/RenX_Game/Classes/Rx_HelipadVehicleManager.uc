class Rx_HelipadVehicleManager extends Rx_VehicleManager;

var array<Rx_Building_Helipad_GDI> GDIHelipad;
var array<Rx_Building_Helipad_Nod> NodHelipad;
var ProductionPlace GDIHelipadSpawn, NodHelipadSpawn;
var array<VQueueElement> GDI_QueueAir, NOD_QueueAir;
var float HelipadSpawnZOffset, WaitTimeForAirVehicleAI;

function Initialize(GameInfo Game, UTTeamInfo GdiTeamInfo, UTTeamInfo NodTeamInfo)
{
   	local Rx_Building build;
	
   	RGame = Rx_Game(Game);
   	if (RGame == none)
   	{
		  RGame = Rx_Game(WorldInfo.Game);
		  if (RGame == none)
		  {
			 return;
		  }
   	}

  	Teams[TEAM_GDI] = GdiTeamInfo;
  	Teams[TEAM_NOD] = NodTeamInfo;
  	

 	if(WeaponsFactory.length <= 0 && AirStrip.length <= 0 && GDIHelipad.length <= 0 && NodHelipad.length <= 0) 
	{
		ForEach AllActors(class'Rx_Building',build)
		{
			if (Rx_Building_Nod_VehicleFactory(build) != None)
				AirStrip.AddItem(Rx_Building_Nod_VehicleFactory(build));
			else if (Rx_Building_GDI_VehicleFactory(build) != None)
				WeaponsFactory.AddItem(Rx_Building_GDI_VehicleFactory(build));
			else if (Rx_Building_Helipad_GDI(build) != None)
				GDIHelipad.AddItem(Rx_Building_Helipad_GDI(build));
			else if (Rx_Building_Helipad_Nod(build) != None)
				NodHelipad.AddItem(Rx_Building_Helipad_Nod(build));
		}
	}

	GDI_Ref = RGame.TeamCredits[TEAM_GDI].Refinery;
	if (GDI_Ref.length <= 0)
		bGDIRefDestroyed = true;
		
	Nod_Ref = RGame.TeamCredits[TEAM_NOD].Refinery;
	if (Nod_Ref.length <= 0)
		bNodRefDestroyed = true;
}

function Rx_Building_VehicleFactory GetAirNearestProduction(Rx_PRI Buyer, out Vector loc, out Rotator rot, optional byte TeamNum)
{
	local int i;
	local float BestDist,CurDist;
	local Rx_Building_VehicleFactory BestFactory;
	local bool bActiveBuildingAvailable;

	if(Buyer.GetTeamNum() == TEAM_GDI)
	{			
		for(i=0; i<GDIHelipad.length;i++)
		{
			if(BestFactory == None)
			{
				BestDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - GDIHelipad[i].location);
				BestFactory = GDIHelipad[i];
				if(!GDIHelipad[i].IsDestroyed())
					bActiveBuildingAvailable = true;
			}
			else if ((bActiveBuildingAvailable && !GDIHelipad[i].IsDestroyed()) || (!bActiveBuildingAvailable))
			{
				CurDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - GDIHelipad[i].location);
				if(BestDist > CurDist)
				{
					BestDist = CurDist;
					BestFactory = GDIHelipad[i];
				}
				if(!bActiveBuildingAvailable &&!GDIHelipad[i].IsDestroyed())
					bActiveBuildingAvailable = true;
			}
		}
		BestFactory.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_Spawn', loc, rot);
	}
	else if(Buyer.GetTeamNum() == TEAM_NOD)
	{
		for(i=0; i<NodHelipad.length;i++)
		{
			if(BestFactory == None)
			{
				BestDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - NodHelipad[i].location);
				BestFactory = NodHelipad[i];
				if(!NodHelipad[i].IsDestroyed())
					bActiveBuildingAvailable = true;			
			}
			else if ((bActiveBuildingAvailable && !NodHelipad[i].IsDestroyed()) || (!bActiveBuildingAvailable))
			{
				CurDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - NodHelipad[i].location);
				if(BestDist > CurDist) 
				{
					BestDist = CurDist;
					BestFactory = NodHelipad[i];
					if(!bActiveBuildingAvailable && !NodHelipad[i].IsDestroyed())
						bActiveBuildingAvailable = true;
				}
			}
		}
		BestFactory.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_Spawn', loc, rot);

	}

	if(BestFactory != None)
		return BestFactory;

	return none;
}


function bool QueueVehicle(class<Rx_Vehicle> inVehicleClass, Rx_PRI Buyer, int VehicleID)
{
	local VQueueElement NewQueueElement;

	if (!IsAirclass(inVehicleClass))
	{
		return Super.QueueVehicle(inVehicleClass, Buyer, VehicleID);
	}

	if (!IsAllowedToQueueUpAnotherVehicle(Buyer)) 
	{
		return false;
	}
	
	NewQueueElement.Buyer = Buyer;
	NewQueueElement.VehClass = inVehicleClass;
	NewQueueElement.VehicleID = VehicleID;
	NewQueueElement.Factory = GetAirNearestProduction(Buyer, NewQueueElement.L, NewQueueElement.R);

	if(Buyer.GetTeamNum() == TEAM_NOD) 
	{
		NOD_QueueAir.AddItem(NewQueueElement);

		if (!IsTimerActive('queueWork_NODAir'))
		   	SetTimer(ProductionDelay, false, 'queueWork_NODAir');

		Rx_TeamInfo(Teams[Buyer.GetTeamNum()]).IncreaseVehicleCount();

		ConstructionWarn(0);
	}
	else if(Buyer.GetTeamNum() == TEAM_GDI)
	{
		GDI_QueueAir.AddItem(NewQueueElement);

		if (!IsTimerActive('queueWork_GDIAir'))
		   	SetTimer(ProductionDelay, false, 'queueWork_GDIAir');	   

		Rx_TeamInfo(Teams[Buyer.GetTeamNum()]).IncreaseVehicleCount();

		ConstructionWarn(1);		
	}
	
	return true;
}

function Actor SpawnVehicle(VQueueElement VehToSpawn, optional byte TeamNum = -1)
{
	local Rx_Vehicle Veh;
	local Vector SpawnLocation;
   
	if (TeamNum < 0)
		TeamNum = VehToSpawn.Buyer.GetTeamNum();

	if (!IsAirClass(VehToSpawn.VehClass))
	{
		return Super.SpawnVehicle(VehToSpawn, TeamNum);
	}

	switch(TeamNum)
	{
		case TEAM_NOD: // buy for NOD
			SpawnLocation = NOD_QueueAir[0].L;
			SpawnLocation.Z += HelipadSpawnZOffset;
			Veh = Spawn(VehToSpawn.VehClass,,, SpawnLocation,NOD_QueueAir[0].R,,true);
		break;
		case TEAM_GDI: // buy for GDI
			SpawnLocation = GDI_QueueAir[0].L;
			SpawnLocation.Z += HelipadSpawnZOffset;
			Veh = Spawn(VehToSpawn.VehClass,,, SpawnLocation,GDI_QueueAir[0].R,,true);
		break;
	}
  
	if (Veh != none)
	{
		lastSpawnedVehicle = Veh;
     
		if(VehToSpawn.Buyer != None) 
		{
			`LogRxPub("GAME" `s "Purchase;" `s "vehicle" `s VehToSpawn.VehClass.name `s "by" `s `PlayerLog(VehToSpawn.Buyer));
			if (Rx_Controller(VehToSpawn.Buyer.Owner) != None)
				Rx_Controller(VehToSpawn.Buyer.Owner).clientmessage("Your vehicle '"$veh.GetHumanReadableName()$"' is ready!", 'Vehicle');
		}
		else
			`LogRxPub("GAME" `s "Spawn;" `s "vehicle" `s class'Rx_Game'.static.GetTeamName(TeamNum) $ "," $ VehToSpawn.VehClass.name);
     
		InitVehicle(Veh,TeamNum,VehToSpawn.Buyer,VehToSpawn.VehicleID,SpawnLocation);
		return Veh;
	}

	return None;
}

function InitVehicle(Rx_Vehicle Veh, byte TeamNum, Rx_Pri Buyer, int VehId, vector SpawnLocation)
{
	local UTVehicle P;	
	local Rx_PurchaseSystem RxPS; 

	if (!IsAirClass(Veh.Class))
	{
		Super.InitVehicle(Veh, TeamNum, Buyer, VehId, SpawnLocation);
		return;
	}
	
	if(WorldInfo.NetMode == NM_StandAlone || (WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) )
		RxPS = Rx_Game(WorldInfo.Game).PurchaseSystem;
	else
		RxPS = Rx_GRI(WorldInfo.GRI).PurchaseSystem;
	
	// destroy everything around
	foreach VisibleCollidingActors(class'UTVehicle', P, 250, SpawnLocation, true)
		if (P != Veh)
			P.TakeDamage(10000, None, P.Location, vect(0,0,1), class'UTDmgType_LinkBeam');

	Rx_TeamInfo(Teams[TeamNum]).addVehicle(Veh);
	
	Veh.TeamBought = TeamNum;
	Veh.lastTeamToUse = TeamNum;
	Veh.SetTeamNum(TeamNum);
	Veh.bTeamLocked = false;
	Veh.DropToGround();

	if (Veh.Mesh != None)
		Veh.Mesh.WakeRigidBody();

	if (Veh != none && Rx_Vehicle_Harvester(Veh) == None)
	{
		Veh.buyerPri = Buyer;
		
		if (Rx_Game(WorldInfo.Game).bReserveVehiclesToBuyer)
			Veh.bReservedToBuyer = true;

		Veh.PromoteUnit(Buyer.VRank);

		Veh.startUpDrivingWithDelay();

		if (Rx_Bot(Veh.buyerPri.owner) != none)
			Rx_Bot(Veh.buyerPri.owner).BaughtVehicle = Veh;
	}

	BroadcastLocalizedTeamMessage(TeamNum,MessageClass,VehId,Buyer,,RxPS);
}

function queueWork_GDIAir()
{
	local Actor Veh;
	
	if(GDI_QueueAir.Length > 0)
	{
		Veh = SpawnVehicle(GDI_QueueAir[0], TEAM_GDI);
		if(Veh != None) 
		{
			GDI_QueueAir.Remove(0, 1);
			ClearTimer('queueWork_GDIAir');
			if (GDI_QueueAir.Length > 0)
			{
				SetTimer(ProductionDelay+4.5f+GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDIAir');

				SetTimer(4.5f,false,'DelayedGDIConstructionWarn');
			}
		}
	}
	else
		ClearTimer('queueWork_GDIAir');
}

function queueWork_NODAir()
{
	local Actor Veh;
	
	if(NOD_QueueAir.Length > 0) 
	{
		Veh = SpawnVehicle(NOD_QueueAir[0], TEAM_NOD);
		if(Veh != None) 
		{
			NOD_QueueAir.Remove(0, 1);
			ClearTimer('queueWork_NODAir');
			if (NOD_QueueAir.Length > 0)
			{
				SetTimer(ProductionDelay+4.5f+NodAdditionalAirdropProductionDelay, false, 'queueWork_NODAir');	

				SetTimer(4.5f,false,'DelayedNodConstructionWarn');
			}
		}
	}
	else
		ClearTimer('queueWork_NODAir');
}

function bool IsAllowedToQueueUpAnotherVehicle(Rx_PRI Buyer)
{
	local int Count, I;
	
	if(Buyer.GetTeamNum() == TEAM_NOD) {
		for (I = 0; I < NOD_QueueAir.Length; I++)
		{
			if (NOD_QueueAir[I].Buyer == Buyer) {Count++;}
		}

		for (I = 0; I < NOD_Queue.Length; I++)
		{
			if (NOD_Queue[I].Buyer == Buyer) {Count++;}
		}
	} else if(Buyer.GetTeamNum() == TEAM_GDI) {
		for (I = 0; I < GDI_QueueAir.Length; I++)
		{
			if (GDI_QueueAir[I].Buyer == Buyer) {Count++;}
		}

		for (I = 0; I < GDI_Queue.Length; I++)
		{
			if (GDI_Queue[I].Buyer == Buyer) {Count++;}
		}
	}
   
	return Count < Buyer.MyVehicleLimitInQueue && CheckVehicleLimit(Buyer.GetTeamNum());
}

function bool IsAirclass(class<Object> VehClass)
{
	if (ClassIsChildOf(VehClass, class'Rx_Vehicle_Air'))
		return true;

	return ClassIsChildOf(VehClass, class'Rx_Vehicle_Air_Jet');
}

DefaultProperties
{
	HelipadSpawnZOffset = 50.0
	WaitTimeForAirVehicleAI = 2.0
}