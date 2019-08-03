class Rx_Chinook_Airdrop extends Actor;

var SkeletalMeshComponent Mesh;


var private repnotify float CurrentTime;
var private bool bGotCurrentTime;
var SkeletalMeshComponent VehicleMesh;
var Rx_vehicle CarriedVehicle;
var const AudioComponent EngineSound;
var byte TeamNum;
var Rx_PRI Buyer;
var int VehicleID;
var DynamicLightEnvironmentComponent        LightEnvironment;

replication
{
	if (bNetDirty)
		CurrentTime,TeamNum,Buyer,VehicleID;
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
	SetHidden(true);
	SetCollision(false,false);
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

simulated function initialize(Rx_PRI Buyer_Local, int VehicleID_local, byte teamnumber)
{			
	Buyer = Buyer_Local;
	VehicleID = VehicleID_local;
	TeamNum = teamnumber;	
}

simulated function class<Rx_Vehicle> GetVehicleClass()
{
	if (TeamNum == TEAM_GDI)
	{
		if (VehicleID == 7)
			return class<Rx_Game>(WorldInfo.GetGameClass()).default.VehicleManagerClass.default.GDIHarvesterClass;
		else
			return class<Rx_Game>(WorldInfo.GetGameClass()).default.PurchaseSystemClass.default.GDIVehicleClasses[VehicleID].default.VehicleClass;
	}
	else
	{
		if (VehicleID == 8)
			return class<Rx_Game>(WorldInfo.GetGameClass()).default.VehicleManagerClass.default.NodHarvesterClass;
		else
			return class<Rx_Game>(WorldInfo.GetGameClass()).default.PurchaseSystemClass.default.NodVehicleClasses[VehicleID].default.VehicleClass;
	}
}

simulated function InitEngineSound()
{
	EngineSound.FadeIn(14.0, 1.f);
}

simulated event Destroyed()
{
	EngineSound.Stop();
	super.Destroyed();
}


simulated function DropVehicle()
{	
	local Vector SocketLocation;
	local Rotator SocketRotation;	
	
	Mesh.DetachComponent(VehicleMesh);
	Mesh.GetSocketWorldLocationAndRotation('AirDrop_Vehicle', SocketLocation, SocketRotation);
	
	if (WorldInfo.NetMode != NM_Client)
	{
		CarriedVehicle = Spawn(GetVehicleClass(),,, SocketLocation,,,true);	
		CarriedVehicle.DropToGround();	
		CarriedVehicle.Mesh.WakeRigidBody();
		Rx_Game(WorldInfo.Game).GetVehicleManager().InitVehicle(CarriedVehicle,TeamNum,Buyer,VehicleID,SocketLocation); 
	}	
	
	/**if (WorldInfo.NetMode != NM_DedicatedServer)
		SetTimer(4.0,false,'EngineSoundFadeOut');
	*/
	}

simulated function EngineSoundFadeOut()
{
	EngineSound.FadeOut(5.0, 0.7f);
	SetTimer(5.0,false,'EngineSoundFadeOutTwo');
}

simulated function EngineSoundFadeOutTwo()
{
	EngineSound.VolumeMultiplier = 0.7;
	EngineSound.FadeOut(11.0, 0.f);
}

simulated event OnAnimPlay(AnimNodeSequence SeqNode)
{
	loginternal("anim started");
}

simulated function InitialSetup()
{	
	local Vector SocketLocation;
	local Rotator SocketRotation;	
	
	Mesh.AttachComponentToSocket(VehicleMesh, 'AirDrop_Vehicle');	
	VehicleMesh.SetSkeletalMesh(GetVehicleClass().default.SkeletalMeshForPT);
	if (WorldInfo.NetMode != NM_DedicatedServer)
		setHidden(false);
	//SetTimer(2.0,false,'InitEngineSound');
	AttachSoundComponent(); 	
	EngineSound.Play(); 
	VehicleMesh.SetShadowParent(Mesh);		
	Mesh.GetSocketWorldLocationAndRotation('AirDrop_Vehicle', SocketLocation, SocketRotation);	
	Mesh.PlayAnim('AirDrop',,false,false,CurrentTime);	
	SetTimer(14.5,false,'DropVehicle');
}

//We're just a big animation. Attach our sound component to the root socket so it follows the animation
simulated function AttachSoundComponent()
{
	Mesh.AttachComponentToSocket(EngineSound, 'VH_Death');
}

DefaultProperties
{
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

	Begin Object Class=SkeletalMeshComponent Name=WSkeletalMesh	
		SkeletalMesh=SkeletalMesh'RX_VH_Chinook.Mesh.SK_VH_Chinook'
		AnimSets(0)=AnimSet'RX_VH_Chinook.Anims.AS_VH_Chinook'
		AnimTreeTemplate=AnimTree'RX_VH_Chinook.Anims.AT_Chinook_AirDrop'
		PhysicsAsset=PhysicsAsset'RX_VH_Chinook.Mesh.SK_VH_Chinook_Physics'
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

		
	Begin Object Class=SkeletalMeshComponent Name=VehMesh
		CollideActors=false
		LightEnvironment = MyLightEnvironment
	End Object
	VehicleMesh=VehMesh		
	
	
	
	bHidden=true
	CurrentTime=-1.f

	NetPriority=+00001.500000
	bAlwaysRelevant=true
	LifeSpan=38.4f
	
    Begin Object Class=AudioComponent Name=EngineSoundComponent
        SoundCue=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Idle'
    End Object
    EngineSound=EngineSoundComponent
    Components.Add(EngineSoundComponent);		
	
}
