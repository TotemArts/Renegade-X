class S_VehicleManager extends Rx_VehicleManager;

function QueueHarvester(RxIfc_Refinery MyRefinery, bool bWithIncreasedDelay)
{
    local VQueueElement NewQueueElement;
    
    NewQueueElement.Buyer = None;
    NewQueueElement.RefineryBuyer = MyRefinery;

    if(Rx_Building(MyRefinery).GetTeamNum() == TEAM_NOD) 
    {
        if(bNodRefDestroyed)
            return;

        NewQueueElement.VehClass  = NodHarvesterClass;
        NewQueueElement.VehicleID = 255;//8;

        if(Airstrip.Length > 0)
            NewQueueElement.Factory = GetNearestProduction(Rx_Building(MyRefinery),NewQueueElement.L,NewQueueElement.R,Rx_Building(MyRefinery).GetTeamNum(),NewQueueElement.VehClass);
        else
        {
            NewQueueElement.L = NOD_ProductionPlace.L;
            NewQueueElement.R = NOD_ProductionPlace.R;          
        }

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
             if(!AreTeamFactoriesDestroyed(TEAM_NOD))
                SpawnC130();
             SetTimer(ProductionDelay, false, 'queueWork_NOD'); 
           }
        }
    } 
    else if(Rx_Building(MyRefinery).GetTeamNum() == TEAM_GDI) 
    {
        if(bGDIRefDestroyed)
            return;     

        NewQueueElement.VehClass  = GDIHarvesterClass;
        NewQueueElement.VehicleID = 254 ;//7;

        if(WeaponsFactory.Length > 0)
            NewQueueElement.Factory = GetNearestProduction(Rx_Building(MyRefinery),NewQueueElement.L,NewQueueElement.R,Rx_Building(MyRefinery).GetTeamNum(),NewQueueElement.VehClass);      
        else
        {
            NewQueueElement.L = GDI_ProductionPlace.L;
            NewQueueElement.R = GDI_ProductionPlace.R;          
        }
        
        GDI_Queue.AddItem(NewQueueElement);
        if (!IsTimerActive('queueWork_GDI'))
        {          
           if(bWithIncreasedDelay)
           {
             SetTimer(ProductionDelay + 10.0, false, 'queueWork_GDI');
                if(!AreTeamFactoriesDestroyed(TEAM_GDI))
                SetTimer(10.0,false,'SpawnC130GDI');
           }
           else
           {
             if(!AreTeamFactoriesDestroyed(TEAM_GDI))
                SpawnC130GDI();
             SetTimer(ProductionDelay, false, 'queueWork_GDI'); 
           }           
        }       
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
               SetTimer(8.0,false,'SpawnC130GDI');
           } else {          
               SetTimer(ProductionDelay+GDIAdditionalAirdropProductionDelay, false, 'queueWork_GDI');
               SpawnC130GDI();
           }
        }
        if(!ClassIsChildOf(inVehicleClass, class'Rx_Vehicle_Harvester'))
        {
            Rx_TeamInfo(Teams[Buyer.GetTeamNum()]).IncreaseVehicleCount();
        }
        ConstructionWarn(1);       
    }
   
    if(NewQueueElement.Factory != None)
        Rx_Building(NewQueueElement.Factory).TriggerEventClass(Class'Rx_SeqEvent_FactoryEvent',NewQueueElement.Buyer.Owner,0);
   
    return true;
}

function SpawnC130() 
{
    local vector loc;
    local rotator C130Rot;

    if(bNodIsUsingAirdrops || !NOD_Queue[0].Factory.SpawnsC130())
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
            `log("C130 Nod spawn: loc" `s loc `s "C130Rot" `s C130Rot);
    }
}
 
function SpawnC130GDI() 
{
    local vector loc;
    local rotator C130Rot;

    if(bGDIIsUsingAirdrops || !GDI_Queue[0].Factory.SpawnsC130())
        return;
    if(WeaponsFactory.Length > 0) 
    {
          loc = GDI_Queue[0].L;     
          loc.z -= 100;
          C130Rot = GDI_Queue[0].R;
          C130Rot.yaw += 32768; 
        if ( Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset > 0 )
            loc.z += Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset;

            Spawn(class'S_C130',,,loc,C130Rot,,true);
            `log("C130 GDI spawn: loc" `s loc `s "C130Rot" `s C130Rot);
    }
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
                AirdropingChinook.initialize(VehToSpawn.Buyer,VehToSpawn.RefineryBuyer,VehToSpawn.VehicleID, TeamNum);           
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
                TempLoc = VehToSpawn.L;
                if (WeaponsFactory.length > 0)
                    TempLoc.Z -= 500;
                   
                AirdropingChinook = Spawn(class'S_Chinook_Airdrop_BH', , , TempLoc, VehToSpawn.R, , false);
                AirdropingChinook.initialize(VehToSpawn.Buyer,VehToSpawn.RefineryBuyer,VehToSpawn.VehicleID, TeamNum);          
            }
            else
            {
                SpawnLocation = VehToSpawn.L;
                if (Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset > 0 )
                    SpawnLocation.Z += Rx_MapInfo(WorldInfo.GetMapInfo()).NodAirstripDropoffHeightOffset ;
                    Veh = Spawn(VehToSpawn.VehClass,,, SpawnLocation,VehToSpawn.R,,true);
            }

        `log("Is GDI using Chinooks?" `s `showvar(bGDIIsUsingAirdrops));
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
        if(VehToSpawn.Buyer != None)
            Rx_Building(VehToSpawn.Factory).TriggerEventClass(Class'Rx_SeqEvent_FactoryEvent',VehToSpawn.Buyer.Owner,1);
        else
            Rx_Building(VehToSpawn.Factory).TriggerEventClass(Class'Rx_SeqEvent_FactoryEvent',Veh,1);
        
            return Veh;
    }
    else if (Veh != none && Rx_Vehicle_Harvester(Veh) != None)
    {
        Veh.DropToGround();
    }
 
    return None;
}
 
function DelayedGDIConstructionWarn() {
    ConstructionWarn(TEAM_GDI);
    SpawnC130GDI();
}
 
DefaultProperties
{
    MessageClass      = class'S_Message_VehicleProduced'
    GDIHarvesterClass = class'S_Vehicle_Harvester_BlackHand'
    NodHarvesterClass = class'S_Vehicle_Harvester_Nod'
}
