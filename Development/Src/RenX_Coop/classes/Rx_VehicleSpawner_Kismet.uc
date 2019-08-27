class Rx_VehicleSpawner_Kismet extends Rx_VehicleSpawner
	placeable;

var(Spawner) bool bShowVehicle;

function ProcessQueue()
{
	local SkeletalMesh Display;
	local Rx_VehicleManager_Coop VM;

	VM = Rx_VehicleManager_Coop(Rx_Game(WorldInfo.Game).GetVehicleManager());

	if(Manager.Team == 0)
		TriggerEventClass(class'SeqEvent_VehicleSpawnerEvent',VM.GDI_QueueCoop[0].Buyer.Owner,0);
	else
		TriggerEventClass(class'SeqEvent_VehicleSpawnerEvent',VM.Nod_QueueCoop[0].Buyer.Owner,0);

	if(bShowVehicle)
	{

		if(Manager.Team == 0)
			Display = VM.GDI_QueueCoop[0].VehClass.default.Mesh.SkeletalMesh;
		else
			Display = VM.Nod_QueueCoop[0].VehClass.default.Mesh.SkeletalMesh;


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
	SupportedEvents(6)=class'SeqEvent_VehicleSpawnerEvent'
}