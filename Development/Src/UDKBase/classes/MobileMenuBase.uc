/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class MobileMenuBase extends MobileMenuScene;

var Texture2D iPadBackgroundTexture;
var MobileMenuObject.UVCoords iPadBackgroundCoords;

/** Controls the scene fade */
var float FadeTime, FadeDuration;
var bool bFadeOut;
var bool bCloseOnFadeOut;

function Fade(bool bIsFadeOut, float FadeDur)
{
	local int i;
	FadeTime = 0;
	FadeDuration = FadeDur;
	bFadeOut = bIsFadeOut;

	if (bIsFadeOut)
	{
		for (i=0;i<MenuObjects.Length;i++)
		{
			MenuObjects[i].bIsActive = false;
		}
		
	}

}

function RenderScene(Canvas Canvas,float RenderDelta)
{
	if (FadeDuration > 0)
	{
		Opacity = bFadeOut ? FInterpEaseOut(1,0,FadeTime/FadeDuration,2.0) : FInterpEaseOut(0,1,FadeTime/FadeDuration,2.0);
		FadeTime += RenderDelta;
		if (FadeTime > FadeDuration)
		{
			FadeDuration = 0;
			if (bFadeOut && bCloseOnFadeOut)
			{
				InputOwner.CloseMenuScene(self);
			}
		}
	}

	Super.RenderScene(Canvas,RenderDelta);
}

defaultproperties
{
	Left=0
	Top=0
	Width=1.0
	Height=1.0
	bRelativeWidth=true
	bRelativeHeight=true

	UITouchSound=none	// SoundCue'CastleAudio.UI.UI_OK_Cue'
	UIUnTouchSound=none	// SoundCue'CastleAudio.UI.UI_OK_Cue'
}