/**
 * UT Heads Up Display base functionality share by old HUD and Scaleform HUD
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTHUDBase extends UDKHUD
	dependson(UTWeapon)
	config(Game);

/** GFx movie used for displaying scores */
var GFxUIScoreboard     ScoreboardMovie;

/** GFx movie used for displaying pause menu */
var GFxUI_PauseMenu		PauseMenuMovie;

/** class of dynamic music manager used with this hud/gametype */
var class<UTMusicManager> MusicManagerClass;

/** Cached a typed Player controller.  Unlike PawnOwner we only set this once in PostBeginPlay */
var UTPlayerController UTPlayerOwner;

/** Cached reference to the GRI */
var UTGameReplicationInfo UTGRI;

/** This will be true if the hud is in splitscreen */
var bool bIsSplitScreen;

/** Whether to let actor overlays get drawn this tick */
var bool	bEnableActorOverlays;

var TextureCoordinates ToolTipSepCoords;
var float LastTimeTooltipDrawn;

var const Texture2D IconHudTexture;

/** Holds a reference to the font to use for a given console */
var config string ConsoleIconFontClassName;

/** If true, we will allow Weapons to show their crosshairs */
var bool bCrosshairShow;

/** If true, we will alter the crosshair when it's over a friendly */
var bool bCrosshairOnFriendly;

/** Make the crosshair green (found valid friendly */
var bool bGreenCrosshair;

/** Configurable crosshair scaling */
var float ConfiguredCrosshairScaling;

/** Used to pulse crosshair size */
var float LastPickupTime;

/** Various colors */
var const color BlackColor, GoldColor;

var const color LightGoldColor, LightGreenColor;

/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

/** Cache viewport size to determine if it has changed */
var int ViewX, ViewY;

/** GFx movie used for displaying the leaderboard */
var GFxUILeaderboard	LeaderboardMovie;

simulated function PostBeginPlay()
{
	local Pawn P;
	local UTGameObjective O;

	super.PostBeginPlay();

	UTPlayerOwner = UTPlayerController(PlayerOwner);

	SetTimer(1.0, true);

	// add actors to the PostRenderedActors array
	ForEach DynamicActors(class'Pawn', P)
	{
		if ( (UTPawn(P) != None) || (UTVehicle(P) != None) )
			AddPostRenderedActor(P);
	}

	foreach WorldInfo.AllNavigationPoints(class'UTGameObjective',O)
	{
		AddPostRenderedActor(O);
	}

	// find the controller icons font
	ConsoleIconFont=Font(DynamicLoadObject(ConsoleIconFontClassName, class'font', true));

	if (UTPlayerOwner.Announcer == None)
	{
		UTPlayerOwner.Announcer = Spawn(class'UTAnnouncer', UTPlayerOwner);
	}

	if (UTPlayerOwner.MusicManager == None)
	{
		UTPlayerOwner.MusicManager = Spawn(MusicManagerClass, UTPlayerOwner);
	}
}

simulated event Timer()
{
	Super.Timer();

	if ( UTGameReplicationInfo(WorldInfo.GRI) != None )
	{
		UTGameReplicationInfo(WorldInfo.GRI).SortPRIArray();
	}
}


exec function ShowMenu()
{
	// if using GFx HUD, use GFx pause menu
	TogglePauseMenu();
}

/** 
  * Reset movies since resolution changed
  */
function ResolutionChanged()
{
	local bool bNeedScoreboardMovie, bNeedPauseMenuMovie, bNeedLeaderboardMovie;

	bNeedScoreboardMovie =  ScoreboardMovie != None && ScoreboardMovie.bMovieIsOpen;
	bNeedPauseMenuMovie = PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen;
	bNeedLeaderboardMovie = LeaderboardMovie != none && LeaderboardMovie.bMovieIsOpen;

	RemoveMovies();
	if ( bNeedScoreboardMovie )
	{
		SetShowScores(true);
	}
	if ( bNeedPauseMenuMovie )
	{
		TogglePauseMenu();
	}

	if (bNeedLeaderboardMovie)
		SetShowLeaderboard(True);
}

/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
	LastHUDRenderTime = WorldInfo.TimeSeconds;

	bIsSplitscreen = class'Engine'.static.IsSplitScreen();

	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;
	if ( bIsSplitScreen )
		ResolutionScale *= 2.0;

	if ( (ViewX != Canvas.ClipX) || (ViewY != Canvas.ClipY) )
	{
		ResolutionChanged();
		ViewX = Canvas.ClipX;
		ViewY = Canvas.ClipY;
	}
	UTGRI = UTGameReplicationInfo(WorldInfo.GRI);

	if ( ScoreboardMovie != None && ScoreboardMovie.bMovieIsOpen )
	{
		ScoreboardMovie.Tick(RenderDelta);
	}

	if (LeaderboardMovie != none && LeaderboardMovie.bMovieIsOpen)
		LeaderboardMovie.Tick(RenderDelta);
}

/*
 * Complete close of Scoreboard.  Fired from Flash
 * when the "close" animation is finished.
 */
function OnCloseAnimComplete()
{
	// Close the scoreboard but keep it in memory.
    ScoreboardMovie.Close(false);
}

/*
 * Complete open of Scoreboard.  Fired from Flash
 * when the "open" animation is finished.
 */
function OnOpenAnimComplete()
{
}

/** 
  * Destroy existing Movies
  */
function RemoveMovies()
{
	if ( ScoreboardMovie != None )
	{
		ScoreboardMovie.Close(true);
		ScoreboardMovie = None;
	}
	if (PauseMenuMovie != None)
	{
		PauseMenuMovie.Close(true);
		PauseMenuMovie = None;
	}

	if (LeaderboardMovie != none)
	{
		LeaderboardMovie.Close(True);
		LeaderboardMovie = none;
	}
}

/** 
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	bEnableActorOverlays = bNewVisible;
	bShowHUD = bNewVisible;
}

/** 
  * Called when pause menu is opened
  */
function CloseOtherMenus();

/*
 * Toggle the Pause Menu on or off.
 * 
 */
function TogglePauseMenu()
{
    if ( PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen )
	{
		
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.PlayCloseAnimation();
		}
		else
		{
			// On mobile previewer, close right away
			CompletePauseMenuClose();
		}
	}
	else
    {
		CloseOtherMenus();

        PlayerOwner.SetPause(True);

        if (PauseMenuMovie == None)
        {
	        PauseMenuMovie = new class'GFxUI_PauseMenu';
            PauseMenuMovie.MovieInfo = SwfMovie'UDKHud.udk_pausemenu';
            PauseMenuMovie.bEnableGammaCorrection = FALSE;
			PauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
            PauseMenuMovie.SetTimingMode(TM_Real);
        }

		SetVisible(false);
        PauseMenuMovie.Start();
        PauseMenuMovie.PlayOpenAnimation();

		// Do not prevent 'escape' to unpause if running in mobile previewer
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.AddFocusIgnoreKey('Escape');
		}
    }
}

/*
 * Complete necessary actions for OnPauseMenuClose.
 * Fired from Flash.
 */
function CompletePauseMenuClose()
{
    PlayerOwner.SetPause(False);
    PauseMenuMovie.Close(false);  // Keep the Pause Menu loaded in memory for reuse.
    SetVisible(true);
}

/* toggles displaying scoreboard (used by console controller)
*/
exec function ReleaseShowScores()
{
	SetShowScores(false);
}

/** 
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
	return class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
}

/*
 * SetShowScores() override to display GFx Scoreboard.
 * If the scoreboard has been loaded, this will play the appropriate
 * Flash animation.
 */
exec function SetShowScores(bool bEnableShowScores)
{
	// Don't allow displaying of leaderboard/scoreboard at same time
	if (LeaderboardMovie != none && LeaderboardMovie.bMovieIsOpen)
		return;

    if(bEnableShowScores)
    {
        if ( ScoreboardMovie == None )
        {
            ScoreboardMovie = new class'GFxUIScoreboard';
			ScoreboardMovie.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
			ScoreboardMovie.SetTimingMode(TM_Real);
			ScoreboardMovie.ExternalInterface = self;
		}

        if ( !ScoreboardMovie.bMovieIsOpen )
        {
            ScoreboardMovie.Start();
            ScoreboardMovie.PlayOpenAnimation();
        }
		SetVisible(false);
    }
    else if ( (ScoreboardMovie != None) && ScoreboardMovie.bMovieIsOpen )
	{
		ScoreboardMovie.PlayCloseAnimation();
		SetVisible(true);
	}
}

/**
 * Toggles display of the leaderboard
 */
exec function ToggleLeaderboard()
{
	SetShowLeaderboard(LeaderboardMovie == none || !LeaderboardMovie.bMovieIsOpen);
}

/**
 * Displays/closes the leaderboard
 */
exec function SetShowLeaderboard(bool bEnableLeaderboard)
{
	// Don't allow displaying of leaderboard/scoreboard at same time
	if (ScoreboardMovie != none && ScoreboardMovie.bMovieIsOpen)
		return;

	if (bEnableLeaderboard)
	{
		if (LeaderboardMovie == none)
		{
			LeaderboardMovie = new Class'GFxUILeaderboard';

			LeaderboardMovie.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
			LeaderboardMovie.SetTimingMode(TM_Real);
			// NOTE: Leaderboard does not need its external interface set
		}

		if (!LeaderboardMovie.bMovieIsOpen)
		{
			LeaderboardMovie.Start();
			LeaderboardMovie.PlayOpenAnimation();
		}

		SetVisible(False);
	}
	else if (LeaderboardMovie != none && LeaderboardMovie.bMovieIsOpen)
	{
		LeaderboardMovie.PlayCloseAnimation();
		SetVisible(True);
	}
}

//Given a input command of the form GBA_ and its mapping store that in a lookup for future use
function DrawToolTip(Canvas Cvs, PlayerController PC, string Command, float X, float Y, float U, float V, float UL, float VL, float ResScale, optional Texture2D IconTexture = default.IconHudTexture, optional float Alpha=1.0)
{
	local float Left,xl,yl;
	local float ScaleX, ScaleY;
	local float WholeWidth;
	local string MappingStr; //String of key mapping
	local font OrgFont, BindFont;
	local string Key;

	//Catchall for spectators who don't need tooltips
	if (PC.PlayerReplicationInfo.bOnlySpectator || LastTimeTooltipDrawn == WorldInfo.TimeSeconds)
	{
		return;
	}

	//Only draw one tooltip per frame
	LastTimeTooltipDrawn = WorldInfo.TimeSeconds;
	if (class'Engine'.static.IsRealDStereoEnabled())
	{
		// Unless stereo rendering is enabled... then we want to render 2x!
		LastTimeTooltipDrawn = WorldInfo.TimeSeconds - 0.001;
	}

	OrgFont = Cvs.Font;

	//Get the fully localized version of the key binding
	UTPlayerController(PC).BoundEventsStringDataStore.GetStringWithFieldName(Command, MappingStr);
	if (MappingStr == "")
	{
		`warn("No mapping for command"@Command);
		return;
	}

	TranslateBindToFont(MappingStr, BindFont, Key);

	if ( BindFont != none )
	{
		//These values might be negative (for flipping textures)
		ScaleX = abs(UL);
		ScaleY = abs(VL);
		Cvs.DrawColor = default.WhiteColor;
		Cvs.DrawColor.A = Alpha * 255;

		//Find the size of the string to be draw
		Cvs.Font = BindFont;
		Cvs.StrLen(Key, XL,YL);

		//Figure the offset from center for the left side
		WholeWidth = XL + (ScaleX * ResScale) + (default.ToolTipSepCoords.UL * ResScale);
		Left = X - (WholeWidth * 0.5);

		//Center and draw the key binding string
		Cvs.SetPos(Left, Y - (YL * 0.5));
		Cvs.DrawText(Key, true, , , TextRenderInfo);

		//Position to the end of the keybinding string
		Left += XL;
		Cvs.SetPos(Left, Y - (default.ToolTipSepCoords.VL * ResScale * 0.5));
		//Draw the separation icon (arrow)
		Cvs.DrawTile(default.IconHudTexture,default.ToolTipSepCoords.UL * ResScale, default.ToolTipSepCoords.VL * ResScale,
			default.ToolTipSepCoords.U,default.ToolTipSepCoords.V,default.ToolTipSepCoords.UL,default.ToolTipSepCoords.VL);

		//Position to the end of the separation icon
		Left += (default.ToolTipSepCoords.UL * ResScale);
		Cvs.SetPos(Left, Y - (ScaleY * ResScale * 0.5) );
		//Draw the tooltip icon
		Cvs.DrawTile(IconTexture, ScaleX * ResScale, ScaleY * ResScale, U, V, UL, VL);
	}

	Cvs.Font = OrgFont;
}

function bool CheckCrosshairOnFriendly()
{
	local float Size;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;
	local actor HitActor;
	local UTVehicle V, HitV;
	local UTWeapon W;
	local int SeatIndex;
	local Pawn MyPawnOwner;

	MyPawnOwner = Pawn(PlayerOwner.ViewTarget);
	if ( MyPawnOwner == None )
	{
		return false;
	}

	V = UTVehicle(MyPawnOwner);
	if ( V != None )
	{
		for ( SeatIndex=0; SeatIndex<V.Seats.Length; SeatIndex++ )
		{
			if ( V.Seats[SeatIndex].SeatPawn == MyPawnOwner )
			{
				HitActor = V.Seats[SeatIndex].AimTarget;
				break;
			}
		}
	}
	else
	{
		W = UTWeapon(MyPawnOwner.Weapon);
		if ( W != None && W.EnableFriendlyWarningCrosshair())
		{
			StartTrace = W.InstantFireStartTrace();
			EndTrace = StartTrace + W.MaxRange() * vector(PlayerOwner.Rotation);
			HitActor = MyPawnOwner.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true, vect(0,0,0),, TRACEFLAG_Bullet);

			if ( Pawn(HitActor) == None )
			{
				HitActor = (HitActor == None) ? None : Pawn(HitActor.Base);
			}
		}
	}

	if ( (Pawn(HitActor) == None) || !Worldinfo.GRI.OnSameTeam(HitActor, MyPawnOwner) )
	{
		return false;
	}

	// if trace hits friendly, draw "no shoot" symbol
	Size = 28 * (Canvas.ClipY / 768);
	Canvas.SetPos( (Canvas.ClipX * 0.5) - (Size *0.5), (Canvas.ClipY * 0.5) - (Size * 0.5) );
	HitV = UTVehicle(HitActor);
	if ( (HitV != None) && (HitV.Health < HitV.default.Health) && ((V != None) ? false : (UTWeap_Linkgun(W) != None)) )
	{
		Canvas.SetDrawColor(255,255,128,255);
		Canvas.DrawTile(class'UTHUD'.default.AltHudTexture, Size, Size, 600, 262, 28, 27);
	}
	return true;
}


simulated function DrawShadowedTile(texture2D Tex, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local Color B;

	B = BlackColor;
	B.A = TileColor.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawColor = B;
	Canvas.DrawTile(Tex,XL,YL,U,V,UL,VL);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawTile(Tex,XL,YL,U,V,UL,VL);
}

simulated function DrawShadowedStretchedTile(texture2D Tex, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local LinearColor C,B;

	C = ColorToLinearColor(TileColor);
	B = ColorToLinearColor(BlackColor);
	B.A = C.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawTileStretched(Tex,XL,YL,U,V,UL,VL,B);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawTileStretched(Tex,XL,YL,U,V,UL,VL,C);
}

simulated function DrawShadowedRotatedTile(texture2D Tex, Rotator Rot, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local Color B;

	B = BlackColor;
	B.A = TileColor.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawColor = B;
	Canvas.DrawRotatedTile(Tex,Rot,XL,YL,U,V,UL,VL);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawRotatedTile(Tex,Rot,XL,YL,U,V,UL,VL);
}

defaultproperties
{
	MusicManagerClass=class'UTGame.UTMusicManager'
	ToolTipSepCoords=(U=260,V=379,UL=29,VL=27)
	IconHudTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseB'
	BindTextFont=MultiFont'UI_Fonts_Final.HUD.MF_Large'
	ConfiguredCrosshairScaling=1.0

	BlackColor=(R=0,G=0,B=0,A=255)
	GoldColor=(R=255,G=183,B=11,A=255)
	LightGoldColor=(R=255,G=255,B=128,A=255)
	LightGreenColor=(R=128,G=255,B=128,A=255)
}


