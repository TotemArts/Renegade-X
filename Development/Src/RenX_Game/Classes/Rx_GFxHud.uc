/*********************************************************
*
* File: Rx_GFxHud.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class handles the creation and modification of the 
* Flash HUD (not items like the reticule) every tick. 
* It is created and called by Rx_HUD.uc.	
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/


class Rx_GFxHud extends GFxMoviePlayer;

struct SBPlayerEntry
{
	var GFxObject EntryLine;
	var GFxObject PlayerName;
	var GFxObject Kills;
	var GFxObject Deaths;
	var GFXObject KDRatio;
	var GFxObject Credits;
	var GFxObject Score;
	var bool bNew;
};

struct BuildingInfo
{
	var GFxObject Icon;
	var GFxObject Stats;
};

struct MessageRow
{
	var GFxObject  MC, TF;
	var int     ConcatDisableTime;//StartFadeTime;
	var int       Y;
	var int		  TextEmphasis; //Add this to the text font size 
};

struct MenuOption
{
	var int Position;
	var string Key;
	var string Message;
	var ASColorTransform myCT;
};

enum EMessageType
{
	EMT_EVA,
	EMT_Chat,
	EMT_Death
};

var GFxObject     ChatLogMC, DeathLogMC, EVALogMC;
var array<MessageRow>   ChatMessages, DeathMessages, EVAMessages;
var array<MessageRow>   FreeChatMessages, FreeDeathMessages, FreeEVAMessages;
var float               MessageHeight;
var int                 NumEVAMessages, NumChatMessages, NumDeathMessages;

var array<string>		Subtitle_Messages; 

var BuildingInfo BuildingInfo_GDI[5];
var BuildingInfo BuildingInfo_Nod[5];

var() Rx_GFxMinimap Minimap;
var() Rx_GFxMarker Marker;
var Rx_GFxOverviewMap OverviewMapMovie;

var Rx_Hud RenxHud;

//Flash radio message menu
var GFxObject header, line1, line2, line3, line4, line5, line6, line7, line8, line9, line10, line11, line12, line13, line14, line15, SideMenu;
var GFxObject key1, key2, key3, key4, key5, key6, key7, key8, key9, key10, key11, key12, key13, key14, key15;
var GFxObject HelpMenu, hline1, hline2, hline3, hline4, hline5, hline6, hline7, hline8, hline9, hline10, hline11, hline12, hline13, hline14, hline15, hline16, hline17, hline18, hline19, hline20, hline21, hline22;
var array<GFxObject> Lines, Keys, HelpLines;
var ASColorTransform DefaultCT;

//Cache variables
var int LastHealthpc, LastArmorpc, LastStaminapc, LastVArmorpc;
var int AmmoInClipValue, AmmoInReserveValue, AltAmmoInClipValue, AltAmmoInReserveValue;
var float primaryReloadTimeEllapsed, secondaryReloadTimeEllapsed;
var bool isInVehicle;
var int currentScoreboard;
var int CurrentTime;
var int CurrentNumVehicles;
var int CurrentMaxVehicles;
var int CurrentNumMines;
var int CurrentMaxMines;

var UTWeapon lastWeaponHeld;  //variable containing weapon user had last time hud was updated
var UTWeapon prevWeapon;      //variable containing previous weapon in player inventory (different from above)
var UTWeapon nextWeapon;      //variable containing next weapon in player inventory

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject HealthBlock, HealthBar, HealthN, HealthMaxN, HealthText, HealthIcon, VHealthN;//nBab
var GFxObject VArmorN, VArmorBar, VehicleMC, VArmorMaxN;
var GFxObject ArmorBar, ArmorN, ArmorMaxN;
var GFxObject StaminaBar;
var GFxObject AmmoInClipN, AmmoBar, AmmoReserveN, AltAmmoInClipN, AltAmmoBar, InfinitAmmo, AltInfinitAmmo, WeaponBlock, VAltWeaponBlock;
var GFxObject WeaponMC, WeaponPrevMC, WeaponNextMC, VBackdrop, WeaponName, AltWeaponName;
var GFxObject AbilityMC, AbilityIconMC, AbilityMeterMC, AbilityTextMC;

//Experimental Progress bar
var GFXObject LoadingMeterMC[2], LoadingText[2];
var GFxClikWidget LoadingBarWidget[2];

var GFxObject GrenadeN, GrenadeMC, TimedC4MC, RemoteC4MC, ProxyC4MC, BeaconMC;
var GFxObject HitLocMC[8];
var GFxObject BottomInfo;
var GFxObject Credits;
var GFxObject MatchTimer;
var GFxObject VehicleCount;
var GFxObject MineCount;
var GFxObject CommPoints;
var GFxObject DirCompassIcon;
var GFxObject RootMC;
 
var GFxObject Scoreboard;
var GFxObject SBTeamScore[2];
var GFxObject SBTeamCredits[2], SBTeamKills[2], SBTeamDeaths[2], SBTeamKDR[2];
var const int NumPlayerStats;
var array<SBPlayerEntry> PlayerInfo;
var int CurrentNumberPRIs;

//MessageBox Variables (nBab)
var string lastPrivateNick;
var string PrivateMessages[10];
var string NormalMessages[10];
var string TeamMessages[10];
var int messageNum;

//Tech Building Icon Variables (nBab)
var array<Actor> Silo;
var Actor Fort;
var Actor MC;
var Actor CC;
var Actor EMP;
var byte buildingCount;

var byte gdi_buildings, nod_buildings;
var array<string> tech_buildings;
var array<byte> tech_buildings_team;
var gfxobject tech_building_icons[5];
var gfxobject tech_icons;
var byte TechIconTweenDuration;
var Rx_Building GDIInfantryFactory;
var bool SetupTechIcons;

//Respawn Hud Variables (nBab)
var int lastFreeClass;
var int lastTeam;

//Veterancy Variables (nBab)
var int VRank;

//Voting Variables (nBab)
var bool voteJustStarted;
var gfxobject voteTextMC;

//items that we are diabling for now - THIS LIST SHOULD BE EMPTY BY THE TIME THE HUD IS DONE
var GFxObject ObjectiveMC, ObjectiveText, TimerMC, TimerText, FadeScreenMC, SubtitlesText, GameplayTipsText, WeaponPickup;
var float LastTipsUpdateTime;
var float VehicleDeathMsgTime;
var float VehicleDeathDisplayLength;
var float VPMsg_Cycler;
var byte Tick_Cycler; 
var int	 SkipNum; 
var bool bUseTickCycle; 

var name AbilityKey; 

function Initialize()
{
	local byte i;
	//Start and load the SWF Movie
	Start();
	Advance(0.f);

	CurrentNumberPRIs = 0;
	CurrentNumVehicles = -1;
	CurrentMaxVehicles = -1;
	NumEVAMessages = 0;
	NumChatMessages = 0;
	NumDeathMessages = 0;

	//Log Implementation
	ChatLogMC = GetVariableObject("_root.chatLog");
	DeathLogMC = GetVariableObject("_root.deathLog");
	EVALogMC = GetVariableObject("_root.evaLog");
	//TODO:set the max limit of each count
	for(i = 0; i < 1; i++) {
		InitMessageRow(EMessageType.EMT_EVA, NumEVAMessages);
	}
	for(i = 0; i < 12; i++) {
		InitMessageRow(EMessageType.EMT_Chat, NumChatMessages);
	}
	for(i = 0; i < 5; i++) {
		InitMessageRow(EMessageType.EMT_Death, NumDeathMessages);
	}

	UpdateHUDVars();

	//hit indicator
	HitLocMC[0] = GetVariableObject("_root.dirHit.t");
	HitLocMC[1] = GetVariableObject("_root.dirHit.tr");
	HitLocMC[2] = GetVariableObject("_root.dirHit.r");
	HitLocMC[3] = GetVariableObject("_root.dirHit.br");
	HitLocMC[4] = GetVariableObject("_root.dirHit.b");
	HitLocMC[5] = GetVariableObject("_root.dirHit.bl");
	HitLocMC[6] = GetVariableObject("_root.dirHit.l");
	HitLocMC[7] = GetVariableObject("_root.dirHit.tl");

	//Flash vote/commander/radio menu
	SideMenu 	= GetVariableObject("_root.SideMenu");
	HelpMenu    = GetVariableObject("_root.SideMenu.HelpMenu");
	header      = GetVariableObject("_root.SideMenu.header");
	line1      = GetVariableObject("_root.SideMenu.line1");
	line2      = GetVariableObject("_root.SideMenu.line2");
	line3      = GetVariableObject("_root.SideMenu.line3");
	line4      = GetVariableObject("_root.SideMenu.line4");
	line5      = GetVariableObject("_root.SideMenu.line5");
	line6      = GetVariableObject("_root.SideMenu.line6");
	line7      = GetVariableObject("_root.SideMenu.line7");
	line8      = GetVariableObject("_root.SideMenu.line8");
	line9      = GetVariableObject("_root.SideMenu.line9");
	line10      = GetVariableObject("_root.SideMenu.line10");
	line11      = GetVariableObject("_root.SideMenu.line11");
	line12      = GetVariableObject("_root.SideMenu.line12");
	line13      = GetVariableObject("_root.SideMenu.line13");
	line14      = GetVariableObject("_root.SideMenu.line14");
	line15      = GetVariableObject("_root.SideMenu.line15");
	key1      = GetVariableObject("_root.SideMenu.key1");
	key2      = GetVariableObject("_root.SideMenu.key2");
	key3      = GetVariableObject("_root.SideMenu.key3");
	key4      = GetVariableObject("_root.SideMenu.key4");
	key5      = GetVariableObject("_root.SideMenu.key5");
	key6      = GetVariableObject("_root.SideMenu.key6");
	key7      = GetVariableObject("_root.SideMenu.key7");
	key8      = GetVariableObject("_root.SideMenu.key8");
	key9      = GetVariableObject("_root.SideMenu.key9");
	key10      = GetVariableObject("_root.SideMenu.key10");
	key11      = GetVariableObject("_root.SideMenu.key11");
	key12      = GetVariableObject("_root.SideMenu.key12");
	key13      = GetVariableObject("_root.SideMenu.key13");
	key14      = GetVariableObject("_root.SideMenu.key14");
	key15      = GetVariableObject("_root.SideMenu.key15");
	hline1      = GetVariableObject("_root.SideMenu.HLine1");
	hline2      = GetVariableObject("_root.SideMenu.HLine2");
	hline3      = GetVariableObject("_root.SideMenu.HLine3");
	hline4      = GetVariableObject("_root.SideMenu.HLine4");
	hline5      = GetVariableObject("_root.SideMenu.HLine5");
	hline6      = GetVariableObject("_root.SideMenu.HLine6");
	hline7      = GetVariableObject("_root.SideMenu.HLine7");
	hline8      = GetVariableObject("_root.SideMenu.HLine8");
	hline9      = GetVariableObject("_root.SideMenu.HLine9");
	hline10      = GetVariableObject("_root.SideMenu.HLine10");
	hline11      = GetVariableObject("_root.SideMenu.HLine11");
	hline12      = GetVariableObject("_root.SideMenu.HLine12");
	hline13      = GetVariableObject("_root.SideMenu.HLine13");
	hline14      = GetVariableObject("_root.SideMenu.HLine14");
	hline15      = GetVariableObject("_root.SideMenu.HLine15");
	hline16      = GetVariableObject("_root.SideMenu.HLine16");
	hline17      = GetVariableObject("_root.SideMenu.HLine17");
	hline18      = GetVariableObject("_root.SideMenu.HLine18");
	hline19      = GetVariableObject("_root.SideMenu.HLine19");
	hline20      = GetVariableObject("_root.SideMenu.HLine20");
	hline21      = GetVariableObject("_root.SideMenu.HLine21");
	hline22      = GetVariableObject("_root.SideMenu.HLine22");

	Lines.AddItem(line1);
	Lines.AddItem(line2);
	Lines.AddItem(line3);
	Lines.AddItem(line4);
	Lines.AddItem(line5);
	Lines.AddItem(line6);
	Lines.AddItem(line7);
	Lines.AddItem(line8);
	Lines.AddItem(line9);
	Lines.AddItem(line10);
	Lines.AddItem(line11);
	Lines.AddItem(line12);
	Lines.AddItem(line13);
	Lines.AddItem(line14);
	Lines.AddItem(line15);

	HelpLines.AddItem(hline1);
	HelpLines.AddItem(hline2);
	HelpLines.AddItem(hline3);
	HelpLines.AddItem(hline4);
	HelpLines.AddItem(hline5);
	HelpLines.AddItem(hline6);
	HelpLines.AddItem(hline7);
	HelpLines.AddItem(hline8);
	HelpLines.AddItem(hline9);
	HelpLines.AddItem(hline10);
	HelpLines.AddItem(hline11);
	HelpLines.AddItem(hline12);
	HelpLines.AddItem(hline13);
	HelpLines.AddItem(hline14);
	HelpLines.AddItem(hline15);
	HelpLines.AddItem(hline16);
	HelpLines.AddItem(hline17);
	HelpLines.AddItem(hline18);
	HelpLines.AddItem(hline19);
	HelpLines.AddItem(hline20);
	HelpLines.AddItem(hline21);
	HelpLines.AddItem(hline22);

	Keys.AddItem(key1);
	Keys.AddItem(key2);
	Keys.AddItem(key3);
	Keys.AddItem(key4);
	Keys.AddItem(key5);
	Keys.AddItem(key6);
	Keys.AddItem(key7);
	Keys.AddItem(key8);
	Keys.AddItem(key9);
	Keys.AddItem(key10);
	Keys.AddItem(key11);
	Keys.AddItem(key12);
	Keys.AddItem(key13);
	Keys.AddItem(key14);
	Keys.AddItem(key15);

	DefaultCT.add.R = 0.5;
	DefaultCT.add.G = 0.5;
	DefaultCT.add.B = 0.5;
	DefaultCT.multiply.R = 1.0;
	DefaultCT.multiply.G = 1.0;
	DefaultCT.multiply.B = 1.0;

	SideMenu.SetVisible(false);
	HelpMenu.SetVisible(false);

	SetupScoreboard();
	DisableHUDItems();

	//AddFocusIgnoreKey('t');

	prevWeapon = none;
	RootMC = GetVariableObject("_root");
	MineCount.SetText(0);

	//setup tech building icons (nBab)
	tech_icons = GetVariableObject("_root.BottomInfo.tech_icons");
	SetupTechIcons = true;

	//set lastfreeclass and lastteam for respawn hud (nBab)
	lastFreeClass = 0;
	lastTeam = GetPC().GetTeamNum();

	//set initial veterancy (nBab)
	VRank = 0;

	//set initial message number (nBab)
	messageNum = -1;

	//set initial messages (nBab)
	for (i=0;i<10;i++)
	{
		NormalMessages[i]="None";
		TeamMessages[i]="None";
		PrivateMessages[i]="None";
	}

	//set initial voting variables (nBab)
	voteJustStarted = true;
	
	AbilityKey = GetBoundKey("GBA_ToggleAbility");
}

function ResizedScreenCheck()
{
	// Resize the HUD after viewport size change
	local Vector2D ViewportSize;
	local float x0, y0, x1, y1;
	local Vector2D HudMovieSize;
	
	GetGameViewportClient().GetViewportSize(ViewportSize);
	Scoreboard.SetVisible(false);
	GetVisibleFrameRect(x0, y0, x1, y1);
	HudMovieSize.X = x1;
	HudMovieSize.Y = y1;
	//`Log("HudMovieSize="@HudMovieSize.X@HudMovieSize.Y@"ViewportSize="@ViewportSize.X@ViewportSize.Y);
	if(int(HudMovieSize.X) != int(ViewportSize.X) || int(HudMovieSize.Y) != int(ViewportSize.Y))
	{
		SetViewport(0,0,int(ViewportSize.X),int(ViewportSize.Y));
		SetViewScaleMode(GFxScaleMode.SM_ShowAll);
		SetAlignment(GFxAlign.Align_Center);
		
		GetVariableObject("_root.minimap").SetPosition(HudMovieSize.X * 0.0808,HudMovieSize.Y * 0.8545);
		GetVariableObject("_root.MarkerContainer").SetPosition(0,0);
		
		//center the icon container (nBab)
		//GetVariableObject("_root.BottomInfo").SetPosition(HudMovieSize.X * 0.3494/*0.4987*/,HudMovieSize.Y * 0.8952/*0.9586*/); (old line)
		GetVariableObject("_root.BottomInfo").SetPosition(HudMovieSize.X * 0.3466/*0.4987*/,HudMovieSize.Y * 0.8952/*0.9586*/);
		//set position of the message box (nBab)
		GetVariableObject("_root.messagebox").SetPosition(HudMovieSize.X * 0.29532/*0.4987*/,HudMovieSize.Y * 0.8/*0.9586*/);
		GetVariableObject("_root.HealthBlock").SetPosition(HudMovieSize.X * 0.1237,HudMovieSize.Y * 0.8728);
		GetVariableObject("_root.WeaponBlock").SetPosition(HudMovieSize.X * 0.7167,HudMovieSize.Y * 0.9775);
		GetVariableObject("_root.WeaponPickup").SetPosition(HudMovieSize.X * 0.3400,HudMovieSize.Y * 0.5855);
	}
	// END of resize code
	
	AbilityKey = GetBoundKey("GBA_ToggleAbility");
}

/**Called every update Tick*/
function TickHUD() 
{
	local Rx_Pawn RxP;
	local Pawn TempPawn;
	local Rx_Weapon RxWeap;
	local Rx_WeaponAbility RxAbility; //Always updated on the HUD as opposed to a regular weapon 
	local Rx_Vehicle RxV;
	local Rx_Vehicle_Weapon RxVWeap;
	local UTPlayerController RxPC;
	local Rx_GRI RxGRI;
	local byte i;
	local string FullVPString; 
	
	if (!bMovieIsOpen) {
		return;
	}
	
	RxPC = UTPlayerController(GetPC());
	
	if(RxPC == None) {
		return;
	}
	
	/**
	Tick Cycle 
	0: Vehicles/Vehicle Weapons
	1: Infantry Health/Ammo/Weapons
	2: Update Map
	*/
	
	if(bUseTickCycle && Tick_Cycler >= SkipNum)
	{
		Tick_Cycler=0;
		return;
	}
	else
	if(bUseTickCycle) Tick_Cycler+=1;
	
	if(RxPC.Pawn != None)
		TempPawn = RxPC.Pawn;
	else if(Pawn(RxPC.viewtarget) != None)
		TempPawn = Pawn(RxPC.viewtarget);		

	//assign all 4 var here. RxP RxV, RxWeap, RxVehicleWeap
	
		if (Rx_Pawn(TempPawn) != none) {
			RxP = Rx_Pawn(TempPawn);
			RxWeap = Rx_Weapon(RxP.Weapon);
			
			if(RxWeap != None && RxP.InvManager != none) {
				if(RxWeap.AttachedWeaponAbility == none)
					RxAbility = Rx_InventoryManager(RxP.InvManager).GetIndexedAbility(0);
				else
					RxAbility = Rx_InventoryManager(RxP.InvManager).GetIndexedAbility(RxWeap.AttachedWeaponAbility.AssignedSlot);
			}
			
			RxV = none;
			RxVWeap = none;
		} else if (Rx_Vehicle(TempPawn) != none) {
			RxV = Rx_Vehicle(TempPawn);
			if (RxV.Weapon != none) {
				RxVWeap = Rx_Vehicle_Weapon(RxV.Weapon);
			} else {
				for (i = 0; i < RxV.Seats.Length; i++) {
					if (RxV.Seats[i].Gun == none) {
						continue;
					}
					RxVWeap = Rx_Vehicle_Weapon(RxV.Seats[i].Gun);
					break;
				}
			}
			RxP = none;
			RxWeap = none;
		} else if (Rx_VehicleSeatPawn(TempPawn) != None) {
			RxV = Rx_Vehicle(Rx_VehicleSeatPawn(TempPawn).MyVehicle);
			
			if (Rx_VehicleSeatPawn(TempPawn).MyVehicleWeapon != none) {
				RxVWeap = Rx_Vehicle_Weapon(Rx_VehicleSeatPawn(TempPawn).MyVehicleWeapon);
			} else if (RxV.Weapon != none) {
				RxVWeap = Rx_Vehicle_Weapon(RxV.Weapon);
			} else {
				for (i = 0; i < RxV.Seats.Length; i++) {
					if (RxV.Seats[i].Gun == none) {
						lastWeaponHeld = none; 
						continue;
					}
					RxVWeap = Rx_Vehicle_Weapon(RxV.Seats[i].Gun);
					break;
				}
			}
			RxP = none;
			RxWeap = none;
		}
	
				
// 		//UTWeaponPawn
// 	if(Rx_Pawn(RxPC.Pawn) != None) {
// 		RxP = Rx_Pawn(RxPC.Pawn);
// 	} else if(Rx_VehicleSeatPawn(RxPC.Pawn) != None) {
// 		RxV = Rx_Vehicle(Rx_VehicleSeatPawn(RxPC.Pawn).MyVehicle);
// 	} 
// // 	else if (UTWeaponPawn(RxPC.Pawn) != None) { //TODO: for Chinook who happens not have 
// // 		RxV = Rx_Vehicle(UTWeaponPawn(RxPC.Pawn).MyVehicle);
// // 	}
// 	else {
// 		RxV = Rx_Vehicle(RxPC.Pawn);
// 	}
	
	if((bUseTickCycle && Tick_Cycler == 1) || !bUseTickCycle)
	{
		SetLivingHUDVisible(true);
		if(RxP != none && RxP.Health > 0) {
			if (VehicleDeathMsgTime >= 0)
			{
				if (RenxHud.WorldInfo.TimeSeconds < VehicleDeathMsgTime)
				{
					FadeScreenMC.SetVisible(true);
					SubtitlesText.SetVisible(true);
				}
				else
				{
					VehicleDeathMsgTime = -1;
					SubtitlesText.SetText("");
					SubtitlesText.SetVisible(false);
					FadeScreenMC.SetVisible(false);
				}
			}
			else
			{
				SubtitlesText.SetText("");
				SubtitlesText.SetVisible(false);
				FadeScreenMC.SetVisible(false);
			}
			if(isInVehicle) //they were in a vehicle
			{

				HealthBlock.GotoAndStopI(2);
				WeaponBlock.GotoAndStopI(2);
				VArmorN.SetVisible(false);
				VArmorMaxN.SetVisible(false);
				isInVehicle = false;
			}
			
			UpdateHealth(RxP.Health , RxP.HealthMax);
			UpdateArmor(RxP.Armor , RxP.ArmorMax);
			//UpdateAbility(); 
			//updates that only happen on foot
			UpdateStamina(RxP.Stamina);
			//UpdateItems();
			if(RxWeap != None) 
			{
				UpdateWeapon(RxWeap);
			}
			
			if (RxAbility != none && RxAbility.bShouldBeVisible()) {
				ShowAbility(true); //Make sure it's visible 
				UpdateAbility(RxAbility);
				}
				else
					ShowAbility(false); 

			//hide respawn hud (nBab)
			hideRespawnHud();
		} else if(RxV != none) {
			if (VehicleDeathMsgTime >= 0)
			{ 
				if (RenxHud.WorldInfo.TimeSeconds < VehicleDeathMsgTime)
				{
					FadeScreenMC.SetVisible(true);
					SubtitlesText.SetVisible(true);
				}
				else
				{
					VehicleDeathMsgTime = -1;
					SubtitlesText.SetText("");
					SubtitlesText.SetVisible(false);
					FadeScreenMC.SetVisible(false);
				}
			}
			else
			{
				SubtitlesText.SetText("");
				SubtitlesText.SetVisible(false);
				FadeScreenMC.SetVisible(false);
			}
			if(!isInVehicle) //they were on foot
			{
				HealthBlock.GotoAndStopI(3);
				WeaponBlock.GotoAndStopI(3);
				UpdateHUDVars();
				VArmorN.SetVisible(true);
				VArmorMaxN.SetVisible(true);
				VArmorMaxN.SetText(RxV.HealthMax);

				//show last pawn health when in vehicle (nBab)
				VHealthN.SetText(LastHealthpc);
				ArmorN.SetText(LastArmorpc);
				
				isInVehicle = true;
			}
				
	// 		if(Rx_VehicleSeatPawn(RxPC.Pawn) != None)
	// 			RxP = Rx_Pawn(Rx_VehicleSeatPawn(RxPC.Pawn).Driver);
	// 		else
	// 			RxP = Rx_Pawn(RxV.Driver);

			//updates that only happen in vehicle
			//`log(vehiclePawn.Health);
			UpdateVehicleArmor(RxV.Health, RxV.HealthMax);
			UpdateVehicleWeapon(RxVWeap);
			if ((Rx_Vehicle_Chinook_GDI(RxV) != none || Rx_Vehicle_Chinook_Nod(RxV) != none) && RxV.Seats[RxV.GetSeatIndexForController(RxPC)].Gun == none) {
				AmmoInClipN.SetText("0");
				AmmoBar.GotoAndStopI(0);
				lastWeaponHeld = none; //And somehow this not being here screwed up the entire HUD... Eh, whatever. -Yosh
			}
			
			
	// 		if (Rx_VehicleSeatPawn(RxPC.Pawn) != none) {
	// 			//if the passenger has its own weapon system (like chinook), then use it
	// 			//else just use the passenger's vehicle default weapon system
	// 			if (Rx_Vehicle_Weapon(Rx_VehicleSeatPawn(RxPC.Pawn).MyVehicleWeapon) != none) {
	// 				UpdateVehicleWeapon(Rx_Vehicle_Weapon(Rx_VehicleSeatPawn(RxPC.Pawn).MyVehicleWeapon));
	// 			} else {
	// 				UpdateVehicleWeapon(Rx_Vehicle_Weapon(Rx_VehicleSeatPawn(RxPC.Pawn).MyVehicle.Weapon));
	// 			}
	// 		} else if (Rx_Vehicle_Chinook_GDI(RxPC.Pawn) != none || Rx_Vehicle_Chinook_Nod(RxPC.Pawn) != none) {
	// 			//VehicleIcon
	// 			VehicleMC.GotoAndStopI(6);
	// 			VBackdrop.GotoAndStopI(1);
	// 			//AmmoBar.SetVisible(false);
	// 			//InfinitAmmo.SetVisible(true);
	// 			AmmoInClipN.SetText("0");
	// 			WeaponName.SetText(RxV.GetHumanReadableName());
	// 			//WeaponBlock.GetObject("AltWeaponBlock").SetVisible(false);
	// 			//UpdateHUDVars();
	// 			lastWeaponHeld = none;
	// 
	// 		} else {
	// 			UpdateVehicleWeapon(Rx_Vehicle_Weapon(RxV.Weapon));
	// 		}
			//hide respawn hud (nBab)
			hideRespawnHud();
		} else {
			SetLivingHUDVisible(false);
			FadeScreenMC.SetVisible(true);
			SubtitlesText.SetVisible(true);
			UpdateHealth(0 , 100);
			UpdateArmor(0 , 100);
			VehicleDeathMsgTime = -1;
			//show respawn hud (nBab)
			showRespawnhud(GetPC().GetTeamNum(),lastFreeClass);
		}
	}

// 	UpdateHealth((RxP == none || RxP.Health <= 0) ? 0 : RxP.Health, RxP.HealthMax);
// 	UpdateArmor((RxP == none || RxP.Armor <= 0) ? 0 : RxP.Health, RxP.ArmorMax);
	if((bUseTickCycle && Tick_Cycler == 2) || !bUseTickCycle)
	{
		if (Minimap != none)
		{
			RxGRI = Rx_GRI(RxPC.WorldInfo.GRI);

			if(RxGRI != None && !RxGRI.bMatchIsOver) {
				Minimap.Update();	
				
			}
		}

		if (Marker != none) {
			RxGRI = Rx_GRI(RxPC.WorldInfo.GRI);

			if(RxGRI != None && !RxGRI.bMatchIsOver) {
				Marker.Update();	
			}
		}
		if (OverviewMapMovie != none && OverviewMapMovie.bMovieIsOpen) {
			OverviewMapMovie.Update();
		}
	}
	if (RxPC.WorldInfo != none && RxPC.WorldInfo.GRI !=none)
	{
		if (RxPC.WorldInfo.GRI.TimeLimit > 0)
			UpdateMatchTimer(RxPC.WorldInfo.GRI.RemainingTime);
		else
			UpdateMatchTimer(RxPC.WorldInfo.GRI.ElapsedTime);

	}

	if (Rx_PRI(RxPC.PlayerReplicationInfo) != none)
	{
		if(!RxPC.IsSpectating())
		{
			UpdateCredits(Rx_PRI(RxPC.PlayerReplicationInfo).GetCredits());
			if(RxPC.PlayerReplicationInfo.Team != None) 
			{
				UpdateVehicleCount(Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).GetVehicleCount(),Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).VehicleLimit);
				UpdateMineCount(Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).MineCount,Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).mineLimit);
			}
		}
		else if(Pawn(RxPC.ViewTarget) != None) 
		{
			UpdateCredits(Rx_PRI(Pawn(RxPC.ViewTarget).PlayerReplicationInfo).GetCredits());
			if(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team != None) 
			{
				UpdateVehicleCount(Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).GetVehicleCount(),Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).VehicleLimit);
				UpdateMineCount(Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).MineCount,Rx_TeamInfo(Pawn(RxPC.ViewTarget).PlayerReplicationInfo.Team).mineLimit);
			}	
		}
	}

	if (Minimap != none)
	{
		RxGRI = Rx_GRI(RxPC.WorldInfo.GRI);

		if(RxGRI != None && !RxGRI.bMatchIsOver) {
			Minimap.UpdateMap();	
				
		}
	}
	
	//Bug fix for 16:10 resolution: The below code wasn't run at the start of the match because
	//there was no TempPawn thus the hud was not resized properly.
	//fixed it by calling "ResizedScreenCheck()" from rx_controller during the start of the match. (nBab)

	/** Code that was found to be expensive and doesent need to be updated every Tick was moved here */
	if(TempPawn != None && TempPawn.WorldInfo.TimeSeconds - LastTipsUpdateTime > 0.15)
	{
		ResizedScreenCheck();
		UpdateBuildings();
		UpdateTips();
		LastTipsUpdateTime = TempPawn.WorldInfo.TimeSeconds;
		//UpdateScoreboard();
	} else if(GameplayTipsText.GetString("htmlText") != "")
	{
		FadeScreenMC.SetVisible(true);
		GameplayTipsText.SetVisible(true);
	}	
	
	//Expirimental VP Stuff 
	if(Subtitle_Messages.Length > 0 && RxPC != none) 
		{
			for(i=0;i<Min(Subtitle_Messages.Length,6);i++)
			{
			if(i>0) FullVPString = FullVPString$"<br>"$Subtitle_Messages[i];
			else
			FullVPString = Subtitle_Messages[0]; 
			}
				SubtitlesText.SetString("htmlText", FullVPString);
				SubtitlesText.SetVisible(true);
				FadeScreenMC.SetVisible(true);
		}
		
		if(Subtitle_Messages.Length > 0) 
		{
			VPMsg_Cycler-=0.5 ; 
			
			if(VPMsg_Cycler <= 0.0) 
			{
				Subtitle_Messages.Remove(0,1); 
				VPMsg_Cycler=default.VPMsg_Cycler;
			}
		}
	//End Expirement 

	//set up tech building icons (nBab)
	if (SetupTechIcons)
	{
		setupTechBuildingIcons();
		SetupTechIcons = false;
	}
	
	if((bUseTickCycle && Tick_Cycler == 2) || !bUseTickCycle ) //Things that don't need to be updated that regularly
	{
	//update tech building icons (nBab)
	updateTechBuildingIcons();

	//update veterancy (nBab)
	updateVeterancy();
	}
	//update respawn ui
	if (GetPC().GetTeamNum() != lastTeam)
	{
		updateRespawnUI(GetPC().GetTeamNum());
		lastTeam = GetPC().GetTeamNum();
	}

	// For the commander points and max points on the bottom part of the hud. EX: "756/3000'
	if(RxPC.PlayerReplicationInfo.Team != None)
		CommPoints.SetText(int(Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).GetCommandPoints())$"/"$int(Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).GetMaxCommandPoints()));

	if(SideMenu.GetBool("visible"))
		DeathLogMC.SetVisible(false);
	else
		DeathLogMC.SetVisible(true);
}

function UpdateTips()
{
	local Rx_Controller RxPC;
	local Rx_ObjectTooltipInterface OT;
	local string bindKey;
	local string jumpKey;
	local string tooltip;
	local Actor act;
	local UTVehicle veh;

	RxPC = Rx_Controller(GetPC());
	
	if(RxPC == None)
	{
		GameplayTipsText.SetString("htmlText", "");
		return;
	}
	
	bindKey = Caps(UDKPlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand("GBA_Use"));
	jumpKey = Caps(UDKPlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand("GBA_Jump"));
	
	if (RxPC != none) 
	{
		
		if (RxPC.bDisplayingAirdropReadyMsg)
		{
			FadeScreenMC.SetVisible(true);
			GameplayTipsText.SetVisible(true);
			GameplayTipsText.SetString("htmlText", "Vehicle Airdrop Available");
			return;
		}
	}	
	
	if (Rx_Pawn(RxPC.Pawn) != none) 
	{
		
		if (Rx_Pawn(RxPC.Pawn).CanParachute() && RenxHud.ShowBasicTips)
		{
			FadeScreenMC.SetVisible(true);
			GameplayTipsText.SetVisible(true);
			GameplayTipsText.SetString("htmlText", "Press <font color='#ff0000' size='20'>[ " $ jumpKey $ " ]</font> to open parachute. " );
			return;
		}
		
		veh = RxPC.GetVehicleToDrive(false);
		if (veh != none) 
		{
			if (Rx_Vehicle_Harvester(veh) == none && Rx_Defence(veh) == none && (!veh.bDriving || (Rx_Vehicle_Air(veh) != None && Rx_Vehicle_Air(veh).AnySeatAvailable()) || Rx_VehRolloutController(veh.Controller) != None)) 
			{
				FadeScreenMC.SetVisible(true);
				GameplayTipsText.SetVisible(true);
				GameplayTipsText.SetString("htmlText", "Press <font color='#ff0000' size='20'>[ " $ bindKey $ " ]</font> to enter " $ Caps(veh.GetHumanReadableName()));
			}
		} 
		else 
		{
			if (GameplayTipsText.GetText() != "") 
			{
				GameplayTipsText.SetString("htmlText", "");
				GameplayTipsText.SetVisible(false);
				FadeScreenMC.SetVisible(false);
			}
		}

		if (RxPC.bIsInPurchaseTerminal == false)
		{
			OT = Rx_ObjectTooltipInterface(RenxHud.TargetingBox.TargetedActor);
			if (OT != none && OT.IsTouchingOnly() == false && (RenxHud.ShowBasicTips || OT.IsBasicOnly() == false))
			{
				tooltip = OT.GetTooltip(RxPC);
				if (tooltip != "")
				{
					FadeScreenMC.SetVisible(true);
					GameplayTipsText.SetVisible(true);
					GameplayTipsText.SetString("htmlText", tooltip);
					return;
				}
			}

			if (RxPC.bCanAccessPT)
			{
				foreach RxPC.Pawn.Touching(act)
				{
					OT = Rx_ObjectTooltipInterface(act);
					if (OT != none && (RenxHud.ShowBasicTips || OT.IsBasicOnly() == false))
					{
						tooltip = OT.GetTooltip(RxPC);
						if (tooltip != "")
						{
							FadeScreenMC.SetVisible(true);
							GameplayTipsText.SetVisible(true);
							GameplayTipsText.SetString("htmlText", tooltip);
							return;
						}
					}
				}
			}
		}
	}
	else if (GameplayTipsText.GetText() != "" && InStr(GameplayTipsText.GetText(), "Respawn available in") < 0)
	{					
		GameplayTipsText.SetString("htmlText", "");
		GameplayTipsText.SetVisible(false);
		FadeScreenMC.SetVisible(false); 
	}
}

exec function SetLivingHUDVisible(bool visible)
{
	//ObjectiveMC.SetVisible(visible);
	Minimap.SetVisible(visible);
	Marker.SetVisible(visible);
	HealthBlock.SetVisible(visible);
	BottomInfo.SetVisible(visible);
	WeaponBlock.SetVisible(visible);
}
exec function UpdateHUDVars() 
{
	// Grease:	When you have two frames, and an object in each frame with the same name,
	//			the variables HAVE to be updated, otherwise it will only change the object
	//			from frame 1, even if you're in frame 2.

	// Shahman: in UT (GFxMinimapHud), what epic did is to call the GFxMoviePlayer's gotoandstop function and reupdate.

	//Health
	HealthBar       = GetVariableObject("_root.HealthBlock.Health");
	HealthN         = GetVariableObject("_root.HealthBlock.HealthText.HealthN");
	HealthMaxN      = GetVariableObject("_root.HealthBlock.HealthText.HealthMaxN");
	HealthBlock     = GetVariableObject("_root.HealthBlock");
	HealthText      = GetVariableObject("_root.HealthBlock.HealthText");
	HealthIcon      = GetVariableObject("_root.HealthBlock.HealthIcon");

	//Armor
	ArmorBar        = GetVariableObject("_root.HealthBlock.Armor");
	ArmorN          = GetVariableObject("_root.HealthBlock.ArmorN");
	ArmorMaxN       = GetVariableObject("_root.HealthBlock.ArmorMaxN");
	VArmorMaxN      = GetVariableObject("_root.HealthBlock.VehicleMaxN");
	//nBab
	VHealthN         = GetVariableObject("_root.HealthBlock.HealthN");

	//Vehicle
	VArmorN         = GetVariableObject("_root.HealthBlock.VehicleN");
	VArmorBar       = GetVariableObject("_root.HealthBlock.HealthVehicle");
	VehicleMC       = GetVariableObject("_root.WeaponBlock.VehicleIcon");
	VAltWeaponBlock = GetVariableObject("_root.WeaponBlock.AltWeaponBlock");
	VBackdrop       = GetVariableObject("_root.WeaponBlock.VehicleBackdrop");

	//Stamina
	StaminaBar      = GetVariableObject("_root.HealthBlock.Stamina");

	//Weapon and Ammo
	WeaponBlock     = GetVariableObject("_root.WeaponBlock");
	WeaponName      = GetVariableObject("_root.WeaponBlock.WeaponName");
	AmmoInClipN     = GetVariableObject("_root.WeaponBlock.AmmoInClipN");
	AmmoReserveN    = GetVariableObject("_root.WeaponBlock.AmmoReserveN");
	InfinitAmmo     = GetVariableObject("_root.WeaponBlock.Infinity");
	AmmoBar         = GetVariableObject("_root.WeaponBlock.Ammo");
	WeaponMC        = GetVariableObject("_root.WeaponBlock.Weapon");
	WeaponPrevMC    = GetVariableObject("_root.WeaponBlock.WeaponPrev");
	WeaponNextMC    = GetVariableObject("_root.WeaponBlock.WeaponNext");

	AltWeaponName   = GetVariableObject("_root.WeaponBlock.AltWeaponBlock.AltWeaponName");
	AltAmmoInClipN  = GetVariableObject("_root.WeaponBlock.AltWeaponBlock.AltAmmoInClipN");
	AltInfinitAmmo  = GetVariableObject("_root.WeaponBlock.AltWeaponBlock.AltInfinity");
	AltAmmoBar      = GetVariableObject("_root.WeaponBlock.AltWeaponBlock.AltAmmo");

	//Abilities
	AbilityMC       = GetVariableObject("_root.WeaponBlock.Ability");
	AbilityMeterMC  = GetVariableObject("_root.WeaponBlock.Ability.Meter");
	AbilityIconMC   = GetVariableObject("_root.WeaponBlock.Ability.Icon");
	AbilityTextMC	= GetVariableObject("_root.WeaponBlock.AbilityText");

	//Items
	GrenadeMC       = GetVariableObject("_root.WeaponBlock.Grenade");
	GrenadeN        = GetVariableObject("_root.WeaponBlock.Grenade.Icon.TextField");
	TimedC4MC       = GetVariableObject("_root.WeaponBlock.TimedC4");
	RemoteC4MC      = GetVariableObject("_root.WeaponBlock.RemoteC4");
	ProxyC4MC       = GetVariableObject("_root.WeaponBlock.ProxyC4");
	BeaconMC        = GetVariableObject("_root.WeaponBlock.Beacon");

	//Gameplay Info
	BottomInfo      = GetVariableObject("_root.BottomInfo");
	Credits         = GetVariableObject("_root.BottomInfo.Stats.Credits");
	MatchTimer      = GetVariableObject("_root.BottomInfo.Stats.Time");
	VehicleCount    = GetVariableObject("_root.BottomInfo.Stats.Vehicles");
	MineCount    	= GetVariableObject("_root.BottomInfo.Stats.Mines");
	CommPoints      = GetVariableObject("_root.BottomInfo.Stats.CP");

	//Progress Bar
	
	LoadingMeterMC[0] = GetVariableObject("_root.loadingMeterGDI");
	LoadingText[0] = GetVariableObject("_root.loadingMeterGDI.loadingText");
	LoadingBarWidget[0] = GFxClikWidget(GetVariableObject("_root.loadingMeterGDI.bar", class'GFxClikWidget'));
	LoadingMeterMC[1] = GetVariableObject("_root.loadingMeterNod");
	LoadingText[1] = GetVariableObject("_root.loadingMeterNod.loadingText");
	LoadingBarWidget[1] = GFxClikWidget(GetVariableObject("_root.loadingMeterNod.bar", class'GFxClikWidget'));

	HideLoadingBar();
//---------------------------------------------------
	//Radar implementation
	if (Minimap == none)
	{
		Minimap = Rx_GFxMinimap(GetVariableObject("_root.minimap", class'Rx_GFxMinimap'));
		Minimap.init(self);
	}

	if (Marker == none) {
		Marker = Rx_GFxMarker(GetVariableObject("_root.MarkerContainer", class'Rx_GFxMarker'));
		Marker.init(self);
	}
	if(GrenadeN != None)
		GrenadeN.SetText("0X");
	if(GrenadeMC != None)
		GrenadeMC.GotoAndStopI(2);
	if(TimedC4MC != None)
		TimedC4MC.GotoAndStopI(2);
	if(RemoteC4MC != None)
		RemoteC4MC.GotoAndStopI(2);
	if(ProxyC4MC != None)
		ProxyC4MC.GotoAndStopI(2);
	HideBuildingIcons();
}

function HideLoadingBar()
{
	local byte i;
	i = GetPC().PlayerReplicationInfo.GetTeamNum();

	if (LoadingBarWidget[i] != none) {
		LoadingBarWidget[i].SetInt("value", 0);
	}
	if (LoadingText[i] != none) {
		LoadingText[i].SetText("");
	}
	if (LoadingMeterMC[i] != none) {
		LoadingMeterMC[i].SetVisible(false);
	}
}
function ShowLoadingBar(float value, optional string message)
{
	local byte i;
	i = GetPC().PlayerReplicationInfo.GetTeamNum();

	if (LoadingMeterMC[i] != none && !LoadingMeterMC[i].GetBool("visible")) {
		LoadingMeterMC[i].SetVisible(true);
	}

	//testBar maximum is 100 so it is (0-100%). our value is 0.0-1.0
	if (LoadingBarWidget[i] != none) {
		LoadingBarWidget[i].SetInt("value", int(value * 100.0f));
	}

	if (message != "" && LoadingText[i] != none && LoadingText[i].GetText() != Caps(message)) {
		LoadingText[i].SetText(Caps(message));
	}
}

/**
 * Initalizes a new MessageRow and adds it to the list
 * of available log MessageRow MovieClips for reuse.
 */
function GFxObject InitMessageRow(EMessageType MsgType, out int NumMessages)
{
	local MessageRow mrow;

	mrow.Y = 0;
	mrow.MC = CreateMessageRow(MsgType, NumMessages);

	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetBool("html", true);
	mrow.TF.SetString("htmlText", "");

	switch (MsgType) 
	{
		case EMT_EVA:
			FreeEVAMessages.AddItem(mrow);
			break;
		case EMT_Chat:
			FreeChatMessages.AddItem(mrow);
			break;
		case EMT_Death:
			FreeDeathMessages.AddItem(mrow);
			break;
	}
	return mrow.MC;
}

/**
 * Creates a new LogMessage MovieClip for use in the 
 * log.
 */
function GFxObject CreateMessageRow(EMessageType MsgType, out int NumMessages)
{
	switch (MsgType) 
	{
		case EMT_EVA:
			return EVALogMC.AttachMovie("logMessage", "EVAMessage"$NumMessages++);
		case EMT_Chat:
			return ChatLogMC.AttachMovie("logMessage", "ChatMessage"$NumMessages++);
		case EMT_Death:
			return DeathLogMC.AttachMovie("logMessage", "DeathMessage"$NumMessages++);
	}
}


function UpdateBuildingInfo(int Index) 
{
	//Buildings
	UpdateBuildingInfo_GDI(Index);
	UpdateBuildingInfo_Nod(Index);
}
function UpdateBuildingInfo_GDI(int Index) 
{
	BuildingInfo_GDI[Index].Icon = GetVariableObject("_root.BottomInfo.BuildingInfo.GDI.Icon"$Index);
	BuildingInfo_GDI[Index].Stats = GetVariableObject("_root.BottomInfo.BuildingInfo.GDI.Icon"$Index$".Stats");
	BuildingInfo_GDI[Index].Icon.SetVisible(false);
}

function UpdateBuildingInfo_Nod(int Index) 
{
	BuildingInfo_Nod[Index].Icon = GetVariableObject("_root.BottomInfo.BuildingInfo.Nod.Icon"$Index);
	BuildingInfo_Nod[Index].Stats = GetVariableObject("_root.BottomInfo.BuildingInfo.Nod.Icon"$Index$".Stats");
	BuildingInfo_Nod[Index].Icon.SetVisible(false);
}

function HideBuildingIcons()
{
	UpdateBuildingInfo(0);
	UpdateBuildingInfo(1);
	UpdateBuildingInfo(2);
	UpdateBuildingInfo(3);
	UpdateBuildingInfo(4);
}

function UpdateHealth(int currentHealth, int maxHealth)
{
	
	local ASColorTransform ColorTransform;
	//Update health if it is required
	//if (LastHealthpc != currentHealth || HealthN.GetText() != string(currentHealth)) {
		
		//update current health, text, and bar
		LastHealthpc = currentHealth;
		HealthBar.GotoAndStopI(float(currentHealth) / float(maxHealth) * 100 + 1);

		if (currentHealth < 25) {
			HealthIcon.GotoAndStopI(3);
			ColorTransform.multiply.R = 1.0;
			ColorTransform.multiply.G = 0.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.0;
			ColorTransform.add.G = 0.0;
			ColorTransform.add.B = 0.0;
		} else if (currentHealth < 62) {
			HealthIcon.GotoAndStopI(2);
			ColorTransform.multiply.R = 0.0;
			ColorTransform.multiply.G = 0.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.8;
			ColorTransform.add.G = 0.2;
			ColorTransform.add.B = 0.0;
		} else {
			HealthIcon.GotoAndStopI(1);
			ColorTransform.multiply.R = 0.0;
			ColorTransform.multiply.G = 1.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.0;
			ColorTransform.add.G = 0.0;
			ColorTransform.add.B = 0.0;
		}
		if(HealthText != None)
			HealthText.SetColorTransform(ColorTransform);

		if(HealthN != None)
			HealthN.SetText(currentHealth);
	//}
	//if (HealthMaxN != None && HealthMaxN.GetText() != string(maxHealth)){
	//if (HealthMaxN != None)
	//{
	//	HealthMaxN.SetText(maxHealth);
	//}

	//show max health as 100+X if it's higher than 100 (only applicable in Fort atm) (nBab)
	if (HealthMaxN != None)
	{
		if (maxHealth>100)
			HealthMaxN.SetText("100+"$(maxHealth-100));
		else
			HealthMaxN.SetText(maxHealth);
	}
}

function UpdateVehicleArmor(int currentArmor, int maxArmor)
{
	//update armor if it is required
	//if (LastVArmorpc != currentArmor || VArmorN.GetText() != string(currentArmor)) {
		
		//update current health, text, and bar
		LastVArmorpc = currentArmor;
		VArmorBar.GotoAndStopI(float(currentArmor) / float(maxArmor) * 100);
		VArmorN.SetText(currentArmor);
		
		if (VArmorMaxN != None)
		{
		VArmorMaxN.SetText(maxArmor);
		}
	//}
}

function UpdateArmor(int currentArmor, int maxArmor){
	//update armor if it is required
	//if (LastArmorpc != currentArmor || ArmorN.GetText() != string(currentArmor)) {
		
		//update current health, text, and bar
		LastArmorpc = currentArmor;
		ArmorBar.GotoAndStopI(float(currentArmor) / float(maxArmor) * 100);
		ArmorN.SetText(currentArmor);
	//}

	//if (ArmorMaxN != None && ArmorMaxN.GetText() != string(maxArmor)){
	if (ArmorMaxN != None)
	{
		ArmorMaxN.SetText(maxArmor);
	}
}

function UpdateStamina(int currentStamina)
{
	//update stamina if it is required
	//if (LastStaminapc != currentStamina) {
	
		//update current health, text, and bar
		LastStaminapc = currentStamina;
		if(StaminaBar != None)
			StaminaBar.GotoAndStopI(int(currentStamina / 100.00 * 42));
	//}
}

function UpdateAbility (Rx_WeaponAbility ability)
{
	if (AbilityIconMC != none) 
	{
		AbilityIconMC.GotoAndStopI(ability.GetFlashIconInt());
		
	}

	if (AbilityMeterMC != none) {
		//GetPC().ClientMessage("RechargeRate: " $ability.RechargeRate $" | RechargeDelay: " $ability.RechargeDelay );
		if (ability.bSingleCharge) {
			//single charge
			AbilityMeterMC.GotoAndStopI(ability.GetRechargeTiming() * 42);
			
			if(!ability.bCanBeSelected()) AbilityIconMC.SetFloat("alpha", 0.5);
				else
				AbilityIconMC.SetFloat("alpha", 1);
				
		} else {
			//not a single charge
			AbilityMeterMC.GotoAndStopI(ability.GetRechargeTiming() * 42);
		}
		AbilityTextMC.SetText("[" $ string( AbilityKey ) $ "]"); 
		
	}
}

function ShowAbility(bool Show)
{
	if(AbilityIconMC != None)
		AbilityIconMC.SetVisible(Show);
	if(AbilityMC != None)
		AbilityMC.SetVisible(Show);
	if(AbilityMeterMC != None)
		AbilityMeterMC.SetVisible(Show); 
	if(AbilityMeterMC != None)
		AbilityTextMC.SetVisible(Show); 
}


function UpdateWeapon(UTWeapon weapon)
{
	local Rx_Controller RxPC;
	local Rx_Weapon_Reloadable Weapon_R; 
	local Rx_WeaponAbility WeaponAbility;
	//we dont want to set visible every tick, so we have this extra IF
	if(weapon != lastWeaponHeld) {
		AmmoInClipValue = -1;
		AmmoInReserveValue = -1;

		UpdateHUDVars();
		
		//This is for mods/mutators. This allows creators of new weapons to set names without having to do a custom version of this function
		if(Rx_Weapon(weapon).CustomWeaponName != "")
			WeaponName.SetText(Rx_Weapon(weapon).CustomWeaponName);
		else
			WeaponName.SetText(weapon.ItemName);
		
		if(Rx_Weapon(weapon).HasInfiniteAmmo()) {
			AmmoReserveN.SetVisible(false);
			InfinitAmmo.SetVisible(true);
		} else {
			AmmoReserveN.SetVisible(true);
			InfinitAmmo.SetVisible(false);
		}

		//now we update the images of the weapons held
		RxPC = Rx_Controller(GetPC());
		prevWeapon = RxPC.GetPrevWeapon(weapon);
		nextWeapon = RxPC.GetNextWeapon(weapon);
		
		if(lastWeaponHeld == prevweapon) {
			ChangedWeapon("switchedToNextWeapon");
		} else {
			ChangedWeapon("switchedToPrevWeapon");
		}	

		lastWeaponHeld = weapon;

		//CHANGE WEAPON HERE
		LoadTexture(Rx_Weapon(weapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(weapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponMC);

		if(prevWeapon != none && Rx_Weapon(prevWeapon) != None) {
			WeaponPrevMC.SetVisible(true);
			LoadTexture(Rx_Weapon(prevWeapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(prevWeapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponPrevMC);
		} else {
			WeaponPrevMC.SetVisible(false);
		}
			

		if(nextWeapon != none && Rx_Weapon(prevWeapon) != None) {
			WeaponNextMC.SetVisible(true);
			LoadTexture(Rx_Weapon(nextWeapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(nextWeapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponNextMC);
		} else {
			WeaponNextMC.SetVisible(false);
		}
	}

	if(Rx_Weapon_Reloadable(weapon) != None) {
		Weapon_R = Rx_Weapon_Reloadable(weapon);
		//Update ammo counts
		if( AmmoInClipValue != Weapon_R.GetUseableAmmo()) {
			AmmoInClipValue = Weapon_R.GetUseableAmmo();
			AmmoInClipN.SetText(AmmoInClipValue);
			AmmoBar.GotoAndStopI(float(AmmoInClipValue) / float(Weapon_R.GetMaxAmmoInClip()) * 100);
		}
		//Update reserve ammo counts
		if( AmmoInReserveValue != Weapon_R.GetReserveAmmo()) {
			AmmoInReserveValue = Weapon_R.GetReserveAmmo();
			AmmoReserveN.SetText(AmmoInReserveValue);
		}
		//realod weapon animation
		if(Weapon_R != None && Weapon_R.CurrentlyReloading && !Weapon_R.PerBulletReload) {	
			AnimateReload(weapon.WorldInfo.TimeSeconds - Weapon_R.reloadBeginTime, Weapon_R.currentReloadTime, AmmoBar);		
		}
	}

	if(Rx_WeaponAbility(weapon) != None) {
		WeaponAbility = Rx_WeaponAbility(weapon);
		//Update ammo counts
		if( AmmoInClipValue != WeaponAbility.CurrentCharges) {
			AmmoInClipValue = WeaponAbility.CurrentCharges;
			AmmoInClipN.SetText(AmmoInClipValue);
			AmmoBar.GotoAndStopI(float(AmmoInClipValue) / WeaponAbility.MaxCharges * 100.0);
		}
		//Update reserve ammo counts
		if( AmmoInReserveValue != WeaponAbility.MaxCharges) {
			AmmoInReserveValue = WeaponAbility.MaxCharges;
			AmmoReserveN.SetText(AmmoInReserveValue);
		}
	}
	if(Rx_WeaponAbility(weapon) != None) {
		WeaponAbility = Rx_WeaponAbility(weapon);
		//Update ammo counts
		if( AmmoInClipValue != WeaponAbility.CurrentCharges) {
			AmmoInClipValue = WeaponAbility.CurrentCharges;
			AmmoInClipN.SetText(AmmoInClipValue);
			AmmoBar.GotoAndStopI(float(AmmoInClipValue) / WeaponAbility.MaxCharges * 100.0);
		}
		//Update reserve ammo counts
		if( AmmoInReserveValue != WeaponAbility.MaxCharges) {
			AmmoInReserveValue = WeaponAbility.MaxCharges;
			AmmoReserveN.SetText(AmmoInReserveValue);
		}
	}}

function LoadTexture(string pathName, GFxObject widget) 
{
	widget.ActionScriptVoid("loadTexture");
}

function UpdateItems()
{
	local Rx_Controller PC;
	local array<UTWeapon> WeaponList;
	local int i;

	PC = Rx_Controller(GetPC());

	if(Rx_InventoryManager(PC.Pawn.InvManager) != None) {
		Rx_InventoryManager(PC.Pawn.InvManager).GetWeaponList(WeaponList);
		for (i = 0; i < WeaponList.Length; i++) {
			if(WeaponList[i] != None) {
				if(Rx_Weapon_Grenade(WeaponList[i]) != None) {
					if(Rx_Weapon_Grenade(WeaponList[i]).AmmoCount > 0) {
						GrenadeMC.GotoAndStopI(1);
						GrenadeN.SetText(Rx_Weapon_Grenade(WeaponList[i]).AmmoCount$"X");
					} else {
						GrenadeMC.GotoAndStopI(2);
					}
				} else if(Rx_Weapon_TimedC4(WeaponList[i]) != None) {
					if(Rx_Weapon_TimedC4(WeaponList[i]).AmmoCount > 0 && TimedC4MC != None) {
						TimedC4MC.GotoAndStopI(1);
					} else if(TimedC4MC != None) {
						TimedC4MC.GotoAndStopI(2);
					}
				} else if(Rx_Weapon_RemoteC4(WeaponList[i]) != None) {
					if(Rx_Weapon_RemoteC4(WeaponList[i]).AmmoCount > 0 && RemoteC4MC != None) {
						RemoteC4MC.GotoAndStopI(1);
					} else if(RemoteC4MC != None) {
						RemoteC4MC.GotoAndStopI(2);
					}
				} else if(Rx_Weapon_ProxyC4(WeaponList[i]) != None) {
					if(Rx_Weapon_ProxyC4(WeaponList[i]).AmmoCount > 0 && ProxyC4MC != None) {
						ProxyC4MC.GotoAndStopI(1);
					} else if(ProxyC4MC != None) {
						ProxyC4MC.GotoAndStopI(2);
					}
				}
			}
		}
	}
}

function UpdateVehicleWeapon(Rx_Vehicle_Weapon weapon)
{
	if(weapon == None) {
		VehicleMC.SetVisible(false);
		//`log ("<GFxHUD Log> GetPC().Pawn? " $ GetPC().Pawn);
		return;
	}
	//UpdateHUDVars();

	if(weapon != lastWeaponHeld) { //this is a new weapon
		VehicleMC.SetVisible(true);
		
		//VehicleMC.GotoAndStopI(weapon.InventoryGroup);
		LoadTexture(Rx_Vehicle(weapon.MyVehicle).VehicleIconTexture != none ? "img://" $ PathName(Rx_Vehicle(weapon.MyVehicle).VehicleIconTexture) : PathName(Texture2D'RenxHud.T_VehicleIcon_MissingCameo'), VehicleMC);
		

		if(Rx_Vehicle_MultiWeapon(weapon) != none) {
			WeaponBlock.GotoAndStopI(4);
			VBackdrop.GotoAndStopI(2);
			UpdateHUDVars(); // Update variables after we change frames otherwise VAltWeaponBlock will be none
			VAltWeaponBlock.SetVisible(true);
			AltWeaponName.SetVisible(true);
			if(AltInfinitAmmo != None) {
				AltInfinitAmmo.SetVisible(true);
			}
			AltWeaponName.SetText(Rx_Vehicle_MultiWeapon(weapon).AltItemName);
		} else {
			if(AmmoReserveN != None) {
				AmmoReserveN.SetVisible(true);
			}
			if(AltInfinitAmmo != None) {
				AltInfinitAmmo.SetVisible(false);
			}
			if(VAltWeaponBlock != None) {
				VAltWeaponBlock.SetVisible(false);
			}
			if(AltWeaponName != None) {
				AltWeaponName.SetVisible(false);
			}
		}
		
		// This block on bottom because when there is a multiweapon equipped,
		// it changes frames, and relocates the objects, after that its time to set vars.
		WeaponName.SetText(weapon.ItemName);
		if(AmmoReserveN != None) {
			AmmoReserveN.SetVisible(false);
		}
		if(InfinitAmmo != None) {
			InfinitAmmo.SetVisible(true);
		}

		lastWeaponHeld = weapon;
	}
	//Update ammo counts
	if( weapon != None) { //AmmoInClipValue != weapon.GetUseableAmmo()
		AmmoInClipValue = weapon.GetUseableAmmo();
		AmmoInClipN.SetText(AmmoInClipValue);
		AmmoBar.GotoAndStopI(float(AmmoInClipValue) / float(weapon.GetMaxAmmoInClip()) * 100);
	}
	if( Rx_Vehicle_MultiWeapon(weapon) != none ) { //&& AltAmmoInClipValue != Rx_Vehicle_MultiWeapon(weapon).GetAltUseableAmmo()
		AltAmmoInClipValue = Rx_Vehicle_MultiWeapon(weapon).GetAltUseableAmmo();
		AltAmmoInClipN.SetText(AltAmmoInClipValue);
		AltAmmoBar.GotoAndStopI(float(AltAmmoInClipValue) / float(Rx_Vehicle_MultiWeapon(weapon).GetMaxAltAmmoInClip()) * 100);
	}
	
	//animate reload
	if( Rx_Vehicle_MultiWeapon(weapon) != none) {
		if(Rx_Vehicle_MultiWeapon(weapon).PrimaryReloading) {
			AnimateReload(weapon.WorldInfo.TimeSeconds - Rx_Vehicle_MultiWeapon(weapon).primaryReloadBeginTime, Rx_Vehicle_MultiWeapon(weapon).currentPrimaryReloadTime, AmmoBar);
		}
		if(Rx_Vehicle_MultiWeapon(weapon).SecondaryReloading) {
			AnimateReload(weapon.WorldInfo.TimeSeconds - Rx_Vehicle_MultiWeapon(weapon).secondaryReloadBeginTime, Rx_Vehicle_MultiWeapon(weapon).currentSecondaryReloadTime, AltAmmoBar);
		}
	} else {
		if(Rx_Vehicle_Weapon_Reloadable(weapon) != None && Rx_Vehicle_Weapon_Reloadable(weapon).CurrentlyReloading) {	
			AnimateReload(weapon.WorldInfo.TimeSeconds - Rx_Vehicle_Weapon_Reloadable(weapon).reloadBeginTime, Rx_Vehicle_Weapon_Reloadable(weapon).currentReloadTime, AmmoBar);
		}
	}
}

function UpdateBuildings()
{
	local WorldInfo WI;
	local Rx_Building BuildingActor;
	local int GDIIndex;
	local int NodIndex;

	WI = GetPC().WorldInfo;
	GDIIndex = -1;
	NodIndex = -1;

	foreach WI.AllActors(class'Rx_Building', BuildingActor)
	{
		if(BuildingActor.TeamID == TEAM_GDI)
		{
			if( Rx_Building_GDI_Defense(BuildingActor) != None )
			{
				GDIIndex++;
				UpdateBuildingInfo_GDI(GDIIndex);
				BuildingInfo_GDI[GDIIndex].Icon.SetVisible(true);
				BuildingInfo_GDI[GDIIndex].Icon.GotoAndStopI(1);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(1);
			}
			else if( Rx_Building_GDI_VehicleFactory(BuildingActor) != None )
			{
				GDIIndex++;
				UpdateBuildingInfo_GDI(GDIIndex);
				BuildingInfo_GDI[GDIIndex].Icon.SetVisible(true);
				BuildingInfo_GDI[GDIIndex].Icon.GotoAndStopI(2);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(1);
			}
			else if(Rx_Building_GDI_InfantryFactory(BuildingActor) != None)
			{
				GDIIndex++;
				UpdateBuildingInfo_GDI(GDIIndex);
				BuildingInfo_GDI[GDIIndex].Icon.SetVisible(true);
				BuildingInfo_GDI[GDIIndex].Icon.GotoAndStopI(3);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(1);
			}
			else if( Rx_Building_GDI_MoneyFactory(BuildingActor) != None )
			{
				GDIIndex++;
				UpdateBuildingInfo_GDI(GDIIndex);
				BuildingInfo_GDI[GDIIndex].Icon.SetVisible(true);
				BuildingInfo_GDI[GDIIndex].Icon.GotoAndStopI(4);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(1);
			}
			else if( Rx_Building_GDI_PowerFactory(BuildingActor) != None )
			{
				GDIIndex++;
				UpdateBuildingInfo_GDI(GDIIndex);
				BuildingInfo_GDI[GDIIndex].Icon.SetVisible(true);
				BuildingInfo_GDI[GDIIndex].Icon.GotoAndStopI(5);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_GDI[GDIIndex].Stats.GotoAndStopI(1);
			}
		}
		else if(BuildingActor.TeamID == TEAM_NOD)
		{
			if( Rx_Building_Nod_Defense(BuildingActor) != None )
			{
				NodIndex++;
				UpdateBuildingInfo_Nod(NodIndex);
				BuildingInfo_Nod[NodIndex].Icon.SetVisible(true);
				BuildingInfo_Nod[NodIndex].Icon.GotoAndStopI(1);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(1);
			}
			else if( Rx_Building_Nod_VehicleFactory(BuildingActor) != None )
			{
				NodIndex++;			
				UpdateBuildingInfo_Nod(NodIndex);
				BuildingInfo_Nod[NodIndex].Icon.SetVisible(true);
				BuildingInfo_Nod[NodIndex].Icon.GotoAndStopI(2);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(1);
			}
			else if( Rx_Building_Nod_InfantryFactory(BuildingActor) != None )
			{
				NodIndex++;
				UpdateBuildingInfo_Nod(NodIndex);
				BuildingInfo_Nod[NodIndex].Icon.SetVisible(true);
				BuildingInfo_Nod[NodIndex].Icon.GotoAndStopI(3);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(1);
			}
			else if( Rx_Building_Nod_MoneyFactory(BuildingActor) != None )
			{
				NodIndex++;
				UpdateBuildingInfo_Nod(NodIndex);
				BuildingInfo_Nod[NodIndex].Icon.SetVisible(true);
				BuildingInfo_Nod[NodIndex].Icon.GotoAndStopI(4);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(1);
			}
			else if( Rx_Building_Nod_PowerFactory(BuildingActor) != None )
			{
				NodIndex++;
				UpdateBuildingInfo_Nod(NodIndex);
				BuildingInfo_Nod[NodIndex].Icon.SetVisible(true);
				BuildingInfo_Nod[NodIndex].Icon.GotoAndStopI(5);

				if( BuildingActor.IsDestroyed() )
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(3);
				/*If not using armour, just say if the health is really low. If using armour, go red when the building is taking true damage*/
				else 
					if( BuildingActor.GetMaxArmor() <= 0 && BuildingActor.GetHealth() <= (BuildingActor.GetMaxHealth()/4)) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); //No armour
				else
					if( BuildingActor.GetMaxArmor() > 0 && BuildingActor.GetArmor() <= 240) BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(2); // armour
				else
					BuildingInfo_Nod[NodIndex].Stats.GotoAndStopI(1);
			}
		}
	}
}

function UpdateCredits(int inCredits)
{
	Credits.SetText(inCredits);
}

function UpdateMatchTimer( int inTime )
{
	local string time;
	local int seconds;
	if( CurrentTime != inTime )
	{
		time = string(FFloor(float(inTime)/60.0f));
		time = time$":";
		seconds = inTime%60;
		if (seconds < 10 )
		{
			time = time$"0";
			if(seconds == 0 && GetPC() != None && Rx_Controller(GetPC()) != None && Rx_PRI(Rx_Controller(GetPC()).playerreplicationinfo) != None)
				Rx_PRI(Rx_Controller(GetPC()).playerreplicationinfo).UpdateScoreLastMinutes();
		}
		time = time$seconds;
		MatchTimer.SetText(time);
		CurrentTime = inTime;
	}
}

function UpdateVehicleCount( int numVehicles, int maxVehicles )
{
	if ( numVehicles != CurrentNumVehicles  || maxVehicles != CurrentMaxVehicles)
	{
		VehicleCount.SetText(numVehicles$"/" $ maxVehicles);
		CurrentNumVehicles = numVehicles;
		CurrentMaxVehicles = maxVehicles;
	}
}

function UpdateMineCount( int numMines, int maxMines )
{
	if ( numMines != CurrentNumMines || maxMines != CurrentMaxMines)
	{
		MineCount.SetText(numMines $"/" $ maxMines);
		CurrentNumMines = numMines;
		CurrentMaxMines = maxMines;
	}
}

function AnimateReload(float timeEllapsed, float reloadTime, GFxObject bar)
{
	bar.GotoAndStopI(timeEllapsed / reloadTime * 100);
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	local Vector Loc;
	local Rotator Rot;
	local float DirOfHit;
	local vector AxisX, AxisY, AxisZ;
	local vector ShotDirection;
	local bool bIsInFront;
	local vector2D	AngularDist;
	local class<Rx_DmgType> DmgType;

	DmgType = class<Rx_DmgType>(damageType);

	if(DmgType != none && !DmgType.Static.IsUnsourcedDamage())			//HANDEPSILON - Damage Type that has bUnsourcedDamage does not show HitLoc
	{
		if (GetPC().pawn != None)
		{
			// Figure out the directional based on the victims current view
			GetPC().GetPlayerViewPoint(Loc, Rot);
			GetAxes(Rot, AxisX, AxisY, AxisZ);
		
			ShotDirection = Normal(HitDir - GetPC().pawn.location);
			bIsInFront = GetAngularDistance( AngularDist, ShotDirection, AxisX, AxisY, AxisZ);
			GetAngularDegreesFromRadians(AngularDist);
			DirOfHit = AngularDist.X;

			if( bIsInFront )
			{
				DirOfHit = AngularDist.X;
				if (DirOfHit < 0)
				DirOfHit += 360;
			}
			else
				DirOfHit = 180 - AngularDist.X;
		}
		else
			DirOfHit = 180;

		HitLocMC[int(DirOfHit/45.0)].GotoAndPlay("on");
		//`log(int(DirOfHit/45.0));
	}
	
}

function ToggleScoreboard()
{
	if(++currentScoreboard >= 5)
		currentScoreboard = 1;

		SetupScoreboard();
	
	Scoreboard.GotoAndStopI(currentScoreboard);
}

function SetupScoreboard()
{
	local Rx_GRI gri;
	local PlayerReplicationInfo pri;
	local int i,j;
	gri = Rx_GRI(GetPC().WorldInfo.GRI);
	
	Scoreboard = GetVariableObject("_root.Scoreboard");
	SBTeamScore[0] = GetVariableObject("_root.Scoreboard.TeamInfo.Score_GDI");
	SBTeamScore[1] = GetVariableObject("_root.Scoreboard.TeamInfo.Score_Nod");
	if ( currentScoreboard == 3 || currentScoreboard == 4 )
	{
		SBTeamCredits[0] = GetVariableObject("_root.Scoreboard.TeamInfo.Credits_GDI");
		SBTeamCredits[1] = GetVariableObject("_root.Scoreboard.TeamInfo.Credits_Nod");
		SBTeamKills[0] = GetVariableObject("_root.Scoreboard.TeamInfo.Kills_GDI");
		SBTeamKills[1] = GetVariableObject("_root.Scoreboard.TeamInfo.Kills_Nod");
		SBTeamDeaths[0] = GetVariableObject("_root.Scoreboard.TeamInfo.Deaths_GDI");
		SBTeamDeaths[1] = GetVariableObject("_root.Scoreboard.TeamInfo.Deaths_Nod");
		SBTeamKDR[0] = GetVariableObject("_root.Scoreboard.TeamInfo.KD_GDI");
		SBTeamKDR[1] = GetVariableObject("_root.Scoreboard.TeamInfo.KD_Nod");
	}
	
	PlayerInfo.Length=0;

	if (currentScoreboard == 2 || currentScoreboard == 4 )
	{
		CurrentNumberPRIs = 0;
		foreach gri.PRIArray(pri)
		{
			if(Rx_Pri(pri) != None) {
				if(i++ >= NumPlayerStats) {
					break;	
				}
				CurrentNumberPRIs++;
				PlayerInfo.AddItem(GetPlayerInfo(i));
			}
		}		
		if(i < NumPlayerStats) {
			for(j=i+1;j<=NumPlayerStats;j++) {
				PlayerInfo.AddItem(GetPlayerInfo(j,true));	
			}
		}
	}
	else if (currentScoreboard == 1 || currentScoreboard == 3 )
	{
		PlayerInfo.AddItem(GetPlayerInfo(1));
	}
	
}

function SBPlayerEntry GetPlayerInfo( int EntryID, optional bool bDisable = false )
{
	local SBPlayerEntry entry;

	entry.EntryLine  = GetVariableObject("_root.Scoreboard.PlayerInfo"$EntryID);

	if(bDisable)
	{
		//entry.EntryLine.SetInt("_alpha",50);
		entry.EntryLine.SetVisible(false);
	}
	
	entry.PlayerName = GetVariableObject("_root.Scoreboard.PlayerInfo"$EntryID$".Name");
	entry.Score      = GetVariableObject("_root.Scoreboard.PlayerInfo"$EntryID$".Score");

	if ( currentScoreboard == 3 || currentScoreboard == 4 )
	{
		entry.Kills   = GetVariableObject("_root.Scoreboard.PlayerInfo"$EntryID$".Kills");
		entry.Deaths  = GetVariableObject("_root.Scoreboard.PlayerInfo"$EntryID$".Deaths");
		entry.KDRatio = GetVariableObject("_root.Scoreboard.PlayerInfo"$EntryID$".KD");
		entry.Credits = GetVariableObject("_root.Scoreboard.PlayerInfo"$EntryID$".Credits");
	}
	entry.bNew = true;
	return entry;
}

function UpdateScoreboard()
{
	UpdateScoreboardCommon();
	UpdateScoreboardElements();
}

function UpdateScoreboardCommon()
{
	local Rx_GRI GRI;
	local PlayerController PC;
	local PlayerReplicationInfo pri;
	local int TeamCredits[2];


	PC = GetPC();
	if (PC != none)
	{
		GRI = Rx_GRI(PC.WorldInfo.GRI);
	}

	if (GRI == none)
	{
		return; // if we don't have a GRI then we cant update the scores
	}

	SBTeamScore[0].SetText(Rx_TeamInfo(GRI.Teams[0]).GetDisplayRenScore());
	SBTeamScore[1].SetText(Rx_TeamInfo(GRI.Teams[1]).GetDisplayRenScore());

	if( currentScoreboard == 3 || currentScoreboard == 4 )
	{
		ForEach GRI.PRIArray(pri)
		{
			if(Rx_Pri(pri) == None) 
				continue;
			if (pri.GetTeamNum() == 0)
			{
				TeamCredits[0] += Rx_PRI(pri).GetCredits();
			}
			else
			{
				TeamCredits[1] += Rx_PRI(pri).GetCredits();
			}
		}
		SBTeamKills[0].SetText(Rx_TeamInfo(GRI.Teams[0]).GetKills());
		SBTeamKills[1].SetText(Rx_TeamInfo(GRI.Teams[1]).GetKills());
		SBTeamDeaths[0].SetText(Rx_TeamInfo(GRI.Teams[0]).GetDeaths());
		SBTeamDeaths[1].SetText(Rx_TeamInfo(GRI.Teams[1]).GetDeaths());
		SBTeamKDR[0].SetText(Rx_TeamInfo(GRI.Teams[0]).GetKDRatio());
		SBTeamKDR[1].SetText(Rx_TeamInfo(GRI.Teams[1]).GetKDRatio());
		SBTeamCredits[0].SetText(TeamCredits[0]);
		SBTeamCredits[1].SetText(TeamCredits[1]);
	}

}

function UpdateScoreboardElements()
{
	local Rx_GRI gri;
	local int i;
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;

	gri = Rx_GRI(GetPC().WorldInfo.GRI);

	if ( currentScoreboard == 1 || currentScoreboard == 3 )
	{
		if(PlayerInfo[0].bNew) {
			PlayerInfo[0].EntryLine.GotoAndStopI(GetPC().GetTeamNum()+2);
			PlayerInfo[0] = GetPlayerInfo(1);
			PlayerInfo[0].bNew = false;	
		}
		PlayerInfo[0].PlayerName.SetText(GetPC().GetHumanReadableName());
		PlayerInfo[0].Score.SetText(Rx_PRI(GetPC().PlayerReplicationInfo).GetRenScore());
		if ( currentScoreboard == 3 )
		{
			PlayerInfo[0].Credits.SetText(FFloor(Rx_PRI(GetPC().PlayerReplicationInfo).GetCredits()));
			PlayerInfo[0].Kills.SetText(Rx_PRI(GetPC().PlayerReplicationInfo).GetRenKills());
			PlayerInfo[0].Deaths.SetText(GetPC().PlayerReplicationInfo.Deaths);
			PlayerInfo[0].KDRatio.SetText(Rx_PRI(GetPC().PlayerReplicationInfo).GetKDRatio());
		}
	}
	else
	{
		foreach gri.PRIArray(pri)
		{
			if(Rx_Pri(pri) != None) {
				PRIArray.AddItem(pri);
			}
		}
		PRIArray.Sort(SortPriDelegate);
		if (CurrentNumberPRIs < PRIArray.Length)
		{
			for (i = CurrentNumberPRIs; i < CurrentNumberPRIs; i++ )
			{
				//PlayerInfo[i].EntryLine.SetInt("_alpha",100);
				PlayerInfo[i].EntryLine.SetVisible(true);
			}
			//CurrentNumberPRIs = PRIArray.Length;
		}
		else if (CurrentNumberPRIs > PRIArray.Length)
		{
			for (i = PRIArray.Length; i < CurrentNumberPRIs; i++ )
			{
				PlayerInfo[i].EntryLine.SetVisible(false);
			}
			CurrentNumberPRIs = PRIArray.Length;
		}
		for (i = 0; i < CurrentNumberPRIs; i++)
		{
			if(PlayerInfo[i].bNew) {
				PlayerInfo[i].EntryLine.GotoAndStopI(PRIArray[i].GetTeamNum()+2);
				PlayerInfo[i] = GetPlayerInfo(i+1);
				PlayerInfo[i].bNew = false;	
			}			
			PlayerInfo[i].PlayerName.SetText(PRIArray[i].GetHumanReadableName());
			PlayerInfo[i].Score.SetText(Rx_PRI(PRIArray[i]).GetRenScore());
			if ( currentScoreboard == 4 )
			{
				PlayerInfo[i].Credits.SetText(FFloor(Rx_PRI(PRIArray[i]).GetCredits()));
				PlayerInfo[i].Kills.SetText(Rx_PRI(PRIArray[i]).GetRenKills());
				PlayerInfo[i].Deaths.SetText(PRIArray[i].Deaths);
				PlayerInfo[i].KDRatio.SetText(Rx_PRI(PRIArray[i]).GetKDRatio());
			}
		}
	}
}

function int SortPriDelegate( coerce PlayerReplicationInfo pri1, coerce PlayerReplicationInfo pri2 )
{
	if (Rx_PRI(pri1) != none && Rx_PRI(pri2) != none)
	{
		if (Rx_PRI(pri1).GetRenScore() > Rx_PRI(pri2).GetRenScore())
		{
			return 1;
		} 
		else if (Rx_PRI(pri1).GetRenScore() == Rx_PRI(pri2).GetRenScore())
		{
			return 0;
		}
		else
		{
			return -1;
		}
	}
	return 0;
}

function DisableHUDItems()
{
	//Items we are disabling
	ObjectiveMC = GetVariableObject("_root.Objective");
	ObjectiveText = GetVariableObject("_root.Objective.TextField");
	TimerMC = GetVariableObject("_root.Objective.Timer");
	TimerText = GetVariableObject("_root.Objective.Timer.TextField");
	FadeScreenMC = GetVariableObject("_root.Cinema");
	SubtitlesText = GetVariableObject("_root.Cinema.Subtitles.Textfield");
	GameplayTipsText = GetVariableObject("_root.Cinema.Tips.Textfield");
	WeaponPickup = GetVariableObject("_root.WeaponPickup");

	if (GetPC().PlayerReplicationInfo.GetTeamNum() == TEAM_GDI) {
		LoadingMeterMC[1].SetVisible(false);
	} else if (GetPC().PlayerReplicationInfo.GetTeamNum() == TEAM_NOD) {
		LoadingMeterMC[0].SetVisible(false);
	}
	ObjectiveMC.SetVisible(false);
	ObjectiveText.SetVisible(false);
	TimerMC.SetVisible(false);
	TimerText.SetVisible(false);
	FadeScreenMC.SetVisible(false);
	SubtitlesText.SetVisible(false);
	GameplayTipsText.SetVisible(false);
	WeaponPickup.SetVisible(false);
	//hide respawn hud (nBab);
	hideRespawnHud();
}

function AddEVAMessage(coerce string sMessage) 
{
	local MessageRow mrow;
	local ASDisplayInfo DisplayInfo;
	local byte i;
	local string msg;

	if (Len(sMessage) == 0)
		return;

	if (FreeEvaMessages.Length > 0)
	{
		mrow = FreeEvaMessages[FreeEvaMessages.Length-1];
		FreeEvaMessages.Remove(FreeEvaMessages.Length-1,1);
	}
	else
	{
		mrow = EVAMessages[EVAMessages.Length-1];
		EVAMessages.Remove(EVAMessages.Length-1,1);
	}

	msg = "EVA: "$sMessage;
	mrow.MC.GetObject("message").GotoAndStopI(4);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("text", msg);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y  = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	mrow.MC.GotoAndPlay("show");
	for (i = 0; i < EVAMessages.Length; i++)
	{
		EVAMessages[i].Y += MessageHeight;
		DisplayInfo.Y = EVAMessages[i].Y;
		EVAMessages[i].MC.SetDisplayInfo(DisplayInfo);
	}
	EVAMessages.InsertItem(0,mrow);
}

/**
* This function is used to display options on the left side menu (vote options, taunts, commander menu, radio commands)
* Each MenuOption consists of 3 parts. The position, the message and the key. Pos 0 is always the header. Having a key on pos 0 will do nothing. Positions 1-13 are the only valid positions for lines.
* Examples on using this function are given in Rx_HUD DrawTaunts(), CreateMenuArray(), CreateVoteMenuArray() and CreateCommanderMenuArray()
* For examples on how to format and ideal execution, look at where the above Create...Array() functions are called.
**/
function DisplayOptions(array<MenuOption> Options)
{
	local Rx_Controller RxPC;
    local int i, ii;
    local GFxObject key, line;

	RxPC = Rx_Controller(GetPC());

	if(RxPC == None) {
		return;
	}

	// Clean the menu of it's current messages.
	ForEach Keys(key) {
		key.SetText("");
	}

	ForEach Lines(line) {
		line.SetText("");
	}

	header.SetText("");

	// Find the header, we do this assuming that not all function calls will have the header as the first item in the array.
	ii = Options.Find('Position', 0);

	header.SetText(Options[ii].Message);

	// Iterate through array and give every line it's message.
	For(i = 1; i < Lines.Length; i++)
	{
		ii = Options.Find('Position', i); // Find the next position
			if(ii == -1) continue;	// If the position doesn't exist, go to the next.

		Lines[i].SetText(Options[ii].Message);

		if(Lines[i].GetColorTransform() != Options[ii].myCT) { // Check if the new line's color is the same as the one it is replacing.
			Lines[i].SetColorTransform(Options[ii].myCT);
			Keys[i].SetColorTransform(Options[ii].myCT);
		}
	}

	// Iterate through array and give every line it's key.
	For(i = 1; i < Keys.Length; i++)
	{
		ii = Options.Find('Position', i); // Find the next position
			if(ii == -1) continue; // If the position doesn't exist, go to the next.

		if(Left(Options[ii].Key, 3) == "-X-") {

			Options[ii].Key = Mid(Options[ii].Key, 3); // Remove -X-

		} else if(Left(Options[ii].Key, 3) == "-S-") {

			Options[ii].Key = Mid(Options[ii].Key, 3); // Remove -S-
		}

		Keys[i].SetText(Options[ii].Key$":");
	
		SideMenuVis(true); // Display the actual menu.
	} 
}

function SideMenuVis(bool type)
{
	SideMenu.SetVisible(type);
}

function DisplayHelpMenu(array<string> Text)
{
	local int i;
	local GFxObject HelpLine;
	local ASDisplayInfo DI;

	ForEach HelpLines(HelpLine)	// Clear pre-existing lines.
		HelpLine.SetText("");

	For(i = 0; i < Text.Length; i++) // Iterate through each line and assign every line it's text.
		HelpLines[i].SetText(Text[i]);

	DI = HelpMenu.GetDisplayInfo();

	DI.YScale = Text.Length * 5 + 15; // Calculate the size of the help menu to be around the same size as the amount of lines.

	HelpMenu.SetDisplayInfo(DI); // Apply said new size to the GFxObject.

	HelpMenuVis(true);
}

function HelpMenuVis(bool type)
{
	local GFxObject Line;

	HelpMenu.SetVisible(type);

	if(!type)
		ForEach HelpLines(Line)
			Line.SetText("");
}

function AddChatMessage(string html, string raw)
{
	local MessageRow mrow;
	local ASDisplayInfo DisplayInfo;
	local byte i;
	local int numLines; //nBab
	local bool bConcated; 
	
	//Inject to concat identical messages spammed 
	if( ChatMessages.Length > 1 && 
	ChatMessages[0].TextEmphasis < 4 && 
	`WorldInfoObject.TimeSeconds < ChatMessages[0].ConcatDisableTime && 
	Caps(ChatMessages[0].TF.GetString("rawMsg")) == Caps(raw))
	{
		ChatMessages[0].TextEmphasis = min(ChatMessages[0].TextEmphasis+1, 4);
		switch(ChatMessages[0].TextEmphasis){
			case 0:
				ChatMessages[0].TF.SetString("htmlText", ">" $ html);
				break;
			case 1:
				ChatMessages[0].TF.SetString("htmlText", ">>" $ html);
				break;
			case 2:
				ChatMessages[0].TF.SetString("htmlText", ">><font size='15'>" $ html $ "</font><");
				break;
			case 3:
				ChatMessages[0].TF.SetString("htmlText", ">><font size='16'>" $ html $ "</font><");
				break;
			case 4:
				ChatMessages[0].TF.SetString("htmlText", ">><font size='17'>" $ html $ "</font><");
				break;
		}
		
		//ChatMessages[0].TextEmphasis = min(ChatMessages[0].TextEmphasis+1, 4);
		bConcated = true; 
		//ChatMessages[0].TF.SetString("htmlText", "<font size='"$14+ChatMessages[0].TextEmphasis$"'>" $ html $ "</font>");
	}
	
	if(bConcated)
	{
		return;
	}
		
	
	if (FreeChatMessages.Length > 0)
	{
		mrow = FreeChatMessages[FreeChatMessages.Length-1];
		FreeChatMessages.Remove(FreeChatMessages.Length-1,1);
	}
	else
	{
		mrow = ChatMessages[ChatMessages.Length-1];
		ChatMessages.Remove(ChatMessages.Length-1,1);
	}
	
	mrow.MC.GetObject("message").GotoAndStopI(0);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText", html);
	mrow.TF.SetString("rawMsg", raw);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	mrow.MC.GotoAndPlay("show");
	//get number of lines from flash (nBab)
	numLines = mrow.MC.GetObject("message").GetObject("textField").GetInt("numLines");
	for (i = 0; i < ChatMessages.Length; i++)
	{
		//set message height based on number of lines (nBab)
		//ChatMessages[i].Y += MessageHeight; (Old line)
		ChatMessages[i].Y += MessageHeight * numLines;
		DisplayInfo.Y = ChatMessages[i].Y;
		ChatMessages[i].MC.SetDisplayInfo(DisplayInfo);
	}
	mrow.ConcatDisableTime=`WorldInfoObject.TimeSeconds+8; //Add time before messages fade away
	ChatMessages.InsertItem(0,mrow);
}

function AddVehicleDeathMessage(string HTMLMessage, class<DamageType> Dmg, PlayerReplicationInfo Killer)
{
	FadeScreenMC.SetVisible(true);
	SubtitlesText.SetVisible(true);

	VehicleDeathMsgTime = RenxHud.WorldInfo.TimeSeconds + VehicleDeathDisplayLength;

	Subtitle_Messages.AddItem(HTMLMessage$"\n<img src='" $ ParseDamageType(Dmg, Killer ) $ "'>");
	
	/**SubtitlesText.SetString("htmlText", HTMLMessage 
		$"\n<img src='" $ParseDamageType(Dmg, Killer ) $"'>");*/
}

function AddDeathMessage(string HTMLMessage, class<DamageType> Dmg, PlayerReplicationInfo Killer)
{
	FadeScreenMC.SetVisible(true);
	SubtitlesText.SetVisible(true);
	//show respawn hud (nBab)
	showRespawnhud(GetPC().GetTeamNum(),lastFreeClass);

	Subtitle_Messages.AddItem(HTMLMessage$"\n<img src='" $ ParseDamageType(Dmg, Killer ) $"'>");
	
	/**SubtitlesText.SetString("htmlText", HTMLMessage  
		$"\n<img src='" $ ParseDamageType(Dmg, Killer ) $"'>");
*/

}

//function AddKillMessage(string msg, string msgColor, int iType)
function AddGameEventMessage(string text)
{
	local MessageRow mrow;
	local ASDisplayInfo DisplayInfo;
	local byte i;

	if (FreeDeathMessages.Length > 0)
	{
		mrow = FreeDeathMessages[FreeDeathMessages.Length-1];
		FreeDeathMessages.Remove(FreeDeathMessages.Length-1,1);
	}
	else
	{
		mrow = DeathMessages[DeathMessages.Length-1];
		DeathMessages.Remove(DeathMessages.Length-1,1);
	}

	mrow.MC.GetObject("message").GotoAndStopI(1);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText", text);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	mrow.MC.GotoAndPlay("show");
	for (i = 0; i < DeathMessages.Length; i++)
	{
		DeathMessages[i].Y += MessageHeight;
		DisplayInfo.Y = DeathMessages[i].Y;
		DeathMessages[i].MC.SetDisplayInfo(DisplayInfo);
	}
	DeathMessages.InsertItem(0,mrow);
}


function newSpot(int num)
{
	RootMC.ActionScriptVoid("newSpot");
}

function updateSpot(int num, int loc_x, int loc_y)
{
	RootMC.ActionScriptVoid("updateSpot");
}

function removeSpot(int num)
{
	RootMC.ActionScriptVoid("removeSpot");
}

function ChangedWeapon(string direction) 
{
	RootMC.ActionScriptVoid("ChangedWeapon");	
}


function MsgFromFlash(string sName, string sMessage, int iType)
{
	if(iType == 0)
	{
		ConsoleCommand("Say"@sMessage);
	}
	if(iType == 1)
	{
		ConsoleCommand("Teamsay"@sMessage);
	}
}

function UnFocusHUD()
{
	
}

function FocusToChat()
{
	//ActionScriptVoid("FocusToChat");
}


function LogToFlash(string sLogMsg)
{
	ActionScriptVoid("ULog");
}

function uLog(string s)
{
	loginternal(s);
}

function string ParseDamageType( class<DamageType> Dmg, optional PlayerReplicationInfo Killer )
{
	local string weaponTexture;
	//local Rx_Weapon KillerWeapon;
	local class<UTWeaponAttachment> KillerWeaponAttachment;
	local Rx_Vehicle_Weapon KillerVehicleWeapon;
	local Pawn KillerPawn;
	local Rx_Vehicle KillerVehicle;
	local byte i;


	if (Killer != none) {
		ForEach GetPC().WorldInfo.AllPawns(class'Pawn', KillerPawn) {
			if ( KillerPawn.PlayerReplicationInfo == Killer ) {
				if (Rx_Vehicle(KillerPawn) != none) {
					KillerVehicle = Rx_Vehicle(KillerPawn);
				}
				if (Rx_Pawn(KillerPawn) != none) {
					KillerWeaponAttachment = Rx_Pawn(KillerPawn).CurrentWeaponAttachmentClass;
				}
			}
		}
	}

	if (KillerVehicle != none) {
		for (i = 0; i < KillerVehicle.Seats.Length; i++) {
			if (KillerVehicle.Seats[i].GunClass != none) {
				KillerVehicleWeapon = Rx_Vehicle_Weapon(KillerVehicle.Seats[i].Gun);
			}
		}
	}
	
	if (class<Rx_DmgType>(Dmg) != None && class<Rx_DmgType>(Dmg).default.IconTexture != None)
	{
		return "img://" $ PathName(class<Rx_DmgType>(Dmg).default.IconTexture);
	}


	weaponTexture = "img://" $ PathName(Texture2D'RenX_AssetBase.DeathIcons.T_DeathIcon_GenericSkull');

	switch (Dmg)
	{
		case class'Rx_DmgType_Headshot': 
			if (KillerWeaponAttachment != none) {
				if (class<UTProjectile>(KillerWeaponAttachment.default.Weaponclass.default.WeaponProjectiles[0]).default.MyDamageType != none) {
					return ParseDamageType(class<UTProjectile>(KillerWeaponAttachment.default.Weaponclass.default.WeaponProjectiles[0]).default.MyDamageType, Killer);
				} else if (KillerWeaponAttachment.default.Weaponclass.default.InstantHitDamageTypes[0] != none) {
					return ParseDamageType(KillerWeaponAttachment.default.Weaponclass.default.InstantHitDamageTypes[KillerWeaponAttachment.default.Weaponclass.default.CurrentFireMode], Killer);
				}
			} else if (KillerVehicleWeapon != none) {
				if (class<UTProjectile>(KillerVehicleWeapon.GetProjectileClass()).default.MyDamageType != none) {
					return ParseDamageType(class<UTProjectile>(KillerVehicleWeapon.GetProjectileClass()).default.MyDamageType, Killer);
				} else if (KillerVehicleWeapon.InstantHitDamageTypes[KillerVehicleWeapon.CurrentFireMode] != none) {
					return ParseDamageType(KillerVehicleWeapon.InstantHitDamageTypes[KillerVehicleWeapon.CurrentFireMode], Killer);
				}
			}
			break;

		// VEHICLES
		case class'Rx_DmgType_RanOver': 
			if (KillerWeaponAttachment != none) {
				if (class<UTProjectile>(KillerWeaponAttachment.default.Weaponclass.default.WeaponProjectiles[0]).default.MyDamageType != none) {
					return ParseDamageType(class<UTProjectile>(KillerWeaponAttachment.default.Weaponclass.default.WeaponProjectiles[0]).default.MyDamageType, Killer);
				} else if (KillerWeaponAttachment.default.Weaponclass.default.InstantHitDamageTypes[0] != none) {
					return ParseDamageType(KillerWeaponAttachment.default.Weaponclass.default.InstantHitDamageTypes[KillerWeaponAttachment.default.Weaponclass.default.CurrentFireMode], Killer);
				}
			} else if (KillerVehicleWeapon != none) {
				if (class<UTProjectile>(KillerVehicleWeapon.GetProjectileClass()).default.MyDamageType != none) {
					return ParseDamageType(class<UTProjectile>(KillerVehicleWeapon.GetProjectileClass()).default.MyDamageType, Killer);
				} else if (KillerVehicleWeapon.InstantHitDamageTypes[KillerVehicleWeapon.CurrentFireMode] != none) {
					return ParseDamageType(KillerVehicleWeapon.InstantHitDamageTypes[KillerVehicleWeapon.CurrentFireMode], Killer);
				}
			}
			break;
		case class'Rx_DmgType_Pancake': 
			if (KillerWeaponAttachment != none) {
				if (class<UTProjectile>(KillerWeaponAttachment.default.Weaponclass.default.WeaponProjectiles[0]).default.MyDamageType != none) {
					return ParseDamageType(class<UTProjectile>(KillerWeaponAttachment.default.Weaponclass.default.WeaponProjectiles[0]).default.MyDamageType, Killer);
				} else if (KillerWeaponAttachment.default.Weaponclass.default.InstantHitDamageTypes[0] != none) {
					return ParseDamageType(KillerWeaponAttachment.default.Weaponclass.default.InstantHitDamageTypes[KillerWeaponAttachment.default.Weaponclass.default.CurrentFireMode], Killer);
				}
			} else if (KillerVehicleWeapon != none) {
				if (class<UTProjectile>(KillerVehicleWeapon.GetProjectileClass()).default.MyDamageType != none) {
					return ParseDamageType(class<UTProjectile>(KillerVehicleWeapon.GetProjectileClass()).default.MyDamageType, Killer);
				} else if (KillerVehicleWeapon.InstantHitDamageTypes[KillerVehicleWeapon.CurrentFireMode] != none) {
					return ParseDamageType(KillerVehicleWeapon.InstantHitDamageTypes[KillerVehicleWeapon.CurrentFireMode], Killer);
				}
			}
			break;
	}

	return weaponTexture;
}

//Setup Tech Building Icons (nBab)
function setupTechBuildingIcons ()
{
	//local RX_Building_Silo tempSilo;
	local Rx_Building tempBuilding;
	local byte i;
	local int startX;
	local string UnrealScriptBug;
	local Rx_GRI GRI;
	local Actor TBA; 
	
	//if tech building icon is disabled in settings menu, do nothing.
	if (Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetTechBuildingIcon() == 2)
		return;

	GRI = Rx_GRI(class'WorldInfo'.static.GetWorldInfo().GRI);
	
	//if color changing tech building icon is selected in settings, show the background.
	if (Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetTechBuildingIcon() == 1)
		GetVariableObject("_root.BottomInfo.tech_icons.tech_bg").SetVisible(true);

	//get building count and gdi infantry building
	buildingCount = 0;
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class 'RX_Building',tempBuilding)
	{
		//skip building ramps and tech buildings and nod buildings
		if (tempBuilding.isA('Rx_Building_GDI_InfantryFactory') || 
			tempBuilding.isA('Rx_Building_GDI_MoneyFactory') || 
			tempBuilding.isA('Rx_Building_GDI_VehicleFactory') || 
			tempBuilding.isA('Rx_Building_GDI_Defense') || 
			tempBuilding.isA('Rx_Building_GDI_PowerFactory'))
			buildingCount++;
		if (tempBuilding.isA('Rx_Building_GDI_InfantryFactory'))
			GDIInfantryFactory = tempBuilding;
	}

	//set gdi and nod building count
	gdi_buildings = buildingCount;
	nod_buildings = buildingCount;

	// Check if the Fort tech building is on this map	
	foreach class'WorldInfo'.static.GetWorldInfo().DynamicActors(class'Actor',TBA)
	{
		if(TBA.isA('Rx_CapturableMCT_Fort')){
			Fort = TBA; 
			break;
		}	
	}
	
	
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor',EMP)
	{
		if (EMP.tag=='EMP')
			break;
	}
	
	//Gather tech buildings 
	foreach GRI.TechBuildingArray(TBA) {
		if(TBA.isA('RX_Building_CommCentre_Internals')) CC = TBA;
		if(TBA.isA('Rx_Building_MedicalCentre_Internals')) MC = TBA;
		if(TBA.isA('RX_Building_Silo_Internals')) Silo.AddItem(TBA); 
	}; 
	
	//sort silos based on distance to bases
	if(Silo.length>1)
		Silo.Sort(SiloSort);

	//if we don't have any tech buildings, do nothing.
	if (Fort == None && MC == None && CC == None && EMP == None && silo.length == 0)
		return;

	//add fort and its initial team
	if (Fort != None)
	{
		tech_buildings.AddItem("Fort");
		tech_buildings_team.AddItem(255);
	}
	//add silos and their initial team
	if (silo[0] != None )
	{
		for (i=0; i<Silo.length; i++)
		{
			if (Silo.length>1 && i==0)
			{
				tech_buildings.AddItem("Silo_GDI");
				tech_buildings_team.AddItem(255);
			}else if (Silo.length>1 && i==Silo.length-1)
			{
				tech_buildings.AddItem("Silo_Nod");
				tech_buildings_team.AddItem(255);
			}else
			{
				tech_buildings.AddItem("Silo_"$i);
				tech_buildings_team.AddItem(255);
			}
		}
	}
	//add medical center and its initial team
	if (MC != None)
	{
		tech_buildings.AddItem("MC");
		tech_buildings_team.AddItem(255);
	}
	//add communications center and its initial team
	if (CC != None)
	{
		tech_buildings.AddItem("CC");
		tech_buildings_team.AddItem(255);
	}
	//add emp and its initial team
	if (EMP != None)
	{
		tech_buildings.AddItem("EMP");
		tech_buildings_team.AddItem(255);
	}

	//set start x position based on number of icons
	if (tech_buildings.length%2==0)
		startX = -10 - (((tech_buildings.length-2)/2)*25);
	else
		startX = 2 - ((tech_buildings.length-1)/2)*25;


	//add icon movieclip from library to hud and set the correct icon
	for (i=0;i<tech_buildings.length;i++)
	{
		tech_building_icons[i] = tech_icons.AttachMovie("tech_icons_mc","tech_icon_"$i);
		tech_building_icons[i].setfloat("x",(startX+(i*25)));
		UnrealScriptBug = tech_buildings[i];
		switch(UnrealScriptBug)
		{
			case "Fort":
				LoadTexture("img://"$PathName(Texture2D'RenxHud.T_Tech_Fort'), tech_building_icons[i]);
				break;
			case "MC":
				LoadTexture("img://"$PathName(Texture2D'RenxHud.T_Tech_MC'), tech_building_icons[i]);
				break;
			case "CC":
				LoadTexture("img://"$PathName(Texture2D'RenxHud.T_Tech_CC'), tech_building_icons[i]);
				break;
			case "EMP":
				LoadTexture("img://"$PathName(Texture2D'RenxHud.T_Tech_EMP'), tech_building_icons[i]);
				break;
			case "Silo_0":
			case "Silo_1":
			case "Silo_2":
			case "Silo_3":
				LoadTexture("img://"$PathName(Texture2D'RenxHud.T_Tech_Silo'), tech_building_icons[i]);
				break;
			case "Silo_GDI":
				LoadTexture("img://"$PathName(Texture2D'RenxHud.T_Tech_Silo_GDI'), tech_building_icons[i]);
				break;
			case "Silo_Nod":
				LoadTexture("img://"$PathName(Texture2D'RenxHud.T_Tech_Silo_Nod'), tech_building_icons[i]);
				break;
			default:
				break;
		}
	}

	/**`log ("**************nBab****************");
	`log ("tech_buildings.length = "$tech_buildings.length);*/
	for (i=0; i<tech_buildings.length; i++)
	{
		`log ("tech_buildings_"$i$" = "$tech_buildings[i]);
	}
	/*`log ("**************nBab****************");*/
}

//Update Tech Building Icons (nBab)
function updateTechBuildingIcons ()
{
	local byte i;
	local string UnrealScriptBug;
	local byte TeamNum;
	local ASColorTransform CT;

	//if tech building icon is disabled in settings menu, do nothing.
	if (Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetTechBuildingIcon() == 2)
		return;

	//if we don't have any tech buildings, do nothing.
	if ( Rx_GRI(GetPC().WorldInfo.GRI).TechBuildingArray.Length == 0)
		return;
		
	for (i=0;i<tech_buildings.length;i++)
	{
		UnrealScriptBug = tech_buildings[i]; 
		switch(UnrealScriptBug)
		{
			case "Fort":
				TeamNum = Fort.GetTeamNum();
				break;
			case "MC":
				TeamNum = MC.GetTeamNum();
				break;
			case "CC":
				TeamNum = CC.GetTeamNum();
				break;
			case "EMP":
				TeamNum = EMP.GetTeamNum();
				break;
			case "Silo_0":
				TeamNum = Silo[0].GetTeamNum();
				break;
			case "Silo_1":
				TeamNum = Silo[1].GetTeamNum();
				break;
			case "Silo_2":
				TeamNum = Silo[2].GetTeamNum();
				break;
			case "Silo_3":
				TeamNum = Silo[3].GetTeamNum();
				break;
			case "Silo_GDI":
				TeamNum = Silo[0].GetTeamNum();
				break;
			case "Silo_Nod":
				TeamNum = Silo[Silo.length-1].GetTeamNum();
				break;
			default:
				break;
		}
		
		//if animating tech building icon is selected
		if (Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetTechBuildingIcon() == 0)
		{ 
			if (TeamNum == Team_GDI && tech_buildings_team[i] == 255)
			{
				//animate from center to gdi
				doTween(tech_building_icons[i],TechIconTweenDuration,GetGDIEmptySocket());
				tech_buildings_team[i] = Team_GDI;
				gdi_buildings++;
			}else if (TeamNum == Team_Nod && tech_buildings_team[i] == 255)
			{
				//animate from center to nod
				doTween(tech_building_icons[i],TechIconTweenDuration,GetNodEmptySocket());
				tech_buildings_team[i] = Team_Nod;
				nod_buildings++;
			}else if (TeamNum != Team_GDI && TeamNum != Team_Nod && tech_buildings_team[i] == Team_GDI)
			{
				//animate from gdi to center
				doTween(tech_building_icons[i],TechIconTweenDuration,GetOriginalSocket(i));
				SortSockets(i,tech_buildings_team[i]);
				tech_buildings_team[i] = 255;
				gdi_buildings--;
			}else if (TeamNum != Team_GDI && TeamNum != Team_Nod && tech_buildings_team[i] == Team_Nod)
			{
				//animate from nod to center
				doTween(tech_building_icons[i],TechIconTweenDuration,GetOriginalSocket(i));
				SortSockets(i,tech_buildings_team[i]);
				tech_buildings_team[i] = 255;
				nod_buildings--;
			}
		}
		//if color changing tech building icon is selected
		else
		{
			if (TeamNum == Team_GDI && tech_buildings_team[i] == 255)
			{
				CT.multiply.G = 0.8;
				CT.multiply.B = 0.15;
				CT.add.R = 0.5;
				CT.add.G = 0.3;
				CT.add.B = 0.07;
				tech_building_icons[i].SetColorTransform(CT);
				tech_buildings_team[i] = Team_GDI;
			}
			else if (TeamNum == Team_Nod && tech_buildings_team[i] == 255)
			{
				CT.multiply.G = 0;
				CT.multiply.B = 0;
				CT.add.R = 0.03;
				CT.add.G = 0.03;
				CT.add.B = 0.03;
				tech_building_icons[i].SetColorTransform(CT);
				tech_buildings_team[i] = Team_Nod;
			}
			else if (TeamNum != Team_GDI && TeamNum != Team_Nod)
			{
				CT.multiply.G = 1;
				CT.multiply.B = 1;
				CT.add.R = 0;
				CT.add.G = 0;
				CT.add.B = 0;
				tech_building_icons[i].SetColorTransform(CT);
				tech_buildings_team[i] = 255;
			}
		}
	}
}

//call the actionscript function to tween the icon (nBab)
function doTween(gfxobject mc_object, int duration, int end)
{
	tech_icons.ActionScriptVoid("doTween");
}

//returns x position of the empty gdi socket (nBab)
function int GetGDIEmptySocket()
{
	return -(159-((gdi_buildings-1)*25));
}

//returns x position of the empty nod socket (nBab)
function int GetNodEmptySocket()
{
	return 163-((nod_buildings-1)*25);
}

//returns original x position of the icon (nBab)
function int GetOriginalSocket(byte i)
{
	local int startX;

	if (tech_buildings.length%2==0)
		startX = -10 - (((tech_buildings.length-2)/2)*25);
	else
		startX = 2 - ((tech_buildings.length-1)/2)*25;

	return startX+(i*25);
}

//tweens icons to fill in the empty socket after an icon has been removed (nBab)
function SortSockets(byte j, byte TeamNum)
{
	local byte i;

	for (i=0;i<tech_buildings.length;i++)
	{
		if (TeamNum == Team_GDI)
		{
			if (tech_buildings_team[i] == TeamNum && tech_building_icons[i].getfloat("x") > tech_building_icons[j].getfloat("x"))
				doTween(tech_building_icons[i],TechIconTweenDuration/2,tech_building_icons[i].getfloat("x")-25);
		}else
		{
			if (tech_buildings_team[i] == TeamNum && tech_building_icons[i].getfloat("x") < tech_building_icons[j].getfloat("x"))
				doTween(tech_building_icons[i],TechIconTweenDuration/2,tech_building_icons[i].getfloat("x")+25);
		}
	}
}

//sorts silos based on their distance to the gdi infantry factory (nBab)
function int SiloSort (Actor Silo1, Actor Silo2)
{
	local float silo1_distance;
	local float silo2_distance;

	silo1_distance = VSizeSq(silo1.Location - GDIInfantryFactory.Location);
	silo2_distance = VSizeSq(silo2.Location - GDIInfantryFactory.Location);

	return (silo1_distance > silo2_distance) ? -1 : 0;
}

//update veterancy (nBab)
function updateVeterancy()
{
	local Rx_PRI RxPRI;
	local int VetProgress;

	RxPRI = Rx_PRI(GetPC().PlayerReplicationInfo);
	if(GetPC().IsSpectating() && Pawn(GetPC().ViewTarget) != None)
		RxPRI = Rx_PRI(Pawn(GetPC().ViewTarget).PlayerReplicationInfo); 	

	if (RxPRI != None)
	{
		//set veterancy title and progress
		switch (RxPRI.VRank)
		{
			case 0:
				setVetText("RECRUIT");
				VetProgress = (RxPRI.Veterancy_Points - RxPRI.default.Veterancy_Points) * 100 / (class'Rx_Game'.default.VPMilestones[0] - RxPRI.default.Veterancy_Points);
				break;
			case 1:
				setVetText("VETERAN");
				VetProgress = (RxPRI.Veterancy_Points - class'Rx_Game'.default.VPMilestones[0]) * 100 / (class'Rx_Game'.default.VPMilestones[1] - class'Rx_Game'.default.VPMilestones[0]);
				break;
			case 2:
				setVetText("ELITE");
				VetProgress = (RxPRI.Veterancy_Points - class'Rx_Game'.default.VPMilestones[1]) * 100 / (class'Rx_Game'.default.VPMilestones[2] - class'Rx_Game'.default.VPMilestones[1]);
				break;
			case 3:
				setVetText("HEROIC");
				VetProgress = 100;	
				break;
			default:
				setVetText("KANE!");
				VetProgress = 100;	
				break;
		}

		//set veterancy icon
		if (RxPRI.VRank == VRank+1)
		{
			GetVariableObject("_root.HealthBlock.vet.vet_icon.vet_icon_current").GotoAndStopI(VRank+1);
			GetVariableObject("_root.HealthBlock.vet.vet_icon.vet_icon_next").GotoAndStopI(RxPRI.VRank+1);
			GetVariableObject("_root.HealthBlock.vet.vet_icon").GotoAndPlayI(2);
			GetVariableObject("_root.centerTextMC.centerText.textField").setText("Promoted to "$GetVariableObject("_root.HealthBlock.vet.vet_tf").getText());
			GetVariableObject("_root.centerTextMC").GotoAndPlayI(2);
			VRank++;
			//play sound
			//GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.SFX.S_Kill_Alert_Cue');
			//GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.SFX.S_Bonus_Complete_Cue');
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.SFX.S_Primary_Update_Cue');
		}

		//set veterancy bar
		GetVariableObject("_root.HealthBlock.vet.vet_bar.bar").GotoAndStopI(VetProgress+1);
	}
}

//show respawn hud (nBab)
function showRespawnHud(int teamNum, int lfClass)
{
	GetVariableObject("_root.Cinema.respawn_ui").ActionScriptVoid("showRespawnHud");
}

//hide respawn hud (nBab)
function hideRespawnHud()
{
	GetVariableObject("_root.Cinema.respawn_ui").ActionScriptVoid("hideRespawnHud");
	//GetVariableObject("_root.Cinema.respawn_ui").ActionScriptVoid("removeListeners");
}

//set respawn hud counter (nBab)
function setRespawnCounter(int count)
{
	//if finished counting, show ready and set color to green
	if (count < 1)
		{
			GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.counter").SetVisible(false);
			GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.tf").SetVisible(false);
			GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.ready").SetVisible(true);
			GetVariableObject("_root.Cinema.respawn_ui.hex_spawn").GotoAndStopI(2);
			GetVariableObject("_root.Cinema.respawn_ui.hex_center").GotoAndStopI(2);
			setReadyText("Ready");
			GetVariableObject("_root.Cinema.respawn_ui").setBool("disableArrowAD",false);
		}
	//if not, set the counter
	else
	{
		GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.counter").SetVisible(true);
		GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.tf").SetVisible(true);
		GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.ready").SetVisible(false);
		GetVariableObject("_root.Cinema.respawn_ui.hex_spawn").GotoAndStopI(1);
		GetVariableObject("_root.Cinema.respawn_ui.hex_center").GotoAndStopI(1);
		GetVariableObject("_root.Cinema.respawn_ui").ActionScriptVoid("setRespawnCounter");	
	}
}

//set ready textfield text(nBab)
function setReadyText(String ready)
{
	GetVariableObject("_root.Cinema.respawn_ui").ActionScriptVoid("setReadyText");	
}

//set last free class (called from flash) (nBab)
function setLastFreeClass(int fClass)
{
	lastFreeClass = fClass;
	
	Rx_PRI(RenxHud.PlayerOwner.PlayerReplicationInfo).SetLastFreeCharacter(fClass); 
}

//play menu change sound (called from flash) (nBab)
function PlayRespawnSound()
{
	GetPC().ClientPlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue');
}

//start normal chat (nBab)
function startchat ()
{
	//show messagebox and set team to 255
	messageboxfocus(255);
	GetVariableObject("_root.messagebox.tf").SetText("");
	//capture keyboard input
	GetPC().PlayerInput.ResetInput();
	self.bCaptureInput = true;
}

//start team chat (nBab)
function startteamchat ()
{
	//show messagebox and set team to current player team
	messageboxfocus(GetPC().GetTeamNum());
	GetVariableObject("_root.messagebox.tf").SetText("");
	//capture keyboard input
	GetPC().PlayerInput.ResetInput();
	self.bCaptureInput = true;
}

//start private chat (nBab)
function startprivatechat ()
{
	//set the last nick
	if (lastPrivateNick != "" && lastPrivateNick != " ")
		GetVariableObject("_root.messagebox.tf").SetText(lastPrivateNick$" ");
	else
		GetVariableObject("_root.messagebox.tf").SetText("");
	//show messagebox and set team to private chat	
	messageboxfocus(3);
	//capture keyboard input
	GetPC().PlayerInput.ResetInput();
	self.bCaptureInput = true;
}

//end the message and submit or discard it
function endchat (int teamNum)
{
	local string msg;
	local int i;
	
	//get the message
	msg = GetVariableObject("_root.messagebox.tf").GetText();

	//submit/discard the message depending on the type
	switch (teamNum)
	{
		case 0:
		case 1:
			ConsoleCommand("teamsay"@msg);
			for (i=9;i>0;i--)
				TeamMessages[i] = TeamMessages[i-1];
			TeamMessages[0] = msg;
			break;
		case 2:
			//discard
			break;
		case 3:
			ConsoleCommand("privatesay"@msg);
			for (i=9;i>0;i--)
				PrivateMessages[i] = PrivateMessages[i-1];
			PrivateMessages[0] = msg;
			//set the last nick a private message has been sent to
			lastPrivateNick = left(msg,InStr(msg," "));
			break;
		case 255:
		default:
			ConsoleCommand("say"@msg);
			for (i=9;i>0;i--)
				NormalMessages[i] = NormalMessages[i-1];
			NormalMessages[0] = msg;
			break;
	}
	//empty the input field
	GetVariableObject("_root.messagebox.tf").SetText("");
	//hide messagebox box
	messageboxremovefocus();
	//stop capturing keyboard input
	self.bCaptureInput = false;
	//reset message number
	messageNum = -1;
}

//show the message box and set its mode (nBab)
function messageboxfocus (int teamNum)
{
	GetVariableObject("_root.messagebox").ActionScriptVoid("doFocus");
}

//hide the message box (nBab)
function messageboxremovefocus ()
{
	GetVariableObject("_root.messagebox").ActionScriptVoid("removeFocus");
}

//get previous message depending on type (nBab)
function string getPreviousMessage (int mode)
{
	switch (mode)
	{
		//team message
		case 0:
		case 1:
			if (messageNum<9 && TeamMessages[messageNum+1] != "None")
				return (TeamMessages[++messageNum]);
			break;
		//private message
		case 3:
			if (messageNum<9 && PrivateMessages[messageNum+1] != "None")
				return (PrivateMessages[++messageNum]);
			break;
		//normal message
		case 255:
			if (messageNum<9 && NormalMessages[messageNum+1] != "None")
				return (NormalMessages[++messageNum]);
			break;
	}
	return "None";
}

//get next message depending on type (nBab)
function string getNextMessage (int mode)
{
	switch (mode)
	{
		//team message
		case 0:
		case 1:
			if (messageNum>0 && TeamMessages[messageNum-1] != "None")
				return (TeamMessages[--messageNum]);
			break;
		//private message
		case 3:
			if (messageNum>0 && PrivateMessages[messageNum-1] != "None")
				return (PrivateMessages[--messageNum]);
			break;
		//normal message
		case 255:
			if (messageNum>0 && NormalMessages[messageNum-1] != "None")
				return (NormalMessages[--messageNum]);
			break;
	}
	return "None";
}

//set veterancy title (nBab)
function setVetText(String str)
{
	GetVariableObject("_root.HealthBlock.vet").ActionScriptVoid("setVetText");
}

//update respawn ui and set the correct 3rd free class team (nBab)
function updateRespawnUI(int Team)
{
	local string center_text;
	center_text = GetVariableObject("_root.Cinema.respawn_ui.hex_center.hex.tf").GetText();
	switch (Team)
	{
		case 0:
		case 255:
			GetVariableObject("_root.Cinema.respawn_ui.sm_fade.sm.hex_3.hex.tf").SetText("Grenadier");
			GetVariableObject("_root.Cinema.respawn_ui.sm_fade.sm.hex_3.hex.wp").GotoAndStopI(3);
			if (center_text == "Flamethrower")
			{
				GetVariableObject("_root.Cinema.respawn_ui.hex_center.hex.tf").SetText("Grenadier");
				GetVariableObject("_root.Cinema.respawn_ui.hex_center.hex.wp").GotoAndStopI(3);
			}
			break;
		case 1:
			GetVariableObject("_root.Cinema.respawn_ui.sm_fade.sm.hex_3.hex.tf").SetText("Flamethrower");
			GetVariableObject("_root.Cinema.respawn_ui.sm_fade.sm.hex_3.hex.wp").GotoAndStopI(6);
			if (center_text == "Grenadier")
			{
				GetVariableObject("_root.Cinema.respawn_ui.hex_center.hex.tf").SetText("Flamethrower");
				GetVariableObject("_root.Cinema.respawn_ui.hex_center.hex.wp").GotoAndStopI(6);
			}
			break;
	}
}

//Show the ongoing vote and animate it at start (nBab)
function showVote(String content, int yes, int no, int yesNeeded, int timeLeft)
{
	local float x0, y0, x1, y1;
	local string VoteYesBind, VoteNoBind;
	
	if (content == "")
	{
		if (voteTextMC != None)
		{
			removeChild(voteTextMC);
			voteJustStarted = true;
		}

		return;
	}
	
	VoteYesBind = Rx_PlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand("voteyes"); 
	
	VoteNoBind = Rx_PlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand("voteno"); 
	
	//if the vote has just started, add the textfield movieclip from library and do the animation
	if (voteJustStarted)
	{
		//Add textfield to the scene
		voteTextMC = GetVariableObject("_root").AttachMovie("centerTextMC","voteTextMC");
		//set the initial position (center)
		GetVisibleFrameRect(x0, y0, x1, y1);
		//voteTextMC.SetPosition(x1 * 0.1197,y1 * 0.4839);
		voteTextMC.SetPosition(x1 * 0.1197,100);
		//voteTextMC.
		//set the content
		voteTextMC.GotoAndStopI(2);
		voteTextMC.GetObject("centerText").GetObject("textField").SetFloat("height",60);
		voteTextMC.GetObject("centerText").GetObject("textField").SetString("htmlText",content$" <br> " $ VoteYesBind $ ": Yes ("$String(yes)$")" $ VoteNoBind $ ": No ("$String(no)$") - "$String(yesNeeded)$" Yes votes needed, "$String(timeLeft)$" seconds left");
		//animate the vote
		doVoteTween(voteTextMC,2,30);
		//play sound
		GetPC().ClientPlaySound(SoundCue'rx_interfacesound.Wave.Vote_Start');

		voteJustStarted = false;
	}
	//else update votes
	else
	{
		voteTextMC.GetObject("centerText").GetObject("textField").SetString("htmlText",content$" <br>" $ VoteYesBind $ ": Yes ("$String(yes)$") " $ VoteNoBind $ ": No ("$String(no)$") - "$String(yesNeeded)$" Yes votes needed, "$String(timeLeft)$" seconds left");
	}
}

//call the actionscript function to tween the icon (nBab)
function doVoteTween(gfxobject mc_object, int duration, int end)
{
	voteTextMC.ActionScriptVoid("doVoteTween");
}

//remove child object (nBab)
function removeChild(GFxObject childObject)
{
    GetVariableObject("_root").ActionScriptVoid("removeChild");
}

function BumpGrenadeMC(int B)
{
	AbilityIconMC.GotoAndStopI(B);
}

/** Returns the first button bound to a given command **/
function name GetBoundKey(string Command)
{
	local byte i;
	local PlayerInput PInput;

	PInput = GetPC().PlayerInput;

	for (i = 0; i < PInput.Bindings.Length; i++) {
		if (PInput.Bindings[i].Command != Command) {
			continue;
		}
		return PInput.Bindings[i].Name;
	}
	return '';
}

DefaultProperties
{
	isInVehicle         = false
	bDisplayWithHudOff  = false
	currentScoreboard   = 1
	MovieInfo           = SwfMovie'RenXHud.RenXHud'
	NumPlayerStats      = 16
	MessageHeight       = 20
	CurrentNumMines     = -1
	CurrentMaxMines     = -1
	CurrentNumVehicles  = -1
	CurrentMaxVehicles  = -1

	VehicleDeathMsgTime = -1
	VehicleDeathDisplayLength = 3
	VPMsg_Cycler = 30

	//tech building icon tween time in seconds (nBab)
	TechIconTweenDuration = 2
	SkipNum = 2
	bUseTickCycle=true //Cycle expensive functions in the TickHUD() function
	
	AbilityKey = X
}