class Rx_BuildingAttachment_GarageDoor extends Rx_BuildingAttachment_LockableDoor;

var repnotify bool  bInital;
var array<StaticMeshComponent>  DoorPieces;

replication
{
	if (bNetInitial && Role == ROLE_Authority)
		bInital;   
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	bInital = true;
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		SetDoorsInitial();
		AnimNode = DoorSkeleton.FindAnimNode(OpenAnimName);
	}
	DoorSkeleton.AttachComponentToSocket(DoorPieces[0], 'Door_Top');
	DoorPieces[0].SetLightEnvironment(LightComp);
	DoorSkeleton.AttachComponentToSocket(DoorPieces[1], 'Door_Bottom');
	DoorPieces[1].SetLightEnvironment(LightComp);
}

simulated function ReplicatedEvent(name VarName)
{
	if ( VarName == 'bInital' )
	{
		SetDoorsInitial();	
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function SetDoorsInitial()
{
	`log("Initializing Garage Door to Closed.",bAttachmentDebug,'BuildingAttachment');
	if (!bOpen && WorldInfo.NetMode != NM_DedicatedServer)
	{
		DoorSkeleton.StopAnim();
		DoorSkeleton.PlayAnim(ClosedAnimName, 1.0f, false, false, 0.0f, false);
	}
}

DefaultProperties
{
	RemoteRole          = ROLE_SimulatedProxy
	SpawnName           = "_GarageDoor"
	SocketPattern       = "GarageWF"
	OpenAnimName        = "Opening"
	ClosedAnimName      = "Closed"
	CollisionType       = COLLIDE_BlockAll
	bCollideActors      = True
	bBlockActors        = True
	SensorRadius        = 700.0f
	SensorHeight        = 375.0f
	TeamID              = TEAM_GDI


	Begin Object Name=DoorSkelCmp
		SkeletalMesh     = SkeletalMesh'RX_BU_WeaponsFactory.Mesh.SK_WF_Garage'
		AnimSets(0)      = AnimSet'RX_BU_WeaponsFactory.Anims.AS_WF_Garage'
		AnimTreeTemplate = AnimTree'RX_BU_WeaponsFactory.Anims.AT_WF_Garage'
		PhysicsAsset	 = PhysicsAsset'RX_BU_WeaponsFactory.Mesh.SK_WF_Garage_Physics'
	End Object
	
	Begin Object Class=StaticMeshComponent Name=TopMeshPiece
		StaticMesh = StaticMesh'RX_BU_WeaponsFactory.Mesh.SM_WF_GarageDoor_Top'
		CastShadow                   = True
		AlwaysLoadOnClient           = True
		AlwaysLoadOnServer           = True
		bUsePrecomputedShadows       = False
		CollideActors                = True
		BlockActors                  = True
		BlockRigidBody               = True
		BlockZeroExtent              = True
		BlockNonZeroExtent           = True
		bCastDynamicShadow           = True
		bAcceptsDynamicLights        = True
		bAcceptsLights               = True
		bAcceptsDecalsDuringGameplay = True
		bAcceptsDecals               = True
		LightingChannels             = (Static = true, BSP = true, Dynamic = True, bInitialized = True)
	End Object
	DoorPieces.Add(TopMeshPiece)
	
	Begin Object Class=StaticMeshComponent Name=BottomMeshPiece
		StaticMesh = StaticMesh'RX_BU_WeaponsFactory.Mesh.SM_WF_GarageDoor_Bottom'
		CastShadow                   = True
		AlwaysLoadOnClient           = True
		AlwaysLoadOnServer           = True
		bUsePrecomputedShadows       = False
		CollideActors                = True
		BlockActors                  = True
		BlockRigidBody               = True
		BlockZeroExtent              = True
		BlockNonZeroExtent           = True
		bCastDynamicShadow           = True
		bAcceptsDynamicLights        = True
		bAcceptsLights               = True
		bAcceptsDecalsDuringGameplay = True
		bAcceptsDecals               = True
		LightingChannels             = (Static = true, BSP = true, Dynamic = True, bInitialized = True)
	End Object
	DoorPieces.Add(BottomMeshPiece)
	
	OpeningSound=SoundCue'RX_BU_WeaponsFactory.Sounds.SC_GarageDoor_Open'
	ClosingSound=SoundCue'RX_BU_WeaponsFactory.Sounds.SC_GarageDoor_Close'
}
