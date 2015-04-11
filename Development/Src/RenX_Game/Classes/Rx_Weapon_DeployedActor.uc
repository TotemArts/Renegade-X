class Rx_Weapon_DeployedActor extends Actor
   abstract;

/** Who owns this */
var Controller	InstigatorController;

/** Owner team number */
var byte TeamNum;

/** The Mesh */
var MeshComponent Mesh;

/** Here on the hud to display it */
var vector HudLocation;

/** The deployable's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

var repnotify bool bDeployed;

var(Damage) int                  HP;
var			int                  MaxHP;
var(Damage) int                  DisarmScoreReward;
var protected repnotify bool     bExplode;         
var protected repnotify bool     bDisarmed;        
var(Damage) float                TimeUntilExplosion; // if 0 no explosion!
var(Damage) bool                 bBroadcastPlaced;
var(Damage) bool                 bBroadcastDisarmed;
var(Damage) int                  Damage;
var(Damage) bool                 bFullDamage; // is doing full damage not radius
var(Damage) float                DmgRadius;
var(Damage) float                BuildingDmgRadius;
var(Damage) class<DamageType>    DamageTypeClass; //
var(Damage) float                DamageMomentum;
var(Damage) Vector               VectorHurtOrigin;
var() string                     DeployableName;
var() name                       ExplosionSocketName;
var() SoundCue                   ExplosionSound;
var() SoundCue                   DisarmedSound;
var() ParticleSystem             ExplosionEffect;
var() ParticleSystem             DisarmedEffect;
var() ParticleSystem             BlinkingLight;
var ParticleSystemComponent      LandEffects; /** When the deployable has landed this system starts running*/
var bool                         bCanNotBeDisarmedAnymore;
var CameraAnim                   ExplosionShake;
var float                        InnerExplosionShakeRadius;
var float                        OuterExplosionShakeRadius;
var(Damage) bool                 bDamageAll;
var bool                         bImminentExplode;

replication
{
   if (Role == ROLE_Authority && bNetDirty)
      TeamNum, bDeployed, HP, bExplode, bDisarmed, bCanNotBeDisarmedAnymore, bImminentExplode;
}

/** We use a delegate so that different types of creators can get the OnDestroyed event */
delegate OnDeployableUsedUp(actor ChildDeployable);

simulated function Destroyed()
{
   Super.Destroyed();

   if (Role == ROLE_Authority)
   {
      // Notify the actor that controls this
      OnDeployableUsedUp(self);
   }
}

simulated function string GetHumanReadableName()
{
	return DeployableName;
}

/**
 * Whether or not to damage all (including deployer and team)
 * */
function SetDamageAll(bool DamageAll)
{
   bDamageAll = DamageAll;
}

simulated function PostBeginPlay()
{
   Super.PostBeginPlay();
   
   MaxHP = HP;

   if (Instigator != None)
   {
      InstigatorController = Instigator.Controller;
      TeamNum = Instigator.GetTeamNum();
   }
   
    if (WorldInfo.NetMode != NM_Client)
    {
       if (TimeUntilExplosion > 0)
          SetTimer(TimeUntilExplosion, false, 'Explosion'); 
    }
}

function Landed(vector HitNormal, Actor FloorActor)
{
    super.Landed(HitNormal, FloorActor);
   
   if (WorldInfo.NetMode != NM_Client)
      bDeployed = true;

   PerformDeploy();
      
   if (FloorActor != None)
    {
      if(Rx_Weapon_DeployedActor(FloorActor) == none) 
      {
            SetBase(FloorActor, HitNormal);
      }
    }
   if(WorldInfo.NetMode != NM_DedicatedServer)
   {
      if(LandEffects != none && !LandEffects.bIsActive)
      {
         LandEffects.SetActive(true);
      }
   }    
}

event bool EncroachingOn(Actor Other)
{
   return false;
}

event RanInto( Actor Other )
{
}

event BaseChange()
{
   if ( bDeployed && (Base == None) && !bDeleteMe )
   {
      Destroy();
   }
}

/**
 * HurtRadius()
 * Hurt locally authoritative actors within the radius.
 */
simulated function bool HurtRadius( float DamageAmount,
                            float InDamageRadius,
                class<DamageType> DamageType,
                           float Momentum,
                           vector HurtOrigin,
                           optional actor IgnoredActor,
                           optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
                           optional bool bDoFullDamage
                           )
{
   if ( bHurtEntry )
      return false;

   if (InstigatedByController == None)
   {
      InstigatedByController = InstigatorController;
   }

   return Super.HurtRadius(DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, None, InstigatedByController, bDoFullDamage);
}

simulated event ReplicatedEvent(name VarName)
{
   if ( VarName == 'bDeployed' )
   {
      PerformDeploy();
   }
    else if (VarName == 'bExplode') 
    {
      if (bExplode)
         PlayExplosionEffect();
   }	
    else if (VarName == 'bDisarmed') 
    {
      PlayDisarmedEffect();
   }	
   else
   {
      Super.ReplicatedEvent(VarName);
   }
}

function ImminentExplode()
{
   bImminentExplode=true;
   bBroadcastPlaced=false;
   Explosion();
}

simulated function PerformDeploy()
{
   SetCollision(true, false);
   SetPhysics(PHYS_None);

   if (bBroadcastPlaced && WorldInfo.NetMode != NM_Client)
      BroadcastPlaced();
}

function BroadcastPlaced() {
   local PlayerController PC;
   foreach LocalPlayerControllers(class'PlayerController', PC)
   {
      PC.ClientMessage(InstigatorController.PlayerReplicationInfo.PlayerName@"placed"
                       @DeployableName@"!", 
                       'PLACED_DEPLOYED', 
                       3.0f);
   }
}

function BroadcastDisarmed(Controller Disarmer) {
   local PlayerController PC;
   foreach LocalPlayerControllers(class'PlayerController', PC)
   {
      PC.ClientMessage(Disarmer.PlayerReplicationInfo.PlayerName@"disarmed"
                       @DeployableName@"!", 
                       'DISARMED_DEPLOYED', 
                       3.0f);
   }
}

simulated function byte GetTeamNum() 
{
   return TeamNum;
}

function Reset()
{
   Destroy();
}

simulated event Attach(Actor Other)
{
}

simulated function PlayExplosionEffect()
{
   local vector SpawnLocation;
   local rotator SpawnRotation;

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      if (ExplosionSound != none && ((!self.IsA('Rx_Weapon_DeployedIonCannonBeacon') && !self.IsA('Rx_Weapon_DeployedNukeBeacon')) || bImminentExplode))
      {
         PlaySound(ExplosionSound, true,,false);
      }
      if (ExplosionSocketName != '')
         SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation( ExplosionSocketName, SpawnLocation, SpawnRotation );
      else
      {
         SpawnLocation = Location;
         SpawnRotation = Rotation;
      }
      SpawnExplosionEmitter(SpawnLocation, SpawnRotation);
    }
}

simulated function PlayDisarmedEffect()
{
   local vector SpawnLocation;
   local rotator SpawnRotation;

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      if (DisarmedSound != none)
         PlaySound(DisarmedSound, true,,false);

      SpawnLocation = Location;
      SpawnRotation = Rotation;
      SpawnDisarmedEmitter(SpawnLocation, SpawnRotation);
    }
}

simulated function SpawnExplosionEmitter(vector SpawnLocation, rotator SpawnRotation)
{
   WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, SpawnRotation);
}  

simulated function SpawnDisarmedEmitter(vector SpawnLocation, rotator SpawnRotation)
{
   WorldInfo.MyEmitterPool.SpawnEmitter(DisarmedEffect, SpawnLocation, SpawnRotation);
}  

function Explosion()
{
   local Rx_Building B, tracedB;
   local Pawn P;
   local vector HitLoc,HitNorm, BuildingLocation, FlatLocation;
   local bool bDamagePawn, bBuildingHit;   


   if (InstigatorController != None && InstigatorController.PlayerReplicationInfo != None)
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "at" `s self.Location `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
   else
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "at" `s self.Location);
   bExplode = true; // trigger client replication
   if (WorldInfo.NetMode != NM_DedicatedServer)
      PlayExplosionEffect();

	// damage Buildings
	FlatLocation = Location;
	foreach OverlappingActors(class'Rx_Building', B, BuildingDmgRadius, Location, false)
	{
		bBuildingHit = false;

		if (VSize(B.Location-Location) <= BuildingDmgRadius)
			bBuildingHit=true;
		else if (B.BuildingInternals.Trace2dTargets.Length > 0)
		{
			foreach B.BuildingInternals.Trace2dTargets(BuildingLocation)
			{
				FlatLocation.Z = BuildingLocation.Z;
				if (VSize(BuildingLocation-FlatLocation) <= BuildingDmgRadius)
					bBuildingHit=true;
				else
				{
					foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, FlatLocation)
					{  
						if (tracedB == B)
						{
							if (VSize(HitLoc-FlatLocation) <= BuildingDmgRadius)
								bBuildingHit = true;
							break;
						}
					}
				}
				if (bBuildingHit)
					break;
			}
		}
		else
		{
			// Fallback method in the event the building does not have any Trace2d targets.
			BuildingLocation = B.Location;
			foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, Location)
			{  
				if (tracedB == B && VSize(HitLoc-Location) <= BuildingDmgRadius)
					bBuildingHit = true;
				break;
			}
		}

		if (bBuildingHit)
		{
			if (GetTeamNum() != B.GetTeamNum() || bDamageAll)
				B.TakeRadiusDamage(InstigatorController, Damage, DmgRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, VectorHurtOrigin, true, self);
		}
	}
   
   // damage Pawns
   foreach CollidingActors(class'Pawn', P, DmgRadius, Location, false)
   {
      bDamagePawn = true;
      foreach TraceActors(class'Rx_Building',B,HitLoc,HitNorm,location,P.location)
      {
         bDamagePawn = false;
         break;		
      }
      if(bDamagePawn) 
      { 
         if ((GetTeamNum() != P.GetTeamNum()) 
             || (P.Controller == InstigatorController) || bDamageAll)
            P.TakeRadiusDamage(InstigatorController, Damage, DmgRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, VectorHurtOrigin, bFullDamage, self);
      }
   }

   SetTimer(0.5f, false, 'ToDestroy');
}

function ToDestroy()
{
   Destroy();
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
   if (Amount <= 0 || HP == MaxHP)
      return false;

   HP += Amount;

   if (HP > MaxHP)
   {
		HP = MaxHP;
   }
   return true;
}

simulated function bool CanDisarmMe(Actor A)
{
	if (Rx_Weapon_RepairGun(A) != None)
		return true;
	return false;
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (!CanDisarmMe(DamageCauser))
	{
		return;
	}
	
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if (DamageAmount <= 0 || HP <= 0 || bDisarmed )
      return;

	HP -= DamageAmount;

	if (HP <= 0)
	{
		BroadcastDisarmed(EventInstigator);
		if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
			bDisarmed = true;
		if (WorldInfo.NetMode != NM_DedicatedServer)
			PlayDisarmedEffect();      
			ClearTimer('Explosion');

		
		if (EventInstigator.PlayerReplicationInfo != none && EventInstigator.PlayerReplicationInfo.GetTeamNum() != TeamNum)
		{
			Rx_Pri(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(DisarmScoreReward,true);
		}
		
		SetTimer(0.1, false, 'DestroyMe'); // delay it a bit so disappearing blends a littlebit better with the disarmed effects
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

defaultproperties
{
   Physics=PHYS_Falling
   RemoteRole=ROLE_SimulatedProxy
   bReplicateInstigator=true

   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
       bEnabled                        = True
      bSynthesizeSHLight              = True
      bUseBooleanEnvironmentShadowing = False
   End Object
   LightEnvironment=MyLightEnvironment
   Components.Add(MyLightEnvironment)
   
   bAlwaysRelevant      = true
   TimeUntilExplosion   = 0
   DisarmScoreReward    = 3
   Begin Object Class=SkeletalMeshComponent Name=DeployableMesh
      BlockNonZeroExtent   = false
      BlockZeroExtent      = true
      CollideActors        = true
      BlockActors          = true
      BlockRigidBody       = false
      LightEnvironment = MyLightEnvironment
   End Object
   Mesh=DeployableMesh
   Components.Add(DeployableMesh)
	
   Begin Object Class=CylinderComponent Name=CollisionCylinder
      CollisionRadius=+000.100000
      CollisionHeight=+000.100000
   End Object
   CollisionComponent=CollisionCylinder
   Components.Add(CollisionCylinder)	
	//CollisionComponent= DeployableMesh
   
   BlinkingLight=ParticleSystem'RX_WP_Nuke.Effects.P_NukeBeacon_BlinkingLight'
   
   DisarmedEffect=ParticleSystem'RX_FX_Munitions.Explosions.P_EquipmentDisarmed'
   DisarmedSound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Fire'

   bWorldGeometry          = true
   //bWorldGeometry          = false
   bPushedByEncroachers    = false
   bIgnoreEncroachers      = false
   bOrientOnSlope          = true
   bIgnoreRigidBodyPawns   = false  
   bNoEncroachCheck        = true
   //bNoEncroachCheck        = false
   bAlwaysEncroachCheck    = false
   
   //bCollideAsEncroacher = true

   bCollideActors=true
    bCollideWorld=true 
    bCollideComplex=true
    bBlockActors=false 
   bProjTarget=true 
   
}