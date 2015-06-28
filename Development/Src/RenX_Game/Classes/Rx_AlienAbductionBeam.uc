class Rx_AlienAbductionBeam extends Actor
	placeable;

var SpotLightComponent BLight;
var StaticMeshComponent Mesh;
var repnotify Rx_Pawn Target;
var bool TargetWasSet;

var float TimeUntilKillTarget;
var float UpwardAcceleration;
var float DeathImpulse;
var float AfterDeathUpwardForce;
var float FadeoutTime;
var float FadeInTime;

var SoundCue BeamSound;
var AudioComponent AudComponent;

var MaterialInstance MatInst;

var	class<DamageType> BeamDamageType;

replication
{
	if ( bNetDirty )
		Target;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'Target' && Target != none)
		SetTarget(Target);
}


simulated event Tick( float DeltaTime )
{
	if (FadeInTime > 0)
	{
		FadeInTime -= DeltaTime;
		UpdateFadeInOut();
	}

	if (Target != none)
	{
		SetLocation(target.Location);


		if (Target.Health <= 0)
		{
			FadeoutTime -= DeltaTime;
			UpdateFadeInOut();

			Target.Mesh.AddForce(vect(0,0,1) * AfterDeathUpwardForce,,'b_head');

			if (FadeoutTime <= 0)
			{
				Target.Destroy();
				Destroy();
			}
		}
		else
		{
			if (Target.Physics != PHYS_Falling) // Don't allow to be grounded, because they stop being affected by the inverse gravity
				Target.SetPhysics(PHYS_Falling);
		}
	}
	else if (TargetWasSet)
		Destroy(); // Target was set, and then destroyed somehow, so we're no longer needed.

}

function UpdateFadeInOut()
{
	local float CurrentFade;
	CurrentFade = FMax(fmin(FadeoutTime / default.FadeoutTime,1 - FadeInTime / default.FadeInTime),0);
	
	AudComponent.VolumeMultiplier = CurrentFade;
	MatInst.SetScalarParameterValue('FadeIn',CurrentFade);
	BLight.SetLightProperties(default.BLight.Brightness * CurrentFade);
}

simulated event PostBeginPlay()
{
	MatInst = new class'MaterialInstanceConstant';
	MatInst.SetParent(Mesh.GetMaterial(0));
	Mesh.SetMaterial(0,MatInst);
	AudComponent.Play();
}

function SetTarget(Rx_Pawn NewTarget)
{
	Target = NewTarget;
	SetTimer(TimeUntilKillTarget,false,'KillTarget');

	Target.CustomGravityScaling = -UpwardAcceleration;

	TargetWasSet = true;
}

function KillTarget()
{
	//Target.Suicide();
	Target.TakeDamage(100000,none,Target.Location,vect(0,0,0),BeamDamageType,,self);
	Target.Mesh.AddImpulse(vect(0,0,1) * DeathImpulse,,'b_head');
}

DefaultProperties
{
	Begin Object Class=AudioComponent name=BeamSoundComp
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'Rx_Pickups.Sounds.SC_Crate_AbductionBeam'
    End Object
	AudComponent = BeamSoundComp
    Components.Add(BeamSoundComp)

	BeamDamageType = class'Rx_DmgType_Abduction'

	TimeUntilKillTarget = 5
	UpwardAcceleration = 0.08
	AfterDeathUpwardForce = 150
	DeathImpulse = 1000
	FadeoutTime = 2
	FadeInTime = 1

	Begin Object Class=SpotLightComponent name=BeamLight
		InnerConeAngle = 0.0
		OuterConeAngle = 4.0
		Translation = (X=0,Y=0,Z=500)
		Rotation    = (Pitch=-16384,Yaw=0,Roll=0)
		LightColor  = (B=255,G=200,R=200,A=0)
		Brightness = 100
		CastShadows = true
		CastStaticShadows = false
		CastDynamicShadows = true
		bAffectCompositeShadowDirection = true
		Radius = 1000
		FalloffExponent = 6;
	End Object

	Components.Add(BeamLight)
	BLight = BeamLight

	Begin Object Class=StaticMeshComponent Name=BeamMesh
		StaticMesh=StaticMesh'rx_fx_envy.Misc.SM_AbductionBeam'
		Scale=1.0f
		CollideActors = false
		BlockActors = false
		BlockZeroExtent = false
		BlockNonZeroExtent = false
		BlockRigidBody = false
	End Object
	Components.Add(BeamMesh)

	bNetTemporary=true
	bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy

	Mesh = BeamMesh
	bTickIsDisabled = false
	TickGroup = TG_PostAsyncWork
}
