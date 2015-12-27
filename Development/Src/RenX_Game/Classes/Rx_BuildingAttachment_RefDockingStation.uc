class Rx_BuildingAttachment_RefDockingStation extends Rx_BuildingAttachment;

var SkeletalMeshComponent   RefDockingStationMesh;
var repnotify bool			bActivate;
var bool			        bAlreadyActivated;
		        



replication
{
   if (Role == ROLE_Authority && bNetDirty)
      bActivate;         
}

simulated event PreBeginPlay()
{ 
	super.PostBeginPlay();
	RefDockingStationMesh.PlayAnim('Inactive');
}

simulated function ReplicatedEvent(name VarName)
{
	if ( VarName == 'bActivate' )
	{
		if(bActivate)
		{
			Activate(true);
		}
		else
		{
			Activate(false);
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function Activate(bool activate)
{
	if(activate && !bAlreadyActivated)
	{
	    if(WorldInfo.NetMode != NM_DedicatedServer)
	    {
			RefDockingStationMesh.PlayAnim('Activating');
		}
	}
	else if(!activate && bAlreadyActivated)
	{
	  	if(WorldInfo.NetMode != NM_DedicatedServer)
	    {
			RefDockingStationMesh.PlayAnim('Activating',,,,,true);	
		}
	}
	bActivate=activate;
	bAlreadyActivated=activate;
}



DefaultProperties
{
	RemoteRole          = ROLE_SimulatedProxy
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled                        = True
		bSynthesizeSHLight              = True
		bUseBooleanEnvironmentShadowing = False
		bCastShadows 					= False
	End Object
	Components.Add(MyLightEnvironment)
	
	Begin Object Class=SkeletalMeshComponent Name=DockingStationMesh
		CollideActors   = True
		BlockActors     = True
		SkeletalMesh 	= SkeletalMesh'RX_BU_Refinery.Mesh.SK_BU_Ref_DockStation'
		AnimSets(0)     = AnimSet'RX_BU_Refinery.Anims.AS_Ref_DockingStation'
		AnimTreeTemplate = AnimTree'RX_BU_Refinery.Anims.AT_Ref_DockingStation'
		PhysicsAsset	= PhysicsAsset'RX_BU_Refinery.Mesh.SK_BU_Ref_DockStation_Physics'
		LightEnvironment = MyLightEnvironment
	End Object
	RefDockingStationMesh = DockingStationMesh	
	
	Components.Add(DockingStationMesh)
	

	SpawnName           = "_DockingStation"
	SocketPattern       = "DockStation_Attach"
	CollisionComponent  = DockingStationMesh
}
