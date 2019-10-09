//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Rx_GFxFrontEnd_Settings extends Rx_GFxFrontEnd_View
	config(Menu);

var Rx_GFXFrontEnd MainFrontEnd;

//var Rx_Jukebox JukeBox;
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
var Rx_GFxDropDown TextureDetailDropDown;
var Rx_GFxDropDown DetailLevelDropDown;
var Rx_GFxDropDown CharacterLODDropDown;
var Rx_GFxDropDown EffectsLODDropDown;
var Rx_GFxDropDown ShadowQualityDropDown;
/** formerly known as ReducedGore. values must be flipped!*/
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
var GFxClikWidget SpeedTreeLeavesCheckBox;//
var GFxClikWidget SpeedTreeFrondsCheckBox;//
var GFxClikWidget StaticDecalsCheckBox;
var GFxClikWidget DynamicDecalsCheckBox;
var GFxClikWidget FramerateSmoothingCheckBox;
var GFxClikWidget OneFrameThreadLagCheckBox;//
var GFxClikWidget HardwarePhysicsCheckBox;//

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
// var GFxObject NowPlayingMC;
// var GFxObject MusicPlayer;


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
var GFxClikWidget ToggleCrouchCheckBox;
var GFxClikWidget ToggleSprintCheckBox;
var GFxClikWidget UseClassicTeamNameColorsCheckBox;
var GFxClikWidget KeyBindingList;
var GFxClikWidget BindingPrimaryList;
var GFxClikWidget BindingSecondaryList;
var GFxClikWidget keyBindScroll;
var GFxClikWidget SettingsInputActionBar;

//nBab
var GFxClikWidget TechBuildingIconDropDown;
var GFxClikWidget BeaconIconDropDown;
var GFxClikWidget CrosshairColorDropDown;
var GFxClikWidget AllowD3D9MSAACheckBox;
var GFxClikWidget UseHardwarePhysicsCheckBox;
var GFxClikWidget KillSoundDropDown;
var GFxClikWidget MusicCheckBoxlist;
var GFxClikWidget KillSoundPlayButton;

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
	var bool bToggleCrouch;
	var bool bToggleSprint;
	var bool bNicknamesUseTeamColors;
	var int KeyBingdingItemPosition;
	var int BindingPrimaryItemPosition;
	var int BindingSecondaryItemPosition;
	//nBab
	var int TechBuildingIcon;
	var int BeaconIcon;
	var int CrosshairColor;
};
var SettingsInputOption SettingsCurrentInput;

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

function OnViewLoaded(Rx_GFXFrontEnd FrontEnd)
{
	MainFrontEnd = FrontEnd;

	if (Resolutions.Length <= 0) {
		Resolutions = MainFrontEnd.SystemSettingsHandler.GetAvailableResolutions();
	}
	
	ResetSettingsVideoOption();
	ResetSettingsAudioOption();
	ResetSettingsInputOption();

	PlayerControlGroup = InitButtonGroupWidget("PlayerControlGroup", MainFrontEnd.SettingsView);
	PlayerControlGroup.AddEventListener('CLIK_change', OnPlayerControlGroupChange);
	SetSelectedButton(StopButton);

	GetPC().WorldInfo.MusicComp.OnAudioFinished = MusicPlayerOnAudioFinished;

	ActionScriptVoid("validateNow");
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
	return GFxClikWidget(ActionScriptConstructor("scaleform.clik.controls.ButtonGroup"));
}

function DeselectPlayerButtonGroup() 
{
	SetSelectedButton(none);
}

function SetSelectedButton  (GFxClikWidget button, bool selected=true)
{
	PlayerControlGroup.ActionScriptVoid("updateSelectedButton");
}

function validateNow(GFxObject event=none)
{
	ActionScriptVoid("validateNow");
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local int i;
	local bool bWasHandled;

	`log("Rx_GFxFrontEnd_Settings::WidgetInitialized"@`showvar(WidgetName),true,'DevGFxUI');

	bWasHandled = false;

	switch(WidgetName)
	{

		/************************************* [Settings - Video] *****************************************/
		case 'SettingsVideoActionBar':
			if (SettingsVideoActionBar == none || SettingsVideoActionBar != Widget) {
				SettingsVideoActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SettingsVideoActionBar);
			SettingsVideoActionBar.AddEventListener('CLIK_buttonClick', OnSettingsVideoActionItemClick);
			bWasHandled = true;
			break;

		case 'ScreenResolutionDropDown':
			if (ScreenResolutionDropDown == none || ScreenResolutionDropDown != Widget) {
				ScreenResolutionDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ScreenResolutionDropDown);
			GetLastSelection(ScreenResolutionDropDown);
			ScreenResolutionDropDown.AddEventListener('CLIK_change', OnScreenResolutionDropDownChange);
			bWasHandled = true;
			break;
		case 'ScreenModeDropDown':
			if (ScreenModeDropDown == none || ScreenModeDropDown != Widget) {
				ScreenModeDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ScreenModeDropDown);
			GetLastSelection(ScreenModeDropDown);
			ScreenModeDropDown.AddEventListener('CLIK_change', OnScreenModeDropDownChange);
			bWasHandled = true;
			break;
		case 'GraphicPresetsDropDown':
			if (GraphicPresetsDropDown == none || GraphicPresetsDropDown != Widget) {
				GraphicPresetsDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(GraphicPresetsDropDown);
			GetLastSelection(GraphicPresetsDropDown);
			GraphicPresetsDropDown.AddEventListener('CLIK_change', OnGraphicPresetsDropDownChange);
			bWasHandled = true;
			break;
		case 'AntiAliasingDropDown':
			if (AntiAliasingDropDown == none || AntiAliasingDropDown != Widget) {
				AntiAliasingDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(AntiAliasingDropDown);
			GetLastSelection(AntiAliasingDropDown);
			AntiAliasingDropDown.AddEventListener('CLIK_change', OnAntiAliasingDropDownChange);
			bWasHandled = true;
			break;
		case 'TextureFilteringDropDown':  
			if (TextureFilteringDropDown == none || TextureFilteringDropDown != Widget) {
				TextureFilteringDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(TextureFilteringDropDown);
			GetLastSelection(TextureFilteringDropDown);
			TextureFilteringDropDown.AddEventListener('CLIK_change', OnTextureFilteringDropDownChange);
			bWasHandled = true;
			break;
		case 'BrightnessSlider':    
			if (BrightnessSlider == none || BrightnessSlider != Widget) {
				BrightnessSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(BrightnessSlider);
			BrightnessSlider.AddEventListener('CLIK_valueChange', OnBrightnessSliderChange);
			bWasHandled = true;
			break;
		case 'BrightnessLabel':
			if (BrightnessLabel == none || BrightnessLabel != Widget) {
				BrightnessLabel = GFxClikWidget(Widget);
			}
			BrightnessLabel.SetText(SettingsCurrentVideo.BrightnessValue);
			bWasHandled = true;
			break;
		case 'FPSSlider':    
			if (FPSSlider == none || FPSSlider != Widget) {
				FPSSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(FPSSlider);
			FPSSlider.AddEventListener('CLIK_valueChange', OnFPSSliderChange);
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
			bWasHandled = true;
			break;
		case 'Dx10CheckBox': //need to remove this.
			if (Dx10CheckBox == none || Dx10CheckBox != Widget) {
				Dx10CheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(Dx10CheckBox);
			Dx10CheckBox.AddEventListener('CLIK_select', OnDx10CheckBoxSelect);
			Dx10CheckBox.SetBool("enabled", false); //Temporary
			Dx10CheckBox.SetVisible(false);
			bWasHandled = true;
			break;
		//nBab
		case 'AllowD3D9MSAACheckBox': 
			if (AllowD3D9MSAACheckBox == none || AllowD3D9MSAACheckBox != Widget) {
				AllowD3D9MSAACheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(AllowD3D9MSAACheckBox);
			AllowD3D9MSAACheckBox.AddEventListener('CLIK_select', OnAllowD3D9MSAACheckBoxSelect);
			bWasHandled = true;
			break;
		//nBab
		case 'UseHardwarePhysicsCheckBox': 
			if (UseHardwarePhysicsCheckBox == none || UseHardwarePhysicsCheckBox != Widget) {
				UseHardwarePhysicsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(UseHardwarePhysicsCheckBox);
			UseHardwarePhysicsCheckBox.AddEventListener('CLIK_select', OnUseHardwarePhysicsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'MotionBlurCheckBox':
			if (MotionBlurCheckBox == none || MotionBlurCheckBox != Widget) {
				MotionBlurCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(MotionBlurCheckBox);
			MotionBlurCheckBox.AddEventListener('CLIK_select', OnMotionBlurCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'DynamicLightsCheckBox':
			if (DynamicLightsCheckBox == none || DynamicLightsCheckBox != Widget) {
				DynamicLightsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DynamicLightsCheckBox);
			DynamicLightsCheckBox.AddEventListener('CLIK_select', OnDynamicLightsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'DynamicShadowsCheckBox':
			if (DynamicShadowsCheckBox == none || DynamicShadowsCheckBox != Widget) {
				DynamicShadowsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DynamicShadowsCheckBox);
			DynamicShadowsCheckBox.AddEventListener('CLIK_select', OnDynamicShadowsCheckBoxSelect);
			//addeventlistener here
			bWasHandled = true;
			break;
		case 'TextureDetailDropDown':
			if (TextureDetailDropDown == none || TextureDetailDropDown != Widget) {
				TextureDetailDropDown = Rx_GFxDropDown(Widget);
			}
			SetUpDataProvider(TextureDetailDropDown);
			GetLastSelection(TextureDetailDropDown);
			TextureDetailDropDown.AddEventListener('CLIK_change', OnTextureDetailDropDownChange);
			bWasHandled = true;
			break;
		case 'DetailLevelDropDown':
			if (DetailLevelDropDown == none || DetailLevelDropDown != Widget) {
				DetailLevelDropDown = Rx_GFxDropDown(Widget);
			}
			SetUpDataProvider(DetailLevelDropDown);
			GetLastSelection(DetailLevelDropDown);
			DetailLevelDropDown.AddEventListener('CLIK_change', OnDetailLevelDropDownChange);
			bWasHandled = true;
			break;
		case 'CharacterLODDropDown':
			if (CharacterLODDropDown == none || CharacterLODDropDown != Widget) {
				CharacterLODDropDown = Rx_GFxDropDown(Widget);
			}
			SetUpDataProvider(CharacterLODDropDown);
			GetLastSelection(CharacterLODDropDown);
			CharacterLODDropDown.AddEventListener('CLIK_change', OnCharacterLODDropDownChange);
			bWasHandled = true;
			break;
		case 'EffectsLODDropDown':
			if (EffectsLODDropDown == none || EffectsLODDropDown != Widget) {
				EffectsLODDropDown = Rx_GFxDropDown(Widget);
			}
			SetUpDataProvider(EffectsLODDropDown);
			GetLastSelection(EffectsLODDropDown);
			EffectsLODDropDown.AddEventListener('CLIK_change', OnEffectsLODDropDownChange);
			bWasHandled = true;
			break;
		case 'ShadowQualityDropDown':
			if (ShadowQualityDropDown == none || ShadowQualityDropDown != Widget) {
				ShadowQualityDropDown = Rx_GFxDropDown(Widget);
			}
			SetUpDataProvider(ShadowQualityDropDown);
			GetLastSelection(ShadowQualityDropDown);
			ShadowQualityDropDown.AddEventListener('CLIK_change', OnShadowQualityDropDownChange);
			bWasHandled = true;
			break;
		case 'EnabledGoreCheckBox':
			if (EnabledGoreCheckBox == none || EnabledGoreCheckBox != Widget) {
				EnabledGoreCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(EnabledGoreCheckBox);
			EnabledGoreCheckBox.AddEventListener('CLIK_select', OnEnabledGoreCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'FOVSlider':
			if (FOVSlider == none || FOVSlider != Widget) {
				FOVSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(FOVSlider);
			FOVSlider.AddEventListener('CLIK_valueChange', OnFOVSliderChange);
			bWasHandled = true;
			break;
		case 'FOVLabel':
			if (FOVLabel == none || FOVLabel != Widget) {
				FOVLabel = GFxClikWidget(Widget);
			}
			FOVLabel.SetText(SettingsCurrentVideo.FOVValue);
			bWasHandled = true;
			break;
		case 'LightEnvironmentShadowsCheckBox':
			if (LightEnvironmentShadowsCheckBox == none || LightEnvironmentShadowsCheckBox != Widget) {
				LightEnvironmentShadowsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(LightEnvironmentShadowsCheckBox);
			LightEnvironmentShadowsCheckBox.AddEventListener('CLIK_select', OnLightEnvironmentShadowsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'CompositeDynamicLightsCheckBox':
			if (CompositeDynamicLightsCheckBox == none || CompositeDynamicLightsCheckBox != Widget) {
				CompositeDynamicLightsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(CompositeDynamicLightsCheckBox);
			CompositeDynamicLightsCheckBox.AddEventListener('CLIK_select', OnCompositeDynamicLightsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'DirectionalLightmapsCheckBox':
			if (DirectionalLightmapsCheckBox == none || DirectionalLightmapsCheckBox != Widget) {
				DirectionalLightmapsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DirectionalLightmapsCheckBox);
			DirectionalLightmapsCheckBox.AddEventListener('CLIK_select', OnDirectionalLightmapsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'BloomDoFCheckBox'://should bloom
			if (BloomDoFCheckBox == none || BloomDoFCheckBox != Widget) {
				BloomDoFCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(BloomDoFCheckBox);
			BloomDoFCheckBox.AddEventListener('CLIK_select', OnBloomDoFCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'BloomSlider':
			if (BloomSlider == none || BloomSlider != Widget) {
				BloomSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(BloomSlider);
			BloomSlider.AddEventListener('CLIK_valueChange', OnBloomSliderChange);
			bWasHandled = true;
			break;
		case 'BloomLabel':
			if (BloomLabel == none || BloomLabel != Widget) {
				BloomLabel = GFxClikWidget(Widget);
			}
			BloomLabel.SetText(Left(""$SettingsCurrentVideo.BloomValue, InStr(""$SettingsCurrentVideo.BloomValue, ".")+3));
			bWasHandled = true;
			break;
		case 'AmbientOcclusionCheckBox'://should doF
			if (AmbientOcclusionCheckBox == none || AmbientOcclusionCheckBox != Widget) {
				AmbientOcclusionCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(AmbientOcclusionCheckBox);
			AmbientOcclusionCheckBox.AddEventListener('CLIK_select', OnAmbientOcclusionCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'LensFlaresCheckBox':
			if (LensFlaresCheckBox == none || LensFlaresCheckBox != Widget) {
				LensFlaresCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(LensFlaresCheckBox);
			LensFlaresCheckBox.AddEventListener('CLIK_select', OnLensFlaresCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'DistortionCheckBox':
			if (DistortionCheckBox == none || DistortionCheckBox != Widget) {
				DistortionCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DistortionCheckBox);
			DistortionCheckBox.AddEventListener('CLIK_select', OnDistortionCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'ParticleDistortionDroppingCheckBox':
			if (ParticleDistortionDroppingCheckBox == none || ParticleDistortionDroppingCheckBox != Widget) {
				ParticleDistortionDroppingCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(ParticleDistortionDroppingCheckBox);
			ParticleDistortionDroppingCheckBox.AddEventListener('CLIK_select', OnParticleDistortionDroppingCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'StaticDecalsCheckBox':
			if (StaticDecalsCheckBox == none || StaticDecalsCheckBox != Widget) {
				StaticDecalsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(StaticDecalsCheckBox);
			StaticDecalsCheckBox.AddEventListener('CLIK_select', OnStaticDecalsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'DynamicDecalsCheckBox':
			if (DynamicDecalsCheckBox == none || DynamicDecalsCheckBox != Widget) {
				DynamicDecalsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(DynamicDecalsCheckBox);
			DynamicDecalsCheckBox.AddEventListener('CLIK_select', OnDynamicDecalsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'FramerateSmoothingCheckBox':
			if (FramerateSmoothingCheckBox == none || FramerateSmoothingCheckBox != Widget) {
				FramerateSmoothingCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(FramerateSmoothingCheckBox);
			FramerateSmoothingCheckBox.AddEventListener('CLIK_select', OnFramerateSmoothingCheckBoxSelect);
			bWasHandled = true;
			break;

		/************************************* [Settings - Audio] *****************************************/
		case'SFXVolumeSlider':
			if (SFXVolumeSlider == none || SFXVolumeSlider != Widget) {
				SFXVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(SFXVolumeSlider);
			SFXVolumeSlider.AddEventListener('CLIK_valueChange', OnSFXVolumeSliderChange);
			bWasHandled = true;
			break;
		case'SFXVolumeLabel':
			if (SFXVolumeLabel == none || SFXVolumeLabel != Widget) {
				SFXVolumeLabel = GFxClikWidget(Widget);
			}
			SFXVolumeLabel.SetText(int(SettingsCurrentAudio.SFXVolumeValue*100) $"%");
			bWasHandled = true;
			break;
		case'MusicVolumeSlider':
			if (MusicVolumeSlider == none || MusicVolumeSlider != Widget) {
				MusicVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(MusicVolumeSlider);
			MusicVolumeSlider.AddEventListener('CLIK_valueChange', OnMusicVolumeSliderChange);
			bWasHandled = true;
			break;
		case'MusicVolumeLabel':
			if (MusicVolumeLabel == none || MusicVolumeLabel != Widget) {
				MusicVolumeLabel = GFxClikWidget(Widget);
			}
			MusicVolumeLabel.SetText(int(SettingsCurrentAudio.MusicVolumeValue*100) $"%");
			bWasHandled = true;
			break;  
		case'AmbianceVolumeSlider':
			if (AmbianceVolumeSlider == none || AmbianceVolumeSlider != Widget) {
				AmbianceVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(AmbianceVolumeSlider);
			AmbianceVolumeSlider.AddEventListener('CLIK_valueChange', OnAmbianceVolumeSliderChange);
			bWasHandled = true;
			break;
		case'AmbianceVolumeLabel':
			if (AmbianceVolumeLabel == none || AmbianceVolumeLabel != Widget) {
				AmbianceVolumeLabel = GFxClikWidget(Widget);
			}
			AmbianceVolumeLabel.SetText(int(SettingsCurrentAudio.AmbianceVolumeValue*100) $"%");
			bWasHandled = true;
			break;
		case'DialogueVolumeSlider':
			if (DialogueVolumeSlider == none || DialogueVolumeSlider != Widget) {
				DialogueVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(DialogueVolumeSlider);
			DialogueVolumeSlider.AddEventListener('CLIK_valueChange', OnCharacterVolumeSliderChange);
			bWasHandled = true;
			break;
		case'DialogueVolumeLabel':
			if (DialogueVolumeLabel == none || DialogueVolumeLabel != Widget) {
				DialogueVolumeLabel = GFxClikWidget(Widget);
			}
			DialogueVolumeLabel.SetText(int(SettingsCurrentAudio.CharacterVolumeValue*100) $"%");
			bWasHandled = true;
			break;
		case'AnnouncerVolumeSlider':
			if (AnnouncerVolumeSlider == none || AnnouncerVolumeSlider != Widget) {
				AnnouncerVolumeSlider = GFxClikWidget(Widget);
			}
			GetLastSelection(AnnouncerVolumeSlider);
			AnnouncerVolumeSlider.AddEventListener('CLIK_valueChange', OnAnnouncerVolumeSliderChange);
			bWasHandled = true;
			break;
		case'AnnouncerVolumeLabel':
			if (AnnouncerVolumeLabel == none || AnnouncerVolumeLabel != Widget) {
				AnnouncerVolumeLabel = GFxClikWidget(Widget);
			}
			AnnouncerVolumeLabel.SetText(int(SettingsCurrentAudio.AnnouncerVolumeValue*100) $"%");
			bWasHandled = true;
			break;
		case'HardwareOpenALCheckBox':
			if (HardwareOpenALCheckBox == none || HardwareOpenALCheckBox != Widget) {
				HardwareOpenALCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(HardwareOpenALCheckBox);
			HardwareOpenALCheckBox.AddEventListener('CLIK_select', OnHardwareOpenALCheckBoxSelect);
			HardwareOpenALCheckBox.SetBool("enabled", false);
			bWasHandled = true;
			break;
		case'AutoplayMusicCheckBox':
			if (AutoplayMusicCheckBox == none || AutoplayMusicCheckBox != Widget) {
				AutoplayMusicCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(AutoplayMusicCheckBox);
			AutoplayMusicCheckBox.AddEventListener('CLIK_select', OnAutoplayMusicCheckBoxSelect);
			bWasHandled = true;
			break;
		case'PlayButton':
			if (PlayButton == none || PlayButton != Widget) {
				PlayButton = GFxClikWidget(Widget);
 				PlayButton.SetObject("group", PlayerControlGroup);
			}
 			GetLastSelection(PlayButton);
			//PlayButton.SetBool("enabled", false);
			bWasHandled = true;
			break;
		case'StopButton':
			if (StopButton == none || StopButton != Widget) {
				StopButton = GFxClikWidget(Widget);
				StopButton.SetObject("group", PlayerControlGroup);
			}
			GetLastSelection(StopButton);
			//StopButton.SetBool("enabled", false);
			bWasHandled = true;
			break;
		case'ShuffleButton':
			if (ShuffleButton == none || ShuffleButton != Widget) {
				ShuffleButton = GFxClikWidget(Widget);
			}
 			GetLastSelection(ShuffleButton);
 			ShuffleButton.AddEventListener('CLIK_itemClick', OnShuffleButtonSelect);
			//ShuffleButton.SetBool("enabled", false);
			bWasHandled = true;
			break;
		case'MusicTrackScrollBar':
			if (MusicTrackScrollBar == none || MusicTrackScrollBar != Widget) {
				MusicTrackScrollBar = GFxClikWidget(Widget);
			}
			GetLastSelection(MusicTrackScrollBar);
			//MusicTrackScrollBar.SetBool("enabled", false);
			bWasHandled = true;
			break;
		case'MusicTracklist':
			if (MusicTracklist == none || MusicTracklist != Widget) {
				MusicTracklist = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MusicTracklist);
 			GetLastSelection(MusicTracklist);
 			MusicTracklist.AddEventListener('CLIK_itemClick', OnMusicTracklistItemClick);
			//nBab
			//MusicTracklist.SetBool("disabled", true);
			bWasHandled = true;
			break;
		//nBab
		case'MusicCheckBoxlist':
			if (MusicCheckBoxlist == none || MusicCheckBoxlist != Widget) {
				MusicCheckBoxlist = GFxClikWidget(Widget);
			}
			SetUpDataProvider(MusicCheckBoxlist);
 			GetLastSelection(MusicCheckBoxlist);
 			MusicCheckBoxlist.AddEventListener('CLIK_itemClick', OnMusicCheckBoxlistItemClick);
			bWasHandled = true;
			break;
		case'TrackNameLabel':
			if (TrackNameLabel == none || TrackNameLabel != Widget) {
				TrackNameLabel = GFxClikWidget(Widget);
			}

			i = MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
			if (i >= 0 ) {
				TrackNameLabel.SetText(MainFrontEnd.JukeBox.JukeBoxList[i].TrackName);
			} else {
				if (MainFrontEnd.JukeBox.CurrentTrack.TrackName != "") {
					TrackNameLabel.SetText(MainFrontEnd.JukeBox.CurrentTrack.TrackName);
				} else {
					TrackNameLabel.SetText("");				
				}
			}
			bWasHandled = true;
			break;
		case'SettingsAudioActionBar':
			if (SettingsAudioActionBar == none || SettingsAudioActionBar != Widget) {
				SettingsAudioActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SettingsAudioActionBar);
			SettingsAudioActionBar.AddEventListener('CLIK_buttonClick', OnSettingsAudioActionBarChange);
			bWasHandled = true;
			break;
		//setting kill sound widget (nBab)
		case 'KillSoundDropDown':
			if (KillSoundDropDown == none || KillSoundDropDown != Widget) {
				KillSoundDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(KillSoundDropDown);
			GetLastSelection(KillSoundDropDown);
			KillSoundDropDown.AddEventListener('CLIK_change', OnKillSoundDropDownChange);
			bWasHandled = true;
			break;
		//setting kill sound play button widget (nBab)
		case 'KillSoundPlayButton':
			if (KillSoundPlayButton == none || KillSoundPlayButton != Widget) {
				KillSoundPlayButton = GFxClikWidget(Widget);
			}
			GetLastSelection(KillSoundPlayButton);
			KillSoundPlayButton.AddEventListener('CLIK_click', OnKillSoundPlayButtonChange);
			bWasHandled = true;
			break;

		/************************************* [Settings - Input] *****************************************/

		case 'MouseSensitivitySlider':
			if (MouseSensitivitySlider == none || MouseSensitivitySlider != Widget) {
				MouseSensitivitySlider = GFxClikWidget(Widget);
			}
			GetLastSelection(MouseSensitivitySlider);
			MouseSensitivitySlider.AddEventListener('CLIK_valueChange', OnMouseSensitivitySliderChange);
			bWasHandled = true;
			break;
		case 'MouseSensitivityInput':
			if (MouseSensitivityInput == none || MouseSensitivityInput != Widget) {
				MouseSensitivityInput = GFxClikWidget(Widget);
			}
			GetLastSelection(MouseSensitivityInput);
			MouseSensitivityInput.AddEventListener('CLIK_focusIn', OnMouseSensitivityInputFocusIn);
			MouseSensitivityInput.AddEventListener('CLIK_focusOut', OnMouseSensitivityInputFocusOut);
			MouseSensitivityInput.AddEventListener('CLIK_textChange', OnMouseSensitivityInputTextChange);
			bWasHandled = true;
			break;
		case 'GamepadSensitivitySlider':
			if (GamepadSensitivitySlider == none || GamepadSensitivitySlider != Widget) {
				GamepadSensitivitySlider = GFxClikWidget(Widget);
			}
			GetLastSelection(GamepadSensitivitySlider);
			GamepadSensitivitySlider.AddEventListener('CLIK_valueChange', OnGamepadSensitivitySliderChange);
			GamepadSensitivitySlider.SetBool("enabled", false);
			bWasHandled = true;
			break;
		case 'GamepadSensitivityInput':
			if (GamepadSensitivityInput == none || GamepadSensitivityInput != Widget) {
				GamepadSensitivityInput = GFxClikWidget(Widget);
			}
			GetLastSelection(GamepadSensitivityInput);
			GamepadSensitivityInput.AddEventListener('CLIK_focusIn', OnGamepadSensitivityInputFocusIn);
			GamepadSensitivityInput.AddEventListener('CLIK_focusOut', OnGamepadSensitivityInputFocusOut);
			GamepadSensitivityInput.AddEventListener('CLIK_textChange', OnGamepadSensitivityInputTextChange);
			GamepadSensitivityInput.SetBool("enabled", false);
			bWasHandled = true;
			break;
		case 'MouseSmoothingCheckBox':
			if (MouseSmoothingCheckBox == none || MouseSmoothingCheckBox != Widget) {
				MouseSmoothingCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(MouseSmoothingCheckBox);
			MouseSmoothingCheckBox.AddEventListener('CLIK_select', OnMouseSmoothingCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'InvertYCheckBox':
			if (InvertYCheckBox == none || InvertYCheckBox != Widget) {
				InvertYCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(InvertYCheckBox);
			InvertYCheckBox.AddEventListener('CLIK_select', OnInvertYCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'WeaponHandDropDown':
			if (WeaponHandDropDown == none || WeaponHandDropDown != Widget) {
				WeaponHandDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(WeaponHandDropDown);
			GetLastSelection(WeaponHandDropDown);
			WeaponHandDropDown.AddEventListener('CLIK_change', OnWeaponHandDropDownChange);
			bWasHandled = true;
			break;
		case 'TankReverseCheckBox':
			if (TankReverseCheckBox == none || TankReverseCheckBox != Widget) {
				TankReverseCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(TankReverseCheckBox);
			TankReverseCheckBox.AddEventListener('CLIK_select', OnTankReverseCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'ToggleADSCheckBox':
			if (ToggleADSCheckBox == none || ToggleADSCheckBox != Widget) {
				ToggleADSCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(ToggleADSCheckBox);
			ToggleADSCheckBox.AddEventListener('CLIK_select', OnToggleADSCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'ToggleCrouchCheckBox':
			if (ToggleCrouchCheckBox == none || ToggleCrouchCheckBox != Widget) {
				ToggleCrouchCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(ToggleCrouchCheckBox);
			ToggleCrouchCheckBox.AddEventListener('CLIK_select', OnToggleCrouchCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'ToggleSprintCheckBox':
			if (ToggleSprintCheckBox == none || ToggleSprintCheckBox != Widget) {
				ToggleSprintCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(ToggleSprintCheckBox);
			ToggleSprintCheckBox.AddEventListener('CLIK_select', OnToggleSprintCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'UseClassicTeamNameColorsCheckBox':
			if (UseClassicTeamNameColorsCheckBox == none || UseClassicTeamNameColorsCheckBox != Widget) {
				UseClassicTeamNameColorsCheckBox = GFxClikWidget(Widget);
			}
			GetLastSelection(UseClassicTeamNameColorsCheckBox);
			UseClassicTeamNameColorsCheckBox.AddEventListener('CLIK_select', OnUseClassicTeamNameColorsCheckBoxSelect);
			bWasHandled = true;
			break;
		case 'KeyBindingList':
			if (KeyBindingList == none || KeyBindingList != Widget) {
				KeyBindingList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(KeyBindingList);
			GetLastSelection(KeyBindingList);
			bWasHandled = true;
			break;
		case 'BindingPrimaryList':
			if (BindingPrimaryList == none || BindingPrimaryList != Widget) {
				BindingPrimaryList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(BindingPrimaryList);
			GetLastSelection(BindingPrimaryList);
			BindingPrimaryList.AddEventListener('CLIK_listIndexChange', OnBindingPrimaryListItemClick);
			bWasHandled = true;
			break;
		case 'BindingSecondaryList':
			if (BindingSecondaryList == none || BindingSecondaryList != Widget) {
				BindingSecondaryList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(BindingSecondaryList);
			GetLastSelection(BindingSecondaryList);
			BindingSecondaryList.AddEventListener('CLIK_listIndexChange', OnBindingSecondaryListItemClick);
			BindingSecondaryList.SetBool("enabled", false);
			BindingSecondaryList.SetVisible(false);
			bWasHandled = true;
			break;
		case 'keyBindScroll':
			if (keyBindScroll == none || keyBindScroll != Widget) {
				keyBindScroll = GFxClikWidget(Widget);
			}
			keyBindScroll.SetVisible(false);
			bWasHandled = true;
			break;
		case 'SettingsInputActionBar':
			if (SettingsInputActionBar == none || SettingsInputActionBar != Widget) {
				SettingsInputActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SettingsInputActionBar);
			SettingsInputActionBar.AddEventListener('CLIK_buttonClick', OnSettingsInputActionBarChange);
			bWasHandled = true;
			break;
		//setting tech building icon widget (nBab)
		case 'TechBuildingIconDropDown':
			if (TechBuildingIconDropDown == none || TechBuildingIconDropDown != Widget) {
				TechBuildingIconDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(TechBuildingIconDropDown);
			GetLastSelection(TechBuildingIconDropDown);
			TechBuildingIconDropDown.AddEventListener('CLIK_change', OnTechBuildingIconDropDownChange);
			bWasHandled = true;
			break;
		//setting beacon icon widget (nBab)
		case 'BeaconIconDropDown':
			if (BeaconIconDropDown == none || BeaconIconDropDown != Widget) {
				BeaconIconDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(BeaconIconDropDown);
			GetLastSelection(BeaconIconDropDown);
			BeaconIconDropDown.AddEventListener('CLIK_change', OnBeaconIconDropDownChange);
			bWasHandled = true;
			break;
		//setting crosshair color widget (nBab)
		case 'CrosshairColorDropDown':
			if (CrosshairColorDropDown == none || CrosshairColorDropDown != Widget) {
				CrosshairColorDropDown = GFxClikWidget(Widget);
			}
			SetUpDataProvider(CrosshairColorDropDown);
			GetLastSelection(CrosshairColorDropDown);
			CrosshairColorDropDown.AddEventListener('CLIK_change', OnCrosshairColorDropDownChange);
			bWasHandled = true;
			break;
		//setting crosshair color text widget (nBab)
		case 'CrosshairColorText':
			Widget.setText("Crosshair Color:");
			bWasHandled = true;
			break;
		//setting beacon icon text widget (nBab)
		case 'BeaconIconText':
			Widget.setText("Beacon Icon:");
			bWasHandled = true;
			break;
		//setting tech building icon text widget (nBab)
		case 'TechBuildingIconText':
			Widget.setText("Tech Building Icon:");
			bWasHandled = true;
			break;
		//setting use hardware physics text widget (nBab)
		case 'UseHardwarePhysicsText':
			Widget.setText("Use Hardware PhysX:");
			bWasHandled = true;
			break;
		//setting allow d3d9msaa text widget (nBab)
		case 'AllowD3D9MSAAText':
			Widget.setText("Allow D3D9 MSAA:");
			bWasHandled = true;
			break;
		//setting kill sound text widget (nBab)
		case 'KillSoundText':
			Widget.setText("Kill Sound:");
			bWasHandled = true;
			break;
		default:
			`log("Unknown Widget: " $ WidgetName);
			break;
	}
	return bWasHandled;
}

function SetUpDataProvider(GFxClikWidget Widget)
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	`log("Rx_GFxFrontEnd_Settings::SetupDataProvider"@Widget.GetString("name"),true,'DevGFxUI');

	DataProvider = CreateObject("scaleform.clik.data.DataProvider");
	switch (Widget)
	{

		/************************************* [Settings - Video] *****************************************/

		case (SettingsVideoActionBar) :
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "BACK");
			TempObj.SetString("action", "back");
			DataProvider.SetElementObject(0, TempObj);
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "APPLY");
			TempObj.SetString("action", "apply");
			DataProvider.SetElementObject(1, TempObj);
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
			//GetPC().ClientMessage("Graphic Card Adapter: " $ Rx_Game(GetPC().WorldInfo.Game).GraphicAdapterCheck.GetGPUAdapterName());

			if (MainFrontEnd.GraphicAdapterCheck != none) {
				if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_Nvidia) {
					for(i = 5; i < ListAA.Length - 1; i++) {
						DataProvider.SetElementString(i, ListAA[i]);
					}
				} else if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_AMD) {
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
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "BACK");
			TempObj.SetString("action", "back");
			DataProvider.SetElementObject(0, TempObj);
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "APPLY");
			TempObj.SetString("action", "apply");
			DataProvider.SetElementObject(1, TempObj);
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
			for(i=0; i < MainFrontEnd.JukeBox.JukeBoxList.Length; i++) {
				TempObj = CreateObject("Object");
 				TempObj.SetString("label", (i+1) $ " - " $ MainFrontEnd.JukeBox.JukeBoxList[i].TrackName);
 				//removed toggle since we're using a separate checkbox list (nBab)
 				//TempObj.SetBool("toggled", MainFrontEnd.JukeBox.JukeBoxList[i].bSelected);
				DataProvider.SetElementObject(i, TempObj);
			}
			break;
		//setting music checkbox list data provider (nBab)
		case (MusicCheckBoxlist):
			for(i=0; i < MainFrontEnd.JukeBox.JukeBoxList.Length; i++) {
				TempObj = CreateObject("Object");
				TempObj.SetBool("toggled", MainFrontEnd.JukeBox.JukeBoxList[i].bSelected);
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
			DataProvider.SetElementString(11, "NONE");
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
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "BACK");
			TempObj.SetString("action", "back");
			DataProvider.SetElementObject(0, TempObj);
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "APPLY");
			TempObj.SetString("action", "apply");
			DataProvider.SetElementObject(1, TempObj);
			break;
		//setting tech building icon data provider (nBab)
		case (TechBuildingIconDropDown):
			DataProvider.SetElementString(0, "ANIMATING");
			DataProvider.SetElementString(1, "COLOR CHANGING");
			DataProvider.SetElementString(2, "NONE");
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
		default:
			return;
	}
	Widget.SetObject("dataProvider", DataProvider);
}
function GetLastSelection(GFxClikWidget Widget)
{
	local int i;

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
			case (FPSSlider) :
				Widget.SetInt("value", SettingsCurrentVideo.FPSValue);
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
				Rx_GFxDropDown(Widget).validateNow();
				break;
			case (DetailLevelDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.DetailLevelItemPosition);
				Rx_GFxDropDown(Widget).validateNow();
				break;
			case (CharacterLODDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.CharacterLODItemPosition);
				Rx_GFxDropDown(Widget).validateNow();
				break;
			case (EffectsLODDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.EffectsLODItemPosition);
				Rx_GFxDropDown(Widget).validateNow();
				break;
			case (ShadowQualityDropDown):
				Widget.SetInt("selectedIndex", SettingsCurrentVideo.ShadowQualityItemPosition);
				Rx_GFxDropDown(Widget).validateNow();
				break;
			case (EnabledGoreCheckBox):
				Widget.SetBool("selected",SettingsCurrentVideo.bEnableGore);
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
				Widget.SetBool("selected", SettingsCurrentVideo.bBloomDoF);
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
					i = MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
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
// 					if (MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue) >= 0) {
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
				Widget.SetBool("selected", MainFrontEnd.JukeBox.bShuffled);
				break;
			case (MusicTrackScrollBar):
				break;
			case (MusicTracklist):

				if (!Widget.GetBool("enabled")) {
					return;
				}
				//added check in case nothing is playing (nBab)
				if (MainFrontEnd.JukeBox.CurrentTrack.TheSoundCue == none)
					return;
				 i = MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
				if (i >=0){
					Widget.SetInt("selectedIndex", i);
				} else {
					Widget.SetInt("selectedIndex", 0);
				}
				break;
			//nBab
			case (MusicCheckBoxlist):

				if (!Widget.GetBool("enabled")) {
					return;
				}
				if (MainFrontEnd.JukeBox.CurrentTrack.TheSoundCue == none)
					return;
				i = MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
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
			case (ToggleCrouchCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInput.bToggleCrouch);
				break;
			case (ToggleSprintCheckBox) :
				Widget.SetBool("selected", SettingsCurrentInput.bToggleSprint);
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
			case (TechBuildingIconDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentInput.TechBuildingIcon);
				break;
			//nBab
			case (BeaconIconDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentInput.BeaconIcon);
				break;
			//nBab
			case (CrosshairColorDropDown) :
				Widget.SetInt("selectedIndex", SettingsCurrentInput.CrosshairColor);
				break;
			default:
				return;
		}
	}
	validateNow();
}

function ResetSettingsVideoOption()
{
	local byte i;

	//Get Resolution Position
	for (i = 0; i < Resolutions.length; i++) {
		if (Resolutions[i] == MainFrontEnd.SystemSettingsHandler.GetCurrentResolution()){
			SettingsCurrentVideo.ScreenResolutionItemPosition = i;
		}
	}

	//Get Screen Mode Position
	SettingsCurrentVideo.ScreenModeItemPosition = MainFrontEnd.SystemSettingsHandler.IsFullScreen()? 0 : 1;

	//Get The Graphics Presets Position
	SettingsCurrentVideo.GraphicPresetsItemPosition = MainFrontEnd.SystemSettingsHandler.GraphicsPresetLevel;

	//SystemSettingsHandler.DefaultAAType (Formerly CurrentAATypeSelection )
	SettingsCurrentVideo.AntiAliasingItemPosition = MainFrontEnd.SystemSettingsHandler.CurrentAAType;
	
	//MainFrontEnd.SystemSettingsHandler.CurrentTextureFilteringSelection
	SettingsCurrentVideo.TextureFilteringItemPosition = MainFrontEnd.SystemSettingsHandler.TextureFilteringLevel;

	SettingsCurrentVideo.TextureDetailItemPosition = MainFrontEnd.SystemSettingsHandler.TexturePresetLevel;

	SettingsCurrentVideo.BrightnessValue = MainFrontEnd.SystemSettingsHandler.GetGammaSettings() * 20;
	SettingsCurrentVideo.FPSValue = MainFrontEnd.SystemSettingsHandler.GetFPSSetting();
	SettingsCurrentVideo.bVSync = MainFrontEnd.SystemSettingsHandler.UseVsync;
	SettingsCurrentVideo.bDx10 = MainFrontEnd.SystemSettingsHandler.AllowD3D10;                                                                 // Useful for Dx10...not working ATM
	//nBab
	SettingsCurrentVideo.bAllowD3D9MSAA = MainFrontEnd.SystemSettingsHandler.bAllowD3D9MSAA;
	//nBab
	SettingsCurrentVideo.bUseHardwarePhysics = !MainFrontEnd.SystemSettingsHandler.GetDisablePhysXHardwareSupport();
	SettingsCurrentVideo.bMotionBlur = MainFrontEnd.SystemSettingsHandler.MotionBlur;
	SettingsCurrentVideo.bDynamicLights = MainFrontEnd.SystemSettingsHandler.DynamicLights;
	SettingsCurrentVideo.bDynamicShadows = MainFrontEnd.SystemSettingsHandler.DynamicShadows;
	SettingsCurrentVideo.DetailLevelItemPosition = MainFrontEnd.SystemSettingsHandler.DetailMode;
	SettingsCurrentVideo.CharacterLODItemPosition = (3 - MainFrontEnd.SystemSettingsHandler.SkeletalMeshLODBias) ;
	SettingsCurrentVideo.EffectsLODItemPosition = (3 - MainFrontEnd.SystemSettingsHandler.ParticleLODBias);
	SettingsCurrentVideo.ShadowQualityItemPosition = (3 - MainFrontEnd.SystemSettingsHandler.ShadowFilterQualityBias);
	SettingsCurrentVideo.bEnableGore = MainFrontEnd.SystemSettingsHandler.GetEnableGore();                                                                                                  //TODO:disable this
	SettingsCurrentVideo.FOVValue = MainFrontEnd.SystemSettingsHandler.GetFOV();
	SettingsCurrentVideo.bLightEnvironmentShadows = MainFrontEnd.SystemSettingsHandler.LightEnvironmentShadows;
	SettingsCurrentVideo.bCompositeDynamicLights = MainFrontEnd.SystemSettingsHandler.CompositeDynamicLights;
	SettingsCurrentVideo.bDirectionalLightmaps = MainFrontEnd.SystemSettingsHandler.DirectionalLightmaps;
	SettingsCurrentVideo.bBloomDoF = (MainFrontEnd.SystemSettingsHandler.Bloom || MainFrontEnd.SystemSettingsHandler.DepthOfField);
	SettingsCurrentVideo.bAmbientOcclusion = MainFrontEnd.SystemSettingsHandler.AmbientOcclusion;                                                     //TODO: NOT WORKING ATM
	SettingsCurrentVideo.bLensFlares = MainFrontEnd.SystemSettingsHandler.LensFlares;
	SettingsCurrentVideo.BloomValue = MainFrontEnd.SystemSettingsHandler.BloomThresholdLevel;
	SettingsCurrentVideo.bDistortion = MainFrontEnd.SystemSettingsHandler.Distortion;
	SettingsCurrentVideo.bParticleDistortionDropping = MainFrontEnd.SystemSettingsHandler.DropParticleDistortion;
	SettingsCurrentVideo.bStaticDecals = MainFrontEnd.SystemSettingsHandler.StaticDecals;
	SettingsCurrentVideo.bDynamicDecals = MainFrontEnd.SystemSettingsHandler.DynamicDecals;
	SettingsCurrentVideo.bFramerateSmoothing = MainFrontEnd.SystemSettingsHandler.GetEnableSmoothFramerate();
}

//PLEASE CREATE A SPECIAL class TO GET THE CURRENT AUDIO ETC... OR RESEARCG
function ResetSettingsAudioOption()
{
	
	SettingsCurrentAudio.AmbianceVolumeValue = MainFrontEnd.SystemSettingsHandler.AmbientSoundClass.Properties.Volume;
	SettingsCurrentAudio.AnnouncerVolumeValue = MainFrontEnd.SystemSettingsHandler.AnnouncerSoundClass.Properties.Volume;                       //TODO: PARSING ALL COMPONENTS;
	SettingsCurrentAudio.CharacterVolumeValue = MainFrontEnd.SystemSettingsHandler.CharacterSoundClass.Properties.Volume;
	SettingsCurrentAudio.MusicVolumeValue = MainFrontEnd.SystemSettingsHandler.MusicSoundClass.Properties.Volume;
	SettingsCurrentAudio.SFXVolumeValue = MainFrontEnd.SystemSettingsHandler.SFXSoundClass.Properties.Volume;

	SettingsCurrentAudio.bHardwareOpenAL = false;                                                                                               //TODO: Research Hardware AL Settings
	SettingsCurrentAudio.bAutostartMusic = MainFrontEnd.SystemSettingsHandler.bAutostartMusic;

	//nBab
	SettingsCurrentAudio.KillSound = MainFrontEnd.SystemSettingsHandler.GetKillSound();
}

function ResetSettingsInputOption()
{
	SettingsCurrentInput.bADS = MainFrontEnd.SystemSettingsHandler.GetToggleADS();
	SettingsCurrentInput.bToggleSprint = MainFrontEnd.SystemSettingsHandler.GetToggleSprint();
	SettingsCurrentInput.bToggleCrouch = MainFrontEnd.SystemSettingsHandler.GetToggleCrouch();
	SettingsCurrentInput.bNicknamesUseTeamColors = MainFrontEnd.SystemSettingsHandler.GetNicknamesUseTeamColors();
	SettingsCurrentInput.BindingPrimaryItemPosition = -1;
	SettingsCurrentInput.BindingSecondaryItemPosition = -1;
	SettingsCurrentInput.KeyBingdingItemPosition = -1;
	SettingsCurrentInput.bMouseSmoothing = MainFrontEnd.SystemSettingsHandler.GetEnableMouseSmoothing();
	SettingsCurrentInput.bInvertY = MainFrontEnd.SystemSettingsHandler.GetInvertYAxis();
	SettingsCurrentInput.bTankReverse = MainFrontEnd.SystemSettingsHandler.GetToggleTankReverse();
	SettingsCurrentInput.GamepadSensitivityValue = 0;                                                                                           //need to figure out 
	SettingsCurrentInput.MouseSensitivityValue = MainFrontEnd.SystemSettingsHandler.GetMouseSensitivity();
	SettingsCurrentInput.WeaponHandItemPosition = MainFrontEnd.SystemSettingsHandler.GetWeaponHand();                                           //will be basing on UTPC Weapon Hand Preference
	//nBab
	SettingsCurrentInput.TechBuildingIcon = MainFrontEnd.SystemSettingsHandler.GetTechBuildingIcon();
	SettingsCurrentInput.BeaconIcon = MainFrontEnd.SystemSettingsHandler.GetBeaconIcon();
	SettingsCurrentInput.CrosshairColor = MainFrontEnd.SystemSettingsHandler.GetCrosshairColor();
}

function OpenConfirmApplyVideoSettingsDialog()
{
	MainFrontEnd.OpenConfirmApplyVideoSettingsDialog();
}
function OpenVideoSettingsSuccessAlertDialog()
{
	MainFrontEnd.OpenVideoSettingsSuccessAlertDialog();
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

	MainFrontEnd.SystemSettingsHandler.ResX = int(Left(newResolution, ( Len(newResolution) - Len( Split( newResolution,"x",false ) ) ) ));
	MainFrontEnd.SystemSettingsHandler.ResY = int(Split(newResolution,"x",true));
	

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




	MainFrontEnd.SystemSettingsHandler.SetSettingBucket(SettingsCurrentVideo.GraphicPresetsItemPosition);

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
			SettingsCurrentVideo.FPSValue = 45;
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
			if (MainFrontEnd.GraphicAdapterCheck != none) {
				if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_Nvidia) {
					SettingsCurrentVideo.AntiAliasingItemPosition = 8;
				} else if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_AMD) {
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
			if (MainFrontEnd.GraphicAdapterCheck != none) {
				if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_Nvidia) {
					SettingsCurrentVideo.AntiAliasingItemPosition = ListAA.Length-2;
				} else if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_AMD) {
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


	
	if (MainFrontEnd.GraphicAdapterCheck != none) {
		if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_Nvidia) {
			MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		} else if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_AMD) {
			if (SettingsCurrentVideo.AntiAliasingItemPosition >= 5) {
				MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[ListAA.Length-1]);
			} else {
				MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
			}
		} else {
			MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		}
	}

	
	MainFrontEnd.SystemSettingsHandler.SetGammaSettings(float(SettingsCurrentVideo.BrightnessValue)*0.05);
	MainFrontEnd.SystemSettingsHandler.SetFPSSetting(SettingsCurrentVideo.FPSValue);
	MainFrontEnd.SystemSettingsHandler.SetFOV(float(SettingsCurrentVideo.FOVValue));
	MainFrontEnd.SystemSettingsHandler.SetAmbientOcclusion(SettingsCurrentVideo.bAmbientOcclusion);
	MainFrontEnd.SystemSettingsHandler.SetEnableSmoothFramerate(SettingsCurrentVideo.bFramerateSmoothing);
	MainFrontEnd.SystemSettingsHandler.SetEnableGore(SettingsCurrentVideo.bEnableGore);

	MainFrontEnd.SystemSettingsHandler.GraphicsPresetLevel = SettingsCurrentVideo.GraphicPresetsItemPosition;
	MainFrontEnd.SystemSettingsHandler.TexturePresetLevel = SettingsCurrentVideo.TextureDetailItemPosition;
	MainFrontEnd.SystemSettingsHandler.CurrentAAType = SettingsCurrentVideo.AntiAliasingItemPosition;
	MainFrontEnd.SystemSettingsHandler.TextureFilteringLevel = SettingsCurrentVideo.TextureFilteringItemPosition;
	MainFrontEnd.SystemSettingsHandler.SaveConfig();


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

	if (SettingsCurrentVideo.GraphicPresetsItemPosition != MainFrontEnd.SystemSettingsHandler.GraphicsPresetLevel) {
		SettingsCurrentVideo.GraphicPresetsItemPosition = MainFrontEnd.SystemSettingsHandler.GraphicsPresetLevel;
		GetLastSelection(GraphicPresetsDropDown);
	}

	return;
}

function ApplyCustomSettings()
{
	//if its a custom setting, then we set it per-componenets

	//AA	
	if (MainFrontEnd.GraphicAdapterCheck != none) {
		if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_Nvidia) {
			MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		} else if (MainFrontEnd.GraphicAdapterCheck.EVendor == V_AMD) {
			if (SettingsCurrentVideo.AntiAliasingItemPosition >= 5) {
				MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[ListAA.Length-1]);
			} else {
				MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
			}
		} else {
			MainFrontEnd.SystemSettingsHandler.SetAntiAliasing(ListAA[SettingsCurrentVideo.AntiAliasingItemPosition]);
		}
	}

	//TexFil
	MainFrontEnd.SystemSettingsHandler.SetTextureFiltering(SettingsCurrentVideo.TextureFilteringItemPosition);

	//Gamma
	MainFrontEnd.SystemSettingsHandler.SetGammaSettings(float(SettingsCurrentVideo.BrightnessValue)*0.05);

	// Max FPS 
	MainFrontEnd.SystemSettingsHandler.SetFPSSetting(SettingsCurrentVideo.FPSValue);

	//Vsync
	MainFrontEnd.SystemSettingsHandler.SetUseVsync(SettingsCurrentVideo.bVSync);

	//AllowD3D9MSAA (nBab)
	MainFrontEnd.SystemSettingsHandler.SetbAllowD3D9MSAA(SettingsCurrentVideo.bAllowD3D9MSAA);

	//UseHardwarePhysics (nBab)
	MainFrontEnd.SystemSettingsHandler.SetDisablePhysXHardwareSupport(!SettingsCurrentVideo.bUseHardwarePhysics);

	//MainFrontEnd.SystemSettingsHandler.SetAllowD3D10(SettingsCurrentVideo.bDx10);

	MainFrontEnd.SystemSettingsHandler.SetMotionBlur(SettingsCurrentVideo.bMotionBlur);
	MainFrontEnd.SystemSettingsHandler.SetDynamicLights(SettingsCurrentVideo.bDynamicLights);
	MainFrontEnd.SystemSettingsHandler.SetDynamicShadows(SettingsCurrentVideo.bDynamicShadows);
	
	MainFrontEnd.SystemSettingsHandler.SetTextureDetail(SettingsCurrentVideo.TextureDetailItemPosition);

	MainFrontEnd.SystemSettingsHandler.SetDetailMode(SettingsCurrentVideo.DetailLevelItemPosition);
	MainFrontEnd.SystemSettingsHandler.SetSkeletalMeshLODBias(3- (SettingsCurrentVideo.CharacterLODItemPosition));
	MainFrontEnd.SystemSettingsHandler.SetParticleLODBias(3 - (SettingsCurrentVideo.EffectsLODItemPosition));
	MainFrontEnd.SystemSettingsHandler.SetShadowFilterQualityBias(3 - (SettingsCurrentVideo.ShadowQualityItemPosition));
	MainFrontEnd.SystemSettingsHandler.SetEnableGore(SettingsCurrentVideo.bEnableGore);
	MainFrontEnd.SystemSettingsHandler.SetFOV(float(SettingsCurrentVideo.FOVValue));
	MainFrontEnd.SystemSettingsHandler.SetLightEnvironmentShadows(SettingsCurrentVideo.bLightEnvironmentShadows);
	MainFrontEnd.SystemSettingsHandler.SetCompositeDynamicLights(SettingsCurrentVideo.bCompositeDynamicLights);
	MainFrontEnd.SystemSettingsHandler.SetDirectionalLightmaps(SettingsCurrentVideo.bDirectionalLightmaps);
	MainFrontEnd.SystemSettingsHandler.SetBloom(SettingsCurrentVideo.bBloomDoF);                                                        //TODO: enable both bloom and dof
	MainFrontEnd.SystemSettingsHandler.SetDepthOfField(SettingsCurrentVideo.bBloomDoF);                                                 //TODO: enable both bloom and dof ! FIX this!
	MainFrontEnd.SystemSettingsHandler.SetAmbientOcclusion(SettingsCurrentVideo.bAmbientOcclusion);
	MainFrontEnd.SystemSettingsHandler.SetLensFlares(SettingsCurrentVideo.bLensFlares);
	MainFrontEnd.SystemSettingsHandler.SetBloomThreshold(SettingsCurrentVideo.BloomValue);

	MainFrontEnd.SystemSettingsHandler.SetDistortion(SettingsCurrentVideo.bDistortion);
	MainFrontEnd.SystemSettingsHandler.SetDropParticleDistortion(SettingsCurrentVideo.bParticleDistortionDropping);
	MainFrontEnd.SystemSettingsHandler.SetStaticDecals(SettingsCurrentVideo.bStaticDecals);
	MainFrontEnd.SystemSettingsHandler.SetDynamicDecals(SettingsCurrentVideo.bDynamicDecals);
	
	MainFrontEnd.SystemSettingsHandler.SetEnableSmoothFramerate(SettingsCurrentVideo.bFramerateSmoothing);

	
	MainFrontEnd.SystemSettingsHandler.GraphicsPresetLevel = SettingsCurrentVideo.GraphicPresetsItemPosition;
	MainFrontEnd.SystemSettingsHandler.TexturePresetLevel = SettingsCurrentVideo.TextureDetailItemPosition;
	MainFrontEnd.SystemSettingsHandler.CurrentAAType = SettingsCurrentVideo.AntiAliasingItemPosition;
	MainFrontEnd.SystemSettingsHandler.TextureFilteringLevel = SettingsCurrentVideo.TextureFilteringItemPosition;

	MainFrontEnd.SystemSettingsHandler.SaveConfig();

	ResetSettingsVideoOption();
}

function ApplyAudioSettings()
{
	MainFrontEnd.SystemSettingsHandler.SFXVolume = SettingsCurrentAudio.SFXVolumeValue;
	MainFrontEnd.SystemSettingsHandler.CharacterVolume = SettingsCurrentAudio.CharacterVolumeValue;
	MainFrontEnd.SystemSettingsHandler.MusicVolume = SettingsCurrentAudio.MusicVolumeValue;
	MainFrontEnd.SystemSettingsHandler.AnnouncerVolume = SettingsCurrentAudio.AnnouncerVolumeValue;
	MainFrontEnd.SystemSettingsHandler.AmbientVolume = SettingsCurrentAudio.AmbianceVolumeValue;
	//SettingsCurrentAudio.bHardwareOpenAL
	MainFrontEnd.SystemSettingsHandler.bAutostartMusic = SettingsCurrentAudio.bAutostartMusic;

	//nBab
	MainFrontEnd.SystemSettingsHandler.SetKillSound(SettingsCurrentAudio.KillSound);

	MainFrontEnd.SystemSettingsHandler.SaveConfig();
	
}
function ApplyInputSettings()
{

	//case 'MouseSensitivitySlider':
	//case 'MouseSensitivityInput':
	MainFrontEnd.SystemSettingsHandler.SetMouseSensitivity(SettingsCurrentInput.MouseSensitivityValue);

	MainFrontEnd.SystemSettingsHandler.SetEnableMouseSmoothing(SettingsCurrentInput.bMouseSmoothing);
	//case 'InvertYCheckBox':
	MainFrontEnd.SystemSettingsHandler.SetInvertYAxis(SettingsCurrentInput.bInvertY);
	//case 'WeaponHandDropDown':
	MainFrontEnd.SystemSettingsHandler.SetWeaponHand(SettingsCurrentInput.WeaponHandItemPosition);
	//case 'MouseSmoothingCheckBox':
	MainFrontEnd.SystemSettingsHandler.SetToggleTankReverse(SettingsCurrentInput.bTankReverse);
	//case 'EnableGamepadCheckBox':
	MainFrontEnd.SystemSettingsHandler.SetToggleADS(SettingsCurrentInput.bADS);
	MainFrontEnd.SystemSettingsHandler.SetToggleCrouch(SettingsCurrentInput.bToggleCrouch);
	MainFrontEnd.SystemSettingsHandler.SetToggleSprint(SettingsCurrentInput.bToggleSprint);
	//case 'NicknamesUseTeamColors'
	MainFrontEnd.SystemSettingsHandler.SetNicknamesUseTeamColors(SettingsCurrentInput.bNicknamesUseTeamColors);

	//nBab
	MainFrontEnd.SystemSettingsHandler.SetTechBuildingIcon(SettingsCurrentInput.TechBuildingIcon);
	MainFrontEnd.SystemSettingsHandler.SetBeaconIcon(SettingsCurrentInput.BeaconIcon);
	MainFrontEnd.SystemSettingsHandler.SetCrosshairColor(SettingsCurrentInput.CrosshairColor);

	//case 'KeyBindingList':
	//case 'BindingPrimaryList':
	//case 'BindingSecondaryList':
}

function SetGraphicPresetsToCustom()
{
	if (GraphicPresetsDropDown == none) return;
	SettingsCurrentVideo.GraphicPresetsItemPosition = 0;
	GraphicPresetsDropDown.SetInt("selectedIndex", SettingsCurrentVideo.GraphicPresetsItemPosition);
}

function OnScreenResolutionDropDownChange(GFxClikWidget.EventData ev) 
{
	SettingsCurrentVideo.ScreenResolutionItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnScreenModeDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentVideo.ScreenModeItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnGraphicPresetsDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentVideo.GraphicPresetsItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnAntiAliasingDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.AntiAliasingItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnTextureFilteringDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.TextureFilteringItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnBrightnessSliderChange(GFxClikWidget.EventData ev)
{
	local float outGammaValue;
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.BrightnessValue = ev._this.GetObject("target").GetInt("value"); 
	BrightnessLabel.SetText(SettingsCurrentVideo.BrightnessValue $ "%");
	outGammaValue = FClamp((ev._this.GetObject("target").GetFloat("value") * 0.05), 0.5, 5);
	MainFrontEnd.SystemSettingsHandler.SetGammaSettings(outGammaValue);
	ConsoleCommand("Gamma " $MainFrontEnd.SystemSettingsHandler.GetGammaSettings());
}
function OnFPSSliderChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.FPSValue = ev._this.GetObject("target").GetInt("value"); 
	FPSLabel.SetText(SettingsCurrentVideo.FPSValue);
}
function OnVSyncCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bVSync = ev._this.GetObject("target").GetBool("selected");
}
function OnDx10CheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDx10 = ev._this.GetObject("target").GetBool("selected");
}
//nBab
function OnAllowD3D9MSAACheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bAllowD3D9MSAA = ev._this.GetObject("target").GetBool("selected");
}
//nBab
function OnUseHardwarePhysicsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bUseHardwarePhysics = ev._this.GetObject("target").GetBool("selected");
}
function OnMotionBlurCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bMotionBlur = ev._this.GetObject("target").GetBool("selected");
}
function OnDynamicLightsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDynamicLights = ev._this.GetObject("target").GetBool("selected");
}
function OnDynamicShadowsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDynamicShadows = ev._this.GetObject("target").GetBool("selected");
}
function OnTextureDetailDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.TextureDetailItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnDetailLevelDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.DetailLevelItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnCharacterLODDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.CharacterLODItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnEffectsLODDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.EffectsLODItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnShadowQualityDropDownChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.ShadowQualityItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnEnabledGoreCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bEnableGore = ev._this.GetObject("target").GetBool("selected");
}
function OnFOVSliderChange(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.FOVValue = ev._this.GetObject("target").GetInt("value");
	FOVLabel.SetText(ev._this.GetObject("target").GetInt("value"));
}
function OnLightEnvironmentShadowsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bLightEnvironmentShadows = ev._this.GetObject("target").GetBool("selected");
}
function OnCompositeDynamicLightsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bCompositeDynamicLights = ev._this.GetObject("target").GetBool("selected");
}
function OnDirectionalLightmapsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDirectionalLightmaps = ev._this.GetObject("target").GetBool("selected");
}
function OnBloomDoFCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bBloomDoF = ev._this.GetObject("target").GetBool("selected");
}
function OnBloomSliderChange(GFxClikWidget.EventData ev)
{
	local string text;
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.BloomValue = ev._this.GetObject("target").GetFloat("value") / 100;
	text = "" $ (ev._this.GetObject("target").GetFloat("value") / 100);
	BloomLabel.SetText(Left(text, InStr(text, ".") + 3));
}
function OnAmbientOcclusionCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bAmbientOcclusion = ev._this.GetObject("target").GetBool("selected");
}
function OnLensFlaresCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bLensFlares = ev._this.GetObject("target").GetBool("selected");
}
function OnDistortionCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDistortion = ev._this.GetObject("target").GetBool("selected");
}
function OnParticleDistortionDroppingCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bParticleDistortionDropping = ev._this.GetObject("target").GetBool("selected");
}
function OnStaticDecalsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bStaticDecals = ev._this.GetObject("target").GetBool("selected");
}
function OnDynamicDecalsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bDynamicDecals = ev._this.GetObject("target").GetBool("selected");
}
function OnFramerateSmoothingCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SetGraphicPresetsToCustom();
	SettingsCurrentVideo.bFramerateSmoothing = ev._this.GetObject("target").GetBool("selected");
}

function OnSFXVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.SFXVolumeValue = ev._this.GetObject("target").GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume SFX " $SettingsCurrentAudio.SFXVolumeValue);
	SFXVolumeLabel.SetText(ev._this.GetObject("target").GetInt("value") $"%");
}
function OnMusicVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.MusicVolumeValue = ev._this.GetObject("target").GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Music " $SettingsCurrentAudio.MusicVolumeValue);
	//ConsoleCommand("MODIFYSOUNDCLASS Music VOL=" $SettingsCurrentAudio.MusicVolumeValue);
	MusicVolumeLabel.SetText(ev._this.GetObject("target").GetInt("value") $"%");
}
function OnAmbianceVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.AmbianceVolumeValue = ev._this.GetObject("target").GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Ambient " $SettingsCurrentAudio.AmbianceVolumeValue);
	AmbianceVolumeLabel.SetText(ev._this.GetObject("target").GetInt("value") $"%");
}
function OnCharacterVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.CharacterVolumeValue = ev._this.GetObject("target").GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Voice " $SettingsCurrentAudio.CharacterVolumeValue);
	DialogueVolumeLabel.SetText(ev._this.GetObject("target").GetInt("value") $"%");
}
function OnAnnouncerVolumeSliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.AnnouncerVolumeValue = ev._this.GetObject("target").GetInt("value") * 0.01;
	GetPC().ConsoleCommand("SetAudioGroupVolume Announcer " $SettingsCurrentAudio.AnnouncerVolumeValue);
	AnnouncerVolumeLabel.SetText(ev._this.GetObject("target").GetInt("value") $"%");
}
function OnHardwareOpenALCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.bHardwareOpenAL = ev._this.GetObject("target").GetBool("selected");
}

function OnAutoplayMusicCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.bAutostartMusic = ev._this.GetObject("target").GetBool("selected");
}

function OnMusicTracklistItemClick(GFxClikWidget.EventData ev)
{
	//disabled toggling because it's done by check box list now (nBab)
	/*local GFxObject item;

	item = ev._this.GetObject("item" );
	
	MainFrontEnd.JukeBox.JukeBoxList[ev.index].bSelected = item.GetBool("toggled");*/
}
//nBab
function OnMusicCheckBoxlistItemClick(GFxClikWidget.EventData ev)
{
	local GFxObject item;
	local int index;

	item = ev._this.GetObject("target").GetObject("itemRenderer");
	index = MusicCheckBoxList.GetInt("selectedIndex");

	//toggle the checkbox
	if (item.GetBool("toggled"))
		item.SetBool("toggled", false);
	else
		item.SetBool("toggled", true);

	//enable/disable the track based on the checkbox
	MainFrontEnd.JukeBox.JukeBoxList[index].bSelected = item.GetBool("toggled");
	
	//old code to disable the track which was commented because the clik component was buggy.
	//MusicTracklist.GetObject("dataProvider").GetElementObject(index).SetBool("disabled",!item.GetBool("toggled"));
	//if the same track is selected, deselect it.
	//if (MusicTracklist.GetInt("selectedIndex") == index)
	//	MusicTracklist.SetInt("selectedIndex",-1);
	
	//if the same track is being played, play the next bSelected track
	if (MainFrontEnd.JukeBox.JukeBoxList[index].TheSoundCue == GetPC().WorldInfo.MusicComp.SoundCue)
	{
		MainFrontEnd.JukeBox.Stop();
		MainFrontEnd.JukeBox.play(index);

		//if there's any enabled tracks
		if (MainFrontEnd.JukeBox.CurrentTrack.TheSoundCue != none)
		{
			index = MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
			TrackNameLabel.SetText(MainFrontEnd.JukeBox.JukeBoxList[index].TrackName);
		}
		else
		{
			TrackNameLabel.SetText("");
			DeselectPlayerButtonGroup();
		}
	}

	//save config
	MainFrontEnd.JukeBox.saveconfig();

}
//nBab
function OnKillSoundPlayButtonChange (GFxClikWidget.EventData ev)
{
	switch(KillSoundDropDown.GetInt("selectedIndex"))
	{
		case 0:		
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.SFX.SC_Boink');
			break;
		case 1:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Boink_Modern');
			break;
		case 2:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Kill_Alert_Cue');
			break;
		case 3:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Commando');
			break;
		case 4:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Havoc');
			break;
		case 5:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_McFarland');
			break;
		case 6:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Gotchya_Cue');
			break;
		case 7:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Aww_Too_Easy_Cue');
			break;
		case 8:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_For_Kane_Cue');
			break;
		case 9:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Die_Infidel_Cue');
			break;
		case 10:
			GetPC().ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Goat_Cue');
			break;	
		default:
			break;
	}
	ev._this.GetObject("target").SetBool("selected",false);
}
function OnPlayerControlGroupChange(GFxClikWidget.EventData ev)
{
	local GFxClikWidget SelectedItem;
	local int SelectedIndex;
	local int i;

	SelectedItem = GFxClikWidget(ev._this.GetObject("target").GetObject("selectedButton", class'GFxClikWidget'));
	
// 	GetPC().ClientMessage("Group Length? " $ PlayerControlGroup.GetInt("length"));
// 	GetPC().ClientMessage("SelectedItem?  " $ SelectedItem);

	switch (SelectedItem.GetString("name"))
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

				if (SelectedIndex >= 0 && MainFrontEnd.JukeBox.JukeBoxList[SelectedIndex].bSelected)
				{

					//old code (nBab)
					//if the music tracklist is not selected, select the default (0)
					/*if (SelectedIndex < 0) {
						SelectedIndex = 0;
			 			MusicTracklist.SetInt("selectedIndex", SelectedIndex);
					}*/

					//if nothing is selected, select the first enabled track (nBab)
					if (SelectedIndex < 0) {
						for (i=0;i<MainFrontEnd.JukeBox.JukeBoxList.length;i++)
						{
							if(MainFrontEnd.JukeBox.JukeBoxList[i].bSelected)
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
						MainFrontEnd.JukeBox.Stop();
						TrackNameLabel.SetText("");
						DeselectPlayerButtonGroup();
						return;
					}

					i = (MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue));
					//then check if we're playing our track AND if we're playing the same track as selected AND if we're playing
					if (i >= 0 && SelectedIndex == i && GetPC().WorldInfo.MusicComp.IsPlaying()) {
						return;
					}
					//~then we're playing a different track OR we're not playing our track.
					
					//stop the track, and play our selected track
					MainFrontEnd.JukeBox.Stop();

					//old code (nBab)
					//check if the selected track is selected
					/*if (MainFrontEnd.JukeBox.JukeBoxList[SelectedIndex].bSelected) {
						//play this
						MainFrontEnd.JukeBox.Play(SelectedIndex);
			 			TrackNameLabel.SetText(MainFrontEnd.JukeBox.JukeBoxList[selectedIndex].TrackName);
					} else {
			 			//loop through list if there is anything to be played.
			 			SelectedIndex = MainFrontEnd.JukeBox.JukeBoxList.Find('bSelected', true);
						if (SelectedIndex >= 0) {
							MainFrontEnd.JukeBox.Play(SelectedIndex);
			 				MusicTracklist.SetInt("selectedIndex", SelectedIndex);
			 				TrackNameLabel.SetText(MainFrontEnd.JukeBox.JukeBoxList[selectedIndex].TrackName);
						} else {
							TrackNameLabel.SetText("");
							DeselectPlayerButtonGroup();
						}
					}*/

					//set tracknamelable if there's a track playing, else set it to empty and deselect tracks (nBab)
					MainFrontEnd.JukeBox.Play(SelectedIndex);
					if(MainFrontEnd.JukeBox.CurrentTrack.TheSoundCue != none)
					{
						SelectedIndex = (MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue));
						MusicTracklist.SetInt("selectedIndex", SelectedIndex);
			 			TrackNameLabel.SetText(MainFrontEnd.JukeBox.JukeBoxList[selectedIndex].TrackName);
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
					MainFrontEnd.JukeBox.Stop();
				}
				
				TrackNameLabel.SetText("");
				//DeselectPlayerButtonGroup();
			}
			break;
		default:
			//GetPC().ClientMessage("Default Name? " $ SelectedItem.GetString("_name"));
			return;
	}
}

function MusicPlayerOnAudioFinished(AudioComponent AC)
{
	local int i;
	`log("MusicPlayerOnAudioFinished :: bStopped? "$ MainFrontEnd.JukeBox.bStopped $" | AC? " $ AC.Name $" | SoundCue? "$ AC.SoundCue );
	if (MainFrontEnd.JukeBox.bStopped) {
		return;
	}
	//find the current index
	
	i = MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
	if (i<0) {
		return;
	}

	//check if we're shuffling
	if (MainFrontEnd.JukeBox.bShuffled) {
		MainFrontEnd.JukeBox.Play(Rand(MainFrontEnd.JukeBox.JukeBoxList.Length));
	} else {
		if (i+1 < MainFrontEnd.JukeBox.JukeBoxList.Length) {
			MainFrontEnd.JukeBox.Play(i+1);
		} else {
			MainFrontEnd.JukeBox.Play(0);
		}
	}


	i = MainFrontEnd.JukeBox.JukeBoxList.Find('TheSoundCue', GetPC().WorldInfo.MusicComp.SoundCue);
	if (MusicTracklist != none) {
		MusicTracklist.SetInt("selectedIndex", i);
	}
	if (TrackNameLabel != none) {
		if (i>=0) {
			TrackNameLabel.SetText(MainFrontEnd.JukeBox.JukeBoxList[i].TrackName);
		} else {
			TrackNameLabel.SetText("");
		} 
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
	MainFrontEnd.JukeBox.bShuffled = ev._this.GetObject("target").GetBool("selected");
}
function OnMouseSensitivitySliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.MouseSensitivityValue = ev._this.GetObject("target").GetInt("value");
	MouseSensitivityInput.SetText(""$ev._this.GetObject("target").GetInt("value"));
}
function OnMouseSensitivityInputTextChange(GFxClikWidget.EventData ev)
{
	if (int(ev._this.GetObject("target").GetText()) != Clamp(int(ev._this.GetObject("target").GetText()), MouseSensitivitySlider.GetInt("minimum"), MouseSensitivitySlider.GetInt("maximum")))
		ev._this.GetObject("target").SetText(""$Clamp(int(ev._this.GetObject("target").GetText()), MouseSensitivitySlider.GetInt("minimum"), MouseSensitivitySlider.GetInt("maximum")));
	SettingsCurrentInput.MouseSensitivityValue = int(ev._this.GetObject("target").GetText());
	MouseSensitivitySlider.SetInt("value", int(ev._this.GetObject("target").GetText()));
}
function OnGamepadSensitivitySliderChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.GamepadSensitivityValue = ev._this.GetObject("target").GetInt("value");
	GamepadSensitivityInput.SetText(""$ev._this.GetObject("target").GetInt("value"));
}
function OnGamepadSensitivityInputTextChange(GFxClikWidget.EventData ev)
{
	if (int(ev._this.GetObject("target").GetText()) != Clamp(int(ev._this.GetObject("target").GetText()), GamepadSensitivitySlider.GetInt("minimum"), GamepadSensitivitySlider.GetInt("maximum")))
		ev._this.GetObject("target").SetText(""$Clamp(int(ev._this.GetObject("target").GetText()), GamepadSensitivitySlider.GetInt("minimum"), GamepadSensitivitySlider.GetInt("maximum")));
	SettingsCurrentInput.GamepadSensitivityValue = int(ev._this.GetObject("target").GetText());
	GamepadSensitivitySlider.SetInt("value", int(ev._this.GetObject("target").GetText()));
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
	SettingsCurrentInput.bMouseSmoothing = ev._this.GetObject("target").GetBool("selected");
}

function OnInvertYCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bInvertY = ev._this.GetObject("target").GetBool("selected");
}
function OnWeaponHandDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.WeaponHandItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
}
//nBab
function OnTechBuildingIconDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.TechBuildingIcon =ev._this.GetObject("target").GetInt("selectedIndex");
}
//nBab
function OnBeaconIconDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.BeaconIcon = ev._this.GetObject("target").GetInt("selectedIndex");
}
//nBab
function OnCrosshairColorDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.CrosshairColor = ev._this.GetObject("target").GetInt("selectedIndex");
}
//nBab
function OnKillSoundDropDownChange(GFxClikWidget.EventData ev)
{
	SettingsCurrentAudio.KillSound = ev._this.GetObject("target").GetInt("selectedIndex");
}
function OnTankReverseCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bTankReverse = ev._this.GetObject("target").GetBool("selected");
}
function OnToggleADSCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bADS = ev._this.GetObject("target").GetBool("selected");
}
function OnToggleCrouchCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bToggleCrouch = ev._this.GetObject("target").GetBool("selected");
}
function OnToggleSprintCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bToggleSprint = ev._this.GetObject("target").GetBool("selected");
}
function OnUseClassicTeamNameColorsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.bNicknamesUseTeamColors = ev._this.GetObject("target").GetBool("selected");
}

function OnBindingPrimaryListItemClick(GFxClikWidget.EventData ev)
{
	SettingsCurrentInput.BindingPrimaryItemPosition = ev._this.GetInt("index");

	if (CurrentPrimaryListItemRenderer != none) {
		if (CurrentPrimaryListItemRenderer.GetString("label") == "???") {
			//SetUpDataProvider(ev._this.GetObject("target"));
			CurrentPrimaryListItemRenderer.SetString("label", PreviousPrimaryListKey);
		}
	}

	if (ev._this.GetInt("index") != Clamp(ev._this.GetInt("index"), 0, BindingList.Length-1)) { //(ev.index < 0 || ev.index > totalBinding - 1) 
		return;
	}

	CurrentPrimaryListItemRenderer = GFxClikWidget(ev._this.GetObject("target").GetObject("itemRenderer", class'GFxClikWidget'));
	PreviousPrimaryListKey = CurrentPrimaryListItemRenderer.GetString("label");
	CurrentPrimaryListItemRenderer.SetString("label", "???");
	ev._this.GetObject("target").GetObject("dataProvider").SetElementString(ev._this.GetInt("index"), "???");
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
	ev._this.GetObject("target").SetInt("selectedIndex", -1);
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
	//local array<string> Konami;
	//Konami = ["Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "B", "A", "Enter"];
	// Only handle keypress if we are expecting one
	// then assign the binding
	if (CurrentPrimaryListItemRenderer != none ) {
		if (SettingsCurrentInput.BindingPrimaryItemPosition > -1 && CurrentPrimaryListItemRenderer.GetString("label") == "???" && InputEvent == IE_Pressed) {
			if (ButtonName == 'Escape') {
				SetUpDataProvider(BindingPrimaryList);
				BindingPrimaryList.SetInt("selectedIndex", -1);
				//CurrentPrimaryListItemRenderer = none;
				return false;
			}
			BindKey(ButtonName, BindingList[SettingsCurrentInput.BindingPrimaryItemPosition].Command);
			
			BindingPrimaryList.GetObject("dataProvider").SetElementString(SettingsCurrentInput.BindingPrimaryItemPosition, UDKPlayerInput(GetPC().PlayerInput).GetUDKBindNameFromCommand(BindingList[SettingsCurrentInput.BindingPrimaryItemPosition].Command));
			SetUpDataProvider(BindingPrimaryList);
			CurrentPrimaryListItemRenderer.SetString("label", "test");
			BindingPrimaryList.SetInt("selectedIndex", -1);
			//CurrentPrimaryListItemRenderer = none;
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
	switch (ev._this.GetObject("target").GetObject("data").GetString("action"))
	{
		case "back": MainFrontEnd.ReturnToBackground(); break;
		case "apply":
			OpenConfirmApplyVideoSettingsDialog();
			//MainFrontEnd.ReturnToBackground();
		break;
		default: break;
	}
}
function OnSettingsAudioActionBarChange(GFxClikWidget.EventData ev)
{
	switch (ev._this.GetObject("target").GetObject("data").GetString("action"))
	{
	  case "back": MainFrontEnd.ReturnToBackground(); break;
	  case "apply": 
	  		ApplyAudioSettings(); 
	  		//ApplyVideoSettings();
			//ApplyInputSettings();
			MainFrontEnd.ReturnToBackground();
	  	break;
	  default: break;
	}
}

function OnSettingsInputActionBarChange(GFxClikWidget.EventData ev)
{
	switch (ev._this.GetObject("target").GetObject("data").GetString("action"))
	{
		case "back": MainFrontEnd.ReturnToBackground(); break;
		case "apply": 
	  		//ApplyAudioSettings(); 
	  		//ApplyVideoSettings();
			ApplyInputSettings();
			MainFrontEnd.ReturnToBackground();
	  	break;
	  default: break;
	}
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
	SubWidgetBindings.Add((WidgetName="FPSSlider",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="FPSLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="VSyncCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="Dx10CheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MotionBlurCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DynamicLightsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="DynamicShadowsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="TextureDetailDropDown",WidgetClass=class'Rx_GFxDropDown'))
	SubWidgetBindings.Add((WidgetName="DetailLevelDropDown",WidgetClass=class'Rx_GFxDropDown'))
	SubWidgetBindings.Add((WidgetName="CharacterLODDropDown",WidgetClass=class'Rx_GFxDropDown'))
	SubWidgetBindings.Add((WidgetName="EffectsLODDropDown",WidgetClass=class'Rx_GFxDropDown'))
	SubWidgetBindings.Add((WidgetName="ShadowQualityDropDown",WidgetClass=class'Rx_GFxDropDown'))
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
	SubWidgetBindings.Add((WidgetName="SettingsAudioActionBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AutoplayMusicCheckBox",WidgetClass=class'GFxClikWidget'))
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
	SubWidgetBindings.Add((WidgetName="ToggleCrouchCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ToggleSprintCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="UseClassicTeamNameColorsCheckBox", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="KeyBindingList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BindingPrimaryList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BindingSecondaryList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="keyBindScroll",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="SettingsInputActionBar",WidgetClass=class'GFxClikWidget'))
	//nBab
	SubWidgetBindings.Add((WidgetName="TechBuildingIconDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="BeaconIconDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CrosshairColorDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="AllowD3D9MSAACheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="UseHardwarePhysicsCheckBox",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="KillSoundDropDown", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="MusicCheckBoxlist",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="KillSoundPlayButton",WidgetClass=class'GFxClikWidget'))
}