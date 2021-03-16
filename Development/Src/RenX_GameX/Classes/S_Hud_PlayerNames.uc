class S_Hud_PlayerNames extends Rx_Hud_PlayerNames;

var protected const Color ColorBlue4;

//var float TestNum; 


function DrawNameOnActor(Actor inActor, string inName, optional STANCE inStance = STANCE_NEUTRAL,optional float Opacity = 1.0f, optional int listOffset = 0)
{
	local float XLen, YLen;
	local vector ScreenLoc;
	local FontRenderInfo FontInfo;
	local Rx_Pawn		RxP; 
	local Rx_Vehicle	RxV; 
	local byte			HealNeccesity; //Hold necessity of healing for this pawn

	ScreenLoc = Canvas.Project(inActor.Location);

	if(Pawn(inActor) != None)
	{
		Canvas.StrLen(inName, XLen, YLen);

		Canvas.SetPos(ScreenLoc.X-0.5*XLen,ScreenLoc.Y-1.2*YLen + (YLen * listOffset));
		FontInfo.bEnableShadow=true;

		Canvas.Font = PlayerNameFont;			

		if(Rx_Pawn(inActor) != none) 
			RxP = Rx_Pawn(inActor);
		else if(Rx_Vehicle(inActor) != none) 
			RxV = Rx_Vehicle(inActor);
	
		if (!RenxHud.SystemSettingsHandler.GetNicknamesUseTeamColors() || RenxHud.PlayerOwner.WorldInfo.IsPlayingDemo())
		{
			if (inStance == STANCE_ENEMY)
				Canvas.DrawColor = ColorRed;
			else if (inStance == STANCE_FRIENDLY)
				Canvas.DrawColor = ColorGreen;
			else 
				Canvas.DrawColor = ColorWhite;
		}
		else
		{
			if (RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI && inStance == STANCE_FRIENDLY ||
				RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD && inStance == STANCE_ENEMY)
				Canvas.DrawColor = ColorBlue4;
			else if (RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD && inStance == STANCE_FRIENDLY ||
				RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI && inStance == STANCE_ENEMY)
				Canvas.DrawColor = ColorRed;
			else
				Canvas.DrawColor = ColorWhite;
		}
				
		Canvas.DrawColor.A *= Opacity;
		Canvas.DrawText(inName,,1.0,1.0,FontInfo);
	}
	if(RenxHud.PlayerOwner.GetTeamNum() == inActor.GetTeamNum())
	{
		if(RxP != None)
			{
			
				if(RxP.UISymbol > 0) DrawRadioCommandUsedIcon(inActor, Rx_Pawn(inActor).UISymbol);
				else
				if(Rx_Pawn(RenxHud.PlayerOwner.Pawn) != none && Rx_Pawn(RenxHud.PlayerOwner.Pawn).IsHealer())
				{
					HealNeccesity = RxP.GetHealNecessity();
					if(HealNeccesity != 0) 
					{
						SetIconBlendColor(HealNeccesity);
						DrawRadioCommandUsedIcon(inActor, 1, 0.5);
					}
				}
				
			
			}	
		else
		if(RxV != None)
			{
			
				if(RxV.UISymbol > 0) DrawRadioCommandUsedIcon(inActor, RxV.UISymbol);
				else
				if(Rx_Pawn(RenxHud.PlayerOwner.Pawn) != none && Rx_Pawn(RenxHud.PlayerOwner.Pawn).IsHealer())
				{
					HealNeccesity = RxV.GetHealNecessity();
					if(HealNeccesity != 0) 
					{
						SetIconBlendColor(HealNeccesity);
						DrawRadioCommandUsedIcon(inActor, 1, 0.5);
					}
				}
				
			
			}
			
		
	}
	else
	if(inStance == STANCE_ENEMY)
	{
		if(Rx_Pawn(inActor) != None && (Rx_PRI(Rx_Pawn(inActor).PlayerReplicationInfo) != none && Rx_PRI(Rx_Pawn(inActor).PlayerReplicationInfo).IsFocused()))
		{
			DrawFocusedIcon(inActor);
		}	
		
	}
}


DefaultProperties
{
	ColorBlue4 = (R = 50, G = 96, B = 255, A = 255) //Black Hand.
}
