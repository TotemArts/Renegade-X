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
	var float     StartFadeTime;
	var int       Y;
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

var BuildingInfo BuildingInfo_GDI[5];
var BuildingInfo BuildingInfo_Nod[5];

var() Rx_GFxMinimap Minimap;
var() Rx_GFxMarker Marker;

var Rx_Hud RenxHud;

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
var GFxObject HealthBlock, HealthBar, HealthN, HealthMaxN, HealthText, HealthIcon;
var GFxObject VArmorN, VArmorBar, VehicleMC, VArmorMaxN;
var GFxObject ArmorBar, ArmorN, ArmorMaxN;
var GFxObject StaminaBar;
var GFxObject AmmoInClipN, AmmoBar, AmmoReserveN, AltAmmoInClipN, AltAmmoBar, InfinitAmmo, AltInfinitAmmo, WeaponBlock, VAltWeaponBlock;
var GFxObject WeaponMC, WeaponPrevMC, WeaponNextMC, VBackdrop, WeaponName, AltWeaponName;

//Experimental Progress bar
var GFXObject LoadingMeterMC[2], LoadingText[2];
var GFxClikWidget LoadingBarWidget[2];

//
var GFxObject GrenadeN, GrenadeMC, TimedC4MC, RemoteC4MC, ProxyC4MC, BeaconMC;
var GFxObject HitLocMC[8];
var GFxObject BottomInfo;
var GFxObject Credits;
var GFxObject MatchTimer;
var GFxObject VehicleCount;
var GFxObject MineCount;
var GFxObject DirCompassIcon;
var GFxObject RootMC;
 
var GFxObject Scoreboard;
var GFxObject SBTeamScore[2];
var GFxObject SBTeamCredits[2], SBTeamKills[2], SBTeamDeaths[2], SBTeamKDR[2];
var const int NumPlayerStats;
var array<SBPlayerEntry> PlayerInfo;
var int CurrentNumberPRIs;

//items that we are diabling for now - THIS LIST SHOULD BE EMPTY BY THE TIME THE HUD IS DONE
var GFxObject ObjectiveMC, ObjectiveText, TimerMC, TimerText, FadeScreenMC, SubtitlesText, GameplayTipsText, WeaponPickup;
var float LastTipsUpdateTime;
var float VehicleDeathMsgTime;
var float VehicleDeathDisplayLength;


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

	SetupScoreboard();
	DisableHUDItems();

	//AddFocusIgnoreKey('t');

	prevWeapon = none;
	RootMC = GetVariableObject("_root");
	MineCount.SetText(0);
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
		GetVariableObject("_root.BottomInfo").SetPosition(HudMovieSize.X * 0.3494/*0.4987*/,HudMovieSize.Y * 0.8952/*0.9586*/);
		GetVariableObject("_root.HealthBlock").SetPosition(HudMovieSize.X * 0.1237,HudMovieSize.Y * 0.8728);
		GetVariableObject("_root.WeaponBlock").SetPosition(HudMovieSize.X * 0.7167,HudMovieSize.Y * 0.9775);
		GetVariableObject("_root.WeaponPickup").SetPosition(HudMovieSize.X * 0.3400,HudMovieSize.Y * 0.5855);
	}
	// END of resize code
}

/**Called every update Tick*/
function TickHUD() 
{
	local Rx_Pawn RxP;
	local Pawn TempPawn;
	local Rx_Weapon RxWeap;
	local Rx_Vehicle RxV;
	local Rx_Vehicle_Weapon RxVWeap;
	local UTPlayerController RxPC;
	local Rx_GRI RxGRI;
	local byte i;
	
	if (!bMovieIsOpen) {
		return;
	}

	RxPC = UTPlayerController(GetPC());
	if(RxPC == None) {
		return;
	}

	if(RxPC.Pawn != None)
		TempPawn = RxPC.Pawn;
	else if(Pawn(RxPC.viewtarget) != None)
		TempPawn = Pawn(RxPC.viewtarget);		


	//assign all 4 var here. RxP RxV, RxWeap, RxVehicleWeap
	if (Rx_Pawn(TempPawn) != none) {
		RxP = Rx_Pawn(TempPawn);
		RxWeap = Rx_Weapon(RxP.Weapon);
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

		//updates that only happen on foot
		UpdateStamina(RxP.Stamina);
		//UpdateItems();
		if(RxWeap != None) 
		{
			UpdateWeapon(RxWeap);
		}
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
 			lastWeaponHeld = none;
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
	} else {
		SetLivingHUDVisible(false);
		FadeScreenMC.SetVisible(true);
		SubtitlesText.SetVisible(true);
		UpdateHealth(0 , 100);
		UpdateArmor(0 , 100);
		VehicleDeathMsgTime = -1;
	}


// 	UpdateHealth((RxP == none || RxP.Health <= 0) ? 0 : RxP.Health, RxP.HealthMax);
// 	UpdateArmor((RxP == none || RxP.Armor <= 0) ? 0 : RxP.Health, RxP.ArmorMax);

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

	if (RxPC.WorldInfo != none && RxPC.WorldInfo.GRI !=none)
	{
		if (RxPC.WorldInfo.GRI.TimeLimit > 0)
			UpdateMatchTimer(RxPC.WorldInfo.GRI.RemainingTime);
		else
			UpdateMatchTimer(RxPC.WorldInfo.GRI.ElapsedTime);

	}

	if (Rx_PRI(RxPC.PlayerReplicationInfo) != none)
	{
		UpdateCredits(Rx_PRI(RxPC.PlayerReplicationInfo).GetCredits());
		if(RxPC.PlayerReplicationInfo.Team != None) 
		{
			UpdateVehicleCount(Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).GetVehicleCount(),Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).VehicleLimit);
			UpdateMineCount(Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).MineCount,Rx_TeamInfo(RxPC.PlayerReplicationInfo.Team).mineLimit);
		}
	}

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
	else if (GameplayTipsText.GetText() != "")
	{					
		GameplayTipsText.SetString("htmlText", "");
		GameplayTipsText.SetVisible(false);
		FadeScreenMC.SetVisible(false); 
	}
}

function SetLivingHUDVisible(bool visible)
{
	//ObjectiveMC.SetVisible(visible);
	Minimap.SetVisible(visible);
	Marker.SetVisible(visible);
	HealthBlock.SetVisible(visible);
	BottomInfo.SetVisible(visible);
	WeaponBlock.SetVisible(visible);

}
function UpdateHUDVars() 
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
		Minimap     = Rx_GFxMinimap(GetVariableObject("_root.minimap", class'Rx_GFxMinimap'));
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
	if (HealthMaxN != None)
	{
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

function UpdateWeapon(UTWeapon weapon)
{
	local Rx_Controller RxPC;
// 	local array<UTWeapon> WeaponList;
// 	local int i;

	//UpdateHUDVars();

	//we dont want to set visible every tick, so we have this extra IF
	if(weapon != lastWeaponHeld) {
		AmmoInClipValue = -1;
		AmmoInReserveValue = -1;

		UpdateHUDVars();
		
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
		//WeaponMC.GotoAndStopI(int(Rx_Weapon(weapon).GetInventoryMovieGroup()));
		LoadTexture(Rx_Weapon(weapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(weapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponMC);

		if(prevWeapon != none && Rx_Weapon(prevWeapon) != None) {
			WeaponPrevMC.SetVisible(true);
			//WeaponPrevMC.GotoAndStopI(int(Rx_Weapon(prevWeapon).GetInventoryMovieGroup()));
			LoadTexture(Rx_Weapon(prevWeapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(prevWeapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponPrevMC);
		} else {
			WeaponPrevMC.SetVisible(false);
		}
			

		if(nextWeapon != none && Rx_Weapon(prevWeapon) != None) {
			WeaponNextMC.SetVisible(true);
			//WeaponNextMC.GotoAndStopI(int(Rx_Weapon(nextWeapon).GetInventoryMovieGroup()));
			LoadTexture(Rx_Weapon(nextWeapon).WeaponIconTexture != none ? "img://" $ PathName(Rx_Weapon(nextWeapon).WeaponIconTexture) : PathName(Texture2D'RenxHud.T_WeaponIcon_MissingCameo'), WeaponNextMC);
		} else {
			WeaponNextMC.SetVisible(false);
		}
	}

	if(Rx_Weapon_Reloadable(weapon) != None) {
		//Update ammo counts
		if( AmmoInClipValue != Rx_Weapon_Reloadable(weapon).GetUseableAmmo()) {
			AmmoInClipValue = Rx_Weapon_Reloadable(weapon).GetUseableAmmo();
			AmmoInClipN.SetText(AmmoInClipValue);
			AmmoBar.GotoAndStopI(float(AmmoInClipValue) / float(Rx_Weapon_Reloadable(weapon).GetMaxAmmoInClip()) * 100);
		}
		//Update reserve ammo counts
		if( AmmoInReserveValue != Rx_Weapon_Reloadable(weapon).GetReserveAmmo()) {
			AmmoInReserveValue = Rx_Weapon_Reloadable(weapon).GetReserveAmmo();
			AmmoReserveN.SetText(AmmoInReserveValue);
		}
		//realod weapon animation
		if(Rx_Weapon_Reloadable(weapon) != None && Rx_Weapon_Reloadable(weapon).CurrentlyReloading && !Rx_Weapon_Reloadable(weapon).PerBulletReload) {	
			AnimateReload(weapon.WorldInfo.TimeSeconds - Rx_Weapon_Reloadable(weapon).reloadBeginTime, Rx_Weapon_Reloadable(weapon).currentReloadTime, AmmoBar);		
		}
	}

// 	if(RxPC != None) {
// 		Rx_InventoryManager(RxPC.Pawn.InvManager).GetWeaponList(WeaponList);
// 		for (i = 0; i < WeaponList.Length; i++) {
// 			if(Rx_Weapon_Grenade(WeaponList[i]) != None && Rx_Weapon_Grenade(WeaponList[i]).AmmoCount > 0) {
// 				GrenadeMC.GotoAndStopI(1);
// 				GrenadeN.SetText(Rx_Weapon_Grenade(WeaponList[i]).AmmoCount$"X");
// 			} else {
// 				GrenadeN.SetText("0X");
// 				GrenadeMC.GotoAndStopI(2);
// 			}
// 	
// 			if(Rx_Weapon_TimedC4(WeaponList[i]) != None && TimedC4MC != None) {
// 				TimedC4MC.GotoAndStopI(1);
// 			} else if(TimedC4MC != None) {
// 				TimedC4MC.GotoAndStopI(2);
// 			}
// 			
// 	
// 			if(Rx_Weapon_RemoteC4(WeaponList[i]) != None && RemoteC4MC != None) {
// 				RemoteC4MC.GotoAndStopI(1);
// 			} else if(RemoteC4MC != None) {
// 				RemoteC4MC.GotoAndStopI(2);
// 			}
// 			
// 	
// 			if(Rx_Weapon_ProxyC4(WeaponList[i]) != None && ProxyC4MC != None) {
// 				ProxyC4MC.GotoAndStopI(1);
// 			} else if(ProxyC4MC != None) {
// 				ProxyC4MC.GotoAndStopI(2);
// 			}
// 		}
// 	}
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
	if(weapon == None) {
		VehicleMC.SetVisible(false);
		`log ("<GFxHUD Log> GetPC().Pawn? " $ GetPC().Pawn);
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
			if( Rx_Building_AdvancedGuardTower(BuildingActor) != None )
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
			else if( Rx_Building_WeaponsFactory(BuildingActor) != None || Rx_Building_WeaponsFactory_Ramps(BuildingActor) != None )
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
			else if( Rx_Building_Barracks(BuildingActor) != None || Rx_Building_Barracks_Ramps(BuildingActor) != None )
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
			else if( Rx_Building_Refinery_GDI(BuildingActor) != None || Rx_Building_Refinery_GDI_Ramps(BuildingActor) != None )
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
			else if( Rx_Building_PowerPlant_GDI(BuildingActor) != None || Rx_Building_PowerPlant_GDI_Ramps(BuildingActor) != None )
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
			if( Rx_Building_Obelisk(BuildingActor) != None )
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
			else if( Rx_Building_AirTower(BuildingActor) != None || Rx_Building_AirTower_Ramps(BuildingActor) != None )
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
			else if( Rx_Building_HandOfNod(BuildingActor) != None || Rx_Building_HandOfNod_Ramps(BuildingActor) != None )
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
			else if( Rx_Building_Refinery_Nod(BuildingActor) != None || Rx_Building_Refinery_Nod_Ramps(BuildingActor) != None )
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
			else if( Rx_Building_PowerPlant_Nod(BuildingActor) != None || Rx_Building_PowerPlant_Nod_Ramps(BuildingActor) != None )
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

	if ( class<UTDamageType>(damageType) != none && GetPC().pawn != None)
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

function AddChatMessage(string html, string raw)
{
	local MessageRow mrow;
	local ASDisplayInfo DisplayInfo;
	local byte i;

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
	for (i = 0; i < ChatMessages.Length; i++)
	{
		ChatMessages[i].Y += MessageHeight;
		DisplayInfo.Y = ChatMessages[i].Y;
		ChatMessages[i].MC.SetDisplayInfo(DisplayInfo);
	}
	ChatMessages.InsertItem(0,mrow);
}

function AddVehicleDeathMessage(string HTMLMessage, class<DamageType> Dmg, PlayerReplicationInfo Killer)
{
	FadeScreenMC.SetVisible(true);
	SubtitlesText.SetVisible(true);

	VehicleDeathMsgTime = RenxHud.WorldInfo.TimeSeconds + VehicleDeathDisplayLength;

	SubtitlesText.SetString("htmlText", HTMLMessage 
		$"\n<img src='" $ParseDamageType(Dmg, Killer ) $"'>");
}

function AddDeathMessage(string HTMLMessage, class<DamageType> Dmg, PlayerReplicationInfo Killer)
{
	FadeScreenMC.SetVisible(true);
	SubtitlesText.SetVisible(true);

	SubtitlesText.SetString("htmlText", HTMLMessage  
		$"\n<img src='" $ ParseDamageType(Dmg, Killer ) $"'>");


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
}