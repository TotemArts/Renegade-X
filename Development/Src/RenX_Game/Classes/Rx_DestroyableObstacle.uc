class Rx_DestroyableObstacle extends Rx_DynamicNavMeshObstacle
abstract;


/** The Mesh */
var StaticMeshComponent Mesh; //We need this apparently..

var int HP, MaxHP;

var SoundCue ExplosionSound;

var bool bExplodes, bFullDamage; 

var float ExplosionDamage, ExplosionRadius;

var class<DamageType> DamageTypeClass; 

var CameraAnim                   ExplosionShake;
var float                        InnerExplosionShakeRadius;
var float                        OuterExplosionShakeRadius;
var() ParticleSystem             ExplosionEffect;

var(Damage) float                DamageMomentum;
var(Damage) bool                 bDamageAll;

var string ObstacleName; 
var float DamageSmokeThreshold; 

replication
{
   if (Role == ROLE_Authority && bNetDirty)
      HP;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetAsCircle(96, 8);
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


function Explosion()
{
   local Pawn P;  


 
   if (WorldInfo.NetMode != NM_DedicatedServer)
      PlayExplosionEffect();

  if(bExplodes)
   foreach CollidingActors(class'Pawn', P, ExplosionRadius, Location, false)
		{
            P.TakeRadiusDamage(none, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, bFullDamage, self);
		}
   

   SetTimer(0.5f, false, 'ToDestroy');
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
	bool				bFullDamage_in,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
);

//Do not allow healing of 'most' destroyable obstacles
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType); 

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local class<Rx_DmgType> RXDT; 
	
	RXDT=class<Rx_DmgType>(DamageType);
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if (DamageAmount <= 0 || HP <= 0)
      return;

	if ( DamageType != None )
	{
		
	DamageAmount *= RXDT.static.BuildingDamageScalingFor();  
	HP -= DamageAmount;
	
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
bDamageAll=false 
DamageMomentum=10000


DamageTypeClass=class'Rx_DmgType_GrenadeLauncher'

 
ObstacleName = "Destroyable Obstacle" 

Begin Object Class=StaticMeshComponent Name=ObstacleMesh
		//HiddenGame=true
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = false
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
	End Object
	Mesh=ObstacleMesh
	Components.Add( ObstacleMesh )
   
   
 bCollideActors=true
 bCollideWorld=true 
 bCollideComplex=true
 bBlockActors=true
 bProjTarget=true 

}