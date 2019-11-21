class Rx_VehicleSpawnerManager extends Actor
	placeable;

var(Spawner) bool bEnabled;
var(Spawner) byte Team;		//The team this spawner is associated with
var(Spawner) Array<Rx_VehicleSpawner> AssociatedSpawners;	//Vehicle spawner that will be used when using this manager
var(Spawner) float Cooldown;

var Rx_VehicleManager_Coop VehicleManager;
var int ProcessedQueue;


replication
{
	if( bNetDirty && Role == ROLE_Authority )
		bEnabled, ProcessedQueue;
}

function Rx_VehicleSpawner GetAvailableSpawner()
{
	local Rx_VehicleSpawner Spawner;

	foreach AssociatedSpawners(Spawner)
	{
		if (Spawner.bReadyToSpawn)
		{
			return Spawner;
		}
	}

		return None;
}

function InitializeSpawn(Rx_VehicleManager_Coop VM)
{
	if (IsTimerActive('CoolingDown'))
		return;

	if(VehicleManager == None || VehicleManager != VM)
		VehicleManager = VM;

	
	StartSpawn();
}

function StartSpawn()
{
	local Rx_VehicleSpawner CurrentSpawner;

	CurrentSpawner = GetAvailableSpawner();

	if(CurrentSpawner != None)	// if no spawner is available, we go back to cooldown
	{
		CurrentSpawner.Manager = self;

		CurrentSpawner.ProcessQueue();
		ProcessedQueue += 1;

	}
	SetTimer(Cooldown,false,'CoolingDown');
}



function CoolingDown()
{
	if(Team == 0 && VehicleManager.GDI_QueueCoop.Length > ProcessedQueue)
		StartSpawn();
	else if (Team == 1 && VehicleManager.Nod_QueueCoop.Length > ProcessedQueue)
		StartSpawn();

}

function SpawnVehicleAtSpawnPoint(Rx_VehicleSpawner Spawner)
{
	Rx_Game_Cooperative(WorldInfo.Game).SpawnVehicleFor(Team, Spawner);
	ProcessedQueue -= 1;

}

simulated function OnToggle(SeqAct_Toggle Action)
{

	if(Action.InputLinks[0].bHasImpulse)
		bEnabled = true;

	else if (Action.InputLinks[1].bHasImpulse)
		bEnabled = false;

	else
		bEnabled = !bEnabled;

}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_NavP'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite)

	RemoteRole            = ROLE_SimulatedProxy
	bGameRelevant       = True
	bOnlyDirtyReplication = True
	
	NetUpdateFrequency=10.0
}
