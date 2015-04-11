class Rx_HUD_CaptureProgress extends Rx_Hud_Component;

var Rx_CapturePoint CP;

function Update(float DeltaTime, Rx_HUD HUD)
{
	super.Update(DeltaTime, HUD);

	CP = RenxHud.CurrentCapturePoint;
}

function Draw()
{
	if (CP != None)
		DrawCaptureProgress();
}

function DrawCaptureProgress()
{
	local float ProgBarX, ProgBarY, ProgBarWidth, ProgBarHeight;
	local CanvasIcon FriendlyIcon, EnemyIcon;
	local int FriendlyCount, EnemyCount;

	ProgBarWidth = 400;
	ProgBarHeight = 25;
	ProgBarX = (Canvas.SizeX/2 - ProgBarWidth/2);
	ProgBarY = Canvas.SizeY-200;

	// Progress bar
	Canvas.SetPos(ProgBarX-4, ProgBarY-4);
	if (!CP.bCaptured)
		Canvas.DrawColor = ColorWhite;
	else if (CP.CapturingTeam == RenxHud.PlayerOwner.GetTeamNum())
		Canvas.DrawColor = ColorGreen;
	else
		Canvas.DrawColor = ColorRed;
	Canvas.DrawBox(ProgBarWidth+8,ProgBarHeight+8);

	Canvas.SetPos(ProgBarX, ProgBarY);
	Canvas.DrawColor = ColorGreyedOut;
	Canvas.DrawRect(ProgBarWidth,ProgBarHeight);

	if (CP.ReplicatedProgress > 0)
	{
		Canvas.SetPos(ProgBarX, ProgBarY);
		if (CP.CapturingTeam == RenxHud.PlayerOwner.GetTeamNum())
			Canvas.DrawColor = ColorGreen;
		else
			Canvas.DrawColor = ColorRed;
		Canvas.DrawRect(ProgBarWidth*CP.ReplicatedProgress,ProgBarHeight);
	}

	// Team counts
	if (RenxHud.PlayerOwner.GetTeamNum() == TEAM_GDI)
	{
		FriendlyIcon = class'Rx_HUD_TargetingBox'.default.GDIFriendlyIcon;
		FriendlyCount = CP.GDICount;
		EnemyIcon = class'Rx_HUD_TargetingBox'.default.NodEnemyIcon;
		EnemyCount = CP.NodCount;
	}
	else
	{
		FriendlyIcon = class'Rx_HUD_TargetingBox'.default.NodFriendlyIcon;
		FriendlyCount = CP.NodCount;
		EnemyIcon = class'Rx_HUD_TargetingBox'.default.GDIEnemyIcon;
		EnemyCount = CP.GDICount;
	}

	Canvas.Font = Font'RenXHud.Font.PlayerName';
	Canvas.DrawColor = ColorGreen;
	if (EnemyCount <= 0)
	{
		Canvas.SetPos(ProgBarX + ProgBarWidth/2 + 20,ProgBarY + ProgBarHeight+10);
		Canvas.DrawText(FriendlyCount);
		Canvas.DrawIcon(FriendlyIcon,ProgBarX+ ProgBarWidth/2 - (class'Rx_HUD_TargetingBox'.default.NeutralIcon.UL/2),ProgBarY + ProgBarHeight+10 + 8 - (class'Rx_HUD_TargetingBox'.default.NeutralIcon.VL/2));
	}
	else
	{
		Canvas.SetPos(ProgBarX + ProgBarWidth/3 + 20,ProgBarY + ProgBarHeight+10);
		Canvas.DrawText(FriendlyCount);
		Canvas.DrawIcon(FriendlyIcon,ProgBarX+ ProgBarWidth/3 - (class'Rx_HUD_TargetingBox'.default.NeutralIcon.UL/2),ProgBarY + ProgBarHeight+10 + 8 - (class'Rx_HUD_TargetingBox'.default.NeutralIcon.VL/2));

		Canvas.Font = Font'RenXHud.Font.PlayerName';
		Canvas.DrawColor = ColorRed;
		Canvas.SetPos(ProgBarX + (ProgBarWidth - ProgBarWidth/3) + 20,ProgBarY + ProgBarHeight+10);
		Canvas.DrawText(EnemyCount);
		Canvas.DrawIcon(EnemyIcon,ProgBarX+ (ProgBarWidth - ProgBarWidth/3) - (class'Rx_HUD_TargetingBox'.default.NeutralIcon.UL/2),ProgBarY + ProgBarHeight+10 + 8 - (class'Rx_HUD_TargetingBox'.default.NeutralIcon.VL/2));
	}

	// Debug text
	/*Canvas.Font = Font'RenXHud.Font.PlayerName';
	Canvas.SetPos(ProgBarX, ProgBarY+ProgBarHeight+5);
	Canvas.DrawColor = ColorWhite;
	Canvas.DrawText(DebugCapPointString());*/
}

function string DebugCapPointString()
{
	return "bCap:"$CP.bCaptured$" CappinTeam:"$CP.CapturingTeam$" Prog:"$int(CP.ReplicatedProgress*100)$"% GDI:"$CP.GDICount $" Nod:"$CP.NodCount;
}

DefaultProperties
{
	
}