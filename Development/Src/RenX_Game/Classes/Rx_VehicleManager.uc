class Rx_VehicleManager extends Actor;

// struct for the queue elements
struct VQueueElement
{
   var Rx_PRI Buyer;
   var class<Rx_Vehicle> VehClass;
   var int VehicleID;
};

struct ProductionPlace
{
   var Vector L;
   var Rotator R;
};

var UTTeamInfo						Teams[2];
var Rx_Game                         RGame;
var private array<Vehicle>          stolenByNOD, stolenByGDI;
var private float                   ProductionDelay;
var float            				NodAdditionalAirdropProductionDelay; 
var float            				GDIAdditionalAirdropProductionDelay;
var ProductionPlace    			  	NOD_ProductionPlace;
var ProductionPlace    			    GDI_ProductionPlace;
var private array<VQueueElement>    GDI_Queue, NOD_Queue;
var private UTVehicle               lastSpawnedVehicle;
var() bool							UseDefaultParkingSpots;
var int                             GDIVehicleCOunt, NodVehicleCount;  
var Rx_Building						AirStrip;  
var Rx_Building						WeaponsFactory;  
var bool							bGDIRefDestroyed; 
var bool							bNodRefDestroyed; 
var bool 							bJustSpawnedNodHarv;
var bool 							bJustSpawnedGDIHarv;
var bool 							bNodIsUsingAirdrops;
var bool 							bGDIIsUsingAirdrops;


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
  
	if(AirStrip == None) 
	{
		ForEach AllActors(class'Rx_Building',build)
		{
			if ( build.Class == class'Rx_Building_Airstrip' )
			{
				AirStrip = build;
			} else if ( build.Class == class'Rx_Building_WeaponsFactory' || build.Class == class'Rx_Building_WeaponsFactory_Ramps')
			{
				WeaponsFactory = build;
			} 
		}
	}
	if (RGame.TeamCredits[TEAM_GDI].Refinery == None)
		bGDIRefDestroyed = true;
	if (RGame.TeamCredits[TEAM_NOD].Refinery == None)
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
	bGDIRefDestroyed = true;
}

function SetNodRefDestroyed(bool destroyed)
{	
	bNodRefDestroyed = true;
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
    	NewQueueElement.VehClass  = class'Rx_Vehicle_Harvester_Nod';
		NewQueueElement.VehicleID = 8;
	    NOD_Queue.AddItem(NewQueueElement);
	    if (!IsTimerActive('queueWork_NOD'))
	    {
	       if(bWithIncreasedDelay)
	       {
	       	 SetTimer(ProductionDelay + 10.0, false, 'queueWork_NOD');
	       	 if(!AirStrip.IsDestroyed())
	       	 	SetTimer(10.0,false,'SpawnC130');
       	   }
	       else
	       {
	       	 if(AirStrip.IsDestroyed())
	       	 	SpawnC130();
	       	 SetTimer(ProductionDelay, false, 'queueWork_NOD'); 
	       }
	    }
	} 
	else if(team == TEAM_GDI) 
	{
    	if(bGDIRefDestroyed)
    		return;
	    NewQueueElement.VehClass  = class'Rx_Vehicle_Harvester_GDI';
		NewQueueElement.VehicleID = 7;
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

	if(bNodIsUsingAirdrops)
		return;
	if(AirStrip != None) {
	   	loc = NOD_ProductionPlace.L;		
	   	loc.z -= 100;
	   	Spawn(class'Rx_C130',,,loc,Airstrip.rotation,,true);
   	}
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
		   if(bJustSpawnedNodHarv) {
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
				TempLoc = NOD_ProductionPlace.L;
				TempLoc.Z -= 500;
				AirdropingChinook = Spawn(class'Rx_Chinook_Airdrop', , , TempLoc, NOD_ProductionPlace.R, , false);
				AirdropingChinook.initialize(VehToSpawn.Buyer,VehToSpawn.VehicleID, TeamNum);			
			}
			else
			{
				Veh = Spawn(VehToSpawn.VehClass,,, NOD_ProductionPlace.L,NOD_ProductionPlace.R,,true);			
				SpawnLocation = NOD_ProductionPlace.L;
			}
		break;
		case TEAM_GDI: // buy for GDI
			if(bGDIIsUsingAirdrops)
			{
				TempLoc =  GDI_ProductionPlace.L + vector(GDI_ProductionPlace.R) * 950;
				TempLoc.Z -= 500;
				AirdropingChinook = Spawn(class'Rx_Chinook_Airdrop', , , TempLoc, GDI_ProductionPlace.R, , false);
				AirdropingChinook.initialize(VehToSpawn.Buyer,VehToSpawn.VehicleID, TeamNum);			
			}
			else
			{
				Veh = Spawn(VehToSpawn.VehClass,,,GDI_ProductionPlace.L,GDI_ProductionPlace.R,,true);
				SpawnLocation = GDI_ProductionPlace.L;
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
		Veh.startUpDriving();
		if (Rx_Bot(Veh.buyerPri.owner) != none )
		{
			Rx_Bot(Veh.buyerPri.owner).BaughtVehicle = Veh;
		}	
	}
	BroadcastLocalizedTeamMessage(TeamNum,MessageClass,VehId,Buyer);
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
	
}
