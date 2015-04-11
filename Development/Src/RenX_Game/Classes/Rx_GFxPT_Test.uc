class Rx_GFxPT_Test extends GFxMoviePlayer;


enum PurchaseBlockEnum
{
	PB_GDI_INFANTRY,
	PB_NOD_INFANTRY,
	PB_GDI_VEHICLES,
	PB_NOD_VEHICLES
};

struct PTPurchaseBlock
{
	var int                     ID;
	var GFxObject               PurchaseBlock;
	var GFxClikWidget           Button;
	var GFxObject               Title;
	var GFxObject               CreditCost;
};

/* unused for now
struct EquipmentBlock
{
    var GFxObject icon;
    var GFxObject title;
    var GFxObject sockettitle;
    var GFxObject background;
};

struct EquipmentDropBlock
{
    var GFxObject title; // displayed title of the weapon.
    var GFxObject background; // frame 1 = with marker, frame 2 without marker.
};*/

struct ControlButton
{
	var GFxObject Block;
	var GFxClikWidget Button;
};

var int                         TeamID;
var Rx_PurchaseSystem           PurchaseSystem;
var Rx_PRI                      PlayerRepInfo;
var Rx_Controller               PlayerControl;
var GFxObject                   CreditsCounter;
var Rx_BuildingAttachment_PT    OwnerPT;
var array<PTPurchaseBlock>      ItemBlocks;
var GFxObject                   Root;
var GFxObject                   InsufficientCredits;
var string                      PurchaseBlockNames[PurchaseBlockEnum.PB_MAX];
var string                      GDIInfantryNames[14];
var string                      NodInfantryNames[14];
var string                      GDIVehicleNames[7];
var string                      NodVehicleNames[8];
var int							GDIItemPrices;
var int							NodItemPrices;
var ControlButton               ChangePageButton;
var ControlButton               InfantryPageButton;
var GFxClikWidget               QuitPTButton;
var GFxClikWidget               ReturnButton;
var ControlButton               RefillButton;

var Rx_PT_Pawn 					DummyPawn;
var Rx_PTVehicleSpot			VehicleShowcaseSpot;
var Rx_PT_Vehicle	            dummyVeh;

/** one1: Rotation increment for single key push (or tick). */
var int                         RotationIncrement;



function SetPurchaseSystem(Rx_PurchaseSystem inPS )
{
	PurchaseSystem = inPS;
}

function SetTeam(int inTeamID)
{
	TeamID = inTeamID;
}

function Initialize(LocalPlayer locplr, Rx_Controller pContrl, Rx_BuildingAttachment_PT owner)
{
	local Rx_PTPlayerSpot dummySpot;
	local vector loc;
	local rotator rot;
	 
	Init(locplr);
	Start();
	Advance(0.0f);

	pContrl.bIsInPurchaseTerminal = true;
	pContrl.myHUD.bShowHUD = false;
	Rx_HUD(pContrl.myHUD).bCrosshairShow = false;
	PlayerControl = pContrl;
	PlayerRepInfo = Rx_PRI(pContrl.PlayerReplicationInfo);
	OwnerPT = owner;
	
	if(DummyPawn == None) {
		foreach pContrl.AllActors(class'Rx_PTPlayerSpot', dummySpot) {
			if(dummySpot.TeamNum == pContrl.GetTeamNum()) {
				loginternal(dummySpot.location);
				break;
			}	
		}
		foreach pContrl.AllActors(class'Rx_PTVehicleSpot', VehicleShowcaseSpot) {
			if(VehicleShowcaseSpot.TeamNum == pContrl.GetTeamNum()) {
				break;
			}	
		}
		loc = dummySpot.location;
		loc.Z += 50;
		rot = dummySpot.Rotation;
		//rot.Yaw += (-16384) * 2; // one1: comment this out to have original pawn rotation
		
		DummyPawn = pContrl.Spawn(class'Rx_PT_Pawn',pContrl,,loc,rot,,true);
		DummyPawn.bIsInvisible = true;
		DummyPawn.SetHidden(true);
	}

	Root = GetVariableObject("_root");

	AddFocusIgnoreKey('E');
	
	StartInfantry();

    // Equipment menu initialization
    GetVariableObject("_root.equipsecondary").GotoAndStopI(0);
    GetVariableObject("_root.equipsecondary.icon").GotoAndStopI(27); // for a reference for all icon frame numbers, see documentation!!!
    GetVariableObject("_root.equipsidearm").GotoAndStopI(0);
    GetVariableObject("_root.equipsidearm.icon").GotoAndStopI(45);
    GetVariableObject("_root.equipexplosives").GotoAndStopI(0);
    GetVariableObject("_root.equipexplosives.icon").GotoAndStopI(58);

    GFxClikWidget(GetVariableObject("_root.equipsecondary", class'GFxClikWidget')).AddEventListener('CLIK_buttonClick',ExpandSecondary);
    GFxClikWidget(GetVariableObject("_root.equipsidearm", class'GFxClikWidget')).AddEventListener('CLIK_buttonClick',ExpandSidearm);
    GFxClikWidget(GetVariableObject("_root.equipexplosives", class'GFxClikWidget')).AddEventListener('CLIK_buttonClick',ExpandExplosives);

    GFxClikWidget(GetVariableObject("_root.equipsecondary", class'GFxClikWidget')).AddEventListener('CLIK_focusOut',CollapseSecondary);
    GFxClikWidget(GetVariableObject("_root.equipsidearm", class'GFxClikWidget')).AddEventListener('CLIK_focusOut',CollapseSidearm);
    GFxClikWidget(GetVariableObject("_root.equipexplosives", class'GFxClikWidget')).AddEventListener('CLIK_focusOut',CollapseExplosives);
}

function array<GFxObject> GetDrops(string slotName)
{
    local array<GFxObject> dropArray;

    dropArray.AddItem(GetVariableObject("_root."$slotName$".drop0"));
    dropArray.AddItem(GetVariableObject("_root."$slotName$".drop1"));
    dropArray.AddItem(GetVariableObject("_root."$slotName$".drop2"));
    dropArray.AddItem(GetVariableObject("_root."$slotName$".drop3"));

    return dropArray;
}
function RemoveDropEventListeners(array<GFxObject> dropArray)
{
    GFxClikWidget(dropArray[0]).RemoveAllEventListeners("CLIK_buttonClick");
    GFxClikWidget(dropArray[1]).RemoveAllEventListeners("CLIK_buttonClick");
    GFxClikWidget(dropArray[2]).RemoveAllEventListeners("CLIK_buttonClick");
    GFxClikWidget(dropArray[3]).RemoveAllEventListeners("CLIK_buttonClick");
}

/** one1: Modified. */
function ChangeDummyPawnClass(int classNum) 
{
    local class<Rx_FamilyInfo> rxCharInfo;   
	
	if (PlayerControl.GetTeamNum() == TEAM_GDI) 
	{
	 	rxCharInfo = class'Rx_PurchaseSystem'.default.GDIInfantryClasses[classNum];	
	} else 
	{
		rxCharInfo = class'Rx_PurchaseSystem'.default.NodInfantryClasses[classNum];	
	}
	DummyPawn.SetHidden(false);
	DummyPawn.SetCharacterClassFromInfo(rxCharInfo);
	DummyPawn.RefreshAttachedWeapons();
}

function TickCredits()
{
	local string team;
	switch(TeamID){
	case TEAM_GDI: team = "GDI"; break;
	case TEAM_NOD: team = "Nod"; break;
	}
	CreditsCounter = GetVariableObject("_root."$team$"Credits.CreditCount");
	CreditsCounter.SetText(FFloor(PlayerRepInfo.GetCredits()));
}

function SetInsufficientCredits()
{
	InsufficientCredits.SetText("Insufficient Credits");
}

function ClearInsufficientCredits()
{
	InsufficientCredits.SetText(" ");
}

function ProcessInput(int keyPress)
{
	local Rotator rot;
	GetPC().ClientMessage("keyPress: "  $keyPress);
	if( keyPress == 27)
	{
		//Close();
	}
	/** one1: Added. Left or right arrow keys rotate character. */
	else if (keyPress == 0x25)
	{
		rot = DummyPawn.Rotation;
		rot.Yaw += RotationIncrement;
		DummyPawn.SetRotation(rot);
	}
	else if (keyPress == 0x27)
	{
		rot = DummyPawn.Rotation;
		rot.Yaw -= RotationIncrement;
		DummyPawn.SetRotation(rot);
	}
}

function StopTimers()
{
	OwnerPT.StopCreditTick();
	OwnerPT.StopInsufCreditsTimeout();
}

event OnClose()
{
	super.OnClose();
	PlayerControl.bIsInPurchaseTerminal = false;
	PlayerControl.bIsInPurchaseTerminalVehicleSection = false;
	PlayerControl.myHUD.bShowHUD = true;
	Rx_HUD(PlayerControl.myHUD).bCrosshairShow = true;
	DummyPawn.Destroy();
	if(dummyVeh != None)
		dummyVeh.destroy();
}

function StartInfantry()
{
	local EventData ev;
	ToInfantry(ev);
}

function DoRefillManual()
{
	PlayerControl.PerformRefill(PlayerControl);
	Close();
}

function ClosePTManual()
{
	Close();
}


function PTPurchaseBlock GetPurchaseBlock(string NameOfBlock, int IDofBlock, optional bool bDisabled = false)
{
	local PTPurchaseBlock block;

	block.ID            = IDofBlock;
	block.PurchaseBlock = GetVariableObject("_root."$NameOfBlock$IDofBlock);

	if ( bDisabled )
	{
		block.PurchaseBlock.GotoAndStopI(2);
	} 
	else
	{
		block.CreditCost = GetVariableObject("_root."$NameOfBlock$IDofBlock$".CreditCost");
		block.Button     = GFxClikWidget(GetVariableObject("_root."$NameOfBlock$IDofBlock$".Buy",class'GFxClikWidget'));
	}

	block.Title = GetVariableObject("_root."$NameOfBlock$IDofBlock$".ItemName");

	return block;
}



function string GetBuyNames(int ID, optional bool bVehicles = false )
{
	if ( TeamID == TEAM_GDI )
	{
		if (bVehicles)
		{
			return GDIVehicleNames[ID];
		} 
		else
		{
			return GDIInfantryNames[ID];
		}
		
	}
	else
	{
		if (bVehicles)
		{
			return NodVehicleNames[ID];
		} 
		else
		{
			return NodInfantryNames[ID];
		}
	}
}

function SetupGDIInfantry()
{
	CreditsCounter = GetVariableObject("_root.GDICredits.CreditCount");
	InsufficientCredits = GetVariableObject("_root.GDICredits.MessageBox");
	InsufficientCredits.SetText(" ");
	
	if (CreditsCounter != none && PlayerRepInfo !=none )
	{
		TickCredits();
		OwnerPT.StartCreditTick();
	}

	SetupInfantry(PB_GDI_INFANTRY);
}

function SetupNodInfantry()
{

	ItemBlocks.Length = 0; // Reset blocks

	CreditsCounter = GetVariableObject("_root.NodCredits.CreditCount");
	
	InsufficientCredits = GetVariableObject("_root.NodCredits.MessageBox");
	InsufficientCredits.SetText(" ");

	if (CreditsCounter != none && PlayerRepInfo !=none )
	{
		TickCredits();
		OwnerPT.StartCreditTick();
	}
	
	SetupInfantry(PB_NOD_INFANTRY);
}

function SetupInfantry(PurchaseBlockEnum BlockName)
{
	local int i;
	local bool bInfBDestroyed;
	ItemBlocks.Length = 0; // Reset blocks

	RefillButton.Block  = GetVariableObject("_root.btnRefill");
	RefillButton.Block.GotoAndStopI( ( (TeamID == TEAM_GDI) ? 1 : 2 ) );
	RefillButton.Button = GFxClikWidget(GetVariableObject("_root.btnRefill.Buy",class'GFxClikWidget'));
	RefillButton.Button.AddEventListener('CLIK_buttonClick',DoRefill);

	if(PurchaseSystem != None)
		bInfBDestroyed         = PurchaseSystem.AreHighTierPayClassesDisabled(TeamID);
	ChangePageButton.Block = GetVariableObject("_root.btnVehicles");
	ChangePageButton.Button = GFxClikWidget(GetVariableObject("_root.btnVehicles",class'GFxClikWidget'));
	ChangePageButton.Button.AddEventListener('CLIK_buttonClick',ToVehicles);
	
	InfantryPageButton.Block = GetVariableObject("_root.btnCharacters");
	InfantryPageButton.Button = GFxClikWidget(GetVariableObject("_root.btnCharacters",class'GFxClikWidget'));
	InfantryPageButton.Button.AddEventListener('CLIK_buttonClick',HasChangedToInfantryView);	

	if (PurchaseSystem != None && PurchaseSystem.AreVehiclesDisabled(TeamID, PlayerControl))
	{
		ChangePageButton.Block.GotoAndStopI(2);
	}

	if (bInfBDestroyed)
	{
		
		for(i = 0; i < 14; i++ )
		{
			ItemBlocks.AddItem(GetPurchaseBlock(PurchaseBlockNames[BlockName], i, ((i < 4) ? false : true) ));
			ItemBlocks[i].Title.SetText(GetBuyNames(ItemBlocks[i].ID));
			
			if ( ItemBlocks[i].ID < 4 )
			{
				ItemBlocks[i].Button.SetString("data",(ItemBlocks[i].ID)$"");
				ItemBlocks[i].Button.AddEventListener('CLIK_buttonClick',BuyChar);
				ItemBlocks[i].Button.AddEventListener('CLIK_rollOver', handleCharRollOver);
				if(PurchaseSystem != None)
					ItemBlocks[i].CreditCost.SetText(PurchaseSystem.GetClassPrices(TeamID,ItemBlocks[i].ID));
			} 	
		}
	} 
	else  
	{
		for (i = 0; i < 14; i++ )
		{
			ItemBlocks.AddItem(GetPurchaseBlock(PurchaseBlockNames[BlockName],i));
			ItemBlocks[i].Button.SetString("data",(ItemBlocks[i].ID)$"");
			ItemBlocks[i].Button.AddEventListener('CLIK_buttonClick',BuyChar);
			ItemBlocks[i].Button.AddEventListener('CLIK_rollOver', handleCharRollOver);
			if(PurchaseSystem != None)
				ItemBlocks[i].CreditCost.SetText(PurchaseSystem.GetClassPrices(TeamID,ItemBlocks[i].ID));
			ItemBlocks[i].Title.SetText(GetBuyNames(ItemBlocks[i].ID));
		}
	}
}


function SetupGDIVehicles()
{
	ItemBlocks.Length = 0; // Reset blocks

	CreditsCounter = GetVariableObject("_root.GDICreditBlock.CreditCount");
	
	if (CreditsCounter != none && PlayerRepInfo !=none )
	{
		TickCredits();
		OwnerPT.StartCreditTick();
	}

	InsufficientCredits = GetVariableObject("_root.GDICredits.MessageBox");
	InsufficientCredits.SetText(" ");

	SetupVehicles(PB_GDI_VEHICLES);

}
function SetupNodVehicles()
{
	ItemBlocks.Length = 0; // Reset blocks

	CreditsCounter = GetVariableObject("_root.NodCredits.CreditCount");
	
	if (CreditsCounter != none && PlayerRepInfo !=none )
	{
		TickCredits();
		OwnerPT.StartCreditTick();
	}

	InsufficientCredits = GetVariableObject("_root.NodCredits.MessageBox");
	InsufficientCredits.SetText(" ");

	SetupVehicles(PB_NOD_VEHICLES);
}

function SetupVehicles(PurchaseBlockEnum BlockName)
{
	local int i, count;
	local bool bInfBDestroyed, bAircraftDisabled;


	ItemBlocks.Length   = 0; // Reset blocks
	if(PurchaseSystem != None)
		bInfBDestroyed  = PurchaseSystem.AreVehiclesDisabled(TeamID, PlayerControl);
	bAircraftDisabled   = OwnerPT.AreAircraftDisabled();
	
	QuitPTButton = GFxClikWidget(GetVariableObject("_root.Quit",class'GFxClikWidget'));
	QuitPTButton.AddEventListener('CLIK_buttonClick',ClosePT);
	
	ReturnButton = GFxClikWidget(GetVariableObject("_root.Return",class'GFxClikWidget'));
	ReturnButton.AddEventListener('CLIK_buttonClick',HasChangedToInfantryView);

	count = (TeamID == TEAM_GDI) ? 7 : 8;
	if (bInfBDestroyed)
	{
		for(i = 0; i < count; i++ )
		{
			ItemBlocks.AddItem( GetPurchaseBlock(PurchaseBlockNames[BlockName], i, true) );
			ItemBlocks[i].Title.SetText(GetBuyNames(ItemBlocks[i].ID,true));
		}
	} 
	else
	{	
		if(bAircraftDisabled)
		{
			for (i = 0; i < count-2; i++ )
			{
			

				ItemBlocks.AddItem(GetPurchaseBlock(PurchaseBlockNames[BlockName],i));
				ItemBlocks[i].Title.SetText(GetBuyNames(ItemBlocks[i].ID,true));
				ItemBlocks[i].Button.SetString("data",(ItemBlocks[i].ID)$"");
				ItemBlocks[i].Button.AddEventListener('CLIK_buttonClick',BuyVehicle);
				ItemBlocks[i].Button.AddEventListener('CLIK_rollOver', handleVehicleRollOver);
				if(PurchaseSystem != None)
					ItemBlocks[i].CreditCost.SetText(PurchaseSystem.GetVehiclePrices(TeamID,ItemBlocks[i].ID,PurchaseSystem.AirdropAvailable(PlayerRepInfo)));
			
			}
			
			for(i = (count-2); i < count; i++ )
			{
				ItemBlocks.AddItem( GetPurchaseBlock(PurchaseBlockNames[BlockName], i, true) );
				ItemBlocks[i].Title.SetText(GetBuyNames(ItemBlocks[i].ID,true));
			}
		}
		else
		{
			for (i = 0; i < count; i++ )
			{
				ItemBlocks.AddItem(GetPurchaseBlock(PurchaseBlockNames[BlockName],i));
				ItemBlocks[i].Title.SetText(GetBuyNames(ItemBlocks[i].ID,true));
				ItemBlocks[i].Button.SetString("data",(ItemBlocks[i].ID)$"");
				ItemBlocks[i].Button.AddEventListener('CLIK_buttonClick',BuyVehicle);
				ItemBlocks[i].Button.AddEventListener('CLIK_rollOver', handleVehicleRollOver);
				if(PurchaseSystem != None)
					ItemBlocks[i].CreditCost.SetText(PurchaseSystem.GetVehiclePrices(TeamID,ItemBlocks[i].ID,PurchaseSystem.AirdropAvailable(PlayerRepInfo)));
			}
		}
	}
}
function SetupItems()
{
    // Item0 = Ion cannon beacon
    // Item1 = A-10 airstrike
    // item2 = medical kit
    // item3 = ammunition kit
    // item4 = mechanical kit
    // item5 = motion sensor
    // item6 = MG sentry
    // item7 = AT sentry
	local array<GFxClikWidget> items;

    GFxClikWidget(GetVariableObject("_root.GDIItems.Item2",class'GFxClikWidget')).SetVisible(false);
    GFxClikWidget(GetVariableObject("_root.GDIItems.Item3",class'GFxClikWidget')).SetVisible(false);
    GFxClikWidget(GetVariableObject("_root.GDIItems.Item4",class'GFxClikWidget')).SetVisible(false);
    GFxClikWidget(GetVariableObject("_root.GDIItems.Item5",class'GFxClikWidget')).SetVisible(false);
    GFxClikWidget(GetVariableObject("_root.GDIItems.Item6",class'GFxClikWidget')).SetVisible(false);
    GFxClikWidget(GetVariableObject("_root.GDIItems.Item7",class'GFxClikWidget')).SetVisible(false);

	ActionScriptVoid("HideItems");

	if(TeamID == TEAM_GDI)
	{
        InsufficientCredits = GetVariableObject("_root.GDICredits.MessageBox");

		items.AddItem(GFxClikWidget(GetVariableObject("_root.GDIItems.Item0.Buy",class'GFxClikWidget')));
		GetVariableObject("_root.GDIItems.Item0.ItemName").SetText("ION Cannon Beacon");
		GetVariableObject("_root.GDIItems.Item0.CreditCost").SetText(GDIItemPrices);
		items[0].SetString("data","ION Cannon Beacon");
		items[0].AddEventListener('CLIK_buttonClick',BuyItem);

		items.AddItem(GFxClikWidget(GetVariableObject("_root.GDIItems.Item1.Buy",class'GFxClikWidget')));
		GetVariableObject("_root.GDIItems.Item1.ItemName").SetText("A-10 Airstrike");
		GetVariableObject("_root.GDIItems.Item1.CreditCost").SetText("700");
		items[1].SetString("data","A-10 Airstrike");
		items[1].AddEventListener('CLIK_buttonClick',BuyAirstrike);
    
        // From here on, fill in the rest of the button data with the known
        // prices and description.
        
		InsufficientCredits.SetText(" ");
	}
	else
	{
        InsufficientCredits = GetVariableObject("_root.NodCredits.MessageBox");

		items.AddItem(GFxClikWidget(GetVariableObject("_root.NodItems.Item0.Buy",class'GFxClikWidget')));
		GetVariableObject("_root.NodItems.Item0.ItemName").SetText("Nuke Beacon");
		GetVariableObject("_root.NodItems.Item0.CreditCost").SetText(NodItemPrices);
		items[0].SetString("data","Nuke Beacon");
		items[0].AddEventListener('CLIK_buttonClick',BuyItem);

		items.AddItem(GFxClikWidget(GetVariableObject("_root.NodItems.Item1.Buy",class'GFxClikWidget')));
		GetVariableObject("_root.NodItems.Item1.ItemName").SetText("AC130 Airstrike");
        GetVariableObject("_root.NodItems.Item1.CreditCost").SetText("700");
		items[1].SetString("data","Nuke Beacon");
		items[1].AddEventListener('CLIK_buttonClick',BuyAirstrike);

		InsufficientCredits.SetText(" ");
	}
	`log(items[0]); // this is just to prevent a compiler warning about items beeing unused
}





//=====================================//
//      Group:Left buttonclick evnt    //
//=====================================//
function ExpandSecondary(EventData data)
{
    local array<GFxObject> dropArray; // List for all weapons available to the player.
    GetVariableObject("_root.equipsecondary").GotoAndStopI(2); // Can't get the drop list if the current frame is 1.
    
    dropArray = GetDrops("equipsecondary"); 

    if(PlayerControl.GetTeamNum() == TEAM_GDI)
    {
        dropArray[0].GetObject("title").SetText("Marksman Rifle");
        GFxClikWidget(dropArray[0]).AddEventListener('CLIK_buttonClick', EquipMarksmanRifle);
        dropArray[0].GetObject("background").GotoAndStopI(1);
        dropArray[1].GetObject("background").GotoAndStopI(0);
        dropArray[2].GetObject("background").GotoAndStopI(0);
        dropArray[3].GetObject("background").GotoAndStopI(0);
    }
    else
    {
        dropArray[0].GetObject("title").SetText("Marksman Rifle");
        GFxClikWidget(dropArray[0]).AddEventListener('CLIK_buttonClick', EquipMarksmanRifle);
        dropArray[0].GetObject("background").GotoAndStopI(1);
        dropArray[1].GetObject("background").GotoAndStopI(0);
        dropArray[2].GetObject("background").GotoAndStopI(0);
        dropArray[3].GetObject("background").GotoAndStopI(0);
    }
}
function ExpandSidearm(EventData data)
{
    local array<GFxObject> dropArray; // List for all weapons available to the player.
    GetVariableObject("_root.equipsidearm").GotoAndStopI(2); // Can't get the drop list if the current frame is 1.
    
    dropArray = GetDrops("equipsidearm"); 

    if(PlayerControl.GetTeamNum() == TEAM_GDI)
    {
        dropArray[0].GetObject("title").SetText("Marksman Rifle");
        GFxClikWidget(dropArray[0]).AddEventListener('CLIK_buttonClick', EquipMarksmanRifle);
        dropArray[0].GetObject("background").GotoAndStopI(1);
        dropArray[1].GetObject("background").GotoAndStopI(0);
        dropArray[2].GetObject("background").GotoAndStopI(0);
        dropArray[3].GetObject("background").GotoAndStopI(0);
    }
    else
    {
        dropArray[0].GetObject("title").SetText("Marksman Rifle");
        GFxClikWidget(dropArray[0]).AddEventListener('CLIK_buttonClick', EquipMarksmanRifle);
        dropArray[0].GetObject("background").GotoAndStopI(1);
        dropArray[1].GetObject("background").GotoAndStopI(0);
        dropArray[2].GetObject("background").GotoAndStopI(0);
        dropArray[3].GetObject("background").GotoAndStopI(0);
    }
}
function ExpandExplosives(EventData data)
{
    local array<GFxObject> dropArray; // List for all weapons available to the player.
    GetVariableObject("_root.equipexplosives").GotoAndStopI(2); // Can't get the drop list if the current frame is 1.
    
    dropArray = GetDrops("equipexplosives"); 

    if(PlayerControl.GetTeamNum() == TEAM_GDI)
    {
        dropArray[0].GetObject("title").SetText("Marksman Rifle");
        GFxClikWidget(dropArray[0]).AddEventListener('CLIK_buttonClick', EquipMarksmanRifle);
        dropArray[0].GetObject("background").GotoAndStopI(1);
        dropArray[1].GetObject("background").GotoAndStopI(0);
        dropArray[2].GetObject("background").GotoAndStopI(0);
        dropArray[3].GetObject("background").GotoAndStopI(0);
    }
    else
    {
        dropArray[0].GetObject("title").SetText("Marksman Rifle");
        GFxClikWidget(dropArray[0]).AddEventListener('CLIK_buttonClick', EquipMarksmanRifle);
        dropArray[0].GetObject("background").GotoAndStopI(1);
        dropArray[1].GetObject("background").GotoAndStopI(0);
        dropArray[2].GetObject("background").GotoAndStopI(0);
        dropArray[3].GetObject("background").GotoAndStopI(0);
    }
}

//=====================================//
//      Group:Left buttonclick evnt    //
//=====================================//
function CollapseSecondary(EventData data)
{
    
        RemoveDropEventListeners(GetDrops("equipsecondary"));
        GetVariableObject("_root.equipsecondary").GotoAndStopI(1);
}
function CollapseSidearm(EventData data)
{
        RemoveDropEventListeners(GetDrops("equipsidearm"));
        GetVariableObject("_root.equipsidearm").GotoAndStopI(1);
}
function CollapseExplosives(EventData data)
{
        RemoveDropEventListeners(GetDrops("equipexplosives"));
        GetVariableObject("_root.equipexplosives").GotoAndStopI(1);
}


//=====================================//
// Scrolling List: item clicked        //
//=====================================//
function EquipMarksmanRifle(EventData data)
{
    PlayerControl.ConsoleCommand("setsecondaryweapon renx_game.rx_weapon_marksmanrifle_gdi");
}
function EquipCarbine(EventData data)
{
    PlayerControl.ConsoleCommand("setsecondaryweapon renx_game.rx_weapon_marksmanrifle_gdi");
}
function EquipSMG(EventData data)
{
    PlayerControl.ConsoleCommand("setsidearmweapon renx_game.rx_weapon_smg");
}
function EquipHeavyPistol(EventData data)
{
    PlayerControl.ConsoleCommand("setsidearmweapon renx_game.rx_weapon_heavypistol");
}
function EquipPistol(EventData data)
{
    PlayerControl.ConsoleCommand("setsidearmweapon renx_game.rx_weapon_pistol");
}



//=====================================//
// Purchase btn evnt: button click     //
//=====================================//
function BuyChar(EventData data)
{
	local int charNum;
	local int Price;

	charNum = int(data._this.GetObject("target").GetString("data"));
	
	if(PurchaseSystem == None)
		Price = 0;
	else 
	 	Price = PurchaseSystem.GetClassPrices(TeamID,charNum);
	
	if (Price > PlayerRepInfo.GetCredits())
	{
		SetInsufficientCredits();
		OwnerPT.StartInsufCreditsTimeout();
	} 
	else
	{
		PlayerControl.PurchaseCharacter(TeamID,charNum);
		Close();
	}	
}

function BuyVehicle( EventData data )
{
	local int vehNum;
	local int Price;

	vehNum = int(data._this.GetObject("target").GetString("data"));

	if(PurchaseSystem == None)
		Price = 0;
	else 
		Price = PurchaseSystem.GetVehiclePrices(TeamID,vehNum,PurchaseSystem.AirdropAvailable(PlayerRepInfo));

	if (Price > PlayerRepInfo.GetCredits())
	{
		SetInsufficientCredits();
		OwnerPT.StartInsufCreditsTimeout();
	} 
	else
	{
		PlayerControl.PurchaseVehicle(TeamID,vehNum);
		Close();
	}
}

function BuyAirstrike( EventData data )
{
    
	if (700 > PlayerRepInfo.GetCredits()){
		SetInsufficientCredits();
		OwnerPT.StartInsufCreditsTimeout();
	} else{
	    if(TeamID == TEAM_GDI)
	        PlayerControl.ConsoleCommand("setitem renx_game.rx_weapon_airstrike_gdi");
	    else
	        PlayerControl.ConsoleCommand("setitem renx_game.rx_weapon_airstrike_nod"); 
        Close();
	}

}

function BuyItem( EventData data )
{
	//local int ItemNum;
	local int Price;

	// GreaseMonk:	Need code here that gives the Nuke or the Ion cannon to the player
	//				and substract the price from the player.
	//				prices are now just one string because it's one item, and an array
	//				of length 1 is forbidden so... 
	//				ItemNum should return "Ion Cannon" or "Nuke".
	//				Price is defined below in defaultproperties.
	//ItemNum = int(data._this.GetObject("target").GetString("data"));
	
	if(TeamID == TEAM_GDI){
		Price = GDIItemPrices;
	}
	else{
		Price = NodItemPrices;
	}

	if (Price > PlayerRepInfo.GetCredits()){
		SetInsufficientCredits();
		OwnerPT.StartInsufCreditsTimeout();
	} 
	else{
		if(TeamID == TEAM_GDI)
			PlayerControl.EquipION();
		else if(TeamID == TEAM_NOD)
			PlayerControl.EquipNuke();
		Close();
	}
}
function DoRefill( EventData ev )
{
	PlayerControl.PerformRefill(PlayerControl);
	Close();
}


//=====================================//
// Group item click event:             //
//=====================================//
function ToInfantry( EventData data )
{
	if ( TeamID == TEAM_GDI )
	{
		StopTimers();
		Root.GotoAndStopI(1);
		SetupGDIInfantry();
		SetupGDIVehicles();
	} 
	else
	{
		StopTimers();
		Root.GotoAndStopI(2);
		SetupNodInfantry();
		SetupNodVehicles();
	}
	SetupItems();
}

function ToVehicles( EventData ev )
{
	PlayerControl.bIsInPurchaseTerminalVehicleSection=true;
}


function HasChangedToInfantryView( EventData ev )
{
	PlayerControl.bIsInPurchaseTerminalVehicleSection=false;
}

//=====================================//
// Exit btn evnt: button click         //
//=====================================//
function ClosePT( EventData data )
{
	Close();
}

//=====================================//
// button evnt: hover on top           //
//=====================================//
function handleCharRollOver(GFxClikWidget.EventData ev)
{
	local int charNum;
	charNum = int(ev._this.GetObject("target").GetString("data"));
	ChangeDummyPawnClass(charNum);
}

/** one1: Modified; do not spawn new actor each roll-over, just replace skeletalmesh. */
function handleVehicleRollOver(GFxClikWidget.EventData ev)
{
	local int vehNum;
	local class<Rx_Vehicle> vehClass;
	
	PlayerControl.bIsInPurchaseTerminalVehicleSection=true;
	vehNum = int(ev._this.GetObject("target").GetString("data"));
	
	if (dummyVeh == None) 
	{
		dummyVeh = PlayerControl.Spawn(class'Rx_PT_Vehicle', PlayerControl, , VehicleShowcaseSpot.Location, VehicleShowcaseSpot.Rotation, , true);
	}
	
	if(PlayerControl.GetTeamNum() == TEAM_GDI) {
	 	vehClass = class'Rx_PurchaseSystem'.default.GDIVehicleClasses[vehNum];	
	} else {
		vehClass = class'Rx_PurchaseSystem'.default.NodVehicleClasses[vehNum];	
	}	

	dummyVeh.SetSkeletalMesh(vehClass.default.SkeletalMeshForPT);
}



DefaultProperties
{
	bAutoPlay = false
	bAllowInput = true
	bCaptureInput = true
	bCaptureMouseInput = true
	bShowHardwareMouseCursor = true
	//MovieInfo = SwfMovie'RenXPT_Test.RenXPT_Test'

	PurchaseBlockNames[PB_GDI_INFANTRY] = "GDIInfantry"
	PurchaseBlockNames[PB_NOD_INFANTRY] = "NodInfantry"
	PurchaseBlockNames[PB_GDI_VEHICLES] = "GDIVehicles"
	PurchaseBlockNames[PB_NOD_VEHICLES] = "NodVehicles"

	GDIInfantryNames[0]  = "Soldier"	
	GDIInfantryNames[1]  = "Shotgunner"
	GDIInfantryNames[2]  = "Grenadier"
	GDIInfantryNames[3]  = "Engineer"
	GDIInfantryNames[4]  = "Officer"
	GDIInfantryNames[5]  = "Rocket Soldier"
	GDIInfantryNames[6]  = "McFarland"
	GDIInfantryNames[7]  = "Gunner"
	GDIInfantryNames[8]  = "Deadeye"
	GDIInfantryNames[9]  = "Patch"
	GDIInfantryNames[10] = "Havoc"
	GDIInfantryNames[11] = "Sydney"
	GDIInfantryNames[12] = "Mobius"
	GDIInfantryNames[13] = "Hotwire"

	NodInfantryNames[0]  = "Soldier"
	NodInfantryNames[1]  = "Shotgunner"
	NodInfantryNames[2]  = "Flame Trooper"
	NodInfantryNames[3]  = "Engineer"
	NodInfantryNames[4]  = "Officer"
	NodInfantryNames[5]  = "Rocket Soldier"
	NodInfantryNames[6]  = "Chemical Trooper"
	NodInfantryNames[7]  = "SBH"
	NodInfantryNames[8]  = "Black Hand Sniper"
	NodInfantryNames[9]  = "Laser Chain Gunner"
	NodInfantryNames[10] = "Sakura"
	NodInfantryNames[11] = "Raveshaw"
	NodInfantryNames[12] = "Mendoza"
	NodInfantryNames[13] = "Technician"

	NodVehicleNames[0]   = "Buggy"
	NodVehicleNames[1]   = "APC"
	NodVehicleNames[2]   = "Artillery"
	NodVehicleNames[3]   = "Flame Tank"
	NodVehicleNames[4]   = "Light Tank"
	NodVehicleNames[5]   = "Stealth Tank"
	NodVehicleNames[6]   = "Chinook"
	NodVehicleNames[7]   = "Apache"


	GDIVehicleNames[0]   = "Humvee"
	GDIVehicleNames[1]   = "APC"
	GDIVehicleNames[2]   = "MRLS"
	GDIVehicleNames[3]   = "Medium Tank"
	GDIVehicleNames[4]   = "Mammoth Tank"
	GDIVehicleNames[5]   = "Chinook"
	GDIVehicleNames[6]   = "Orca"

	GDIItemPrices	= 1000
	NodItemPrices	= 1000

	/** one1: Added. */
	RotationIncrement = 1000
}
