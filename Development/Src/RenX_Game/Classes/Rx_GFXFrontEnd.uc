class Rx_GFXFrontEnd extends GFxMoviePlayer;


var UIDataStore_Registry Registry;
var Rx_SystemSettingsHandler SystemSettingsHandler;

var Rx_Jukebox JukeBox;

/**@Shahman: Retrieves the Graphic Adapter name for the user*/
var Rx_GraphicAdapterCheck GraphicAdapterCheck;

var bool HasRunOnce;

/**@Shahman: Cache button bar's selected button into our variable.*/
var GFxObject CurrentSelectedButton;


var GFxObject RootMC;
var GFxObject DialogContainer;
var GFxObject MenuSubTitleLabel;
var GFxObject GameVersionLabel;

//Main Menu
var GFxClikWidget MainMenuView;
var GFxClikWidget MainMenuBar;
var GFxClikWidget PlayerProfileLabel;
var GFxClikWidget ChangeUserButton;

var GFxClikWidget MultiplayerBar;
var Rx_GFxFrontEnd_Multiplayer MultiplayerView;
var GFxClikWidget SettingsBar;
var Rx_GFxFrontEnd_Settings SettingsView;
var GFxClikWidget SkirmishBar;
var Rx_GFxFrontEnd_Skirmish SkirmishView;
var GFxClikWidget ExtrasBar;
var Rx_GFxFrontEnd_Extras ExtrasView;

var GFxObject viewToCache;

var GFxClikWidget ProgressDialogInstance;
var GFxClikWidget DownloadProgressDialogInstance;

var string StoredServerIP;
var string StoredServerPort;

/** Called on start **/
function bool Start (optional bool StartPaused = false)
{
	local bool retVal;

	RunOnce();

	// CaptureBindIndex = -1;
	retVal = super.Start();
	Advance(0);
	Rx_Game(GetPC().WorldInfo.Game).VQueryHandler.NotifyDelegate = isGameOutOfDate;

	//now set inside the flash movie
	//SetAlignment(Align_Center);
	//SetViewScaleMode(SM_ShowAll);



	RootMC = GetVariableObject("root");
	//DialogContainer = GetVariableObject("root.DialogContainer");
	MenuSubTitleLabel = GetVariableObject("root.manager.MainMenuContainer.MainMenu.MenuSubTitleLabel");
	MenuSubTitleLabel.SetText(Caps("Welcome to Renegade-X"));

	CheckForErrorMessages();
	Rx_GameViewportClient(GetGameViewportClient()).FrontEnd = self;

	return retVal;
}


/** Trace flash log ingame */
function GfxTraceLog (string message) 
{
	`log("GfxLog [" $ MovieInfo.Name $"] : " $ message);
	GetPC().ClientMessage("GFxTraceLog: " $ message);
}

function OnClose() 
{
	if (SystemSettingsHandler != none) {
		SystemSettingsHandler.Destroy();
		SystemSettingsHandler = none;
	}
	if (GraphicAdapterCheck != none) {
		GraphicAdapterCheck.Destroy();
		GraphicAdapterCheck = none;
	}
	
 	//GetPC().WorldInfo.MusicComp.Stop();

	if (JukeBox != none) {
		JukeBox.MusicComp.ResetToDefaults();
		JukeBox.MusicComp.bAutoDestroy = true;
		JukeBox.MusicComp.Stop();
	}
	
	super.OnClose();
}

function OnVersionOutOfDate()
{
	OpenVersionOutOfDateDialog();
}

/* Use Rx_VersionQueryHandler and check if there's a newer client update available. */
function isGameOutOfDate()
{
	local Rx_Game RxG;
	RxG = Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game);

	if(RxG.VQueryHandler.MasterVersionURL == "")
		return;

	if(RxG.VQueryHandler.QueryedVersionNumber != 0)
	{
		if(RxG.VQueryHandler.QueryedVersionNumber != RxG.GameVersionNumber)
			OpenVersionOutOfDateDialog();
		else
			return;
	}
}

function RunOnce()
{
	if (HasRunOnce == false)
	{
		if (SystemSettingsHandler == none) {
			SystemSettingsHandler = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_SystemSettingsHandler');
		}
		SystemSettingsHandler.SetSettingBucket(SystemSettingsHandler.GraphicsPresetLevel);
		SystemSettingsHandler.PopulateSystemSettings();
		SystemSettingsHandler.SetAAType(SystemSettingsHandler.CurrentAAType);
		SystemSettingsHandler.SetGammaSettings(SystemSettingsHandler.GetGammaSettings());
		SystemSettingsHandler.SetFOV(SystemSettingsHandler.DefaultFOV); 
		SystemSettingsHandler.SetAmbientOcclusion(SystemSettingsHandler.AmbientOcclusion);
		SystemSettingsHandler.SetEnableSmoothFramerate(SystemSettingsHandler.GetEnableSmoothFramerate());
		SystemSettingsHandler.SetDisablePhysXHardwareSupport(SystemSettingsHandler.GetDisablePhysXHardwareSupport());
		SystemSettingsHandler.SetBloomThreshold(SystemSettingsHandler.BloomThresholdLevel);

		if (GraphicAdapterCheck == none) {
			GraphicAdapterCheck = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_GraphicAdapterCheck');
			GraphicAdapterCheck.CheckGraphicAdapter();
		}


		if (JukeBox == none) {
			JukeBox = new class'Rx_Jukebox';
			JukeBox.Init();

			//Disable this if we do not want to play on start.
			//JukeBox.Play(0);
		}
		if (GetPC().WorldInfo.MusicComp != none) {
			JukeBox.CurrentTrack.TheSoundCue = GetPC().WorldInfo.MusicComp.SoundCue;
			JukeBox.CurrentTrack.TrackName = "Main Menu";
		}

		//Load our Audio Settings
		GetPC().SetAudioGroupVolume('UI', SystemSettingsHandler.UIVolume);
		GetPC().SetAudioGroupVolume('Item', SystemSettingsHandler.ItemVolume);
		GetPC().SetAudioGroupVolume('Vehicle', SystemSettingsHandler.VehicleVolume);
		GetPC().SetAudioGroupVolume('Weapon', SystemSettingsHandler.WeaponVolume);
		GetPC().SetAudioGroupVolume('SFX', SystemSettingsHandler.SFXVolume);
		GetPC().SetAudioGroupVolume('Character', SystemSettingsHandler.CharacterVolume);
		GetPC().SetAudioGroupVolume('Music', SystemSettingsHandler.MusicVolume);
		GetPC().SetAudioGroupVolume('Announcer', SystemSettingsHandler.AnnouncerVolume);
		GetPC().SetAudioGroupVolume('MovieVoice', SystemSettingsHandler.MovieVoiceVolume);
		GetPC().SetAudioGroupVolume('WeaponBulletEffects', SystemSettingsHandler.WeaponBulletEffectsVolume);
		GetPC().SetAudioGroupVolume('OptionVoice', SystemSettingsHandler.OptionVoiceVolume);
		GetPC().SetAudioGroupVolume('MovieEffects', SystemSettingsHandler.MovieEffectsVolume);
		GetPC().SetAudioGroupVolume('Ambient', SystemSettingsHandler.AmbientVolume);
		GetPC().SetAudioGroupVolume('UnGrouped', SystemSettingsHandler.UnGroupedVolume);
		GetPC().SetAudioGroupVolume('Voice', SystemSettingsHandler.CharacterVolume);
		
		HasRunOnce = true;

	}
}

function CheckForErrorMessages()
{
	local string frontEndErrorTitle, frontEndErrorMessage;
	Registry = UIDataStore_Registry(class'UIRoot'.static.StaticResolveDataStore('Registry'));
	Registry.GetData("FrontEndError_Message", frontEndErrorMessage);
    Registry.GetData("FrontEndError_Title", frontEndErrorTitle);

	if (frontEndErrorTitle != "" || frontEndErrorMessage != "") {
		OpenFrontEndErrorAlertDialog(frontEndErrorTitle,frontEndErrorMessage);
	}

	//reset eror message variables after opening the dialog so they don't show up next time (nBab)
	Registry.SetData("FrontEndError_Message", "");
    Registry.SetData("FrontEndError_Title", "");
}

protected function precache(array<string> a)
{
	viewToCache.ActionScriptVoid("precache");
}

protected function setupPrecache(GFxObject bar, GFxObject view)
{
	local GFxObject TempData;
	local int i;
	local array<string> arrViews;

	if(bar != none && view != none)
	{
		TempData = bar.GetObject("dataProvider");
		for (i = 0; i < TempData.GetInt("length"); i++)
		{
			arrViews.AddItem(TempData.GetElementMemberString(i, "data"));
		}
	
		viewToCache = view;
		precache(arrViews);

		if(Rx_GFxFrontEnd_View(view) != None)
			Rx_GFxFrontEnd_View(view).SetupMenu();
	}
	
}

/** Called when a CLIK Widget is initialized **/
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;

	`log("Rx_GFxFrontEnd::WidgetInitialized"@`showvar(WidgetName),true,'DevGFxUI');

	bWasHandled = false;

	switch (WidgetName)
	{
		/****************************
		*  Main Scene               *
		****************************/
		case 'MainMenuBar':
			if (MainMenuBar == none || MainMenuBar != Widget) {
				MainMenuBar = GFxClikWidget(Widget);
			}
//			SetUpDataProvider(MainMenuBar);
			MainMenuBar.AddEventListener('CLIK_clikIndexChange', OnMainMenuBarChange);
			MainMenuBar.SetInt("selectedIndex", -1);
			if(MainMenuView != none)
				setupPrecache(MainMenuBar, MainMenuView);
			bWasHandled = true;
			break;
		case 'MainMenuView':
			if (MainMenuView == none || MainMenuView != Widget) {
				MainMenuView = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MainMenuView);
			if(MainMenuBar != none)
				setupPrecache(MainMenuBar, MainMenuView);
			bWasHandled = true;
			break;
		case 'PlayerProfileLabel':
			if (PlayerProfileLabel == none || PlayerProfileLabel != Widget) {
				PlayerProfileLabel = GFxClikWidget(Widget);
			}
			PlayerProfileLabel.SetText("|  LOGGED IN: "$ Caps(GetPC().PlayerReplicationInfo.PlayerName) $"  |");
			bWasHandled = true;
			break;
		case 'ChangeUserButton':
			if (ChangeUserButton == none || ChangeUserButton != Widget) {
				ChangeUserButton = GFxClikWidget(Widget);
			}
			ChangeUserButton.AddEventListener('CLIK_press', OnChangeUserButtonClik);
			ChangeUserButton.SetVisible(false); //Hack for the time being
			bWasHandled = true;
			break;
		case 'GameVersionLabel':
			if (GameVersionLabel == none || GameVersionLabel != Widget) {
				GameVersionLabel = GFxClikWidget(Widget);
			}
			//GameVersionLabel.SetString("text", "| "$ Caps(Rx_Game(GetPC().WorldInfo.Game).GameVersion) $" |");
			GameVersionLabel.SetString("text", "| " $ Rx_Game(GetPC().WorldInfo.Game).GameVersion $ " |");
			bWasHandled = true;
			break;
		case 'SkirmishBar':
			if (SkirmishBar == none || SkirmishBar != Widget) {
				SkirmishBar = GFxClikWidget(Widget);
			}
//			SetUpDataProvider(SkirmishBar);
			SkirmishBar.SetInt("selectedIndex", 0);
			if(SkirmishView != none)
				setupPrecache(SkirmishBar, SkirmishView);
			bWasHandled = true;
			break;
		case 'SkirmishView':
			if (SkirmishView == none || SkirmishView != Widget) {
				SkirmishView = Rx_GFxFrontEnd_Skirmish(Widget);
			}
			`log("Rx_GFxFrontEnd::Loading SkirmishView",true,'GFxUI');
			SetWidgetPathBinding(SkirmishView, WidgetPath);
			SkirmishView.OnViewLoaded(self);
			if(SkirmishBar != none)
				setupPrecache(SkirmishBar, SkirmishView);
			bWasHandled = true;
			break;
		case 'SettingsBar':
			if (SettingsBar == none || SettingsBar != Widget) {
				SettingsBar = GFxClikWidget(Widget);
			}
//			SetUpDataProvider(SettingsBar);
			SettingsBar.SetInt("selectedIndex", 0);
			if(SettingsView != none)
				setupPrecache(SettingsBar, SettingsView);
			bWasHandled = true;
			break;
		case 'SettingsView':
			if (SettingsView == none || SettingsView != Widget) {
				SettingsView = Rx_GFxFrontEnd_Settings(Widget);
			}
			`log("Rx_GFxFrontEnd::Loading SettingsView",true,'GFxUI');
			SetWidgetPathBinding(SettingsView, WidgetPath);
			SettingsView.OnViewLoaded(self);
			if(SettingsBar != none)
			{
				setupPrecache(SettingsBar, SettingsView);
			}
			bWasHandled = true;
			break;
		case 'MultiplayerBar':
			if (MultiplayerBar == none || MultiplayerBar != Widget) {
				MultiplayerBar = GFxClikWidget(Widget);
			}
//			SetUpDataProvider(MultiplayerBar);
			MultiplayerBar.SetInt("selectedIndex", 0);
			if(MultiplayerView != none)
				setupPrecache(MultiplayerBar, MultiplayerView);
			MultiplayerBar.AddEventListener('CLIK_buttonSelect', OnMultiplayerBarItemChange);
			bWasHandled = true;
			break;
		case 'MultiplayerView':
			if (MultiplayerView == none || MultiplayerView != Widget) {
				MultiplayerView = Rx_GFxFrontEnd_Multiplayer(Widget);
			}
			`log("Rx_GFxFrontEnd::Loading MultiplayerView",true,'GFxUI');
			SetWidgetPathBinding(MultiplayerView, WidgetPath);
			MultiplayerView.OnViewLoaded(self);
			if(MultiplayerBar != none)
				setupPrecache(MultiplayerBar, MultiplayerView);
			bWasHandled = true;
			break;
		case 'ExtrasBar':
			if (ExtrasBar == none || ExtrasBar != Widget) {
				ExtrasBar = GFxClikWidget(Widget);
			}
//			SetUpDataProvider(ExtrasBar);
			ExtrasBar.SetInt("selectedIndex", 0);
			if(ExtrasView != none)
				setupPrecache(ExtrasBar, ExtrasView);
			bWasHandled = true;
			break;
		case 'ExtrasView':
			if (ExtrasView == none || ExtrasView != Widget) {
				ExtrasView = Rx_GFxFrontEnd_Extras(Widget);
			}
			`log("Rx_GFxFrontEnd::Loading ExtrasView",true,'GFxUI');
			SetWidgetPathBinding(ExtrasView, WidgetPath);
			ExtrasView.OnViewLoaded(self);
			if(ExtrasBar != none)
				setupPrecache(ExtrasBar, ExtrasView);
			bWasHandled = true;
			break;
		default:
			break;
	}
	return bWasHandled;
}


/** Populates dropdowns, selection lists, and button groups with appropriate data **/
function SetUpDataProvider(GFxClikWidget Widget)
{
	local GFxObject DataProvider;
	local GFxObject TempData;

	`log("Rx_GFxFrontEnd::SetupDataProvider"@Widget.GetString("name"),true,'DevGFxUI');

	DataProvider = CreateObject("scaleform.clik.data.DataProvider");
	switch(Widget)
	{
		case (MainMenuBar):
			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("Skirmish"));
			TempData.SetString("data", "SkirmishMenu");
			DataProvider.SetElementObject(0, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("Multiplayer"));
			TempData.SetString("data", "MultiplayerMenu");
			DataProvider.SetElementObject(1, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("Settings"));
			TempData.SetString("data", "SettingsMenu");
			DataProvider.SetElementObject(2, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("Extras"));
			TempData.SetString("data", "ExtrasMenu");
			DataProvider.SetElementObject(3, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("Exit"));
			DataProvider.SetElementObject(4, TempData);
			break;
		case (SkirmishBar):
			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("MAP"));
			TempData.SetString("data", "SkirmishMapContainer");
			DataProvider.SetElementObject(0, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("GAME"));
			TempData.SetString("data", "SkirmishGameContainer");
			DataProvider.SetElementObject(1, TempData);
			break;
		case (MultiplayerBar):
			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("Internet"));
			TempData.SetString("data", "MultiplayerServerContainer");
			DataProvider.SetElementObject(0, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("Local"));
			TempData.SetString("data", "MultiplayerServerContainer");
			DataProvider.SetElementObject(1, TempData);
			break;
		case (SettingsBar):
			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("VIDEO"));
			TempData.SetString("data", "SettingsVideoContainer");
			DataProvider.SetElementObject(0, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("AUDIO"));
			TempData.SetString("data", "SettingsAudioContainer");
			DataProvider.SetElementObject(1, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("INPUT"));
			TempData.SetString("data", "SettingsInputContainer");
			DataProvider.SetElementObject(2, TempData);

			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("INTERFACE"));
			TempData.SetString("data", "SettingsInterfaceContainer");
			DataProvider.SetElementObject(3, TempData);

			break;
		case (ExtrasBar):
			TempData = CreateObject("Object");
			TempData.SetString("label", Caps("CREDITS"));
			TempData.SetString("data", "ExtrasCreditsContainer");
			DataProvider.SetElementObject(0, TempData);
			break;
		default:
			return;
	}
	Widget.SetObject("dataProvider", DataProvider);
}

/** Grants Kane total world domination */
function ExitGame()
{
	ConsoleCommand("exit");
}

/** Returns back to the main view (background) )*/
function ReturnToBackground()
{
	DeselectButtonBar() ;
	MainMenuBar.SetFloat("selectedIndex", -1);
	MainMenuView.SetBool("visible", false);
}

function DeselectButtonBar() 
{
	if (CurrentSelectedButton == none) {
		return;
	}

	CurrentSelectedButton.SetBool("selected", false);
}


function OpenExitDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXConfirmationForm", "com.scaleform.renx.dialogs.RenXDialogWindow", -1, -1, true);
	dialogInstance.SetString("name", "exitDialog");
	dialogInstance.SetString("title", "Exit");

	dialogInstance.GetObject("Form").GetObject("messageField").SetString("text", "Are you sure you want to exit to windows?");
	dialogInstance.AddEventListener('CLIK_hide', OnExitSubmit);

}

function OpenEnterIPDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXEnterIpForm", "com.scaleform.renx.dialogs.RenXDialogWindow", -1, -1, true);
	dialogInstance.SetString("name", "enterIPDialog");
	dialogInstance.SetString("title", "Enter IP");
	dialogInstance.AddEventListener('CLIK_hide', OnEnterIPSubmit);
}

function OpenEnterPasswordDialog(string serverIP, string serverPort)
{
	local GFxClikWidget dialogInstance;
	local GFxObject tempObject;

	dialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXEnterPasswordForm", "com.scaleform.renx.dialogs.RenXDialogWindow", -1, -1, true);
	dialogInstance.SetString("name", "enterPasswordDialog");
	dialogInstance.SetString("title", "Enter Password");


	//testing binding data in dialoginstance
	tempObject = CreateObject("Object");
	tempObject.SetString("serverIP", serverIP);
	tempObject.SetString("serverPort", ServerPort);
	dialogInstance.SetObject("data", tempObject);

	StoredServerIP = serverIP;
	StoredServerPort = serverPort;

	dialogInstance.AddEventListener('CLIK_hide', OnEnterPasswordSubmit);
}
function OpenConfirmApplyVideoSettingsDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXConfirmationForm", "com.scaleform.renx.dialogs.RenXDialogWindow", -1, -1, true);
	dialogInstance.SetString("name", "confirmApplyVideoSettingsDialog");
	dialogInstance.GetObject("Form").GetObject("messageField").SetString("text", "Are you sure you want to apply the settings?");
	dialogInstance.SetString("title", "Confirm");

	dialogInstance.AddEventListener('CLIK_hide', OnApplyVideoSettingsSubmit);
}

function OpenVideoSettingsSuccessAlertDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXConfirmationForm", "com.scaleform.renx.dialogs.RenXAlertDialogWindow", -1, -1, true);
	dialogInstance.SetString("name", "videoSettingsSuccessAlertDialog");
	dialogInstance.SetString("title", "Success");
	dialogInstance.GetObject("Form").GetObject("messageField").SetString("text", "Success");

	dialogInstance.AddEventListener('CLIK_hide', OnVideoSuccessClose);
}

function OpenFrontEndErrorAlertDialog(string title, string message) {
	local GFxClikWidget dialogInstance;
	dialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXConfirmationForm", "com.scaleform.renx.dialogs.RenXAlertDialogWindow", -1, -1, true);
	dialogInstance.SetString("name", "frontEndErrorAlertDialog");
	dialogInstance.SetString("title", title);
	dialogInstance.GetObject("Form").GetObject("messageField").SetString("text",  message);
	dialogInstance.AddEventListener('CLIK_hide', OnFrontEndErrorClose);
}

function OpenVersionOutOfDateDialog()
{
	local GFxClikWidget dialogInstance;
	local Rx_Game RenGame;

	RenGame = Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game);

	dialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXConfirmationForm", "com.scaleform.renx.dialogs.RenXDialogWindow", -1, -1, true);
	dialogInstance.SetString("name", "outOfDateDialog");
	dialogInstance.SetString("title", "Out of Date");
	if (RenGame != none)
		dialogInstance.GetObject("Form").GetObject("messageField").SetString("text", "Game is out of date; run the Renegade X Launcher to update.\n\nInstalled: " @ RenGame.GameVersion @ "\nLatest:     " @ RenGame.VQueryHandler.QueryedVersionName);
	else
		dialogInstance.GetObject("Form").GetObject("messageField").SetString("text", "Game is out of date; run the Renegade X Launcher to update.");
	dialogInstance.AddEventListener('CLIK_hide', OpenVersionOutOfDateDownload);
}

function OpenShowProgressDialog (float loaded, float total) 
{
	local float percentage;
	local GFxClikWidget progressBar;

	percentage = loaded / total * 100;

	if (ProgressDialogInstance == none) {
		ProgressDialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXProgressForm", "com.scaleform.renx.dialogs.RenXAlertDialogWindow", -1, -1, true);
		ProgressDialogInstance.SetString("name", "ProgressDialog");
		ProgressDialogInstance.SetString("message", "Fetching Server List");
		ProgressDialogInstance.SetString("title", "Receiving");

		progressBar = GFxClikWidget(ProgressDialogInstance.GetObject("form").GetObject("progressBarField", class'GFxClikWidget'));
		progressBar.ActionScriptVoid("setProgress");

		ProgressDialogInstance.GetObject("Form").GetObject("percentageField").SetString("text",int(percentage) $ "%");

		ProgressDialogInstance.AddEventListener('CLIK_hide', OnOpenShowProgressClose);

		GFxClikWidget(ProgressDialogInstance.GetObject("Form").GetObject("closeBtn", class'GFxClikWidget')).SetBool("disabled", true); //TODO: currently disable the manual cancellation
		
	} else {
		progressBar = GFxClikWidget(ProgressDialogInstance.GetObject("Form").GetObject("progressBarField", class'GFxClikWidget'));
		progressBar.ActionScriptVoid("setProgress");
		ProgressDialogInstance.GetObject("Form").GetObject("percentageField").SetString("text",int(percentage) $ "%");
	}
}

function CloseProgressDialog() {
	CloseDialog();
	ProgressDialogInstance = none;
}

function OpenShowDownloadProgressDialog(string title, string size) 
{
	//local GFxClikWidget progressBar;

	if (DownloadProgressDialogInstance == none)
	{
		DownloadProgressDialogInstance = OpenDialog("com.scaleform.renx.dialogs.RenXProgressForm", "com.scaleform.renx.dialogs.RenXAlertDialogWindow", -1, -1, true);
		DownloadProgressDialogInstance.SetString("name", "ProgressDialog");
		DownloadProgressDialogInstance.GetObject("Form").GetObject("messageField").SetString("text", title $ " - " $ size);
		DownloadProgressDialogInstance.SetString("title", "Downloading");

		DownloadProgressDialogInstance.AddEventListener('CLIK_hide', OnDownloadProgressClose);

		GFxClikWidget(DownloadProgressDialogInstance.GetObject("Form").GetObject("closeBtn", class'GFxClikWidget')).SetBool("disabled", true); //TODO: currently disable the manual cancellation
	}
}

function UpdateDownloadProgressDialog(float loaded, float total) 
{
	DownloadProgressDialogInstance.GetObject("Form").GetObject("progressBarField", class'GFxObject').ActionScriptVoid("setProgress");
}

function UpdateDownloadProgressPercentage(string percentage) 
{
	DownloadProgressDialogInstance.GetObject("Form").GetObject("percentageField").SetString("text", percentage);
}

function CloseDownloadProgressDialog()
{
	CloseDialog();
	DownloadProgressDialogInstance = none;
}

function OnDownloadProgressClose(GFxClikWidget.EventData ev)
{
	DownloadProgressDialogInstance = none;
	ConsoleCommand("disconnect");
}

function OnMultiplayerBarItemChange(GFxClikWidget.EventData ev)
{
	MultiplayerView.ServerList.SetInt("selectedIndex", -1);

	switch (ev._this.GetInt("index"))
    {
      case 0: 
      	MultiplayerView.eMode = BrowserMode_Internet;
		MultiplayerView.RefreshServers();
      	break;
      case 1: 
      	MultiplayerView.eMode = BrowserMode_Local;
		MultiplayerView.RefreshServers();
      	break;		 
      default: break;
    }

	MultiplayerView.SetServerDetailsVisibility(false);
}

function GFxClikWidget OpenDialog(string Form, string diagType, int DiagX, int DiagY, bool Modal, GFxObject Container=none)
{
	return GFxClikWidget(ActionScriptObject("root.openDialog"));	
}
function CloseDialog()
{
	ActionScriptVoid("closeDialog");
}


//=============================================================================
//   Rx_GFxFrontEnd event Listener Callbacks
//=============================================================================

function OnMainMenuBarChange(GFxClikWidget.EventData ev)
{
	if (GFxClikWidget(ev._this.GetObject("renderer", class'GFxClikWidget')) != none) {
		CurrentSelectedButton = GFxClikWidget(ev._this.GetObject("renderer", class'GFxClikWidget'));
	}

	switch (ev._this.GetInt("index"))
	{
		case -1:
			if (MenuSubTitleLabel != none) {
				MenuSubTitleLabel.SetText(Caps("Welcome to Renegade-X"));
			}
			
			if (SkirmishView != none) {
				SkirmishView.SaveConfig();
			}
			if (SettingsView != none) {
				SettingsView.ResetSettingsVideoOption();
				SettingsView.ResetSettingsAudioOption();
				SettingsView.ResetSettingsInputOption();
				SettingsView.ResetSettingsInterfaceOption();
			}

			DeselectButtonBar();
			break;
		case 0:
			MainMenuView.SetVisible(true);
			if (MenuSubTitleLabel != none) {
				MenuSubTitleLabel.SetText(Caps("Fight Against A.I in offline play"));
			}
			if (SettingsView != none) {
				SettingsView.ResetSettingsVideoOption();
				SettingsView.ResetSettingsAudioOption();
				SettingsView.ResetSettingsInputOption();
				SettingsView.ResetSettingsInterfaceOption();
			}
			break;
		case 1:
			MainMenuView.SetVisible(true);
			if (MenuSubTitleLabel != none) {
				MenuSubTitleLabel.SetText(Caps("Fight Against other players from around the world in online matches"));
			}
			if (SkirmishView != none) {
				SkirmishView.SaveConfig();
			}
			if (SettingsView != none) {
				SettingsView.ResetSettingsVideoOption();
				SettingsView.ResetSettingsAudioOption();
				SettingsView.ResetSettingsInputOption();
				SettingsView.ResetSettingsInterfaceOption();
			}
			break;
		case 2:
			MainMenuView.SetVisible(true);
			if (MenuSubTitleLabel != none) {
				MenuSubTitleLabel.SetText(Caps("Configure Video, Audio, Input and Interface Settings"));
			}
			if (SkirmishView != none) {
				SkirmishView.SaveConfig();
			}
			break;
		case 3:
			MainMenuView.SetVisible(true);
			if (MenuSubTitleLabel != none) {
				MenuSubTitleLabel.SetText(Caps("Tutorials & Tips, Go Deeper into the lore, and meet the developers"));
			}
			if (SkirmishView != none) {
				SkirmishView.SaveConfig();
			}
			if (SettingsView != none) {
				SettingsView.ResetSettingsVideoOption();
				SettingsView.ResetSettingsAudioOption();
				SettingsView.ResetSettingsInputOption();
				SettingsView.ResetSettingsInterfaceOption();
			}
			break;
		case 4:
			if (SkirmishView != none) {
				SkirmishView.SaveConfig();
			}
			if (SettingsView != none) {
				SettingsView.ResetSettingsVideoOption();
				SettingsView.ResetSettingsAudioOption();
				SettingsView.ResetSettingsInputOption();
				SettingsView.ResetSettingsInterfaceOption();
			}
			OpenExitDialog();
			break;
		default:
			return;
	}
}

function OnExitClose(GFxClikWidget.EventData ev) {
	ReturnToBackground();
	//DeselectButtonBar();
}

function OnExitSubmit(GFxClikWidget.EventData ev) {
	if(!ev._this.GetObject("target").GetBool("Success"))
	{
		ReturnToBackground();
		return;
	}

	ExitGame();
}

function OnOpenShowProgressClose(GFxClikWidget.EventData ev){
}

//function OnEnterPasswordClose(GFxClikWidget.EventData ev);
function OnApplyVideoSettingsClose(GFxClikWidget.EventData ev);

function OnApplyVideoSettingsSubmit(GFxClikWidget.EventData ev){

	if(!ev._this.GetObject("target").GetBool("Success"))
	{
		//ReturnToBackground();
		return;
	}

	if (SettingsView != none) {
		SettingsView.ApplyVideoSettings();
		ReturnToBackground();
	}
}
function OnEnterPasswordSubmit(GFxClikWidget.EventData ev) {
	local string Password;
//	local GFxObject dialogData;

	local string ServerIP;
	local string ServerPort;

	Password = ev._this.GetObject("target").GetObject("Form").GetObject("PasswordField").GetString("text");

//	dialogData = ev._this.GetObject("target").GetObject("data");
	ServerIP = StoredServerIP;
	ServerPort = StoredServerPort;

	`log("Trying to join"@ServerIP$":"$ServerPort@"while inputting "@"'"$Password$"'"@"as Password....");

	if (ServerPort == "") {
		`log("Opening without Port Number");
		ConsoleCommand("open " $ ServerIP $ "?Password=" $ Password);
	} else {
		ConsoleCommand("open " $ ServerIP $ ":" $ ServerPort $ "?Password=" $ Password);
	}

}

//function OnEnterIPClose(GFxClikWidget.EventData ev) ;
function OnEnterIPSubmit(GFxClikWidget.EventData ev) {

	local string IPAddress;
	local string Port;
	local bool HasPassword;
	local string Password;

	local GFxObject Data;

	if(!ev._this.GetObject("target").GetBool("Success"))
		return;

	Data = ev._this.GetObject("target").GetObject("Form");

	IPAddress = Data.GetObject("IPAddressField").GetString("text");
	Port = Data.GetObject("PortField").GetString("text");
	HasPassword = Data.GetObject("HasPasswordCheckBox").GetBool("selected");
	Password = Data.GetObject("PasswordField").GetString("text");

	if (IPAddress == "") {
		return;
	}
	
	if (Port == "") {
		`log("Opening without Port Number");
		if (HasPassword) {
			`log("open "$ IPAddress $ "?Password=" $ Password);
			ConsoleCommand("open "$ IPAddress $ "?Password=" $ Password);
		} else {
			ConsoleCommand("open "$ IPAddress); 
		}
	} else {
		if (HasPassword) {
			`log("open "$ IPAddress $":"$ Port $ "?Password=" $ Password);
			ConsoleCommand("open "$ IPAddress $":"$ Port $ "?Password=" $ Password);
		} else {
			ConsoleCommand("open "$ IPAddress $":"$ Port);
		}
	}

}

function OnVideoSuccessClose(GFxClikWidget.EventData ev);

function OnFrontEndErrorClose(GFxClikWidget.EventData ev);

function OpenVersionOutOfDateDownload(GFxClikWidget.EventData ev){
	if(!ev._this.GetObject("target").GetBool("Success"))
		return;

	Rx_Game(GetPC().WorldInfo.Game).ExitGameAndOpenLauncher();
}
//function OpenVersionOutOfDateSubmit(GFxClikWidget.EventData ev);
//ChangeUserButton
function OnChangeUserButtonClik(GFxClikWidget.EventData ev)
{
	//GetPC().ClientMessage("[Rx_GFxFrontEnd]: ChangeUserButton Pressed!");
}

/** Called whenever a button is pressed **/
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if (SettingsView == none || MainMenuBar == none || MainMenuBar.GetInt("selectedIndex") != 2) return false;
	return SettingsView.FilterButtonInput(ControllerId, ButtonName, InputEvent);
}

function ExportPlaySound(string EventName, optional string SoundThemeName = "default")
{
	PlaySoundFromTheme(name(EventName), name(SoundThemeName));	
}
//=============================================================================
//   Rx_GFxFrontEnd Debugging Tool
//=============================================================================

defaultproperties
{
	
	//Sound Mapping
	SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'renxfrontend.Sounds.SoundTheme')

	//root widget
	WidgetBindings.Add((WidgetName="MainMenuBar",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MainMenuView",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="PlayerProfileLabel",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="ChangeUserButton",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="GameVersionLabel",WidgetClass=class'GFxClikWidget'))

	//view widget
	WidgetBindings.Add((WidgetName="SkirmishBar",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="SkirmishView",WidgetClass=class'Rx_GFxFrontEnd_Skirmish'))
	WidgetBindings.Add((WidgetName="SettingsBar",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="SettingsView",WidgetClass=class'Rx_GFxFrontEnd_Settings'))
	WidgetBindings.Add((WidgetName="MultiplayerBar",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="MultiplayerView",WidgetClass=class'Rx_GFxFrontEnd_Multiplayer'))
	WidgetBindings.Add((WidgetName="ExtrasBar",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="ExtrasView",WidgetClass=class'Rx_GFxFrontEnd_Extras'))



	bDisplayWithHudOff=TRUE
	MovieInfo=SwfMovie'RenXFrontEnd.RenXFrontEnd'
	bPauseGameWhileActive=FALSE
	bCaptureInput=true
	TimingMode=TM_Real
}