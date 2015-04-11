class Rx_GFxUIScoreboard extends GFxMoviePlayer;

var GFxObject RootMC;
var GFxObject ServerName;
var GFxObject ScoreGDI;
var GFxObject ScoreNod;
var GFxObject test;
var GFxObject buildings[10];
var GFxObject buildingsHp[10];
var GFxObject buildingsStatus[10];
var GFxObject Scoreboard;
var GFxObject ScoreboardVictoryMsg;
var GFxObject ScoreboardVictoryReason;
var GFxObject NextRound;//
var GFxObject NextRoundRed;//
var GFxObject NextMap;//
var GFxObject NextLoadingMap;//
var GFxObject NextLoadingMapRed;//
var GFxObject MapList;
var GFxObject FadeMC;

var GFxClikWidget PlayerChatMsg;
var GFxClikWidget MapVoteList;
var GFxClikWidget PlayerChatBtn;
var GFxClikWidget ChatBox;
var string ChatLog;

var float LastUpdateTime;
var float EndGameTime;
var float LastEndGameUpdateTime;

var bool bInitialized;
var bool bHasFadeIn;
var bool bMapVoteInitialized;
var bool bChatInitialized;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0.f);

	if (!bInitialized)
	{		
		UpdateGfxObjects();
		bInitialized = true;	
		bHasFadeIn = false;
		CheckEndGameScoreboard();
	}	
	AddFocusIgnoreKey('Escape');
    return true;
}

function UpdateGfxObjects()
{
	RootMC = GetVariableObject("_root");
	ServerName = GetVariableObject("_root.ServerName");
	ScoreGDI = GetVariableObject("_root.sb.GDI.TeamScore");
	ScoreNod = GetVariableObject("_root.sb.Nod.TeamScore");
	Scoreboard = GetVariableObject("_root.sb");	
	ScoreboardVictoryMsg = GetVariableObject("_root.sb.VictoryMessage");	
	ScoreboardVictoryReason = GetVariableObject("_root.sb.VictoryReason");	
	NextRound = GetVariableObject("_root.sb.Nextround");	
	NextRoundRed = GetVariableObject("_root.sb.NextroundRed");	
	NextMap = GetVariableObject("_root.sb.Nextmap");
	NextLoadingMap = GetVariableObject("_root.sb.NextLoadingMap");
	NextLoadingMapRed = GetVariableObject("_root.sb.NextLoadingMapRed");
	
	MapList = GetVariableObject("_root.sb.MapList");	
	FadeMC = GetVariableObject("_root.fadeMC");
	
	SetBuildingGfxObjects();
}

function Draw()
{
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;	
	local Rx_GRI GRI;
	local int i;
	local int gdiScore;
	local int nodScore;
	local Rx_Building B;
	local int health;
	local int UpdateInterval;
	
	if (!bMovieIsOpen) {
		return;
	}

	if(GetPC() == None || Rx_GRI(GetPC().WorldInfo.GRI) == None)
		return; 
	
	if(GetPC().WorldInfo.GRI.bMatchIsOver)
		//UpdateInterval = 0.5;
		UpdateInterval = 0.0;
	else
		UpdateInterval = 0.1;
			
	//nl = Chr(13)$Chr(10);
	if(GetPC().Worldinfo.Timeseconds - LastUpdateTime < UpdateInterval)
		return;
	LastUpdateTime = GetPC().Worldinfo.Timeseconds;
	
	GRI = Rx_GRI(GetPC().WorldInfo.GRI);	
	
	UpdateGfxObjects();
	ResetFields();	
	
	CheckEndGameScoreboard();
	

// 	if(GRI.bMatchIsOver && ChatBox!= none)
// 	{
// 		if (Rx_HUD(GetPC().myHUD).HudMovie != none) {
// 			foreach Rx_HUD(GetPC().myHUD).HudMovie.ChatMessages(mrow)
// 			{
// 				chatText = chatText$nl$mrow.TF.GetString("rawMsg");
// 			}
// 			//ChatBox.SetText(chatText);
// 			ChatBox.SetString("htmlText", chatText);
// 		}
// 	}
		
	for (i = 0; i < 10 ; i++)
	{
		buildings[i].SetVisible(false);
	}
	
	foreach GetPC().AllActors(class'Rx_Building', B)
	{
		if(GetBuildingIndex(B) == -1)
			continue;
		buildings[GetBuildingIndex(B)].SetVisible(true);
		health = Float(B.GetHealth())/Float(B.GetMaxHealth())*100.0;
		if(health <= 0)
			buildings[GetBuildingIndex(B)].GotoAndStopI(2);
		else	
			buildingsHp[GetBuildingIndex(B)].GotoAndStopI(health);
		buildingsStatus[GetBuildingIndex(B)].GotoAndStopI(GetBuildingPicIndex(B));
	}	
	
	foreach GRI.PRIArray(pri)
	{
		if(Rx_Pri(pri) != None) {
			PRIArray.AddItem(pri);
		}
	}
	PRIArray.Sort(SortPriDelegate);	
	
	for (i = 0; i < PRIArray.Length ; i++)
	{
		if (!PRIArray[i].bIsSpectator)
		{
			if(PRIArray[i].GetTeamNum() == TEAM_GDI) {
				if(GRI != none && !GRI.bMatchIsOver) {
					PopulateFields(0,PRIArray[i].GetHumanReadableName(),false,Rx_Pri(PRIArray[i]).GetRenScore(),Rx_Pri(PRIArray[i]).GetRenKills(),PRIArray[i].Deaths, PRIArray[i].Ping * 4);
				} else {
					PopulateFields(0,PRIArray[i].GetHumanReadableName(),false,Rx_Pri(PRIArray[i]).GetRenScore(),Rx_Pri(PRIArray[i]).GetRenKills(),PRIArray[i].Deaths, -1);
				}
			}
			else {
				if(GRI != none && !GRI.bMatchIsOver) {
					PopulateFields(1,PRIArray[i].GetHumanReadableName(),false,Rx_Pri(PRIArray[i]).GetRenScore(),Rx_Pri(PRIArray[i]).GetRenKills(),PRIArray[i].Deaths, PRIArray[i].Ping * 4);
				} else {
					PopulateFields(1,PRIArray[i].GetHumanReadableName(),false,Rx_Pri(PRIArray[i]).GetRenScore(),Rx_Pri(PRIArray[i]).GetRenKills(),PRIArray[i].Deaths, -1);
				}
			}
		}
	}
	gdiScore = Rx_TeamInfo(GetPC().WorldInfo.GRI.Teams[TEAM_GDI]).GetRenScore();
	nodScore = Rx_TeamInfo(GetPC().WorldInfo.GRI.Teams[TEAM_NOD]).GetRenScore();
	ScoreGDI.SetText(gdiScore);	
	ScoreNod.SetText(nodScore);	

	
	ServerName.SetText(GetPC().WorldInfo.GRI.ServerName);
}

function CheckEndGameScoreboard()
{
    local Rx_GRI RxGRI;	
	local float TimeLeft;
	
	RxGRI = Rx_GRI(GetPC().WorldInfo.GRI);
	if(RxGRI != none && RxGRI.bMatchIsOver)
	{
		TimeLeft = RxGRI.RenEndTime - GetPC().WorldInfo.RealTimeSeconds; //?
		if (int(TimeLeft) < 10) {
			TimeLeft = FClamp(TimeLeft, 0.0, 10.0);
			if (NextRound != none) {
				if (NextRound.GetBool("_visible")) {
					NextRound.SetText("");
					NextRound.SetVisible(false);
				}
				if (!NextRoundRed.GetBool("_visible")) {
					NextRoundRed.SetVisible(true);
				}
			
				if (NextRoundRed != none) {
					NextRoundRed.SetText(Left(string(TimeLeft), InStr(string(TimeLeft), ".") + 2));
				}

				if (TimeLeft <= 0.0) {
					NextLoadingMap.SetVisible(false);
					NextRoundRed.SetVisible(false);
					NextLoadingMapRed.SetVisible(true);
					NextLoadingMapRed.SetText("Loading Map...");
				}
			}

			if ((float(int(TimeLeft*10.0))/10.0) - int(TimeLeft) == 0 && (float(int(TimeLeft*10.0))/10.0) != LastEndGameUpdateTime) {
				LastEndGameUpdateTime = float(int(TimeLeft));
				//TODO: find a way to call this once per second
				PlaySoundFromTheme('Click', 'default'); 
			}

		} else {
			if (NextRoundRed != none) {
				if (NextRoundRed.GetBool("_visible")) {
					NextRoundRed.SetText("");
					NextRoundRed.SetVisible(false);
				}
				if (!NextRound.GetBool("_visible")) {
					NextRound.SetVisible(true);
				}
				if (NextRound != none) {
					NextRound.SetText(int(TimeLeft));
				}
			}
			if (NextLoadingMapRed != none) {
				if (NextLoadingMapRed.GetBool("_visible")) {
					NextLoadingMapRed.SetText("");
					NextLoadingMapRed.SetVisible(false);
				}
			}
		}
		
		if (RxGRI.NextMap != "")
		{
			// Set Map Rotation mode
			if (NextMap != none)
				NextMap.SetText(GetMapFriendlyName(RxGRI.NextMap));
		}
		else
		{
			// End of Map Vote mode
			if (RxGRI.GetMapVote() >= 0) {
			if (NextMap != none) {
				NextMap.SetText(GetMapFriendlyName(Rx_GRI(GetPC().WorldInfo.GRI).MapVoteList[RxGRI.GetMapVote()]));
				}			
			}
		}

		if (!bMapVoteInitialized) {
				if (MapVoteList == none) {
					MapVoteList = GFxClikWidget(GetVariableObject("_root.sb.mapVoteList", class 'GFxClikWidget' ));
					if (MapVoteList != none) {
						SetUpDataProvider (MapVoteList);
						MapVoteList.Setint("selectedIndex", -1);
						//MapVoteList.AddEventListener('CLIK_itemClick', OnMapVoteListItemClick);
						if (RxGRI.NextMap == "")
							MapVoteList.AddEventListener('CLIK_change', OnMapVoteListChange);
						bMapVoteInitialized = true;
					}
				} 
			} else {
				//TEMP
				if (MapVoteList != none) {
					SetUpDataProvider (MapVoteList);
				}
			}

		if (!bChatInitialized) {
			if (PlayerChatMsg == none) {
				PlayerChatMsg = GFxClikWidget(GetVariableObject("_root.sb.TextMsg", class'GFxClikWidget'));	
				if (PlayerChatMsg != none) {
					PlayerChatMsg.SetString("text", "");
				}
			}
			if (PlayerChatBtn == none) {
				PlayerChatBtn = GFxClikWidget(GetVariableObject("_root.sb.SendBtn", class'GFxClikWidget'));	
				if (PlayerChatBtn != none) {
					PlayerChatBtn.AddEventListener('CLIK_Press', OnPlayerChatBtnPress);
				}
			}
			if (ChatBox == none) {
				ChatBox = GFxClikWidget(GetVariableObject("_root.sb.ChatBox", class'GFxClikWidget'));	
				if (ChatBox != none) {
					ChatBox.SetString("htmlText", ChatLog);
					ChatBox.SetFloat("position", ChatBox.GetFloat("maxscroll"));
				}
			}

			if (PlayerChatMsg != none && PlayerChatBtn != none && ChatBox != none) {
				bChatInitialized = false;
			}
			
		}
		
		//RootMC.GotoAndStopI(10);

		if(ScoreboardVictoryReason != None)
		{
			if(RxGRI.WinnerReason ~= "By Time Limit")
				ScoreboardVictoryReason.GotoAndStopI(4);
			else
				ScoreboardVictoryReason.GotoAndStopI(2);
		}
			
		if(ScoreboardVictoryMsg != None)
		{
			if(RxGRI.WinnerTeamNum == TEAM_GDI)
				ScoreboardVictoryMsg.GotoAndStopI(2);
			else
				ScoreboardVictoryMsg.GotoAndStopI(3);
		}
	}		
}

function SetUpDataProvider(GFxClikWidget Widget)
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	local Rx_GRI rxGRI;

	DataProvider = CreateArray();

	rxGRI = Rx_GRI(GetPC().WorldInfo.GRI);
	switch (Widget) 
	{
		case (MapVoteList):
			if (rxGRI.NextMap != "")
			{
				TempObj = CreateObject("Object");
				TempObj.SetString("label", "");
				TempObj.SetString("numLabel", "");
				for (i=0; i<5; i++)
					DataProvider.SetElementObject(i, TempObj);
			}
			else
			{
				//Widget.SetInt("rowCount", 5);
				for (i=0; i<rxGRI.MapVotesSize && rxGRI.MapVoteList[i] != ""; i++) {
					TempObj = CreateObject("Object");

					TempObj.SetString("label", GetMapFriendlyName(Rx_GRI(GetPC().WorldInfo.GRI).MapVoteList[i]));
					TempObj.SetString("numLabel", "" $ Rx_GRI(GetPC().WorldInfo.GRI).MapVotes[i]); 

					DataProvider.SetElementObject(i, TempObj);
				}
			}
			break;
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
				if (PlayerChatMsg != none && PlayerChatMsg.GetBool("_visible") && PlayerChatMsg.GetString("text") != "") {
					GetPC().Say(PlayerChatMsg.GetString("text"));
					PlaySoundFromTheme('click', 'default');
					PlayerChatMsg.SetString("text", "");
				} 
			}
			return false;
		default:
			return false;
	}
	
}

function AddChatMessage(string html, string raw)
{
	ChatLog $= html $ "\n";

	if (ChatBox != none) {
		ChatBox.SetString("htmlText", ChatLog);
		ChatBox.SetString("rawMsg", raw);
		ChatBox.SetFloat("position", ChatBox.GetFloat("maxscroll"));
	}
}

function OnPlayerChatBtnPress(GFxClikWidget.EventData ev)
{
	if (PlayerChatMsg == none || PlayerChatMsg.GetString("text") == "") {
		GetPC().ClientMessage("WARN: " $ "PlayerChatMsg? " $ PlayerChatMsg $ "PlayerChatMsg.GetString('text')" $ PlayerChatMsg.GetString("text"));
		return;
	}
	GetPC().Say(PlayerChatMsg.GetString("text"));
	PlayerChatMsg.SetString("text", "");
}

function OnMapVoteListChange (GFxClikWidget.EventData ev) 
{
	Rx_Controller(GetPC()).VoteForMap(ev.index);
	//SetUpDataProvider(MapVoteList);
}

function OnMapVoteListItemClick(GFxClikWidget.EventData ev)
{
	Rx_Controller(GetPC()).VoteForMap(ev.index);
}

function int GetBuildingIndex(Rx_Building B)
{
	if(Rx_Building_Barracks(B) != None) return 0;
	if(Rx_Building_WeaponsFactory(B) != None) return 1;
	if(Rx_Building_Refinery_GDI(B) != None) return 2;
	if(Rx_Building_PowerPlant_GDI(B) != None) return 3;
	if(Rx_Building_AdvancedGuardTower(B) != None) return 4;
	
	if(Rx_Building_HandOfNod(B) != None) return 5;
	if(Rx_Building_AirTower(B) != None) return 6;
	if(Rx_Building_Refinery_Nod(B) != None) return 7;
	if(Rx_Building_PowerPlant_Nod(B) != None) return 8;
	if(Rx_Building_Obelisk(B) != None) return 9;
	return -1;
}

function int GetBuildingPicIndex(Rx_Building B)
{
	if(Rx_Building_Barracks(B) != None) return 3;
	if(Rx_Building_WeaponsFactory(B) != None) return 8;
	if(Rx_Building_Refinery_GDI(B) != None) return 7;
	if(Rx_Building_PowerPlant_GDI(B) != None) return 6;
	if(Rx_Building_AdvancedGuardTower(B) != None) return 1;
	
	if(Rx_Building_HandOfNod(B) != None) return 4;
	if(Rx_Building_AirTower(B) != None) return 2;
	if(Rx_Building_Refinery_Nod(B) != None) return 7;
	if(Rx_Building_PowerPlant_Nod(B) != None) return 6;
	if(Rx_Building_Obelisk(B) != None) return 5;
	return -1;
}

/** Helper function for converting a MapName to a label for list. Copied from GFxUDKFrontEnd_MapSelect */
function string GetMapFriendlyName(string Map)
{
	local int p;

	

	switch (Map) {
		case "CNC-Field":
			return "Field";
		case "CNC-Walls_Flying":
			return "Walls";
		case "CNC-GoldRush":
			return "GoldRush";
		case "CNC-Whiteout":
			return "Whiteout";
		case "CNC-Islands":
			return "Islands";
		case "CNC-LakeSide":
			return "LakeSide";
		case "CNC-Mesa_ii":
			return "Mesa II";
		case "CNC-Volcano":
			return "Volcano";
		case "CNC-Xmountain":
			return "XMountain";
		case "CNC-Complex":
			return "Complex";
		case "CNC-Canyon":
			return "Canyon";
		case "CNC-UnderRedux":
			return "Under";
		default:
			GetPC().ClientMessage("WARN: Map not registered yet: " $ Map);
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
}

function SetBuildingGfxObjects()
{
	buildings[0] = GetVariableObject("_root.sb.Stats_GDI.building1");
	buildingsHp[0] = GetVariableObject("_root.sb.Stats_GDI.building1.hp");
	buildingsStatus[0] = GetVariableObject("_root.sb.Stats_GDI.building1.status");	
	buildings[1] = GetVariableObject("_root.sb.Stats_GDI.building2");
	buildingsHp[1] = GetVariableObject("_root.sb.Stats_GDI.building2.hp");
	buildingsStatus[1] = GetVariableObject("_root.sb.Stats_GDI.building2.status");	
	buildings[2] = GetVariableObject("_root.sb.Stats_GDI.building3");
	buildingsHp[2] = GetVariableObject("_root.sb.Stats_GDI.building3.hp");
	buildingsStatus[2] = GetVariableObject("_root.sb.Stats_GDI.building3.status");	
	buildings[3] = GetVariableObject("_root.sb.Stats_GDI.building4");
	buildingsHp[3] = GetVariableObject("_root.sb.Stats_GDI.building4.hp");
	buildingsStatus[3] = GetVariableObject("_root.sb.Stats_GDI.building4.status");	
	buildings[4] = GetVariableObject("_root.sb.Stats_GDI.building5");
	buildingsHp[4] = GetVariableObject("_root.sb.Stats_GDI.building5.hp");
	buildingsStatus[4] = GetVariableObject("_root.sb.Stats_GDI.building5.status");	
	buildings[5] = GetVariableObject("_root.sb.Stats_Nod.building1");
	buildingsHp[5] = GetVariableObject("_root.sb.Stats_Nod.building1.hp");
	buildingsStatus[5] = GetVariableObject("_root.sb.Stats_Nod.building1.status");	
	buildings[6] = GetVariableObject("_root.sb.Stats_Nod.building2");
	buildingsHp[6] = GetVariableObject("_root.sb.Stats_Nod.building2.hp");
	buildingsStatus[6] = GetVariableObject("_root.sb.Stats_Nod.building2.status");	
	buildings[7] = GetVariableObject("_root.sb.Stats_Nod.building3");
	buildingsHp[7] = GetVariableObject("_root.sb.Stats_Nod.building3.hp");
	buildingsStatus[7] = GetVariableObject("_root.sb.Stats_Nod.building3.status");	
	buildings[8] = GetVariableObject("_root.sb.Stats_Nod.building4");
	buildingsHp[8] = GetVariableObject("_root.sb.Stats_Nod.building4.hp");
	buildingsStatus[8] = GetVariableObject("_root.sb.Stats_Nod.building4.status");	
	buildings[9] = GetVariableObject("_root.sb.Stats_Nod.building5");
	buildingsHp[9] = GetVariableObject("_root.sb.Stats_Nod.building5.hp");
	buildingsStatus[9] = GetVariableObject("_root.sb.Stats_Nod.building5.status");	
}

function int SortPriDelegate( coerce PlayerReplicationInfo pri1, coerce PlayerReplicationInfo pri2 )
{
	if (Rx_PRI(pri1) != none && Rx_PRI(pri2) != none)
	{
		if (Rx_PRI(pri1).GetRenScore() > Rx_PRI(pri2).GetRenScore())
		{
			return 1;
		} 
		else if (Rx_PRI(pri1).GetRenScore() == Rx_PRI(pri2).GetRenScore())
		{
			return 0;
		}
		else
		{
			return -1;
		}
	}
	return 0;
}

function PopulateFields(int t,string n,bool mvp,int s,int k,int d, int p)
{
	RootMC.ActionScriptVoid("PopulateFields");
}

function ResetFields()
{
	RootMC.ActionScriptVoid("ResetFields");
}

DefaultProperties
{
	MovieInfo=SwfMovie'RenXScoreboard.RenXScoreboard'
	SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'renxfrontend.Sounds.SoundTheme')
	bHasFadeIn = false;
	bMapVoteInitialized = false;
	bChatInitialized = false;
	//bCaptureInput=true
}
