class Rx_BuildingAttachment_RefGarageDoor extends Rx_BuildingAttachment_Door;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		SetTimer(0.5,false,'SetDoorsInitial');
	}
}

simulated function OpenDoor()
{
	bOpen=true;
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		PlaySound(OpeningSound);
		
		DoorSkeleton.StopAnim();
		DoorSkeleton.PlayAnim(OpenAnimName, 3.0f, false,false, 0.0f, false);
	}
	else
	{
		bServerOpen = true;
	}	
}
simulated function CloseDoor()
{
	bOpen=false;
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		SetTimer(4.5,false,'FollowAnim');
	}
	else
	{
		bServerOpen = false;
	}
}

simulated function FollowAnim()
{
	if(!bOpen) 
	{
		PlaySound(OpeningSound);
		DoorSkeleton.StopAnim();
		DoorSkeleton.PlayAnim(OpenAnimName, 3.0f, false, false, 0.0f, true);
	}
}

simulated function SetDoorsInitial()
{
	if (!bOpen)
	{
		PlaySound(ClosingSound);
		DoorSkeleton.StopAnim();
		DoorSkeleton.PlayAnim(OpenAnimName, 1.0f, false, false, 0.0f, true);	
	}
}

simulated function SensorTouch( Actor Other )
{
	if(Other.isA('Rx_Vehicle_Harvester'))
	{
		super.SensorTouch(Other);
	}
}

simulated function SensorUnTouch( Actor Other )
{
	if(Other.isA('Rx_Vehicle_Harvester'))
	{
		if(NumActorsTouching > 0) 
		{
			NumActorsTouching--;
		}

		if(Other.bHidden || Other.Physics == PHYS_None)
			return;
		if(Rx_Vehicle_HarvesterController(Pawn(Other).Controller) != None && Rx_Vehicle_HarvesterController(Pawn(Other).Controller).IsTurningToDock()) 
			return;

		if( NumActorsTouching == 0 )
		{
		}
	}
}

simulated function Close() 
{
	CloseDoor();
}

DefaultProperties
{
	RemoteRole          = ROLE_SimulatedProxy
	SpawnName           = "_GarageDoor"
	SocketPattern       = "Garage"
	OpenAnimName        = "Opening"
	CollisionType       = COLLIDE_BlockAll
	bCollideActors      = True
	bBlockActors        = True
	SensorRadius        = 800.0f
	SensorHeight        = 375.0f


	Begin Object Name=DoorSkelCmp
		SkeletalMesh     = SkeletalMesh'RX_BU_Refinery.Mesh.SK_BU_Ref_GarageDoor'
		AnimSets(0)      = AnimSet'RX_BU_Refinery.Anims.AS_Ref_GarageDoor'
		AnimTreeTemplate = AnimTree'RX_BU_Refinery.Anims.AT_Ref_GarageDoor'
		PhysicsAsset	 = PhysicsAsset'RX_BU_Refinery.Mesh.SK_BU_Ref_GarageDoor_Physics'
	End Object
	
	OpeningSound=SoundCue'RX_BU_WeaponsFactory.Sounds.SC_GarageDoor_Open'
	ClosingSound=SoundCue'RX_BU_WeaponsFactory.Sounds.SC_GarageDoor_Close'
}
