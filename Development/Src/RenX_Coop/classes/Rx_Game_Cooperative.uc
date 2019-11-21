class Rx_Game_Cooperative extends Rx_Game;

var Array<Rx_VehicleSpawnerManager> VehicleSpawnerManagers;

struct PlayerAccount 
{
	var string	PlayersID; /*Added an S just so it doesn't overlap PRI's PlayerID for my own sanity */
	var float		PlayerAggregateScore; // based on Playerscore/VP/Kills-Deaths
};

var Array<PlayerAccount> PlayersArray;
var Array<Rx_CoopObjective> CoopObjectives;


function SpawnVehicleFor(byte VTeam, Rx_VehicleSpawner Spawner)
{
	if(VTeam == 0)
		Rx_VehicleManager_Coop(VehicleManager).SpawnGDIVehicle(Spawner);

	else
		Rx_VehicleManager_Coop(VehicleManager).SpawnNodVehicle(Spawner);
}

function PreBeginPlay()
{
	local Rx_CoopObjective O;

	super.PreBeginPlay();

	foreach WorldInfo.AllActors(class'Rx_CoopObjective', O)
	{
		CoopObjectives.AddItem(O);
	}
}

function int GetPlayerTeam()
{
	if (Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()) == None)
	{
		return 0;
	}
	else
	{
		return Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()).PlayerTeam;
	}	
}

event PostLogin( PlayerController NewPlayer )
{
	local string SteamID, ID;
	local int AvgVeterancy; 
	local PlayerReplicationInfo PRI;
	local int num, index; 
	local Rx_Mutator Rx_Mut;
	local Rx_PRI NewPRI; 

	NewPRI = Rx_Pri(NewPlayer.PlayerReplicationInfo);
	ID = `WorldInfoObject.Game.OnlineSub.UniqueNetIdToString(NewPRI.UniqueId);
	
	SetTeam(NewPlayer, Teams[GetPlayerTeam()], false);

	if(GetPlayerTeam() == TEAM_GDI)
	{
		index = `RxEngineObject.GDIPlayers.Find('PlayersID',ID);

		if (index >= 0)
			NewPRI.OldRenScore = `RxEngineObject.GDIPlayers[index].PlayerAggregateScore;
		else
		{
			`RxEngineObject.AddGDIPlayer(NewPRI);
		}
	}
	else if(GetPlayerTeam() == TEAM_Nod)
	{
		index = `RxEngineObject.NodPlayers.Find('PlayersID',ID);

		if (index >= 0)
			NewPRI.OldRenScore = `RxEngineObject.NodPlayers[index].PlayerAggregateScore;
		else
		{
			`RxEngineObject.AddNodPlayer(NewPRI);
		}
	}
		//`log("Call PostLogin: " @ `RxEngineObject.IsPlayerCommander(NewPlayer.PlayerReplicationInfo));
	if(bUseStaticCommanders && `RxEngineObject.IsPlayerCommander(NewPlayer.PlayerReplicationInfo) ) 
		ChangeCommander(NewPlayer.GetTeamNum(), Rx_PRI(NewPlayer.PlayerReplicationInfo), true); 

	SteamID = OnlineSub.UniqueNetIdToString(NewPlayer.PlayerReplicationInfo.UniqueId);
	if (SteamID == `BlankSteamID || SteamID == "")
		RxLog("PLAYER" `s "Enter;" `s `PlayerLog(NewPlayer.PlayerReplicationInfo) `s "from" `s NewPlayer.GetPlayerNetworkAddress() `s "hwid" `s Rx_Controller(NewPlayer).PlayerUUID `s "nosteam");
	else
		RxLog("PLAYER" `s "Enter;" `s `PlayerLog(NewPlayer.PlayerReplicationInfo) `s "from" `s NewPlayer.GetPlayerNetworkAddress() `s "hwid" `s Rx_Controller(NewPlayer).PlayerUUID `s "steamid"`s SteamID);
	
	AnnounceTeamJoin(NewPlayer.PlayerReplicationInfo, NewPlayer.PlayerReplicationInfo.Team, None, false);

	super(UTTeamGame).PostLogin(NewPlayer);
				
	Rx_Pri(NewPlayer.PlayerReplicationInfo).ReplicatedNetworkAddress = NewPlayer.PlayerReplicationInfo.SavedNetworkAddress;
	Rx_Controller(NewPlayer).RequestDeviceUUID();
	
	if(bDelayedStart) // we want bDelayedStart, but still want players to spawn immediatly upon connect
		RestartPlayer(newPlayer);		
	
	/**Needed anything that happened when a player first joined. If the team is using airdrops, it'll update them correctly **/

	//Nods (Could probably make this cleaner looking, but at the moment I'm just making sure it works)
	if(Rx_Pri(NewPlayer.PlayerReplicationInfo) != None && (Rx_Pri(NewPlayer.PlayerReplicationInfo).GetTeamNum() == TEAM_NOD) && VehicleManager.bNodIsUsingAirdrops)
	{
		if(Rx_Pri(NewPlayer.PlayerReplicationInfo).AirdropCounter == 0)
		{
			Rx_Pri(NewPlayer.PlayerReplicationInfo).AirdropCounter++;
			//Rx_Pri(NewPlayer.PlayerReplicationInfo).LastAirdropTime=WorldInfo.TimeSeconds;
		}
	}
	//Disable veterancy accordingly for surrenders
	if(Rx_Pri(NewPlayer.PlayerReplicationInfo) != None && Rx_Pri(NewPlayer.PlayerReplicationInfo).GetTeamNum() == TEAM_Nod && bNodHasSurrendered)
	{
		Rx_Pri(NewPlayer.PlayerReplicationInfo).DisableVeterancy(true); 	
	}
			
	//GDI 
	if(Rx_Pri(NewPlayer.PlayerReplicationInfo) != None && (Rx_Pri(NewPlayer.PlayerReplicationInfo).GetTeamNum() == TEAM_GDI) && VehicleManager.bGDIIsUsingAirdrops)
	{
		if(Rx_Pri(NewPlayer.PlayerReplicationInfo).AirdropCounter == 0)
		{
			Rx_Pri(NewPlayer.PlayerReplicationInfo).AirdropCounter++;
			//Rx_Pri(NewPlayer.PlayerReplicationInfo).LastAirdropTime=WorldInfo.TimeSeconds;
		}
	}
	//Disable veterancy accordingly for surrenders
	if(Rx_Pri(NewPlayer.PlayerReplicationInfo) != None && Rx_Pri(NewPlayer.PlayerReplicationInfo).GetTeamNum() == TEAM_GDI && bGDIHasSurrendered)
	{
		Rx_Pri(NewPlayer.PlayerReplicationInfo).DisableVeterancy(true); 	
	}
	
	
	if( Rx_Pri(NewPlayer.PlayerReplicationInfo) != none)
	{

	//Set Commander if they exist
	if(Rx_PRI(NewPlayer.PlayerReplicationInfo).GetTeamNum() == 0 && Commander_PRI[0] != none) 
		Rx_PRI(NewPlayer.PlayerReplicationInfo).SetCommander(Commander_PRI[0]);

	else if(Rx_PRI(NewPlayer.PlayerReplicationInfo).GetTeamNum() == 1 && Commander_PRI[1] != none) 
		Rx_PRI(NewPlayer.PlayerReplicationInfo).SetCommander(Commander_PRI[1]);

	foreach GameReplicationInfo.PRIArray(PRI) 
	{			
		if(Rx_PRI(PRI) == none) 
			continue;
		
				if (PRI.GetTeamNum() == Rx_Pri(NewPlayer.PlayerReplicationInfo).GetTeamNum()) 
				{
					AvgVeterancy+=Rx_PRI(PRI).Veterancy_Points;
					num++; 
				}
			
		}
		if(num > 0) AvgVeterancy=min(MaxInitialVeterancy,AvgVeterancy/(num+2));
				Rx_PRI(NewPlayer.PlayerReplicationInfo).InitVP(
				AvgVeterancy,
				Rx_Game(WorldInfo.Game).VPMilestones[0], 
				Rx_Game(WorldInfo.Game).VPMilestones[1], 
				Rx_Game(WorldInfo.Game).VPMilestones[2]);
	}	
	
	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnPlayerConnect(NewPlayer, SteamID);
	}

	UpdateDiscordPresence();
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	if (Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()) != None)
		return super.ChangeTeam(Other, GetPlayerTeam(), bNewTeam);
}

function UTBot AddBot(optional string BotName, optional bool bUseTeamIndex, optional int TeamIndex)
{
	
	if(bBotsDisabled || (NumPlayers+NumBots >= MaxPlayers))
		return None;
		

	return OnAddBot(super(UTTeamGame).AddBot(BotName, true, GetPlayerTeam()));


}

function CheckBuildingsDestroyed(Actor destroyedBuilding, Rx_Controller StarPC)
{
	local BuildingCheck Check;
	local Rx_CoopObjective O;

	if (Role == ROLE_Authority)
	{
		CurrentBuildingVPModifier +=0.5;
		Check = CheckBuildings();
		if(Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()) == None)
		{
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

function AnnounceObjectiveCompletion(Controller InstigatingPlayer, Rx_CoopObjective O)
{
	local string ActualMessage;
	local Rx_Controller PC;

	if(O.bAnnounceCompletingPlayer)
	{
		if(InstigatingPlayer != None)
			ActualMessage = InstigatingPlayer.GetHumanReadableName()@O.CompletionMessage;
		else
			ActualMessage = "A mysterious force"@O.CompletionMessage;
	}
	else
		ActualMessage = O.CompletionMessage;
				
	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		if(O.bFailCompletion)
			PC.CTextMessage(ActualMessage,'Red',180,,false,true);
		else
			PC.CTextMessage(ActualMessage,'Green',180,);
	}
}	

function CheckObjectives()
{
	local Rx_CoopObjective O;

		foreach CoopObjectives(O)
		{
			if(!O.bOptional)
			{
				if(!O.IsDisabled())
				{
					return;
				}
				if(O.bFailCompletion)
				{
					EndRxGame("Objective Failure",255);
					return;
				}
			}
		}	

		EndRxGame("Objective Completion",Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()).PlayerTeam);
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
	if ( ((Reason ~= "Objective Completion") || (Reason ~= "Objective Failure") || (Reason ~= "triggered")) && !bGameEnded) {
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

		if(Reason ~= "Objective Completion") 
		{
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "Mission Accomplished";
		}
		else if(Reason ~= "Objective Failure") 
		{
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "Mission Failed";
		}			
		else if(Reason ~= "Triggered")
		{
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "Voted Out";
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

function bool CanPlayBuildingUnderAttackMessage(byte TeamNum) 
{
	if(Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()) != None && Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()).bEnableBuildingAlert)
	{
		return Super.CanPlayBuildingUnderAttackMessage(TeamNum);
	}

	return false;
}

function AdjustTeamBalance()
{
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		if(Rx_Mut.adjustTeamBalance())
	}	
}

function AdjustTeamSize()
{
	local Controller PC;
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		if(Rx_Mut.adjustTeamSize())
			return;
	}

	foreach WorldInfo.AllControllers( class'Controller', PC )
	{
		if(PC.bIsPlayer && PC.GetTeamNum() != GetPlayerTeam())
			SetTeam(PC, Teams[GetPlayerTeam()], false);
	}
}

DefaultProperties
{
	PlayerControllerClass	   = class'Rx_Controller_Coop'
	HudClass                   = class'Rx_HUD_Coop'
	PurchaseSystemClass        = class'Rx_PurchaseSystem_Coop'
	VehicleManagerClass        = class'Rx_VehicleManager_Coop'

	TeamInfoClass			   = class'Rx_TeamInfo_Coop'
	TeamAIType(0)              = class'Rx_TeamAI_Coop'
	TeamAIType(1)              = class'Rx_TeamAI_Coop'

}