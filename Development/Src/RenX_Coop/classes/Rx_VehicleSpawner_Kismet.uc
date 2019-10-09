class Rx_VehicleSpawner_Kismet extends Rx_VehicleSpawner
	placeable;

var(Spawner) bool bShowVehicle;
var(Display) SkeletalMeshComponent Mesh;
var repnotify SkeletalMesh Display;

replication
{
	if( bShowVehicle && bNetDirty && Role == ROLE_Authority )
		Display;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'Display')
	{
		Mesh.SetSkeletalMesh(Display);
	}
}

function ProcessQueue()
{
	local Rx_VehicleManager_Coop VM;
	local int i;

	bReadyToSpawn = false;

	i = Manager.ProcessedQueue;
	VM = Rx_VehicleManager_Coop(Rx_Game(WorldInfo.Game).GetVehicleManager());

	if(Manager.Team == 0)
		TriggerEventClass(class'SeqEvent_VehicleSpawnerEvent',VM.GDI_QueueCoop[i].Buyer.Owner,0);
	else
		TriggerEventClass(class'SeqEvent_VehicleSpawnerEvent',VM.Nod_QueueCoop[i].Buyer.Owner,0);

	if(bShowVehicle)
	{

		if(Manager.Team == 0)
			Display = VM.GDI_QueueCoop[i].VehClass.default.Mesh.SkeletalMesh;
		else
			Display = VM.Nod_QueueCoop[i].VehClass.default.Mesh.SkeletalMesh;

		Mesh.SetSkeletalMesh(Display);
		SetHidden(false);
	}
}

function OnSpawnQueuedVehicle(SeqAct_SpawnQueuedVehicle Action)
{
	SpawnVehicle();

	if(bShowVehicle)
		SetHidden(true);
}

DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=SVehicleMesh
		CollideActors=false
		AlwaysLoadOnClient=false
		AlwaysLoadOnServer=false
		bUpdateSkelWhenNotRendered=false
        LightEnvironment=MyLightEnvironment
		SkeletalMesh=SkeletalMesh'RX_VH_MammothTank.Mesh.SK_VH_Mammoth'
		Translation=(X=-40.0,Y=0.0,Z=-70.0)
	End Object
	Components.Add(SVehicleMesh)
	Mesh = SVehicleMesh

	SupportedEvents(6)=class'SeqEvent_VehicleSpawnerEvent'

	RemoteRole            = ROLE_SimulatedProxy
	bGameRelevant       = True
	bOnlyDirtyReplication = True
	
	NetUpdateFrequency=10.0
}