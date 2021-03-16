class Rx_GFxPauseMenu_SettingsMenu extends Rx_GFxPauseMenu_View
	config(Menu);

var Rx_GFxPauseMenu PauseMenu;

/************************************
*  Settings                         *
************************************/
var GFxClikWidget SettingsVideoActionBar;
var GFxClikWidget ScreenResolutionDropDown;
var GFxClikWidget ScreenModeDropDown;
var GFxClikWidget GraphicPresetsDropDown;
var GFxClikWidget AntiAliasingDropDown;
var GFxClikWidget TextureFilteringDropDown;
var GFxClikWidget BrightnessSlider;
var GFxClikWidget BrightnessLabel;
var GFxClikWidget FPSSlider;
var GFxClikWidget FPSLabel;
var GFxClikWidget VSyncCheckBox;
var GFxClikWidget Dx10CheckBox;
var GFxClikWidget MotionBlurCheckBox;
var GFxClikWidget DynamicLightsCheckBox;
var GFxClikWidget DynamicShadowsCheckBox;
var GFxClikWidget TextureDetailDropDown;
var GFxClikWidget DetailLevelDropDown;
var GFxClikWidget CharacterLODDropDown;
var GFxClikWidget EffectsLODDropDown;
var GFxClikWidget ShadowQualityDropDown;
var GFxClikWidget EnabledGoreCheckBox;
var GFxClikWidget FOVSlider;
var GFxClikWidget FOVLabel;
var GFxClikWidget LightEnvironmentShadowsCheckBox;
var GFxClikWidget CompositeDynamicLightsCheckBox;
var GFxClikWidget DirectionalLightmapsCheckBox;
var GFxClikWidget BloomDoFCheckBox;
var GFxClikWidget AmbientOcclusionCheckBox;
var GFxClikWidget LensFlaresCheckBox;
var GFxClikWidget BloomSlider;
var GFxClikWidget BloomLabel;
var GFxClikWidget DistortionCheckBox;
var GFxClikWidget ParticleDistortionDroppingCheckBox;
var GFxClikWidget StaticDecalsCheckBox;
var GFxClikWidget DynamicDecalsCheckBox;
var GFxClikWidget FramerateSmoothingCheckBox;

var GFxClikWidget SFXVolumeSlider;
var GFxClikWidget SFXVolumeLabel;
var GFxClikWidget MusicVolumeSlider;
var GFxClikWidget MusicVolumeLabel;
var GFxClikWidget AmbianceVolumeSlider;
var GFxClikWidget AmbianceVolumeLabel;
var GFxClikWidget DialogueVolumeSlider;
var GFxClikWidget DialogueVolumeLabel;
var GFxClikWidget AnnouncerVolumeSlider;
var GFxClikWidget AnnouncerVolumeLabel;
var GFxClikWidget HardwareOpenALCheckBox;
var GFxClikWidget AutoplayMusicCheckBox;

var GFxClikWidget PlayerControlGroup;
var GFxClikWidget PlayButton;
var GFxClikWidget StopButton;
var GFxClikWidget ShuffleButton;
var GFxClikWidget MusicTrackScrollBar;
var GFxClikWidget MusicTracklist;
var GFxClikWidget TrackNameLabel;
var GFxClikWidget SettingsAudioActionBar;

var GFxClikWidget MouseSensitivitySlider;
var GFxClikWidget MouseSensitivityInput;
var GFxClikWidget GamepadSensitivitySlider;
var GFxClikWidget GamepadSensitivityInput;
var GFxClikWidget MouseSmoothingCheckBox;
var GFxClikWidget InvertYCheckBox;
var GFxClikWidget WeaponHandDropDown;
var GFxClikWidget TankReverseCheckBox;
var GFxClikWidget ToggleADSCheckBox;
var GFxClikWidget UseClassicTeamNameColorsCheckBox;
var GFxClikWidget KeyBindingList;
var GFxClikWidget BindingPrimaryList;
var GFxClikWidget BindingSecondaryList;
var GFxClikWidget keyBindScroll;
var GFxClikWidget SettingsInputActionBar;

//nBab
// var GFxClikWidget TechBuildingIconDropDown;
var GFxClikWidget BeaconIconDropDown;
var GFxClikWidget CrosshairColorDropDown;
var GFxClikWidget AllowD3D9MSAACheckBox;
var GFxClikWidget UseHardwarePhysicsCheckBox;
var GFxClikWidget KillSoundDropDown;
var GFxClikWidget MusicCheckBoxlist;
var GFxClikWidget KillSoundPlayButton;

//UI - Handepsilon
var GFxClikWidget HUDScaleLabel;
var GFxClikWidget HUDScaleSlider;
var GFxClikWidget MinimapCheckBox;
var GFxClikWidget GameInfoCheckBox;
var GFxClikWidget TeamInfoCheckBox;
var GFxClikWidget PersonalInfoCheckBox;
var GFxClikWidget NoPTSceneCheckBox;
var GFxClikWidget ScorePanelCheckBox;
var GFxClikWidget RadioCommandDropDown;

var GFxClikWidget CustomRadioCurrent;
var GFxClikWidget CustomRadioNextButton;
var GFxClikWidget CustomRadioPrevButton;

var Array<GFxClikWidget> CustomRadioDropDown;

var GFxClikWidget SettingsInterfaceActionBar;

struct SettingsVideoOption
{
	var int ScreenResolutionItemPosition;
	var int ScreenModeItemPosition;
	var int GraphicPresetsItemPosition;
	var int AntiAliasingItemPosition;
	var int TextureFilteringItemPosition;
	var int BrightnessValue;
	var int FPSValue;
	var bool bVSync;
	var bool bDx10;
	var bool bMotionBlur;
	var bool bDynamicLights;
	var bool bDynamicShadows;
	var int TextureDetailItemPosition;
	var int DetailLevelItemPosition;
	var int CharacterLODItemPosition;
	var int EffectsLODItemPosition;
	var int ShadowQualityItemPosition;
	var bool bEnableGore;
	var int FOVValue;
	var bool bLightEnvironmentShadows;
	var bool bCompositeDynamicLights;
	var bool bDirectionalLightmaps;
	var bool bBloomDoF;
	var bool ProjectileLights;
	var float BloomValue;
	var bool bAmbientOcclusion;
	var bool bLensFlares;
	var bool bDistortion;
	var bool bParticleDistortionDropping;
	var bool bStaticDecals;
	var bool bDynamicDecals;
	var bool bFramerateSmoothing;
	//nBab
	var bool bAllowD3D9MSAA;
	var bool bUseHardwarePhysics;
};
var SettingsVideoOption SettingsCurrentVideo;


struct SettingsAudioOption
{
	var float SFXVolumeValue;
	var float MusicVolumeValue;
	var float AmbianceVolumeValue;
	var float CharacterVolumeValue;
	var float AnnouncerVolumeValue;
	var bool bHardwareOpenAL;
	var bool bAutostartMusic;
	//nBab
	var int KillSound;
};
var SettingsAudioOption SettingsCurrentAudio;

struct SettingsInputOption
{
	var int MouseSensitivityValue;
	var int GamepadSensitivityValue;
	var bool bMouseSmoothing;
	var bool bInvertY;
	var int WeaponHandItemPosition;
	var bool bTankReverse;
	var bool bADS;
	var bool bNicknamesUseTeamColors;
	var int KeyBingdingItemPosition;
	var int BindingPrimaryItemPosition;
	var int BindingSecondaryItemPosition;
	//nBab
//	var int TechBuildingIcon;
	var int BeaconIcon;
	var int CrosshairColor;
};
var SettingsInputOption SettingsCurrentInput;

struct SettingsInterfaceOption
{
	var float HUDScale;
	var bool bMinimap;
	var bool bGameInfo;
	var bool bTeamInfo;
	var bool bPersonalInfo;
	var bool bScorePanel;
	var int RadioCommand;
	var bool bDisablePTScene;

	var int CustomRadioCurrentPosition;
	var Array<int> RadioCommandsCtrl, RadioCommandsAlt, RadioCommandsCtrlAlt;
};

var SettingsInterfaceOption SettingsCurrentInterface;

/************************************
*  CONFIG                           *
************************************/



var array<string> Resolutions;

var config array<string> ListAA;

struct BindAlias
{
	var config string Command;
	var config string Alias;
};
// struct BindGroup
// {
// 	var config string ButtonText;
// 	var config string Description;
// 	var config array<BindAlias> BindingList;
// };
var config array<BindAlias> BindingList;

//Bind Renderer
var GFxClikWidget CurrentPrimaryListItemRenderer;
var string PreviousPrimaryListKey;
var GFxObject CurrentSecondaryListItemRenderer;
var string PreviousSecondaryListKey;

/** Configures the view when it is first loaded. */
function OnViewLoaded(Rx_GFxPauseMenu Menu)
{
	PauseMenu = Menu;

	if (Resolutions.Length <= 0) {
		Resolutions = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetAvailableResolutions();
	}
	ResetSettingsVideoOption();
	ResetSettingsAudioOption();
	ResetSettingsInputOption();
	ResetSettingsInterfaceOption();

	PlayerControlGroup = InitButtonGroupWidget("PlayerControlGroup", PauseMenu.SettingsView);
	PlayerControlGroup.AddEventListener('CLIK_change', OnPlayerControlGroupChange);

	if (GetPC().WorldInfo.MusicComp == none) {
		GetPC().WorldInfo.MusicComp = Rx_HUD(GetPC().myHUD).JukeBox.MusicComp;
	}
	GetPC().WorldInfo.MusicComp.OnAudioFinished = Rx_HUD(GetPC().myHUD).MusicPlayerOnAudioFinished;

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

function DeselectPlayerButtonGroup() 
{
	SetSelectedButton(none);
}

function SetSelectedButton  (GFxClikWidget button)
{
	PlayerControlGroup.ActionScriptVoid("setSelectedButton");
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local byte i;
	local string WidgetString;
	local int CustomRadioNumber;


	WidgetString = String(WidgetName);

	// to save time, handle the custom radio command here
	if(Left(Caps(WidgetString),19) == "CUSTOMRADIODROPDOWN")
	{
		if(CustomRadioDropDown.Length < 10)
			CustomRadioDropDown.Length = 10;

		CustomRadioNumber = int(Split(WidgetString,"CustomRadioDropDown", true));
//		`log(CustomRadioNumber);
		if(CustomRadioDropDown[CustomRadioNumber] == None || CustomRadioDropDown[CustomRadioNumber] != Widget)
		{
			CustomRadioDropDown[CustomRadioNumber] = GFxClikWidget(Widget);
		}
		RadioSetUpDataProvider(CustomRadioNumber);

		switch(CustomRadioNumber)
		{
			case 0:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownOneChange);
				break;
			case 1:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownTwoChange);
				break;
			case 2:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownThreeChange);
				break;
			case 3:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownFourChange);
				break;
			case 4:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownFiveChange);
				break;
			case 5:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownSixChange);
				break;
			case 6:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownSevenChange);
				break;
			case 7:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownEightChange);
				break;
			case 8:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownNineChange);
				break;
			case 9:
				CustomRadioDropDown[CustomRadioNumber].AddEventListener('CLIK_change', OnCustomRadioDropdownTenChange);
				break;
		}
		RadioGetLastSelection(CustomRadioNumber);

		return true;
	}
	
	switch(WidgetName)
	{

		/************************************* [Settings - Video] *****************************************/
		case 'SettingsVideoActionBar':
			if (SettingsVideoActionBar == none || SettingsVideoActionBar != Widget) {
				SettingsVideoActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SettingsVideoActionBar);
			SettingsVideoActionBar.AddEventListener('CLIK_itemClick', OnSettingsVideoActionItemClick);
			break;

		case 'ScreenResolutionDropDown':
			if (ScreenResolutionDropDown == none || ScreenResolutionDropDown != Widget) {
				ScreenResolutionDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ScreenResolutionDropDown);
			GetLastSelection(ScreenResolutionDropDown);
			ScreenResolutionDropDown.AddEventListener('CLIK_change', OnScreenResolutionDropDownChange);
			break;
		case 'ScreenModeDropDown':
			if (ScreenModeDropDown == none || ScreenModeDropDown != Widget) {
				ScreenModeDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ScreenModeDropDown);
			GetLastSelection(ScreenModeDropDown);
			ScreenModeDropDown.AddEventListener('CLIK_change', OnScreenModeDropDownChange);
			break;
		case 'GraphicPresetsDropDown':
			if (GraphicPresetsDropDown == none || GraphicPresetsDropDown != Widget) {
				GraphicPresetsDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(GraphicPresetsDropDown);
			GetLastSelection(GraphicPresetsDropDown);
			GraphicPresetsDropDown.AddEventListener('CLIK_change', OnGraphicPresetsDropDownChange);
			break;
		case 'AntiAliasingDropDown':
			if (AntiAliasingDropDown == none || AntiAliasingDropDown != Widget) {
				AntiAliasingDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(AntiAliasingDropDown);
			GetLastSelection(AntiAliasingDropDown);
			AntiAliasingDropDown.AddEventListener('CLIK_change', OnAntiAliasingDropDownChange);
			break;
		case 'TextureFilteringDropDown':  
			if (TextureFilteringDropDown == none || TextureFilteringDropDown != Widget) {
				TextureFilteringDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(TextureFilteringDropDown);
			GetLastSelection(TextureFilteringDropDown);
			TextureFilteringDropDown.AddEventListener('CLIK_change', OnTextureFilteringDropDownChange);
			break;
		case 'BrightnessSlider':    
			if (BrightnessSlider == none || BrightnessSlider != Widget) {
				BrightnessSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(BrightnessSlider);
			BrightnessSlider.AddEventListener('CLIK_change', OnBrightnessSliderChange);
			break;
		case 'BrightnessLabel':
			if (BrightnessLabel == none || BrightnessLabel != Widget) {
				BrightnessLabel = GFxClikWidget(Widget);
			}
			BrightnessLabel.SetText(SettingsCurrentVideo.BrightnessValue);
			break;
		case 'FPSSlider':    
			if (FPSSlider == none || FPSSlider != Widget) {
				FPSSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(FPSSlider);
			FPSSlider.AddEventListener('CLIK_change', OnFPSSliderChange);
			break;
		case 'FPSLabel':
			if (FPSLabel == none || FPSLabel != Widget) {
				FPSLabel = GFxClikWidget(Widget);
			}
			FPSLabel.SetText(SettingsCurrentVideo.FPSValue);
			break;
		case 'VSyncCheckBox':
			if (VSyncCheckBox == none || VSyncCheckBox != Widget) {
				VSyncCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(VSyncCheckBox);
			VSyncCheckBox.AddEventListener('CLIK_select', OnVSyncCheckBoxSelect);
			break;
		case 'Dx10CheckBox': //need to remove this.
			if (Dx10CheckBox == none || Dx10CheckBox != Widget) {
				Dx10CheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(Dx10CheckBox);
			Dx10CheckBox.AddEventListener('CLIK_select', OnDx10CheckBoxSelect);
			Dx10CheckBox.SetBool("disabled", true); //Temporary
			Dx10CheckBox.SetVisible(false);
			break;
		//nBab
		case 'AllowD3D9MSAACheckBox': 
			if (AllowD3D9MSAACheckBox == none || AllowD3D9MSAACheckBox != Widget) {
				AllowD3D9MSAACheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(AllowD3D9MSAACheckBox);
			AllowD3D9MSAACheckBox.AddEventListener('CLIK_select', OnAllowD3D9MSAACheckBoxSelect);
			break;
		//nBab
		case 'UseHardwarePhysicsCheckBox': 
			if (UseHardwarePhysicsCheckBox == none || UseHardwarePhysicsCheckBox != Widget) {
				UseHardwarePhysicsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(UseHardwarePhysicsCheckBox);
			UseHardwarePhysicsCheckBox.AddEventListener('CLIK_select', OnUseHardwarePhysicsCheckBoxSelect);
			break;
		case 'MotionBlurCheckBox':
			if (MotionBlurCheckBox == none || MotionBlurCheckBox != Widget) {
				MotionBlurCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(MotionBlurCheckBox);
			MotionBlurCheckBox.AddEventListener('CLIK_select', OnMotionBlurCheckBoxSelect);
			break;
		case 'DynamicLightsCheckBox':
			if (DynamicLightsCheckBox == none || DynamicLightsCheckBox != Widget) {
				DynamicLightsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DynamicLightsCheckBox);
			DynamicLightsCheckBox.AddEventListener('CLIK_select', OnDynamicLightsCheckBoxSelect);
			break;
		case 'DynamicShadowsCheckBox':
			if (DynamicShadowsCheckBox == none || DynamicShadowsCheckBox != Widget) {
				DynamicShadowsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DynamicShadowsCheckBox);
			DynamicShadowsCheckBox.AddEventListener('CLIK_select', OnDynamicShadowsCheckBoxSelect);
			//addeventlistener here
			break;
		case 'TextureDetailDropDown':
			if (TextureDetailDropDown == none || TextureDetailDropDown != Widget) {
				TextureDetailDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(TextureDetailDropDown);
			GetLastSelection(TextureDetailDropDown);
			TextureDetailDropDown.AddEventListener('CLIK_change', OnTextureDetailDropDownChange);
			break;
		case 'DetailLevelDropDown':
			if (DetailLevelDropDown == none || DetailLevelDropDown != Widget) {
				DetailLevelDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(DetailLevelDropDown);
			GetLastSelection(DetailLevelDropDown);
			DetailLevelDropDown.AddEventListener('CLIK_change', OnDetailLevelDropDownChange);
			break;
		case 'CharacterLODDropDown':
			if (CharacterLODDropDown == none || CharacterLODDropDown != Widget) {
				CharacterLODDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(CharacterLODDropDown);
			GetLastSelection(CharacterLODDropDown);
			CharacterLODDropDown.AddEventListener('CLIK_change', OnCharacterLODDropDownChange);
			break;
		case 'EffectsLODDropDown':
			if (EffectsLODDropDown == none || EffectsLODDropDown != Widget) {
				EffectsLODDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(EffectsLODDropDown);
			GetLastSelection(EffectsLODDropDown);
			EffectsLODDropDown.AddEventListener('CLIK_change', OnEffectsLODDropDownChange);
			break;
		case 'ShadowQualityDropDown':
			if (ShadowQualityDropDown == none || ShadowQualityDropDown != Widget) {
				ShadowQualityDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ShadowQualityDropDown);
			GetLastSelection(ShadowQualityDropDown);
			ShadowQualityDropDown.AddEventListener('CLIK_change', OnShadowQualityDropDownChange);
			break;
		case 'EnabledGoreCheckBox':
			if (EnabledGoreCheckBox == none || EnabledGoreCheckBox != Widget) {
				EnabledGoreCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(EnabledGoreCheckBox);
			EnabledGoreCheckBox.AddEventListener('CLIK_select', OnEnabledGoreCheckBoxSelect);
			break;
		case 'FOVSlider':
			if (FOVSlider == none || FOVSlider != Widget) {
				FOVSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(FOVSlider);
			FOVSlider.AddEventListener('CLIK_change', OnFOVSliderChange);
			FOVSlider.SetInt("minimum",60);
			FOVSlider.SetInt("maximum",120);
			break;
		case 'FOVLabel':
			if (FOVLabel == none || FOVLabel != Widget) {
				FOVLabel = GFxClikWidget(Widget);
			}
			FOVLabel.SetText(SettingsCurrentVideo.FOVValue);
			break;
		case 'LightEnvironmentShadowsCheckBox':
			if (LightEnvironmentShadowsCheckBox == none || LightEnvironmentShadowsCheckBox != Widget) {
				LightEnvironmentShadowsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(LightEnvironmentShadowsCheckBox);
			LightEnvironmentShadowsCheckBox.AddEventListener('CLIK_select', OnLightEnvironmentShadowsCheckBoxSelect);
			break;
		case 'CompositeDynamicLightsCheckBox':
			if (CompositeDynamicLightsCheckBox == none || CompositeDynamicLightsCheckBox != Widget) {
				CompositeDynamicLightsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(CompositeDynamicLightsCheckBox);
			CompositeDynamicLightsCheckBox.AddEventListener('CLIK_select', OnCompositeDynamicLightsCheckBoxSelect);
			break;
		case 'DirectionalLightmapsCheckBox':
			if (DirectionalLightmapsCheckBox == none || DirectionalLightmapsCheckBox != Widget) {
				DirectionalLightmapsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DirectionalLightmapsCheckBox);
			DirectionalLightmapsCheckBox.AddEventListener('CLIK_select', OnDirectionalLightmapsCheckBoxSelect);
			break;
		case 'BloomDoFCheckBox'://should bloom
			if (BloomDoFCheckBox == none || BloomDoFCheckBox != Widget) {
				BloomDoFCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(BloomDoFCheckBox);
			BloomDoFCheckBox.AddEventListener('CLIK_select', OnBloomDoFCheckBoxSelect);
			break;

		case 'BloomSlider':
			if (BloomSlider == none || BloomSlider != Widget) {
				BloomSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(BloomSlider);
			BloomSlider.AddEventListener('CLIK_change', OnBloomSliderChange);
			break;
		case 'BloomLabel':
			if (BloomLabel == none || BloomLabel != Widget) {
				BloomLabel = GFxClikWidget(Widget);
			}
			BloomLabel.SetText(Left(""$SettingsCurrentVideo.BloomValue, InStr(""$SettingsCurrentVideo.BloomValue, ".")+3));
			break;
		case 'AmbientOcclusionCheckBox'://should doF
			if (AmbientOcclusionCheckBox == none || AmbientOcclusionCheckBox != Widget) {
				AmbientOcclusionCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(AmbientOcclusionCheckBox);
			AmbientOcclusionCheckBox.AddEventListener('CLIK_select', OnAmbientOcclusionCheckBoxSelect);
			break;
		case 'LensFlaresCheckBox':
			if (LensFlaresCheckBox == none || LensFlaresCheckBox != Widget) {
				LensFlaresCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(LensFlaresCheckBox);
			LensFlaresCheckBox.AddEventListener('CLIK_select', OnLensFlaresCheckBoxSelect);
			break;
		case 'DistortionCheckBox':
			if (DistortionCheckBox == none || DistortionCheckBox != Widget) {
				DistortionCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DistortionCheckBox);
			DistortionCheckBox.AddEventListener('CLIK_select', OnDistortionCheckBoxSelect);
			break;
		case 'ParticleDistortionDroppingCheckBox':
			if (ParticleDistortionDroppingCheckBox == none || ParticleDistortionDroppingCheckBox != Widget) {
				ParticleDistortionDroppingCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(ParticleDistortionDroppingCheckBox);
			ParticleDistortionDroppingCheckBox.AddEventListener('CLIK_select', OnParticleDistortionDroppingCheckBoxSelect);
			break;
		case 'StaticDecalsCheckBox':
			if (StaticDecalsCheckBox == none || StaticDecalsCheckBox != Widget) {
				StaticDecalsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(StaticDecalsCheckBox);
			StaticDecalsCheckBox.AddEventListener('CLIK_select', OnStaticDecalsCheckBoxSelect);
			break;
		case 'DynamicDecalsCheckBox':
			if (DynamicDecalsCheckBox == none || DynamicDecalsCheckBox != Widget) {
				DynamicDecalsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DynamicDecalsCheckBox);
			DynamicDecalsCheckBox.AddEventListener('CLIK_select', OnDynamicDecalsCheckBoxSelect);
			break;
		case 'FramerateSmoothingCheckBox':
			if (FramerateSmoothingCheckBox == none || FramerateSmoothingCheckBox != Widget) {
				FramerateSmoothingCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(FramerateSmoothingCheckBox);
			FramerateSmoothingCheckBox.AddEventListener('CLIK_select', OnFramerateSmoothingCheckBoxSelect);
			break;

		/************************************* [Settings - Audio] *****************************************/
		case'SFXVolumeSlider':
			if (SFXVolumeSlider == none || SFXVolumeSlider != Widget) {
				SFXVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(SFXVolumeSlider);
			SFXVolumeSlider.AddEventListener('CLIK_change', OnSFXVolumeSliderChange);
			break;
		case'SFXVolumeLabel':
			if (SFXVolumeLabel == none || SFXVolumeLabel != Widget) {
				SFXVolumeLabel = GFxClikWidget(Widget);
			}
			SFXVolumeLabel.SetText(int(SettingsCurrentAudio.SFXVolumeValue*100) $"%");
			break;
		case'MusicVolumeSlider':
			if (MusicVolumeSlider == none || MusicVolumeSlider != Widget) {
				MusicVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(MusicVolumeSlider);
			MusicVolumeSlider.AddEventListener('CLIK_change', OnMusicVolumeSliderChange);
			break;
		case'MusicVolumeLabel':
			if (MusicVolumeLabel == none || MusicVolumeLabel != Widget) {
				MusicVolumeLabel = GFxClikWidget(Widget);
			}
			MusicVolumeLabel.SetText(int(SettingsCurrentAudio.MusicVolumeValue*100) $"%");
			break;
		case'AmbianceVolumeSlider':
			if (AmbianceVolumeSlider == none || AmbianceVolumeSlider != Widget) {
				AmbianceVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(AmbianceVolumeSlider);
			AmbianceVolumeSlider.AddEventListener('CLIK_change', OnAmbianceVolumeSliderChange);
			break;
		case'AmbianceVolumeLabel':
			if (AmbianceVolumeLabel == none || AmbianceVolumeLabel != Widget) {
				AmbianceVolumeLabel = GFxClikWidget(Widget);
			}
			AmbianceVolumeLabel.SetText(int(SettingsCurrentAudio.AmbianceVolumeValue*100) $"%");
			break;
		case'DialogueVolumeSlider':
			if (DialogueVolumeSlider == none || DialogueVolumeSlider != Widget) {
				DialogueVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(DialogueVolumeSlider);
			DialogueVolumeSlider.AddEventListener('CLIK_change', OnCharacterVolumeSliderChange);
			break;
		case'DialogueVolumeLabel':
			if (DialogueVolumeLabel == none || DialogueVolumeLabel != Widget) {
				DialogueVolumeLabel = GFxClikWidget(Widget);
			}
			DialogueVolumeLabel.SetText(int(SettingsCurrentAudio.CharacterVolumeValue*100) $"%");
			break;
		case'AnnouncerVolumeSlider':
			if (AnnouncerVolumeSlider == none || AnnouncerVolumeSlider != Widget) {
				AnnouncerVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(AnnouncerVolumeSlider);
			AnnouncerVolumeSlider.AddEventListener('CLIK_change', OnAnnouncerVolumeSliderChange);
			break;
		case'AnnouncerVolumeLabel':
			if (AnnouncerVolumeLabel == none || AnnouncerVolumeLabel != Widget) {
				AnnouncerVolumeLabel = GFxClikWidget(Widget);
			}
			AnnouncerVolumeLabel.SetText(int(SettingsCurrentAudio.AnnouncerVolumeValue*100) $"%");
			break;
		case'HardwareOpenALCheckBox':
			if (HardwareOpenALCheckBox == none || HardwareOpenALCheckBox != Widget) {
				HardwareOpenALCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(HardwareOpenALCheckBox);
			HardwareOpenALCheckBox.AddEventListener('CLIK_select', OnHardwareOpenALCheckBoxSelect);
			HardwareOpenALCheckBox.SetBool("disabled", true);
			break;
		case'AutoplayMusicCheckBox':
			if (AutoplayMusicCheckBox == none || AutoplayMusicCheckBox != Widget) {
				AutoplayMusicCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(AutoplayMusicCheckBox);
			AutoplayMusicCheckBox.AddEventListener('CLIK_select', OnAutoplayMusicCheckBoxSelect);
			break;
		case'PlayButton':
			`log("PlayButton found");
			if (PlayButton == none || PlayButton != Widget) {
				PlayButton = GFxClikWidget(Widget);
 				PlayButton.SetObject("group", PlayerControlGroup);
			}
 			GetLastSelection(PlayButton);
			//PlayButton.AddEventListener('CLIK_select', OnPlayButtonSelect);
			break;
		case'StopButton':
			`log("StopButton found");
			if (StopButton == none || StopButton != Widget) {
				StopButton = GFxClikWidget(Widget);
				StopButton.SetObject("group", PlayerControlGroup);
			}
			GetLastSelection(StopButton);
			//StopButton.AddEventListener('CLIK_select', OnStopButtonSelect);
			break;
		case'ShuffleButton':
			`log("ShuffleButton found");
			if (ShuffleButton == none || ShuffleButton != Widget) {
				ShuffleButton = GFxClikWidget(Widget);
			}
 			GetLastSelection(ShuffleButton);
 			ShuffleButton.AddEventListener('CLIK_select', OnShuffleButtonSelect);
			break;
		case'MusicTrackScrollBar':
			`log("MusicTrackScrollBar found");
			if (MusicTrackScrollBar == none || MusicTrackScrollBar != Widget) {
				MusicTrackScrollBar = GFxClikWidget(Widget);
			}
			GetLastSelection(MusicTrackScrollBar);
			break;
		case'MusicTracklist':
			`log("MusicTracklist found");
			if (MusicTracklist == none || MusicTracklist != Widget) {
				MusicTracklist = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MusicTracklist);
 			GetLastSelection(MusicTracklist);
 			MusicTracklist.AddEventListener('CLIK_itemClick', OnMusicTracklistItemClick);
			break;
		//nBab
		case'MusicCheckBoxlist':
			`log("MusicCheckBoxlist found");
			if (MusicCheckBoxlist == none || MusicCheckBoxlist != Widget) {
				MusicCheckBoxlist = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MusicCheckBoxlist);
 			GetLastSelection(MusicCheckBoxlist);
 			MusicCheckBoxlist.AddEventListener('CLIK_itemClick', OnMusicCheckBoxlistItemClick);
			break;
		case'TrackNameLabel':
			`log("TrackNameLabel found");
			if (TrackNameLabel == none || TrackNameLabel != Widget) {
				TrackNameLabel = GFxClikWidget(Widget);
			}
			if (Rx_HUD(GetPC().myHUD).JukeBox.CurrentTrack.TheSoundCue == none)
				TrackNameLabel.SetText("");	
			else
			{	
				i = Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
				if (i >= 0 ) {
					TrackNameLabel.SetText(Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[i].TrackName);
				} else {
					if (Rx_HUD(GetPC().myHUD).JukeBox.CurrentTrack.TrackName != "") {
						TrackNameLabel.SetText(Rx_HUD(GetPC().myHUD).JukeBox.CurrentTrack.TrackName);
					} else {
						TrackNameLabel.SetText("");			
					} 
				}
			}
			break;
		case'SettingsAudioActionBar':
			if (SettingsAudioActionBar == none || SettingsAudioActionBar != Widget) {
				SettingsAudioActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SettingsAudioActionBar);
			SettingsAudioActionBar.AddEventListener('CLIK_itemClick', OnSettingsAudioActionBarChange);
			break;
		//setting kill sound widget (nBab)
		case 'KillSoundDropDown':
			if (KillSoundDropDown == none || KillSoundDropDown != Widget) {
				KillSoundDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(KillSoundDropDown);
			GetLastSelection(KillSoundDropDown);
			KillSoundDropDown.AddEventListener('CLIK_change', OnKillSoundDropDownChange);
			break;
		//setting kill sound play button widget (nBab)
		case 'KillSoundPlayButton':
			if (KillSoundPlayButton == none || KillSoundPlayButton != Widget) {
				KillSoundPlayButton = GFxClikWidget(Widget);
			}
			GetLastSelection(KillSoundPlayButton);
			KillSoundPlayButton.AddEventListener('CLIK_click', OnKillSoundPlayButtonChange);
			break;

		/************************************* [Settings - Input] *****************************************/

		case 'MouseSensitivitySlider':
			if (MouseSensitivitySlider == none || MouseSensitivitySlider != Widget) {
				MouseSensitivitySlider = GFxClikWidget(Widget);
			}
			GetLastSelection(MouseSensitivitySlider);
			MouseSensitivitySlider.AddEventListener('CLIK_change', OnMouseSensitivitySliderChange);
			break;
		case 'MouseSensitivityInput':
			if (MouseSensitivityInput == none || MouseSensitivityInput != Widget) {
				MouseSensitivityInput = GFxClikWidget(Widget);
			}
			GetLastSelection(MouseSensitivityInput);
			MouseSensitivityInput.AddEventListener('CLIK_focusIn', OnMouseSensitivityInputFocusIn);
			MouseSensitivityInput.AddEventListener('CLIK_focusOut', OnMouseSensitivityInputFocusOut);
			MouseSensitivityInput.AddEventListener('CLIK_textChange', OnMouseSensitivityInputTextChange);
			break;
		case 'GamepadSensitivitySlider':
			if (GamepadSensitivitySlider == none || GamepadSensitivitySlider != Widget) {
				GamepadSensitivitySlider = GFxClikWidget(Widget);
			}
			GetLastSelection(GamepadSensitivitySlider);
			GamepadSensitivitySlider.AddEventListener('CLIK_change', OnGamepadSensitivitySliderChange);
			GamepadSensitivitySlider.SetBool("disabled", true);
			break;
		case 'GamepadSensitivityInput':
			if (GamepadSensitivityInput == none || GamepadSensitivityInput != Widget) {
				GamepadSensitivityInput = GFxClikWidget(Widget);
			}
			GetLastSelection(GamepadSensitivityInput);
			GamepadSensitivityInput.AddEventListener('CLIK_focusIn', OnGamepadSensitivityInputFocusIn);
			GamepadSensitivityInput.AddEventListener('CLIK_focusOut', OnGamepadSensitivityInputFocusOut);
			GamepadSensitivityInput.AddEventListener('CLIK_textChange', OnGamepadSensitivityInputTextChange);
			GamepadSensitivityInput.SetBool("disabled", true);
			break;
		case 'MouseSmoothingCheckBox':
			if (MouseSmoothingCheckBox == none || MouseSmoothingCheckBox != Widget) {
				MouseSmoothingCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(MouseSmoothingCheckBox);
			MouseSmoothingCheckBox.AddEventListener('CLIK_select', OnMouseSmoothingCheckBoxSelect);
			break;
		case 'InvertYCheckBox':
			if (InvertYCheckBox == none || InvertYCheckBox != Widget) {
				InvertYCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(InvertYCheckBox);
			InvertYCheckBox.AddEventListener('CLIK_select', OnInvertYCheckBoxSelect);
			break;
		case 'WeaponHandDropDown':
			if (WeaponHandDropDown == none || WeaponHandDropDown != Widget) {
				WeaponHandDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(WeaponHandDropDown);
			GetLastSelection(WeaponHandDropDown);
			WeaponHandDropDown.AddEventListener('CLIK_change', OnWeaponHandDropDownChange);
			break;
		case 'TankReverseCheckBox':
			if (TankReverseCheckBox == none || TankReverseCheckBox != Widget) {
				TankReverseCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(TankReverseCheckBox);
			TankReverseCheckBox.AddEventListener('CLIK_select', OnTankReverseCheckBoxSelect);
			break;
		case 'ToggleADSCheckBox':
			if (ToggleADSCheckBox == none || ToggleADSCheckBox != Widget) {
				ToggleADSCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(ToggleADSCheckBox);
			ToggleADSCheckBox.AddEventListener('CLIK_select', OnToggleADSCheckBoxSelect);
			break;
		case 'UseClassicTeamNameColorsCheckBox':
			if (UseClassicTeamNameColorsCheckBox == none || UseClassicTeamNameColorsCheckBox != Widget) {
				UseClassicTeamNameColorsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(UseClassicTeamNameColorsCheckBox);
			UseClassicTeamNameColorsCheckBox.AddEventListener('CLIK_select', OnUseClassicTeamNameColorsCheckBoxSelect);
			break;
		case 'KeyBindingList':
			if (KeyBindingList == none || KeyBindingList != Widget) {
				KeyBindingList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(KeyBindingList);
			GetLastSelection(KeyBindingList);
			break;
		case 'BindingPrimaryList':
			if (BindingPrimaryList == none || BindingPrimaryList != Widget) {
				BindingPrimaryList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(BindingPrimaryList);
			GetLastSelection(BindingPrimaryList);
			BindingPrimaryList.AddEventListener('CLIK_itemClick', OnBindingPrimaryListItemClick);
			break;
		case 'BindingSecondaryList':
			if (BindingSecondaryList == none || BindingSecondaryList != Widget) {
				BindingSecondaryList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(BindingSecondaryList);
			GetLastSelection(BindingSecondaryList);
			BindingSecondaryList.AddEventListener('CLIK_itemClick', OnBindingSecondaryListItemClick);
			BindingSecondaryList.SetBool("disabled", true);
			BindingSecondaryList.SetVisible(false);
			break;
		case 'keyBindScroll':
			if (keyBindScroll == none || keyBindScroll != Widget) {
				keyBindScroll = GFxClikWidget(Widget);
			}
			keyBindScroll.SetVisible(false);
			break;
		case 'SettingsInputActionBar':
			if (SettingsInputActionBar == none || SettingsInputActionBar != Widget) {
				SettingsInputActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SettingsInputActionBar);
			SettingsInputActionBar.AddEventListener('CLIK_itemClick', OnSettingsInputActionBarChange);
			break;
		//setting tech building icon widget (nBab)

		/*
		case 'TechBuildingIconDropDown':
			if (TechBuildingIconDropDown == none || TechBuildingIconDropDown != Widget) {
				TechBuildingIconDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(TechBuildingIconDropDown);
			GetLastSelection(TechBuildingIconDropDown);
			TechBuildingIconDropDown.AddEventListener('CLIK_change', OnTechBuildingIconDropDownChange);
			TechBuildingIconDropDown.SetBool("disabled", true);
			break;
		*/

		case 'RadioCommandDropDown':
			if (RadioCommandDropDown == none || RadioCommandDropDown != Widget) {
				RadioCommandDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(RadioCommandDropDown);
			GetLastSelection(RadioCommandDropDown);
			RadioCommandDropDown.AddEventListener('CLIK_change', OnRadioCommandDropDownChange);
//			RadioCommandDropDown.SetBool("disabled", true);
			break;

		//setting beacon icon widget (nBab)
		case 'BeaconIconDropDown':
			if (BeaconIconDropDown == none || BeaconIconDropDown != Widget) {
				BeaconIconDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(BeaconIconDropDown);
			GetLastSelection(BeaconIconDropDown);
			BeaconIconDropDown.AddEventListener('CLIK_change', OnBeaconIconDropDownChange);
			break;
		//setting crosshair color widget (nBab)
		case 'CrosshairColorDropDown':
			if (CrosshairColorDropDown == none || CrosshairColorDropDown != Widget) {
				CrosshairColorDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(CrosshairColorDropDown);
			GetLastSelection(CrosshairColorDropDown);
			CrosshairColorDropDown.AddEventListener('CLIK_change', OnCrosshairColorDropDownChange);
			break;
		//setting crosshair color text widget (nBab)
		case 'CrosshairColorText':
			Widget.setText("Crosshair Color:");
			break;
		//setting beacon icon text widget (nBab)
		case 'BeaconIconText':
			Widget.setText("Beacon Icon:");
			break;
		//setting tech building icon text widget (nBab)
//		case 'TechBuildingIconText':
//			Widget.setText("Tech Building Icon:");
//			break;
		//setting use hardware physics text widget (nBab)
		case 'UseHardwarePhysicsText':
			Widget.setText("Use Hardware PhysX:");
			break;
		//setting allow d3d9msaa text widget (nBab)
		case 'AllowD3D9MSAAText':
			Widget.setText("Allow D3D9 MSAA:");
			break;
		//setting kill sound text widget (nBab)
		case 'KillSoundText':
			Widget.setText("Kill Sound:");
			break;
		case 'HUDScaleLabel':
			if (HUDScaleLabel == none || HUDScaleLabel != Widget) {
				HUDScaleLabel = GFxClikWidget(Widget);
			}
			HUDScaleLabel.SetText(int(SettingsCurrentInterface.HUDScale)@"%");
			break;
		case 'HUDScaleSlider':
			if (HUDScaleSlider == none || HUDScaleSlider != Widget) {
				HUDScaleSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(HUDScaleSlider);
			HUDScaleSlider.AddEventListener('CLIK_change', OnHUDScaleSliderChange);
			break;
		case 'MinimapCheckBox':
			if (MinimapCheckBox == none || MinimapCheckBox != Widget) {
				MinimapCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(MinimapCheckBox);
			MinimapCheckBox.AddEventListener('CLIK_select', OnMinimapCheckBoxSelect);
			break;
		case 'GameInfoCheckBox':
			if (GameInfoCheckBox == none || GameInfoCheckBox != Widget) {
				GameInfoCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(GameInfoCheckBox);
			GameInfoCheckBox.AddEventListener('CLIK_select', OnGameInfoCheckBoxSelect);
			break;
		case 'TeamInfoCheckBox':
			if (TeamInfoCheckBox == none || TeamInfoCheckBox != Widget) {
				TeamInfoCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(TeamInfoCheckBox);
			TeamInfoCheckBox.AddEventListener('CLIK_select', OnTeamInfoCheckBoxSelect);
			break;
		case 'PersonalInfoCheckBox':
			if (PersonalInfoCheckBox == none || PersonalInfoCheckBox != Widget) {
				PersonalInfoCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(PersonalInfoCheckBox);
			PersonalInfoCheckBox.AddEventListener('CLIK_select', OnPersonalInfoCheckBoxSelect);
			break;
		case 'NoPTSceneCheckBox':
			if (NoPTSceneCheckBox == none || NoPTSceneCheckBox != Widget) {
				NoPTSceneCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(NoPTSceneCheckBox);
			NoPTSceneCheckBox.AddEventListener('CLIK_select', OnNoPTSceneCheckBoxSelect);
			break;
		case 'ScorePanelCheckBox':
			if (ScorePanelCheckBox == none || ScorePanelCheckBox != Widget) {
				ScorePanelCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(ScorePanelCheckBox);
			ScorePanelCheckBox.AddEventListener('CLIK_select', OnScorePanelCheckBoxSelect);
			break;
		case 'CustomRadioCurrent':
			if(CustomRadioCurrent == None || CustomRadioCurrent != Widget)
			{
				CustomRadioCurrent = GFxClikWidget(Widget);
			}
			UpdateCustomRadioLabel();
			break;
		case 'CustomRadioNextButton':
			if(CustomRadioNextButton == None || CustomRadioNextButton != Widget)
			{
				CustomRadioNextButton = GFxClikWidget(Widget);
			}
			CustomRadioNextButton.AddEventListener('CLIK_click', OnCustomRadioNextButtonClick);
			break;

		case 'CustomRadioPrevButton':
			if(CustomRadioPrevButton == None || CustomRadioPrevButton != Widget)
			{
				CustomRadioPrevButton = GFxClikWidget(Widget);
			}
			CustomRadioPrevButton.SetBool("disabled", true);
			CustomRadioPrevButton.AddEventListener('CLIK_click', OnCustomRadioPrevButtonClick);
			break;
		case 'SettingsInterfaceActionBar':
			if (SettingsInterfaceActionBar == none || SettingsInterfaceActionBar != Widget) {
				SettingsInterfaceActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SettingsInterfaceActionBar);
			SettingsInterfaceActionBar.AddEventListener('CLIK_itemClick', OnSettingsInterfaceActionBarChange);
			break;
		default:
			`log("Unknown Widget: " $ WidgetName);
			return false;
	}
	return true;
}

function SetUpDataProvider(GFxClikWidget Widget)
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	DataProvider = CreateArray();
	switch (Widget)
	{

		/************************************* [Settings - Video] *****************************************/

		case (SettingsVideoActionBar) :
			DataProvider.SetElementString(0, "BACK");
			DataProvider.SetElementString(1, "APPLY");
			break;

		case (ScreenResolutionDropDown) :
			for(i = 0; i < Resolutions.Length; i++) 			{
				DataProvider.SetElementString(i, Resolutions[i]);
			}
			break;
		case (ScreenModeDropDown) :
			DataProvider.SetElementString(0, Caps("FullScreen"));
			DataProvider.SetElementString(1, Caps("Windowed"));
			break;
		case (GraphicPresetsDropDown) :
			DataProvider.SetElementString(0, Caps("Custom"));
			DataProvider.SetElementString(1, Caps("Very Low"));
			DataProvider.SetElementString(2, Caps("Low"));
			DataProvider.SetElementString(3, Caps("Medium"));
			DataProvider.SetElementString(4, Caps("High"));
			DataProvider.SetElementString(5, Caps("Very High"));
			DataProvider.SetElementString(6, Caps("Ultra"));
			break;
		case (AntiAliasingDropDown):
			for(i = 0; i < 5; i++) {
				DataProvider.SetElementString(i, ListAA[i]);
			}
			
			if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck != none) {
				if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_Nvidia) {
					for(i = 5; i < ListAA.Length - 1; i++) {
						DataProvider.SetElementString(i, ListAA[i]);
					}
				} else if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_AMD) {
					DataProvider.SetElementString(5, ListAA[ListAA.Length-1]);
				}
			}
			break;
		case (TextureFilteringDropDown):
			DataProvider.SetElementString(0, Caps("Low"));
			DataProvider.SetElementString(1, Caps("Normal"));
			DataProvider.SetElementString(2, Caps("High"));
			DataProvider.SetElementString(3, Caps("Ultra"));
			break;
		case (TextureDetailDropDown) :
			DataProvider.SetElementString(0, Caps("Very Low"));
			DataProvider.SetElementString(1, Caps("Low"));
			DataProvider.SetElementString(2, Caps("Medium"));
			DataProvider.SetElementString(3, Caps("High"));
			DataProvider.SetElementString(4, Caps("Ultra"));
			break;
		case (DetailLevelDropDown) :
			DataProvider.SetElementString(0, Caps("Low"));
			DataProvider.SetElementString(1, Caps("Medium"));
			DataProvider.SetElementString(2, Caps("High"));
			DataProvider.SetElementString(3, Caps("Very High"));
			break;
		case (CharacterLODDropDown) :
			DataProvider.SetElementString(0, Caps("Low"));
			DataProvider.SetElementString(1, Caps("Medium"));
			DataProvider.SetElementString(2, Caps("High"));
			DataProvider.SetElementString(3, Caps("Very High"));

			break;
		case (EffectsLODDropDown) :
			DataProvider.SetElementString(0, Caps("Low"));
			DataProvider.SetElementString(1, Caps("Medium"));
			DataProvider.SetElementString(2, Caps("High"));
			DataProvider.SetElementString(3, Caps("Very High"));
			break;
		case (ShadowQualityDropDown) :
			DataProvider.SetElementString(0, Caps("Low"));
			DataProvider.SetElementString(1, Caps("Medium"));
			DataProvider.SetElementString(2, Caps("High"));
			DataProvider.SetElementString(3, Caps("Very High"));
			break;

		/************************************* [Settings - Audio] *****************************************/

		case (SettingsAudioActionBar):
			DataProvider.SetElementString(0, "BACK");
			DataProvider.SetElementString(1, "APPLY");
			break;
		case (MusicTracklist):
			//TODO: find a way to get the audio data

			/*	::Example::
			 *	
			 *	MusicTracklist.dataProvider = [
					{label:"one", toggled:true},
					{label:"three", toggled:false},
					{label:"four", toggled:true},
					{label:"five", toggled:true},
					{label:"six", toggled:false},
					{label:"seven", toggled:false},
					{label:"eight", toggled:false},
					{label:"nine", toggled:true},
					{label:"ten", toggled:true},
					{label:"potato", toggled:false},
					{label:"apple", toggled:true},
					{label:"twinkies", toggled:false},
					{label:"03 - Command and Conquer", toggled:true},
					{label:"pirates", toggled:false}
				];
			*/
			//place1
			for(i=0; i < Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Length; i++) {
				TempObj = CreateObject("Object");
				`log("Data.label :: JukeBox.JukeBoxList["$ i $"] : "$ Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[i].TrackName);
 				TempObj.SetString("label", (i+1) $ " - " $ Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[i].TrackName);
 				//removed toggle since we're using a separate checkbox list (nBab)
 				DataProvider.SetElementObject(i, TempObj);
			}

			break;
		//setting music checkbox list data provider (nBab)
		case (MusicCheckBoxlist):
			for(i=0; i < Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Length; i++) {
				TempObj = CreateObject("Object");
				TempObj.SetBool("toggled", Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[i].bSelected);
				DataProvider.SetElementObject(i, TempObj);
			}
			break;
		//setting kill sound data provider (nBab)
		case (KillSoundDropDown):
			DataProvider.SetElementString(0, "BOINK");
			DataProvider.SetElementString(1, "MODERN");
			DataProvider.SetElementString(2, "KILL ALERT");
			DataProvider.SetElementString(3, "COMMANDO");
			DataProvider.SetElementString(4, "HAVOC");
			DataProvider.SetElementString(5, "MCFARLAND");
			DataProvider.SetElementString(6, "GOTCHYA");
			DataProvider.SetElementString(7, "AWW TOO EASY");
			DataProvider.SetElementString(8, "FOR KANE");
			DataProvider.SetElementString(9, "DIE INFIDEL");
			DataProvider.SetElementString(10, "GOAT");
			DataProvider.SetElementString(11, "CUSTOM");
			DataProvider.SetElementString(12, "NONE");
			break;

		/************************************* [Settings - Input] *****************************************/

		case (KeyBindingList):

			for (i=0; i < BindingList.Length; i++)
			{
				DataProvider.SetElementString(i,BindingList[i].Alias);
			}
			//TODO: Get Total Binding List
			if (BindingList.Length > Widget.Getint("rowCount"))
			{
				if (keyBindScroll != none)
					keyBindScroll.SetVisible(true);
			}
			else
			{
				DataProvider.SetInt("rowCount", BindingList.Length);
				if (keyBindScroll != none)
					keyBindScroll.SetVisible(false);
			}
			break;

		case (BindingPrimaryList):
			for (i=0; i < BindingList.Length; i++) {
				DataProvider.SetElementString(i,Rx_PlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand(BindingList[i].Command));
			}

			if (BindingList.Length > Widget.Getint("rowCount")) {
				if (keyBindScroll != none)
					keyBindScroll.SetVisible(true);
			} else {
				DataProvider.SetInt("rowCount", BindingList.Length);
				if (keyBindScroll != none) {
					keyBindScroll.SetVisible(false);
				}					
			}
			break;

		case (BindingSecondaryList):
			for (i=0; i < BindingList.Length; i++)
			{
				DataProvider.SetElementString(i,UDKPlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand(BindingList[i].Command));
			}

			if (BindingList.Length > Widget.Getint("rowCount"))
			{
				if (keyBindScroll != none)
					keyBindScroll.SetVisible(true);
			}
			else
			{
				DataProvider.SetInt("rowCount", BindingList.Length);
				if (keyBindScroll != none)
					keyBindScroll.SetVisible(false);
			}
			break;
		case (WeaponHandDropDown):
			DataProvider.SetElementString(0, "RIGHT");
			DataProvider.SetElementString(1, "LEFT");
			break;
		case (SettingsInputActionBar):
			DataProvider.SetElementString(0, "BACK");
			DataProvider.SetElementString(1, "APPLY");
			break;
		//setting tech building icon data provider (nBab)
//		case (TechBuildingIconDropDown):
//			DataProvider.SetElementString(0, "ANIMATING");
//			DataProvider.SetElementString(1, "COLOR CHANGING");
//			DataProvider.SetElementString(2, "NONE");
//			break;
		//setting radio command data provider
		case (RadioCommandDropDown):
			DataProvider.SetElementString(0, "NEW");
			DataProvider.SetElementString(1, "CLASSIC");
			DataProvider.SetElementString(2, "CUSTOM");
			break;
		//setting beacon icon data provider (nBab)
		case (BeaconIconDropDown):
			DataProvider.SetElementString(0, "NUKE/ION");
			DataProvider.SetElementString(1, "STAR");
			break;
		//setting crosshair color data provider (nBab)
		case (CrosshairColorDropDown):
			DataProvider.SetElementString(0, "WHITE");
			DataProvider.SetElementString(1, "ORANGE");
			DataProvider.SetElementString(2, "VIOLET");
			DataProvider.SetElementString(3, "BLUE");
			DataProvider.SetElementString(4, "CYAN");
			break;
		case (SettingsInterfaceActionBar) :
			DataProvider.SetElementString(0, "BACK");
			DataProvider.SetElementString(1, "APPLY");
			break;
		default:
			return;
	}
	Widget.SetObject("dataProvider", DataProvider);
}

function RadioSetUpDataProvider(int Num)
{
	local GFxObject DataProvider;
	local Rx_Controller C;
	local string RadioStringList;
	local int i;

	C = Rx_Controller(GetPC());

	if(C == None)
		return;

	i = 0;

	DataProvider = CreateArray();
	foreach C.RadioCommandsText(RadioStringList)
	{
		DataProvider.SetElementString(i, RadioStringList);
		i++;
	}
	DataProvider.SetElementString(i, "--NONE--");

	CustomRadioDropDown[Num].SetBool("disabled",(SettingsCurrentInterface.RadioCommand != 2));
	CustomRadioDropDown[Num].SetObject("dataProvider", DataProvider);
}

function GetLastSelection(GFxClikWidget Widget)
{
	local byte i;
	if (Widget != none) {
		switch (Widget)
		{
			/************************************* [Settings - Video] *****************************************/
			case (ScreenResolutionDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.ScreenResolutionItemPosition);
				break;
			case (ScreenModeDropDown):
				//SettingsCurrentVideo.ScreenModeItemPosition = MainFrontEnd.SystemSettingsHandler.IsFullScreen() ? 0 : 1;
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.ScreenModeItemPosition);
				break;
			case (GraphicPresetsDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.GraphicPresetsItemPosition);
				break;
			case (AntiAliasingDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.AntiAliasingItemPosition);
				break;
			case (TextureFilteringDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.TextureFilteringItemPosition);
				break;
			case (BrightnessSlider) :
				Widget.SetInt("value", SettingsCurrentVideo.BrightnessValue);
				break;
			case (VSyncCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bVSync);
				break;
			case (Dx10CheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bDx10);
				break;
			//nBab
			case (AllowD3D9MSAACheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bAllowD3D9MSAA);
				break;
			//nBab
			case (UseHardwarePhysicsCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bUseHardwarePhysics);
				break;
			case (MotionBlurCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bMotionBlur);
				break;
			case (DynamicLightsCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bDynamicLights);
				break;
			case (DynamicShadowsCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bDynamicShadows);
				break;
			case (TextureDetailDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.TextureDetailItemPosition);
				break;
			case (DetailLevelDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.DetailLevelItemPosition);
				break;
			case (CharacterLODDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.CharacterLODItemPosition);
				break;
			case (EffectsLODDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.EffectsLODItemPosition);
				break;
			case (ShadowQualityDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.ShadowQualityItemPosition);
				break;
			case (EnabledGoreCheckBox):
				Widget.SetBool("selected",!SettingsCurrentVideo.bEnableGore);
				break;
			case (FOVSlider):
				Widget.SetInt("value", SettingsCurrentVideo.FOVValue);
				break;
			case (LightEnvironmentShadowsCheckBox):
				Widget.SetBool("selected",SettingsCurrentVideo.bLightEnvironmentShadows );
				break;
			case (CompositeDynamicLightsCheckBox):
				Widget.SetBool("selected",SettingsCurrentVideo.bCompositeDynamicLights);
				break;
			case (DirectionalLightmapsCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bDirectionalLightmaps);
				break;
			case (BloomDoFCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.ProjectileLights);
				break;
			case (BloomSlider):
				Widget.SetInt("value", SettingsCurrentVideo.BloomValue * 100);
				break;
			case (AmbientOcclusionCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bAmbientOcclusion);
				break;
			case (LensFlaresCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bLensFlares);
				break;
			case (DistortionCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bDistortion);
				break;
			case (ParticleDistortionDroppingCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bParticleDistortionDropping);
				break;
			case (StaticDecalsCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bStaticDecals);
				break;
			case (DynamicDecalsCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bDynamicDecals);
				break;
			case (FramerateSmoothingCheckBox):
				Widget.SetBool("selected", SettingsCurrentVideo.bFramerateSmoothing);
				break;

			/************************************* [Settings - Audio] *****************************************/

			case (SFXVolumeSlider):
				Widget.SetInt("value", SettingsCurrentAudio.SFXVolumeValue * 100 );
				break;
			case (MusicVolumeSlider):
				Widget.SetInt("value", SettingsCurrentAudio.MusicVolumeValue * 100 );
				break;
			case (AmbianceVolumeSlider):
				Widget.SetInt("value", SettingsCurrentAudio.AmbianceVolumeValue * 100 );
				break;
			case (DialogueVolumeSlider):
				Widget.SetInt("value", SettingsCurrentAudio.CharacterVolumeValue * 100 );
				break;
			case (AnnouncerVolumeSlider):
				Widget.SetInt("value", SettingsCurrentAudio.AnnouncerVolumeValue * 100 );
				break;
			case (HardwareOpenALCheckBox):
				Widget.SetBool("selected", SettingsCurrentAudio.bHardwareOpenAL );
				break;
			case (AutoplayMusicCheckBox):
				Widget.SetBool("selected", SettingsCurrentAudio.bAutostartMusic);
				break;
			case (PlayButton):
 				if (GetPC().WorldInfo.MusicComp.IsPlaying()) {
 					//lets check if we're playing our track
					i = Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
 					if (i >= 0) {
 						Widget.SetBool("selected", true);
 					} else {
 						Widget.SetBool("selected", false);
 					}
				} else {
					Widget.SetBool("selected", false);
 				}
				break;
			case (StopButton):

 				Widget.SetBool("selected", false);

// 				if (GetPC().WorldInfo.MusicComp.IsPlaying()) {
// 					//lets check if we're playing our track
// 					if (Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue) >= 0) {
// 						Widget.SetBool("selected", false);
// 					} else {
// 						Widget.SetBool("selected", true);
// 					}
// 				} else {
// 					Widget.SetBool("selected", true);
// 				}
				break;
			case (ShuffleButton):
				//settingsaudio is shuffled
				Widget.SetBool("selected", Rx_HUD(GetPC().myHUD).JukeBox.bShuffled);
				break;
			case (MusicTrackScrollBar):
				break;
			case (MusicTracklist):

				if (Widget.GetBool("disabled")) {
					return;
				}
				//added check in case nothing is playing (nBab)
				if (Rx_HUD(GetPC().myHUD).JukeBox.CurrentTrack.TheSoundCue == none)
					return;
				i = Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
				if (i >=0){
					Widget.SetInt("selectedIndex", i);
				} else {
					Widget.SetInt("selectedIndex", 0);
				}
				break;
			//nBab
			case (MusicCheckBoxlist):

				if (Widget.GetBool("disabled")) {
					return;
				}
				if (Rx_HUD(GetPC().myHUD).JukeBox.CurrentTrack.TheSoundCue == none)
					return;
				i = Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
				if (i >=0){
					Widget.SetInt("selectedIndex", i);
				} else {
					Widget.SetInt("selectedIndex", 0);
				}
				break;
			//nBab
			case (KillSoundDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentAudio.KillSound);
				break;
			//nBab
			case (KillSoundPlayButton) :
				Widget.SetBool("selected", false);
				break;
			/************************************* [Settings - Input] *****************************************/

			case (MouseSensitivitySlider) :
				Widget.SetInt("value", SettingsCurrentInput.MouseSensitivityValue);
				break;
			case (MouseSensitivityInput) :
				Widget.SetText(""$SettingsCurrentInput.MouseSensitivityValue);
				break;
			case (GamepadSensitivitySlider) :
				Widget.SetInt("value", SettingsCurrentInput.GamepadSensitivityValue);
				break;
			case (GamepadSensitivityInput) :
				Widget.SetText(""$SettingsCurrentInput.GamepadSensitivityValue);
				break;
			case (MouseSmoothingCheckBox):
				Widget.SetBool("selected", SettingsCurrentInput.bMouseSmoothing);
				break;
			case (InvertYCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInput.bInvertY);
				break;
			case (WeaponHandDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentInput.WeaponHandItemPosition);
				break;
			case (TankReverseCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInput.bTankReverse);
				break;
			case (ToggleADSCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInput.bADS);
				break;
			case (UseClassicTeamNameColorsCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInput.bNicknamesUseTeamColors);
				break;
			case (KeyBindingList) :
				Widget.SetInt("selectedIndex", -1);
				break;
			case (BindingPrimaryList) :
				Widget.SetInt("selectedIndex", -1);
				break;
			case (BindingSecondaryList) :
				Widget.SetInt("selectedIndex", -1);
				break;
			//nBab
//			case (TechBuildingIconDropDown) :
//				Widget.SetInt("selectedIndex", SettingsCurrentInput.TechBuildingIcon);
//				break;
			case (RadioCommandDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentInterface.RadioCommand);
				break;
			//nBab
			case (BeaconIconDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentInput.BeaconIcon);
				break;
			//nBab
			case (CrosshairColorDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentInput.CrosshairColor);
				break;

			case (HUDScaleSlider) :
				Widget.SetInt("value", SettingsCurrentInterface.HUDScale);
				break;
			case (MinimapCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInterface.bMinimap);
				break;			
			case (GameInfoCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInterface.bGameInfo);
				break;
			case (TeamInfoCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInterface.bTeamInfo);
				break;
			case (PersonalInfoCheckBox)	:		  
				Widget.SetBool("selected", SettingsCurrentInterface.bPersonalInfo);
				break;
			case (ScorePanelCheckBox) :			
				Widget.SetBool("selected", SettingsCurrentInterface.bScorePanel);
				break;		
			case (NoPTSceneCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInterface.bDisablePTScene);
				break;					

			default:
				return;
		}
	}
}


function RadioGetLastSelection(int i)
{
	switch(SettingsCurrentInterface.CustomRadioCurrentPosition)
	{
		case 0:
			CustomRadioDropDown[i].SetInt("selectedIndex",SettingsCurrentInterface.RadioCommandsCtrl[i]);
			break;
		case 1:
			CustomRadioDropDown[i].SetInt("selectedIndex",SettingsCurrentInterface.RadioCommandsAlt[i]);
			break;
		case 2:
			CustomRadioDropDown[i].SetInt("selectedIndex",SettingsCurrentInterface.RadioCommandsCtrlAlt[i]);
			break;
	}
}

function ResetSettingsVideoOption()
{
	local byte i;

	//Get Resolution Position
	for (i = 0; i < Resolutions.length; i++) {
		if (Resolutions[i] == Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetCurrentResolution()){
			SettingsCurrentVideo.ScreenResolutionItemPosition = i;
		}
	}

	//Get Screen Mode Position
	SettingsCurrentVideo.ScreenModeItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.IsFullScreen()? 0 : 1;

	//Get The Graphics Presets Position
	SettingsCurrentVideo.GraphicPresetsItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GraphicsPresetLevel;

	//SystemSettingsHandler.DefaultAAType (Formerly CurrentAATypeSelection )
	SettingsCurrentVideo.AntiAliasingItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CurrentAAType;
	
	//MainFrontEnd.SystemSettingsHandler.CurrentTextureFilteringSelection
	SettingsCurrentVideo.TextureFilteringItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.TextureFilteringLevel;

	SettingsCurrentVideo.TextureDetailItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.TexturePresetLevel;

	SettingsCurrentVideo.BrightnessValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetGammaSettings() * 20;
	SettingsCurrentVideo.bVSync = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.UseVsync;
	SettingsCurrentVideo.bDx10 = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AllowD3D10;                                                                 // Useful for Dx10...not working ATM
	//nBab
	SettingsCurrentVideo.bAllowD3D9MSAA = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bAllowD3D9MSAA;
	//nBab
	SettingsCurrentVideo.bUseHardwarePhysics = !Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetDisablePhysXHardwareSupport();
	SettingsCurrentVideo.bMotionBlur = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MotionBlur;
	SettingsCurrentVideo.bDynamicLights = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.DynamicLights;
	SettingsCurrentVideo.bDynamicShadows = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.DynamicShadows;
	SettingsCurrentVideo.DetailLevelItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.DetailMode;
	SettingsCurrentVideo.CharacterLODItemPosition = (3 - Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SkeletalMeshLODBias) ;
	SettingsCurrentVideo.EffectsLODItemPosition = (3 - Rx_HUD(GetPC().myHUD).SystemSettingsHandler.ParticleLODBias);
	SettingsCurrentVideo.ShadowQualityItemPosition = (3 - Rx_HUD(GetPC().myHUD).SystemSettingsHandler.ShadowFilterQualityBias);
	SettingsCurrentVideo.bEnableGore = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetEnableGore();                                                                                                  //TODO:disable this
	SettingsCurrentVideo.FOVValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetFOV();
	SettingsCurrentVideo.bLightEnvironmentShadows = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.LightEnvironmentShadows;
	SettingsCurrentVideo.bCompositeDynamicLights = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CompositeDynamicLights;
	SettingsCurrentVideo.bDirectionalLightmaps = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.DirectionalLightmaps;
	SettingsCurrentVideo.bBloomDoF = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.Bloom;
//	SettingsCurrentVideo.bBloomDoF = (Rx_HUD(GetPC().myHUD).SystemSettingsHandler.ProjectileLights || Rx_HUD(GetPC().myHUD).SystemSettingsHandler.ProjectileLights);
	SettingsCurrentVideo.bAmbientOcclusion = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AmbientOcclusion;                                                     //TODO: NOT WORKING ATM
	SettingsCurrentVideo.bLensFlares = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.LensFlares;
	SettingsCurrentVideo.BloomValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.BloomThresholdLevel;
	SettingsCurrentVideo.bDistortion = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.Distortion;
	SettingsCurrentVideo.bParticleDistortionDropping = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.DropParticleDistortion;
	SettingsCurrentVideo.bStaticDecals = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.StaticDecals;
	SettingsCurrentVideo.bDynamicDecals = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.DynamicDecals;
	SettingsCurrentVideo.bFramerateSmoothing = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetEnableSmoothFramerate();
}

//PLEASE CREATE A SPECIAL class TO GET THE CURRENT AUDIO ETC... OR RESEARCG
function ResetSettingsAudioOption()
{

	SettingsCurrentAudio.AmbianceVolumeValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AmbientSoundClass != none 
		? Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AmbientSoundClass.Properties.Volume
		: Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AmbientVolume;

	SettingsCurrentAudio.AnnouncerVolumeValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AnnouncerSoundClass != none 
		? Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AnnouncerSoundClass.Properties.Volume                       //TODO: PARSING ALL COMPONENTS;
		: Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AnnouncerVolume;

	SettingsCurrentAudio.CharacterVolumeValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler != none
		? Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CharacterSoundClass.Properties.Volume
		: Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CharacterVolume;

	SettingsCurrentAudio.MusicVolumeValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MusicSoundClass != none
		? Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MusicSoundClass.Properties.Volume
		: Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MusicVolume;

	SettingsCurrentAudio.SFXVolumeValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SFXSoundClass != none 
		? Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SFXSoundClass.Properties.Volume
		: Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SFXVolume;


	SettingsCurrentAudio.bHardwareOpenAL = false;                                                                                               //TODO: Research Hardware AL Settings                                                 //TODO: Research Hardware AL Settings
	SettingsCurrentAudio.bAutostartMusic = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bAutostartMusic;

	//nBab
	SettingsCurrentAudio.KillSound = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetKillSound();
}

function ResetSettingsInputOption()
{
	SettingsCurrentInput.bADS = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetToggleADS();
	//bNicknamesUseTeamColors
	SettingsCurrentInput.BindingPrimaryItemPosition = -1;
	SettingsCurrentInput.BindingSecondaryItemPosition = -1;
	SettingsCurrentInput.KeyBingdingItemPosition = -1;
	SettingsCurrentInput.bMouseSmoothing = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetEnableMouseSmoothing();
	SettingsCurrentInput.bInvertY = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetInvertYAxis();
	SettingsCurrentInput.bTankReverse = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetToggleTankReverse();
	SettingsCurrentInput.GamepadSensitivityValue = 0;                                                                                           //need to figure out 
	SettingsCurrentInput.MouseSensitivityValue = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetMouseSensitivity();
	SettingsCurrentInput.WeaponHandItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetWeaponHand();                                          //will be basing on UTPC Weapon Hand Preference

}

function ResetSettingsInterfaceOption()
{
	local Rx_HUD myHUD;

	myHUD = Rx_HUD(GetPC().myHUD);

	// if some people gets a bit naughty with the settings, clamp it up
	myHUD.SystemSettingsHandler.HUDScale = FClamp(Rx_HUD(GetPC().myHUD).SystemSettingsHandler.HUDScale ,75, 125);

	SettingsCurrentInterface.HUDScale = myHUD.SystemSettingsHandler.HUDScale;
	SettingsCurrentInterface.bMinimap = myHUD.SystemSettingsHandler.bMinimap;
	SettingsCurrentInterface.bGameInfo = myHUD.SystemSettingsHandler.bGameInfo;
	SettingsCurrentInterface.bTeamInfo = myHUD.SystemSettingsHandler.bTeamInfo;
	SettingsCurrentInterface.bPersonalInfo = myHUD.SystemSettingsHandler.bPersonalInfo;
	SettingsCurrentInterface.bScorePanel = myHUD.SystemSettingsHandler.bScorePanel;
	SettingsCurrentInterface.RadioCommand = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetRadioCommand();
	SettingsCurrentInterface.bDisablePTScene = myHUD.SystemSettingsHandler.bDisablePTScene;

	SettingsCurrentInput.bNicknamesUseTeamColors = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetNicknamesUseTeamColors();
	//nBab
//	SettingsCurrentInput.TechBuildingIcon = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetTechBuildingIcon();
	SettingsCurrentInput.BeaconIcon = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetBeaconIcon();
	SettingsCurrentInput.CrosshairColor = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetCrosshairColor();

	SettingsCurrentInterface.RadioCommandsCtrl = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.RadioCommandsCtrl;
	if(SettingsCurrentInterface.RadioCommandsCtrl.Length < 10)
		SettingsCurrentInterface.RadioCommandsCtrl.Length = 10;

	SettingsCurrentInterface.RadioCommandsAlt = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.RadioCommandsAlt;
	if(SettingsCurrentInterface.RadioCommandsAlt.Length < 10)
		SettingsCurrentInterface.RadioCommandsAlt.Length = 10;

	SettingsCurrentInterface.RadioCommandsCtrlAlt = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.RadioCommandsCtrlAlt;
	if(SettingsCurrentInterface.RadioCommandsCtrlAlt.Length < 10)
		SettingsCurrentInterface.RadioCommandsCtrlAlt.Length = 10;
}

function OpenConfirmApplyVideoSettingsDialog()
{
	PauseMenu.OpenConfirmApplyVideoSettingsDialog();
}
function OpenVideoSettingsSuccessAlertDialog()
{
	PauseMenu.OpenVideoSettingsSuccessAlertDialog();
}
function ApplyVideoSettings()
{

	//update resolution if there is a changes...
	ApplyResolutionChanges();

	// if there is a change in graphics preset, set scale bucket it and return
	// probably need to reparse it again and assign.
	if (SettingsCurrentVideo.GraphicPresetsItemPosition > 0) {
		ApplyPresetSettings();
	} else {
		ApplyCustomSettings();
	}

	OpenVideoSettingsSuccessAlertDialog();
}

function ApplyResolutionChanges()
{
	local string newResolution;
	local string newScreenMode;

	newResolution = Resolutions[SettingsCurrentVideo.ScreenResolutionItemPosition];
	newScreenMode = SettingsCurrentVideo.ScreenModeItemPosition == 0 ? "f" : "w";
	GetPC().ConsoleCommand("setres " $newResolution $newScreenMode);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.ResX = int(Left(newResolution, ( Len(newResolution) - Len( Split( newResolution,"x",false ) ) ) ));
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.ResY = int(Split(newResolution,"x",true));
	

	//here is where we set the dialog for confirmation...
}

function ApplyPresetSettings()
{
	//apply bucket settings
	//do a switch
	//then apply non bucket settings base on case
	//which is:
	//      custom AA
	//      gamma
	//      fov
	//      framerate smoothing
	//      hardware physics




	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetSettingBucket(SettingsCurrentVideo.GraphicPresetsItemPosition);

	switch (SettingsCurrentVideo.GraphicPresetsItemPosition)
	{
		case 1:
			SettingsCurrentVideo.AntiAliasingItemPosition = 0; // NO AA
			SettingsCurrentVideo.TextureFilteringItemPosition = 0;
			SettingsCurrentVideo.TextureDetailItemPosition = 0;
			SettingsCurrentVideo.BrightnessValue = 50;
			SettingsCurrentVideo.FOVValue = 90;
			SettingsCurrentVideo.bFramerateSmoothing = true;
			SettingsCurrentVideo.bAmbientOcclusion = false;
			SettingsCurrentVideo.bEnableGore = true;
			break;
		case 2:
			SettingsCurrentVideo.AntiAliasingItemPosition = 0; // MSAA 2X
			SettingsCurrentVideo.TextureFilteringItemPosition = 1;
			SettingsCurrentVideo.TextureDetailItemPosition = 1;
			SettingsCurrentVideo.BrightnessValue = 50;
			SettingsCurrentVideo.FOVValue = 90;
			SettingsCurrentVideo.bFramerateSmoothing = true;
			SettingsCurrentVideo.bAmbientOcclusion = false;
			SettingsCurrentVideo.bEnableGore = true;
			break;
		case 3:
			SettingsCurrentVideo.AntiAliasingItemPosition = 0; // MSAA 4X
			SettingsCurrentVideo.TextureFilteringItemPosition = 2;
			SettingsCurrentVideo.TextureDetailItemPosition = 2;
			SettingsCurrentVideo.BrightnessValue = 50;
			SettingsCurrentVideo.FOVValue = 90;
			SettingsCurrentVideo.bFramerateSmoothing = true;
			SettingsCurrentVideo.bAmbientOcclusion = false;
			SettingsCurrentVideo.bEnableGore = true;
			break;
		case 4:
			SettingsCurrentVideo.AntiAliasingItemPosition = 3; //MSAA 8X
			SettingsCurrentVideo.TextureFilteringItemPosition = 3;
			SettingsCurrentVideo.TextureDetailItemPosition = 3;
			SettingsCurrentVideo.BrightnessValue = 50;
			SettingsCurrentVideo.FOVValue = 90;
			SettingsCurrentVideo.bFramerateSmoothing = false;
			SettingsCurrentVideo.bAmbientOcclusion = false;
			SettingsCurrentVideo.bEnableGore = true;
			break;
		case 5:
			if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck != none) {
				if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_Nvidia) {
					SettingsCurrentVideo.AntiAliasingItemPosition = 8;
				} else if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_AMD) {
					SettingsCurrentVideo.AntiAliasingItemPosition = ListAA.Length - 1;
				} else {
					SettingsCurrentVideo.AntiAliasingItemPosition = 3;
				}
			}
			//SettingsCurrentVideo.AntiAliasingItemPosition = MainFrontEnd.SystemSettingsHandler.bAllowPostprocessMLAA ? 3 : 8; // MSAA 8X if MLAA Enabled, FXAA 3 for NVidia devices
			SettingsCurrentVideo.TextureFilteringItemPosition = 3;
			SettingsCurrentVideo.TextureDetailItemPosition = 3;
			SettingsCurrentVideo.BrightnessValue = 50;
			SettingsCurrentVideo.FOVValue = 90;
			SettingsCurrentVideo.bFramerateSmoothing = false;
			SettingsCurrentVideo.bAmbientOcclusion = false;
			SettingsCurrentVideo.bEnableGore = false;
			break;
		case 6:
			if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck != none) {
				if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_Nvidia) {
					SettingsCurrentVideo.AntiAliasingItemPosition = ListAA.Length-2;
				} else if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_AMD) {
					SettingsCurrentVideo.AntiAliasingItemPosition = ListAA.Length - 1;
				} else {
					SettingsCurrentVideo.AntiAliasingItemPosition = 4;
				}
			}
			//SettingsCurrentVideo.AntiAliasingItemPosition = MainFrontEnd.SystemSettingsHandler.bAllowPostprocessMLAA ? (ListAA.Length-1) : (ListAA.Length-2); // MLAA for AMD : FXAA 5 for NVidia
			SettingsCurrentVideo.TextureFilteringItemPosition = 3;
			SettingsCurrentVideo.TextureDetailItemPosition = 4;
			SettingsCurrentVideo.BrightnessValue = 50;
			SettingsCurrentVideo.FOVValue = 90;
			SettingsCurrentVideo.bFramerateSmoothing = false;
			SettingsCurrentVideo.bAmbientOcclusion = true;
			SettingsCurrentVideo.bEnableGore = false;
			break;
		default:
			break;
	}


	
	if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck != none) {
		if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_Nvidia) {
			Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		} else if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_AMD) {
			if (SettingsCurrentVideo.AntiAliasingItemPosition >= 5) {
				Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[ListAA.Length-1]);
			} else {
				Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
			}
		} else {
			Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		}
	}

	
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetGammaSettings(float(SettingsCurrentVideo.BrightnessValue)*0.05);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetFOV(float(SettingsCurrentVideo.FOVValue));
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAmbientOcclusion(SettingsCurrentVideo.bAmbientOcclusion);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetEnableSmoothFramerate(SettingsCurrentVideo.bFramerateSmoothing);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetEnableGore(SettingsCurrentVideo.bEnableGore);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GraphicsPresetLevel = SettingsCurrentVideo.GraphicPresetsItemPosition;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.TexturePresetLevel = SettingsCurrentVideo.TextureDetailItemPosition;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CurrentAAType = SettingsCurrentVideo.AntiAliasingItemPosition;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.TextureFilteringLevel = SettingsCurrentVideo.TextureFilteringItemPosition;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SaveConfig();


	ResetSettingsVideoOption();

	GetLastSelection(ScreenResolutionDropDown);
	GetLastSelection(ScreenModeDropDown);
	GetLastSelection(AntiAliasingDropDown);
	GetLastSelection(TextureFilteringDropDown);
	GetLastSelection(BrightnessSlider);
	if (BrightnessLabel != none) {
		BrightnessLabel.SetText(SettingsCurrentVideo.BrightnessValue $ "%");
	}
	GetLastSelection(FPSSlider);
	if (FPSLabel != none) {
		FPSLabel.SetText(SettingsCurrentVideo.FPSValue $ "%");
	}
	//nBab
	GetLastSelection(AllowD3D9MSAACheckBox);
	//nBab
	GetLastSelection(UseHardwarePhysicsCheckBox);
	GetLastSelection(VSyncCheckBox);
	GetLastSelection(MotionBlurCheckBox);
	GetLastSelection(DynamicLightsCheckBox);
	GetLastSelection(DynamicShadowsCheckBox);
	GetLastSelection(TextureDetailDropDown);
	GetLastSelection(DetailLevelDropDown);
	GetLastSelection(CharacterLODDropDown);
	GetLastSelection(EffectsLODDropDown);
	GetLastSelection(ShadowQualityDropDown);
	GetLastSelection(EnabledGoreCheckBox);
	GetLastSelection(FOVSlider);
	if (FOVLabel != none) {
		FOVLabel.SetText(SettingsCurrentVideo.FOVValue);
	}
	GetLastSelection(LightEnvironmentShadowsCheckBox);
	GetLastSelection(CompositeDynamicLightsCheckBox);
	GetLastSelection(DirectionalLightmapsCheckBox);
	GetLastSelection(BloomDoFCheckBox);

	GetLastSelection(BloomSlider);
	if (BloomLabel != none) {
		BloomLabel.SetText(Left(""$SettingsCurrentVideo.BloomValue, InStr(""$SettingsCurrentVideo.BloomValue, ".")+3));
	}
	GetLastSelection(AmbientOcclusionCheckBox);//!
	GetLastSelection(LensFlaresCheckBox);
	GetLastSelection(DistortionCheckBox);
	GetLastSelection(ParticleDistortionDroppingCheckBox);
	GetLastSelection(StaticDecalsCheckBox);
	GetLastSelection(DynamicDecalsCheckBox);
	GetLastSelection(FramerateSmoothingCheckBox);

	if (SettingsCurrentVideo.GraphicPresetsItemPosition != Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GraphicsPresetLevel) {
		SettingsCurrentVideo.GraphicPresetsItemPosition = Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GraphicsPresetLevel;
		GetLastSelection(GraphicPresetsDropDown);
	}

	return;
}

function ApplyCustomSettings()
{
	//if its a custom setting, then we set it per-componenets

	//AA	
	if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck != none) {
		if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_Nvidia) {
			Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		} else if (Rx_HUD(GetPC().myHUD).GraphicAdapterCheck.EVendor == V_AMD) {
			if (SettingsCurrentVideo.AntiAliasingItemPosition >= 5) {
				Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[ListAA.Length-1]);
			} else {
				Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
			}
		} else {
			Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		}
	}

	//TexFil
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetTextureFiltering(SettingsCurrentVideo.TextureFilteringItemPosition);

	//Gamma
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetGammaSettings(float(SettingsCurrentVideo.BrightnessValue)*0.05);

	//Vsync
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetUseVsync(SettingsCurrentVideo.bVSync);

	//AllowD3D9MSAA (nBab)
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetbAllowD3D9MSAA(SettingsCurrentVideo.bAllowD3D9MSAA);

	//UseHardwarePhysics (nBab)
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDisablePhysXHardwareSupport(!SettingsCurrentVideo.bUseHardwarePhysics);

	//MainFrontEnd.SystemSettingsHandler.SetAllowD3D10(SettingsCurrentVideo.bDx10);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetMotionBlur(SettingsCurrentVideo.bMotionBlur);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDynamicLights(SettingsCurrentVideo.bDynamicLights);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDynamicShadows(SettingsCurrentVideo.bDynamicShadows);
	
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetTextureDetail(SettingsCurrentVideo.TextureDetailItemPosition);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDetailMode(SettingsCurrentVideo.DetailLevelItemPosition);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetSkeletalMeshLODBias(3- (SettingsCurrentVideo.CharacterLODItemPosition));
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetParticleLODBias(3 - (SettingsCurrentVideo.EffectsLODItemPosition));
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetShadowFilterQualityBias(3 - (SettingsCurrentVideo.ShadowQualityItemPosition));
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetEnableGore(SettingsCurrentVideo.bEnableGore);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetFOV(float(SettingsCurrentVideo.FOVValue));
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetLightEnvironmentShadows(SettingsCurrentVideo.bLightEnvironmentShadows);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetCompositeDynamicLights(SettingsCurrentVideo.bCompositeDynamicLights);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDirectionalLightmaps(SettingsCurrentVideo.bDirectionalLightmaps);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetBloom(SettingsCurrentVideo.ProjectileLights);                                                        //TODO: enable both bloom and dof
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDepthOfField(SettingsCurrentVideo.ProjectileLights);                                                 //TODO: enable both bloom and dof ! FIX this!
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetAmbientOcclusion(SettingsCurrentVideo.bAmbientOcclusion);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetLensFlares(SettingsCurrentVideo.bLensFlares);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetBloomThreshold(SettingsCurrentVideo.BloomValue);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDistortion(SettingsCurrentVideo.bDistortion);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDropParticleDistortion(SettingsCurrentVideo.bParticleDistortionDropping);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetStaticDecals(SettingsCurrentVideo.bStaticDecals);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetDynamicDecals(SettingsCurrentVideo.bDynamicDecals);
	
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetEnableSmoothFramerate(SettingsCurrentVideo.bFramerateSmoothing);

	
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GraphicsPresetLevel = SettingsCurrentVideo.GraphicPresetsItemPosition;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.TexturePresetLevel = SettingsCurrentVideo.TextureDetailItemPosition;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CurrentAAType = SettingsCurrentVideo.AntiAliasingItemPosition;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.TextureFilteringLevel = SettingsCurrentVideo.TextureFilteringItemPosition;

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SaveConfig();

	ResetSettingsVideoOption();
}

function ApplyAudioSettings()
{
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SFXVolume = SettingsCurrentAudio.SFXVolumeValue;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.CharacterVolume = SettingsCurrentAudio.CharacterVolumeValue;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.MusicVolume = SettingsCurrentAudio.MusicVolumeValue;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AnnouncerVolume = SettingsCurrentAudio.AnnouncerVolumeValue;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.AmbientVolume = SettingsCurrentAudio.AmbianceVolumeValue;
	//SettingsCurrentAudio.bHardwareOpenAL
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bAutostartMusic = SettingsCurrentAudio.bAutostartMusic;

	//nBab
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetKillSound(SettingsCurrentAudio.KillSound);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SaveConfig();
	
}
function ApplyInputSettings()
{

	//case 'MouseSensitivitySlider':
	//case 'MouseSensitivityInput':
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetMouseSensitivity(SettingsCurrentInput.MouseSensitivityValue);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetEnableMouseSmoothing(SettingsCurrentInput.bMouseSmoothing);
	//case 'InvertYCheckBox':
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetInvertYAxis(SettingsCurrentInput.bInvertY);
	//case 'WeaponHandDropDown':
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetWeaponHand(SettingsCurrentInput.WeaponHandItemPosition);
	//case 'MouseSmoothingCheckBox':
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetToggleTankReverse(SettingsCurrentInput.bTankReverse);
	//case 'EnableGamepadCheckBox':
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetToggleADS(SettingsCurrentInput.bADS);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SaveConfig();
	//case 'KeyBindingList':
	//case 'BindingPrimaryList':
	//case 'BindingSecondaryList':
}


function ApplyInterfaceSettings()
{
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.HUDScale = SettingsCurrentInterface.HUDScale;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bMinimap = SettingsCurrentInterface.bMinimap;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bGameInfo = SettingsCurrentInterface.bGameInfo;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bTeamInfo = SettingsCurrentInterface.bTeamInfo;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bPersonalInfo = SettingsCurrentInterface.bPersonalInfo;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bScorePanel = SettingsCurrentInterface.bScorePanel;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.bDisablePTScene = SettingsCurrentInterface.bDisablePTScene;


	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetRadioCommand(SettingsCurrentInterface.RadioCommand);

	//case 'NicknamesUseTeamColors'
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetNicknamesUseTeamColors(SettingsCurrentInput.bNicknamesUseTeamColors);
	//nBab
//	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetTechBuildingIcon(SettingsCurrentInput.TechBuildingIcon);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetBeaconIcon(SettingsCurrentInput.BeaconIcon);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetCrosshairColor(SettingsCurrentInput.CrosshairColor);

	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.RadioCommandsCtrl = SettingsCurrentInterface.RadioCommandsCtrl;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.RadioCommandsAlt = SettingsCurrentInterface.RadioCommandsAlt;
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.RadioCommandsCtrlAlt = SettingsCurrentInterface.RadioCommandsCtrlAlt;


	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SaveConfig();
	Rx_HUD(GetPC().myHUD).UpdateRadioCommandList();

	if(Rx_HUD(GetPC().myHUD).HudMovie != None && Rx_HUD(GetPC().myHUD).GIHudMovie != None)
	{
		Rx_HUD(GetPC().myHUD).HudMovie.ResizedScreenCheck(true);
		Rx_HUD(GetPC().myHUD).GIHudMovie.ResizedScreenCheck(true);
	}
	
}

function SetGraphicPresetsToCustom()
{
	if (GraphicPresetsDropDown == none) return;
	SettingsCurrentVideo.GraphicPresetsItemPosition = 0;
	GraphicPresetsDropDown.SetInt("selectedIndex", SettingsCurrentVideo.GraphicPresetsItemPosition);
}

function OnScreenResolutionDropDownChange(GFxClikWidget.EventData ev) 
{
	SettingsCurrentVideo.ScreenResolutionItemPosition = ev._this.GetInt("index");
}
function OnScreenModeDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentVideo.ScreenModeItemPosition = ev._this.GetInt("index");
}
function OnGraphicPresetsDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentVideo.GraphicPresetsItemPosition = ev._this.GetInt("index");
}
function OnAntiAliasingDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.AntiAliasingItemPosition = ev._this.GetInt("index");
}
function OnTextureFilteringDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.TextureFilteringItemPosition = ev._this.GetInt("index");
}
function OnBrightnessSliderChange(GFxClikWidget.EventData ev)
{
	local float outGammaValue;
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.BrightnessValue = ev.target.GetInt("value"); 
	BrightnessLabel.SetText(SettingsCurrentVideo.BrightnessValue $ "%");
	outGammaValue = FClamp((ev.target.GetFloat("value") * 0.05), 0.5, 5);
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetGammaSettings(outGammaValue);
	ConsoleCommand("Gamma " $ Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetGammaSettings());
}
function OnFPSSliderChange(GFxClikWidget.EventData ev)
{
	local float outFPSValue;

	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.FPSValue = ev.target.GetInt("value"); 
	FPSLabel.SetText(SettingsCurrentVideo.FPSValue $ "%");
	outFPSValue = ev.target.GetFloat("value");
	Rx_HUD(GetPC().myHUD).SystemSettingsHandler.SetFPSSetting(outFPSValue);
	ConsoleCommand("Target FPS " $ Rx_HUD(GetPC().myHUD).SystemSettingsHandler.GetFPSSetting());
}
function OnVSyncCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bVSync = ev._this.GetBool("selected");
}
function OnDx10CheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDx10 = ev._this.GetBool("selected");
}
//nBab
function OnAllowD3D9MSAACheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bAllowD3D9MSAA = ev._this.GetBool("selected");
}
//nBab
function OnUseHardwarePhysicsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bUseHardwarePhysics = ev._this.GetBool("selected");
}
function OnMotionBlurCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bMotionBlur = ev._this.GetBool("selected");
}
function OnDynamicLightsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDynamicLights = ev._this.GetBool("selected");
}
function OnDynamicShadowsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDynamicShadows = ev._this.GetBool("selected");
}
function OnTextureDetailDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.TextureDetailItemPosition = ev._this.GetInt("index");
}
function OnDetailLevelDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.DetailLevelItemPosition = ev._this.GetInt("index");
}
function OnCharacterLODDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.CharacterLODItemPosition = ev._this.GetInt("index");
}
function OnEffectsLODDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.EffectsLODItemPosition = ev._this.GetInt("index");
}
function OnShadowQualityDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.ShadowQualityItemPosition = ev._this.GetInt("index");
}
function OnEnabledGoreCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bEnableGore = !ev._this.GetBool("selected");
}
function OnFOVSliderChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.FOVValue = ev.target.GetInt("value");
	FOVLabel.SetText(ev.target.GetInt("value"));
}

function OnLightEnvironmentShadowsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bLightEnvironmentShadows = ev._this.GetBool("selected");
}
function OnCompositeDynamicLightsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bCompositeDynamicLights = ev._this.GetBool("selected");
}
function OnDirectionalLightmapsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDirectionalLightmaps = ev._this.GetBool("selected");
}
function OnBloomDoFCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bBloomDoF = ev._this.GetBool("selected");
}
function OnBloomSliderChange(GFxClikWidget.EventData ev)
{
	local string text;
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.BloomValue = ev.target.GetFloat("value") / 100;
	text = "" $ (ev.target.GetFloat("value") / 100);
	BloomLabel.SetText(Left(text, InStr(text, ".") + 3));
}
function OnAmbientOcclusionCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bAmbientOcclusion = ev._this.GetBool("selected");
}
function OnLensFlaresCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bLensFlares = ev._this.GetBool("selected");
}
function OnDistortionCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDistortion = ev._this.GetBool("selected");
}
function OnParticleDistortionDroppingCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bParticleDistortionDropping = ev._this.GetBool("selected");
}
function OnStaticDecalsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bStaticDecals = ev._this.GetBool("selected");
}
function OnDynamicDecalsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDynamicDecals = ev._this.GetBool("selected");
}
function OnFramerateSmoothingCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bFramerateSmoothing = ev._this.GetBool("selected");
}

function OnSFXVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.SFXVolumeValue = ev.target.GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume SFX " $SettingsCurrentAudio.SFXVolumeValue);
	SFXVolumeLabel.SetText(ev.target.GetInt("value") $"%");
}
function OnMusicVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.MusicVolumeValue = ev.target.GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Music " $SettingsCurrentAudio.MusicVolumeValue);
	//ConsoleCommand("MODIFYSOUNDCLASS Music VOL=" $SettingsCurrentAudio.MusicVolumeValue);
	MusicVolumeLabel.SetText(ev.target.GetInt("value") $"%");
}
function OnAmbianceVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.AmbianceVolumeValue = ev.target.GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Ambient " $SettingsCurrentAudio.AmbianceVolumeValue);
	AmbianceVolumeLabel.SetText(ev.target.GetInt("value") $"%");
}
function OnCharacterVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.CharacterVolumeValue = ev.target.GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Voice " $SettingsCurrentAudio.CharacterVolumeValue);
	DialogueVolumeLabel.SetText(ev.target.GetInt("value") $"%");
}
function OnAnnouncerVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.AnnouncerVolumeValue = ev.target.GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Announcer " $SettingsCurrentAudio.AnnouncerVolumeValue);
	AnnouncerVolumeLabel.SetText(ev.target.GetInt("value") $"%");
}
function OnHardwareOpenALCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.bHardwareOpenAL = ev._this.GetBool("selected");
}

function OnAutoplayMusicCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.bAutostartMusic = ev._this.GetBool("selected");
}

function OnMusicTracklistItemClick(GFxClikWidget.EventData ev)
{
	//disabled toggling because it's done by check box list now (nBab)
	/*local GFxObject item;

	item = ev._this.GetObject("item");
	
	Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[ev.index].bSelected = item.GetBool("toggled");*/
}
//nBab
function OnMusicCheckBoxlistItemClick(GFxClikWidget.EventData ev)
{
	local GFxObject item;
	local int index;

	item = ev._this.GetObject("item");
	index = MusicCheckBoxList.GetInt("selectedIndex");

	//toggle the checkbox
	if (item.GetBool("toggled"))
		item.SetBool("toggled", false);
	else
		item.SetBool("toggled", true);

	//enable/disable the track based on the checkbox
	Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[index].bSelected = item.GetBool("toggled");
	
	//old code to disable the track which was commented because the clik component was buggy.
	//MusicTracklist.GetObject("dataProvider").GetElementObject(index).SetBool("disabled",!item.GetBool("toggled"));
	//if the same track is selected, deselect it.
	//if (MusicTracklist.GetInt("selectedIndex") == index)
	//	MusicTracklist.SetInt("selectedIndex",-1);
	
	//if the same track is being played, play the next bSelected track
	if (Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[index].TheSoundCue == GetPC().WorldInfo.MusicComp.SoundCue)
	{
		Rx_HUD(GetPC().myHUD).JukeBox.Stop();
		Rx_HUD(GetPC().myHUD).JukeBox.play(index);

		//if there's any enabled tracks
		if (Rx_HUD(GetPC().myHUD).JukeBox.CurrentTrack.TheSoundCue != none)
		{
			index = Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
			TrackNameLabel.SetText(Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[index].TrackName);
		}
		else
		{
			TrackNameLabel.SetText("");
			DeselectPlayerButtonGroup();
		}
	}

	//save config
	Rx_HUD(GetPC().myHUD).JukeBox.saveconfig();

	//force update on the lists
	MusicTracklist.SetBool("disabled",false);
	MusicCheckBoxlist.SetBool("disabled",false);
}
//nBab
function OnKillSoundPlayButtonChange (GFxClikWidget.EventData ev)
{
	local SoundCue CustomSound;
	local Rx_Controller C;

	C = Rx_Controller(GetPC());

	CustomSound = SoundCue(DynamicLoadObject(C.CustomKillsound, class'SoundCue'));

	switch(KillSoundDropDown.GetInt("selectedIndex"))
	{
		case 0:		
			C.ClientPlaySound(SoundCue'RX_SoundEffects.SFX.SC_Boink');
			break;
		case 1:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Boink_Modern');
			break;
		case 2:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Kill_Alert_Cue');
			break;
		case 3:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Commando');
			break;
		case 4:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Havoc');
			break;
		case 5:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_McFarland');
			break;
		case 6:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Gotchya_Cue');
			break;
		case 7:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Aww_Too_Easy_Cue');
			break;
		case 8:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_For_Kane_Cue');
			break;
		case 9:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Die_Infidel_Cue');
			break;
		case 10:
			C.ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Goat_Cue');
			break;
		case 11:
			C.ClientPlaySound(CustomSound);

		default:
			break;
	}
	ev.target.SetBool("selected",false);
}
function OnPlayerControlGroupChange(GFxClikWidget.EventData ev)
{
	local GFxClikWidget SelectedItem;
	local int SelectedIndex;
	local int i;


	SelectedItem = GFxClikWidget(ev._this.GetObject("item", class'GFxClikWidget'));

	
// 	GetPC().ClientMessage("Group Length? " $ PlayerControlGroup.GetInt("length"));
// 	GetPC().ClientMessage("SelectedItem?  " $ SelectedItem);

	switch (SelectedItem.GetString("_name"))
	{

		case "PlayButton":
			
// 			//Play music here
			if (PlayButton.GetBool("selected")) {

				//if the music tracklist is not existed, then do not run
				if (MusicTracklist == none) {
					return;
				}
				
				//get selected index of our music tracklist
				SelectedIndex = MusicTracklist.GetInt("selectedIndex");

				if (SelectedIndex >= 0 && Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[SelectedIndex].bSelected)
				{
					//old code (nBab)
					//if the music tracklist is not selected, select the default (0)
					/*if (SelectedIndex < 0) {
						SelectedIndex = 0;
			 			MusicTracklist.SetInt("selectedIndex", SelectedIndex);
					}*/

					//if nothing is selected, select the first enabled track (nBab)
					if (SelectedIndex < 0) {
						for (i=0;i<Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.length;i++)
						{
							if(Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[i].bSelected)
							{
								SelectedIndex = i;
								MusicTracklist.SetInt("selectedIndex", SelectedIndex);
								break;
							}
						}
					}
					//if all tracks were disabled (nBab)
					if (SelectedIndex < 0)
					{
						Rx_HUD(GetPC().myHUD).JukeBox.Stop();
						TrackNameLabel.SetText("");
						DeselectPlayerButtonGroup();
						return;
					}

					i = (Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue));
					//then check if we're playing our track AND if we're playing the same track as selected AND if we're playing
					if (i >= 0 && SelectedIndex == i && GetPC().WorldInfo.MusicComp.IsPlaying()) {
						return;
					}
					//~then we're playing a different track OR we're not playing our track.
					
					//stop the track, and play our selected track
					Rx_HUD(GetPC().myHUD).JukeBox.Stop();

					//old code (nBab)
					//check if the selected track is selected
					/*if (Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[SelectedIndex].bSelected) {
						//play this
						Rx_HUD(GetPC().myHUD).JukeBox.Play(SelectedIndex);
			 			TrackNameLabel.SetText(Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[selectedIndex].TrackName);
					} else {
			 			//loop through list if there is anything to be played.
			 			SelectedIndex = Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('bSelected', true);
						if (SelectedIndex >= 0) {
							Rx_HUD(GetPC().myHUD).JukeBox.Play(SelectedIndex);
			 				MusicTracklist.SetInt("selectedIndex", SelectedIndex);
			 				TrackNameLabel.SetText(Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[selectedIndex].TrackName);
						} else {
							TrackNameLabel.SetText("");
							DeselectPlayerButtonGroup();
						}
					}*/

					//set tracknamelable if there's a track playing, else set it to empty and deselect tracks (nBab)
					Rx_HUD(GetPC().myHUD).JukeBox.Play(SelectedIndex);
					if(Rx_HUD(GetPC().myHUD).JukeBox.CurrentTrack.TheSoundCue != none)
					{
						SelectedIndex = (Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue));
						MusicTracklist.SetInt("selectedIndex", SelectedIndex);
			 			TrackNameLabel.SetText(Rx_HUD(GetPC().myHUD).JukeBox.JukeBoxList[selectedIndex].TrackName);
		 			}else
		 			{
		 				MusicTracklist.SetInt("selectedIndex", -1);
		 				TrackNameLabel.SetText("");
		 				DeselectPlayerButtonGroup();
		 			}
		 		}
			}
			break;
		case "StopButton":
			//stop music here
			if (StopButton.GetBool("selected")) {
				//is the music playing?
				if (GetPC().WorldInfo.MusicComp.IsPlaying()) {
					Rx_HUD(GetPC().myHUD).JukeBox.Stop();
				}
				
				TrackNameLabel.SetText("");
				DeselectPlayerButtonGroup();
			}
			break;
		default:
//			GetPC().ClientMessage("Default Name? " $ SelectedItem.GetString("_name"));
			return;
	}
}

// function OnPlayButtonSelect(GFxClikWidget.EventData ev){
// // 	GetPC().ClientMessage("PlayButton Selected? " $ ev._this.GetBool("selected"));
// // 	MainFrontEnd.OpenFrontEndErrorAlertDialog("PlayButton", "Play Button Clicked");
// }
// function OnStopButtonSelect(GFxClikWidget.EventData ev){
// 	//Stop music here
// // 	GetPC().ClientMessage("StopButton Selected? " $ ev._this.GetBool("selected"));
// // 	MainFrontEnd.OpenFrontEndErrorAlertDialog("StopButton", "Stop Button Clicked");
// }

function OnShuffleButtonSelect(GFxClikWidget.EventData ev){
	Rx_HUD(GetPC().myHUD).JukeBox.bShuffled = ev._this.GetBool("selected");
}
function OnMouseSensitivitySliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.MouseSensitivityValue = ev.target.GetInt("value");
	MouseSensitivityInput.SetText(""$ev.target.GetInt("value"));
}
function OnMouseSensitivityInputTextChange(GFxClikWidget.EventData ev)
{
	if (int(ev.target.GetText()) != Clamp(int(ev.target.GetText()), MouseSensitivitySlider.GetInt("minimum"), MouseSensitivitySlider.GetInt("maximum")))
		ev.target.SetText(""$Clamp(int(ev.target.GetText()), MouseSensitivitySlider.GetInt("minimum"), MouseSensitivitySlider.GetInt("maximum")));
	SettingsCurrentInput.MouseSensitivityValue = int(ev.target.GetText());
	MouseSensitivitySlider.SetInt("value", int(ev.target.GetText()));
}
function OnGamepadSensitivitySliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.GamepadSensitivityValue = ev.target.GetInt("value");
	GamepadSensitivityInput.SetText(""$ev.target.GetInt("value"));
}
function OnGamepadSensitivityInputTextChange(GFxClikWidget.EventData ev)
{
	if (int(ev.target.GetText()) != Clamp(int(ev.target.GetText()), GamepadSensitivitySlider.GetInt("minimum"), GamepadSensitivitySlider.GetInt("maximum")))
		ev.target.SetText(""$Clamp(int(ev.target.GetText()), GamepadSensitivitySlider.GetInt("minimum"), GamepadSensitivitySlider.GetInt("maximum")));
	SettingsCurrentInput.GamepadSensitivityValue = int(ev.target.GetText());
	GamepadSensitivitySlider.SetInt("value", int(ev.target.GetText()));
}

function OnMouseSensitivityInputFocusIn(GFxClikWidget.EventData ev)
{
	IgnoreAlphabeticals(ev);

}
function OnMouseSensitivityInputFocusOut(GFxClikWidget.EventData ev)
{
	ClearFocusIgnoreKeys();
}
function OnGamepadSensitivityInputFocusIn(GFxClikWidget.EventData ev)
{
	IgnoreAlphabeticals(ev);
}
function OnGamepadSensitivityInputFocusOut(GFxClikWidget.EventData ev)
{
	ClearFocusIgnoreKeys();
}
function IgnoreAlphabeticals(GFxClikWidget.EventData ev)
{
	local byte i;
	for (i = 32; i < 128; i ++)
	{
		if (i == Clamp(i, 48, 57))
			continue;
		AddFocusIgnoreKey(name(chr(i)));
	}

	AddFocusIgnoreKey(name("LeftShift"));
	AddFocusIgnoreKey(name("RightShift"));
	AddFocusIgnoreKey(name("Spacebar"));
}

function OnMouseSmoothingCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bMouseSmoothing = ev.target.GetBool("selected");
}

function OnInvertYCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bInvertY = ev.target.GetBool("selected");
}
function OnWeaponHandDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.WeaponHandItemPosition = ev._this.GetInt("index");
}
//nBab
/*
function OnTechBuildingIconDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.TechBuildingIcon = ev._this.GetInt("index");
}
*/


function OnCustomRadioNextButtonClick(GFxClikWidget.EventData ev)
{
	local int i;

	SettingsCurrentInterface.CustomRadioCurrentPosition++;
	SettingsCurrentInterface.CustomRadioCurrentPosition = Clamp(SettingsCurrentInterface.CustomRadioCurrentPosition, 0, 2);
	for(i = 0;i< 10;i++)
		RadioGetLastSelection(i);

	if(SettingsCurrentInterface.CustomRadioCurrentPosition >= 2)
	{
		CustomRadioNextButton.SetBool("disabled", true);
	}
	if(SettingsCurrentInterface.CustomRadioCurrentPosition > 0)
	{
		CustomRadioPrevButton.SetBool("disabled", false);
	}
	UpdateCustomRadioLabel();
}

function OnCustomRadioPrevButtonClick(GFxClikWidget.EventData ev)
{
	local int i;

	SettingsCurrentInterface.CustomRadioCurrentPosition--;
	SettingsCurrentInterface.CustomRadioCurrentPosition = Clamp(SettingsCurrentInterface.CustomRadioCurrentPosition, 0, 2);
	for(i = 0;i< 10;i++)
		RadioGetLastSelection(i);

	if(SettingsCurrentInterface.CustomRadioCurrentPosition <= 0)
	{
		CustomRadioPrevButton.SetBool("disabled", true);
	}
	if(SettingsCurrentInterface.CustomRadioCurrentPosition < 2)
	{
		CustomRadioNextButton.SetBool("disabled", false);
	}
	UpdateCustomRadioLabel();
}

function UpdateCustomRadioLabel()
{
	switch(SettingsCurrentInterface.CustomRadioCurrentPosition)
	{
		case 0:
			CustomRadioCurrent.SetText("CTRL");
			break;
		case 1:
			CustomRadioCurrent.SetText("ALT");
			break;
		case 2:
			CustomRadioCurrent.SetText("CTRLALT");
			break;
		default:
			CustomRadioCurrent.SetText("UNKNOWN");
			break;
	}
}

function OnRadioCommandDropDownChange(GFxClikWidget.EventData ev)
{
	local bool bCustomEnabled;

	if(SettingsCurrentInterface.RadioCommand == 2)
		bCustomEnabled = true;

	SettingsCurrentInterface.RadioCommand = ev._this.GetInt("index");

	if((SettingsCurrentInterface.RadioCommand == 2 && !bCustomEnabled) || (SettingsCurrentInterface.RadioCommand != 2 && bCustomEnabled))
	{
		UpdateCustomRadioStatus(!bCustomEnabled);
	}
}


function UpdateCustomRadioStatus(bool bCustom)
{
	local GFxClikWidget Widget;

	foreach CustomRadioDropDown(Widget)
	{
		Widget.SetBool("disabled",!bCustom);
	}
}

function OnCustomRadioDropdownOneChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 0);
}

function OnCustomRadioDropdownTwoChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 1);
}

function OnCustomRadioDropdownThreeChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 2);
}

function OnCustomRadioDropdownFourChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 3);
}

function OnCustomRadioDropdownFiveChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 4);
}

function OnCustomRadioDropdownSixChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 5);
}

function OnCustomRadioDropdownSevenChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 6);
}

function OnCustomRadioDropdownEightChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 7);
}

function OnCustomRadioDropdownNineChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 8);
}

function OnCustomRadioDropdownTenChange(GFxClikWidget.EventData ev)
{
	OnCustomRadioDropdownChange(ev, 9);
}

function OnCustomRadioDropdownChange(GFxClikWidget.EventData ev, int RadioNumber)
{
	switch(SettingsCurrentInterface.CustomRadioCurrentPosition)
	{
		case 0:
			SettingsCurrentInterface.RadioCommandsCtrl[RadioNumber] = ev._this.GetObject("target").GetInt("selectedIndex");
			break;
		case 1:
			SettingsCurrentInterface.RadioCommandsAlt[RadioNumber] = ev._this.GetObject("target").GetInt("selectedIndex");
			break;
		case 2:
			SettingsCurrentInterface.RadioCommandsCtrlAlt[RadioNumber] = ev._this.GetObject("target").GetInt("selectedIndex");
			break;
	}
}

//nBab
function OnBeaconIconDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.BeaconIcon = ev._this.GetInt("index");
}
//nBab
function OnCrosshairColorDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.CrosshairColor = ev._this.GetInt("index");
}
//nBab
function OnKillSoundDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.KillSound = ev._this.GetInt("index");
}
function OnTankReverseCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bTankReverse = ev.target.GetBool("selected");
}
function OnToggleADSCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bADS = ev.target.GetBool("selected");
}
function OnUseClassicTeamNameColorsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bNicknamesUseTeamColors = ev.target.GetBool("selected");
}

function OnBindingPrimaryListItemClick(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.BindingPrimaryItemPosition = ev._this.GetInt("index");

	if (CurrentPrimaryListItemRenderer != none) {
		if (CurrentPrimaryListItemRenderer.GetString("label") == "???") {
			//SetUpDataProvider(ev.target);
			CurrentPrimaryListItemRenderer.SetString("label", PreviousPrimaryListKey);
		}
	}

	if (ev._this.GetInt("index") != Clamp(ev._this.GetInt("index"), 0, BindingList.Length-1)) { //(ev.index < 0 || ev.index > totalBinding - 1) 
		return;
	}

	CurrentPrimaryListItemRenderer = GFxClikWidget(ev._this.GetObject("renderer", class'GFxClikWidget'));
	PreviousPrimaryListKey = CurrentPrimaryListItemRenderer.GetString("label");
	CurrentPrimaryListItemRenderer.SetString("label", "???");
	ev.target.GetObject("dataProvider").SetElementString(ev._this.GetInt("index"), "???");
	ClearFocusIgnoreKeys();
}
function OnBindingSecondaryListItemClick(GFxClikWidget.EventData ev)
{
	if (CurrentSecondaryListItemRenderer != none)
	{
		if (CurrentSecondaryListItemRenderer.GetString("label") == "???")
		{
			CurrentSecondaryListItemRenderer.SetString("label", PreviousSecondaryListKey);
		}
	}

	
	if (ev._this.GetInt("index") != Clamp(ev._this.GetInt("index"), 0, BindingList.Length-1))//(ev.index < 0 || ev.index > totalBinding - 1)
	{
		return;
	}

	//SettingsCurrentInput.BindingSecondaryItemPosition = ev.index;
	CurrentSecondaryListItemRenderer = ev._this.GetObject("renderer");
	PreviousSecondaryListKey = CurrentSecondaryListItemRenderer.GetString("label");
	CurrentSecondaryListItemRenderer.SetString("label", "???");
	ev.target.SetInt("selectedIndex", -1);
	ClearFocusIgnoreKeys();
}


/** Returns the first button bound to a given command **/
function name GetBoundKey(string Command)
{
	local byte i;
	local PlayerInput PInput;

	PInput = GetPC().PlayerInput;

	for (i = 0; i < PInput.Bindings.Length; i++) {
		if (PInput.Bindings[i].Command != Command) {
			continue;
		}
		return PInput.Bindings[i].Name;
	}
	return '';
}

/** Called whenever a button is pressed **/
function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	//`log("ControllerId: "$ControllerId $", ButtonName: "$ButtonName $", InputEvent: "$InputEvent);
	//local array<string> Konami;
	//Konami = ["Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "B", "A", "Enter"];
	// Only handle keypress if we are expecting one
	// then assign the binding
	if (CurrentPrimaryListItemRenderer != none ) {
		if (SettingsCurrentInput.BindingPrimaryItemPosition > -1 && CurrentPrimaryListItemRenderer.GetString("label") == "???" && InputEvent == IE_Pressed) {
			if (ButtonName == 'Escape') {
				CurrentPrimaryListItemRenderer.SetBool("selected", false);
				SetUpDataProvider(BindingPrimaryList);
				BindingPrimaryList.SetInt("focused", 0);
				return false;
			}
			BindKey(ButtonName, BindingList[SettingsCurrentInput.BindingPrimaryItemPosition].Command);
			
			CurrentPrimaryListItemRenderer.SetBool("selected", false);
			BindingPrimaryList.GetObject("dataProvider").SetElementString(SettingsCurrentInput.BindingPrimaryItemPosition, UDKPlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand(BindingList[SettingsCurrentInput.BindingPrimaryItemPosition].Command));
			SetUpDataProvider(BindingPrimaryList);
			BindingPrimaryList.SetInt("focused", 0);
			return true;
		}
	}

	if (CurrentSecondaryListItemRenderer != none) {
		if (SettingsCurrentInput.BindingSecondaryItemPosition > -1 && CurrentSecondaryListItemRenderer.GetBool("selected") && InputEvent == IE_Pressed) {
			if (ButtonName == 'Escape') {
				return false;
			}
			BindKey(ButtonName, BindingList[SettingsCurrentInput.BindingSecondaryItemPosition].Command);
			CurrentSecondaryListItemRenderer.SetString("label", UDKPlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand(BindingList[SettingsCurrentInput.BindingSecondaryItemPosition].Command));
			SetUpDataProvider(BindingSecondaryList);
			return true;
		}
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


	PInput = GetPC().PlayerInput;

	// Unbind what used to be bound to this command.
	UnbindKey(PreviousBinding);
	// Unbind the new key to whatever it may have been bound to. (and thus, setting the whatever it binds to ???)
	UnbindKey(KeyName);

	NewKeyBind.Command = Command;
	NewKeyBind.Name = KeyName;
	// Bind the Key
	PInput.Bindings[PInput.Bindings.length] = NewKeyBind;

	PInput.SaveConfig();
	`log("[Rx_GFxFrontEnd_Settings]: Binding for Command " $ Command $" to key " $ KeyName $" is successful");
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

function OnSettingsVideoActionItemClick(GFxClikWidget.EventData ev)
{
	switch (ev._this.GetInt("index"))
	{
	  case 0: PauseMenu.ReturnToBackground(); break;
	  case 1: OpenConfirmApplyVideoSettingsDialog();/*ApplyVideoSettings();*/ break;
	  default: break;
	}
}
function OnSettingsAudioActionBarChange(GFxClikWidget.EventData ev)
{
	switch (ev._this.GetInt("index"))
	{
	  case 0: PauseMenu.ReturnToBackground(); break;
	  case 1: 
	  	ApplyAudioSettings(); 
	  	//ApplyVideoSettings();
		//ApplyInputSettings();
		//MainFrontEnd.ReturnToBackground();
	  	break;
	  default: break;
	}
}

function OnSettingsInputActionBarChange(GFxClikWidget.EventData ev)
{
	switch (ev._this.GetInt("index"))
	{
	  case 0: PauseMenu.ReturnToBackground(); break;
	  case 1: 
	  	//ApplyAudioSettings(); 
	  	//ApplyVideoSettings();
		ApplyInputSettings();
		//MainFrontEnd.ReturnToBackground();
	  	break;
	  default: break;
	}
}

function OnSettingsInterfaceActionBarChange(GFxClikWidget.EventData ev)
{
	switch (ev._this.GetInt("index"))
	{
		case 0: PauseMenu.ReturnToBackground(); break;
		case 1: 
	  		//ApplyAudioSettings(); 
	  		//ApplyVideoSettings();
			ApplyInterfaceSettings();
	  	break;
	  default: break;
	}
}

// UI SETTINGS Feedback

function OnHUDScaleSliderChange(GFxClikWidget.EventData ev)
{
	local string text;

	SettingsCurrentInterface.HUDScale = ev._this.GetObject("target").GetFloat("value");
	text = int(SettingsCurrentInterface.HUDScale)@"%";
	HUDScaleLabel.SetText(text);
}

function OnMinimapCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInterface.bMinimap = ev._this.GetObject("target").GetBool("selected");
}
function OnGameInfoCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInterface.bGameInfo = ev._this.GetObject("target").GetBool("selected");
}
function OnTeamInfoCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInterface.bTeamInfo = ev._this.GetObject("target").GetBool("selected");
}
function OnPersonalInfoCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInterface.bPersonalInfo = ev._this.GetObject("target").GetBool("selected");
}
function OnScorePanelCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInterface.bScorePanel = ev._this.GetObject("target").GetBool("selected");
}
function OnNoPTSceneCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInterface.bDisablePTScene = ev._this.GetObject("target").GetBool("selected");
}

DefaultProperties
{
	//Settings
	SubWidgetBindings.Add((WidgetName="SettingsVideoActionBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ScreenResolutionDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ScreenModeDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="GraphicPresetsDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AntiAliasingDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="TextureFilteringDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BrightnessSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BrightnessLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="VSyncCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Dx10CheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MotionBlurCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DynamicLightsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DynamicShadowsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="TextureDetailDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DetailLevelDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CharacterLODDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="EffectsLODDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ShadowQualityDropDown",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="EnabledGoreCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FOVSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FOVLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="LightEnvironmentShadowsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CompositeDynamicLightsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DirectionalLightmapsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BloomDoFCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AmbientOcclusionCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="LensFlaresCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BloomSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BloomLabel",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="DistortionCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ParticleDistortionDroppingCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="StaticDecalsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DynamicDecalsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FramerateSmoothingCheckBox",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="SFXVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SFXVolumeLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MusicVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MusicVolumeLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AmbianceVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AmbianceVolumeLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DialogueVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DialogueVolumeLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AnnouncerVolumeSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AnnouncerVolumeLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="HardwareOpenALCheckBox",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="AutoplayMusicCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SettingsAudioActionBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PlayButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="StopButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ShuffleButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ShuffleButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MusicTrackScrollBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MusicTracklist",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="TrackNameLabel",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="MouseSensitivitySlider", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MouseSensitivityInput", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="GamepadSensitivitySlider", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="GamepadSensitivityInput", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MouseSmoothingCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="InvertYCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="WeaponHandDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="TankReverseCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ToggleADSCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="UseClassicTeamNameColorsCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="KeyBindingList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BindingPrimaryList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BindingSecondaryList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="keyBindScroll",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SettingsInputActionBar",WidgetClass=class'GFxClikWidget'))
	//nBab
//	SubWidgetBindings.Add((WidgetName="TechBuildingIconDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="RadioCommandDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BeaconIconDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CrosshairColorDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AllowD3D9MSAACheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="UseHardwarePhysicsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="KillSoundDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MusicCheckBoxlist",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="KillSoundPlayButton",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="HUDScaleLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="HUDScaleSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MinimapCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="GameInfoCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="TeamInfoCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="PersonalInfoCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ScorePanelCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="NoPTSceneCheckBox",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="SettingsInterfaceActionBar",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="CustomRadioNextButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioPrevButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioCurrent",WidgetClass=class'GFxClikWidget'))

	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown0",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown1",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown2",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown3",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown4",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown5",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown6",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown7",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown8",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CustomRadioDropDown9",WidgetClass=class'GFxClikWidget'))

	CustomRadioDropDown[0] = None;
	CustomRadioDropDown[1] = None;
	CustomRadioDropDown[2] = None;
	CustomRadioDropDown[3] = None;
	CustomRadioDropDown[4] = None;
	CustomRadioDropDown[5] = None;
	CustomRadioDropDown[6] = None;
	CustomRadioDropDown[7] = None;
	CustomRadioDropDown[8] = None;
	CustomRadioDropDown[9] = None;
}