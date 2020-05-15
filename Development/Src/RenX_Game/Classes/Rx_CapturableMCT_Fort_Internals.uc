class Rx_CapturableMCT_Fort_Internals extends Rx_CapturableMCT_Internals
    notplaceable;
	
var Array<class<Rx_Vehicle_PTInfo> >  CustomGDIVehicleList, CustomNodVehicleList, DefaultGDIVehicleList ,DefaultNodVehicleList;

var Rx_PurchaseSystem PS;

/*
*	We take input from here since this is called every time FlagTeam is replicated. This
*	is always called during initial replication (which helps with recently-joining player)
*	and further one (which happens when tech building is captured/neutralized in game-time)
*/

simulated function Init(Rx_Building Visuals, bool isDebug )
{
    local Rx_MapInfo RxMapInfo;

    super(Rx_Building_Team_Internals).Init(Visuals, isDebug);

    // Because this needs to be called first before FlagChanged right now, use the super-superclass version of Init

    RxMapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());

    GetPurchaseSystem();

    if(RxMapInfo != None)
    {
        DefaultGDIVehicleList= RxMapInfo.GDIVehicleArray;
        DefaultNodVehicleList = RxMapInfo.NodVehicleArray;
    }
    else
    {
        DefaultGDIVehicleList= PS.default.GDIVehicleClasses;
        DefaultNodVehicleList = PS.default.NodVehicleClasses;
    }

    if(Rx_CapturableMCT_Fort(Visuals) != None)
    {
        //You will want to add variables in the building class for the internals to get it
        CustomGDIVehicleList = Rx_CapturableMCT_Fort(Visuals).CustomGDIVehicleList;
        CustomNodVehicleList = Rx_CapturableMCT_Fort(Visuals).CustomNodVehicleList;
        // PrintingToLogCustomTanks();
    }

    MICFlag = BuildingSkeleton.CreateAndSetMaterialInstanceConstant(0);
    FlagChanged();
    Armor=0;
    
    if(ROLE == ROLE_Authority)
        AddToGRIArray();
    
}

simulated function GetPurchaseSystem()
{

    if(PS == None) // first, we get the PurchaseSystem and store it in
    {
        if(WorldInfo.Game != None) //Server side
        {
            if(Rx_Game(WorldInfo.Game) != None)
                PS = Rx_Game(WorldInfo.Game).PurchaseSystem;
        }
        else if (WorldInfo.GRI != None) // Client side
        {
            if(Rx_GRI(WorldInfo.GRI) != None)
                PS = Rx_GRI(WorldInfo.GRI).PurchaseSystem;
        }
    }
}

function PrintingToLogCustomTanks()
{

    local int index;
    
    `log("*****----GDI CUSTOM TANKS----*******");
    if(CustomGDIVehicleList.Length==0)
    {
        `log("&&&&&& THERE ARE NO GDI TANKSS &&&&&&&&&&");

    }

    `log("CustomGDIVehicleList length = "@CustomGDIVehicleList.Length);
    `log("CustomNodVehicleList length = "@CustomNodVehicleList.Length);

    for(index=0;index<CustomGDIVehicleList.Length;index++)
    {
        `log(CustomGDIVehicleList[index]);
    }

    `log("*****----GDI CUSTOM TANKS----*******");
    `log("*****----NOD CUSTOM TANKS----*******");


    for(index=0;index<CustomNodVehicleList.Length;index++)
    {
        `log(CustomNodVehicleList[index]);
    }

    `log("*****----NOD CUSTOM TANKS----*******");


}

simulated function FlagChanged() 
{
	super.FlagChanged();

    if(PS == None)
        GetPurchaseSystem();

    if(PS != None)
    {
	   UpdatePurchaseSystem();
    }
    else if(!IsTimerActive('PendingUpdatePurchaseSystem'))
    {
        SetTimer(0.5, true, 'PendingUpdatePurchaseSystem');
    }
}

// fallback function if PurchaseSystem keeps failing to be found

simulated function PendingUpdatePurchaseSystem()
{
    if(PS == None)
        GetPurchaseSystem();

    if(PS != None)
    {
        ClearTimer('PendingUpdatePurchaseSystem');
        UpdatePurchaseSystem();
    }
}

simulated function UpdatePurchaseSystem()
{




    if(BuildingVisuals == None) // if we haven't passed Init yet, return for now and wait for it to be called later
        return;    

    if(FlagTeam == TEAM_GDI) 
    {
   
      
        PS.GDIVehicleClasses = CustomGDIVehicleList; //Instead of chinook
//      `log((CustomGDIVehicleList[0]@" has been added to the purchase system for GDI team."));
//      `log((CustomGDIVehicleList[1]@" has been added to the purchase system for GDI team."));
       
    }
      
    else 
    {
        PS.GDIVehicleClasses = DefaultGDIVehicleList;
//        `log("GDI purchase system rolled up to default");

    }
       
    if(FlagTeam == TEAM_NOD) 
    {
        PS.NodVehicleClasses = CustomNodVehicleList;
//        `log((CustomNodVehicleList[0]@" has been added to the purchase system for NOD team."));
//        `log((CustomNodVehicleList[1]@" has been added to the purchase system for NOD team."));  
    } 
    else
    {  
        PS.NodVehicleClasses = DefaultNodVehicleList;
//        `log("NOD purchase system rolled up to default");
    }



}

DefaultProperties
{
   
   
}
