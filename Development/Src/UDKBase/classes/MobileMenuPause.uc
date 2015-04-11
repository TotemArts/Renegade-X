/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class MobileMenuPause extends MobileMenuScene
	dependson(SimpleGame);

// A reference to the help screen that we will fade out as the player enters the game
var MobileMenuControls FadingControlsMenu;

var bool bHelpFadingOut;
var float HelpFadeTime;
var float HelpFadeDuration;

/** Holds how much of the menu is shown. */
var float ShownSize;

var float Scale;

var bool bFlashHelp;
var float FlashDuration;
var float FlashTime;

event InitMenuScene(MobilePlayerInput PlayerInput, int ScreenWidth, int ScreenHeight, bool bIsFirstInitialization)
{
	local int i;

	Super.InitMenuScene(PlayerInput, 960, 640, bIsFirstInitialization);

	Scale = /*(ScreenWidth >= 960) ? 1.0 : */Float(ScreenWidth) / 960.0;
	for(i=1;i<MenuObjects.Length;i++)
	{
		MenuObjects[i].Left *= Scale;
		MenuObjects[i].Top *= Scale;
		MenuObjects[i].Width *= Scale;
		MenuObjects[i].Height *= Scale;
	}
	
	MenuObjects[0].Height *= Scale;
	MenuObjects[0].Width *= Float(ScreenWidth) / 960.0;
	if (ScreenWidth == 1024)
	{
		MenuObjects[0].Width = 2048;
	}
	else if (ScreenWidth < 960)
	{
		MobileMenuImage(MenuObjects[0]).ImageDrawStyle=IDS_Stretched;
	}

	// Handle the main window

	Width = ScreenWidth;
	Height *= Scale;
	// Position the buttons..

	if (class'WorldInfo'.static.IsConsoleBuild(CONSOLE_IPhone))
	{
		MenuObjects[1].Left = (ScreenWidth / 4) - (MenuObjects[2].Width/2);
		MenuObjects[2].Left = ScreenWidth - (ScreenWidth / 4) - (MenuObjects[2].Width/2);
		MenuObjects.length = 3;
	}
	else
	{
		MenuObjects[3].Left = (ScreenWidth / 2) - (MenuObjects[3].Width/2);	// Put the benchmark button in the middle... note there isn't quite room for it here, will have to get an artist to help clean this up...
		MenuObjects[1].Left = (MenuObjects[3].Left/2) - (MenuObjects[1].Width/2);
		MenuObjects[2].Left = (MenuObjects[3].Left/2) + MenuObjects[3].Left + MenuObjects[3].Width - (MenuObjects[2].Width/2);
		MenuObjects[4].Left = Width;
	}

	Top = -Height;
	ShownSize = Height - MenuObjects[1].Top + (8 * Scale);	// @ToDo Make the top border size config.
}

event OnTouch(MobileMenuObject Sender, ETouchType EventType, float TouchX, float TouchY)
{
	local CastlePC PC;

	if (Sender == none)
	{
		return;
	}

	if (EventType != Touch_Began)
	{
		return;
	}

	PC = CastlePC(InputOwner.Outer);

	if (Sender.Tag == "BIRDSEYE")
	{
		// start or stop the matinee
		if (PC.bIsInAttractMode)
		{
			PC.ExitAttractMode();
		}
		else
		{
			PC.EnterAttractMode();
		}
	}
	else if (Sender.Tag == "ABOUT")
	{
		if (PC.bIsInBenchmarkMode)
		{
			PC.ExitAttractMode();
		}
		InputOwner.Outer.ConsoleCommand("mobile about technology/epic-citadel");
	}
	else if (Sender.Tag == "BENCHMARK")
	{
		// Enter benchmark mode if we're not already in it
		if (!PC.bIsInBenchmarkMode)
		{
			InputOwner.Outer.ConsoleCommand("mobile benchmark begin");
			PC.EnterAttractMode( true );
		}
	}
	else if (Sender.Tag == "SETTINGS")
	{
		// Open up the settings menu
		InputOwner.Outer.ConsoleCommand("mobile SettingsMenu");
	}
}

function OnResetMenu()
{
}


/**
 * When the submenu is open, force the freelook zone to have a full opaque inactive color so we
 * can see it in the input samples.
 */
function HackInactiveAlpha(float NewValue)
{
	local MobileInputZone Zone;
	Zone = MobilePlayerInput(CastlePC(InputOwner.Outer).PlayerInput).FindZone("FreeMoveZone");
	Zone.InactiveAlpha=NewValue;
}

function RenderScene(Canvas Canvas,float RenderDelta)
{
	if (InputOwner == none)
	{
		return;
	}
	// Set the right UVs
	if (CastlePC(InputOwner.Outer).bIsInAttractMode)

	{
		MobileMenuButton(MenuObjects[2]).ImagesUVs[0].U = 610;
		MobileMenuButton(MenuObjects[2]).ImagesUVs[0].V = 440;
		MobileMenuButton(MenuObjects[2]).ImagesUVs[1].U = 610;
		MobileMenuButton(MenuObjects[2]).ImagesUVs[1].V = 542;
	} 
	else
	{
		MobileMenuButton(MenuObjects[2]).ImagesUVs[0].U = 256;
		MobileMenuButton(MenuObjects[2]).ImagesUVs[0].V = 1230;
		MobileMenuButton(MenuObjects[2]).ImagesUVs[1].U = 256;
		MobileMenuButton(MenuObjects[2]).ImagesUVs[1].V = 1344;
	}

	Super.RenderScene(Canvas, RenderDelta);
}

function bool OnSceneTouch(ETouchType EventType, float X, float Y, bool bInside)
{
	local CastlePC PC;

	PC = CastlePC(InputOwner.Outer);
	if (PC.bPauseMenuOpen)
	{
		if (EventType == Touch_Began)
		{
			if( PC.SliderZone != none &&
				( X >= PC.SliderZone.CurrentLocation.X && X < PC.SliderZone.CurrentLocation.X + PC.SliderZone.ActiveSizeX &&
				  Y >= PC.SliderZone.CurrentLocation.Y && Y < PC.SliderZone.CurrentLocation.Y + PC.SliderZone.ActiveSizeY ) )
			{
				PC.ResetMenu();
				return true;
			}
		}
	}
	return bInside;
}

function FlashHelp(float Duration)
{
	bFlashHelp = true;
	FlashDuration = Duration;
	FlashTime = 0;
	bHelpFadingOut = false;
	HelpFadeTime = 0;
}

function ReleaseHelp()
{
	if (bFlashHelp)
	{
		bFlashHelp = false;
		bHelpFadingOut = true;
		HelpFadeTime = HelpFadeDuration;
		HelpFadeTime = HelpFadeDuration - HelpFadeTime;
	}
}

function SetAttractModeUI( bool bIsInBenchmarkMode )
{
	// nothing to do if we don't have these extra controls
	if (MenuObjects.length < 5)
	{
		return;
	}

	MenuObjects[3].bIsHidden = true;
	MenuObjects[3].bIsActive = false;

	if (bIsInBenchmarkMode)
	{
		// Hide settings button if in benchmark mode only
		MenuObjects[4].bIsHidden = true;
		MenuObjects[4].bIsActive = false;
	}

	// Position the buttons
	MenuObjects[1].Left = (Width/4) - (MenuObjects[2].Width/2);
	MenuObjects[2].Left = Width - (Width/4) - (MenuObjects[2].Width/2);
}

function SetDefaultUI()
{
	// nothing to do if we don't have these extra controls
	if (MenuObjects.length < 5)
	{
		return;
	}

	MenuObjects[3].bIsHidden = false;
	MenuObjects[3].bIsActive = true;
	MenuObjects[4].bIsHidden = false;
	MenuObjects[4].bIsActive = true;

	// Position the buttons
	MenuObjects[3].Left = (Width / 2) - (MenuObjects[3].Width/2);	
	MenuObjects[1].Left = (MenuObjects[3].Left/2) - (MenuObjects[1].Width/2);
	MenuObjects[2].Left = (MenuObjects[3].Left/2) + MenuObjects[3].Left + MenuObjects[3].Width - (MenuObjects[2].Width/2);
	
}

defaultproperties
{
	SceneCaptionFont=none	// MultiFont'CastleFonts.Positec'
	Left=0
	Top=0
	Width=1.0
	bRelativeLeft=true
	bRelativeWidth=true
	Height=180;

	Begin Object Class=MobileMenuImage Name=Background
		Tag="Background"
		Left=0
		Top=0
		Width=1.5
		Height=1.0
		bRelativeWidth=true
		bRelativeHeight=true
		Image=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
		ImageDrawStyle=IDS_Stretched
		ImageUVs=(bCustomCoords=true,U=0,V=60,UL=2048,VL=360)
	End Object
	MenuObjects(0)=Background

	Begin Object Class=MobileMenuButton Name=AboutButton
 		Tag="ABOUT"
		Left=0
		Top=-85
		Width=281
		Height=48
		TopLeeway=20
 		Images(0)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
 		Images(1)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
 		ImagesUVs(0)=(bCustomCoords=true,U=708,V=1124,UL=620,VL=96)
 		ImagesUVs(1)=(bCustomCoords=true,U=1352,V=1124,UL=620,VL=96)
	End Object
	MenuObjects(1)=AboutButton

	Begin Object Class=MobileMenuButton Name=AttractButton
		Tag="BIRDSEYE"
		Left=0
		Top=-85
		Width=310
		Height=48
		TopLeeway=20
		Images(0)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
		Images(1)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
		ImagesUVs(0)=(bCustomCoords=true,U=256,V=1230,UL=620,VL=96)
		ImagesUVs(1)=(bCustomCoords=true,U=256,V=1338,UL=620,VL=96)
	End Object
	MenuObjects(2)=AttractButton

	Begin Object Class=MobileMenuButton Name=BenchmarkButton
		Tag="BENCHMARK"
		Left=0
		Top=-85
		Width=310
		Height=48
		TopLeeway=20
		Images(0)=none	// Texture2D'CastleUIExt.T_CastleMenu2Ext'
		Images(1)=none	// Texture2D'CastleUIExt.T_CastleMenu2Ext'
		ImagesUVs(0)=(bCustomCoords=true,U=6,V=0,UL=620,VL=96)
		ImagesUVs(1)=(bCustomCoords=true,U=6,V=118,UL=620,VL=96)
	End Object
	MenuObjects(3)=BenchmarkButton

	Begin Object Class=MobileMenuButton Name=SettingsButton
		Tag="SETTINGS"
		Left=0
		Top=-15
		Width=138
		Height=64
		TopLeeway=20
		Images(0)=none	// Texture2D'CastleUIExt.T_CastleMenu2Ext'
		Images(1)=none	// Texture2D'CastleUIExt.T_CastleMenu2Ext'
		ImagesUVs(0)=(bCustomCoords=true,U=740,V=3 ,UL=284,VL=134)
		ImagesUVs(1)=(bCustomCoords=true,U=740,V=137,UL=284,VL=134)
	End Object
	MenuObjects(4)=SettingsButton

 	UITouchSound=none	// SoundCue'CastleAudio.UI.UI_ChangeSelection_Cue'
 	UIUnTouchSound=none	// SoundCue'CastleAudio.UI.UI_ChangeSelection_Cue'
	HelpFadeDuration=0.3
}

