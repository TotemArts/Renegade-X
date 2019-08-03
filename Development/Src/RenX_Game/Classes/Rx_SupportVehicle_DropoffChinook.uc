class Rx_SupportVehicle_DropOffChinook extends Rx_SupportVehicle_Air ;

/* Base Clase for all Support Power Vehicles (including Missiles)*/
var private repnotify float CurrentTime;
var private bool bGotCurrentTime;
var Rx_vehicle CarriedVehicle;
var Rx_PRI Buyer;
var int VehicleID;

//Temporarily just use a mask to determine location 
var	Rx_SupportVehicle_DropOffChinook_Mask	Mask;

replication
{
	if (bNetDirty)
		CurrentTime;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		CurrentTime = 0.f;
		SetTimer(1.0,false,'InitialSetup');
		bForceNetUpdate = true;
	}
	
	//SetCollision(tru,false);
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'CurrentTime')
	{
		if (!bGotCurrentTime)
		{
			bGotCurrentTime = true;
			SetTimer(1.0,false,'InitialSetup');
			
		}
	}
	else super.ReplicatedEvent(VarName);
}

simulated function InitMyAudioComponent()
{
	//Now that we're supposedly visible, also play attached effects for payload
	if(Payload != none && RxIfc_Airlift(Payload) != none) RxIfc_Airlift(Payload).OnAttachToVehicle();  
	AttachSoundComponent(); 
	MyAudioComponent.Play();
	//MyAudioComponent.FadeIn(14.0, 1.f);
}

simulated event Destroyed()
{
	Mask.ToDestroy(); 
	MyAudioComponent.Stop();
	super.Destroyed();
}


simulated function DropPayload()
{ 
	//Mesh.GetSocketWorldLocationAndRotation(PayLoadSocketName, SocketLocation, SocketRotation);
	
	if(Payload == none) return; 

	
	if (WorldInfo.NetMode != NM_Client)
	{

		//Tell the Payload itself to start acting like it's got some damn sense
				
		Payload.SetBase(none); 
		Payload.SetHardAttach(Payload.default.bHardAttach); 
		Payload.bBlockActors = true; 
		//Payload.DropToGround(); //Get the hell off of me 
		Payload.SetLocation(Payload.location); //Replicate final server location before dropping
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

simulated function HandleDroppedVehicle(Rx_Vehicle DroppedVehicle)
{
		
	//	if(Rx_Vehicle(Payload) != none) Rx_Vehicle(Payload).bPickedUp=false; 
		
		DroppedVehicle.SetPhysics(PHYS_RigidBody); //Normal drop to ground is ineffective here. Go right to being a drivable hunk of machine
		//DroppedVehicle.DropToGround();	
		
		DroppedVehicle.Mesh.WakeRigidBody();
		
		
		//Rx_Game(WorldInfo.Game).GetVehicleManager().InitVehicle(CarriedVehicle,TeamIndex,Buyer,VehicleID,SocketLocation); 	//EDIT Maybe make Commanders able to break the vehicle limit? 
}

simulated function MyAudioComponentFadeOut()
{
	//MyAudioComponent.FadeOut(5.0, 0.7f);
	SetTimer(5.0,false,'MyAudioComponentFadeOutTwo');
}

simulated function MyAudioComponentFadeOutTwo()
{
	MyAudioComponent.VolumeMultiplier = 0.7;
	MyAudioComponent.FadeOut(11.0, 0.f);
}

simulated event OnAnimPlay(AnimNodeSequence SeqNode)
{
	local vector	SocketLocation;
	local rotator	SocketRotation;

	Mesh.GetSocketWorldLocationAndRotation(RootSocketName, SocketLocation, SocketRotation);

	/**Exclusively because this is just a big ass animation and needs a backup system for location detection*/
	if(ROLE == ROLE_Authority)
	{
		Mask = spawn(class'Rx_SupportVehicle_DropOffChinook_Mask',,,SocketLocation,SocketRotation,,true);
		Mask.SetBase(none); 
		Mask.SetPhysics(PHYS_None); 
		Mask.SetHardAttach(true); 
		Mask.SetHidden(false); 
		Mask.SetBase(self,,Mesh,RootSocketName); 
		Mask.TeamIndex = TeamIndex;
	}
	/*******************************************/	
	loginternal("anim started");
}

simulated function LocTest()
{
	if(ROLE == ROLE_Authority)
	{
		//`log("LocTest" @ Payload.location @ Payload.bSkipActorPropertyReplication @ bReplicateMovement @ RemoteRole); 
	
	//Payload.SetLocation(Payload.Location); 
	
	Payload.SetBase(self,,Mesh,PayloadSocketName); 
	
	
	Payload.ForceNetRelevant();
	Payload.bUpdateSimulatedPosition = true;
	Payload.bReplicateMovement = true;
	Payload.bNetDirty = true;   	
	}
	
}

simulated function InitialSetup()
{

	SetTimer(2.0,false,'InitMyAudioComponent');		
	Mesh.PlayAnim('AirDrop',,false,false,CurrentTime);	
	SetTimer(14.5,false,'DropPayload');	
	//if(ROLE == ROLE_Authority) SetTimer(5.0,true,'LocTest'); 
	if(WorldInfo.NetMode != NM_DedicatedServer)
	SetHidden(false);
	if(PayLoad != none) Payload.SetHidden(false); 
	
	
	SetCollision(true,true);
	

}

simulated function Explosion(optional Controller EventInstigator)
{
	super.Explosion(); 
	
	if(ROLE == ROLE_Authority && Payload != none && Payload.Base == self) 
	{
	DropPayload(); 	
	}
}

simulated function ClientAttachPayload() //Also attach your mask locally
{
	local Actor 	CA; 
	local vector	SocketLocation, RootSocketLocation;
	local rotator	SocketRotation, RootSocketRotation;
	
	
	super.ClientAttachPayload();
	
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{	
	//Just use some logic here for clients
		Mesh.GetSocketWorldLocationAndRotation(PayLoadSocketName, SocketLocation, SocketRotation);
		Mesh.GetSocketWorldLocationAndRotation(RootSocketName, RootSocketLocation, RootSocketRotation);
		
			//Attach Payload
			foreach VisibleCollidingActors(class'Actor', CA, 200, SocketLocation, false)
			{
				//`log("-----Actor------: " @ CA @ VSize(CA.location-SocketLocation) $ "Units"); 
				if(CA == Self || RxIfc_Airlift(CA) == none) 
				{
				//`log("Skipping :" @ CA);
				continue; 	
				}
				
				if(!RxIfc_Airlift(CA).bReadyToLift()) continue; //Not prepared to be lifted. 
				
				//`log("-----Actor Found------: " @ CA); 
				Payload=CA; 
				Payload.SetPhysics(PHYS_NONE);
				Payload.SetHidden(false); 
				Payload.SetBase(none); 
				Payload.SetHardAttach(true); 
				Payload.SetBase(self,,Mesh,PayloadSocketName); 
				Payload.bNetDirty = true; 
				break; 
			}
			
			//Attach Mask
			foreach CollidingActors(class'Actor', CA, 100, RootSocketLocation, false)
			{
				//`log("-----Actor------: " @ CA @ VSize(CA.location-SocketLocation) $ "Units"); 
				if(CA == Self || Rx_SupportVehicle_DropOffChinook_Mask(CA) == none) 
				{
				//`log("Skipping :" @ CA);
				continue; 	
				}
				
				//`log("-----Actor Found------: " @ CA); 
				Mask=Rx_SupportVehicle_DropOffChinook_Mask(CA); 
				Mask.SetPhysics(PHYS_NONE);
				Mask.SetHidden(false); 
				Mask.SetBase(none); 
				Mask.SetHardAttach(true); 
				Mask.SetBase(self,,Mesh,RootSocketName); 
				Mask.bNetDirty = true; 
				break; 
			}
			
	}	
}

function CallForceDetach(bool bKillVehicle, Controller EventInstigator)
{
	super.CallForceDetach(bKillVehicle, EventInstigator);
	DropPayload(); 
}

//We're just a big animation. Attach our sound component to the root socket so it follows the animation
simulated function AttachSoundComponent()
{
	Mesh.AttachComponentToSocket(MyAudioComponent, RootSocketName);
}

simulated function vector GetAdjustedLocation()
{
	local vector	SocketLocation;
	local rotator	SocketRotation;
	
	Mesh.GetSocketWorldLocationAndRotation(RootSocketName, SocketLocation, SocketRotation);	
	
	return SocketLocation; 
}

DefaultProperties
{
	
	Health=300
	HealthMax=300
	
	ArmorType = ARM_Light
	
	PayLoadSocketName =AirDrop_Vehicle
	RootSocketName =VH_Death //9/10 for Chinook and most models 
	
	bAttractAA = false ; /*EDIT: I ... randomly considered it worth it one day----Getting this big ass animation to work with SAMs just isn't worth it. Just let them target the payload*/
	
	/***End vars ******/
	
	Begin Object Name=WSkeletalMesh	
		SkeletalMesh=SkeletalMesh'RX_VH_Chinook.Mesh.SK_VH_Chinook'
		AnimSets(0)=AnimSet'RX_VH_Chinook.Anims.AS_VH_Chinook'
		AnimTreeTemplate=AnimTree'RX_VH_Chinook.Anims.AT_Chinook_AirDrop'
		PhysicsAsset=PhysicsAsset'RX_VH_Chinook.Mesh.SK_VH_Chinook_Physics'
		AlwaysLoadOnServer=true
		CastShadow=true
		AlwaysLoadOnClient=true
		BlockNonZeroExtent   = true  
		BlockZeroExtent      = true
		BlockActors=true
		CollideActors=true
		bUpdateSkelWhenNotRendered=true
		bCastDynamicShadow=true
		LightEnvironment = MyLightEnvironment
	End Object
	Mesh=WSkeletalMesh
	Components.Add(WSkeletalMesh)
	
	
	bHidden=true
	CurrentTime=-1.f

	
	bUseInitializationVector 	= true
	RelativeInitVector			= (X=0,Y=0,Z=200)
	TimeToMoveToRelativeVector	= 1.0; 
	
	NetPriority=+00001.500000
	bAlwaysRelevant=true
	LifeSpan=38.4f
	
	
    Begin Object Name=VehicleAudioComponent
        SoundCue=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Idle'
    End Object
    MyAudioComponent=VehicleAudioComponent
    Components.Add(VehicleAudioComponent);		
	
	bDrawLocation = false; 
	MinimapIconTexture=Texture2D'RX_VH_Chinook.UI.T_MinimapIcon_Chinook'
}
