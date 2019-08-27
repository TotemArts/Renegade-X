class Rx_VehicleSpawnerManager extends Actor
	placeable;

var(Spawner) bool bEnabled;
var(Spawner) byte Team;		//The team this spawner is associated with
var(Spawner) Array<Rx_VehicleSpawner> AssociatedSpawners;	//Vehicle spawner that will be used when using this manager
var(Spawner) float Cooldown;

var Rx_VehicleManager VehicleManager;
var bool bSpawningVehicle;
var Rx_VehicleSpawner CurrentSpawner;

function PostBeginPlay()
{
	if(Rx_Game_Cooperative(WorldInfo.Game) == None)
		return;

	Rx_Game_Cooperative(WorldInfo.Game).AddSpawnerManager(Self);
}

function Rx_VehicleSpawner GetAvailableSpawner()
{
	local Rx_VehicleSpawner Spawner;
	local int Num;

	foreach AssociatedSpawners(Spawner)
	{
		if (Spawner.bReadyToSpawn)
		{
			return Spawner;
		}
		else
		{	
			if(Num < AssociatedSpawners.length - 1)
			{
				Num++;
				continue;
			}
			else
			{
				return AssociatedSpawners[0];
			}
		}
	}
}

function InitializeSpawn()
{
	if (bSpawningVehicle || IsTimerActive('CoolingDown'))
		return;

	CurrentSpawner = GetAvailableSpawner();
	if(CurrentSpawner == None)
	{
		`Warn("VSM failed to get viable spawnpoint!");
	}
	else
	{
		CurrentSpawner.Manager = self;

		CurrentSpawner.ProcessQueue();
	}
	SetTimer(Cooldown,false,'CoolingDown');
}

function CoolingDown()
{
	local Rx_VehicleManager_Coop VM;

	VM = Rx_VehicleManager_Coop(Rx_Game(WorldInfo.Game).GetVehicleManager());
	if(Team == 0 && VM.GDI_QueueCoop.Length > 0)
		InitializeSpawn();
	else if (Team == 1 && VM.Nod_QueueCoop.Length > 0)
		InitializeSpawn();

}

function SpawnVehicleAtSpawnPoint()
{
	bSpawningVehicle = false;
	Rx_Game_Cooperative(WorldInfo.Game).SpawnVehicleFor(Team);
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
}
