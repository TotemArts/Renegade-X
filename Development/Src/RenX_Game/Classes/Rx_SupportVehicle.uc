class Rx_SupportVehicle extends Rx_BasicPawn //Rx_DestroyableObstaclePlus ; 
implements(RxIfC_RadarMarker);

/* Base Clase for all Support Power Vehicles (including Missiles)*/

var	Rx_CommanderSupportBeacon			ParentBeacon;  //Who's yo' daddy?
var	vector								TargetVector; //Where am I flying to, or near?

var bool								bUseInitializationVector; //If true, teleport to a location after you initialize (E.G, to the beacon itself after everything's attached and such)
var	vector								RelativeInitVector; //After spawning, should I teleport somewhere? [In relation to the beacon that spawned me] 
var float								TimeToMoveToRelativeVector; //Time until we teleport to our relative vector after initializing

var Actor								Payload; 
var name								PayloadSocketName; 
var	name								RootSocketName;
var Controller							InstigatorController;

/*Visual and Audio Feedback*/

//var SkeletalMeshComponent 				Mesh;
var const AudioComponent 				MyAudioComponent; 
var SoundCue							EntrySound; 
var DynamicLightEnvironmentComponent    LightEnvironment;

var repnotify bool						bAttachedPayload; 
var bool								bDropPayload; //Determines if this payload is actually dropped when DropPayload is called
var bool								bIsInvincible; //Whether to take damage or not

var bool								bBroadcastDeath; 
var	string								BroadcastDeathStr; 

var() Texture MinimapIconTexture;

//Effectiveness Calculations 
var float								EffectivenessRating; //How much of an impact did this make? 
var int									MaxEffectivenessCPRecoup; //Maximum CP achievable with max effectiveness
var int									ER_VehicleDamageAddend, ER_PawnDamageAddend, ER_BuildingDamage; //Percentage added to effectiveness rating for damaging certain objects (Or other actions)

replication 
{
	if(bNetDirty)
		bAttachedPayload, bDropPayload; 
}


simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'bAttachedPayload')
	{
		if(bAttachedPayload)
		{
			ClientAttachPayload();	
		}
	}
	else
		super.ReplicatedEvent(VarName);
}

function Initialize(Controller C, byte TI, vector V, Rx_CommanderSupportBeacon P, optional class<Actor> PayloadActorClass, optional int MaxRecoverableCP)
{
	local vector 	SocketLocation;
	local rotator	SocketRotation; 

		ParentBeacon = P; 
		TargetVector = V;
		TeamIndex = TI;
		InstigatorController=C;
		
		if(PayloadActorClass != none) 
		{
			Mesh.GetSocketWorldLocationAndRotation(PayloadSocketName, SocketLocation, SocketRotation);
			Payload = Spawn(PayloadActorClass,,, SocketLocation,SocketRotation,,true);
			Payload.SetHidden(true); 
			AttachPayload(Payload);
			bAttachedPayload=true; 
		}
		SetCollision(true,true);
		
		if(bUseInitializationVector) 
			SetTimer(TimeToMoveToRelativeVector, false, 'MoveToRelativeInitVector') ; 
		
		if(EntrySound != none) PlaySound(EntrySound); 
		
		if(MaxRecoverableCP > 0) MaxEffectivenessCPRecoup = MaxRecoverableCP; 

}

function AttachPayload(Actor PayloadActor)
{
	PayloadActor.SetBase(none); 
	PayloadActor.SetPhysics(PHYS_None); 
	PayloadActor.SetHardAttach(true); 
	PayloadActor.SetHidden(false); 
	PayloadActor.SetBase(self,,Mesh,PayloadSocketName); 
	if(RxIfc_Airlift(Payload) != none) RxIfc_Airlift(Payload).OnAttachToVehicle() ;
}

simulated function ClientAttachPayload() //Can vary depending on just how payloads are attached from client-side. E.G, Chinooks only look for things with certain interfaces. 
{
	//loginternal("Attach Payload [Client]");
}

simulated function Explosion(optional Controller EventInstigator)
{
   local Pawn P;  
   
   local vector SocketLocation;
   local rotator SocketRotation;
   local bool	 bUseSocket;  
  
      if(bExploded) 
		  return; //Don't double dip on explosions
	  
   if(RootSocketName != '') 
   {
		Mesh.GetSocketWorldLocationAndRotation(RootSocketName, SocketLocation, SocketRotation);
		bUseSocket = true; 
   }

  
	bExploded = true; 
	if(WorldInfo.NetMode != NM_DedicatedServer) //This is literally the most worthless line ever for network play
		PlayExplosionEffect();
		
	if(bExplodes && !bDamageThroughWalls)
	{
		foreach VisibleCollidingActors(class'Pawn', P, ExplosionRadius, Location, false)
		{
		   if(!bUseSocket) 
		   {
			   P.TakeRadiusDamage(EventInstigator, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, bDoFullDamage, self);
			   
			   if(P.GetTeamNum() != GetTeamNum()) 
				   AddEffectiveness(P);
		   }
		   else
		   {
			   P.TakeRadiusDamage(EventInstigator, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, SocketLocation, bDoFullDamage, self);
			     
				 if(P.GetTeamNum() != GetTeamNum()) 
				   AddEffectiveness(P);
		   }
		}
	} 
	else if(bExplodes && bDamageThroughWalls)
	{
	  foreach CollidingActors(class'Pawn', P, ExplosionRadius, Location, false)
		{
           if(!bUseSocket)
		   {
			   P.TakeRadiusDamage(EventInstigator, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, bDoFullDamage, self);
			   AddEffectiveness(P);
		   }			  
		   else
		   {
				P.TakeRadiusDamage(EventInstigator, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, SocketLocation, bDoFullDamage, self);
				AddEffectiveness(P);
		   }
		}
	}
   
   
	SetHidden(true); 
	
	if(Health > 0) 
		Health = 0; //So that everything knows we're irrelevant now
		
   SetTimer(0.2f, false, 'ToDestroy');
}

simulated function PlayExplosionEffect()
{

   local vector SocketLocation;
   local rotator SocketRotation;
   local bool	 bUseSocket; 
   
   if(RootSocketName != '') 
   {
		Mesh.GetSocketWorldLocationAndRotation(RootSocketName, SocketLocation, SocketRotation);
		bUseSocket = true; 
   }

   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
	   if(!bUseSocket)
	   {
		  if (ExplosionSound != none)
		  {
			 PlaySound(ExplosionSound, true,,false, location);
		  }
		  
		  SpawnExplosionEmitter(Location, Rotation);
		}
		else
		 {
		  if (ExplosionSound != none)
		  {
			 PlaySound(ExplosionSound, true,,false, SocketLocation);
		  }
		  
		  SpawnExplosionEmitter(SocketLocation, SocketRotation);
		  PlayCameraShakeAnim();
		}
   }
}


/**simulated function SpawnExplosionEmitter(vector SpawnLocation, rotator SpawnRotation)
{
   WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, SpawnRotation);
}  */


simulated function byte ScriptGetTeamNum()
{
	return TeamIndex;
}

simulated function MoveToRelativeInitVector()
{
	SetLocation(TargetVector+RelativeInitVector);	// Make sure the beacon lingertime is set high enough that it's still around for this!Otherwise it will obviously fail because the beacon doesn't exist
}

//Called from Payload to forcibly detach itself for whatever reason. Over ride in sub classes 
function CallForceDetach(bool bKillVehicle, Controller EventInstigator)
{
	if(bKillVehicle) 
	{
		InstaKill(EventInstigator); 
	}
	
}

function SetbDropPayload(bool Drop)
{
	bDropPayload = Drop; 
}

function SetInvincible(bool Invincible)
{
	bIsInvincible = Invincible;
}

simulated event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(bIsInvincible) 
		return; //Take no damage
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	
	
}

//Called whenever the Pawn takes fatal damage (Not just explodes for no reason)
simulated function BasicPawnKilled(string KillerName) 
{ 
	if(ROLE == ROLE_Authority && bBroadcastDeath)
	{
		if(Rx_Game(WorldInfo.Game) == none) 
			return; 
		
		Rx_Game(WorldInfo.Game).CTextBroadCast(GetTeamNum(), "-Friendly" @ ActorName @ "Intercepted by" @ KillerName $ " -", 'Red') ; 
		
		Rx_Game(WorldInfo.Game).CTextBroadCast(GetAntiTeamByte(GetTeamNum()), "-Enemy" @ ActorName @ "Intercepted by" @ KillerName $ " -", 'Green') ; 
		
	}
}

function AddEffectiveness(Actor AffectedActor, optional int Amount = 0){
	if(Amount > 0) {
		EffectivenessRating += Amount;
	}
	else
	{
		if(Rx_Pawn(AffectedActor) != none) 
			EffectivenessRating += ER_PawnDamageAddend;
		else
		if(Rx_Vehicle(AffectedActor) != none) 
			EffectivenessRating += ER_VehicleDamageAddend;
		else
		if(Rx_Building(AffectedActor) != none) 
			EffectivenessRating += ER_VehicleDamageAddend;
	}
	
	EffectivenessRating = min(EffectivenessRating,100); 
}

function RewardCP()
{
	local Rx_Game OurGame; 
	
	if(Rx_Game(WorldInfo.Game) != none) 
		OurGame = Rx_Game(WorldInfo.Game);
	
	if(EffectivenessRating > 0)
		Rx_TeamInfo(OurGame.Teams[GetTeamNum()]).AddCommandPoints((EffectivenessRating/100.0)*MaxEffectivenessCPRecoup, "Support Power Effectiveness&" $ (EffectivenessRating/100.0)*MaxEffectivenessCPRecoup $ "&") ;
}

/******************
*RxIfc_RadarMarker*
*******************/

//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int GetRadarIconType()
{
	return 1; //Vehicle
} 

//Support vehicles are always visible
simulated function bool ForceVisible()
{
	return true;  
}

simulated function vector GetRadarActorLocation() 
{
	return location; 
} 
simulated function rotator GetRadarActorRotation()
{
	return rotation; 
}
//Always visible
simulated function byte GetRadarVisibility()
{
	return 2; 
} 
simulated function Texture GetMinimapIconTexture()
{
	return MinimapIconTexture; 
}

simulated function bool GetUseSquadMarker(byte TeamByte, byte SquadByte)
{
	return false; 
}

/******************
*END RadarMarker***
*******************/

DefaultProperties
{

	bDrawLocation = true //Target these for friendly and enemy 

	/*Health/Destruction Variables*/
		
	Health=700
	HealthMax=700
	bIsInvincible = false

	bExplodes = true
	ExplosionDamage=0
	ExplosionRadius=1
	bDamageAll=true 
	DamageMomentum=10000
	bTakeRadiusDamage = true; 

	DamageTypeClass=class'Rx_DmgType_GrenadeLauncher'
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'
	bShowHealth=true

	/*Location initalization variables*/
	bUseInitializationVector 	= false
	RelativeInitVector			= (X=0,Y=0,Z=0)

	//Name
	ActorName = "Chinook" 


	/*Effects*/
	ExplosionShake = CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius = 200.0
	OuterExplosionShakeRadius = 600.0
	ExplosionEffect = ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Air'


	/*Default Visual stuff*/


	//Default Lights 
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
			bEnabled            = True
			bDynamic            = True
			bSynthesizeSHLight  = True
			TickGroup           = TG_DuringAsyncWork
		End Object
		Components.Add(MyLightEnvironment)
		LightEnvironment = MyLightEnvironment
		
		/** Simulated proxy, so players can execute simulated functions to
		 *  spawn visual and sound effects. */
		RemoteRole=ROLE_SimulatedProxy
		bAlwaysRelevant = true; //Their location needs to be known
		
		//Default to the dropoff Chinook for visuals
		//Begin Object Class=SkeletalMeshComponent Name=WSkeletalMesh	
		Begin Object Class=SkeletalMeshComponent Name=WSkeletalMesh	
			SkeletalMesh=SkeletalMesh'RX_VH_Chinook.Mesh.SK_VH_Chinook'
			AlwaysLoadOnServer=true
			CastShadow=true
			AlwaysLoadOnClient=true
			BlockActors=true
			CollideActors=true
			bUpdateSkelWhenNotRendered=true
			bCastDynamicShadow=true
			LightEnvironment = MyLightEnvironment
		End Object
		Mesh=WSkeletalMesh
		Components.Add(WSkeletalMesh)
		
		 Begin Object Class=AudioComponent Name=VehicleAudioComponent
			bStopWhenOwnerDestroyed = true
			SoundCue=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Idle'
		End Object
		MyAudioComponent=VehicleAudioComponent
		Components.Add(VehicleAudioComponent);	
		
		bCollideActors = true
		bCollideWorld = true; 
		bCollideComplex = true;
		
		MinimapIconTexture=Texture2D'RX_VH_A-10.UI.T_MinimapIcon_A10'
		
		EffectivenessRating = 0.0f
		MaxEffectivenessCPRecoup = 0
		ER_BuildingDamage = 0
		ER_VehicleDamageAddend = 0
		ER_PawnDamageAddend = 0
		

}