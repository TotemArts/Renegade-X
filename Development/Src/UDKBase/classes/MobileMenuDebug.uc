/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class MobileMenuDebug extends MobileMenuBase;

/**
 * Handle menu input
 * 
 * @param Sender The object clicked on
 * @param TouchX X location in screen space
 * @param TouchY Y location in screen space
 */
event OnTouch(MobileMenuObject Sender, ETouchType EventType, float TouchX, float TouchY)
{
	if (Sender == none)
	{
		return;
	}

	if (EventType == Touch_Cancelled)
	{
		return;
	}

	if (Sender.Tag ~= "FPS")
	{
		InputOwner.Outer.ConsoleCommand("stat fps");
	}
	else if (Sender.Tag ~= "MSAA")
	{
		InputOwner.Outer.ConsoleCommand("es2 msaa");
	}
	else if (Sender.Tag ~= "UNIT")
	{
		InputOwner.Outer.ConsoleCOmmand("stat unit");
	}
	else if (Sender.Tag ~= "Close")
	{
		InputOwner.CloseMenuScene(self);
	}
}

defaultproperties
{
	Begin Object Class=MobileMenuButton Name=CloseButton
		Tag="Close"
		bRelativeLeft=true
		Left=0.1
		Top=20
		Width=100
		Height=100
		Caption="Close"
		CaptionColor=(R=0.0,G=0.5,B=1.0,A=1.0)
		End Object
		MenuObjects.Add(CloseButton)

	Begin Object Class=MobileMenuButton Name=ShowFPSButton
		Tag="FPS"
		bRelativeLeft=true
		Left=0.1
		Top=120
		Width=100
		Height=100
		Caption="Toggle FPS"
		CaptionColor=(R=0.0,G=0.5,B=1.0,A=1.0)
	End Object
	MenuObjects.Add(ShowFPSButton)

	Begin Object Class=MobileMenuButton Name=StatUnitButton
	Tag="UNIT"
	bRelativeLeft=true
	Left=0.6
	Top=120
	Width=100
	Height=100
	Caption="Toggle StatUnit"
	CaptionColor=(R=0.0,G=0.5,B=1.0,A=1.0)
	End Object
	MenuObjects.Add(StatUnitButton)

	Begin Object Class=MobileMenuButton Name=ShowMSAAButton
		Tag="MSAA"
		bRelativeLeft=true
		Left=0.1
		Top=220
		Width=100
		Height=100
		Caption="Toggle MSAA"
		CaptionColor=(R=0.0,G=0.5,B=1.0,A=1.0)
	End Object
	MenuObjects.Add(ShowMSAAButton)
}