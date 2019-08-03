class Rx_SupportVehicle_A10 extends Rx_SupportVehicle_Air; 

var	ParticleSystemComponent		PS_Engine_R, PS_Wing_R; 
var	ParticleSystemComponent		PS_Engine_L, PS_Wing_L; 

var name						Name_Engine_R_Socket, Name_Engine_L_Socket, Name_Wing_L_Socket, Name_Wing_R_Socket;

var array<vector>						NavCourse; //Use to set waypoints (in relation to the parent beacon)
var int									CurrentNav;
var float 								HomingSensitivity; //How often to add acceleration toward our current target vector
var	float								CurrentSpeed;
var float								NavPointProximity; //How far away from a Nav point before we start accelerating toward the next one?
var float								PayloadDropDelay; //Time after getting in range of final target vector to explode
var bool								bTargetReached;
var bool								bNavCourseInitialized; 
var float TestSensitivity;
var	byte								StartSoundWaypoint; //Used to hold what waypoint number to begin our audio component since the A10's sound is 'unique'

struct LocationFinder
{
	var float Distance; //How far away is this point? 
	var float Altitude; //How high is this point
};

var array<LocationFinder>				Navs; //Actual numbers to use when setting up the nav course

var repnotify bool						bReachedSoundWaypoint; //Tell clients to start playing the fly over sound 

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	Mesh.WakeRigidBody();
	
	InitParticles(); 
	
}



replication
{
		if(bNetDirty)
			bReachedSoundWaypoint; 
}

simulated function ReplicatedEvent(name VarName)
{
	if(VarName == 'bReachedSoundWaypoint')
	{
		if(bReachedSoundWaypoint) MyAudioComponent.Play(); 
	}
	else
	super.ReplicatedEvent(VarName); 
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
	
	if(ROLE == ROLE_Authority)
	{
		if(VSize(NavCourse[CurrentNav] - location) <= NavPointProximity && bNavCourseInitialized && !bTargetReached) GotoNextNav();
	}		
	super.Tick(DeltaTime);
}

function UpdateTrajectory()
{
	Acceleration = 16 * AccelRate * Normal(NavCourse[CurrentNav] - Location); 	
}

function GotoNextNav()
{
	
	if(CurrentNav < NavCourse.Length-2 && !bTargetReached) //On second to last waypoint, begin dropping payload 
	
	{
		if(CurrentNav == StartSoundWaypoint) 
		{
			MyAudioComponent.Play();
			bReachedSoundWaypoint = true;
		}
		
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
	
	Acceleration = AirSpeed * AccelRate * Normal(NavCourse[CurrentNav+1] - Location);	
	CurrentNav++  ;
	
	DropPayload(); 
	
	SetTimer(1.0, false, 'PullOut'); 
	
	//SetTimer(PayloadDropDelay, false, 'DropPayload'); 
}

simulated function InitParticles()
{

	Mesh.AttachComponentToSocket(PS_Engine_L, Name_Engine_L_Socket)  ;
	Mesh.AttachComponentToSocket(PS_Engine_R, Name_Engine_R_Socket)  ;
	Mesh.AttachComponentToSocket(PS_Wing_L, Name_Wing_L_Socket)  ;
	Mesh.AttachComponentToSocket(PS_Wing_R, Name_Wing_R_Socket)  ;

	//Also initialize sound component
	AttachSoundComponent(); 
}

event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	if(Rx_Building(Wall) != none && !bExploded) 
	{
		Wall.TakeDamage(ExplosionDamage, InstigatorController, HitNormal, HitNormal, DamageTypeClass); 
		Explosion(InstigatorController);	
	}
	
	Explosion(); 
	
	super.HitWall(HitNormal, Wall, WallComp);
}


simulated function AttachSoundComponent()
{
	Mesh.AttachComponentToSocket(MyAudioComponent, RootSocketName);
}


//Simple GTFO after dropping your payload
simulated function PullOut()
{
	bIsInvincible = true; 
	AccelRate	= default.AccelRate*5; 
	Airspeed	= default.AirSpeed*20000; 
	
	SetTimer(5.0, false, 'RewardCP');
	SetTimer(9.0, false, 'ToDestroy'); 
}

simulated function ToDestroy()
{
	MyAudioComponent.Stop();
	if(Payload != none) 
		Payload.Destroy(); 
	super.ToDestroy();
}

simulated function DropPayload()
{

	//Mesh.GetSocketWorldLocationAndRotation(PayLoadSocketName, SocketLocation, SocketRotation);
	
	if(Payload == none || !bDropPayload) return; 

	
	if (WorldInfo.NetMode != NM_Client)
	{

		//Tell the Payload itself to start acting like it's got some damn sense
		//`log(location @ "----" @ NavCourse[2] @ "-------" @ VSize(location-NavCourse[2]));
		Payload.SetBase(none); 
		Payload.SetHardAttach(Payload.default.bHardAttach); 
		Payload.bBlockActors = true; 
		//Payload.DropToGround(); //Get the hell off of me 
		Payload.SetLocation(Payload.location); //Replicate final server location before dropping
		Payload.Velocity = Velocity; 
		if(RxIfc_Airlift(Payload) != none) RxIfc_Airlift(Payload).DetachFromVehicle(); //Actually built for this 
		else
		PayLoad.SetPhysics(PHYS_Falling); //Else just drop it.. .it can figure itself out
		
		//Payload.SetCollision(true,true);
	}
	else
	if(RxIfc_Airlift(Payload) != none) RxIfc_Airlift(Payload).DetachFromVehicle();
	
	/**if (WorldInfo.NetMode != NM_DedicatedServer)
		SetTimer(4.0,false,'MyAudioComponentFadeOut');*/
}


function CallForceDetach(bool bKillVehicle, Controller EventInstigator)
{
	super.CallForceDetach(bKillVehicle, EventInstigator);
	DropPayload(); 
}


simulated function Explosion(optional Controller EventInstigator)
{
	super.Explosion(); 
	
	if(ROLE == ROLE_Authority && Payload != none && Payload.Base == self) 
	{
		Payload.Destroy();  	
	}
}

simulated function SimulatedCleanup()
{
	MyAudioComponent.Stop();  
}

DefaultProperties
{
	RootSocketName = VH_Death
	PayLoadSocketName=BombSocket_1
	bDropPayload = true  //By default always drop payloads

	/**Missile specific*/ 
	NavPointProximity = 2200 //How far away from a Nav point before we start accelerating toward the next one?

	//LocationTarget = LocationStart + vector(Rotation) * Distance;
	PayloadDropDelay = 0.1
	HomingSensitivity = 0.25 //Update our heading every quarter of a second or so

	Navs(0) = (Distance = 20000, Altitude = 15000) //Teleports to this one initially, then follows the rest of the path
	Navs(1) = (Distance = 10000, Altitude = 8000)
	Navs(2) = (Distance = 3000, Altitude = 5000)
	Navs(3) = (Distance = -50000, Altitude = 50000)

	StartSoundWaypoint = 1
	/****************************/


	/**Rx_SupportVehicle_Air*/

	AntiAirAimAheadMod	=	250.0
	AntiAirAccelMod		=	200.0

	/************************/
	
	/*Rx_SupportVehicle Effectiveness vars*/
	//These are mostly decided by the payloads themselves
	ER_BuildingDamage = 0
	ER_VehicleDamageAddend = 10
	ER_PawnDamageAddend = 10 
	
	/********************************/
	/**Rx_BasicPawn characteristics**/
	/********************************/

	Health = 150
	HealthMax = 150
	bIsInvincible = false //By default these should not be what is being aimed at

	ArmorType = ARM_Light

	Physics = PHYS_Flying
	DamageSmokeThreshold=0.25
	 
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'
	ExplosionEffect=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Air'

	EntrySound = none

	bHidden = true 

	bExplodes = true
	ExplosionDamage=100
	ExplosionRadius=500
	bDamageAll=true 
	DamageMomentum=1000
	bExplodeOnImpact = true; 

	DamageTypeClass=class'Rx_DmgType_CruiseMissile'

	ActorName = "A10" 
	bShowHealth=true
	 
	 
	 bAttractAA = false
	 /**************************************/
	 
	 /*****Pawn Characteristics*******/
		AirSpeed=+10000.0
		GroundSpeed=+10000.0
		AccelRate = +700.0 
		
		bForceMaxAccel = false 
		
		bSimulateGravity = false; 
		bSimGravityDisabled = true
		
		Mass =+5000.00; //Try not to get too knocked around by SAMs
	/***********************/


	Begin Object Name=WSkeletalMesh	
			SkeletalMesh=SkeletalMesh'RX_VH_A-10.Mesh.SK_VH_A-10_Gameplay'
			AnimTreeTemplate=AnimTree'RX_VH_A-10.Anim.AT_VH_A-10_Gameplay'
			PhysicsAsset=PhysicsAsset'RX_VH_A-10.Mesh.SK_VH_A-10_Gameplay_Physics'
			AlwaysLoadOnServer=true
			CastShadow=true
			AlwaysLoadOnClient=true
			BlockNonZeroExtent   = true  
			BlockZeroExtent      = true
			BlockActors=false
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
		
		
		/*WING and Engine Particle Systems*/
		
		Name_Engine_L_Socket =Jet_L
		Name_Engine_R_Socket =Jet_R 
		
		Name_Wing_L_Socket	=WingTip_L
		Name_Wing_R_Socket	=WingTip_R
		
		//Right Engine 
		Begin Object Class=ParticleSystemComponent Name=EngineTrail_R
		Template=ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large'
			bAutoActivate=true
		End Object
		PS_Engine_R = EngineTrail_R
		Components.Add(EngineTrail_R)
		
		//Left Engine 
		Begin Object Class=ParticleSystemComponent Name=EngineTrail_L
		Template=ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large'
			bAutoActivate=true
		End Object
		PS_Engine_L = EngineTrail_L
		Components.Add(EngineTrail_L)
		
		//Right Wing Tip  
		Begin Object Class=ParticleSystemComponent Name=WingTrail_R
		Template=ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large'
			bAutoActivate=true
		End Object
		PS_Wing_R = WingTrail_R
		Components.Add(WingTrail_R)
		
		//Left Wing Tip 
		Begin Object Class=ParticleSystemComponent Name=WingTrail_L
		Template=ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large'
			bAutoActivate=true
		End Object
		PS_Wing_L = WingTrail_L
		Components.Add(WingTrail_L)
		
		/***********************************/
		
		//ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large'
		//ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large'
		
		//Audio
		   Begin Object Name=VehicleAudioComponent
			SoundCue=SoundCue'RX_VH_A-10.Sounds.SC_A-10_FlyOver'
			bStopWhenOwnerDestroyed = 	true 
			bAutoDestroy			=	true 
		End Object
		MyAudioComponent=VehicleAudioComponent
		Components.Add(VehicleAudioComponent);		
		
		
}