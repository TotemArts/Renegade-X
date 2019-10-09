class Rx_Game_Survival extends Rx_Game_Cooperative
	config(Survival);

var int RemainingEnemy;
var int WaveNumber;
var config float TimeBeforeCountdown;
var config float WaveGraceTime;
var config int MaximumEnemy;
var Rx_MapInfo_Survival SurvivalInfo;

var int WaveCountdown;
var Array<Rx_SurvivalSpawner> Spawners;

struct SpawnInfo
{
	var() class<Rx_FamilyInfo> InfantryClass;
	var() class<Rx_Vehicle> VehicleClass;
	var() Int Number;
	var() float DamageTakenMultiplier;
	var() float DamageDealtMultiplier;

	structdefaultproperties
	{
		DamageTakenMultiplier=1.f
		DamageDealtMultiplier=1.f
	}
};	

var Array<SpawnInfo> CurrentWaveSpawns;
var Array<Rx_BuildingObjective> BuildingObjectives;

function PreBeginPlay()
{
	local Rx_BuildingObjective O;

	super.PreBeginPlay();

	foreach WorldInfo.AllActors(class'Rx_BuildingObjective', O)
	{
		if(O.myBuilding.GetTeamNum() == GetPlayerTeam())
			BuildingObjectives.AddItem(O);
	}
}

function CheckBuildingsDestroyed(Actor destroyedBuilding, Rx_Controller StarPC)
{
	local BuildingCheck Check;
	local Rx_CoopObjective O;

	if (Role == ROLE_Authority && destroyedBuilding.GetTeamNum() == GetPlayerTeam())
	{
		CurrentBuildingVPModifier +=0.5;

		if(Rx_Building(destroyedBuilding).bSignificant)
		{
			Check = CheckBuildings();
			if (Check == BC_GDIDestroyed || Check == BC_NodDestroyed || Check == BC_TeamsHaveNoBuildings)
			{
				if(Check == BC_GDIDestroyed)
					EndRxGame("Buildings",TEAM_NOD);
				else if(Check == BC_NodDestroyed)
					EndRxGame("Buildings",TEAM_GDI); 	
				else 
					EndRxGame("Buildings",255);
			}
		}

	}

	if(Rx_Building(destroyedBuilding).myObjective != None)
	{
		foreach CoopObjectives(O)
		{
			if(Rx_CoopObjective_DestroyBuilding(O) != None && Rx_CoopObjective_DestroyBuilding(O).myBuildingObjective == Rx_Building(destroyedBuilding).myObjective)
			{
				O.FinishObjective(StarPC);
			}
		}
	}
	
	if(Rx_Building(destroyedBuilding).GetTeamNum() == 0) 
		DestroyedBuildings_GDI++; 
	else
		DestroyedBuildings_Nod++; 
	
}

function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
	local float TempDifficulty;

	if(Rx_Bot_Survival(injured.Controller) != None)
		Damage = Damage * Rx_Bot_Survival(injured.Controller).DamageTakenModifier;

	if(Rx_Bot_Survival(instigatedBy) != None)
		Damage = Damage * Rx_Bot_Survival(instigatedBy).DamageDealtModifier;

	TempDifficulty = WorldInfo.Game.GameDifficulty;
	WorldInfo.Game.GameDifficulty = 5.0;
	super(UTGame).ReduceDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType,DamageCauser);
	WorldInfo.Game.GameDifficulty = TempDifficulty;
}

function BuildingCheck CheckBuildings () 
{
	local Rx_Building B;
	local bool bBuildingExists;
	

	foreach AllActors(class'Rx_Building', B)
	{
		if(Rx_Building_Techbuilding(B) != None || !B.bSignificant || B.GetTeamNum() != GetPlayerTeam() || B.IsDestroyed())
			continue;		
		else
			bBuildingExists = true;

	}

	if(bBuildingExists)
		return BC_TeamsHaveBuildings;

	else if(GetPlayerTeam() == 0)
		return BC_GDIDestroyed;

	else
		return BC_NodDestroyed;
}


function PostBeginPlay()
{
	local Rx_SurvivalSpawner S;

	foreach WorldInfo.AllNavigationPoints(class'Rx_SurvivalSpawner',S)
	{
		Spawners.AddItem(S);
	}

	super.PostBeginPlay();
}

// -- InitializeWave --
// 
// This is where we parse the info from MapInfo so that we don't have to go back and forth

function InitializeWave()
{
	local int i;
	local int BaseNum;
	local float Mult;
	local SpawnInfo Spawns;

	if(SurvivalInfo == None)
	{
		if(Rx_MapInfo_Survival(WorldInfo.GetMapInfo()) != None)
		{
			SurvivalInfo = Rx_MapInfo_Survival(WorldInfo.GetMapInfo());
		}
		else
			return;
	}

	CurrentWaveSpawns.Length = 0;	// empty out the list

	for(i = 0; i < SurvivalInfo.Wave[WaveNumber].InfantryWaves.Length; i++)
	{
		Spawns.InfantryClass = SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].InfantryClass;

		BaseNum = SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].BaseNumber;
		Mult = SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].PerPlayerMultiplier;

		Spawns.Number = CalculateSpawnNumber(BaseNum,Mult);

		Spawns.DamageDealtMultiplier = SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].DamageDealtMultiplier;
		Spawns.DamageTakenMultiplier = SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].DamageTakenMultiplier;

		CurrentWaveSpawns.AddItem(Spawns);
	}

	if(SurvivalInfo.Wave[WaveNumber].VehicleWaves.Length <= 0)
		return;	

	Spawns.InfantryClass = None;

	for(i = 0; i < SurvivalInfo.Wave[WaveNumber].VehicleWaves.Length; i++)
	{
		Spawns.VehicleClass = SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].VehicleClass;

		BaseNum = SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].BaseNumber;
		Mult = SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].PerPlayerMultiplier;

		Spawns.Number = CalculateSpawnNumber(BaseNum,Mult);

		Spawns.DamageDealtMultiplier = SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].DamageDealtMultiplier;
		Spawns.DamageTakenMultiplier = SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].DamageTakenMultiplier;

		CurrentWaveSpawns.AddItem(Spawns);
	}

}

function int CalculateSpawnNumber(int BaseNumber, float Multiplier)
{
	local int PlayerMultiplier;

	PlayerMultiplier = FFloor(Multiplier * Teams[GetPlayerTeam()].Size);
	if(PlayerMultiplier <= 0)
		return BaseNumber;

	return BaseNumber * PlayerMultiplier;
}

function StartWaveCountdown()
{
	WaveCountdown = 5;
	WaveCount();
	SetTimer(1.0,true,'WaveCount');
}

function WaveCount()
{
	if(WaveCountdown > 0)
	{
		CTextBroadcast(255,"Next Wave in"@WaveCountdown,,30);
		WaveCountdown -= 1;
	}
	else
	{
		InitializeWave();	// we do it here so any newcomers when the countdown is over will be considered
		ClearTimer('WaveCount');
		SetTimer(1.0, true, 'BatchSpawn');
	}
}

function BatchSpawn()
{
	local Rx_SurvivalSpawner S;
	local int i;

	foreach Spawners(S)
	{
		if(CurrentWaveSpawns.Length <= 0 || SurvivalInfo == None || (RemainingEnemy >= MaximumEnemy && MaximumEnemy > 0))
		{
			ClearTimer('BatchSpawn');
			return;
		}

		i = Rand(CurrentWaveSpawns.Length);

		if(CurrentWaveSpawns[i].VehicleClass == None)
		{
			if(!CanSpawnHere(class'Rx_Pawn_SurvivalEnemy', S))
				continue;

			if(!SpawnInfantry(CurrentWaveSpawns[i].InfantryClass, S, CurrentWaveSpawns[i].DamageTakenMultiplier, CurrentWaveSpawns[i].DamageDealtMultiplier))
				continue;
		}
		else
		{
			if(!CanSpawnHere(CurrentWaveSpawns[i].VehicleClass, S))
				continue;

			if(!SpawnVehicle(CurrentWaveSpawns[i].VehicleClass, S, CurrentWaveSpawns[i].DamageTakenMultiplier, CurrentWaveSpawns[i].DamageDealtMultiplier))
				continue;
		}

		CurrentWaveSpawns[i].Number -= 1;

		if(CurrentWaveSpawns[i].Number <= 0)
			CurrentWaveSpawns.Remove(i,1);
		
		RemainingEnemy++;

	}
}

function bool SpawnInfantry(class<Rx_FamilyInfo> InfClass, Rx_SurvivalSpawner Spawner, float DamageTakenModifier, float DamageDealtModifier)
{
	local Rx_Bot_Survival B;
	local Rx_Pawn_SurvivalEnemy P;
	local Rx_TeamAI TeamAI;

	TeamAI = Rx_TeamAI(Teams[1-GetPlayerTeam()].AI);

	if(Spawner == None)
	{
		`log(Self@"Missing Spawnpoints. Abort Spawning");
		return false;
	}

	P = Spawn(class'Rx_Pawn_SurvivalEnemy',,,Spawner.location,Spawner.rotation);

	if(P == None)
		return false;

	P.TeamNum = 1 - GetPlayerTeam();
	B = Spawn(class'Rx_Bot_Survival');
	SetTeam(B, Teams[1 - GetPlayerTeam()], false);
	B.Possess(P,false);
	B.DamageTakenModifier = DamageTakenModifier;
	B.DamageDealtModifier = DamageDealtModifier;

	B.SetChar(InfClass, InfClass.default.BasePurchaseCost <= 0);


	if(TeamAI.Squads == None || TeamAI.Squads.Size > 8)
	{
		TeamAI.AddSquadWithLeader(B,BuildingObjectives[Rand(BuildingObjectives.Length)]);
	}
	else
		TeamAI.Squads.AddBot(B);

	B.UpdateModifiedStats();
	B.Skill = WorldInfo.Game.GameDifficulty;
	B.ResetSkill();

	return true;

}

function bool SpawnVehicle(class<Rx_Vehicle> VehClass, Rx_SurvivalSpawner Spawner, float DamageTakenModifier, float DamageDealtModifier)
{
	local Rx_Bot_Survival B;
	local Rx_Vehicle V;
	local Rx_Pawn_SurvivalEnemy P;
	local Rx_TeamAI TeamAI;

	TeamAI = Rx_TeamAI(Teams[1-GetPlayerTeam()].AI);

	if(Spawner == None)
	{
		`log(Self@"Missing Spawnpoints. Abort Spawning");
		return false;
	}

	V = Spawn(VehClass,,,Spawner.location,Spawner.rotation);

	if(V == None)
		return false;

	P = Spawn(class'Rx_Pawn_SurvivalEnemy',,,Spawner.location + (vect(0,0,1) * 10000),Spawner.rotation);

	if(P == None)
		return false;

	P.TeamNum = 1 - GetPlayerTeam();
	B = Spawn(class'Rx_Bot_Survival');
	SetTeam(B, Teams[1 - GetPlayerTeam()], false);
		
	B.Possess(P,false);
	B.DamageTakenModifier = DamageTakenModifier;
	B.DamageDealtModifier = DamageDealtModifier;

	B.SetChar(B.DefaultClass[1-GetPlayerTeam()], true);


	if(TeamAI.Squads == None || TeamAI.Squads.Size > 8)
	{
		TeamAI.AddSquadWithLeader(B,BuildingObjectives[Rand(BuildingObjectives.Length)]);
	}
	else
		TeamAI.Squads.AddBot(B);

	if(V != None)
	{
		V.DropToGround();

		if (V.Mesh != none)
			V.Mesh.WakeRigidBody();

		B.BoundVehicle = V;
	}

	B.UpdateModifiedStats();

	B.Skill = WorldInfo.Game.GameDifficulty;
	B.ResetSkill();

	return true;

}
function bool CanSpawnHere(class<Pawn> PawnClass, Rx_SurvivalSpawner CurrentSpawn)
{
	local Pawn Others;

	if(CurrentSpawn.bInfantryOnly && PawnClass != class'Rx_Pawn_SurvivalEnemy')
	{
		return false;
	}
	else
	{
		ForEach WorldInfo.AllPawns(class'Pawn', Others)
		{
			if(Others.Health <= 0)
				continue;

			if ((Abs(CurrentSpawn.Location.Z - Others.Location.Z) < PawnClass.Default.CylinderComponent.CollisionHeight + Others.CylinderComponent.CollisionHeight) 
				&& (VSize2D(CurrentSpawn.Location - Others.Location) < PawnClass.Default.CylinderComponent.CollisionRadius + Others.CylinderComponent.CollisionRadius))
			{
				return false;
			}

			if(!CurrentSpawn.bIgnoreLOS && Rx_Controller(Others.Controller) != None && Others.Controller.CanSeeByPoints(Others.Location, CurrentSpawn.Location, Others.Rotation))
			{
				return false;
			}
		}
	}

	return true;
}

function NotifyEnemyDeath(Rx_Bot_Survival B)
{
	RemainingEnemy--;

	if(RemainingEnemy < MaximumEnemy && CurrentWaveSpawns.Length > 0 && !IsTimerActive('BatchSpawn'))
	{
		SetTimer(1.0, true, 'BatchSpawn');
	}
	else if(RemainingEnemy <= 0 && CurrentWaveSpawns.Length <= 0)
	{
		if(SurvivalInfo.Wave.Length <= WaveNumber)
		{
			EndRxGame("Successful Defense",GetPlayerTeam());
		}
		else
		{
			WaveNumber++;

			CTextBroadcast(255,"Wave"@WaveNumber@"CLEAR!",'Green',120);

			SetTimer(WaveGraceTime, false, 'StartWaveCountdown');
		}
	}
}

function EndRxGame(string Reason, byte WinningTeamNum )
{
	local PlayerReplicationInfo PRI;
	local Rx_Controller c;
	local int GDICount, NodCount;

	// MPalko: This no longer calles Super(). Was extremely messy, so everything is done right here now.

	//M.Palko endgame crash track log.
	`log("------------------------------EndRxGame called, Reason: " @ Reason @ " Winning Team Num: " @ WinningTeamNum);
	
	
	// Make sure end game is a valid reason, and then verify the game is over.
	//Yosh: Added Surrender on the off chance we can get that built into the flash for the end-game screen
	if ( ((Reason ~= "Buildings") || (Reason ~= "Successful Defense") || (Reason ~= "triggered")) && !bGameEnded) {
		// From super(), manualy integrated.
		bGameEnded = true;
		//EndTime = WorldInfo.RealTimeSeconds + EndTimeDelay;
		EndTime = 0;//WorldInfo.RealTimeSeconds + EndTimeDelay;

		// Allow replication to happen before reporting scores, stats, etc.
		// @Shahman: Ensure that the timer is longer than camera end game delay, otherwise the transition would not be as smooth.
		SetTimer( EndgameCamDelay + 0.5f,false,nameof(PerformEndGameHandling) );

		// Set winning team and endgame reason.
		WinnerTeamNum = WinningTeamNum;
		Rx_GRI(WorldInfo.GRI).WinnerTeamNum = WinnerTeamNum;
		
		//Stop this timer from counting down in the background... whoops >_> 
		if(isTimerActive('PlaySurrenderClockGameOverAnnouncment')) ClearTimer('PlaySurrenderClockGameOverAnnouncment');

		if (WinnerTeamNum == 0 || WinnerTeamNum == 1)
			GameReplicationInfo.Winner = Teams[WinnerTeamNum];
		else
			GameReplicationInfo.Winner = none;

		if(Reason ~= "Successful Defense") 
		{
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "Successful Defense!";
		}
			
		else if(Reason ~= "Buildings") 
		{
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "Overran";
		}

		else if(Reason ~= "triggered") 
		{
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "Base Abandoned";
		}

		// Set everyone's camera focus
		SetTimer(EndgameCamDelay,false,nameof(SetEndgameCam));

		// Send game result to RxLog
		if (WinningTeamNum == TEAM_GDI || WinningTeamNum == TEAM_NOD)
			RxLog("GAME"`s "MatchEnd;"`s "winner"`s GetTeamName(WinningTeamNum)`s  Reason `s"GDI="$Rx_TeamInfo(Teams[TEAM_GDI]).GetDisplayRenScore()`s"Nod="$Rx_TeamInfo(Teams[TEAM_NOD]).GetDisplayRenScore());
		else
			RxLog("GAME"`s "MatchEnd;"`s "tie"`s Reason `s"GDI="$Rx_TeamInfo(Teams[TEAM_GDI]).GetDisplayRenScore()`s"Nod="$Rx_TeamInfo(Teams[TEAM_NOD]).GetDisplayRenScore());

		CalculateEndGameAwards(0); 
		CalculateEndGameAwards(1); 
		AssignAwards(0);
		AssignAwards(1); 

		if (StatAPI != None)
		{
			ForEach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'Rx_Controller', c)
			if (c.GetTeamNum() == 0)
				GDICount++;
			else if (c.GetTeamNum() == 1)
				NodCount++;

			StatAPI.GameEnd(string(Rx_TeamInfo(Teams[TEAM_GDI]).GetDisplayRenScore()), string(Rx_TeamInfo(Teams[TEAM_NOD]).GetDisplayRenScore()), string(GDICount), string(NodCount), int(WinningTeamNum), Reason);
			ClearTimer('GameUpdate');
		}
		
		// Store score
		foreach WorldInfo.GRI.PRIArray(pri)
			if (Rx_PRI(pri) != None)
			{
				Rx_PRI(pri).OldRenScore = CalcPlayerScoreThisMatch(Rx_PRI(pri));
			}

		//M.Palko endgame crash track log.
		`log("------------------------------Triggering game ended kismet events");

		// trigger any Kismet "Game Ended" events
		TriggerKismetGameEnded();

		//@Shahman: Match over state will be called after the camera transition has been made.
	}
}

private function TriggerKismetGameEnded()
{
	local Sequence GameSequence;
	local array<SequenceObject> Events;
	local int i;
	// trigger any Kismet "Game Ended" events
	GameSequence = WorldInfo.GetGameSequence();
	if (GameSequence != None)
	{
		GameSequence.FindSeqObjectsByClass(class'UTSeqEvent_GameEnded', true, Events);
		for (i = 0; i < Events.length; i++)
		{
			UTSeqEvent_GameEnded(Events[i]).CheckActivate(self, None);
		}
	}
}

State MatchInProgress
{
	function BeginState( Name PreviousState )
	{
		super.BeginState(PreviousState);
		
		if(TimeBeforeCountdown > 0)
			SetTimer(TimeBeforeCountdown,false,'StartWaveCountdown');

		else
			StartWaveCountdown();
	}

	function EndState( Name NextStateName )
	{
		super.EndState(NextStateName);
	}
}

DefaultProperties
{
	TeamAIType(0)              = class'Rx_TeamAI_Survival'
	TeamAIType(1)              = class'Rx_TeamAI_Survival'
}