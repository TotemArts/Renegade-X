class Rx_Weapon_DeployedActor extends Actor
   abstract
   implements(RxIfc_Targetable)
   implements(Rx_ObjectTooltipInterface);

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
var bool                         PlayExplosionSound;
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

// Pickup related
var class<Rx_Weapon_Deployable>  WeaponClass;
var float PickupDistance;

//Veterancy
var byte 						 VRank; 
var float						 Vet_DamageModifier[4]; 

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

function ClientPickup(Rx_Controller InController)
{
    Pickup(InController);
}

reliable server function Pickup(Rx_Controller InController)
{
    local Rx_InventoryManager InvManager;
    local Rx_Weapon_Deployable TheWeapon;

    if (!CanPickup(InController)) return;

    InvManager = Rx_InventoryManager(InController.Pawn.InvManager);

    TheWeapon = Rx_Weapon_Deployable(InvManager.FindInventoryType(WeaponClass));

    if (TheWeapon != None)
    {
        // Not at full clip
        if (TheWeapon.GetMaxAmmoInClip() != TheWeapon.CurrentAmmoInClip)
        {
            ServerPickup(TheWeapon, InController, TheWeapon.CurrentAmmoInClip + 1, TheWeapon.GetReserveAmmo());
        }
        // Full clip, add to reserve ammo
        else
        {
            ServerPickup(TheWeapon, InController, TheWeapon.CurrentAmmoInClip, TheWeapon.GetReserveAmmo() + 1);
        }
    }

    // required for picking up mines and other weapons that hide when ammo is depleted (but you could pick up again)
    Rx_Pawn(InController.Pawn).RefreshBackWeapons();
}

reliable private server function ServerPickup(Rx_Weapon_Deployable TheWeapon, Rx_Controller InController, int NewAmmoInClip, int NewAmmo)
{
    if (!CanPickup(InController)) return;

    // Make sure we don't overfill their weapon
    if (TheWeapon.AmmoCount != TheWeapon.MaxAmmoCount)
    {
        TheWeapon.CurrentAmmoInClip = NewAmmoInClip;
        TheWeapon.AmmoCount = NewAmmo + NewAmmoInClip;
        TheWeapon.CurrentAmmoInClipClientside = NewAmmoInClip;
        TheWeapon.ClientAmmoCount = NewAmmo + NewAmmoInClip;

        TheWeapon.ClientUpdateAmmoCount(NewAmmo);
    }

    Destroy();
}

reliable server function bool CanPickup(Rx_Controller InController)
{
    return false;
}

simulated function bool CanPickupClient()
{
    return false;
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
			Mesh.SetTraceBlocking (true,true); //Enable collision with zero-extent traces for repair guns
			
	  }
    }
   if(WorldInfo.NetMode != NM_DedicatedServer)
   {
      if(LandEffects != none && !LandEffects.bIsActive)
      {
         LandEffects.SetActive(true);
      }
   } 
   else 
   {    
		SetTimer(0.5,false,'ReplicatePositionAfterLanded');
   }
   
}

/** to make sure final location gets replicated */
function ReplicatePositionAfterLanded()
{
	ForceNetRelevant();
	bUpdateSimulatedPosition = true;
	bNetDirty = true;   
	
	
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

   return Super.HurtRadius(DamageAmount*Vet_DamageModifier[VRank], InDamageRadius, DamageType, Momentum, HurtOrigin, None, InstigatedByController, bDoFullDamage);
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
		if (ExplosionSound != none && (PlayExplosionSound || bImminentExplode))
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
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
   else
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location);
   bExplode = true; // trigger client replication
   if (WorldInfo.NetMode != NM_DedicatedServer)
      PlayExplosionEffect();

	// damage Buildings
	FlatLocation = Location;
	foreach OverlappingActors(class'Rx_Building', B, BuildingDmgRadius, Location, false)
	{
		bBuildingHit = false;

		if (VSizeSq(B.Location-Location) <= Square(BuildingDmgRadius))
			bBuildingHit=true;
		else if (B.BuildingInternals.Trace2dTargets.Length > 0)
		{
			foreach B.BuildingInternals.Trace2dTargets(BuildingLocation)
			{
				FlatLocation.Z = BuildingLocation.Z;
				if (VSizeSq(BuildingLocation-FlatLocation) <= Square(BuildingDmgRadius))
					bBuildingHit=true;
				else
				{
					foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, FlatLocation)
					{  
						if (tracedB == B)
						{
							if (VSizeSq(HitLoc-FlatLocation) <= Square(BuildingDmgRadius))
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
				if (tracedB == B && VSizeSq(HitLoc-Location) <= Square(BuildingDmgRadius))
					bBuildingHit = true;
				break;
			}
		}

		if (bBuildingHit)
		{
			if (GetTeamNum() != B.GetTeamNum() || bDamageAll)
				B.TakeRadiusDamage(InstigatorController, Damage*Vet_DamageModifier[VRank], DmgRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, VectorHurtOrigin, true, self);
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
            P.TakeRadiusDamage(InstigatorController, Damage*Vet_DamageModifier[VRank], DmgRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, VectorHurtOrigin, bFullDamage, self);
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
   local float ExplosionShakeScale;

   foreach LocalPlayerControllers(class'UTPlayerController', UTPC)
   {
      Dist = VSizeSq(Location - UTPC.ViewTarget.Location);

      if (Dist < Square(OuterExplosionShakeRadius))
      {
         if (ExplosionShake != None)
         {
            ExplosionShakeScale = 1.5;
            if (Dist > Square(InnerExplosionShakeRadius))
            {
               ExplosionShakeScale -= (Sqrt(Dist) - InnerExplosionShakeRadius) / (OuterExplosionShakeRadius - InnerExplosionShakeRadius);
            }
            UTPC.PlayCameraAnim(ExplosionShake, ExplosionShakeScale);
         }
      }
   }
}

function string GetSpotMarkerName()
{
	local Actor TempActor;
	local Rx_GRI WGRI; 
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	
	WGRI = Rx_GRI(WorldInfo.GRI);
	
	if (WGRI == none) return "";
	
	foreach WGRI.SpottingArray(TempActor)
	{
		DistToSpot = VSizeSq(TempActor.location - Location);
		if (NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist)
		{
			NearestSpotDist = DistToSpot;
			NearestSpotMarker = RxIfc_SpotMarker(TempActor);
		}
	}

	if (NearestSpotMarker == None)
		return "";
	
	return NearestSpotMarker.GetSpotName();
}

simulated function string GetTooltip(Rx_Controller PC)
{
    local string bindKey;
    local Rx_Weapon_Deployable Wep;

    bindKey = Caps(UDKPlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand("GBA_PickupDeployedActor"));

    if (!CanPickupClient()) return "";

    Wep = Rx_Weapon_Deployable(PC.Pawn.FindInventoryType(WeaponClass));

    if (Wep == None) return "";

    if (Wep.AmmoCount >= Wep.MaxAmmoCount)
        return "Press <font color='#ff0000' size='20'>[ " $ bindKey $ " ]</font> to remove <font color='#ff0000' size='20'>" $ DeployableName $ "</font>.";

    return "Press <font color='#ff0000' size='20'>[ " $ bindKey $ " ]</font> to pick <font color='#ff0000' size='20'>" $ DeployableName $ "</font> up.";
}

simulated function bool IsTouchingOnly()
{
    return false;
}

simulated function bool IsBasicOnly()
{
    return false;
}

/*-------------------------------------------*/
/*BEGIN TARGET INTERFACE [RxIfc_Targetable]*/
/*------------------------------------------*/
//Health
simulated function int GetTargetHealth() {return HP;} //Return the current health of this target
simulated function int GetTargetHealthMax() {return MaxHP;} //Return the current health of this target

//Armour 
simulated function int GetTargetArmour() {return 0;} // Get the current Armour of the target
simulated function int GetTargetArmourMax() {return 0;} // Get the current Armour of the target 

// Veterancy

simulated function int GetVRank() {return 0;}

/*Get Health/Armour Percents*/
simulated function float GetTargetHealthPct() {return float(HP) / max(1,float(MaxHP));}
simulated function float GetTargetArmourPct() {return 0;}
simulated function float GetTargetMaxHealthPct() {return 1.0f;} //Everything together (Basically Health and armour)

/*Get what we're actually looking at*/
simulated function Actor GetActualTarget() {return self;} //Should return 'self' most of the time, save for things that should return something else (like building internals should return the actual building)

/*Booleans*/
simulated function bool GetUseBuildingArmour(){return false;} //Stupid legacy function to determine if we use building armour when drawing. 
simulated function bool GetShouldShowHealth(){return true;} //If we need to draw health on this 
simulated function bool AlwaysTargetable() {return true;} //Targetable no matter what range they're at
simulated function bool GetIsInteractable(PlayerController PC) {return false;} //Are we ever interactable?
simulated function bool GetCurrentlyInteractable(PlayerController RxPC) {return false;} //Are we interactable right now? 
simulated function bool GetIsValidLocalTarget(Controller PC) {return true;} //Are we a valid target for our local playercontroller?  (Buildings are always valid to look at (maybe stealthed buildings aren't?))
simulated function bool HasDestroyedState() {return false;} //Do we have a destroyed state where we won't have health, but can't come back? (Buildings in particular have this)
simulated function bool UseDefaultBBox() {return false;} //We're big AF so don't use our bounding box 
simulated function bool IsStickyTarget() {return false;} //Does our target box 'stick' even after we're untargeted for awhile 
simulated function bool HasVeterancy() {return false;}

//Spotting
simulated function bool IsSpottable() {return true;}
simulated function bool IsCommandSpottable() {return false;} 

simulated function bool IsSpyTarget(){return false;} //Do we use spy mechanics? IE: our bounding box will show up friendly to the enemy [.... There are no spy Refineries...... Or are there?]

/* Text related */

simulated function string GetTargetName() {return DeployableName;} //Get our targeted name 
simulated function string GetInteractText(Controller C, string BindKey) {return "";} //Get the text for our interaction 
simulated function string GetTargetedDescription(PlayerController PlayerPerspectiv) {return "";} //Get any special description we might have when targeted 

//Actions
simulated function SetTargeted(bool bTargeted) ; //Function to say what to do when you're targeted client-side 

/*----------------------------------------*/
/*END TARGET INTERFACE [RxIfc_Targetable]*/
/*---------------------------------------*/

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
      BlockNonZeroExtent   = false //true  Set to true after landing  
      BlockZeroExtent      = true
      CollideActors        = true
      BlockActors          = true
      BlockRigidBody       = false
	  CanBlockCamera		= false 
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
   PlayExplosionSound = false;
   DisarmedEffect=ParticleSystem'RX_FX_Munitions.Explosions.P_EquipmentDisarmed'
   DisarmedSound=SoundCue'rx_wp_proxyc4.Sounds.SC_Mine_Disarm' //SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Fire'

   bWorldGeometry          = true //true  //Set to false to not block the camera 
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
   
   bCanStepUpOn = false 
   
   VRank = 0
   
   Vet_DamageModifier(0) = 1 
    Vet_DamageModifier(1) = 1.10 
	 Vet_DamageModifier(2) = 1.25
	  Vet_DamageModifier(3) = 1.50
}