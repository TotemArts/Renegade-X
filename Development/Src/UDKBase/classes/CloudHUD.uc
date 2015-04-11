/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class CloudHUD extends UDKHUD;

function PostRender()
{
	local CloudPC PC;
	local FacebookIntegration Facebook;

	PC = CloudPC(PlayerOwner);

	super.PostRender();
	
	Canvas.DrawColor = class'HUD'.default.WhiteColor;
	Canvas.SetPos(300 / 2, 100 / 2);
	Canvas.DrawText("Exp: " $ PC.SaveData.Exp $ " -- Gold: " $ PC.SaveData.Gold);

	Canvas.SetPos(900 / 2, 300 / 2);
	if (PC.Slot1DocIndex == -1)
	{
		Canvas.DrawText("No Data");
	}
	else
	{
		Canvas.DrawText("Save Game 1");
	}

	Canvas.SetPos(900 / 2, 450 / 2);
	if (PC.Slot2DocIndex == -1)
	{
		Canvas.DrawText("No Data");
	}
	else
	{
		Canvas.DrawText("Save Game 2");
	}


	Facebook = class'PlatformInterfaceBase'.static.GetFacebookIntegration();
	Canvas.SetPos(450 / 2, Canvas.SizeY - 50);

	if (Facebook.IsAuthorized())
	{
		Canvas.DrawText("FB authorized: " $ Facebook.Username);
	}
	else if (PC.bIsFBAuthenticating)
	{
		Canvas.DrawText("FB authenticating...");
	}
	else
	{
		Canvas.DrawText("FB not authorized");
	}
}


defaultproperties
{
	ButtonFont = Font'EngineFonts.SmallFont'
	ButtonCaptionColor=(R=255,G=255,B=255,A=255)
}
