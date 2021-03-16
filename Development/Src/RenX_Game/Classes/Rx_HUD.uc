
/*********************************************************
*
* File: RxHUD.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class manages the HUD object Rx_GFxHud. 
* 	
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/

class Rx_HUD extends UTHUDBase
config(XSettings)
DependsOn(Rx_GFxHud);

var config bool ShowInteractableIcon;
var config bool ShowInteractMessage;

var config bool ShowOwnName;
var config bool ShowOwnNameInVehicle;

var config bool ShowBasicTips;

/**Reference the actual SWF container*/
var class<Rx_GFxHud> HudMovieClass;
var Rx_GFxHud HudMovie;

var class<Rx_GFxGameinfoHud> GIHudMovieClass;
var Rx_GFxGameinfoHud GIHudMovie;

var class<Rx_Hud_TargetingBox> TargetingBoxClass;
var class<Rx_Hud_PlayerNames> PlayerNamesClass;
var class<Rx_HUD_CaptureProgress> CaptureProgressClass;
var class<Rx_HUD_CTextComponent> CommandTextClass;
var class<Rx_GFxUIScoreboard> ScoreboardClass;

var Rx_HUD_TargetingBox TargetingBox;
var Rx_Hud_PlayerNames PlayerNames;
var Rx_HUD_CaptureProgress CaptureProgress;
var Rx_HUD_CTextComponent CommandText;

var bool DrawCText, DrawTargetBox,DrawPlayerNames,DrawCaptureProgress, DrawFlashHUD; //DrawC_Visuals; 

/** Flash vote/radio menu stuff **/
var array<int> RadioCommandsCtrl, RadioCommandsAlt, RadioCommandsCtrlAlt;

/*Vignette on the screen edges used for damage and other events*/
var Rx_HUD_VignetteComponent HUDVignette;
var class<Rx_HUD_VignetteComponent> HUDVignetteClass; 


/** GFx movie used for displaying pause menu */
var class<Rx_GFxPauseMenu> RxPauseMenuMovieClass;
var Rx_GFxPauseMenu		RxPauseMenuMovie;
var Rx_GFxPauseMenu_FadeSystem RxPauseMenu_FadeSystemMovie;

/** GFx movie used for purchase terminal */
var Rx_GFxPurchaseMenu PTMovie;

var bool bToggleOverviewMap;
/** GFx movie used for Overview Map */
var class<Rx_GfxOverviewMap> OverviewMapClass; 
var Rx_GFxOverviewMap OverviewMapMovie;

var float MaxSpotDistance;
var array<Actor> UnmarkTargets;

/** Debug flag to show AI information */
var bool bShowAllAI;
var bool bShowAIFireline;
var	const color	YellowColor;
var	const color	BlueColor;

var LinearColor HitMarker_Color, LC_White, LC_Red; 

/** HTML Color Codes */
var string 	GDIColor, NodColor, NeutralColor, PrivateFromColor, PrivateToColor, HostColor, RadioColor, CommandTextColor;

var array<Actor> SpotTargets, CommandSpotTargets;
var int NumSpotTargetDots;
var actor LastSpotTarget;
var bool bSpottedBuilding;
var private CanvasIcon EnemySpottedIcon;

var byte   ScorePanelMode;
var protected float     ScorePanelX, ScorePanelY;
var protected float     DistText[5];
var protected float     DrawStartX[6];
var float DrawStartModifier;
var bool bDrawAdditionalPlayerInfo;

var string PlayAreaAnnouncementText;
var string PlayAreaAnnouncementCount;
var protected array<Rx_Building> BuildingsGdi;
var protected array<Rx_Building> BuildingsNod;

var Rx_GFxUIScoreboard     Scoreboard;
var int HitEffectAplha;
var float LastScoreboardRenderTime;
var array<PlayerReplicationInfo> PRIArray;
var Rx_Vehicle_Harvester GDI_Harvester;
var Rx_Vehicle_Harvester Nod_Harvester;
var string LastEndScoreboardChats;

var private const float DefaultTargettingRange;

var Actor ScreenCentreActor;
var Actor WeaponAimingActor;

var string PublicChatMessageLog;
var string PrivateChatMessageLog;

var Rx_SystemSettingsHandler SystemSettingsHandler;

/**@Shahman: Retrieves the Graphic Adapter name for the user*/
var Rx_GraphicAdapterCheck GraphicAdapterCheck;

var Rx_Jukebox JukeBox;

var Rx_CapturePoint CurrentCapturePoint;
var vector AimLoc;

//VOTE/CONTEXT MENU RELATED//
var byte 		CurrentPageNum;
var float		ContextMenu_AnchorX, ContextMenu_AnchorY, ContextMenu_FontScale;
var color		ContextMenu_NormalColor, ContextMenu_HighlightColor;  
var CanvasIcon 	ContextualMenuBackground, ContextualMenuHelpBackground;	//Separate so the help can be hidden when not in use
var float		ContextMenu_SizeX, ContextMenu_SizeY; 
var float		ContextMenu_TextSeparationX, ContextMenu_TextSeparationY, ContextMenu_TextAnchorX, ContextMenu_TextAnchorY; 
var float		ContextMenu_PromptsAnchorY;
var float		ContextMenu_TitleAnchorX, ContextMenu_TitleAnchorY;
var float		ContextMenu_FooterY; 	
var float		TestFontScale;

var bool		bAimingAtSomething;

var float		MiniCommandWindow_AnchorX, MiniCommandWindow_AnchorY; 

var CanvasIcon VetRankIcons[4];

var bool bEnableFade;
var float FadePercentage,FadePerSecond;

var config int KillFeedMode;
var bool bShowScorePanel;
var int RadioCommand;

//cache data for GFxObjects, if necessary...
var Array<Rx_Building_TechBuilding> TechBuildings;
var Array<Rx_Building_Team_Internals> TeamBuildingInternals;

var int DamageIntensity;
var float DamageIntensityDelay;
var int PendingBleed;

var Vector2D ViewportSize;

function Actor GetActorAtScreenCentre()
{
	return ScreenCentreActor;
}

function Actor GetActorWeaponIsAimingAt()
{
	return WeaponAimingActor;
}

function UpdateScreenCentreActor()
{
	local Vector CameraOrigin, CameraDirection, HitLoc,HitNormal,TraceRange;
	local float ClosestHit, extendedDist, tempDist;
	local Actor HitActor, PotentialTarget;
	local bool  bHittingSomething; 
	
	PotentialTarget = none;
	WeaponAimingActor = none;
	ClosestHit = Square(GetWeaponTargetingRange());

	GetCameraOriginAndDirection(CameraOrigin,CameraDirection);
	
	TraceRange = CameraOrigin + CameraDirection * GetWeaponTargetingRange();
	extendedDist = VSizeSq(CameraOrigin - PlayerOwner.ViewTarget.location);
	TraceRange += CameraDirection * Sqrt(extendedDist);

	// This trace will ignore the view target so we don't target ourselves.
	foreach TraceActors(class'actor',HitActor,HitLoc,HitNormal,TraceRange,CameraOrigin,vect(0,0,0),,1)
	{
		if(HitActor !=none) 
			bHittingSomething = true;  
		
			AimLoc = HitLoc;
		if(RxIfc_TargetedSubstitution(HitActor) == None)
		{
			if (Landscape(HitActor) != None)
				break;
			if (StaticMeshActor(HitActor) != None)
				break;			
		}
		tempDist = VSizeSq(CameraOrigin - HitLoc) - extendedDist;
		if (HitActor != PlayerOwner.ViewTarget && (Rx_Pickup(HitActor) == none || Rx_CratePickup(HitActor) != none) && ClosestHit >= tempDist)
		{
			ClosestHit = tempDist;
			if (ClosestHit < Square(GetWeaponRange())) {
				WeaponAimingActor = HitActor;
			}
				
			PotentialTarget = HitActor;
			TargetingBox.TargetActorHitLoc = HitLoc;
			break;
		}
	}
	
	bAimingAtSomething = bHittingSomething; 
	ScreenCentreActor = PotentialTarget;
}

function GetCameraOriginAndDirection(out vector CameraOrigin, out vector CameraDirection)
{
	local Vector2d screenCentre;
	
	screenCentre.X = SizeX/2;
	screenCentre.Y = SizeY/2;

	canvas.DeProject(screenCentre,CameraOrigin,CameraDirection);	
}

function float GetWeaponTargetingRange()
{
	local Weapon OurWeapon;
	local Rx_CommanderSupport_TargetingParticleSystem CommandPS; 
	
	if (PlayerOwner != none && PlayerOwner.ViewTarget != none)
	{
		//Inject. Are we trying to cast a support power?
		CommandPS = Rx_Controller(PlayerOwner).CommanderTargetingReticule;
		
		if(CommandPS != none && CommandPS.MaxSpotRange > 0) 
			return CommandPS.MaxSpotRange; 
		
		if (UTVehicle(PlayerOwner.ViewTarget) != none && UTVehicle(PlayerOwner.ViewTarget).Weapon != none)
			OurWeapon = UTVehicle(PlayerOwner.ViewTarget).Weapon;
		else if (UTPawn(PlayerOwner.ViewTarget) != none && UTPawn(PlayerOwner.ViewTarget).Weapon != none)
			OurWeapon = UTPawn(PlayerOwner.ViewTarget).Weapon;

		if (OurWeapon != none && Rx_Weapon_Deployable(OurWeapon) == none && Rx_Weapon_RepairGun(OurWeapon) == none)
			return GetWeaponRange();
		else return DefaultTargettingRange;
	}
	else return DefaultTargettingRange;
}

function float GetWeaponRange()
{
	local Weapon OurWeapon;

	if (PlayerOwner != none && PlayerOwner.ViewTarget != none)
	{
		if (UTVehicle(PlayerOwner.ViewTarget) != none && UTVehicle(PlayerOwner.ViewTarget).Weapon != none)
			OurWeapon = UTVehicle(PlayerOwner.ViewTarget).Weapon;
		else if (UTPawn(PlayerOwner.ViewTarget) != none && UTPawn(PlayerOwner.ViewTarget).Weapon != none)
			OurWeapon = UTPawn(PlayerOwner.ViewTarget).Weapon;

		if (OurWeapon != none)
			return OurWeapon.MaxRange();
		else return DefaultTargettingRange;
	}
	else return DefaultTargettingRange;
}

function string ParseRadioMessage(string Msg) {
	local array<string> Split;
	local int TextIndex;
	local string Result;
	local Rx_Controller PC;

	PC = Rx_Controller(PlayerOwner);

	// Split message based on "|" seperator
	Split = SplitString(Msg, "|");
	if (Split.Length <= 0) {
		// Failed to parse incoming message; return message unprocessed
		return Msg;
	}

	// Parse TextIndex out of message
	TextIndex = int(Split[0]);

	// Sanity check index
	if (TextIndex < 0 || TextIndex >= PC.RadioCommandsText.Length) {
		// Invalid TextIndex; return message unprocessed
		return Msg;
	}

	// Get radio command text
	Result = PC.RadioCommandsText[TextIndex];

	// Append or insert context string (if there is any)
	if (Split.Length > 1) {
		if (InStr(Result, "{CONTEXT}") >= 0) {
			// {CONTEXT} is in string; replace it
			Result = Repl(Result, "{CONTEXT}", Split[1]);
		}
		else {
			// No {CONTEXT} in radio command text; append it
			Result @= Split[1];
		}
	}

	return Result;
}

//Handles drawing for log, chat, kill and EVA messages
function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType, optional float LifeTime = 60)
{
	local string cName, fMsg, rMsg;
	local int MessageType; // 0 = global, 1 = team, 2 = EVA, 3 = Radio

	if (Len(Msg) == 0)
		return;
	
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
 
	// Create Raw and Formatted Chat Messages

	if (PRI != None)
		cName = CleanHTMLMessage(PRI.PlayerName);
	else
		cName = "Host";


	if (MsgType == 'Special') 
	{
		if (MsgType == 'Special')
			fMsg = "<font color='" $HostColor$"'>" $cName$"</font>: <font color='#FFFFFF'>"$Msg$"</font>";
		PublicChatMessageLog $= fMsg $ "\n";
		rMsg = cName $": "$ Msg;
		MessageType = 0;
	}
	else if (MsgType == 'Say') 
	{
		if (PRI == None)
			fMsg = "<font color='" $HostColor$"'>" $cName$"</font>: <font color='#FFFFFF'>"$CleanHTMLMessage(Msg)$"</font>";
		else if (PRI.Team.GetTeamNum() == TEAM_GDI)
			fMsg = "<font color='" $GDIColor $"'>" $cName $"</font>: " $ CleanHTMLMessage(Msg);
		else if (PRI.Team.GetTeamNum() == TEAM_NOD)
			fMsg = "<font color='" $NodColor $"'>" $cName $"</font>: " $ CleanHTMLMessage(Msg);
		PublicChatMessageLog $= fMsg $ "\n";
		rMsg = cName $": "$ Msg;
		MessageType = 0;
	}
	else if (MsgType == 'TeamSay') {
		if (PRI.GetTeamNum() == TEAM_GDI)
		{
			fMsg = "<font color='" $GDIColor $"'>" $ cName $": "$ CleanHTMLMessage(Msg) $"</font>";
			PublicChatMessageLog $= fMsg $ "\n";
			rMsg = cName $": "$ Msg;
			MessageType = 1;
		}
		else if (PRI.GetTeamNum() == TEAM_NOD)
		{
			fMsg = "<font color='" $NodColor $"'>" $ cName $": "$ CleanHTMLMessage(Msg) $"</font>";
			PublicChatMessageLog $= fMsg $ "\n";
			rMsg = cName $": "$ Msg;
			MessageType = 1;
		}
	}
	else if (MsgType == 'Radio') {
		Msg = ParseRadioMessage(Msg);

		if (Rx_PRI(PRI).bGetIsCommander()) {
			fMsg = "<font color='" $CommandTextColor $"'>" $ "[Commander]" $ cName $": "$ Msg $"</font>"; 
		}
		else {
			fMsg = "<font color='" $RadioColor $"'>" $ cName $": "$ Msg $"</font>"; 
		}

		fMsg = HighlightStructureNames(fMsg); 
		//PublicChatMessageLog $= "\n" $ fMsg;
		rMsg = cName $ ": "$ Msg;
		MessageType = 3;
	}
	else if (MsgType == 'Commander') 
		{
			if (Left(Caps(msg), 2) == "/C") 
			{
				msg = Right(msg, Len(msg)-2);
				Rx_Controller(PlayerOwner).CTextMessage(msg,'Pink', 120.0,,true);
			}
			else if (Left(Caps(msg), 2) == "/R") 
			{
				msg = Right(msg, Len(msg)-2);
				Rx_Controller(PlayerOwner).CTextMessage(msg,'Pink', 360.0,,true);
			}
			fMsg = "<b><font color='" $CommandTextColor $"'>" $ "[Commander]"$ cName $": "$ CleanHTMLMessage(Msg) $"</font></b>";
			//PublicChatMessageLog $= "\n" $ fMsg;
			rMsg = cName $": "$ Msg;
			MessageType = 1;
		}
	else if (MsgType == 'System') {
		if(InStr(Msg, "entered the game") >= 0)
			return;
		fMsg = CleanHTMLMessage(Msg);
		PublicChatMessageLog $= fMsg $ "\n";
		rMsg = Msg;
		MessageType = 0;
	}
	else if (MsgType == 'PM') {
		if (PRI != None)
			fMsg = "<font color='"$PrivateFromColor$"'>Private from "$cName$": "$CleanHTMLMessage(Msg)$"</font>";
		else
			fMsg = "<font color='"$HostColor$"'>Private from "$cName$": "$CleanHTMLMessage(Msg)$"</font>";
		PrivateChatMessageLog $= fMsg $ "\n";
		rMsg = "Private from "$ cName $": "$ Msg;
		MessageType = 0;
	}
	else if (MsgType == 'PM_Loopback') {
		fMsg = "<font color='"$PrivateToColor$"'>Private to "$cName$": "$CleanHTMLMessage(Msg)$"</font>";
		PrivateChatMessageLog $= fMsg $ "\n";
		rMsg = "Private to "$ cName $": "$ Msg;
		MessageType = 0;
	}
	else if (MsgType == 'CTEXT')
	{
		fMsg = Msg;
		MessageType = 4;
	}
	else if (MsgType == 'AdminMsg' || MsgType == 'PM_AdminMsg') {
		MessageType = 5;
		// TODO: This should go through to the HUD somewhere
		fMsg = "<font color='#FFFFFF' size='20'>" $ CleanHTMLMessage(Msg) $ "</font>";
	}
	else if (MsgType == 'AdminWarn' || MsgType == 'PM_AdminWarn') {
		MessageType = 5;
		fMsg = "<font color='#FFFF00' size='25'>You received a Warning from an Admin</font><br><br><font color='#FFFFFF' size='20'>" $ CleanHTMLMessage(Msg) $ "</font>";
	}
	else
		MessageType = 2;

	// Add to currently active GUI | Edit by Yosh : Don't bother spamming the non-HUD chat logs with radio messages... it's pretty pointless for them to be there. 

	if(HudMovie != none && HudMovie.bMovieIsOpen)
	{
		if (MessageType == 0) {
			HudMovie.AddChatMessage(fMsg, rMsg);
		}
		else if (MessageType == 1) {
			HudMovie.AddChatMessage(fMsg, rMsg);
		}
		else if (MessageType == 2) {
			HudMovie.AddEVAMessage(CleanHTMLMessage(Msg));
		}
		else if (MessageType == 3) {
			HudMovie.AddRadioMessage(fMsg, rMsg);
		}
		else if (MessageType == 4) {
			HudMovie.AddCTextMessage(fMsg,LifeTime);	
		}
		else if (MessageType == 5) {
			HudMovie.PushAdminMessage(fMsg);
		}
	}	
	else
	{
		if(MsgType == 'System' 
			|| MsgType == 'CTEXT' 
			|| MsgType == 'AdminWarn' 
			|| MsgType == 'Radio'
			|| MessageType == 2) // these types are invalid and should not be registered in scoreboard/pause menu
			return;

		if (Scoreboard != none && Scoreboard.bMovieIsOpen) 
		{
			if (PlayerOwner.WorldInfo.GRI.bMatchIsOver) 
			{
				Scoreboard.AddChatMessage(fMsg, rMsg);
			}
		}		
		if (RxPauseMenuMovie != none && RxPauseMenuMovie.bMovieIsOpen) {
			if (RxPauseMenuMovie.ChatView != none) 
			{
				RxPauseMenuMovie.ChatView.AddChatMessage(fMsg, rMsg, MsgType=='PM' || MsgType=='PM_Loopback');
			}
			if(Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver)
			{
				LastEndScoreboardChats $= fMsg $ "\n";
			}
		}

	}
}

function string GetColouredName(PlayerReplicationInfo PRI)
{
	if (PRI.GetTeamNum() == TEAM_GDI)
	{
			return "<font color='" $GDIColor $"'>" $CleanHTMLMessage(PRI.PlayerName)$"</font>";
	}
	else if (PRI.GetTeamNum() == TEAM_NOD)
	{
			return "<font color='" $NodColor$"'>" $CleanHTMLMessage(PRI.PlayerName)$"</font>";
	}
	else return CleanHTMLMessage(PRI.PlayerName);
}

function string GetTeamColour(byte TeamIndex)
{
	if (TeamIndex == 0)
		return GDIColor;
	else if (TeamIndex == 1)
		return NodColor;
	else
		return NeutralColor;
}

static function string CleanHTMLMessage(string msg) // because it might be used elsewhere, turn this to static - Handepsilon
{
	msg = Repl(msg, "<", "&lt;");
	msg = Repl(msg, ">", "&gt;");
	msg = Repl(msg, "\\", "&#92;");
	return msg;
}

static function string RestoreHTMLFormat(string msg) // because previous CleanHTMLMessage might mess up formattings, try to restore most if not all... - Handepsilon
{
	//Italic
	msg = Repl(msg, "&lt;i&gt;", "<i>");
	msg = Repl(msg, "&lt;/i&gt;", "</i>");

	//Bold
	msg = Repl(msg, "&lt;b&gt;", "<b>");
	msg = Repl(msg, "&lt;/b&gt;", "</b>");

	// font
	msg = Repl(msg, "&lt;font", "<font");
	msg = Repl(msg, "&lt;/font&gt;", "</font>");

	//color end, may not always work
	msg = Repl(msg, "'&gt;", "'>");

	return msg;
}

simulated function PostBeginPlay() 
{
	super.PostBeginPlay();

	if (SystemSettingsHandler == none) 
	{
		SystemSettingsHandler = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_SystemSettingsHandler');
		SystemSettingsHandler.SetSettingBucket(SystemSettingsHandler.GraphicsPresetLevel);
		SystemSettingsHandler.PopulateSystemSettings();
		bShowScorePanel = SystemSettingsHandler.bScorePanel;
	}
	if (GraphicAdapterCheck == none)
	{
		GraphicAdapterCheck = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_GraphicAdapterCheck');
		GraphicAdapterCheck.CheckGraphicAdapter();
	}
	
	if (JukeBox == none)
	{
		JukeBox = new Rx_MapInfo(WorldInfo.GetMapInfo()).JukeboxClass;
		JukeBox.Init();
		WorldInfo.MusicComp = JukeBox.MusicComp;
		WorldInfo.MusicComp.OnAudioFinished = MusicPlayerOnAudioFinished;

		if(Rx_MapInfo(WorldInfo.GetMapInfo()).DisableMusicAutoPlay)
		{
			`log("Rx_HUD::Jukebox AutoPlay music disabled by map.");
		}
		else
		{
			`log ("Rx_HUD::Jukebox" @ `showvar(SystemSettingsHandler.bAutostartMusic));
			//Disable this if we do not want to play on start.
			if (SystemSettingsHandler.bAutostartMusic) {
				if (JukeBox.bShuffled) {
					JukeBox.Play(Rand(JukeBox.JukeBoxList.Length));
				} else {
					JukeBox.Play(0);
				}
			}
		}
	}

	CreateUIInterface();

	SetTimer(0.1,false,'AttemptCacheBuildings');
}

function AttemptCacheBuildings()
{
	local Rx_Building B;
	
	if(TeamBuildingInternals.Length > 0)
		return;
	// a cache for things to come
	foreach WorldInfo.AllActors(class'Rx_Building',B)
	{
		if(Rx_Building_Team_Internals(B.BuildingInternals) != None)
			TeamBuildingInternals.AddItem(Rx_Building_Team_Internals(B.BuildingInternals));
	
		if(Rx_Building_TechBuilding(B) != None)
			TechBuildings.AddItem(Rx_Building_TechBuilding(B));

	}	
}

function ResetVignette()
{
	if(HUDVignette != none)
	{
		HUDVignette.Reset();
	}
}

function UpdateRadioCommandList()
{
	switch (SystemSettingsHandler.RadioCommand)
	{
		case 2:
			SetRadioCommandsCustom();
		break;
		case 1:
			SetRadioCommandsClassic();
		break;
		default:
			SetRadioCommandsDefault();
	}
}

function MusicPlayerOnAudioFinished(AudioComponent AC)
{
	local int i;

	`log("MusicPlayerOnAudioFinished :: bStopped? "$ JukeBox.bStopped $" | AC? " $ AC.Name $" | SoundCue? "$ AC.SoundCue,bDebug);
	if (JukeBox.bStopped)
		return;

	//find the current index
	i = JukeBox.JukeBoxList.Find('TheSoundCue', WorldInfo.MusicComp.SoundCue);
	if (i < 0)
		return;

	//check if we're shuffling
	if (JukeBox.bShuffled)
		JukeBox.PlayShuffled();
	else if (i + 1 < JukeBox.JukeBoxList.Length)
		JukeBox.Play(i+1);
	else
		JukeBox.Play(0);

	i = JukeBox.JukeBoxList.Find('TheSoundCue', WorldInfo.MusicComp.SoundCue);
	
	if (RxPauseMenuMovie != none && RxPauseMenuMovie.SettingsView.MusicTracklist != none)
	{
			RxPauseMenuMovie.SettingsView.MusicTracklist.SetInt("selectedIndex", i);

		if (RxPauseMenuMovie.SettingsView.TrackNameLabel != none)
		{
			if (i >= 0)
				RxPauseMenuMovie.SettingsView.TrackNameLabel.SetText(JukeBox.JukeBoxList[i].TrackName);
			else
				RxPauseMenuMovie.SettingsView.TrackNameLabel.SetText("");
		}
	}
}

function bool IsMainMenu()
{
	return (Rx_Game(PlayerOwner.WorldInfo.Game) != None && Rx_Game(PlayerOwner.WorldInfo.Game).GameType == 0);
}

//Create and initialize the UI Interface.
function CreateUIInterface()
{
	if(IsMainMenu())
		return;

	//CreateDamageSystemMovie();
	CreateGIHUDMovie();
	CreateHUDMovie();
	CreateHudCompoenents();
}

//Create and initialize the HUDMovie.
function CreateHUDMovie()
{
	//Create a STGFxHUD for HudMovie
	HudMovie = new HudMovieClass;
	//Set the timing mode to TM_Real - otherwide things get paused in menus
	HudMovie.SetTimingMode(TM_Real);
	//Call HudMovie's Initialise function
	HudMovie.Initialize();
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.SetViewScaleMode(SM_NoBorder);
	HudMovie.SetAlignment(Align_TopLeft);

	HudMovie.RenxHud = self;
}

function CreateGIHUDMovie()
{
	//Create a STGFxHUD for HudMovie
	GIHudMovie = new GIHudMovieClass;
	//Set the timing mode to TM_Real - otherwide things get paused in menus
	GIHudMovie.SetTimingMode(TM_Real);
	//Call HudMovie's Initialise function
	GIHudMovie.Initialize();
	GIHudMovie.SetTimingMode(TM_Real);
	GIHudMovie.SetViewScaleMode(SM_NoBorder);
	GIHudMovie.SetAlignment(Align_TopLeft);

	GIHudMovie.RenxHud = self;
}


//Create and initialize hud components
function CreateHudCompoenents()
{
	TargetingBox = New TargetingBoxClass;
	PlayerNames = New PlayerNamesClass;
	CaptureProgress = New CaptureProgressClass;
	CommandText = New CommandTextClass;
	HUDVignette = new HUDVignetteClass;
	HUDVignette.InitMaterial();	 
}

function UpdateHudCompoenents(float DeltaTime, Rx_HUD HUD)
{
	if(DrawTargetBox)	TargetingBox.Update(DeltaTime,HUD);  // Targetting box isn't fully seperated from this class yet so we can't update it here.
	if(DrawPlayerNames)	PlayerNames.Update(DeltaTime,HUD);
	if(DrawCaptureProgress) CaptureProgress.Update(DeltaTime,HUD);
	if(DrawCText)	CommandText.Update(DeltaTime,HUD);
	if(HUDVignette != none) HUDVignette.Update(DeltaTime,HUD);
	if(Rx_Controller(PlayerOwner).Vet_Menu != none) Rx_Controller(PlayerOwner).Vet_Menu.UpdateTiles(DeltaTime, HUD);
}

function DrawHudCompoenents()
{
	if(DrawTargetBox)	TargetingBox.Draw(); // Targeting box isn't fully separated from this class yet so we can't draw it here.
	if(DrawPlayerNames)	PlayerNames.Draw();
	if(DrawCaptureProgress)	CaptureProgress.Draw();
	if(Rx_Controller(PlayerOwner).Vet_Menu != none) Rx_Controller(PlayerOwner).Vet_Menu.DrawTiles(self);
	if(HUDVignette != none) HUDVignette.Draw();
}

function RemoveMovies()
{
	//@Shahman: we will begin monitoring the scaleform removal procedure

	//Let's start by Tracing our last function calls
	`log("======================= " $self.Class $" =========================",bDebug);
	//ScriptTrace();
	// We will now check if each active GFx class has any movie open or not. 
	// ONLY when it is still open and active, we will CLOSE them. we can't CLOSE something that is no longer exists.
	// this could be the main reason of the crash in the first place. but as of (5/9/2014), its too early to tell.
	// for now, we need to monitor this.

	if (Scoreboard != none) {
		`log("Scoreboard.bMovieIsOpen? " $ Scoreboard.bMovieIsOpen,bDebug);
		if (Scoreboard.bMovieIsOpen) {
			Scoreboard.Close(true);
		}
		Scoreboard = none;
	}		

	if (PTMovie != none) {
		`log("PTMovie.bMovieIsOpen? " $ PTMovie.bMovieIsOpen,bDebug);
		if (PTMovie.bMovieIsOpen) {
			PTMovie.ClosePTMenu(true);
		}
		PTMovie = none;
	}
	if ( RxPauseMenuMovie != None ) {
		`log("RxPauseMenuMovie.bMovieIsOpen? " $ RxPauseMenuMovie.bMovieIsOpen,bDebug);
		if (RxPauseMenuMovie.bMovieIsOpen) {
			RxPauseMenuMovie.Close(true);
		}
		RxPauseMenuMovie = None;
	}
	if( HudMovie != None) {
		`log("HudMovie.bMovieIsOpen? " $ HudMovie.bMovieIsOpen,bDebug);
		if (HudMovie.bMovieIsOpen) {
			HudMovie.close(true);
		}
		HudMovie = None;
	}
	if( GIHudMovie != None) {
		`log("GIHudMovie.bMovieIsOpen? " $ GIHudMovie.bMovieIsOpen,bDebug);
		if (GIHudMovie.bMovieIsOpen) {
			GIHudMovie.close(true);
		}
		GIHudMovie = None;
	}
	if (OverviewMapMovie != None) {
		if (OverviewMapMovie.bMovieIsOpen) {
			OverviewMapMovie.Close(true);
		}
		OverviewMapMovie = none;
	}
	Super.RemoveMovies();
}

singular event Destroyed()
{
	RemoveMovies();
	// Making sure object references aren't causing crashes.
	TargetingBox = None;
	PlayerNames = None;
	CaptureProgress = None;

	if (SystemSettingsHandler != none) {
		SystemSettingsHandler.Destroy();
		SystemSettingsHandler = none;
	}

	if (GraphicAdapterCheck != none) {
		GraphicAdapterCheck.Destroy();
		GraphicAdapterCheck = none;
	}

	if (JukeBox != none) {
		JukeBox.MusicComp.ResetToDefaults();
		JukeBox.MusicComp.bAutoDestroy = true;
		JukeBox.MusicComp.Stop();
	}


	Super.Destroyed();
}


//Called every tick the HUD should be updated
event PostRender() 
{
	local float XL, YL, YPos;
	local font TempFont;
	local Rx_RangeDummy_NoArmour Dummy;
	local LocalPlayer LP;
	local Vector2d EnemyScreenPos;
	local bool bIsInFrontOfMe;

	if(HudMovie != None && HudMovie.bMovieIsOpen && DrawFlashHUD)
		HudMovie.TickHUD(); //Draw flash HUD
	if(GIHudMovie != None && GIHudMovie.bMovieIsOpen && DrawFlashHUD)	
		GIHudMovie.TickHUD();

	if(Scoreboard != None && Scoreboard.bMovieIsOpen)
		Scoreboard.Draw(); 	

	//TODO: find another way to do this
	if (RxPauseMenuMovie != None && RxPauseMenuMovie.bMovieIsOpen) {
		RxPauseMenuMovie.TickHUD();
	}
	
	// Pre calculate most common variables
	if (SizeX != Canvas.SizeX || SizeY != Canvas.SizeY)
		PreCalcValues();

	// Set up delta time
	RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
	LastHUDRenderTime = WorldInfo.TimeSeconds;


	ProcessFade(RenderDelta);
		
	UTGRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (!WorldInfo.IsPlayingDemo() && !IsMainMenu())
	{
		TempFont = Canvas.Font;
		DisplayRadioCommands();
		DrawTaunts();
		//DrawCommanderMiniWindow(); 
		Canvas.Font = TempFont;
	}
	
	if (UTGRI != None && UTGRI.bMatchIsOver)
	{
		if(PTMovie != none)
		{
			if (PTMovie.bMovieIsOpen) {
				PTMovie.ClosePTMenu(true);
			}			
			PTMovie = none;
		}
			
		return;	
	}
	
	if (Rx_Controller(PlayerOwner) != None && PTMovie != none && PTMovie.bMovieIsOpen && (Rx_Controller(PlayerOwner).bIsInPurchaseTerminal || Rx_Controller(PlayerOwner).bIsInPurchaseTerminalVehicleSection)) {
		PTMovie.TickHUD();
		return;
	}

	if(!bShowHUD)
		return;

	UpdateScreenCentreActor();

	// Update and draw hud components.
	UpdateHudCompoenents(RenderDelta,self);
	DrawHudCompoenents();
	
	if(Rx_Controller(PlayerOwner).IsSpectating() && PlayerOwner.WorldInfo.GRI.bMatchHasBegun)
	{
		if(!PlayerOwner.IsInState('PlayerWaiting'))
		{
			if(HudMovie != None)
				HudMovie.GameplayTipsText.SetVisible(false);
			DrawSpecmodeInfos();
		}
		else
		{
			if(HudMovie != None)
				HudMovie.GameplayTipsText.SetText("Press Fire to Spawn!");			
		}
	}

	DoSpotting();
	//DoCommandSpotting(); 
	//DrawSpotTargets();
	DrawPlayAreaAnnouncement();
	DrawReticule();
	 
	//This is the one thing that needs to be drawn over the scope/crosshair overlay for warnings 
	if(DrawCText)	
		CommandText.Draw(); 
	
   if((PlayerOwner.Pawn != None || PlayerOwner.PlayerReplicationInfo.bIsSpectator) && bShowScorePanel) 
      DrawNewScorePanel();
	
	if (bShowDebugInfo)
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
	}

	if (bShowAllAI)
		DrawAIOverlays();
	else if(bShowAIFireline) // don't render if ShowAllAI is active
		DrawAIFirelineOverlays();

	ForEach WorldInfo.AllActors(class'Rx_RangeDummy_NoArmour', Dummy)
	{
		if (Dummy.DPS == 0) continue;

		LP = LocalPlayer(PlayerOwner.Player);
		Canvas.SetDrawColor(255,255,255,200);
		Canvas.Font = Font'RenxHud.Font.AgentConDB';
	
		// Convert self and enemy world location to screen-space 2d coordinates
		EnemyScreenPos = LP.Project(Dummy.Location);
	
		Canvas.SetPos(EnemyScreenPos.X * Canvas.SizeX, EnemyScreenPos.Y * Canvas.SizeY);
	
		bIsInFrontOfMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Dummy.Location, PlayerOwner.Rotation, PlayerOwner.Pawn.Location) < -0.5;
	
		if (!bIsInFrontOfMe) return;
		
		Canvas.DrawText("Peak DPS:"@Dummy.PeakDPS$"\nDPS:"@Dummy.DPS$"\nTotal Dmg:"@Dummy.TotalDamageTaken$"\nTotal Hits:"@Dummy.TotalHitsTaken,,0.7,0.7);
	}

	if (SystemSettingsHandler.RadioCommand != RadioCommand)
	{
		UpdateRadioCommandList();
	}
}

function DisplayCapturePoint(Rx_CapturePoint CP)
{
	CurrentCapturePoint = CP;
}

function UndisplayCapturePoint(Rx_CapturePoint CP)
{
	if (CurrentCapturePoint == CP)
		CurrentCapturePoint = None;
}

function ClearCapturePoint()
{
	CurrentCapturePoint = None;
}

function DrawSpecmodeInfos()
{
	local float XL, YL;
	
	XL = Canvas.ClipX * 0.05;
	YL = Canvas.Clipy * 0.65;
	Canvas.SetPos(XL,YL);

	Canvas.Font = MultiFont'UI_Fonts_Final.HUD.MF_Large';
	Canvas.TextSize ("A", XL, YL, 0.6f, 0.6f);
	Canvas.DrawColor = ConsoleColor;
	if(PlayerOwner.ViewTarget != None && UTVehicle(PlayerOwner.ViewTarget) != None)
		Canvas.DrawText(UTVehicle(PlayerOwner.ViewTarget).GetSeatPRI(0).GetHumanReadableName());
	else if(PlayerOwner.ViewTarget != None && Rx_Controller(PlayerOwner.ViewTarget) == None)
		Canvas.DrawText(PlayerOwner.ViewTarget.GetHumanReadableName());	
	
	XL = Canvas.ClipX * 0.05;
	YL = Canvas.Clipy * 0.7;
	Canvas.Font = MultiFont'UI_Fonts_Final.HUD.MF_Small';	
	Canvas.TextSize ("A", XL, YL, 0.6f, 0.6f);
	Canvas.SetPos(XL,YL);
	Canvas.DrawText("'L' - Lock Rotation");
	Canvas.DrawText("'Alt Fire' - Freeview");
	Canvas.DrawText("'MouseWheel' - Switch Players");
}

function DrawSpotTargets()
{
	local actor SpotTarget;
	//local int i;
	local vector screenLoc;
	local bool bIsBehindMe;
	
	foreach SpotTargets(SpotTarget)
	{
		if(Rx_Building(SpotTarget) != None || Rx_Vehicle_Harvester(SpotTarget) != None || Rx_Defence(SpotTarget) != None
			|| (SpotTarget.GetTeamNum() == PlayerOwner.GetTeamNum()))
			continue;	
			
		if(RxIfc_Stealth(SpotTarget) != None && RxIfc_Stealth(SpotTarget).GetIsinTargetableState() == false)
			continue;			
			
		bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(PlayerOwner.ViewTarget.Location,PlayerOwner.Rotation,SpotTarget.location) < -0.5;
		
		if(bIsBehindMe || (Rx_Building(SpotTarget) == None && !FastTrace(SpotTarget.location,PlayerOwner.ViewTarget.Location,,true)))
		{
			if(Rx_Building(SpotTarget) == None)
			continue;
		}
		
		screenLoc = Canvas.Project(SpotTarget.location);
		ScreenLoc.X -= 25.5;
		ScreenLoc.Y -= 25;
		Canvas.SetPos(ScreenLoc.X, ScreenLoc.Y);	

		Canvas.SetDrawColor(255,0,0,255);
		Canvas.DrawIcon(EnemySpottedIcon,screenLoc.X-SizeX*0.005,screenLoc.Y-SizeY*0.01);	
	}
}

function PreCalcValues()
{
	super.PreCalcValues();
    // position of ScorePanel
    ScorePanelX = SizeX - 30*RatioX;
}

exec function ShowAllAI()
{
	bShowAllAI = !bShowAllAI;
}

exec function ShowAIFireline()
{
	bShowAIFireline = !bShowAIFireline;
}

exec function BumpVignette(byte T, int Intensity)
{
	local LinearColor LC;
	
	if(T == 0)
	{
		LC.R = 0.33; 
		LC.G = 0.1;
		LC.B = 0.5; 
	}
	else if(T == 1)
	{
		LC.R = 0.0; 
		LC.G = 1.0;
		LC.B = 0.9; 
	}
	else if(T == 2)
	{
		LC.R = 0.0; 
		LC.G = 1.0;
		LC.B = 1.0; 
	}
	
	
	HUDVignette.VignetteTakeHit(LC,Intensity);
}

//draws AI goal overlays over each AI pawn
function DrawAIOverlays()
{
	local UTBot B;
	local vector Pos;
	local float XL, YL;
	local string Text;

	Canvas.Font = GetFontSizeIndex(0);

	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		if (B.Pawn != None)
		{
			// draw route
			DrawRoute(B.Pawn);
			
			// draw goal string
			if ((vector(PlayerOwner.Rotation) dot (B.Pawn.Location - PlayerOwner.ViewTarget.Location)) > 0.f)
			{
				Pos = Canvas.Project(B.Pawn.Location + B.Pawn.GetCollisionHeight() * vect(0,0,1.1));
				Text = "("$B.GetOrders()$")"$B.GetHumanReadableName()$"<<"$Rx_Bot(B).PTTask$">>"$ ":" @ B.GoalString;
				Canvas.StrLen(Text, XL, YL);
				Pos.X = FClamp(Pos.X, 0.f, Canvas.ClipX - XL);
				Pos.Y = FClamp(Pos.Y, 0.f, Canvas.ClipY - YL);
				Canvas.SetPos(Pos.X, Pos.Y);
				
				if (B.PlayerReplicationInfo != None && B.PlayerReplicationInfo.Team != None)
				{
					Canvas.DrawColor = UTTeaminfo(B.PlayerReplicationInfo.Team).GetHUDColor();
					// brighten the color a bit
					Canvas.DrawColor.R = Min(Canvas.DrawColor.R + 64, 255);
					Canvas.DrawColor.G = Min(Canvas.DrawColor.G + 64, 255);
					Canvas.DrawColor.B = Min(Canvas.DrawColor.B + 64, 255);
				}
				else
					Canvas.DrawColor = ConsoleColor;
				
				Canvas.DrawColor.A = (WorldInfo.TimeSeconds - B.Pawn.LastRenderTime < 0.1) ? 255 : 128;
				Canvas.DrawText(Text);
			}
		}
	}
}

function DrawAIFirelineOverlays()
{
	local UTBot B;
	local vector Pos;
	local float XL, YL;
	local string Text;

	Canvas.Font = GetFontSizeIndex(0);

	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		if (B.Pawn != None)
		{
			// draw route
			DrawRoute(B.Pawn);
			
			// draw fire line string
			if ((vector(PlayerOwner.Rotation) dot (B.Pawn.Location - PlayerOwner.ViewTarget.Location)) > 0.f)
			{
				Pos = Canvas.Project(B.Pawn.Location + B.Pawn.GetCollisionHeight() * vect(0,0,1.1));
				Text = Rx_Bot(B).FireAssessment;
				Canvas.StrLen(Text, XL, YL);
				Pos.X = FClamp(Pos.X, 0.f, Canvas.ClipX - XL);
				Pos.Y = FClamp(Pos.Y, 0.f, Canvas.ClipY - YL);
				Canvas.SetPos(Pos.X, Pos.Y);
				
				if (B.PlayerReplicationInfo != None && B.PlayerReplicationInfo.Team != None)
				{
					Canvas.DrawColor = UTTeaminfo(B.PlayerReplicationInfo.Team).GetHUDColor();
					// brighten the color a bit
					Canvas.DrawColor.R = Min(Canvas.DrawColor.R + 64, 255);
					Canvas.DrawColor.G = Min(Canvas.DrawColor.G + 64, 255);
					Canvas.DrawColor.B = Min(Canvas.DrawColor.B + 64, 255);
				}
				else
					Canvas.DrawColor = ConsoleColor;
				
				Canvas.DrawColor.A = (WorldInfo.TimeSeconds - B.Pawn.LastRenderTime < 0.1) ? 255 : 128;
				Canvas.DrawText(Text);
			}
		}
	}
}

function DoSpotting()
{
	local bool bPlayerIsSpotting;
	local Actor StealthedActor, TargetActor;
	
	if(Rx_Controller(PlayerOwner) == None)
		return;
	
	TargetActor = TargetingBox.TargetedActor != None ? TargetingBox.TargetedActor.GetActualTarget() : none; 
	bPlayerIsSpotting = Rx_Controller(PlayerOwner).bSpotting;
	
	if (bPlayerIsSpotting)
	{
		// if we have an actor targeted, and it's not already spotted
		if (TargetActor != None && SpotTargets.Find(TargetActor) == -1)
		{
			// If we're spotting a building
			if ( Rx_Building(TargetActor) != None || Rx_BuildingAttachment(TargetActor) != None)
				AddNewSpotTarget(Rx_Building(TargetActor) != None ? TargetActor : Rx_BuildingAttachment(TargetActor).OwnerBuilding.BuildingVisuals);
			else 			
				AddNewSpotTarget(TargetActor);
		}
		else if(TargetActor == None && RxIfc_Stealth(GetActorWeaponIsAimingAt()) != None)
		{
			StealthedActor = GetActorWeaponIsAimingAt();
			if (RxIfc_Stealth(StealthedActor).GetIsinTargetableState())
				AddNewSpotTarget(StealthedActor);		
		}
	}
	
}

function DoCommandSpotting() //Mostly like DoSpotting(), but handled differently elsewhere
{
	
	if(Rx_Controller(PlayerOwner).bCommandSpotting == false || Rx_Controller(PlayerOwner) == None )
		return;

	if(TargetingBox.TargetedActor != None && !TargetingBox.TargetedActor.IsCommandSpottable() )
		return; 
		
		// if we have an actor targeted, and it's not already spotted [EDIT: remove anything regarding buildings and stealthed units for C-Spotting]
		if (TargetingBox.TargetedActor.GetActualTarget() != None && CommandSpotTargets.Find(TargetingBox.TargetedActor.GetActualTarget()) == -1)
		{
				AddCommanderSpotTarget(TargetingBox.TargetedActor.GetActualTarget());
		}
	
	
	
	
}


function Actor GetTargetFromVehicle(Rx_Vehicle VehicleActor)
{
	local byte i;
	local Pawn PawnOwner; 

	PawnOwner = Pawn(PlayerOwner.ViewTarget);
	if (VehicleActor == None) {
		return None;
	}
	for (i = 0; i < VehicleActor.Seats.Length; i++) {
		if (VehicleActor.Seats[i].SeatPawn ==  PawnOwner) {
			return VehicleActor.Seats[i].AimTarget;
		}
	}
}

function Actor GetTargetFromTrace(out vector HitLocation)
{
	local vector HitNormal, StartTrace, EndTrace;
	local Actor TraceActor;
	local UTWeapon WeaponOwner;
	local Pawn PawnOwner; 
	local float TraceRange;

	PawnOwner = Pawn(PlayerOwner.ViewTarget);
	WeaponOwner = UTWeapon(PawnOwner.Weapon);

	if (WeaponOwner == None || !WeaponOwner.EnableFriendlyWarningCrosshair())
		return None;

	StartTrace = WeaponOwner.InstantFireStartTrace();
	TraceRange = 15000;
	EndTrace = StartTrace + TraceRange * vector(PlayerOwner.Rotation);
	TraceActor = PawnOwner.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true, vect(0,0,0),, TRACEFLAG_Bullet);			

	if (Rx_Pawn(TraceActor) != None || Rx_Vehicle(TraceActor) != None || Rx_Weapon_DeployedActor(TraceActor) != None ||
		Rx_Building(TraceActor) != None || Rx_BuildingAttachment(TraceActor) != None)
	{
		return TraceActor;
	} 
	else
		return (TraceActor == None) ? None : Pawn(TraceActor.Base);
}

function float GetProjectileRange(Weapon W)
{
	local class<Projectile> ProjectileClass;
	local float Range;
	ProjectileClass = Rx_Weapon(W).GetProjectileClassSimulated();
	Range = ProjectileClass.default.LifeSpan * ProjectileClass.default.Speed;
	return Range;
}

function AddNewSpotTarget(actor SpotTarget) 
{
	
	if(LastSpotTarget != SpotTarget && SpotTargets.Find(SpotTarget) == -1) 
	{
		if(Pawn(SpotTarget) != None && (Pawn(SpotTarget).Health <= 0 || Pawn(SpotTarget).GetTeamNum() == 255))
			return;
			
		if(Rx_Building(SpotTarget) != None && Rx_Building(SpotTarget).IsDestroyed())
			return;
			
		SpotTargets.AddItem(SpotTarget);
		LastSpotTarget = SpotTarget;
		
		if(SpotTargets.Length > 1 && 
			(Rx_Building(SpotTargets[0]) != None || Rx_Vehicle_Harvester(SpotTargets[0]) != None || 
				Rx_Defence(SpotTargets[0]) != None)) 
		{
			SpotTargets.Remove(0,1);	
		}
	}
}

function AddCommanderSpotTarget(actor SpotTarget)
{
	local Rx_Controller PC; 
	
	PC=Rx_Controller(PlayerOwner) ;
	//0 is ATTACK / 1 is DEFEND. Return if invalid targets are being looked at
	
	if( (PC.Spotting_Mode == 0 && SpotTarget.GetTeamNum() == PC.GetTeamNum() ) || 
		PC.Spotting_Mode == 1 && SpotTarget.GetTeamNum() != PC.GetTeamNum() ) 
		return;
	
	if(LastSpotTarget != SpotTarget && CommandSpotTargets.Find(SpotTarget) == -1) 
	{
		if(Pawn(SpotTarget) != None && (Pawn(SpotTarget).Health <= 0 || Pawn(SpotTarget).GetTeamNum() == 255))
			return;
			
		CommandSpotTargets.AddItem(SpotTarget);
		LastSpotTarget = SpotTarget;
		
	}
}

function DrawNewScorePanel()
{
	local float YL, SizeSX, SizeSY;
	local int /*  FirstTeamID ,*/ I;
	local PlayerReplicationInfo PRI;	
	local FontRenderInfo FontInfo;
	local Vector2D GlowRadius;
	local Rx_Pawn P;
	local RxIfc_SpotMarker SpotMarker;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;
	local Actor TempActor;
	local String TempStr;
	local int TempCredits;
	local float ResScaleY; 
	local CanvasIcon Temp_Icon;
	
	// If we have no GRI, no point in drawing the score panel.
	if(WorldInfo.GRI == none)
		return;
	
	//Honestly looks better without scaling. Just wait for Flash on this one I 
	ResScaleY = 1.0 ; //Canvas.SizeY/1080.0;
	
	
	//Canvas.Font = Font'RenXFonts.Agency12';
	//Canvas.Font = GetFontSizeIndex(1);
	Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small'; //Font'RenXHud.Font.AS_small';
	Canvas.TextSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ", SizeSX, SizeSY, 0.6f*ResScaleY, 0.6f*ResScaleY);
	
    FontInfo = Canvas.CreateFontRenderInfo(true);
    FontInfo.bClipText = true;
    FontInfo.bEnableShadow = true;
    FontInfo.GlowInfo.GlowColor = MakeLinearColor(1.0, 0.0, 0.0, 1.0);
    GlowRadius.X=2.0;
    GlowRadius.Y=1.0;
    FontInfo.GlowInfo.bEnableGlow = true;
    FontInfo.GlowInfo.GlowOuterRadius = GlowRadius;	

	YL = (ScorePanelY * Canvas.SizeY/1050.0) + SizeSY + 10.0f*ResScaleY;

	DrawScorePanelTitle(,YL - ScorePanelY*ResScaleY);
	YL += SizeSY + 10.0f*ResScaleY;

	if(WorldInfo.TimeSeconds - LastScoreboardRenderTime > 1.0)
	{ 
		PRIArray = WorldInfo.GRI.PRIArray;
		
		foreach WorldInfo.GRI.PRIArray(pri)
		{
			if(Rx_Pri(pri) == None || Rx_PRI(PRI).bIsScripted)
				PRIArray.RemoveItem(pri);
		}
		
		PRIArray.Sort(SortPriDelegate);
		LastScoreboardRenderTime = WorldInfo.TimeSeconds;	  
		if(bDrawAdditionalPlayerInfo)
		{
			ForEach DynamicActors(class'Rx_Pawn', P)
			{
				if(PlayerOwner.GetTeamNum() != P.GetTeamNum())
					continue;
				ForEach PRIArray(PRI)
				{
					if ( P.PlayerReplicationInfo == PRI )
					{
						foreach AllActors(class'Actor',TempActor,class'RxIfc_SpotMarker') {
							SpotMarker = RxIfc_SpotMarker(TempActor);
							DistToSpot = VSizeSq(TempActor.location - P.location);
							if(NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist) {
								NearestSpotDist = DistToSpot;	
								NearestSpotMarker = SpotMarker;
							}
						}
						Rx_Pri(PRI).SetPawnArea(NearestSpotMarker.GetNonHTMLSpotName());
						break;
					}
				}
			}
		}  	
	}

	switch (ScorePanelMode)
	{
		case 0: // show all players in list with points and rank
		case 1:
			for (I = 0; I < PRIArray.Length ; I++)
			{
				if(PRIArray[I] == None)
					continue;
				
				TempStr = "";
				Temp_Icon = VetRankIcons[0]; // Always show recruit icon if all else fails.
				
				if (!PRIArray[I].bIsSpectator)
				{
					if(Rx_PRI(PRIArray[I]).Team == None)
						continue;
					if (PRIArray[I].Owner == self.Owner)
						Canvas.SetDrawColor(0,255,0,255);
					else
					{
						Canvas.DrawColor = UTTeamInfo(Rx_PRI(PRIArray[I]).Team).GetHUDColor();
						if(PRIArray[i].bBot)
						{
							Canvas.DrawColor.R *= 0.6;
						}
						else if(Rx_PRI(PRIArray[I]).bIsAFK)
						{
							Canvas.DrawColor = Canvas.DrawColor * 0.75;
							if(Canvas.DrawColor.B <= 0)
								Canvas.DrawColor.B = 64;

							if(Canvas.DrawColor.G <= 0)
								Canvas.DrawColor.B = 64;
						}
					}
					Canvas.SetPos(DrawStartX[0] - 40.0*ResScaleY, YL);
					Canvas.DrawText(I+1, false,,,FontInfo);
					Temp_Icon = VetRankIcons[Rx_Pri(PRIArray[I]).VRank];
					
					Canvas.DrawIcon(Temp_Icon,DrawStartX[0] - 5.0*ResScaleY-40, YL-18.0, 0.75);		
				      
					Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);					
					
					if(bDrawAdditionalPlayerInfo)
					{
						if(PlayerOwner.GetTeamNum() == PRIArray[I].GetTeamNum())
						{
							TempCredits = Rx_PRI(PRIArray[I]).GetCredits();
							if(Rx_Pri(PRIArray[I]).CharClassInfo == class'Rx_FamilyInfo_GDI_Engineer'
									|| Rx_Pri(PRIArray[I]).CharClassInfo == class'Rx_FamilyInfo_Nod_Engineer')
								TempStr = " >>Engi";
							else if(Rx_Pri(PRIArray[I]).CharClassInfo == class'Rx_FamilyInfo_GDI_Hotwire'
									|| Rx_Pri(PRIArray[I]).CharClassInfo == class'Rx_FamilyInfo_Nod_Technician')
								TempStr = " >>Adv. Engi";	
						}					
						Canvas.SetDrawColor(50, 50,50, 255);
						Canvas.SetPos(DrawStartX[0] - 10.0*ResScaleY, YL);
						if(PlayerOwner.GetTeamNum() == PRIArray[I].GetTeamNum())
						{
							Canvas.DrawRect(StrLeng(PRIArray[I].GetHumanReadableName()$" | "$TempCredits$" | "
									$Rx_PRI(PRIArray[I]).GetPawnArea()
									$TempStr)+10.0*ResScaleY,15.0*ResScaleY);
						} else
						{
							Canvas.DrawRect(StrLeng(PRIArray[I].GetHumanReadableName())+10.0*ResScaleY,15.0*ResScaleY);
						}
						
						if (PRIArray[I].Owner == self.Owner)
							Canvas.SetDrawColor(0,255,0,255);
						else
							Canvas.DrawColor = UTTeamInfo(Rx_PRI(PRIArray[I]).Team).GetHUDColor();									
						
						Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);
						
						if(PlayerOwner.GetTeamNum() == PRIArray[I].GetTeamNum())
						{						
							Canvas.DrawText(PRIArray[I].GetHumanReadableName()$" | "$TempCredits$" | "
								$Rx_PRI(PRIArray[I]).GetPawnArea()
								$TempStr
								, false,,,FontInfo);
						}
						else
							Canvas.DrawText(PRIArray[I].GetHumanReadableName()
								, false,,,FontInfo);						
					}
					else
					{
						Canvas.DrawText(PRIArray[I].GetHumanReadableName(), false,,,FontInfo);	
					}
						
					Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_Pri(PRIArray[I]).GetRenScore()), YL);			
			
					Canvas.DrawText(Rx_Pri(PRIArray[I]).GetRenScore(), false,,,FontInfo);
					YL += SizeSY + 5.0f*ResScaleY; //5.0f*ResScaleY;
				}
			}
			break;
		case 2: // show only players score and position
			TempStr = "";

			Canvas.SetDrawColor(0,255,0,255);
			Canvas.SetPos(DrawStartX[0] - 40.0*ResScaleY, YL);
			Canvas.DrawText(I+1, false,,,FontInfo);
		      
			Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);						
			Canvas.DrawText(PlayerOwner.PlayerReplicationInfo.GetHumanReadableName(), false,,,FontInfo);	
			Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore()), YL);
			Canvas.DrawText(Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore(), false,,,FontInfo);
			YL += SizeSY + 5.0f*ResScaleY;
		
	   default:
			break;					
	}
	
	if(ScorePanelMode != 2)
		for (I = 0; I < PRIArray.Length ; I++)
		{
			if(PRIArray[I] == None || !PRIArray[I].bIsSpectator)
				continue;
			
			Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.DrawText(PRIArray[I].GetHumanReadableName());	
			YL += SizeSY + 10.0f*ResScaleY;		
		}
	
	if(bDrawAdditionalPlayerInfo)
	{
		YL += SizeSY + 10.0f*ResScaleY;
		Canvas.SetPos(DrawStartX[0]-40*ResScaleY, YL);
		Canvas.SetDrawColor(0, 255, 0, 255);
		Canvas.DrawText("Your score this minute: " $ Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore()-Rx_Pri(PlayerOwner.PlayerReplicationInfo).ScoreLastMinutes, false,,,FontInfo);
	} 
	
}

function DrawHarvesterHealth(int TeamID, float YL, FontRenderInfo FontInfo)
{
	local Rx_Vehicle_Harvester harv;
	
	if(GDI_Harvester == None || Nod_Harvester == None)
	{
		ForEach DynamicActors(class'Rx_Vehicle_Harvester',harv)
		{
			if(harv.GetTeamNum() == TEAM_GDI)
				GDI_Harvester = harv;
			else
				Nod_Harvester = harv;
		}	
	}
	
	Canvas.SetDrawColor(50, 50,50, 255);
	Canvas.SetPos(DrawStartX[0] + 30, YL);
	Canvas.DrawRect(StrLeng("Harvester:")+10,13);
	Canvas.DrawColor = Rx_TeamInfo(WorldInfo.GRI.Teams[TeamID]).GetTeamColor();
	Canvas.SetPos(DrawStartX[0] + 35, YL);
	Canvas.DrawText("Harvester:", false,,,FontInfo);
	Canvas.SetDrawColor(82, 163, 0, 255);
	Canvas.SetPos(DrawStartX[0] + 40 + StrLeng("Harvester:")+10, YL+4);
	if(WorldInfo.GRI.Teams[TeamID].GetTeamNum() == TEAM_GDI)
	{
		if(GDI_Harvester != None)
			Canvas.DrawRect(GDI_Harvester.Health*0.04,3);
	}
	else
	{
		if(Nod_Harvester != None)
			Canvas.DrawRect(Nod_Harvester.Health*0.04,3);
	}
}

function int SortPriDelegate(coerce PlayerReplicationInfo pri1, coerce PlayerReplicationInfo pri2)
{
	local int score1,score2;
	
	if (Rx_PRI(pri1) != None && Rx_PRI(pri2) != None)
	{
		score1 = Rx_PRI(pri1).GetRenScore();
		score2 = Rx_PRI(pri2).GetRenScore();
		
		if (score1 > score2)
			return 1;
		else if (score1 == score2)
			return 0;
		else
			return -1;
	}
	
	return 0;
}

function DrawScorePanelTitle (optional bool bTeams, optional float gap)
{
   local float XL, YL;
   
   Canvas.SetDrawColor(255, 255, 255, 255);

   XL = ScorePanelX - DoMinus(bTeams);
   YL = ScorePanelY + gap;

   switch (ScorePanelMode)
   {
      case 0: // show "Player" and "Score"
      case 1:
      case 2: // show  Player, Kills, Deaths, KD-Ratio, Credits, Score
      case 3: //
      default:
               if(bDrawAdditionalPlayerInfo)
               	  DrawStartModifier = -200.0;
               else
                  DrawStartModifier = 0.0;		
               DrawStartX[0] = XL + StrLeng("#    ") + 20 + DrawStartModifier;          
               DrawStartX[0] = bTeams ? DrawStartX[0] : DrawStartX[0] - 4;
               DrawStrHorizontal(bTeams ? " #" : "#", XL, YL);
               XL += StrLeng("#    ");
               DrawStrHorizontal(bTeams ? "Teams" : "Name", XL, YL);
               XL += DistText[0];
               XL = bTeams ? XL : XL + StrLeng("#") - 5;
               DrawStartX[1] = XL;
               DrawStrHorizontal("Score", XL, YL);
               break;
   }
}

function float DoMinus (optional bool bTeams)
{
   local int X, Plus, WholeMinus;

   switch (ScorePanelMode)
   {
		case 1: //
		case 3: //
		case 0: //
		case 2: //
		default:
               WholeMinus = (bTeams ? StrLeng("#    Teams") : StrLeng("#    Name")) + StrLeng("Score");
               break;
   }

	Plus = 1;

	for (X=0;X<Plus;X++) // add space Length
	{
		WholeMinus += DistText[X];
	}
	
	return WholeMinus;
}

function float StrLeng (coerce string Str)
{
   local float XL, YL;
   
	if (Canvas != None)
	{
		Canvas.StrLen(Str, XL, YL);
		return XL;
	}
   
   return 0.0f;
}

function float StrHeight (coerce string Str)
{
   local float XL, YL;
   
	if (Canvas != None)
	{
		Canvas.StrLen(Str, XL, YL);
		return YL;
	}
   
   return 0.0f;
}

function DrawStrHorizontal (coerce string Str, out float oX, float Y)
{
	if (Canvas != None)
	{
		Canvas.SetPos(oX, Y);
		Canvas.DrawText(Str, true);
		oX += StrLeng(Str);
	}
}

function DrawStrVertical(coerce string Str, out float X, float oY)
{
	if (Canvas != None)
	{
		Canvas.SetPos(X, oY);
		Canvas.DrawText(Str, true);
		oY += StrHeight(Str) + 0.5f; // here is the gap for the vertical draw!
	}
}

function DisplayRadioCommands()
{
	local Rx_Controller pc;

	pc = Rx_Controller(PlayerOwner);
	
	if(UTGRI != None && UTGRI.bMatchIsOver) 
	{
		return;
	} 
	else 
	{
		HudMovie.showVote(pc.VoteTopString,pc.VotesYes,pc.VotesNo,pc.YesVotesNeeded,pc.VoteTimeLeft);

		if (pc.VoteHandler != none)
		{
			/* one1: display vote related stuff only. */
			pc.VoteHandler.Display(self);
			return;
		}
		
		if (pc.Com_Menu != none)
		{
			/* one1: display Commander menu things  */
			pc.Com_Menu.Display(self);
			return;
		}

		if (!Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio1Pressed && !Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio0Pressed){
			HudMovie.SideMenuVis(false);
			return;
		}
		else if(Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio1Pressed && Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio0Pressed){
			if(HudMovie != none && HudMovie.bMovieIsOpen)
				CreateMenuArray("CTRLALT");

		} else if (Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio0Pressed) {
			if(HudMovie != none && HudMovie.bMovieIsOpen)
				CreateMenuArray("CTRL");

		} else if (Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio1Pressed) {
			if(HudMovie != none && HudMovie.bMovieIsOpen)
				CreateMenuArray("ALT");
		}
	}
}

function PopulateRadioCommandOptions(out array<MenuOption> MenuOptions, array<int> RadioCommandIndexes, MenuOption Option) {
	local int index;

	// Popualte MenuOptions based on Radio Command indexes provided
	for (index = 0; index < RadioCommandIndexes.Length; ++index) {
		// Populate Option
		Option.Position = index + 1;
		if(RadioCommandIndexes[index] < Rx_Controller(PlayerOwner).RadioCommandsText.Length)
			Option.Message = Rx_Controller(PlayerOwner).RadioCommandsText[RadioCommandIndexes[index]];
		else
			Option.Message = "";

		if (Option.Position < 10) {
			Option.Key = String(Option.Position);
		}
		else {
			Option.Key = String(0);
		}

		// Add option to list
		if(Option.Message != "")
			MenuOptions.AddItem(Option);
	}
}

function CreateMenuArray(string type)
{
	local array<MenuOption> MenuOptions;
	local MenuOption Option;
	local Rx_Controller PC;
	local ASColorTransform defaultCT;

	defaultCT.add.R = 0;
	defaultCT.add.G = 0;
	defaultCT.add.B = 0;
	defaultCT.multiply.R = 0.83;
	defaultCT.multiply.G = 0.94;
	defaultCT.multiply.B = 1.0;

	PC = Rx_Controller(PlayerOwner);

	Option.myCT = defaultCT;

	switch(type) {
		case "CTRL":
			PopulateRadioCommandOptions(MenuOptions, RadioCommandsCtrl, Option);
			break;
		case "ALT":
			PopulateRadioCommandOptions(MenuOptions, RadioCommandsAlt, Option);
			break;
		case "CTRLALT":
			PopulateRadioCommandOptions(MenuOptions, RadioCommandsCtrlAlt, Option);
			break;
	}

	Option.Position = 0;
	Option.Key = "";
	Option.Message = "Radio Commands";
	MenuOptions.AddItem(Option);

	if(PC != None && PC.bPlayerIsCommander()) {
		Option.Position = 12;
		Option.Key = "C";
		Option.Message = "Commander Menu";
		MenuOptions.AddItem(Option);
	}

	Option.Position = 13;
	Option.Key = "N";
	Option.Message = "Donate Menu";
	MenuOptions.AddItem(Option);

	Option.Position = 14;
	Option.Key = "V";
	Option.Message = "Vote Menu";
	MenuOptions.AddItem(Option);

	HudMovie.DisplayOptions(MenuOptions);
	HudMovie.HelpMenuVis(false);
}

function CreateVoteMenuArray(array<string> VoteOptions)
{
	local array<MenuOption> MenuOptions;
	local array<string> Split;
	local MenuOption Option;
	local int i;
	local ASColorTransform defaultCT;
	local Rx_Controller RxC; 
	
	RxC = Rx_Controller(PlayerOwner); 

	defaultCT.add.R = 0;
	defaultCT.add.G = 0;
	defaultCT.add.B = 0;
	defaultCT.multiply.R = 0.8;
	defaultCT.multiply.G = 0.9;
	defaultCT.multiply.B = 0.96;

	Option.myCT = defaultCT;

	For(i = 10*(CurrentPageNum-1); i < VoteOptions.Length && i < 10*CurrentPageNum; i++) {
		Split = SplitString(VoteOptions[i], "|");
		Option.Position = i%10 + 1;
		Option.Key = Split[0];
		Option.Message = Split[1];
		MenuOptions.AddItem(Option);
	}

	Option.Position = 0;
	Option.Key = "";
	Option.Message = "Vote Menu";
	MenuOptions.AddItem(Option);

  if(CurrentPageNum < RxC.VoteHandler.NumPages) {
	  Option.Position = 13;
	  Option.Key = "Q";
	  Option.Message = "Next Page";
	  MenuOptions.AddItem(Option);
  }
  if(CurrentPageNum > 1) {
	  Option.Position = 14;
	  Option.Key = "E";
	  Option.Message = "Previous Page";
	  MenuOptions.AddItem(Option);
  } else {
	  Option.Position = 14;
	  Option.Key = "E";
	  Option.Message = "Back/Cancel";
	  MenuOptions.AddItem(Option);
  }

	HudMovie.DisplayOptions(MenuOptions);
	HudMovie.HelpMenuVis(false);
}

function CreateCommanderMenuArray(array<string> ComOptions, int ComPoints, int MaxComPoints)
{
	local array<MenuOption> MenuOptions;
	local array<string> Split;
	local MenuOption Option;
	local int i;
	local ASColorTransform greenCT, greyCT, defaultCT;

	greenCT.add.R = 0;
	greenCT.add.G = 0;
	greenCT.add.B = 0;
	greenCT.multiply.R = 0;
	greenCT.multiply.G = 5;
	greenCT.multiply.B = 0;

	greyCT.add.R = 0;
	greyCT.add.G = 0;
	greyCT.add.B = 0;
	greyCT.multiply.R = 0.55;
	greyCT.multiply.G = 0.55;
	greyCT.multiply.B = 0.55;

	defaultCT.add.R = 0;
	defaultCT.add.G = 0;
	defaultCT.add.B = 0;
	defaultCT.multiply.R = 0.8;
	defaultCT.multiply.G = 0.9;
	defaultCT.multiply.B = 0.96;

	HudMovie.HelpMenuVis(false);

	For(i = 0; i < ComOptions.Length; i++) {
		Split = SplitString(ComOptions[i], "|");
		Option.myCT = defaultCT;

		if(Left(Split[0], 3) == "-X-") { // If this item is too expensive
			Split[0] = Mid(Split[0], 3); // Remove the -X-
			Option.myCT = greyCT;        // Set the color to grey
		} else if(Left(Split[0], 3) == "-S-") { // If this item is selected
			Split[0] = Mid(Split[0], 3); 		// Remove the -S-
			Option.myCT = greenCT;				// Set color to green
			HudMovie.HelpMenuVis(true);
		}

		Option.Position = i + 1;
		Option.Key = Split[0];
		Option.Message = Split[1];

		MenuOptions.AddItem(Option);
	}

	if(ComOptions[0] == "1|Meet Here" || ComOptions[1] == "2|DEFEND") // Disable help menu if we're on the waypoints page.
		HudMovie.HelpMenuVis(false);

	Option.myCT = defaultCT;
	Option.Position = 0;
	Option.Key = "";
	Option.Message = "Commander Menu";
	MenuOptions.AddItem(Option);

	Option.Position = 13;
	Option.Key = "E";
	Option.Message = "Back/Cancel";
	MenuOptions.AddItem(Option);

	Option.Position = 14;
	Option.Key = "CP";
	Option.Message = " "$ComPoints $ "/" $ MaxComPoints;
	MenuOptions.AddItem(Option);

	HudMovie.DisplayOptions(MenuOptions);
}

function CreateHelpMenuArray(string HelpText) {
	local array<string> Split;

	Split = SplitString(HelpText, "%");

	HudMovie.DisplayHelpMenu(Split);
}

function CreateDonateMenuArray(array<string> DonateOptions)
{
	local array<MenuOption> MenuOptions;
	local array<string> Split;
	local MenuOption Option;
	local int i;
	local ASColorTransform defaultCT;

	defaultCT.add.R = 0;
	defaultCT.add.G = 0;
	defaultCT.add.B = 0;
	defaultCT.multiply.R = 0.8;
	defaultCT.multiply.G = 0.9;
	defaultCT.multiply.B = 0.96;

	Option.myCT = defaultCT;

	For(i = 0; i < DonateOptions.Length; i++) {
		Split = SplitString(DonateOptions[i], "|");
		Option.Position = i + 1;
		Option.Key = Split[0];
		Option.Message = Split[1];
		MenuOptions.AddItem(Option);
	}

	Option.Position = 0;
	Option.Key = "";
	Option.Message = "Donate Menu";
	MenuOptions.AddItem(Option);

	Option.Position = 14;
	Option.Key = "E";
	Option.Message = "Back/Cancel";
	MenuOptions.AddItem(Option);

	HudMovie.DisplayOptions(MenuOptions);
	HudMovie.HelpMenuVis(false);
}

function DrawTaunts()
{
	local int i;
	local class<Rx_FamilyInfo> FamInfo;
	local class<Rx_Vehicle> VehInfo;
	local Rx_Controller PC;
	local array<MenuOption> MenuOptions;
	local MenuOption Option;

	PC = Rx_Controller(PlayerOwner);

	if(!PC.bTauntMenuOpen) return; 

	if (PC.VoteHandler != none)
	{
		return;
	}

	// If holding radio menu, dismiss this function call.
	if (Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio1Pressed || Rx_PlayerInput(PlayerOwner.PlayerInput).bRadio0Pressed)
		return;

	if(Rx_Pawn(PC.Pawn) != none)
		FamInfo = class<Rx_FamilyInfo>(Rx_PRI(PC.PlayerReplicationInfo).CharClassInfo); 
		
	else if(Rx_Vehicle(PC.Pawn) != none && Rx_Pawn(Rx_Vehicle(PC.Pawn).Driver) != none)
	{
		 FamInfo = class<Rx_FamilyInfo>(Rx_PRI(PC.PlayerReplicationInfo).CharClassInfo); 
		 VehInfo = class<Rx_Vehicle>(Rx_PRI(PC.PlayerReplicationInfo).GetPawnVehicleClass());
	}		
		

	if(FamInfo == none) 
		return;
	
	//No vehicle to check, 
	if(VehInfo == none || VehInfo.default.VehicleVoiceClass == none){
		for(i=0; i<FamInfo.default.PawnVoiceClass.default.TauntLines.Length; i++)
		{
			// Add each taunt to the array for the menu
			Option.Position = i + 1;
			Option.Key = string(i + 1);
			Option.Message = FamInfo.default.PawnVoiceClass.default.TauntLines[i];
			MenuOptions.AddItem(Option);
		}
	}
	else if(VehInfo.default.VehicleVoiceClass != none){
		for(i=0; i<VehInfo.default.VehicleVoiceClass.default.TauntLines.Length; i++)
		{
			// Add each taunt to the array for the menu
			Option.Position = i + 1;
			Option.Key = string(i + 1);
			Option.Message = VehInfo.default.VehicleVoiceClass.default.TauntLines[i];
			MenuOptions.AddItem(Option);
		}
	}

	// Add our header for the menu
	Option.Position = 0;
	Option.Key = "";
	Option.Message = "Taunts";
	MenuOptions.AddItem(Option);

	// Add the exit key
	Option.Position = 14;
	Option.Key = "Z";
	Option.Message = "Exit Menu";
	MenuOptions.AddItem(Option);

	// Display our taunt menu
	HudMovie.DisplayOptions(MenuOptions);
	HudMovie.HelpMenuVis(false);
}

//This function was a long time coming
function DrawCenteredText(string Text, float CentX, float CentY)
{
	local float XL, YL; 
	
	Canvas.StrLen(Text, XL,YL);
	
	Canvas.SetPos(CentX-(XL*0.5), CentY);
	Canvas.DrawText(Text, false); 
}

function DrawDelimitedText(string Txt, string Delimiter, float CurX, float CurY, optional bool bDrawBackground = false, optional color BGColor, optional float XExcess = 1.0, optional float YExcess = 1.0, optional float TextScaling = 1.0) //Use single character for delimiter 
{
	local array<string> DelimitedString; 
	local string WorkingText, StringPiece; 
	local int i;
	local float XL,YL; 
	local float FontScale; 
	local float LongestStringLength, StringX, StringY; 
	local color OldColor;
	
	FontScale=TextScaling*(Canvas.SizeY/720.0); 
	
	WorkingText = Txt; 
	
	while ( Instr(WorkingText,Delimiter) != -1) 
	{
		//First piece should ALWAYS be a string
		StringPiece = Left(WorkingText, Instr(WorkingText,Delimiter));
		DelimitedString.AddItem(StringPiece);
		
		//Check if this is he longest string
		Canvas.TextSize(StringPiece, StringX, StringY); 
		if(StringX > LongestStringLength) LongestStringLength = StringX; 
			
		WorkingText=Right(WorkingText, (Len(WorkingText)-(Len(StringPiece)+1) )); //Delete the piece we were working with
	}
	
	
	Canvas.TextSize("A", XL, YL);
	Canvas.SetPos(CurX,CurY);
	if(bDrawBackground) 
	{
		OldColor = Canvas.DrawColor;
		Canvas.DrawColor=BGColor;
		Canvas.SetPos(CurX-XExcess,CurY-YExcess); 
		Canvas.DrawRect(LongestStringLength*XExcess*FontScale, (YL*(DelimitedString.Length+1)*YExcess*FontScale));
		Canvas.DrawColor = OldColor; 
	}
	
		
	for(i=0;i<DelimitedString.Length;i++)
	{
		Canvas.SetPos(CurX,CurY+(YL*ContextMenu_TextSeparationY*i*FontScale));
		Canvas.DrawText(DelimitedString[i],false,FontScale,FontScale); 
	}
}

function string GetPawnName(Actor p)
{
	if (Rx_Pawn(p) == None) 
		return "";

	return Rx_Pawn(p).GetCharacterClassName();
}

function DrawBox(int X, int Y, int XSize, int YSize)
{
	Canvas.SetPos(X, Y);
	Canvas.DrawRect(XSize, YSize);
}

function vector ReturnVector(float X, float Y, float Z)
{
	local vector result;
	result.X = X;
	result.Y = Y;
	result.Z = Z;
	
	return result;
}

function color GetTeamColor(int playerTeamIndex, int enemyTeamIndex)
{
	if(enemyTeamIndex == -1)
		return Default.WhiteColor;

	if(playerTeamIndex == enemyTeamIndex)
		return Default.GreenColor;
	else
		return Default.RedColor;
}

function DrawReticule()
{
	if (PlayerOwner == None || (PlayerOwner.Pawn == None && PlayerOwner.ViewTarget == None))
		return;
	
	if(Rx_Controller(PlayerOwner).IsSpectating() && PlayerOwner.ViewTarget != None && Rx_Controller(PlayerOwner.ViewTarget) == None && PlayerOwner.WorldInfo.GRI.bMatchHasBegun)
	{	
		if(Rx_Controller(PlayerOwner).bLockRotationToViewTarget)
		{
			Canvas.SetPos(Canvas.ClipX * 0.5,Canvas.ClipY * 0.5);
			Canvas.SetDrawColor( 255, 255, 255 );
			Canvas.DrawText(".");
		}		
		return;
	}	

	if(PlayerOwner.Pawn != None)
	{
		if (Rx_Weapon(PlayerOwner.Pawn.Weapon) != None)
			Rx_Weapon(PlayerOwner.Pawn.Weapon).ActiveRenderOverlays(self);
		else if (Rx_Vehicle_Weapon(PlayerOwner.Pawn.Weapon) != None)
			Rx_Vehicle_Weapon(PlayerOwner.Pawn.Weapon).ActiveRenderOverlays(self);
		
		if(RxIfc_PassiveAbility(PlayerOwner.Pawn) != none)
		{
			RxIfc_PassiveAbility(PlayerOwner.Pawn).RenderPassiveOverlays(self);
		}
			
	}
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	local LinearColor LC;
	
	HudMovie.DisplayHit(HitDir, Damage, damageType); //Show the hit direction 
	
	if(class<Rx_DmgType>(damageType) != none)
		LC = class<Rx_DmgType>(damageType).static.GetHitColour();
		
	if(PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health < (PlayerOwner.Pawn.HealthMax*0.20) )
		HUDVignette.SetCritical(true);
	
	
	HUDVignette.VignetteTakeHit(LC,Damage);
}

function DisplayHeals(int HealAmount, class<DamageType> damageType)
{
	local LinearColor LC;

	if(class<Rx_DmgType>(damageType) != none)
		LC = class<Rx_DmgType>(damageType).static.GetHitColour();

	if(PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health >= (PlayerOwner.Pawn.HealthMax*0.20) )
		HUDVignette.SetCritical(false);
	
	HUDVignette.VignetteTakeHeals(LC,HealAmount); //Heals generally work in a weirdly consistent manner [This is a bit hacky, but works]
}

function NotifySpecialVignette(class<Rx_StatModifierInfo> Info)
{
	local LinearColor LC; 
	
	if(Info != none)
	{
		LC = Info.default.EffectColor;
	
		HUDVignette.SetSpecialVignette(true, LC, Info.default.VignetteIntensity);
	}
	else 
		HUDVignette.SetSpecialVignette(false);
	
}

//chain the toggle from the Rx_Controller to the GFx Hud object where it occurs
function ToggleScoreboard()
{
	bShowScorePanel = !bShowScorePanel;
}

function ToggleOverviewMap()
{
	if (LeaderboardMovie != None && LeaderboardMovie.bMovieIsOpen)
		return;

	if (!bToggleOverviewMap)
		OpenOverviewMap();
	else
		CloseOverviewMap();
}

function OpenOverviewMap()
{
	bToggleOverviewMap = true;

	if(OverviewMapMovie == None)
	{
	//ToggleOverviewMap
		OverviewMapMovie = new OverviewMapClass;
		OverviewMapMovie.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
		if(Canvas != none)
			OverviewMapMovie.SetViewport(0,0,Canvas.ClipX, Canvas.ClipY);
		OverviewMapMovie.SetViewScaleMode(SM_ExactFit);
		OverviewMapMovie.SetTimingMode(TM_Real);
		//OverviewMapMovie.ExternalInterface = self;
		HudMovie.OverviewMapMovie = OverviewMapMovie;
	}

	if(!OverviewMapMovie.bMovieIsOpen)
		OverviewMapMovie.Start();


	//Hide our hud
	SetVisible(false);
}

function CloseOverviewMap()
{
	bToggleOverviewMap = false;

	if (OverviewMapMovie != none )
	{
		if (OverviewMapMovie.bMovieIsOpen)
			OverviewMapMovie.Close(false);
	}

	//show our hud again
	if(RxPauseMenuMovie == none || !RxPauseMenuMovie.bMovieIsOpen)
	{
		SetVisible(true);
	}
}

exec function SetShowScores(bool bEnableShowScores)
{
	// Don't allow displaying of leaderboard/scoreboard at same time
	if (LeaderboardMovie != None && LeaderboardMovie.bMovieIsOpen)
		return;

	HandleSetShowScores(bEnableShowScores, false);
}

function HandleSetShowScores(bool bEnableShowScores, bool bForceHandle)
{

    if(bEnableShowScores)
    {
        if ( Scoreboard == None )
        {
            Scoreboard = new ScoreboardClass;
			Scoreboard.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
			Scoreboard.SetViewport(0,0,Canvas.ClipX, Canvas.ClipY);
			Scoreboard.SetViewScaleMode(SM_ExactFit);
			Scoreboard.SetTimingMode(TM_Real);
			Scoreboard.ExternalInterface = self;
		}

        if (!Scoreboard.bMovieIsOpen)
        {
            Scoreboard.Start();            
            Scoreboard.Draw();            
        }
		
		SetVisible(false);
    }
    else if (Scoreboard != None && Scoreboard.bMovieIsOpen && (!Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver || bForceHandle))
	{
		if(Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver)
			LastEndScoreboardChats = Scoreboard.Chatlog;


		Scoreboard.Close(false);

		iF(!Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver && (RxPauseMenuMovie == none || !RxPauseMenuMovie.bMovieIsOpen))
			SetVisible(true);
	}

}



function LocalizedMessage
(
	class<LocalMessage>		InMessageClass,
	PlayerReplicationInfo	RelatedPRI_1,
	PlayerReplicationInfo	RelatedPRI_2,
	string					CriticalString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional object			OptionalObject
)
{
	super.LocalizedMessage(InMessageClass,RelatedPRI_1,RelatedPRI_2,CriticalString,Switch,Position,LifeTime,FontSize,DrawColor,OptionalObject);

	if (HudMovie == none || !HudMovie.bMovieIsOpen)
		return;

	if (InMessageClass == class'Rx_DeathMessage')
	{
		if (RelatedPRI_1 == none)
		{
			if (switch == 1)    // Suicide
			{
				AddKillMessage(RelatedPRI_2, RelatedPRI_2, class<Rx_DmgType>(OptionalObject));
				if (RelatedPRI_2 == PlayerOwner.PlayerReplicationInfo)
					AddDeathMessage(RelatedPRI_2, class<Rx_DmgType>(OptionalObject));
			}
			else   // Died
			{
				AddKillMessage(None, RelatedPRI_2, class<Rx_DmgType>(OptionalObject));
				if (RelatedPRI_2 == PlayerOwner.PlayerReplicationInfo)
					AddDeathMessage(None, class<Rx_DmgType>(OptionalObject));
			}
		}
		else
		{
			AddKillMessage(RelatedPRI_1, RelatedPRI_2, class<Rx_DmgType>(OptionalObject));
			if (RelatedPRI_2 == PlayerOwner.PlayerReplicationInfo)
				AddDeathMessage(RelatedPRI_1, class<Rx_DmgType>(OptionalObject));
		}
	}
	else if (InMessageClass == class'Rx_Message_Vehicle')
	{
		HudMovie.AddEVAMessage(CriticalString);
	}
	else if (InMessageClass == class'Rx_Message_Buildings')
	{
		if (Switch == 0)
			AddBuildingKillMessage(RelatedPRI_1, Rx_Building_Team_Internals(OptionalObject), class<Rx_DmgType>(OptionalObject));
		else if (Switch == 8)
			AddBuildingReviveMessage(RelatedPRI_1, Rx_Building_Team_Internals(OptionalObject));
	}
	else if (InMessageClass == class'Rx_Message_TechBuilding')
	{
		switch (Switch)
		{
			case class'Rx_Building_TechBuilding_Internals'.const.GDI_CAPTURED:
				AddTechBuildingCaptureMessage(RelatedPRI_1, Rx_Building_Team_Internals(OptionalObject), TEAM_GDI);
				break;
			case class'Rx_Building_TechBuilding_Internals'.const.NOD_CAPTURED:
				AddTechBuildingCaptureMessage(RelatedPRI_1, Rx_Building_Team_Internals(OptionalObject), TEAM_Nod);
				break;
			case class'Rx_Building_TechBuilding_Internals'.const.GDI_LOST:
				AddTechBuildingLostMessage(RelatedPRI_1, Rx_Building_Team_Internals(OptionalObject), TEAM_GDI);
				break;
			case class'Rx_Building_TechBuilding_Internals'.const.NOD_LOST:
				AddTechBuildingLostMessage(RelatedPRI_1, Rx_Building_Team_Internals(OptionalObject), TEAM_Nod);
				break;
		}
	}
	else if (InMessageClass == class'Rx_CratePickup'.default.MessageClass)
	{
		if(RelatedPRI_1 != PlayerOwner.PlayerReplicationInfo)
		{ 	
			if(RelatedPRI_1.GetTeamNum() != PlayerOwner.GetTeamNum())
				HudMovie.AddEVAMessage("<font color='#ff0000'>"$CriticalString$"</font>");
			else
				HudMovie.AddEVAMessage("<font color='#00ff00'>"$CriticalString$"</font>");
		}
	} 
	else if (InMessageClass == class'Rx_Message_Deployed')
	{
		if (Switch == -1)
			AddDeployedMessage(RelatedPRI_1, class<Rx_Weapon_DeployedBeacon>(OptionalObject));
		else
			AddDisarmedMessage(RelatedPRI_1, class<Rx_Weapon_DeployedBeacon>(OptionalObject), Switch);
	}
	else if (InMessageClass == class'GameMessage')
	{
		switch (switch)
		{
		case 1: // Player Connected
			AddTeamJoinMessage(RelatedPRI_1, UTTeamInfo(RelatedPRI_1.Team));   // Team join messages don't get sent for connected players, so emulate one.
			// FALLTHRU
		case 2: // Name Change
		case 4: // Player Disconnected
			Message(None, class'GameMessage'.static.GetString(Switch, (RelatedPRI_1 == PlayerOwner.PlayerReplicationInfo), RelatedPRI_1, RelatedPRI_2, OptionalObject), 'System');
			break;
		case 3: // Team Change
			AddTeamJoinMessage(RelatedPRI_1, UTTeamInfo(OptionalObject));
			break;
		}
	}

}

function AddKillMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed, optional class<Rx_DmgType> DmgType)
{
	local string htmlMsg;

	if(KillFeedMode < 2)
		htmlMsg = GetSimpleKillMessage(Killer, Killed, DmgType);

	else
	{
		if(DmgType == None || (Killer == Killed && DmgType.default.MaleSuicide == "") || (Killer != Killed && DmgType.default.DeathString == ""))
			htmlMsg = GetSimpleKillMessage(Killer, Killed);

		else if(Killer != None)
		{
			if (Killer != Killed)
			{
				htmlMsg = Repl(DmgType.default.DeathString,"`k",GetColouredName(Killer));
				htmlMsg = Repl(htmlMsg,"`o",GetColouredName(Killed));
			}
			else
			{
				htmlMsg = Repl(DmgType.default.MaleSuicide,"`o",GetColouredName(Killed));
			}
		}
		else
		{
			htmlMsg = Repl(DmgType.default.MaleSuicide,"`o",GetColouredName(Killed));
		}
	}

	HudMovie.AddGameEventMessage(htmlMsg);
}

function string GetSimpleKillMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed, optional class<Rx_DmgType> DmgType)
{
	local string htmlMsg;

	if (Killer != none)
	{
		htmlMsg = GetColouredName(Killer);

		if (Killer != Killed)
		{
			htmlMsg @= "killed" @ GetColouredName(Killed);

			if(KillFeedMode == 1 && DmgType != None && DmgType.default.WeaponName != "")
				htmlMsg @= "("$DmgType.default.WeaponName$")";

		}
		else
		{
			htmlMsg @= "suicided";

			if(KillFeedMode == 1 && DmgType != None && DmgType.default.WeaponName != "")
				htmlMsg @= "("$DmgType.default.WeaponName$")";	
					
		}
	}
	else
	{
		htmlMsg = GetColouredName(Killed) @ "died";

		if(KillFeedMode == 1 && DmgType != None && DmgType.default.WeaponName != "")
			htmlMsg @= "("$DmgType.default.WeaponName$")";


	}

	return htmlMsg;
}

function AddBuildingKillMessage(PlayerReplicationInfo Killer, Rx_Building_Team_Internals Building, optional class<Rx_DmgType> DmgType)
{
	if(KillFeedMode == 1 && DmgType != None && DmgType.default.WeaponName != "")
		HudMovie.AddGameEventMessage("* "$ GetColouredName(Killer) $" destroyed the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.GetBuildingName() $"</font> ("$DmgType.default.WeaponName$")*");

	else
		HudMovie.AddGameEventMessage("* "$ GetColouredName(Killer) $" destroyed the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.GetBuildingName() $"</font> *");
}

function AddBuildingReviveMessage(PlayerReplicationInfo Reviver, Rx_Building_Team_Internals Building)
{
	HudMovie.AddGameEventMessage("* "$ GetColouredName(Reviver) $" restored the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.GetBuildingName() $"</font> *");
}

function AddTechBuildingCaptureMessage(PlayerReplicationInfo Capturer, Rx_Building_Team_Internals Building, byte CapturingTeam)
{
	if (Capturer != None)
		HudMovie.AddGameEventMessage(GetColouredName(Capturer) $" captured the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.GetBuildingName() $"</font>");
	else
		HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(CapturingTeam) $"'>"$ class'Rx_Game'.static.GetTeamName(CapturingTeam) $"</font> captured the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.GetBuildingName() $"</font>");
}
function AddTechBuildingLostMessage(PlayerReplicationInfo Capturer, Rx_Building_Team_Internals Building, byte LosingTeam)
{
	local byte InstigatingTeam;

	if (Capturer != None)
		HudMovie.AddGameEventMessage(GetColouredName(Capturer) $" neutralized the <font color='"$ GetTeamColour(LosingTeam) $"'>"$ Building.GetBuildingName() $"</font>");
	else
	{
		InstigatingTeam = LosingTeam == TEAM_GDI ? TEAM_Nod : TEAM_GDI;
		HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(InstigatingTeam) $"'>"$ class'Rx_Game'.static.GetTeamName(InstigatingTeam) $"</font> neutralized the <font color='"$ GetTeamColour(LosingTeam) $"'>"$ Building.GetBuildingName() $"</font>");
	}
}

function AddDeployedMessage(PlayerReplicationInfo Deployer, class<Rx_Weapon_DeployedBeacon> DeployedClass )
{
	HudMovie.AddGameEventMessage(GetColouredName(Deployer) $" deployed <font color='"$ GetTeamColour(Deployer.GetTeamNum()) $"'>"$ DeployedClass.default.DeployableName $"</font>");
}

function AddDisarmedMessage(PlayerReplicationInfo Disarmer, class<Rx_Weapon_DeployedBeacon> DeployedClass, byte DeployedTeam )
{
	HudMovie.AddGameEventMessage(GetColouredName(Disarmer) $" disarmed <font color='"$ GetTeamColour(DeployedTeam) $"'>"$ DeployedClass.default.DeployableName $"</font>");
}

function AddTeamJoinMessage(PlayerReplicationInfo Player, UTTeamInfo NewTeam)
{
	HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(NewTeam.GetTeamNum()) $"'>" $CleanHTMLMessage(Player.PlayerName)$"</font> joined <font color='"$ GetTeamColour(NewTeam.GetTeamNum()) $"'>"$ class'Rx_Game'.static.GetTeamName(NewTeam.GetTeamNum()) $"</font>");
}

function AddFakedTeamJoinMessage(string PlayerName, int TeamIndex)
{
	LocalPlayer( GetALocalPlayerController().Player).ViewportClient.ViewportConsole.OutputText( PlayerName@class'GameMessage'.Default.NewTeamMessage@ class'Rx_Game'.static.GetTeamName(TeamIndex)$class'GameMessage'.Default.NewTeamMessageTrailer );
	HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(TeamIndex) $"'>" $CleanHTMLMessage(PlayerName)$"</font> joined <font color='"$ GetTeamColour(TeamIndex) $"'>"$ class'Rx_Game'.static.GetTeamName(TeamIndex) $"</font>");
}

function AddDeathMessage(PlayerReplicationInfo Killer, class<DamageType> DmgType)
{
	if (Killer == None)
		HudMovie.AddDeathMessage("You have died.", DmgType, Killer);
	else if (Killer == PlayerOwner.PlayerReplicationInfo)
		HudMovie.AddDeathMessage("You killed yourself.", DmgType, Killer);
	else
		HudMovie.AddDeathMessage("You were killed by "$GetColouredName(Killer)$".", DmgType, Killer);

}

function AddVehicleDeathMessage(PlayerReplicationInfo Killer, class<DamageType> DmgType)
{
	// Function called from outside this class, so do the flash checks.
	if (HudMovie == none || !HudMovie.bMovieIsOpen)
		return;

	if (Killer == None)
		HudMovie.AddVehicleDeathMessage("Vehicle destroyed.", DmgType, Killer);
	else if (Killer == PlayerOwner.PlayerReplicationInfo)
		HudMovie.AddVehicleDeathMessage("You destroyed your Vehicle.", DmgType, Killer);
	else
		HudMovie.AddVehicleDeathMessage("Vehicle destroyed by "$GetColouredName(Killer)$".", DmgType, Killer);
}


function AddLocalizedMessage
(
	int						Index,
	class<LocalMessage>		InMessageClass,
	string					CriticalString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional int			MessageCount,
	optional object			OptionalObject
)
{
	super.AddLocalizedMessage(
		Index,
		InMessageClass, 
		CriticalString, 
		Switch,
		Position,
		LifeTime,
		FontSize,
		DrawColor,
		MessageCount,
		OptionalObject);
}

// halo2pac - sets the announcement to be rendered.
// announcement = title text, count = countdown number subtext.
function PlayAreaAnnouncement(string announcement, int count)
{
	PlayAreaAnnouncementText = announcement;
	PlayAreaAnnouncementCount = string(count);
}

// halo2pac - clears the announcement on screen.
function ClearPlayAreaAnnouncement()
{
	PlayAreaAnnouncementText = "";
	PlayAreaAnnouncementCount = "";
}

//halo2pac - draws text at ~15/16 pt font, near center of screen.
//as a warning for the play area
function DrawPlayAreaAnnouncement()
{
	local float TextX, TextY, PosX, PosY;
	local float TextX2, TextY2, PosX2, PosY2;
	
	local float CCenterY, CCenterX, TotalY, LineSpacing;
	
	local float FScaleX, FScaleY, OffsetX, OffsetY;
	
	local Font OldFont;
	local Color OldColor;

	//Check if lines are empty
	if (PlayAreaAnnouncementText == "" || PlayAreaAnnouncementText == " ")
		return;
	
	if (PlayAreaAnnouncementCount == "" || PlayAreaAnnouncementCount == " ")
		return;
	
	//set our variables
	OffsetX = 0;
	OffsetY = 0;
	FScaleX = 1.5;
	FScaleY = 1.5;
	LineSpacing = 10;
	
	//save current canvas stuff.
	OldFont = Canvas.Font;
	OldColor = Canvas.DrawColor;
	
	//setup our canvas for this print.
	Canvas.Font = Font'RenXHud.Font.AS_Med';
	Canvas.DrawColor = Default.RedColor;
	
	//calculate each line's area
	Canvas.StrLen(PlayAreaAnnouncementText, TextX, TextY);
	Canvas.StrLen(PlayAreaAnnouncementCount, TextX2, TextY2);
	
	//calculate canvas center
	CCenterX = Canvas.SizeX / 2;
	CCenterY = Canvas.SizeY / 2;
	
	//each line needs to be centered horizontally seperately.
	PosX = CCenterX - ((TextX / 2) * FScaleX) + OffsetX;
	PosX2 = CCenterX - ((TextX2 / 2) * FScaleX) + OffsetX;
	
	//total line height + spacing
	TotalY = TextY + TextY2 + LineSpacing;
	
	//each line has to be calculated together to center vertically.
	PosY = CCenterY - ((TextY / 2) * FScaleX) - (TotalY / 2) + OffsetY; //above center
	PosY2 = CCenterY - ((TextY2 / 2) * FScaleX) + (TotalY / 2) + OffsetY; //below center

	//draw first line
	Canvas.SetPos(PosX, PosY);
	Canvas.DrawText(PlayAreaAnnouncementText,,FScaleX,FScaleY);
	
	//draw our second line
	Canvas.SetPos(PosX2, PosY2);
	Canvas.DrawText(PlayAreaAnnouncementCount,,FScaleX,FScaleY);
	
	//revert back to canvas originals		
	Canvas.Font = OldFont;
	Canvas.DrawColor = OldColor;
}

function ShowHitMarker(optional bool bHeadShot = false)
{
	if(!bHeadshot) 
	{
		HitMarker_Color=LC_White;	
		HitEffectAplha = 100;
	}
	else
	{
		HitMarker_Color=LC_Red;	
		HitEffectAplha = 200;
	}
	
	if(Rx_Vehicle_Artillery(PlayerOwner.Pawn) != None)
		SetTimer(5, False, 'TargetingTimer');
}

function float GetHitEffectAplha()
{
	return HitEffectAplha;
}

/*
 * Toggle the Pause Menu on or off.
 * CAUTION: The script is very horny so tame it at all costs. Else it will start raiding women's drawers and sniffing panties.
 */
function TogglePauseMenu()
{
    if ( RxPauseMenuMovie != none && RxPauseMenuMovie.bMovieIsOpen ) 
    {
		
		if( !WorldInfo.IsPlayInMobilePreview() ) 
		{
			RxPauseMenu_FadeSystemMovie.HideSystem();
			CompletePauseMenuClose();
		} 
		else 
		{
			// On mobile previewer, close right away
			CompletePauseMenuClose();
		}
	} 
	else 
	{

		// Do not prevent 'escape' to unpause once we finished the game
		if (Rx_GRI(PlayerOwner.WorldInfo.GRI) != none && Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver) 
		{
			if (Scoreboard != none && Scoreboard.EndGameTime > 0 && (Rx_GRI(PlayerOwner.WorldInfo.GRI).RenEndTime - PlayerOwner.WorldInfo.RealTimeSeconds) > 0) 
			{
				PlayerOwner.SetPause(false);

				if (RxPauseMenu_FadeSystemMovie == None) 
				{
					RxPauseMenu_FadeSystemMovie = new class'Rx_GFxPauseMenu_FadeSystem';
					RxPauseMenu_FadeSystemMovie.MovieInfo = SwfMovie'RenXPauseMenu.RenXFadeScreen';
					RxPauseMenu_FadeSystemMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
					RxPauseMenu_FadeSystemMovie.SetTimingMode(TM_Real);
				}
				if (RxPauseMenuMovie == None) 
				{
					RxPauseMenuMovie = new RxPauseMenuMovieClass;
					RxPauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
					RxPauseMenuMovie.SetTimingMode(TM_Real);
				}


				SetVisible(false);
				RxPauseMenu_FadeSystemMovie.Start();
				RxPauseMenu_FadeSystemMovie.ShowSystem();
				RxPauseMenuMovie.Start();

				// Do not prevent 'escape' to unpause if running in mobile previewer
				if(!WorldInfo.IsPlayInMobilePreview()) 
				{
					RxPauseMenuMovie.AddFocusIgnoreKey('Escape');
				}
			}
		} 
		else 
		{
			PlayerOwner.SetPause(True);

			if (RxPauseMenu_FadeSystemMovie == None) 
			{
				RxPauseMenu_FadeSystemMovie = new class'Rx_GFxPauseMenu_FadeSystem';
				RxPauseMenu_FadeSystemMovie.MovieInfo = SwfMovie'RenXPauseMenu.RenXFadeScreen';
				RxPauseMenu_FadeSystemMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
				RxPauseMenu_FadeSystemMovie.SetTimingMode(TM_Real);
			}
			if (RxPauseMenuMovie == None) 
			{
				RxPauseMenuMovie = new RxPauseMenuMovieClass;
				RxPauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
				RxPauseMenuMovie.SetTimingMode(TM_Real);
			}


			SetVisible(false);
			RxPauseMenu_FadeSystemMovie.Start();
			RxPauseMenu_FadeSystemMovie.ShowSystem();
			RxPauseMenuMovie.Start();

			// Do not prevent 'escape' to unpause if running in mobile previewer
			if(!WorldInfo.IsPlayInMobilePreview()) 
			{
				RxPauseMenuMovie.AddFocusIgnoreKey('Escape');
			}
		}

		if(RxPauseMenuMovie != None)
			CloseOtherMenus();
    }
	PlayerOwner.Pawn.StopFiring();
}

/*
 * Complete necessary actions for OnPauseMenuClose.
 * Fired from Flash.
 */
function CompletePauseMenuClose()
{
    PlayerOwner.SetPause(False);
    FadeScreenClose();
	if (RxPauseMenuMovie.bMovieIsOpen) {
		RxPauseMenuMovie.Close(true);  // crash happened when pressing settings too many times after closing apparently
	}
	RxPauseMenuMovie = none;
	
	if (Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver) 
	{
		if (Scoreboard != None && Scoreboard.bMovieIsOpen) 
		{
			Scoreboard.RootMC.SetVisible(true);
		}
		else
		{
			SetShowScores(true);
		}
	}
	else
	{
	    SetVisible(true);
	}
}
function FadeScreenClose()
{
	if (RxPauseMenu_FadeSystemMovie.bMovieIsOpen) {
		RxPauseMenu_FadeSystemMovie.Close(false);
	}
}

function DrawAdditionalPlayerInfo(bool bEnable)
{
	bDrawAdditionalPlayerInfo = bEnable;
	LastScoreboardRenderTime = WorldInfo.TimeSeconds - 1.0; // so that scoreboard is immediatly rendered again
}

//start normal chat (nBab)
exec function startchat()
{
	if (WorldInfo.NetMode != NM_Standalone) {
		HudMovie.startchat();
	}
}

//start team chat (nBab)
exec function startteamchat()
{
	if (WorldInfo.NetMode != NM_Standalone) {
		HudMovie.startteamchat();
	}
}

//start private chat (nBab)
exec function startprivatechat()
{
	if (WorldInfo.NetMode != NM_Standalone) {
		HudMovie.startprivatechat();
	}
}

//start private chat (nBab)
exec function starthostprivatechat()
{
	if (WorldInfo.NetMode != NM_Standalone) {
		HudMovie.starthostprivatechat();
	}
}

function string HighlightStructureNames(string Str)
{
	//Highlight immediate repair warnings 
	Str = Repl(Str, "needs repair immediately!", "<font color='" $NodColor$"'>" $"needs repair immediately!"$  "</font>"); 
	
	//Highlight C4
	Str = Repl(Str, "Defend &gt;&gt;C4&lt;&lt;", "<font color='" $NeutralColor$"'>" $"Defend &gt;&gt;C4&lt;&lt;"$  "</font>");
	
	Str = Repl(Str, "ENEMY &gt;&gt;C4&lt;&lt;", "<font color='" $NodColor$"'>" $"ENEMY &gt;&gt;C4&lt;&lt;"$  "</font>");
	
	Str = Repl(Str, "MCT", "<b><font color='" $NeutralColor$"'>" $"MCT"$  "</font></b>");
	
	return Str; 
} 

function SetHelpText();
 
exec function bool FlipPageForward()
{
	local Rx_Controller RxC; 
	
	RxC = Rx_Controller(PlayerOwner); 
	
	if(RxC.VoteHandler != none && CurrentPageNum < RxC.VoteHandler.NumPages ) 
	{
		CurrentPageNum +=1; 
		return true; 
	}
	else
	return false; 
}

exec function bool FlipPageBackward()
{
	local Rx_Controller RxC; 
	
	RxC = Rx_Controller(PlayerOwner); 
	
	if(RxC.VoteHandler != none && CurrentPageNum > 1) 
	{
		CurrentPageNum -=1; 
		return true; 
	}
	else return false;
}

function CloseOtherMenus()
{
	super.CloseOtherMenus(); 

	if(Rx_Controller(PlayerOwner) != none) 
	{
		Rx_Controller(PlayerOwner).DestroyOldComMenu();
		Rx_Controller(PlayerOwner).DisableVoteMenu(true);
	}

	if(Scoreboard != None)
		HandleSetShowScores(False, True);

	if(OverviewMapMovie != None && OverviewMapMovie.bMovieIsOpen)
		CloseOverviewMap();



}

function SetFadeToBlack (float Time, bool bToBlack)
{

	bEnableFade = true;

	if(bToBlack)
		FadePerSecond = 1.f / Time;

	else
		FadePerSecond = -1.f / Time;
}

function ProcessFade (float DeltaTime)
{
	local byte AlphaNum;

	if(bEnableFade)
	{
		FadePercentage += FadePerSecond * DeltaTime;

		FadePercentage = FClamp(FadePercentage,0.f,1.f);

		if((FadePerSecond > 0.f && FadePercentage >= 1.f) || (FadePerSecond <= 0.f && FadePercentage <= 0.f))
			bEnableFade = false;
	}

	if(FadePercentage <= 0.f)	//skip drawing if the percentage is 0
		return;

	AlphaNum = FadePercentage * 255;
	Canvas.SetDrawColor(0,0,0,AlphaNum);
	Canvas.SetPos(0,0);
	Canvas.DrawRect(SizeX,SizeY);
}

function SetRadioCommandsClassic()
{
	local int index;

	// Populate Ctrl
	for (index = 0; index < 10; ++index) {
		RadioCommandsCtrl[index] = index;
	}

	// Populate Alt
	for (index = 0; index < 10; ++index) {
		RadioCommandsAlt[index] = index + 10;
	}

	// Populate Ctrl + Alt
	for (index = 0; index < 10; ++index) {
		RadioCommandsCtrlAlt[index] = index + 20;
	}
}

function SetRadioCommandsDefault()
{
	RadioCommandsCtrl = default.RadioCommandsCtrl;
	RadioCommandsAlt = default.RadioCommandsAlt;
	RadioCommandsCtrlAlt = default.RadioCommandsCtrlAlt;
}

function SetRadioCommandsCustom()
{
	RadioCommandsCtrl = SystemSettingsHandler.RadioCommandsCtrl;
	RadioCommandsAlt = SystemSettingsHandler.RadioCommandsAlt;
	RadioCommandsCtrlAlt = SystemSettingsHandler.RadioCommandsCtrlAlt;
}



DefaultProperties
{
	YellowColor=(R=255,G=215,B=0,A=255)
	BlueColor=(R=0,G=0,B=255,A=255)
	ConsoleMessagePosY=0.08f // 0.8f
	MaxSpotDistance = 8000;
	ScorePanelY = 90.0f; // constant as it will be always on the right top
	
	DistText(0) = 70.0f
	DistText(1) = 10.0f
	DistText(2) = 10.0f
	DistText(3) = 20.0f
	DistText(4) = 10.0f
	DrawStartModifier = 0.0f
	
	EnemySpottedIcon = (Texture = Texture2D'RenXTargetSystem.T_NavMarker_Mini_Red', U= 0, V = 0, UL = 64, VL = 64)
	DefaultTargettingRange = 10000;

	NodColor            = "#FF0000"
	GDIColor            = "#FFC600"
	NeutralColor        = "#00FF00"
	PrivateFromColor    = "#2288FF"
	PrivateToColor      = "#0055FF"
	HostColor           = "#22BBFF"
	RadioColor			= "#00FF7F"
	CommandTextColor	= "#E8DAEF" //"#87CEEB" 
	
	LC_Red = (R=1.0, G=0, B=0, A=1.0)
	LC_White = (R=1.0, G=1.0, B=1.0, A=1.0)

	HudMovieClass = class 'Rx_GFxHud'
	GIHudMovieClass = class 'Rx_GFxGameinfoHud'
	TargetingBoxClass = class 'Rx_Hud_TargetingBox'
	PlayerNamesClass = class 'Rx_Hud_PlayerNames'
	CaptureProgressClass = class 'Rx_HUD_CaptureProgress'
	CommandTextClass = class 'Rx_HUD_CTextComponent'
	ScoreboardClass = class'Rx_GFxUIScoreboard'
	//C_VisualsClass = class 'Rx_HUD_ObjectiveVisuals';
	HUDVignetteClass = class'Rx_HUD_VignetteComponent'
	
	RxPauseMenuMovieClass = class'Rx_GFxPauseMenu'
	
	DrawCText = true 
	DrawTargetBox = true 
	DrawPlayerNames = true 
	DrawCaptureProgress = false
	DrawFlashHUD = true 
	
	ContextualMenuBackground = (Texture = Texture2D'RenxHud.Images.Rx_HUD_ContextualMenu', U= 134, V = 81, UL = 245, VL = 348); 
	ContextualMenuHelpBackground = (Texture = Texture2D'RenxHud.Images.Rx_HUD_ContextHelpAddon', U= 57, V = 26, UL = 139, VL = 202); 
	ContextMenu_AnchorY = 0.22
	ContextMenu_NormalColor = (R=255, G=255, B =255, A=255)
	ContextMenu_HighlightColor = (R=0, G=255, B = 0, A=255)
	CurrentPageNum	=	1
	ContextMenu_FontScale = 0.75
	ContextMenu_TextAnchorX = 5 
	ContextMenu_TextAnchorY = 56
	ContextMenu_PromptsAnchorY = 2.22
	ContextMenu_TextSeparationY = 0.77
	ContextMenu_TitleAnchorX	= 115 
	ContextMenu_FooterY			= 127
	MiniCommandWindow_AnchorX	= 1220
	MiniCommandWindow_AnchorY	= 970

	VetRankIcons(0) = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Recruit', U= 0, V = 0, UL = 64, VL = 64)
	VetRankIcons(1) = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Veteran', U= 0, V = 0, UL = 64, VL = 64)
	VetRankIcons(2) = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Elite', U= 0, V = 0, UL = 64, VL = 64)
	VetRankIcons(3) = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Heroic', U= 0, V = 0, UL = 64, VL = 64)

	TestFontScale = 1.15
	
	OverviewMapClass = class'Rx_GfxOverviewMap'

	// Defaults for Classic
	//RadioCommandsCtrl = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
	//RadioCommandsAlt = (10, 11, 12, 13, 14, 15, 16, 17, 18, 19)
	//RadioCommandsCtrlAlt = (20, 21, 22, 23, 24, 25, 26, 27, 28, 29)

	// Defaults for simplified
	RadioCommandsCtrl = (0, 6, 7, 1, 2, 3, 25, 8)
	RadioCommandsAlt = (10, 12, 26, 21, 13, 14, 17, 19)
}
