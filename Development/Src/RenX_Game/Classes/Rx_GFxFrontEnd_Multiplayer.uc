//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Rx_GFxFrontEnd_Multiplayer extends Rx_GFxFrontEnd_View
    config(Menu);

//for getting that server browser
var Rx_Game rxGame;

var Rx_GFXFrontEnd MainFrontEnd;

/************************************
*  Multiplayer                      *
************************************/

var GFxClikWidget MapHeader;
var GFxClikWidget ServerNameHeader;
var GFxClikWidget PlayerHeader;
var GFxClikWidget PingHeader;
var GFxClikWidget ServerList;
var GFxClikWidget ServerScrollBar;


var GFxClikWidget GameplayPresetDropDown;
var GFxClikWidget ServerPlayerSizeDropDown;
var GFxClikWidget FreeSlotsDropDown;
var GFxClikWidget PasswordProtectedDropDown;
var GFxClikWidget RankedDropDown;
var GFxClikWidget NorthAmericaCheckBox;
var GFxClikWidget SouthAmericaCheckBox;
var GFxClikWidget EuropeCheckBox;
var GFxClikWidget AsiaCheckBox;
var GFxClikWidget AfricaCheckBox;
var GFxClikWidget OceniaCheckBox;
var GFxClikWidget MapsCheckBox;
var GFxClikWidget GameCheckBox;
var GFxClikWidget StartingCreditsDropDown;
var GFxClikWidget MineLimitDropDown;
var GFxClikWidget VehicleLimitDropDown;

var GFxClikWidget ServerNameTextInput;
var GFxClikWidget PasswordTextInput;
var GFxClikWidget IPAddressTextInput;
var GFxClikWidget MaxPlayersLabel;
var GFxClikWidget DedicatedServerCheckBox;
var GFxClikWidget ServerAutoRestartCheckBox;
var GFxClikWidget AllowQuickMatchCheckBox;
var GFxClikWidget StartTrackingCheckBox;
var GFxClikWidget AutoBalanceCheckBox;
var GFxClikWidget ManualTeamingCheckBox;
var GFxClikWidget RemixTeamsCheckBox;

var GFxClikWidget SubHostBar;
var GFxClikWidget MineLimitLabel;
var GFxClikWidget DestrolAllCheckBox;
var GFxClikWidget MultiplayerHostActionBar;
var GFxClikWidget MultiplayerServerActionBar;

var bool bRefreshing;

struct MapImageFile
{
	var string mapName;
	var string mapAlias;
	var string mapImageFilename;
};
//var config array <MapImageFile> MapImageList;

function OnViewLoaded(Rx_GFXFrontEnd FrontEnd)
{
	MainFrontEnd = FrontEnd;
	
	rxGame = Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game);
	rxGame.ServiceBrowser.RegisterNotifyDelegate(OnNotifyFromServer);
	rxGame.RegisterPingFinished(OnPingFinished);
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch (WidgetName)
	{
		
		/********************************* [Multiplayer - Server Browser] ***********************************/

		case 'MapHeader':
			if (MapHeader == none || MapHeader != Widget) {
				MapHeader = GFxClikWidget(Widget);
				MapHeader.SetBool("disabled", true);
			}
		case 'ServerNameHeader':
			if (ServerNameHeader == none || ServerNameHeader != Widget) {
				ServerNameHeader = GFxClikWidget(Widget);
				ServerNameHeader.SetBool("disabled", true);
			}
		case 'PlayerHeader':
			if (PlayerHeader == none || PlayerHeader != Widget) {
				PlayerHeader = GFxClikWidget(Widget);
				ServerNameHeader.SetBool("disabled", true);
			}
		case 'PingHeader':
			if (PingHeader == none || PingHeader != Widget) {
				PingHeader = GFxClikWidget(Widget);
				ServerNameHeader.SetBool("disabled", true);
			}
			break;
		case 'ServerList':
			if (ServerList == none || ServerList != Widget) {
				ServerList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ServerList);
			ServerList.AddEventListener('CLIK_itemDoubleClick', OnServerItemDoubleClick);
			break;
		case 'ServerScrollBar':
			if (ServerScrollBar == none || ServerScrollBar != Widget) {
				ServerScrollBar = GFxClikWidget(Widget);
			}

		/************************************* [Multiplayer - Host] *****************************************/
        case 'ServerNameTextInput':
			if (ServerNameTextInput == none || ServerNameTextInput != Widget) {
				ServerNameTextInput = GFxClikWidget(Widget);
			}
            //addeventlistener here
            break;
        case 'PasswordTextInput':
			if (PasswordTextInput == none || PasswordTextInput != Widget) {
				PasswordTextInput = GFxClikWidget(Widget);
			}
            //addeventlistener here
            break;
        case 'IPAddressTextInput':
			if (IPAddressTextInput == none || IPAddressTextInput != Widget) {
				IPAddressTextInput = GFxClikWidget(Widget);
			}
            //addeventlistener here
            break;
        case 'MaxPlayersLabel':
			if (MaxPlayersLabel == none || MaxPlayersLabel != Widget) {
				MaxPlayersLabel = GFxClikWidget(Widget);
			}
            MaxPlayersLabel.SetText(32);
            break;
        case 'DedicatedServerCheckBox':
			if (DedicatedServerCheckBox == none || DedicatedServerCheckBox != Widget) {
				DedicatedServerCheckBox = GFxClikWidget(Widget);
			}
            DedicatedServerCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
        case 'ServerAutoRestartCheckBox':
			if (ServerAutoRestartCheckBox == none || ServerAutoRestartCheckBox != Widget) {
				ServerAutoRestartCheckBox = GFxClikWidget(Widget);
			}
            ServerAutoRestartCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
        case 'AllowQuickMatchCheckBox':
			if (AllowQuickMatchCheckBox == none || AllowQuickMatchCheckBox != Widget) {
				AllowQuickMatchCheckBox = GFxClikWidget(Widget);
			}
            AllowQuickMatchCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
        case 'StartTrackingCheckBox':
			if (StartTrackingCheckBox == none || StartTrackingCheckBox != Widget) {
				StartTrackingCheckBox = GFxClikWidget(Widget);
			}
            StartTrackingCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
        case 'AutoBalanceCheckBox':
			if (AutoBalanceCheckBox == none || AutoBalanceCheckBox != Widget) {
				AutoBalanceCheckBox = GFxClikWidget(Widget);
			}
            AutoBalanceCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
        case 'ManualTeamingCheckBox':
			if (ManualTeamingCheckBox == none || ManualTeamingCheckBox != Widget) {
				ManualTeamingCheckBox = GFxClikWidget(Widget);
			}
            ManualTeamingCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
        case 'RemixTeamsCheckBox':
			if (RemixTeamsCheckBox == none || RemixTeamsCheckBox != Widget) {
				RemixTeamsCheckBox = GFxClikWidget(Widget);
			}
            RemixTeamsCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
        case 'SubHostBar':
			if (SubHostBar == none || SubHostBar != Widget) {
				SubHostBar = GFxClikWidget(Widget);
			}
            SetUpDataProvider(SubHostBar);
            //addeventlistener here
            break;
//        case 'TimeLimitLabel':
//            TimeLimitLabel = GFxClikWidget(Widget);
//            TimeLimitLabel.SetText(25 $" Minutes");
//            //addeventlistener here
//            break;
        case 'MineLimitLabel':
			if (MineLimitLabel == none || MineLimitLabel != Widget) {
				MineLimitLabel = GFxClikWidget(Widget);
			}
            MineLimitLabel.SetText(30);
            //addeventlistener here
            break;
//        case 'VehicleLimitLabel':
//            VehicleLimitLabel = GFxClikWidget(Widget);
//            VehicleLimitLabel.SetText(7);
//            //addeventlistener here
//            break;
        case 'DestrolAllCheckBox':
			if (DestrolAllCheckBox == none || DestrolAllCheckBox != Widget) {
				DestrolAllCheckBox = GFxClikWidget(Widget);
			}
            DestrolAllCheckBox.SetBool("selected", true);
            //addeventlistener here
            break;
//        case 'EndGamePedistalCheckBox':
//            EndGamePedistalCheckBox = GFxClikWidget(Widget);
//            EndGamePedistalCheckBox.SetBool("selected", true);
//            //addeventlistener here
//            break;
//        case 'FriendlyFireCheckBox':
//            FriendlyFireCheckBox = GFxClikWidget(Widget);
//            FriendlyFireCheckBox.SetBool("selected", true);
//            //addeventlistener here
//            break;
//        case 'CanRepairBuildingsCheckBox':
//            CanRepairBuildingsCheckBox = GFxClikWidget(Widget);
//            CanRepairBuildingsCheckBox.SetBool("selected", true);
//            //addeventlistener here
//            break;
        case 'MultiplayerHostActionBar':
			if (MultiplayerHostActionBar == none || MultiplayerHostActionBar != Widget) {
				MultiplayerHostActionBar = GFxClikWidget(Widget);
			}
            MultiplayerHostActionBar = GFxClikWidget(Widget);
            SetUpDataProvider(MultiplayerHostActionBar);
            break;
        case 'MultiplayerServerActionBar':
			if (MultiplayerServerActionBar == none || MultiplayerServerActionBar != Widget) {
				MultiplayerServerActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MultiplayerServerActionBar);
			MultiplayerServerActionBar.AddEventListener('CLIK_itemClick', OnMultiplayerServerActionBarItemClick);
			break;
		default:
			break;
	}
	return false;
}

function string GetMapImageName (string mapFileName) 
{
	local byte i;

	for (i = 0; i < Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList.Length; i++) {
		if (Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList[i].MapName ~= mapFileName) {
			return "img://" $ Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList[i].PreviewImageMarkup;
		}
		
	}
	return "img://RenXFrontEnd.MapImage.___map-pic-missing-cameo";
}

function string GetMapName (string mapFileName) {
	local byte i;
	//local int pos;

	for (i = 0; i < Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList.Length; i++) {
		if (Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList[i].MapName ~= mapFileName) {
			return Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList[i].FriendlyName;
		}
	}
	return mapFileName;
}

function SetUpDataProvider(GFxClikWidget Widget)
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local byte i;


	DataProvider = CreateArray();
	switch(Widget)
	{
		//for getting that server browser
		case (ServerList):
			if (!bRefreshing) {
				Widget.SetInt("rowCount", 0);
				ServerScrollBar.SetVisible(false);
				RefreshServers();
				bRefreshing = true;
			} else {
				if (rxGame.ListServers.Length > 0) {

					for (i = 0; i < rxGame.ListServers.Length; i++) {	

						if (i+1 < 6) {
							Widget.SetInt("rowCount", i+1);
							ServerScrollBar.SetVisible(false);
						} else {
							Widget.SetInt("rowCount", 6);
							ServerScrollBar.SetVisible(true);
						}			

						TempObj = CreateObject("Object");

						TempObj.SetString("mapName", "" $ GetMapName(rxGame.ListServers[i].Mapname));
						TempObj.SetString("mapFileName", "" $ GetMapImageName(rxGame.ListServers[i].Mapname));
						TempObj.SetString("servername", "" $ rxGame.ListServers[i].ServerName);
						TempObj.SetBool("isFavourites", false); //TODO: Parsed from server
						TempObj.SetBool("isLocked", rxGame.ListServers[i].bPassword); //TODO: Parsed from server
						TempObj.SetString("serverLocation", ""); //TODO: Parsed from server
						TempObj.SetString("serverGameType", (rxGame.ListServers[i].Gametype == 0 ? "Command & Conquer" : "Unknown Game Type" ) $ " ("$ rxGame.ListServers[i].GameVersion $")"); //TODO: temp hack for gametype as we only have one at the moment
						TempObj.SetInt("playerCount", rxGame.ListServers[i].NumPlayers);
						TempObj.SetInt("botCount", 0);
						TempObj.SetInt("maxPlayers", rxGame.ListServers[i].MaxPlayers);
						
						if (rxGame.ListServers[i].Ping <= 0)
							TempObj.SetString("ping", "no ping");
						else
							TempObj.SetInt("ping", rxGame.ListServers[i].Ping);

						TempObj.SetString("serverPort", rxGame.ListServers[i].ServerPort);
						TempObj.SetString("serverAddress", rxGame.ListServers[i].ServerIP);

						DataProvider.SetElementObject(i, TempObj);
						MainFrontEnd.OpenFrontEndErrorAlertDialog("INFORMATION", "Fetching Server List Complete.\nNumber of Servers: " $ rxGame.ListServers.Length);
					}
				} else {
					// no data, please empty out the list
					Widget.SetInt("rowCount", 0);
					ServerScrollBar.SetVisible(false);
					MainFrontEnd.OpenFrontEndErrorAlertDialog("INFORMATION", "Fetching Server List Complete.\nNo Server Found!");
				}
				bRefreshing = false;
			}
			break;
        case (GameplayPresetDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "Normal");
            DataProvider.SetElementString(1, "Aggressive");
            DataProvider.SetElementString(2, "Turtler");
            break;
        case (ServerPlayerSizeDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "Small");
            DataProvider.SetElementString(1, "Medium");
            DataProvider.SetElementString(2, "Large");
            break;
        case (FreeSlotsDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "None");
            DataProvider.SetElementString(1, "Any");
            break;
        case (PasswordProtectedDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "Yes");
            DataProvider.SetElementString(1, "No");
            break;
        case (RankedDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "Yes");
            DataProvider.SetElementString(1, "No");
            break;
        case (StartingCreditsDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "0-200");
            DataProvider.SetElementString(1, "200-400");
            DataProvider.SetElementString(2, "400-600");
            DataProvider.SetElementString(3, "600-800");
            DataProvider.SetElementString(4, "800-1000");
            break;
        case (MineLimitDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "0-20");
            DataProvider.SetElementString(1, "20-40");
            DataProvider.SetElementString(2, "40-60");
            DataProvider.SetElementString(3, "60-80");
            DataProvider.SetElementString(4, "80-100");
            break;
        case (VehicleLimitDropDown):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, "Upto7");
            DataProvider.SetElementString(1, "7to10");
            break;
        case (SubHostBar):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, Caps("[ Game Options ]"));
            DataProvider.SetElementString(1, Caps("[ Map Cycle ]]"));
            break;
        case (MultiplayerHostActionBar):
            //hack with graphic presets atm
            DataProvider.SetElementString(0, Caps("Back"));
            DataProvider.SetElementString(1, Caps("Launch"));
            break;
        case (MultiplayerServerActionBar):
			DataProvider.SetElementString(0, Caps("Join"));
			DataProvider.SetElementString(1, Caps("Enter IP"));
			DataProvider.SetElementString(2, Caps("Refresh"));
			break;
        default:
            return;
    }
    Widget.SetObject("dataProvider", DataProvider);
}

function JoinServerGame(int index) {
// 	local string serverIP;
// 	local string serverPort;

	local GFxObject dataProvider;

	local string mapName;
	local string mapFileName;
	local string serverName;
	local bool isLocked;
	local bool isFavourites;
	local string serverLocation;
	local string serverGameType;
	local int playerCount;
	local int maxPlayers;
	local int botCount;
	local int ping;
	local string serverPort;
	local string serverAddress;

	if (ServerList == none) {
		return;
	}

	dataProvider = ServerList.GetObject("dataProvider");
	


	mapName = dataProvider.GetElementMemberString(index, "mapName");
	mapFileName = dataProvider.GetElementMemberString(index, "mapFileName");
	serverName = dataProvider.GetElementMemberString(index, "serverName");
	isFavourites = dataProvider.GetElementMemberBool(index, "isFavourites");
	isLocked = dataProvider.GetElementMemberBool(index, "isLocked");
	serverLocation = dataProvider.GetElementMemberString(index, "serverLocation");
	serverGameType = dataProvider.GetElementMemberString(index, "serverGameType");
	playerCount = dataProvider.GetElementMemberInt(index, "playerCount");
	botCount = dataProvider.GetElementMemberInt(index, "botCount");
	maxPlayers = dataProvider.GetElementMemberInt(index, "maxPlayers");
	ping = dataProvider.GetElementMemberInt(index, "ping");
	serverPort = dataProvider.GetElementMemberString(index, "serverPort");
	serverAddress = dataProvider.GetElementMemberString(index, "serverAddress");

	//The following logs is meant for us devs to check if the server that we're selecting is the correct server, even if we already sort it.
	`log("mapName " $ mapName);
	`log("mapFileName " $ mapFileName);
	`log("serverName " $ serverName);
	`log("isFavourites " $ isFavourites);
	`log("isLocked " $ isLocked);
	`log("serverLocation " $ serverLocation);
	`log("serverGameType " $ serverGameType);
	`log("playerCount " $ playerCount);
	`log("botCount " $ botCount);
	`log("maxPlayers " $ maxPlayers);
	`log("ping " $ ping);
	`log("serverPort " $ serverPort);
	`log("serverAddress " $ serverAddress);


	if (isLocked) {
		OpenEnterPasswordDialog(serverAddress, serverPort);
		return;
	}

	if (serverPort == "") {
		`log("Opening without Port Number");
		`log("[Rx_GFxFrontEnd_Multiplayer] : open " $ serverAddress);
		ConsoleCommand("open "$ serverAddress);
	} else {
		`log("[Rx_GFxFrontEnd_Multiplayer] : open " $ serverAddress $":" $ serverPort);
		ConsoleCommand("open "$ serverAddress $":"$ serverPort);
	}
}

function OpenEnterIPDialog()
{
	MainFrontEnd.OpenEnterIPDialog();
}

function OpenEnterPasswordDialog(string serverIP, string serverPort)
{
	MainFrontEnd.OpenEnterPasswordDialog(serverIP, serverPort);
}

function RefreshServers() {

	if (MapHeader != none) {
		MapHeader.SetBool("disabled", true);
	}
	if (ServerNameHeader != none) {
		ServerNameHeader.SetBool("disabled", true);
	}
	if (PlayerHeader != none) {
		PlayerHeader.SetBool("disabled", true);
	}
	if (PingHeader != none) {
		PingHeader.SetBool("disabled", true);
	}

	rxGame.ListServers.Length = 0;
	rxGame.ServerListRawData = "";
	if (ServerList != none) {
		ServerList.SetInt("rowCount", rxGame.ListServers.Length);
	}
	if (ServerScrollBar != none) {
		ServerScrollBar.SetVisible(false);
	}
	rxGame.ServiceBrowser.GetFromServer();
}

function OnServerItemDoubleClick(GFxClikWidget.EventData ev) {

	//TODO: currently have a log to check the ListItem's data
	`log("[Rx_GFxFrontEnd_Multiplayer] : serverIP: " $ GFxClikWidget(ev._this.GetObject("renderer", class'GFxClikWidget')).GetString("serverAddress") $" | serverPort:" $ GFxClikWidget(ev._this.GetObject("renderer", class'GFxClikWidget')).GetString("serverPort"));
    JoinServerGame(ev.index);
}

function OnMultiplayerServerActionBarItemClick(GFxClikWidget.EventData ev) {

    switch (ev.index)
    {
      case 0: 
      	JoinServerGame(ServerList.GetInt("selectedIndex")); 
      	break;
      case 1: 
      	OpenEnterIPDialog();
      	break;
      case 2: 
      	RefreshServers();
      	break;
		
      default: break;
    }
}

function OnPingFinished(int SrvIndex)
{
 	bRefreshing = true;

	if (SrvIndex >= rxGame.ListServers.Length - 1) {
		MainFrontEnd.CloseProgressDialog();
	} else {
		ShowProgressDialog (float(SrvIndex), float(rxGame.ListServers.Length));
	}	
	SetUpDataProvider(ServerList);

	
	if (MapHeader != none) {
		MapHeader.SetBool("disabled", false);
	}
	if (ServerNameHeader != none) {
		ServerNameHeader.SetBool("disabled", false);
	}
	if (PlayerHeader != none) {
		PlayerHeader.SetBool("disabled", false);
	}
	if (PingHeader != none) {
		PingHeader.SetBool("disabled", false);
	}
}

function ShowProgressDialog (float loaded, float total)
{
	MainFrontEnd.OpenShowProgressDialog(loaded, total);
}

function OnNotifyFromServer() {
	if (ServerList != none) {
		SetUpDataProvider(ServerList);
	}
	if (MapHeader != none) {
		MapHeader.SetBool("disabled", false);
	}
	if (ServerNameHeader != none) {
		ServerNameHeader.SetBool("disabled", false);
	}
	if (PlayerHeader != none) {
		PlayerHeader.SetBool("disabled", false);
	}
	if (PingHeader != none) {
		PingHeader.SetBool("disabled", false);
	}
}

function GetLastSelection(GFxClikWidget Widget)
{
	switch(Widget)
	{
		default:
			return;
	}
}

DefaultProperties
{    
	bRefreshing = false

	SubWidgetBindings.Add((WidgetName="MapHeader", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ServerNameHeader", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PlayerHeader", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PingHeader", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ServerList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ServerScrollBar", WidgetClass=class'GFxClikWidget'))
	
	SubWidgetBindings.Add((WidgetName="GameplayPresetDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="ServerPlayerSizeDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="FreeSlotsDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="PasswordProtectedDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="RankedDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="NorthAmericaCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="SouthAmericaCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="EuropeCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="AsiaCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="AfricaCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="OceniaCheckBox",WidgetClass=class'GFxClikWidget'))
    //maybe need to create a button group for maps and game?
    SubWidgetBindings.Add((WidgetName="MapsCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="GameCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="StartingCreditsDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MineLimitDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="VehicleLimitDropDown",WidgetClass=class'GFxClikWidget'))

    SubWidgetBindings.Add((WidgetName="ServerNameTextInput",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="PasswordTextInput",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="IPAddressTextInput",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MaxPlayersLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="DedicatedServerCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="ServerAutoRestartCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="AllowQuickMatchCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="StartTrackingCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="AutoBalanceCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="ManualTeamingCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="RemixTeamsCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="TimeLimitLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="SubHostBar",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MineLimitLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="VehicleLimitLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="DestrolAllCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="EndGamePedistalCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="FriendlyFireCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="CanRepairBuildingsCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MultiplayerHostActionBar",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MultiplayerServerActionBar",WidgetClass=class'GFxClikWidget'))
}