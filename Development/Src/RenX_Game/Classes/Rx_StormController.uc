class Rx_StormController extends Actor
	placeable;

var private float LastUpdateStormIntensity;
/** Current Storm intensity. Range 0-1 */
var private float CurrentStormIntensity;
/** Reference to the current renx game */
var private Rx_Game RenGame;
/** How Long in seconds to transition from intensity 0 to intensity 1 */
var(Rx_Storm,Timing) const float StormTransitionInTime;
/** How Long in seconds to transition from intensity 1 to intensity 0 */
var(Rx_Storm,Timing) const float StormTransitionOutTime;
/** How Long after the match has started before the storm starts */
var(Rx_Storm,Timing) const float FixedStormStartDelay;
/** How Long does the storm last after reaching full intensity */
var(Rx_Storm,Timing) const float FixedStormLength;
/** For timed matches, percentage of the game completed before the storm starts. Range 0-1 */
var(Rx_Storm,Timing) const float RelativeStormStartDelay;
/** For timed matches, percentage of the game the storm will stay at full intensity. Range 0-1 */
var(Rx_Storm,Timing) const float RelativeStormLength;
/** Use Relative times during timed matches */
var(Rx_Storm,Timing) const bool bUseRelativeTimesWhenPossible;


var (Rx_Storm,Lighting) const DominantDirectionalLight DominantLight;

var private float InitialLightBrightness;
var (Rx_Storm,Lighting) const float StormLightBrightness;

/** Particles to enable during storm */
var(Rx_Storm,Particles) const array<Emitter> StormParticles;
var private bool EmittersEnabled;

/** Material Instances affected by the storm */
var(Rx_Storm,Materials) const array<MaterialInstance> StormMaterialInstances;
var private array<MaterialInstance> DiskMaterialInstances;

var(Rx_Storm,PostProcess) const float SceneDesaturationStorm;
var(Rx_Storm,PostProcess) const Vector SceneHiLightsStorm;
var(Rx_Storm,PostProcess) const Vector SceneMidTonesStorm;
var(Rx_Storm,PostProcess) const Vector SceneShadowsStorm;

var private float SceneDesaturationDefault;
var private Vector SceneHiLightsDefault;
var private Vector SceneMidTonesDefault;
var private Vector SceneShadowsDefault;

replication
{
	if (bNetDirty)
		CurrentStormIntensity;
}

simulated event PostBeginPlay()
{
	RenGame = Rx_Game(WorldInfo.Game);

	EmittersEnabled = false;
	DisableParticles();

	GetMaterials();
	GetDefaults();
	UpdateEffects();
}

simulated event Destroyed()
{
	super.Destroyed();
	RevertMaterials();

	CurrentStormIntensity = 0.0f;
	UpdateEffects();
}

simulated event ShutDown()
{
	super.ShutDown();
	RevertMaterials();

	CurrentStormIntensity = 0.0f;
	UpdateEffects();
}

simulated function GetDefaults()
{
	InitialLightBrightness = DominantLight.LightComponent.Brightness;
	SceneDesaturationDefault = WorldInfo.DefaultPostProcessSettings.Scene_Desaturation;
	SceneHiLightsDefault = WorldInfo.DefaultPostProcessSettings.Scene_HighLights;
	SceneMidTonesDefault = WorldInfo.DefaultPostProcessSettings.Scene_MidTones;
	SceneShadowsDefault = WorldInfo.DefaultPostProcessSettings.Scene_Shadows;	
}

simulated function BeginStorm()
{
	GotoState('StormBeginTransition');
}

simulated function EndStorm()
{
	GotoState('StormEndTransition');
}

simulated function UpdateEffects()
{
	//`log("Effects Updated   " @ CurrentStormIntensity);
	if (Worldinfo.NetMode != NM_DedicatedServer && LastUpdateStormIntensity != CurrentStormIntensity)
	{
		UpdateParticles();
		UpdateMaterials();
		UpdateLight();
		UpdatePost();
		LastUpdateStormIntensity = CurrentStormIntensity;
	}
}

simulated function UpdatePost()
{
	WorldInfo.DefaultPostProcessSettings.Scene_Desaturation = Lerp(SceneDesaturationDefault,SceneDesaturationStorm,CurrentStormIntensity);
	WorldInfo.DefaultPostProcessSettings.Scene_HighLights = VLerp(SceneHiLightsDefault,SceneHiLightsStorm,CurrentStormIntensity);
	WorldInfo.DefaultPostProcessSettings.Scene_MidTones = VLerp(SceneMidTonesDefault,SceneMidTonesStorm,CurrentStormIntensity);
	WorldInfo.DefaultPostProcessSettings.Scene_Shadows = VLerp(SceneShadowsDefault,SceneShadowsStorm,CurrentStormIntensity);
}

simulated function UpdateLight()
{
	DominantLight.LightComponent.SetLightProperties(Lerp(InitialLightBrightness,StormLightBrightness,CurrentStormIntensity));
}

simulated function UpdateParticles()
{
	local int i;
	for ( i = 0; i < StormParticles.Length; i++)
	{
		StormParticles[i].ParticleSystemComponent.SetFloatParameter('Rate Scale',CurrentStormIntensity);
	}

	if (CurrentStormIntensity > 0.0 && !EmittersEnabled)
		EnableParticles();
	else if (CurrentStormIntensity <= 0.0 && EmittersEnabled)
		DisableParticles ();


}

simulated function EnableParticles()
{
	local int i;
	for ( i = 0; i < StormParticles.Length; i++)
	{
		StormParticles[i].ParticleSystemComponent.ActivateSystem();
		StormParticles[i].ParticleSystemComponent.KillParticlesForced();
	}
	EmittersEnabled = true;
}

simulated function DisableParticles()
{
	local int i;
	for ( i = 0; i < StormParticles.Length; i++)
	{
		StormParticles[i].ParticleSystemComponent.DeactivateSystem();
	}
	EmittersEnabled = false;
}

function GetMaterials()
{
	//local MaterialInstanceConstant MatInst;
	//local int i;
	//for ( i = 0; i < StormMaterialInstances.Length; i++)
	//{
	//	// Make a new mat inst in memory as a parent of the one on disk to stop it complaining.
	//	MatInst = new class'MaterialInstanceConstant';
	//	MatInst.SetParent(StormMaterialInstances[i].Parent);
	//	DiskMaterialInstances.AddItem(StormMaterialInstances[i]);
	//	StormMaterialInstances[i].SetParent(MatInst);
	//	StormMaterialInstances[i] = MatInst;
	//}
}

function RevertMaterials()
{
	//local int i;
	//for ( i = 0; i < DiskMaterialInstances.Length; i++)
	//{
	//	DiskMaterialInstances[i].SetParent(StormMaterialInstances[i].Parent);
	//}
}

simulated function UpdateMaterials()
{
	local int i;
	for ( i = 0; i < StormMaterialInstances.Length; i++)
	{
		StormMaterialInstances[i].SetScalarParameterValue('StormIntensity',CurrentStormIntensity);
	}
}

auto state Clear
{
	simulated event Tick(float DeltaTime)
	{
		UpdateEffects();
	}

	simulated event BeginState(name PreviousStateName)
	{
		if (CurrentStormIntensity > 0.0f)
			GotoState('StormEndTransition');

		if (Role == ROLE_Authority)
		{
			if (bUseRelativeTimesWhenPossible && RenGame != none && RenGame.TimeLimit != 0)
				SetTimer(RenGame.TimeLimit / RelativeStormStartDelay, false, 'BeginStorm');
			else
				SetTimer(FixedStormStartDelay, false, 'BeginStorm');
		}
	}
}

state Storming
{
	simulated event Tick(float DeltaTime)
	{
		UpdateEffects();
	}

	simulated event BeginState(name PreviousStateName)
	{
		if (CurrentStormIntensity < 1.0f)
			GotoState('StormBeginTransition');

		if (Role == ROLE_Authority)
		{
			if (bUseRelativeTimesWhenPossible && RenGame != none && RenGame.TimeLimit != 0)
				SetTimer(RenGame.TimeLimit / RelativeStormLength, false, 'EndStorm');
			else
				SetTimer(FixedStormLength, false, 'EndStorm');
		}
	}
}

state StormBeginTransition
{
	simulated event Tick(float DeltaTime)
	{		
		CurrentStormIntensity += (1/StormTransitionInTime) * DeltaTime;
		if (CurrentStormIntensity >= 1)
		{
			CurrentStormIntensity = 1;
			GotoState('Storming');
		}

		UpdateEffects();
	}

	simulated event BeginState(name PreviousStateName)
	{
	}
}

state StormEndTransition
{
	simulated event Tick(float DeltaTime)
	{
		CurrentStormIntensity -= (1/StormTransitionOutTime) * DeltaTime;
		if (CurrentStormIntensity <= 0)
		{
			CurrentStormIntensity = 0;
			GotoState('Clear');
		}

		UpdateEffects();
	}

	simulated event BeginState(name PreviousStateName)
	{
	}
}

DefaultProperties
{
	LastUpdateStormIntensity = -1.0f
	CurrentStormIntensity = 0.0f
	StormTransitionInTime = 10.0f
	StormTransitionOutTime = 10.0f
	FixedStormStartDelay = 20.0f
	FixedStormLength = 20.0f
	RelativeStormStartDelay = 0.5f
	RelativeStormLength = 1.0f
	bUseRelativeTimesWhenPossible = false

	EmittersEnabled = true

	RemoteRole = ROLE_SimulatedProxy
	bAlwaysRelevant = true

	bNoDelete = true


	SceneDesaturationStorm = 0
	//SceneHiLightsStorm { X = 1, Y = 1, Z = 1}
	//SceneMidTonesStorm { X = 1, Y = 1, Z = 1}
	//SceneShadowsStorm { X = 0, Y = 0, Z = 0}

	Begin Object Class=SpriteComponent Name=Icon
		Sprite = Texture2D'Rx_Storm.StormIcon'
		HiddenGame = true
	End Object
	Components.Add(Icon)
}
