/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class MobileHUDExt extends MobileHUD native;

/** Texture to use for 'tap-to-move' screen space effect */
var Texture2D TapToMoveTexture;

/** Last time that we were asked to draw the tap to move effect */
var float LastTapToMoveEffectTime;
var Vector2D TapToMoveEffectPos;

var bool bFlashJoysticks;
var float FlashTime;

/** The font to use for displaying benchmark results */
var font BenchmarkFont;

/** Background texture for displaying the benchmark results */
var Texture2D BenchmarkBackground;
var TextureUVs BenchmarkBackgroundUVs;

var float BenchmarkResolutionScale;
var int BenchmarkFeatureLevel;

var string DeviceModel;
var string DeviceGPU;
var String DeviceGPUVendor;

var bool bHasSentBenchmarkAnalytics;

native function UpdateBenchmarkInformation();
native function UpdateBenchmarkAnalyticsInformation();
native function SetEngineBenchmarkingMode(bool bIsBenchmarking);

native function NotifyEngineOfBackButtonHandling();
native function bool HandleBackButtonPressed();
native function RequestExitDialog();

/** Starts drawing a transparent circle at the specified location for a brief moment (with animation) */
function StartTapToMoveEffect( float X, float Y )
{
	// Store time that we were asked to draw the effect.  This effectively "turns on" the effect.
	LastTapToMoveEffectTime = WorldInfo.RealTimeSeconds;
	TapToMoveEffectPos.X = X;
	TapToMoveEffectPos.Y = Y;
}


/** Draws the tap to move effect if we need to */
function ConditionallyDrawTapToMoveEffect()
{
	local float EffectDuration;
	local float EffectSize;
	local float EffectOpacity;
	local float FadeInPercent;
	local float FadeOutPercent;

	local float EffectProgress;
	local float AnimatedSize;
	local float AnimatedOpacity;

	// How long the effect should last
	EffectDuration = 0.25;
	FadeInPercent = 0.1;
	FadeOutPercent = 0.6;

	// How big the effect should be
	EffectSize = 64.0;

	// Maximum opacity of the effect
	EffectOpacity = 0.3;

	// Is it time to draw the effect?
	if( WorldInfo.RealTimeSeconds - LastTapToMoveEffectTime < EffectDuration )
	{
		EffectProgress = FClamp( ( WorldInfo.RealTimeSeconds - LastTapToMoveEffectTime ) / EffectDuration, 0.0, 1.0 );
		EffectProgress = FInterpEaseIn( 0.0, 1.0, EffectProgress, 1.5 );

		AnimatedSize = EffectSize * 0.15 + EffectSize * EffectProgress * 0.85;
		
		AnimatedOpacity = EffectOpacity;

		// Fade in over the first bit of the effect
		if( EffectProgress < FadeInPercent )
		{
			AnimatedOpacity *= ( EffectProgress / FadeInPercent );
		}

		// Fade out over the tail end of the effect
		if( EffectProgress > ( 1.0 - FadeOutPercent ) )
		{
			AnimatedOpacity *= 1.0 - ( EffectProgress - ( 1.0 - FadeOutPercent ) ) / FadeOutPercent;
		}


		Canvas.SetPos( TapToMoveEffectPos.X - AnimatedSize * 0.5, TapToMoveEffectPos.Y - AnimatedSize * 0.5 );
 		Canvas.SetDrawColor( 255, 255, 255, AnimatedOpacity * 255.0 );
		Canvas.DrawTile( TapToMoveTexture, AnimatedSize, AnimatedSize, 0.0, 0.0, TapToMoveTexture.GetSurfaceWidth(), TapToMoveTexture.GetSurfaceHeight() );
	}
}

function bool ShowMobileHud()
{
	// Show the mobile HUD if we are allowed to and if we don't have the HUD disabled via cinematic mode.
	return bShowMobileHud && bShowHud;
}

function PostRender()
{
	local CastlePC PC;

	Instigator = PlayerOwner.Pawn;

	super.PostRender();	

	PC = CastlePC(PlayerOwner);

	if (PC.bIsInAttractMode)
	{
		PostRenderAttractMode();
	}

	// Notify engine if benchmarking to prevent framerate smoothing
	SetEngineBenchmarkingMode(PC.bIsInBenchmarkMode && !PC.bBenchmarkLoopCompleted);

	// Display benchmark information
	if (PC.bIsInBenchmarkMode)
	{
		// If the benchmark loop has completed, then display the results of the benchmark loop
		if( PC.bBenchmarkLoopCompleted )
		{
			PostRenderBenchmarkModeCompleted();
		}
		else
		{	
			bHasSentBenchmarkAnalytics = false; // set flag so completion knows to send analytics
			PostRenderBenchmarkModeRunning();
		}
	}

	if ( bShowHud && !PC.bIsInAttractMode)
		return;
	
	// Draw the tap to move HUD animation, if we need to
	ConditionallyDrawTapToMoveEffect();

}

function PostRenderAttractMode()
{
	local float Scale,w,h;

	Scale = Canvas.ClipX / 960;
	w = 124 * Scale;
	h = w * 1.193548387096774;
	Canvas.SetPos(Canvas.ClipX - 192*Scale, Canvas.ClipY - 171*Scale);
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawTile(Texture2D'MobileResources.T_MobileControls_texture',w,h,5,230,246,278);
	
}

function PostRenderBenchmarkModeCompleted()
{
	local CastlePC PC;
	local int fps, ScreenCenterX, BGTop, BGWidth, BGHeight, ScaledWindowWidth, ScaledWindowHeight;
	local float StringWidth, StringHeight, TextScale;
	local string PerformanceString;
	local array<EventStringParam> AnalyticsParams;

	UpdateBenchmarkInformation();

	Canvas.Font = BenchmarkFont;

	PC = CastlePC(PlayerOwner);
	TextScale = 1.5f;

	ScreenCenterX = PC.ViewportSize.X / 2;
	BGTop = PC.ViewportSize.Y * 0.28;
	BGWidth = PC.ViewportSize.Y * 1.0;
	BGHeight = PC.ViewportSize.Y * 0.55;

	// Draw background
	Canvas.SetPos(ScreenCenterX - BGWidth/2, BGTop);
	Canvas.DrawTile(BenchmarkBackground, BGWidth, BGHeight, BenchmarkBackgroundUVs.U, BenchmarkBackgroundUVs.V, BenchmarkBackgroundUVs.UL, BenchmarkBackgroundUVs.VL);

	// Draw benchmark results header
	Canvas.DrawColor = WhiteColor;
	Canvas.StrLen( "Benchmark Results", StringWidth, StringHeight );
	Canvas.SetPos( ScreenCenterX - StringWidth/2 * TextScale, BGTop + BGHeight * 0.1 );
	Canvas.DrawText( "Benchmark Results", true, TextScale, TextScale );

	// Draw result fields here
	fps = 10 * PC.BenchmarkNumFrames / PC.BenchmarkElapsedTime;
	Canvas.StrLen(  "Average FPS: " $ (fps/10) $ "." $ (fps%10), StringWidth, StringHeight );
	Canvas.SetPos( ScreenCenterX - StringWidth/2 * TextScale, BGTop + (BGHeight * 0.25) );
	Canvas.DrawText( "Average FPS: " $ (fps/10) $ "." $ (fps%10), false, TextScale, TextScale );

	// Draw benchmark information
	ScaledWindowWidth = SizeX * BenchmarkResolutionScale;
	ScaledWindowHeight = SizeY * BenchmarkResolutionScale;
	Canvas.StrLen(  "Resolution: " $ ScaledWindowWidth $ "x" $ ScaledWindowHeight, StringWidth, StringHeight );
	Canvas.SetPos( ScreenCenterX - StringWidth/2 * TextScale, BGTop + (BGHeight * 0.4) );
	Canvas.DrawText( "Resolution: " $ ScaledWindowWidth $ "x" $ ScaledWindowHeight, false, TextScale, TextScale );

	Canvas.StrLen(  "Performance Level: ", StringWidth, StringHeight );
	Canvas.SetPos( ScreenCenterX - StringWidth/2 * TextScale, BGTop + (BGHeight * 0.55) );
	Canvas.DrawText( "Performance Level: ", false, TextScale, TextScale );

	switch (BenchmarkFeatureLevel)
	{
		case 2:
			PerformanceString = "Ultra High Quality";
			break;
		case 1:
			PerformanceString = "High Quality";
			break;
		case 0:
		default:
			PerformanceString = "High Performance";
			break;
	}

	Canvas.StrLen( PerformanceString, StringWidth, StringHeight );
	Canvas.SetPos( ScreenCenterX - StringWidth/2 * TextScale, BGTop + (BGHeight * 0.7) );
	Canvas.DrawText( PerformanceString, false, TextScale, TextScale );

	// Send results to analytics if not already done so for this run
	if (!bHasSentBenchmarkAnalytics)
	{
		AnalyticsParams.Add(1);
		UpdateBenchmarkAnalyticsInformation();
		
		// don't allow negative FPS logging
		if (fps < 0)
		{
			fps = 0;
		}

		`log("Benchmark data for BR " $ (BenchmarkFeatureLevel + 1));
		`log("Device Model: " $ DeviceModel $ " (" $ DeviceGPU $ ")");
		`log("Device GPU: " $ DeviceGPU);
		`log("Device Vendor: " $ DeviceGPUVendor);

		// Device Model by FPS
		if ((fps/10) >= 120)
		{
			// clamp extremely large values
			AnalyticsParams[0].ParamName = ">= 120 FPS";
		}
		else
		{
			AnalyticsParams[0].ParamName = "" $ (((fps/10) / 10) * 10) $ " - " $ (((fps/10) / 10) * 10 + 10) $ " FPS";
		}
		AnalyticsParams[0].ParamValue = DeviceModel $ " (" $ DeviceGPU $ ")";
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": Model by FPS", AnalyticsParams, false);

		`log("FPS Bucket: " $ AnalyticsParams[0].ParamName);

		// Device GPU by FPS
		AnalyticsParams[0].ParamValue = DeviceGPU;
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": GPU by FPS", AnalyticsParams, false);

		// Device GPU Vendor by FPS
		AnalyticsParams[0].ParamValue = DeviceGPUVendor;
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": GPU Vendor by FPS", AnalyticsParams, false);

		// resend with just < or > 30 FPS buckets
		// Device Model by FPS
		if ((fps/10) >= 30)
		{
			AnalyticsParams[0].ParamName = "All 30+ FPS";
		}
		else
		{
			AnalyticsParams[0].ParamName = "All < 30 FPS";
		}
		AnalyticsParams[0].ParamValue = DeviceModel $ " (" $ DeviceGPU $ ")";
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": Model by FPS", AnalyticsParams, false);

		`log("FPS Bucket: " $ AnalyticsParams[0].ParamName);

		// Device GPU by FPS
		AnalyticsParams[0].ParamValue = DeviceGPU;
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": GPU by FPS", AnalyticsParams, false);

		// Device GPU Vendor by FPS
		AnalyticsParams[0].ParamValue = DeviceGPUVendor;
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": GPU Vendor by FPS", AnalyticsParams, false);


		if ((fps/10) >= 120)
		{
			// clamp extremely large values
			AnalyticsParams[0].ParamValue = ">= 120 FPS";
		}
		else
		{
			AnalyticsParams[0].ParamValue = "" $ (fps/10);
		}
		`log("FPS: " $ AnalyticsParams[0].ParamValue);

		// FPS by Device GPU
		AnalyticsParams[0].ParamName = DeviceGPU;
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": FPS by GPU", AnalyticsParams, false);

		// FPS by GPU Vendor
		AnalyticsParams[0].ParamName = DeviceGPUVendor;
		class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface().LogStringEventParamArray("BR " $ (BenchmarkFeatureLevel + 1) $ ": FPS by GPU Vendor", AnalyticsParams, false);

		bHasSentBenchmarkAnalytics = true;
	}
}

function PostRenderBenchmarkModeRunning()
{
	local CastlePC PC;
	local float Scale;
	local int fps, ScreenCenterX;
	local float StringWidth, StringHeight, MaxFPSWidth, FpsY;

	Canvas.Font = BenchmarkFont;

	PC = CastlePC(PlayerOwner);
	Scale = PC.PauseMenu.Scale;

	ScreenCenterX = PC.ViewportSize.X / 2;

	// Draw the frame rate of the current frame
	fps = 1 / WorldInfo.DeltaSeconds;


	Canvas.StrLen( "Benchmarking...", StringWidth, StringHeight );

	Canvas.SetPos( ScreenCenterX - (StringWidth / 2), PC.PauseMenu.Height );
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawText( "Benchmarking...", false );
			
	// Draw fps information
	Canvas.StrLen( "100", MaxFPSWidth, StringHeight );
	Canvas.StrLen( fps, StringWidth, StringHeight );

	FpsY = PC.ViewportSize.Y - StringHeight * Scale - 20 * Scale;
	Canvas.SetPos( 30 * Scale - StringWidth + MaxFPSWidth, FpsY ); 
	Canvas.DrawText( fps, false );

	Canvas.SetPos( 45 * Scale + MaxFPSWidth, FpsY );
	Canvas.DrawText( "FPS", false );	
}

function DrawMobileZone_Slider(MobileInputZone Zone)
{
	local TextureUVs UVs;
	local Texture2D Tex;
	local float Ofs,Scale;

	// First, look up the Texture

	Tex = SliderImages[int(Zone.SlideType)];
	UVs = SliderUVs[int(Zone.SlideType)];

	// Now, figure out where we have to draw.


	Scale = CastlePC(PlayerOwner).PauseMenu.Scale;
	Ofs = 16 *Scale;

	Canvas.SetPos(Zone.CurrentLocation.X, Zone.CurrentLocation.Y-Ofs);
	Canvas.DrawTile(Tex,Zone.ActiveSizeX, Zone.ActiveSizeY, UVs.U, UVs.V, UVs.UL, UVs.VL);
}

function DrawMobileZone_Joystick(MobileInputZone Zone)
{
	local int X, Y, Width, Height;
	local Color LineColor;
	local float ClampedX, ClampedY, Scale;
	local Color TempColor;
	local float FlashScale;


	if (bFlashJoysticks)
	{
		FlashScale = FInterpEaseOut(3.0,1.0,FlashTime/0.75,2);
		FlashTime += RenderDelta;
		if (FlashTime > 0.75)
		{
			bFlashJoysticks = false;
		}
	}
	else
	{
		FlashScale = 1.0;
	}

	if (JoystickBackground != none)
	{
		Width = Zone.ActiveSizeX * FlashScale;
		Height = Zone.ActiveSizeY * FlashScale;

		X = Zone.CurrentCenter.X - (Width /2);
		Y = Zone.CurrentCenter.Y - (Height /2);

		Canvas.SetPos(X,Y);
		Canvas.DrawTile(JoystickBackground, Width, Height, JoystickBackgroundUVs.U, JoystickBackgroundUVs.V, JoystickBackgroundUVs.UL, JoystickBackgroundUVs.VL);
	}

	// Draw the Hat

	if (JoystickHat != none)
	{
		// Compute X and Y clamped to the size of the zone for the joystick
		ClampedX = Zone.CurrentLocation.X - Zone.CurrentCenter.X;
		ClampedY = Zone.CurrentLocation.Y - Zone.CurrentCenter.Y;
		Scale = 1.0f;
		if ( ClampedX != 0 || ClampedY != 0 )
		{
			Scale = Min( Zone.ActiveSizeX, Zone.ActiveSizeY ) / ( 2.0 * Sqrt(ClampedX * ClampedX + ClampedY * ClampedY) );
			Scale = FMin( 1.0, Scale );
		}
		ClampedX = ClampedX * Scale + Zone.CurrentCenter.X;
		ClampedY = ClampedY * Scale + Zone.CurrentCenter.Y;

		if (Zone.bRenderGuides)
		{
			TempColor = Canvas.DrawColor;
			LineColor.R = 128;
			LineColor.G = 128;
			LineColor.B = 128;
			LineColor.A = 255;
			Canvas.Draw2DLine(Zone.CurrentCenter.X, Zone.CurrentCenter.Y, ClampedX, ClampedY, LineColor);
			Canvas.DrawColor = TempColor;

		}

		// The size of the indicator will be a fraction of the background's total size
		Width = Zone.ActiveSizeX * 0.65 * FlashScale;
		Height = Zone.ActiveSizeY * 0.65 * FlashScale;

		Canvas.SetPos( ClampedX - Width / 2, ClampedY - Height / 2);
		Canvas.DrawTile(JoystickHat, Width, Height, JoystickHatUVs.U, JoystickHatUVs.V, JoystickHatUVs.UL, JoystickHatUVs.VL);
	}
}

function FlashSticks()
{
	bFlashJoysticks = true;
	FlashTime = 0;
}

defaultproperties
{
	JoystickBackground=none	// Texture2D'MobileResources.T_MobileControls_texture'
	JoystickBackgroundUVs=(U=0,V=0,UL=126,VL=126)
	JoystickHat=none	// Texture2D'MobileResources.T_MobileControls_texture'
	JoystickHatUVs=(U=128,V=0,UL=78,VL=78)

	ButtonImages(0)=none	// Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonImages(1)=none	// Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonUVs(0)=(U=0,V=0,UL=32,VL=32)
	ButtonUVs(1)=(U=0,V=0,UL=32,VL=32)

	TrackballBackground=none
	TrackballTouchIndicator=none	// Texture2D'MobileResources.T_MobileControls_texture'
	TrackballTouchIndicatorUVs=(U=160,V=0,UL=92,VL=92)

	ButtonFont = Font'EngineFonts.SmallFont'
	ButtonCaptionColor=(R=0,G=0,B=0,A=255);

	SliderImages(0)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
	SliderImages(1)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
	SliderImages(2)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
	SliderImages(3)=none	// Texture2D'CastleUI.menus.T_CastleMenu2'
	SliderUVs(0)=(U=1282,V=440,UL=322,VL=150)
	SliderUVs(1)=(U=1282,V=440,UL=322,VL=150)
	SliderUVs(2)=(U=1282,V=440,UL=322,VL=150)
	SliderUVs(3)=(U=1282,V=440,UL=322,VL=150)

	LastTapToMoveEffectTime=-99999.0

	TapToMoveTexture=none	// Texture2D'CastleHUD.HUD_TouchToMove'

	BenchmarkFont=Font'UI_Fonts.MultiFonts.MF_LargeFont'

	BenchmarkBackground=none	// Texture2D'CastleUIExt.T_CastleMenu2Ext'
	BenchmarkBackgroundUVs=(U=19,V=335,UL=996,VL=322)
 }
