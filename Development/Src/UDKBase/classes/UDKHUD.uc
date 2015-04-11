/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKHUD extends MobileHUD
	native;

var font GlowFonts[2];	// 0 = the Glow, 1 = Text

/** How long should the pulse take total */
var float PulseDuration;

/** When should the pulse switch from Out to in */
var float PulseSplit;

/** How much should the text pulse - NOTE this will be added to 1.0 (so PulseMultipler 0.5 = 1.5) */
var float PulseMultiplier;

var FontRenderInfo TextRenderInfo;

/** Holds a reference to the font to use for a given console */
var font ConsoleIconFont;

/** Font used to display input binds when they aren't represented by an icon in ConsoleIconFont. */
var font BindTextFont;

/**
 * Draw a glowing string
 */
native function DrawGlowText(string Text, float X, float Y, optional float MaxHeightInPixels=0.0, optional float PulseTime=-100.0, optional bool bRightJustified);

/** Convert a string with potential escape sequenced data in it to a font and the string that should be displayed */
native static function TranslateBindToFont(string InBindStr, out Font DrawFont, out string OutBindStr);

defaultproperties
{
	JoystickBackground=Texture2D'MobileResources.T_MobileControls_texture'
	JoystickBackgroundUVs=(U=0,V=0,UL=126,VL=126)
	JoystickHat=Texture2D'MobileResources.T_MobileControls_texture'
	JoystickHatUVs=(U=128,V=0,UL=78,VL=78)

	ButtonImages(0)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonImages(1)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonUVs(0)=(U=0,V=0,UL=32,VL=32)
	ButtonUVs(1)=(U=0,V=0,UL=32,VL=32)

	TrackballBackground=none
	TrackballTouchIndicator=Texture2D'MobileResources.T_MobileControls_texture'
	TrackballTouchIndicatorUVs=(U=160,V=0,UL=92,VL=92)

	SliderImages(0)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderImages(1)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderImages(2)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderImages(3)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	SliderUVs(0)=(U=0,V=0,UL=32,VL=32)
	SliderUVs(1)=(U=0,V=0,UL=32,VL=32)
	SliderUVs(2)=(U=0,V=0,UL=32,VL=32)
	SliderUVs(3)=(U=0,V=0,UL=32,VL=32)

	ButtonFont = Font'EngineFonts.SmallFont'
	ButtonCaptionColor=(R=0,G=0,B=0,A=255);

	PulseDuration=0.33
	PulseSplit=0.25
	PulseMultiplier=0.5
}