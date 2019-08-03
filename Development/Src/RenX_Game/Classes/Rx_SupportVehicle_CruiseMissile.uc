class Rx_SupportVehicle_CruiseMissile extends Rx_SupportVehicle_Air; 

var	ParticleSystemComponent		TrailEffects; 

var array<vector>						NavCourse; //Use to set waypoints (in relation to the parent beacon)
var int									CurrentNav;
var float 								HomingSensitivity; //How often to add acceleration toward our current target vector
var	float								CurrentSpeed;
var float								NavPointProximity; //How far away from a Nav point before we start accelerating toward the next one?
var float								FuseTime; //Time after getting in range of final target vector to explode
var bool								bTargetReached;
var bool								bNavCourseInitialized; 

var float TestSensitivity, TestVar;


struct LocationFinder
{
	var float Distance; //How far away is this point? 
	var float Altitude; //How high is this point
};

var array<LocationFinder>				Navs; //Actual numbers to use when setting up the nav course



simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	Mesh.WakeRigidBody();
	
	InitParticles(); 
	
}

function Initialize(Controller C, byte TI, vector V, Rx_CommanderSupportBeacon P, optional class<Actor> PayloadActorClass, optional int MaxRecoverableCP)
{
	local rotator MirrorRotator;
	super.Initialize(C,TI,V,P,PayloadActorClass, MaxRecoverableCP);
	//LocationTarget = LocationStart + vector(Rotation) * Distance;
	
	MirrorRotator = P.rotation; 
	
	MirrorRotator.Yaw+=32768 ;
	
	InitNavCourse(V, MirrorRotator); 
	
	SetLocation(NavCourse[0]); 
	
	SetHidden(false); 
}

simulated function Tick(float DeltaTime)
{
	SetRotation(rotator(Velocity));
	super.Tick(DeltaTime);
	
	if(WorldInfo.NetMode == NM_Client) return; //Becomes authoritative on death O.o ?  EDIT:TearOff is a thing
	
	if(ROLE == ROLE_Authority)
	{
		if(VSize(NavCourse[CurrentNav] - location) <= NavPointProximity && bNavCourseInitialized && !bTargetReached) GotoNextNav();
	}
	
}

function UpdateTrajectory()
{
	Acceleration = 16 * AccelRate * Normal(NavCourse[CurrentNav] - Location); 	
}

function GotoNextNav()
{
	
	
	if(CurrentNav < NavCourse.Length-1 && !bTargetReached) 
	
	{
		Acceleration = AirSpeed * AccelRate * Normal(NavCourse[CurrentNav+1] - Location);	
		CurrentNav++  ;
	}
	else //we're at the end 
	if(!bTargetReached) ReachedTarget(); 
}

function InitNavCourse(vector OriginVector, rotator OriginRotation) //find our ParentBeacon rotation and such and plot our course
{
	local vector WorkingVector; 
	local int	i; 
	
	for(i=0;i<Navs.Length;i++)
	{
		WorkingVector = OriginVector + vector(OriginRotation) * Navs[i].Distance;
		
		WorkingVector.Z+=Navs[i].Altitude;
		
		NavCourse.AddItem(WorkingVector);
	}
	bNavCourseInitialized = true; 
	SetTimer(HomingSensitivity, true, 'UpdateTrajectory'); 
} 

function ReachedTarget() //Provide functions on what to do once in range of the target. By design cruise missiles explode over the target for max splash damage and calamity
{
	bTargetReached = true; 
	
	SetTimer(FuseTime, false, 'AirBurst'); 
}

simulated function InitParticles()
{

	Mesh.AttachComponentToSocket(TrailEffects, 'JetSocket')  ;
	//Also initialize sound component
	AttachSoundComponent(); 
	MyAudioComponent.Play();
}


event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	if(!bExploded) 
	{
		Wall.TakeDamage(ExplosionDamage, InstigatorController, HitNormal, HitNormal, DamageTypeClass);
		
		if(Rx_Building(Wall) != none && Rx_Building(Wall).GetTeamNum() != GetTeamNum()) 
			AddEffectiveness(Wall);
		
		Explosion(InstigatorController);
	}
	super.HitWall(HitNormal, Wall, WallComp);	
}

simulated function AttachSoundComponent()
{
	Mesh.AttachComponentToSocket(MyAudioComponent, RootSocketName);
}

simulated function AirBurst()
{
	MyAudioComponent.Stop(); 

	Explosion(InstigatorController);	
}

simulated function Explosion(optional Controller EventInstigator)
{
	MyAudioComponent.Stop(); //if you haven't shutup already 
	super.Explosion(EventInstigator);
	RewardCP();
}

simulated function SimulatedCleanup()
{
	MyAudioComponent.Stop(); 
}

simulated function SpawnExplosionEmitter(vector SpawnLocation, rotator SpawnRotation)
{
	local ParticleSystemComponent MyExplosionEmitter;
	local vector normthing, endL;  
	local Actor TraceActor;
	local vector Direction; 
	local rotator PitchCorrection; 
	
	//rotate the explosion 90 degrees
	PitchCorrection.Pitch = 16384; 
	
	//Inject from UTProjectile to find the direction the explosion should face
	
	TraceActor = Trace(endL, normthing, location + vector(rotation) * ExplosionRadius, location, true);
	  
	Direction = normal(Velocity - 2.0 * normthing * (Velocity dot normthing)) * Vect(1,1,0);
	  
	  if(TraceActor != none)
	  {
			MyExplosionEmitter = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, endL, rotator(Direction)+PitchCorrection);
			MyExplosionEmitter.SetVectorParameter('Velocity',Direction);
			MyExplosionEmitter.SetVectorParameter('HitNormal',normthing);
	  }
		else
			MyExplosionEmitter = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, SpawnLocation, SpawnRotation);
	
		SetExplosionEffectParams(MyExplosionEmitter);
}  
/*Radar marker interface */
//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int GetRadarIconType()
{
	return 0; //Infantry
} 

DefaultProperties
{

	/**Missile specific*/ 
	NavPointProximity = 1250 //How far away from a Nav point before we start accelerating toward the next one?

	//LocationTarget = LocationStart + vector(Rotation) * Distance;
	FuseTime = 0.25
	HomingSensitivity = 0.25 //Update our heading ever quarter of a second or so

	Navs(0) = (Distance = 20000, Altitude = 15000) //Teleports to this one initially, then follows the rest of the path
	Navs(1) = (Distance = 10000, Altitude = 10000)
	Navs(2) = (Distance = 7000, Altitude = 7000)
	Navs(3) = (Distance = 0, Altitude = 0)
	/****************************/


	/**Rx_SupportVehicle_Air*/

	AntiAirAimAheadMod	=	250.0
	AntiAirAccelMod		=	200.0
	
	bBroadcastDeath = true; 
	
	bCollideWorld = true 

	/************************/

	/********************************/
	/**Rx_BasicPawn characteristics**/
	/********************************/

	Health = 90 //50
	HealthMax = 90 //50

	ArmorType = ARM_HEAVY

	RootSocketName = JetSocket

	Physics = PHYS_Flying
	DamageSmokeThreshold=0.25
	 
	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_CruiseMissile' //SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'
	ExplosionEffect=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt'
	ExplosionScale = 2.0f
	InnerExplosionShakeRadius=2000.0
	OuterExplosionShakeRadius=5000.0
	ExplosionShake=CameraAnim'RX_FX_Envy.Camera.CA_Shake_Nuke'
	ExplosionShakeScale=1.5
	
	EntrySound = SoundCue'RX_SoundEffects.Missiles.SC_CruiseMissileFire'

	bHidden = true 

	bExplodes = true
	ExplosionDamage=2000
	ExplosionRadius=2000
	bDamageAll=true 
	DamageMomentum=100000
	bExplodeOnImpact = true; 
	
	DamageTypeClass=class'Rx_DmgType_CruiseMissile'

	ActorName = "Cruise Missile" 
	bShowHealth=true
	 
	 /**************************************/
	 
	 /*****Pawn Characteristics*******/
		AirSpeed=+6000.0
		GroundSpeed=+6000.0
		AccelRate = +400.0 
		Mass = +1500.0
	/***********************/


	Begin Object Name=WSkeletalMesh	
			SkeletalMesh=SkeletalMesh'RX_FX_Munitions.cruisemissile.SK_WP_CruiseMissile'
			AnimSets(0)=AnimSet'RX_FX_Munitions.cruisemissile.AS_WP_CruiseMissile'
			PhysicsAsset=PhysicsAsset'RX_FX_Munitions.cruisemissile.SK_WP_CruiseMissile_Physics'
			AlwaysLoadOnServer=true
			CastShadow=true
			AlwaysLoadOnClient=true
			BlockNonZeroExtent   = true  
			BlockZeroExtent      = true
			BlockActors=true
			CollideActors=true
			bUpdateSkelWhenNotRendered=true
			bCastDynamicShadow=true
			bHasPhysicsAssetInstance=true
			TickGroup=TG_PreAsyncWork
			LightEnvironment = MyLightEnvironment
			RBChannel=RBCC_Vehicle
			RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
			BlockRigidBody=true
			bForceDiscardRootMotion=true
			bUseSingleBodyPhysics=1
			bNotifyRigidBodyCollision=true
			ScriptRigidBodyCollisionThreshold=100.0
		End Object
		Mesh=WSkeletalMesh
		CollisionComponent=WSkeletalMesh
		Components.Add(WSkeletalMesh)
		
		Begin Object Class=ParticleSystemComponent Name=Trail
		Template=ParticleSystem'RX_FX_Munitions.cruisemissile.P_CruiseMissile_SmokeTrail'
			bAutoActivate=true
		End Object
		TrailEffects = Trail
		Components.Add(Trail)
		
		//Audio
		   Begin Object Name=VehicleAudioComponent
			bStopWhenOwnerDestroyed = true
			SoundCue=SoundCue'RX_SoundEffects.Missiles.SC_CruiseMissile_Amb'
		End Object
		MyAudioComponent=VehicleAudioComponent
		Components.Add(VehicleAudioComponent);		
		
		bForceMaxAccel = false 
		
		bSimulateGravity = false; 
		bSimGravityDisabled = true
		
		MaxEffectivenessCPRecoup = 400
		ER_BuildingDamage = 25
		ER_VehicleDamageAddend = 10
		ER_PawnDamageAddend = 5
		
}