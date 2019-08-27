/**
 * Rx_SystemSettingsHandler
 *     Handler class to Get and Set values directly from systemSettings.ini
 *     Thanks  Crusha K. Rool for his amazing systemSettings class.
 * */
class Rx_SystemSettingsHandler extends Rx_Actor
	  dependson(UberPostProcessEffect) // <-- experimenting on settings that was not available on systemsettings.ini
	  config(XSettings);//config(RenegadeX);


var Engine engine;
var PlayerController PC;

var config float DefaultFOV;

var config int CurrentAAType;
var config int GraphicsPresetLevel;
var config int TexturePresetLevel;
var config int TextureFilteringLevel;

var config float BloomThresholdLevel;

var config float UIVolume;
var config float ItemVolume;
var config float VehicleVolume;
var config float WeaponVolume;
var config float SFXVolume;
var config float CharacterVolume;
var config float MusicVolume;
var config float AnnouncerVolume;
var config float MovieVoiceVolume;
var config float WeaponBulletEffectsVolume;
var config float OptionVoiceVolume;
var config float MovieEffectsVolume;
var config float AmbientVolume;
var config float UnGroupedVolume;

var config bool bAutostartMusic;

//Setting variables (nBab)
var config int TechBuildingIconPreference;
var config int BeaconIconPreference;
var config int CrosshairColorPreference;
var config int KillSoundPreference;
// Use team colors for player names. Otherwise show friendly/enemy
var config bool NicknamesUseTeamColors;

/*
;Audio Settings here
UIVolume = 1.0
ItemVolume = 1.0
VehicleVolume = 1.0
WeaponVolume = 1.0
SFXVolume = 1.0
CharacterVolume = 1.0
MusicVolume = 1.0
AnnouncerVolume = 1.0
MovieVoiceVolume = 1.0
WeaponBulletEffectsVolume = 1.0
OptionVoiceVolume = 1.0
MovieEffectsVolume = 1.0
AmbientVolume = 1.0
UnGroupedVolume = 1.0
 * */

/*
 * from defaultmenu-settings
CurrentAATypeSelection=0
CurrentTextureFilteringSelection=2
GraphicsPresetLevel=3
TexturePresetLevel=2
 * */

//======================================
// World Detail Settings
//======================================

/** (int) (1-3) Current detail mode; determines whether components of actors should be updated/ ticked.
 * Corresponds to the EDetailMode enum in Scene.uc, also set in PrimitiveComponent, and returned by WorldInfo.GetDetailMode() */
var() int DetailMode;
/** (UBOOL) Whether to allow rendering of SpeedTree leaves. */
var() bool SpeedTreeLeaves;
/** (UBOOL) Whether to allow rendering of SpeedTree fronds. */
var() bool SpeedTreeFronds;
/** (UBOOL) Whether to allow static decals. */
var() bool StaticDecals;
/** (UBOOL) Whether to allow dynamic decals. */
var() bool DynamicDecals;
/** (UBOOL) Whether to allow decals that have not been placed in static draw lists and have dynamic view relevance*/
var() bool UnbatchedDecals;
/** (float) Scale factor for distance culling decals*/
var() float DecalCullDistanceScale;
/** (UBOOL) Whether to allow dynamic lights.*/
var() bool DynamicLights;
/** (UBOOL) Whether to composte dynamic lights into light environments. */
var() bool CompositeDynamicLights;
/** (UBOOL) Whether to allow directional lightmaps, which use the material's normal and specular.*/
var() bool DirectionalLightmaps;
/** (UBOOL) Whether to allow motion blur.*/
var() bool MotionBlur;
/** (UBOOL) Whether to allow depth of field.*/
var() bool DepthOfField;
/** (UBOOL) Whether to allow ambient occlusion.*/
var() bool AmbientOcclusion;
/** (UBOOL) Whether to allow bloom. */
var() bool Bloom;
/** (UBOOL) Whether to use high quality bloom or fast versions.*/
var() bool UseHighQualityBloom;
/** (UBOOL) Whether to allow distortion.*/
var() bool Distortion;
/** (UBOOL) Whether to allow distortion to use bilinear filtering when sampling the scene color during its apply pass*/
var() bool FilteredDistortion;
/** (UBOOL) Whether to allow dropping distortion on particles based on WorldInfo::bDropDetail.*/
var() bool DropParticleDistortion;
/** (UBOOL) Whether to allow rendering of LensFlares.*/
var() bool LensFlares;
/** (UBOOL) Whether to allow fog volumes.*/
var() bool FogVolumes;
/** (UBOOL) Whether to allow floating point render targets to be used.*/
var() bool FloatingPointRenderTargets;
/** (UBOOL) Whether to allow the rendering thread to lag one frame behind the game thread.*/
var() bool OneFrameThreadLag;
/** (INT) LOD bias for skeletal meshes.*/
var() int SkeletalMeshLODBias;
/** (INT) LOD bias for particle systems.*/
var() int ParticleLODBias;
/** (UBOOL) Whether to use D3D10 when it's available. */
var() bool AllowD3D10;
/** (UBOOL) Whether to allow radial blur effects to render.*/
var() bool AllowRadialBlur;

//======================================
// Fractured Detail Settings
//======================================

/** (UBOOL) Whether to allow fractured meshes to take damage. */
var() bool bAllowFracturedDamage;
/** (FLOAT) Scales the game-specific number of fractured physics objects allowed.*/
var() float NumFracturedPartsScale;
/** (FLOAT) Percent chance of a rigid body spawning after a fractured static mesh is damaged directly. [0-1]*/
var() float FractureDirectSpawnChanceScale;
/** (float) Percent chance of a rigid body spawning after a fractured static mesh is damaged by radial blast. [0-1]  */
var() float FractureRadialSpawnChanceScale;
/** (float) Distance scale for whether a fractured static mesh should actually fracture when damaged  */
var() float FractureCullDistanceScale;

//======================================
// Shadow Detail Settings
//======================================

/** (UBOOL) Whether to allow dynamic shadows.*/
var() bool DynamicShadows;
/** (UBOOL) Whether to allow dynamic light environments to cast shadows.*/
var() bool LightEnvironmentShadows;
/** (INT) min dimensions (in texels) allowed for rendering shadow subject depths*/
var() int MinShadowResolution;
/** (INT) max square dimensions (in texels) allowed for rendering shadow subject depths*/
var() int MaxShadowResolution;
/** (FLOAT) The ratio of subject pixels to shadow texels.*/
var() float ShadowTexelsPerPixel;
/** (UBOOL) Toggle Branching PCF implementation for projected shadows*/
var() bool bEnableBranchingPCFShadows;
/** (UBOOL) Toggle extra geometry pass needed for culling shadows on emissive and backfaces*/
var() bool bAllowBetterModulatedShadows;
/** (UBOOL) hack to allow for foreground DPG objects to cast shadows on the world DPG*/
var() bool bEnableForegroundShadowsOnWorld;
/** (UBOOL) Whether to allow foreground DPG self-shadowing*/
var() bool bEnableForegroundSelfShadowing;
/** (float) Radius, in shadowmap texels, of the filter disk*/
var() float ShadowFilterRadius;
/** (float) Depth bias that is applied in the depth pass for all types of projected shadows except VSM*/
var() float ShadowDepthBias;
/** (INT) Resolution in texel below which shadows are faded out.*/
var() int ShadowFadeResolution;
/** (float) Controls the rate at which shadows are faded out.*/
var() float ShadowFadeExponent;
/** (float) Lights with radius below threshold will not cast shadow volumes.*/
var() float ShadowVolumeLightRadiusThreshold;
/** (FLOAT) Primitives with screen space percantage below threshold will not cast shadow volumes.*/
var() float ShadowVolumePrimitiveScreenSpacePercentageThreshold;

//======================================
// texture Detail Settings
//======================================

/** (UBOOL) If enabled, texture will only be streamed in, not out.*/
var() bool OnlyStreamInTextures;
/** (INT) Maximum level of anisotropy used.*/
var() int MaxAnisotropy;
/** (FLOAT) Scene capture streaming texture update distance scalar.*/
var() float SceneCaptureStreamingMultiplier;
/** (float) Foliage draw distance scalar.*/
var() float FoliageDrawRadiusMultiplier;

//======================================
// VSync Settings
//======================================

/** (UBOOL) Whether to use VSync or not.*/
var() bool UseVsync;

//======================================
// Screen Percentage Settings
//======================================

/** (float) Percentage of screen main view should take up.*/
var() float ScreenPercentage;
/** (UBOOL) Whether to upscale the screen to take up the full front buffer.*/
var() bool UpscaleScreenPercentage;

//======================================
// Resolution Settings
//======================================

/** (INT) Screen X resolution*/
var() int ResX;
/** (INT) Screen Y resolution*/
var() int ResY;
/** (UBOOL) Fullscreen*/
var() bool Fullscreen;

//======================================
// MSAA Settings
//======================================

/** (int) The maximum number of MSAA samples to use.*/
var() int MaxMultiSamples;

//======================================
// mesh Settings
//======================================

/** (UBOOL) Whether to force CPU access to GPU skinned vertex data.*/
var() bool bForceCPUAccessToGPUSkinVerts;
/** (UBOOL) Whether to disable instanced skeletal weights.*/
var() bool bDisableSkeletalInstanceWeights;


//======================================
// Additional Settings
//     [Unlisted in ConsoleCommand "scale Set"]
//======================================

/** Whether to allow light shafts.*/
var() bool bAllowLightShafts;
/** Whether to keep separate translucency (for better Depth of Field), experimental.*/
var() bool bAllowSeparateTranslucency;
/** Whether to allow post process MLAA to render. requires extra memory.*/
var() bool bAllowPostprocessMLAA;
/** Whether to use high quality materials when low quality exist.*/
var() bool bAllowHighQualityMaterials;
/** Max filter sample count.*/
var() int MaxFilterBlurSampleCount;
/** scale applied to primitive's MaxDrawDistance.*/
var() float MaxDrawDistanceScale;
/***/
var() bool bAllowD3D9MSAA;
/** min dimensions (in texels) allowed for rendering preshadow depths*/
var() int MinPreShadowResolution;
/** max square dimensions (in texels) allowed for rendering whole scene shadow depths.*/
var() int MaxWholeSceneDominantShadowResolution;
/** Whether to allow whole scene dominant shadows.*/
var() bool bAllowWholeSceneDominantShadows;
/** Whether to use safe and conservative shadow frustum creation that wastes some shadowmap space.*/
var() bool bUseConservativeShadowBounds;
/** If TRUE, allow APEX skinning to occur without blocking fetch results. bEnableParallelApexClothingFetch must be enabled for this to work.*/
var() bool bApexClothingAsyncFetchResults;

//======================================
// Debug Settings
//     [Unlisted in ConsoleCommand "scale Set"]
//======================================
/** Whether to use OpenGL when it's available.*/
var() bool AllowOpenGL;
/** Whether to allow sub-surface scattering to render.*/
var() bool AllowSubsurfaceScattering;
/** Whether to allow image reflections to render.*/
var() bool AllowImageReflections;
/** Whether to allow image reflections to be shadowed.*/
var() bool AllowImageReflectionShadowing;
/** */
var() bool bAllowTemporalAA;
/** */
var() float TemporalAA_MinDepth;
/** */
var() float TemporalAA_StartDepthVelocityScale;


//======================================
// Uncategorize Settings
//     [Unlisted in ConsoleCommand "scale Set"]
//======================================

/** Whether to allow light environments to use SH lights for secondary lighting.*/
var() bool SHSecondaryLighting;
/** Whether to allow motion blur to be paused.*/
var() bool MotionBlurPause;
/** state of the console variable MotionBlurSkinning.*/
var() int MotionBlurSkinning;
/** Whether to allow downsampled transluency.*/
var() bool bAllowDownsampledTranslucency;
/** Quality bias for projected shadow buffer filtering. Higher values use better quality filtering.*/
var() int ShadowFilterQualityBias;
/** Resolution in texel below which preshadows are faded out.*/
var() int PreShadowFadeResolution;
/** */
var() float PreShadowResolutionFactor;
/** Whether to allow hardware filtering optimizations like hardware PCF and Fetch4.*/
var() bool bAllowHardwareShadowFiltering;
/** global tessellation factor multiplier.*/
var() float TessellationAdaptivePixelsPerTriangle;
/** Higher values make the per object soft shadow comparison sharper, lower values make the transition softer.*/
var() float PerObjectShadowTransition;
/** Higher values make the per scene soft shadow comparison sharper, lower values make the transition softer.*/
var() float PerSceneShadowTransition;
/** Scale applied to the penumbra size of Cascaded Shadow Map splits, useful for minimizing the transition between splits.*/
var() float CSMSplitPenumbraScale;
/** Scale applied to the soft comparison transition distance of Cascaded Shadow Map splits, useful for minimizing the transition between splits.*/
var() float CSMSplitSoftTransitionDistanceScale;
/** Scale applied to the depth bias of Cascaded Shadow Map splits, useful for minimizing the transition between splits.*/
var() float CSMSplitDepthBiasScale;
/** Minimum camera FOV for CSM, this is used to prevent shadow shimmering when animating the FOV lower than the min, for example when zooming.*/
var() float CSMMinimumFOV;
/** The FOV will be rounded by this factor for the purposes of CSM, which turns shadow shimmering into discrete jumps.*/
var() float CSMFOVRoundFactor;
/** WholeSceneDynamicShadowRadius to use when using CSM to preview unbuilt lighting from a directional light.*/
var() float UnbuiltWholeSceneDynamicShadowRadius;
/** NumWholeSceneDynamicShadowCascades to use when using CSM to preview unbuilt lighting from a directional light.*/
var() int UnbuiltNumWholeSceneDynamicShadowCascades;
/** How many unbuilt light-primitive interactions there can be for a light before the light switches to whole scene shadows.*/
var() int WholeSceneShadowUnbuiltInteractionThreshold;
/** Whether to use high-precision GBuffers.*/
var() bool HighPrecisionGBuffers;
/** Whether to allow independent, external displays.*/
var() bool AllowSecondaryDisplays;
/** The maximum width of any potentially allowed secondary displays (requires bAllowSecondaryDisplays == true)*/
var() int SecondaryDisplayMaximumWidth;
/** The maximum height of any potentially allowed secondary displays (requires bAllowSecondaryDisplays == true)*/
var() int SecondaryDisplayMaximumHeight;

//======================================
// APEX Settings
//     [Unlisted in ConsoleCommand "scale Set"]
//======================================

/** Resource budget for APEX LOD. Higher values indicate the system can handle more APEX load.*/
var() float ApexLODResourceBudget;
/** The maximum number of active PhysX actors which represent dynamic groups of chunks (islands).*/
var() int ApexDestructionMaxChunkIslandCount;
/** The maximum number of PhysX shapes which represent destructible chunks.*/
var() int ApexDestructionMaxShapeCount;
/** Every destructible asset defines a min and max lifetime, and maximum separation distance for its chunks.*/
var() float ApexDestructionMaxChunkSeparationLOD;
/** Lets the user throttle the number of fractures processed per frame (per scene) due to destruction, as this can be quite costly. The default is 0xffffffff (unlimited).*/
var() int ApexDestructionMaxFracturesProcessedPerFrame;
/** Average Simulation Frequency is estimated with the last n frames. This is used in Clothing when bAllowAdaptiveTargetFrequency is enabled.*/
var() float ApexClothingAvgSimFrequencyWindow;
/** if set to true, destructible chunks with the lowest benefit would get removed first instead of the oldest.*/
var() bool ApexDestructionSortByBenefit;
/** Whether or not to use GPU Rigid Bodies.*/
var() bool ApexGRBEnable;
/** Amount (in MB) of GPU memory to allocate for GRB scene data (shapes, actors etc).*/
var() int ApexGRBGPUMemSceneSize;
/** Amount (in MB) of GPU memory to allocate for GRB temporary data (broadphase pairs, contacts etc).*/
var() int ApexGRBGPUMemTempDataSize;
/** The size of the cells to divide the world into for GPU collision detection.*/
var() float ApexGRBMeshCellSize;
/** Number of non-penetration solver iterations.*/
var() int ApexGRBNonPenSolverPosIterCount;
/** Number of friction solver position iterations.*/
var() int ApexGRBFrictionSolverPosIterCount;
/** Number of friction solver velocity iterations.*/
var() int ApexGRBFrictionSolverVelIterCount;
/** Collision skin width, as in PhysX.*/
var() float ApexGRBSkinWidth;
/** Maximum linear acceleration.*/
var() float ApexGRBMaxLinearAcceleration;
/** if TRUE, allow APEX clothing fetch (skinning etc) to be done on multiple threads.*/
var() bool bEnableParallelAPEXClothingFetch;
/** ClothingActors will cook in a background thread to speed up creation time.*/
var() bool ApexClothingAllowAsyncCooking;
/** Allow APEX SDK to interpolate clothing matrices between the substeps.*/
var() bool ApexClothingAllowApexWorkBetweenSubsteps;
/** */
var() int ApexDestructionMaxActorCreatesPerFrame;


//======================================
// Audio Settings
//     [listed in ConsoleCommand LISTSOUNDCLASSES] 
//======================================

/** Sound Component for UI */
var() SoundClass UISoundClass;
/** Sound Component for Item */
var() SoundClass ItemSoundClass;
/** Sound Component for Vehicle */
var() SoundClass VehicleSoundClass;
/** Sound Component for Weapon */
var() SoundClass WeaponSoundClass;
/** Sound Component for SFX */
var() SoundClass SFXSoundClass;
/** Sound Component for Character */
var() SoundClass CharacterSoundClass;
/** Sound Component for Music */
var() SoundClass MusicSoundClass;
/** Sound Component for Master */
var() SoundClass MasterSoundClass;
/** Sound Component for MovieVoice */
var() SoundClass MovieVoiceSoundClass;
/** Sound Component for WeaponBulletEffects */
var() SoundClass WeaponBulletEffectsSoundClass;
/** Sound Component for Announcer */
var() SoundClass AnnouncerSoundClass;
/** Sound Component for Cinematic */
var() SoundClass CinematicSoundClass;
/** Sound Component for MovieEffects */
var() SoundClass MovieEffectsSoundClass;
/** Sound Component for Ambient */
var() SoundClass AmbientSoundClass;
/** Sound Component for UnGrouped */
var() SoundClass UnGroupedSoundClass;


/** Reads scalable System Settings directly from the INI and populates
 * the variables in this class with the results if they did not have any value yet
 * as well as other settings that is not from SystemSettings.ini. */
final function PopulateSystemSettings()
{
	local string DumpString;
	local array<string> SettingsList;
	local int i;

	if (engine == none)
		engine = class'Engine'.static.GetEngine();
	if (PC == none)
		PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();

	DumpString = PC.ConsoleCommand("SCALE DUMP", false);
	SettingsList = SplitString(DumpString, "\n", true);
	for (i=1; i<SettingsList.Length; i++)
	{
		SettingsList[i] = Right(SettingsList[i], len(SettingsList[i])-4);
		if (Left(SettingsList[i],6) == "Mobile")
			continue;
		ParseSetting(SettingsList[i]);
	}

	DumpString = PC.ConsoleCommand("SCALE DUMPPREFS", false);
	SettingsList = SplitString(DumpString, "\n", true);
	for (i=1; i<SettingsList.Length; i++)
	{
		SettingsList[i] = Right(SettingsList[i], len(SettingsList[i])-4);
		if (Left(SettingsList[i],6) == "Mobile")
			continue;
		else
			ParseSetting(SettingsList[i]);
	}

	DumpString = PC.ConsoleCommand("SCALE DUMPDEBUG", false);
	SettingsList = SplitString(DumpString, "\n", true);
	for (i=1; i<SettingsList.Length; i++)
	{
		SettingsList[i] = Right(SettingsList[i], len(SettingsList[i])-4);
		if (Left(SettingsList[i],6) == "Mobile")
			continue;
		else
			ParseSetting(SettingsList[i]);
	}

	DumpString = PC.ConsoleCommand("SCALE DUMPUNKNOWN", false);
	SettingsList = SplitString(DumpString, "\n", true);
	for (i=1; i<SettingsList.Length; i++)
	{
		SettingsList[i] = Right(SettingsList[i], len(SettingsList[i])-4);
		if (Left(SettingsList[i],6) == "Mobile")
			continue;
		else
			ParseSetting(SettingsList[i]);
	}

	DumpString = PC.ConsoleCommand("LISTSOUNDCLASSES", false);
	//DumpString = PC.ConsoleCommand("LISTSOUNDCLASSVOLUMES", false);
	SettingsList = SplitString(DumpString, "\n", true);
	for(i=1;i<SettingsList.Length; i++)
	{
		ParseAudioSetting(SettingsList[i]);
	}

	PC.ConsoleCommand("GAMMA " $GetGammaSettings());
}

final function ParseSetting(string Setting)
{
	local int Pos;
	local string Cleaned;

	Pos = InStr(Setting, "(");
	Cleaned = Left(Setting, Pos);


	if(InStr(Cleaned, "TRUE", true, true) != -1)
	{
		Pos = InStr(Cleaned, "=");
		ParseBoolSetting(Left(Cleaned, Pos - 1), true);
	}
	else if(InStr(Cleaned, "FALSE", true, true) != -1)
	{
		Pos = InStr(Cleaned, "=");
		ParseBoolSetting(Left(Cleaned, Pos - 1), false);
	}
	else
	{
		Pos = InStr(Cleaned, "=");
		ParseNumericalSetting(Left(Cleaned, Pos - 1), Right(Cleaned, Len(Cleaned) - (Pos + 2)));
	}
	

}

final function ParseAudioSetting(string Setting)
{
	local int Pos;
	local string Cleaned;
	local AudioDevice AD;

	Pos = InStr(Setting, "' has");
	Cleaned = Left(Setting, Pos);
	Cleaned = Right(Cleaned, Len(Cleaned) - Len("Class '"));
	AD = class'Engine'.static.GetAudioDevice();

	switch (Cleaned)
	{
		case "None": break;
		case "UI": UISoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Item": ItemSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Vehicle": VehicleSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Weapon": WeaponSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "SFX": SFXSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Character": CharacterSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Music": MusicSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Master": MasterSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "MovieVoice": MovieVoiceSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "WeaponBulletEffects": WeaponBulletEffectsSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Announcer": AnnouncerSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Cinematic": CinematicSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "MovieEffects": MovieEffectsSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "Ambient": AmbientSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		case "UnGrouped": UnGroupedSoundClass = AD.FindSoundClass(Name(Cleaned)); break;
		default: break;
	}
}

final function ParseBoolSetting(string key, bool Value)
{

	//`log("key: " $key $" | value: " $Value);

	switch(key)
	{
		case "AllowD3D10": if(AllowD3D10 != Value) AllowD3D10 = engine.GetSystemSettingBool(key); /*`log("AllowD3D10" $AllowD3D10);*/ break;
		case "SpeedTreeLeaves": if(SpeedTreeLeaves != Value) SpeedTreeLeaves = engine.GetSystemSettingBool(key); /*`log("SpeedTreeLeaves"$SpeedTreeLeaves);*/ break;
		case "SpeedTreeFronds": if(SpeedTreeFronds != Value) SpeedTreeFronds = engine.GetSystemSettingBool(key); /*`log("SpeedTreeFronds"$SpeedTreeFronds);*/ break;
		case "StaticDecals": if(StaticDecals != Value) StaticDecals = engine.GetSystemSettingBool(key); /*`log("StaticDecals"$StaticDecals);*/ break;
		case "DynamicDecals": if(DynamicDecals != Value) DynamicDecals = engine.GetSystemSettingBool(key); /*`log("DynamicDecals"$DynamicDecals);*/ break;
		case "UnbatchedDecals": if(UnbatchedDecals != Value) UnbatchedDecals = engine.GetSystemSettingBool(key); /*`log("UnbatchedDecals"$UnbatchedDecals);*/ break;
		case "DynamicLights": if(DynamicLights != Value) DynamicLights = engine.GetSystemSettingBool(key); /*`log("DynamicLights"$DynamicLights);*/ break;
		case "CompositeDynamicLights": if(CompositeDynamicLights != Value) CompositeDynamicLights = engine.GetSystemSettingBool(key); /*`log("CompositeDynamicLights"$CompositeDynamicLights);*/ break;
		case "DirectionalLightmaps": if(DirectionalLightmaps != Value) DirectionalLightmaps = engine.GetSystemSettingBool(key); /*`log("DirectionalLightmaps"$DirectionalLightmaps);*/ break;
		case "MotionBlur": if(MotionBlur != Value) MotionBlur = engine.GetSystemSettingBool(key); /*`log("MotionBlur"$MotionBlur);*/ break;
		case "MotionBlurPause": if(MotionBlurPause != Value) MotionBlurPause = engine.GetSystemSettingBool(key); /*`log("MotionBlurPause"$MotionBlurPause);*/ break;
		case "DepthOfField": if(DepthOfField != Value) DepthOfField = engine.GetSystemSettingBool(key); /*`log("DepthOfField"$DepthOfField);*/ break;
		case "AmbientOcclusion": if(AmbientOcclusion != Value) AmbientOcclusion = engine.GetSystemSettingBool(key); /*`log("AmbientOcclusion"$AmbientOcclusion);*/ break;
		case "Bloom": if(Bloom != Value) Bloom = engine.GetSystemSettingBool(key); /*`log("Bloom"$Bloom);*/ break;
		case "UseHighQualityBloom": if(UseHighQualityBloom != Value) UseHighQualityBloom = engine.GetSystemSettingBool(key); /*`log("UseHighQualityBloom"$UseHighQualityBloom);*/ break;
		case "Distortion": if(Distortion != Value) Distortion = engine.GetSystemSettingBool(key); /*`log("Distortion"$Distortion);*/ break;
		case "FilteredDistortion": if(FilteredDistortion != Value) FilteredDistortion = engine.GetSystemSettingBool(key); /*`log("FilteredDistortion"$FilteredDistortion);*/ break;
		case "DropParticleDistortion": if(DropParticleDistortion != Value) DropParticleDistortion = engine.GetSystemSettingBool(key); /*`log("DropParticleDistortion"$DropParticleDistortion);*/ break;
		case "LensFlares": if(LensFlares != Value) LensFlares = engine.GetSystemSettingBool(key); /*`log("LensFlares"$LensFlares);*/ break;
		case "FogVolumes": if(FogVolumes != Value) FogVolumes = engine.GetSystemSettingBool(key); /*`log("FogVolumes"$FogVolumes);*/ break;
		case "FloatingPointRenderTargets": if(FloatingPointRenderTargets != Value) FloatingPointRenderTargets = engine.GetSystemSettingBool(key); /*`log("FloatingPointRenderTargets"$FloatingPointRenderTargets);*/ break;
		case "OneFrameThreadLag": if(OneFrameThreadLag != Value) OneFrameThreadLag = engine.GetSystemSettingBool(key); /*`log("OneFrameThreadLag"$OneFrameThreadLag);*/ break;
		case "AllowRadialBlur": if(AllowRadialBlur != Value) AllowRadialBlur = engine.GetSystemSettingBool(key); /*`log("AllowRadialBlur"$AllowRadialBlur);*/ break;
		case "bAllowFracturedDamage": if(bAllowFracturedDamage != Value) bAllowFracturedDamage = engine.GetSystemSettingBool(key); /*`log("bAllowFracturedDamage"$bAllowFracturedDamage);*/ break;
		case "DynamicShadows": if(DynamicShadows != Value) DynamicShadows = engine.GetSystemSettingBool(key); /*`log("DynamicShadows"$DynamicShadows);*/ break;
		case "LightEnvironmentShadows": if(LightEnvironmentShadows != Value) LightEnvironmentShadows = engine.GetSystemSettingBool(key); /*`log("LightEnvironmentShadows"$LightEnvironmentShadows);*/ break;
		case "bEnableBranchingPCFShadows": if(bEnableBranchingPCFShadows != Value) bEnableBranchingPCFShadows = engine.GetSystemSettingBool(key); /*`log("bEnableBranchingPCFShadows"$bEnableBranchingPCFShadows);*/ break;
		case "bAllowBetterModulatedShadows": if(bAllowBetterModulatedShadows != Value) bAllowBetterModulatedShadows = engine.GetSystemSettingBool(key); /*`log("bAllowBetterModulatedShadows"$bAllowBetterModulatedShadows);*/ break;
		case "bEnableForegroundShadowsOnWorld": if(bEnableForegroundShadowsOnWorld != Value) bEnableForegroundShadowsOnWorld = engine.GetSystemSettingBool(key); /*`log("bEnableForegroundShadowsOnWorld"$bEnableForegroundShadowsOnWorld);*/ break;
		case "bEnableForegroundSelfShadowing": if(bEnableForegroundSelfShadowing != Value) bEnableForegroundSelfShadowing = engine.GetSystemSettingBool(key); /*`log("bEnableForegroundSelfShadowing"$bEnableForegroundSelfShadowing);*/ break;
		case "OnlyStreamInTextures": if(OnlyStreamInTextures != Value) OnlyStreamInTextures = engine.GetSystemSettingBool(key); /*`log("OnlyStreamInTextures"$OnlyStreamInTextures);*/ break;
		case "UseVsync": if(UseVsync != Value) UseVsync = engine.GetSystemSettingBool(key); /*`log("UseVsync"$UseVsync);*/ break;
		case "UpscaleScreenPercentage": if(UpscaleScreenPercentage != Value) UpscaleScreenPercentage = engine.GetSystemSettingBool(key); /*`log("UpscaleScreenPercentage"$UpscaleScreenPercentage);*/ break;
		case "Fullscreen": if(Fullscreen != Value) Fullscreen = engine.GetSystemSettingBool(key); /*`log("Fullscreen"$Fullscreen);*/ break;
		case "bForceCPUAccessToGPUSkinVerts": if(bForceCPUAccessToGPUSkinVerts != Value) bForceCPUAccessToGPUSkinVerts = engine.GetSystemSettingBool(key); /*`log("bForceCPUAccessToGPUSkinVerts"$bForceCPUAccessToGPUSkinVerts);*/ break;
		case "bDisableSkeletalInstanceWeights": if(bDisableSkeletalInstanceWeights != Value) bDisableSkeletalInstanceWeights = engine.GetSystemSettingBool(key); /*`log("bDisableSkeletalInstanceWeights"$bDisableSkeletalInstanceWeights);*/ break;
		case "bAllowLightShafts": if(bAllowLightShafts != Value) bAllowLightShafts = engine.GetSystemSettingBool(key); /*`log("bAllowLightShafts"$bAllowLightShafts);*/ break;
		case "bAllowSeparateTranslucency": if(bAllowSeparateTranslucency != Value) bAllowSeparateTranslucency = engine.GetSystemSettingBool(key); /*`log("bAllowSeparateTranslucency"$bAllowSeparateTranslucency);*/ break;
		case "bAllowPostprocessMLAA": if(bAllowPostprocessMLAA != Value) bAllowPostprocessMLAA = engine.GetSystemSettingBool(key); /*`log("bAllowPostprocessMLAA"$bAllowPostprocessMLAA);*/ break;
		case "bAllowHighQualityMaterials": if(bAllowHighQualityMaterials != Value) bAllowHighQualityMaterials = engine.GetSystemSettingBool(key); /*`log("bAllowHighQualityMaterials"$bAllowHighQualityMaterials);*/ break;
		case "bAllowD3D9MSAA": if(bAllowD3D9MSAA != Value) bAllowD3D9MSAA = engine.GetSystemSettingBool(key); /*`log("bAllowD3D9MSAA"$bAllowD3D9MSAA);*/ break;
		case "bAllowWholeSceneDominantShadows": if(bAllowWholeSceneDominantShadows != Value) bAllowWholeSceneDominantShadows = engine.GetSystemSettingBool(key); /*`log("bAllowWholeSceneDominantShadows"$bAllowWholeSceneDominantShadows);*/ break;
		case "bUseConservativeShadowBounds": if(bUseConservativeShadowBounds != Value) bUseConservativeShadowBounds = engine.GetSystemSettingBool(key); /*`log("bUseConservativeShadowBounds"$bUseConservativeShadowBounds);*/ break;
		case "bApexClothingAsyncFetchResults": if(bApexClothingAsyncFetchResults != Value) bApexClothingAsyncFetchResults = engine.GetSystemSettingBool(key); /*`log("bApexClothingAsyncFetchResults"$bApexClothingAsyncFetchResults);*/ break;
		case "AllowOpenGL": if(AllowOpenGL != Value) AllowOpenGL = engine.GetSystemSettingBool(key); /*`log("AllowOpenGL"$AllowOpenGL);*/ break;
		case "AllowSubsurfaceScattering": if(AllowSubsurfaceScattering != Value) AllowSubsurfaceScattering = engine.GetSystemSettingBool(key); /*`log("AllowSubsurfaceScattering"$AllowSubsurfaceScattering);*/ break;
		case "AllowImageReflections": if(AllowImageReflections != Value) AllowImageReflections = engine.GetSystemSettingBool(key); /*`log("AllowImageReflections"$AllowImageReflections);*/ break;
		case "AllowImageReflectionShadowing": if(AllowImageReflectionShadowing != Value) AllowImageReflectionShadowing = engine.GetSystemSettingBool(key); /*`log("AllowImageReflectionShadowing"$AllowImageReflectionShadowing);*/ break;
		case "bAllowTemporalAA": if(bAllowTemporalAA != Value) bAllowTemporalAA = engine.GetSystemSettingBool(key); /*`log("bAllowTemporalAA"$bAllowTemporalAA);*/ break;
		case "SHSecondaryLighting": if(SHSecondaryLighting != Value) SHSecondaryLighting = engine.GetSystemSettingBool(key); /*`log("SHSecondaryLighting"$SHSecondaryLighting);*/ break;
		case "bAllowDownsampledTranslucency": if(bAllowDownsampledTranslucency != Value) bAllowDownsampledTranslucency = engine.GetSystemSettingBool(key); /*`log("bAllowDownsampledTranslucency"$bAllowDownsampledTranslucency);*/ break;
		case "bAllowHardwareShadowFiltering": if(bAllowHardwareShadowFiltering != Value) bAllowHardwareShadowFiltering = engine.GetSystemSettingBool(key); /*`log("bAllowHardwareShadowFiltering"$bAllowHardwareShadowFiltering);*/ break;
		case "HighPrecisionGBuffers": if(HighPrecisionGBuffers != Value) HighPrecisionGBuffers = engine.GetSystemSettingBool(key); /*`log("HighPrecisionGBuffers"$HighPrecisionGBuffers);*/ break;
		case "AllowSecondaryDisplays": if(AllowSecondaryDisplays != Value) AllowSecondaryDisplays = engine.GetSystemSettingBool(key); /*`log("AllowSecondaryDisplays"$AllowSecondaryDisplays);*/ break;
		case "ApexDestructionSortByBenefit": if(ApexDestructionSortByBenefit != Value) ApexDestructionSortByBenefit = engine.GetSystemSettingBool(key); /*`log("ApexDestructionSortByBenefit"$ApexDestructionSortByBenefit);*/ break;
		case "ApexGRBEnable": if(ApexGRBEnable != Value) ApexGRBEnable = engine.GetSystemSettingBool(key); /*`log("ApexGRBEnable"$ApexGRBEnable);*/ break;
		case "bEnableParallelApexClothingFetch": if(bEnableParallelApexClothingFetch != Value) bEnableParallelApexClothingFetch = engine.GetSystemSettingBool(key); /*`log("bEnableParallelApexClothingFetch"$bEnableParallelApexClothingFetch);*/ break;
		case "ApexClothingAllowAsyncCooking": if(ApexClothingAllowAsyncCooking != Value) ApexClothingAllowAsyncCooking = engine.GetSystemSettingBool(key); /*`log("ApexClothingAllowAsyncCooking"$ApexClothingAllowAsyncCooking);*/ break;
		case "ApexClothingAllowApexWorkBetweenSubsteps": if(ApexClothingAllowApexWorkBetweenSubsteps != Value) ApexClothingAllowApexWorkBetweenSubsteps = engine.GetSystemSettingBool(key); /*`log("ApexClothingAllowApexWorkBetweenSubsteps"$ApexClothingAllowApexWorkBetweenSubsteps);*/ break;
		default: break;
	}
}

final function ParseNumericalSetting(string key, string Value)
{
	//`log("key: " $key $" | value: " $Value);
	switch(key)
	{
		case "DetailMode": if(DetailMode != int(Value)) DetailMode =  engine.GetSystemSettingInt(key); /*`log("DetailMode? "$DetailMode);*/ break;
		case "SkeletalMeshLODBias": if(SkeletalMeshLODBias != int(Value)) SkeletalMeshLODBias = engine.GetSystemSettingInt(key); /*`log("SkeletalMeshLODBias? "$SkeletalMeshLODBias);*/ break;
		case "ParticleLODBias": if(ParticleLODBias != int(Value)) ParticleLODBias = engine.GetSystemSettingInt(key); /*`log("ParticleLODBias? "$ParticleLODBias);*/ break;
		case "MinShadowResolution": if(MinShadowResolution != int(Value)) MinShadowResolution = engine.GetSystemSettingInt(key); /*`log("MinShadowResolution? "$MinShadowResolution);*/ break;
		case "MaxShadowResolution": if(MaxShadowResolution != int(Value)) MaxShadowResolution = engine.GetSystemSettingInt(key); /*`log("MaxShadowResolution? "$MaxShadowResolution);*/ break;
		case "ShadowFadeResolution": if(ShadowFadeResolution != int(Value)) ShadowFadeResolution = engine.GetSystemSettingInt(key); /*`log("ShadowFadeResolution? "$ShadowFadeResolution);*/ break;
		case "MaxAnisotropy": if(MaxAnisotropy != int(Value)) MaxAnisotropy = engine.GetSystemSettingInt(key); /*`log("MaxAnisotropy? "$MaxAnisotropy);*/ break;
		case "ResX": if(ResX != int(Value)) ResX = engine.GetSystemSettingInt(key); /*`log("ResX? "$ResX);*/ break;
		case "ResY": if(ResY != int(Value)) ResY = engine.GetSystemSettingInt(key); /*`log("ResY? "$ResY);*/ break;
		case "MaxMultiSamples": if(MaxMultiSamples != int(Value)) MaxMultiSamples = engine.GetSystemSettingInt(key); /*`log("MaxMultiSamples? "$MaxMultiSamples);*/ break;
		case "MaxFilterBlurSampleCount": if(MaxFilterBlurSampleCount != int(Value)) MaxFilterBlurSampleCount = engine.GetSystemSettingInt(key); /*`log("MaxFilterBlurSampleCount? "$MaxFilterBlurSampleCount);*/ break;
		case "MinPreShadowResolution": if(MinPreShadowResolution != int(Value)) MinPreShadowResolution = engine.GetSystemSettingInt(key); /*`log("MinPreShadowResolution? "$MinPreShadowResolution);*/ break;
		case "MaxWholeSceneDominantShadowResolution": if(MaxWholeSceneDominantShadowResolution != int(Value)) MaxWholeSceneDominantShadowResolution = engine.GetSystemSettingInt(key); /*`log("MaxWholeSceneDominantShadowResolution? "$MaxWholeSceneDominantShadowResolution);*/ break;
		case "TemporalAA_MinDepth": if(TemporalAA_MinDepth != float(Value)) TemporalAA_MinDepth = engine.GetSystemSettingFloat(key); /*`log("TemporalAA_MinDepth? "$TemporalAA_MinDepth);*/ break;
		case "MotionBlurSkinning": if(MotionBlurSkinning != int(Value)) MotionBlurSkinning = engine.GetSystemSettingInt(key); /*`log("MotionBlurSkinning? "$MotionBlurSkinning);*/ break;
		case "ShadowFilterQualityBias": if(ShadowFilterQualityBias != int(Value)) ShadowFilterQualityBias = engine.GetSystemSettingInt(key); /*`log("ShadowFilterQualityBias? "$ShadowFilterQualityBias);*/ break;
		case "PreShadowFadeResolution": if(PreShadowFadeResolution != int(Value)) PreShadowFadeResolution = engine.GetSystemSettingInt(key); /*`log("PreShadowFadeResolution? "$PreShadowFadeResolution);*/ break;
		case "TessellationAdaptivePixelsPerTriangle": if(TessellationAdaptivePixelsPerTriangle != float(Value)) TessellationAdaptivePixelsPerTriangle = engine.GetSystemSettingFloat(key); /*`log("TessellationAdaptivePixelsPerTriangle? "$TessellationAdaptivePixelsPerTriangle);*/ break;
		case "PerObjectShadowTransition": if(PerObjectShadowTransition != float(Value)) PerObjectShadowTransition = engine.GetSystemSettingFloat(key); /*`log("PerObjectShadowTransition? "$PerObjectShadowTransition);*/ break;
		case "PerSceneShadowTransition": if(PerSceneShadowTransition != float(Value)) PerSceneShadowTransition = engine.GetSystemSettingFloat(key); /*`log("PerSceneShadowTransition? "$PerSceneShadowTransition);*/ break;
		case "CSMMinimumFOV": if(CSMMinimumFOV != float(Value)) CSMMinimumFOV = engine.GetSystemSettingFloat(key); /*`log("CSMMinimumFOV? "$CSMMinimumFOV);*/ break;
		case "UnbuiltNumWholeSceneDynamicShadowCascades": if(UnbuiltNumWholeSceneDynamicShadowCascades != int(Value)) UnbuiltNumWholeSceneDynamicShadowCascades = engine.GetSystemSettingInt(key); /*`log("UnbuiltNumWholeSceneDynamicShadowCascades? "$UnbuiltNumWholeSceneDynamicShadowCascades);*/ break;
		case "WholeSceneShadowUnbuiltInteractionThreshold": if(WholeSceneShadowUnbuiltInteractionThreshold != int(Value)) WholeSceneShadowUnbuiltInteractionThreshold = engine.GetSystemSettingInt(key); /*`log("WholeSceneShadowUnbuiltInteractionThreshold? "$WholeSceneShadowUnbuiltInteractionThreshold);*/ break;
		case "SecondaryDisplayMaximumWidth": if(SecondaryDisplayMaximumWidth != int(Value)) SecondaryDisplayMaximumWidth = engine.GetSystemSettingInt(key); /*`log("SecondaryDisplayMaximumWidth? "$SecondaryDisplayMaximumWidth);*/ break;
		case "SecondaryDisplayMaximumHeight": if(SecondaryDisplayMaximumHeight != int(Value)) SecondaryDisplayMaximumHeight = engine.GetSystemSettingInt(key); /*`log("SecondaryDisplayMaximumHeight? "$SecondaryDisplayMaximumHeight);*/ break;
		case "ApexDestructionMaxChunkIslandCount": if(ApexDestructionMaxChunkIslandCount != int(Value)) ApexDestructionMaxChunkIslandCount = engine.GetSystemSettingInt(key); /*`log("ApexDestructionMaxChunkIslandCount? "$ApexDestructionMaxChunkIslandCount);*/ break;
		case "ApexDestructionMaxShapeCount": if(ApexDestructionMaxShapeCount != int(Value)) ApexDestructionMaxShapeCount = engine.GetSystemSettingInt(key); /*`log("ApexDestructionMaxShapeCount? "$ApexDestructionMaxShapeCount);*/ break;
		case "ApexDestructionMaxChunkSeparationLOD": if(ApexDestructionMaxChunkSeparationLOD != float(Value)) ApexDestructionMaxChunkSeparationLOD = engine.GetSystemSettingFloat(key); /*`log("ApexDestructionMaxChunkSeparationLOD? "$ApexDestructionMaxChunkSeparationLOD);*/ break;
		case "ApexDestructionMaxFracturesProcessedPerFrame": if(ApexDestructionMaxFracturesProcessedPerFrame != int(Value)) ApexDestructionMaxFracturesProcessedPerFrame = engine.GetSystemSettingInt(key); /*`log("ApexDestructionMaxFracturesProcessedPerFrame? "$ApexDestructionMaxFracturesProcessedPerFrame);*/ break;
		case "ApexGRBGPUMemSceneSize": if(ApexGRBGPUMemSceneSize != int(Value)) ApexGRBGPUMemSceneSize = engine.GetSystemSettingInt(key); /*`log("ApexGRBGPUMemSceneSize? "$ApexGRBGPUMemSceneSize);*/ break;
		case "ApexGRBGPUMemTempDataSize": if(ApexGRBGPUMemTempDataSize != int(Value)) ApexGRBGPUMemTempDataSize = engine.GetSystemSettingInt(key); /*`log("ApexGRBGPUMemTempDataSize? "$ApexGRBGPUMemTempDataSize);*/ break;
		case "ApexGRBNonPenSolverPosIterCount": if(ApexGRBNonPenSolverPosIterCount != int(Value)) ApexGRBNonPenSolverPosIterCount = engine.GetSystemSettingInt(key); /*`log("ApexGRBNonPenSolverPosIterCount? "$ApexGRBNonPenSolverPosIterCount);*/ break;
		case "ApexGRBFrictionSolverPosIterCount": if(ApexGRBFrictionSolverPosIterCount != int(Value)) ApexGRBFrictionSolverPosIterCount = engine.GetSystemSettingInt(key); /*`log("ApexGRBFrictionSolverPosIterCount? "$ApexGRBFrictionSolverPosIterCount);*/ break;
		case "ApexGRBFrictionSolverVelIterCount": if(ApexGRBFrictionSolverVelIterCount != int(Value)) ApexGRBFrictionSolverVelIterCount = engine.GetSystemSettingInt(key); /*`log("ApexGRBFrictionSolverVelIterCount? "$ApexGRBFrictionSolverVelIterCount);*/ break;
		case "ApexDestructionMaxActorCreatesPerFrame": if(ApexDestructionMaxActorCreatesPerFrame != int(Value)) ApexDestructionMaxActorCreatesPerFrame = engine.GetSystemSettingInt(key); /*`log("ApexDestructionMaxActorCreatesPerFrame? "$ApexDestructionMaxActorCreatesPerFrame);*/ break;
		case "DecalCullDistanceScale": if(DecalCullDistanceScale != float(Value)) DecalCullDistanceScale = engine.GetSystemSettingFloat(key); /*`log("DecalCullDistanceScale? "$DecalCullDistanceScale);*/ break;
		case "NumFracturedPartsScale": if(NumFracturedPartsScale != float(Value)) NumFracturedPartsScale = engine.GetSystemSettingFloat(key); /*`log("NumFracturedPartsScale? "$NumFracturedPartsScale);*/ break;
		case "FractureDirectSpawnChanceScale": if(FractureDirectSpawnChanceScale != float(Value)) FractureDirectSpawnChanceScale = engine.GetSystemSettingFloat(key); /*`log("FractureDirectSpawnChanceScale? "$FractureDirectSpawnChanceScale);*/ break;
		case "FractureRadialSpawnChanceScale": if(FractureRadialSpawnChanceScale != float(Value)) FractureRadialSpawnChanceScale = engine.GetSystemSettingFloat(key); /*`log("FractureRadialSpawnChanceScale? "$FractureRadialSpawnChanceScale);*/ break;
		case "FractureCullDistanceScale": if(FractureCullDistanceScale != float(Value)) FractureCullDistanceScale = engine.GetSystemSettingFloat(key); /*`log("FractureCullDistanceScale? "$FractureCullDistanceScale);*/ break;
		case "ShadowTexelsPerPixel": if(ShadowTexelsPerPixel != float(Value)) ShadowTexelsPerPixel = engine.GetSystemSettingFloat(key); /*`log("ShadowTexelsPerPixel? "$ShadowTexelsPerPixel);*/ break;
		case "ShadowFilterRadius": if(ShadowFilterRadius != float(Value)) ShadowFilterRadius = engine.GetSystemSettingFloat(key); /*`log("ShadowFilterRadius? "$ShadowFilterRadius);*/ break;
		case "ShadowDepthBias": if(ShadowDepthBias != float(Value)) ShadowDepthBias = engine.GetSystemSettingFloat(key); /*`log("ShadowDepthBias? "$ShadowDepthBias);*/ break;
		case "ShadowFadeExponent": if(ShadowFadeExponent != float(Value)) ShadowFadeExponent = engine.GetSystemSettingFloat(key); /*`log("ShadowFadeExponent? "$ShadowFadeExponent);*/ break;
		case "ShadowVolumeLightRadiusThreshold": if(ShadowVolumeLightRadiusThreshold != float(Value)) ShadowVolumeLightRadiusThreshold = engine.GetSystemSettingFloat(key); /*`log("ShadowVolumeLightRadiusThreshold? "$ShadowVolumeLightRadiusThreshold);*/ break;
		case "ShadowVolumePrimitiveScreenSpacePercentageThreshold": if(ShadowVolumePrimitiveScreenSpacePercentageThreshold != float(Value)) ShadowVolumePrimitiveScreenSpacePercentageThreshold = engine.GetSystemSettingFloat(key); /*`log("ShadowVolumePrimitiveScreenSpacePercentageThreshold? "$ShadowVolumePrimitiveScreenSpacePercentageThreshold);*/ break;
		case "SceneCaptureStreamingMultiplier": if(SceneCaptureStreamingMultiplier != float(Value)) SceneCaptureStreamingMultiplier = engine.GetSystemSettingFloat(key); /*`log("SceneCaptureStreamingMultiplier? "$SceneCaptureStreamingMultiplier);*/ break;
		case "FoliageDrawRadiusMultiplier": if(FoliageDrawRadiusMultiplier != float(Value)) FoliageDrawRadiusMultiplier = engine.GetSystemSettingFloat(key); /*`log("FoliageDrawRadiusMultiplier? "$FoliageDrawRadiusMultiplier);*/ break;
		case "ScreenPercentage": if(ScreenPercentage != float(Value)) ScreenPercentage = engine.GetSystemSettingFloat(key); /*`log("ScreenPercentage? "$ScreenPercentage);*/ break;
		case "MaxDrawDistanceScale": if(MaxDrawDistanceScale != float(Value)) MaxDrawDistanceScale = engine.GetSystemSettingFloat(key); /*`log("MaxDrawDistanceScale? "$MaxDrawDistanceScale);*/ break;
		case "TemporalAA_StartDepthVelocityScale": if(TemporalAA_StartDepthVelocityScale != float(Value)) TemporalAA_StartDepthVelocityScale = engine.GetSystemSettingFloat(key); /*`log("TemporalAA_StartDepthVelocityScale? "$TemporalAA_StartDepthVelocityScale);*/ break;
		case "PreShadowResolutionFactor": if(PreShadowResolutionFactor != float(Value)) PreShadowResolutionFactor = engine.GetSystemSettingFloat(key); /*`log("PreShadowResolutionFactor? "$PreShadowResolutionFactor);*/ break;
		case "CSMSplitPenumbraScale": if(CSMSplitPenumbraScale != float(Value)) CSMSplitPenumbraScale = engine.GetSystemSettingFloat(key); /*`log("CSMSplitPenumbraScale? "$CSMSplitPenumbraScale);*/ break;
		case "CSMSplitSoftTransitionDistanceScale": if(CSMSplitSoftTransitionDistanceScale != float(Value)) CSMSplitSoftTransitionDistanceScale = engine.GetSystemSettingFloat(key); /*`log("CSMSplitSoftTransitionDistanceScale? "$CSMSplitSoftTransitionDistanceScale);*/ break;
		case "CSMSplitDepthBiasScale": if(CSMSplitDepthBiasScale != float(Value)) CSMSplitDepthBiasScale = engine.GetSystemSettingFloat(key); /*`log("CSMSplitDepthBiasScale? "$CSMSplitDepthBiasScale);*/ break;
		case "CSMFOVRoundFactor": if(CSMFOVRoundFactor != float(Value)) CSMFOVRoundFactor = engine.GetSystemSettingFloat(key); /*`log("CSMFOVRoundFactor? "$CSMFOVRoundFactor);*/ break;
		case "UnbuiltWholeSceneDynamicShadowRadius": if(UnbuiltWholeSceneDynamicShadowRadius != float(Value)) UnbuiltWholeSceneDynamicShadowRadius = engine.GetSystemSettingFloat(key); /*`log("UnbuiltWholeSceneDynamicShadowRadius? "$UnbuiltWholeSceneDynamicShadowRadius);*/ break;
		case "ApexLODResourceBudget": if(ApexLODResourceBudget != float(Value)) ApexLODResourceBudget = engine.GetSystemSettingFloat(key); /*`log("ApexLODResourceBudget? "$ApexLODResourceBudget);*/ break;
		case "ApexClothingAvgSimFrequencyWindow": if(ApexClothingAvgSimFrequencyWindow != float(Value)) ApexClothingAvgSimFrequencyWindow = engine.GetSystemSettingFloat(key); /*`log("ApexClothingAvgSimFrequencyWindow? "$ApexClothingAvgSimFrequencyWindow);*/ break;
		case "ApexGRBMeshCellSize": if(ApexGRBMeshCellSize != float(Value)) ApexGRBMeshCellSize = engine.GetSystemSettingFloat(key); /*`log("ApexGRBMeshCellSize? "$ApexGRBMeshCellSize);*/ break;
		case "ApexGRBSkinWidth": if(ApexGRBSkinWidth != float(Value)) ApexGRBSkinWidth = engine.GetSystemSettingFloat(key); /*`log("ApexGRBSkinWidth? "$ApexGRBSkinWidth);*/ break;
		case "ApexGRBMaxLinearAcceleration": if(ApexGRBMaxLinearAcceleration != float(Value)) ApexGRBMaxLinearAcceleration = engine.GetSystemSettingFloat(key); /*`log("ApexGRBMaxLinearAcceleration? "$ApexGRBMaxLinearAcceleration);*/ break;
		default: break;
	}
}

/**
 * Returns a string array with each index representing a resolution available on this system.
*/
final function array<string> GetAvailableResolutions()
{
	local string tempResolutionList;
	local array<string> ResolutionList;
	local byte i,j;

	tempResolutionList = PC.ConsoleCommand("DUMPAVAILABLERESOLUTIONS",false);
	ParseStringIntoArray(tempResolutionList, ResolutionList,"\n",true);

	//now to remove the duplicates

	for (i=0; i < ResolutionList.Length; i++) {
		for (j=ResolutionList.Length - 1; j > i; j--) {
			if (ResolutionList[j] != ResolutionList[i]) {
				continue;
			}
			if (ResolutionList.Find(ResolutionList[j]) == j) {
				continue;
			}
			ResolutionList.Remove(j,1);
		}
	}


	return ResolutionList;
}
final function bool IsFullScreen()
{
	return LocalPlayer(PC.Player).ViewportClient.IsFullScreenViewport();
}

final function string GetCurrentResolution()
{
	// local Vector2D Res;
	// LocalPlayer(PC.Player).ViewportClient.GetViewportSize(Res);
	// return (int(Res.X)) $"x" $(int(Res.Y));
	return (ResX $"x" $ResY);
}

final function bool GetEnableGore()
{
	//WI.NetMode != NM_DedicatedServer
	if (class'WorldInfo'.static.GetWorldInfo().NetMode == NM_Standalone) {
		return (Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game).GoreLevel > 0);
	} 
	return (class'Rx_Game'.default.GoreLevel > 0);
}

final function SetEnableGore(bool data)
{
	//local Rx_Game rxGame;
	if (class'WorldInfo'.static.GetWorldInfo().NetMode == NM_Standalone) {
		Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game).GoreLevel = data ? 6 : 0;
		Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game).SaveConfig();
		return;
	}

	class'Rx_Game'.default.GoreLevel = data ? 6 : 0;
	class'Rx_Game'.static.StaticSaveConfig();
}

final function float GetFOV()
{
	return DefaultFOV;
}
final function SetFOV(float data)
{
	DefaultFOV = data;
	//PC.SetFOV(data);
	
    PC.ConsoleCommand("FOV "$int(data));
	SaveConfig();
}

final function float GetMouseSensitivity()
{
	return PC.PlayerInput.MouseSensitivity;
}
final function SetMouseSensitivity(float newData)
{
	PC.PlayerInput.SetSensitivity(newData);
	PC.PlayerInput.SaveConfig();
}

final function bool GetToggleTankReverse()
{
	return Rx_PlayerInput(PC.PlayerInput).bThreadedVehReverseSteeringInverted;
}
final function SetToggleTankReverse(bool data)
{
	Rx_PlayerInput(PC.PlayerInput).bThreadedVehReverseSteeringInverted = data;
	Rx_PlayerInput(PC.PlayerInput).SaveConfig();
}

final function int GetWeaponHand()
{
	local Rx_Controller rxPC;
	rxPC = Rx_Controller(PC);

	return int(rxPC.WeaponHandPreference);
}
final function SetWeaponHand(int data)
{
	local Rx_Controller rxPC;
	rxPC = Rx_Controller(PC);
	
	rxPC.SetHand(EWeaponHand(data));
}
//nBab
final function int GetTechBuildingIcon()
{
	return TechBuildingIconPreference;
}
final function SetTechBuildingIcon(int data)
{
	TechBuildingIconPreference = data;
	saveConfig();
}
//nBab
final function int GetBeaconIcon()
{
	return BeaconIconPreference;
}
final function SetBeaconIcon(int data)
{
	BeaconIconPreference = data;
	SaveConfig();
}
//nBab
final function int GetCrosshairColor()
{
	return CrosshairColorPreference;
}
final function SetCrosshairColor(int data)
{
	CrosshairColorPreference = data;
	SaveConfig();
}
//nBab
final function int GetKillSound()
{
	return KillSoundPreference;
}
final function SetKillSound(int data)
{
	KillSoundPreference = data;
	SaveConfig();
}

//they have a const on var declaration. 
final function bool GetToggleADS() //need to load seetings onto them.
{
	return Rx_PlayerInput(PC.PlayerInput).bClickToGoOutOfADS;
}

final function SetToggleADS(bool data) 
{
	Rx_PlayerInput(PC.PlayerInput).bClickToGoOutOfADS = data;
	Rx_PlayerInput(PC.PlayerInput).SaveConfig();
}

//they have a const on var declaration. 
final function bool GetToggleCrouch() //need to load seetings onto them.
{
	return Rx_PlayerInput(PC.PlayerInput).bToggleCrouch;
}

final function SetToggleCrouch(bool data) 
{
	Rx_PlayerInput(PC.PlayerInput).bToggleCrouch = data;
	Rx_PlayerInput(PC.PlayerInput).SaveConfig();
}

//they have a const on var declaration. 
final function bool GetToggleSprint() //need to load seetings onto them.
{
	return Rx_PlayerInput(PC.PlayerInput).bToggleSprint;
}

final function SetToggleSprint(bool data) 
{
	Rx_PlayerInput(PC.PlayerInput).bToggleSprint = data;
	Rx_PlayerInput(PC.PlayerInput).SaveConfig();
}

final function bool GetNicknamesUseTeamColors() //need to load seetings onto them.
{
	//modified/cleaned up code becuase it didn't retain the config betwen frontend and pause menu (nBab)
	return NicknamesUseTeamColors;
}

final function SetNicknamesUseTeamColors(bool data) //need to load seetings onto them.
{
	//modified/cleaned up code becuase it didn't retain the config betwen frontend and pause menu (nBab)
	NicknamesUseTeamColors = data;
	SaveConfig();
}

final function bool GetInvertYAxis()
{
	return PC.PlayerInput.bInvertMouse;
}
final function SetInvertYAxis(bool data)
{
	PC.PlayerInput.bInvertMouse = data;
	PC.PlayerInput.SaveConfig();
}

final function bool GetEnableMouseSmoothing()
{
	return PC.PlayerInput.bEnableMouseSmoothing;
}

final function SetEnableMouseSmoothing(bool data)
{
	PC.PlayerInput.bEnableMouseSmoothing = data;
	PC.PlayerInput.SaveConfig();
}


final function bool GetEnableSmoothFramerate()
{
	return engine.bSmoothFrameRate;
}
final function SetEnableSmoothFramerate(bool data)
{
	engine.bSmoothFrameRate = data;
	engine.SaveConfig();
}

final function bool GetDisablePhysXHardwareSupport()
{
	return engine.bDisablePhysXHardwareSupport;
}
final function SetDisablePhysXHardwareSupport(bool data)
{
	engine.bDisablePhysXHardwareSupport = data;
	engine.SaveConfig();
}

final function float GetGammaSettings()
{
	return engine.Client.DisplayGamma;
}
final function SetGammaSettings(float data)
{
	engine.Client.DisplayGamma = data;
	class'Client'.default.DisplayGamma = data; //Overide the DisplayGamma's Default. This is the only way to save the data in Engine.ini
	class'Client'.static.StaticSaveConfig();
	engine.Client.SaveConfig();
}

final function float GetFPSSetting()
{
	return engine.MaxSmoothedFrameRate;
}
final function SetFPSSetting(float data)
{
	engine.MaxSmoothedFrameRate = data;
	engine.SaveConfig();
}

/** Sets all system settings to one pre-defined settings group.
 *  By default these are:
 *      0 = Custom
 *      1 = Minimum
 *      2 = Low
 *      3 = Medium
 *      4 = high
 *      5 = very high
 *      6 = Ultra
*/
final function SetSettingBucket(byte BucketNum)
{
	if (PC == none)
	   return;
	if (BucketNum != clamp(BucketNum, -1, 6))
	   return;
	GraphicsPresetLevel = BucketNum;
	SaveConfig();
	PC.ConsoleCommand("SCALE Bucket Bucket"$BucketNum);
	PopulateSystemSettings(); //repopulate the system settings to be parsed in.
	//maybe save bucket
}

final function SetAAType(int AAType)
{
	local PostProcessChain PPChain;
	local PostProcessEffect PPEffect;

	CurrentAAType = AAType;
	SaveConfig();

	PPChain = class'Engine'.static.GetWorldPostProcessChain();
	if (PPChain == none) {
		PPChain = class'Engine'.static.GetDefaultPostProcessChain();
	}

	if (PPChain != none && AAType == Clamp(AAType, 0, 7)) 	{
		foreach PPChain.Effects(PPEffect) 		{
			if (UberPostProcessEffect(PPEffect) != none) 			{
				UberPostProcessEffect(PPEffect).PostProcessAAType = EPostProcessAAType(AAType);
			}
		}
	}
	//save AA here...
}

final function SetTextureDetail(int Value)
{
	if (PC == none)
		return;
	PC.ConsoleCommand("SCALE Bucket TextureDetail" $Value);
	 
}
final function SetSpeedTreeLeaves(bool Value)
{
    if (PC == none)
       return;
    SpeedTreeLeaves = Value;
    PC.ConsoleCommand("SCALE SET SpeedTreeLeaves "$Value);
     
}
final function SetSpeedTreeFronds(bool Value)
{
    if (PC == none)
       return;
    SpeedTreeFronds = Value;
    PC.ConsoleCommand("SCALE SET SpeedTreeFronds "$Value);
     
}
final function SetStaticDecals(bool Value)
{
    if (PC == none)
       return;
    StaticDecals = Value;
    PC.ConsoleCommand("SCALE SET StaticDecals "$Value);
     
}
final function SetDynamicDecals(bool Value)
{
    if (PC == none)
       return;
    DynamicDecals = Value;
    PC.ConsoleCommand("SCALE SET DynamicDecals "$Value);
     
}
final function SetUnbatchedDecals(bool Value)
{
    if (PC == none)
       return;
    UnbatchedDecals = Value;
    PC.ConsoleCommand("SCALE SET UnbatchedDecals "$Value);
     
}
final function SetDynamicLights(bool Value)
{
    if (PC == none)
       return;
    DynamicLights = Value;
    PC.ConsoleCommand("SCALE SET DynamicLights "$Value);
     
}
final function SetCompositeDynamicLights(bool Value)
{
    if (PC == none)
       return;
    CompositeDynamicLights = Value;
    PC.ConsoleCommand("SCALE SET CompositeDynamicLights "$Value);
     
}
final function SetDirectionalLightmaps(bool Value)
{
    if (PC == none)
       return;
    DirectionalLightmaps = Value;
    PC.ConsoleCommand("SCALE SET DirectionalLightmaps "$Value);
     
}
final function SetMotionBlur(bool Value)
{
    if (PC == none)
       return;
    MotionBlur = Value;
    PC.ConsoleCommand("SCALE SET MotionBlur "$Value);
     
}
final function SetDepthOfField(bool Value)
{
    if (PC == none)
       return;
    DepthOfField = Value;
    PC.ConsoleCommand("SCALE SET DepthOfField "$Value);
     
}
final function SetMotionBlurPause(bool Value)
{
    if (PC == none)
       return;
    MotionBlurPause = Value;
    PC.ConsoleCommand("SCALE SET MotionBlurPause "$Value);
     
}
final function SetAmbientOcclusion(bool Value)
{
	local PostProcessChain PPChain;
	local PostProcessEffect PPEffect;

    if (PC == none)
       return;
    AmbientOcclusion = Value;
    PC.ConsoleCommand("SCALE SET AmbientOcclusion "$Value);

	//set the PP aswell
	

	PPChain = class'Engine'.static.GetWorldPostProcessChain();
	if (PPChain == none) {
		PPChain = class'Engine'.static.GetDefaultPostProcessChain();
	}

	if (PPChain != none) {
		foreach PPChain.Effects(PPEffect) {
			if (AmbientOcclusionEffect(PPEffect) != none) {
				if (AmbientOcclusion) {
					AmbientOcclusionEffect(PPEffect).bAngleBasedSSAO = true; //give this a test
					AmbientOcclusionEffect(PPEffect).OcclusionQuality = EAmbientOcclusionQuality(0); //give this a test
				} else {
					AmbientOcclusionEffect(PPEffect).bAngleBasedSSAO = false; //give this a test
					AmbientOcclusionEffect(PPEffect).OcclusionQuality = EAmbientOcclusionQuality(2); //give this a test
				}
			}
		}
	}
     
}
final function SetBloom(bool Value)
{
    if (PC == none)
       return;
    Bloom = Value;
    PC.ConsoleCommand("SCALE SET Bloom "$Value);
     
}
final function SetUseHighQualityBloom(bool Value)
{
    if (PC == none)
       return;
    UseHighQualityBloom = Value;
    PC.ConsoleCommand("SCALE SET UseHighQualityBloom "$Value);
     
}

final function SetBloomThreshold(float data)
{
	BloomThresholdLevel = data;
 	SaveConfig();

	PC.ConsoleCommand("bloomthreshold "$1.0f - BloomThresholdLevel);
}

final function SetDistortion(bool Value)
{
    if (PC == none)
       return;
    Distortion = Value;
    PC.ConsoleCommand("SCALE SET Distortion "$Value);
     
}
final function SetFilteredDistortion(bool Value)
{
    if (PC == none)
       return;
    FilteredDistortion = Value;
    PC.ConsoleCommand("SCALE SET FilteredDistortion "$Value);
     
}
final function SetDropParticleDistortion(bool Value)
{
    if (PC == none)
       return;
    DropParticleDistortion = Value;
    PC.ConsoleCommand("SCALE SET DropParticleDistortion "$Value);
     
}
final function SetLensFlares(bool Value)
{
    if (PC == none)
       return;
    LensFlares = Value;
    PC.ConsoleCommand("SCALE SET LensFlares "$Value);
     
}
final function SetFogVolumes(bool Value)
{
    if (PC == none)
       return;
    FogVolumes = Value;
    PC.ConsoleCommand("SCALE SET FogVolumes "$Value);
     
}
final function SetFloatingPointRenderTargets(bool Value)
{
    if (PC == none)
       return;
    FloatingPointRenderTargets = Value;
    PC.ConsoleCommand("SCALE SET FloatingPointRenderTargets "$Value);
     
}
final function SetOneFrameThreadLag(bool Value)
{
	if (PC == none)
	   return;
	OneFrameThreadLag = Value;
	PC.ConsoleCommand("SCALE SET OneFrameThreadLag "$Value);
	 
}
final function SetAllowRadialBlur(bool Value)
{
	if (PC == none)
	   return;
	AllowRadialBlur = Value;
	PC.ConsoleCommand("SCALE SET AllowRadialBlur "$Value);
	 
}
final function SetbAllowFracturedDamage(bool Value)
{
	if (PC == none)
	   return;
	bAllowFracturedDamage = Value;
	PC.ConsoleCommand("SCALE SET bAllowFracturedDamage "$Value);
	 
}
final function SetDynamicShadows(bool Value)
{
	if (PC == none)
	   return;
	DynamicShadows = Value;
	PC.ConsoleCommand("SCALE SET DynamicShadows "$Value);
	 
}
final function SetLightEnvironmentShadows(bool Value)
{	
	if (PC == none)
	   return;
	LightEnvironmentShadows = Value;
	PC.ConsoleCommand("SCALE SET LightEnvironmentShadows "$Value);
	 
}
final function SetbEnableBranchingPCFShadows(bool Value)
{
	if (PC == none)
	   return;
	bEnableBranchingPCFShadows = Value;
	PC.ConsoleCommand("SCALE SET bEnableBranchingPCFShadows "$Value);
	 
}
final function SetbAllowBetterModulatedShadows(bool Value)
{
	if (PC == none)
	   return;
	bAllowBetterModulatedShadows = Value;
	PC.ConsoleCommand("SCALE SET bAllowBetterModulatedShadows "$Value);
	 
}
final function SetbEnableForegroundShadowsOnWorld(bool Value)
{
	if (PC == none)
	   return;
	bEnableForegroundShadowsOnWorld = Value;
	PC.ConsoleCommand("SCALE SET bEnableForegroundShadowsOnWorld "$Value);
	 
}
final function SetbEnableForegroundSelfShadowing(bool Value)
{
	if (PC == none)
	   return;
	bEnableForegroundSelfShadowing = Value;
	PC.ConsoleCommand("SCALE SET bEnableForegroundSelfShadowing "$Value);
	 
}
final function SetOnlyStreamInTextures(bool Value)
{
	if (PC == none)
	   return;
	OnlyStreamInTextures = Value;
	PC.ConsoleCommand("SCALE SET OnlyStreamInTextures "$Value);
	 
}
final function SetUseVsync(bool Value)
{
	if (PC == none)
	   return;
	UseVsync = Value;
	PC.ConsoleCommand("SCALE SET UseVsync "$Value);
	 
}
final function SetAllowD3D10(bool Value)
{
	if (PC == none)
		return;
	AllowD3D10 = Value;
	PC.ConsoleCommand("SCALE SET AllowD3D10 "$Value);
	 
}
final function SetUpscaleScreenPercentage(bool Value)
{
	if (PC == none)
	   return;
	UpscaleScreenPercentage = Value;
	PC.ConsoleCommand("SCALE SET UpscaleScreenPercentage "$Value);
	 
}
final function SetFullscreen(bool Value)
{
	if (PC == none)
	   return;
	Fullscreen = Value;
	PC.ConsoleCommand("SCALE SET Fullscreen "$Value);
	 
}
final function SetbForceCPUAccessToGPUSkinVerts(bool Value)
{
	if (PC == none)
	   return;
	bForceCPUAccessToGPUSkinVerts = Value;
	PC.ConsoleCommand("SCALE SET bForceCPUAccessToGPUSkinVerts "$Value);
	 
}
final function SetbDisableSkeletalInstanceWeights(bool Value)
{
	if (PC == none)
	   return;
	bDisableSkeletalInstanceWeights = Value;
	PC.ConsoleCommand("SCALE SET bDisableSkeletalInstanceWeights "$Value);
	 
}
final function SetbAllowLightShafts(bool Value)
{
	if (PC == none)
	   return;
	bAllowLightShafts = Value;
	PC.ConsoleCommand("SCALE SET bAllowLightShafts "$Value);
	 
}
final function SetbAllowSeparateTranslucency(bool Value)
{
	if (PC == none)
	   return;
	bAllowSeparateTranslucency = Value;
	PC.ConsoleCommand("SCALE SET bAllowSeparateTranslucency "$Value);
	 
}
final function SetbAllowPostprocessMLAA(bool Value)
{
	if (PC == none)
	   return;
	bAllowPostprocessMLAA = Value;
	PC.ConsoleCommand("SCALE SET bAllowPostprocessMLAA "$Value);
	 
}
final function SetbAllowHighQualityMaterials(bool Value)
{
	if (PC == none)
	   return;
	bAllowHighQualityMaterials = Value;
	PC.ConsoleCommand("SCALE SET bAllowHighQualityMaterials "$Value);
	 
}
final function SetbAllowD3D9MSAA(bool Value)
{
	if (PC == none)
	   return;
	bAllowD3D9MSAA = Value;
	PC.ConsoleCommand("SCALE SET bAllowD3D9MSAA "$Value);
	saveconfig();
}
final function SetbAllowWholeSceneDominantShadows(bool Value)
{
	if (PC == none)
	   return;
	bAllowWholeSceneDominantShadows = Value;
	PC.ConsoleCommand("SCALE SET bAllowWholeSceneDominantShadows "$Value);
	 
}
final function SetbUseConservativeShadowBounds(bool Value)
{
	if (PC == none)
	   return;
	bUseConservativeShadowBounds = Value;
	PC.ConsoleCommand("SCALE SET bUseConservativeShadowBounds "$Value);
	 
}
final function SetbApexClothingAsyncFetchResults(bool Value)
{
	if (PC == none)
	   return;
	bApexClothingAsyncFetchResults = Value;
	PC.ConsoleCommand("SCALE SET bApexClothingAsyncFetchResults "$Value);
	 
}
final function SetAllowOpenGL(bool Value)
{
	if (PC == none)
	   return;
	AllowOpenGL = Value;
	PC.ConsoleCommand("SCALE SET AllowOpenGL "$Value);
	 
}
final function SetAllowSubsurfaceScattering(bool Value)
{
	if (PC == none)
	   return;
	AllowSubsurfaceScattering = Value;
	PC.ConsoleCommand("SCALE SET AllowSubsurfaceScattering "$Value);
	 
}
final function SetAllowImageReflections(bool Value)
{
	if (PC == none)
	   return;
	AllowImageReflections = Value;
	PC.ConsoleCommand("SCALE SET AllowImageReflections "$Value);
	 
}
final function SetAllowImageReflectionShadowing(bool Value)
{
	if (PC == none)
	   return;
	AllowImageReflectionShadowing = Value;
	PC.ConsoleCommand("SCALE SET AllowImageReflectionShadowing "$Value);
	 
}
final function SetbAllowTemporalAA(bool Value)
{
	if (PC == none)
	   return;
	bAllowTemporalAA = Value;
	PC.ConsoleCommand("SCALE SET bAllowTemporalAA "$Value);
	 
}
final function SetSHSecondaryLighting(bool Value)
{
	if (PC == none)
	   return;
	SHSecondaryLighting = Value;
	PC.ConsoleCommand("SCALE SET SHSecondaryLighting "$Value);
	 
}
final function SetbAllowDownsampledTranslucency(bool Value)
{
	if (PC == none)
	   return;
	bAllowDownsampledTranslucency = Value;
	PC.ConsoleCommand("SCALE SET bAllowDownsampledTranslucency "$Value);
	 
}
final function SetbAllowHardwareShadowFiltering(bool Value)
{
	if (PC == none)
	   return;
	bAllowHardwareShadowFiltering = Value;
	PC.ConsoleCommand("SCALE SET bAllowHardwareShadowFiltering "$Value);
	 
}
final function SetHighPrecisionGBuffers(bool Value)
{
	if (PC == none)
	   return;
	HighPrecisionGBuffers = Value;
	PC.ConsoleCommand("SCALE SET HighPrecisionGBuffers "$Value);
	 
}
final function SetAllowSecondaryDisplays(bool Value)
{
	if (PC == none)
	   return;
	AllowSecondaryDisplays = Value;
	PC.ConsoleCommand("SCALE SET AllowSecondaryDisplays "$Value);
	 
}
final function SetApexDestructionSortByBenefit(bool Value)
{
	if (PC == none)
	   return;
	ApexDestructionSortByBenefit = Value;
	PC.ConsoleCommand("SCALE SET ApexDestructionSortByBenefit "$Value);
	 
}
final function SetApexGRBEnable(bool Value)
{
	if (PC == none)
	   return;
	ApexGRBEnable = Value;
	PC.ConsoleCommand("SCALE SET ApexGRBEnable "$Value);
	 
}
final function SetbEnableParallelApexClothingFetch(bool Value)
{
	if (PC == none)
	   return;
	bEnableParallelApexClothingFetch = Value;
	PC.ConsoleCommand("SCALE SET bEnableParallelApexClothingFetch "$Value);
	 
}
final function SetApexClothingAllowAsyncCooking(bool Value)
{
	if (PC == none)
	   return;
	ApexClothingAllowAsyncCooking = Value;
	PC.ConsoleCommand("SCALE SET ApexClothingAllowAsyncCooking "$Value);
	 
}
final function SetApexClothingAllowApexWorkBetweenSubsteps(bool Value)
{
	if (PC == none)
	   return;
	ApexClothingAllowApexWorkBetweenSubsteps = Value;
	PC.ConsoleCommand("SCALE SET ApexClothingAllowApexWorkBetweenSubsteps "$Value);
	 
}
final function SetDetailMode(int Value)
{
	if (PC == none)
	   return;
	DetailMode = Value;
	PC.ConsoleCommand("SCALE SET DetailMode "$Value);
	 
}
final function SetSkeletalMeshLODBias(int Value)
{
	if (PC == none)
	   return;
	SkeletalMeshLODBias = Value;
	PC.ConsoleCommand("SCALE SET SkeletalMeshLODBias "$Value);
	 
}
final function SetParticleLODBias(int Value)
{
	if (PC == none)
	   return;
	ParticleLODBias = Value;
	PC.ConsoleCommand("SCALE SET ParticleLODBias "$Value);
	 
}
final function SetMinShadowResolution(int Value)
{
	if (PC == none)
	   return;
	MinShadowResolution = Value;
	PC.ConsoleCommand("SCALE SET MinShadowResolution "$Value);
	 
}
final function SetMaxShadowResolution(int Value)
{
	if (PC == none)
	   return;
	MaxShadowResolution = Value;
	PC.ConsoleCommand("SCALE SET MaxShadowResolution "$Value);
	 
}
final function SetShadowFadeResolution(int Value)
{
	if (PC == none)
	   return;
	ShadowFadeResolution = Value;
	PC.ConsoleCommand("SCALE SET ShadowFadeResolution "$Value);
	 
}
final function SetTextureFiltering(int Value)
{
	if (PC == none)
	   return;
	PC.ConsoleCommand("SCALE Bucket TextureFilteringLevel" $Value);
// 	MaxAnisotropy = Value;
// 	PC.ConsoleCommand("SCALE SET MaxAnisotropy "$Value);
	 
}
final function SetResX(int Value)
{
	if (PC == none)
	   return;
	ResX = Value;
	PC.ConsoleCommand("SCALE SET ResX "$Value);
	 
}
final function SetResY(int Value)
{
	if (PC == none)
	   return;
	ResY = Value;
	PC.ConsoleCommand("SCALE SET ResY "$Value);
	 
}
final function SetAntiAliasing(string AAType)
{
	local int AAValue;
	if (PC == none)
	   return;

	switch(AAType) 
	{
		case "No AA":
			SetbAllowPostprocessMLAA(false);
			AAValue = 0;
			MaxMultiSamples = AAValue;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ AAValue);
			SetAAType(AAValue);
			break;
		case "MSAA 2x":
			SetbAllowPostprocessMLAA(false);
			AAValue = 2;
			MaxMultiSamples = AAValue;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ AAValue);
			SetAAType(0);
			break;
		case "MSAA 4x":
			SetbAllowPostprocessMLAA(false);
			AAValue = 4;
			MaxMultiSamples = AAValue;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ AAValue);
			SetAAType(0);
			break;
		case "MSAA 8x":
			SetbAllowPostprocessMLAA(false);
			AAValue = 8;
			MaxMultiSamples = AAValue;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ AAValue);
			SetAAType(0);
			break;
		case "Nvidia FXAA 1":
			SetbAllowPostprocessMLAA(false);
			AAValue = 2;
			SetAAType(AAValue);
			MaxMultiSamples = 0;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ 0);
			break;
		case "Nvidia FXAA 2":
			SetbAllowPostprocessMLAA(false);
			AAValue = 3;
			SetAAType(AAValue);
			MaxMultiSamples = 0;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ 0);
			break;
		case "Nvidia FXAA 3":
			SetbAllowPostprocessMLAA(false);
			AAValue = 4;
			SetAAType(AAValue);
			MaxMultiSamples = 0;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ 0);
			break;
		case "Nvidia FXAA 4":
			SetbAllowPostprocessMLAA(false);
			AAValue = 5;
			SetAAType(AAValue);
			MaxMultiSamples = 0;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ 0);
			break;
		case "Nvidia FXAA 5":
			SetbAllowPostprocessMLAA(false);
			AAValue = 6;
			SetAAType(AAValue);
			MaxMultiSamples = 0;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ 0);
			break;
		case "AMD MLAA 1":
			SetbAllowPostprocessMLAA(true);
			AAValue = 7;
			SetAAType(AAValue);
			MaxMultiSamples = 0;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ 0);
			break;
		default:
			SetbAllowPostprocessMLAA(false);
			AAValue = 0;
			MaxMultiSamples = AAValue;
			PC.ConsoleCommand("SCALE SET MaxMultiSamples "$ AAValue);
			SetAAType(AAValue);
			break;
	}
}
final function SetMaxFilterBlurSampleCount(int Value)
{
	if (PC == none)
	   return;
	MaxFilterBlurSampleCount = Value;
	PC.ConsoleCommand("SCALE SET MaxFilterBlurSampleCount "$Value);
	 
}
final function SetMinPreShadowResolution(int Value)
{
	if (PC == none)
	   return;
	MinPreShadowResolution = Value;
	PC.ConsoleCommand("SCALE SET MinPreShadowResolution "$Value);
	 
}
final function SetMaxWholeSceneDominantShadowResolution(int Value)
{
    if (PC == none)
           return;
        MaxWholeSceneDominantShadowResolution = Value;
        PC.ConsoleCommand("SCALE SET MaxWholeSceneDominantShadowResolution "$Value);
         
}
final function SetTemporalAA_MinDepth(float Value)
{
    if (PC == none)
           return;
        TemporalAA_MinDepth = Value;
        PC.ConsoleCommand("SCALE SET TemporalAA_MinDepth "$Value);
         
}
final function SetMotionBlurSkinning(int Value)
{
    if (PC == none)
           return;
        MotionBlurSkinning = Value;
        PC.ConsoleCommand("SCALE SET MotionBlurSkinning "$Value);
         
}
final function SetShadowFilterQualityBias(int Value)
{
    if (PC == none)
           return;
        ShadowFilterQualityBias = Value;
        PC.ConsoleCommand("SCALE SET ShadowFilterQualityBias "$Value);
         
}
final function SetPreShadowFadeResolution(int Value)
{
    if (PC == none)
           return;
        PreShadowFadeResolution = Value;
        PC.ConsoleCommand("SCALE SET PreShadowFadeResolution "$Value);
         
}
final function SetTessellationAdaptivePixelsPerTriangle(float Value)
{
    if (PC == none)
           return;
        TessellationAdaptivePixelsPerTriangle = Value;
        PC.ConsoleCommand("SCALE SET TessellationAdaptivePixelsPerTriangle "$Value);
         
}
final function SetPerObjectShadowTransition(float Value)
{
    if (PC == none)
           return;
        PerObjectShadowTransition = Value;
        PC.ConsoleCommand("SCALE SET PerObjectShadowTransition "$Value);
         
}
final function SetPerSceneShadowTransition(float Value)
{
    if (PC == none)
           return;
        PerSceneShadowTransition = Value;
        PC.ConsoleCommand("SCALE SET PerSceneShadowTransition "$Value);
         
}
final function SetCSMMinimumFOV(float Value)
{
    if (PC == none)
           return;
        CSMMinimumFOV = Value;
        PC.ConsoleCommand("SCALE SET CSMMinimumFOV "$Value);
         
}
final function SetUnbuiltNumWholeSceneDynamicShadowCascades(int Value)
{
    if (PC == none)
           return;
        UnbuiltNumWholeSceneDynamicShadowCascades = Value;
        PC.ConsoleCommand("SCALE SET UnbuiltNumWholeSceneDynamicShadowCascades "$Value);
         
}
final function SetWholeSceneShadowUnbuiltInteractionThreshold(int Value)
{
    if (PC == none)
           return;
        WholeSceneShadowUnbuiltInteractionThreshold = Value;
        PC.ConsoleCommand("SCALE SET WholeSceneShadowUnbuiltInteractionThreshold "$Value);
         
}
final function SetSecondaryDisplayMaximumWidth(int Value)
{
    if (PC == none)
           return;
        SecondaryDisplayMaximumWidth = Value;
        PC.ConsoleCommand("SCALE SET SecondaryDisplayMaximumWidth "$Value);
         
}
final function SetSecondaryDisplayMaximumHeight(int Value)
{
    if (PC == none)
           return;
        SecondaryDisplayMaximumHeight = Value;
        PC.ConsoleCommand("SCALE SET SecondaryDisplayMaximumHeight "$Value);
         
}
final function SetApexDestructionMaxChunkIslandCount(int Value)
{
    if (PC == none)
           return;
        ApexDestructionMaxChunkIslandCount = Value;
        PC.ConsoleCommand("SCALE SET ApexDestructionMaxChunkIslandCount "$Value);
         
}
final function SetApexDestructionMaxShapeCount(int Value)
{
    if (PC == none)
           return;
        ApexDestructionMaxShapeCount = Value;
        PC.ConsoleCommand("SCALE SET ApexDestructionMaxShapeCount "$Value);
         
}
final function SetApexDestructionMaxChunkSeparationLOD(float Value)
{
    if (PC == none)
           return;
        ApexDestructionMaxChunkSeparationLOD = Value;
        PC.ConsoleCommand("SCALE SET ApexDestructionMaxChunkSeparationLOD "$Value);
         
}
final function SetApexDestructionMaxFracturesProcessedPerFrame(int Value)
{
    if (PC == none)
           return;
        ApexDestructionMaxFracturesProcessedPerFrame = Value;
        PC.ConsoleCommand("SCALE SET ApexDestructionMaxFracturesProcessedPerFrame "$Value);
         
}
final function SetApexGRBGPUMemSceneSize(int Value)
{
    if (PC == none)
           return;
        ApexGRBGPUMemSceneSize = Value;
        PC.ConsoleCommand("SCALE SET ApexGRBGPUMemSceneSize "$Value);
         
}
final function SetApexGRBGPUMemTempDataSize(int Value)
{
    if (PC == none)
           return;
        ApexGRBGPUMemTempDataSize = Value;
        PC.ConsoleCommand("SCALE SET ApexGRBGPUMemTempDataSize "$Value);
         
}
final function SetApexGRBNonPenSolverPosIterCount(int Value)
{
    if (PC == none)
           return;
        ApexGRBNonPenSolverPosIterCount = Value;
        PC.ConsoleCommand("SCALE SET ApexGRBNonPenSolverPosIterCount "$Value);
         
}
final function SetApexGRBFrictionSolverPosIterCount(int Value)
{
    if (PC == none)
           return;
        ApexGRBFrictionSolverPosIterCount = Value;
        PC.ConsoleCommand("scale SET ApexGRBFrictionSolverPosIterCount "$Value);
         
}
final function SetApexGRBFrictionSolverVelIterCount(int Value)
{
    if (PC == none)
           return;
        ApexGRBFrictionSolverVelIterCount = Value;
        PC.ConsoleCommand("SCALE SET ApexGRBFrictionSolverVelIterCount "$Value);
         
}
final function SetApexDestructionMaxActorCreatesPerFrame(int Value)
{
    if (PC == none)
           return;
        ApexDestructionMaxActorCreatesPerFrame = Value;
        PC.ConsoleCommand("SCALE SET ApexDestructionMaxActorCreatesPerFrame "$Value);
         
}
final function SetDecalCullDistanceScale(float Value)
{
    if (PC == none)
           return;
        DecalCullDistanceScale = Value;
        PC.ConsoleCommand("SCALE SET DecalCullDistanceScale "$Value);
         
}
final function SetNumFracturedPartsScale(float Value)
{
    if (PC == none)
           return;
        NumFracturedPartsScale = Value;
        PC.ConsoleCommand("SCALE SET NumFracturedPartsScale "$Value);
         
}
final function SetFractureDirectSpawnChanceScale(float Value)
{
    if (PC == none)
           return;
        FractureDirectSpawnChanceScale = Value;
        PC.ConsoleCommand("SCALE SET FractureDirectSpawnChanceScale "$Value);
         
}
final function SetFractureRadialSpawnChanceScale(float Value)
{
    if (PC == none)
           return;
        FractureRadialSpawnChanceScale = Value;
        PC.ConsoleCommand("SCALE SET FractureRadialSpawnChanceScale "$Value);
         
}
final function SetFractureCullDistanceScale(float Value)
{
    if (PC == none)
           return;
        FractureCullDistanceScale = Value;
        PC.ConsoleCommand("SCALE SET FractureCullDistanceScale "$Value);
         
}
final function SetShadowTexelsPerPixel(float Value)
{
    if (PC == none)
           return;
        ShadowTexelsPerPixel = Value;
        PC.ConsoleCommand("SCALE SET ShadowTexelsPerPixel "$Value);
         
}
final function SetShadowFilterRadius(float Value)
{
    if (PC == none)
           return;
        ShadowFilterRadius = Value;
        PC.ConsoleCommand("SCALE SET ShadowFilterRadius "$Value);
         
}
final function SetShadowDepthBias(float Value)
{
    if (PC == none)
           return;
        ShadowDepthBias = Value;
        PC.ConsoleCommand("SCALE SET ShadowDepthBias "$Value);
         
}
final function SetShadowFadeExponent(float Value)
{
    if (PC == none)
           return;
        ShadowFadeExponent = Value;
        PC.ConsoleCommand("SCALE SET ShadowFadeExponent "$Value);
         
}
final function SetShadowVolumeLightRadiusThreshold(float Value)
{
    if (PC == none)
           return;
        ShadowVolumeLightRadiusThreshold = Value;
        PC.ConsoleCommand("SCALE SET ShadowVolumeLightRadiusThreshold "$Value);
         
}
final function SetShadowVolumePrimitiveScreenSpacePercentageThreshold(float Value)
{
    if (PC == none)
           return;
        ShadowVolumePrimitiveScreenSpacePercentageThreshold = Value;
        PC.ConsoleCommand("SCALE SET ShadowVolumePrimitiveScreenSpacePercentageThreshold "$Value);
         
}
final function SetSceneCaptureStreamingMultiplier(float Value)
{
    if (PC == none)
           return;
        SceneCaptureStreamingMultiplier = Value;
        PC.ConsoleCommand("SCALE SET SceneCaptureStreamingMultiplier "$Value);
         
}
final function SetFoliageDrawRadiusMultiplier(float Value)
{
    if (PC == none)
           return;
        FoliageDrawRadiusMultiplier = Value;
        PC.ConsoleCommand("SCALE SET FoliageDrawRadiusMultiplier "$Value);
         
}
final function SetScreenPercentage(float Value)
{
    if (PC == none)
           return;
        ScreenPercentage = Value;
        PC.ConsoleCommand("SCALE SET ScreenPercentage "$Value);
         
}
final function SetMaxDrawDistanceScale(float Value)
{
    if (PC == none)
           return;
        MaxDrawDistanceScale = Value;
        PC.ConsoleCommand("SCALE SET MaxDrawDistanceScale "$Value);
         
}
final function SetTemporalAA_StartDepthVelocityScale(float Value)
{
    if (PC == none)
           return;
        TemporalAA_StartDepthVelocityScale = Value;
        PC.ConsoleCommand("SCALE SET TemporalAA_StartDepthVelocityScale "$Value);
         
}
final function SetPreShadowResolutionFactor(float Value)
{
    if (PC == none)
           return;
        PreShadowResolutionFactor = Value;
        PC.ConsoleCommand("SCALE SET PreShadowResolutionFactor "$Value);
         
}
final function SetCSMSplitPenumbraScale(float Value)
{
    if (PC == none)
           return;
        CSMSplitPenumbraScale = Value;
        PC.ConsoleCommand("SCALE SET CSMSplitPenumbraScale "$Value);
         
}
final function SetCSMSplitSoftTransitionDistanceScale(float Value)
{
    if (PC == none)
           return;
        CSMSplitSoftTransitionDistanceScale = Value;
        PC.ConsoleCommand("SCALE SET CSMSplitSoftTransitionDistanceScale "$Value);
         
}
final function SetCSMSplitDepthBiasScale(float Value)
{
    if (PC == none)
           return;
        CSMSplitDepthBiasScale = Value;
        PC.ConsoleCommand("SCALE SET CSMSplitDepthBiasScale "$Value);
         
}
final function SetCSMFOVRoundFactor(float Value)
{
    if (PC == none)
           return;
        CSMFOVRoundFactor = Value;
        PC.ConsoleCommand("SCALE SET CSMFOVRoundFactor "$Value);
         
}
final function SetUnbuiltWholeSceneDynamicShadowRadius(float Value)
{
    if (PC == none)
           return;
        UnbuiltWholeSceneDynamicShadowRadius = Value;
        PC.ConsoleCommand("SCALE SET UnbuiltWholeSceneDynamicShadowRadius "$Value);
         
}
final function SetApexLODResourceBudget(float Value)
{
    if (PC == none)
           return;
        ApexLODResourceBudget = Value;
        PC.ConsoleCommand("SCALE SET ApexLODResourceBudget "$Value);
         
}
final function SetApexClothingAvgSimFrequencyWindow(float Value)
{
    if (PC == none)
           return;
        ApexClothingAvgSimFrequencyWindow = Value;
        PC.ConsoleCommand("SCALE SET ApexClothingAvgSimFrequencyWindow "$Value);
         
}
final function SetApexGRBMeshCellSize(float Value)
{
    if (PC == none)
           return;
        ApexGRBMeshCellSize = Value;
        PC.ConsoleCommand("SCALE SET ApexGRBMeshCellSize "$Value);
         
}
final function SetApexGRBSkinWidth(float Value)
{
    if (PC == none)
           return;
        ApexGRBSkinWidth = Value;
        PC.ConsoleCommand("SCALE SET ApexGRBSkinWidth "$Value);
         
}
final function SetApexGRBMaxLinearAcceleration(float Value)
{
    if (PC == none)
           return;
        ApexGRBMaxLinearAcceleration = Value;
        PC.ConsoleCommand("SCALE SET ApexGRBMaxLinearAcceleration "$Value);
         
}

DefaultProperties
{
}