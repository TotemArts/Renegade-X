class Rx_ScriptedBotSpawner extends Actor
	ClassGroup(Scripted)	
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
var(Spawner) bool bCheckPlayerLOS;
var(Spawner) bool bInvulnerableBots;						// Is the bot in God Mode?


var bool bActive;
var int SpawnedBotNumber, BotRemaining;
var Rx_SquadAI_Scripted AffiliatedSquad;
var Rx_TeamInfo AffiliatedTeam;
var Array<Rx_Bot_Scripted> MyBots;

event PostBeginPlay()
{
	AffiliatedTeam = Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[TeamIndex]);
	AffiliatedSquad = GetSquadByID(SquadID);

	if(SpawnNumber <= 0 && MaxSpawn <= 0)
	{
		`warn(self@" : WARNING, ad infinitum spawner detected. Forcing MaxSpawn to 30");
		MaxSpawn = 30;
	}

	if(bActivateOnStart)
		bActive = true;

	if(bActive)
	{
		if(SpawnInterval > 0)
			SetTimer(SpawnInterval,true,'StartSpawning');

		else
			StartSpawning();
	}

}

function StartSpawning (optional bool bForced)
{
	local Rx_Bot_Scripted B;
	local Rx_Pawn_Scripted P;
	local Rx_TeamAI TeamAI;
	local Rx_Vehicle V;
	local int I, VI;
	local Actor BestSpawn;

	if(!bActive && !bForced)
		return;

	TeamAI = Rx_TeamAI(AffiliatedTeam.AI);

	if(SpawnPoints.Length <= 0)
	{
		`log(Self@"Missing Spawnpoints. Abort Spawning");
		StopSpawning();
		return;
	}

	VI = -1;

	if(VehicleTypes.Length > 0)
	{
		VI = Rand(VehicleTypes.Length);
		BestSpawn = RateBestSpawn(VehicleTypes[VI]);		
	}
	else
		BestSpawn = RateBestSpawn(class'Rx_Pawn_Scripted');

	if(BestSpawn != None)		// if failed, postpone the spawn cycle
	{
		if(VI >= 0)
			V = Spawn(VehicleTypes[VI],,,BestSpawn.location,BestSpawn.rotation);
	

		if(V != None)
			P = Spawn(class'Rx_Pawn_Scripted',,,BestSpawn.location + vect(0,0,100000),BestSpawn.rotation);
		else
			P = Spawn(class'Rx_Pawn_Scripted',,,BestSpawn.location,BestSpawn.rotation);
		B = Spawn(class'Rx_Bot_Scripted');
		B.Possess(P,false);
		MyBots.AddItem(B);
		B.MySpawner = Self;

		I = Rand(CharTypes.Length);

		if(CharTypes[I].static.Cost(Rx_PRI(B.PlayerReplicationInfo)) <= 0)
			Rx_PRI(B.PlayerReplicationInfo).SetChar(CharTypes[I], B.Pawn, true);
		else
			Rx_PRI(B.PlayerReplicationInfo).SetChar(CharTypes[I], B.Pawn, false);


		if(V != None)
		{
			V.DriverEnter(P);
			V.DropToGround();

			if (V.Mesh != none)
				V.Mesh.WakeRigidBody();
		}

		Rx_Game(WorldInfo.Game).SetTeam(B, Rx_Game(WorldInfo.Game).Teams[TeamIndex], false);


		if(AffiliatedSquad == None)
		{
			AffiliatedSquad = Rx_SquadAI_Scripted(TeamAI.AddSquadWithLeader(B,SquadObjective));
		}
		else
			AffiliatedSquad.AddBot(B);

		AffiliatedSquad.Spawner = self;

		if((SquadID != "" && B.Squad.SquadObjective != SquadObjective) || B.MyObjective != SquadObjective)
			B.ForceAssignObjective(SquadObjective);

		SpawnedBotNumber += 1;
		BotRemaining += 1;
	}

	TriggerEventClass(Class'Rx_SeqEvent_ScriptedSpawnerEvent',B,0);

	if(SpawnNumber > 0 && SpawnedBotNumber >= SpawnNumber)
		StopSpawning();

	else if(MaxSpawn > 0 && BotRemaining >= MaxSpawn)
		StopSpawning();

	else if(SpawnInterval < 0)
		StartSpawning();

}

function Actor RateBestSpawn(class<Pawn> PawnClass)
{
	local float CurrentRate,BestRate;
	local Actor CurrentSpawn,BestSpawn;
	local Controller Others;

	if(CurrentRate < 0)
		return None;

	foreach SpawnPoints(CurrentSpawn)
	{
		CurrentRate = (FRand() + 5.f);

		ForEach WorldInfo.AllControllers(class'Controller', Others)
		{
			if(Others.Pawn == None)	// no point in checking controller that has no pawn, continue
				continue;

			if ((Abs(CurrentSpawn.Location.Z - Others.Pawn.Location.Z) < PawnClass.Default.CylinderComponent.CollisionHeight + Others.Pawn.CylinderComponent.CollisionHeight) 
					&& (VSize2D(CurrentSpawn.Location - Others.Pawn.Location) < PawnClass.Default.CylinderComponent.CollisionRadius + Others.Pawn.CylinderComponent.CollisionRadius))
			{
				CurrentRate = -10.f;
				Break;
			}

			if( Rx_Controller(Others) != None && Others.CanSeeByPoints(Others.Pawn.Location, CurrentSpawn.Location, Others.Pawn.Rotation))
			{
				if(bCheckPlayerLOS)
				{
					CurrentRate = -5.f;
					break; // immediately invalidate, break away
				}
				else
					CurrentRate = CurrentRate * 0.8;	// Diminish rate for each time a player can see this point
			}
		}

		if(BestSpawn == None || BestRate < CurrentRate)
		{
			BestRate = CurrentRate;
			BestSpawn = CurrentSpawn;
		}

	}

	if(BestRate > 0)
		return BestSpawn;

	// if BestRate is less than 0, that means our search has failed, return none

	return none;
}

function StopSpawning ()
{
	TriggerEventClass(Class'Rx_SeqEvent_ScriptedSpawnerEvent',None,1);
	ClearTimer('StartSpawning');
}

function NotifyPawnDeath (Rx_Bot_Scripted B)
{

	if(SpawnNumber <= 0 || (SpawnNumber > SpawnedBotNumber && SpawnNumber > 0))
	{	
		RestartSpawning();
	}
	else if(BotRemaining <= 0)
	{
		TriggerEventClass(Class'Rx_SeqEvent_ScriptedSpawnerEvent',None,3);
	}

	TriggerEventClass(Class'Rx_SeqEvent_ScriptedSpawnerEvent',None,2);
}

function RestartSpawning ()
{
	if(!bActive || IsTimerActive('StartSpawning'))
		return;

	if(MaxSpawn <= 0 || MaxSpawn > BotRemaining)
	{
		if(SpawnInterval > 0)
			SetTimer(SpawnInterval,true,'StartSpawning');
		else
			StartSpawning();
	}
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

// KISMET HANDLER SECTION

function OnToggle(SeqAct_Toggle Action)
{
	if(Action.InputLinks[0].bHasImpulse)
	{
		bActive = true;
	}
	else if(Action.InputLinks[1].bHasImpulse)
	{
		bActive = false;
	}
	else
		bActive = !bActive;

	if(bActive && !IsTimerActive('StartSpawning'))
		RestartSpawning();

	else if (!bActive && IsTimerActive('StartSpawning'))
		StopSpawning();
}

function OnForceSpawn(Rx_SeqAct_ScriptedBotForceSpawn Action)
{
	StartSpawning(true);
}

function OnModifySpawner (Rx_SeqAct_ScriptedBotModifySpawnValues Action)
{
	if(Action.SpawnPoints.Length > 0)
		SpawnPoints = Action.SpawnPoints;

	if(Action.SpawnNumber > 0 || Action.MaxSpawn > 0)
	{
		SpawnNumber = Action.SpawnNumber;
		MaxSpawn = Action.MaxSpawn;
	}

	if(Action.bModifyTypes)
	{
		if(Action.CharTypes.Length > 0)
			CharTypes = Action.CharTypes;

		VehicleTypes = Action.VehicleTypes;
	}

	SpawnInterval = Action.SpawnInterval;
	bCheckPlayerLOS = Action.bCheckPlayerLOS;
}


function OnChangeObjective(Rx_SeqAct_ScriptedBotChangeObjective Action)
{
	local SeqVar_Object ObjVar;
	local Rx_ScriptedObj NewObjective;

	foreach Action.LinkedVariables(class'SeqVar_Object', ObjVar, "Objective")
	{
		NewObjective = Rx_ScriptedObj(ObjVar.GetObjectValue());

		if(NewObjective == None)
			continue;

		else
		{
			SquadObjective = NewObjective;
			break;
		}
	}

	if(NewObjective != None)
	{
		AffiliatedSquad.SetObjective(SquadObjective,true);
	}
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorMaterials.TargetIcon'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Pawns"
	End Object
	Components.Add(Sprite)

	SupportedEvents.Add(class'Rx_SeqEvent_ScriptedSpawnerEvent')
}