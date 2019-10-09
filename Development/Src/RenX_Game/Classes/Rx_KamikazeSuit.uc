class Rx_KamikazeSuit extends Actor; 

var PointLightComponent LightComp;
var repnotify Rx_Pawn Target;
var bool TargetWasSet;

var float TimeUntilKillTarget;


//Explosion Vars 
var CameraAnim          ExplosionShake;
var float               InnerExplosionShakeRadius;
var float               OuterExplosionShakeRadius;
var float				ExplosionShakeScale;
var ParticleSystem      ExplosionEffect;
var float				ExplosionScale;
var int					ExplosionRadius;  
var SoundCue			ExplosionSound; 
var int					ExplosionDamage; 
var class<DamageType>	DamageTypeClass;
var float				DamageMomentum;

var bool 		bExploded; 

var AudioComponent AudComponent;
var SoundCue BeamSound;

var	class<DamageType> ExplosionDamageType;

replication
{
	if ( bNetDirty )
		Target;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'Target' && Target != none)
		SetTarget(Target);
	else 
		super.ReplicatedEvent(VarName);
	
}

simulated event Tick( float DeltaTime )
{
	if(Target != none)
	{
		SetLocation(target.Location);
	}		
	
	if (ROLE == ROLE_Authority && !bExploded && Target != none)
	{
		if (Target.Health <= 0)
		{
			Explosion(Target.LastHitBy); 
		}
	}
}

simulated event PostBeginPlay()
{
	AudComponent.Play();
}

simulated function SetTarget(Rx_Pawn NewTarget)
{
	Target = NewTarget;
	
	
	if(ROLE == Role_Authority)
	{	
		if(Rx_Controller(Target.Controller) != none){
			Rx_Controller(Target.Controller).AddActiveModifier(class'Rx_StatModifierInfo_Kamikaze'); 
			SetTimer(1.0, true, 'CountDownTimer');
		}
	}
	
	SetTimer(default.TimeUntilKillTarget,false,'KillTarget');
	
	Target.CanEnterVehicles = false;
	Target.bCanSuicide = false; 
}

function CountDownTimer()
{
	if(Rx_Controller(Target.Controller) != none)
	{
		Rx_Controller(Target.Controller).CTextMessage("-"$int(TimeUntilKillTarget)-1$"-",'Red', 25.0, 2.0, false, true);
		TimeUntilKillTarget-=1;
	}
}

simulated function KillTarget()
{
	if(ROLE == ROLE_Authority)
	{
		ClearTimer('CountDownTimer');
		if(Target == none || Target.Controller == none)
		{
			Target.SetHidden(true); 
			Explosion();
			Target.TakeDamage(100000,none,Target.Location,vect(0,0,0),DamageTypeClass,,self);
			return;
		}
		
		Target.TakeDamage(100000,none,Target.Location,vect(0,0,0),DamageTypeClass,,self);
		Target.SetHidden(true); 
	}
	//Target.Suicide();
	Explosion(Target.Controller);
	Target = none; 
	Destroy(); 
}

simulated function PlayExplosionEffect()
{

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      if (ExplosionSound != none)
      {
         PlaySound(ExplosionSound, true,,false);
      }
      
      SpawnExplosionEmitter(Target.Location, Target.Rotation);
	  //PlayCamerashakeAnim();
    }
}

simulated function SpawnExplosionEmitter(vector SpawnLocation, rotator SpawnRotation)
{
	local ParticleSystemComponent MyExplosionEmitter;
	
	MyExplosionEmitter = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, SpawnRotation);
	
	SetExplosionEffectParams(MyExplosionEmitter);
}  

simulated function SetExplosionEffectParams(ParticleSystemComponent PSC)
{
	PSC.SetScale(ExplosionScale);
} 

simulated function Explosion(optional Controller EventInstigator) //By default they explode with no instigator, but can be told what the explosion should belong to
{
	local Pawn P;  
	  
	if(bExploded) 
		return; //Don't double dip on explosions
	  
	bExploded = true; 
	if (WorldInfo.NetMode != NM_DedicatedServer) //This is literally the most worthless line ever for network play
		PlayExplosionEffect();

		foreach VisibleCollidingActors(class'Pawn', P, ExplosionRadius, Location, false)
		{
			if(P != Target)
			{
				if(P.GetTeamNum() != Target.GetTeamNum())
					P.TakeRadiusDamage(EventInstigator, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, false, self);
				else
					P.TakeRadiusDamage(none, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, false, self);
			}				
				
		}
	
	AudComponent.Stop(); 
	SetTimer(1.0f, false, 'ToDestroy');
}



function ToDestroy()
{
   Destroy();
}

DefaultProperties
{
	Begin Object Class=AudioComponent name=BeamSoundComp
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'Rx_Pickups.Sounds.SC_KamikazeBeeps'
    End Object
	AudComponent = BeamSoundComp
    Components.Add(BeamSoundComp)

	ExplosionDamageType = class'Rx_DmgType_Kamikaze'

	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'
	ExplosionEffect=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Air'
	ExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=150.0
	OuterExplosionShakeRadius=550.0
	ExplosionShakeScale=1.5
	
	ExplosionDamage=500
	ExplosionRadius=800
	DamageMomentum=10000
	DamageTypeClass=class'Rx_DmgType_Kamikaze'
	ExplosionScale = 1.0f
	
	TimeUntilKillTarget = 10

	 Begin Object Class=PointLightComponent Name=RadialLight
	Brightness=12.0
	Radius=300
	LightColor=(R=255,G=0,B=0)
	bEnabled=TRUE
   End Object
   LightComp = RadialLight
   Components.Add(RadialLight)

	bNetTemporary=true
	bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy

	bTickIsDisabled = false
	TickGroup = TG_PostAsyncWork
	bHardAttach = true
	
	
	
}
