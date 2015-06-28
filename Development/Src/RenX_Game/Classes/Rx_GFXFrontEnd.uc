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

var Rx_GFxFrontEnd_Multiplayer MultiplayerView;
var Rx_GFxFrontEnd_Settings SettingsView;
var Rx_GFxFrontEnd_Skirmish SkirmishView;
var Rx_GFxFrontEnd_Extras ExtrasView;

var GFxClikWidget ProgressDialogInstance;
var GFxClikWidget DownloadProgressDialogInstance;

/** Called on start **/
function bool Start (optional bool StartPaused = false)
{
	// CaptureBindIndex = -1;
	super.Start();
	Advance(0);
	Rx_Game(GetPC().WorldInfo.Game).VersionCheck.RegisterNotifyDelegate(OnVersionOutOfDate);

	SetAlignment(Align_Center);
	SetViewScaleMode(SM_ShowAll);

	RunOnce();

	RootMC = GetVariableObject("_root");
	DialogContainer = GetVariableObject("_root.DialogContainer");
	MenuSubTitleLabel = GetVariableObject("_root.MenuSubTitleLabel");
	MenuSubTitleLabel.SetText(Caps("Welcome to Renegade-X"));

	CheckForErrorMessages();
	Rx_GameViewportClient(GetGameViewportClient()).FrontEnd = self;

	return true;
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
}

/** Called when a CLIK Widget is initialized **/
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch (WidgetName)
	{
		/****************************
		*  Main Scene               *
		****************************/
		case 'MainMenuBar':
			if (MainMenuBar == none || MainMenuBar != Widget) {
				MainMenuBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MainMenuBar);
			MainMenuBar.AddEventListener('CLIK_change', OnMainMenuBarChange);
			MainMenuBar.SetInt("selectedIndex", -1);
			break;
		case 'MainMenuView':
			if (MainMenuView == none || MainMenuView != Widget) {
				MainMenuView = GFxClikWidget(Widget);
			}
			break;
		case 'PlayerProfileLabel':
			if (PlayerProfileLabel == none || PlayerProfileLabel != Widget) {
				PlayerProfileLabel = GFxClikWidget(Widget);
			}
			PlayerProfileLabel.SetText("|  LOGGED IN: "$ Caps(GetPC().PlayerReplicationInfo.PlayerName) $"  |");
			break;
		case 'ChangeUserButton':
			if (ChangeUserButton == none || ChangeUserButton != Widget) {
				ChangeUserButton = GFxClikWidget(Widget);
			}
			ChangeUserButton.AddEventListener('CLIK_press', OnChangeUserButtonClik);
			ChangeUserButton.SetVisible(false); //Hack for the time being
			break;
		case 'GameVersionLabel':
			if (GameVersionLabel == none || GameVersionLabel != Widget) {
				GameVersionLabel = GFxClikWidget(Widget);
			}
			//GameVersionLabel.SetString("text", "| "$ Caps(Rx_Game(GetPC().WorldInfo.Game).GameVersion) $" |");
			GameVersionLabel.SetString("text", "| VERSION: " $ Left("" $ (float(Rx_Game(GetPC().WorldInfo.Game).GameVersionNumber)/1000.0f), InStr("" $ (float(Rx_Game(GetPC().WorldInfo.Game).GameVersionNumber)/1000.0f), ".")+4 )  $ " |");
			break;
		case 'SkirmishView':
			if (SkirmishView == none || SkirmishView != Widget) {
				SkirmishView = Rx_GFxFrontEnd_Skirmish(Widget);
			}
			SetWidgetPathBinding(SkirmishView, WidgetPath);
			SkirmishView.OnViewLoaded(self);
			break;
		case 'SettingsView':
			if (SettingsView == none || SettingsView != Widget) {
				SettingsView = Rx_GFxFrontEnd_Settings(Widget);
			}
			SetWidgetPathBinding(SettingsView, WidgetPath);
			SettingsView.OnViewLoaded(self);
			break;
		case 'MultiplayerView':
			if (MultiplayerView == none || MultiplayerView != Widget) {
				MultiplayerView = Rx_GFxFrontEnd_Multiplayer(Widget);
			}
			SetWidgetPathBinding(MultiplayerView, WidgetPath);
			MultiplayerView.OnViewLoaded(self);
			break;
		case 'ExtrasView':
			if (ExtrasView == none || ExtrasView != Widget) {
				ExtrasView = Rx_GFxFrontEnd_Extras(Widget);
			}
			SetWidgetPathBinding(ExtrasView, WidgetPath);
			ExtrasView.OnViewLoaded(self);
			break;
		default:
			break;
	}
	return true;
}


/** Populates dropdowns, selection lists, and button groups with appropriate data **/
function SetUpDataProvider(GFxClikWidget Widget)
{
	local GFxObject DataProvider;
	local GFxObject TempData;

	DataProvider = CreateArray();
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

	dialogInstance = OpenDialog(DialogContainer, "RenXConfirmationDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "exitDialog");
	dialogInstance.SetString("message", "Are you sure you want to exit to windows?");
	dialogInstance.AddEventListener('CLIK_close', OnExitClose);
	dialogInstance.AddEventListener('CLIK_submit', OnExitSubmit);

}

function OpenEnterIPDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog(DialogContainer, "RenXEnterIPDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "enterIPDialog");
	dialogInstance.AddEventListener('CLIK_close', OnEnterIPClose);
	dialogInstance.AddEventListener('CLIK_submit', OnEnterIPSubmit);
}

function OpenEnterPasswordDialog(string serverIP, string serverPort)
{
	local GFxClikWidget dialogInstance;
	local GFxObject tempObject;

	dialogInstance = OpenDialog(DialogContainer, "RenXEnterPasswordDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "enterPasswordDialog");


	//testing binding data in dialoginstance
	tempObject = CreateObject("Object");
	tempObject.SetString("serverIP", serverIP);
	tempObject.SetString("serverPort", ServerPort);
	dialogInstance.SetObject("data", tempObject);


	dialogInstance.AddEventListener('CLIK_close', OnEnterPasswordClose);
	dialogInstance.AddEventListener('CLIK_submit', OnEnterPasswordSubmit);
}
function OpenConfirmApplyVideoSettingsDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog(DialogContainer, "RenXConfirmationDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "confirmApplyVideoSettingsDialog");
	dialogInstance.SetString("message", "Are you sure you want to apply the settings?");
	dialogInstance.AddEventListener('CLIK_close', OnApplyVideoSettingsClose);
	dialogInstance.AddEventListener('CLIK_submit', OnApplyVideoSettingsSubmit);
}

function OpenVideoSettingsSuccessAlertDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog(DialogContainer, "RenXAlertDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "videoSettingsSuccessAlertDialog");
	
	dialogInstance.GetObject("drageBar").GetObject("textField").SetString("text", "Success");
	dialogInstance.SetString("message", "Success");
	dialogInstance.AddEventListener('CLIK_close', OnVideoSuccessClose);
}

function OpenFrontEndErrorAlertDialog(string title, string message) {
	local GFxClikWidget dialogInstance;
	dialogInstance = OpenDialog(DialogContainer, "RenXAlertDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "frontEndErrorAlertDialog");
	
	dialogInstance.GetObject("drageBar").GetObject("textField").SetString("text", title != "" ? title : "Error");
	dialogInstance.SetString("message", message != "" ? message : "Unknown Error Occured");
	dialogInstance.AddEventListener('CLIK_close', OnFrontEndErrorClose);
}

function OpenVersionOutOfDateDialog()
{
	local GFxClikWidget dialogInstance;
	local Rx_Game RenGame;

	RenGame = Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game);

	dialogInstance = OpenDialog(DialogContainer, "RenXOutOfDateDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "outOfDateDialog");
	if (RenGame != none)
		dialogInstance.SetString("message", "Game is out of date, visit www.Renegade-X.com to update.\n\nInstalled: " @ RenGame.GameVersion @ "\nLatest:     " @ RenGame.VersionCheck.LatestVersion);
	else
		dialogInstance.SetString("message", "Game is out of date, visit www.Renegade-X.com to update.");
	dialogInstance.AddEventListener('CLIK_close', OpenVersionOutOfDateDownload);
	dialogInstance.AddEventListener('CLIK_submit', OpenVersionOutOfDateSubmit);
}

function OpenShowProgressDialog (float loaded, float total) 
{
	local float percentage;
	local GFxClikWidget progressBar;

	percentage = loaded / total * 100;

	if (ProgressDialogInstance == none) {
		ProgressDialogInstance = OpenDialog(DialogContainer, "RenXProgressDialog", none, true);
		ProgressDialogInstance.SetBool("topmostLevel", false);
		ProgressDialogInstance.SetString("_name", "ProgressDialog");
		ProgressDialogInstance.GetObject("drageBar").GetObject("textField").SetString("text", "RECEIVING");
		ProgressDialogInstance.SetString("message", "Fetching Server List");

		progressBar = GFxClikWidget(ProgressDialogInstance.GetObject("progressBarField", class'GFxClikWidget'));
		progressBar.ActionScriptVoid("setProgress");

		ProgressDialogInstance.GetObject("percentageField").SetString("text",int(percentage) $ "%");

		ProgressDialogInstance.AddEventListener('CLIK_close', OnOpenShowProgressClose);

		GFxClikWidget(ProgressDialogInstance.GetObject("cancelBtn", class'GFxClikWidget')).SetBool("disabled", true); //TODO: currently disable the manual cancellation
		
	} else {
		progressBar = GFxClikWidget(ProgressDialogInstance.GetObject("progressBarField", class'GFxClikWidget'));
		progressBar.ActionScriptVoid("setProgress");
		ProgressDialogInstance.GetObject("percentageField").SetString("text",int(percentage) $ "%");
	}
}

function OpenServerInfoDebugDialog()
{
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
		DownloadProgressDialogInstance = OpenDialog(DialogContainer, "RenXProgressDialog", none, true);
		DownloadProgressDialogInstance.SetBool("topmostLevel", false);
		DownloadProgressDialogInstance.SetString("_name", "ProgressDialog");
		DownloadProgressDialogInstance.GetObject("drageBar").GetObject("textField").SetString("text", "Downloading");
		DownloadProgressDialogInstance.SetString("message", title $ " - " $ size);

		DownloadProgressDialogInstance.AddEventListener('CLIK_close', OnDownloadProgressClose);

		GFxClikWidget(DownloadProgressDialogInstance.GetObject("cancelBtn", class'GFxClikWidget')).SetBool("disabled", true); //TODO: currently disable the manual cancellation
	}
}

function UpdateDownloadProgressDialog(float loaded, float total) 
{
	DownloadProgressDialogInstance.GetObject("progressBarField", class'GFxObject').ActionScriptVoid("setProgress");
}

function UpdateDownloadProgressPercentage(string percentage) 
{
	DownloadProgressDialogInstance.GetObject("percentageField").SetString("text", percentage);
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

function GFxClikWidget OpenDialog(GFxObject Context, string Linkage, GFxObject Props, bool Modal)
{
	return GFxClikWidget(ActionScriptObject("openDialog"));	
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

	switch (ev.index)
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
			}
			break;
		case 2:
			MainMenuView.SetVisible(true);
			if (MenuSubTitleLabel != none) {
				MenuSubTitleLabel.SetText(Caps("Configure Video, Audio & Input Settings"));
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
	ExitGame();
}

function OnOpenShowProgressClose(GFxClikWidget.EventData ev){
}

function OnEnterPasswordClose(GFxClikWidget.EventData ev);
function OnApplyVideoSettingsClose(GFxClikWidget.EventData ev);

function OnApplyVideoSettingsSubmit(GFxClikWidget.EventData ev){
	if (SettingsView != none) {
		SettingsView.ApplyVideoSettings();
		ReturnToBackground();
	}
}
function OnEnterPasswordSubmit(GFxClikWidget.EventData ev) {
	local string Password;
	local GFxObject Data;
	local GFxObject dialogData;

	local string ServerIP;
	local string ServerPort;

	Data = ev._this.GetObject("data");
	Password = Data.GetString("Password");


	//testing binding data in dialoginstance
	dialogData = ev.target.GetObject("data");
	`log("dialogData " $ dialogData);
	ServerIP = dialogData.GetString("serverIP");
	ServerPort = dialogData.GetString("serverPort");

	`log("ServerIP: " $ ServerIP);
	`log("ServerPort: " $ ServerPort);


	if (ServerPort == "") {
		`log("Opening without Port Number");
		ConsoleCommand("open " $ ServerIP $ "?Password=" $ Password);
	} else {
		ConsoleCommand("open " $ ServerIP $ ":" $ ServerPort $ "?Password=" $ Password);
	}

}

function OnEnterIPClose(GFxClikWidget.EventData ev) ;
function OnEnterIPSubmit(GFxClikWidget.EventData ev) {

	local string IPAddress;
	local string Port;
	local bool HasPassword;
	local string Password;

	local GFxObject Data;

	Data = ev._this.GetObject("data");

	IPAddress = Data.GetString("IPAddress");
	Port = Data.GetString("Port");
	HasPassword = Data.GetBool("HasPassword");
	Password = Data.GetString("Password");

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
	Rx_Game(GetPC().WorldInfo.Game).OpenDownloadLink();
}
function OpenVersionOutOfDateSubmit(GFxClikWidget.EventData ev);
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
	WidgetBindings.Add((WidgetName="SkirmishView",WidgetClass=class'Rx_GFxFrontEnd_Skirmish'))
	WidgetBindings.Add((WidgetName="SettingsView",WidgetClass=class'Rx_GFxFrontEnd_Settings'))
	WidgetBindings.Add((WidgetName="MultiplayerView",WidgetClass=class'Rx_GFxFrontEnd_Multiplayer'))
	WidgetBindings.Add((WidgetName="ExtrasView",WidgetClass=class'Rx_GFxFrontEnd_Extras'))



	bDisplayWithHudOff=TRUE
	MovieInfo=SwfMovie'RenXFrontEnd.RenXFrontEnd'
	bPauseGameWhileActive=FALSE
	bCaptureInput=true
}