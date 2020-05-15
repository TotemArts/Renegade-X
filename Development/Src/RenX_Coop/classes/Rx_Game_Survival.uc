class Rx_Game_Survival extends Rx_Game_Cooperative
	config(Survival);

var int RemainingEnemy;
var int TotalEnemyInCurrentWave;
var Array<Rx_Bot_Survival> CurrentEnemies;
var int WaveNumber;
var config float TimeBeforeCountdown;
var config float WaveGraceTime;
var config int MaximumEnemy;
var config bool bHardcoreMode;
var config float HardcoreDamageTakenMult;
var Rx_MapInfo_Survival SurvivalInfo;

var int WaveCountdown;
var Array<Rx_SurvivalSpawner> Spawners;

var Array<Controller> KilledPlayerList;

/*REWARD MECHANIC */
var config float BaseWaveCreditsReward;
var config float BaseWaveCPReward;
var config float BaseWaveVPReward;

/*FRUSTRATION MECHANIC*/

// baseline

var float FrustrationMeter; //if this goes high, players go kaput
var config bool bEnableFrustration;
var config float FrustrationVentInterval; // This is the time an attempt to 'vent' is made
var config float FrustrationCoolOffTimer;
var config float FrustrationFailureChance;

// increments/decrements

var config int FrustrationBuildUpStartWave; // This is the wave that the Frustration meter builds up on its' own
var config float FrustrationBuildUpMult;
var config float FrustrationBuildDownMult;
var config float FrustrationInfKillIncrement;
var config float FrustrationVehKillIncrement;
var config float FrustrationPlayerKillDecrement;
var config float FrustrationWaveClearIncrement;
var config float FrustrationWaveClearDecrement;

struct SpawnInfo
{
	var() class<Rx_FamilyInfo> InfantryClass;
	var() class<Rx_Vehicle> VehicleClass;
	var() Int Number;
	var() float DamageTakenMultiplier;
	var() float DamageDealtMultiplier;
	var() bool bIsBoss;

	structdefaultproperties
	{
		DamageTakenMultiplier=1.f
		DamageDealtMultiplier=1.f
	}
};	

var Array<SpawnInfo> CurrentWaveSpawns;
var Array<Rx_BuildingObjective> BuildingObjectives;

var int AllBuildingHealth;
var bool bIsWaveActive;

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

function HandleScriptedDeath(Rx_Bot_Scripted B)
{
	if(Rx_Bot_Survival(B) != None && B.GetTeamNum() != GetPlayerTeam())
		NotifyEnemyDeath(Rx_Bot_Survival(B));

	super.HandleScriptedDeath(B);	
}

function CheckBuildingsDestroyed(Actor destroyedBuilding, Rx_Controller StarPC)
{
	local BuildingCheck Check;
	local Rx_CoopObjective O;

	if (Role == ROLE_Authority && destroyedBuilding.GetTeamNum() == GetPlayerTeam())
	{
		CurrentBuildingVPModifier[GetPlayerTeam()] +=0.5;

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

	if(bHardcoreMode && injured.Controller != None && injured.Controller.bIsPlayer && HardcoreDamageTakenMult > 0)
		Damage *= HardcoreDamageTakenMult;

	TempDifficulty = WorldInfo.Game.GameDifficulty;
	WorldInfo.Game.GameDifficulty = 5.0;
	super(UTTeamGame).ReduceDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType,DamageCauser);
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
	if(bEnableFrustration)
		SetTimer(FMax(0.1,FrustrationVentInterval),true,nameof(VentFrustration));
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

		Spawns.DamageDealtMultiplier = CalculateSpawnMod(SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].DamageDealtMultiplier,SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].PerPlayerDamageDealtMod);
		Spawns.DamageTakenMultiplier = CalculateSpawnMod(SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].DamageTakenMultiplier,SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].PerPlayerDamageTakenMod);
		Spawns.bIsBoss				 = SurvivalInfo.Wave[WaveNumber].InfantryWaves[i].bIsBoss;
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

		Spawns.DamageDealtMultiplier = CalculateSpawnMod(SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].DamageDealtMultiplier, SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].PerPlayerDamageDealtMod);
		Spawns.DamageTakenMultiplier = CalculateSpawnMod(SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].DamageTakenMultiplier, SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].PerPlayerDamageTakenMod);
		Spawns.bIsBoss				 = SurvivalInfo.Wave[WaveNumber].VehicleWaves[i].bIsBoss;

		CurrentWaveSpawns.AddItem(Spawns);
	}

}

function int CalculateSpawnNumber(int BaseNumber, float Multiplier)
{
	local int PlayerMultiplier;

	PlayerMultiplier = FFloor(Multiplier * Teams[GetPlayerTeam()].Size * 0.75);
	if(PlayerMultiplier <= 0)
		return BaseNumber;

	return BaseNumber * PlayerMultiplier;
}

function float CalculateSpawnMod(float BaseMod, float Multiplier)
{
	local float Modifier;

	if(Teams[GetPlayerTeam()].Size <= 1)
		return BaseMod;

	Modifier = Multiplier ** (Teams[GetPlayerTeam()].Size - 1);

	return BaseMod * Modifier;	
}

function StartWaveCountdown()
{
	WaveCountdown = 5;
	WaveCount();
	SetTimer(1.0,true,'WaveCount');
}

function WaveCount()
{
	if(bGameEnded)
	{
		ClearTimer('WaveCount');
		bIsWaveActive = false;
	}
	else
	{
		if(WaveCountdown > 0)
		{
			CTextBroadcast(255,"Next Wave in"@WaveCountdown,,30);
			WaveCountdown -= 1;
		}
		else
		{
			StoreAllBuildingHealth();
			InitializeWave();	// we do it here so any newcomers when the countdown is over will be considered
			ClearTimer('WaveCount');
			SetTimer(1.0, true, 'BatchSpawn');
			bIsWaveActive = true;
			ActivateWaveSeqEvent(true);
		}
	}
}

function BatchSpawn()
{
	local Rx_SurvivalSpawner SpawnpointCounter, S;
	local int i;
	local Array<Rx_SurvivalSpawner> TempSpawnList;

	if(bGameEnded)
	{
		ClearTimer('BatchSpawn');
		return;
	}

	TempSpawnList = Spawners;

	foreach Spawners(SpawnpointCounter) // considering that the temp array has the same length at start, I think it's fine to keep utilizing this. Also this means it won't disturb the spawner
	{
		if(CurrentWaveSpawns.Length <= 0 || SurvivalInfo == None || (RemainingEnemy >= MaximumEnemy && MaximumEnemy > 0))
		{
			ClearTimer('BatchSpawn');
			return;
		}

		S = TempSpawnList[Rand(TempSpawnList.Length)];

		TempSpawnList.RemoveItem(S); // remove from the temporary list as we go...
		i = Rand(CurrentWaveSpawns.Length);

		if(CurrentWaveSpawns[i].VehicleClass == None)
		{
			if(!CanSpawnHere(class'Rx_Pawn_Scripted', S))
				continue;

			if(!SpawnInfantry(CurrentWaveSpawns[i].InfantryClass, S, CurrentWaveSpawns[i].DamageTakenMultiplier, CurrentWaveSpawns[i].DamageDealtMultiplier,CurrentWaveSpawns[i].bIsBoss))
				continue;
		}
		else
		{
			if(!CanSpawnHere(CurrentWaveSpawns[i].VehicleClass, S))
				continue;

			if(!SpawnVehicle(CurrentWaveSpawns[i].VehicleClass, S, CurrentWaveSpawns[i].DamageTakenMultiplier, CurrentWaveSpawns[i].DamageDealtMultiplier,CurrentWaveSpawns[i].bIsBoss))
				continue;
		}

		CurrentWaveSpawns[i].Number -= 1;

		if(CurrentWaveSpawns[i].Number <= 0)
			CurrentWaveSpawns.Remove(i,1);
		
		TotalEnemyInCurrentWave++;
		RemainingEnemy++;

	}
}

function bool SpawnInfantry(class<Rx_FamilyInfo> InfClass, Rx_SurvivalSpawner Spawner, float DamageTakenModifier, float DamageDealtModifier, bool bIsBoss)
{
	local Rx_Bot_Survival B;
	local Rx_Pawn_Scripted P;
	local Rx_TeamAI TeamAI;

	TeamAI = Rx_TeamAI(Teams[1-GetPlayerTeam()].AI);

	if(Spawner == None)
	{
		`log(Self@"Missing Spawnpoints. Abort Spawning");
		return false;
	}

	P = Spawn(class'Rx_Pawn_Scripted',,,Spawner.location,Spawner.rotation);

	if(P == None)
		return false;

	P.TeamNum = 1 - GetPlayerTeam();
	B = Spawn(class'Rx_Bot_Survival',P);
	B.SetOwner(None);
	SetTeam(B, Teams[1 - GetPlayerTeam()], false);
	B.Possess(P,false);
	B.DamageTakenModifier = DamageTakenModifier;
	B.DamageDealtModifier = DamageDealtModifier;
	B.bIsBoss = bIsBoss;

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
	B.Enemy = None;

	CurrentEnemies.AddItem(B);
	return true;

}

function bool SpawnVehicle(class<Rx_Vehicle> VehClass, Rx_SurvivalSpawner Spawner, float DamageTakenModifier, float DamageDealtModifier, bool bIsBoss)
{
	local Rx_Bot_Survival B;
	local Rx_Vehicle V;
	local Rx_Pawn_Scripted P;
	local Rx_TeamAI TeamAI;
	local Vector PawnLoc;

	TeamAI = Rx_TeamAI(Teams[1-GetPlayerTeam()].AI);

	if(Spawner == None)
	{
		`log(Self@"Missing Spawnpoints. Abort Spawning");
		return false;
	}

	V = Spawn(VehClass,,,Spawner.location,Spawner.rotation);

	if(V == None)
		return false;

	PawnLoc = V.Location;
	PawnLoc.z += 1000;

	P = Spawn(class'Rx_Pawn_Scripted',,,PawnLoc,Spawner.rotation);

	if(P == None)
	{
		V.Destroy();
		return false;
	}

	P.TeamNum = 1 - GetPlayerTeam();
	B = Spawn(class'Rx_Bot_Survival',P);
	B.SetOwner(None);
	SetTeam(B, Teams[1 - GetPlayerTeam()], false);
		
	B.Possess(P,false);
	B.DamageTakenModifier = DamageTakenModifier;
	B.DamageDealtModifier = DamageDealtModifier;
	b.bIsBoss = bIsBoss;

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

		V.SetTeamNum(1 - GetPlayerTeam());
		B.BoundVehicle = V;
		V.DriverEnter(P);
	}

	B.UpdateModifiedStats();

	B.Skill = WorldInfo.Game.GameDifficulty;
	B.ResetSkill();
	B.Enemy = None;

	CurrentEnemies.AddItem(B);
	return true;

}
function bool CanSpawnHere(class<Pawn> PawnClass, Rx_SurvivalSpawner CurrentSpawn)
{
	local Pawn Others;

	if(CurrentSpawn.bInfantryOnly && PawnClass != class'Rx_Pawn_Scripted')
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
	local Controller C;

	CurrentEnemies.RemoveItem(B);
	RemainingEnemy--;

	if(bGameEnded)
		return;

	if(!IsTimerActive('BatchSpawn'))
	{
		if(RemainingEnemy < MaximumEnemy && CurrentWaveSpawns.Length > 0)
		{
			SetTimer(1.0, true, 'BatchSpawn');
		}
		else if (CurrentWaveSpawns.Length <= 0)
		{
			if(RemainingEnemy <= 0)
			{
				if(!bIsWaveActive)
					return;

				ActivateWaveSeqEvent(false);

				WaveNumber++;

				if(SurvivalInfo.Wave.Length <= WaveNumber)
				{
					EndRxGame("Successful Defense",GetPlayerTeam());
				}
				else
				{
					CTextBroadcast(255,"Wave"@WaveNumber@"CLEAR!",'Green',120);
					RewardPlayers();
					if(WaveGraceTime > 0)
					{
						Rx_GRI_Survival(GameReplicationInfo).TimeUntilNextWave = WaveGraceTime + 5.f;
						SetTimer(WaveGraceTime, false, 'StartWaveCountdown');
					}

					else
					{
						StartWaveCountdown();
						Rx_GRI_Survival(GameReplicationInfo).TimeUntilNextWave = 5.f;
					}

					Rx_GRI_Survival(GameReplicationInfo).WaveNumber = WaveNumber + 1;
				}

				TotalEnemyInCurrentWave = 0;
				CurrentEnemies.length = 0;
				Rx_GRI_Survival(WorldInfo.GRI).bNearWaveEnd = false;
				bIsWaveActive = false;
				ClearTimer('CleanUpBots');
				if(KilledPlayerList.Length > 0)
				{
					foreach KilledPlayerList(C)
					{
						RestartPlayer(C);
					}

					KilledPlayerList.Length = 0;
				}
			}

			else 
			{
				if(!IsTimerActive('CleanUpBots') && RemainingEnemy < Round(TotalEnemyInCurrentWave * 0.15))
				{
					SetTimer(10.0, true, 'CleanUpBots');
					
				}
				if(RemainingEnemy <= Max(Round(TotalEnemyInCurrentWave * 0.15),2))
				{
					Rx_GRI_Survival(WorldInfo.GRI).bNearWaveEnd = true;
				}
			}
		}
	}
}

function RestartPlayer(Controller NewPlayer)
{
	if(bHardcoreMode && bIsWaveActive && Rx_PRI_Survival(NewPlayer.PlayerReplicationInfo) != None && Rx_PRI_Survival(NewPlayer.PlayerReplicationInfo).bOverrun)
		return;

	super.RestartPlayer(NewPlayer);

	if(Rx_PRI_Survival(NewPlayer.PlayerReplicationInfo) != None)
		Rx_PRI_Survival(NewPlayer.PlayerReplicationInfo).bOverrun = false;
}

function CleanUpBots()
{
	local Rx_Bot_Survival B;

	foreach CurrentEnemies(B)
	{
		if (B.Pawn.PlayerCanSeeMe() || B.bIsBoss)
			return;
	}

	foreach CurrentEnemies(B)
	{
		if(Vehicle(B.Pawn) != None)
			Vehicle(B.Pawn).TakeDamage(10000, none, B.Pawn.Location, vect(0,0,1), class'UTDmgType_LinkBeam');
		else
			B.Pawn.Suicide();
	}
}

function ActivateWaveSeqEvent(bool bStarted) // if not started, then it's finished
{
	local Sequence GameSeq;
	local array<SequenceObject> AllSeqEvents;
	local array<int> ActivateIndices;
	local int i;
	local Rx_SeqEvent_WaveEvent WE;
	local SeqVar_Int IntVar;

	// reset Kismet and activate any Level Reset events
	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		// reset the game sequence
		GameSeq.Reset();

		// find any Level Loaded events that exist
		GameSeq.FindSeqObjectsByClass(class'Rx_SeqEvent_WaveEvent', true, AllSeqEvents);

		// activate them
		if(bStarted)
			ActivateIndices[0] = 2;
		else
			ActivateIndices[1] = 2;

		for (i = 0; i < AllSeqEvents.Length; i++)
		{
			WE = Rx_SeqEvent_WaveEvent(AllSeqEvents[i]);

			if(WE != None && WE.CheckActivate(WorldInfo, None, false, ActivateIndices))
			{
				foreach WE.LinkedVariables(class'SeqVar_Int', IntVar, "WaveNumber")
				{
						IntVar.IntValue = WaveNumber;
				}
			}
		}
	}
}


function EndRxGame(string Reason, byte WinningTeamNum )
{
//	local PlayerReplicationInfo PRI;
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
			{
				if (c.GetTeamNum() == 0)
					GDICount++;
				else if (c.GetTeamNum() == 1)
					NodCount++;

			}

			StatAPI.GameEnd(string(Rx_TeamInfo(Teams[TEAM_GDI]).GetDisplayRenScore()), string(Rx_TeamInfo(Teams[TEAM_NOD]).GetDisplayRenScore()), string(GDICount), string(NodCount), int(WinningTeamNum), Reason);
			ClearTimer('GameUpdate');
		}
		
		// Store score
/*		foreach WorldInfo.GRI.PRIArray(pri)
			if (Rx_PRI(pri) != None)
			{
				Rx_PRI(pri).OldRenScore = CalcPlayerScoreThisMatch(Rx_PRI(pri));
			}
*/
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

function RewardPlayers()
{
	local float Bonus;
	local string BonusString;
	local Rx_Controller PC;

	Bonus = GetBuildingArmorAward();
	if(Bonus > 2)
		BonusString = "PERFECT Defense";
	else if(Bonus > 1.5)
		BonusString = "Great Defense";
	else if(Bonus > 1)
		BonusString = "Okay Defense";

	if(BaseWaveCreditsReward > 0.0)
		GiveTeamCredits(BaseWaveCreditsReward * WaveNumber * Bonus,GetPlayerTeam());
	if(Bonus > 1)
	{
		if(BaseWaveCPReward > 0.0)
			Rx_TeamInfo(Teams[GetPlayerTeam()]).AddCommandPoints(BaseWaveCPReward * WaveNumber * Bonus,BonusString$"&" $ 100.f * WaveNumber * Bonus$ "&");
		
		if(BaseWaveVPReward > 0.0)
		{
			foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
			{
				if(PC.GetTeamNum() != GetPlayerTeam())
					continue;

				PC.DisseminateVPString("["$BonusString$"]&" $ (BaseWaveVPReward * Bonus) $ "&");
			}	
		}
	}

	else
		Rx_TeamInfo(Teams[GetPlayerTeam()]).AddCommandPoints(100.f * WaveNumber,"Survived&" $ 100.f * WaveNumber * Bonus$ "&");

	if(Bonus > 1.5)
		FrustrationMeter += FMax(0.0, FrustrationWaveClearIncrement) * Bonus;
	else
		FrustrationMeter -= FMax(0.0, FrustrationWaveClearDecrement) / FMax(1,Bonus);
}

function float GetBuildingArmorAward()
{
	local Rx_Building B;
	local int TotalMaxArmor;
	local int TotalArmor;
	local int TotalHealth;

	foreach AllActors(class'Rx_Building',B)
	{
		if(B.GetTeamNum() != GetPlayerTeam() || Rx_Building_Techbuilding(B) != None)
			continue;

		if(B.GetMaxArmor() > 0)
		{
			TotalMaxArmor += B.GetMaxArmor();
			TotalArmor += B.GetArmor();
		}
		else
		{
			TotalMaxArmor += B.GetMaxHealth();
			TotalArmor += B.GetHealth();			
		}

		TotalHealth += B.GetHealth();
	}
	if(TotalArmor / TotalMaxArmor >= 1 && TotalHealth >= AllBuildingHealth)
	{
		return 3.f;
	}
	else if(float(TotalArmor) / float(TotalMaxArmor) >= 0.8)
	{
		return 2.f;
	}
	else if(float(TotalArmor) / float(TotalMaxArmor) >= 0.5)
	{
		return 1.5;
	}
	else
	{
		return 1;
	}
}

function StoreAllBuildingHealth()
{
	local Rx_Building B;


	AllBuildingHealth = 0;
	foreach AllActors(class'Rx_Building',B)
	{
		if(B.GetTeamNum() != GetPlayerTeam() || Rx_Building_Techbuilding(B) != None)
			continue;


		AllBuildingHealth += B.GetHealth();			

	}	
}

State MatchInProgress
{
	function BeginState( Name PreviousState )
	{
		super.BeginState(PreviousState);
		
		if(TimeBeforeCountdown > 0)
		{
			Rx_GRI_Survival(GameReplicationInfo).TimeUntilNextWave = TimeBeforeCountdown + 5;
			SetTimer(TimeBeforeCountdown,false,'StartWaveCountdown');
		}
		else
		{
			StartWaveCountdown();
			Rx_GRI_Survival(GameReplicationInfo).TimeUntilNextWave = 5.f;
		}
	}
}

// 'Venting' mechanic

function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
	if(bEnableFrustration && KilledPlayer != None)
	{
		if(Rx_PRI(KilledPlayer.PlayerReplicationInfo) != None 
			&& KilledPlayer.GetTeamNum() == GetPlayerTeam() 
			&& Killer != None && Killer.GetTeamNum() != GetPlayerTeam())
		{
			FrustrationMeter -= FMax(0.0,FrustrationPlayerKillDecrement) * FMin(WaveNumber, 4); // lower frustration if the player gets killed by an enemy
		}

		if(KilledPlayer.GetTeamNum() != GetPlayerTeam())
		{
			if(Vehicle(KilledPawn) != None)
				FrustrationMeter += FMax(0.0,FrustrationVehKillIncrement);

			else
				FrustrationMeter += FMax(0.0,FrustrationInfKillIncrement);
		}
	}

	super.Killed(Killer,KilledPlayer,KilledPawn,damageType);

	if(bHardcoreMode && KilledPlayer != None && KilledPlayer.GetTeamNum() == GetPlayerTeam() && Rx_Pawn(KilledPawn) != None && Rx_Pawn_Scripted(KilledPawn) == None)
	{
		if(PlayerController(KilledPlayer) != None)
			KilledPlayer.GoToState('Spectating');

		KilledPlayerList.AddItem(KilledPlayer);
		if(Rx_PRI_Survival(KilledPlayer.PlayerReplicationInfo) != None)
			Rx_PRI_Survival(KilledPlayer.PlayerReplicationInfo).bOverrun = true;

		if(Rx_Controller(KilledPlayer) != None)
			Rx_Controller(KilledPlayer).CTextMessage("YOU'RE DEAD! You'll respawn at the end of the wave...",'Red',180,,false,true);
		CTextBroadcast(255,KilledPlayer.PlayerReplicationInfo.PlayerName@"is overrun!",'Red',120);
	}

}

function Tick(float DeltaTime)
{
	super.Tick(deltaTime);

	if(bEnableFrustration)
	{
		if(!IsTimerActive(nameof(FrustrationCoolOff)) && bIsWaveActive && WaveNumber >= FrustrationBuildUpStartWave)
		{
			FrustrationMeter += (DeltaTime * FrustrationBuildUpMult * (WaveNumber + 1));
		}

		else if(IsTimerActive(nameof(FrustrationCoolOff)))
		{
			FrustrationMeter -= (DeltaTime * FrustrationBuildDownMult);
		}

		FrustrationMeter = FMax(0,FrustrationMeter);
	}
}

function VentFrustration()	//if the you are doing TOO well in surviving, the hand of God shall smite thee
{
	if(!bEnableFrustration || !bIsWaveActive || FrustrationMeter < 40 || IsTimerActive('FrustrationCoolOff') || FRand() <= FMin(FrustrationFailureChance, 0.99))
		return;

	if(FRand() > 0.5 && AttemptVent(250))
	{
		return;
	}
	else if(FRand() > 0.25 && AttemptVent(150))
	{
		return;
	}
	else if(FRand() > 0.5 && AttemptVent(60))
	{
		return;
	}
	else if(FRand() > 0.75 && AttemptVent(20))
	{
		return;
	}
}

function bool AttemptVent(float Cost)
{
	local Actor VentTarget;
	local Rotator FlatYaw;

	if(FrustrationMeter < Cost || !bEnableFrustration)
		return false;

	if(Cost >= 250)
	{
		VentTarget = AcquireVentTarget(2);
		if(VentTarget == None)
			return false;

		FlatYaw.Yaw = VentTarget.Rotation.Yaw;

		VentByCruise(VentTarget.Location, FlatYaw);
	}
	else if(Cost >= 150)
	{
		VentTarget = AcquireVentTarget(1);
		if(VentTarget == None)
			return false;

		VentByAirstrike(VentTarget.Location);
	}
	else if(Cost >= 60)
	{
		VentTarget = AcquireVentTarget(0);
		if(VentTarget == None)
			return false;

		FlatYaw.Yaw = VentTarget.Rotation.Yaw;

		VentByEMP(VentTarget.Location, FlatYaw);
	}
	else if(Cost >= 20)
	{
		VentTarget = AcquireVentTarget(3);
		if(VentTarget == None)
			return false;

		FlatYaw.Yaw = VentTarget.Rotation.Yaw;

		VentBySmoke(VentTarget.Location, FlatYaw);
	}

	FrustrationMeter -= Cost;
	if(FrustrationCoolOffTimer > 0.0)
		SetTimer(FrustrationCoolOffTimer,false,nameof(FrustrationCoolOff));

	return true;
}

function Actor AcquireVentTarget(int Type) // 0 : EMP, 1 : Airstrike, 2 : Cruise
{
	local int Randomizer;

	if(Type == 0)
	{
		return AcquireVentCrowd(true,false,class'Rx_CommanderSupport_Beaconinfo_EMPMissile');
	}
	else if(Type == 1)
	{
		Randomizer = Rand(2);
		if(Randomizer == 1)
			return AcquireVentCrowd(false,true);
		else
			return AcquireHighValuable(false,true);

	}
	else if(Type == 2)
	{
		Randomizer = Rand(2);
		if(Randomizer == 1)
			return AcquireVentCrowd(false,true,class'Rx_CommanderSupport_Beaconinfo_CruiseMissile');
		else
			return AcquireHighValuable(false,true,class'Rx_CommanderSupport_Beaconinfo_CruiseMissile');
	}
	else if(Type == 3)
	{
		Randomizer = Rand(2);
		if(Randomizer == 1)
			return AcquireVentCrowd(false,true,class'Rx_CommanderSupport_Beaconinfo_SmokeDrop');
		else
			return AcquireHighValuable(false,true,class'Rx_CommanderSupport_Beaconinfo_SmokeDrop');
	}

	return None;
}

function Actor AcquireVentCrowd(bool bVehicleOnly, bool bCanTraceToRoof, optional class<Rx_CommanderSupport_BeaconInfo> BeaconInfo)
{
	local Pawn P;
	local PlayerReplicationInfo pri;
	local int CurrentCrowdNum, BestCrowdNum;
	local Actor CurrentActor, BestActor;
	local Rotator FlatYaw;

	foreach WorldInfo.GRI.PRIArray(pri)
	{
		if(Rx_PRI(pri) == None)
			continue;

		if(Controller(pri.Owner).Pawn == None || (bVehicleOnly && Rx_Vehicle(Controller(pri.Owner).Pawn) == None))
			continue;

		CurrentActor = Controller(pri.Owner).Pawn;

		FlatYaw.yaw = CurrentActor.Rotation.Yaw;

		if(!bCanTraceToRoof && !CurrentActor.FastTrace(CurrentActor.Location, CurrentActor.Location * vect(1.0,1.0,100000.0)))
			continue;

		if(BeaconInfo != None && !BeaconInfo.static.IsEntryVectorClear(CurrentActor.Location,FlatYaw, CurrentActor))
			continue;

		CurrentCrowdNum = 0;

		foreach WorldInfo.AllPawns(class'Pawn', P, CurrentActor.Location, 3000)
		{
			if(P.GetTeamNum() == GetPlayerTeam() && (!bVehicleOnly || Rx_Vehicle(P) != None))
				CurrentCrowdNum++;
		}
		if(BestActor == None || CurrentCrowdNum > BestCrowdNum)
		{
			BestActor = CurrentActor;
			BestCrowdNum = CurrentCrowdNum;
		}
	}
	if(BestActor != None)
		return BestActor;

	return none;
}

function Actor AcquireHighValuable(bool bVehicleOnly, bool bCanTraceToRoof, optional class<Rx_CommanderSupport_BeaconInfo> BeaconInfo)
{
	local PlayerReplicationInfo pri;
	local int CurrentScore, BestScore;
	local Actor CurrentActor, BestActor;
	local Rotator FlatYaw;

	foreach WorldInfo.GRI.PRIArray(pri)
	{
		if(Rx_PRI(pri) == None)
			continue;

		if(Controller(pri.Owner).Pawn == None || (bVehicleOnly && Rx_Vehicle(Controller(pri.Owner).Pawn) == None))
			continue;

		CurrentActor = Controller(pri.Owner).Pawn;

		if(!bCanTraceToRoof && !CurrentActor.FastTrace(CurrentActor.Location, CurrentActor.Location * vect(1.0,1.0,100000.0)))
			continue;

		FlatYaw.yaw = CurrentActor.Rotation.Yaw;

		if(BeaconInfo != None && !BeaconInfo.static.IsEntryVectorClear(CurrentActor.Location,FlatYaw, CurrentActor))
			continue;

		CurrentScore = Rx_PRI(pri).GetRenScore();

		if(BestActor == None || CurrentScore > BestScore)
		{
			BestScore = CurrentScore;
			BestActor = CurrentActor;
		}

	}
	if(BestActor != None)
		return BestActor;

	return none;
}

function VentByCruise(vector PowerLocation, Rotator PowerRotation)
{
	local Rx_CommanderSupportBeacon SB;

	if(GetPlayerTeam() == 1) 
		SB=spawn(class'Rx_CommanderSupportBeacon_GDI',,,PowerLocation,PowerRotation,, true); 
	else
		SB=spawn(class'Rx_CommanderSupportBeacon_Nod',,,PowerLocation,PowerRotation,, true); 

	SB.Init(1 - GetPlayerTeam(), class'Rx_CommanderSupport_Beaconinfo_CruiseMissile', none);	
}

function VentByEMP(vector PowerLocation, Rotator PowerRotation)
{
	local Rx_CommanderSupportBeacon SB;

	if(GetPlayerTeam() == 1) 
		SB=spawn(class'Rx_CommanderSupportBeacon_GDI',,,PowerLocation,PowerRotation,, true); 
	else
		SB=spawn(class'Rx_CommanderSupportBeacon_Nod',,,PowerLocation,PowerRotation,, true); 

	SB.Init(1 - GetPlayerTeam(), class'Rx_CommanderSupport_Beaconinfo_EMPMissile', none);	
}

function VentBySmoke(vector PowerLocation, Rotator PowerRotation)
{
	local Rx_CommanderSupportBeacon SB;

	if(GetPlayerTeam() == 1) 
		SB=spawn(class'Rx_CommanderSupportBeacon_GDI',,,PowerLocation,PowerRotation,, true); 
	else
		SB=spawn(class'Rx_CommanderSupportBeacon_Nod',,,PowerLocation,PowerRotation,, true); 

	SB.Init(1 - GetPlayerTeam(), class'Rx_CommanderSupport_Beaconinfo_SmokeDrop', none);	
}

function VentByAirstrike(vector AirstrikeLocation)
{
	local Rx_Airstrike as;

	as = Spawn(class'Rx_Airstrike', None, , AirstrikeLocation, rot(0,0,0), , false);
	if(GetPlayerTeam() == 0)	
		as.Init(class'Rx_Airstrike_AC130');

	else
		as.Init(class'Rx_Airstrike_A10');

}

function FrustrationCoolOff();

DefaultProperties
{
	PurchaseSystemClass        = class'Rx_PurchaseSystem_Survival'
	VehicleManagerClass        = class'Rx_VehicleManager_Survival'
	TeamAIType(0)              = class'Rx_TeamAI_Survival'
	TeamAIType(1)              = class'Rx_TeamAI_Survival'

	HudClass                   = class'Rx_HUD_Survival'

	GameReplicationInfoClass   = class'Rx_GRI_Survival'
	PlayerReplicationInfoClass = class'Rx_PRI_Survival'

}