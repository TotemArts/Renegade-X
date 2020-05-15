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

//Set variables (nBab)
var GFxClikWidget M_ServerNameLabel;
var GFxClikWidget MultiplayerMapImage;
var GFxClikWidget MapLabel;
var GFxClikWidget PlayersLabel;
var GFxClikWidget TimeLimitLabel;
var GFxClikWidget PlayerLimitLabel;
var GFxClikWidget M_MineLimitLabel;
var GFxClikWidget VehicleLimitLabel;
var GFxClikWidget CratesCheckBox;
var GFxClikWidget CratesLabel;
var GFxClikWidget RankedCheckBox;
var GFxClikWidget RankedLabel;
var GFxClikWidget M_AutoBalanceCheckBox;
var GFxClikWidget AutoBalanceLabel;
var GFxClikWidget PasswordRequiredCheckBox;
var GFxClikWidget PasswordRequiredLabel;
var GFxClikWidget MapImageLoader;

var enum EBrowserMode
{
	BrowserMode_Internet,
	BrowserMode_Local
} eMode;

//var bool bRefreshing;

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
	rxGame.NotifyPingFinished = OnPingFinished;
	rxGame.NotifyServerListUpdate = OnNotifyFromServer;

	eMode = EBrowserMode.BrowserMode_Internet;
	
	ActionScriptVoid("validateNow");
	refreshServers();

}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;

	`log("Rx_GFxFrontEnd_Multiplayer::WidgetInitialized"@`showvar(WidgetName),true,'DevGFxUI');

	bWasHandled = false;

	switch (WidgetName)
	{
		
		/********************************* [Multiplayer - Server Browser] ***********************************/

		case 'MapHeader':
			if (MapHeader == none || MapHeader != Widget) {
				MapHeader = GFxClikWidget(Widget);
				MapHeader.SetBool("enabled", false);
			}
			bWasHandled = true;
			break;
		case 'ServerNameHeader':
			if (ServerNameHeader == none || ServerNameHeader != Widget) {
				ServerNameHeader = GFxClikWidget(Widget);
				ServerNameHeader.SetBool("enabled", false);
			}
			bWasHandled = true;
			break;
		case 'PlayerHeader':
			if (PlayerHeader == none || PlayerHeader != Widget) {
				PlayerHeader = GFxClikWidget(Widget);
				ServerNameHeader.SetBool("enabled", false);
			}
			bWasHandled = true;
			break;
		case 'PingHeader':
			if (PingHeader == none || PingHeader != Widget) {
				PingHeader = GFxClikWidget(Widget);
				ServerNameHeader.SetBool("enabled", false);
			}
			bWasHandled = true;
			break;
		case 'ServerList':
			if (ServerList == none || ServerList != Widget) {
				ServerList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ServerList);
			ServerList.AddEventListener('CLIK_itemDoubleClick', OnServerItemDoubleClick);
			//nBab
			ServerList.AddEventListener('CLIK_listIndexChange', OnServerItemClick);
			Widget.SetInt("selectedIndex", -1);
			//Widget.ActionScriptVoid("validateNow");
			bWasHandled = true;
			break;
		case 'ServerScrollBar':
			if (ServerScrollBar == none || ServerScrollBar != Widget) {
				ServerScrollBar = GFxClikWidget(Widget);
			}
			bWasHandled = true;
			break;
		case 'M_ServerNameLabel':
			if (M_ServerNameLabel == none || M_ServerNameLabel != Widget) {
				M_ServerNameLabel = GFxClikWidget(Widget);
			}
			M_ServerNameLabel.SetVisible(false);
			bWasHandled = true;
			break;
		/*case 'MultiplayerMapImage':
			if (MultiplayerMapImage == none || MultiplayerMapImage != Widget) {
				MultiplayerMapImage = GFxClikWidget(Widget);
			}
			MultiplayerMapImage.SetVisible(false);
			`log ("nbab = "$MultiplayerMapImage.GetObject("border"));
			bWasHandled = true;
			break;*/
		case 'MapLabel':
			if (MapLabel == none || MapLabel != Widget) {
				MapLabel = GFxClikWidget(Widget);
			}
			MapLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'PlayersLabel':
			if (PlayersLabel == none || PlayersLabel != Widget) {
				PlayersLabel = GFxClikWidget(Widget);
			}
			PlayersLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'TimeLimitLabel':
			if (TimeLimitLabel == none || TimeLimitLabel != Widget) {
				TimeLimitLabel = GFxClikWidget(Widget);
			}
			TimeLimitLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'PlayerLimitLabel':
			if (PlayerLimitLabel == none || PlayerLimitLabel != Widget) {
				PlayerLimitLabel = GFxClikWidget(Widget);
			}
			PlayerLimitLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'M_MineLimitLabel':
			if (M_MineLimitLabel == none || M_MineLimitLabel != Widget) {
				M_MineLimitLabel = GFxClikWidget(Widget);
			}
			M_MineLimitLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'VehicleLimitLabel':
			if (VehicleLimitLabel == none || VehicleLimitLabel != Widget) {
				VehicleLimitLabel = GFxClikWidget(Widget);
			}
			VehicleLimitLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'CratesCheckBox':
			if (CratesCheckBox == none || CratesCheckBox != Widget) {
				CratesCheckBox = GFxClikWidget(Widget);
			}
			CratesCheckBox.SetBool("enabled",false);
			CratesCheckBox.SetVisible(false);
			bWasHandled = true;
			break;
		case 'CratesLabel':
			if (CratesLabel == none || CratesLabel != Widget) {
				CratesLabel = GFxClikWidget(Widget);
			}
			CratesLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'RankedCheckBox':
			if (RankedCheckBox == none || RankedCheckBox != Widget) {
				RankedCheckBox = GFxClikWidget(Widget);
			}
			RankedCheckBox.SetBool("enabled",false);
			RankedCheckBox.SetVisible(false);
			bWasHandled = true;
			break;
		case 'RankedLabel':
			if (RankedLabel == none || RankedLabel != Widget) {
				RankedLabel = GFxClikWidget(Widget);
			}
			RankedLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'M_AutoBalanceCheckBox':
			if (M_AutoBalanceCheckBox == none || M_AutoBalanceCheckBox != Widget) {
				M_AutoBalanceCheckBox = GFxClikWidget(Widget);
			}
			M_AutoBalanceCheckBox.SetBool("enabled",false);
			M_AutoBalanceCheckBox.SetVisible(false);
			bWasHandled = true;
			break;
		case 'AutoBalanceLabel':
			if (AutoBalanceLabel == none || AutoBalanceLabel != Widget) {
				AutoBalanceLabel = GFxClikWidget(Widget);
			}
			AutoBalanceLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'PasswordRequiredCheckBox':
			if (PasswordRequiredCheckBox == none || PasswordRequiredCheckBox != Widget) {
				PasswordRequiredCheckBox = GFxClikWidget(Widget);
			}
			PasswordRequiredCheckBox.SetBool("enabled",false);
			PasswordRequiredCheckBox.SetVisible(false);
			bWasHandled = true;
			break;
		case 'PasswordRequiredLabel':
			if (PasswordRequiredLabel == none || PasswordRequiredLabel != Widget) {
				PasswordRequiredLabel = GFxClikWidget(Widget);
			}
			PasswordRequiredLabel.SetVisible(false);
			bWasHandled = true;
			break;
		case 'MapImageLoader':
			if (MapImageLoader == none || MapImageLoader != Widget) {
				MapImageLoader = GFxClikWidget(Widget);
			}
			MapImageLoader.SetVisible(false);
			MapImageLoader.GetObject("parent").GetObject("border").SetVisible(false);
			bWasHandled = true;
			break;

		/************************************* [Multiplayer - Host] *****************************************/
        case 'ServerNameTextInput':
			if (ServerNameTextInput == none || ServerNameTextInput != Widget) {
				ServerNameTextInput = GFxClikWidget(Widget);
			}
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'PasswordTextInput':
			if (PasswordTextInput == none || PasswordTextInput != Widget) {
				PasswordTextInput = GFxClikWidget(Widget);
			}
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'IPAddressTextInput':
			if (IPAddressTextInput == none || IPAddressTextInput != Widget) {
				IPAddressTextInput = GFxClikWidget(Widget);
			}
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'MaxPlayersLabel':
			if (MaxPlayersLabel == none || MaxPlayersLabel != Widget) {
				MaxPlayersLabel = GFxClikWidget(Widget);
			}
            MaxPlayersLabel.SetText(32);
			bWasHandled = true;
            break;
        case 'DedicatedServerCheckBox':
			if (DedicatedServerCheckBox == none || DedicatedServerCheckBox != Widget) {
				DedicatedServerCheckBox = GFxClikWidget(Widget);
			}
            DedicatedServerCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'ServerAutoRestartCheckBox':
			if (ServerAutoRestartCheckBox == none || ServerAutoRestartCheckBox != Widget) {
				ServerAutoRestartCheckBox = GFxClikWidget(Widget);
			}
            ServerAutoRestartCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'AllowQuickMatchCheckBox':
			if (AllowQuickMatchCheckBox == none || AllowQuickMatchCheckBox != Widget) {
				AllowQuickMatchCheckBox = GFxClikWidget(Widget);
			}
            AllowQuickMatchCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'StartTrackingCheckBox':
			if (StartTrackingCheckBox == none || StartTrackingCheckBox != Widget) {
				StartTrackingCheckBox = GFxClikWidget(Widget);
			}
            StartTrackingCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'AutoBalanceCheckBox':
			if (AutoBalanceCheckBox == none || AutoBalanceCheckBox != Widget) {
				AutoBalanceCheckBox = GFxClikWidget(Widget);
			}
            AutoBalanceCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'ManualTeamingCheckBox':
			if (ManualTeamingCheckBox == none || ManualTeamingCheckBox != Widget) {
				ManualTeamingCheckBox = GFxClikWidget(Widget);
			}
            ManualTeamingCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'RemixTeamsCheckBox':
			if (RemixTeamsCheckBox == none || RemixTeamsCheckBox != Widget) {
				RemixTeamsCheckBox = GFxClikWidget(Widget);
			}
            RemixTeamsCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
        case 'SubHostBar':
			if (SubHostBar == none || SubHostBar != Widget) {
				SubHostBar = GFxClikWidget(Widget);
			}
            SetUpDataProvider(SubHostBar);
            //addeventlistener here
			bWasHandled = true;
            break;
//        case 'TimeLimitLabel':
//            TimeLimitLabel = GFxClikWidget(Widget);
//            TimeLimitLabel.SetText(25 $" Minutes");
//            //addeventlistener here
//			bWasHandled = true;
//            break;
        case 'MineLimitLabel':
			if (MineLimitLabel == none || MineLimitLabel != Widget) {
				MineLimitLabel = GFxClikWidget(Widget);
			}
            MineLimitLabel.SetText(30);
            //addeventlistener here
			bWasHandled = true;
            break;
//        case 'VehicleLimitLabel':
//            VehicleLimitLabel = GFxClikWidget(Widget);
//            VehicleLimitLabel.SetText(7);
//            //addeventlistener here
//			bWasHandled = true;
//            break;
        case 'DestrolAllCheckBox':
			if (DestrolAllCheckBox == none || DestrolAllCheckBox != Widget) {
				DestrolAllCheckBox = GFxClikWidget(Widget);
			}
            DestrolAllCheckBox.SetBool("selected", true);
            //addeventlistener here
			bWasHandled = true;
            break;
//        case 'EndGamePedistalCheckBox':
//            EndGamePedistalCheckBox = GFxClikWidget(Widget);
//            EndGamePedistalCheckBox.SetBool("selected", true);
//            //addeventlistener here
//			bWasHandled = true;
//            break;
//        case 'FriendlyFireCheckBox':
//            FriendlyFireCheckBox = GFxClikWidget(Widget);
//            FriendlyFireCheckBox.SetBool("selected", true);
//            //addeventlistener here
//			bWasHandled = true;
//            break;
//        case 'CanRepairBuildingsCheckBox':
//            CanRepairBuildingsCheckBox = GFxClikWidget(Widget);
//            CanRepairBuildingsCheckBox.SetBool("selected", true);
//            //addeventlistener here
//			bWasHandled = true;
//            break;
        case 'MultiplayerHostActionBar':
			if (MultiplayerHostActionBar == none || MultiplayerHostActionBar != Widget) {
				MultiplayerHostActionBar = GFxClikWidget(Widget);
			}
            MultiplayerHostActionBar = GFxClikWidget(Widget);
            SetUpDataProvider(MultiplayerHostActionBar);
			bWasHandled = true;
            break;
        case 'MultiplayerServerActionBar':
			if (MultiplayerServerActionBar == none || MultiplayerServerActionBar != Widget) {
				MultiplayerServerActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MultiplayerServerActionBar);
			MultiplayerServerActionBar.AddEventListener('CLIK_buttonPress', OnMultiplayerServerActionBarItemClick);
			bWasHandled = true;
			break;
		default:
			break;
	}
	return bWasHandled;
}

function string GetMapImageName (string mapFileName) 
{
	local byte i;

	for (i = 0; i < Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList.Length; i++) {
		if (Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList[i].MapName ~= mapFileName) {
			return Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList[i].PreviewImageMarkup;
		}
		
	}
	return "RenXFrontEnd.MapImage.___map-pic-missing-cameo";
}

function string GetMapName (string mapFileName)
{
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
	local int itemCount;

	`log("Rx_GFxFrontEnd_Multiplayer::SetupDataProvider"@Widget.GetString("name"),true,'DevGFxUI');

	DataProvider = CreateObject("scaleform.clik.data.DataProvider");
	switch(Widget)
	{
		//for getting that server browser
		case (ServerList):
			if (rxGame.ListServers.Length > 0) {
				Widget.SetBool("enabled", true);

				itemCount = 0;

				for (i = 0; i < rxGame.ListServers.Length; i++) {	

					//only add servers relevant to the current ui browser mode.
					if((eMode == eBrowserMode.BrowserMode_Internet && rxGame.ListServers[i].isLAN == true) ||
						(eMode == eBrowserMode.BrowserMode_Local && rxGame.ListServers[i].isLAN == false))
						continue;

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
					TempObj.SetBool("isRanked", rxGame.ListServers[i].Ranked); //TODO: Parsed from server
					TempObj.SetString("serverLocation", ""); //TODO: Parsed from server
					TempObj.SetString("serverGameType", (rxGame.ListServers[i].Gametype == 1 ? "Command & Conquer" : "Unknown Game Type" ) $ " ("$ rxGame.ListServers[i].GameVersion $")"); //TODO: temp hack for gametype as we only have one at the moment
					TempObj.SetInt("playerCount", rxGame.ListServers[i].NumPlayers);
					TempObj.SetInt("botCount", 0);
					TempObj.SetInt("maxPlayers", rxGame.ListServers[i].MaxPlayers);
						
					TempObj.SetInt("ping", rxGame.ListServers[i].Ping);

					TempObj.SetString("serverPort", rxGame.ListServers[i].ServerPort);
					TempObj.SetString("serverAddress", rxGame.ListServers[i].ServerIP);

					//nBab
					TempObj.SetInt("VehicleLimit",rxGame.ListServers[i].VehicleLimit);
					TempObj.SetInt("MineLimit",rxGame.ListServers[i].MineLimit);
					TempObj.SetInt("TimeLimit",rxGame.ListServers[i].TimeLimit);
					TempObj.SetBool("CratesEnabled",rxGame.ListServers[i].CratesEnabled);
					TempObj.SetBool("Autobalanced",rxGame.ListServers[i].TeamMode == 3); // Needs to be replaced

					DataProvider.SetElementObject(itemCount, TempObj);
					++itemCount;
				}
			}
			else
			{				
				Widget.SetBool("enabled", false);
				return;
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

			TempObj = CreateObject("Object");
			TempObj.SetString("label", "JOIN");
			TempObj.SetString("action", "join");
			DataProvider.SetElementObject(0, TempObj);
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "Enter IP");
			TempObj.SetString("action", "ip");
			DataProvider.SetElementObject(1, TempObj);
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "REFRESH");
			TempObj.SetString("action", "refresh");
			DataProvider.SetElementObject(2, TempObj);
			break;
        default:
            return;
    }
    Widget.SetObject("dataProvider", DataProvider);
}

function JoinServerGame(int index)
{
// 	local string serverIP;
// 	local string serverPort;

	local GFxObject dataProvider;

	local string mapName;
	local string mapFileName;
	local string serverName;
	local bool isLocked;
	local bool isRanked;
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
	isRanked = dataProvider.GetElementMemberBool(index, "isRanked");
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
	`log("isRanked " $ isRanked);
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

	`RxGameObject.LANBroadcast.Close();

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

function RefreshServers()
{

	//bRefreshing = true;

	if (MapHeader != none) {
		MapHeader.SetBool("enabled", false);
	}
	if (ServerNameHeader != none) {
		ServerNameHeader.SetBool("enabled", false);
	}
	if (PlayerHeader != none) {
		PlayerHeader.SetBool("enabled", false);
	}
	if (PingHeader != none) {
		PingHeader.SetBool("enabled", false);
	}

	`Logd(`Location@"Clearing server list variables",,'DevNet');

	rxGame.ListServers.Length = 0;
	`RxEngineObject.DllCore.clear_pings();
	//rxGame.ServerListRawData = "";

	if (ServerList != none) {
		ServerList.SetInt("rowCount", rxGame.ListServers.Length);
	}
	if (ServerScrollBar != none) {
		ServerScrollBar.SetVisible(false);
	}

	if(eMode == BrowserMode_Internet)
		rxGame.ServiceBrowser.GetFromServer();
}

function OnServerItemDoubleClick(GFxClikWidget.EventData ev)
{

	//TODO: currently have a log to check the ListItem's data
    JoinServerGame(ev._this.GetInt("index"));
}

//nBab
function OnServerItemClick(GFxClikWidget.EventData ev)
{

	local GFxObject dataProvider;
	local texture2D mapImage;

	local string mapName;
	local string mapFileName;
	local string serverName;
	local bool isLocked;
	local bool isRanked;
	//local bool isFavourites;
	//local string serverLocation;
	//local string serverGameType;
	local int playerCount;
	local int maxPlayers;
	//local int botCount;
	//local int ping;
	local int VehicleLimit;
	local int MineLimit;
	local int TimeLimit;
	local bool CratesEnabled;
	local bool Autobalanced;

	if (ServerList == none) {
		return;
	}

	dataProvider = ServerList.GetObject("dataProvider");
	

	mapName = dataProvider.GetElementMemberString(ev._this.GetInt("index"), "mapName");
	mapFileName = dataProvider.GetElementMemberString(ev._this.GetInt("index"), "mapFileName");
	serverName = dataProvider.GetElementMemberString(ev._this.GetInt("index"), "servername");
	//isFavourites = dataProvider.GetElementMemberBool(ev._this.GetInt("index"), "isFavourites");
	isLocked = dataProvider.GetElementMemberBool(ev._this.GetInt("index"), "isLocked");
	isRanked = dataProvider.GetElementMemberBool(ev._this.GetInt("index"), "isRanked");
	//serverLocation = dataProvider.GetElementMemberString(ev._this.GetInt("index"), "serverLocation");
	//serverGameType = dataProvider.GetElementMemberString(ev._this.GetInt("index"), "serverGameType");
	playerCount = dataProvider.GetElementMemberInt(ev._this.GetInt("index"), "playerCount");
	//botCount = dataProvider.GetElementMemberInt(ev._this.GetInt("index"), "botCount");
	maxPlayers = dataProvider.GetElementMemberInt(ev._this.GetInt("index"), "maxPlayers");
	//ping = dataProvider.GetElementMemberInt(ev._this.GetInt("index"), "ping");
	
	VehicleLimit = dataProvider.GetElementMemberInt(ev._this.GetInt("index"), "VehicleLimit");
	MineLimit = dataProvider.GetElementMemberInt(ev._this.GetInt("index"), "MineLimit");
	TimeLimit = dataProvider.GetElementMemberInt(ev._this.GetInt("index"), "TimeLimit");
	CratesEnabled = dataProvider.GetElementMemberBool(ev._this.GetInt("index"), "CratesEnabled");
	Autobalanced = dataProvider.GetElementMemberBool(ev._this.GetInt("index"), "Autobalanced");
	
	if(ServerList.GetInt("selectedIndex") != -1)
		SetServerDetailsVisibility(true);

	M_ServerNameLabel.SetText(serverName);
	mapImage = texture2d(DynamicLoadObject(mapFileName, class'texture2d', true));
	if(mapImage == none)
		MapImageLoader.SetString("source", "img://RenXFrontEnd.MapImage.___map-pic-missing-cameo");
	else
	{
		MapImageLoader.SetString("source", "img://"$mapFileName);
	}
	MapLabel.SetText("Map:  "$mapName);
	PlayersLabel.SetText("Players:  "$playerCount);
	if (TimeLimit == 0)
		TimeLimitLabel.SetText("Time Limit:  Unlimited");
	else
		TimeLimitLabel.SetText("Time Limit:  "$TimeLimit$" Minutes");
	PlayerLimitLabel.SetText("Player Limit:  "$maxPlayers);
	M_MineLimitLabel.SetText("Mine Limit:  "$MineLimit);
	VehicleLimitLabel.SetText("Vehicle Limit:  "$VehicleLimit);
	CratesCheckBox.SetBool("selected",CratesEnabled);
	RankedCheckBox.SetBool("selected",isRanked);
	M_AutoBalanceCheckBox.SetBool("selected",Autobalanced);
	PasswordRequiredCheckBox.SetBool("selected",isLocked);
}

function SetServerDetailsVisibility(bool state)
{
	M_ServerNameLabel.SetVisible(state);
	//MultiplayerMapImage.SetVisible(state);
	MapLabel.SetVisible(state);
	PlayersLabel.SetVisible(state);
	TimeLimitLabel.SetVisible(state);
	PlayerLimitLabel.SetVisible(state);
	M_MineLimitLabel.SetVisible(state);
	VehicleLimitLabel.SetVisible(state);
	CratesCheckBox.SetVisible(state);
	RankedCheckBox.SetVisible(state);
	CratesLabel.SetVisible(state);
	RankedLabel.SetVisible(state);
	M_AutoBalanceCheckBox.SetVisible(state);
	AutoBalanceLabel.SetVisible(state);
	PasswordRequiredCheckBox.SetVisible(state);
	PasswordRequiredLabel.SetVisible(state);
	MapImageLoader.SetVisible(state);
	MapImageLoader.GetObject("parent").GetObject("border").SetVisible(state);

}

function OnMultiplayerServerActionBarItemClick(GFxClikWidget.EventData ev)
{

    switch (ev._this.GetObject("target").GetObject("data").GetString("action"))
    {
      case "join": 
      	JoinServerGame(ServerList.GetInt("selectedIndex")); 
      	break;
      case "ip": 
      	OpenEnterIPDialog();
      	break;
      case "refresh": 
      	RefreshServers();
      	break;
		 
      default: break;
    }
}

function OnPingFinished()
{

 	//bRefreshing = true;

	`Entry(,'DevNet');

	SetUpDataProvider(ServerList);
	ServerList.ActionScriptVoid("validateNow");

	
	if (MapHeader != none) {
		MapHeader.SetBool("enabled", true);
	}
	if (ServerNameHeader != none) {
		ServerNameHeader.SetBool("enabled", true);
	}
	if (PlayerHeader != none) {
		PlayerHeader.SetBool("enabled", true);
	}
	if (PingHeader != none) {
		PingHeader.SetBool("enabled", true);
	}
}

function ShowProgressDialog (float loaded, float total)
{
	MainFrontEnd.OpenShowProgressDialog(loaded, total);
}

function OnNotifyFromServer()
{
	`Entry(,'DevNetTraffic');

	`RxGameObject.StartPings();

	if (ServerList != none) {
		SetUpDataProvider(ServerList);
		ServerList.ActionScriptVoid("validateNow");
	}
	if (MapHeader != none) {
		MapHeader.SetBool("enabled", true);
	}
	if (ServerNameHeader != none) {
		ServerNameHeader.SetBool("enabled", true);
	}
	if (PlayerHeader != none) {
		PlayerHeader.SetBool("enabled", true);
	}
	if (PingHeader != none) {
		PingHeader.SetBool("enabled", true);
	}

	//`Exit(,,'DevNetTraffic');
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
	//bRefreshing = false

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

    //nBab
	SubWidgetBindings.Add((WidgetName="M_ServerNameLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MultiplayerMapImage",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MapLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PlayersLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="TimeLimitLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PlayerLimitLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="M_MineLimitLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="VehicleLimitLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CratesCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="RankedCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="RankedLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CratesLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="M_AutoBalanceCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AutoBalanceLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PasswordRequiredCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PasswordRequiredLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MapImageLoader",WidgetClass=class'GFxClikWidget'))
}