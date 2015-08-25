/*********************************************************
*
* File: Rx_GFxPurchaseMenu.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class handles the creation and modification of the 
* Purchase Menu when opening a terminal.
* It is created and called by Rx_BuildingAttachment_PT.uc.
* 
* Related Flash content:   RenXPurchaseMenu.fla
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************
*  Drawboards
* 
* after finishing init, set the first selection.
* 
* 
* item clik cause the group to set selected on the selection
* use the item click on the selected to show dummy pawn
* 
* purchase button set
* 
* 
* 
* 
* 
* 
* 
*********************************************************/
class Rx_GFxPurchaseMenu extends GFxMoviePlayer;


var Rx_BuildingAttachment_PT                    rxBuildingOwner;
var Rx_PurchaseSystem                           rxPurchaseSystem;
var Rx_Controller                               rxPC;
var Rx_Hud                                      rxHUD;
var Rx_PRI                                      rxPRI;
var int                                         TeamID;
var float                                         PlayerCredits;
var int                                         VehicleCount;

enum PurchaseBlockType
{
	EPBT_MENU,
	EPBT_CLASS,
	EPBT_WEAPON,
	EPBT_ITEM,
	EPBT_VEHICLE
};

struct PTMenuBlock
{
	//id is obsolete now. use icon instead
	var int 									id;
	var Texture                                 PTIconTexture;
	var PurchaseBlockType                       BlockType;
	var string 									hotkey;
	var string 									title;
	var string 									cost;
	var byte 									type;
	var int 									iconID;
	var string 									desc;
	var byte 									damage;
	var byte 									range;
	var byte 									rateOfFire;
	var byte 									magCap;
	var bool                                    bEnable;
	var bool                                    bSilo;
	
	StructDefaultProperties
	{
		id		        =	0
		PTIconTexture   =   Texture2D'RenXPurchaseMenu.T_WeaponIcon_MissingCameo'
		BlockType       =   EPBT_MENU
		hotkey	        =	""
		title	        =	""
		cost	        =	""
		type	        =	0
		iconID	        =	0
		desc	        =	""
		damage	        =	0
		range	        =	0
		rateOfFire	    =	0
		magCap	        =	0
		bEnable         =   true
		bSilo           =   false
	}
};


struct PTVehicleBlock
{
	var int 									id;
	var Texture                                 PTIconTexture;
	var PurchaseBlockType                       BlockType;
	var string 									hotkey;
	var string 									title;
	var string 									cost;
	var int 									iconID;
	var string 									desc;
	var bool                                    bEnable;
	var bool                                    bAircraft;
	StructDefaultProperties
	{
		id		    =	0
		BlockType   =   EPBT_VEHICLE
		hotkey	    =	""
		title	    =	""
		cost	    =	""
		iconID	    =	0
		desc	    =	""
		bEnable     =   true
		bAircraft   =   false
	}
};

struct PTEquipmentBlock
{
	var int 									id;
	var Texture                                 PTIconTexture;
	var string 									title;
	var string 									desc;
	//obsolete. please use icon instead
	var int 									iconID;
	var string 									hotkey;
	//var array<>                                 BindingList;
	var bool                                    bEnable;
	var bool                                    bFree;
	var class<Rx_Weapon>                        WeaponClass;
	StructDefaultProperties
	{
		id		        =	0
		title			=	""
		desc			=	""
		iconID			=	0
		bEnable         =   true
		bFree           =   false
		WeaponClass     =   none
	}
};

var PTMenuBlock 								GDIMainMenuData[10];
var PTMenuBlock 								GDIItemMenuData[8];
var PTMenuBlock 								GDIWeaponMenuData[7];
var PTMenuBlock 								GDIClassMenuData[10];
var PTVehicleBlock 								GDIVehicleMenuData[8];

var PTMenuBlock 								NodMainMenuData[10];
var PTMenuBlock 								NodItemMenuData[8];
var PTMenuBlock 								NodWeaponMenuData[7];
var PTMenuBlock 								NodClassMenuData[10];
var PTVehicleBlock 								NodVehicleMenuData[8];

var array<PTEquipmentBlock>                     GDIEquipmentSideArmData;
var array<PTEquipmentBlock>                     NodEquipmentSideArmData;
var array<PTEquipmentBlock>                     GDIEquipmentExplosiveData;
var array<PTEquipmentBlock>                     NodEquipmentExplosiveData;

// var GFxObject ChatBox;
var GFxObject 									Root;

var GFxObject 									VehicleDrawer, EquipmentDrawer, BottomDrawer, MainDrawer, ClassDrawer, ItemDrawer, WeaponDrawer;

var GFxObject                                   CursorMC;

//ButtonGroup
var GFxClikWidget 								MainMenuGroup;
var GFxClikWidget 								ClassMenuGroup;
var GFxClikWidget 								ItemMenuGroup;
var GFxClikWidget 								WeaponMenuGroup;
var GFxClikWidget 								VehicleMenuGroup;
var GFxClikWidget                               EquipmentMenuGroup;

var GFxObject 									ExitTween, BackTween, VehicleInfoTween, CreditsTween, PurchaseTween;
var GFxClikWidget 								ExitButton, BackButton, VehicleInfoButton, CreditsButton, PurchaseButton;



//MainDrawer widgets
var GFxClikWidget 								MainMenuButton[10];
//ClassDrawer widgets
var GFxClikWidget 								ClassMenuButton[10];
//vehicleDrawer widgets
var GFxClikWidget 								VehicleMenuButton[8];
//sidearms and explosive Drawer widgets 
//TODO:Not implemented yet
var GFxClikWidget 								WeaponMenuButton[10];
//airstrikes, kits, superpower 
//TODO: not implemented yet
var GFxClikWidget 								ItemMenuButton[10];

//Equipment Button
var GFxClikWidget 								EquipSideArmButton;
var GFxClikWidget 								EquipExplosivesButton;
var GFxClikWidget 								EquipSideArmList;
var GFxClikWidget 								EquipExplosivesList;


var Rx_PTPlayerSpot             				PawnShowcaseSpot;
var Rx_PT_Pawn 									DummyPawn;
var Rx_PTVehicleSpot							VehicleShowcaseSpot;
var Rx_PT_Vehicle	            				DummyVehicle;

/** one1: Rotation increment for single key push (or tick). */
var int                         				RotationIncrement;
/** shahman: Rotation increment for mouse click. */
var float                         				MouseRotationIncrement;
var float                                       LastCursorXPosition;

var bool										bMainDrawerOpen, bClassDrawerOpen, bItemDrawerOpen, bWeaponDrawerOpen, bEquipmentDrawerOpen, bVehicleDrawerOpen;
var bool                                        bIsInTransition;

var private class<Rx_Weapon>                    OwnedSidearm, OwnedExplosive, OwnedItem;
var private class<Rx_FamilyInfo>                OwnedFamilyInfo;



// function UpdateReferences();

function SetTeam(int inTeamID)
{
	TeamID    =   inTeamID;
}

function Initialize(LocalPlayer player, Rx_BuildingAttachment_PT PTOwner)
{	
	local byte i; 
	local string WidgetTeamPrefix;
	local array<PTEquipmentBlock> explosiveData;
	local array<PTEquipmentBlock> sidearmData;
	local Rx_InventoryManager rxInv;

	`log("<PT Log> ------------------ [ Setting up ] ------------------ ");
	Init(player);
	Start();
	Advance(0.0f);

	
	rxPC						=	Rx_Controller(GetPC());
	rxHUD						=	Rx_HUD(rxPC.myHUD);
	rxBuildingOwner				=   PTOwner;
	rxPRI						=	Rx_PRI(rxPC.PlayerReplicationInfo);

	rxPC.bIsInPurchaseTerminal	=   true;
	rxHUD.bShowHUD              =   false;
	rxHUD.bCrosshairShow        =   false;
	
	//store items here
	rxInv                       =   Rx_InventoryManager(RxPC.Pawn.InvManager);

	// 	[ASSIGN ROOT MC]
	Root                        =   GetVariableObject("_root");

	//ButtonGroup Widget
	MainMenuGroup               =   InitButtonGroupWidget("mainMenu", Root);
	ClassMenuGroup				=	InitButtonGroupWidget("classMenu", Root);
	ItemMenuGroup				=	InitButtonGroupWidget("itemMenu", Root);
	WeaponMenuGroup				=	InitButtonGroupWidget("weaponMenu", Root);
	VehicleMenuGroup			=	InitButtonGroupWidget("vehicleMenu", Root);
	EquipmentMenuGroup          =   InitButtonGroupWidget("equipmentMenu", Root);


	VehicleDrawer				=	GetVariableObject("_root.vehicleDrawer");
	EquipmentDrawer				=	GetVariableObject("_root.equipmentDrawer");
	BottomDrawer				=	GetVariableObject("_root.bottomDrawer");
	MainDrawer					=	GetVariableObject("_root.mainDrawer");
	ClassDrawer					=	GetVariableObject("_root.classDrawer");
	ItemDrawer					=	GetVariableObject("_root.itemDrawer");
	WeaponDrawer				=	GetVariableObject("_root.weaponDrawer");

	ExitTween 					=	GetVariableObject("_root.bottomDrawer.exitButton");
	BackTween 					=	GetVariableObject("_root.bottomDrawer.backButton");
	VehicleInfoTween 			=	GetVariableObject("_root.bottomDrawer.vehicleInfoButton");
	CreditsTween 				=	GetVariableObject("_root.bottomDrawer.creditsButton");
	PurchaseTween 				=	GetVariableObject("_root.bottomDrawer.purchaseButton");

	CursorMC                    =   GetVariableObject("_root.CursorMC");

	LastCursorXPosition         =   CursorMC.GetFloat("x");

	WidgetTeamPrefix            =   TeamID == TEAM_GDI? "GDI" : "Nod";

	GetVariableObject("_root.bottomDrawer.exitButton.PTButton").GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
	GetVariableObject("_root.bottomDrawer.backButton.PTButton").GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
	GetVariableObject("_root.bottomDrawer.vehicleInfoButton.PTButton").GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
	GetVariableObject("_root.bottomDrawer.creditsButton.PTButton").GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
	GetVariableObject("_root.bottomDrawer.purchaseButton.PTButton").GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
	GetVariableObject("_root.equipmentDrawer.tween.equipsidearm").GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
	GetVariableObject("_root.equipmentDrawer.tween.equipexplosives").GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);

	//	[ASSIGN EXIT BACK VEHICLE CREDITS PURCHASEBUTTON]
	ExitButton 					=	GFxClikWidget(GetVariableObject("_root.bottomDrawer.exitButton.PTButton."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));
	ExitButton.SetString("label", "<b>"$"<font size='14'>Exit [</font>" $ "<font size='10'> Escape </font>" $ "<font size='14'>]</font>"$"</b>");

	BackButton 					=	GFxClikWidget(GetVariableObject("_root.bottomDrawer.backButton.PTButton."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));
	BackButton.SetString("label", "<b>"$"<font size='14'>Back [</font>" $ "<font size='10'> Back Space </font>" $ "<font size='14'>]</font>"$"</b>");

	VehicleInfoButton 			=	GFxClikWidget(GetVariableObject("_root.bottomDrawer.vehicleInfoButton.PTButton."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));

	CreditsButton 				=	GFxClikWidget(GetVariableObject("_root.bottomDrawer.creditsButton.PTButton."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));

	PurchaseButton 				=	GFxClikWidget(GetVariableObject("_root.bottomDrawer.purchaseButton.PTButton."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));
	PurchaseButton.SetString("label", "<b>"$"<font size='14'>Purchase [</font>" $ "<font size='10'> Enter </font>" $ "<font size='14'>]</font>"$"</b>");


	OwnedFamilyInfo = Rx_Pawn(RxPC.Pawn).GetRxFamilyInfo();

	if (rxInv.SidearmWeapons.Length > 0) {
		OwnedSidearm            =   rxInv.SidearmWeapons[rxInv.SidearmWeapons.Length - 1];
	}
	if (rxInv.ExplosiveWeapons.Length > 0){
		if (OwnedFamilyInfo == class'Rx_FamilyInfo_GDI_Hotwire' || OwnedFamilyInfo == class'Rx_FamilyInfo_Nod_Technician') {
			//OwnedExplosive      = rxInv.PrimaryWeapons[rxInv.PrimaryWeapons.Find(class'Rx_Weapon_ProxyC4')];
			OwnedExplosive      =   rxInv.ExplosiveWeapons[rxInv.ExplosiveWeapons.Length - 1];
		} else {
			OwnedExplosive      =   rxInv.ExplosiveWeapons[rxInv.ExplosiveWeapons.Length - 1];
		}
	}
	if (rxInv.Items.Length > 0){
		OwnedItem               =   rxInv.Items[rxInv.Items.Length - 1];
	}



	`log("<PT Log> rxPC.bJustBaughtEngineer= "$ rxPC.bJustBaughtEngineer);
	`log("<PT Log> rxPC.bJustBaughtHavocSakura= "$ rxPC.bJustBaughtHavocSakura);
	`log("<PT Log> OwnedFamilyInfo= " $ OwnedFamilyInfo);
	`log("");
	`log("<PT Log> OwnedSidearm= " $ OwnedSidearm);
	`log("<PT Log> OwnedExplosive= " $ OwnedExplosive);
	`log("<PT Log> OwnedItem= " $ OwnedItem);
	`log("");


// 	if (rxPC.CurrentSidearmWeapon == none) {
// 		//then use rxinventory defaults
// 		rxPC.CurrentSidearmWeapon = rxInv.SidearmWeapons[rxInv.SidearmWeapons.Length - 1];
// 	}
	`log("<PT Log> rxPC.CurrentSidearmWeapon= " $ rxPC.CurrentSidearmWeapon);

	if (rxPC.CurrentExplosiveWeapon == none) {
		//then set defaults based on class
// 		if (rxPC.bJustBaughtEngineer 
// 		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' 
// 		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician'){
// 			//rxPC.CurrentExplosiveWeapon = rxInv.PrimaryWeapons[rxInv.PrimaryWeapons.Find(class'Rx_Weapon_ProxyC4')];
// 		} else {
// 			//rxPC.CurrentExplosiveWeapon = rxInv.ExplosiveWeapons[rxInv.ExplosiveWeapons.Length - 1];
// 		}
	}
	`log("<PT Log> rxPC.CurrentExplosiveWeapon= " $ rxPC.CurrentExplosiveWeapon);


	// 	[ASSIGN EQUIPMENT]
	// 	[ASSIGN MAINMENU]
	//  [ASSIGN CHARACTERS]
	// 	[ASSIGN CHATBOX]

	for (i = 0; i < 10; i++) {
		
		GetVariableObject("_root.mainDrawer.tween.btnMenu"$i).GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
		GetVariableObject("_root.classDrawer.tween.btnMenu"$i).GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
		GetVariableObject("_root.itemDrawer.tween.btnMenu"$i).GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);
		GetVariableObject("_root.weaponDrawer.tween.btnMenu"$i).GotoAndStopI(TeamID == TEAM_GDI? 1 : 2);

		MainMenuButton[i] 		= 	GFxClikWidget(GetVariableObject("_root.mainDrawer.tween.btnMenu"$i $"."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));
		ClassMenuButton[i] 		=	GFxClikWidget(GetVariableObject("_root.classDrawer.tween.btnMenu"$i $"."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));
		ItemMenuButton[i] 		=	GFxClikWidget(GetVariableObject("_root.itemDrawer.tween.btnMenu"$i $"."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));
		WeaponMenuButton[i] 	=	GFxClikWidget(GetVariableObject("_root.weaponDrawer.tween.btnMenu"$i $"."$WidgetTeamPrefix $"Button", class'GFxClikWidget'));

		AssignButtonData(MainMenuButton[i], TeamID == TEAM_GDI ? GDIMainMenuData[i] : NodMainMenuData[i], i);
 		MainMenuButton[i].SetObject("group", MainMenuGroup);
		
		AssignButtonData(ClassMenuButton[i], TeamID == TEAM_GDI ? GDIClassMenuData[i] : NodClassMenuData[i], i);
		ClassMenuButton[i].SetObject("group", ClassMenuGroup);
		
		//Enable the first 7 items in weapon menu, disable the rest
		if (i < 7) {
			AssignButtonData(WeaponMenuButton[i], TeamID == TEAM_GDI ? GDIWeaponMenuData[i] : NodWeaponMenuData[i], i);
			WeaponMenuButton[i].SetObject("group", WeaponMenuGroup);
		} else {
			WeaponMenuButton[i].SetBool("enable", false);
			WeaponMenuButton[i].SetVisible(false);
		}
		//Enable the first 8 items in item menu, disable the rest
		if (i < 8) {
			AssignButtonData(ItemMenuButton[i], TeamID == TEAM_GDI ? GDIItemMenuData[i] : NodItemMenuData[i], i);
			ItemMenuButton[i].SetObject("group", ItemMenuGroup);
		} else {
			ItemMenuButton[i].SetBool("enable", false);
			ItemMenuButton[i].SetVisible(false);
		}
	}

	//  [ASSIGN VEHICLES]
	for (i = 0; i < 8; i++) {
		GetVariableObject("_root.vehicleDrawer.tween.btnVehicle"$i).GotoAndStopI(TeamID == TEAM_GDI ? 1 : 2);

		if (TeamID == TEAM_GDI) {
			//hide additional vehicle slot since GDI has less vehicle.
			if (i == 7) {
				VehicleMenuButton[i] = GFxClikWidget(GetVariableObject("_root.vehicleDrawer.tween.btnVehicle5" $"." $WidgetTeamPrefix $"Button", class 'GFxClikWidget'));
				VehicleMenuButton[i].SetBool("enable", false);
				VehicleMenuButton[i].SetVisible(false);
				continue;
			}
			VehicleMenuButton[i] = GFxClikWidget(GetVariableObject("_root.vehicleDrawer.tween.btnVehicle" $ (int(GDIVehicleMenuData[i].hotkey) - 1) $"." $WidgetTeamPrefix $"Button", class 'GFxClikWidget'));

		} else if (TeamID == TEAM_NOD) {
			VehicleMenuButton[i] = GFxClikWidget(GetVariableObject("_root.vehicleDrawer.tween.btnVehicle" $ i $"." $WidgetTeamPrefix $"Button", class 'GFxClikWidget'));
		}
 		AssignVehicleData(VehicleMenuButton[i], TeamID == TEAM_GDI ? GDIVehicleMenuData[i] : NodVehicleMenuData[i], i);
 		VehicleMenuButton[i].SetObject("group", VehicleMenuGroup);

	}
	
	// 	[ASSIGN EQUIPMENU BUTTON] 
	//need to add player's own sidearm and explosives into the list
	//equipment data need to have in def props

	EquipSideArmButton 			=	GFxClikWidget(GetVariableObject("_root.equipmentDrawer.tween.equipsidearm."$WidgetTeamPrefix $"Button", class 'GFxClikWidget'));
	EquipSideArmList 			=	GFxClikWidget(GetVariableObject("_root.equipmentDrawer.tween.equipsidearm."$WidgetTeamPrefix $"EquipmentList", class 'GFxClikWidget'));
	EquipExplosivesButton 		=	GFxClikWidget(GetVariableObject("_root.equipmentDrawer.tween.equipexplosives."$WidgetTeamPrefix $"Button", class 'GFxClikWidget'));
	EquipExplosivesList 		=	GFxClikWidget(GetVariableObject("_root.equipmentDrawer.tween.equipexplosives."$WidgetTeamPrefix $"EquipmentList", class 'GFxClikWidget'));

	explosiveData = TeamID == TEAM_GDI ? GDIEquipmentExplosiveData : NodEquipmentExplosiveData;
	sidearmData = TeamID == TEAM_GDI ? GDIEquipmentSideArmData : NodEquipmentSideArmData;

	if (rxPC.CurrentSidearmWeapon != none) {
		AssignEquipmentData(EquipSideArmButton, EquipSideArmList, sidearmData, rxPC.PreviousSidearmTransactionRecords, rxPC.CurrentSidearmWeapon);
	} else {
		
		AssignEquipmentData(EquipSideArmButton, EquipSideArmList, sidearmData, rxPC.PreviousSidearmTransactionRecords, class'Rx_InventoryManager'.default.SidearmWeapons[0]);
	}
	EquipSideArmButton.SetObject("group", EquipmentMenuGroup);

	if (rxPC.bJustBaughtEngineer 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician'){

			//supposely replace the 1st index, which is the timedc4


// 			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_ProxyC4')]);
// 			explosiveData[0] = explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_ProxyC4')];
// 			explosiveData[0].bFree = true;
			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_TimedC4')]);
			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_RemoteC4')]);
			explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_ProxyC4')].bFree = true;
// 		explosiveData[0] = explosiveData[explosiveData.Length - 1];
// 		explosiveData[0].bFree = true;
// 		explosiveData.Remove(explosiveData.length - 1, 1);

			//log
				`log("<PT Log>              ====================== ");
			for (i=0; i<explosiveData.Length; i++) {
				`log("<PT Log> Engi explosiveData["$ i $"]= " $ explosiveData[i].title);
			}

	} else if (rxPC.bJustBaughtHavocSakura 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Havoc'
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Sakura' ) {
			
// 			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_ProxyC4')]);
// 			explosiveData[0] = explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_RemoteC4')];
// 			explosiveData[0].bFree = true;
			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_TimedC4')]);
			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_ProxyC4')]);
			explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_RemoteC4')].bFree = true;
		}
	
	else {
		
			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_RemoteC4')]);
			explosiveData.RemoveItem(explosiveData[explosiveData.Find('WeaponClass', class'Rx_Weapon_ProxyC4')]);

			//log
			`log("<PT Log>              ====================== ");
			for (i=0; i<explosiveData.Length; i++) {
				`log("<PT Log> Norm explosiveData["$ i $"]= " $ explosiveData[i].title);
			}
	}

	if (rxPC.CurrentExplosiveWeapon != none) {
		AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, rxPC.CurrentExplosiveWeapon);
	} else {
		if (rxPC.bJustBaughtEngineer 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician'){
			//AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, rxInv.PrimaryWeapons[rxInv.PrimaryWeapons.Find(class'Rx_Weapon_ProxyC4')]);
			`log("<PT Log> engi rxPC.Pawn.InvManager= " $ rxPC.Pawn.InvManager);
			if (TeamID == TEAM_GDI) {
				AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, class'Rx_InventoryManager_GDI_Hotwire'.default.ExplosiveWeapons[0]);
			} else {
				AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, class'Rx_InventoryManager_Nod_Technician'.default.ExplosiveWeapons[0]);
			}
		} else if (rxPC.bJustBaughtHavocSakura 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Havoc'
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Sakura' ) {
			//AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, class'Rx_InventoryManager'.default.ExplosiveWeapons[0]);
			`log("<PT Log> Hvc/Skr rxPC.Pawn.InvManager= " $ rxPC.Pawn.InvManager);
			if (TeamID == TEAM_GDI) {
				AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, class'Rx_InventoryManager_GDI_Havoc'.default.ExplosiveWeapons[0]);
			} else {
				AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, class'Rx_InventoryManager_Nod_Sakura'.default.ExplosiveWeapons[0]);
			}
		} else {
			`log("<PT Log> norm rxPC.Pawn.InvManager= " $ rxPC.Pawn.InvManager);
			//AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, Rx_InventoryManager(rxPC.Pawn.InvManager).default.ExplosiveWeapons[0]);
			AssignEquipmentData(EquipExplosivesButton, EquipExplosivesList, explosiveData , rxPC.PreviousExplosiveTransactionRecords, class'Rx_InventoryManager'.default.ExplosiveWeapons[0]);
		}
	}
	EquipExplosivesButton.SetObject("group", EquipmentMenuGroup);


	bIsInTransition = true;
	BottomWidgetFadeIn(ExitTween);
	BottomWidgetFadeIn(CreditsTween);
	BottomWidgetFadeIn(PurchaseTween);
	MainDrawerFadeIn();
	EquipmentDrawerFadeIn();
	bIsInTransition = false;;

	
	//  [WIRE EVENTS FOR EQUIPMENT BUTTON]
	RemoveWidgetEvents();
	AddWidgetEvents();

	//set the dummy pawn/vehicle here
	SetupPTDummyActor();
	// 	[SET IGNORE 'E' BUTTON]
}

function RemoveWidgetEvents()
{
	local byte i;

	for (i = 0; i < 10; i ++)
	{

		MainMenuButton[i].RemoveAllEventListeners("CLIK_buttonClick");
		MainMenuButton[i].RemoveAllEventListeners("buttonClick");
		ClassMenuButton[i].RemoveAllEventListeners("CLIK_buttonClick");
		ClassMenuButton[i].RemoveAllEventListeners("buttonClick");
		ItemMenuButton[i].RemoveAllEventListeners("CLIK_buttonClick");
		ItemMenuButton[i].RemoveAllEventListeners("buttonClick");
		WeaponMenuButton[i].RemoveAllEventListeners("CLIK_buttonClick");
		WeaponMenuButton[i].RemoveAllEventListeners("buttonClick");
	}
	for (i = 0; i < 8; i ++)
	{
		VehicleMenuButton[i].RemoveAllEventListeners("CLIK_buttonClick");
		VehicleMenuButton[i].RemoveAllEventListeners("buttonClick");
	}
	
	ExitButton.RemoveAllEventListeners("CLIK_buttonClick");
	ExitButton.RemoveAllEventListeners("buttonClick");
	BackButton.RemoveAllEventListeners("CLIK_buttonClick");
	BackButton.RemoveAllEventListeners("buttonClick");
	PurchaseButton.RemoveAllEventListeners("CLIK_buttonClick");
	PurchaseButton.RemoveAllEventListeners("buttonClick");

	EquipSideArmButton.RemoveAllEventListeners("CLIK_buttonClick");
	EquipSideArmButton.RemoveAllEventListeners("buttonClick");
	EquipSideArmList.RemoveAllEventListeners("CLIK_itemClick");
	EquipSideArmList.RemoveAllEventListeners("itemClick");
	EquipExplosivesButton.RemoveAllEventListeners("CLIK_buttonClick");
	EquipExplosivesButton.RemoveAllEventListeners("buttonClick");
	EquipExplosivesList.RemoveAllEventListeners("CLIK_itemClick");
	EquipExplosivesList.RemoveAllEventListeners("itemClick");

	
}
function AddWidgetEvents()
{
	local byte i;

	for (i = 0; i < 10; i ++)
	{
		if (MainMenuButton[i].GetBool("enabled")){
			MainMenuButton[i].AddEventListener('CLIK_buttonClick', OnPTButtonClick);
		}
		if (ClassMenuButton[i].GetBool("enabled")){
			ClassMenuButton[i].AddEventListener('CLIK_buttonClick', OnPTButtonClick);
		}
		if (ItemMenuButton[i].GetBool("enabled")){
			ItemMenuButton[i].AddEventListener('CLIK_buttonClick', OnPTButtonClick);
		}
		if (WeaponMenuButton[i].GetBool("enabled")){
			WeaponMenuButton[i].AddEventListener('CLIK_buttonClick', OnPTButtonClick);
		}
	}
	for (i = 0; i < 8; i ++)
	{
		if (VehicleMenuButton[i].GetBool("enabled")){
			VehicleMenuButton[i].AddEventListener('CLIK_buttonClick', OnPTButtonClick);
		}
	}

	//bottom drawer 
	ExitButton.AddEventListener('CLIK_buttonClick', OnExitButtonClick);
	BackButton.AddEventListener('CLIK_buttonClick', OnBackButtonClick);
	PurchaseButton.AddEventListener('CLIK_buttonClick', OnPurchaseButtonClick);
	EquipSideArmButton.AddEventListener('CLIK_buttonClick', OnEquipButtonClick);
	EquipSideArmList.AddEventListener('CLIK_itemClick', OnEquipSideArmListItemClick);
	EquipExplosivesButton.AddEventListener('CLIK_buttonClick', OnEquipButtonClick);
	EquipExplosivesList.AddEventListener('CLIK_itemClick', OnExplosivesListItemClick);

}

function AssignButtonData(GFxClikWidget widget, PTMenuBlock menuData, byte i)
{
	local GFxObject Type;

	//if (i == menuData.ID) {
		widget.SetString("hotkeyLabel", menuData.hotkey);
		widget.SetString("data", "" $ menuData.ID);
		widget.SetString("label", menuData.title);

		//if this is engineer type, display repair bar instead.
		if (menuData.title == "ENGINEER" || menuData.title == "HOTWIRE" || menuData.title == "TECHNICIAN") {
			widget.SetBool("isDamageBar", false);
		}
		//widget.SetString("Group", menuData.Group);
		switch (menuData.BlockType)
		{
			case EPBT_MENU:
				widget.SetString("costLabel", "MENU");
				widget.SetBool("toggle", false);
				break;
			case EPBT_CLASS:
				if (rxPurchaseSystem.GetClassPrices(TeamID, menuData.ID) > 0) {
					widget.SetString("costLabel", "$" $ rxPurchaseSystem.GetClassPrices(TeamID, menuData.ID));
				} else {
					widget.SetString("costLabel", "FREE");
				}
				widget.SetBool("toggle", true);
				break;
			case EPBT_ITEM:
				if (rxPurchaseSystem.GetItemPrices(TeamID, menuData.ID) > 0) {
					widget.SetString("costLabel", "$" $ rxPurchaseSystem.GetItemPrices(TeamID, menuData.ID));
				} else {
					widget.SetString("costLabel", "FREE");
				}
				widget.SetBool("toggle", true);
				break;
			case EPBT_WEAPON:
				if (rxPurchaseSystem.GetWeaponPrices(TeamID, menuData.ID) > 0) {
					widget.SetString("costLabel", "$" $ rxPurchaseSystem.GetWeaponPrices(TeamID, menuData.ID));
				} else {
					widget.SetString("costLabel", "FREE");
				}
				widget.SetBool("toggle", true);
				break;
		}
		//[VEHICLE COUNT]
		Type = widget.GetObject("type");
		Type.GotoAndStopI(menuData.type);
		//Type.GetObject("icon").GotoAndStopI(menuData.iconID);

		//the following is the test
		LoadTexture("img://" $ PathName(menuData.PTIconTexture), Type.GetObject("icon"));
		//end test

		if (menuData.title == "VEHICLES" || menuData.title == "CHARACTERS") {
			widget.SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, menuData.title, rxPC));
			if (menuData.title == "VEHICLES") {
				widget.SetString("vehicleCountLabel", "( "$ VehicleCount $ " )");
			}
		} else {
			widget.SetString("sublabel", menuData.desc);
		}
		if (menuData.type == 2) {
			Type.GetObject("DamageBar").GotoAndStopI(menuData.damage + 1);
			Type.GetObject("RangeBar").GotoAndStopI(menuData.range + 1);
			Type.GetObject("RoFBar").GotoAndStopI(menuData.rateOfFire + 1);
			Type.GetObject("MagCapBar").GotoAndStopI(menuData.magCap + 1);
		}

		widget.SetBool("enabled", menuData.bEnable);
		//hide anything that is disabled
		if (!menuData.bEnable) {
			widget.SetBool("visible", menuData.bEnable);
		}

		if (!rxPurchaseSystem.AreSilosCaptured(TeamID)) {
			if (menuData.bSilo) {
				widget.SetBool("enabled", false);
			}
		}
}


function uLog(string s)
{
	loginternal(s);
}
function LoadTexture(string pathName, GFxObject widget) 
{
	widget.ActionScriptVoid("loadTexture");
}

function AssignEquipmentData( GFxClikWidget widgetButton, GFxClikWidget widgetList, array<PTEquipmentBlock> equipmentData, array<class<Rx_Weapon> > PreviousPurchasedWeapons, class<Rx_Weapon> CurrentWeapon )
{
	//create widget list first
	//then from the selected index, assign the widgetbutton
	local byte i, j;
    local GFxObject DataProvider;
	local int selectedIndex, selectedData;
	local class< Rx_Weapon > weaponClass;


    DataProvider = CreateArray();
	j=0;

	//iterate the equipData
	for (i=0; i < equipmentData.Length; i++){
		//if it is disabled, ignore
		if (!equipmentData[i].bEnable) {
			continue;
		}
		//if it is free, add to list
		if (equipmentData[i].bFree) {
			DataProvider.SetElementString(j, equipmentData[i].title);
			j++;
		} else {
			// @shahman: InventoryManager::FindInventoryType() is returning null for our weapons, which means the weapon is not totally removed. take note
			// foreach the purchased weapons
			foreach PreviousPurchasedWeapons(weaponClass)
			{
				// if eqipmentlist has previous purchased weapons, add to list.
				if (equipmentData[i].WeaponClass == weaponClass){
					DataProvider.SetElementString(j, equipmentData[i].title);
					j++;
					//weaponClass = equipmentData[i].WeaponClass;
					break;
				} 
			}
		}

// 		// if the equipdata is the same as our current weapon, then get the index data
// 		`log("<PT Log>");
// 		`log("<PT Log> equipmentData[i].WeaponClass= " $ equipmentData[i].WeaponClass);
// 		`log("<PT Log> CurrentWeapon= " $ CurrentWeapon);
// 		`log("<PT Log>");
		if (equipmentData[i].WeaponClass == CurrentWeapon) {
			selectedIndex = j - 1;
			selectedData = i;
		}
	}

    widgetList.SetObject("dataProvider", InitScrollingListDataProvider(DataProvider));
	widgetList.SetInt("rowCount", j);

	if (selectedIndex < 0) {
		selectedIndex = 0;
	}
	widgetList.SetInt("selectedIndex", selectedIndex);
	
	//update the widget with our selected equipment data
	UpdateEquipmentButton(widgetButton, equipmentData[selectedData]);
	widgetButton.SetBool("toggle", true);

	widgetButton.SetBool("enabled", equipmentData[selectedData].bEnable);
	widgetList.SetBool("enabled", equipmentData[selectedData].bEnable);
}

function UpdateEquipmentButton(GFxClikWidget widgetButton, PTEquipmentBlock equipmentData)
{
	widgetButton.SetString("label", equipmentData.title);
	widgetButton.SetString("sublabel", equipmentData.desc);
	widgetButton.GetObject("icon").GotoAndStopI(equipmentData.iconID);
	//the following is the test
	LoadTexture("img://" $ PathName(equipmentData.PTIconTexture), widgetButton.GetObject("icon"));
	//end test
	widgetButton.SetString("hotkey", equipmentData.hotkey);
}

function AssignVehicleData(GFxClikWidget widget, PTVehicleBlock menuData, byte i)
{
	
	if (i == menuData.ID) {
		widget.SetString("hotkeyLabel", menuData.hotkey);
		widget.SetString("data", "" $ menuData.ID);
		widget.SetString("label", menuData.title);
		if (rxPurchaseSystem.GetVehiclePrices(TeamID, menuData.ID, rxPurchaseSystem.AirdropAvailable(rxPRI)) > 0) {
			widget.SetString("costLabel", "$" $ rxPurchaseSystem.GetVehiclePrices(TeamID, menuData.ID, rxPurchaseSystem.AirdropAvailable(rxPRI)));
		} else {
			widget.SetString("costLabel", "FREE");
		}
		widget.SetBool("toggle", true);
		widget.GetObject("icon").GotoAndStopI(menuData.iconID);
		//the following is the test
		LoadTexture("img://" $ PathName(menuData.PTIconTexture), widget.GetObject("icon"));
		//end test
		widget.SetString("sublabel", menuData.desc);

		widget.SetBool("enabled", menuData.bEnable);
		//hide anything that is disabled
		if (!menuData.bEnable) {
			widget.SetBool("visible", menuData.bEnable);
		}

		
		if (rxBuildingOwner.AreAircraftDisabled()) {
			if (menuData.bAircraft) {
				widget.SetBool("enabled", false);
			}
		}		
	} 
}
function TickHUD() 
{
	local Rx_TeamInfo rxTeamInfo;
	local byte i, j;
	local int data;
	local Rx_Vehicle RxV;

	if (!bMovieIsOpen) {
		return;
	}

	rxTeamInfo = Rx_TeamInfo(rxPRI.Team);

	if (PlayerCredits != rxPRI.GetCredits()){
		PlayerCredits = rxPRI.GetCredits();
		CreditsButton.SetString("label", "Credits: "$int(PlayerCredits));
	}

	if (VehicleCount != rxTeamInfo.GetVehicleCount()){
		VehicleCount = rxTeamInfo.GetVehicleCount();
		
		if (VehicleCount ==  Clamp(VehicleCount, 1, 10)) {
			VehicleInfoButton.GetObject("vehicleCount").SetVisible(true);
			VehicleInfoButton.GetObject("vehicleCount").GotoAndStopI(VehicleCount);

			i = 0;			
			foreach rxPC.WorldInfo.AllPawns(class'Rx_Vehicle', RxV) {
				if (RxV.GetTeamNum() != TeamID || i > VehicleCount) {
					continue;
				} 
				if (TeamID == TEAM_GDI){
					for (j=0; j < rxPurchaseSystem.GDIVehicleClasses.Length; j++) {
						if (RxV.Class != rxPurchaseSystem.GDIVehicleClasses[j]) {
							continue;
						}
						VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i).GotoAndStopI(GDIVehicleMenuData[j].iconID);
						//the following is the test
						LoadTexture("img://" $ PathName(GDIVehicleMenuData[j].PTIconTexture), VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i));
						//end test
					}
				} else if (TeamID == TEAM_NOD) {
					for (j=0; j < rxPurchaseSystem.NodVehicleClasses.Length; j++) {
						if (RxV.Class != rxPurchaseSystem.NodVehicleClasses[j]) {
							continue;
						}
						VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i).GotoAndStopI(NodVehicleMenuData[j].iconID);
						//the following is the test
						LoadTexture("img://" $ PathName(NodVehicleMenuData[j].PTIconTexture), VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i));
						//end test
					}
				}
				i++;
			}
		} else {
			VehicleInfoButton.GetObject("vehicleCount").SetVisible(false);
			if (VehicleCount > 10) {
				`log("<PT Log> WARNING: vehicle exceeding the game vehicle limit");
			}
		}

		VehicleInfoButton.SetString("label", "Vehicles: " $ VehicleCount $" / " $ rxTeamInfo.VehicleLimit);
		MainMenuButton[9].SetString("vehicleCountLabel", "( "$ VehicleCount $ " )");
		//vehicle button number update here
		
	}


	if (!EquipSideArmButton.GetBool("selected")) {
		if (EquipSideArmList.GetBool("visible")) {
			if (TeamID == TEAM_GDI) {
				GetVariableObject("_root.equipmentDrawer.tween.equipsidearm.GDIListArrow").SetVisible(false);
			} else {
				GetVariableObject("_root.equipmentDrawer.tween.equipsidearm.NodListArrow").SetVisible(false);
			}
			EquipSideArmList.SetVisible(false);
		}
	}

	if (!EquipExplosivesButton.GetBool("selected")) {
		if (EquipExplosivesList.GetBool("visible")) {
			if (TeamID == TEAM_GDI) {
				GetVariableObject("_root.equipmentDrawer.tween.equipexplosives.GDIListArrow").SetVisible(false);
			} else {
				GetVariableObject("_root.equipmentDrawer.tween.equipexplosives.NodListArrow").SetVisible(false);
			}
			EquipExplosivesList.SetVisible(false);
		}
	}

	//Pay Class Condition

	if (rxPurchaseSystem.AreHighTierPayClassesDisabled(TeamID)) {
		if (bClassDrawerOpen) {
			for (i = 9; i > 2; i--) {
				if (!ClassMenuButton[i].GetBool("enabled")) {
					continue;
				}
				ClassMenuButton[i].SetBool("selected", false);
				ClassMenuButton[i].SetBool("enabled", false);
			}
			for (i = 0; i < 3; i++) {
				data = int(ClassMenuButton[i].GetString("data"));
 				ClassMenuButton[i].SetBool("enabled", TeamID == TEAM_GDI ? GDIClassMenuData[i].bEnable : NodClassMenuData[i].bEnable);
			}			
		} else if (bMainDrawerOpen) {
			MainMenuButton[8].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[8].title : NodMainMenuData[8].title), rxPC));
			MainMenuButton[8].SetBool("enabled", true);
		}
	} else {
		if (bClassDrawerOpen) {
			for (i = 0; i < 10; i++) {
				data = int(ClassMenuButton[i].GetString("data"));
 				ClassMenuButton[i].SetBool("enabled", TeamID == TEAM_GDI ? GDIClassMenuData[i].bEnable : NodClassMenuData[i].bEnable);
			}
		} else if (bMainDrawerOpen) {
			MainMenuButton[8].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[8].title : NodMainMenuData[8].title), rxPC));
			MainMenuButton[8].SetBool("enabled", true);
		}
	}

	//Vehicle Condition

	if (rxPurchaseSystem.AreVehiclesDisabled(TeamID, rxPC)) {
		if (bVehicleDrawerOpen) {
 			for(i=0; i < 8; i++) {
				if (!VehicleMenuButton[i].GetBool("enabled")) {
					continue;
				}
 				VehicleMenuButton[i].SetBool("selected", false);
 				VehicleMenuButton[i].SetBool("enabled", false);
 			}
			SelectBack();
			MainMenuButton[9].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[9].title : NodMainMenuData[9].title), rxPC ));
			MainMenuButton[9].SetBool("selected", false);
			MainMenuButton[9].SetBool("enabled", false);
		} else if (bMainDrawerOpen) {
			MainMenuButton[9].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[9].title : NodMainMenuData[9].title), rxPC));
			MainMenuButton[9].SetBool("selected", false);
			MainMenuButton[9].SetBool("enabled", false);
		}
	} else {
		if (bVehicleDrawerOpen) {
 			for(i=0; i < 8; i++) {
				data = int(VehicleMenuButton[i].GetString("data"));
 				VehicleMenuButton[i].SetBool("enabled", TeamID == TEAM_GDI ? GDIVehicleMenuData[i].bEnable : NodVehicleMenuData[i].bEnable);


				if (rxBuildingOwner.AreAircraftDisabled()) {
					if (TeamID == TEAM_GDI) {
						if (GDIVehicleMenuData[data].bAircraft) {
 							VehicleMenuButton[i].SetBool("selected", false);
 							VehicleMenuButton[i].SetBool("enabled", false);
						}
					} else {
						if (NodVehicleMenuData[data].bAircraft) {
 							VehicleMenuButton[i].SetBool("selected", false);
 							VehicleMenuButton[i].SetBool("enabled", false);
						}
					}
				}

 			}
		} else if (bMainDrawerOpen) {
			MainMenuButton[9].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[9].title : NodMainMenuData[9].title), rxPC));
			MainMenuButton[9].SetBool("enabled", true);
		}
	}

	//silo condition
	if (!rxPurchaseSystem.AreSilosCaptured(TeamID)) {
		if (bWeaponDrawerOpen) {
			for (i=0; i < 7; i++) {
				data = int(WeaponMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (GDIWeaponMenuData[data].bSilo){
						WeaponMenuButton[i].SetBool("selected", false);
						WeaponMenuButton[i].SetBool("enabled", false);
					}
				} else {
					if (NodWeaponMenuData[data].bSilo){
						WeaponMenuButton[i].SetBool("selected", false);
						WeaponMenuButton[i].SetBool("enabled", false);
					}
				}
			}
		}
	} else {
		if (bWeaponDrawerOpen) {
			for (i=0; i < 7; i++) {
				data = int(WeaponMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (GDIWeaponMenuData[data].bSilo){
						WeaponMenuButton[i].SetBool("enabled", true);
					}
				} else {
					if (NodWeaponMenuData[i].bSilo){
						WeaponMenuButton[i].SetBool("enabled", true);
					}
				}
			}
		}
	}
	
	//payment conditions

		if (bClassDrawerOpen) {
			for (i = 0; i < 10; i++) {
				data = int(ClassMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (!GDIClassMenuData[i].bEnable) {
						continue;
					}
				} else {
					if (!NodClassMenuData[i].bEnable) {
						continue;
					}
				}
				if (ClassMenuButton[i].GetBool("enabled") && PlayerCredits < rxPurchaseSystem.GetClassPrices(TeamID, data)){
					ClassMenuButton[i].SetBool("enabled", false);
				}
			}
		} else if (bVehicleDrawerOpen) {
			for (i = 0; i < 8; i++) {
				data = int(VehicleMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (!GDIVehicleMenuData[i].bEnable) {
						continue;
					}
				} else {
					if (!NodVehicleMenuData[i].bEnable) {
						continue;
					}
				}
				if (rxBuildingOwner.AreAircraftDisabled()) {
					if (TeamID == TEAM_GDI) {
						if (GDIVehicleMenuData[i].bAircraft) {
							continue;
						}
					} else {
						if (NodVehicleMenuData[i].bAircraft) {
							continue;
						}
					}
				}
				
				
				if (TeamID == TEAM_GDI) {
					VehicleMenuButton[i].SetString("costLabel", "$" $ rxPurchaseSystem.GetVehiclePrices(TeamID, GDIVehicleMenuData[i].ID, rxPurchaseSystem.AirdropAvailable(rxPRI)));
				} else {
					VehicleMenuButton[i].SetString("costLabel", "$" $ rxPurchaseSystem.GetVehiclePrices(TeamID, NodVehicleMenuData[i].ID, rxPurchaseSystem.AirdropAvailable(rxPRI)));
				}				
				
				if (PlayerCredits > rxPurchaseSystem.GetVehiclePrices(TeamID, data, rxPurchaseSystem.AirdropAvailable(rxPRI))){
					VehicleMenuButton[i].SetBool("enabled", true);
				} else {
					VehicleMenuButton[i].SetBool("enabled", false);
				}
			}
		} else if (bWeaponDrawerOpen) {
			for (i = 0; i < 7; i++) {
				data = int(WeaponMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (!GDIWeaponMenuData[i].bEnable) {
						continue;
					}
				} else {
					if (!NodWeaponMenuData[i].bEnable) {
						continue;
					}
				}
				if (!rxPurchaseSystem.AreSilosCaptured(TeamID)) {
					if (TeamID == TEAM_GDI) {
						if (GDIWeaponMenuData[i].bSilo) {
							continue;
						}
					} else {
						if (NodWeaponMenuData[i].bSilo) {
							continue;
						}
					}
				}
				if (PlayerCredits > rxPurchaseSystem.GetWeaponPrices(TeamID, data)){
					WeaponMenuButton[i].SetBool("enabled", true);
				} else {
					WeaponMenuButton[i].SetBool("enabled", false);
				}
			}
		} else if (bItemDrawerOpen) {
			for (i = 0; i < 8; i++) {
				data = int(ItemMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (!GDIItemMenuData[i].bEnable) {
						continue;
					}
				} else {
					if (!NodItemMenuData[i].bEnable) {
						continue;
					}
				}
				if (PlayerCredits > rxPurchaseSystem.GetItemPrices(TeamID, data)){
					ItemMenuButton[i].SetBool("enabled", true);
				} else {
					ItemMenuButton[i].SetBool("enabled", false);
				}
			}
		}

}


function SetPurchaseSystem(Rx_PurchaseSystem inPS )
{
	rxPurchaseSystem = inPS;
}



// **************************************************************** //
//																	//
//						BUTTON GROUP CONSTRUCTORS					//
//																	//
// **************************************************************** //
/** 
 *  Instantiatea a ButtonGroup Widget through a wrapper constructor.
 *  The Corresponding constructor would be: [ new ButtonGroup( name:String, scope:DisplayObjectContainer) ]
 */
function GFxClikWidget InitButtonGroupWidget(string groupName, GFxObject scope)
{
	return GFxClikWidget(ActionScriptConstructor("scaleform.clik.controls.ButtonGroup"));
}

function GFxObject InitScrollingListDataProvider(GFxObject DataArray = none)
{
	return ActionScriptConstructor("scaleform.clik.data.DataProvider");
}


// **************************************************************** //
//																	//
//						DUMMY ACTOR MANAGEMENTS 					//
//																	//
// **************************************************************** //
function SetupPTDummyActor()
{
	local vector loc;
	local rotator rot;

	if(DummyPawn == None) {
		foreach rxPC.AllActors(class'Rx_PTPlayerSpot', PawnShowcaseSpot) {
			if(PawnShowcaseSpot.TeamNum == rxPC.GetTeamNum()) {
				break;
			}	
		}
		
		loc = PawnShowcaseSpot.location;
		loc.Z += 50;
		rot = PawnShowcaseSpot.Rotation;
		//rot.Yaw += (-16384) * 2; // one1: comment this out to have original pawn rotation
		
		DummyPawn = rxPC.Spawn(class'Rx_PT_Pawn',rxPC,,loc,rot,,true);
		DummyPawn.bIsInvisible = true;
		DummyPawn.SetHidden(true); 

		//TODO:Temp placeholder
		DummyPawn.SetHidden(false);
		DummyPawn.SetCharacterClassFromInfo(Rx_Pawn(rxPC.Pawn).CurrCharClassInfo);
		DummyPawn.RefreshAttachedWeapons();
	}

	if (DummyVehicle == none) {
		foreach rxPC.AllActors(class'Rx_PTVehicleSpot', VehicleShowcaseSpot) {
			if(VehicleShowcaseSpot.TeamNum == rxPC.GetTeamNum()) {
				break;
			}	
		}
		loc = VehicleShowcaseSpot.location;
		rot = VehicleShowcaseSpot.Rotation;

		DummyVehicle = rxPC.Spawn(class'Rx_PT_Vehicle', rxPC, , loc, rot, , true);
		DummyVehicle.SetHidden(true); //it was true earlier

		
// 		DummyVehicle.SetHidden(false);
// 			DummyVehicle.SetSkeletalMesh(TeamID == TEAM_GDI 
// 				? class'RenX_Game.Rx_Vehicle_MediumTank'.default.SkeletalMeshForPT 
// 				: class'RenX_Game.Rx_Vehicle_LightTank'.default.SkeletalMeshForPT );
	}
}
/** one1: Modified. */
function ChangeDummyPawnClass(int classNum) 
{
    local class<Rx_FamilyInfo> rxCharInfo;   
	
	if (TeamID == TEAM_GDI) 
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

/** one1: Modified; do not spawn new actor each roll-over, just replace skeletalmesh. */
function ChangeDummyVehicleClass (int classNum) 
{
	local class<Rx_Vehicle> vehicleClass;
		
	if (DummyVehicle == None) 
	{
		DummyVehicle = rxPC.Spawn(class'Rx_PT_Vehicle', rxPC, , VehicleShowcaseSpot.Location, VehicleShowcaseSpot.Rotation, , true);
	}
	
 	DummyVehicle.SetHidden(false);
	if(rxPC.GetTeamNum() == TEAM_GDI) {
	 	vehicleClass = class'Rx_PurchaseSystem'.default.GDIVehicleClasses[classNum];	
	} else {
		vehicleClass = class'Rx_PurchaseSystem'.default.NodVehicleClasses[classNum];	
	}	

	DummyVehicle.SetSkeletalMesh(vehicleClass.default.SkeletalMeshForPT);
}



// **************************************************************** //
//																	//
//						DRAWER AND BUTTON ANIMATIONS				//
//																	//
// **************************************************************** //

function BottomWidgetFadeIn(GFxObject Widget)
{
	//local int CurrentFrame;

	if (Widget == none || Widget != ExitTween && Widget != BackTween && Widget != VehicleInfoTween && Widget != CreditsTween && Widget != PurchaseTween){
		return;
	}

	//CurrentFrame = Widget.GetInt("currentFrame");

	Widget.GotoAndPlay("Fade In");
}

function BottomWidgetFadeOut(GFxObject Widget)
{
	//local int CurrentFrame;

	if (Widget == none || Widget != ExitTween && Widget != BackTween && Widget != VehicleInfoTween && Widget != CreditsTween && Widget != PurchaseTween){
		return;
	}

	//CurrentFrame = Widget.GetInt("currentFrame");
	Widget.GotoAndPlay("Fade Out");
}

function BottomDrawerFadeIn() 
{
	if (ExitTween == none || BackTween == none || VehicleInfoTween == none || CreditsTween == none || PurchaseTween == none) {
		return;
	}

	if (ExitTween.GetInt("currentFrame") == 1) {
		ExitTween.GotoAndPlay("Fade In");
	}
	if (BackTween.GetInt("currentFrame") == 1) {
		BackTween.GotoAndPlay("Fade In");
	}
	if (VehicleInfoTween.GetInt("currentFrame") == 1) {
		VehicleInfoTween.GotoAndPlay("Fade In");
	}
	if (CreditsTween.GetInt("currentFrame") == 1) {
		CreditsTween.GotoAndPlay("Fade In");
	}
	if (PurchaseTween.GetInt("currentFrame") == 1) {
		PurchaseTween.GotoAndPlay("Fade In");
	}

}

function BottomDrawerFadeOut()
{
	if (ExitTween == none || BackTween == none || VehicleInfoTween == none || CreditsTween == none || PurchaseTween == none) {
		return;
	}
	//return if widget not init yet or null
	if (ExitTween.GetInt("currentFrame") == 20) {
		ExitTween.GotoAndPlay("Fade Out");
	}
	if (BackTween.GetInt("currentFrame") == 20) {
		BackTween.GotoAndPlay("Fade Out");
	}
	if (VehicleInfoTween.GetInt("currentFrame") == 20) {
		VehicleInfoTween.GotoAndPlay("Fade Out");
	}
	if (CreditsTween.GetInt("currentFrame") == 20) {
		CreditsTween.GotoAndPlay("Fade Out");
	}
	if (PurchaseTween.GetInt("currentFrame") == 20) {
		PurchaseTween.GotoAndPlay("Fade Out");
	}
}

function MainDrawerFadeIn()
{
	//local int CurrentFrame;
	if (MainDrawer == none) {
		return;
	}
	//CurrentFrame = MainDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 1) {
		MainDrawer.GotoAndPlay("Fade In");
		bMainDrawerOpen = true;
	//}
}
function MainDrawerFadeOut()
{
	//local int CurrentFrame;
	if (MainDrawer == none) {
		return;
	}
	//CurrentFrame = MainDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 20) {
		MainDrawer.GotoAndPlay("Fade Out");
		bMainDrawerOpen = false;
	//}
}

function ClassDrawerFadeIn()
{
	//local int CurrentFrame;
	if (ClassDrawer == none) {
		return;
	}
	//CurrentFrame = ClassDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 1) {
		ClassDrawer.GotoAndPlay("Fade In");
		bClassDrawerOpen = true;
	//}
}
function ClassDrawerFadeOut()
{
	//local int CurrentFrame;
	if (ClassDrawer == none) {
		return;
	}
	//CurrentFrame = ClassDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 20) {
		ClassDrawer.GotoAndPlay("Fade Out");
		bClassDrawerOpen = false;
	//}
}

function ItemDrawerFadeIn()
{
	//local int CurrentFrame;
	if (ItemDrawer == none) {
		return;
	}
	//CurrentFrame = ItemDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 1) {
		ItemDrawer.GotoAndPlay("Fade In");
		bItemDrawerOpen = true;
	//}
}
function ItemDrawerFadeOut()
{
	//local int CurrentFrame;
	if (ItemDrawer == none) {
		return;
	}
	//CurrentFrame = ItemDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 20) {
		ItemDrawer.GotoAndPlay("Fade Out");
		bItemDrawerOpen = false;
	//}
}

function WeaponDrawerFadeIn()
{
	//local int CurrentFrame;
	if (WeaponDrawer == none) {
		return;
	}
	//CurrentFrame = WeaponDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 1) {
		WeaponDrawer.GotoAndPlay("Fade In");
		bWeaponDrawerOpen = true;
	//}
}
function WeaponDrawerFadeOut()
{
	//local int CurrentFrame;
	if (WeaponDrawer == none) {
		return;
	}
	//CurrentFrame = WeaponDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 20) {
		WeaponDrawer.GotoAndPlay("Fade Out");
		bWeaponDrawerOpen = false;
	//}
}

function VehicleDrawerFadeIn()
{
	//local int CurrentFrame;
	if (VehicleDrawer == none) {
		return;
	}
	//CurrentFrame = VehicleDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 1) {
		VehicleDrawer.GotoAndPlay("Fade In");
		bVehicleDrawerOpen = true;
	//}
}
function VehicleDrawerFadeOut()
{
	//local int CurrentFrame;
	if (VehicleDrawer == none) {
		return;
	}
	//CurrentFrame = VehicleDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 20) {
		VehicleDrawer.GotoAndPlay("Fade Out");
		bVehicleDrawerOpen = false;
	//}
}

function EquipmentDrawerFadeIn()
{
	//local int CurrentFrame;
	if (EquipmentDrawer == none) {
		return;
	}
	//CurrentFrame = EquipmentDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 1) {
		EquipmentDrawer.GotoAndPlay("Fade In");
		bEquipmentDrawerOpen = true;
	//}
}
function EquipmentDrawerFadeOut()
{
	//local int CurrentFrame;
	if (EquipmentDrawer == none) {
		return;
	}
	//CurrentFrame = EquipmentDrawer.GetInt("currentFrame");
	//if (CurrentFrame == 20) {
		EquipmentDrawer.GotoAndPlay("Fade Out");
		bEquipmentDrawerOpen = false;
	//}
}

function CancelCurrentAnimations()
{
	if ( MainDrawer.GetInt("currentFrame") != 20 && bMainDrawerOpen) {
		MainDrawer.GotoAndPlay("Fade Out");
	} else if ( VehicleDrawer.GetInt("currentFrame") != 20 && bVehicleDrawerOpen ) {
		VehicleDrawer.GotoAndPlay("Fade Out");
	} else if (WeaponDrawer.GetInt("currentFrame") != 20 && bWeaponDrawerOpen ) {
		WeaponDrawer.GotoAndPlay("Fade Out");
	} else if (ItemDrawer.GetInt("currentFrame") != 20 && bItemDrawerOpen) {
		ItemDrawer.GotoAndPlay("Fade Out");
	} else if (ClassDrawer.GetInt("currentFrame") != 20 && bClassDrawerOpen ) {
		ClassDrawer.GotoAndPlay("Fade Out");
	}
}

// **************************************************************** //
//																	//
//				PERFORM CLICK, KEYPRESS AND SELECTION				//
//																	//
// **************************************************************** //

/**
* Handles any button Input from any keypress.
* Formerly known as ProcessInput (last modified by one1), it has now been replaced by FilterButtonInput which has much more control.
*/
function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{



// 	/** @shahman:temp hack to do a check whether the drawer is playing animation. slightly dirty. */
// 	if ( (MainDrawer.GetInt("currentFrame") != 20 && bMainDrawerOpen) 
// 		|| (VehicleDrawer.GetInt("currentFrame") != 20 && bVehicleDrawerOpen) 
// 		|| (WeaponDrawer.GetInt("currentFrame") != 20 && bWeaponDrawerOpen) 
// 		|| (ItemDrawer.GetInt("currentFrame") != 20 && bItemDrawerOpen) 
// 		|| (EquipmentDrawer.GetInt("currentFrame") != 20 && bEquipmentDrawerOpen) 
// 		|| (ClassDrawer.GetInt("currentFrame") != 20 && bClassDrawerOpen) ) {
// 		return false;
// 		}

	if (InputEvent == EInputEvent.IE_Pressed) {
		`log("<PT Log> ------------------ [ FilterButtonInput ] ------------------ ");
		`log("<PT Log> Button Pressed? " $ ButtonName);
	}
	switch (ButtonName) 
	{
		case 'Escape':
			if (InputEvent == EInputEvent.IE_Pressed) {
				PlaySoundFromTheme('buttonClick', 'default'); //TODO
				SetLoadout();
				ClosePTMenu(false);
			}
			break;
		case 'Enter':
			if (InputEvent == EInputEvent.IE_Pressed) {
				PlaySoundFromTheme('buttonClick', 'default'); //TODO
				SelectPurchase();
			}
			break;
		case 'BackSpace':
			if (InputEvent == EInputEvent.IE_Pressed) {
				PlaySoundFromTheme('buttonClick', 'default'); //TODO
				SelectBack();
			}
			break;
		case 'One':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bVehicleDrawerOpen && VehicleMenuButton[0].GetBool("enabled")) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(0);
					SelectPurchase();
				} else if ((bMainDrawerOpen && MainMenuButton[0].GetBool("enabled") ) 
					|| (bClassDrawerOpen && ClassMenuButton[0].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[0].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[0].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(0);
					//SelectMenu(1);
					SelectPurchase();
				}
			}
			break;
		case 'Two':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bVehicleDrawerOpen && VehicleMenuButton[1].GetBool("enabled")) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					if (TeamID == TEAM_GDI) {
						SetSelectedButtonByIndex(1);
					} else {
						SetSelectedButtonByIndex(1);
					}
					SelectPurchase();
				} else if ((bMainDrawerOpen && MainMenuButton[1].GetBool("enabled") ) 
					|| (bClassDrawerOpen && ClassMenuButton[1].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[1].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[1].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(1);
					//SelectMenu(2);
					SelectPurchase();
				}
			}
			break;
		case 'Three':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bVehicleDrawerOpen && VehicleMenuButton[1].GetBool("enabled")) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					if (TeamID == TEAM_GDI) {
						SetSelectedButtonByIndex(2);
					} else {
						SetSelectedButtonByIndex(2);
					}
					SelectPurchase();
				} else if ((bMainDrawerOpen && MainMenuButton[2].GetBool("enabled") ) 
					|| (bClassDrawerOpen && ClassMenuButton[2].GetBool("enabled")) 
					|| (bVehicleDrawerOpen && VehicleMenuButton[2].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[2].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[2].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(2);
					//SelectMenu(3);
					SelectPurchase();
				}
			}
			break;
		case 'Four':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bVehicleDrawerOpen && VehicleMenuButton[3].GetBool("enabled")) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					if (TeamID == TEAM_GDI) {
						SetSelectedButtonByIndex(3);
					} else {
						SetSelectedButtonByIndex(3);
					}
					SelectPurchase();
				} else if ((bMainDrawerOpen && MainMenuButton[3].GetBool("enabled") ) 
					|| (bClassDrawerOpen && ClassMenuButton[3].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[3].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[3].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(3);
					//SelectMenu(4);
					SelectPurchase();
				}
			}
			break;
		case 'Five':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bVehicleDrawerOpen && VehicleMenuButton[4].GetBool("enabled")) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					if (TeamID == TEAM_GDI) {
						SetSelectedButtonByIndex(4);
					} else {
						SetSelectedButtonByIndex(4);
					}
					SelectPurchase();
				} else if ((bClassDrawerOpen && ClassMenuButton[4].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[4].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[4].GetBool("enabled"))) {
					SetSelectedButtonByIndex(4);
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					//SelectMenu(5);
					SelectPurchase();
				} else if(bMainDrawerOpen && MainMenuButton[4].GetBool("enabled") ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(4);
					SelectPurchase();
				}
			}
			break;
			
		case 'E'://engi
// 			if (InputEvent == EInputEvent.IE_Pressed) {
// 				if(bMainDrawerOpen && MainMenuButton[4].GetBool("enabled") ) {
// 					PlaySoundFromTheme('buttonClick', 'default'); //TODO
// 					SetSelectedButtonByIndex(4);
// 					SelectPurchase();
// 				}
// 			}
			break;
			//break;
		case 'R'://refill
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bMainDrawerOpen && MainMenuButton[5].GetBool("enabled") ) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SelectMenu(6);
				}
			}
			break;
		case 'W'://weap
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bMainDrawerOpen && MainMenuButton[6].GetBool("enabled") ) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SelectMenu(7);
				}
			}
			break;
		case 'Q'://item
			if (InputEvent == EInputEvent.IE_Pressed) {
				 if ((bMainDrawerOpen && MainMenuButton[7].GetBool("enabled") ) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SelectMenu(8);
				}
			}
			break;
		case 'C'://char
			if (InputEvent == EInputEvent.IE_Pressed) {
				 if ((bMainDrawerOpen && MainMenuButton[8].GetBool("enabled") ) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SelectMenu(9);
				}
			}
			break;
		case 'V'://veh
			if (InputEvent == EInputEvent.IE_Pressed) {
				 if ((bMainDrawerOpen && MainMenuButton[9].GetBool("enabled") ) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SelectMenu(0);
				}
			}
			break;
		case 'Six':
			if (InputEvent == EInputEvent.IE_Pressed) {

				if ((bVehicleDrawerOpen && VehicleMenuButton[5].GetBool("enabled")) ) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					if (TeamID == TEAM_GDI) {
						//
					} else {
						SetSelectedButtonByIndex(5);
					}
					SelectPurchase();
				} else if ( (bClassDrawerOpen && ClassMenuButton[5].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[5].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[5].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(5);
					SelectPurchase();
				} 
			}
			break;
		case 'Seven':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bVehicleDrawerOpen && VehicleMenuButton[6].GetBool("enabled")) ) {
					if (!rxBuildingOwner.AreAircraftDisabled()) {
						PlaySoundFromTheme('buttonClick', 'default'); //TODO
						if (TeamID == TEAM_GDI) {
							SetSelectedButtonByIndex(5);//
						} else {
							SetSelectedButtonByIndex(6);
						}
						SelectPurchase();
					}
				} else if ((bClassDrawerOpen && ClassMenuButton[6].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[6].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[6].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(6);
					SelectPurchase();
				} 
			}
			break;
		case 'Eight':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bVehicleDrawerOpen && VehicleMenuButton[7].GetBool("enabled")) ) {
					if (!rxBuildingOwner.AreAircraftDisabled()) {
						PlaySoundFromTheme('buttonClick', 'default'); //TODO
						if (TeamID == TEAM_GDI) {
							SetSelectedButtonByIndex(6);//orca
						} else {
							SetSelectedButtonByIndex(7);
						}
						SelectPurchase();
					}
				} else if ((bClassDrawerOpen && ClassMenuButton[7].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[7].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[7].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(7);
					SelectPurchase();
				}
			}
			break;
		case 'Nine':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bClassDrawerOpen && ClassMenuButton[8].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[8].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[8].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(8);
					SelectPurchase();
				}
			}
			break;
		case 'Zero':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if ((bClassDrawerOpen && ClassMenuButton[9].GetBool("enabled")) 
					|| (bWeaponDrawerOpen && WeaponMenuButton[9].GetBool("enabled")) 
					|| (bItemDrawerOpen && ItemMenuButton[9].GetBool("enabled"))) {
					PlaySoundFromTheme('buttonClick', 'default'); //TODO
					SetSelectedButtonByIndex(9);
					SelectPurchase();
				}
			}
			break;
		case 'RightMouseButton': 
			if (InputEvent == EInputEvent.IE_Pressed) {
				rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue'); //TODO
				LastCursorXPosition = CursorMC.GetFloat("x");
			}
			
			if (DummyPawn != none) {
				//last - current
				MouseRotationIncrement = LastCursorXPosition - CursorMC.GetFloat("x");
				//difference used on rotation
				RotateDummyPawn(DummyPawn.Rotation.Yaw + ( MouseRotationIncrement * 128 ) );
				//then last = current
				LastCursorXPosition = CursorMC.GetFloat("x");
			}
			break;
		case 'LeftMouseButton': 
			//will be used for char rotation, along with left and right arrow
			break;
		case 'Left':
			/* one1: Added. Left arrow keys rotate character. */
			if (DummyPawn != none) {
				RotateDummyPawn(DummyPawn.Rotation.Yaw + RotationIncrement);
			}
			break;
		case 'Right':
			/* one1: Added. right arrow keys rotate character. */
			if (DummyPawn != none) {
				RotateDummyPawn(DummyPawn.Rotation.Yaw - RotationIncrement);
			}
			break;
		case 'F1':
			if (InputEvent == EInputEvent.IE_Pressed) {
				rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue');
				CycleEquipmentButton(EquipSideArmButton, EquipSideArmList, TeamID == TEAM_GDI ? GDIEquipmentSideArmData : NodEquipmentSideArmData);
			}
			break;
		case 'F2':
			if (InputEvent == EInputEvent.IE_Pressed) {
				rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue');
				CycleEquipmentButton(EquipExplosivesButton, EquipExplosivesList, TeamID == TEAM_GDI ? GDIEquipmentExplosiveData : NodEquipmentExplosiveData);
			}
			break;

		default:
			//`log("ControllerId: "$ControllerId $", ButtonName: "$ButtonName $", InputEvent: "$InputEvent);
			//break;
			return false;
	}

	return false;
}


function RotateDummyPawn (int NewYawRotation)
{
	local rotator rot;
	if (DummyPawn == none) {
		return;
	}
	if (NewYawRotation > 65536 ) {
		NewYawRotation = NewYawRotation - 65536;
	} else if (NewYawRotation < - 65536) {
		NewYawRotation = NewYawRotation + 65536;
	}
	rot = DummyPawn.Rotation;
	rot.Yaw = NewYawRotation;
	DummyPawn.SetRotation(rot);
}

function SetSelectedButtonByIndex (int index, optional bool selected = true)
{
	`log("<PT Log> Button Selected Index? " $ Index);
	if (bMainDrawerOpen) {
		if (index < 5) {
			MainMenuGroup.ActionScriptVoid("setSelectedButtonByIndex");
		}
		return;
	}
	if (bClassDrawerOpen) {
		ClassMenuGroup.ActionScriptVoid("setSelectedButtonByIndex");
		return;
	}
	if (bWeaponDrawerOpen) {
		if (index < 7) {
			WeaponMenuGroup.ActionScriptVoid("setSelectedButtonByIndex");
		}
		return;
	}
	if (bItemDrawerOpen) {
		if (index < 8){
			ItemMenuGroup.ActionScriptVoid("setSelectedButtonByIndex");
		}
		return;
	}
	if (bVehicleDrawerOpen) {
		if (index < 8) {
			VehicleMenuGroup.ActionScriptVoid("setSelectedButtonByIndex");
		}
		return;
	}
}
function SelectBack()
{
	`log("<PT Log> ------------------ [ Perform Select Back ] ------------------ ");

	if (bMainDrawerOpen) {
		return;
	}

	if (bVehicleDrawerOpen) {
		if (GFxClikWidget(VehicleMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
			GFxClikWidget(VehicleMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
		}
		CancelCurrentAnimations();
		if (BackTween.GetInt("currentFrame") != 20 && bVehicleDrawerOpen) {
			BackTween.GotoAndPlay("Fade Out");
		} 
		if (VehicleInfoTween.GetInt("currentFrame") != 20 && bVehicleDrawerOpen) {
			VehicleInfoTween.GotoAndPlay("Fade Out");
		} 
		bIsInTransition = true;
		rxPC.bIsInPurchaseTerminalVehicleSection = false;
		VehicleDrawerFadeOut();
		BottomWidgetFadeOut(VehicleInfoTween);
		BottomWidgetFadeOut(BackTween);
		MainDrawerFadeIn();
		EquipmentDrawerFadeIn();
		bIsInTransition = false;
	}

	if (bClassDrawerOpen) {
		if (GFxClikWidget(ClassMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
			GFxClikWidget(ClassMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
		}
		CancelCurrentAnimations();
		if (BackTween.GetInt("currentFrame") != 20 && bClassDrawerOpen) {
			BackTween.GotoAndPlay("Fade Out");
		} 
		bIsInTransition = true;
		ClassDrawerFadeOut();
		BottomWidgetFadeOut(BackTween);
		MainDrawerFadeIn();
		bIsInTransition = false;
	}

	if (bWeaponDrawerOpen) {
		if (GFxClikWidget(WeaponMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
			GFxClikWidget(WeaponMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
		}
		CancelCurrentAnimations();
		if (BackTween.GetInt("currentFrame") != 20 && bWeaponDrawerOpen) {
			BackTween.GotoAndPlay("Fade Out");
		} 
		bIsInTransition = true;
		WeaponDrawerFadeOut();
		BottomWidgetFadeOut(BackTween);
		MainDrawerFadeIn();
		EquipmentDrawerFadeIn();
		bIsInTransition = false;
	}
	if (bItemDrawerOpen) {
		if (GFxClikWidget(ItemMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
			GFxClikWidget(ItemMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
		}
		CancelCurrentAnimations();
		if (BackTween.GetInt("currentFrame") != 20 && bItemDrawerOpen) {
			BackTween.GotoAndPlay("Fade Out");
		} 
		bIsInTransition = true;
		ItemDrawerFadeOut();
		BottomWidgetFadeOut(BackTween);
		MainDrawerFadeIn();
		EquipmentDrawerFadeIn();
		bIsInTransition = false;
	}
}


function SelectMenu(int selectedIndex)
{
	if (selectedIndex != Clamp(selectedIndex, 0, 9) || bIsInTransition) {
		return;
	}


	switch (selectedIndex)
	{
		case 1: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 2: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 3: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 4: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 5: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 6: 
			if (bMainDrawerOpen) {
				rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundRefill');
				
				//set the current weapon to defaults so we can force perform our loadouts
		
				if (rxPC.CurrentSidearmWeapon == none) {
					//rxPC.CurrentSidearmWeapon = class<Rx_InventoryManager>(rxPC.Pawn.InventoryManagerClass).default.SidearmWeapons[0];
					rxPC.CurrentSidearmWeapon = class'Rx_InventoryManager'.default.SidearmWeapons[0];
				}
				
				//`log("<PT Log> rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
				if (rxPC.CurrentExplosiveWeapon == none) {
					if (rxPC.bJustBaughtEngineer 
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' 
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician'){
						rxPC.RemoveAllExplosives();
						//class<Rx_InventoryManager>(rxPC.Pawn.InventoryManagerClass).default.ExplosiveWeapons[0]
						if (TeamID == TEAM_GDI) {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_GDI_Hotwire'.default.ExplosiveWeapons[0];
						} else {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_Nod_Technician'.default.ExplosiveWeapons[0];
						}
						//`log("<PT Log> new rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
						rxPC.SetAdvEngineerExplosives(rxPC.CurrentExplosiveWeapon);
					} else if (rxPC.bJustBaughtHavocSakura 
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Havoc'
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Sakura' ) {
						rxPC.RemoveAllExplosives();
						//rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager'.default.ExplosiveWeapons[0];
						if (TeamID == TEAM_GDI) {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_GDI_Havoc'.default.ExplosiveWeapons[0];
						} else {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_Nod_Sakura'.default.ExplosiveWeapons[0];
						}
						//`log("<PT Log> new rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
						rxPC.AddExplosives(rxPC.CurrentExplosiveWeapon);
					}  else {
						rxPC.RemoveAllExplosives();
						rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager'.default.ExplosiveWeapons[0];
						//`log("<PT Log> new rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
						rxPC.AddExplosives(rxPC.CurrentExplosiveWeapon);
					}
				}

				SetLoadout();
				rxPC.PerformRefill(rxPC);
				rxPC.SwitchWeapon(0);
				ClosePTMenu(false);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				if (TeamID == TEAM_NOD) {
					ChangeDummyVehicleClass(NodVehicleMenuData[selectedIndex - 1].ID);
				}
			}
			break;
		case 7: 
			if (bMainDrawerOpen) {
				if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
					GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
				}

				//check if there is something transitioning, fade out immidietly
				CancelCurrentAnimations();
				if (EquipmentDrawer.GetInt("currentFrame") != 20 && bEquipmentDrawerOpen) {
					EquipmentDrawer.GotoAndPlay("Fade Out");
				} 

				bIsInTransition = true;								
				MainDrawerFadeOut();
				EquipmentDrawerFadeOut();
				WeaponDrawerFadeIn();
				BottomWidgetFadeIn(BackTween);
				bIsInTransition = false;
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				if (!rxBuildingOwner.AreAircraftDisabled()) {
					ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-2].ID : NodVehicleMenuData[selectedIndex - 1].ID);
				}
			}
			break;
		case 8: 
			if (bMainDrawerOpen) {
				if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
					GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
				}
				//check if there is something transitioning, fade out immidietly
				CancelCurrentAnimations();
				if (EquipmentDrawer.GetInt("currentFrame") != 20 && bEquipmentDrawerOpen) {
					EquipmentDrawer.GotoAndPlay("Fade Out");
				} 
				bIsInTransition = true;
				MainDrawerFadeOut();
				EquipmentDrawerFadeOut();
				ItemDrawerFadeIn();
				BottomWidgetFadeIn(BackTween);
				bIsInTransition = false;
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				if (!rxBuildingOwner.AreAircraftDisabled()) {
					ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-2].ID : NodVehicleMenuData[selectedIndex - 1].ID);
				}
			}
			break;
		case 9: 
			if (bMainDrawerOpen) { 
				if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
					GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
				}
				//check if there is something transitioning, fade out immidietly
				CancelCurrentAnimations();

				bIsInTransition = true;
				MainDrawerFadeOut();
				ClassDrawerFadeIn();
				BottomWidgetFadeIn(BackTween);
				bIsInTransition = false;
			}else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			}
			break;
		case 0: 
			if (bMainDrawerOpen) {
				if (!rxPurchaseSystem.AreVehiclesDisabled(TeamID, rxPC)) {
					if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
						GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
					}
					//check if there is something transitioning, fade out immidietly
					CancelCurrentAnimations();
					if (EquipmentDrawer.GetInt("currentFrame") != 20 && bEquipmentDrawerOpen) {
						EquipmentDrawer.GotoAndPlay("Fade Out");
					} 

					bIsInTransition = true;
					rxPC.bIsInPurchaseTerminalVehicleSection = true;
					MainDrawerFadeOut();
					EquipmentDrawerFadeOut();
					VehicleDrawerFadeIn();
					BottomWidgetFadeIn(BackTween);
					BottomWidgetFadeIn(VehicleInfoTween);
					bIsInTransition = false;
				}
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[9].ID : NodClassMenuData[9].ID);
			}
			break;
	}
	
}


function SelectPurchase()
{
	//local array< class<Rx_Weapon> > SidearmClasses;
	//local array< class<Rx_Weapon> > ExplosiveClasses;
	//local byte i;
	`log("<PT Log> ------------------ SelectPurchase() ------------------ ");

	
	if (bMainDrawerOpen) {
		SelectClassPurchase(MainMenuGroup);
	} 
	if (bClassDrawerOpen) {
		SelectClassPurchase(ClassMenuGroup);
// 		if ( (GetPC().WorldInfo.NetMode == NM_ListenServer && GetPC().RemoteRole == ROLE_SimulatedProxy) || GetPC().WorldInfo.NetMode == NM_Standalone ) {
// 			if (Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() != class'Rx_FamilyInfo_GDI_Hotwire' && Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() != class'Rx_FamilyInfo_Nod_Technician') {
// 				SetLoadout();
// 			}
// 		} else {
// 			if (!rxPC.bJustBaughtEngineer) {
// 				SetLoadout();
// 			}
// 		}
	}
	if (bVehicleDrawerOpen) {
		SelectVehiclePurchase(VehicleMenuGroup);
	}
	if (bWeaponDrawerOpen) {
		SelectWeaponPurchase(WeaponMenuGroup);
	}
	if (bItemDrawerOpen) {
		SelectItemPurchase(ItemMenuGroup);
	}

	//TODO:Show Insufficient Credits
	//by 'toasting' insufficient credits
}

function SelectClassPurchase(GFxClikWidget ButtonGroup) 
{
	local GFxClikWidget selectedButton;
	local int data;
	local int Price;

	

	selectedButton = GFxClikWidget(ButtonGroup.GetObject("selectedButton", class'GFxClikWidget'));

	//if it is not selected or not existed, then exit?
	if (selectedButton == none || !selectedButton.GetBool("selected")){
// 		if ( EquipSideArmList.GetInt("selectedIndex") >= 0 || EquipExplosivesList.GetInt("selectedIndex") >= 0 ){
// 			rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase');
// 			SetLoadout();
// 			rxPC.SwitchWeapon(0);
// 			ClosePTMenu(false);
// 		}
		return;
	}

	data = int(selectedButton.GetString("data"));
	Price = rxPurchaseSystem == None ? 0 : rxPurchaseSystem.GetClassPrices(TeamID, data);
			`log("<PT Log> Purchase Information ::");
			`log("<PT Log> Character: " $ rxPurchaseSystem.GetFamilyClass(TeamID, data));
			`log("<PT Log> Price: " $ Price);
			`log("<PT Log> PlayerCredits: " $ PlayerCredits);
	//if we have enough credits, proceed with purchase
	if (PlayerCredits > Price) {
		rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase');
		rxPC.PurchaseCharacter(TeamID, data);

		//set the current weapon to defaults so we can force perform our loadouts
		
		rxPC.CurrentSidearmWeapon = class'Rx_InventoryManager'.default.SidearmWeapons[0];
		if (rxPC.bJustBaughtEngineer 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician'){
			rxPC.CurrentExplosiveWeapon = class'Rx_Weapon_ProxyC4';
			//rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager'.default.ExplosiveWeapons[0];
		} else if (rxPC.bJustBaughtHavocSakura 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Havoc'
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Sakura' ) {
			rxPC.CurrentExplosiveWeapon = class'Rx_Weapon_RemoteC4';
		}else {
			rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager'.default.ExplosiveWeapons[0];
		}
		
		

		SetLoadout();
			
		rxPC.SwitchWeapon(0);
		ClosePTMenu(false);
	}

}

function SelectVehiclePurchase(GFxClikWidget ButtonGroup) 
{
	local GFxClikWidget selectedButton;
	local int data;
	local int Price;

	selectedButton = GFxClikWidget(VehicleMenuGroup.GetObject("selectedButton", class'GFxClikWidget'));
	if (selectedButton == none || !selectedButton.GetBool("selected")){
		return;
	}
	data = int(selectedButton.GetString("data"));
	Price = rxPurchaseSystem == None ? 0 : rxPurchaseSystem.GetVehiclePrices(TeamID, data, rxPurchaseSystem.AirdropAvailable(rxPRI));
		`log("<PT Log> Purchase Information ::");
		`log("<PT Log> Character: " $ rxPurchaseSystem.GetVehicleClass(TeamID, data));
		`log("<PT Log> Price: " $ Price);
		`log("<PT Log> PlayerCredits: " $ PlayerCredits);
	if (PlayerCredits > Price) {
		rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase');
		rxPC.PurchaseVehicle(TeamID, data);
		ClosePTMenu(false);
	}
}

function SelectWeaponPurchase(GFxClikWidget ButtonGroup) 
{
	local GFxClikWidget selectedButton;
	local int data;
	local int Price;

	selectedButton = GFxClikWidget(WeaponMenuGroup.GetObject("selectedButton", class'GFxClikWidget'));
	if (selectedButton == none || !selectedButton.GetBool("selected")){
		return;
	}
	data = int(selectedButton.GetString("data"));
	Price = rxPurchaseSystem == None ? 0 : rxPurchaseSystem.GetWeaponPrices(TeamID, data);
		`log("<PT Log> Purchase Information ::");
		`log("<PT Log> Character: " $ rxPurchaseSystem.GetWeaponClass(TeamID, data));
		`log("<PT Log> Price: " $ Price);
		`log("<PT Log> PlayerCredits: " $ PlayerCredits);
	if (PlayerCredits > Price) {
		rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase');
		rxPC.PurchaseWeapon(TeamID, data);
		ClosePTMenu(false);
	}
}

function SelectItemPurchase(GFxClikWidget ButtonGroup) 
{
	local GFxClikWidget selectedButton;
	local int data;
	local int Price;

	selectedButton = GFxClikWidget(ItemMenuGroup.GetObject("selectedButton", class'GFxClikWidget'));
	if (selectedButton == none || !selectedButton.GetBool("selected")){
		return;
	}
	data = int(selectedButton.GetString("data"));
	Price = rxPurchaseSystem == None ? 0 : rxPurchaseSystem.GetItemPrices(TeamID, data);
		`log("<PT Log> Purchase Information ::");
		`log("<PT Log> Character: " $ rxPurchaseSystem.GetItemClass(TeamID, data));
		`log("<PT Log> Price: " $ Price);
		`log("<PT Log> PlayerCredits: " $ PlayerCredits);
	if (PlayerCredits > Price) {
		rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase');
		rxPC.PurchaseItem(TeamID, data);
		ClosePTMenu(false);
	}
}
function CycleEquipmentButton(GFxClikWidget WidgetButton, GFxClikWidget WidgetList,  array<PTEquipmentBlock> equipmentData)
{
	local int SelectedIndex;
	local byte i;

	if (WidgetList == none) {
		return;
	}
	i = WidgetList.GetInt("selectedIndex");
	i++;
	if (i >= WidgetList.GetInt("rowCount")) {
		i = 0;
	}

	WidgetList.SetInt("selectedIndex", i);

	SelectedIndex = equipmentData.Find('title', WidgetList.GetObject("dataProvider").GetElementString(i) );

	if (SelectedIndex > -1) {
		`log("<PT Log> Update Equipment to " $ equipmentData[SelectedIndex].WeaponClass);
		UpdateEquipmentButton(WidgetButton, equipmentData[SelectedIndex]);
	}
}

function SetLoadout() {
	
	

	/**
	 * • Perform Loadouts on each category if there is a 'change' with the current equipped category
	 * • Everything should transfer even items
	 * 
	 * */

	`log("<PT Log> ------------------ [ SetLoadout() Called ] ------------------ ");
	SetExplosiveLoadout();
	SetSidearmLoadout();
	//SetItemLoadout();
	//TODO:SetItemLoadout
}

function SetExplosiveLoadout ()
{
	/**
	 * If the explosive selected is not the same as player loadout explosives,
	 *      make the change
	 * 
	 * */
	local int SelectedIndex;
	local byte i;
	local class<Rx_Weapon> explosiveClass;
	local array<PTEquipmentBlock> EquipmentExplosiveData;

	EquipmentExplosiveData  = teamID == TEAM_GDI ? GDIEquipmentExplosiveData    : NodEquipmentExplosiveData;

	
	//Equip our explosive data
	`log("<PT Log> GFx EquipExplosivesList["$ EquipExplosivesList.GetInt("selectedIndex") $"]? " $ EquipExplosivesList.GetObject("dataProvider").GetElementString(EquipExplosivesList.GetInt("selectedIndex")));
	`log("<PT Log> GetRxFamilyInfo()? "$ Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo());
	`log("<PT Log> Rx_Pawn(rxPC.Pawn).CurrCharClassInfo? "$ Rx_Pawn(rxPC.Pawn).CurrCharClassInfo);
	`log("<PT Log> rxPC.Pawn? "$ rxPC.Pawn);
	`log("<PT Log> bJustBaughtEngineer? " $ rxPC.bJustBaughtEngineer);
	`log("<PT Log> bJustBaughtHavocSakura? " $ rxPC.bJustBaughtHavocSakura);

	i = EquipExplosivesList.GetInt("selectedIndex");
	SelectedIndex = EquipmentExplosiveData.Find('title', EquipExplosivesList.GetObject("dataProvider").GetElementString(i));
	if (SelectedIndex >= 0) {
		
		// if this is an engineer type
		if (rxPC.bJustBaughtEngineer 
			|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' 
			|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician') {

			//it is not suppose to happen, but if we have a timedC4, swap it with proxyc4, else continue
			if (EquipmentExplosiveData[SelectedIndex].WeaponClass == class'Rx_Weapon_TimedC4'
				|| EquipmentExplosiveData[SelectedIndex].WeaponClass == class'Rx_Weapon_RemoteC4') {
				explosiveClass = class'Rx_Weapon_ProxyC4';
			} else {
				explosiveClass = EquipmentExplosiveData[SelectedIndex].WeaponClass;
			}
			//do a check if there is a 'change' in our explosive loadout, if there is perform change.

			//class'Rx_InventoryManager'.default.ExplosiveWeapons[0]

			`log("<PT Log>      engi rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
			`log("<PT Log>      engi OwnedExplosive? " $ OwnedExplosive);
			`log("<PT Log>      engi selected explosive data? " $ explosiveClass);

			if (rxPC.CurrentExplosiveWeapon != none) {
				if (rxPC.CurrentExplosiveWeapon != explosiveClass) {
					rxPC.RemoveAllExplosives();
					rxPC.SetAdvEngineerExplosives(explosiveClass);
				} else {
					`log ("<PT Log> Engi Explosive Loadout is the same as current loadout. loadout not performed!!!");
				}
			} else {
				if (class'Rx_Weapon_ProxyC4' != explosiveClass) {
					rxPC.RemoveAllExplosives();
					rxPC.SetAdvEngineerExplosives(explosiveClass);
				} else {
					`log ("<PT Log> Engi Explosive Loadout is the same as current loadout. loadout not performed!!!");
				}
			}

		} else if (rxPC.bJustBaughtHavocSakura 
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Havoc'
		|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Sakura' ) {
		
			//do a check if there is a 'change' in our explosive loadout, if there is perform change.
			//explosiveClass = EquipmentExplosiveData[SelectedIndex].WeaponClass;
			//it is not suppose to happen, but if we have a proxyc4, swap it with timedc4, else continue
			if (EquipmentExplosiveData[SelectedIndex].WeaponClass == class'Rx_Weapon_TimedC4'
				|| EquipmentExplosiveData[SelectedIndex].WeaponClass == class'Rx_Weapon_ProxyC4') {
				explosiveClass = class'Rx_Weapon_RemoteC4';
			} else {
				explosiveClass = EquipmentExplosiveData[SelectedIndex].WeaponClass;
			}
			`log("<PT Log>      hvc/skr rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
			`log("<PT Log>      hvc/skr OwnedExplosive? " $ OwnedExplosive);
			`log("<PT Log>      hvc/skr selected explosive data? " $ explosiveClass);

			if (rxPC.CurrentExplosiveWeapon != none) {
				if (rxPC.CurrentExplosiveWeapon != explosiveClass) {
					rxPC.RemoveAllExplosives();
					rxPC.AddExplosives(explosiveClass);
				} else {
					`log ("<PT Log> hvc/skr Explosive Loadout is the same as current loadout. loadout not performed!!!");
				}
			} else {
				if (class'Rx_Weapon_RemoteC4' != explosiveClass) {
					rxPC.RemoveAllExplosives();
					rxPC.AddExplosives(explosiveClass);
				} else {
					`log ("<PT Log> hvc/skr Explosive Loadout is the same as current loadout. loadout not performed!!!");
				}
			}
		}else {
			

			//do a check if there is a 'change' in our explosive loadout, if there is perform change.
			//explosiveClass = EquipmentExplosiveData[SelectedIndex].WeaponClass;
			//it is not suppose to happen, but if we have a proxyc4, swap it with timedc4, else continue
			if (EquipmentExplosiveData[SelectedIndex].WeaponClass == class'Rx_Weapon_ProxyC4'
				|| EquipmentExplosiveData[SelectedIndex].WeaponClass == class'Rx_Weapon_RemoteC4') {
				explosiveClass = class'Rx_Weapon_TimedC4';
			} else {
				explosiveClass = EquipmentExplosiveData[SelectedIndex].WeaponClass;
			}
			`log("<PT Log>      norm rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
			`log("<PT Log>      norm OwnedExplosive? " $ OwnedExplosive);
			`log("<PT Log>      norm selected explosive data? " $ explosiveClass);

			if (rxPC.CurrentExplosiveWeapon != none) {
				if (rxPC.CurrentExplosiveWeapon != explosiveClass) {
					rxPC.RemoveAllExplosives();
					rxPC.AddExplosives(explosiveClass);
				} else {
					`log ("<PT Log> norm Explosive Loadout is the same as current loadout. loadout not performed!!!");
				}
			} else {
				if (class'Rx_InventoryManager'.default.ExplosiveWeapons[0] != explosiveClass) {
					rxPC.RemoveAllExplosives();
					rxPC.AddExplosives(explosiveClass);
				} else {
					`log ("<PT Log> norm Explosive Loadout is the same as current loadout. loadout not performed!!!");
				}
			}
		}
	}
}

function SetSidearmLoadout() 
{
	local int SelectedIndex;
	local byte i;
	local class<Rx_Weapon> sidearmClass;
	local array<PTEquipmentBlock> EquipmentSidearmData;

	EquipmentSidearmData    = teamID == TEAM_GDI ? GDIEquipmentSidearmData      : NodEquipmentSidearmData;

	//Equip our sidearm data
	`log("<PT Log> GFx EquipmentSidearmData["$ EquipSideArmList.GetInt("selectedIndex") $"]? " $ EquipSideArmList.GetObject("dataProvider").GetElementString(EquipSideArmList.GetInt("selectedIndex")));
	
	i = EquipSideArmList.GetInt("selectedIndex");
	SelectedIndex = EquipmentSidearmData.Find('title', EquipSideArmList.GetObject("dataProvider").GetElementString(i));
	if (SelectedIndex >= 0) {
		sidearmClass = EquipmentSidearmData[SelectedIndex].WeaponClass;
			`log("<PT Log> rxPC.CurrentSidearmWeapon? " $ rxPC.CurrentSidearmWeapon);
			`log("<PT Log> OwnedSidearm? " $ OwnedSidearm);
			`log("<PT Log> selected sidearm data? " $ sidearmClass);
		if (rxPC.CurrentSidearmWeapon != sidearmClass) {
			rxPC.SetSidearmWeapon(EquipmentSidearmData[SelectedIndex].WeaponClass);
		} else {
			
			`log ("<PT Log> Sidearm Loadout is the same as current loadout. loadout not performed!!!");
		}
		
	}
}

// function SetItemLoadout()
// {
// 	`log("<PT Log> >> Performing our item loadouts!");
// 	//if item has existed before
// 	if (OwnedItem != none) {
// 		//if the current inventory do not have it
// 		if (Rx_InventoryManager(rxPC.Pawn.InvManager).Items.Find(OwnedItem) < 0) {
// 			//re-add it
// 			rxPC.SetItem(OwnedItem);
// 		}
// 	}
// 	//Equip our sidearm data
// }

// **************************************************************** //
//																	//
//						EVENT LISTENER FUNCTIONS					//
//																	//
// **************************************************************** //

function OnEquipButtonClick(GFxClikWidget.EventData ev) 
{
	local GFxClikWidget button;
	local string WidgetTeamPrefix;

	WidgetTeamPrefix = TeamID == TEAM_GDI ? "GDI" : "Nod";
	button = GFxClikWidget(ev._this.GetObject("currentTarget", class'GFxClikWidget'));

	//`log("button Parents" $ button.GetObject("parent"));
	if (button.GetBool("selected")) {
		button.GetObject("parent").GetObject("" $ WidgetTeamPrefix $ "ListArrow").SetVisible(true);
		GFxClikWidget(button.GetObject("parent").GetObject("" $ WidgetTeamPrefix $ "EquipmentList", class'GFxClikWidget')).SetVisible(true);
		//GDIListArrow
	} else {
		button.GetObject("parent").GetObject("" $ WidgetTeamPrefix $ "ListArrow").SetVisible(false);
		GFxClikWidget(button.GetObject("parent").GetObject("" $ WidgetTeamPrefix $ "EquipmentList", class'GFxClikWidget')).SetVisible(false);
	}
}

function OnEquipSideArmListItemClick(GFxClikWidget.EventData ev) 
{
	local int SelectedIndex;
	local GFxClikWidget CurrentTarget;
	local byte i;

	SelectedIndex = ev._this.GetInt("index");
	CurrentTarget = GFxClikWidget(ev._this.GetObject("currentTarget", class'GFxClikWidget'));

	if (TeamID == TEAM_GDI) {
		for (i=0; i < GDIEquipmentSideArmData.Length; i++) {
			if (GDIEquipmentSideArmData[i].title == CurrentTarget.GetObject("dataProvider").GetElementString(SelectedIndex)){
				SelectedIndex = i;
				break;
			}
		}
		
		UpdateEquipmentButton(EquipSideArmButton, GDIEquipmentSideArmData[SelectedIndex]);
	} else {
		for (i=0; i < NodEquipmentSideArmData.Length; i++) {
			if (NodEquipmentSideArmData[i].title == CurrentTarget.GetObject("dataProvider").GetElementString(SelectedIndex)){
				SelectedIndex = i;
				break;
			}
		}
		UpdateEquipmentButton(EquipSideArmButton, NodEquipmentSideArmData[SelectedIndex]);
	}
}
function OnExplosivesListItemClick(GFxClikWidget.EventData ev) 
{
	local int SelectedIndex;
	local GFxClikWidget CurrentTarget;
	local byte i;

	SelectedIndex = ev._this.GetInt("index");
	CurrentTarget = GFxClikWidget(ev._this.GetObject("currentTarget", class'GFxClikWidget'));

	if (TeamID == TEAM_GDI) {
		for (i=0; i < GDIEquipmentExplosiveData.Length; i++) {
			if (GDIEquipmentExplosiveData[i].title == CurrentTarget.GetObject("dataProvider").GetElementString(SelectedIndex)){
				SelectedIndex = i;
				break;
			}
		}
		UpdateEquipmentButton(EquipExplosivesButton, GDIEquipmentExplosiveData[SelectedIndex]);
	} else {
		for (i=0; i < NodEquipmentExplosiveData.Length; i++) {
			if (NodEquipmentExplosiveData[i].title == CurrentTarget.GetObject("dataProvider").GetElementString(SelectedIndex)){
				SelectedIndex = i;
				break;
			}
		}
		UpdateEquipmentButton(EquipExplosivesButton, NodEquipmentExplosiveData[SelectedIndex]);
	}
}


function OnExitButtonClick(GFxClikWidget.EventData ev)
{
	SetLoadout();
	ClosePTMenu(false);
}
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	SelectBack();
}
function OnPurchaseButtonClick(GFxClikWidget.EventData ev)
{
	SelectPurchase();
}
function OnPTButtonClick(GFxClikWidget.EventData ev) 
{
	local GFxClikWidget button;
	local int hotkey;

	//PlaySoundFromTheme('buttonClick');
	button = GFxClikWidget(ev._this.GetObject("currentTarget", class'GFxClikWidget'));

	switch (button.GetString("hotkeyLabel")) 
	{
		case "E":
			if(bMainDrawerOpen) {
				hotkey = 5;
			}
			break;
		case "R":
			if(bMainDrawerOpen) {
				hotkey = 6;
			}
			break;
		case "W":
			if(bMainDrawerOpen) {
				hotkey = 7;
			}
			break;
		case "Q":
			if(bMainDrawerOpen) {
				hotkey = 8;
			}
			break;
		case "C":
			if(bMainDrawerOpen) {
				hotkey = 9;
			}
			break;
		case "V":
			if(bMainDrawerOpen) {
				hotkey = 0;
			}
			break;
		default:
			hotkey = int(button.GetString("hotkeyLabel"));
			break;
	}


	if (button.GetBool("toggle") && !button.GetBool("selected")) {
		button.SetBool("selected", true);
		//prototype double click
		if (bMainDrawerOpen && hotkey == 6) {
			SelectMenu(hotkey);
		}
		SelectPurchase();
		return;
	} else  {
		SelectMenu(hotkey);
	}
	
}

/**
 * @Shahman [03/01/2014] ExportPlaySound() : 
 * This is a semi-dirty hack for CLIK AS3. It is a Workaround for AS2's playSound() as AS3 no longer have support for _global.gfxProcessSound() . 
 * From a modified CLIK AS3 source code in flash, an externalInterface.Call() is executed to this function.
 * From here, we are simply call the arbitary function PlaySoundFromTheme().
 * 
 * */
function ExportPlaySound(string EventName, optional string SoundThemeName = "default")
{
	local name OutEventName;
	local name OutSoundThemeName;
	local byte i,j;

	OutEventName = name(EventName);
	OutSoundThemeName = name(SoundThemeName);

	for (i=0; i < SoundThemes.Length; i++) {
		if (OutSoundThemeName != SoundThemes[i].ThemeName) {
			continue;
		}
		for (j=0; j<SoundThemes[i].Theme.SoundEventBindings.Length; j++) {
			if (OutEventName != SoundThemes[i].Theme.SoundEventBindings[j].SoundEventName) {
				continue;
			}
			PlaySoundFromTheme(OutEventName, OutSoundThemeName);
		}
	}
}




// **************************************************************** //
//																	//
//						SHUTDOWN AND CLEANUPS   					//
//																	//
// **************************************************************** //
function ClosePTMenu(bool unload)
{
	`log("<PT Log> ------------------ [ Close PT menu ] ------------------ ");


	`log("<PT Log> Loadout Results:: ");
	`log("<PT Log>");
	`log("<PT Log> rxPC.bJustBaughtEngineer= "$ rxPC.bJustBaughtEngineer);
	`log("<PT Log> rxPC.bJustBaughtHavocSakura= "$ rxPC.bJustBaughtHavocSakura);
	`log("<PT Log> OwnedFamilyInfo= " $ OwnedFamilyInfo);
	`log("<PT Log>");
	`log("<PT Log> OwnedSidearm= " $ OwnedSidearm);
	`log("<PT Log> OwnedExplosive= " $ OwnedExplosive);
	`log("<PT Log> OwnedItem= " $ OwnedItem);
	`log("<PT Log>");
	`log("<PT Log> rxPC.CurrentExplosiveWeapon= "$ rxPC.CurrentExplosiveWeapon);
	`log("<PT Log> rxPC.CurrentSidearmWeapon= "$ rxPC.CurrentSidearmWeapon);

	//play sound
	//pull ALL the drawer out of screen
	BottomDrawerFadeOut();
	MainDrawerFadeOut();
	//began removing widgets manually

	//revert init settings back to main game 
	
	RemoveWidgetEvents();

	rxPC.bIsInPurchaseTerminal = false;
	rxPC.bIsInPurchaseTerminalVehicleSection = false;
	rxHUD.bShowHUD = true;
	rxHUD.bCrosshairShow = true;

	//close remaining leftovers.

	if (DummyPawn != none) {
		DummyPawn.SetHidden(true);
		DummyPawn.Destroy();
	}
	if (DummyVehicle != none) {
		DummyVehicle.SetHidden(true);
		DummyVehicle.Destroy();
	}
	if (rxBuildingOwner != none) {
		rxBuildingOwner.StopCreditTick();
		rxBuildingOwner.StopInsufCreditsTimeout();
	}
	//close the movie once everything is removed to avoid mem leaks.
	Close(unload); 
	
	
}

DefaultProperties
{
bAutoPlay                       	=   false
	bAllowInput                     =   true
	//
	bCaptureInput                   =   true
	bCaptureMouseInput              =   true
	//bShowHardwareMouseCursor        =   true
	MovieInfo                       =   SwfMovie'RenXPurchaseMenu.RenXPurchaseMenu'

	PlayerCredits                   =   0
	VehicleCount                    =   1337 //leet yo !

	//Sound Mapping
	SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'RenXPurchaseMenu.Sounds.SoundTheme')

	bMainDrawerOpen                 =   false
	bClassDrawerOpen                =   false
	bItemDrawerOpen                 =   false
	bWeaponDrawerOpen               =   false
	bEquipmentDrawerOpen            =   false
	bVehicleDrawerOpen              =   false
	

	GDIMainMenuData(0) 				= (BlockType=EPBT_CLASS, id=0,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Autorifle',  iconID=27, hotkey="1", title="SOLDIER",	    desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Buildings\n-Heavy Armour Vehicles\n",	cost="FREE", type=2, damage=1,range=3,rateOfFire=5,magCap=4)
	GDIMainMenuData(1) 				= (BlockType=EPBT_CLASS, id=1,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Shotgun', iconID=52, hotkey="2", title="SHOTGUNNER",  desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Vehicles, Buildings\n-Heavy Armour",	cost="FREE", type=2, damage=3,range=1,rateOfFire=2,magCap=2)
	GDIMainMenuData(2) 				= (BlockType=EPBT_CLASS, id=2,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_GrenadeLauncher', iconID=34, hotkey="3", title="GRENADIER",   desc="Good Vs:\n-Light Armour\n-Heavy Armour\n-Buildings\n\nWeak Vs:\n-Infrantry",						cost="FREE", type=2, damage=3,range=4,rateOfFire=2,magCap=2)
	GDIMainMenuData(3) 				= (BlockType=EPBT_CLASS, id=3,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MarksmanRifle', iconID=41, hotkey="4", title="MARKSMAN",	desc="Good Vs:\n-Infrantry\n-Light Armour\n\nWeak Vs:\n-Vehicles, Buildings\n-Heavy Armour",			cost="FREE", type=2, damage=3,range=5,rateOfFire=3,magCap=2)
	GDIMainMenuData(4) 				= (BlockType=EPBT_CLASS, id=4,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun', iconID=50, hotkey="5", title="ENGINEER",	desc="Pros:\n-Building Destruction\n-Repairing/Healing\n\nCons:\n-No Offensive Weapon\n-Short Ranged",	cost="FREE", type=2, damage=3,range=1,rateOfFire=6,magCap=6)
	GDIMainMenuData(5) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Refill', iconID=05, hotkey="R", title="REFILL",	    desc="\nRefill Health\nRefill Armour\nRefill Ammo\nRefill Stamina",										cost="MENU", type=1)
	GDIMainMenuData(6) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapons', iconID=60, hotkey="W", title="WEAPONS",	    desc="\n\nSidearms\nGrenades\nSupport Weapons",															cost="MENU", type=1)
	GDIMainMenuData(7) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_ItemsGDI', iconID=03, hotkey="Q", title="ITEM",		desc="\n\nSuperweapons\nEquipment\nDeployables",														cost="MENU", type=1)
	GDIMainMenuData(8) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Characters', iconID=02, hotkey="C", title="CHARACTERS",  desc="",																								cost="MENU", type=1)
	GDIMainMenuData(9) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Vehicles_GDI', iconID=25, hotkey="V", title="VEHICLES",	desc="",																								cost="MENU", type=1)

	GDIClassMenuData(0) 			= (BlockType=EPBT_CLASS, id=5,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Chaingun', iconID=28, hotkey="1", title="OFFICER"		 ,desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Buildings\n-Heavy Armour Vehicles",	cost="175", type=2,damage=1,range=3,rateOfFire=6,magCap=6)
	GDIClassMenuData(1) 			= (BlockType=EPBT_CLASS, id=6,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MissileLauncher', iconID=42, hotkey="2", title="ROCKET SOLDIER",desc="Good Vs:\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Infratry\n-Buildings",						cost="225", type=2,damage=4,range=5,rateOfFire=1,magCap=1)
	GDIClassMenuData(2) 			= (BlockType=EPBT_CLASS, id=7,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_FlakCannon', iconID=31, hotkey="3", title="MCFARLAND"	 ,desc="Good Vs:\n-Infratry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",						cost="150", type=2,damage=3,range=1,rateOfFire=3,magCap=3)
	GDIClassMenuData(3) 			= (BlockType=EPBT_CLASS, id=8,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SniperRifle', iconID=54, hotkey="4", title="DEADEYE"		 ,desc="Good Vs:\n-Infrantry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",					cost="500", type=2,damage=4,range=6,rateOfFire=1,magCap=2)
	GDIClassMenuData(4) 			= (BlockType=EPBT_CLASS, id=9,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RocketLauncher', iconID=51, hotkey="5", title="GUNNER"		 ,desc="Good Vs:\n-Light Armour\n-Heavy Armour\n-Buildings\n\nWeak Vs:\n-Infrantry",					cost="400", type=2,damage=4,range=5,rateOfFire=3,magCap=2)
	GDIClassMenuData(5) 			= (BlockType=EPBT_CLASS, id=10, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TacticalRifle', iconID=55, hotkey="6", title="PATCH"		 ,desc="Good Vs:\n-Infratry\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Buildings",						cost="450", type=2,damage=3,range=4,rateOfFire=4,magCap=3)
	GDIClassMenuData(6) 			= (BlockType=EPBT_CLASS, id=11, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RamjetRifle', iconID=48, hotkey="7", title="HAVOC"		 ,desc="Good Vs:\n-Infrantry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",					cost="1000",type=2,damage=5,range=6,rateOfFire=2,magCap=2)
	GDIClassMenuData(7) 			= (BlockType=EPBT_CLASS, id=12, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_PIC', iconID=44, hotkey="8", title="SYDNEY"		 ,desc="Good Vs:\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Infrantry\n-Buildings",					cost="1000",type=2,damage=6,range=4,rateOfFire=1,magCap=2)
	GDIClassMenuData(8) 			= (BlockType=EPBT_CLASS, id=13, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_VoltAutoRifle', iconID=59, hotkey="9", title="MOBIUS"		 ,desc="Good Vs:\n-Infrantry\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Buildings",					cost="1000",type=2,damage=3,range=3,rateOfFire=6,magCap=4)
	GDIClassMenuData(9) 			= (BlockType=EPBT_CLASS, id=14, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun', iconID=50, hotkey="0", title="HOTWIRE"		 ,desc="Pros:\n-Building Destruction\n-Repairing/Healing\n\nCons:\n-No Defensive Weapon\n-Short Range",	cost="350", type=2,damage=6,range=1,rateOfFire=6,magCap=6)

	GDIItemMenuData(0) 				= (BlockType=EPBT_ITEM, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_IonCannonBeacon', iconID=70, hotkey="1", title="ION CANNON BEACON", desc="<font size='8'>Pros:\n-Instant Building Destruction\n-Large Blast Radius\n\nCons:\n-60 Seconds for impact(Dismantle)\n-5 seconds for deployment\n-Statitargets only</font>", 	cost="1000", type=1)
	GDIItemMenuData(1) 				= (BlockType=EPBT_ITEM, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Airstrike_A10', iconID=62, hotkey="2", title="A-10 AIRSTRIKE",	desc="<font size='8'>Pros:\n-5 seconds to impact\n-Quick bombardment\n-Anti-Infrantry/Vehicle\n\nCons:\n-Weak Vs. Buildings</font>", 												cost="800",  type=1)
	GDIItemMenuData(2) 				= (BlockType=EPBT_ITEM, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MedKit', iconID=66, hotkey="3", title="MEDICAL KIT",	 	desc="<font size='8'>Pros:\n-Heals near by infrantry\n-30 seconds before depletion\n\nCons:\n-Heals near by eenemies as well\n-Cannot refill</font>", 								cost="150",  type=1 , bEnable = false)
	GDIItemMenuData(3) 				= (BlockType=EPBT_ITEM, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_AmmoKit', iconID=64, hotkey="4", title="AMMUNITION KIT",	desc="<font size='8'>Pros:\n-Rearms near by infrantry\n-30 seconds before depletion\n\nCons:\n-Rearms near by enemies as well\n-Cannot refill</font>", 								cost="150",  type=1 , bEnable = false)
	GDIItemMenuData(4) 				= (BlockType=EPBT_ITEM, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MechanicalKit', iconID=65, hotkey="5", title="MECHANICAL KIT",	desc="<font size='8'>Pros:\n-Repairs near by vehicles\n-30 seconds before depletion\n\nCons:\n-Repairs near by enemies as well\n-Cannot refill</font>", 							cost="150",  type=1 , bEnable = false)
	GDIItemMenuData(5) 				= (BlockType=EPBT_ITEM, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MotionSensor', iconID=67, hotkey="6", title="MOTION SENSOR",	 	desc="<font size='8'>Pros:\n-Relays enemy position in a radius\n-Detects mines and beacons\n\nCons:\n-Emits an audible sound\n-Cannot refill</font>", 								cost="200",  type=1 , bEnable = false)
	GDIItemMenuData(6) 				= (BlockType=EPBT_ITEM, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_MG', iconID=68, hotkey="7", title="MG SENTRY",	 	 	desc="<font size='8'>Requires Armory\n\n-Automated Sentry Turret\n-Anti-Infrantry\n-Limited Ammo\n-Can be picked up\n-Cannot refill</font>", 										cost="300",  type=1 , bEnable = false)
	GDIItemMenuData(7) 				= (BlockType=EPBT_ITEM, id=7, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_AT', iconID=69, hotkey="8", title="AT SENTRY",	 	 	desc="<font size='8'>Requires Armory\n\n-Automated Sentry Turret\n-Anti-Vehicle\n-Limited Ammo\n-Can be picked up\n-Cannot refill</font>", 											cost="300",  type=1 , bEnable = false)

	GDIWeaponMenuData(0) 			= (BlockType=EPBT_WEAPON, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_HeavyPistol', iconID=36, hotkey="1", title="HEAVY PISTOL",	 		  desc="Good Vs:\n-Infantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Buildings\n-Light Armour Vehicles",									 cost="100", type=2, damage=4,range=2,rateOfFire=3,magCap=2)
	GDIWeaponMenuData(1) 			= (BlockType=EPBT_WEAPON, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Carbine', iconID=72, hotkey="2", title="CARBINE",	 			      desc="Good Vs:\n-Infantry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",														 cost="250", type=2, damage=3,range=3,rateOfFire=4,magCap=2)
	GDIWeaponMenuData(2) 			= (BlockType=EPBT_WEAPON, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibFlechetteRifle', iconID=57, hotkey="3", title="TIBERIUM FLECHETTE RIFLE",  desc="<font size='8'>[Requires Silo] \nGood Vs: \n-Infrantry\n-Light Armour\nWeak Vs:\n-Heavy Armour\n-Buildings</font>",				 cost="400", type=2, damage=2,range=3,rateOfFire=5,magCap=3, bSilo = true)
	GDIWeaponMenuData(3) 			= (BlockType=EPBT_WEAPON, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibAutoRifle', iconID=56, hotkey="4", title="TIBERIUM AUTO-RIFLE",		  desc="<font size='8'>[Requires Silo] \nGood Vs: \n-Infrantry\n-Light Armour\nWeak Vs:\n-Heavy Armour\n-Buildings</font>",				 cost="400", type=2, damage=4,range=3,rateOfFire=2,magCap=3, bSilo = true)
	GDIWeaponMenuData(4) 			= (BlockType=EPBT_WEAPON, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_EMPGrenade', iconID=30, hotkey="5", title="EMP GRENADE",	 			  desc="<font size='8'>\nPros:\n-Disables vehicles\n-Disarm mines\n\nCons:\n-Weapons remain active</font>", 					 		 cost="300", type=1)
	GDIWeaponMenuData(5) 			= (BlockType=EPBT_WEAPON, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ATMine', iconID=26, hotkey="6", title="ANTI-TANK MINE",	 	 	  desc="<font size='8'>\nPros:\n-Heavy vehicle damage\n\nCons:\n-Can be destroyed\n-Limit 2 per person</font>",							 cost="250", type=1)
	GDIWeaponMenuData(6) 			= (BlockType=EPBT_WEAPON, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SmokeGrenade', iconID=74, hotkey="7", title="SMOKE GRENADE",	 	      desc="<font size='8'>\nPros:\n-Reduces Visibility\n-Disables Target Info\n\nCons:\n-Weapons remain active</font>", 					 cost="100", type=1)

	GDIVehicleMenuData(0) 			= (BlockType=EPBT_VEHICLE, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_Humvee', iconID=9,  hotkey="1",title="HUMVEE",								desc="<font size='10'>-.50 Calibre Machine Gun\n-Light Armour\n-Fast Attack Scout\n-Driver + Passenger</font>",				cost="350")
	GDIVehicleMenuData(1) 			= (BlockType=EPBT_VEHICLE, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_APC', iconID=7,  hotkey="2",title="ARMOURED PERSONNEL CARRIER",			desc="<font size='10'>-M134 Minigun\n-Heavy Armour\n-Troop Transport\n-Driver + 4 Passengers</font>",						cost="500")
	GDIVehicleMenuData(2) 			= (BlockType=EPBT_VEHICLE, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_MRLS', iconID=12, hotkey="3",title="MOBILE ROCKET LAUNCHER SYSTEM",		desc="<font size='10'>-M269 Missiles\n-Light Armour\n-Long Range Ballistics\n-Driver + Passenger</font>",					cost="450")
	GDIVehicleMenuData(3) 			= (BlockType=EPBT_VEHICLE, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_MediumTank', iconID=11, hotkey="4",title="MEDIUM TANK",							desc="<font size='10'>-105mm Cannon\n-Heavy Armour\n-Main Battle Tank\n-Driver + Passenger</font>",							cost="800")
	GDIVehicleMenuData(4) 			= (BlockType=EPBT_VEHICLE, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_MammothTank', iconID=10, hotkey="5",title="MAMMOTH TANK",						desc="<font size='10'>-2x 120mm Cannons\n-4x Tusk Missiles\n-Heavy Armour\n-Heavy Battle Tank\n-Driver + Passenger</font>",	cost="1500")
	GDIVehicleMenuData(5) 			= (BlockType=EPBT_VEHICLE, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_TransportHelicopter', iconID=24, hotkey="7",title="TRANSPORT HELICOPTER",				desc="<font size='10'>-2x Gattling Guns\n-Light Armour\n-Troop Transport\n-Pilot + 4 Passengers</font>",					cost="700", bAircraft = true)
	GDIVehicleMenuData(6) 			= (BlockType=EPBT_VEHICLE, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_Orca', iconID=13, hotkey="8",title="ORCA FIGHTER",						desc="<font size='10'>-Hellfire Missiles\n-.50 Calibre Machine Gun\n-Light Armour\n-Attack VTOL\n-Pilot Only</font>",		cost="900", bAircraft = true)

	NodMainMenuData(0) 				= (BlockType=EPBT_CLASS, id=0,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Autorifle', iconID=27, hotkey="1", title="SOLDIER",	 	 desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Buildings\n-Heavy Armour Vehicles",	cost="FREE", type=2, damage=1, range=3, rateOfFire=5, magCap=4 )
	NodMainMenuData(1) 				= (BlockType=EPBT_CLASS, id=1,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Shotgun', iconID=52, hotkey="2", title="SHOTGUNNER",	 desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Vehicles, Buildings\n-Heavy Armour",	cost="FREE", type=2, damage=3, range=1, rateOfFire=2, magCap=2 )
	NodMainMenuData(2) 				= (BlockType=EPBT_CLASS, id=2,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_FlameThrower', iconID=32, hotkey="3", title="FLAMETHROWER", desc="Good Vs:\n-Infrantry\n-Light Armour\n-Buildings\n\nWeak Vs:\n-Heavy Armour",						cost="FREE", type=2, damage=2, range=1, rateOfFire=4, magCap=4 )
	NodMainMenuData(3) 				= (BlockType=EPBT_CLASS, id=3,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MarksmanRifle', iconID=41, hotkey="4", title="MARKSMAN",	 desc="Good Vs:\n-Infrantry\n-Light Armour\n\nWeak Vs:\n-Vehicles, Buildings\n-Heavy Armour",			cost="FREE", type=2, damage=3, range=5, rateOfFire=3, magCap=2 )
	NodMainMenuData(4) 				= (BlockType=EPBT_CLASS, id=4,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun', iconID=50, hotkey="5", title="ENGINEER",	 desc="Pros:\n-Building Destruction\n-Repairing/Healing\n\nCons:\n-No Offensive Weapon\n-Short Ranged",	cost="FREE", type=2, damage=3, range=1, rateOfFire=6, magCap=6 )
	NodMainMenuData(5) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Refill', iconID=05, hotkey="R", title="REFILL",	 	 desc="\nRefill Health\nRefill Armour\nRefill Ammo\nRefill Stamina",									cost="MENU", type=1 )
	NodMainMenuData(6) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapons', iconID=60, hotkey="W", title="WEAPONS",	 	 desc="\n\nSidearms\nGrenades\nSupport Weapons",														cost="MENU", type=1 )
	NodMainMenuData(7) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_ItemsNod', iconID=04, hotkey="Q", title="ITEM",		 desc="\n\nSuperweapons\nEquipment\nDeployables",														cost="MENU", type=1 )
	NodMainMenuData(8) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Characters', iconID=02, hotkey="C", title="CHARACTERS",	 desc="",																								cost="MENU", type=1 )
	NodMainMenuData(9) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Vehicles_Nod', iconID=61, hotkey="V", title="VEHICLES",	 desc="",																								cost="MENU", type=1 )

	NodClassMenuData(0)				= (BlockType=EPBT_CLASS, id=5,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Chaingun', iconID=28, hotkey="1", title="OFFICER",				desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Buildings\n-Heavy Armour Vehicles",	cost="175",  type=2, damage=1, range=3, rateOfFire=6, magCap=6)
	NodClassMenuData(1)				= (BlockType=EPBT_CLASS, id=6,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MissileLauncher', iconID=42, hotkey="2", title="ROCKET SOLDIER",		desc="Good Vs:\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Infratry\n-Buildings",						cost="225",  type=2, damage=4, range=5, rateOfFire=1, magCap=1)
	NodClassMenuData(2)				= (BlockType=EPBT_CLASS, id=7,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ChemicalThrower', iconID=29, hotkey="3", title="CHEMICAL TROOPER",	desc="Good Vs:\n-Infratry\n-Light Armour\n-Buildings\n\nWeak Vs:\n-Heavy Armour",						cost="150",  type=2, damage=3, range=1, rateOfFire=4, magCap=4)
	NodClassMenuData(3)				= (BlockType=EPBT_CLASS, id=8,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SniperRifle', iconID=54, hotkey="4", title="BLACK HAND SNIPER",	desc="Good Vs:\n-Infrantry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",						cost="500",  type=2, damage=4, range=6, rateOfFire=1, magCap=2)
	NodClassMenuData(4)				= (BlockType=EPBT_CLASS, id=9,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_LaserRifle', iconID=39, hotkey="5", title="STEALTH BLACK HAND",	desc="Good Vs:\n-Infrantry\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Buildings",						cost="400",  type=2, damage=3, range=4, rateOfFire=4, magCap=3)
	NodClassMenuData(5)				= (BlockType=EPBT_CLASS, id=10, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_LaserChaingun', iconID=38, hotkey="6", title="LASER CHAINGUNNER",	desc="Good Vs:\n-Infratry\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Buildings",						cost="450",  type=2, damage=3, range=3, rateOfFire=5, magCap=5)
	NodClassMenuData(6)				= (BlockType=EPBT_CLASS, id=11, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RamjetRifle', iconID=48, hotkey="7", title="SAKURA",				desc="Good Vs:\n-Infrantry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",						cost="1000", type=2, damage=5, range=6, rateOfFire=2, magCap=2)
	NodClassMenuData(7)				= (BlockType=EPBT_CLASS, id=12, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Railgun', iconID=47, hotkey="8", title="RAVESHAW",			desc="Good Vs:\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Infrantry\n-Buildings",						cost="1000", type=2, damage=6, range=4, rateOfFire=1, magCap=2)
	NodClassMenuData(8)				= (BlockType=EPBT_CLASS, id=13, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_VoltAutoRifle', iconID=59, hotkey="9", title="MENDOZA",				desc="Good Vs:\n-Infrantry\n-Light Armour\n-Heavy Armour\n\nWeak Vs:\n-Buildings",						cost="1000", type=2, damage=3, range=3, rateOfFire=6, magCap=4)
	NodClassMenuData(9)				= (BlockType=EPBT_CLASS, id=14, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun', iconID=50, hotkey="0", title="TECHNICIAN",			desc="Pros:\n-Building Destruction\n-Repairing/Healing\n\nCons:\n-No Defensive Weapon\n-Short Range",	cost="350",  type=2, damage=6, range=1, rateOfFire=6, magCap=6)


	NodItemMenuData(0)				= (BlockType=EPBT_ITEM, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_NukeBeacon', iconID=71, hotkey="1", title="NUKE STRIKE BEACON", desc="<font size='8'>Pros:\n-Instant Building Destruction\n-Large Blast Radius\n\nCons:\n-60 Seconds for impact(Dismantle)\n-5 seconds for deployment\n-Statitargets only</font>", cost="1000", type=1)
	NodItemMenuData(1)				= (BlockType=EPBT_ITEM, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Airstrike_AC130', iconID=63, hotkey="2", title="AC-130 AIRSTRIKE",	 desc="<font size='8'>Pros:\n-5 seconds to impact\n-Quick bombardment\n-Anti-Infrantry/Vehicle\n\nCons:\n-Weak Vs. Buildings</font>", 												cost="800" , type=1)
	NodItemMenuData(2)				= (BlockType=EPBT_ITEM, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MedKit', iconID=66, hotkey="3", title="MEDICAL KIT",	 	 desc="<font size='8'>Pros:\n-Heals near by infrantry\n-30 seconds before depletion\n\nCons:\n-Heals near by eenemies as well\n-Cannot refill</font>", 								cost="150" , type=1, bEnable = false)
	NodItemMenuData(3)				= (BlockType=EPBT_ITEM, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_AmmoKit', iconID=64, hotkey="4", title="AMMUNITION KIT",	 desc="<font size='8'>Pros:\n-Rearms near by infrantry\n-30 seconds before depletion\n\nCons:\n-Rearms near by enemies as well\n-Cannot refill</font>", 							cost="150" , type=1, bEnable = false)
	NodItemMenuData(4)				= (BlockType=EPBT_ITEM, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MechanicalKit', iconID=65, hotkey="5", title="MECHANICAL KIT",	 desc="<font size='8'>Pros:\n-Repairs near by vehicles\n-30 seconds before depletion\n\nCons:\n-Repairs near by enemies as well\n-Cannot refill</font>", 							cost="150" , type=1, bEnable = false)
	NodItemMenuData(5)				= (BlockType=EPBT_ITEM, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MotionSensor', iconID=67, hotkey="6", title="MOTION SENSOR",	 	 desc="<font size='8'>Pros:\n-Relays enemy position in a radius\n-Detects mines and beacons\n\nCons:\n-Emits an audible sound\n-Cannot refill</font>", 								cost="200" , type=1, bEnable = false)
	NodItemMenuData(6)				= (BlockType=EPBT_ITEM, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_MG', iconID=68, hotkey="7", title="MG SENTRY",	 		 desc="<font size='8'>Requires Armory\n\n-Automated Sentry Turret\n-Anti-Infrantry\n-Limited Ammo\n-Can be picked up\n-Cannot refill</font>", 										cost="300" , type=1, bEnable = false)
	NodItemMenuData(7)				= (BlockType=EPBT_ITEM, id=7, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_AT', iconID=69, hotkey="8", title="AT SENTRY",	 		 desc="<font size='8'>Requires Armory\n\n-Automated Sentry Turret\n-Anti-Vehicle\n-Limited Ammo\n-Can be picked up\n-Cannot refill</font>", 										cost="300" , type=1, bEnable = false)


	NodWeaponMenuData(0)			= (BlockType=EPBT_WEAPON, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_HeavyPistol', iconID=36, hotkey="1", title="HEAVY PISTOL",	 		  desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Buildings\n-Light Armour Vehicles", 									 cost="100", type=2, damage=4,range=2,rateOfFire=3,magCap=2)
	NodWeaponMenuData(1)			= (BlockType=EPBT_WEAPON, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Carbine', iconID=72, hotkey="2", title="CARBINE",	 			      desc="Good Vs:\n-Infantry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",	 													 cost="250", type=2, damage=3,range=3,rateOfFire=4,magCap=2)
	NodWeaponMenuData(2)			= (BlockType=EPBT_WEAPON, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibFlechetteRifle', iconID=57, hotkey="3", title="TIBERIUM FLECHETTE RIFLE",  desc="<font size='8'>[Requires Silo] \nGood Vs: \n-Infrantry\n-Light Armour\nWeak Vs:\n-Heavy Armour\n-Buildings</font>",				 cost="400", type=2, damage=2,range=3,rateOfFire=5,magCap=3, bSilo = true)
	NodWeaponMenuData(3)			= (BlockType=EPBT_WEAPON, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibAutoRifle', iconID=56, hotkey="4", title="TIBERIUM AUTO-RIFLE",	 	  desc="<font size='8'>[Requires Silo] \nGood Vs: \n-Infrantry\n-Light Armour\nWeak Vs:\n-Heavy Armour\n-Buildings</font>",				 cost="400", type=2, damage=4,range=3,rateOfFire=2,magCap=3, bSilo = true)
	NodWeaponMenuData(4)			= (BlockType=EPBT_WEAPON, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_EMPGrenade', iconID=30, hotkey="5", title="EMP GRENADE",	 			  desc="<font size='8'>\nPros:\n-Disables vehicles\n-Disarm mines\n\nCons:\n-Weapons remain active</font>", 					 		 cost="300", type=1)
	NodWeaponMenuData(5)			= (BlockType=EPBT_WEAPON, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ATMine', iconID=26, hotkey="6", title="ANTI-TANK MINE",	 		  desc="<font size='8'>\nPros:\n-Heavy vehicle damage\n\nCons:\n-Can be destroyed\n-Limit 2 per person</font>", 						 cost="250", type=1)
	NodWeaponMenuData(6) 			= (BlockType=EPBT_WEAPON, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SmokeGrenade', iconID=74, hotkey="7", title="SMOKE GRENADE",	 	      desc="<font size='8'>\nPros:\n-Reduces Visibility\n-Disables Target Info\n\nCons:\n-Weapons remain active</font>", 					 cost="100", type=1)


	NodVehicleMenuData(0)			= (BlockType=EPBT_VEHICLE, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_Buggy', iconID=20, hotkey="1", title="BUGGY", 						desc="<font size='10'>-.50 Calibre Machine Gun\n-Light Armour\n-Fast Attack Scout\n-Driver + Passenger</font>", 		 cost="350")
	NodVehicleMenuData(1)			= (BlockType=EPBT_VEHICLE, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_APC', iconID=18, hotkey="2", title="ARMOURED PERSONNEL CARRIER", desc="<font size='10'>-M134 Minigun\n-Heavy Armour\n-Troop Transport\n-Driver + 4 Passengers</font>", 					 cost="500")
	NodVehicleMenuData(2)			= (BlockType=EPBT_VEHICLE, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_Artillery', iconID=19, hotkey="3", title="MOBILE ARTILLERY", 			desc="<font size='10'>\n-155mm Howitzer\n-Light Armour\n-Long Range Ballistics\n-Driver + Passenger</font>", 			 cost="450")
	NodVehicleMenuData(3)			= (BlockType=EPBT_VEHICLE, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_FlameTank', iconID=21, hotkey="4", title="FLAME TANK", 				desc="<font size='10'>\n-2x Flame Throwers\n-Heavy Armour\n-Close Range Suppressor\n-Driver + Passenger</font>", 		 cost="800")
	NodVehicleMenuData(4)			= (BlockType=EPBT_VEHICLE, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_LightTank', iconID=22, hotkey="5", title="LIGHT TANK", 				desc="<font size='10'>\n-75mm Cannon\n-Heavy Armour\n-Main Battle Tank\n-Driver + Passenger</font>", 					 cost="600")
	NodVehicleMenuData(5)			= (BlockType=EPBT_VEHICLE, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_StealthTank', iconID=23, hotkey="6", title="STEALTH TANK", 				desc="<font size='10'>-2x TOW Missiles\n-Heavy Armour\n-Guerilla Combat Vehicle\n-Active Camouflage\n-DriveOnly</font>", cost="900")
	NodVehicleMenuData(6)			= (BlockType=EPBT_VEHICLE, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_TransportHelicopter', iconID=24, hotkey="7", title="TRANSPORT HELICOPTER", 		desc="<font size='10'>\n-2x Gattling Guns\n-Light Armour\n-Troop Transport\n-Pilot + 4 Passengers</font>", 				 cost="700", bAircraft = true)
	NodVehicleMenuData(7)			= (BlockType=EPBT_VEHICLE, id=7, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_Apache', iconID=17, hotkey="8", title="APACHE", 					desc="<font size='10'>-30mm Auto-Cannon\n-Hydra-70 Rockets\n-Light Armour\n-Attack Helocopter\n-Pilot Only</font>", 	 cost="900", bAircraft = true)


	GDIEquipmentSideArmData(0) 		= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Pistol', iconID=45, hotkey="[F1]", title="Silenced Pistol",  desc="Sidearm", 	WeaponClass = class'Rx_Weapon_Pistol',      bFree=true);
	GDIEquipmentSideArmData(1) 		= (id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MachinePistol', iconID=40, hotkey="[F1]", title="Machine Pistol",   desc="Sidearm", 	WeaponClass = class'Rx_Weapon_SMG_GDI',     bFree=true);
	GDIEquipmentSideArmData(2) 		= (id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairTool', iconID=73, hotkey="[F1]", title="Repair Tool",      desc="Sidearm", 	WeaponClass = class'Rx_Weapon_RepairTool',  bFree=true, bEnable=false);
	GDIEquipmentSideArmData(3) 		= (id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_HeavyPistol', iconID=36, hotkey="[F1]", title="Heavy Pistol",     desc="Sidearm", 	WeaponClass = class'Rx_Weapon_HeavyPistol');
	GDIEquipmentSideArmData(4) 		= (id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Carbine', iconID=72, hotkey="[F1]", title="Carbine",          desc="Sidearm", 	WeaponClass = class'Rx_Weapon_Carbine');
	GDIEquipmentSideArmData(5) 		= (id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibFlechetteRifle', iconID=57, hotkey="[F1]", title="Flechette Rifle",  desc="Sidearm", 	WeaponClass = class'Rx_Weapon_TiberiumFlechetteRifle');
	GDIEquipmentSideArmData(6) 		= (id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibAutoRifle', iconID=56, hotkey="[F1]", title="Auto-Rifle",       desc="Sidearm", 	WeaponClass = class'Rx_Weapon_TiberiumAutoRifle');

	GDIEquipmentExplosiveData(0) 	= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TimedC4', iconID=58, hotkey="[F2]", title="Timed C4", 		 desc="Explosives", WeaponClass = class'Rx_Weapon_TimedC4',     bFree=true);
	GDIEquipmentExplosiveData(1) 	= (id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_FragGrenade', iconID=33, hotkey="[F2]", title="Grenades", 		 desc="Explosives", WeaponClass = class'Rx_Weapon_Grenade',     bFree=true);
	GDIEquipmentExplosiveData(2) 	= (id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SmokeGrenade', iconID=74, hotkey="[F2]", title="Smoke Grenade", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_SmokeGrenade');
	GDIEquipmentExplosiveData(3) 	= (id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_EMPGrenade', iconID=30, hotkey="[F2]", title="EMP Grenade", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_EMPGrenade');
	GDIEquipmentExplosiveData(4) 	= (id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ATMine', iconID=26, hotkey="[F2]", title="Anti-Tank Mine", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_ATMine');
	GDIEquipmentExplosiveData(5) 	= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ProxyC4', iconID=46, hotkey="[F2]", title="Proximity C4", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_ProxyC4');
	GDIEquipmentExplosiveData(6) 	= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RemoteC4', iconID=49, hotkey="[F2]", title="Remote C4", 	     desc="Explosives", WeaponClass = class'Rx_Weapon_RemoteC4');

	NodEquipmentSideArmData(0) 		= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Pistol', iconID=45, hotkey="[F1]", title="Silenced Pistol",  desc="Sidearm", 	WeaponClass = class'Rx_Weapon_Pistol',      bFree=true);
	NodEquipmentSideArmData(1) 		= (id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MachinePistol', iconID=40, hotkey="[F1]", title="Machine Pistol",   desc="Sidearm", 	WeaponClass = class'Rx_Weapon_SMG_Nod',     bFree=true);
	NodEquipmentSideArmData(2) 		= (id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairTool', iconID=73, hotkey="[F1]", title="Repair Tool",      desc="Sidearm", 	WeaponClass = class'Rx_Weapon_RepairTool',  bFree=true, bEnable=false);
	NodEquipmentSideArmData(3) 		= (id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_HeavyPistol', iconID=36, hotkey="[F1]", title="Heavy Pistol",     desc="Sidearm", 	WeaponClass = class'Rx_Weapon_HeavyPistol');
	NodEquipmentSideArmData(4) 		= (id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Carbine', iconID=72, hotkey="[F1]", title="Carbine",          desc="Sidearm", 	WeaponClass = class'Rx_Weapon_Carbine');
	NodEquipmentSideArmData(5) 		= (id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibFlechetteRifle', iconID=57, hotkey="[F1]", title="Flechette Rifle",  desc="Sidearm", 	WeaponClass = class'Rx_Weapon_TiberiumFlechetteRifle');
	NodEquipmentSideArmData(6) 		= (id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibAutoRifle', iconID=56, hotkey="[F1]", title="Auto-Rifle",       desc="Sidearm", 	WeaponClass = class'Rx_Weapon_TiberiumAutoRifle');

	NodEquipmentExplosiveData(0)	= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TimedC4', iconID=58, hotkey="[F2]", title="Timed C4", 		 desc="Explosives", WeaponClass = class'Rx_Weapon_TimedC4',      bFree=true);
	NodEquipmentExplosiveData(1) 	= (id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_FragGrenade', iconID=33, hotkey="[F2]", title="Grenades", 		 desc="Explosives", WeaponClass = class'Rx_Weapon_Grenade',      bFree=true);
	NodEquipmentExplosiveData(2) 	= (id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SmokeGrenade', iconID=74, hotkey="[F2]", title="Smoke Grenade", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_SmokeGrenade');
	NodEquipmentExplosiveData(3) 	= (id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_EMPGrenade', iconID=30, hotkey="[F2]", title="EMP Grenade", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_EMPGrenade');
	NodEquipmentExplosiveData(4) 	= (id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ATMine', iconID=26, hotkey="[F2]", title="Anti-Tank Mine", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_ATMine');
	NodEquipmentExplosiveData(5) 	= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ProxyC4', iconID=46, hotkey="[F2]", title="Proximity C4", 	 desc="Explosives", WeaponClass = class'Rx_Weapon_ProxyC4');
	NodEquipmentExplosiveData(6) 	= (id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RemoteC4', iconID=49, hotkey="[F2]", title="Remote C4", 	     desc="Explosives", WeaponClass = class'Rx_Weapon_RemoteC4');
	
	 /** one1: Added. */
	 RotationIncrement 				= 1000
	MouseRotationIncrement          = 0
}