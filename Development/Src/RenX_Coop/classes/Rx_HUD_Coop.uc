class Rx_HUD_Coop extends Rx_HUD;

/*
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
	local float ResScaleY; 
	local CanvasIcon Temp_Icon;
	
	// If we have no GRI, no point in drawing the score panel.
	if(WorldInfo.GRI == none)
		return;
	
	//Honestly looks better without scaling. Just wait for Flash on this one I 
	ResScaleY = 1.0 ; //Canvas.SizeY/1080.0;
	
	
	//Canvas.Font = Font'RenXFonts.Agency12';
	//Canvas.Font = GetFontSizeIndex(1);
	Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small'; //Font'RenXHud.Font.AS_small';
	Canvas.TextSize("ABCDEFGHIJKLMNOPQRSTUVWXYZ", SizeSX, SizeSY, 0.6f*ResScaleY, 0.6f*ResScaleY);
	
    FontInfo = Canvas.CreateFontRenderInfo(true);
    FontInfo.bClipText = true;
    FontInfo.bEnableShadow = true;
    FontInfo.GlowInfo.GlowColor = MakeLinearColor(1.0, 0.0, 0.0, 1.0);
    GlowRadius.X=2.0;
    GlowRadius.Y=1.0;
    FontInfo.GlowInfo.bEnableGlow = true;
    FontInfo.GlowInfo.GlowOuterRadius = GlowRadius;	

	DrawScorePanelTitle(true);
	YL = ScorePanelY + SizeSY + 10.0f*ResScaleY;
	FirstTeamID = PlayerOwner.GetTeamNum();

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
				Canvas.SetPos(DrawStartX[0] - 37.0*ResScaleY, YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).ReplicatedSize, false,,,FontInfo);
				Canvas.SetPos(DrawStartX[0], YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetTeamName(), false,,,FontInfo);
				
				
				Canvas.DrawColor = Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetTeamColor();
				Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetRenScore()), YL);
				Canvas.DrawText(Rx_TeamInfo(WorldInfo.GRI.Teams[FirstTeamID]).GetRenScore(), false,,,FontInfo);

				YL += SizeSY + 10.0f*ResScaleY;
			}
			break;
		default:
			break;
	}

	YL += SizeSY + 10.0f*ResScaleY;
	//YL += SizeSY + 4.0f*ResScaleY;
	DrawScorePanelTitle(,YL - ScorePanelY*ResScaleY);
	YL += SizeSY + 10.0f*ResScaleY;

	if(WorldInfo.TimeSeconds - LastScoreboardRenderTime > 1.0)
	{ 
		PRIArray = WorldInfo.GRI.PRIArray;
		
		foreach WorldInfo.GRI.PRIArray(pri)
		{
			if(Rx_Pri(pri) == None || Rx_PRI(PRI).bIsScripted)
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
							DistToSpot = VSizeSq(TempActor.location - P.location);
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
				Temp_Icon = Neutral_Recruit; // Always show recruit icon if all else fails.
				
				if (!PRIArray[I].bIsSpectator)
				{
					if(Rx_PRI(PRIArray[I]).Team == None)
						continue;
					if (PRIArray[I].Owner == self.Owner)
						Canvas.SetDrawColor(0,255,0,255);
					else
						Canvas.DrawColor = UTTeamInfo(Rx_PRI(PRIArray[I]).Team).GetHUDColor();
					Canvas.SetPos(DrawStartX[0] - 40.0*ResScaleY, YL);
					Canvas.DrawText(I+1, false,,,FontInfo);
					if(Rx_Pri(PRIArray[I]).VRank == 0)
						Temp_Icon = Neutral_Recruit;
					if(Rx_Pri(PRIArray[I]).VRank == 1)
						Temp_Icon = Neutral_Veteran;
					if(Rx_Pri(PRIArray[I]).VRank == 2)
						Temp_Icon = Neutral_Elite;
					if(Rx_Pri(PRIArray[I]).VRank == 3)
						Temp_Icon = Neutral_Heroic;
					Canvas.DrawIcon(Temp_Icon,DrawStartX[0] - 5.0*ResScaleY-40, YL-18.0, 0.75);		
				      
					Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);					
					
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
						Canvas.SetPos(DrawStartX[0] - 10.0*ResScaleY, YL);
						if(PlayerOwner.GetTeamNum() == PRIArray[I].GetTeamNum())
						{
							Canvas.DrawRect(StrLeng(PRIArray[I].GetHumanReadableName()$" | "$TempCredits$" | "
									$Rx_PRI(PRIArray[I]).GetPawnArea()
									$TempStr)+10.0*ResScaleY,15.0*ResScaleY);
						} else
						{
							Canvas.DrawRect(StrLeng(PRIArray[I].GetHumanReadableName())+10.0*ResScaleY,15.0*ResScaleY);
						}
						
						if (PRIArray[I].Owner == self.Owner)
							Canvas.SetDrawColor(0,255,0,255);
						else
							Canvas.DrawColor = UTTeamInfo(Rx_PRI(PRIArray[I]).Team).GetHUDColor();									
						
						Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);
						
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
					{
						Canvas.DrawText(PRIArray[I].GetHumanReadableName(), false,,,FontInfo);	
					}
						
					Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_Pri(PRIArray[I]).GetRenScore()), YL);			
			
					Canvas.DrawText(Rx_Pri(PRIArray[I]).GetRenScore(), false,,,FontInfo);
					YL += SizeSY + 5.0f*ResScaleY; //5.0f*ResScaleY;
				}
			}
			break;
		case 2: // show only players score and position
			TempStr = "";

			Canvas.SetDrawColor(0,255,0,255);
			Canvas.SetPos(DrawStartX[0] - 40.0*ResScaleY, YL);
			Canvas.DrawText(I+1, false,,,FontInfo);
		      
			Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);						
			Canvas.DrawText(PlayerOwner.PlayerReplicationInfo.GetHumanReadableName(), false,,,FontInfo);	
			Canvas.SetPos(DrawStartX[1] + StrLeng("Score") - StrLeng(Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore()), YL);
			Canvas.DrawText(Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore(), false,,,FontInfo);
			YL += SizeSY + 5.0f*ResScaleY;
		
	   default:
			break;					
	}
	
	if(ScorePanelMode != 2)
		for (I = 0; I < PRIArray.Length ; I++)
		{
			if(PRIArray[I] == None || !PRIArray[I].bIsSpectator)
				continue;
			
			Canvas.SetPos(DrawStartX[0] - 5.0*ResScaleY, YL);
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.DrawText(PRIArray[I].GetHumanReadableName());	
			YL += SizeSY + 10.0f*ResScaleY;		
		}
	
	if(bDrawAdditionalPlayerInfo)
	{
		YL += SizeSY + 10.0f*ResScaleY;
		Canvas.SetPos(DrawStartX[0]-40*ResScaleY, YL);
		Canvas.SetDrawColor(0, 255, 0, 255);
		Canvas.DrawText("Your score this minute: " $ Rx_Pri(PlayerOwner.PlayerReplicationInfo).GetRenScore()-Rx_Pri(PlayerOwner.PlayerReplicationInfo).ScoreLastMinutes, false,,,FontInfo);
	} 
	
}
*/

DefaultProperties
{
	PlayerNamesClass = class 'Rx_Hud_PlayerNames_Coop';
	ScoreboardClass = class'Rx_GFxUIScoreboard_Coop'
}