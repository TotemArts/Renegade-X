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

struct SubMsg
{
	var string Message;
	var float Lifetime;	
};

enum EMessageType
{
	EMT_EVA,
	EMT_Chat,
	EMT_CText,
	EMT_Radio,
	EMT_Death
};

var GFxObject     ChatLogMC, CTextLogMC, RadioLogMC, DeathLogMC, EVALogMC;
var array<MessageRow>   ChatMessages, CTextMessages, RadioMessages, DeathMessages, EVAMessages;
var array<MessageRow>   FreeChatMessages, FreeCTextMessages, FreeRadioMessages, FreeDeathMessages, FreeEVAMessages;
var float               MessageHeight,CTextMessageHeight;
var int                 NumEVAMessages, NumCTextMessages, NumRadioMessages, NumChatMessages, NumDeathMessages;

var array<SubMsg>		Subtitle_Messages; 

var GFxObject MinimapBase, CompassMC;
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
var int LastHealthpc, LastMaxHealthpc, LastMaxArmorpc, LastArmorpc, LastStaminapc, LastVArmorpc, LastMaxVArmorpc;
var string LastArmorType;
var string LastVPString;
var int AmmoInClipValue, AmmoInReserveValue, AltAmmoInClipValue, AltAmmoInReserveValue;
var float primaryReloadTimeEllapsed, secondaryReloadTimeEllapsed;
var bool isInVehicle;
var Pawn LastPawn;
var string LastPassengerText;
var string LastWeaponTips, LastSecWeaponTips;
var ASColorTransform LastWeaponTipsColor, LastSecWeaponTipsColor;

//var Rx_Vehicle_Harvester CurrentHarvester;
//var int LastHarvyHealthpc, LastMaxHarvyHealthpc;
var bool bWasBound;
var bool bWasLocked;
var bool bPlayerDead;
var bool bRespawnHUDHidden;
// placed here so we don't have to recall it over and over
var Rx_Controller RxPC;
var Rx_GRI RxGRI;
var Rx_PRI RxPRI;

var UTWeapon lastWeaponHeld;  //variable containing weapon user had last time hud was updated

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject HealthBlock, HealthBar, HealthN, HealthMaxN, HealthText;//nBab
var GFxObject VArmorN, VArmorBar, VArmorText, VArmorMaxN, PassengerContainer, VehicleMC;
var GFxObject ArmorBar, ArmorN, ArmorMaxN, ArmorText;
var GFxObject StaminaBar;
var GFxObject AmmoInClipN, AmmoBar, AmmoReserveN, AltAmmoInClipN, AltAmmoBar, InfinitAmmo, AltInfinitAmmo, WeaponBlock, VAltWeaponBlock;
var GFxObject WeaponListContainer, WeaponMC[5], WeaponName, AltWeaponName;
var GFxObject AbilityMC, AbilityIconMC, AbilityMeterMC, AbilityTextMC;
var GFxObject LockMC;
var GFxObject WeaponTipsMaster;
var GFxObject WeaponTips, WeaponTipsText, WeaponTipsBKG;
var GFxObject SecWeaponTips, SecWeaponTipsText, SecWeaponTipsBKG;
var float WeaponMCAlpha[4];

//Experimental Progress bar
var GFXObject LoadingMeterMC[2], LoadingText[2];
var GFxClikWidget LoadingBarWidget[2];

var GFxObject GrenadeN, GrenadeMC, TimedC4MC, RemoteC4MC, ProxyC4MC, BeaconMC;
var GFxObject HitLocMasterMC;
var GFxObject HitLocMC[8];

//var GFxObject HarvyHealthContainer;
//var GFxObject HarvyBars;
var GFxObject RootMC;


//MessageBox Variables (nBab)
var string lastPrivateNick;
var string PrivateMessages[10];
var string NormalMessages[10];
var string TeamMessages[10];
var int messageNum;

//Respawn Hud Variables (nBab)
var int lastFreeClass;
var int lastTeam;

//Veterancy Variables (nBab)
var GFxObject VeterancyContainer; //'vet'
var GFxObject VeterancyLabel; //'vet_tf'
var GFxObject VeterancyIcon,VeterancyIconCurrent,VeterancyIconNext; //'vet_icon''vet_icon_current''vet_icon_next'
var GFxObject VeterancyBar;
var int LastVetPoint;
var int VRank;

//Voting Variables (nBab, modified by Handepsilon)
var bool bvoteJustStarted;
var GFxObject voteMC;
var GFxObject VoteTextContainerMC;
var GFxObject VoteBackdropMC;
var GFxObject VoteTitleText;
var GFxObject VoteChoiceText;
var int LastYesVote;
var int LastNoVote;
var int LastYesNeededVote;
var int LastVoteSecondsLeft;

//items that we are diabling for now - THIS LIST SHOULD BE EMPTY BY THE TIME THE HUD IS DONE
var GFxObject ObjectiveMC, ObjectiveText, TimerMC, TimerText, FadeScreenMC, SubtitlesText, GameplayTipsText, AdminMessageText, WeaponPickup;
var float LastTipsUpdateTime;
var array<string> AdminMessageQueue;
//var float VehicleDeathDisplayLength;
var byte Tick_Cycler; 
var int	 SkipNum; 
var bool bUseTickCycle; 

var int LastResX;
var int LastResY;

var name AbilityKey; 
var name LockKey;

var float LastCompassPos;

function Initialize()
{
	local byte i;
	//Start and load the SWF Movie
	Start();
	Advance(0.f);

	NumCTextMessages = 0;
	NumEVAMessages = 0;
	NumChatMessages = 0;
	NumRadioMessages=0;
	NumDeathMessages = 0;

	//Log Implementation
	ChatLogMC = GetVariableObject("_root.chatLog");
//	TeamChatLogMC = GetVariableObject("_root.teamchatLog");
	RadioLogMC = GetVariableObject("_root.radioLog");
	DeathLogMC = GetVariableObject("_root.deathLog");
	EVALogMC = GetVariableObject("_root.evaLog");
	CTextLogMC = GetVariableObject("_root.CTextLog");

	//TODO:set the max limit of each count
	for(i = 0; i < 3; i++) 
	{
		InitMessageRow(EMessageType.EMT_CText, NumCTextMessages);
	}
	for(i = 0; i < 5; i++) 
	{
		InitMessageRow(EMessageType.EMT_Chat, NumChatMessages);
	}

	
	InitMessageRow(EMessageType.EMT_EVA, NumEVAMessages);

	for(i = 0; i < 5; i++)
	{
		InitMessageRow(EMessageType.EMT_Radio, NumChatMessages);
	}
	for(i = 0; i < 5; i++) 
	{
		InitMessageRow(EMessageType.EMT_Death, NumDeathMessages);
	}

	InitializeHUDVars();

	//hit indicator
	HitLocMasterMC = GetVariableObject("_root.dirHit");
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

	DisableHUDItems();

	//AddFocusIgnoreKey('t');

	RootMC = GetVariableObject("_root");


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
	bvoteJustStarted = true;
	
	AbilityKey = GetBoundKey("GBA_ToggleAbility");
	LockKey = GetBoundKey("GBA_ToggleVehicleLocking");
}

// Handepsilon : I've been tormented by text that cannot be decipherable in 800x600 for years, 
//				it is time to finally balance the scales >:(

function ResizedScreenCheck()
{
	// Resize the HUD after viewport size change
	local Vector2D ViewportSize;
//	local float x0, y0, x1, y1;
	local Vector2D HudMovieSize;
	local Vector2D PositionMod;
	local Vector2D LowerLeftCorner, LowerRightCorner;

	local float RatioDiscrepancy;
	local float SizeDiscrepancy;
	local float StageWidthPct, StageHeightPct;
	local float ResizerX, ResizerY;
	local ASDisplayInfo DI;
	
	GetGameViewportClient().GetViewportSize(ViewportSize);
//	GetVisibleFrameRect(x0, y0, x1, y1);
	HudMovieSize.X = ViewportSize.X;
	HudMovieSize.Y = ViewportSize.Y;

	if(RenxHUD.GIHudMovie != None)
		RenxHUD.GIHudMovie.ResizedScreenCheck();

	if(LastResX != int(ViewportSize.X) || LastResY != int(ViewportSize.Y))
	{

//		`Log("LastRes="@LastResX@LastResY@"ViewportSize="@ViewportSize.X@ViewportSize.Y);
		LastResX = ViewportSize.X;
		LastResY = ViewportSize.Y;

		SetViewport(0,0,int(ViewportSize.X),int(ViewportSize.Y));

		SetViewScaleMode(GFxScaleMode.SM_NoBorder);
		SetAlignment(GFxAlign.Align_Center);  



 
		StageWidthPct = HudMovieSize.X/1680;
		StageHeightPct = HudMovieSize.Y/1050;

		PositionMod.X = 0;
		PositionMod.Y = 0;

//		Handepsilon : This takes AGES to figure out. I pray that it works

		RatioDiscrepancy = (HudMovieSize.X/HudMovieSize.Y) - 1.6;

		if(RatioDiscrepancy > 0) //Height is smaller than in ratio
		{
			SizeDiscrepancy = (HudMovieSize.X / 1680 * 1050) - HudMovieSize.Y;
			PositionMod.Y = SizeDiscrepancy *  840 / HudMovieSize.X;
		}
		else if(RatioDiscrepancy < 0) //Width is smaller than in ratio
		{
			SizeDiscrepancy = (HudMovieSize.Y / 1050 * 1680) - HudMovieSize.X;
			PositionMod.X = SizeDiscrepancy *  525 / HudMovieSize.Y;

		}

		// Some of these will need manual rescaling to be readable on low res, unfortunately
		ResizerX = FClamp(StageWidthPct,0.9,1);
		ResizerY = FClamp(StageHeightPct,0.9,1);

//		`log("StageWidthPct : "$StageWidthPct@"StageHeightPct : "$StageHeightPct);
//		UpperLeftCorner.X = PositionMod.X;
//		UpperLeftCorner.Y = PositionMod.Y;
//		UpperRightCorner.X = 1680 - PositionMod.X;
//		UpperRightCorner.Y = PositionMod.Y;
		LowerLeftCorner.X = PositionMod.X;
		LowerLeftCorner.Y = 1050 - PositionMod.Y;
		LowerRightCorner.X = 1680 - PositionMod.X;
		LowerRightCorner.Y = 1050 - PositionMod.Y;


//		`log("StageHeightPct :"@StageHeightPct);
//		`log("StageWidthPct :"@StageWidthPct);
		`log("PositionModX :"@PositionMod.X);
		`log("PositionModY :"@PositionMod.Y);

		DI.HasXScale = true;
		DI.HasYScale = true;

		//HealthBlock
		DI.XScale = 100.f + (100.f * (1.0 - FMin(ResizerX,ResizerY)));
		DI.YScale = DI.XScale;
//		`log("HealthBlock Scale :"@DI.XScale@DI.YScale);
		HealthBlock.SetDisplayInfo(DI);
		HealthBlock.SetPosition(LowerLeftCorner.X,LowerLeftCorner.Y);

		//Minimap
		MinimapBase.SetDisplayInfo(DI);
		MinimapBase.SetPosition(LowerLeftCorner.X,LowerLeftCorner.Y);


		//WeaponBlock		
//		DI.XScale = 100.f + (100.f * (1.0 - FMin(StageHeightPct,StageWidthPct)));
//		DI.YScale = DI.XScale;
//		`log("WeaponBlock Scale :"@DI.XScale@DI.YScale);
		WeaponBlock.SetDisplayInfo(DI);
		WeaponBlock.SetPosition(LowerRightCorner.X,LowerRightCorner.Y);
 
		DI.XScale = 100.f + (100.f * (1.0 - FMin(ResizerX,ResizerY)) / 2);
		DI.YScale = DI.XScale;
		SideMenu.SetDisplayInfo(DI);
		SideMenu.SetPosition(PositionMod.X,PositionMod.Y + 240);

//		FadeScreenMC.SetPosition(UpperLeftCorner.X,UpperLeftCorner.Y);

		//Chattos
		RadioLogMC.SetPosition(PositionMod.X + 20,PositionMod.Y + 50);
//		TeamChatLog.SetPosition((PositionMod.X * -1) + 17,(PositionMod.Y * -1) + 120);
		ChatLogMC.SetPosition(PositionMod.X + 20,600 - PositionMod.Y);
		CTextLogMC.SetPosition(440, 203 + PositionMod.Y);
		DeathLogMC.SetPosition(858 - PositionMod.X, 71 + PositionMod.Y);
		EvaLogMC.SetPosition(PositionMod.X + 20,20 + PositionMod.Y);

		VoteMC.SetPosition(840,PositionMod.Y + 40);

		Marker.SetPosition(0,0);

		
		 
		
		
		//center the icon container (nBab)
		//GetVariableObject("_root.BottomInfo").SetPosition(HudMovieSize.X * 0.3494/*0.4987*/,HudMovieSize.Y * 0.8952/*0.9586*/); (old line)
		//set position of the message box (nBab)
		GetVariableObject("_root.messagebox").SetPosition(860,722 - PositionMod.Y);
		
//		Scoreboard.SetPosition(HudMovieSize.X * 0.856,HudMovieSize.Y * 0.0327);

//		if(WeaponPickup != None)
//			WeaponPickup.SetPosition(655 ,HudMovieSize.Y * 0.5855);

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
	local int i;
	local string FullVPString; 
	local float CompassPos;
	local ASDisplayInfo CompassDI;
	local rotator PlayerRot;

	
	if (!bMovieIsOpen) {
		return;
	}
	
	if(RxPC == None)
		RxPC = Rx_Controller(GetPC());

	if(RxPC == None) 
	{
		return;
	}
	else
	{
		if(RxPRI == None)
			RxPRI = Rx_PRI(RxPC.PlayerReplicationInfo);

		if(RxGRI == None)
			RxGRI = Rx_GRI(RxPC.WorldInfo.GRI);	
	}
	// Cache everything here first
	
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
	else if(bUseTickCycle) 
		Tick_Cycler+=1;
	
	if(RxPC.Pawn != None)
		TempPawn = RxPC.Pawn;
	else if(Pawn(RxPC.viewtarget) != None)
		TempPawn = Pawn(RxPC.viewtarget);		

	//assign all 4 var here. RxP RxV, RxWeap, RxVehicleWeap
	
		if (Rx_Pawn(TempPawn) != none) 
		{
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
		} 
		else if (Rx_Vehicle(TempPawn) != none) 
		{
			RxV = Rx_Vehicle(TempPawn);
			if (RxV.Weapon != none) 
			{
				RxVWeap = Rx_Vehicle_Weapon(RxV.Weapon);
			} 
			else 
			{/*
				for (i = 0; i < RxV.Seats.Length; i++)
				 {
					if (RxV.Seats[i].Gun == none) 
					{
						continue;
					}
					RxVWeap = Rx_Vehicle_Weapon(RxV.Seats[i].Gun);
					break;
				}
				*/
				RxVWeap = None;
			}
			RxP = none;
			RxWeap = none;
		} 
		else if (Rx_VehicleSeatPawn(TempPawn) != None) 
		{
			RxV = Rx_Vehicle(Rx_VehicleSeatPawn(TempPawn).MyVehicle);
			
			if (Rx_VehicleSeatPawn(TempPawn).MyVehicleWeapon != none) {
				RxVWeap = Rx_Vehicle_Weapon(Rx_VehicleSeatPawn(TempPawn).MyVehicleWeapon);
			} /*
			else if (RxV.Weapon != none) 
			{
				RxVWeap = Rx_Vehicle_Weapon(RxV.Weapon);
			} */
			else 
			{/*
				for (i = 0; i < RxV.Seats.Length; i++) 
				{
					if (RxV.Seats[i].Gun == none) {
						lastWeaponHeld = none; 
						continue;
					}
					RxVWeap = Rx_Vehicle_Weapon(RxV.Seats[i].Gun);
					break;
				}*/
				RxVWeap = None;
			}
			RxP = none;
			RxWeap = none;
		}
	
		if(LastPawn != TempPawn)
		{
			LastPawn = TempPawn;
			bWasBound = false;
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
		if(bPlayerDead && ((RxP != none && RxP.Health > 0) || RxV != none))
		{
			bPlayerDead = false;
			SetLivingHUDVisible(true);
			if(Subtitle_Messages.Length > 0)
				Subtitle_Messages.Length = 0;

		}

		if(CompassMC != None)
		{
			PlayerRot = Rotator(Vector(RxPC.Rotation));

			while(PlayerRot.yaw < 0)
			{
				PlayerRot.yaw += 65536.f;
			}

			CompassPos = 116 - (((PlayerRot.Yaw) / 65536.f) * 512);
			if(LastCompassPos != CompassPos)
			{
				LastCompassPos = CompassPos;
				CompassDI.HasX = true;
				CompassDI.X = CompassPos;
				CompassMC.SetDisplayInfo(CompassDI);
			}
		}

	

/*		if(CurrentHarvester == None)
		{
			if(LastHarvyHealthpc >= 0)
				HarvyBars.GotoAndStopI(1);

			LastHarvyHealthpc = -1;
			LastMaxHarvyHealthpc = -1;

			CurrentHarvester = Rx_TeamInfo(RxPRI.Team).CurrentHarvester;
		}

		if(CurrentHarvester != None)
		{

			if(CurrentHarvester.GetTeamNum() != RxPC.GetTeamNum())	// if changed team, detract
				CurrentHarvester = None;
			else				
				UpdateMyHarvy();
		}
*/

		if(RxP != none && RxP.Health > 0) 
		{
/*			if (Subtitle_Messages.Length > 0)
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

			*/
			if(isInVehicle) //they were in a vehicle
			{

				HealthBlock.GotoAndStopI(1);
				WeaponBlock.GotoAndStopI(1);
				VArmorN.SetVisible(false);
				VArmorMaxN.SetVisible(false);
				isInVehicle = false;
				LastStaminapc = -1;
				LastArmorpc = -1;
				LastMaxArmorpc = -1;
				LastHealthpc = -1;
				LastMaxHealthpc = -1;
				LastVArmorpc = -1;
				LastMaxVArmorpc = -1; 
				LastArmorType = "";
				UpdateHealthGFx(,,,true);
				UpdateWeaponGFx(false, true);				
				PassengerContainer = None;
				AmmoInClipValue = -100;
				AmmoInReserveValue = -100;
				AltAmmoInClipValue = -100;
				AltAmmoInReserveValue = -100;
				LastPassengerText = "";
				bWasBound = false;
				bWasLocked = false;
			}
			
			UpdateHealth(RxP.Health , RxP.HealthMax);
			UpdateArmor(RxP.Armor , RxP.ArmorMax, Class<Rx_Familyinfo>(RxP.CurrCharClassInfo));
			//UpdateAbility(); 
			//updates that only happen on foot
			UpdateStamina(RxP.Stamina);
			//UpdateItems();
			if(RxWeap != None) 
			{
				UpdateWeapon(RxWeap);
			}
			
			if (RxAbility != none && RxAbility.bShouldBeVisible()) 
			{
				ShowAbility(true); //Make sure it's visible 
				UpdateAbility(RxAbility);
			}
			else
				ShowAbility(false); 

			//hide respawn hud (nBab)
			hideRespawnHud();
		} 
		else if(RxV != none) 
		{
/*			if (VehicleDeathMsgTime >= 0)
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
			}*/
			if(!isInVehicle) //they were on foot
			{			
				HealthBlock.GotoAndStopI(3);
				UpdateHealthGFx();
				VArmorN.SetVisible(true);
				VArmorMaxN.SetVisible(true);
				VArmorMaxN.SetText(RxV.HealthMax);
				AmmoInClipValue = -100;
				AmmoInReserveValue = -100;
				AltAmmoInClipValue = -100;
				AltAmmoInReserveValue = -100;
				//show last pawn health when in vehicle (nBab)
				UpdatePilotHealth();
				UpdatePilotArmor();

				isInVehicle = true;
				ShowAbility(false); 
			}
				
	// 		if(Rx_VehicleSeatPawn(RxPC.Pawn) != None)
	// 			RxP = Rx_Pawn(Rx_VehicleSeatPawn(RxPC.Pawn).Driver);
	// 		else
	// 			RxP = Rx_Pawn(RxV.Driver);

			//updates that only happen in vehicle
			//`log(vehiclePawn.Health);
			UpdateVehicleArmor(RxV.Health, RxV.HealthMax);
			UpdateVehicleWeapon(RxVWeap);
			UpdateVehicleSeats(RxV);
	//		if ((Rx_Vehicle_Chinook_GDI(RxV) != none || Rx_Vehicle_Chinook_Nod(RxV) != none) && RxV.Seats[RxV.GetSeatIndexForController(RxPC)].Gun == none) 
	//		{
	//			AmmoInClipN.SetText("0");
	//			AmmoBar.GotoAndStopI(0);
	//			lastWeaponHeld = none; //And somehow this not being here screwed up the entire HUD... Eh, whatever. -Yosh
	//		}
			
			
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
		} 
		else 
		{
			if(!bPlayerDead)
			{
				bPlayerDead = true;
				SetLivingHUDVisible(false);
			}

			SubtitlesText.SetVisible(true);
			UpdateHealth(0 , 100);
			UpdateArmor(0 , 100, None);
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
			if(RxGRI != None && !RxGRI.bMatchIsOver) 
			{
				Minimap.Update();	
				
			}
		}

		if (Marker != none) 
		{
			if(RxGRI != None && !RxGRI.bMatchIsOver) 
			{
				Marker.Update();	
			}
		}
		if (OverviewMapMovie != none && OverviewMapMovie.bMovieIsOpen) 
		{
			OverviewMapMovie.Update();
		}
	}

	if (Minimap != none)
	{

		if(RxGRI != None && !RxGRI.bMatchIsOver) 
		{
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

		UpdateTips();
		LastTipsUpdateTime = TempPawn.WorldInfo.TimeSeconds;
		//UpdateScoreboard();
	} 
	else if(GameplayTipsText.GetString("htmlText") != "")
	{
		GameplayTipsText.SetVisible(true);
	}	
	
	//Expirimental VP Stuff 
	if(Subtitle_Messages.Length > 0 && RxPC != none) 
	{
		for(i=Min(Subtitle_Messages.Length - 1,5);i >= 0;i--)
		{
			if(i == (Subtitle_Messages.Length -1) || i == 5) 
				FullVPString = Subtitle_Messages[i].Message;
			else				
				FullVPString = Subtitle_Messages[i].Message$"<br>"$FullVPString;
		}
		if(FullVPString != LastVPString)
		{
			LastVPString = FullVPString;
			SubtitlesText.SetString("htmlText", FullVPString);
			SubtitlesText.SetVisible(true);
			if(TempPawn != None)
				hideRespawnHud();
		}
	}
		
	if(Subtitle_Messages.Length > 0) 
	{	
		for(i = 0;i<Subtitle_Messages.Length; i++)
		{
			Subtitle_Messages[i].Lifetime -= 0.5;

			if(Subtitle_Messages[i].Lifetime <= 0)
			{
				Subtitle_Messages.RemoveItem(Subtitle_Messages[i]);
			}

		}
	}
	if(Subtitle_Messages.Length <= 0 && LastVPString != "")
	{
		LastVPString = "";
		SubtitlesText.SetString("htmlText", "");
	}

	//End Expirement 


	
	if((bUseTickCycle && Tick_Cycler == 2) || !bUseTickCycle ) //Things that don't need to be updated that regularly
	{


		//update veterancy (nBab)
		updateVeterancy();
	}
	//update respawn ui
	if (GetPC().GetTeamNum() != lastTeam)
	{
		updateRespawnUI(GetPC().GetTeamNum());
		lastTeam = GetPC().GetTeamNum();
	}

	if(SideMenu.GetBool("visible"))
		ChatLogMC.SetVisible(false);
	else
		ChatLogMC.SetVisible(true);


}

function UpdateTips()
{
	local Rx_ObjectTooltipInterface OT;
	local string bindKey;
	local string jumpKey;
	local string tooltip;
	local Actor act;
	local UTVehicle veh;

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
			GameplayTipsText.SetVisible(true);
			GameplayTipsText.SetString("htmlText", "Vehicle Airdrop Available");
			return;
		}
	}	
	
	if (Rx_Pawn(RxPC.Pawn) != none) 
	{
		
		if (Rx_Pawn(RxPC.Pawn).CanParachute() && RenxHud.ShowBasicTips)
		{
			GameplayTipsText.SetVisible(true);
			GameplayTipsText.SetString("htmlText", "Press <font color='#ff0000' size='20'>[ " $ jumpKey $ " ]</font> to open parachute. " );
			return;
		}
		
		veh = RxPC.GetVehicleToDrive(false);
		if (veh != none) 
		{
			if (Rx_Vehicle_Harvester(veh) == none && Rx_Defence(veh) == none && (!veh.bDriving || (Rx_Vehicle_Air(veh) != None && Rx_Vehicle_Air(veh).AnySeatAvailable()) || Rx_VehRolloutController(veh.Controller) != None)) 
			{
				GameplayTipsText.SetVisible(true);
				GameplayTipsText.SetString("htmlText", "Press <font color='#ff0000' size='20'>[ " $ bindKey $ " ]</font> to enter " $ Caps(veh.GetHumanReadableName()));
			}
		} 
		else 
		{
			if (GameplayTipsText.GetText() != "") 
			{
				GameplayTipsText.SetString("htmlText", "");
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
		if(RxPC.Pawn != None)
			hideRespawnHud();
	}
}

exec function SetLivingHUDVisible(bool visible)
{
	//ObjectiveMC.SetVisible(visible);
	MinimapBase.SetVisible(visible);
	Marker.SetVisible(visible);
	HealthBlock.SetVisible(visible);
	WeaponBlock.SetVisible(visible);
	WeaponTipsMaster.SetVisible(visible);
}
exec function InitializeHUDVars() 
{
	// Grease:	When you have two frames, and an object in each frame with the same name,
	//			the variables HAVE to be updated, otherwise it will only change the object
	//			from frame 1, even if you're in frame 2.

	// Shahman: in UT (GFxMinimapHud), what epic did is to call the GFxMoviePlayer's gotoandstop function and reupdate.

	// Handepsilon: Ok, whoever has the idea of reassigning ALL gfxobject for each necessary update needs some spanking.

	//Items
//	GrenadeMC       = WeaponBlock.GetObject("Grenade");
//	GrenadeN        = WeaponBlock.GetObject("Grenade.Icon.TextField");
//	TimedC4MC       = WeaponBlock.GetObject("TimedC4");
//	RemoteC4MC      = WeaponBlock.GetObject("RemoteC4");
//	ProxyC4MC       = WeaponBlock.GetObject("ProxyC4");
//	BeaconMC        = WeaponBlock.GetObject("Beacon");
	UpdateHealthGFx(,,,true);
	UpdateWeaponGFx(false, true);
	UpdateVeterancyGFx(true);

//	HarvyHealthContainer = StatsMC.GetObject("HarvyCont");
//	HarvyBars = HarvyHealthContainer.GetObject("HarvyHealth");

	VoteMC = GetVariableObject("_root.VoteTextBase");

	//Progress Bar
	UpdateLoadingBar();

	HideLoadingBar();
//---------------------------------------------------
	//Radar implementation
	if (Minimap == none)
	{
		MinimapBase = GetVariableObject("_root.minimapBase");
		CompassMC = MinimapBase.GetObject("CompassMC");
		Minimap = Rx_GFxMinimap(GetVariableObject("_root.minimapBase.minimap", class'Rx_GFxMinimap'));
		Minimap.init(self);
	}

	if (Marker == none) {
		Marker = Rx_GFxMarker(GetVariableObject("_root.MarkerContainer", class'Rx_GFxMarker'));
		Marker.init(self);
	}
}

function UpdateHealthGFx(optional bool bSkipHealth, optional bool bSkipArmor, optional bool bSkipStamina, optional bool bSkipVehicle)
{

	if(!bSkipHealth)
	{
		HealthBlock     = GetVariableObject("_root.HealthBlock");

		//Health
		HealthText      = HealthBlock.GetObject("HealthText");
		HealthBar       = HealthBlock.GetObject("Health");
		HealthN         = HealthText.GetObject("HealthN");
		HealthMaxN      = HealthText.GetObject("HealthMaxN");
	}


	if(!bSkipArmor)
	{
		//Armor
		ArmorBar        = HealthBlock.GetObject("Armor");
		ArmorN          = HealthBlock.GetObject("ArmorN");
		ArmorMaxN       = HealthBlock.GetObject("ArmorMaxN");
		ArmorText		= HealthBlock.GetObject("ArmorText");
		
	}

	//Stamina
	if(!bSkipStamina)
		StaminaBar      = GetVariableObject("_root.HealthBlock.stamina.stam_bar.bar");

	if(!bSkipVehicle)
	{
	//Vehicle
		VArmorText		= HealthBlock.GetObject("VehicleText");
		VArmorN         = VArmorText.GetObject("VehicleN");
		VArmorMaxN      = VArmorText.GetObject("VehicleMaxN");
		
		VArmorBar       = HealthBlock.GetObject("HealthVehicle");
	}

}

function UpdateWeaponGFx(bool bUsesMultiWeapon, bool bUpdateAbility)
{

	local int i;
	local Pawn MyPawn;

	// WEAPON SYSTEM
	if(WeaponBlock == None)
	{
		WeaponBlock     = GetVariableObject("_root.WeaponBlock");
	}

	WeaponName      = WeaponBlock.GetObject("WeaponName");
	AmmoInClipN     = WeaponBlock.GetObject("AmmoInClipN");
	AmmoReserveN    = WeaponBlock.GetObject("AmmoReserveN");
	AmmoBar         = WeaponBlock.GetObject("AmmoBar");	


	//Weapon and Ammo


	MyPawn = GetPC().Pawn;

		

	if(WeaponMC[0] == None)
	{
		WeaponListContainer = WeaponBlock.GetObject("WeaponList");

		for(i=0; i < 5; i++)
		{
			WeaponMC[i] = WeaponListContainer.GetObject("Weapon"$i+1);
		}
	}

	if(Vehicle(MyPawn) == None)
	{

		for(i=0; i < 5; i++)
		{	
			WeaponMC[i].SetVisible(true);
		}	

		if(bUpdateAbility)
		{
			AbilityMC = WeaponBlock.GetObject("Ability");
			AbilityTextMC = WeaponBlock.GetObject("AbilityText");

			AbilityMeterMC = AbilityMC.GetObject("Meter");
			AbilityIconMC = AbilityMC.GetObject("Icon");
		}

		InfinitAmmo     = WeaponBlock.GetObject("Infinity");
	}
	else
	{
		for(i=0; i < 5; i++)
		{	
			WeaponMC[i].SetVisible(false);
		}	

		LockMC = WeaponBlock.GetObject("Lock");
		AbilityTextMC = WeaponBlock.GetObject("AbilityText");

		LockMC.SetVisible(false);
		AbilityTextMC.SetVisible(false);

		if(bUsesMultiWeapon)
		{
			AltWeaponName   = WeaponBlock.GetObject("AltWeaponName");
			AltAmmoInClipN  = WeaponBlock.GetObject("AltAmmoInClipN");
//			AltInfinitAmmo  = WeaponBlock.GetObject("AltInfinity");
			AltAmmoBar      = WeaponBlock.GetObject("AltAmmoBar");
		}
	}

}

function UpdateVeterancyGFx(bool bInitial)
{
	if(bInitial)
	{
		VeterancyContainer = HealthBlock.GetObject("vet"); //'vet'
		VeterancyLabel = VeterancyContainer.GetObject("vet_tf"); //'vet_tf'
		
		VeterancyIcon = VeterancyContainer.GetObject("vet_icon");
		
		VeterancyBar = GetVariableObject("_root.HealthBlock.vet.vet_bar.bar");		
	}

	VeterancyIconCurrent = VeterancyIcon.GetObject("vet_icon_current");
	VeterancyIconNext = VeterancyIcon.GetObject("vet_icon_next");

}

function UpdateLoadingBar()
{
	LoadingMeterMC[0] = GetVariableObject("_root.loadingMeterGDI");
	LoadingText[0] = LoadingMeterMC[0].GetObject("loadingText");
	LoadingBarWidget[0] = GFxClikWidget(LoadingMeterMC[0].GetObject("bar", class'GFxClikWidget'));
	LoadingMeterMC[1] = GetVariableObject("_root.loadingMeterNod");
	LoadingText[1] = LoadingMeterMC[1].GetObject("loadingText");
	LoadingBarWidget[1] = GFxClikWidget(LoadingMeterMC[1].GetObject("bar", class'GFxClikWidget'));

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
		case EMT_CText:
			FreeCTextMessages.AddItem(mrow);
			break;
		case EMT_Radio:
			FreeRadioMessages.AddItem(mrow);
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
		case EMT_CText:
			return CTextLogMC.AttachMovie("logMessage", "CTextMessage"$NumMessages++);
		case EMT_Radio:
			return RadioLogMC.AttachMovie("logMessage", "RadioMessage"$NumMessages++);
		case EMT_Death:
			return DeathLogMC.AttachMovie("logMessage", "DeathMessage"$NumMessages++);
	}
}

function UpdateHealth(int currentHealth, int maxHealth)
{
	
	local ASColorTransform ColorTransform;
	//Update health if it is required
	//if (LastHealthpc != currentHealth || HealthN.GetText() != string(currentHealth)) {
	
	if(LastHealthpc == currentHealth)
		return;

		//update current health, text, and bar
		LastHealthpc = currentHealth;
		HealthBar.GotoAndStopI(float(currentHealth) / float(maxHealth) * 100 + 1);

		if (currentHealth < 25) 
		{
			ColorTransform.multiply.R = 1.0;
			ColorTransform.multiply.G = 0.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.0;
			ColorTransform.add.G = 0.0;
			ColorTransform.add.B = 0.0;
		} 
		else if (currentHealth < 62) 
		{
			ColorTransform.multiply.R = 1.f;
			ColorTransform.multiply.G = 1.f;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.f;
			ColorTransform.add.G = 0.f;
			ColorTransform.add.B = 0.f;
		} 
		else 
		{
			ColorTransform.multiply.R = 0.0;
			ColorTransform.multiply.G = 1.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.0;
			ColorTransform.add.G = 0.0;
			ColorTransform.add.B = 0.0;
		}
		if(HealthText != None)
		{
			HealthBar.SetColorTransform(ColorTransform);
			HealthText.SetColorTransform(ColorTransform);
		}

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

		LastMaxHealthpc = maxHealth;
	}
}

function UpdateVehicleArmor(int currentArmor, int maxArmor)
{
	//update armor if it is required
	//if (LastVArmorpc != currentArmor || VArmorN.GetText() != string(currentArmor)) {
		local ASColorTransform ColorTransform;		
		//update current health, text, and bar
		if(LastVArmorpc != currentArmor)
		{
			LastVArmorpc = currentArmor;
			VArmorBar.GotoAndStopI(float(currentArmor) / float(maxArmor) * 100);
			VArmorN.SetText(currentArmor);


			if (currentArmor < (maxArmor* 0.25) )
			{
				ColorTransform.multiply.R = 1.0;
				ColorTransform.multiply.G = 0.0;
				ColorTransform.multiply.B = 0.0;
				ColorTransform.add.R = 0.0;
				ColorTransform.add.G = 0.0;
				ColorTransform.add.B = 0.0;
			} 
			else if (currentArmor < (maxArmor* 0.5) )
			{
				ColorTransform.multiply.R = 1.f;
				ColorTransform.multiply.G = 1.f;
				ColorTransform.multiply.B = 0.0;
				ColorTransform.add.R = 0.f;
				ColorTransform.add.G = 0.f;
				ColorTransform.add.B = 0.0; 
			} 
			else 
			{
				ColorTransform.multiply.R = 0.0;
				ColorTransform.multiply.G = 1.0;
				ColorTransform.multiply.B = 0.0;
				ColorTransform.add.R = 0.0;
				ColorTransform.add.G = 0.0;
				ColorTransform.add.B = 0.0;
			}

			VArmorBar.SetColorTransform(ColorTransform);
			VArmorText.SetColorTransform(ColorTransform);
		}
		

		if (VArmorMaxN != None && LastMaxVArmorpc != maxArmor)
		{
			LastMaxVArmorpc = maxArmor;
			VArmorMaxN.SetText(maxArmor);
		}
	//}
}

function UpdateArmor(int currentArmor, int maxArmor, class<Rx_Familyinfo> FamInfo)
{
	local String CurrentArmorType;
	//update armor if it is required
	//if (LastArmorpc != currentArmor || ArmorN.GetText() != string(currentArmor)) {
		
	if(LastArmorpc != currentArmor)
	{
		//update current health, text, and bar
		LastArmorpc = currentArmor;
		ArmorBar.GotoAndStopI(float(currentArmor) / float(maxArmor) * 100);
		ArmorN.SetText(currentArmor);
	//}
	}

	//if (ArmorMaxN != None && ArmorMaxN.GetText() != string(maxArmor)){
	if (ArmorMaxN != None && maxArmor != LastMaxArmorpc)
	{
		LastMaxArmorpc = maxArmor;
		ArmorMaxN.SetText(maxArmor);
	}

	if(FamInfo == None)
	{
		CurrentArmorType = "UNKNOWN";
	}
	else
	{
		Switch(FamInfo.default.armor_type)
		{
			case A_Kevlar:
				CurrentArmorType = "KEVLAR";
				break;

			case A_FLAK:
				CurrentArmorType = "FLAK";
				break;

			case A_Lazarus:
				CurrentArmorType = "LAZARUS";
				break;

			default:
				CurrentArmorType = "LIGHT";
				break;

		}
	}		

	if(LastArmorType != CurrentArmorType)
	{
		LastArmorType = CurrentArmorType;
		ArmorText.SetText(CurrentArmorType);
	}
}

/*
function UpdateMyHarvy()
{
	local float HarvyHealthPercent;
	local ASColorTransform ColorTransform;

	if(CurrentHarvester == None)
		return;

	if(CurrentHarvester.HealthMax != LastMaxHarvyHealthpc)
	{
		LastMaxHarvyHealthpc = CurrentHarvester.HealthMax;
	}
	if(CurrentHarvester.Health != LastHarvyHealthpc)
	{
		LastHarvyHealthpc = CurrentHarvester.Health;
		HarvyHealthPercent = LastHarvyHealthpc / LastMaxHarvyHealthpc * 100;
		HarvyBars.GotoAndStopI(Max(int(HarvyHealthPercent),2));
		if (LastHealthpc < 25) 
		{
			ColorTransform.multiply.R = 0.0;
			ColorTransform.multiply.G = 0.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 1.0;
			ColorTransform.add.G = 0.0;
			ColorTransform.add.B = 0.0;
		} 
		else if (LastHealthpc < 62) 
		{
			ColorTransform.multiply.R = 0.0;
			ColorTransform.multiply.G = 0.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.8;
			ColorTransform.add.G = 0.7;
			ColorTransform.add.B = 0.0;
		} 
		else 
		{
			ColorTransform.multiply.R = 0.0;
			ColorTransform.multiply.G = 1.0;
			ColorTransform.multiply.B = 0.0;
			ColorTransform.add.R = 0.0;
			ColorTransform.add.G = 0.0;
			ColorTransform.add.B = 0.0;
		}
		HarvyBars.SetColorTransform(ColorTransform);
	}


}
*/
// since Rx_Pawn no longer exists when piloting vehicle, take from last values

function UpdatePilotHealth()
{
	local ASColorTransform ColorTransform;

	if(HealthBar != None)
		HealthBar.GotoAndStopI(float(LastHealthpc) / float(LastmaxHealthpc) * 100 + 1);

	if (LastHealthpc < 25) 
	{
		ColorTransform.multiply.R = 1.0;
		ColorTransform.multiply.G = 0.0;
		ColorTransform.multiply.B = 0.0;
		ColorTransform.add.R = 0.0;
		ColorTransform.add.G = 0.0;
		ColorTransform.add.B = 0.0;
		ColorTransform.add.A = 0.0;
	} 
	else if (LastHealthpc < 62) 
	{
		ColorTransform.multiply.R = 1.0;
		ColorTransform.multiply.G = 1.0;
		ColorTransform.multiply.B = 0.0;
		ColorTransform.add.R = 0.0;
		ColorTransform.add.G = 0.0;
		ColorTransform.add.B = 0.0;
		ColorTransform.add.A = 0.0;
	} 
	else 
	{
		ColorTransform.multiply.R = 0.0;
		ColorTransform.multiply.G = 1.0;
		ColorTransform.multiply.B = 0.0;
		ColorTransform.add.R = 0.0;
		ColorTransform.add.G = 0.0;
		ColorTransform.add.B = 0.0;
		ColorTransform.add.A = 0.0;
	}
	
	if(HealthText != None)
	{
		HealthBar.SetColorTransform(ColorTransform);
		HealthText.SetColorTransform(ColorTransform);
	}

	if(HealthN != None)
		HealthN.SetText(LastHealthpc);

	if (HealthMaxN != None)
	{
		if (LastmaxHealthpc>100)
			HealthMaxN.SetText("100+"$(LastmaxHealthpc-100));
		else
			HealthMaxN.SetText(LastmaxHealthpc);
	}
}

function UpdatePilotArmor()
{
	if(ArmorBar != None)
		ArmorBar.GoToAndStopI(float(LastArmorpc) / float(LastMaxArmorpc) * 100);

	if(ArmorN != None)
		ArmorN.SetText(LastArmorpc);

	if(ArmorMaxN != None)
		ArmorMaxN.SetText(LastMaxArmorpc);

	if(ArmorText != None)
		ArmorText.SetText(LastArmorType);
}

function UpdateStamina(int currentStamina)
{
	//update stamina if it is required
	//if (LastStaminapc != currentStamina) {
	
		//update current health, text, and bar
		if(LastStaminapc == currentStamina)
			return;

		LastStaminapc = currentStamina;
		if(StaminaBar != None)
			StaminaBar.GotoAndStopI(currentStamina);

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
			AbilityMeterMC.GotoAndStopI(ability.GetRechargeTiming() * 51);
			
			if(!ability.bCanBeSelected()) 
				AbilityIconMC.SetFloat("alpha", 0.5);
			else
				AbilityIconMC.SetFloat("alpha", 1);
				
		} 
		else
		{
			//not a single charge
			AbilityMeterMC.GotoAndStopI(ability.GetRechargeTiming() * 51);
		}
		if(ability.bCanBeSelected() || Rx_Pawn(GetPC().Pawn).Weapon == ability)
		{
			AbilityTextMC.SetText("ABILITY[" $ string( AbilityKey ) $ "]"); 
		}
		else
		{
			AbilityTextMC.SetText(FCeil(ability.RechargeRate - ability.GetRechargeRealTime())$"s");
		}
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
	local Rx_Weapon_Reloadable Weapon_R; 
	local Rx_WeaponAbility WeaponAbility;
	local int i;
	local Rx_Weapon W;
	local string WeaponTipsString, SecWeaponTipsString;
	local LinearColor TempColor;
	local ASColorTransform WeaponTipsColor, SecWeaponTipsColor;
	local ASDisplayInfo DI, WTDI;
	local bool bReachedWeaponLoop;
	local ASColorTransform CT;
	local float TipsXScaleActual;
	//we dont want to set visible every tick, so we have this extra IF
	if(weapon != lastWeaponHeld) 
	{
		HideLoadingBar(); // because the beacon/airstrike is destroyed before it can hide the loading bar, we hide it here

		AmmoInClipValue = -100;
		AmmoInReserveValue = -100;

		//This is for mods/mutators. This allows creators of new weapons to set names without having to do a custom version of this function
		if(Rx_Weapon(weapon).CustomWeaponName != "")
			WeaponName.SetText(caps(Rx_Weapon(weapon).CustomWeaponName));
		else
			WeaponName.SetText(caps(weapon.ItemName));

		DI.HasY = true;


		if(WeaponName.GetInt("numLines") > 1)
		{
			WeaponName.SetPosition(-143.5,-90.0);
			DI.Y = -317.f;
		}
		else
		{
			WeaponName.SetPosition(-143.5,-75.f);
			DI.Y = -302.f;
		}
		WeaponListContainer.SetDisplayInfo(DI);

		if(Rx_Weapon(weapon).HasInfiniteAmmo()) 
		{
			AmmoReserveN.SetVisible(false);
			InfinitAmmo.SetVisible(true);
		} else 
		{
			AmmoReserveN.SetVisible(true);
			InfinitAmmo.SetVisible(false);
		}

		//now we update the images of the weapons held
		lastWeaponHeld = weapon;

		//CHANGE WEAPON HERE

//		LoadTexture(Rx_Weapon(weapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(weapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponMC[0]);

		LoadTexture(Rx_Weapon(weapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(weapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponMC[0]);

		if((Rx_Weapon_Reloadable(weapon) != None && (Rx_Weapon_Reloadable(weapon).HasAnyAmmoOfType(0) || Rx_Weapon_Reloadable(weapon).bHasInfiniteAmmo )) || Weapon.HasAnyAmmo())
		{
			CT.Multiply.R = 1.f;
			CT.Multiply.G = 1.f;
			CT.Multiply.B = 1.f;
			CT.Add.R = 0.f;
			CT.Add.G = 0.f;
			CT.Add.B = 0.f;
		}
		else
		{
			CT.Multiply.R = 1.f;
			CT.Multiply.G = 1.f;
			CT.Multiply.B = 0.75;
			CT.Add.R = 0.4;
			CT.Add.G = 0.4;
			CT.Add.B = 0.4;
		}
		CT.Add.A = 0.f;

		WeaponMC[0].SetColorTransform(CT);

		for(i = 0;i < 4; i++)
		{
			W = Rx_Weapon(RxPC.GetWeapon((i+1) * -1));
			if(W != None && !bReachedWeaponLoop)
			{
				if(W == weapon || (i != 0 && W == Rx_Weapon(RxPC.GetWeapon(-1))))
				{
					bReachedWeaponLoop = true;
					WeaponMC[i+1].SetVisible(false);
				}
				else
				{
					WeaponMC[i+1].SetVisible(true);
					LoadTexture(W.WeaponIconTexture != none ? "img://" $ PathName(W.WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponMC[i+1]);
					if((Rx_Weapon_Reloadable(W) != None && (Rx_Weapon_Reloadable(W).HasAnyAmmoOfType(0) || Rx_Weapon_Reloadable(W).bHasInfiniteAmmo )) || W.HasAnyAmmo())
					{
						CT.Multiply.R = 1.f;
						CT.Multiply.G = 1.f;
						CT.Multiply.B = 1.f;
						CT.Add.R = 0.f;
						CT.Add.G = 0.f;
						CT.Add.B = 0.f;
					}
					else
					{
						CT.Multiply.R = 1.f;
						CT.Multiply.G = 1.f;
						CT.Multiply.B = 0.75;
						CT.Add.R = 0.4;
						CT.Add.G = 0.4;
						CT.Add.B = 0.4;
					}

					CT.Multiply.A = WeaponMCAlpha[i];
					WeaponMC[i+1].SetColorTransform(CT);
				}
			} 
			else 
			{
				WeaponMC[i+1].SetVisible(false);
			}
		}
	}
	if(Rx_Weapon(Weapon) != None && !HasAdminMessage())
	{
		W = Rx_Weapon(weapon);

		WeaponTipsString = W.GetWeaponTips();
		TempColor = W.GetTipsColor();
		WeaponTipsColor.Multiply.R = TempColor.R;
		WeaponTipsColor.Multiply.G = TempColor.G;
		WeaponTipsColor.Multiply.B = TempColor.B;
		WeaponTipsColor.Multiply.A = TempColor.A; 

		SecWeaponTipsString = W.GetWeaponSecondaryTips();
		TempColor = W.GetSecondTipsColor();

		SecWeaponTipsColor.Multiply.R = TempColor.R;
		SecWeaponTipsColor.Multiply.G = TempColor.G;
		SecWeaponTipsColor.Multiply.B = TempColor.B;
		SecWeaponTipsColor.Multiply.A = TempColor.A;
	}
	else
	{
		WeaponTipsString = "";
		WeaponTipsColor.Multiply.R = 1.0;
		WeaponTipsColor.Multiply.G = 1.0;
		WeaponTipsColor.Multiply.B = 1.0;
		WeaponTipsColor.Multiply.A = 1.0;

		SecWeaponTipsString = "";
		SecWeaponTipsColor.Multiply.R = 1.0;
		SecWeaponTipsColor.Multiply.G = 1.0;
		SecWeaponTipsColor.Multiply.B = 1.0;
		SecWeaponTipsColor.Multiply.A = 1.0;	
	}

	WeaponTipsColor.Add.A = 0.0;
	SecWeaponTipsColor.Add.A = 0.0;

	if(WeaponTipsString != LastWeaponTips)
	{
		WeaponTipsText.SetText(WeaponTipsString);

		if(WeaponTipsString == "")
		{
			WeaponTips.SetVisible(false);
		}	
		else	
		{
			if(LastWeaponTips == "")
				WeaponTips.SetVisible(true);

			WTDI.HasXScale = true;
			WTDI.HasX = true;
			TipsXScaleActual = 25.6 * Len(WeaponTipsString);
			WTDI.XScale = TipsXScaleActual / 256 * 100;
			WTDI.X = TipsXScaleActual * -1 / 2;
			WeaponTipsBKG.SetDisplayInfo(WTDI);
		}
		LastWeaponTips = WeaponTipsString;
	}
	if(WeaponTipsColor != LastWeaponTipsColor)
	{
		LastWeaponTipsColor = WeaponTipsColor;
		WeaponTips.SetColorTransform(LastWeaponTipsColor);
	}

	if(SecWeaponTipsString != LastSecWeaponTips)
	{
		SecWeaponTipsText.SetText(SecWeaponTipsString);

		if(SecWeaponTipsString == "")
		{
			SecWeaponTips.SetVisible(false);
		}	
		else	
		{
			if(LastSecWeaponTips == "")
				SecWeaponTips.SetVisible(true);

			WTDI.HasXScale = true;
			WTDI.HasX = true;
			TipsXScaleActual = 25.6 * Len(SecWeaponTipsString);
			WTDI.XScale = TipsXScaleActual / 256 * 100;
			WTDI.X = TipsXScaleActual * -1 / 2;
			SecWeaponTipsBKG.SetDisplayInfo(WTDI);
		}
		LastSecWeaponTips = SecWeaponTipsString;
	}
	if(SecWeaponTipsColor != LastSecWeaponTipsColor)
	{
		LastSecWeaponTipsColor = SecWeaponTipsColor;
		SecWeaponTips.SetColorTransform(LastSecWeaponTipsColor);
	}

	if(Rx_Weapon_Reloadable(weapon) != None) 
	{
		Weapon_R = Rx_Weapon_Reloadable(weapon);
		//Update ammo counts
		if(weapon != lastWeaponHeld || AmmoInClipValue != Weapon_R.GetUseableAmmo()) 
		{
			AmmoInClipValue = Weapon_R.GetUseableAmmo();
			AmmoInClipN.SetText(AmmoInClipValue);
			AmmoBar.GotoAndStopI(float(AmmoInClipValue) / float(Weapon_R.GetMaxAmmoInClip()) * 100);
		}
		//Update reserve ammo counts
		if( AmmoInReserveValue != Weapon_R.GetReserveAmmo()) 
		{
			AmmoInReserveValue = Weapon_R.GetReserveAmmo();
			AmmoReserveN.SetText(AmmoInReserveValue);
		}
		if(weapon == lastWeaponHeld && (Weapon_R.GetReserveAmmo() + Weapon_R.GetUseableAmmo()) <= 0)
		{
			CT.Multiply.R = 1.f;
			CT.Multiply.G = 1.f;
			CT.Multiply.B = 0.75;
			CT.Add.R = 0.4;
			CT.Add.G = 0.4;
			CT.Add.B = 0.4;			
			
			WeaponMC[0].SetColorTransform(CT);		
		}

		//realod weapon animation
		if(Weapon_R != None && Weapon_R.CurrentlyReloading && !Weapon_R.PerBulletReload) 
		{	
			AnimateReload(weapon.WorldInfo.TimeSeconds - Weapon_R.reloadBeginTime, Weapon_R.currentReloadTime, AmmoBar);		
		}
	}

	if(Rx_WeaponAbility(weapon) != None) {
		WeaponAbility = Rx_WeaponAbility(weapon);
		//Update ammo counts
		if(weapon != lastWeaponHeld || AmmoInClipValue != WeaponAbility.CurrentCharges) 
		{
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
}

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
	local string WeaponTipsString, SecWeaponTipsString;
	local LinearColor TempColor;
	local ASColorTransform WeaponTipsColor, SecWeaponTipsColor;
	local ASDisplayInfo WTDI;
	local float TipsXScaleActual;
//	if(weapon == None) {
//		VehicleMC.SetVisible(false);
//		//`log ("<GFxHUD Log> GetPC().Pawn? " $ GetPC().Pawn);
//		return;
//	}
	//UpdateHUDVars();

	if(weapon != lastWeaponHeld) 
	{ //this is a new weapon
		WeaponBlock.GotoAndStopI((Rx_Vehicle_MultiWeapon(weapon) != None) ? 4 : 3);


		lastWeaponHeld = weapon;

//		VehicleMC.SetVisible(true);
		
		//VehicleMC.GotoAndStopI(weapon.InventoryGroup);
		//LoadTexture(Rx_Vehicle(weapon.MyVehicle).VehicleIconTexture != none ? "img://" $ PathName(Rx_Vehicle(weapon.MyVehicle).VehicleIconTexture) : PathName(Texture2D'RenxHud.T_VehicleIcon_MissingCameo'), VehicleMC);
		
		AmmoInClipValue = -100;
		AltAmmoInClipValue = -100;

		UpdateWeaponGFx((Rx_Vehicle_MultiWeapon(weapon) != none), false);
		
		PassengerContainer = None; // just a precaution if we end up changing frame
		
		// This block on bottom because when there is a multiweapon equipped,
		// it changes frames, and relocates the objects, after that its time to set vars.
		if(weapon != None)
			WeaponName.SetText(caps(weapon.ItemName));
		else
			WeaponName.SetText("UNARMED");

//		if(AmmoReserveN != None) {
//			AmmoReserveN.SetVisible(false);
//		}
//		if(InfinitAmmo != None) {
//			InfinitAmmo.SetVisible(true);
//		}
	}

	if(Weapon != None && !HasAdminMessage())
	{


		WeaponTipsString = Weapon.GetWeaponTips();
		TempColor = Weapon.GetTipsColor();
		WeaponTipsColor.Multiply.R = TempColor.R;
		WeaponTipsColor.Multiply.G = TempColor.G;
		WeaponTipsColor.Multiply.B = TempColor.B;
		WeaponTipsColor.Multiply.A = TempColor.A; 

		SecWeaponTipsString = Weapon.GetWeaponSecondaryTips();
		TempColor = Weapon.GetSecondTipsColor();

		SecWeaponTipsColor.Multiply.R = TempColor.R;
		SecWeaponTipsColor.Multiply.G = TempColor.G;
		SecWeaponTipsColor.Multiply.B = TempColor.B;
		SecWeaponTipsColor.Multiply.A = TempColor.A;
	}
	else
	{
		WeaponTipsString = "";
		WeaponTipsColor.Multiply.R = 1.0;
		WeaponTipsColor.Multiply.G = 1.0;
		WeaponTipsColor.Multiply.B = 1.0;
		WeaponTipsColor.Multiply.A = 1.0;

		SecWeaponTipsString = "";
		SecWeaponTipsColor.Multiply.R = 1.0;
		SecWeaponTipsColor.Multiply.G = 1.0;
		SecWeaponTipsColor.Multiply.B = 1.0;
		SecWeaponTipsColor.Multiply.A = 1.0;	
	}

	WeaponTipsColor.Add.A = 0.0;
	SecWeaponTipsColor.Add.A = 0.0;

	if(WeaponTipsString != LastWeaponTips)
	{
		WeaponTipsText.SetText(WeaponTipsString);

		if(WeaponTipsString == "")
		{
			WeaponTips.SetVisible(false);
		}	
		else	
		{
			if(LastWeaponTips == "")
				WeaponTips.SetVisible(true);

			WTDI.HasXScale = true;
			WTDI.HasX = true;
			TipsXScaleActual = 25.6 * Len(WeaponTipsString);
			WTDI.XScale = TipsXScaleActual / 256 * 100;
			WTDI.X = TipsXScaleActual * -1 / 2;
			WeaponTipsBKG.SetDisplayInfo(WTDI);
		}
		LastWeaponTips = WeaponTipsString;
	}
	if(WeaponTipsColor != LastWeaponTipsColor)
	{
		LastWeaponTipsColor = WeaponTipsColor;
		WeaponTips.SetColorTransform(LastWeaponTipsColor);
	}

	if(SecWeaponTipsString != LastSecWeaponTips)
	{
		SecWeaponTipsText.SetText(SecWeaponTipsString);

		if(SecWeaponTipsString == "")
		{
			SecWeaponTips.SetVisible(false);
		}	
		else	
		{
			if(LastSecWeaponTips == "")
				SecWeaponTips.SetVisible(true);

			WTDI.HasXScale = true;
			WTDI.HasX = true;
			TipsXScaleActual = 25.6 * Len(SecWeaponTipsString);
			WTDI.XScale = TipsXScaleActual / 256 * 100;
			WTDI.X = TipsXScaleActual * -1 / 2;
			SecWeaponTipsBKG.SetDisplayInfo(WTDI);
		}
		LastSecWeaponTips = SecWeaponTipsString;
	}
	if(SecWeaponTipsColor != LastSecWeaponTipsColor)
	{
		LastSecWeaponTipsColor = SecWeaponTipsColor;
		SecWeaponTips.SetColorTransform(LastSecWeaponTipsColor);
	}
	//Update ammo counts
	if( weapon != None) 
	{ //AmmoInClipValue != weapon.GetUseableAmmo()

		if(AmmoInClipValue != weapon.GetUseableAmmo())
		{
			AmmoInClipValue = weapon.GetUseableAmmo();
			AmmoInClipN.SetText(AmmoInClipValue);
			AmmoBar.GotoAndStopI(float(AmmoInClipValue) / float(weapon.GetMaxAmmoInClip()) * 100);
		}
	}
	else
	{
		if(AmmoInClipValue != 0)
		{
			AmmoInClipValue = 0;
			AmmoInClipN.SetText("---");
			AmmoBar.GotoAndStopI(1);
		}		
	}
	if( Rx_Vehicle_MultiWeapon(weapon) != none ) 
	{ //&& AltAmmoInClipValue != Rx_Vehicle_MultiWeapon(weapon).GetAltUseableAmmo()
		
		AltWeaponName.SetText(caps(Rx_Vehicle_MultiWeapon(weapon).AltItemName));		
		AltAmmoInClipN.SetText(AltAmmoInClipValue);
		if(AltAmmoInClipValue != Rx_Vehicle_MultiWeapon(weapon).GetAltUseableAmmo())
		{
			AltAmmoInClipValue = Rx_Vehicle_MultiWeapon(weapon).GetAltUseableAmmo();
			AltAmmoBar.GotoAndStopI(float(AltAmmoInClipValue) / float(Rx_Vehicle_MultiWeapon(weapon).GetMaxAltAmmoInClip()) * 100);
		}
	}
	
	//animate reload
	if( Rx_Vehicle_MultiWeapon(weapon) != none) 
	{
		if(Rx_Vehicle_MultiWeapon(weapon).PrimaryReloading) 
		{
			AnimateReload(weapon.WorldInfo.TimeSeconds - Rx_Vehicle_MultiWeapon(weapon).primaryReloadBeginTime, Rx_Vehicle_MultiWeapon(weapon).currentPrimaryReloadTime, AmmoBar);
		}
		if(Rx_Vehicle_MultiWeapon(weapon).SecondaryReloading) 
		{
			AnimateReload(weapon.WorldInfo.TimeSeconds - Rx_Vehicle_MultiWeapon(weapon).secondaryReloadBeginTime, Rx_Vehicle_MultiWeapon(weapon).currentSecondaryReloadTime, AltAmmoBar);
		}
	} 
	else 
	{
		if(Rx_Vehicle_Weapon_Reloadable(weapon) != None && Rx_Vehicle_Weapon_Reloadable(weapon).CurrentlyReloading) 
		{	
			AnimateReload(weapon.WorldInfo.TimeSeconds - Rx_Vehicle_Weapon_Reloadable(weapon).reloadBeginTime, Rx_Vehicle_Weapon_Reloadable(weapon).currentReloadTime, AmmoBar);
		}
	}
}

function UpdateVehicleSeats(Rx_Vehicle RxV)
{
	local string PassengerText;
	local int i;

	if(PassengerContainer == None)
		PassengerContainer = WeaponBlock.GetObject("PassengerContainer");

	for (i = (RxV.Seats.Length - 1); i >= 0; i--) // reverse iteration yo
	{
		if(i < (RxV.Seats.Length - 1))
			PassengerText $= "\n";

		if (RxV.GetSeatPRI(i) != none )
		{
			PassengerText $= RxV.GetSeatPRI(i).GetHumanReadableName() @ "- ("$i+1$")";
		}
		else
		{
			PassengerText $= "-------- - ("$i+1$")";
		}
	}	
	if(RxV.Seats.Length < 5)
	{
		for(i = 0; i < 5 - RxV.Seats.Length; i++)
		{
			PassengerText = "\n"$PassengerText;
		}
	}

	if (!bWasBound && RxV.BoundPRI == Rx_PRI(GetPC().PlayerReplicationInfo))
	{
		bWasBound = true;
		LockMC.SetVisible(true);
		AbilityTextMC.SetVisible(true);
		LockMC.GoToAndStopI((!RxV.bDriverLocked) ? 1 : 2);
		if(RxV.bDriverLocked)
			AbilityTextMC.SetText(Caps("Unlock["$LockKey$"]"));
		else
			AbilityTextMC.SetText(Caps("Lock["$LockKey$"]"));

	}
	else if(bWasBound && RxV.BoundPRI != Rx_PRI(GetPC().PlayerReplicationInfo))
	{
		bWasBound = false;
		bWasLocked = false;
		LockMC.SetVisible(false);
		AbilityTextMC.SetVisible(false);			
	}

	if(bWasBound)
	{
		if(!bWasLocked && RxV.bDriverLocked)
		{
			bWasLocked = true;
			LockMC.GoToAndStopI(2);
			AbilityTextMC.SetText(Caps("Unlock["$LockKey$"]"));
		}
		else if(bWasLocked && !RxV.bDriverLocked)
		{
			bWasLocked = false;
			LockMC.GoToAndStopI(1);	
			AbilityTextMC.SetText(Caps("Lock["$LockKey$"]"));			
		}
	}

	if(PassengerText == LastPassengerText) // if same, no need to update HUD
		return;

	LastPassengerText = PassengerText;
	PassengerContainer.SetString("htmlText",PassengerText);


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

/*
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
*/

//Placeholder because TS_GFxHud is still using the old stuff

function UpdateBuildingInfo_GDI(int i);

function UpdateBuildingInfo_Nod(int i);

//placeholder end here



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
	WeaponTipsMaster = GetVariableObject("_root.Cinema.WeaponTipsMC");
	WeaponTips = WeaponTipsMaster.GetObject("WeapTips");
	WeaponTipsText = WeaponTips.GetObject("Textfield");
	WeaponTipsBKG = WeaponTips.GetObject("Background");
	SecWeaponTips = WeaponTipsMaster.GetObject("SecWeapTips");
	SecWeaponTipsText = SecWeaponTips.GetObject("Textfield");
	SecWeaponTipsBKG = SecWeaponTips.GetObject("Background");	
	AdminMessageText = GetVariableObject("_root.Cinema.AdminMessage.Textfield");
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
	SubtitlesText.SetVisible(false);
	GameplayTipsText.SetVisible(false);
	AdminMessageText.SetVisible(false);
	WeaponPickup.SetVisible(false);
	//hide respawn hud (nBab);
	hideRespawnHud();
}

function AddEVAMessage(string sMessage) 
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

	msg = sMessage;
	mrow.MC.GetObject("message").GotoAndStopI(6);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText","EVA :"@msg);
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

function AddCTextMessage(coerce string sMessage, optional int ShownTime = 60) 
{
	local MessageRow mrow;
	local ASDisplayInfo DisplayInfo,BackDI;
	local byte i;
	local string msg;
	local int numLines;

	if (Len(sMessage) == 0)
		return;

	if (FreeCTextMessages.Length > 0)
	{
		mrow = FreeCTextMessages[FreeCTextMessages.Length-1];
		FreeCTextMessages.Remove(FreeCTextMessages.Length-1,1);
	}
	else
	{
		mrow = CTextMessages[CTextMessages.Length-1];
		CTextMessages.Remove(CTextMessages.Length-1,1);
	}

	mrow.MC.GotoAndPlayI(Max(3,253-ShownTime));
	msg = sMessage;
	mrow.MC.GetObject("message").GotoAndStopI(4);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText", msg);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y  = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	numLines = mrow.MC.GetObject("message").GetObject("textField").GetInt("numLines");

	BackDI.HasYScale = true;
	BackDI.YScale = 100 * numLines;
	mrow.MC.GetObject("message").GetObject("CTextBG").SetDisplayInfo(BackDI);

	for (i = 0; i < CTextMessages.Length; i++)
	{
		CTextMessages[i].Y += CTextMessageHeight * numLines;
		DisplayInfo.Y = CTextMessages[i].Y;
		CTextMessages[i].MC.SetDisplayInfo(DisplayInfo);
	}
	CTextMessages.InsertItem(0,mrow);
}

// Admin message management

function bool HasAdminMessage() {
	return AdminMessageQueue.Length != 0;
}

function UpdateAdminMessage() {
	if (HasAdminMessage()) {
		// There's an admin message in the queue; set it
		AdminMessageText.SetString("htmlText", AdminMessageQueue[0]);
		AdminMessageText.SetVisible(true);
	}
	else {
		// There is no admin message to display; hide text
		AdminMessageText.SetVisible(false);
	}
}

function PushAdminMessage(coerce string sMessage) {
	// Push message to queue
	AdminMessageQueue.AddItem(sMessage);

	// Update current message
	UpdateAdminMessage();
}

function PopAdminMessage() {
	if (HasAdminMessage()) {
		// Pop front message from queue
		// TODO: Log message confirmation back to server?
		AdminMessageQueue.Remove(0, 1);

		// Update current message
		UpdateAdminMessage();
	}
}

/**
* This function is used to display options on the left side menu (vote options, taunts, commander menu, radio commands)
* Each MenuOption consists of 3 parts. The position, the message and the key. Pos 0 is always the header. Having a key on pos 0 will do nothing. Positions 1-13 are the only valid positions for lines.
* Examples on using this function are given in Rx_HUD DrawTaunts(), CreateMenuArray(), CreateVoteMenuArray() and CreateCommanderMenuArray()
* For examples on how to format and ideal execution, look at where the above Create...Array() functions are called.
**/
function DisplayOptions(array<MenuOption> Options)
{

    local int i, ii;
    local GFxObject key, line;


	if(RxPC == None) 
	{
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
	
	mrow.MC.GotoAndPlay("show");
	mrow.MC.GetObject("message").GotoAndStopI(5);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText", html);
	mrow.TF.SetString("rawMsg", raw);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	
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
/*
function AddTeamChatMessage(string html, string raw)
{
	local MessageRow mrow;
	local ASDisplayInfo DisplayInfo;
	local byte i;
	local int numLines; //nBab
	local bool bConcated; 
	
	//Inject to concat identical messages spammed 
	if( TeamChatMessages.Length > 1 && 
	TeamChatMessages[0].TextEmphasis < 4 && 
	`WorldInfoObject.TimeSeconds < TeamChatMessages[0].ConcatDisableTime && 
	Caps(TeamChatMessages[0].TF.GetString("rawMsg")) == Caps(raw))
	{
		TeamChatMessages[0].TextEmphasis = min(TeamChatMessages[0].TextEmphasis+1, 4);
		switch(TeamChatMessages[0].TextEmphasis){
			case 0:
				TeamChatMessages[0].TF.SetString("htmlText", ">" $ html);
				break;
			case 1:
				TeamChatMessages[0].TF.SetString("htmlText", ">>" $ html);
				break;
			case 2:
				TeamChatMessages[0].TF.SetString("htmlText", ">><font size='15'>" $ html $ "</font><");
				break;
			case 3:
				TeamChatMessages[0].TF.SetString("htmlText", ">><font size='16'>" $ html $ "</font><");
				break;
			case 4:
				TeamChatMessages[0].TF.SetString("htmlText", ">><font size='17'>" $ html $ "</font><");
				break;
		}
		
		bConcated = true; 
	}
	
	if(bConcated)
	{
		return;
	}
		
	
	if (FreeTeamChatMessages.Length > 0)
	{
		mrow = FreeTeamChatMessages[FreeTeamChatMessages.Length-1];
		FreeTeamChatMessages.Remove(FreeTeamChatMessages.Length-1,1);
	}
	else
	{
		mrow = TeamChatMessages[TeamChatMessages.Length-1];
		TeamChatMessages.Remove(TeamChatMessages.Length-1,1);
	}
	
	mrow.MC.GotoAndPlay("show");
	mrow.MC.GetObject("message").GotoAndStopI(5);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText", html);
	mrow.TF.SetString("rawMsg", raw);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	
	//get number of lines from flash (nBab)
	numLines = mrow.MC.GetObject("message").GetObject("textField").GetInt("numLines");
	for (i = 0; i < TeamChatMessages.Length; i++)
	{
		//set message height based on number of lines (nBab)
		//TeamChatMessages[i].Y += MessageHeight; (Old line)
		TeamChatMessages[i].Y += MessageHeight * numLines;
		DisplayInfo.Y = TeamChatMessages[i].Y;
		TeamChatMessages[i].MC.SetDisplayInfo(DisplayInfo);
	}
	mrow.ConcatDisableTime=`WorldInfoObject.TimeSeconds+8; //Add time before messages fade away
	TeamChatMessages.InsertItem(0,mrow);
}
*/
function AddRadioMessage(string html, string raw)
{
	local MessageRow mrow;
	local ASDisplayInfo DisplayInfo;
	local byte i;
	local int numLines; //nBab
	local bool bConcated; 
	
	//Inject to concat identical messages spammed 
	if( RadioMessages.Length > 1 && 
	RadioMessages[0].TextEmphasis < 4 && 
	`WorldInfoObject.TimeSeconds < RadioMessages[0].ConcatDisableTime && 
	Caps(RadioMessages[0].TF.GetString("rawMsg")) == Caps(raw))
	{
		RadioMessages[0].TextEmphasis = min(RadioMessages[0].TextEmphasis+1, 4);
		switch(RadioMessages[0].TextEmphasis){
			case 0:
				RadioMessages[0].TF.SetString("htmlText", ">" $ html);
				break;
			case 1:
				RadioMessages[0].TF.SetString("htmlText", ">>" $ html);
				break;
			case 2:
				RadioMessages[0].TF.SetString("htmlText", ">><font size='15'>" $ html $ "</font><");
				break;
			case 3:
				RadioMessages[0].TF.SetString("htmlText", ">><font size='16'>" $ html $ "</font><");
				break;
			case 4:
				RadioMessages[0].TF.SetString("htmlText", ">><font size='17'>" $ html $ "</font><");
				break;
		}
		
		bConcated = true; 
	}
	
	if(bConcated)
	{
		return;
	}
		
	
	if (FreeRadioMessages.Length > 0)
	{
		mrow = FreeRadioMessages[FreeRadioMessages.Length-1];
		FreeRadioMessages.Remove(FreeRadioMessages.Length-1,1);
	}
	else
	{
		mrow = RadioMessages[RadioMessages.Length-1];
		RadioMessages.Remove(RadioMessages.Length-1,1);
	}
	
	mrow.MC.GotoAndPlay("show");
	mrow.MC.GetObject("message").GotoAndStopI(5);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText", html);
	mrow.TF.SetString("rawMsg", raw);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	
	//get number of lines from flash (nBab)
	numLines = mrow.MC.GetObject("message").GetObject("textField").GetInt("numLines");
	for (i = 0; i < RadioMessages.Length; i++)
	{
		//set message height based on number of lines (nBab)
		//RadioMessages[i].Y += MessageHeight; (Old line)
		RadioMessages[i].Y += MessageHeight * numLines;
		DisplayInfo.Y = RadioMessages[i].Y;
		RadioMessages[i].MC.SetDisplayInfo(DisplayInfo);
	}
	mrow.ConcatDisableTime=`WorldInfoObject.TimeSeconds+8; //Add time before messages fade away
	RadioMessages.InsertItem(0,mrow);
}

function AddVehicleDeathMessage(string HTMLMessage, class<DamageType> Dmg, PlayerReplicationInfo Killer)
{
	local SubMsg TempSubtitle;

	SubtitlesText.SetVisible(true);

	TempSubtitle.Message = HTMLMessage$"\n<img src='" $ ParseDamageType(Dmg, Killer ) $ "'>";
	TempSubtitle.Lifetime = 60;

	Subtitle_Messages.AddItem(TempSubtitle);
	
	/**SubtitlesText.SetString("htmlText", HTMLMessage 
		$"\n<img src='" $ParseDamageType(Dmg, Killer ) $"'>");*/
}

function AddDeathMessage(string HTMLMessage, class<DamageType> Dmg, PlayerReplicationInfo Killer)
{
	local SubMsg TempSubtitle;

	SubtitlesText.SetVisible(true);
	//show respawn hud (nBab)
	showRespawnhud(GetPC().GetTeamNum(),lastFreeClass);

	TempSubtitle.Message = HTMLMessage$"\n<img src='" $ ParseDamageType(Dmg, Killer ) $"'>";
	TempSubtitle.Lifetime = 300;

	Subtitle_Messages.AddItem(TempSubtitle);
	
	/**SubtitlesText.SetString("htmlText", HTMLMessage  
		$"\n<img src='" $ ParseDamageType(Dmg, Killer ) $"'>");
*/

}

function AddVPMessage(string HTMLMessage)
{
	local SubMsg TempSubtitle;

	if(bPlayerDead)
		return; // don't add if we die

	SubtitlesText.SetVisible(true);
	//show respawn hud (nBab)
//	showRespawnhud(GetPC().GetTeamNum(),lastFreeClass);

	TempSubtitle.Message = HTMLMessage;
	TempSubtitle.Lifetime = 60;
	// Death message takes more priority
	Subtitle_Messages.AddItem(TempSubtitle);
	
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

	mrow.MC.GotoAndPlay("show");
	mrow.MC.GetObject("message").GotoAndStopI(1);
	mrow.TF = mrow.MC.GetObject("message").GetObject("textField");
	mrow.TF.SetString("htmlText", text);
	mrow.Y = 0;
	DisplayInfo.hasY = true;
	DisplayInfo.Y = 0;
	mrow.MC.SetDisplayInfo(DisplayInfo);
	
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

//update veterancy (nBab)
function updateVeterancy()
{
	local int VetProgress;

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
			VeterancyIconCurrent.GotoAndStopI(VRank+1);
			VeterancyIconNext.GotoAndStopI(RxPRI.VRank+1);
			VeterancyIcon.GotoAndPlayI(2);
			GetVariableObject("_root.centerTextRoot.centerText.textField").setText("Promoted to "$GetVariableObject("_root.HealthBlock.vet.vet_tf").getText());
			GetVariableObject("_root.centerTextRoot").GotoAndPlayI(2);
			VRank++;

			UpdateVeterancyGFx(false);
			//play sound
			//GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.SFX.S_Kill_Alert_Cue');
			//GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.SFX.S_Bonus_Complete_Cue');
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.SFX.S_Primary_Update_Cue');
		}

		//set veterancy bar
		if(VetProgress == LastVetPoint) // if we don't need to update the bar, it's pointless to do so
			return;

		LastVetPoint = VetProgress;
		VeterancyBar.GotoAndStopI(VetProgress+1);
	}
}

//show respawn hud (nBab)
function showRespawnHud(int teamNum, int lfClass)
{	
	if(bRespawnHUDHidden)
	{
		bRespawnHUDHidden = false;
		GetVariableObject("_root.Cinema.respawn_ui").ActionScriptVoid("showRespawnHud");
	}
}

//hide respawn hud (nBab)
function hideRespawnHud()
{
	if(!bRespawnHUDHidden)
	{
		bRespawnHUDHidden = true;
		GetVariableObject("_root.Cinema.respawn_ui").ActionScriptVoid("hideRespawnHud");
	}
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
	local string VoteYesBind, VoteNoBind;
	local string VoteTitle;
	local string VoteChoice;
	local ASDisplayInfo DI;
 
	if (content == "")
	{
		if(!bvoteJustStarted && VoteMC != None)
		{
			VoteMC.GoToAndPlayI(23);
			bvoteJustStarted = true;
		}			
		return;
	}
	
	VoteYesBind = Rx_PlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand("voteyes"); 
	
	VoteNoBind = Rx_PlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand("voteno"); 
	
	//if the vote has just started, add the textfield movieclip from library and do the animation
	if (bvoteJustStarted)
	{
		//set the content
		voteMC.GotoAndPlayI(2);
		VoteTextContainerMC = VoteMC.GetObject("VoteText");
		VoteBackdropMC = VoteMC.GetObject("VoteBackdrop");
		VoteTitleText = VoteTextContainerMC.GetObject("VoteTitleText");
		VoteChoiceText = VoteTextContainerMC.GetObject("VoteChoiceText");
		
		VoteTitle = "<font color='#00FF00'>"$"VOTE INITIATED"$"</font>"$" : " $caps(content)$ "["$"<font color='#00FF00'>"$String(yes)$"/"$String(yesNeeded)$"</font>"$"] | ["$"<font color='#FF0000'>"$String(no)$"</font>"$"]";	
		VoteTitleText.SetString("htmlText",VoteTitle);
		VoteChoice = "<font color='#00FF00'>"$"["$VoteYesBind$"]: YES"$"</font>"$" "$"<font color='#FF0000'>"$"["$VoteNoBind$"]: NO"$"</font> | "$String(timeLeft)$" seconds left";
		VoteChoiceText.SetString("htmlText",VoteChoice);

		LastNoVote = no;
		LastYesVote = yes;
		LastYesNeededVote = yesNeeded;
		LastVoteSecondsLeft = timeLeft;

		DI.hasYScale = true;
		DI.YScale = 100.f * (VoteTitleText.GetInt("numLines"));
		if(DI.YScale > 100.f)
			VoteBackdropMC.SetDisplayInfo(DI);

		VoteChoiceText.SetPosition(0,30 * VoteTitleText.GetInt("numLines"));
		//play sound
		GetPC().ClientPlaySound(SoundCue'rx_interfacesound.Wave.Vote_Start');

		bvoteJustStarted = false;
	}
	//else update votes
	else if (LastNoVote != no || LastYesVote != Yes || LastYesNeededVote != yesNeeded || LastVoteSecondsLeft != timeLeft)
	{

		LastNoVote = no;
		LastYesVote = yes;
		LastYesNeededVote = yesNeeded;
		LastVoteSecondsLeft = timeLeft;

		VoteTitle = "<font color='#00FF00'>"$"VOTE INITIATED"$"</font>"$" : " $caps(content)$ "["$"<font color='#00FF00'>"$String(yes)$"/"$String(yesNeeded)$"</font>"$"] | ["$"<font color='#FF0000'>"$String(no)$"</font>"$"]";	
		VoteTitleText.SetString("htmlText",VoteTitle);
		VoteChoice = "<font color='#00FF00'>["$VoteYesBind$"]: YES</font> <font color='#FF0000'>["$VoteNoBind$"]: NO</font> | "$String(timeLeft)$" seconds left";
		VoteChoiceText.SetString("htmlText",VoteChoice);

		VoteChoiceText.SetPosition(0,30 * VoteTitleText.GetInt("numLines"));
	}
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

function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if (HasAdminMessage()) {
		if (ButtonName == 'Enter' && InputEvent == IE_Released) {
			PopAdminMessage();
		}

		// Trap user input when displaying an admin message
		return true;
	}

	return false;
}

DefaultProperties
{
	isInVehicle         = false
	bDisplayWithHudOff  = false

	MovieInfo           = SwfMovie'RenXHud.RenXHud'
	MessageHeight       = 20
	CTextMessageHeight       = 38

//	VehicleDeathMsgTime = -1
//	VehicleDeathDisplayLength = 3

	//tech building icon tween time in seconds (nBab)
	SkipNum = 2
	bUseTickCycle=true //Cycle expensive functions in the TickHUD() function
	
	AbilityKey = Xf

	WeaponMCAlpha[0] = 0.7
	WeaponMCAlpha[1] = 0.6
	WeaponMCAlpha[2] = 0.4
	WeaponMCAlpha[3] = 0.2

	LastWeaponTips = "WEAPON TIPS"
	LastSecWeaponTips = "WEAPON TIPS"

}