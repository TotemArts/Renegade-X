class Rx_DestroyableObstaclePlus extends Actor 
abstract;


/** The Mesh */
var() StaticMeshComponent Mesh; //We need this apparently..

/** Component properties to replicate */
var repnotify vector ReplicatedMeshTranslation;
var repnotify rotator ReplicatedMeshRotation;
var repnotify vector ReplicatedMeshScale3D;
var repnotify StaticMesh ReplicatedMesh; 
var repnotify MaterialInterface ReplicatedMaterial0, ReplicatedMaterial1;
var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

var() int HP, MaxHP;

var() bool bShowHealth; //Whether to show a target reticle with health

var() SoundCue ExplosionSound;

var() bool bExplodes, bDoFullDamage; 

var() float ExplosionDamage, ExplosionRadius;

var() class<DamageType> DamageTypeClass; 
var() bool				bLightArmor; //Just means whether this will take damage from bullets and normal weapons or not
var() bool				bTakeRadiusDamage; 
var() bool				bCanHeal;  


var CameraAnim                   ExplosionShake;
var float                        InnerExplosionShakeRadius;
var float                        OuterExplosionShakeRadius;
var() ParticleSystem             ExplosionEffect;
var() float                        ExplosionDelay;

var(Damage) float                DamageMomentum;
var(Damage) bool                 bDamageAll;

var() string ObstacleName; 
var float DamageSmokeThreshold; 

var repnotify bool bExploded;


replication
{
	if(bNetDirty && ROLE == ROLE_Authority && bNetInitial) //This is what making things customizable looks like...... LOOK AT IT
		ReplicatedMesh, ReplicatedMeshTranslation, ReplicatedMeshRotation, ReplicatedMeshScale3D, ReplicatedMaterial0, ReplicatedMaterial1,
		ExplosionDamage, ExplosionRadius, DamageMomentum, bDamageAll, ExplosionShake, InnerExplosionShakeRadius, OuterExplosionShakeRadius, ExplosionEffect,
		DamageTypeClass, MaxHP, bShowHealth, ExplosionSound, ObstacleName;
	
   if (bNetDirty)
      HP, bExploded ;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ReplicatedMesh')
	{
		LightEnvironment.bCastShadows = false;
		LightEnvironment.SetEnabled(TRUE);
		
	 Mesh.SetStaticMesh(ReplicatedMesh);
	 
	}
	else if (VarName == 'ReplicatedMeshTranslation')
	{
		Mesh.SetTranslation(ReplicatedMeshTranslation);
	}
	else if (VarName == 'ReplicatedMeshRotation')
	{
		Mesh.SetRotation(ReplicatedMeshRotation);
	}
	else if (VarName == 'ReplicatedMeshScale3D')
	{
		Mesh.SetScale3D(ReplicatedMeshScale3D / 100); // remove compensation for replication rounding
	}
	else
 if (VarName == 'ReplicatedMaterial0')
	{
		Mesh.SetMaterial(0, ReplicatedMaterial0);
	}
	else if (VarName == 'ReplicatedMaterial1')
	{
		Mesh.SetMaterial(1, ReplicatedMaterial1);
	}
	else if (VarName == 'bExploded')
	{
		if(bExploded) PlayExplosionEffect(); 
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}



event PostBeginPlay()
{
	Super.PostBeginPlay();

	if( Mesh != none )
	{
		ReplicatedMesh = Mesh.StaticMesh;
		ReplicatedMeshRotation=Mesh.rotation;
		ReplicatedMeshTranslation=Mesh.Translation;
		ReplicatedMeshScale3D=DrawScale3D*100; //The editor usually uses the object's DrawScale as opposed to the scale on the Mesh
		ReplicatedMaterial0 = Mesh.Materials[0];
		if(mesh.Materials.Length == 2)
			ReplicatedMaterial1 = Mesh.Materials[1];
	
		//bForceStaticDecals = Mesh.bForceStaticDecals;
	}
}

function SetStaticMesh(StaticMesh NewMesh, optional vector NewTranslation, optional rotator NewRotation, optional vector NewScale3D)
{
	
	Mesh.SetStaticMesh(NewMesh);
	Mesh.SetTranslation(NewTranslation);
	Mesh.SetRotation(NewRotation);
	if (!IsZero(NewScale3D))
	{
		Mesh.SetScale3D(NewScale3D);
		ReplicatedMeshScale3D = NewScale3D * 100; // avoid rounding in replication code
	}
	ReplicatedMesh = NewMesh;
	ReplicatedMeshTranslation = NewTranslation;
	ReplicatedMeshRotation = NewRotation;
	ForceNetRelevant();
}


simulated function string GetHumanReadableName()
{
	return ObstacleName;
}

simulated function PlayExplosionEffect()
{

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      if (ExplosionSound != none)
      {
         PlaySound(ExplosionSound, true,,false);
      }
      
      SpawnExplosionEmitter(Location, Rotation);
    }
}

simulated function SpawnExplosionEmitter(vector SpawnLocation, rotator SpawnRotation)
{
   WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, SpawnRotation);
}  


simulated function Explosion()
{
   local Pawn P;  

  
  bExploded = true; 
   if (WorldInfo.NetMode != NM_DedicatedServer) //This is literally the most worthless line ever for network play
      PlayExplosionEffect();

  if(bExplodes )
   foreach CollidingActors(class'Pawn', P, ExplosionRadius, Location, false)
		{
            P.TakeRadiusDamage(none, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, bDoFullDamage, self);
		}
   

   SetTimer(ExplosionDelay, false, 'ToDestroy');
}

function ToDestroy()
{
   Destroy();
}

//Do not take Radius Damage
simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
)
{
	if(bTakeRadiusDamage) super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent) ;
	else
	return;
	
}

//Do not allow healing of 'most' destroyable obstacles
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
if(bCanHeal) HP=Min(MaxHP,HP+Amount); //Nothing fancy for a rock 
else
return false;
} 

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local class<Rx_DmgType> RXDT; 
	
	RXDT=class<Rx_DmgType>(DamageType);
	
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if (DamageAmount <= 0 || HP <= 0)
      return;

	if ( DamageType != None )
	{
		
	if(bLightArmor) 
	{
	DamageAmount*=RXDT.static.VehicleDamageScalingFor(none);
	HP-=fmax(DamageAmount, 1);
	}  
	else //Heavy armor is fine taking no damage from low damage weapons 
	{
	DamageAmount *= RXDT.static.BuildingDamageScalingFor();  
	HP-=DamageAmount;
	}
	
	
	
	
	}
	
	//KISS
	if (HP <= 0)
	{	
		Explosion();
	}
}

function DestroyMe() {
   Destroy();	
}

simulated function int GetHealth() {
   return HP;
}

simulated function int GetMaxHealth() {
   return MaxHP;
}

simulated function PlayCamerashakeAnim()
{
	
   local UTPlayerController UTPC;
   local float Dist;
   local float MinViewDist;
   local float ExplosionShakeScale;
   
   MinViewDist = 10000.0;
   
   foreach LocalPlayerControllers(class'UTPlayerController', UTPC)
   {
      Dist = VSize(Location - UTPC.ViewTarget.Location);

      MinViewDist = FMin(Dist, MinViewDist);
      if (Dist < OuterExplosionShakeRadius)
      {
         if (ExplosionShake != None)
         {
            ExplosionShakeScale = 1.5;
            if (Dist > InnerExplosionShakeRadius)
            {
               ExplosionShakeScale -= (Dist - InnerExplosionShakeRadius) / (OuterExplosionShakeRadius - InnerExplosionShakeRadius);
            }
            UTPC.PlayCameraAnim(ExplosionShake, ExplosionShakeScale);
         }
      }
   }
}

DefaultProperties

{
Physics=PHYS_NONE
HP=7000

MaxHP=7000

//Team=255


 
//Jack a small bit from Rx_Vehicle for explosions/animations 
 
DamageSmokeThreshold=0.25
 
ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'


bExplodes = false
ExplosionDamage=0
ExplosionRadius=1
ExplosionDelay=0.5f;
bDamageAll=false 
DamageMomentum=10000


DamageTypeClass=class'Rx_DmgType_GrenadeLauncher'

 
ObstacleName = "Destroyable Obstacle" 

 
   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

Begin Object Class=StaticMeshComponent Name=ObstacleMesh
		//HiddenGame=true
		CastShadow                      = True
		CollideActors                   = True
		BlockActors                     = True
		BlockRigidBody                  = True
		BlockZeroExtent                 = True
		BlockNonZeroExtent              = True
		bCastDynamicShadow              = True
		bAcceptsLights                  = True
		bAcceptsDecalsDuringGameplay    = True
		bAcceptsDecals                  = True
		bAllowApproximateOcclusion      = True
		bUsePrecomputedShadows          = True
		bForceDirectLightMap            = True
		bAcceptsDynamicLights           = True
		ForcedLodModel 					= 1
		LightingChannels                = (bInitialized=True,Static=True)
		LightEnvironment=MyLightEnvironment
	End Object
	Mesh=ObstacleMesh
	Components.Add(ObstacleMesh)
  
 bCollideActors=true
 bCollideWorld=true 
 bCollideComplex=true
 bBlockActors=true
 bProjTarget=true 
 
 bShowHealth=true
 
 bAlwaysRelevant=true
 bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bPathColliding=true

}