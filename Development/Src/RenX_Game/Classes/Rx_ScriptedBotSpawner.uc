class Rx_ScriptedBotSpawner extends Actor
	placeable;

var(Spawner) bool bActivateOnStart;
var(Spawner) Array<Actor> SpawnPoints;					// Places where bots can spawn
var(Spawner) int SpawnNumber;							// The number of spawn until spawner is disabled. set to 0 or lower for infinite
var(Spawner) int MaxSpawn;								// Maximum amount of existing bots. Set to 0 for indefinite amount
var(Spawner) Array<class<Rx_FamilyInfo> > CharTypes;	// Type of squad to spawn
var(Spawner) Array<class<Rx_Vehicle> > VehicleTypes;		// Type of Vehicles the squad will spawn with
var(Spawner) int TeamIndex;								// Which side the bots belong to
var(Spawner) float SpawnInterval;						// How often the spawn occurs
var(Spawner) string SquadID;
var(Spawner) Rx_ScriptedObj SquadObjective;
var(Spawner) bool bOverrideObjective;


var int SpawnedBotNumber, BotRemaining;
var Rx_SquadAI_Scripted AffiliatedSquad;
var Rx_TeamInfo AffiliatedTeam;
var Array<Rx_Bot_Scripted> MyBots;

event PostBeginPlay()
{
	AffiliatedTeam = Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[TeamIndex]);
	AffiliatedSquad = GetSquadByID(SquadID);


	if(bActivateOnStart)
		SetTimer(SpawnInterval,true,'StartSpawning');
}

function StartSpawning ()
{
	local Rx_Bot_Scripted B;
	local Rx_Pawn_Scripted P;
	local Rx_TeamAI TeamAI;
	local Rx_Vehicle V;
	local int I, VI;

	TeamAI = Rx_TeamAI(AffiliatedTeam.AI);

	if(SpawnPoints.Length <= 0)
	{
		`log(Self@"Missing Spawnpoints. Abort Spawning");
		StopSpawning();
		return;
	}

	I = Rand(SpawnPoints.Length);

	P = Spawn(class'Rx_Pawn_Scripted',,,SpawnPoints[I].location,SpawnPoints[I].rotation);
	B = Spawn(class'Rx_Bot_Scripted');
	B.Possess(P,false);
	MyBots.AddItem(B);
	B.MySpawner = Self;

	Rx_Game(WorldInfo.Game).SetTeam(B, Rx_Game(WorldInfo.Game).Teams[TeamIndex], false);

	if(VehicleTypes.Length > 0)
	{
		VI = Rand(VehicleTypes.Length);
		V = Spawn(VehicleTypes[VI],,,SpawnPoints[I].location,SpawnPoints[I].rotation);
		V.DriverEnter(P);
	}
	

	if(AffiliatedSquad == None)
	{
		AffiliatedSquad = Rx_SquadAI_Scripted(TeamAI.AddSquadWithLeader(B,SquadObjective));
	}
	else
		AffiliatedSquad.AddBot(B);

	AffiliatedSquad.Spawner = self;

	if(bOverrideObjective && ((SquadID != "" && B.Squad.SquadObjective != SquadObjective) || B.MyObjective != SquadObjective))
		B.ForceAssignObjective(SquadObjective);

	I = Rand(CharTypes.Length);

	if(CharTypes[I].static.Cost(Rx_PRI(B.PlayerReplicationInfo)) <= 0)
		Rx_PRI(B.PlayerReplicationInfo).SetChar(CharTypes[I], B.Pawn, true);
	else
		Rx_PRI(B.PlayerReplicationInfo).SetChar(CharTypes[I], B.Pawn, false);



	SpawnedBotNumber += 1;
	BotRemaining += 1;

	if(SpawnNumber > 0 && SpawnedBotNumber >= SpawnNumber)
		StopSpawning();

	if(MaxSpawn > 0 && BotRemaining >= MaxSpawn)
		StopSpawning();

}

function StopSpawning ()
{
	ClearTimer('StartSpawning');
}

function NotifyPawnDeath ()
{
	if(MaxSpawn <= 0 || MaxSpawn > SpawnedBotNumber)
	{	
		if(MaxSpawn > BotRemaining) 
			RestartSpawning();
	}

}

function RestartSpawning ()
{
	if(MaxSpawn <= 0 || MaxSpawn > SpawnedBotNumber)
		SetTimer(SpawnInterval,true,'StartSpawning');
}

function Rx_SquadAI_Scripted GetSquadByID(string ID)
{
	local Rx_SquadAI S;


	for (S=Rx_SquadAI(Rx_Game(WorldInfo.Game).Teams[TeamIndex].AI.Squads); S!=None; S=Rx_SquadAI(S.NextSquad) )
	{
		if(Rx_SquadAI_Scripted(S) == None)
			continue;

		if(Rx_SquadAI_Scripted(S).SquadID == SquadID)
		return Rx_SquadAI_Scripted(S);
	}

	return none;
}

function bool DoTaskFor (Rx_Bot_Scripted B)
{
	if (SquadObjective != None)
	{
		return SquadObjective.DoTaskFor(B);
	}
	return false;
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Pawns"
	End Object
	Components.Add(Sprite)
}