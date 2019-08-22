class Rx_VehicleManager extends Actor;

// struct for the queue elements
struct VQueueElement
{
   var Rx_PRI Buyer;
   var class<Rx_Vehicle> VehClass;
   var int VehicleID;
   var Vector L;
   var Rotator R;
   var Rx_Building_VehicleFactory Factory;
};

struct ProductionPlace
{
   var Vector L;
   var Rotator R;
};

var UTTeamInfo						Teams[2];
var Rx_Game                         RGame;
var array<Vehicle>          stolenByNOD, stolenByGDI;
var float                   ProductionDelay;
var float            				NodAdditionalAirdropProductionDelay; 
var float            				GDIAdditionalAirdropProductionDelay;
var ProductionPlace    			  	NOD_ProductionPlace;
var ProductionPlace    			    GDI_ProductionPlace;
var array<VQueueElement>    GDI_Queue, NOD_Queue;
var UTVehicle               lastSpawnedVehicle;
var() bool							UseDefaultParkingSpots;
var int                             GDIVehicleCOunt, NodVehicleCount;  
var array<Rx_Building_Nod_VehicleFactory>	AirStrip;  
var array<Rx_Building_GDI_VehicleFactory>	WeaponsFactory;
var array<Rx_Building_Refinery>		Nod_Ref;
var array<Rx_Building_Refinery>		GDI_Ref;  
var bool							bGDIRefDestroyed; 
var bool							bNodRefDestroyed; 
var bool 							bJustSpawnedNodHarv;
var bool 							bJustSpawnedGDIHarv;
var bool 							bNodIsUsingAirdrops;
var bool 							bGDIIsUsingAirdrops;
var class<Rx_Vehicle_Harvester>		NodHarvesterClass;
var class<Rx_Vehicle_Harvester>		GDIHarvesterClass;
var Rx_Tib_NavigationPoint	GDITibPoint, NodTibPoint;

function CheckVehicleSpawn()
{
	local vector Nod_Ref_Loc;
	local rotator Nod_Ref_Rot;
	local vector GDI_Ref_Loc;
	local rotator GDI_Ref_Rot;

	if (AirStrip.length <= 0 && Nod_Ref.length > 0) 
	{
		Nod_Ref[0].BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('RefNodeSocket', Nod_Ref_Loc, Nod_Ref_Rot);
		Set_NOD_ProductionPlace(Nod_Ref_Loc, Nod_Ref_Rot);
		bNodIsUsingAirdrops = true;
	}
	if (WeaponsFactory.length <= 0 && GDI_Ref.length > 0) 
	{
		GDI_Ref[0].BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('RefNodeSocket', GDI_Ref_Loc, GDI_Ref_Rot);
		Set_GDI_ProductionPlace(GDI_Ref_Loc, GDI_Ref_Rot);
		bGDIIsUsingAirdrops = true;
	}
}

function Initialize(GameInfo Game, UTTeamInfo GdiTeamInfo, UTTeamInfo NodTeamInfo)
{
   local Rx_Building build;
   local Rx_Tib_NavigationPoint N;

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
  	
  	foreach WorldInfo.AllNavigationPoints(class'Rx_Tib_NavigationPoint',N) 
  	{
  		if(N.GetTeamNum() == TEAM_GDI)
  		{
  			GDITibPoint = N;
  		}
  		else if(N.GetTeamNum() == TEAM_NOD)
  		{
  			NodTibPoint = N;
  		}

  		if(GDITibPoint != None && NodTibPoint != None)
  			break;
  	}

	if(WeaponsFactory.length <= 0 && AirStrip.length <= 0) 
	{
		ForEach AllActors(class'Rx_Building',build)
		{
			if (Rx_Building_Nod_VehicleFactory(build) != None)
				AirStrip.AddItem(Rx_Building_Nod_VehicleFactory(build));
			else if (Rx_Building_GDI_VehicleFactory(build) != None)
				WeaponsFactory.AddItem(Rx_Building_GDI_VehicleFactory(build));
		}
	}
	GDI_Ref = RGame.TeamCredits[TEAM_GDI].Refinery;
	if (GDI_Ref.length <= 0)
		bGDIRefDestroyed = true;
		
	Nod_Ref = RGame.TeamCredits[TEAM_NOD].Refinery;
	if (Nod_Ref.length <= 0)
		bNodRefDestroyed = true;

}

function SpawnInitialHarvesters()
{
  	QueueHarvester(TEAM_GDI,false);
  	QueueHarvester(TEAM_NOD,false);
}

function Set_NOD_ProductionPlace(vector loc, rotator rot)
{
	NOD_ProductionPlace.L = loc;
	NOD_ProductionPlace.R = rot;
}

function Set_GDI_ProductionPlace(vector loc, rotator rot)
{
	GDI_ProductionPlace.L = loc;
	GDI_ProductionPlace.R = rot;
}

function SetGDIRefDestroyed(bool destroyed)
{
	bGDIRefDestroyed = Rx_Game(WorldInfo.Game).AreTeamRefineriesDestroyed(TEAM_GDI);
}

function SetNodRefDestroyed(bool destroyed)
{	
	bNodRefDestroyed = Rx_Game(WorldInfo.Game).AreTeamRefineriesDestroyed(TEAM_NOD);
}

function HarvDestroyed(byte team, bool bWithIncreasedDelay)
{
    if(team == TEAM_NOD && bNodRefDestroyed) 
    	return;
    else if(team == TEAM_GDI && bGDIRefDestroyed) 	
    	return;
    	
    if(team == TEAM_NOD && bNodIsUsingAirdrops) 
    	SetTimer(360.0, false, 'NodHarvAirdrop');
    else if(team == TEAM_GDI && bGDIIsUsingAirdrops) 	
    	SetTimer(360.0, false, 'GDIHarvAirdrop');
    else
    	QueueHarvester(team, bWithIncreasedDelay);	  	
}


function NodHarvAirdrop()
{
	QueueHarvester(TEAM_NOD, false);	
}

function GDIHarvAirdrop()
{
	QueueHarvester(TEAM_GDI, false);	
}

function QueueHarvester(byte team, bool bWithIncreasedDelay)
{
	local VQueueElement NewQueueElement;
	
	NewQueueElement.Buyer = None;

    if(team == TEAM_NOD) 
    {
    	if(bNodRefDestroyed)
    		return;

    	if(Airstrip.Length > 0)
    		NewQueueElement.Factory = GetNearestProduction(None,NewQueueElement.L,NewQueueElement.R,team);
   		else
    	{
			NewQueueElement.L = NOD_ProductionPlace.L;
			NewQueueElement.R = NOD_ProductionPlace.R;    		
    	}
    	NewQueueElement.VehClass  = NodHarvesterClass;
		NewQueueElement.VehicleID = 255;//8;
	    NOD_Queue.AddItem(NewQueueElement);
	    if (!IsTimerActive('queueWork_NOD'))
	    {
	       if(bWithIncreasedDelay)
	       {
	       	 SetTimer(ProductionDelay + 10.0, false, 'queueWork_NOD');
	       	 if(!AreTeamFactoriesDestroyed(TEAM_NOD))
	       	 	SetTimer(10.0,false,'SpawnC130');
       	   }
	       else
	       {
	       	 if(AreTeamFactoriesDestroyed(TEAM_NOD))
	       	 	SpawnC130();
	       	 SetTimer(ProductionDelay, false, 'queueWork_NOD'); 
	       }
	    }
	} 
	else if(team == TEAM_GDI) 
	{
    	if(bGDIRefDestroyed)
    		return;
 
    	if(WeaponsFactory.Length > 0)
    		NewQueueElement.Factory = GetNearestProduction(None,NewQueueElement.L,NewQueueElement.R,team);    	
    	else
    	{
			NewQueueElement.L = GDI_ProductionPlace.L;
			NewQueueElement.R = GDI_ProductionPlace.R;    		
    	}	    

    	NewQueueElement.VehClass  = GDIHarvesterClass;
		NewQueueElement.VehicleID = 254 ;//7;
	    GDI_Queue.AddItem(NewQueueElement);
	    if (!IsTimerActive('queueWork_GDI'))
	    {	       
	       if(bWithIncreasedDelay)
	       {
	       	 SetTimer(ProductionDelay + 10.0 + GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDI');
       	   }
	       else
	       {
	       	 SetTimer(ProductionDelay + GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDI'); 
	       }	       
	    }		
	}		
}

function SpawnC130() 
{
	local vector loc;
	local rotator C130Rot;

	if(bNodIsUsingAirdrops || !NOD_Queue[0].Factory.SpawnsC130)
		return;
	if(AirStrip.Length > 0) 
	{
	 	  loc = NOD_Queue[0].L;		
	 	  loc.z -= 100;
	 	  C130Rot = NOD_Queue[0].R;
	 	  C130Rot.yaw += 32768; 
		if ( Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset > 0 )
			loc.z += Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset;

	   		Spawn(class'Rx_C130',,,loc,C130Rot,,true);
   	}
}

simulated function bool AreTeamFactoriesDestroyed(byte teamID)
{
	local int i;

	if(teamID == TEAM_GDI && WeaponsFactory.Length > 0)
	{
		for(i=0; i < WeaponsFactory.Length; i++)
		{
			if(!WeaponsFactory[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else if(teamID == TEAM_NOD && AirStrip.Length > 0)
	{
		for(i=0; i < AirStrip.Length; i++)
		{
			if(!AirStrip[i].IsDestroyed())
				return false;
		}
		return true;
	}
	else
		return true;	
}

function Rx_Building_VehicleFactory GetNearestProduction(Rx_PRI Buyer, out Vector loc, out Rotator rot, optional byte TeamNum)
{
	local int i;
	local float BestDist,CurDist;
	local Rx_Building_VehicleFactory BestFactory;
	local bool bActiveBuildingAvailable;

	if(Buyer == None) // Probably Harvy
	{
		if(TeamNum == TEAM_GDI)
		{
			for(i=0; i<WeaponsFactory.length;i++)
			{
				if(BestFactory == None)
				{
					BestDist = VSizeSq(GDITibPoint.Location - WeaponsFactory[i].location);
					BestFactory = WeaponsFactory[i];
					if(!WeaponsFactory[i].IsDestroyed())
						bActiveBuildingAvailable = true;
				}
				else if ((bActiveBuildingAvailable && !WeaponsFactory[i].IsDestroyed()) || (!bActiveBuildingAvailable))
				{
					CurDist = VSizeSq(GDITibPoint.Location - WeaponsFactory[i].location);
					if(BestDist > CurDist)
					{
						BestDist = CurDist;
						BestFactory = WeaponsFactory[i];
					}
					if(!bActiveBuildingAvailable &&!WeaponsFactory[i].IsDestroyed())
						bActiveBuildingAvailable = true;
				}
			}
			BestFactory.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_Spawn', loc, rot);
		}	
		else if(TeamNum == TEAM_NOD)
		{
			for(i=0; i<Airstrip.length;i++)
			{
				if(BestFactory == None)
				{
					BestDist = VSizeSq(NodTibPoint.Location - Airstrip[i].location);
					BestFactory = Airstrip[i];
					if(!AirStrip[i].IsDestroyed())
						bActiveBuildingAvailable = true;			
				}
				else if ((bActiveBuildingAvailable && !AirStrip[i].IsDestroyed()) || (!bActiveBuildingAvailable))
				{
					CurDist = VSizeSq(NodTibPoint.Location - Airstrip[i].location);
					if(BestDist > CurDist)
					{
						BestDist = CurDist;
						BestFactory = Airstrip[i];
						if(!bActiveBuildingAvailable && !AirStrip[i].IsDestroyed())
							bActiveBuildingAvailable = true;
					}
				}
			}
			BestFactory.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_DropOff', loc, rot);
		}		
	}

	else if(Buyer.GetTeamNum() == TEAM_GDI)
	{			
		for(i=0; i<WeaponsFactory.length;i++)
		{
			if(BestFactory == None)
			{
				BestDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - WeaponsFactory[i].location);
				BestFactory = WeaponsFactory[i];
				if(!WeaponsFactory[i].IsDestroyed())
					bActiveBuildingAvailable = true;
			}
			else if ((bActiveBuildingAvailable && !WeaponsFactory[i].IsDestroyed()) || (!bActiveBuildingAvailable))
			{
				CurDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - WeaponsFactory[i].location);
				if(BestDist > CurDist)
				{
					BestDist = CurDist;
					BestFactory = WeaponsFactory[i];
				}
				if(!bActiveBuildingAvailable &&!WeaponsFactory[i].IsDestroyed())
					bActiveBuildingAvailable = true;
			}
		}
		BestFactory.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_Spawn', loc, rot);
	}
	else if(Buyer.GetTeamNum() == TEAM_NOD)
	{
		for(i=0; i<Airstrip.length;i++)
		{
			if(BestFactory == None)
			{
				BestDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - Airstrip[i].location);
				BestFactory = Airstrip[i];
				if(!AirStrip[i].IsDestroyed())
					bActiveBuildingAvailable = true;			
			}
			else if ((bActiveBuildingAvailable && !AirStrip[i].IsDestroyed()) || (!bActiveBuildingAvailable))
			{
				CurDist = VSizeSq(Controller(Buyer.Owner).Pawn.Location - Airstrip[i].location);
				if(BestDist > CurDist) 
				{
					BestDist = CurDist;
					BestFactory = Airstrip[i];
					if(!bActiveBuildingAvailable && !AirStrip[i].IsDestroyed())
						bActiveBuildingAvailable = true;
				}
			}
		}
		BestFactory.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_DropOff', loc, rot);

	}
	if(BestFactory != None)
		return BestFactory;

		return None;

}

function bool QueueVehicle(class<Rx_Vehicle> inVehicleClass, Rx_PRI Buyer, int VehicleID)
{
	local VQueueElement NewQueueElement;
	
	if(!IsAllowedToQueueUpAnotherVehicle(Buyer)) 
	{
		return false;
	}
	
	NewQueueElement.Buyer = Buyer;
	NewQueueElement.VehClass = inVehicleClass;
	NewQueueElement.VehicleID = VehicleID;
	NewQueueElement.Factory = GetNearestProduction(Buyer, NewQueueElement.L, NewQueueElement.R);
	
	if(Buyer.GetTeamNum() == TEAM_NOD) 
	{
		NOD_Queue.AddItem(NewQueueElement);
		if (!IsTimerActive('queueWork_NOD'))
		{
		   if(bJustSpawnedNodHarv) {
		   	   SetTimer(ProductionDelay+8.0+NodAdditionalAirdropProductionDelay, false, 'queueWork_NOD');
		   	   bJustSpawnedNodHarv = false;
		   	   SetTimer(8.0,false,'SpawnC130');
		   } else {			  
		   	   SetTimer(ProductionDelay+NodAdditionalAirdropProductionDelay, false, 'queueWork_NOD');
		   	   SpawnC130();
		   }
		}
		if( !ClassIsChildOf(inVehicleClass, class'Rx_Vehicle_Harvester') )
		{
			Rx_TeamInfo(Teams[Buyer.GetTeamNum()]).IncreaseVehicleCount();
		}
		ConstructionWarn(0);
		
	} 
	else if(Buyer.GetTeamNum() == TEAM_GDI)
	{
		GDI_Queue.AddItem(NewQueueElement);
		if (!IsTimerActive('queueWork_GDI'))
		{
		   if(bJustSpawnedGDIHarv) {
		   	   SetTimer(ProductionDelay+8.0+GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDI');
		   	   bJustSpawnedGDIHarv = false;
		   } else {			  
		   	   SetTimer(ProductionDelay+GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDI');
		   }		   
		}
		if( !ClassIsChildOf(inVehicleClass, class'Rx_Vehicle_Harvester') )
		{
			Rx_TeamInfo(Teams[Buyer.GetTeamNum()]).IncreaseVehicleCount();
		}		
		ConstructionWarn(1);		
	}
	
	
	return true;
}

function bool IsAllowedToQueueUpAnotherVehicle(Rx_PRI Buyer)
{
	local int Count, I;
	
	if(Buyer.GetTeamNum() == TEAM_NOD) {
		for (I = 0; I < NOD_Queue.Length; I++)
		{
			if (NOD_Queue[I].Buyer == Buyer) {Count++;}
		}
	} else if(Buyer.GetTeamNum() == TEAM_GDI) {
		for (I = 0; I < GDI_Queue.Length; I++)
		{
			if (GDI_Queue[I].Buyer == Buyer) {Count++;}
		}
	}
   
	return Count < Buyer.MyVehicleLimitInQueue && CheckVehicleLimit(Buyer.GetTeamNum());
}

function Actor SpawnVehicle(VQueueElement VehToSpawn, optional byte TeamNum = -1)
{

	local Rx_Vehicle Veh;
	local Vector SpawnLocation;
	local Rx_Chinook_Airdrop AirdropingChinook;
	local vector TempLoc;
   
	if (TeamNum < 0)
		TeamNum = VehToSpawn.Buyer.GetTeamNum();
	  
	  
	switch(TeamNum)
	{
		case TEAM_NOD: // buy for NOD
			if(bNodIsUsingAirdrops)
			{
				TempLoc = VehToSpawn.L;
				if (AirStrip.length > 0)
					TempLoc.Z -= 500;
					
				AirdropingChinook = Spawn(class'Rx_Chinook_Airdrop', , , TempLoc, VehToSpawn.R, , false);
				AirdropingChinook.initialize(VehToSpawn.Buyer,VehToSpawn.VehicleID, TeamNum);			
			}
			else
			{
				SpawnLocation = VehToSpawn.L;
				if (Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset > 0 )
					SpawnLocation.Z += Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset ; 
					Veh = Spawn(VehToSpawn.VehClass,,, SpawnLocation,VehToSpawn.R,,true);
							
			}
		break;
		case TEAM_GDI: // buy for GDI
			if(bGDIIsUsingAirdrops)
			{
				if (WeaponsFactory.Length > 0) 
				{
					TempLoc = VehToSpawn.L + vector(VehToSpawn.R) * 950;
					TempLoc.Z -= 500;
					AirdropingChinook = Spawn(class'Rx_Chinook_Airdrop_GDI', , , TempLoc, VehToSpawn.R, , false);
				}
				else
					AirdropingChinook = Spawn(class'Rx_Chinook_Airdrop_GDI', , , VehToSpawn.L, VehToSpawn.R, , false);
				AirdropingChinook.initialize(VehToSpawn.Buyer,VehToSpawn.VehicleID, TeamNum);			
			}
			else
			{
				Veh = Spawn(VehToSpawn.VehClass,,,VehToSpawn.L,VehToSpawn.R,,true);
				SpawnLocation = VehToSpawn.L;
			}
		break;
	}
  
  	if (AirdropingChinook != none  )
  	{
  		if(VehToSpawn.Buyer != None) 
		{
			`LogRxPub("GAME" `s "Purchase;" `s "vehicle" `s VehToSpawn.VehClass.name `s "by" `s `PlayerLog(VehToSpawn.Buyer));
			if (Rx_Controller(VehToSpawn.Buyer.Owner) != None)
				Rx_Controller(VehToSpawn.Buyer.Owner).clientmessage("Your vehicle is being delivered!", 'Vehicle');
		}
		else
			`LogRxPub("GAME" `s "Spawn;" `s "vehicle" `s class'Rx_Game'.static.GetTeamName(TeamNum) $ "," $ VehToSpawn.VehClass.name);
			
		return AirdropingChinook;	
  	}
  
	if (Veh != none  )
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
     
		InitVehicle(Veh,TeamNum,VehToSpawn.Buyer,VehToSpawn.VehicleID,SpawnLocation);
		return Veh;
	}
	else if (Veh != none && Rx_Vehicle_Harvester(Veh) != None) 
	{
		Veh.DropToGround(); 
	}

	return None;
}

function InitVehicle(Rx_Vehicle Veh, byte TeamNum, Rx_Pri Buyer, int VehId, vector SpawnLocation)
{
	local UTVehicle P;	
	local Rx_PurchaseSystem RxPS; 
	
	if(WorldInfo.NetMode == NM_StandAlone || (WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) )
		RxPS = Rx_Game(WorldInfo.Game).PurchaseSystem ;
	else
		RxPS = Rx_GRI(WorldInfo.GRI).PurchaseSystem ;
	
	// destroy everything around
	foreach VisibleCollidingActors(class'UTVehicle', P, 250, SpawnLocation, true)
	{
		if (P != Veh)
		{
			P.TakeDamage(10000, none, P.Location, vect(0,0,1), class'UTDmgType_LinkBeam');
		}
	}	
	
	if(Rx_Vehicle_Harvester(Veh) == None) 
	{
		Rx_TeamInfo(Teams[TeamNum]).addVehicle(Veh);
	}	
	
	Veh.TeamBought = TeamNum;
	Veh.lastTeamToUse = TeamNum;
	Veh.SetTeamNum(TeamNum);
	Veh.bTeamLocked=false;
	Veh.DropToGround();

	if (Veh.Mesh != none)
		Veh.Mesh.WakeRigidBody();

	if ( Veh != none && Rx_Vehicle_Harvester(Veh) == None)
	{
		Veh.buyerPri = Buyer;
		
		if ( Rx_Game(WorldInfo.Game).bReserveVehiclesToBuyer )
			Veh.bReservedToBuyer = true;
			Veh.PromoteUnit(Buyer.VRank); 
		Veh.startUpDriving();
		if (Rx_Bot(Veh.buyerPri.owner) != none )
		{
			Rx_Bot(Veh.buyerPri.owner).BaughtVehicle = Veh;
		}	
	}
	BroadcastLocalizedTeamMessage(TeamNum,MessageClass,VehId,Buyer,,RxPS);
}

function bool CheckVehicleLimit(byte TeamNum)
{
	return (Rx_Game(WorldInfo.Game).getVehicleLimit() - Rx_TeamInfo(Teams[TeamNum]).GetVehicleCount() ) > 0;
}

function array<VQueueElement> getVQueueForTeam(byte TeamNum)
{
   return (TeamNum == TEAM_GDI ? GDI_Queue : NOD_Queue);
}

function vehChangedTeam(UTVehicle V)
{
   if (V.GetTeamNum() == 0)
   {
	  if (stolenByGDI.Find(V) >= 0)
		 stolenByGDI.RemoveItem(V);
	  if (v.default.Team != 0)
		 stolenByNOD.AddItem(V);
   }
   else
   {
	  if (stolenByNOD.Find(V) >= 0)
		 stolenByNOD.RemoveItem(V);
	  if (v.default.Team != 1)
		 stolenByGDI.AddItem(V);
   }
}

function queueWork_GDI()
{
	local Actor Veh;
	
	if(GDI_Queue.Length > 0)
	{
		Veh = SpawnVehicle(GDI_Queue[0], TEAM_GDI);
		if(Veh != None) 
		{
			GDI_Queue.Remove(0, 1);
			ClearTimer('queueWork_GDI');
			if (GDI_Queue.Length > 0)
			{
				if(Rx_Vehicle_Harvester(Veh) != None) 
					SetTimer(ProductionDelay+9.0f+GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDI');	
				else
					SetTimer(ProductionDelay+4.5f+GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDI');	
				SetTimer(4.5f,false,'DelayedGDIConstructionWarn');
			}
		}
	}
	else
		ClearTimer('queueWork_GDI');
}

function queueWork_NOD()
{
	local Actor Veh;
	
	if(NOD_Queue.Length > 0) 
	{
		Veh = SpawnVehicle(NOD_Queue[0], TEAM_NOD);
		if(Veh != None) 
		{
			NOD_Queue.Remove(0, 1);
			ClearTimer('queueWork_NOD');
			if (NOD_Queue.Length > 0)
			{
				if(Rx_Vehicle_Harvester(Veh) != None) 
					SetTimer(ProductionDelay+9.0f+NodAdditionalAirdropProductionDelay, false, 'queueWork_NOD');	
				else
					SetTimer(ProductionDelay+4.5f+NodAdditionalAirdropProductionDelay, false, 'queueWork_NOD');	
				SetTimer(4.5f,false,'DelayedNodConstructionWarn');
			}
		}
	}
	else
		ClearTimer('queueWork_NOD');
}

function DelayedNodConstructionWarn() {
	ConstructionWarn(TEAM_NOD);
	SpawnC130();	
}

function DelayedGDIConstructionWarn() {
	ConstructionWarn(TEAM_GDI);
}

//TODO: play sound for vehicle spawn (EVA voice) and also warn players in the danger zone
function ConstructionWarn(byte TeamNum)
{
  
}

DefaultProperties
{
	ProductionDelay                 = 5.5f
	NodAdditionalAirdropProductionDelay = 0.0f // gets set once AS gets destroyed
	GDIAdditionalAirdropProductionDelay = 0.0f // gets set once WF gets destroyed
	bOnlyDirtyReplication           = true
	bSkipActorPropertyReplication   = true
	bAlwaysRelevant                 = true
	MessageClass                    = class'Rx_Message_VehicleProduced'
	NodHarvesterClass				= class'Rx_Vehicle_Harvester_Nod'
	GDIHarvesterClass				= class'Rx_Vehicle_Harvester_GDI'
}
