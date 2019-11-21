class Rx_GFxUIScoreboard extends GFxMoviePlayer
	config(UI);

var GFxObject RootMC;
var GFxObject CursorMC;
var GFxObject FadeMC;
var GFxObject ResultMC;
var GFxObject LogoMC;
var GFxObject ResultTextMC;
var GFxObject rootdebugtimertext;

var GFxObject ScoreGDI;
var GFxObject ScoreNod;
var GFxObject StatsNod;
var GFxObject StatsGDI;


var GFxObject ServerName;
var GFxObject NextMap;
var GFxObject currentMap;
var GFxObject duration;

var GFxClikWidget ScoreBoardGDI;
var GFxClikWidget ScoreBoardNod;
var GFxObject Scoreboard;
var GFxClikWidget EndGameScoreBoard;
var GFxClikWidget MapVoteList;
var GFxClikWidget ChatBox;
var GFxClikWidget NODPlayerList;
var GFxClikWidget GDIPlayerList;
var GFxClikWidget TextMsg;
var GFxClikWidget SendBtn;
var GFxClikWidget NextRound;
var GFxObject NextLoadingMap;
var GFxClikWidget rootdebugtimerlabel;

var GFxClikWidget MVPGDICommander;
var GFxClikWidget MVPGDIPlayer;
var GFxClikWidget MVPGDIOffense;
var GFxClikWidget MVPGDIDefense;
var GFxClikWidget MVPGDISupport;
var GFxClikWidget MVPNODCommander;
var GFxClikWidget MVPNODPlayer;
var GFxClikWidget MVPNODOffense;
var GFxClikWidget MVPNODDefense;
var GFxClikWidget MVPNODSupport;

struct Buildings
{
	// references to the flash objects.
	var GFxObject containerMC;
	var GFxObject hpMC;
	var GFxObject armorMC;
	var GFxObject iconMC;

	var Rx_Building building;
	var int iconIndex;

	// cache currently known state of flash states. Allows us to not update flash if there isnt a change.
	var int hp;
	var int armor;
	var bool status;
};

//var Buildings BuildingsList[12];
var Array<Buildings> GDIBuilding;
var Array<Buildings> NodBuilding;

var array<GFxObject> VoteList;
var array<int> VoteListNum;

var string ChatLog;

var float LastUpdateTime;
var float EndGameTime;
var float LastEndGameUpdateTime;
//var bool EndGameScoresUpdateFirstLoaded, EndGameBuildingsUpdateFirstLoaded; // We only need to values once when the match has ended.

var PlayerController PC;
var Rx_GRI RxGRI;	

var config bool debugScoreboardUI; // Show debug elements on screen.

var array<Rx_UIDataProvider_MapInfo> MapDataProviderList;
var bool bHasFadeIn;

var string CommanderName[2]; 
var bool bHasInitialized;
var float ChatMaxRubberband;
var int BeepPoint;


//Caches
var int LastGDIScore, LastNodScore;


function bool Start(optional bool StartPaused = false)
{
	//cache variables we use alot
	PC = GetPC();
	RxGRI = Rx_GRI(PC.WorldInfo.GRI);

    super.Start();
    Advance(0.f);

    LastGDIScore = -1;
    LastNodScore = -1;
	
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

/**
 * Finds objects inside loaded flash file and stores a reference.
 * The more we can move out of this and into WidgetInitialized() the better
 */
function LoadGfxObjects()
{
	`logd(">> Rx_GFxUIScoreBoard::UpdateGfxObjects",true,'DevGFxUI');

	//Root
	RootMC = GetVariableObject("root1.rootMC");
	
	
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

	else
		Scoreboard = RootMC.GetObject("sb");	
//	{		
//		SetBuildingGfxObjects(EndGameScoreBoard);
//	}

	if(debugScoreboardUI)
		rootdebugtimertext.SetVisible(true);
}

function InitScoreboard()
{
	if(Scoreboard != None)
		ServerName = Scoreboard.GetObject("ServerName");

	if(ServerName == None)
		return;

	if(PC.WorldInfo.NetMode == NM_Standalone)
		ServerName.SetText("Skirmish Session");
	else
		ServerName.SetText(RxGRI.ServerName);

	LoadBuildings();

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

function LoadBuildings()
{
	local Rx_Building B;
	local Array<Rx_Building> BList;
	local Buildings TempBuilding;

	local int buildingIndex;
	local ASDisplayInfo DI;
	local float GDIYPos, NodYPos;

	//empty these out
	GDIBuilding.Length = 0;
	NodBuilding.Length = 0;

	foreach PC.AllActors(class'Rx_Building', B)
	{
		if(!B.bSignificant)
			continue;

		BList.AddItem(B);
	}

	BList.Sort(SortBuildingDelegate);

	foreach BList(B)
	{
		BuildingIndex = GetBuildingIndex(B);
		if(buildingIndex == -1)
			continue;

		if(B.GetTeamNum() == 0)
		{
			if(StatsGDI == None) // if there's no movie here, drop
				continue;


			TempBuilding.containerMC = StatsGDI.AttachMovie("StatsBuilding","Building"$(GDIBuilding.Length + 1));

			if(!RxGRI.bMatchIsOver)
			{
				if(GDIBuilding.Length > 0)
					GDIYPos += 96; 
				else
					GDIYPos = 64;

				TempBuilding.containerMC.SetPosition(-64.f,GDIYPos);

			}
			else
				TempBuilding.containerMC.SetPosition(-64.f - (98 * ((GDIBuilding.Length + 3) % 3)),(64.f + (128.f * FFLoor(GDIBuilding.Length / 3))));


			
		}
		else if(B.GetTeamNum() == 1)
		{
			if(StatsNod == None) // if there's no movie here, drop
				continue;			

			TempBuilding.containerMC = StatsNod.AttachMovie("StatsBuilding","Building"$(NodBuilding.Length + 1));

			if(GDIBuilding.Length > 0)
				NodYPos += 96; 
			else
				NodYPos = 64;
			
			if(!RxGRI.bMatchIsOver)
			{
				TempBuilding.containerMC.SetPosition(64.f,NodYPos);
			}
			else
				TempBuilding.containerMC.SetPosition(64.f + (98 * ((NodBuilding.Length + 3) % 3)),(64.f + (128.f * FFLoor(NodBuilding.Length / 3))));

			
		}

		TempBuilding.building = B;

		TempBuilding.hpMC = TempBuilding.containerMC.GetObject("hp");
		TempBuilding.armorMC = TempBuilding.containerMC.GetObject("ap");
		TempBuilding.iconMC = TempBuilding.containerMC.GetObject("icon");	

		`logd("Rx_GFxUIScoreBoard::LoadBuildings"@`ShowVar(buildingIndex),true,'DevGFxUI');
		
		TempBuilding.iconIndex = GetBuildingPicIndex(B);
		TempBuilding.iconMC.GotoAndStopI(TempBuilding.iconIndex);

		if(RxGRI.bMatchIsOver)
		{
			TempBuilding.hp = 100;
			TempBuilding.armor = 100;
		}
		if(B.GetTeamNum() == 0)
		{
			GDIBuilding.AddItem(TempBuilding);
		}
		else
		{
			NodBuilding.AddItem(TempBuilding);
		}
	}

	// Reset our cached values for buildings as we are moving to endgame scoreboard.
	if(!RxGRI.bMatchIsOver)	
	{
		if(GDIBuilding.Length > 5)
		{
			DI.HasXScale = True;
			DI.HasYScale = True;
			DI.YScale = 100.f * 6 / GDIBuilding.Length;
			DI.XScale = DI.YScale;

			StatsGDI.SetDisplayInfo(DI);
		}

		if(NodBuilding.Length > 5)
		{
			DI.HasXScale = True;
			DI.HasYScale = True;
			DI.YScale = 100.f * 6 / NodBuilding.Length;
			DI.XScale = DI.YScale;

			StatsNod.SetDisplayInfo(DI);
		}
	}
}

function UpdateBuildings(bool force) 
{

	if(GDIBuilding.Length > 0)
		UpdateBuildingGFx(GDIBuilding,force);

	if(NodBuilding.Length > 0);
		UpdateBuildingGFx(NodBuilding,force);

}

function UpdateBuildingGFx(Array<Buildings> BList, bool force)
{
	local int health, armor, i;
	local Buildings TempBuilding;

	foreach BList(TempBuilding, i)
	{
		`logd("Rx_GFxUIScoreBoard::UpdateBuildings"@`ShowVar(i),true,'DevGFxUI');

		if(TempBuilding.building == none) //building doesnt exist on map.
			continue;

		`logd("Rx_GFxUIScoreBoard::UpdateBuildings"@`ShowVar(TempBuilding.building),true,'DevGFxUI');

		`logd("Rx_GFxUIScoreBoard::UpdateBuildings"@`ShowVar(TempBuilding.building.GetArmor())@`ShowVar(TempBuilding.building.GetMaxArmor())@`ShowVar(TempBuilding.building.GetArmor()/TempBuilding.building.GetMaxArmor()*100.0),true,'DevGFxUI');
		

		// Get health and armor levels as percentage
		health = float(TempBuilding.building.GetHealth())/float(TempBuilding.building.GetTrueMaxHealth())*100.0;
		if(TempBuilding.building.GetMaxArmor() != 0)
			armor = float(TempBuilding.building.GetArmor())/float(TempBuilding.building.GetMaxArmor())*100.0; 

		`logd("Rx_GFxUIScoreBoard::UpdateBuildings"@`ShowVar(health)@`ShowVar(TempBuilding.hp)@`ShowVar(armor),true,'DevGFxUI');

		if(TempBuilding.building.IsDestroyed() && (TempBuilding.hp != 0 || force)) // Building is destroyed, if TempBuilding.hp is already 0, we have already updated flash.
		{
			TempBuilding.hp = 0;
			TempBuilding.containerMC.GotoAndStopI(2); //swap building symbol to destroyed frame.
			
			// regrab icon movie clip & reset icon, as we have changed frame.
			TempBuilding.iconMC = TempBuilding.containerMC.GetObject("icon");	
			TempBuilding.iconMC.GotoAndStopI(TempBuilding.iconIndex);
		}
		else if (!TempBuilding.building.IsDestroyed()) // Update health and armor levels on UI.
		{
			 //check our cached health to see if it has changed.
			if(force || health != TempBuilding.hp)
			{
				TempBuilding.hpMC.GotoAndStopI(health);
				TempBuilding.hp = Max(1,health); // we get here only because we're alive. if the hp is 0, that means we're dead
			}
			if(force || armor != TempBuilding.armor)
			{
				TempBuilding.armorMC.GotoAndStopI(armor);
				TempBuilding.armor = armor;
			}
		}
	}	
}

function UpdateScoreTotals()
{
	local int gdiScore;
	local int nodScore;

	gdiScore = Rx_TeamInfo(PC.WorldInfo.GRI.Teams[TEAM_GDI]).GetRenScore();
	if(LastGDIScore != gdiScore)
	{
		ScoreGDI.SetText(gdiScore);		
		LastGDIScore = gdiScore;
	}

	nodScore = Rx_TeamInfo(PC.WorldInfo.GRI.Teams[TEAM_NOD]).GetRenScore();
	if(LastNodScore != nodScore)
	{
		ScoreNod.SetText(nodScore);	
		LastNodScore = nodScore;
	}

}

function UpdatePlayers()
{
	local int i, NODp, GDIp;
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;
	local Rx_PRI RPRI;
	local GFxObject DataProviderNod, DataProviderGDI, tmpObj;

	GDIp = 0;
	NODp = 0;
	
	DataProviderNod = CreateObject("scaleform.clik.data.DataProvider");
	DataProviderGDI = CreateObject("scaleform.clik.data.DataProvider");

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

		if (PRIArray[i] == PC.PlayerReplicationInfo) tmpObj.SetString("Color", "0x00FF00");

		if (PRIArray[i].GetTeamNum() == TEAM_GDI && GDIp < 32)
		{
			tmpObj.SetInt("Position", GDIp + 1);
			DataProviderGDI.SetElementObject(GDIp, tmpObj);
			GDIp++;
		}
		else if (PRIArray[i].GetTeamNum() == TEAM_NOD && NODp < 32)
		{
			tmpObj.SetInt("Position", NODp + 1);
			DataProviderNOD.SetElementObject(NODp, tmpObj);
			NODp++;
		}
		else
			continue;
	}

	if(NODPlayerList != none || GDIPlayerList != none)
	{
		NODPlayerList.SetObject("dataProvider", DataProviderNOD);
		GDIPlayerList.SetObject("dataProvider", DataProviderGDI);

		NODPlayerList.SetInt("rowCount", NODp);
		GDIPlayerList.SetInt("rowCount", GDIp);		

	}
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
			if(TimeLeft < BeepPoint)
			{
				BeepPoint = FFloor(TimeLeft);
				PlayTickSound();
			}


			if(TimeLeft > 0)
			{
				NextRound.GotoAndStopI(10); // swap nextround countdown to red.		
				NextRound.SetText(Left(string(TimeLeft), InStr(string(TimeLeft), ".") + 2));
			}
			else
			{
				NextRound.SetVisible(false);
				NextLoadingMap.GotoAndStopI(10); // swap NextLoadingMap to red.
				NextLoadingMap.SetText("Loading Map...");
				PC.ClearTimer('PlayTickSound', self);
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
	local GFxObject WinnerTeam, WinnerReason;

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

	if(RxGRI != None)
		switch (RxGRI.WinnerTeamNum)
		{
			case TEAM_GDI:
				WinnerTeam = ScoreBoardGDI.GetObject("victory");
				WinnerReason = ScoreBoardGDI.GetObject("reason");
			break;
	
			case TEAM_NOD:
				WinnerTeam = ScoreBoardNod.GetObject("victory");
				WinnerReason = ScoreBoardNod.GetObject("reason");
			break;
		}

	WinnerTeam.SetVisible(true);
	WinnerReason.SetVisible(true);
	WinnerReason.SetText(RxGRI.WinnerReason);

	SetViewScaleMode(SM_ShowAll);
}

/**
 * Format time from float into string for ui
 * Format as HH:MM:SS
 */
function string FormatTime(float fTime)
{
	local string sTime;

	sTime = "";

	sTime $= divideTime(fTime, 3600); // hours
	sTime $= ":";
	sTime $= divideTime(fTime, 60); // minutes
	sTime $= ":";

	//seconds
	if(fTime < 10)
		sTime $= "0";
	sTime $= string(ffloor(fTime)); 

	return sTime;
}

function string divideTime(out float fTime, int timeDivision)
{
	local string sTime;
	local int iTmp;

	sTime = "";

	if(fTime - timeDivision > 0)
	{
		iTmp = ffloor(fTime / timeDivision);
		sTime $= string(iTmp);
		fTime -= timeDivision * iTmp;

		if(iTmp < 10)
			sTime = "0" $ sTime;
	} else
		sTime = "00";

	return sTime;
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
		case 'Stats_Nod':
			StatsNod = Widget;
			SetUpDataProvider(StatsNod);
			bWasHandled = true;
			break;
		case 'Stats_GDI':
			StatsGDI = Widget;
			SetUpDataProvider(StatsGDI);
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
			ServerName = EndGameScoreBoard.GetObject("ServerName");
			NextMap =  EndGameScoreBoard.GetObject("Nextmap");
			NextLoadingMap = EndGameScoreboard.GetObject("NextLoadingMap");
			duration = EndGameScoreBoard.GetObject("duration");
			currentMap = EndGameScoreboard.GetObject("map");
			return;
		case (ScoreBoardGDI):
			ScoreGDI = ScoreBoardGDI.GetObject("TeamScore");
			ScoreBoardGDI.GetObject("victory").SetVisible(false);
			ScoreBoardGDI.GetObject("reason").SetVisible(false);
			return;
		case (ScoreBoardNod):
			ScoreNod = ScoreBoardNod.GetObject("TeamScore");
			ScoreBoardNod.GetObject("victory").SetVisible(false);
			ScoreBoardNod.GetObject("reason").SetVisible(false);
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

function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	switch (ButtonName) 
	{
		case 'Enter':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if (TextMsg != none && TextMsg.GetText() != "") {
					PC.Say(TextMsg.GetText());
					PlaySoundFromTheme('press', 'default');
					TextMsg.SetText("");
				} 
			}
			return false;
		default:
			return false;
	}
}

function OnPlayerSendBtnPress(GFxClikWidget.EventData ev)
{
	if (TextMsg == none || TextMsg.GetText() == "") {
		PC.ClientMessage("WARN: " $ "TextMsg? " $ TextMsg $ "TextMsg.GetText()" $ TextMsg.GetText());
		return;
	}

	PC.Say(TextMsg.GetText());
	TextMsg.SetText("");
}

function AddChatMessage(string html, string raw)
{
	local bool bUpdateTomaxScroll;
	local int CurrentPos;

	ChatLog $= html $ "\n";

	if (ChatBox != none) 
	{
		CurrentPos = ChatBox.GetInt("position");

		if(CurrentPos >= ChatBox.GetInt("maxScroll") - ChatMaxRubberband)
			bUpdateTomaxScroll = true;


		ChatBox.SetString("htmlText", ChatLog);
		ChatBox.SetString("rawMsg", raw);

		if(bUpdateTomaxScroll && PC != None && !PC.IsTimerActive('UpdateScroll',Self))
			PC.SetTimer(0.1,false,'UpdateScroll',Self); // Set timer here since maxScroll doesn't update immediately
			

	}
}

function UpdateScroll()
{
	ChatBox.SetInt("position", ChatBox.GetInt("maxScroll"));
}

function OnMapVoteListChange (GFxClikWidget.EventData ev) 
{

	local int selectedIndex;
	//`log(GFxClikWidget.Name);
	//`log("map:"@ev._this.GetString("mapName"));
	//`log(`showvar(ev.target));
	//`log(`showvar(ev.type));
	//`log(`showvar(ev.data));
	//`log(`showvar(ev.mouseIndex));
	//`log(`showvar(ev.button));
	selectedIndex = MapVoteList.GetInt("selectedIndex");
	//`log(`showvar(ev.lastIndex));
	Rx_Controller(PC).VoteForMap(selectedIndex);
	//SetUpDataProvider(MapVoteList);

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

	if(B.GetTeamNum() > 0)
		Index = Index + 6;

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

function SetBuildingGfxObjects(GFXObject obj)
{
//	local int i;

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

function int SortBuildingDelegate( coerce Rx_Building B1, coerce Rx_Building B2 )
{
	if (B1.myBuildingType > B2.myBuildingType)
		return 1;
	else if (B1.myBuildingType == B2.myBuildingType)
		return 0;
	else
		return -1;


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

DefaultProperties
{
	MovieInfo=SwfMovie'RenXScoreboard.RenXScoreboard'
	SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'renxfrontend.Sounds.SoundTheme')
	TimingMode=TM_Real
	Priority=10
	bIgnoreMouseInput = true
	bCaptureInput = false	
	ChatMaxRubberband = 2

	WidgetBindings.Add((WidgetName="mapVoteList",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="NODPlayerList",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="GDIPlayerList",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="rootdebugtimerlabel",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="TextMsg",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="ChatBox",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="SendBtn",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="NextRound",WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="NextLoadingMap",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="Stats_Nod",WidgetClass=class'GFxObject'))
	WidgetBindings.Add((WidgetName="Stats_GDI",WidgetClass=class'GFxObject'))

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

	BeepPoint = 10
}
