/*********************************************************
*
* File: Rx_GFxPauseMenu.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class handles the creation and modification of the 
* Pause Menu.
* 
* Related Flash content:   RenXPauseMenu.fla
*
* ConfigFile:   DefaultMenu.ini
*
*********************************************************
*  
*********************************************************
*  Drawboards
* 
* after finishing init, set the first selection.
* 
* 
* item clik cause the group to set selected on the selection
* use the item click on the selected to show dummy pawn
* 
* purchase button set
* 
* 
* 
* 
* 
* 
* 
*********************************************************/

class Rx_GFxPauseMenu extends GFxMoviePlayer
	config(Menu);


var bool HasRunOnce;

// var GFxObject RootMC, PauseMC, ResumeBtn, RestartBtn, ExitBtn, SuicideBtn, SwitchTeamBtn;
var GFxObject RootMC;
var GFxObject DialogContainer;
var GFxObject PauseSubTitleLabel;
var GFxObject ServerNameLabel; //  GetPC().WorldInfo.GRI.ServerName
var GFxObject ServerMessageLabel;

var GFxClikWidget PauseMenuView;
var GFxClikWidget PauseMenuGroup;

var GFxClikWidget SettingsButton;
var GFxClikWidget ResumeButton;
var GFxClikWidget ExitButton;
var GFxClikWidget ScoreboardButton;
var GFxClikWidget HowToPlayButton;
var GFxClikWidget ChatButton;
var GFxClikWidget VoteButton;
var GFxClikWidget SuicideButton;
var GFxClikWidget ChangeteamButton;
var GFxClikWidget DonateButton;

var Rx_GFxPauseMenu_ChatMenu ChatView;
var Rx_GFxPauseMenu_DonateMenu DonateView;
var Rx_GFxPauseMenu_Scoreboard ScoreboardView;
var Rx_GFxPauseMenu_SettingsMenu SettingsView;
var Rx_GFxPauseMenu_VoteMenu VoteView;


function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);

	SetAlignment(Align_Center);
	SetViewScaleMode(SM_ShowAll);


	if (GetPC().WorldInfo.GRI.bMatchIsOver) {
		bPauseGameWhileActive=false;
	} else {
		bPauseGameWhileActive=true;
	}

	RunOnce();

	RootMC = GetVariableObject("_root");
	DialogContainer = GetVariableObject("_root.DialogContainer");
	PauseSubTitleLabel = GetVariableObject("_root.PauseSubTitleLabel");
	PauseSubTitleLabel.SetText(Caps("Welcome to Renegade-X"));
	//servertitile
	ServerNameLabel = GetVariableObject("_root.ServerNameLabel");
	ServerNameLabel.SetText("");
	//servermessage
	ServerMessageLabel = GetVariableObject("_root.ServerMessageLabel");
	ServerMessageLabel.SetText("");

	//button group
// 	if (PauseMenuGroup == none) {
// 	}
	PauseMenuGroup = InitButtonGroupWidget("PauseMenuGroup", RootMC);
	PauseMenuView = GFxClikWidget(GetVariableObject("_root.PauseMenuView",class'GFxClikWidget'));
	PauseMenuView.SetObject("targetGroup", PauseMenuGroup);

	SettingsButton = GFxClikWidget(GetVariableObject("_root.settingsButton", class'GFxClikWidget'));
	ResumeButton = GFxClikWidget(GetVariableObject("_root.resumeButton", class'GFxClikWidget'));
	ExitButton = GFxClikWidget(GetVariableObject("_root.exitButton", class'GFxClikWidget'));
	ScoreboardButton = GFxClikWidget(GetVariableObject("_root.scoreboardButton", class'GFxClikWidget'));
	HowToPlayButton = GFxClikWidget(GetVariableObject("_root.howToPlayButton", class'GFxClikWidget'));
	HowToPlayButton.SetVisible(false);
	ChatButton = GFxClikWidget(GetVariableObject("_root.chatButton", class'GFxClikWidget'));
	VoteButton = GFxClikWidget(GetVariableObject("_root.voteButton", class'GFxClikWidget'));
	SuicideButton = GFxClikWidget(GetVariableObject("_root.suicideButton", class'GFxClikWidget'));
	ChangeteamButton = GFxClikWidget(GetVariableObject("_root.changeteamButton", class'GFxClikWidget'));
	DonateButton = GFxClikWidget(GetVariableObject("_root.donateButton", class'GFxClikWidget'));

	SetupButtonGroup();

	AddCaptureKey('XboxTypeS_A');
	AddCaptureKey('XboxTypeS_Start');
	AddCaptureKey('Enter');

    return true;
}

function OnClose() 
{
	super.OnClose();
}

//TODO: will need to figure out how to call this in other places.
function RunOnce()
{
	if (HasRunOnce == false)
	{
		if (Rx_HUD(GetPC().myHUD).SystemSettingsHandler == none) {
			Rx_HUD(GetPC().myHUD).SystemSettingsHandler = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_SystemSettingsHandler');
			Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetSettingBucket(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GraphicsPresetLevel);
			Rx_HUD(GetPC().myHUD).SystemSettingsHandler.PopulateSystemSettings();
		}
		Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAAType(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CurrentAAType);
		Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetGammaSettings(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetGammaSettings());
		Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetFOV(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.DefaultFOV); 
		Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAmbientOcclusion(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AmbientOcclusion);
		Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetEnableSmoothFramerate(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetEnableSmoothFramerate());
		Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDisablePhysXHardwareSupport(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetDisablePhysXHardwareSupport());

		if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck == none) {
			Rx_HUD(GetPC().myHUD).GraphicAdapterCheck = class'WorldInfo'.static.GetWorldInfo().Spawn(class'Rx_GraphicAdapterCheck');
			Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.CheckGraphicAdapter();
		}


		//Load our Audio Settings
		GetPC().SetAudioGroupVolume('UI', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.UIVolume);
		GetPC().SetAudioGroupVolume('Item', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.ItemVolume);
		GetPC().SetAudioGroupVolume('Vehicle', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.VehicleVolume);
		GetPC().SetAudioGroupVolume('Weapon', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.WeaponVolume);
		GetPC().SetAudioGroupVolume('SFX', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SFXVolume);
		GetPC().SetAudioGroupVolume('Character', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CharacterVolume);
		GetPC().SetAudioGroupVolume('Music', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MusicVolume);
		GetPC().SetAudioGroupVolume('Announcer', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AnnouncerVolume);
		GetPC().SetAudioGroupVolume('MovieVoice', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MovieVoiceVolume);
		GetPC().SetAudioGroupVolume('WeaponBulletEffects', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.WeaponBulletEffectsVolume);
		GetPC().SetAudioGroupVolume('OptionVoice', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.OptionVoiceVolume);
		GetPC().SetAudioGroupVolume('MovieEffects', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MovieEffectsVolume);
		GetPC().SetAudioGroupVolume('Ambient', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AmbientVolume);
		GetPC().SetAudioGroupVolume('UnGrouped', Rx_HUD(GetPC().myHUD).SystemSettingsHandler.UnGroupedVolume);


		HasRunOnce = true;
	}
}

// **************************************************************** //
//																	//
//						BUTTON GROUP CONSTRUCTORS					//
//																	//
// **************************************************************** //
/** 
 *  Instantiatea a ButtonGroup Widget through a wrapper constructor.
 *  The Corresponding constructor would be: [ new ButtonGroup( name:String, scope:DisplayObjectContainer) ]
 */
function GFxClikWidget InitButtonGroupWidget(string groupName, GFxObject scope)
{
	return GFxClikWidget(ActionScriptConstructor("gfx.controls.ButtonGroup"));
}

function SetupButtonGroup ()
{

	SettingsButton.SetObject("group", PauseMenuGroup);
	SettingsButton.SetString("data", "SettingsMenu");

	ResumeButton.SetObject("group", PauseMenuGroup);

	ExitButton.SetObject("group", PauseMenuGroup);

	ScoreboardButton.SetObject("group", PauseMenuGroup);
	ScoreboardButton.SetString("data", "ScoreboardMenu");

	HowToPlayButton.SetObject("group", PauseMenuGroup);
	HowToPlayButton.SetString("data", "HowtoPlay");

	ChatButton.SetObject("group", PauseMenuGroup);
	ChatButton.SetString("data", "ChatMenu");

	VoteButton.SetObject("group", PauseMenuGroup);
	VoteButton.SetString("data", "VoteMenu");
	VoteButton.SetBool("disabled", true);

	SuicideButton.SetObject("group", PauseMenuGroup);

	ChangeteamButton.SetObject("group", PauseMenuGroup);

	
	DonateButton.SetObject("group", PauseMenuGroup);
	DonateButton.SetString("data", "DonateMenu");

	PauseMenuGroup.AddEventListener('CLIK_change', OnPauseMenuGroupChange);
	//SetSelectedButton(HowToPlayButton);
}

/** Called when a CLIK Widget is initialized **/
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	//GetPC().ClientMessage("WidgetName: " $ WidgetName);
	switch (WidgetName) 
	{
		case 'ChatView':
			if (ChatView == none || ChatView != Widget) {
				ChatView = Rx_GFxPauseMenu_ChatMenu(Widget);
			}
			SetWidgetPathBinding(ChatView, WidgetPath);
			ChatView.OnViewLoaded(self);
			break;
		case 'VoteView':
			if (VoteView == none || VoteView != Widget) {
				VoteView = Rx_GFxPauseMenu_VoteMenu(Widget);
			}
			SetWidgetPathBinding(VoteView, WidgetPath);
			VoteView.OnViewLoaded(self);
			break;
		case 'SettingsView':
			if (SettingsView == none || SettingsView != Widget) {
				SettingsView = Rx_GFxPauseMenu_SettingsMenu(Widget);
			}
			SetWidgetPathBinding(SettingsView, WidgetPath);
			SettingsView.OnViewLoaded(self);
			break;
		case 'ScoreboardView':
			if (ScoreboardView == none || ScoreboardView != Widget) {
				ScoreboardView = Rx_GFxPauseMenu_Scoreboard(Widget);
			}
			SetWidgetPathBinding(ScoreboardView, WidgetPath);
			ScoreboardView.OnViewLoaded(self);
			break;
		case 'DonateView':
			if (DonateView == none || DonateView != Widget) {
				DonateView = Rx_GFxPauseMenu_DonateMenu(Widget);
			}
			SetWidgetPathBinding(DonateView, WidgetPath);
			DonateView.OnViewLoaded(self);
			break;
		default:
			break;
	}
	return true;
}


/**Called every update Tick*/
function TickHUD() 
{
	if (!bMovieIsOpen) {
		return;
	}

	if (DonateView != None) {
		DonateView.TickHUD();
	}
	if (ScoreboardView != None) {
		ScoreboardView.TickHUD();
	}
}

/** Returns back to the main view (background) )*/
function ReturnToBackground()
{
	DeselectButtonGroup() ;
	PauseMenuView.SetBool("visible", false);
// 	MainMenuBar.SetFloat("selectedIndex", -1);
// 	MainMenuView.SetBool("visible", false);
}

function DeselectButtonGroup() 
{
	SetSelectedButton(none);
//  Set the current button group to false, making it deselected.

// 	if (CurrentSelectedButton == none) {
// 		return;
// 	}
// 
// 	CurrentSelectedButton.SetBool("selected", false);
}


function SetSelectedButton  (GFxClikWidget button)
{
	PauseMenuGroup.ActionScriptVoid("setSelectedButton");
}
//=============================================================================
//   Rx_GFxFrontEnd event Dialog Functions
//=============================================================================

function OpenExitDialog()
{
	local GFxClikWidget dialogInstance;

	dialogInstance = OpenDialog(DialogContainer, "RenXConfirmationDialog", none, true);
	dialogInstance.SetBool("topmostLevel", false);
	dialogInstance.SetString("_name", "exitDialog");
	dialogInstance.SetString("message", "Are you sure you want to exit this game?");
	dialogInstance.AddEventListener('CLIK_close', OnExitClose);
	dialogInstance.AddEventListener('CLIK_submit', OnExitSubmit);

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

function OnPauseMenuGroupChange(GFxClikWidget.EventData ev)
{
	local GFxClikWidget SelectedItem;

	SelectedItem = GFxClikWidget(ev._this.GetObject("item", class'GFxClikWidget'));
	switch (SelectedItem)
	{
		case (SettingsButton):
			if (PauseSubTitleLabel != none) {
				PauseSubTitleLabel.SetText(Caps("Welcome to Renegade-X"));
			}
			PauseMenuView.SetBool("visible", true);
			break;
		case (ResumeButton):
			ReturnToBackground();
			Rx_HUD(GetPC().myHUD).CompletePauseMenuClose();
			break;
		case (ExitButton):
			OpenExitDialog();
			break;
		case (ScoreboardButton):
			if (PauseSubTitleLabel != none) {
				PauseSubTitleLabel.SetText(Caps("See your score among others"));
			}
			PauseMenuView.SetBool("visible", true);
			break;
		case (HowToPlayButton):
			if (PauseSubTitleLabel != none) {
				PauseSubTitleLabel.SetText(Caps("Quick tutorial on how to play"));
			}
			PauseMenuView.SetBool("visible", true);
			break;
		case (ChatButton):
			if (PauseSubTitleLabel != none) {
				PauseSubTitleLabel.SetText(Caps("Communicate with the team members and others"));
			}
			PauseMenuView.SetBool("visible", true);
			break;
		case (VoteButton):
			if (PauseSubTitleLabel != none) {
				PauseSubTitleLabel.SetText(Caps("Call on a vote"));
			}
			PauseMenuView.SetBool("visible", true);
			break;
		case (SuicideButton):
			ReturnToBackground();
		 	GetPC().SetTimer(0.4f,, 'Suicide');
			Rx_HUD(GetPC().myHUD).CompletePauseMenuClose();
			break;
		case (ChangeteamButton):
			ReturnToBackground();
		 	GetPC().SetTimer(0.4f,, 'SwitchTeam');
			Rx_HUD(GetPC().myHUD).CompletePauseMenuClose();
			break;
		case (DonateButton):
			if (PauseSubTitleLabel != none) {
				PauseSubTitleLabel.SetText(Caps("Donate credits to others"));
			}
			PauseMenuView.SetBool("visible", true);
			break;
// 		case -1:
// 			if (MenuSubTitleLabel != none) {
// 				MenuSubTitleLabel.SetText(Caps("Welcome to Renegade-X"));
// 			}
// 			
// 			if (SkirmishView != none) {
// 				SkirmishView.SaveConfig();
// 			}
// 			if (SettingsView != none) {
// 				SettingsView.ResetSettingsVideoOption();
// 				SettingsView.ResetSettingsAudioOption();
// 				SettingsView.ResetSettingsInputOption();
// 			}
// 
// 			DeselectButtonBar();
// 			break;
// 		case 0:
// 			MainMenuView.SetVisible(true);
// 			if (MenuSubTitleLabel != none) {
// 				MenuSubTitleLabel.SetText(Caps("Fight Against A.I in offline play"));
// 			}
// 			if (SettingsView != none) {
// 				SettingsView.ResetSettingsVideoOption();
// 				SettingsView.ResetSettingsAudioOption();
// 				SettingsView.ResetSettingsInputOption();
// 			}
// 			break;
// 		case 1:
// 			MainMenuView.SetVisible(true);
// 			if (MenuSubTitleLabel != none) {
// 				MenuSubTitleLabel.SetText(Caps("Fight Against other players from around the world in online matches"));
// 			}
// 			if (SkirmishView != none) {
// 				SkirmishView.SaveConfig();
// 			}
// 			if (SettingsView != none) {
// 				SettingsView.ResetSettingsVideoOption();
// 				SettingsView.ResetSettingsAudioOption();
// 				SettingsView.ResetSettingsInputOption();
// 			}
// 			break;
// 		case 2:
// 			MainMenuView.SetVisible(true);
// 			if (MenuSubTitleLabel != none) {
// 				MenuSubTitleLabel.SetText(Caps("Configure Video, Audio & Input Settings"));
// 			}
// 			if (SkirmishView != none) {
// 				SkirmishView.SaveConfig();
// 			}
// 			break;
// 		case 3:
// 			MainMenuView.SetVisible(true);
// 			if (MenuSubTitleLabel != none) {
// 				MenuSubTitleLabel.SetText(Caps("Tutorials & Tips, Go Deeper into the lore, and meet the developers"));
// 			}
// 			if (SkirmishView != none) {
// 				SkirmishView.SaveConfig();
// 			}
// 			if (SettingsView != none) {
// 				SettingsView.ResetSettingsVideoOption();
// 				SettingsView.ResetSettingsAudioOption();
// 				SettingsView.ResetSettingsInputOption();
// 			}
// 			break;
// 		case 4:
// 			if (SkirmishView != none) {
// 				SkirmishView.SaveConfig();
// 			}
// 			if (SettingsView != none) {
// 				SettingsView.ResetSettingsVideoOption();
// 				SettingsView.ResetSettingsAudioOption();
// 				SettingsView.ResetSettingsInputOption();
// 			}
// 			OpenExitDialog();
// 			break;
		default:
			return;
	}
}

//Exit Dialog Callbacks
function OnExitClose(GFxClikWidget.EventData ev) {
	ReturnToBackground();
}

function OnExitSubmit(GFxClikWidget.EventData ev) {
	//ExitGame();
	ReturnToBackground();
	GetPC().ConsoleCommand("disconnect");
	Rx_HUD(GetPC().myHUD).CompletePauseMenuClose();
}

//Apply Video Settings Dialog
function OnApplyVideoSettingsSubmit(GFxClikWidget.EventData ev){
	if (SettingsView != none) {
		SettingsView.ApplyVideoSettings();
		ReturnToBackground();
	}
}

function OnApplyVideoSettingsClose(GFxClikWidget.EventData ev);
function OnVideoSuccessClose(GFxClikWidget.EventData ev);


//=============================================================================
//   Misc
//=============================================================================

/** Called whenever a button is pressed **/
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if (SettingsView != none && PauseMenuGroup != none && GFxClikWidget(PauseMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) == SettingsButton) {
		return SettingsView.FilterButtonInput(ControllerId, ButtonName, InputEvent);
	} else if (ChatView != none && PauseMenuGroup != none && GFxClikWidget(PauseMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) == ChatButton) {
		return ChatView.FilterButtonInput(ControllerId, ButtonName, InputEvent);
	}
	return false;
// 	if (SettingsView == none || MainMenuBar == none || MainMenuBar.GetInt("selectedIndex") != 2) return false;
// 	return SettingsView.FilterButtonInput(ControllerId, ButtonName, InputEvent);
}

// 
// 
// function OnPressSwitchTeamButton(GFxClikWidget.EventData ev)
// {
// 	PlayCloseAnimation();
// 	GetPC().SetTimer(0.4f,, 'SwitchTeam');
// }
// 
// function OnPressResumeButton(GFxClikWidget.EventData ev)
// {
//     PlayCloseAnimation();
// }
// 
// function OnPressRestartButton(GFxClikWidget.EventData ev)
// {
//     Rx_ConsoleCommand("restartlevel");
// }
// 
// function OnPressExitButton(GFxClikWidget.EventData ev)
// {
// 	UTPlayerController(GetPC()).QuitToMainMenu();	
// }
// 
// function PlayOpenAnimation()
// {
//     PauseMC.GotoAndPlay("open");
// }
// function PlayCloseAnimation()
// {
//     PauseMC.GotoAndPlay("close");
// }
// function OnPlayAnimationComplete();
// function OnCloseAnimationComplete()
// {
//     UTHUDBase(GetPC().MyHUD).CompletePauseMenuClose();
// }
// 
// /*
//     Launch a console command using the PlayerOwner.
//     Will fail if PlayerOwner is undefined.
// */
// final function Rx_ConsoleCommand(string Cmd, optional bool bWriteToLog)
// {
//     GetPC().Player.Actor.ConsoleCommand(Cmd, bWriteToLog);
// }

defaultproperties
{
	//Sound Mapping
	SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'renxfrontend.Sounds.SoundTheme')



	//root widget

	WidgetBindings.Add((WidgetName="ChatView",WidgetClass=class'Rx_GFxPauseMenu_ChatMenu'))
	WidgetBindings.Add((WidgetName="VoteView",WidgetClass=class'Rx_GFxPauseMenu_VoteMenu'))
	//WidgetBindings.Add((WidgetName="HowtoPlay",WidgetClass=class'Rx_GFxFrontEnd_Multiplayer'))
	WidgetBindings.Add((WidgetName="SettingsView",WidgetClass=class'Rx_GFxPauseMenu_SettingsMenu'))
	WidgetBindings.Add((WidgetName="ScoreboardView",WidgetClass=class'Rx_GFxPauseMenu_Scoreboard'))
	WidgetBindings.Add((WidgetName="DonateView",WidgetClass=class'Rx_GFxPauseMenu_DonateMenu'))

	//view widget
    bDisplayWithHudOff=TRUE
	MovieInfo=SwfMovie'RenXPauseMenu.RenXPauseMenu'
    bEnableGammaCorrection=FALSE
	bCaptureInput=true
}
