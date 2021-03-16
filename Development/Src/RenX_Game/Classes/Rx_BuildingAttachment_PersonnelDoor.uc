class Rx_BuildingAttachment_PersonnelDoor extends Rx_BuildingAttachment_LockableDoor;

var array<StaticMeshComponent>  DoorPieces;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	DoorSkeleton.AttachComponentToSocket(DoorPieces[0], 'Door_Top');
	DoorPieces[0].SetLightEnvironment(LightComp);
	DoorSkeleton.AttachComponentToSocket(DoorPieces[1], 'Door_Left');
	DoorPieces[1].SetLightEnvironment(LightComp);
	DoorSkeleton.AttachComponentToSocket(DoorPieces[2], 'Door_Right');
	DoorPieces[2].SetLightEnvironment(LightComp);
}

DefaultProperties
{
	RemoteRole          = ROLE_SimulatedProxy
	bCollideWhenPlacing = False
	CollisionType       = COLLIDE_BlockAll
	bAlwaysRelevant     = True
	bCollideActors      = True
	bBlockActors        = true
	DoorOpenTime        = 1.0f
	bOpenForVehicles    = false

	SpawnName           = "_Door"
	SocketPattern       = "Door_"
	OpenAnimName        = "Open"
	SensorRadius        = 250.0f
	SensorHeight        = 100.0f
	
	Begin Object Name=DoorSkelCmp
		SkeletalMesh     = SkeletalMesh'rx_bu_door.Mesh.SK_BU_Door_Skeleton'
		AnimSets(0)      = AnimSet'rx_bu_door.Anims.A_BU_Door'
		AnimTreeTemplate = AnimTree'rx_bu_door.Anims.AT_Door'
		PhysicsAsset	 = PhysicsAsset'rx_bu_door.Mesh.SK_BU_Door_Physics'
	End Object

	Begin Object Class=StaticMeshComponent Name=TopMeshPiece
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
		LightingChannels             = (Static=true,BSP=true,Dynamic=True,bInitialized=True)
	End Object
	DoorPieces.Add(TopMeshPiece)

	Begin Object Class=StaticMeshComponent Name=LeftMeshPiece
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
		LightingChannels             = (Static=true,BSP=true,Dynamic=True,bInitialized=True)
	End Object
	DoorPieces.Add(LeftMeshPiece)

	Begin Object Class=StaticMeshComponent Name=RightMeshPiece
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
		LightingChannels             = (Static=true,BSP=true,Dynamic=True,bInitialized=True)
	End Object
	DoorPieces.Add(RightMeshPiece)
	
}
