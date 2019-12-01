class Rx_ScriptedBotSpawner extends Actor
	ClassGroup(Scripted)	
	placeable;

var(Spawn) bool bActivateOnStart;
var(Spawn) Array<Actor> SpawnPoints;					// Places where bots can spawn
var(Spawn) int SpawnNumber;							// The number of spawn until spawner is disabled. set to 0 or lower for infinite
var(Spawn) int MaxSpawn;								// Maximum amount of existing bots. Set to 0 for indefinite amount
var(Spawn) Array<class<Rx_FamilyInfo> > CharTypes;	// Type of squad to spawn
var(Spawn) Array<class<Rx_Vehicle> > VehicleTypes;		// Type of Vehicles the squad will spawn with
var(Spawn) int TeamIndex;								// Which side the bots belong to
var(Spawn) float SpawnInterval;						// How often the spawn occurs
var(Spawn) string SquadID;
var(Objective) Rx_ScriptedObj SquadObjective;
var(Spawn) bool bCheckPlayerLOS;
var(Combat) float Skill;
var(Combat) bool bInvulnerableBots;						// Is the bot in God Mode?
var(Combat) float DamageDealtModifier;					// Determines the multiplier of this bot's damage
var(Combat) float DamageTakenModifier;					// Determines the multiplier of the damage this bot takes from others
var(Combat) float SpeedModifier;						// Determines the multiplier for speed of the bot

struct CustomInv
{
	var() array<class<Rx_Weapon> > PrimaryWeapons;
	var() array<class<Rx_Weapon> > SecondaryWeapons;
	var() array<class<Rx_Weapon> > SidearmWeapons;
	var() array<class<Rx_Weapon> > ExplosiveWeapons;
	var() array<class<Rx_Weapon> > Items;	
};

var(Combat) array<CustomInv> CustomInventory;		// a set of Custom inventory for the class corresponding to the index
var(Combat) bool bDriverSurvives;					// Kills driver upon vehicle destruction if set to false

var bool bActive;
var int SpawnedBotNumber, BotRemaining;
var Rx_SquadAI_Scripted AffiliatedSquad;
var Rx_TeamInfo AffiliatedTeam;
var Array<Rx_Bot_Scripted_Customizeable> MyBots;

var bool bWaitForMatch;



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
		if(Rx_Game(WorldInfo.Game) != None && Rx_Game(WorldInfo.Game).IsInState('MatchInProgress'))
		{
			if(SpawnInterval > 0)
				SetTimer(SpawnInterval,true,'StartSpawning');

			StartSpawning();
		}
		else
		{
			bWaitForMatch = true;
		}
	}

}

event Tick(float DeltaTime)
{
	if(bWaitForMatch)
	{
		if(Rx_Game(WorldInfo.Game) != None && Rx_Game(WorldInfo.Game).IsInState('MatchInProgress'))
		{
			if(SpawnInterval > 0)
				SetTimer(SpawnInterval,true,'StartSpawning');

			StartSpawning();
			bWaitForMatch = false;
		}		
	}
}

function StartSpawning (optional bool bForced)
{
	local Rx_Bot_Scripted_Customizeable B;
	local Rx_Pawn_Scripted_Customizeable P;
	local Rx_TeamAI TeamAI;
	local Rx_Vehicle V;
	local int I, VI;
	local Actor BestSpawn;
	local Rx_InventoryManager PawnIM;
	local Vector PawnLoc;

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
		BestSpawn = RateBestSpawn(class'Rx_Pawn_Scripted_Customizeable');

	if(BestSpawn != None)		// if failed, postpone the spawn cycle
	{
		if(VI >= 0)
		{
			V = Spawn(VehicleTypes[VI],,,BestSpawn.location,BestSpawn.rotation);
			if(V != None)
			{
				PawnLoc = V.Location;
				PawnLoc.z += 1000;
				P = Spawn(class'Rx_Pawn_Scripted_Customizeable',,,PawnLoc,BestSpawn.rotation,,true);
			}
		}
		else
		{
			P = Spawn(class'Rx_Pawn_Scripted_Customizeable',,,BestSpawn.location,BestSpawn.rotation);
		}
	}

	if(P != None)	// check if spawn fails
	{
		P.TeamNum = TeamIndex;
		B = Spawn(class'Rx_Bot_Scripted_Customizeable',self);
		B.SetOwner(None);
		Rx_Game(WorldInfo.Game).SetTeam(B, Rx_Game(WorldInfo.Game).Teams[TeamIndex], false);
		P.MySpawner = Self;
		B.Possess(P,false);
		MyBots.AddItem(B);
		B.MySpawner = Self;

		I = Rand(CharTypes.Length);

		if(i + 1 <= CustomInventory.Length)
		{
			P.CurrCharClassInfo = CharTypes[i];
			P.NotifyTeamChanged();

			PawnIM = Rx_InventoryManager(B.Pawn.InvManager);

			PawnIM.PrimaryWeapons = CustomInventory[i].PrimaryWeapons;
			PawnIM.SecondaryWeapons = CustomInventory[i].SecondaryWeapons;
			PawnIM.SidearmWeapons = CustomInventory[i].SidearmWeapons;
			PawnIM.ExplosiveWeapons = CustomInventory[i].ExplosiveWeapons;
			PawnIM.Items = CustomInventory[i].Items;

			P.equipStartWeapons();

		}
		else
			B.SetChar(CharTypes[i], CharTypes[i].default.BasePurchaseCost <= 0);


		if(AffiliatedSquad == None)
		{
			AffiliatedSquad = Rx_SquadAI_Scripted(TeamAI.AddSquadWithLeader(B,SquadObjective));
		}
		else
			AffiliatedSquad.AddBot(B);

		if(V != None)
		{
			V.DropToGround();

			if (V.Mesh != none)
				V.Mesh.WakeRigidBody();

			B.BoundVehicle = V;
			V.DriverEnter(P);
		}

		B.UpdateModifiedStats();

		if((SquadID != "" && B.Squad.SquadObjective != SquadObjective) || B.MyObjective != SquadObjective)
			B.ForceAssignObjective(SquadObjective);

		B.Skill = Skill;
		B.ResetSkill();

		SpawnedBotNumber += 1;
		BotRemaining += 1;

		TriggerEventClass(Class'Rx_SeqEvent_ScriptedSpawnerEvent',B,0);

	}
	else if (SpawnInterval <= 0)
	{
		SetTimer(0.1,false,'StartSpawning'); // Add grace time to avoid loop
		return;
	}

	if(SpawnNumber > 0 && SpawnedBotNumber >= SpawnNumber)
		StopSpawning();

	else if(MaxSpawn > 0 && BotRemaining >= MaxSpawn)
		StopSpawning();

	else if(SpawnInterval <= 0)
		StartSpawning();

}

function Actor RateBestSpawn(class<Pawn> PawnClass)
{
	local float CurrentRate,BestRate;
	local Actor CurrentSpawn,BestSpawn;
	local Pawn Others;

	if(CurrentRate < 0)
		return None;

	foreach SpawnPoints(CurrentSpawn)
	{
		CurrentRate = (FRand() + 5.f);

		ForEach WorldInfo.AllPawns(class'Pawn', Others)
		{
			if(Others.Health <= 0)
				continue;

			if ((Abs(CurrentSpawn.Location.Z - Others.Location.Z) < PawnClass.Default.CylinderComponent.CollisionHeight + Others.CylinderComponent.CollisionHeight) 
					&& (VSize2D(CurrentSpawn.Location - Others.Location) < PawnClass.Default.CylinderComponent.CollisionRadius + Others.CylinderComponent.CollisionRadius))
			{
				CurrentRate = -10.f;
				Break;
			}

			if( Rx_Controller(Others.Controller) != None && Others.Controller.CanSeeByPoints(Others.Location, CurrentSpawn.Location, Others.Rotation))
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

function NotifyPawnDeath (Rx_Bot_Scripted_Customizeable B)
{

	BotRemaining = Max(0,BotRemaining - 1);

	if(bActive && (SpawnNumber <= 0 || (SpawnNumber > SpawnedBotNumber && SpawnNumber > 0)))
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


	for (S=Rx_SquadAI_Scripted(Rx_TeamAI(Rx_Game(WorldInfo.Game).Teams[TeamIndex].AI).ScriptedSquads); S!=None; S=Rx_SquadAI_Scripted(S).NextScriptedSquad )
	{
		if(Rx_SquadAI_Scripted(S) == None)
			continue;

		if(Rx_SquadAI_Scripted(S).SquadID == SquadID)
			return Rx_SquadAI_Scripted(S);
	}

	return none;
}

function bool DoTaskFor (Rx_Bot_Scripted_Customizeable B)
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

function OnModifySpawn (Rx_SeqAct_ScriptedBotModifySpawnValues Action)
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
	bInvulnerableBots = Action.bInvulnerableBots;

	Skill = Action.Skill;

	DamageDealtModifier = Action.DamageDealtModifier;
	DamageTakenModifier = Action.DamageTakenModifier;
	SpeedModifier = Action.SpeedModifier;
}


function OnChangeObjective(Rx_SeqAct_ScriptedBotChangeObjective Action)
{
	local SeqVar_Object ObjVar;
	local Rx_ScriptedObj NewObjective;
	local Rx_Bot_Scripted_Customizeable B;

	foreach Action.LinkedVariables(class'SeqVar_Object', ObjVar, "New Objective")
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
		foreach MyBots(B)
		{
			B.MyObjective = SquadObjective;
		}
	}

}

simulated function byte GetTeamNum()
{
	return TeamIndex;
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

	DamageDealtModifier = 1.f
	DamageTakenModifier = 1.f
	SpeedModifier = 1.f
	Skill = 5.f
/*
	RemoteRole            = ROLE_SimulatedProxy
	bAlwaysRelevant     = True
	bGameRelevant       = True
	bOnlyDirtyReplication = True
	
	NetUpdateFrequency=10.0

*/
}