
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
config(XSettings);

// Use team colors for player names. Otherwise show friendly/enemy
var config bool NicknamesUseTeamColors;

var config bool ShowInteractableIcon;
var config bool ShowInteractMessage;

var config bool ShowOwnName;
var config bool ShowOwnNameInVehicle;

var config bool ShowBasicTips;

/**Reference the actual SWF container*/
var Rx_GFxHud HudMovie;

var Rx_HUD_TargetingBox TargetingBox;
var Rx_Hud_PlayerNames PlayerNames;
var Rx_HUD_CaptureProgress CaptureProgress;
var Rx_HUD_CTextComponent CommandText;
var bool DrawCText, DrawTargetBox,DrawPlayerNames,DrawCaptureProgress, DrawDamageSystem, DrawFlashHUD; 


/** GFx movie used for displaying damage system */
var Rx_GFxDamageSystem DamageSystemMovie;

/** GFx movie used for displaying pause menu */
var Rx_GFxPauseMenu		RxPauseMenuMovie;
var Rx_GFxPauseMenu_FadeSystem RxPauseMenu_FadeSystemMovie;

/** GFx movie used for purchase terminal */
var Rx_GFxPurchaseMenu PTMovie;

var float MaxSpotDistance;
var array<Actor> UnmarkTargets;

/** Debug flag to show AI information */
var bool bShowAllAI;
var	const color	YellowColor;
var	const color	BlueColor;

/** HTML Color Codes */
var string 	GDIColor, NodColor, NeutralColor, PrivateFromColor, PrivateToColor, HostColor;

var array<Actor> SpotTargets;
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

	PotentialTarget = none;
	WeaponAimingActor = none;
	ClosestHit = GetWeaponTargetingRange();

	GetCameraOriginAndDirection(CameraOrigin,CameraDirection);
	
	TraceRange = CameraOrigin + CameraDirection * GetWeaponTargetingRange();
	extendedDist = VSize(CameraOrigin - PlayerOwner.ViewTarget.location);
	TraceRange += CameraDirection * extendedDist;

	// This trace will ignore the view target so we don't target ourselves.
	foreach TraceActors(class'actor',HitActor,HitLoc,HitNormal,TraceRange,CameraOrigin,vect(0,0,0),,1)
	{
		if (StaticMeshActor(HitActor) != None)
			break;
		tempDist = VSize(CameraOrigin - HitLoc) - extendedDist;
		if (HitActor != PlayerOwner.ViewTarget && ClosestHit >= tempDist)
		{
			ClosestHit = tempDist;
			if (ClosestHit < GetWeaponRange()) // If the hit actor is also within weapon range, then weapon aiming actor is it.
				WeaponAimingActor = HitActor;
			PotentialTarget = HitActor;
			TargetingBox.TargetActorHitLoc = HitLoc;
			break;
		}
	}

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

	if (PlayerOwner != none && PlayerOwner.ViewTarget != none)
	{
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

//Handles drawing for log, chat, kill and EVA messages
function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType, optional float LifeTime )
{
	local string cName, fMsg, rMsg;
	local bool bEVA;

	if (Len(Msg) == 0)
		return;
	
	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
 
	// Create Raw and Formatted Chat Messages

	if (PRI != None)
		cName = CleanHTMLMessage(PRI.PlayerName);
	else
		cName = "Host";
	
	if (MsgType == 'Say') {
		if (PRI == None)
			fMsg = "<font color='" $HostColor$"'>" $cName$"</font>: <font color='#FFFFFF'>"$CleanHTMLMessage(Msg)$"</font>";
		else if (PRI.Team.GetTeamNum() == TEAM_GDI)
			fMsg = "<font color='" $GDIColor $"'>" $cName $"</font>: " $ CleanHTMLMessage(Msg);
		else if (PRI.Team.GetTeamNum() == TEAM_NOD)
			fMsg = "<font color='" $NodColor $"'>" $cName $"</font>: " $ CleanHTMLMessage(Msg);
		PublicChatMessageLog $= "\n" $ fMsg;
		rMsg = cName $": "$ Msg;
	}
	else if (MsgType == 'TeamSay') {
		if (PRI.GetTeamNum() == TEAM_GDI)
		{
			fMsg = "<font color='" $GDIColor $"'>" $ cName $": "$ CleanHTMLMessage(Msg) $"</font>";
			PublicChatMessageLog $= "\n" $ fMsg;
			rMsg = cName $": "$ Msg;
		}
		else if (PRI.GetTeamNum() == TEAM_NOD)
		{
			fMsg = "<font color='" $NodColor $"'>" $ cName $": "$ CleanHTMLMessage(Msg) $"</font>";
			PublicChatMessageLog $= "\n" $ fMsg;
			rMsg = cName $": "$ Msg;
		}
	}
	else if (MsgType == 'System') {
		if(InStr(Msg, "entered the game") >= 0)
			return;
		fMsg = Msg;
		PublicChatMessageLog $= "\n" $ fMsg;
		rMsg = Msg;
	}
	else if (MsgType == 'PM') {
		if (PRI != None)
			fMsg = "<font color='"$PrivateFromColor$"'>Private from "$cName$": "$CleanHTMLMessage(Msg)$"</font>";
		else
			fMsg = "<font color='"$HostColor$"'>Private from "$cName$": "$CleanHTMLMessage(Msg)$"</font>";
		PrivateChatMessageLog $= "\n" $ fMsg;
		rMsg = "Private from "$ cName $": "$ Msg;
	}
	else if (MsgType == 'PM_Loopback') {
		fMsg = "<font color='"$PrivateToColor$"'>Private to "$cName$": "$CleanHTMLMessage(Msg)$"</font>";
		PrivateChatMessageLog $= "\n" $ fMsg;
		rMsg = "Private to "$ cName $": "$ Msg;
	}
	else
		bEVA = true;

	// Add to currently active GUI
	if (bEVA)
	{
		if (HudMovie != none && HudMovie.bMovieIsOpen)
			HudMovie.AddEVAMessage(Msg);
	}
	else
	{
		if (HudMovie != none && HudMovie.bMovieIsOpen)
			HudMovie.AddChatMessage(fMsg, rMsg);

		if (Scoreboard != none && Scoreboard.bMovieIsOpen) {
			if (PlayerOwner.WorldInfo.GRI.bMatchIsOver) {
				Scoreboard.AddChatMessage(fMsg, rMsg);
			}
		}
		if (RxPauseMenuMovie != none && RxPauseMenuMovie.bMovieIsOpen) {
			if (RxPauseMenuMovie.ChatView != none) {
				RxPauseMenuMovie.ChatView.AddChatMessage(fMsg, rMsg, MsgType=='PM' || MsgType=='PM_Loopback');
			}
		}	
	}
}

function string GetColouredName(PlayerReplicationInfo PRI)
{
	if (PRI.GetTeamNum() == TEAM_GDI)
		return "<font color='" $GDIColor $"'>" $CleanHTMLMessage(PRI.PlayerName)$"</font>";
	else if (PRI.GetTeamNum() == TEAM_NOD)
		return "<font color='" $NodColor$"'>" $CleanHTMLMessage(PRI.PlayerName)$"</font>";
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

function string CleanHTMLMessage(string msg)
{
	msg = Repl(msg, "<", "&lt;");
	msg = Repl(msg, ">", "&gt;");
	msg = Repl(msg, "\\", "&#92;");
	return msg;
}

simulated function PostBeginPlay() 
{
	super.PostBeginPlay();
	if (SystemSettingsHandler == none) {
		SystemSettingsHandler = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_SystemSettingsHandler');
		SystemSettingsHandler.SetSettingBucket(SystemSettingsHandler.GraphicsPresetLevel);
		SystemSettingsHandler.PopulateSystemSettings();
	}
	if (GraphicAdapterCheck == none) {
		GraphicAdapterCheck = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_GraphicAdapterCheck');
		GraphicAdapterCheck.CheckGraphicAdapter();
	}
	
	if (JukeBox == none) {
		JukeBox = new class'Rx_Jukebox';
		JukeBox.Init();
		WorldInfo.MusicComp = JukeBox.MusicComp;
		WorldInfo.MusicComp.OnAudioFinished = MusicPlayerOnAudioFinished;

		`log ("<Rx_HUD log> SystemSettingsHandler.bAutostartMusic? " $ SystemSettingsHandler.bAutostartMusic);
		//Disable this if we do not want to play on start.
		if (SystemSettingsHandler.bAutostartMusic) {
			if (JukeBox.bShuffled) {
				JukeBox.Play(Rand(JukeBox.JukeBoxList.Length));
			} else {
				JukeBox.Play(0);
			}
		}
	}
// 
// 	GetPC().WorldInfo.MusicComp.bAutoDestroy = false;

	CreateUIInterface();
}

function MusicPlayerOnAudioFinished(AudioComponent AC)
{
	local int i;
	`log("MusicPlayerOnAudioFinished :: bStopped? "$ JukeBox.bStopped $" | AC? " $ AC.Name $" | SoundCue? "$ AC.SoundCue );
	if (JukeBox.bStopped)
		return;

	//find the current index
	i = JukeBox.JukeBoxList.Find('TheSoundCue', WorldInfo.MusicComp.SoundCue);
	if (i < 0)
		return;

	//check if we're shuffling
	if (JukeBox.bShuffled)
		JukeBox.Play(Rand(JukeBox.JukeBoxList.Length));
	else if (i + 1 < JukeBox.JukeBoxList.Length)
		JukeBox.Play(i+1);
	else
		JukeBox.Play(0);

	i = JukeBox.JukeBoxList.Find('TheSoundCue', WorldInfo.MusicComp.SoundCue);
	
	if (RxPauseMenuMovie.SettingsView.MusicTracklist != none)
		RxPauseMenuMovie.SettingsView.MusicTracklist.SetInt("selectedIndex", i);

	if (RxPauseMenuMovie.SettingsView.TrackNameLabel != none)
	{
		if (i >= 0)
			RxPauseMenuMovie.SettingsView.TrackNameLabel.SetText(JukeBox.JukeBoxList[i].TrackName);
		else
			RxPauseMenuMovie.SettingsView.TrackNameLabel.SetText("");
	}
}

//Create and initialize the UI Interface.
function CreateUIInterface()
{
	CreateDamageSystemMovie();
	CreateHUDMovie();
	CreateHudCompoenents();
}

//Create and initialize the HUDMovie.
function CreateHUDMovie()
{
	//Create a STGFxHUD for HudMovie
	HudMovie = new class'Rx_GFxHud';
	//Set the timing mode to TM_Real - otherwide things get paused in menus
	HudMovie.SetTimingMode(TM_Real);
	//Call HudMovie's Initialise function
	HudMovie.Initialize();
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.SetViewScaleMode(SM_NoBorder);
	HudMovie.SetAlignment(Align_TopLeft);

	HudMovie.RenxHud = self;
}


//Create and initialize hud components
function CreateHudCompoenents()
{
	TargetingBox = New class'Rx_Hud_TargetingBox';
	PlayerNames = New class 'Rx_Hud_PlayerNames';
	CaptureProgress = New class 'Rx_HUD_CaptureProgress';
	CommandText = New class 'Rx_HUD_CTextComponent';
}

function UpdateHudCompoenents(float DeltaTime, Rx_HUD HUD)
{
if(DrawTargetBox)	TargetingBox.Update(DeltaTime,HUD);  // Targetting box isn't fully seperated from this class yet so we can't update it here.
if(DrawPlayerNames)	PlayerNames.Update(DeltaTime,HUD);
if(DrawCaptureProgress) CaptureProgress.Update(DeltaTime,HUD);
if(DrawCText)	CommandText.Update(DeltaTime,HUD);
}

function DrawHudCompoenents()
{
if(DrawTargetBox)	TargetingBox.Draw(); // Targeting box isn't fully separated from this class yet so we can't draw it here.
if(DrawPlayerNames)	PlayerNames.Draw();
if(DrawCaptureProgress)	CaptureProgress.Draw();
if(DrawCText)	CommandText.Draw(); 
}

//Create and initialize the Damage System.
function CreateDamageSystemMovie()
{
	DamageSystemMovie = new class'Rx_GFxDamageSystem';
	DamageSystemMovie.SetTimingMode(TM_Real);
	DamageSystemMovie.Init(class'Engine'.static.GetEngine().GamePlayers[DamageSystemMovie.LocalPlayerOwnerIndex]);
}

/*
simulated function RemoveDamageSystemMovie()
{
	if ( DamageSystemMovie != None )
	{
		DamageSystemMovie.Close(true);
		DamageSystemMovie = None;
	}
}


//Destroy existing Movies
function RemoveMovies()
{
	RemoveDamageSystemMovie();
	Super.RemoveMovies();
}
*/

function RemoveMovies()
{
	//@Shahman: we will begin monitoring the scaleform removal procedure

	//Let's start by Tracing our last function calls
	`log("======================= " $self.Class $" =========================");
	ScriptTrace();
	// We will now check if each active GFx class has any movie open or not. 
	// ONLY when it is still open and active, we will CLOSE them. we can't CLOSE something that is no longer exists.
	// this could be the main reason of the crash in the first place. but as of (5/9/2014), its too early to tell.
	// for now, we need to monitor this.

	if (Scoreboard != none) {
		`log("Scoreboard.bMovieIsOpen? " $ Scoreboard.bMovieIsOpen);
		if (Scoreboard.bMovieIsOpen) {
			Scoreboard.Close(true);
		}
		Scoreboard = none;
	}		

	if (PTMovie != none) {
		`log("PTMovie.bMovieIsOpen? " $ PTMovie.bMovieIsOpen);
		if (PTMovie.bMovieIsOpen) {
			PTMovie.ClosePTMenu(true);
		}
		PTMovie = none;
	}
	if ( DamageSystemMovie != None ) {
		`log("DamageSystemMovie.bMovieIsOpen? " $ DamageSystemMovie.bMovieIsOpen);
		if (DamageSystemMovie.bMovieIsOpen) {
			DamageSystemMovie.Close(true);
		}
		DamageSystemMovie = None;
	}
	if ( RxPauseMenuMovie != None ) {
		`log("RxPauseMenuMovie.bMovieIsOpen? " $ RxPauseMenuMovie.bMovieIsOpen);
		if (RxPauseMenuMovie.bMovieIsOpen) {
			RxPauseMenuMovie.Close(true);
		}
		RxPauseMenuMovie = None;
	}
	if( HudMovie != None) {
		`log("HudMovie.bMovieIsOpen? " $ HudMovie.bMovieIsOpen);
		if (HudMovie.bMovieIsOpen) {
			HudMovie.close(true);
		}
		HudMovie = None;
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
	
	
	if(HudMovie != None && HudMovie.bMovieIsOpen && DrawFlashHUD)
		HudMovie.TickHUD(); //Draw flash HUD
	if(Scoreboard != None && Scoreboard.bMovieIsOpen)
		Scoreboard.Draw(); 	
	
	if (DamageSystemMovie != None && DamageSystemMovie.bMovieIsOpen && DrawDamageSystem)
		DamageSystemMovie.TickHud(PlayerOwner); //Draw flash damage screen

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
		
	UTGRI = UTGameReplicationInfo(WorldInfo.GRI);

	if (!WorldInfo.IsPlayingDemo())
	{
		TempFont = Canvas.Font;
		DisplayRadioCommands();
		Canvas.Font = TempFont;
	}
	
	if (UTGRI != None && UTGRI.bMatchIsOver)
	{
		if(PTMovie != none)
		{
			`log("=======================" $self.Class $"=========================");
			`log("PTMovie.bMovieIsOpen? " $PTMovie.bMovieIsOpen);
			ScriptTrace();
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


	DoSpotting();
	//DrawSpotTargets();
	DrawPlayAreaAnnouncement();
	DrawReticule();

	 
   if(PlayerOwner.Pawn != None) 
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

function DrawSpotTargets()
{
	local actor SpotTarget;
	//local int i;
	local vector screenLoc;
	local bool bIsBehindMe;
	
	foreach SpotTargets(SpotTarget)
	{
		/**
		if(i >= NumSpotTargetDots) {
			hudMovie.newSpot(i);
			NumSpotTargetDots++;
		}
		*/
		//i++;	
		if(Rx_Building(SpotTarget) != None || Rx_Vehicle_Harvester(SpotTarget) != None || Rx_Defence(SpotTarget) != None
			|| (SpotTarget.GetTeamNum() == PlayerOwner.GetTeamNum()))
			continue;	
			
		if(Rx_Pawn_SBH(SpotTarget) != None)
		{
			if (SpotTarget.GetStateName() == 'Stealthed' || SpotTarget.GetStateName() == 'BeenShot' || Rx_Pawn_SBH(SpotTarget).bStealthRecoveringFromBeeingShotOrSprinting)
			{
				continue;
			}
		
		}				
			
		bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(PlayerOwner.ViewTarget.Location,PlayerOwner.Rotation,SpotTarget.location) < -0.5;
		
		if(bIsBehindMe || (Rx_Building(SpotTarget) == None && !FastTrace(SpotTarget.location,PlayerOwner.ViewTarget.Location,,true)))
		{
			if(Rx_Building(SpotTarget) == None)
				//@Shahman: temp commented out the following line.
				//SpotTargets.RemoveItem(SpotTarget);
			continue;
		}
		
		screenLoc = Canvas.Project(SpotTarget.location);
		//screenLoc = Canvas.Project(SpotTarget.location + Pawn(SpotTarget).GetCollisionHeight() * vect(0,0,1.1));
		
		//ScreenLoc.X = FClamp(ScreenLoc.X, 0.f, Canvas.ClipX - 20);
		//ScreenLoc.Y = FClamp(ScreenLoc.Y, 0.f, Canvas.ClipY - 20);
		ScreenLoc.X -= 25.5;
		ScreenLoc.Y -= 25;
		Canvas.SetPos(ScreenLoc.X, ScreenLoc.Y);		

		Canvas.SetDrawColor(255,0,0,255);
		//Canvas.SetPos(ScreenLoc.X-SizeX*0.005, ScreenLoc.Y-SizeY*0.01);
		Canvas.DrawIcon(EnemySpottedIcon,screenLoc.X-SizeX*0.005,screenLoc.Y-SizeY*0.01);
		// Canvas.DrawBox(SizeX*0.01, SizeY*0.02);
		
		//hudMovie.updateSpot(i-1, screenLoc.x *RatioX, screenLoc.y *Ratioy);		
		//hudMovie.updateSpot(i-1, screenLoc.x, screenLoc.y);		
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
				Text = B.GetHumanReadableName() $ ":" @ B.GoalString;
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
	local Rx_Pawn_SBH sbh;
	
	if(Rx_Controller(PlayerOwner) == None)
		return;
	bPlayerIsSpotting = Rx_Controller(PlayerOwner).bSpotting;

	if (bPlayerIsSpotting)
	{
		// if we have an actor targeted, and it's not already spotted
		if (TargetingBox.TargetedActor != None && SpotTargets.Find(TargetingBox.TargetedActor) == -1)
		{
			// If we're spotting a building
			if (Rx_Building(TargetingBox.TargetedActor) != None || Rx_BuildingAttachment(TargetingBox.TargetedActor) != None)
				AddNewSpotTarget(Rx_Building(TargetingBox.TargetedActor) != None ? TargetingBox.TargetedActor : Rx_BuildingAttachment(TargetingBox.TargetedActor).OwnerBuilding.BuildingVisuals);
			else			
				AddNewSpotTarget(TargetingBox.TargetedActor);
		}
		else if(TargetingBox.TargetedActor == None && Rx_Pawn_SBH(GetActorWeaponIsAimingAt()) != None)
		{
			sbh = Rx_Pawn_SBH(GetActorWeaponIsAimingAt());
			if (!sbh.IsInState('Stealthed'))
				AddNewSpotTarget(sbh);		
		}
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
	//TraceRange = (WeaponOwner.WeaponFireTypes[0] == EWFT_Projectile) ? GetProjectileRange(WeaponOwner) : WeaponOwner.WeaponRange;
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

function DrawNewScorePanel()
{
	local float YL, SizeSX, SizeSY;
	local int  FirstTeamID, I;
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

	
	// If we have no GRI, no point in drawing the score panel.
	if(WorldInfo.GRI == none)
		return;
	
	//Canvas.Font = Font'RenXFonts.Agency12';
	//Canvas.Font = GetFontSizeIndex(1);
	Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small'; //Font'RenXHud.Font.AS_small';
	Canvas.TextSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ", SizeSX, SizeSY, 0.6f, 0.6f);
	
    FontInfo = Canvas.CreateFontRenderInfo(true);
    FontInfo.bClipText = true;
    FontInfo.bEnableShadow = true;
    FontInfo.GlowInfo.GlowColor = MakeLinearColor(1.0, 0.0, 0.0, 1.0);
    GlowRadius.X=2.0;
    GlowRadius.Y=1.0;
    FontInfo.GlowInfo.bEnableGlow = true;
    FontInfo.GlowInfo.GlowOuterRadius = GlowRadius;	

	DrawScorePanelTitle(true);
	YL = ScorePanelY + SizeSY + 10.0f;
	FirstTeamID = 0;

	// draw the teams
	switch (ScorePanelMode)
	{
		case 0:
		case 1: // show team points and rank
		case 2:
		case 3:
			// Draw the first team
			if (WorldInfo.GRI != None && WorldInfo.GRI.Teams.Length > 1)
			{
				Canvas.DrawColor = Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetTeamColor();
				Canvas.SetPos(DrawStartX[0] - 37, YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).ReplicatedSize, false,,,FontInfo);
				Canvas.SetPos(DrawStartX[0], YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetTeamName(), false,,,FontInfo);
				
				if(bDrawAdditionalPlayerInfo)
				{
					DrawHarvesterHealth(FirstTeamID,YL,FontInfo);		
				}
				
				
				Canvas.DrawColor = Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetTeamColor();
				Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetRenScore()), YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetRenScore(), false,,,FontInfo);

				YL += SizeSY + 5.0f;

				FirstTeamID = FirstTeamID == 0 ? 1 : 0; // set new team id to draw

				// Draw the other team
				Canvas.DrawColor = Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetTeamColor();
				Canvas.SetPos(DrawStartX[0] - 37, YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).ReplicatedSize, false,,,FontInfo);
				Canvas.SetPos(DrawStartX[0], YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetTeamName(), false,,,FontInfo);
				
				if(bDrawAdditionalPlayerInfo)
				{
					DrawHarvesterHealth(FirstTeamID,YL,FontInfo);	
				}				
				
				Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetRenScore()), YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetRenScore(), false,,,FontInfo);
			}
			break;
		default:
			break;
	}

	YL += SizeSY + 4.0f;
	YL += SizeSY + 4.0f;
	DrawScorePanelTitle(,YL - ScorePanelY);
	YL += SizeSY + 10.0f;

	if(WorldInfo.TimeSeconds - LastScoreboardRenderTime > 1.0)
	{ 
		PRIArray = WorldInfo.GRI.PRIArray;
		
		foreach WorldInfo.GRI.PRIArray(pri)
		{
			if(Rx_Pri(pri) == None)
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
							DistToSpot = VSize(TempActor.location - P.location);
							if(NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist) {
								NearestSpotDist = DistToSpot;	
								NearestSpotMarker = SpotMarker;
							}
						}
						Rx_Pri(PRI).SetPawnArea(NearestSpotMarker.GetSpotName());
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
				
				if (!PRIArray[I].bIsSpectator)
				{
					if(Rx_PRI(PRIArray[I]).Team == None)
						continue;
					if (PRIArray[I].Owner == self.Owner)
						Canvas.SetDrawColor(0,255,0,255);
					else
						Canvas.DrawColor = UTTeamInfo(Rx_PRI(PRIArray[I]).Team).GetHUDColor();
					Canvas.SetPos(DrawStartX[0] - 40, YL);
					Canvas.DrawText(I+1, false,,,FontInfo);
				      
					Canvas.SetPos(DrawStartX[0] - 5, YL);					
					
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
						Canvas.SetPos(DrawStartX[0] - 10, YL);
						if(PlayerOwner.GetTeamNum() == PRIArray[I].GetTeamNum())
						{
							Canvas.DrawRect(StrLeng(PRIArray[I].GetHumanReadableName()$" | "$TempCredits$" | "
									$Rx_PRI(PRIArray[I]).GetPawnArea()
									$TempStr)+10,15);
						} else
						{
							Canvas.DrawRect(StrLeng(PRIArray[I].GetHumanReadableName())+10,15);
						}
						
						if (PRIArray[I].Owner == self.Owner)
							Canvas.SetDrawColor(0,255,0,255);
						else
							Canvas.DrawColor = UTTeamInfo(Rx_PRI(PRIArray[I]).Team).GetHUDColor();									
						
						Canvas.SetPos(DrawStartX[0] - 5, YL);
						
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
						Canvas.DrawText(PRIArray[I].GetHumanReadableName(), false,,,FontInfo);	
					Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_Pri(PRIArray[I]).GetRenScore()), YL);
					
					
					Canvas.DrawText(Rx_Pri(PRIArray[I]).GetRenScore(), false,,,FontInfo);
					YL += SizeSY + 5.0f;
				}
			}
			break;
		case 2: // show only players score and position
			TempStr = "";

			Canvas.SetDrawColor(0,255,0,255);
			Canvas.SetPos(DrawStartX[0] - 40, YL);
			Canvas.DrawText(I+1, false,,,FontInfo);
		      
			Canvas.SetPos(DrawStartX[0] - 5, YL);						
			Canvas.DrawText(PlayerOwner.PlayerReplicationInfo.GetHumanReadableName(), false,,,FontInfo);	
			Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore()), YL);
			Canvas.DrawText(Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore(), false,,,FontInfo);
			YL += SizeSY + 5.0f;
		
	   default:
			break;					
	}
	if(bDrawAdditionalPlayerInfo)
	{
		YL += SizeSY + 10.0f;
		Canvas.SetPos(DrawStartX[0]-40, YL);
		Canvas.SetDrawColor(0, 255, 0, 255);
		Canvas.DrawText("Your Score this minute: " $ Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore()-Rx_Pri(PlayerOwner.PlayerReplicationInfo).ScoreLastMinutes, false,,,FontInfo);
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
		//case 1: //
		//  case 3: //
		//default:
               //WholeMinus = StrLeng("Player") + StrLeng("Kills") + StrLeng("Deaths") + StrLeng("K/D") + StrLeng("Credits") + StrLeng("Score");
               //break;
   }

   //if ((ScorePanelMode % 2) == 1) Plus = 5; else Plus = 1;
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
	local int Idx, XPos, YPos;
	local float XL, YL;
	local array<String> AvailableRadioCommands;
	local Rx_Controller pc;
	local string s;
	local bool bDrawingMapVotes;


	pc = Rx_Controller(PlayerOwner);
	bDrawingMapVotes = false;
	if(UTGRI != None && UTGRI.bMatchIsOver) {
		//TODO: Draw cleanup
// 		bDrawingMapVotes = true;
// 		RxGRI = Rx_GRI(UTGRI);
// 		for (i=0; i<RxGRI.MapVotesSize && RxGRI.MapVoteList[i] != ""; ++i)
// 		{
// 			s = i+1@". "@RxGRI.MapVoteList[i]@"("@RxGRI.MapVotes[i]@")";
// 			AvailableRadioCommands.AddItem(s);
// 		}
	} else {

		class'Rx_VoteMenuHandler'.static.DisplayOngoingVote(pc, Canvas, HUDCanvasScale, ConsoleColor);

		if (pc.VoteHandler != none)
		{
			/* one1: display vote related stuff only. */
			pc.VoteHandler.Display(Canvas, HUDCanvasScale, ConsoleMessagePosX, ConsoleMessagePosY, ConsoleColor);
			return;
		}

		if ( !Rx_PlayerInput(PlayerOwner.PlayerInput).bAltPressed && !Rx_PlayerInput(PlayerOwner.PlayerInput).bCntrlPressed)
			return;
		else if(Rx_PlayerInput(PlayerOwner.PlayerInput).bAltPressed && Rx_PlayerInput(PlayerOwner.PlayerInput).bCntrlPressed){
			s = "1. "@pc.RadioCommandsText[20];
			AvailableRadioCommands.AddItem(s);
			s = "2. "@pc.RadioCommandsText[21];
			AvailableRadioCommands.AddItem(s);
			s = "3. "@pc.RadioCommandsText[22];
			AvailableRadioCommands.AddItem(s);
			s = "4. "@pc.RadioCommandsText[23];
			AvailableRadioCommands.AddItem(s);
			s = "5. "@pc.RadioCommandsText[24];
			AvailableRadioCommands.AddItem(s);
			s = "6. "@pc.RadioCommandsText[25];
			AvailableRadioCommands.AddItem(s);
			s = "7. "@pc.RadioCommandsText[26];
			AvailableRadioCommands.AddItem(s);
			s = "8. "@pc.RadioCommandsText[27];
			AvailableRadioCommands.AddItem(s);
			s = "9. "@pc.RadioCommandsText[28];
			AvailableRadioCommands.AddItem(s);
			s = "0. "@pc.RadioCommandsText[29];
			AvailableRadioCommands.AddItem(s);
			s = "V: "@pc.VoteCommandText;
			AvailableRadioCommands.AddItem(s);
			s = "N: "@pc.DonateCommandText;
			AvailableRadioCommands.AddItem(s);
		} else if (Rx_PlayerInput(PlayerOwner.PlayerInput).bCntrlPressed) {
			s = "1. "@pc.RadioCommandsText[0];
			AvailableRadioCommands.AddItem(s);
			s = "2. "@pc.RadioCommandsText[1];
			AvailableRadioCommands.AddItem(s);
			s = "3. "@pc.RadioCommandsText[2];
			AvailableRadioCommands.AddItem(s);
			s = "4. "@pc.RadioCommandsText[3];
			AvailableRadioCommands.AddItem(s);
			s = "5. "@pc.RadioCommandsText[4];
			AvailableRadioCommands.AddItem(s);
			s = "6. "@pc.RadioCommandsText[5];
			AvailableRadioCommands.AddItem(s);
			s = "7. "@pc.RadioCommandsText[6];
			AvailableRadioCommands.AddItem(s);
			s = "8. "@pc.RadioCommandsText[7];
			AvailableRadioCommands.AddItem(s);
			s = "9. "@pc.RadioCommandsText[8];
			AvailableRadioCommands.AddItem(s);
			s = "0. "@pc.RadioCommandsText[9];	
			AvailableRadioCommands.AddItem(s);
			s = "V: "@pc.VoteCommandText;
			AvailableRadioCommands.AddItem(s);
			s = "N: "@pc.DonateCommandText;
			AvailableRadioCommands.AddItem(s);
		} else if (Rx_PlayerInput(PlayerOwner.PlayerInput).bAltPressed) {
			s = "1. "@pc.RadioCommandsText[10];
			AvailableRadioCommands.AddItem(s);
			s = "2. "@pc.RadioCommandsText[11];
			AvailableRadioCommands.AddItem(s);
			s = "3. "@pc.RadioCommandsText[12];
			AvailableRadioCommands.AddItem(s);
			s = "4. "@pc.RadioCommandsText[13];
			AvailableRadioCommands.AddItem(s);
			s = "5. "@pc.RadioCommandsText[14];
			AvailableRadioCommands.AddItem(s);
			s = "6. "@pc.RadioCommandsText[15];
			AvailableRadioCommands.AddItem(s);
			s = "7. "@pc.RadioCommandsText[16];
			AvailableRadioCommands.AddItem(s);
			s = "8. "@pc.RadioCommandsText[17];
			AvailableRadioCommands.AddItem(s);
			s = "9. "@pc.RadioCommandsText[18];
			AvailableRadioCommands.AddItem(s);
			s = "0. "@pc.RadioCommandsText[19];
			AvailableRadioCommands.AddItem(s);
			s = "V: "@pc.VoteCommandText;
			AvailableRadioCommands.AddItem(s);
			s = "N: "@pc.DonateCommandText;
			AvailableRadioCommands.AddItem(s);
		}
	}

    XPos = (ConsoleMessagePosX * HudCanvasScale * Canvas.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * Canvas.SizeY) + 20* (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeY);
    
    Canvas.Font = Font'RenXHud.Font.RadioCommand_Medium'; //class'Engine'.Static.GetMediumFont();
    Canvas.DrawColor = ConsoleColor;

    Canvas.TextSize ("A", XL, YL);
    YPos -= YL * AvailableRadioCommands.Length; // DP_LowerLeft
    YPos -= YL; // Room for typing prompt

	if(bDrawingMapVotes) {
		XPos -= 30;	
	}

    for (Idx = 0; Idx < AvailableRadioCommands.Length; Idx++)
    {
    	Canvas.StrLen( AvailableRadioCommands[Idx], XL, YL );
		Canvas.SetPos( XPos, YPos );
		if(bDrawingMapVotes) {
			Canvas.DrawText( AvailableRadioCommands[Idx], false, 0.8, 0.8 );
		} else {
			Canvas.DrawText( AvailableRadioCommands[Idx], false );
		}
		YPos += YL;
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
	if (PlayerOwner == None || PlayerOwner.Pawn == None)
		return;

	if (Rx_Weapon(PlayerOwner.Pawn.Weapon) != None)
		Rx_Weapon(PlayerOwner.Pawn.Weapon).ActiveRenderOverlays(self);
	else if (Rx_Vehicle_Weapon(PlayerOwner.Pawn.Weapon) != None)
		Rx_Vehicle_Weapon(PlayerOwner.Pawn.Weapon).ActiveRenderOverlays(self);
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	HudMovie.DisplayHit(HitDir, Damage, damageType);
}

//chain the toggle from the Rx_Controller to the GFx Hud object where it occurs
function ToggleScoreboard()
{
	if (ScorePanelMode == 2) 
		ScorePanelMode = 1;
	else 
		ScorePanelMode = 2;
}

exec function SetShowScores(bool bEnableShowScores)
{
	// Don't allow displaying of leaderboard/scoreboard at same time
	if (LeaderboardMovie != None && LeaderboardMovie.bMovieIsOpen)
		return;

    if(bEnableShowScores)
    {
        //if ( Scoreboard == None )
        //{
            Scoreboard = new class'Rx_GFxUIScoreboard';
			Scoreboard.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
			Scoreboard.SetViewport(0,0,Canvas.ClipX, Canvas.ClipY);
			Scoreboard.SetViewScaleMode(SM_ExactFit);
			Scoreboard.SetTimingMode(TM_Real);
			Scoreboard.ExternalInterface = self;
		//}

        if (!Scoreboard.bMovieIsOpen)
        {
            Scoreboard.Start();            
            Scoreboard.Draw();            
        }
		
		SetVisible(false);
    }
    else if (Scoreboard != None && Scoreboard.bMovieIsOpen)
	{
		Scoreboard.Close(false);
		Scoreboard = None;
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

   //PlayerOwner.ClientMessage("ClassType: "$InMessageClass $" | Message: "$CriticalString);
	if (InMessageClass == class'Rx_DeathMessage')
	{
		if (RelatedPRI_1 == none)
		{
			if (switch == 1)    // Suicide
			{
				AddKillMessage(RelatedPRI_2, RelatedPRI_2);
				if (RelatedPRI_2 == PlayerOwner.PlayerReplicationInfo)
					AddDeathMessage(RelatedPRI_2, class<DamageType>(OptionalObject));
			}
			else   // Died
			{
				AddKillMessage(None, RelatedPRI_2);
				if (RelatedPRI_2 == PlayerOwner.PlayerReplicationInfo)
					AddDeathMessage(None, class<DamageType>(OptionalObject));
			}
		}
		else
		{
			AddKillMessage(RelatedPRI_1, RelatedPRI_2);
			if (RelatedPRI_2 == PlayerOwner.PlayerReplicationInfo)
				AddDeathMessage(RelatedPRI_1, class<DamageType>(OptionalObject));
		}
	}
	else if (InMessageClass == class'Rx_Message_Vehicle')
	{
		HudMovie.AddEVAMessage(CriticalString);
	}
	else if (InMessageClass == class'Rx_Message_Buildings')
	{
		if (Switch == 0)
			AddBuildingKillMessage(RelatedPRI_1, Rx_Building_Team_Internals(OptionalObject));
	}
	else if (InMessageClass == class'Rx_Message_TechBuilding')
	{
		switch (Switch)
		{
		case class'Rx_Building_TechBuilding_Internals'.const.GDI_CAPTURED:
			AddTechBuildingCaptureMessage(RelatedPRI_1, Rx_Building_Silo_Internals(OptionalObject), TEAM_GDI);
			break;
		case class'Rx_Building_TechBuilding_Internals'.const.NOD_CAPTURED:
			AddTechBuildingCaptureMessage(RelatedPRI_1, Rx_Building_Silo_Internals(OptionalObject), TEAM_Nod);
			break;
		case class'Rx_Building_TechBuilding_Internals'.const.GDI_LOST:
			AddTechBuildingLostMessage(RelatedPRI_1, Rx_Building_Silo_Internals(OptionalObject), TEAM_GDI);
			break;
		case class'Rx_Building_TechBuilding_Internals'.const.NOD_LOST:
			AddTechBuildingLostMessage(RelatedPRI_1, Rx_Building_Silo_Internals(OptionalObject), TEAM_Nod);
			break;
		}
	}
	else if (InMessageClass == class'Rx_CratePickup'.default.MessageClass)
	{ 
		HudMovie.AddEVAMessage(CriticalString);
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

function AddKillMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed )
{
	local string htmlMsg;

	if (Killer != none)
	{
		htmlMsg = GetColouredName(Killer);

		if (Killer != Killed)
			htmlMsg @= "killed" @ GetColouredName(Killed);
		else
			htmlMsg @= "suicided";	
	}
	else
		htmlMsg = GetColouredName(Killed) @ "died";
	
	HudMovie.AddGameEventMessage(htmlMsg);
}

function AddBuildingKillMessage(PlayerReplicationInfo Killer, Rx_Building_Team_Internals Building)
{
	HudMovie.AddGameEventMessage("* "$ GetColouredName(Killer) $" destroyed the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.BuildingName $"</font> *");
}

function AddTechBuildingCaptureMessage(PlayerReplicationInfo Capturer, Rx_Building_Team_Internals Building, byte CapturingTeam)
{
	if (Capturer != None)
		HudMovie.AddGameEventMessage(GetColouredName(Capturer) $" captured the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.BuildingName $"</font>");
	else
		HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(CapturingTeam) $"'>"$ class'Rx_Game'.static.GetTeamName(CapturingTeam) $"</font> captured the <font color='"$ GetTeamColour(Building.TeamID) $"'>"$ Building.BuildingName $"</font>");
}
function AddTechBuildingLostMessage(PlayerReplicationInfo Capturer, Rx_Building_Team_Internals Building, byte LosingTeam)
{
	local byte InstigatingTeam;

	if (Capturer != None)
		HudMovie.AddGameEventMessage(GetColouredName(Capturer) $" neutralized the <font color='"$ GetTeamColour(LosingTeam) $"'>"$ Building.BuildingName $"</font>");
	else
	{
		InstigatingTeam = LosingTeam == TEAM_GDI ? TEAM_Nod : TEAM_GDI;
		HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(InstigatingTeam) $"'>"$ class'Rx_Game'.static.GetTeamName(InstigatingTeam) $"</font> neutralized the <font color='"$ GetTeamColour(LosingTeam) $"'>"$ Building.BuildingName $"</font>");
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

function ShowHitMarker()
{
	HitEffectAplha = 100;
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
    if ( RxPauseMenuMovie != none && RxPauseMenuMovie.bMovieIsOpen ) {
		
		if( !WorldInfo.IsPlayInMobilePreview() ) {
			RxPauseMenu_FadeSystemMovie.HideSystem();
			CompletePauseMenuClose();
		} else {
			// On mobile previewer, close right away
			CompletePauseMenuClose();
		}
	} else {
		
		CloseOtherMenus();

		// Do not prevent 'escape' to unpause once we finished the game
		if (Rx_GRI(PlayerOwner.WorldInfo.GRI) != none && Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver) {
			if (Scoreboard != none && Scoreboard.EndGameTime > 0 && (Rx_GRI(PlayerOwner.WorldInfo.GRI).RenEndTime - PlayerOwner.WorldInfo.RealTimeSeconds) > 0) {
				PlayerOwner.SetPause(false);

				if (RxPauseMenu_FadeSystemMovie == None) {
					RxPauseMenu_FadeSystemMovie = new class'Rx_GFxPauseMenu_FadeSystem';
					RxPauseMenu_FadeSystemMovie.MovieInfo = SwfMovie'RenXPauseMenu.RenXFadeScreen';
					RxPauseMenu_FadeSystemMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
					RxPauseMenu_FadeSystemMovie.SetTimingMode(TM_Real);
				}
				if (RxPauseMenuMovie == None) {
					RxPauseMenuMovie = new class'Rx_GFxPauseMenu';
					RxPauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
					RxPauseMenuMovie.SetTimingMode(TM_Real);
				}


				SetVisible(false);
				RxPauseMenu_FadeSystemMovie.Start();
				RxPauseMenu_FadeSystemMovie.ShowSystem();
				RxPauseMenuMovie.Start();
				//RxPauseMenuMovie.PlayOpenAnimation();

				// Do not prevent 'escape' to unpause if running in mobile previewer
				if( !WorldInfo.IsPlayInMobilePreview() ) {
					RxPauseMenuMovie.AddFocusIgnoreKey('Escape');
				}

				Scoreboard.RootMC.SetVisible(false);
			}
		} else {
			PlayerOwner.SetPause(True);

			if (RxPauseMenu_FadeSystemMovie == None) {
				RxPauseMenu_FadeSystemMovie = new class'Rx_GFxPauseMenu_FadeSystem';
				RxPauseMenu_FadeSystemMovie.MovieInfo = SwfMovie'RenXPauseMenu.RenXFadeScreen';
				RxPauseMenu_FadeSystemMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
				RxPauseMenu_FadeSystemMovie.SetTimingMode(TM_Real);
			}
			if (RxPauseMenuMovie == None) {
				RxPauseMenuMovie = new class'Rx_GFxPauseMenu';
				RxPauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
				RxPauseMenuMovie.SetTimingMode(TM_Real);
			}


			SetVisible(false);
			RxPauseMenu_FadeSystemMovie.Start();
			RxPauseMenu_FadeSystemMovie.ShowSystem();
			RxPauseMenuMovie.Start();
			//RxPauseMenuMovie.PlayOpenAnimation();

			// Do not prevent 'escape' to unpause if running in mobile previewer
			if( !WorldInfo.IsPlayInMobilePreview() ) {
				RxPauseMenuMovie.AddFocusIgnoreKey('Escape');
			}
		}
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
		RxPauseMenuMovie.Close(false);  // Keep the Pause Menu loaded in memory for reuse.
	}
	RxPauseMenuMovie = none;
	
	if (Rx_GRI(PlayerOwner.WorldInfo.GRI).bMatchIsOver) {
		if (Scoreboard != none) {
			Scoreboard.RootMC.SetVisible(true);
		}
	}
    SetVisible(true);
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

DefaultProperties
{
	
	YellowColor=(R=255,G=215,B=0,A=255)
	BlueColor=(R=0,G=0,B=255,A=255)
	ConsoleMessagePosY=0.08f // 0.8f
	MaxSpotDistance = 8000;
	ScorePanelY = 40.0f; // constant as it will be always on the right top
	
	DistText(0) = 70.0f
	DistText(1) = 10.0f
	DistText(2) = 10.0f
	DistText(3) = 20.0f
	DistText(4) = 10.0f
	DrawStartModifier = 0.0f
	
	EnemySpottedIcon = (Texture = Texture2D'RenXHud.T_NavMarker_Mini_Red', U= 0, V = 0, UL = 64, VL = 64)
	DefaultTargettingRange = 10000;

	NodColor            = "#FF0000"
	GDIColor            = "#FFC600"
	NeutralColor        = "#00FF00"
	PrivateFromColor    = "#2288FF"
	PrivateToColor      = "#0055FF"
	HostColor           = "#22BBFF"
	
	DrawCText = true 
	DrawTargetBox = true 
	DrawPlayerNames = true 
	DrawCaptureProgress = true 
	DrawDamageSystem = true 
	DrawFlashHUD = true 
}
