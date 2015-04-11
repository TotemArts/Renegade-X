class Rx_GFxFrontEnd_old extends GFxMoviePlayer
	config(Menu);

var UIDataStore_Registry Registry;
var bool HasRunOnce;

var GFxClikWidget btnBack;

/** MAIN **/
var GFxClikWidget btnMainCampaign;
var GFxClikWidget btnMainSettings;
var GFxClikWidget btnMainControls;
var GFxClikWidget btnMainExit;

/** CAMPAIGN **/
var GFxClikWidget btnCampaignLaunch;
var GFxClikWidget lstCampaignMaps;
var GFxClikWidget bbCampaignDifficulty;
var GFxClikWidget lblCampaignDescription;

/** SETTINGS **/
var GFxClikWidget lstSettingsResolutions;
var GFxClikWidget lstSettingsFullscreen;
var GFxClikWidget lstSettingsPreset;
var GFxClikWidget lstSettingsAA;
var GFxClikWidget lstSettingsAF;
var GFxClikWidget lstSettingsGamma;
var GFxClikWidget btnSettingsApply;
var GFxClikWidget lblConfirmTimer;
var GFxClikWidget btnConfirmYes;
var GFxClikWidget btnConfirmNo;
var string RevertResolution;
var int RevertGraphicsPresetLevel;
var config int GraphicsPresetLevel;
var int RevertMaxMultiSamples;
var config int MaxMultiSamples;
var int RevertMaxAnisotropy;
var config int MaxAnisotropy;
var config float Gamma;
var config array<int> ListAAAF;

/** CONTROLS **/
var int CaptureBindIndex;
var int ActiveControlGroup;
var GFxClikWidget bbControlsGroup;
var GFxClikWidget lblControlsDescription;

var GFxClikWidget lstControlsNames;
var GFxClikWidget lstControlsBinds;

/** CONFIG **/
struct MapOption
{
    var string Filename; 
    var string Description; // This will be displayed in the list.
};
var config array<MapOption> CampaignMaps; 

struct Difficulty
{
    var string Level; 
    var string ButtonText;
	var string Description;
};
var config array<Difficulty> Difficulties; 

var config array<string> Resolutions;

struct BindAlias
{
	var config string Command;
	var config string Alias;
};
struct BindGroup
{
	var config string ButtonText;
	var config string Description;
	var config array<BindAlias> BindingList;
};
var config array<BindGroup> BindingGroup;

/** Called on start **/
function bool Start (optional bool StartPaused = false)
{
	CaptureBindIndex = -1;

	super.Start();
	Advance(0);

	SetAlignment(Align_Center);
	SetViewScaleMode(SM_ShowAll);
	
	RunOnce();
	
	return true;
}

function RunOnce()
{
	if (HasRunOnce == false)
	{
		ConsoleCommand("Scale Level" @ GraphicsPresetLevel);
		ConsoleCommand("Scale Set MaxMultiSamples" @ ListAAAF[MaxMultiSamples]);
		ConsoleCommand("Scale Set MaxAnisotropy" @ ListAAAF[MaxAnisotropy]);
		ConsoleCommand("Gamma" @ Gamma);
		HasRunOnce = true;
	}
}
/** Called when a CLIK Widget is initialized **/
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch (WidgetName)
	{
		case ('btnMainExit'):
			btnMainExit = GFxClikWidget(Widget);
			btnMainExit.AddEventListener('CLIK_press', ExitGame);
			break;
		case ('btnCampaignLaunch'):
			btnCampaignLaunch = GFxClikWidget(Widget);
			btnCampaignLaunch.AddEventListener('CLIK_press', OnCampaignLaunchPress);
			break;
		case ('lstCampaignMaps'):
			lstCampaignMaps = GFxClikWidget(Widget);
			SetUpDataProvider(lstCampaignMaps);
			break;
		case ('bbCampaignDifficulty'):
			bbCampaignDifficulty = GFxClikWidget(Widget);
			SetUpDataProvider(bbCampaignDifficulty);
			bbCampaignDifficulty.AddEventListener('CLIK_change', OnCampaignDifficultyChange);
			bbCampaignDifficulty.SetFloat("selectedIndex", 1); // Normal
			break;
		case ('lblCampaignDescription'):
			lblCampaignDescription = GFxClikWidget(Widget);
			break;
		case ('btnSettingsApply'):
			btnSettingsApply = GFxClikWidget(Widget);
			btnSettingsApply.AddEventListener('CLIK_press', OnSettingsApplyPress);
			break;
		case ('lstSettingsResolutions'):
			lstSettingsResolutions = GFxClikWidget(Widget);
			SetUpDataProvider(lstSettingsResolutions);
			lstSettingsResolutions.SetFloat("rowCount", Resolutions.Length);
			lstSettingsResolutions.SetFloat("selectedIndex", GetCurrentResolutionIndex());
			break;
		case ('lstSettingsFullscreen'):
			lstSettingsFullscreen = GFxClikWidget(Widget);
			SetUpDataProvider(lstSettingsFullscreen);
			lstSettingsFullscreen.SetFloat("selectedIndex", int(GetGameViewportClient().IsFullScreenViewport()));
			break;
		case ('lstSettingsPreset'):
			lstSettingsPreset = GFxClikWidget(Widget);
			SetUpDataProvider(lstSettingsPreset);
			lstSettingsPreset.SetFloat("selectedIndex", GraphicsPresetLevel-1);
			break;
		case ('lstSettingsAA'):
			lstSettingsAA = GFxClikWidget(Widget);
			SetUpDataProvider(lstSettingsAA);
			lstSettingsAA.SetFloat("selectedIndex", MaxMultiSamples);
			break;
		case ('lstSettingsAF'):
			lstSettingsAF = GFxClikWidget(Widget);
			SetUpDataProvider(lstSettingsAF);
			lstSettingsAF.SetFloat("selectedIndex", MaxAnisotropy);
			break;
		case ('lstSettingsGamma'):
			lstSettingsGamma = GFxClikWidget(Widget);
			SetUpDataProvider(lstSettingsGamma);
			lstSettingsGamma.SetFloat("value", Gamma);
			lstSettingsGamma.AddEventListener('CLIK_change', OnSettingsGammaChange);
			break;
		case ('btnConfirmYes'):
			btnConfirmYes = GFxClikWidget(Widget);
			btnConfirmYes.AddEventListener('CLIK_press', OnConfirmYesPress);
			break;
		case ('btnConfirmNo'):
			btnConfirmNo = GFxClikWidget(Widget);
			btnConfirmNo.AddEventListener('CLIK_press', OnConfirmNoPress);
			break;
		case ('lblControlsDescription'):
			lblControlsDescription = GFxClikWidget(Widget);
			lblControlsDescription.SetText(BindingGroup[ActiveControlGroup].Description);
			break;
		case ('bbControlsGroup'):
			bbControlsGroup = GFxClikWidget(Widget);
			SetUpDataProvider(bbControlsGroup);
			bbControlsGroup.AddEventListener('CLIK_change', OnControlsGroupChange);
			bbControlsGroup.SetFloat("selectedIndex", ActiveControlGroup);
			break;
		case ('lstControlsNames'):
			lstControlsNames = GFxClikWidget(Widget);
			SetUpDataProvider(lstControlsNames);
			break;
		case ('lstControlsBinds'):
			lstControlsBinds = GFxClikWidget(Widget);
			SetUpDataProvider(lstControlsBinds);
			lstControlsBinds.AddEventListener('CLIK_change', OnControlsListPress);
			break;
		default:
			return false;
			break;
	}
	return true;
}

/** Populates dropdowns, selection lists, and button groups with appropriate data **/
function SetUpDataProvider(GFxClikWidget Widget)
{
    local byte i;
    local GFxObject DataProvider;

    DataProvider = CreateArray();
    switch(Widget)
    {
        case (lstCampaignMaps):
			for (i = 0; i < CampaignMaps.Length; i++)
			{
				DataProvider.SetElementString(i, CampaignMaps[i].Description);
			}
			break;
		case (bbCampaignDifficulty):
			for (i = 0; i < Difficulties.Length; i++)
			{
				DataProvider.SetElementString(i, Difficulties[i].ButtonText);
			}
			break;
		case (lstSettingsResolutions):
			for (i = 0; i < Resolutions.Length; i++)
			{
				DataProvider.SetElementString(i, Resolutions[i]);
			}
			break;
		case (lstSettingsFullscreen):
			DataProvider.SetElementString(0,"Windowed");
			DataProvider.SetElementString(1,"Fullscreen");
			break;
		case (lstSettingsPreset):
			DataProvider.SetElementString(0,"Lowest");
			DataProvider.SetElementString(1,"Low");
			DataProvider.SetElementString(2,"Medium");
			DataProvider.SetElementString(3,"High");
			DataProvider.SetElementString(4,"Highest");
			break;
		case (lstSettingsAA):
		case (lstSettingsAF):
			for (i = 0; i < ListAAAF.Length+1; i++)
			{
				DataProvider.SetElementString(i, ListAAAF[i] $ "x");
			}
			break;
		case (bbControlsGroup):
			for (i = 0; i < BindingGroup.Length; i++)
			{
				DataProvider.SetElementString(i, BindingGroup[i].ButtonText);
			}
			break;
		case (lstControlsNames):
			for (i = 0; i < BindingGroup[ActiveControlGroup].BindingList.Length; i++)
			{
				DataProvider.SetElementString(i, BindingGroup[ActiveControlGroup].BindingList[i].Alias);
			}
			break;
		case (lstControlsBinds):
			for (i = 0; i < BindingGroup[ActiveControlGroup].BindingList.Length; i++)
			{
				DataProvider.SetElementString(i, CAPS(GetBoundKey(BindingGroup[ActiveControlGroup].BindingList[i].Command)));
			}
			break;
		default:
			return;
    }
    Widget.SetObject("dataProvider", DataProvider);   
}

/** Returns the current resolution as an index from the supported resolutions list **/
function int GetCurrentResolutionIndex()
{
	local Vector2D size;
	local string resolution;

	GetGameViewportClient().GetViewportSize(size);
	resolution = int(size.X) $ "x" $ int(size.Y);
	return Resolutions.Find(resolution);
}

/** Called when somebody clicks a keybinding on the controls screen **/
function OnControlsListPress(GFxClikWidget.EventData ev)
{
	// Don't prompt for new key if not valid bind; occurs when the current binding group list is short
	if (ev.index < 0 || ev.index > BindingGroup[ActiveControlGroup].BindingList.Length - 1)
	{
		return;
	}
	LogToConsole("Requesting new key for: " @ BindingGroup[ActiveControlGroup].BindingList[ev.index].Alias);
	// Sends the menu into 'key capture' mode -- maybe I should make this a state
	CaptureBindIndex = ev.index;
	ActionScriptVoid("OpenCaptureScreen");
}

/** Returns the first button bound to a given command **/
function name GetBoundKey(string Command)
{
		local byte i;
		local PlayerInput PInput;

		PInput = GetPC().PlayerInput;

        for (i = 0; i < PInput.Bindings.Length; i++)
        {
                if (PInput.Bindings[i].Command == Command)
                {
                        return PInput.Bindings[i].Name;
                }                       
        }
}

/** Loads the selected map **/
function OnCampaignLaunchPress(GFxClikWidget.EventData ev)
{
	local int MapIndex;
	local string MapName;
	
	MapIndex = lstCampaignMaps.GetFloat("selectedIndex");
	MapName = CampaignMaps[MapIndex].Filename;
	
	ConsoleCommand("open" @ MapName);
}

/** Updates difficulty description when a difficulty is selected **/
function OnCampaignDifficultyChange(GFxClikWidget.EventData ev)
{
	Registry.SetData("BotSkill", Difficulties[ev.index].Level);
	lblCampaignDescription.SetText(Difficulties[ev.index].Description);
}

/** Returns the current difficulty as an index of the difficulties array **/
function int GetCurrentDifficultyIndex()
{
	local string level;
	local byte i;

	level = GetStringFromMarkup("BotSkill");
	// Would use Difficulties.find(), but find() is case sensitive
	for (i=0;i<Difficulties.Length;i++)
	{
		// Case insensitive
		if (Difficulties[i].Level ~= level)
		{
			return i;
		}
	}
	return -1;
}

/** Gets global configuration settings -- borrowed from UDK example code **/
static function String GetStringFromMarkup(String MarkupString)
{
    local String RetVal;
	local UIDataStore_Registry xRegistry;
    RetVal = "";
	xRegistry = UIDataStore_Registry(class'UIRoot'.static.StaticResolveDataStore('Registry'));
    xRegistry.GetData(MarkupString, RetVal);
    return RetVal;
}

/** Updates the controls list when controls group selected **/
function OnControlsGroupChange(GFxClikWidget.EventData ev)
{
	ActiveControlGroup = int(bbControlsGroup.GetFloat("selectedIndex"));
	lblControlsDescription.SetText(BindingGroup[ActiveControlGroup].Description);
	SetUpDataProvider(lstControlsNames);
	SetUpDataProvider(lstControlsBinds);
}

/** Called when somebody plays with the gamma slider **/
function OnSettingsGammaChange(GFxClikWidget.EventData ev)
{
	Gamma = lstSettingsGamma.GetFloat("value");
	ConsoleCommand("Gamma" @ Gamma);
	SaveConfig();
}

/** Applies graphics settings **/
function OnSettingsApplyPress(GFxClikWidget.EventData ev)
{
	local string NewResolution;
	local int ResolutionIndex;
	local bool IsFullscreen;
	local Vector2D size;

	// Make it so the button does not stay highlighted
	btnSettingsApply.SetBool("selected",false);

	// Prepare for revert
	GetGameViewportClient().GetViewportSize(size);
	RevertResolution = int(size.X) $ "x" $ int(size.Y) $ (GetGameViewportClient().IsFullScreenViewport() ? "f" : "w");
	RevertGraphicsPresetLevel = GraphicsPresetLevel;

	// Set graphics level
	GraphicsPresetLevel = int(lstSettingsPreset.GetFloat("selectedIndex")) + 1;
	ConsoleCommand("Scale Level" @ GraphicsPresetLevel);

	// Set AA & AF
	RevertMaxMultiSamples = MaxMultiSamples;
	MaxMultiSamples = lstSettingsAA.GetFloat("selectedIndex");
	RevertMaxAnisotropy = MaxAnisotropy;
	MaxAnisotropy = lstSettingsAF.GetFloat("selectedIndex");

	// Set new resolution
	ResolutionIndex = lstSettingsResolutions.GetFloat("selectedIndex");
	IsFullscreen = (lstSettingsFullscreen.GetFloat("selectedIndex") > 0);
	NewResolution = Resolutions[ResolutionIndex] $ (IsFullscreen ? "f" : "w");
	ConsoleCommand("setres" @ NewResolution);

	// Refresh the gui or setres fails -- March 2011
	Close(false);
	Start(false);

	// Starts a 15 second timer
	class'WorldInfo'.static.GetWorldInfo().SetTimer(0.1, False, 'MyFunc', Self);

	ActionScriptVoid("OpenConfirmSettingsScreen");
}

/** Reverts the graphics settings
 *  
 *  I had hoped to keep all code in unrealscript, but the movieplayer class does not support timers.
 *  Therefore, the swf file handles the timer and calls this method when it expires.
 *  
 **/
function RevertGraphics()
{
	GraphicsPresetLevel = RevertGraphicsPresetLevel;
	MaxMultiSamples = RevertMaxMultiSamples;
	MaxAnisotropy = RevertMaxAnisotropy;
	ConsoleCommand("Scale Level" @ GraphicsPresetLevel);
	ConsoleCommand("setres" @ RevertResolution);
	ConsoleCommand("Scale Set MaxMultiSamples" @ ListAAAF[MaxMultiSamples]);
	ConsoleCommand("Scale Set MaxAnisotropy" @ ListAAAF[MaxAnisotropy]);
	Close(false);
	Start(false);
	ActionScriptVoid("OpenSettingsScreen");
}

/** Reverts graphics changes by user request **/
function OnConfirmNoPress(GFxClikWidget.EventData ev)
{
	ActionScriptVoid("StopTimer");
	RevertGraphics();
}
/** Confirms graphics settings **/
function OnConfirmYesPress(GFxClikWidget.EventData ev)
{
	SaveConfig();
	RevertGraphicsPresetLevel = GraphicsPresetLevel;
	RevertMaxMultiSamples = MaxMultiSamples;
	RevertMaxAnisotropy = MaxAnisotropy;
	RevertResolution = "";
	ActionScriptVoid("StopTimer");
	ActionScriptVoid("OpenSettingsScreen");
}
/** Grants Kane total world domination **/
function ExitGame(GFxClikWidget.EventData ev)
{
	ConsoleCommand("exit");
}
/** Called whenever a button is pressed **/
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	//local array<string> Konami;
	//Konami = ["Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "B", "A", "Enter"];
	// Only handle keypress if we are expecting one
	if (self.CaptureBindIndex > -1 && InputEvent == IE_Pressed)
	{
		if (ButtonName != 'Escape')
		{
			BindKey(ButtonName, BindingGroup[ActiveControlGroup].BindingList[CaptureBindIndex].Command);
		}
		self.CaptureBindIndex = -1;
		ActionScriptVoid("OpenControlsScreen");
		return true;
	}
	return false;
}

/** Binds a key to a command **/
function BindKey(Name KeyName, String Command)
{
	local PlayerInput PInput;
	local KeyBind NewKeyBind;
	local name PreviousBinding;

	PreviousBinding = GetBoundKey(Command);

	LogToConsole(" Binding key '" $ KeyName $ "' to command '" $ Command $ "' instead of '"$ PreviousBinding $"'");

	PInput = GetPC().PlayerInput;

	// Unbind what used to be bound to this command.
	UnbindKey(PreviousBinding);
	// Unbind the new key to whatever it may have been bound to.
 	UnbindKey(KeyName);

	NewKeyBind.Command = Command;
	NewKeyBind.Name = KeyName;
	// Bind the Key	
	PInput.Bindings[PInput.Bindings.length] = NewKeyBind;
	
	PInput.SaveConfig();
}

/** Unbinds the specified key. */
function UnbindKey(name BindName)
{
	local PlayerInput PInput;
	local int BindingIdx;

	PInput = GetPC().PlayerInput;

	for(BindingIdx = 0;BindingIdx < PInput.Bindings.Length;BindingIdx++)
	{
		if(PInput.Bindings[BindingIdx].Name == BindName)
		{
			PInput.Bindings.Remove(BindingIdx, 1);
			//break;
		}
	}
}


/** 
 *  Routes a console command through the player's PlayerController
 *  
 *  @param Command - The console command to run
 */
function ConsoleCommand( string Command )
{
	LogToConsole("Command: " $ Command);
	super.ConsoleCommand(Command);
}

/** Prints stuff to the console since `Log() no longer works**/
function LogToConsole(string message)
{
	GetGameViewportClient().ViewportConsole.OutputText(message);
}

defaultproperties
{
	WidgetBindings.Add((WidgetName="btnBack",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnMainCampaign",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnMainSettings",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnMainControls",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnMainExit",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="bbCampaignDifficulty",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblCampaignDescription",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCampaignLaunch",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstCampaignMaps",WidgetClass=class'GFxClikWidget'))
	
	WidgetBindings.Add((WidgetName="btnSettingsApply",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstSettingsFullscreen",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstSettingsResolutions",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstSettingsPreset",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstSettingsAA",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstSettingsAF",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstSettingsGamma",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblConfirmTimer",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnConfirmYes",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnConfirmNo",WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="bbControlsGroup",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblControlsDescription",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstControlsNames",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lstControlsBinds",WidgetClass=class'GFxClikWidget'))

    //SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'UDKFrontEnd.Sound.SoundTheme')
	
    bDisplayWithHudOff=TRUE
    //MovieInfo=SwfMovie'RenXFrontEnd_old.RenXFrontEnd_old'
	bPauseGameWhileActive=FALSE
	bCaptureInput=true
}