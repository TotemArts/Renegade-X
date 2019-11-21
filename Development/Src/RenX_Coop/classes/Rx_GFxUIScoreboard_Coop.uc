class Rx_GFxUIScoreboard_Coop extends Rx_GFxUIScoreboard;

var GFxObject Score;
var GFxObject BuildingStats;
var GFxObject VictoryText;

function bool Start(optional bool StartPaused = false)
{
	//cache variables we use alot
	PC = GetPC();
	RxGRI = Rx_GRI(PC.WorldInfo.GRI);

    super(GFxMoviePlayer).Start();
    Advance(0.f);
	
	LoadGfxObjects();

	if(RxGRI.bMatchIsOver)
		EndGameMode();
	else
		InitScoreboard();


	AddFocusIgnoreKey('Escape');

    return true;
}

function EndGameMode() 
{
	EndGameTime = RxGRI.RenEndTime;
	InitEndGameScoreboard();
}

function InitScoreboard()
{
	if(Scoreboard != None)
	{
		Scoreboard.GotoAndStopI(PC.GetTeamNum() + 1);
		ServerName = Scoreboard.GetObject("ServerName");
	}

	if(ServerName == None)
		return;

	if(PC.WorldInfo.NetMode == NM_Standalone)
		ServerName.SetText("Skirmish Session");
	else
		ServerName.SetText(RxGRI.ServerName);

}

/**
 * Finds objects inside loaded flash file and stores a reference.
 * The more we can move out of this and into WidgetInitialized() the better
 */
function LoadGfxObjects()
{
	`logd(">> Rx_GFxUIScoreBoard::UpdateGfxObjects",true,'DevGFxUI');

	//Root
	RootMC = GetVariableObject("root1.rootMC");
	Scoreboard = RootMC.GetObject("sb");
	if(Scoreboard != None)
		Scoreboard.GotoAndStopI(PC.GetTeamNum() + 1);

	
	//Root objects	
	rootdebugtimertext = RootMC.GetObject("namedtest");
	FadeMC = RootMC.GetObject("fadeMC");
	CursorMC = RootMC.GetObject("CursorMC");

	//Result objects
	ResultMC = RootMC.GetObject("ResultMC");
	ResultTextMC = ResultMC.GetObject("MC_ResultText");
	LogoMC = ResultMC.GetObject("ResultLogoMC");

	ResultMC.SetVisible(false);

	if(RxGRI.bMatchIsOver)
		RootMC.GotoAndStopI(10);

	if(debugScoreboardUI)
		rootdebugtimertext.SetVisible(true);
}

/** Are we in a state where we should be updating the scoreboard, or has enough time passed since last update. */
function bool ShouldUpdate() 
{
	local float UpdateInterval;
	local float timeSec;

	timeSec = PC.Worldinfo.Timeseconds;	

	UpdateInterval = 0.25;

	if(PC.WorldInfo.GRI.bMatchIsOver != true) {
		if((timeSec - LastUpdateTime) < UpdateInterval)
			return false;
	}

	LastUpdateTime = timeSec;

	return true;
}

function validateNow(GFxObject event=none)
{
	ActionScriptVoid("validateNow");
}

function invalidate()
{
	ActionScriptVoid("invalidate");
}

function Draw()
{
	if (!bMovieIsOpen) {
		return;
	}

	if(PC == None || RxGRI == None)
		return; 
	
	if(!ShouldUpdate())
		return;
	
	if(RxGRI.bMatchIsOver)
	{
		TickEndGameScoreboard();	
		UpdateBuildings(true);
	} 
	else if(bHasInitialized)
	{
		UpdateBuildings(false);
	}
	else
	{
		UpdateBuildings(true);
		bHasInitialized = true;
	}

	UpdatePlayers();
	UpdateScoreTotals();
}

function PlayTickSound()
{
	PlaySoundFromTheme('press', 'default'); 
}

function SetEndGameResult(bool bWin)
{
	if(PC.GetTeamNum() == TEAM_GDI)
		LogoMC.GotoAndStop("GDI");

	else if(PC.GetTeamNum() == TEAM_NOD)
		LogoMC.GotoAndStop("Nod");

	if(bWin)
		ResultTextMC.GotoAndStopI(1);
	else
		ResultTextMC.GotoAndStopI(3);

	ResultMC.GotoAndPlayI(2);
	ResultMC.SetVisible(true);
}

function TickEndGameScoreboard()
{
	local float TimeLeft;
	local int i;
	local bool bVoteNeedUpdate;
//	local GFxObject TempObj, DataProvider;

//	DataProvider = CreateObject("scaleform.clik.data.DataProvider");

	`logd(">> Rx_GFxUIScoreboard::TickEndGameScoreboard",true,'DevGFxUI');

	if(NextRound != None)
	{
		TimeLeft = RxGRI.RenEndTime - PC.WorldInfo.RealTimeSeconds; //work out countdown for map voting/till next map load
		if (int(TimeLeft) < 10) 
		{
			if(TimeLeft > 0)
			{
				if(!PC.IsTimerActive('PlayTickSound',self))
				{
					PlayTickSound();
					PC.SetTimer(1, true, 'PlayTickSound',self);
				}

				NextRound.GotoAndStopI(10); // swap nextround countdown to red.		
				NextRound.SetText(Left(string(TimeLeft), InStr(string(TimeLeft), ".") + 2));
			}
			else
			{
				NextRound.SetVisible(false);
				NextLoadingMap.GotoAndStopI(10); // swap NextLoadingMap to red.
				NextLoadingMap.SetText("Loading Map...");
				`GameObject.ClearTimer('PlayTickSound', self);
			}		
		} 
		else
			NextRound.SetText(int(TimeLeft));
	}

	if (RxGRI.NextMap != "") {
		// Set Map Rotation mode
		if (NextMap != none)
			NextMap.SetText(GetMapFriendlyName(RxGRI.NextMap));
	} else {
		// End of Map Vote mode
		if (RxGRI.GetMapVote() >= 0) {
			if (NextMap != none) 
				NextMap.SetText(GetMapFriendlyName(RxGRI.MapVoteList[RxGRI.GetMapVote()]));	
		}
	}

	if(rxGRI.MapVotesSize > 0)
	{
		if(VoteListNum.Length <= 0)
		{
			for (i=0; i<rxGRI.MapVotesSize && rxGRI.MapVoteList[i] != ""; i++)
			{
				VoteListNum[i] = rxGRI.MapVotes[i];
			}
		}

		for (i=0; i<rxGRI.MapVotesSize && rxGRI.MapVoteList[i] != ""; i++)
		{
			//`log(VoteList.Length);
			//`log("ENDGAMESCORE"@rxGRI.MapVoteList[i]@rxGRI.MapVotes[i]);
			//`log(VoteList[i].name);
	//       VoteList[i].SetString("mapName", GetMapFriendlyName(RxGRI.MapVoteList[i]));
    	   
   	    	if(VoteListNum[i] != rxGRI.MapVotes[i])
   	    	{
   	    		VoteListNum[i] = rxGRI.MapVotes[i];

   	    		if(!bVoteNeedUpdate)
   	    			bVoteNeedUpdate = true;
       			
				VoteList[i].SetString("votes", "" $ rxGRI.MapVotes[i]);
			}
		}
    }

    if(bVoteNeedUpdate)
    	MapVoteList.SetBool("NeedUpdate",bVoteNeedUpdate);
}

function InitEndGameScoreboard()
{
	local float x0, y0, x1, y1; // Mouse co-ords
	local Vector2D lastMousePOS;

	`logd(">> Rx_GFxUIScoreBoard::CheckEndGameScoreboard",true,'DevGFxUI');	

	//Set mouse
	bCaptureInput = true;
	bIgnoreMouseInput = false;
	GetVisibleFrameRect(x0, y0, x1, y1);
    lastMousePOS.X = (x1-x0)/2;
    lastMousePOS.Y = (y1-y0)/2;

	//Get current mouse position in unreal, then set the flash mouse graphic to the same location.
	GetGameViewportClient().SetMouse(lastMousePOS.X,lastMousePOS.Y);
	CursorMC.SetPosition(lastMousePOS.x,lastMousePOS.Y);
	
	CursorMC.SetVisible(true);
	
	// swap building status icon layout
	BuildingStats.GotoAndStopI(2);

	LoadBuildings();

	if(duration != none)
		duration.SetText(FormatTime(RxGRI.RenEndTime));

	if(ServerName != None)
	{
		if(PC.WorldInfo.NetMode == NM_Standalone)
			ServerName.SetText("Skirmish Session");
		else
			ServerName.SetText(RxGRI.ServerName);
	}

	if(currentMap != None)
		currentMap.SetText(GetMapFriendlyName(PC.WorldInfo.GetMapName()));


	SetViewScaleMode(SM_ShowAll);
}

function SetEndVictoryText()
{
	local GFxObject WinnerReason;	

	VictoryText.SetVisible(true);

	if(RxGRI.WinnerTeamNum != PC.GetTeamNum())
	{
		VictoryText.GotoAndStopI(2);
	}

	WinnerReason = VictoryText.GetObject("reason");

	WinnerReason.SetText(RxGRI.WinnerReason);
}


/** Called when a CLIK Widget is initialized **/
 event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;


	`log(">> Rx_GFxUIScoreboard::WidgetInitialized"@`showvar(WidgetName),true,'DevGFxUI');

	bWasHandled = false;

	switch (WidgetName)
	{
		case 'mapVoteList':
			if (MapVoteList == none || MapVoteList != Widget) {
				MapVoteList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MapVoteList);
			MapVoteList.AddEventListener('CLIK_listIndexChange', OnMapVoteListChange);
			bWasHandled = true;
			break;
		case 'NODPlayerList':
			if (NODPlayerList == none || NODPlayerList != Widget) {
				NODPlayerList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(NODPlayerList);
			bWasHandled = true;
			break;
		case 'GDIPlayerList':
			if (GDIPlayerList == none || GDIPlayerList != Widget) {
				GDIPlayerList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(GDIPlayerList);
			bWasHandled = true;
			break;
		case 'ChatBox':
			if (ChatBox == none || ChatBox != Widget) {
				ChatBox = GFxClikWidget(Widget);
			}
			bWasHandled = true;
			break;
		case 'TextMsg':
			if (TextMsg == none || TextMsg != Widget) {
				TextMsg = GFxClikWidget(Widget);
			}
			bWasHandled = true;
			break;
		case 'SendBtn':
			if (SendBtn == none || SendBtn != Widget) {
				SendBtn = GFxClikWidget(Widget);
			}
			SendBtn.AddEventListener('CLIK_buttonClick', OnPlayerSendBtnPress);
			bWasHandled = true;
			break;
		case 'rootdebugtimerlabel':
			if (rootdebugtimerlabel == none || rootdebugtimerlabel != Widget) {
				rootdebugtimerlabel = GFxClikWidget(Widget);
			}
			SetUpDataProvider(rootdebugtimerlabel);
			bWasHandled = true;
			break;
		case 'NextRound':
			if (NextRound == none || NextRound != Widget) {
				NextRound = GFxClikWidget(Widget);
			}
			bWasHandled = true;
			break;
		case 'MVPGDICommander':
			if (MVPGDICommander == none || MVPGDICommander != Widget) {
				MVPGDICommander = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPGDICommander);
			bWasHandled = true;
			break;
		case 'MVPGDIPlayer':
			if (MVPGDIPlayer == none || MVPGDIPlayer != Widget) {
				MVPGDIPlayer = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPGDIPlayer);
			bWasHandled = true;
			break;
		case 'MVPGDIOffense':
			if (MVPGDIOffense == none || MVPGDIOffense != Widget) {
				MVPGDIOffense = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPGDIOffense);
			bWasHandled = true;
			break;
		case 'MVPGDIDefense':
			if (MVPGDIDefense == none || MVPGDIDefense != Widget) {
				MVPGDIDefense = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPGDIDefense);
			bWasHandled = true;
			break;
		case 'MVPGDISupport':
			if (MVPGDISupport == none || MVPGDISupport != Widget) {
				MVPGDISupport = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPGDISupport);
			bWasHandled = true;
			break;
		case 'MVPNODCommander':
			if (MVPNODCommander == none || MVPNODCommander != Widget) {
				MVPNODCommander = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPNODCommander);
			bWasHandled = true;
			break;
		case 'MVPNODPlayer':
			if (MVPNODPlayer == none || MVPNODPlayer != Widget) {
				MVPNODPlayer = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPNODPlayer);
			bWasHandled = true;
			break;
		case 'MVPNODOffense':
			if (MVPNODOffense == none || MVPNODOffense != Widget) {
				MVPNODOffense = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPNODOffense);
			bWasHandled = true;
			break;
		case 'MVPNODDefense':
			if (MVPNODDefense == none || MVPNODDefense != Widget) {
				MVPNODDefense = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPNODDefense);
			bWasHandled = true;
			break;
		case 'MVPNODSupport':
			if (MVPNODSupport == none || MVPNODSupport != Widget) {
				MVPNODSupport = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MVPNODSupport);
			bWasHandled = true;
			break;
		case 'BuildingStats':
			BuildingStats = Widget;
			SetUpDataProvider(BuildingStats);
			bWasHandled = true;
			break;
//		case 'sb':
//			if (Scoreboard == none || Scoreboard != Widget) {
//				Scoreboard = GFxClikWidget(Widget);
//			}
//			SetUpDataProvider(Scoreboard);
//			bWasHandled = true;
//			break;
		case 'endgameSB':
			if (EndGameScoreBoard == none || EndGameScoreBoard != Widget) {
				EndGameScoreBoard = GFxClikWidget(Widget);
			}
			SetUpDataProvider(EndGameScoreBoard);
			bWasHandled = true;
			break;
		case 'GDIScores':
			ScoreBoardGDI = GFxClikWidget(Widget);
			SetUpDataProvider(ScoreBoardGDI);
			bWasHandled = true;
			break;
		case 'NODScores':
			ScoreBoardNod = GFxClikWidget(Widget);
			SetUpDataProvider(ScoreBoardNod);
			bWasHandled = true;
			break;
		default:
			break;
	}
	return bWasHandled;
}

function SetUpDataProvider(GFxObject Widget)
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	DataProvider = CreateObject("scaleform.clik.data.DataProvider");

	UpdateCommanderNames();
	
	switch (Widget) 
	{
		case (MapVoteList):
			if (rxGRI.NextMap != "")
			{
				TempObj = CreateObject("Object");
				TempObj.SetString("mapName", "");
				TempObj.SetString("votes", "");
				for (i=0; i<5; i++)
					DataProvider.SetElementObject(i, TempObj);
			}
			else
			{
				`log("Scoreboard : Creating vote list...");

				for (i=0; i<rxGRI.MapVotesSize && rxGRI.MapVoteList[i] != ""; i++) {
					TempObj = CreateObject("Object");

					TempObj.SetString("mapName", GetMapFriendlyName(RxGRI.MapVoteList[i]));
					TempObj.SetString("votes", "" $ RxGRI.MapVotes[i]);
					VoteList[i] = TempObj;

					DataProvider.SetElementObject(i, TempObj);
				}
			}
			MapVoteList.Setint("selectedIndex", -1);
			break;
		case (NODPlayerList):
			NODPlayerList.SetInt("rowCount", 0);
			return;
		case (GDIPlayerList):
			GDIPlayerList.SetInt("rowCount", 0);
			return;
		case (rootdebugtimerlabel):
			if(debugScoreboardUI){
				rootdebugtimerlabel.SetText("Init");
				rootdebugtimerlabel.SetVisible(true);
			}
			return;
		case (TextMsg):
			TextMsg.SetText("");
			return;
		case (ChatBox):
			ChatBox.SetString("htmlText", ChatLog);
			ChatBox.SetInt("position", ChatBox.GetInt("maxScroll"));
			return;
		case (MVPGDICommander):
			if(CommanderName[0] != "")
				MVPGDICommander.SetText(CommanderName[0]);
			else
				MVPGDICommander.SetText("None");
			return;
		case (MVPGDIPlayer):
			if(RxGRI.MVP[0] != "")
				MVPGDIPlayer.SetText(RxGRI.MVP[0]);
			else
				MVPGDIPlayer.SetText("None");
			return;
		case (MVPGDIOffense):
			if(RxGRI.BestOP[0] != "")
				MVPGDIOffense.SetText(RxGRI.BestOP[0]);
			else
				MVPGDIOffense.SetText("None");
			return;
		case (MVPGDIDefense):
			if(RxGRI.BestDP[0] != "")
				MVPGDIDefense.SetText(RxGRI.BestDP[0]);
			else
				MVPGDIDefense.SetText("None");
			return;
		case (MVPGDISupport):
			if(RxGRI.BestSP[0] != "")
				MVPGDISupport.SetText(RxGRI.BestSP[0]);
			else
				MVPGDISupport.SetText("None");
			return;
		case (MVPNODCommander):
			if(CommanderName[1] != "")
				MVPNODCommander.SetText(CommanderName[1]);
			else
				MVPNODCommander.SetText("None");
			return;
		case (MVPNODPlayer):
			if(RxGRI.MVP[1] != "")
				MVPNODPlayer.SetText(RxGRI.MVP[1]);
			else
				MVPNODPlayer.SetText("None");
			return;
		case (MVPNODOffense):
			if(RxGRI.BestOP[1] != "")
				MVPNODOffense.SetText(RxGRI.BestOP[1]);
			else
				MVPNODOffense.SetText("None");
			return;
		case (MVPNODDefense):
			if(RxGRI.BestDP[1] != "")
				MVPNODDefense.SetText(RxGRI.BestDP[1]);
			else
				MVPNODDefense.SetText("None");
			return;
		case (MVPNODSupport):
			if(RxGRI.BestSP[1] != "")
				MVPNODSupport.SetText(RxGRI.BestSP[1]);
			else
				MVPNODSupport.SetText("None");
			return;
		case (EndGameScoreBoard):
			EndGameScoreboard.GotoAndStopI(PC.GetTeamNum() + 1);
			ServerName = EndGameScoreBoard.GetObject("ServerName");
			NextMap =  EndGameScoreBoard.GetObject("Nextmap");
			NextLoadingMap = EndGameScoreboard.GetObject("NextLoadingMap");
			duration = EndGameScoreBoard.GetObject("duration");
			currentMap = EndGameScoreboard.GetObject("map");
			return;
		case (ScoreBoardGDI):
			ScoreGDI = ScoreBoardGDI.GetObject("TeamScore");
			VictoryText = ScoreBoardGDI.GetObject("GameResultText");
			VictoryText.SetVisible(false);
			if(RxGRI.bMatchIsOver)
				SetEndVictoryText();
			return;
		case (ScoreBoardNod):
			ScoreNod = ScoreBoardNod.GetObject("TeamScore");
			VictoryText = ScoreBoardNod.GetObject("GameResultText");
			VictoryText.SetVisible(false);
			if(RxGRI.bMatchIsOver)
				SetEndVictoryText();
			return;
		/*case (StatsNod):
			if(RxGRI.bMatchIsOver && StatsGDI != none)
				UpdateBuildings();
		case (StatsGDI):
			if(RxGRI.bMatchIsOver && StatsNod != none)
				UpdateBuildings();*/
		default:
			return;
	}

	Widget.SetObject("dataProvider", DataProvider);
}

function int GetBuildingIndex(Rx_Building B)
{
	local Int Index;
	
	if(Rx_Building_InfantryFactory(B) != None)
		Index = 0;

	else if(Rx_Building_VehicleFactory(B) != None)
		Index = 1;

	else if(Rx_Building_MoneyFactory(B) != None)
		Index = 2;

	else if(Rx_Building_PowerFactory(B) != None)
		Index = 3;

	else if(Rx_Building_Defense(B) != None)
		Index = 4;

	else if(Rx_Building_RepairFacility(B) != None)
		Index = 5;

	else
		return -1;

	return Index;
}

function int GetBuildingPicIndex(Rx_Building B)
{
	if(Rx_Building_GDI_InfantryFactory(B) != None) return 3;
	if(Rx_Building_GDI_VehicleFactory(B) != None) return 8;
	if(Rx_Building_GDI_Defense(B) != None) return 1;
	
	if(Rx_Building_Nod_InfantryFactory(B) != None) return 4;
	if(Rx_Building_Nod_VehicleFactory(B) != None) return 2;
	if(Rx_Building_Nod_Defense(B) != None) return 5;

	if(Rx_Building_MoneyFactory(B) != None) return 7;
	if(Rx_Building_PowerFactory(B) != None) return 6;
	if(Rx_Building_RepairFacility(B) != None) return 9;

	return -1;
}

/** Helper function for converting a MapName to a label for list. Copied from GFxUDKFrontEnd_MapSelect */
function string GetMapFriendlyName(string Map)
{
	local int p, i;

	if (MapDataProviderList.Length <= 0) {
		if (PC.WorldInfo.Game != none) {
			MapDataProviderList = Rx_Game(PC.WorldInfo.Game).MapDataProviderList;
		} else {
			MapDataProviderList = RxGRI.GetMapDataProviderList();
		}
	}

	for (i = 0; i < MapDataProviderList.Length; i++) {
		if (Map ~= MapDataProviderList[i].MapName) {
			return MapDataProviderList[i].FriendlyName;
		}
	}
	PC.ClientMessage("WARN: Map not registered yet: " $ Map);
	`warn("WARN: Map not registered yet: " $ Map);
	// just strip the prefix
	p = InStr(Map,"-");
	if (P > INDEX_NONE)
	{
		Map = Right(Map, Len(Map) - P - 1);
	}
	if (Repl(Map, "_", " ") != "") {
		Map = Repl(Map, "_", " ");
	}

	return Map;
}

function int SortPriDelegate( coerce PlayerReplicationInfo pri1, coerce PlayerReplicationInfo pri2 )
{
	if (Rx_PRI(pri1) != none && Rx_PRI(pri2) != none)
	{
		if (Rx_PRI(pri1).GetRenScore() > Rx_PRI(pri2).GetRenScore())
			return 1;
		else if (Rx_PRI(pri1).GetRenScore() == Rx_PRI(pri2).GetRenScore())
			return 0;
		else
			return -1;
	}
	return 0;
}

function UpdateCommanderNames(){ 
	local PlayerReplicationInfo pri; 
	
	CommanderName[0] = ""; 
	CommanderName[1] = ""; 
	
	foreach RxGRI.PRIArray(pri)
	{
		if(Rx_Pri(pri) != None && Rx_PRI(pri).bIsCommander){
			if(pri.GetTeamNum() == 0){
				CommanderName[0] = pri.PlayerName; 
			}
			else{
				CommanderName[1] = pri.PlayerName; 
			}
				
		}
	}
}

function UpdateScoreTotals()
{
	local int gdiScore;
	local int nodScore;

	if(PC.GetTeamNum() == 0)
	{
		gdiScore = Rx_TeamInfo(PC.WorldInfo.GRI.Teams[TEAM_GDI]).GetRenScore();
		ScoreGDI.SetText(gdiScore);	
	}
	else
	{
		nodScore = Rx_TeamInfo(PC.WorldInfo.GRI.Teams[TEAM_NOD]).GetRenScore();
		ScoreNod.SetText(nodScore);	
	}
}

function UpdatePlayers()
{
	local int i, p;
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;
	local Rx_PRI RPRI;
	local GFxObject TeamDataProvider, tmpObj;

	p = 0;
	
	TeamDataProvider = CreateObject("scaleform.clik.data.DataProvider");

	foreach RxGRI.PRIArray(pri)
	{
		if(Rx_Pri(pri) == None || Rx_PRI(pri).bIsScripted)	// skip if the bot is a scripted one
			continue;

		PRIArray.AddItem(pri);
	}

	PRIArray.Sort(SortPriDelegate);	
	
	for (i = 0; i < PRIArray.Length ; i++)
	{
		
		RPRI = Rx_PRI(PRIArray[i]);
		
		tmpObj = CreateObject("Object");
		tmpObj.SetString("PlayerName", PRIArray[i].GetHumanReadableName());
		tmpObj.SetInt("Score", RPRI.GetRenScore());
		tmpObj.SetInt("Kills", RPRI.GetRenKills());
		tmpObj.SetInt("Deaths", PRIArray[i].Deaths);
		tmpObj.SetInt("VehicleKills", RPRI.Total_Vehicle_Kills);
		tmpObj.SetInt("Ping", PRIArray[i].Ping * 4);
		tmpObj.SetInt("Vet_Rank", int(RPRI.VRank) + 1);
		tmpObj.SetString("Color", "0xD4F0FF");

		if (RPRI.bIsCommander)
		{
			switch (PRIArray[i].GetTeamNum())
			{
				case TEAM_GDI:
					tmpObj.SetString("Color", "0xFFFF00");
				break;

				case TEAM_NOD:
					tmpObj.SetString("Color", "0xFF0000");
				break;
			}
		}

		if (PRIArray[i] == PC.PlayerReplicationInfo) 
			tmpObj.SetString("Color", "0x00FF00");

		if (PRIArray[i].GetTeamNum() == PC.GetTeamNum() && p < 32)
		{
			tmpObj.SetInt("Position", p + 1);
			TeamDataProvider.SetElementObject(p, tmpObj);
			p++;
		}
		else
			continue;
	}

	if(GDIPlayerList != none)
	{
		GDIPlayerList.SetObject("dataProvider", TeamDataProvider);
		GDIPlayerList.SetInt("rowCount", p);		
	}

	else if(NODPlayerList != None)
	{
		NODPlayerList.SetObject("dataProvider", TeamDataProvider);
		NODPlayerList.SetInt("rowCount", p);
	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'RenXScoreboard_Survival.RenXScoreboard_Survival'
	SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'renxfrontend.Sounds.SoundTheme')
	TimingMode=TM_Real
	Priority=10
	bIgnoreMouseInput = true
	bCaptureInput = false	
	ChatMaxRubberband = 2

	WidgetBindings.Empty

	WidgetBindings.Add((WidgetName="mapVoteList",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="NODPlayerList",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="GDIPlayerList",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="rootdebugtimerlabel",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="TextMsg",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="ChatBox",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="SendBtn",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="NextRound",WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="NextLoadingMap",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="sb",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="endgameSB",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="GDIScores",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="NODScores",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="MVPGDICommander",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPGDIPlayer",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPGDIOffense",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPGDIDefense",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPGDISupport",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPNODCommander",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPNODPlayer",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPNODOffense",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPNODDefense",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MVPNODSupport",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="BuildingStats",WidgetClass=class'GFxObject'))

}