/**
 * RxGame
 *
 * */
class Rx_Game extends UTTeamGame
	config(RenegadeX);

`define SupressNullDamageType(Statement) if (DamageType != class'DamageType') `Statement
`define GAMEINFO(dummy)
`include(RenX_Game\RenXStats.uci);
`undefine(GAMEINFO)

/** one1: Current vote in progress. */
var Rx_VoteMenuChoice GlobalVote;
var Rx_VoteMenuChoice GDIVote;
var Rx_VoteMenuChoice NODVote;
var float VotePersonalCooldown;
var float VoteTeamCooldown_GDI, VoteTeamCoolDown_Nod, NextChangeMapTime_GDI, NextChangeMapTime_Nod; 
var bool IgnoreGameServerVersionCheck;

var config bool bFixedMapRotation;

var Rx_LANBroadcast LANBroadcast;
var OnlineGameSettings GameSettings;

var string PingIpList;

var globalconfig array<string> MapHistory; // In order of most recent (0 = Most Recent)
var int MapHistoryMax; // Max number of recently played maps to hold in memory

var config int RecentMapsToExclude;
var config int MaxMapVoteSize;
var config int CnCModeTimeLimit;
var int VPMilestones[3]; //Config
var int MaxInitialVeterancy; //Maximum veterancy you can be given at the beginning of a game
var float CurrentBuildingVPModifier; //Modifier based on number buildings currently destroyed. 1st building kill awards the least, and gradually rises with each kill
var int CreditTickRate; // Frequency in seconds that credit ticks occur
var private float CreditTickTimer;

/** Team Numbers in handy ENUM form */
enum TEAM
{
	TEAM_GDI,
	TEAM_NOD,
	TEAM_UNOWNED
};

struct TeamCreditStruct 
{
	var array<Rx_Building_Refinery>    Refinery;
	var array<Rx_PRI>           	   PlayerRI;
};
	
var class<UTHudBase>					HudClass;
var float								EndGameDelay;
var float								RenEndTime;
var int									MineLimit;
var int 							    VehicleLimit;
var	SoundCue							BoinkSound;

struct MapMineAndVehLimit
{
	var name MapName;
	var int MineLimit;
	var int VehicleLimit;
};
var globalconfig array<MapMineAndVehLimit> MapSpecificMineAndVehLimit;

var bool                                bAddRepGunDefenderNOD;
var bool                                bAddRepGunDefenderGDI;

var TeamCreditStruct                    TeamCredits[2]; // stores PRI's and ref for GDI(0) and Nod(1)

var int				                    MaxPlayerNameLength;
var array<string>                       DisallowedNames;

var config int                          InitialCredits;  // the initial credits a player gets when they spawn in
//var config float                        CreditTickRateModifier; // How much faster or slower do we tick credits (not implemented)
var config bool	                        SpawnCrates; // whether or not to spawn crates in this game
var config float                        CrateRespawnAfterPickup; // interval for crate respawn (after pickup)
var config bool                         bBotsDisabled;
var config bool 						bBotVotesDisabled;
var config int                          DonationsDisabledTime;

var config bool                         bReserveVehiclesToBuyer;
var config bool							bAllowPowerUpDrop;
var int									RTC_DisableTime; //Amount of time changing teams [sans admin forcing team changes] is disabled. 0 is never ADD TO CONFIG

//Surrender Specific Variables
var config int 	SurrenderDisabledTime; 
var bool bGDIHasSurrendered, bNodHasSurrendered ; 
var int SurrenderStartTime ; 
var config int SurrenderLength; //How long till a surrender vote actually ends the game. 
var bool bCountingToSurrender; //Are we counting down rapidly now?

var class<Rx_PurchaseSystem>			PurchaseSystemClass, HelipadPurchaseSystemClass;
var Rx_PurchaseSystem                   PurchaseSystem;
var class<Rx_VehicleManager>			VehicleManagerClass, HelipadVehicleManagerClass;
var Rx_VehicleManager                   VehicleManager;
var class<Rx_TeamInfo>					TeamInfoClass;
var bool							    bCanPlayEvaBuildingUnderAttackGDI;
var bool							    bCanPlayEvaBuildingUnderAttackNOD;
var byte						        WinnerTeamNum;
var Rx_Building_Nod_Defense				Obelisk;
var Rx_Building_GDI_Defense				AGT;
var int SmokeScreenCount;   // Optimisation - Used to track if there is an active SmokeScreen and allows AI to skip traces for SmokeScreens if there are none.

var Rx_ServerListQueryHandler ServiceBrowser;
var Rx_VersionQueryHandler VQueryHandler;

var const float EndgameCamDelay, EndgameSoundDelay;

var Rx_AuthenticationService authenticationService;
var config bool bHostsAuthenticationService;

/**Provides Map Information stored in the .ini file. (expensive to get, so cache here). */
var array<Rx_UIDataProvider_MapInfo> MapDataProviderList;

/** Name of the class that manages maplists and map cycles */
var string MapListManagerClassName;
var Rx_MapListManager MapListManager;

// Skirmish options:
var int GDIBotCount;
var int NODBotCount;
var int GDIDifficulty;
var int NODDifficulty;
var int PlayerTeam;
var int NodAttackingValue;
var int GDIAttackingValue;
var bool bInitialBotsCreated; //Checks if the initial bot number was created in Skirmish, so it won't create them 4 times over. 

var int Port;
var config array<string> SteamLogins;

var config bool bIsCompetitive;
var config bool bFillSpaceWithBots;
var bool bIsClanWars;
var Rx_MatchInfo MatchInfo;

var array<Rx_CratePickup> AllCrates;

/** Does the server allow non-admin clients to PM each other. */
var config bool bAllowPrivateMessaging;
/** Restrict PMing to just teammates. */
var config bool bPrivateMessageTeamOnly;

// Determines how teams are organized between matches. 0 = static, 1 = swap, 2 = random swap, 3 = shuffle, 4 = traditional (assign as players connect)
var config int TeamMode;

var int buildingArmorPercentage; //Always 50 if enabled 

var bool UsePurchaseSystem; //Should gamemode setup the purchase system

var config bool bListed;

var int RTC_TimeLimit;

struct ServerInfo
{
	var string ServerName;
	var string ServerIP;
	var string ServerPass;
	var string ServerPort;
	var int GameType;
	var string Mapname;
	var string GameVersion;
	var int NumPlayers;
	var int MaxPlayers;
	var bool Ranked;
	var int Ping;
	var bool bInGame;
	var bool bPassword;
	
	//nBab
	var int VehicleLimit;
	var int MineLimit;
	var int TimeLimit;
	var bool SteamRequired;
	var bool CratesEnabled;
	var int TeamMode;
	var bool isLAN; //Is this server a local area network server (rather than internet).
};

var array<ServerInfo> ListServers;
//var string ServerListRawData;

/**@Shahman: Version of this build*/
var config string GameVersion;
/**@Shahman: Game Version Number*/
var config int GameVersionNumber;
/**@MPalko: Retrieves latest version from the website*/
var Rx_VersionCheck VersionCheck;

var int GameType; // < 0 = Invalid, 0 = Rx_Game_MainMenu, 1 = Rx_Game, 2 = TS_Game, 3 = SP_Game, [3, 1000) = RenX Unused/Reserved, [1000, 2^31 - 1] Unassigned / Mod space


var int curIndPinged;

var config bool bLogRcon;

var globalconfig bool bDisableDemoRequests;
var bool ClientDemoInProgress;

var bool bForceNonSeamless;

var array<class<Rx_ScoreEvent> > ScoreEvents;
var Rx_ScoreEvent UpcomingScoreEvent;
var Rx_ScoreEvent LastScoreEvent;

var array<class<Rx_PickUp> > PowerUpClasses;

enum BuildingCheck
{
	BC_TeamsHaveBuildings,
	BC_GDIDestroyed,
	BC_NodDestroyed,
	BC_TeamsHaveNoBuildings
}; 

var class<Rx_CommanderController> CommanderControllerClass;
var Rx_CommanderController CommanderController; //TODO ...... basically all of this

//var Rx_SystemSettingsHandler SystemSettingsHandler;

//var array<string> GDI_SpotMarkers, Nod_SpotMarkers; //Capture a list of spot markers at the beginning of the game to determine which ones are GDI/Nod-based.

//Awards [0 for GDI  1 for Nod]
var Rx_PRI Award_MVP[2], Award_Offense[2], Award_Defense[2], Award_Support[2]; 

/**Team Management**/

struct TC_Request
{
	var Rx_PRI PPRI;
	var int TimeStamp; 	
};

var array<TC_Request> RTC_GDI, RTC_Nod; 

/*****************************************
*Remember the Commander stuff?? Okay let's finally do that (2+ years later)
******************************************/

var config bool bEnableCommanders ; //, bEnableSupportPowers, bEnableSquads, bEnableObjectives ; //Self explanatory 
var Rx_PRI Commander_PRI[2]; //Hold the PRI of the commander(s?) 0 for Geeds 1 for Nod 
var config int		InitialCP, Max_CP; 
var array<PlayerReplicationInfo> TargetedPlayers_GDI, TargetedPlayers_Nod; 
var int			CP_TickRate; 
var int			LastDecayMsgTime[2]; 
var int			CPReward_Emplacement, CPReward_Infantry, CPReward_Vehicle; 

var config bool bUseStaticCommanders;

var int			DestroyedBuildings_Nod, DestroyedBuildings_GDI; 

//Control Groups [Not currently in use]
struct ControlGroup 
{
	var string 			GroupTitle; //Title, has a default value set but can be changed 
	var Rx_PRI 			LeaderPRI; // Squad leader; everyone can see what they're targeting? Or something like that 
	var array<Rx_PRI>	Members; 
};

//Optimizations 
var config bool bVehiclesAlwaysRelevant, bInfantryAlwaysRelevant; 

var Rx_StatAPI StatAPI;


var ControlGroup GDIControlGroups[6], NodControlGroups[6];  
 
/*****************************************
*End of significantly less complicated Commander things
******************************************/

var int Defence_IDs; //Hold and create the ID's for Rx_Defences so they can stop being stupid to work with for client > server 
//var config int MinPlayersForNukes; 

//Score System 
var config bool		bUseLegacyScoreSystem;  

delegate NotifyServerListUpdate();

function PreBeginPlay()
{
	local class<Rx_GameplayEventsWriter> GameplayEventsWriterClass;
	local color C;
	local Rx_Building B;

	//Optionally setup the gameplay event logger
   if (bLogGameplayEvents && GameplayEventsWriterClassName != "")
   {
      GameplayEventsWriterClass = class<Rx_GameplayEventsWriter>(FindObject(GameplayEventsWriterClassName, class'Class'));
      if ( GameplayEventsWriterClass != None )
      {
         `log("Recording game events with"@GameplayEventsWriterClass);
         GameplayEventsWriter = new(self) GameplayEventsWriterClass;
         //Optionally begin logging here
         GameplayEventsWriter.StartLogging(0.5f);
      }
      else
      {
         `log("Unable to record game events with"@GameplayEventsWriterClassName);
      }
   }
   else
   {
      `log("Gameplay events will not be recorded.");
   }

	Super.PreBeginPlay();

	`RecordGameIntStat(MATCH_STARTED,1);
	`RecordGameStringStat(GAME_CLASS,"RenX");

	GameSettings = OnlineSub.GameInterface.GetGameSettings(WorldInfo.Game.PlayerReplicationInfoClass.default.SessionName);

	if(GameSettings == none)
		`logd("GameSettings is none");
	else
		`logd("bIsLanMatch: "@GameSettings.bIsLanMatch);

	if((WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) && GameSettings != none && GameSettings.bIsLanMatch)
	{
		LANBroadcast.start(true);
		SetTimer(1, true, 'SendLANBroadcast');
	}		

	if ( Role == ROLE_Authority )
	{
		ForEach `WorldInfoObject.AllActors(class'Rx_Building', B)
		{
			if (Rx_Building_Helipad_Nod(B) != None || Rx_Building_Helipad_GDI(B) != None)
			{
				VehicleManagerClass = HelipadVehicleManagerClass;
				PurchaseSystemClass = HelipadPurchaseSystemClass;
			}
			B.GetAttackPoints();
		}

		PurchaseSystem = spawn(PurchaseSystemClass, self,'PurchaseSystem',Location,Rotation);
		VehicleManager = spawn(VehicleManagerClass, self,'VehicleManager',Location,Rotation);
		
		PurchaseSystem.SetVehicleManager(VehicleManager);
	}

	if(Rx_MapInfo(WorldInfo.GetMapInfo()).MapBotType == navmesh)
	{
		Teams[TEAM_GDI].AI.SquadType = class'RenX_Game.Rx_SquadAI_Mesh';
		Teams[TEAM_NOD].AI.SquadType = class'RenX_Game.Rx_SquadAI_Mesh';
		BotClass = class'RenX_Game.Rx_Bot_Mesh';
	}

	`log("Rx_Game::PreBeginPlay"@`showvar(BotClass) @ bInfantryAlwaysRelevant);


	Teams[TEAM_GDI].AI.EnemyTeam = Teams[TEAM_NOD];
	Teams[TEAM_NOD].AI.EnemyTeam = Teams[TEAM_GDI];

	c.R=255;
	Teams[TEAM_NOD].TeamColor = c;
	c.G=255;
	Teams[TEAM_GDI].TeamColor = c;
	
	
	`RecordTeamStringStat(CREATED, Teams[TEAM_GDI], "Ready");
	`RecordTeamStringStat(CREATED, Teams[TEAM_NOD], "Ready");
	
	
	VehicleManager.Initialize(self, Teams[TEAM_GDI], Teams[TEAM_NOD]);
	
	if(bHostsAuthenticationService) {
		authenticationService = Spawn(class'Rx_AuthenticationService');
	}
	
	if (ServiceBrowser == None && WorldInfo.NetMode == NM_StandAlone)
	{
		ServiceBrowser = new(self)class'Rx_ServerListQueryHandler';
	}
		// Create our version check class.
	VersionCheck = Spawn(class'Rx_VersionCheck');

	/* Spawn our Rx_VersionQueryHandler, so we can access it from external classes and use it's functions. */
	if (VQueryHandler == None && WorldInfo.NetMode == NM_StandAlone)
	{
		VQueryHandler = new(self)class'Rx_VersionQueryHandler';
		VQueryHandler.GetFromServer();
	}

// 	// Create our Graphic Adapter check class.
// 	GraphicAdapterCheck = Spawn(class'Rx_GraphicAdapterCheck');
// 	GraphicAdapterCheck.CheckGraphicAdapter();

	ListServers.length = 0;

	//Create our systemsettingshandler here
	//SystemSettingsHandler = Spawn(class'Rx_SystemSettingsHandler');

	MaxMapVoteSize = Clamp(MaxMapVoteSize, 1, 9);
	RecentMapsToExclude = Clamp(RecentMapsToExclude, 0, 14);
	

	//Get out map info here
	SetupMapDataList();
}

function SendLANBroadcast()
{
	LANBroadcast.SendBroadcast();
}

function bool AddServerInfo(ServerInfo s)
{
	local string ourIPaddress;
	local int i;
	local InternetLink il;
	local ServerInfo si;
	local bool found;
	local IpAddr addr;

	`Entry(,'DevNet');

	// get our ip
	il = `RxGameObject.spawn(class'InternetLink');
	il.GetLocalIP(addr);
	ourIPaddress = il.IpAddrToString(addr);
	//ipaddresstostring returns port aswell, need to get just ip.
	i = InStr(ourIPaddress, ":");
		if(i != -1)
			ourIPaddress = Left(ourIPaddress, i);

	//check if server is us.
	if ((WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) && s.ServerIP == ourIPaddress)
		return false;

	//check if server is already in list.
	Foreach ListServers(si)
	{
		if(si.ServerName == s.ServerName && si.ServerIP == s.ServerIP)
			found = true;
	}

	if(!found)
	{
		s.Ping = -1; // Make ping unset for fresh servers.
		ListServers.AddItem(s);
		AddServerPing(s.ServerIP, ListServers.Length - 1);
		return true;
	}
	else 
		return false;
}

function SetupMapDataList()
{
	local array<UDKUIResourceDataProvider> ProviderList; 
	local int i;

	// make sure default map exists
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'Rx_UIDataProvider_MapInfo', ProviderList);
	
	//hack until we solve the sorting issue
	for (i = ProviderList.length; i >= 1; i--)
	{		
		if (Rx_UIDataProvider_MapInfo(ProviderList[i-1]) == none) {
			`log("NONE - ProviderList[i-1]? " $ Rx_UIDataProvider_MapInfo(ProviderList[i-1]).MapName);
			continue;
		}
		//`log("------YOSH----------" @ Rx_UIDataProvider_MapInfo(ProviderList[i]) @ "---------YOSH----------"); 
		MapDataProviderList.AddItem(Rx_UIDataProvider_MapInfo(ProviderList[i-1]));
	} 
	if (MapDataProviderList.Length > 0) {
		MapDataProviderList.Sort(MapListSort);
	}
}

function bool MapPackageExists (coerce string PackageName)
{
	local int i, MapNum;

	MapNum=MapDataProviderList.Length; 	
	
	for(i=0; i < MapNum; i++)
	{
		if(PackageName ~= MapDataProviderList[i].MapName) 
		{
		return true; 	
		}
		else continue;
	}
	return false; 
}

delegate int MapListSort(Rx_UIDataProvider_MapInfo A, Rx_UIDataProvider_MapInfo B) 
{
	return A.FriendlyName < B.FriendlyName ? 0 : -1;
}

event exec viewmode (string VM)
{
	return;
}

event exec FogDensity()
{
	return; 
}

/** one1: added */
function PostBeginPlay()
{
	local string CappedName;
	local class<Rx_ScoreEvent> Event;
	//local Rx_MatchInfo m;

	if(Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap) // if deathmatch map, switch to UT's team AI
	{
		TeamAIType[0] = class'UTTeamAI';
		TeamAIType[1] = class'UTTeamAI';
		BotClass      = class'RenX_Game.Rx_Bot';
	}

	super.PostBeginPlay();

	if (Rx_GameEngine(class'Engine'.static.GetEngine()) != none)
		Rx_GameEngine(class'Engine'.static.GetEngine()).Initialize();

	if ((WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) && !GameSettings.bIsLanMatch)
	{
		if (Rx_GameEngine(class'Engine'.static.GetEngine()) != none)
			Rx_GameEngine(class'Engine'.static.GetEngine()).init_rcon();

		StatAPI = new class'Rx_StatAPI';

		if (!StatAPI.bPostToAPI)
			StatAPI = None;

		if (StatAPI != None) 
		{
			StatAPI.GameStart(WorldInfo.GRI.ServerName, string(WorldInfo.GetPackageName()), string(WorldInfo.Game.Class), string(GameVersionNumber));

			if (StatAPI.APIUpdateInterval != 0)
				SetTimer(StatAPI.APIUpdateInterval, true, 'GameUpdate');
		}
	}
	else
	{
		if (bIsClanWars)
			bIsClanWars=false;
	}

	SetTimer(1.f, true, 'VoteTimer');

	/* Strip Day/Night from Field/Canyon/Mesa or whatever other map*/
	
	CappedName = string(WorldInfo.GetPackageName()); 

	if (right(CappedName, 6) ~= "_NIGHT") CappedName = Left(CappedName, Len(CappedName)-6);   

	if (right(CappedName, 4) ~= "_DAY") CappedName = Left(CappedName, Len(CappedName)-4); 
 
	//RecordToMapHistory(string(WorldInfo.GetPackageName()));

	RecordToMapHistory(CappedName); 
	
	if (bFixedMapRotation)
		Rx_GRI(GameReplicationInfo).SetFixedNextMap(GetNextMapInRotationName());
	else
		Rx_GRI(GameReplicationInfo).SetupEndMapVote(BuildMapVoteList(), true);

	/** Initialize score events */
	foreach ScoreEvents(Event)
	{
		if (UpcomingScoreEvent == None)
		{
			UpcomingScoreEvent = new Event;
			LastScoreEvent = UpcomingScoreEvent;
		}
		else
		{
			LastScoreEvent.Next = new Event;
			LastScoreEvent = LastScoreEvent.Next;
		}
	}

	RxLog("MAP"`s"Loaded;"`s GetPackageName() );

	`RecordGameFloatStat(ROUND_STARTED,1.0);
	
	if (VehicleManager != None)
		VehicleManager.CheckVehicleSpawn();
}

function GameUpdate()
{
	local Rx_Controller c;
	local int GDICount, NodCount;

	if (StatAPI != None)
	{
		ForEach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'Rx_Controller', c)
		if (c.GetTeamNum() == 0)
			GDICount++;
		else if (c.GetTeamNum() == 1)
			NodCount++;

		StatAPI.GameUpdate(string(Rx_TeamInfo(Teams[TEAM_GDI]).GetDisplayRenScore()), string(Rx_TeamInfo(Teams[TEAM_NOD]).GetDisplayRenScore()), string(GDICount), string(NodCount));
	}
}

function ShuffleTeamsNextMatch()
{
	local Array<Rx_Controller> Team1, Team2, All;
	local float Team1Score, Team2Score;
	local int GDICount, NodCount;
	local Rx_Controller PC, Highest;
	local Rx_Mutator Rx_Mut;

	LogInternal("autobal: shuffle" );

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnBeforeTeamShuffling();
	}		

	if (Rx_Mut != None)
	{
		if(Rx_Mut.ShuffleTeamsNextMatch())
			return;
	}		

	// Gather all Human Players
	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
			All.AddItem(PC);
	}

	// Sort them all into 2 teams.
	while (All.Length > 0)
	{
		Highest = None;
		foreach All(PC)
		{
			if (Highest == None)
				Highest = PC;
			else if (Rx_PRI(PC.PlayerReplicationInfo).OldRenScore > Rx_PRI(Highest.PlayerReplicationInfo).OldRenScore)
				Highest = PC;
		}

		All.RemoveItem(Highest);

		if (Team1Score <= Team2Score)
		{
			Team1.AddItem(Highest);
			Team1Score += Rx_PRI(Highest.PlayerReplicationInfo).OldRenScore;
		}
		else
		{
			Team2.AddItem(Highest);
			Team2Score += Rx_PRI(Highest.PlayerReplicationInfo).OldRenScore;
		}

		// If the small team + the rest is less than the larger team, then place all remaining players in the small team.
		if (Team1.Length >= Team2.Length + All.Length)
		{
			// Dump the rest in Team2.
			foreach All(PC)
				Team2.AddItem(PC);
			break;
		}
		else if (Team2.Length >= Team1.Length + All.Length)
		{
			// Dump the rest in Team1.
			foreach All(PC)
				Team1.AddItem(PC);
			break;
		}
	}

	// Figure out which team will be which faction. Just do the one that moves the least.
	foreach Team1(PC)
	{
		if (PC.PlayerReplicationInfo.Team.TeamIndex == 0)
			++GDICount;
		else
			++NodCount;
	}
	if (GDICount >= NodCount)
	{
		// Team 1 go GDI, Team 2 go Nod
		foreach Team1(PC)
			`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
		foreach Team2(PC)
			`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
	}
	else
	{
		// Team 1 go Nod, Team 2 go GDI
		foreach Team1(PC)
			`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
		foreach Team2(PC)
			`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
	}

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnAfterTeamShuffling();
	}	

	// Terribly unoptimized, but done.

}

function RetainTeamsNextMatch()
{
	local Controller PC;

	foreach WorldInfo.AllControllers(class'Controller', PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
		{
			if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI)
				`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
			else if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD)
				`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
		}
	}
}

function SwapTeamsNextMatch()
{
	local Controller PC;

	foreach WorldInfo.AllControllers(class'Controller', PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
		{
			if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI)
				`RxEngineObject.AddNodPlayer(PC.PlayerReplicationInfo);
			else if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD)
				`RxEngineObject.AddGDIPlayer(PC.PlayerReplicationInfo);
		}
	}
}

function SwapTeamsHelper(class<Controller> ControllerType)
{
	local Controller PC;

	foreach WorldInfo.AllControllers(ControllerType, PC)
	{
		if ( (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
		{
			if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI)
			{
				SetTeam(PC, Teams[TEAM_NOD], false);
				if (PC.Pawn != None)
					PC.Pawn.PlayerChangedTeam();
			}
			else if (PC.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD)
			{
				SetTeam(PC, Teams[TEAM_GDI], false);
				if (PC.Pawn != None)
					PC.Pawn.PlayerChangedTeam();
			}
		}
	}
}

function SwapTeams()
{
	SwapTeamsHelper(class'PlayerController');
	SwapTeamsHelper(class'Rx_Bot');
}

function byte PickTeam(byte num, Controller C)
{
	if (bIsClanWars)
		return MatchInfo.PickTeam(Rx_Controller(C));
	return super.PickTeam(num, C);
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local byte AntiTeamByte; 
	
	if(num < 3) AntiTeamByte = num == 0 ? 1 : 0 ;
	
	if (super.ChangeTeam(Other, num, bNewTeam))
	{
		if (Rx_Controller(Other) != None)
		{
			Rx_Controller(Other).BindVehicle(None);
			Rx_Controller(Other).VoteTopString = "";
		}
		if (Rx_PRI(Other.PlayerReplicationInfo) != None )
		{
			if(Rx_PRI(Other.PlayerReplicationInfo) == Commander_PRI[AntiTeamByte]) RemoveCommander(AntiTeamByte);  
			
			if(Commander_PRI[AntiTeamByte] != none) Rx_PRI(Other.PlayerReplicationInfo).SetCommander(Commander_PRI[AntiTeamByte]);
			else
			Rx_PRI(Other.PlayerReplicationInfo).RemoveCommander(AntiTeamByte);
			
			if(WorldInfo.NetMode == NM_StandAlone && Rx_Controller(Other) != none) ChangeCommander(num, Rx_PRI(Other.PlayerReplicationInfo)) ;
			
			Rx_PRI(Other.PlayerReplicationInfo).DestroyATMines();
			Rx_PRI(Other.PlayerReplicationInfo).DestroyRemoteC4();
		}
		return true;
	}
	return false;
}

function SetTeam(Controller Other, UTTeamInfo NewTeam, bool bNewTeam)
{
	local Actor A;
	local TeamInfo OldTeam;

	if ( Other.PlayerReplicationInfo == None )
	{
		return;
	}
	
	`RecordPlayerIntStat(TEAMCHANGE,Other,NewTeam.TeamIndex);

	if (Other.PlayerReplicationInfo.Team != None || !ShouldSpawnAtStartSpot(Other))
	{
		// clear the StartSpot, which was a valid start for his old team
		Other.StartSpot = None;
	}

	// remove the controller from his old team
	if ( Other.PlayerReplicationInfo.Team != None )
	{
		OldTeam = Other.PlayerReplicationInfo.Team;
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = none;
		
		//Clear Binds/locks/C4s
		if (Rx_Controller(Other) != None)
		{
			Rx_Controller(Other).BindVehicle(None);
			Rx_Controller(Other).VoteTopString = "";
		}
		if (Rx_PRI(Other.PlayerReplicationInfo) != None)
		{
			Rx_PRI(Other.PlayerReplicationInfo).DestroyATMines();
			Rx_PRI(Other.PlayerReplicationInfo).DestroyRemoteC4();
		}
		
	}
	
	//Just set them to commander
	if(WorldInfo.NetMode == NM_StandAlone && Rx_Controller(Other) != none) ChangeCommander(NewTeam.TeamIndex, Rx_PRI(Other.PlayerReplicationInfo)) ;	
	
	if ( NewTeam==None || (NewTeam!= none && NewTeam.AddToTeam(Other)) )
	{
		if ( (NewTeam!=None) && ((WorldInfo.NetMode != NM_Standalone) || (PlayerController(Other) == None) || (PlayerController(Other).Player != None)) );
	}

	if (bNewTeam)
		AnnounceTeamJoin(Other.PlayerReplicationInfo, NewTeam, OldTeam);

	if ( (PlayerController(Other) != None) && (LocalPlayer(PlayerController(Other).Player) != None) )
	{
		// if local player, notify level actors
		ForEach AllActors(class'Actor', A)
		{
			A.NotifyLocalPlayerTeamReceived();
		}
		
	}
}

function AnnounceTeamJoin(PlayerReplicationInfo PRI, TeamInfo NewTeam, optional TeamInfo OldTeam, optional bool bBroadcast = true)
{
	if (OldTeam == None)
		RxLog("PLAYER"`s "TeamJoin;"`s `PlayerLog(PRI) `s "joined"`s GetTeamName(NewTeam.GetTeamNum()) );
	else
		RxLog("PLAYER"`s "TeamJoin;"`s `PlayerLog(PRI) `s "joined"`s GetTeamName(NewTeam.GetTeamNum()) `s "left" `s GetTeamName(OldTeam.GetTeamNum()) );

	if (bBroadcast)
		BroadcastLocalizedMessage( GameMessageClass, 3, PRI, None, NewTeam );
}

function bool AllowedName(string playername)
{
	local int i;

	// If length of name is less than 3 characters
	if (Len(playername) < 3)
		return false;
	// Or exists in the disallowed list
	for (i = 0; i < DisallowedNames.Length; i++)
	{
		if (playername ~= DisallowedNames[i])
			return false;
	}
	return true;
}

function ChangeName(Controller Other, string S, bool bNameChange)
{
    local Controller APlayer;
	
	if(bIsCompetitive && bNameChange)
	{

		PlayerController(Other).ClientMessage("Can not change name during competitive play");

		return; 	
	}	
	
	if (bNameChange && Rx_Controller(Other) != None && WorldInfo.TimeSeconds < Rx_Controller(Other).NextNameChangeTime)
	{
		PlayerController(Other).ClientMessage("Name change rejected - you changed name too recently.");
		return;
	}

	s = class'Rx_BroadcastHandler'.static.CleanMessage(s);
	s = Rx_BroadcastHandler(BroadcastHandler).ApplyChatFilter(s);
	if (!AllowedName(S))
		s = DefaultPlayerName;

	if (Left(s,Len(DefaultPlayerName)) ~= DefaultPlayerName && ( int(Mid(s,Len(DefaultPlayerName),1)) != 0 || Mid(s,Len(DefaultPlayerName),1) ~= "0" ) ) 
	{
		Other.PlayerReplicationInfo.SetPlayerName(DefaultPlayerName$Other.PlayerReplicationInfo.PlayerID);
		return;
	}

    if ( bNameChange && Other.PlayerReplicationInfo.playername~=S )
    {
		return;
	}

	// Not allowed pidX where x is a digit, to avoid trying to confuse people when using pid to parse player.
	if (Left(s,3) ~= "pid" && ( int(Mid(s,3,1)) != 0 || Mid(s,3,1) ~= "0" ) )
	{
		if (!bNameChange)
			Other.PlayerReplicationInfo.SetPlayerName(DefaultPlayerName$Other.PlayerReplicationInfo.PlayerID);
		return;
	}


    // Cap player name's at 15 characters...
	if (Len(s)>MaxPlayerNameLength)
	{
		s = Left(S,MaxPlayerNameLength);
	}

	foreach WorldInfo.AllControllers(class'Controller', APlayer)
	{
		if (APlayer.bIsPlayer && APlayer.PlayerReplicationInfo.playername ~= S)
		{
			if ( PlayerController(Other) != None )
			{
					PlayerController(Other).ReceiveLocalizedMessage( GameMessageClass, 8 );
					if ( Other.PlayerReplicationInfo.PlayerName ~= DefaultPlayerName )
					{
						if (bNameChange)
						{
							RxLog("PLAYER"`s "NameChange;" `s `PlayerLog(Other.PlayerReplicationInfo)`s"to:"`s DefaultPlayerName$Other.PlayerReplicationInfo.PlayerID);
							if (Rx_Controller(Other) != None)
								Rx_Controller(Other).UpdateNameChangeTime();
						}
						Other.PlayerReplicationInfo.SetPlayerName(DefaultPlayerName$Other.PlayerReplicationInfo.PlayerID);
					}
				return;
			}
		}
	}

	if (bNameChange)
	{
		RxLog("PLAYER"`s "NameChange;" `s `PlayerLog(Other.PlayerReplicationInfo)`s"to:"`s S);
		if (Rx_Controller(Other) != None)
			Rx_Controller(Other).UpdateNameChangeTime();
	}
    Other.PlayerReplicationInfo.SetPlayerName(S);
}

function static string GetTeamName(byte Index)
{
	switch (Index)
	{
	case TEAM_GDI:
		return "GDI";
	case TEAM_NOD:
		return "Nod";
	default:
		return "Neutral";
	}
}

exec function GetTeamSizes()
{
	`log("GDI: "$ Teams[0].Size $"Nod: "$Teams[1].Size);
}

function TeamDonate(Rx_Controller Donor, float Credits)
{
	local float share;
	local Controller c;
	local byte teamNum;
	
	teamNum = Donor.GetTeamNum();

	if (Teams[teamNum].Size < 2)    // Need to have at least 1 teammate.
		return;

	share = Credits / (Teams[teamNum].Size - 1);

	foreach WorldInfo.AllControllers(class'Controller', c)
	{
		if (c.GetTeamNum() == teamNum && Rx_PRI(c.PlayerReplicationInfo) != None && c != Donor )
		{
			Rx_PRI(c.PlayerReplicationInfo).AddCredits(share);
			if (PlayerController(c) != None)
				PlayerController(c).ClientMessage(Donor.PlayerReplicationInfo.PlayerName $ " team-donated you " $ share $" credits.");
		}
	}
	Rx_PRI(Donor.PlayerReplicationInfo).RemoveCredits(Credits);
}

function Array<string> BuildClientList(string seperator)
{
	local Rx_Controller C;
	local string SteamID;
	local string AdminStatus;
	local Array<string> list;

	foreach WorldInfo.AllControllers(class'Rx_Controller', C)
	{
		SteamID = OnlineSub.UniqueNetIdToString(C.PlayerReplicationInfo.UniqueId);

		if (Rx_PRI(C.PlayerReplicationInfo).bModeratorOnly)
			AdminStatus = "Mod";
		else if (C.PlayerReplicationInfo.bAdmin)
			AdminStatus = "Admin";
		else
			AdminStatus = "None";

		if (SteamID == `BlankSteamID)
			SteamID = "-----NO-STEAM-----";
		List.AddItem(C.PlayerReplicationInfo.PlayerID$seperator$C.GetPlayerNetworkAddress()$seperator$SteamID$seperator$AdminStatus$seperator$class'Rx_Game'.static.GetTeamName(C.PlayerReplicationInfo.Team.TeamIndex)$seperator$C.PlayerReplicationInfo.PlayerName);
	}
	return List;
}

/** Log messages for Gameplay/Server-management events. Will be written to the logfile with a RenX tag, and sent out to any Log Subscribers over Rcon. */
final function RxLog(string Msg)
{
	if (bLogRcon)
		`log(Msg,true,'Rx');

	if(bLogRcon && !(worldinfo.IsPlayInEditor() || worldinfo.IsPlayInPreview()))
		Rx_GameEngine(class'Engine'.static.GetEngine()).RconLog(Msg);
}

final function RxLogPub(string Msg)
{
	if (bLogRcon)
		`log(Msg,true,'Rx');

	if(bLogRcon && !(worldinfo.IsPlayInEditor() || worldinfo.IsPlayInPreview()))
		Rx_GameEngine(class'Engine'.static.GetEngine()).RconLogPub(Msg);
}

function LogBuildingDestroyed(PlayerReplicationInfo Destroyer, Rx_Building_Team_Internals BuildingInternals, Rx_Building Building, class<DamageType> DamageType)
{		
	local Rx_Mutator Rx_Mut;
	
	RxLog("GAME"`s "Destroyed;"`s "building"`s Building.Class `s "by"`s `PlayerLog(Destroyer)`s "with"`s DamageType);

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnBuildingDestroyed(Destroyer, BuildingInternals, Building, DamageType);
	}
}

function SendPM(PlayerController Sender, int RecipientID, String msg)
{
	local PlayerReplicationInfo PRI;

	// If PMing is not allowed, only allow Admins to do so.
	if (!bAllowPrivateMessaging && !Sender.PlayerReplicationInfo.bAdmin)
	{
		Sender.ClientMessage("This server does not allow Private Messaging.");
		return;
	}

	if (UTPlayerController(Sender).bServerMutedText)
	{
		Sender.ClientMessage("You are muted from chat, including Private Messaging.");
		return;
	}

	PRI = FindPlayerByID(RecipientID);

	if (PRI.bBot || PRI == Sender.PlayerReplicationInfo)    // can't PM to bots or yourself.
		return;
	if (bPrivateMessageTeamOnly && PRI.Team != Sender.PlayerReplicationInfo.Team)   // If game doesn't allow PMing the enemy.
	{
		Sender.ClientMessage("This server only allows Private Messaging to teammates.");
		return;
	}
	Rx_BroadcastHandler(BroadcastHandler).BroadcastPM(Sender, Rx_Controller(PRI.Owner), Msg);
	return;
}

function PlayerReplicationInfo FindPlayerByID(int ID)
{
	local PlayerReplicationInfo PRI;

	foreach GameReplicationInfo.PRIArray(PRI)
		if (PRI.PlayerID == ID)
			return PRI;
}

// For Servers, use Rx_Controller::ParsePlayer as server. ANY CHANGES HERE SHOULD BE MADE TO THE RX_CONTROLLER FUNCTION AS WELL.
function Rx_PRI ParsePlayer(String in, optional out string Error)
{
	//local int id;
	local string temp;
	local int id;
	local PlayerReplicationInfo PRI, Match;

	//The UE3 console has problems if the first character is a symbol, disabled finding by ID for the mo.

	// If the first char is a #, then try to parse by player id.
	if (Left(in,3) ~= "pid")
	{
		id = int(Mid(in, 3));
		if (id != 0)
		{
			// Parsed numbers after the "pid", now check to see if there were non-numeric characters as well
			temp = string(id);
			if ( Len(temp) == Len(Mid(in, 3)) )
			{
				// Equal length means there were no non-numerics in the string at all, so continue to find by Player ID
				foreach GameReplicationInfo.PRIArray(PRI)
					if (PRI.PlayerID == id)
						return Rx_PRI(PRI);
			}
		}
	}
	

	// Failed to find by ID, Attempt to find by Name
	temp = Caps(in); // make case insensitive
	foreach GameReplicationInfo.PRIArray(PRI)
	{
		if (InStr(Caps(PRI.PlayerName), temp) != -1)
		{
			if (Match == None)
				Match = PRI;
			else
			{
				// Multiple matches, abort.
				Error = "Multiple player matches on \""$in$"\", please be more specific.";
				return None;
			}
		}
	}
	
	if (Match != None)
	{
		// We found one match by name.
		return Rx_PRI(Match);
	}
	Error = "No player matches on \""$in$"\" found.";
	return None;
}

exec function AddAdministrator(int id)
{
	Rx_AccessControl(AccessControl).AddAdmin(None, FindPlayerByID(id), false);
}

function ClientRequestDemoRec(Rx_Controller who)
{
	if (bDisableDemoRequests)
		return;

	if (!WorldInfo.IsRecordingDemo())
	{
		ClientDemoInProgress = true;
		RxLog("DEMO"`s"Record;"`s"client request by"`s`PlayerLog(who.PlayerReplicationInfo));
		ConsoleCommand("demorec" @ string(WorldInfo.GetPackageName()) $ "-%td");
		SetTimer(120,false,'StopDemoRecording');
	}
}

function AdminDemoRec(Rx_Controller who)
{
	if (WorldInfo.IsRecordingDemo())
	{
		if (ClientDemoInProgress)
		{
			ClearTimer('StopDemoRecording');
			StopDemoRecording();
			AdminRecord(who);
		}
	}
	else
		AdminRecord(who);
}

function AdminRecord(Rx_Controller who)
{
	if (who != None)
		RxLog("DEMO"`s"Record;"`s"admin command by"`s`PlayerLog(who.PlayerReplicationInfo));
	else
		RxLog("DEMO"`s"Record;"`s"rcon command");
	ConsoleCommand("demorec" @ string(WorldInfo.GetPackageName()) $ "-%td");
}

function StopDemoRecording()
{
	RxLog("DEMO" `s "RecordStop;");
	ClientDemoInProgress = false;
	ConsoleCommand("demostop");
}

/** one1: added */
event VoteTimer()
{
	if (GlobalVote != none)
		GlobalVote.ServerSecondTick(self);
	if (GDIVote != none)
		GDIVote.ServerSecondTick(self);
	if (NODVote != none)
		NODVote.ServerSecondTick(self);
}

function DestroyVote(Rx_VoteMenuChoice vote)
{
	vote.DestroyVote(self);

	if (GlobalVote == vote)
		GlobalVote = none;
	else if (GDIVote == vote)
		GDIVote = none;
	else if (NODVote == vote)
		NODVote = none;
}
	
function GenericPlayerInitialization(Controller C)
{
	HUDType = HudClass;
	super(GameInfo).GenericPlayerInitialization(C);
}		

event PostLogin( PlayerController NewPlayer )
{
	local string SteamID;
	local int AvgVeterancy; 
	local PlayerReplicationInfo PRI;
	local int num; 
	local Rx_Mutator Rx_Mut;

	//if(NewPlayer.bIsPlayer)
		//`RecordLoginChange(LOGIN, NewPlayer, NewPlayer.PlayerReplicationInfo.PlayerName, NewPlayer.PlayerReplicationInfo.UniqueId, false);

	if (TeamMode != 4)
	{
		SetTeam(NewPlayer, UTTeamInfo(`RxEngineObject.GetInitialTeam(NewPlayer.PlayerReplicationInfo)), false);
		//`log("Call PostLogin: " @ `RxEngineObject.IsPlayerCommander(NewPlayer.PlayerReplicationInfo));
		if(bUseStaticCommanders && `RxEngineObject.IsPlayerCommander(NewPlayer.PlayerReplicationInfo) ) ChangeCommander(NewPlayer.GetTeamNum(), Rx_PRI(NewPlayer.PlayerReplicationInfo), true); 
	}

	SteamID = OnlineSub.UniqueNetIdToString(NewPlayer.PlayerReplicationInfo.UniqueId);
	if (SteamID == `BlankSteamID || SteamID == "")
		RxLog("PLAYER" `s "Enter;" `s `PlayerLog(NewPlayer.PlayerReplicationInfo) `s "from" `s NewPlayer.GetPlayerNetworkAddress() `s "hwid" `s Rx_Controller(NewPlayer).PlayerUUID `s "nosteam");
	else
		RxLog("PLAYER" `s "Enter;" `s `PlayerLog(NewPlayer.PlayerReplicationInfo) `s "from" `s NewPlayer.GetPlayerNetworkAddress() `s "hwid" `s Rx_Controller(NewPlayer).PlayerUUID `s "steamid"`s SteamID);
	
	AnnounceTeamJoin(NewPlayer.PlayerReplicationInfo, NewPlayer.PlayerReplicationInfo.Team, None, false);

	super.PostLogin(NewPlayer);
				
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

	Rx_PRI(NewPlayer.PlayerReplicationInfo).bCanRequestCheatBots = CheckCheatBot();

	//Disable veterancy accordingly for surrenders
	if(Rx_Pri(NewPlayer.PlayerReplicationInfo) != None && Rx_Pri(NewPlayer.PlayerReplicationInfo).GetTeamNum() == TEAM_GDI && bGDIHasSurrendered)
	{
		Rx_Pri(NewPlayer.PlayerReplicationInfo).DisableVeterancy(true); 	
	}
	
	
	if( Rx_Pri(NewPlayer.PlayerReplicationInfo) != none)
	{

	//Set Commander if they exist
	if(Rx_PRI(NewPlayer.PlayerReplicationInfo).GetTeamNum() == 0 && Commander_PRI[0] != none) Rx_PRI(NewPlayer.PlayerReplicationInfo).SetCommander(Commander_PRI[0]) ;
	else
	if(Rx_PRI(NewPlayer.PlayerReplicationInfo).GetTeamNum() == 1 && Commander_PRI[1] != none) Rx_PRI(NewPlayer.PlayerReplicationInfo).SetCommander(Commander_PRI[1]) ;

		foreach GameReplicationInfo.PRIArray(PRI) 
		{			
		if(Rx_PRI(PRI) == none) continue;
		
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

function UpdateDiscordPresence() {
	local Rx_Controller P;
	foreach WorldInfo.AllControllers(class'Rx_Controller', P) {
		P.UpdateDiscordPresence(MaxPlayers);
	}
}

function Logout( Controller Exiting )
{
	local UTPlayerReplicationInfo PRI;
	local UTPlayerController ExitingPC;
	local int i;
	local Rx_Mutator Rx_Mut;
	
	if (Rx_Controller(Exiting) != None)
	{
		Rx_Controller(Exiting).BindVehicle(None);
	}
	if (Rx_PRI(Exiting.PlayerReplicationInfo) != None && Rx_Bot_Scripted(Exiting) == None)
	{
		
		for(i=0;i<2;i++)
		{
			if(Exiting.PlayerReplicationInfo == Commander_PRI[i]) RemoveCommander(i); 
		}
		
		Rx_PRI(Exiting.PlayerReplicationInfo).DestroyATMines();
		Rx_PRI(Exiting.PlayerReplicationInfo).DestroyRemoteC4();
	}

	PRI = UTPlayerReplicationInfo(Exiting.PlayerReplicationInfo);
	if ( PRI.bHasFlag )
	{
		PRI.GetFlag().Drop();
	}


	// Remove from all mute lists so they can rejoin properly
	ExitingPC = UTPlayerController( Exiting );
	if( ExitingPC != None )
	{
		RemovePlayerFromMuteLists( ExitingPC );
	}


	Super(UDKGame).Logout(Exiting);
	if(Rx_Bot_Scripted(Exiting) == None)
	{
		if (Exiting.IsA('UTBot') && !UTBot(Exiting).bSpawnedByKismet)
		{
			i = ActiveBots.Find('BotName', Exiting.PlayerReplicationInfo.PlayerName);
			if (i != INDEX_NONE)
			{
				ActiveBots[i].bInUse = false;
			}
			NumBots--;
		}

		if ( NeedPlayers() )
		{
			AddBot();
		}

		if (MaxLives > 0)
		{
			CheckMaxLives(None);
		}

	}

	RxLog("PLAYER"`s "Exit;"`s `PlayerLog(Exiting.PlayerReplicationInfo));

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Bot_Scripted(Exiting) == None &&Rx_Mut != None)
	{
		Rx_Mut.OnPlayerDisconnect(Exiting);
	}
	
	//if(Rx_Controller(Exiting) != none) 
		//`RecordLoginChange(LOGOUT,Exiting,Exiting.PlayerReplicationInfo.PlayerName,Exiting.PlayerReplicationInfo.UniqueId, false)

	UpdateDiscordPresence();
}

function KillBot(UTBot B)
{
	if(DesiredPlayerCount > 1)
		DesiredPlayerCount--;
	Super.KillBot(B);
}

exec function KillBots()
{
	local UTBot B;

	bPlayersVsBots = false;

	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		KillBot(B);
	}
}

function String getPlayerStatsStringFromPri(Rx_Pri pri)
{
	local String ret;
	if(OnlineSub == None) {
		OnlineSub = Class'GameEngine'.static.GetOnlineSubsystem();
	}
	if(OnlineSub.UniqueNetIdToString(pri.UniqueId) == `BlankSteamID) {
		return "";
	}	
	ret = ret$OnlineSub.UniqueNetIdToString(pri.UniqueId)$",";	
	ret = ret$Repl(Repl(pri.PlayerName,";",""), ",","")$",";
	ret = ret$pri.GetRenScore()$",";
	ret = ret$pri.GetRenPlayerKills()$",";
	ret = ret$pri.deaths$",";
	ret = ret$pri.GetTeamNum()$",";
	if(GameReplicationInfo.Winner == None) {
		ret = ret$2;	
	} else if(GameReplicationInfo.Winner.GetTeamNum() == pri.GetTeamNum()) {
		ret = ret$1;
	} else {
		ret = ret$0;
	}
	loginternal(ret);
	return ret;
}

static function string GuidToHex(Guid in_guid)
{
	return class'Rx_RconConnection'.static.intToHex(in_guid.A) $ class'Rx_RconConnection'.static.intToHex(in_guid.B) $ class'Rx_RconConnection'.static.intToHex(in_guid.C) $ class'Rx_RconConnection'.static.intToHex(in_guid.D);
}

/** Fetches a server variable by name. */
function string GetGameProperty(string prop)
{
	switch(Caps(prop))
	{
		// ServerInfo defaults
	case "PORT":
		return string(Port);
	case "NAME": // Alias
	case "SERVERNAME":
		return WorldInfo.GRI.ServerName;
	case "LEVEL": // Alias
	case "MAP": // Alias
	case "PACKAGE": // Alias
	case "PACKAGENAME": // Alias
	case "GETPACKAGENAME": // Alias(Function)
		return string(GetPackageName());
	case "LEVELGUID": // Alias
	case "MAPGUID": // Alias
	case "PACKAGEGUID": // Alias
	case "GUID":
		return GuidToHex(GetPackageGuid(GetPackageName()));
	case "PLAYERS": // Alias
	case "NUMPLAYERS":
		return string(NumPlayers);
	case "BOTS": // Alias
	case "NUMBOTS":
		return string(NumBots);

		// GameInfo defaults
	case "PLAYERLIMIT": // Alias
	case "MAXPLAYERS":
		return string(MaxPlayers);
	case "VEHICLELIMIT":
		return string(VehicleLimit);
	case "MINELIMIT":
		return string(MineLimit);
	case "TIMELIMIT":
		return string(TimeLimit);
	case "BPASSWORDED": // Alias
	case "REQUIRESPASSWORD": // Alias(Function)
		return string(AccessControl.RequiresPassword());
	case "BSTEAMREQUIRED": // Alias
	case "BREQUIRESTREAM":
		return string(Rx_AccessControl(AccessControl).bRequireSteam);
	case "BPRIVATEMESSAGETEAMONLY":
		return string(bPrivateMessageTeamOnly);
	case "BALLOWPRIVATEMESSAGING":
		return string(bAllowPrivateMessaging);
	case "BAUTOBALANCETEAMS": // Alias
	case "BSPAWNCRATES": // Alias
	case "SPAWNCRATES":
		return string(SpawnCrates);
	case "CRATERESPAWNAFTERPICKUP":
		return string(CrateRespawnAfterPickup);

		// Some others in Rx_Game (hey, maybe somebody will want it -shrugs-)
	case "BFIXEDMAPROTATION":
		return string(bFixedMapRotation);
	case "RECENTMAPSTOEXCLUDE":
		return string(RecentMapsToExclude);
	case "MAXMAPVOTESIZE":
		return string(MaxMapVoteSize);
	case "INITIALCREDITS":
		return string(InitialCredits);
	case "BBOTSDISABLED":
		return string(bBotsDisabled);
	case "DONATIONSDISABLEDTIME":
		return string(DonationsDisabledTime);
	case "BRESERVEVEHICLESTOBUYER":
		return string(bReserveVehiclesToBuyer);
	case "BISCOMPETITIVE":
	case "BCOMPETITIVE":
		return string(bIsCompetitive);
	case "BISCLANWARS":
		return string(bIsClanwars);
	case "BLISTED":
		return string(bListed);
	case "BUNLISTED":
		return string(!bListed);
	case "GAMEVERSION":
		return GameVersion;
	case "GAMEVERSIONNUMBER":
		return string(GameVersionNumber);
	case "BDISABLEDEMOREQUESTS":
		return string(bDisableDemoRequests);
	case "GAMEMODE":
	case "MODE":
		return string(WorldInfo.Game.Class);
	case "MATCHIISNPROGRESS":
	case "MATCHINPROGRESS":
	case "MIP":
		return string(MatchIsInProgress());
	case "MATCHSTATE":
	case "GAMESTATE":
		return string(GetStateName());

		// Not found
	default:
		return "ERR_UNKNOWNVAR";
	}
}

event InitGame( string Options, out string ErrorMessage )
{	
	//local int MapIndex;

	LANBroadcast = new class'Rx_LANBroadcast';
	
	if(Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap)
	{
		if(TimeLimit != 10)
			CnCModeTimeLimit = TimeLimit;
		TimeLimit = 10;
		bSpawnInTeamArea = false;
	} else if(CnCModeTimeLimit > 0 && CnCModeTimeLimit != TimeLimit)
	{
		TimeLimit = CnCModeTimeLimit;
	}

	if (WorldInfo.NetMode == NM_Standalone)
		TeamMode = 4;

	super.InitGame(Options, ErrorMessage);
	TeamFactions[TEAM_GDI] = "GDI";
	TeamFactions[TEAM_NOD] = "Nod";
	if(bFillSpaceWithBots)
		DesiredPlayerCount = Rx_MapInfo(WorldInfo.GetMapInfo()).MinNumPlayers;
	else
		DesiredPlayerCount = 1;
	bCanPlayEvaBuildingUnderAttackGDI = true;
	bCanPlayEvaBuildingUnderAttackNOD = true;

	if (Role == ROLE_Authority )
	{
		FindRefineries(); // Find the refineries so we can give players credits
	}

	IgnoreGameServerVersionCheck = HasOption( Options, "IgnoreGameServerVersionCheck");

	GDIBotCount = GetIntOption( Options, "GDIBotCount",0);
	NODBotCount = GetIntOption( Options, "NODBotCount",0);
	AdjustedDifficulty = 5;
	GDIDifficulty = GetIntOption( Options, "GDIDifficulty",4);
	NODDifficulty = GetIntOption( Options, "NODDifficulty",4);
	GDIDifficulty += 3;
	NODDifficulty += 3;
	
	if (WorldInfo.NetMode == NM_DedicatedServer) //Static limits on-line
	{
		MineLimit = Rx_MapInfo(WorldInfo.GetMapInfo()).MineLimit;
		VehicleLimit= Rx_MapInfo(WorldInfo.GetMapInfo()).VehicleLimit;
	}
	else if(WorldInfo.NetMode == NM_Standalone)
	{
		MineLimit = GetIntOption( Options, "MineLimit", MineLimit);
		VehicleLimit = GetIntOption( Options, "VehicleLimit", VehicleLimit);
		bDelayedStart = false;
		//AddInitialBots();	
	}

	InitialCredits = GetIntOption(Options, "StartingCredits", InitialCredits);
	PlayerTeam = GetIntOption( Options, "Team",0);
	GDIAttackingValue = GetIntOption( Options, "GDIAttackingStrengh",0.7);
	NodAttackingValue = GetIntOption( Options, "NodAttackingStrengh",0.7);
	//Port = GetIntOption( Options, "PORT",7777);
	Port = `GamePort;
	//GamePassword = ParseOption( Options, "GamePassword");
	

	// Initialize the maplist manager
	InitializeMapListManager();

	//adding fort mutator (nBab)
	if (WorldInfo.GetmapName() == "Fort")
	{
		AddMutator("RenX_nBabMutators.Fort");
		BaseMutator.InitMutator(Options, ErrorMessage);
	}
}


function InitializeMapListManager(optional string MLMOverrideClass)
{
	local class<Rx_MapListManager> MapListManagerClass;

	if (MLMOverrideClass == "")
		MLMOverrideClass = MapListManagerClassName;

	if (MLMOverrideClass != "")
		MapListManagerClass = Class<Rx_MapListManager>(DynamicLoadObject(MLMOverrideClass, Class'Class'));

	if (MapListManagerClass == none)
		MapListManagerClass = Class'Rx_MapListManager';

	MapListManager = Spawn(MapListManagerClass);

	if (MapListManager == none && MapListManagerClass != Class'Rx_MapListManager')
	{
		`log("Unable to spawn maplist manager of class '"$MLMOverrideClass$"', loading the default maplist manager");
		MapListManager = Spawn(Class'Rx_MapListManager');
	}

	MapListManager.Initialize();
}
function int InitBotDifficultyFromBaseDifficulty(int Difficulty)
{
	local int ret;
	if(Difficulty == 0) {
		ret = 2;
	} else if(Difficulty == 1) {
		ret = 4;
	} else if(Difficulty == 2) {
		ret = 6;
	} else if(Difficulty == 3) {
		ret = 7;
	}
	return ret;
}

function AddInitialBots()
{
	
	if( bInitialBotsCreated) return; 
	
	if(GDIBotCount > 0) {
		AdjustedDifficulty = GDIDifficulty;
		AddRedBots(GDIBotCount);
		
		loginternal("GDIDifficulty"$GDIDifficulty);
	}	
	if(NODBotCount > 0) {
		AdjustedDifficulty = NODDifficulty;
		AddBlueBots(NODBotCount);
		loginternal("NODDifficulty"$NODDifficulty);
	}
	bInitialBotsCreated=true; 
}

function CreateTeam(int TeamIndex) 
{
	if (TeamIndex > 2) // only 2: GDI and NOD
	  return;

	Teams[TeamIndex] = spawn(TeamInfoClass);
	Teams[TeamIndex].Faction = TeamFactions[TeamIndex];
	Teams[TeamIndex].Initialize(TeamIndex);
	
	Rx_TeamInfo(Teams[TeamIndex]).VehicleLimit = VehicleLimit;
	Rx_TeamInfo(Teams[TeamIndex]).mineLimit = MineLimit;
	//Setup CP
	Rx_TeamInfo(Teams[TeamIndex]).InitCommandPoints(Max_CP, InitialCP);
	
	
	Teams[TeamIndex].AI = Spawn(TeamAIType[TeamIndex]);
	Teams[TeamIndex].AI.Team = Teams[TeamIndex];
	Rx_TeamAI(Teams[TeamIndex].AI).InitializeOrderList();
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
	Teams[TeamIndex].AI.SetObjectiveLists();    
	if(TeamIndex == TEAM_GDI) {
		Rx_TeamAI(Teams[TeamIndex].AI).MinAttackersRatio[TEAM_GDI] = GDIAttackingValue/100.0;
		loginternal("GDI:"$Rx_TeamAI(Teams[TeamIndex].AI).MinAttackersRatio[TEAM_GDI]);
	} else {
		Rx_TeamAI(Teams[TeamIndex].AI).MinAttackersRatio[TEAM_Nod] = NodAttackingValue/100.0;
		loginternal("Nod:"$Rx_TeamAI(Teams[TeamIndex].AI).MinAttackersRatio[TEAM_Nod]);
	}

}

function bool CheckCheatBot()
{
	return Rx_TeamAI(Teams[0].AI).bCanGetCheatBot;
}

function bool ToggleForceBot()
{
	local bool bNewSetup;
	local int BotNeeded;

	bNewSetup = !bFillSpaceWithBots;

	bFillSpaceWithBots = bNewSetup;

	if(bFillSpaceWithBots)
	{
		DesiredPlayerCount = Clamp(Max(DesiredPlayerCount, Rx_MapInfo(WorldInfo.GetMapInfo()).MinNumPlayers), 1, 64);
		BotNeeded = DesiredPlayerCount - NumPlayers - NumBots;

		if(BotNeeded > 0)
			AddBots(BotNeeded);
	}
	else
	{
		DesiredPlayerCount = NumPlayers+NumBots;
	}

	

	return true;
}

function bool ToggleCheatBot()
{
	local PlayerReplicationInfo pri;

	if(Teams[0].AI == None)
		return false;


	if(Rx_TeamAI(Teams[0].AI).bCanGetCheatBot)
	{
		Rx_TeamAI(Teams[0].AI).bCanGetCheatBot = false;
		Rx_TeamAI(Teams[1].AI).bCanGetCheatBot = false;
	}

	else
	{
		Rx_TeamAI(Teams[0].AI).bCanGetCheatBot = true;
		Rx_TeamAI(Teams[1].AI).bCanGetCheatBot = true;
	}

	foreach WorldInfo.GRI.PRIArray(pri)
	{
		Rx_PRI(pri).bCanRequestCheatBots = CheckCheatBot();
	}

	return true;
}

function SetPlayerDefaults(Pawn PlayerPawn)
{
	if(Rx_Pri(PlayerPawn.PlayerReplicationInfo) != none)
	{ 
		Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.GetStartClass(PlayerPawn.GetTeamNum(), PlayerPawn.PlayerReplicationInfo);
		`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PlayerPawn.PlayerReplicationInfo) `s "character" `s UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo).CharClassInfo);
		PlayerPawn.NotifyTeamChanged();
	}
	
	if(Rx_Bot(PlayerPawn.Controller) != None) 
	{
		if(!Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = Rx_Bot(PlayerPawn.Controller).BotBuy(Rx_Bot(PlayerPawn.Controller), true);
		} else if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_GDI) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.GDIInfantryClasses[Rand(PurchaseSystem.GDIInfantryClasses.Length)];
			`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PlayerPawn.PlayerReplicationInfo) `s "character" `s UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo).CharClassInfo);
		} else if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_NOD) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.NodInfantryClasses[Rand(PurchaseSystem.NodInfantryClasses.Length)];
			`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PlayerPawn.PlayerReplicationInfo) `s "character" `s UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo).CharClassInfo);
		}
		//Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = class'Rx_FamilyInfo_Nod_StealthBlackHand';
		//Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = class'Rx_FamilyInfo_Nod_RocketSoldier';
		PlayerPawn.NotifyTeamChanged();
	} else if(Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap)
	{
		if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_GDI) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.GDIInfantryClasses[Rand(PurchaseSystem.GDIInfantryClasses.Length)];
		} else if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_NOD) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.NodInfantryClasses[Rand(PurchaseSystem.NodInfantryClasses.Length)];
		}
		PlayerPawn.NotifyTeamChanged();
	}
	
	super.SetPlayerDefaults(PlayerPawn);

	if(Rx_Controller(PlayerPawn.Controller) != None && PurchaseSystem.IsStealthBlackHand( Rx_PRI(PlayerPawn.PlayerReplicationInfo) ) ) 
	{
		Rx_Controller(PlayerPawn.Controller).SetJustBaughtEngineer(false);
		Rx_Controller(PlayerPawn.Controller).SetJustBaughtHavocSakura(false);
		Rx_Controller(PlayerPawn.Controller).ChangeToSBH(true);	
	} 
	else if(Rx_Bot(PlayerPawn.Controller) != None && PurchaseSystem.IsStealthBlackHand( Rx_PRI(PlayerPawn.PlayerReplicationInfo) ) ) 
	{
		Rx_Bot(PlayerPawn.Controller).ChangeToSBH(true);
	} else {
		if (Rx_Controller(PlayerPawn.Controller) != none) {
			Rx_Controller(PlayerPawn.Controller).SetJustBaughtEngineer(false);
			Rx_Controller(PlayerPawn.Controller).SetJustBaughtHavocSakura(false);
			Rx_Controller(PlayerPawn.Controller).RemoveCurrentSidearmAndExplosive();
		}
		Rx_Pri(PlayerPawn.PlayerReplicationInfo).equipStartWeapons();
	}
	
	
}

function AddDefaultInventory( Pawn PlayerPawn )
{
	local int i;
	for (i=0; i<DefaultInventory.Length; i++)
	{
		// Ensure we don't give duplicate items
		if (PlayerPawn.FindInventoryType( DefaultInventory[i] ) == None)
		{
			// Only activate the first weapon
			PlayerPawn.CreateInventory(DefaultInventory[i], (i > 0));
		}
	}
	PlayerPawn.AddDefaultInventory();
}

static function string GetPRILogName(PlayerReplicationInfo PRI)
{
	if (Rx_PRI(PRI) != None)
		return class'Rx_PRI'.static.LogNameOf(PRI);
	else if (Rx_DefencePRI(PRI) != None)
		return class'Rx_DefencePRI'.static.LogNameOf(PRI);
	else
	{
		`log("Tried to get LogName of a non-Rx PRI class.");
		return"";
	}
}

function DropPowerUp(Rx_Pawn Killed)
{
	local Rx_Pickup PowerUp;
	local int index;

	if (PowerUpClasses.Length == 0)
		return;

	index = Rand(PowerUpClasses.Length + Killed.GetRxFamilyInfo().default.PowerUpClasses.Length);

	if (index < PowerUpClasses.Length)
		PowerUp = Spawn(PowerUpClasses[index], Self, , Killed.Location, Killed.Rotation, , true);
	else
		PowerUp = Spawn(Killed.GetRxFamilyInfo().default.PowerUpClasses[index - PowerUpClasses.Length], Self, , Killed.Location, Killed.Rotation, , true);

	PowerUp.PickupsRemaining = 1;
	PowerUp.SetTimer(PowerUp.DespawnTime, false, 'Expire');
}

// managed extra score for kills and destruction (only player and vehicles)
function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
	local Rx_PRI PlayerPRI;
	local string KillerLogStr;
	local bool		bEnemyKill;
	local UTPlayerReplicationInfo KillerPRI, KilledPRI;
	local UTVehicle V;
	
	local Rx_Mutator Rx_Mut;
	local bool bValidPlayerDeath;

	bValidPlayerDeath = Rx_Bot_Scripted(KilledPlayer) == None;
	
	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnPlayerKill(Killer, KilledPlayer, KilledPawn, damageType);
	}

	if ( Killer != None )
	{
		PlayerPRI = Rx_PRI(Killer.PlayerReplicationInfo);

		// Adds logging for AIControllers, but passes objects with a PRI on to normal logging.
		if (AIController(Killer) != None && Killer.PlayerReplicationInfo == None)
			KillerLogStr = class'Rx_Game'.static.GetTeamName(Killer.GetTeamNum()) $ ",ai," $ Killer.Pawn.Class.name;
		else
			KillerLogStr = `PlayerLog(Killer.PlayerReplicationInfo);

		// score for vehicles here
		if ( Rx_Vehicle(KilledPawn) != None && KilledPawn.GetTeamNum() != Killer.GetTeamNum() )
		{
			if (PlayerPRI != None)
				PlayerPRI.AddScoreToPlayerAndTeam(Rx_Vehicle(KilledPawn).PointsForDestruction);

			if (Rx_Defence(KilledPawn) != None)
				RxLog("GAME"`s "Destroyed;" `s "defence" `s KilledPawn.Class `s "by" `s KillerLogStr`s "with"`s damageType);
			else if (Rx_Defence_Emplacement(KilledPawn) != None)
				RxLog("GAME"`s "Destroyed;" `s "emplacement" `s KilledPawn.Class `s "by" `s KillerLogStr`s "with"`s damageType);
			else
				RxLog("GAME"`s "Destroyed;" `s "vehicle" `s KilledPawn.Class `s "by" `s KillerLogStr`s "with"`s damageType);
		}
		// score for pawns here
		else if ( Rx_Pawn(KilledPawn) != None && KilledPlayer != none)
		{
			if (PlayerPRI != None)
			{
				if (KilledPlayer.GetTeamNum() != Killer.GetTeamNum() )
				{
					PlayerPRI.AddScoreToPlayerAndTeam(class<Rx_FamilyInfo>(Rx_Pawn(KilledPawn).CurrCharClassInfo).default.PointsForKill);
					if(bValidPlayerDeath)
					{
						Rx_TeamInfo(PlayerPRI.Team).AddKill();
						Rx_TeamInfo(KilledPlayer.PlayerReplicationInfo.Team).AddDeath();
					}
				}
				if(Killer != KilledPlayer && PlayerController(Killer) != none && bValidPlayerDeath) 
				{
					Rx_Controller(PlayerController(Killer)).PlayKillSound();
					//if(Rx_Controller(PlayerController(Killer)).bSuspect) 
					Rx_Controller(PlayerController(Killer)).SLogKill(damageType, KilledPlayer.PlayerReplicationInfo.Playername);
				}
			}

			if (KilledPlayer != none && Killer != KilledPlayer && bValidPlayerDeath)
				RxLog("GAME"`s "Death;"`s "player"`s `PlayerLog(KilledPlayer.PlayerReplicationInfo)`s "by"`s KillerLogStr `s "with"`s damageType);
			else
				RxLog("GAME"`s "Death;"`s "player"`s KillerLogStr`s "suicide by"`s damageType);

			if (bAllowPowerUpDrop)
				DropPowerUp(Rx_Pawn(KilledPawn));
		}
	}
	else if (KilledPlayer != none && Rx_PRI(KilledPlayer.PlayerReplicationInfo) != None && bValidPlayerDeath)    // ignore ai being destroyed (notably harvester death due to refinery lost)
	{
		`SupressNullDamageType(RxLog("GAME"`s "Death;"`s "player"`s `PlayerLog(KilledPlayer.PlayerReplicationInfo)`s "died by"`s damageType));
	}

	if (bValidPlayerDeath && UTBot(KilledPlayer) != None )
		UTBot(KilledPlayer).WasKilledBy(Killer);

	if ( Killer != None )
		KillerPRI = UTPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( KilledPlayer != None )
		KilledPRI = UTPlayerReplicationInfo(KilledPlayer.PlayerReplicationInfo);

	bEnemyKill = ( ((KillerPRI != None) && (KillerPRI != KilledPRI) && (KilledPRI != None)) && (!bTeamGame || (KillerPRI.Team != KilledPRI.Team)) );

	if ( (KillerPRI != None) && UTVehicle(KilledPawn) != None )
	{
		KillerPRI.IncrementVehicleKillStat(UTVehicle(KilledPawn).GetVehicleKillStatName());
	}
	if (bValidPlayerDeath && KilledPRI != None)
	{
		KilledPRI.LastKillerPRI = KillerPRI;

		if ( class<UTDamageType>(DamageType) != None )
		{
			class<UTDamageType>(DamageType).static.ScoreKill(KillerPRI, KilledPRI, KilledPawn);
		}
		else
		{
			// assume it's some kind of environmental damage
			if ( (KillerPRI == KilledPRI) || (KillerPRI == None) )
			{
				KilledPRI.IncrementSuicideStat('SUICIDES_ENVIRONMENT');
			}
			else
			{
				KillerPRI.IncrementKillStat('KILLS_ENVIRONMENT');
				KilledPRI.IncrementDeathStat('DEATHS_ENVIRONMENT');
			}
		}
		if ( KilledPRI.Spree > 4 )
		{
			EndSpree(KillerPRI, KilledPRI);
		}
		else
		{
			KilledPRI.Spree = 0;
		}
		if ( KillerPRI != None )
		{
			KillerPRI.IncrementKills(bEnemyKill);

			if ( bEnemyKill )
			{
				V = UTVehicle(KilledPawn);

				if ( !bFirstBlood )
				{
					bFirstBlood = True;
					BroadcastLocalizedMessage( class'UTFirstBloodMessage', 0, KillerPRI );
					KillerPRI.IncrementEventStat('EVENT_FIRSTBLOOD');
				}
			}
		}
	}
    
    if( KilledPlayer != None && bValidPlayerDeath && KilledPlayer.bIsPlayer )
	{
		KilledPlayer.PlayerReplicationInfo.IncrementDeaths();
		KilledPlayer.PlayerReplicationInfo.SetNetUpdateTime(FMin(KilledPlayer.PlayerReplicationInfo.NetUpdateTime, WorldInfo.TimeSeconds + 0.3 * FRand()));
		BroadcastDeathMessage(Killer, KilledPlayer, damageType);
	}

    if( KilledPlayer != None  && bValidPlayerDeath)
	{
		ScoreKill(Killer, KilledPlayer);
	}

	DiscardInventory(KilledPawn, Killer);
    NotifyKilled(Killer, KilledPlayer, KilledPawn, damageType);

    if ( (WorldInfo.NetMode == NM_Standalone) && (PlayerController(KilledPlayer) != None) )
    {
		// clear telling bots not to get into nearby vehicles
		for ( V=VehicleList; V!=None; V=V.NextVehicle )
			if ( WorldInfo.GRI.OnSameTeam(KilledPlayer,V) )
				V.PlayerStartTime = 0;
	}

	if(Rx_Bot_Scripted(KilledPlayer) == None)
		ScoreRenKill(Killer,KilledPlayer);

	if(Killer != none && KilledPlayer != none)
	{
		`RecordDeathEvent(NORMAL, Killer, damageType, KilledPlayer);
	}
	else if(KilledPlayer != none)
	{
		`RecordDeathEvent(NORMAL, none, damageType, KilledPlayer);
	}
}

function GameEventsPoll()
{
	local Rx_Vehicle V;

	ForEach `WorldInfoObject.AllPawns(class'Rx_Vehicle', V)
	{
		if(Rx_Vehicle_Harvester(V) == none)
		{
			`RecordGamePositionStat(VEHICLE_LOCATION_POLL,V.Location, 1);		
			if(v.Team == TEAM_GDI)
			{
				`RecordGamePositionStat(VEHICLE_LOCATION_POLL_GDI,V.Location, 1);		
			}
			else if(v.Team == TEAM_NOD)
				`RecordGamePositionStat(VEHICLE_LOCATION_POLL_NOD,V.Location, 1);		
		}

		`RecordGamePositionStat(VEHICLE_WITH_HARV_LOCATION_POLL,V.Location, 1);	
	}

}

function ScoreRenKill(Controller Killer, Controller Other)
{
	if ( Killer != None && killer.PlayerReplicationInfo != None && Rx_PRI(killer.PlayerReplicationInfo) != None &&
		 Other != None && Other.PlayerReplicationInfo != None && Rx_PRI(Other.PlayerReplicationInfo) != None && Killer != Other)
	{
		Rx_PRI(Killer.PlayerReplicationInfo).AddRenKill(,!Other.bIsPlayer || Rx_Bot_Scripted(Other) != None);
	}

}

/** Suppress death messages caused by team switch and disconnects. */
function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> DamageType)
{
	if (DamageType == class'DamageType' && (Killer == Other || Killer == None))
		return;

	if (Killer == Other)
		BroadcastLocalized(self,DeathMessageClass, 1, None, Other.PlayerReplicationInfo, DamageType);
	else if (Killer == None)
		BroadcastLocalized(self,DeathMessageClass, 2, None, Other.PlayerReplicationInfo, DamageType);
	else
		super.BroadcastDeathMessage(Killer, Other, DamageType);
}

function EndSpree(UTPlayerReplicationInfo Killer, UTPlayerReplicationInfo Other);

function bool CheckScore(PlayerReplicationInfo Scorer)
{	
	return false;
}

function UTBot OnAddBot(UTBot bot)
{
	if (bot != None)
	{
		`LogRxPub("GAME" `s "Spawn;" `s "bot" `s `PlayerLog(bot.PlayerReplicationInfo));
		//`RecordLoginChange(LOGIN,bot,bot.PlayerReplicationInfo.PlayerName,bot.PlayerReplicationInfo.UniqueId, false)
	}
	return bot;
}

function InitializeBot(UTBot NewBot, UTTeamInfo BotTeam, const out CharacterInfo BotInfo)
{
	Rx_Bot(NewBot).RxInitialize(AdjustedDifficulty, BotInfo, BotTeam);
	
	if(Rx_Bot_Scripted(NewBot) == None)
		{
			BotTeam.AddToTeam(NewBot);
			ChangeName(NewBot, BotInfo.CharName, false);
			BotTeam.SetBotOrders(NewBot);
		}
}

exec function AddBots(int Num)
{
	local int AddCount;

	DesiredPlayerCount = Clamp(Max(DesiredPlayerCount, NumPlayers+NumBots)+Num, 1, 64);

	// add up to 8 immediately, then the rest automatically via game timer.
	while ( (NumPlayers + NumBots < DesiredPlayerCount) && (AddBot() != none) && (AddCount < 8) )
	{
		`log("added bot");
		AddCount++;
	}
}

exec function RxAddBots(int Num, optional int Skill, optional String ToTeam)
{
	local int AddCount;
	local bool bUseTeamIndex;
	local int TeamIndex;

	if(ToTeam != "")
	{
		bUseTeamIndex = true;

		if(ToTeam ~= "GDI")
		{
			TeamIndex = 0;
		}
		else if (ToTeam ~= "Nod")
		{
			TeamIndex = 1;
		}
		else
			bUseTeamIndex = false;
	}

	DesiredPlayerCount = Clamp(Max(DesiredPlayerCount, NumPlayers+NumBots)+Num, 1, 64);

	// add up to 8 immediately, then the rest automatically via game timer.
	while ( (NumPlayers + NumBots < DesiredPlayerCount) && (RxAddBot(Skill, ,bUseTeamIndex,TeamIndex) != none) && (AddCount < 8) )
	{
		`log("added bot");
		AddCount++;
	}
}

exec function UTBot AddNamedBot(string BotName, optional bool bUseTeamIndex, optional int TeamIndex)
{

	DesiredPlayerCount = Clamp(Max(DesiredPlayerCount, NumPlayers + NumBots) + 1, 1, 64);
	return AddBot(BotName, bUseTeamIndex, TeamIndex);
}

function UTBot RxAddBot(optional int Skill, optional string BotName, optional bool bUseTeamIndex, optional int TeamIndex)
{
	local int first, second;
	local PlayerController PC;	
	local UTBot B;
	
	if(bBotsDisabled || (NumPlayers+NumBots >= MaxPlayers))
		return None;
		
	if(bUseTeamIndex) 
	{
		B = OnAddBot(super.AddBot(BotName, bUseTeamIndex, TeamIndex));
	} 
	else 
	{
		first = 0;
		second = 1;
		// imbalance teams in favor of bot team in single player
		if (  WorldInfo.NetMode == NM_Standalone )
		{
			ForEach LocalPlayerControllers(class'PlayerController', PC)
			{
				if ( (PC.PlayerReplicationInfo.Team != None) && (PC.PlayerReplicationInfo.Team.TeamIndex == 1) )
				{
					first = 1;
					second = 0;
				}
				break;
			}
		}
		
		if ( Rx_TeamInfo(Teams[first]).Size < Rx_TeamInfo(Teams[second]).Size )
		{
			B = OnAddBot(super.AddBot(BotName, true, first));
		}
		else
		{
			B = OnAddBot(super.AddBot(BotName, true, second));
		}	
	}

	if(B != None && Skill > 0)
	{
		Skill = Clamp(Skill,1,9);
		B.Skill = Skill;
		B.ResetSkill();
	}

	return B;
}

function UTBot AddBot(optional string BotName, optional bool bUseTeamIndex, optional int TeamIndex)
{
	local int first, second;
	local PlayerController PC;	
	
	if(bBotsDisabled || (NumPlayers+NumBots >= MaxPlayers))
		return None;
		
	if(bUseTeamIndex) 
	{
		return OnAddBot(super.AddBot(BotName, bUseTeamIndex, TeamIndex));
	} 
	else 
	{
		first = 0;
		second = 1;
		// imbalance teams in favor of bot team in single player
		if (  WorldInfo.NetMode == NM_Standalone )
		{
			ForEach LocalPlayerControllers(class'PlayerController', PC)
			{
				if ( (PC.PlayerReplicationInfo.Team != None) && (PC.PlayerReplicationInfo.Team.TeamIndex == 1) )
				{
					first = 1;
					second = 0;
				}
				break;
			}
		}
		
		if ( Rx_TeamInfo(Teams[first]).Size < Rx_TeamInfo(Teams[second]).Size )
		{
			return OnAddBot(super.AddBot(BotName, true, first));
		}
		else
		{
			return OnAddBot(super.AddBot(BotName, true, second));
		}	
	}
}

function bool TooManyBots(Controller botToRemove)
{
	if(NumPlayers+NumBots > 64) // if exceeding player limit, there's *way* too many
		return true;

	if(!bFillSpaceWithBots)
		return false;

	if ((Rx_Bot(botToRemove).GetTeamNum() == TEAM_GDI && Teams[TEAM_GDI].Size > Teams[TEAM_NOD].Size)
			|| (Rx_Bot(botToRemove).GetTeamNum() == TEAM_NOD && Teams[TEAM_NOD].Size > Teams[TEAM_GDI].Size))
	{
			return Super.TooManyBots(botToRemove);
	}

	return false;
}

function CheckBuildingsDestroyed(Actor destroyedBuilding, Rx_Controller StarPC)
{
	local BuildingCheck Check;
	local PlayerReplicationInfo pri;
	local Rx_Controller PC;
	
	/*Show message where people will actually see it -Yosh (Remember the outrage when destruction and beacon messages were moved to the middle left? Yeah.. neither do the people that ranted about it.)*/
	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		if (StarPC == none)
			PC.CTextMessage(Caps("The"@destroyedBuilding.GetHumanReadableName()@ "was destroyed!"),'Red', 180);
		else if (PC.GetTeamNum() == StarPC.GetTeamNum())
		{
			PC.CTextMessage(Caps("The"@destroyedBuilding.GetHumanReadableName()@ "was destroyed!"),'Green',180);
			PC.DisseminateVPString("[Team Building Kill Bonus]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingDestroyed*Rx_Game(WorldInfo.Game).CurrentBuildingVPModifier $ "&");
		}
		else
		{
			PC.CTextMessage(Caps("The"@destroyedBuilding.GetHumanReadableName()@ "was destroyed!"),'Red',180);
		}
	}
	//End show message where people will actually look at it.

	if (Role == ROLE_Authority)
	{
		CurrentBuildingVPModifier +=0.5;
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
		
		if (Rx_Building_Nod_VehicleFactory(destroyedBuilding) != None || Rx_Building_AirTower(destroyedBuilding) != none && Rx_Building_Helipad_Nod(destroyedBuilding) == None)
		{
			if(PurchaseSystem.AreTeamFactoriesDestroyed(TEAM_NOD))
			{
				foreach WorldInfo.GRI.PRIArray(pri)
				{
					if(Rx_Pri(pri) != None && (Rx_Pri(pri).GetTeamNum() == TEAM_NOD) && Rx_Pri(pri).AirdropCounter == 0)
					{
						Rx_Pri(pri).AirdropCounter++;
						Rx_Pri(pri).LastAirdropTime=WorldInfo.TimeSeconds;
					}
				}
				VehicleManager.bNodIsUsingAirdrops = true;
				VehicleManager.NodAdditionalAirdropProductionDelay = 20.0;
			}
		}
		else if (Rx_Building_GDI_VehicleFactory(destroyedBuilding) != None && Rx_Building_Helipad_GDI(destroyedBuilding) == None)
		{
			if(PurchaseSystem.AreTeamFactoriesDestroyed(TEAM_GDI))
			{
				foreach WorldInfo.GRI.PRIArray(pri)
				{
					if(Rx_Pri(pri) != None && (Rx_Pri(pri).GetTeamNum() == TEAM_GDI) && Rx_Pri(pri).AirdropCounter == 0)
					{	
						Rx_Pri(pri).AirdropCounter++;
						Rx_Pri(pri).LastAirdropTime=WorldInfo.TimeSeconds;
					}
				}
				VehicleManager.bGDIIsUsingAirdrops = true;
				VehicleManager.GDIAdditionalAirdropProductionDelay = 20.0;
			}
		}
	
	if(Rx_Building(destroyedBuilding).GetTeamNum() == 0) 
			DestroyedBuildings_GDI++; 
		else
			DestroyedBuildings_Nod++; 
	
	}
	
	
}


/** CheckBuildings()
 *
 *
 *  RETURNS:
 *   BC_TeamsHaveBuildings      - both teams got min. 1 building left
 *   BC_GDIDestroyed            - means GDI lost all buildings (but Nod not!)
 *   BC_NodDestroyed            - means Nod lost all buildings (but GDI not!)
 *   BC_TeamsHaveNoBuildings    - means both teams lost all buildings
 **/
function BuildingCheck CheckBuildings () 
{
	local Rx_Building B;
	local bool BuildGDI, BuildNod;
	

	foreach AllActors(class'Rx_Building', B)
	{
		if(Rx_Building_Techbuilding(B) != None)
			continue;		
		if (B.GetTeamNum() == TEAM_GDI && !(B.IsDestroyed()) ) // GDI
		{
			BuildGDI = true;
		}
		else if (B.GetTeamNum() == TEAM_NOD && !(B.IsDestroyed())) // Nod
		{
			BuildNod = true;
		}
	}

	if ( !BuildGDI && BuildNod ) 
	{
		return BC_GDIDestroyed;
	}
	else if ( BuildGDI && !BuildNod )
	{
		return BC_NodDestroyed;
	}
	else if ( !BuildGDI && !BuildNod )
	{
		return BC_TeamsHaveNoBuildings;
	}

	return BC_TeamsHaveBuildings;
}

State MatchOver
{

	function BeginState( name PreviousState )
	{
		local Rx_Mutator Rx_Mut;
		
		//`log("################################ -( MatchOver:BeginState() )-");
		RenEndTime = WorldInfo.RealTimeSeconds + EndGameDelay;
		`log("RenEndTime: " $ RenEndTime);
		//M.Palko endgame crash track log.
		`log("------------------------------Now in state: MatchOver");
		UTGameReplicationInfo(GameReplicationInfo).bMatchIsOver = true;
		//M.Palko endgame crash track log.
		`log("------------------------------Game rep info bMatchIsOver set to true");
		super.BeginState(PreviousState);
		
		Rx_Mut = GetBaseRXMutator();
		if (Rx_Mut != None)
		{
			Rx_Mut.OnMatchEnd();
		}
	}


	function RestartGame()
	{
		LANBroadcast.close();
		if( RenEndTime < WorldInfo.RealTimeSeconds )
		{			
			EndLogging("Game Ended");
			super(GameInfo).RestartGame();
		}
	}
}

function RestartGame()
{
	LANBroadcast.close();
	Super.RestartGame();
}

function bool IsWinningTeam( TeamInfo T )
{
	local Rx_TeamInfo Tinfo;
	Tinfo = Rx_TeamInfo(T);

	if (Tinfo != none && Tinfo.TeamIndex == WinnerTeamNum)
		return true;	
	else return false;
}

State MatchInProgress
{
	function BeginState( Name PreviousState )
	{
		super.BeginState(PreviousState);
	}

	function EndState( Name NextStateName )
	{
		super.EndState(NextStateName);
	}

	function SwapTeams()
	{
		Global.SwapTeams();
		Broadcast(None, "Teams have been swapped.");
	}
}

function FindRefineries()
{
	local Rx_Building_Refinery ref;

	foreach AllActors(class'Rx_Building_Refinery', ref)
	{
		if (ref.GetTeamNum() == TEAM_GDI ) // GDI
		{
			TeamCredits[TEAM_GDI].Refinery.AddItem(ref);
		}
		else if (ref.GetTeamNum() == TEAM_NOD ) // Nod
		{
			TeamCredits[TEAM_NOD].Refinery.AddItem(ref);
		}
	}
}

function StartMatch()
{
	local Controller PC;
	local Rx_Mutator Rx_Mut;
	
	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnMatchStart();
	}
	
	RxLog("MAP" `s "Start;" `s GetPackageName());

	super.StartMatch();

	`RxEngineObject.ClearTeams();

	if (TeamMode != 4)
	{
		AdjustTeamBalance();
		AdjustTeamSize();
	}
	
	if (TeamCredits[TEAM_GDI].PlayerRI.Length > 0) {
		TeamCredits[TEAM_GDI].PlayerRI.Remove(0, TeamCredits[TEAM_GDI].PlayerRI.Length-1);
	}
	if (TeamCredits[TEAM_NOD].PlayerRI.Length > 0) {
		TeamCredits[TEAM_NOD].PlayerRI.Remove(0, TeamCredits[TEAM_NOD].PlayerRI.Length-1);
	}
	
	foreach WorldInfo.AllControllers( class'Controller', PC )
	{
		if(UTPlayerController(PC) != None || Rx_Bot(PC) != None) {
		
			if(TeamCredits[PC.GetTeamNum()].PlayerRI.Find(Rx_PRI(PC.PlayerReplicationInfo)) < 0) {
				TeamCredits[PC.GetTeamNum()].PlayerRI.AddItem(Rx_PRI(PC.PlayerReplicationInfo));
				Rx_PRI(PC.PlayerReplicationInfo).SetCredits( Rx_Game(WorldInfo.Game).InitialCredits ); 
				
			}
		}

		if (Rx_Controller(PC) != None) {
			Rx_Controller(PC).UpdateDiscordPresence(MaxPlayers);
		}
	}
	
	if(!Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap)
		VehicleManager.SpawnInitialHarvesters();
	
}

// Teams are balanced and sorted into lists at the end of a map. But incase someone leaves at the start of the new map, some players might need to be switched to bring back balance to the force.
// Balances based on player rankings from last map.
function AdjustTeamBalance()
{
	local float team1ranking;
	local float team2ranking;
	local Rx_Controller highestRankedPlayer;
	local PlayerReplicationInfo pri;
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		if(Rx_Mut.adjustTeamBalance())
			return;
	}	

	foreach WorldInfo.GRI.PRIArray(pri)
		if(Rx_Pri(pri) != None)
			if(pri.Team.TeamIndex == TEAM_GDI)
				team1ranking += Rx_PRI(pri).OldRenScore;
			else
				team2ranking += Rx_PRI(pri).OldRenScore;

	if(team1ranking == 0.0 && team2ranking == 0.0)
		return;

	if(team1ranking > team2ranking)
		highestRankedPlayer = getHighestRankedPlayer(TEAM_GDI);
	else
		highestRankedPlayer = getHighestRankedPlayer(TEAM_NOD);

	while(highestRankedPlayer != None && Abs(team1ranking - team2ranking) > Rx_Pri(highestRankedPlayer.PlayerReplicationInfo).OldRenScore)
	{
		if(highestRankedPlayer.GetTeamNum() == TEAM_GDI)
		{
			SetTeam(highestRankedPlayer, Teams[TEAM_NOD], true);
			if (highestRankedPlayer.Pawn != None)
				highestRankedPlayer.Pawn.PlayerChangedTeam();
			team1ranking -= Rx_Pri(highestRankedPlayer.PlayerReplicationInfo).OldRenScore;
			team2ranking += Rx_Pri(highestRankedPlayer.PlayerReplicationInfo).OldRenScore;
		} else 
		{
			SetTeam(highestRankedPlayer, Teams[TEAM_GDI], true);
			if (highestRankedPlayer.Pawn != None)
				highestRankedPlayer.Pawn.PlayerChangedTeam();			
			team2ranking -= Rx_Pri(highestRankedPlayer.PlayerReplicationInfo).OldRenScore;
			team1ranking += Rx_Pri(highestRankedPlayer.PlayerReplicationInfo).OldRenScore;
		}
        if(team1ranking > team2ranking) {
            highestRankedPlayer = getHighestRankedPlayer(TEAM_GDI);
        } else {
            highestRankedPlayer = getHighestRankedPlayer(TEAM_NOD);
        }
	}
}

function AdjustTeamSize()
{
	local int difference;
	local Controller PC;
	local Rx_Mutator Rx_Mut;

	Rx_Mut = GetBaseRXMutator();
	if (Rx_Mut != None)
	{
		if(Rx_Mut.adjustTeamSize())
			return;
	}

	// Make sure teams are even
	difference = Teams[TEAM_GDI].Size - Teams[TEAM_NOD].Size;

	if (difference > 1) // too many on GDI
	{
		while (difference > 1)
		{	
			PC = getLowestRankedPlayer(TEAM_GDI); // switch lowest ranked player to have minimal influence on balance
			SetTeam(PC, Teams[TEAM_NOD], true);
			if (PC.Pawn != None)
				PC.Pawn.PlayerChangedTeam();
			difference -= 2;
		}
	}
	else if (difference < -1) // too many on Nod
	{
		while (difference < -1)
		{
			PC = getLowestRankedPlayer(TEAM_NOD);
			SetTeam(PC, Teams[TEAM_GDI], true);
			if (PC.Pawn != None)
				PC.Pawn.PlayerChangedTeam();
			difference += 2;
		}
	}
	// else // teams are close enough
}

function Rx_Controller getLowestRankedPlayer(int teamNum)
{
	local Rx_Controller PC, lowestRankedPlayer;

	lowestRankedPlayer = None;

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
		if (PC.PlayerReplicationInfo.GetTeamNum() == teamNum)
		{
			if(lowestRankedPlayer == None 
				|| Rx_Pri(PC.PlayerReplicationInfo).OldRenScore < Rx_Pri(lowestRankedPlayer.PlayerReplicationInfo).OldRenScore)
			{
				lowestRankedPlayer = PC;
			}
		}

	return lowestRankedPlayer;	
}

function Rx_Controller getHighestRankedPlayer(int teamNum)
{
	local Rx_Controller PC, highestRankedPlayer;

	highestRankedPlayer = None;

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
		if (PC.PlayerReplicationInfo.GetTeamNum() == teamNum)
		{
			if(highestRankedPlayer == None 
				|| Rx_Pri(PC.PlayerReplicationInfo).OldRenScore > Rx_Pri(highestRankedPlayer.PlayerReplicationInfo).OldRenScore)
			{
				highestRankedPlayer = PC;
			}
		}

	return highestRankedPlayer;	
}

exec function QuickStart()
{
	StartMatch();
}

/**
 * Pops up a scaleform dialog. Note: Grabs scaleform instance from frontmenu kismit.
 * @param form The form to use inside the dialog
 * @param diagType the type of dialog to popup
 */
exec function PopUpDialog(string form, string diagType)
{
	local array<SequenceObject> a;

	class'WorldInfo'.static.GetWorldInfo().GetGameSequence().FindSeqObjectsByClass(class'GFxAction_OpenMovie', false, a);
	if(a.Length == 1);
		Rx_GFXFrontEnd(GFxAction_OpenMovie(a[0]).MoviePlayer).OpenDialog(form,diagType, -1, -1, true);
}

/**
 * Pops up the scaleform VersionOutOfDateDialog. Note: Grabs scaleform instance from frontmenu kismit.
 */
exec function PopUpOutOfDateDialog()
{
	local array<SequenceObject> a;

	class'WorldInfo'.static.GetWorldInfo().GetGameSequence().FindSeqObjectsByClass(class'GFxAction_OpenMovie', false, a);
	if(a.Length == 1);
		Rx_GFXFrontEnd(GFxAction_OpenMovie(a[0]).MoviePlayer).OpenVersionOutOfDateDialog();
}

/**
 * Pops up the scaleform ShowDownloadProgressDialog. Note: Grabs scaleform instance from frontmenu kismit.
 */
exec function PopUpShowDownloadProgressDialog(string title, string size)
{
	local array<SequenceObject> a;

	class'WorldInfo'.static.GetWorldInfo().GetGameSequence().FindSeqObjectsByClass(class'GFxAction_OpenMovie', false, a);
	if(a.Length == 1);
		Rx_GFXFrontEnd(GFxAction_OpenMovie(a[0]).MoviePlayer).OpenShowDownloadProgressDialog(title, size);
}

/**
 * Updates the scaleform UpdateDownloadProgressDialog. Note: Grabs scaleform instance from frontmenu kismit.
 */
exec function UpdateDownloadProgressDialog(float loaded, float size)
{
	local array<SequenceObject> a;

	class'WorldInfo'.static.GetWorldInfo().GetGameSequence().FindSeqObjectsByClass(class'GFxAction_OpenMovie', false, a);
	if(a.Length == 1);
		Rx_GFXFrontEnd(GFxAction_OpenMovie(a[0]).MoviePlayer).UpdateDownloadProgressDialog(loaded, size);
}

function Rx_PurchaseSystem GetPurchaseSystem()
{
	return PurchaseSystem;
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
	`logd("Rx_Game::EndGame");

	if(Reason ~= "TimeLimit" || Reason ~= "triggered")
	{
		if(Rx_TeamInfo(Teams[TEAM_GDI]).GetRenScore() >= Rx_TeamInfo(Teams[TEAM_NOD]).GetRenScore())
			EndRxGame(Reason,TEAM_GDI);
		else 
			EndRxGame(Reason,TEAM_NOD);	
	}
	// for other victory conditions EndRxGame gets directly called
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
	if ( ((Reason ~= "Buildings") || (Reason ~= "TimeLimit") || (Reason ~= "triggered") || (Reason ~="Surrender")) && !bGameEnded) {
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

		if(Reason ~= "TimeLimit") {
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "By Points";
		} else if(Reason ~= "Buildings") {
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "By Base Destruction";
		} else if (Reason ~= "Surrender") {
			Rx_GRI(WorldInfo.GRI).WinnerReason = "By Surrender";
			Rx_GRI(WorldInfo.GRI).WinBySurrender=true;
			if(GameSpeed != 1.0) SetTimer(0.75f,false, 'ResetGameSpeed'); //IF it was by surrender, it may have very well changed the game speed. 
		} else {
			Rx_GRI(WorldInfo.GRI).WinBySurrender=false;
			Rx_GRI(WorldInfo.GRI).WinnerReason = "triggered";
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

function float CalcPlayerScoreThisMatch(Rx_Pri pri)
{
	local float ret;

	ret = pri.GetRenScore();
	if(ret < 1.0)
		ret = 0.0;
	else	
		ret = loge(pri.GetRenScore());

	if(pri.GetRenKills() - pri.Deaths > 0)
		ret += loge((pri.GetRenKills() - pri.Deaths) / 2.0);
		
	return ret;
}

function PerformEndGameHandling()
{
	`log("################################ -( PerformEndGameHandling() )-");
	`RecordGameIntStat(ROUND_ENDED,1);
	`RecordGameIntStat(MATCH_ENDED,1);
	super.PerformEndGameHandling();
}

function SetEndgameCam()
{
	//`log("################################ -( SetEndgameCam() )-");
	SetRxEndGameFocus(FindEndgameFocus());
}

function Actor FindEndgameFocus()
{
	// For now, we just return the first endgame camera we find.
	local Rx_EndgameCamera Focus;
	foreach AllActors(class'Rx_EndgameCamera',Focus)
	{
		return Focus;
	}
	return none;
}

function SetRxEndGameFocus(Actor Focus)
{
	local Controller P;
	//`log("################################ -( SetRxEndGameFocus() )-");
	EndGameFocus = Focus;

	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;
	
	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		if(Rx_Controller(P) != None || Rx_Bot(P) != None)			// So that any players and player-like bots will go into roundended state
			P.GameHasEnded( EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
	
	//M.Palko endgame crash track log.
	`log("------------------------------Sending to match over state");

	// Finally, go to match over state...after 9 seconds delay
	//SetTimer(9.0, false, nameof(SetMatchOverState));
	GotoState('MatchOver');
	
}


/**Special case to end game via surrender:
1st play the surrender message across all controllers via CText
then play the surrender announcement (as they sound weird coming after the screen fades)
then wait a second or two before ending the game
**/

function BeginSurrender(int TeamI)
{
	local Rx_Controller P;
	local string HR_Team;
	local Rx_Mutator Rx_Mut;
	
	if(bGDIHasSurrendered || bNodHasSurrendered) return; //Catch any surrenders that get through after a team's already happened.
	
	Rx_Mut = GetBaseRxMutator();
	if (Rx_Mut != None)
	{
		Rx_Mut.OnTeamSurrender(TeamI);
	}
	
	switch (TeamI) 
	{
		case 0:
		HR_Team = "NOD" ;
		break;
		
		case 1:
		HR_Team = "GDI" ;
		break;
		
	}
	
	Rx_GRI(WorldInfo.GRI).WinnerReason = "By Surrender";
	Rx_GRI(WorldInfo.GRI).WinBySurrender=true;
	
	foreach WorldInfo.AllControllers(class'Rx_Controller', P)
	{
		P.CTextMessage(HR_Team @ "TEAM SURRENDERED!",,120, 1.0) ;
	}
	SetGameSpeed(0.5);//fancy... but we'll see how it holds up online
	/*Both of these play the appropriate surrender Announcement AND start the small countdown to end the game. The delay for sounds make it a bit more obvious a team surrendered. */
	if(TeamI==1) 
	{
		bGDIHasSurrendered = true;
		SetTimer(1.0, false, 'PlayGDISurrender');
	}
	else
	{
	bNodHasSurrendered = true; 
	SetTimer(1.0, false, 'PlayNodSurrender'); //Account for time increase (1 second)	
	}
	
}

function PlayGDISurrender() 
{
local Rx_Controller PC;

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
	PC.ClientPlayAnnouncement(VictoryMessageClass, 5);
	}
	
	SurrenderStartTime = WorldInfo.TimeSeconds ; 
	
	ResetGameSpeed();
	
	InitSurrender(0) ; 
	
	//SetTimer(0.75, false, 'FinishGDISurrender') ;
	
}

function PlayNodSurrender() 
{
local Rx_Controller PC;

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		PC.ClientPlayAnnouncement(VictoryMessageClass, 4);
	}
	
	SurrenderStartTime = WorldInfo.TimeSeconds ; 

	
	ResetGameSpeed();
	
	InitSurrender(1) ; 
	//SetTimer(0.75, false, 'FinishNodSurrender') ;
	
}

function PlaySurrenderClockGameOverAnnouncment()
{
	local int TotalTime, TimeMinutes, TimeInSeconds; 
	
	TotalTime = (SurrenderStartTime + SurrenderLength ) - WorldInfo.TimeSeconds ; 
	
	if(TotalTime <= 0) 
		
		{
		
			ClearTimer('PlaySurrenderClockGameOverAnnouncment');
			if(bGDIHasSurrendered) FinishGDISurrender();
			else
			if(bNodHasSurrendered) FinishNodSurrender();
			else
			return;	
		}
	
	TimeMinutes = (TotalTime / 60);
		
	TimeInSeconds = (TotalTime % 60) ;

		if(TotalTime > 60) CTextBroadcast(255, "-Game Ending in:" @ TimeMinutes+1 $ "m-", 'White',,1.0) ;
		else
		CTextBroadcast(255, "-Game Ending in:" @ TimeInSeconds $ "s-" , 'White',,1.0) ; 
	
	if(!bCountingToSurrender && TotalTime <= 60) //Setup to countdown 
	{
	bCountingToSurrender = true; 
	ClearTimer('PlaySurrenderClockGameOverAnnouncment');
	SetTimer(50.0,true,'PlaySurrenderClockGameOverAnnouncment');	
	}
	else
	if(bCountingToSurrender && TotalTime >=9) 
	{
	ClearTimer('PlaySurrenderClockGameOverAnnouncment');
	SetTimer(1.0,true,'PlaySurrenderClockGameOverAnnouncment');
	}
	
	
	
}

function InitSurrender (byte SurrenderingTeam)
{
	local Rx_PRI RxPRI; 
	local PlayerReplicationInfo PRI ; 
	
	foreach GameReplicationInfo.PRIArray(PRI)
	{
	
	if(Rx_PRI(PRI) != none && PRI.GetTeamNum() == SurrenderingTeam) 
		{
			RxPRI=Rx_PRI(PRI); 
			RxPRI.DisableVeterancy(true);
		}
		else
		if(Rx_PRI(PRI) != none && PRI.GetTeamNum() != SurrenderingTeam)
		{
			RxPRI=Rx_PRI(PRI); 
			RxPRI.TickVPToFull();
			//RxPRI.Vrank=3;
		}
	}
	
	PlaySurrenderClockGameOverAnnouncment();
	SetTimer(60.0, true, 'PlaySurrenderClockGameOverAnnouncment'); 
}


function FinishGDISurrender()
{
	if(Rx_GRI(WorldInfo.GRI).WinnerReason ~= "By Surrender")
	{
	EndRxGame("Surrender", 1);
	}
	
}

function FinishNodSurrender()
{
	if(Rx_GRI(WorldInfo.GRI).WinnerReason ~= "By Surrender")
	{
	EndRxGame("Surrender", 0);
	}
	
}

function ResetGameSpeed()
{
SetGameSpeed(1); 
}

/*Surrender functions over*/


private function SetMatchOverState()
{
	GotoState('MatchOver');
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

/*
 * Adds crate to global array and sets one random active
 * */
function AddCrateAndActivateRnd(Rx_CratePickup InCrate)
{
   local Rx_CratePickup tmpCrate;
   local int activeCratesNum;
   activeCratesNum = 0;
   if (!SpawnCrates)
   {
      InCrate.GotoState('Disabled');
   }
   else
   {
      AllCrates.AddItem(InCrate);

      foreach AllCrates(tmpCrate)
      {
         if (tmpCrate.getIsActive())
            activeCratesNum++;
      }


      if (activeCratesNum > Rx_MapInfo(WorldInfo.GetMapInfo()).NumCratesToBeActive)
         InCrate.DeactivateCrate();
      else
         InCrate.ActivateCrate();
         
   }
}

/*
 * called after crate was picked up and next one should be activated
 * used with config to delay crate respawn set by user
 * */
function ActivateRandomCrate()
{
   local Rx_CratePickup tmpCrate;
   local array<Rx_CratePickup> CratesNotActive;

   // get non active crates
   foreach AllCrates(tmpCrate)
   {
      if(!tmpCrate.getIsActive())
      {
         CratesNotActive.AddItem(tmpCrate);
      }
   }
   // activate a rnd one
   
   CrateRespawnAfterPickup = 60.0f - Worldinfo.GRI.ElapsedTime % 60.0f;
   if(CrateRespawnAfterPickup == 0.0)
   		CrateRespawnAfterPickup = 1.0;
   
   CratesNotActive[Rand(CratesNotActive.Length)].setActiveIn(CrateRespawnAfterPickup);
}

function PlayEndOfMatchMessage()
{
/*	local Rx_Controller PC;


	//M.Palko endgame crash track log.
	`log("------------------------------Playing end of match message");

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		if (IsAWinner(PC))
		{
			if ( PC.GetTeamNum() == 0 )
			{
				if(!WasSurrenderWin()) PC.ClientPlayAnnouncement(VictoryMessageClass, 0); // GDI Win
				//else
				//PC.ClientPlayAnnouncement(VictoryMessageClass, 4); 
			}
			else
			{
				if(!WasSurrenderWin()) PC.ClientPlayAnnouncement(VictoryMessageClass, 1); // Nod Win
				//else
				//PC.ClientPlayAnnouncement(VictoryMessageClass, 5); // Nod Win through GDI Surrender
			}
		}
		else
		{
			if ( PC.GetTeamNum() == 0 )
			{
			if(!WasSurrenderWin())	PC.ClientPlayAnnouncement(VictoryMessageClass, 2); // GDI Defeat
			//else
			//PC.ClientPlayAnnouncement(VictoryMessageClass, 5); // Nod Win through GDI Surrender
			}
			else
			{
				if(!WasSurrenderWin()) PC.ClientPlayAnnouncement(VictoryMessageClass, 3); // Nod Defeat
				//else
				//PC.ClientPlayAnnouncement(VictoryMessageClass, 4); // GDI Win through Nod Surrender

			}
		}
	}

*/
}

simulated function bool WasSurrenderWin()
{
	
	return Rx_Gri(GameReplicationInfo).WinBySurrender;
	
}

simulated function int getVehicleLimit()
{
   return VehicleLimit;
}

function Rx_VehicleManager GetVehicleManager() 
{
	return VehicleManager;
}

function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
	local float TempDifficulty;
	
	TempDifficulty = WorldInfo.Game.GameDifficulty;
	WorldInfo.Game.GameDifficulty = 5.0;
	super.ReduceDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType,DamageCauser);
	WorldInfo.Game.GameDifficulty = TempDifficulty;
}

function bool CanPlayBuildingUnderAttackMessage(byte TeamNum) 
{
	if(TeamNum == TEAM_GDI) {
		return bCanPlayEvaBuildingUnderAttackGDI;
	} else {
		return bCanPlayEvaBuildingUnderAttackNOD;
	}
}

function ResetBuildingUnderAttackEvaTimer(byte TeamNum) 
{
	if(TeamNum == TEAM_GDI) {
		bCanPlayEvaBuildingUnderAttackGDI = false;
		SetTimer(30.0,false,'ResetBuildingUnderAttackEvaGDI');
	} else {
		bCanPlayEvaBuildingUnderAttackNOD = false;
		SetTimer(30.0,false,'ResetBuildingUnderAttackEvaNOD');
	}
}

function ResetBuildingUnderAttackEvaGDI()
{
	bCanPlayEvaBuildingUnderAttackGDI = true;
}	

function ResetBuildingUnderAttackEvaNOD()
{
	bCanPlayEvaBuildingUnderAttackNOD = true;
}

function TriggerRemoteKismetEvent(name EventName)
{
	local array<SequenceObject> AllSeqEvents;
	local Sequence GameSeq;
	local int i;
	GameSeq = WorldInfo.GetGameSequence();
	if(GameSeq != none)
	{
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllSeqEvents);
		for(i = 0; i < AllSeqEvents.Length; i++)
		{
			if(SeqEvent_RemoteEvent(AllSeqEvents[i]).EventName == EventName)
				SeqEvent_RemoteEvent(AllSeqEvents[i]).CheckActivate(WorldInfo, None);
		}
	}
}

function string Unescape(string Text)
{
	return class'Rx_RconConnection'.static.ProcessEscapeSequences(Text);
}


function bool ProcessNewServerInfo(JsonObject ServerData, bool isServerLan)
{
	local JsonObject ServerMoreData;
	local ServerInfo si;

	si.GameVersion = Unescape(ServerData.GetStringValue("Game Version"));
	if (IgnoreGameServerVersionCheck || si.GameVersion == GameVersion) {
		
			
		si.ServerName = Unescape(ServerData.GetStringValue("Name"));
	
		`logd(`Location@`showvar(si.ServerName),,'DevNet');

		si.ServerIp = ServerData.GetStringValue("IP");
		si.ServerPort = string(ServerData.GetIntValue("Port"));
		si.MapName = Unescape(ServerData.GetStringValue("Current Map"));
		si.NumPlayers = ServerData.GetIntValue("Players");
		
		ServerMoreData = ServerData.GetObject("Variables");

		si.VehicleLimit = ServerMoreData.GetIntValue("Vehicle Limit");
		si.MineLimit = ServerMoreData.GetIntValue("Mine Limit");
		si.MaxPlayers = ServerMoreData.GetIntValue("Player Limit");
		si.TimeLimit = ServerMoreData.GetIntValue("Time Limit");
		si.TeamMode = ServerMoreData.GetIntValue("Team Mode");
		si.GameType = ServerMoreData.GetIntValue("Game Type");
		si.SteamRequired = ServerMoreData.GetBoolValue("bSteamRequired");
		si.bPassword = ServerMoreData.GetBoolValue("bPassworded");
		si.CratesEnabled = ServerMoreData.GetBoolValue("bSpawnCrates");
		si.Ranked = ServerMoreData.GetBoolValue("bRanked");
			
		si.isLAN = isServerLan;

		`logd(`Location@`ShowVar(isServerLan)@`ShowVar(si.isLAN),,'DevNet');

		return AddServerInfo(si);
	}
	return false;
}

function AddServerPing(string ServerIp, int Index)
{
	local string PingIpItem;

	`Entry(`ShowVar(ServerIp)@`ShowVar(Index),'DevNet');

	PingIpItem = ServerIp $ "-" $ Index;

	if(PingIpList != "")
		PingIpList $= "," $ PingIpItem;
	else
		PingIpList $= PingIpItem;
}

function HandleServerData(JsonObject MasterServerData)
{
	local JsonObject ServerData;
	local bool bIsNewServer;

	bIsNewServer = false;

	foreach MasterServerData.ObjectArray(ServerData)
	{
		`logd("HandleServerData: Server:"@ServerData,,'DevNet');
		if(ProcessNewServerInfo(ServerData, false))
			bIsNewServer = true;
	}

	if(bIsNewServer)
	{
		NotifyServerListUpdate();
	}
}

function StartPings()
{
	`Entry(,'DevNet');

	if(ListServers.Length > 0)
	{
		VersionCheck.StartPingAll(PingIpList);

		CurIndPinged = 0;
		if(!IsTimerActive('PingServers'))
			SetTimer(0.5f, true, 'PingServers');
	}
}

/* Using Rx_VersionQueryHandler, we will fetch the data from the release JSON and parse the information here. The info is stored in the class VQueryHandler */
function HandleVersionData(JsonObject VersionData)
{
	VQueryHandler.QueryedVersionNumber = VersionData.GetObject("game").GetIntValue("version_number");
	VQueryHandler.QueryedVersionName = VersionData.GetObject("game").GetStringValue("version_name");
}

function PingServers()
{
	local string currentPingedIds;
	local array<string> finishedIds;
	local int i, leng, PingedCount;
	local int PingedId;

	`Entry("", 'DevNet');

	
	currentPingedIds = VersionCheck.GetPingedIDs();
	ParseStringIntoArray(currentPingedIds, finishedIds, ",", true);
	leng = finishedIds.Length;

	if(ListServers.Length != 0) //This is a workaround. When swapping between internet and local browser modes, the listserver gets cleared. The ping/version check dll lists gets cleared aswell(with an empty start ping call), but any ongoing pings still get reported back, and end up here.
	{
		for(i = 0; i < leng; i++)
		{
			PingedId = Int(finishedIds[i]);
			ListServers[PingedId].Ping = VersionCheck.GetPingFor(ListServers[PingedId].ServerIP);
		
			`logd(`Location@`ShowVar(PingedId)@`ShowVar(ListServers[PingedId].Ping)@`ShowVar(ListServers[PingedId].ServerIP),,'DevNetTraffic');
		}
	}
	
	PingedCount = VersionCheck.GetPingStatus();

	/*

	for(i = 0; i < ListServers.Length; i++)
	{
		if (ListServers[i].Ping <= 0)
		{
			ListServers[i].Ping = VersionCheck.GetPingFor(ListServers[i].ServerIP);
			`Logd(`Location@`ShowVar(ListServers[i].Ping),,'DevNet');
		}
	}*/

	`Logd(`Location@`ShowVar(PingedCount)@`ShowVar(ListServers.Length),,'DevNetTraffic');

	if(PingedCount >= ListServers.Length)
	{
		ClearTimer(nameof(PingServers));
		//curIndPinged = 0;
		`Logd(`Location@"Ping Timer Cleared",,'DevNet');
	}

	NotifyPingFinished(PingedId);
}

delegate NotifyPingFinished(int SrvIndex);

function bool FindInactivePRI(PlayerController PC)
{
	local bool ret;
	local int oldId;
	oldId = PC.PlayerReplicationInfo.PlayerID;
	ret = super.FindInactivePRI(PC);
	if(ret) {
		TeamCredits[PC.GetTeamNum()].PlayerRI.AddItem(Rx_PRI(PC.PlayerReplicationInfo));
		if (oldId != PC.PlayerReplicationInfo.PlayerID)
			`LogRx("PLAYER" `s "ChangeID;" `s "to" `s PC.PlayerReplicationInfo.PlayerID `s "from" `s oldId);
		//Rx_PRI(PC.PlayerReplicationInfo).SetCredits( Rx_Game(WorldInfo.Game).InitialCredits ); - Removed as Inactive PRIs now save credits.
	}
	return ret;
}

event GetSeamlessTravelActorList(bool bToEntry, out array<Actor> ActorList)
{
	super.GetSeamlessTravelActorList(bToEntry, ActorList);

	if (MatchInfo != None)
		ActorList.AddItem(MatchInfo);
}

function NotifyNavigationChanged(NavigationPoint N)
{
	local UTBot B;

	/**
	// if a point becomes unblocked, force bots to repath in case it's faster than their current one
	if (!N.bBlocked)
	{
		foreach WorldInfo.AllControllers(class'UTBot', B)
		{
			//B.bForceRefreshRoute = true; // dont always do that because the harv does unblocking a lot
		}
	}
	*/
	
	if (N.bBlocked)
	{
		foreach WorldInfo.AllControllers(class'UTBot', B)
		{
			//if(B.NextRoutePath != None && B.NextRoutePath.GetEnd() == N) 
			//if(B.CurrentPath != None && B.CurrentPath.GetEnd() == N) {
			if(B.NextRoutePath != None && B.NextRoutePath.GetEnd() == N || B.MoveTarget != None && B.MoveTarget == N) {
				//loginternal("ddd");
				B.bForceRefreshRoute = true; // dont always do that because the harv does unblocking a lot
			}
		}
	}	
	
	// only if close to blocked node
}

function SetObelisk()
{
	ForEach AllActors(class'Rx_Building_Nod_Defense', Obelisk) {
		break;
	}
}

function SetAGT()
{
	ForEach AllActors(class'Rx_Building_GDI_Defense', AGT) {
		break;
	}
}

function Actor GetObelisk()
{
	return Obelisk;
}  
function Actor GetAGT()
{
	return AGT;
}

function RestartPlayer(Controller NewPlayer)
{
	local Rx_Hud RxHUD;
	super.RestartPlayer(NewPlayer);

	if(Rx_Bot(NewPlayer) != None) {
	
		if(Rx_Bot(NewPlayer).bAttackingEnemyBase) {
			Rx_Bot(NewPlayer).bAttackingEnemyBase = false;
			Rx_Bot(NewPlayer).bInvalidatePreviousSO = true;
		}
		
		if(NewPlayer.PlayerReplicationInfo.Deaths > 0 && Rx_Bot(NewPlayer).Squad != None && UTSquadAI(Rx_Bot(NewPlayer).Squad).GetOrders() == 'Attack') {
			UTSquadAI(Rx_Bot(NewPlayer).Squad).RemoveBot(Rx_Bot(NewPlayer));	
			Rx_TeamAI(UTTeamInfo(NewPlayer.PlayerReplicationInfo.Team).AI).PutOnOffense(Rx_Bot(NewPlayer));
		} 
		else if(Rx_Bot(NewPlayer).GetOrders() == 'Follow')
		{
			UTTeamInfo(Rx_Bot(NewPlayer).Squad.Team).AI.SetBotOrders(Rx_Bot(NewPlayer));
		}
		 
//	    if(Rx_Bot(NewPlayer).IsInBuilding()) {
//	   		Rx_Bot(NewPlayer).setStrafingDisabled(true);	
//	    }
	} 
	else if(PlayerController(NewPlayer) != None) {
		RxHUD = Rx_Hud(PlayerController(NewPlayer).myHUD);
		if (WorldInfo.NetMode != NM_DedicatedServer && RxHUD != None)
			RxHUD.ClearPlayAreaAnnouncement();
		else
			Rx_Controller(NewPlayer).ClearPlayAreaAnnouncementClient();
		if(Rx_Controller(NewPlayer) != None)
			Rx_Controller(NewPlayer).RefillCooldownTime=0;	
	}
	if(TeamCredits[NewPlayer.GetTeamNum()].PlayerRI.Find(Rx_PRI(NewPlayer.PlayerReplicationInfo)) < 0) {
		TeamCredits[NewPlayer.GetTeamNum()].PlayerRI.AddItem(Rx_PRI(NewPlayer.PlayerReplicationInfo));
		Rx_PRI(NewPlayer.PlayerReplicationInfo).SetCredits( Rx_Game(WorldInfo.Game).InitialCredits ); 
	}	

	if(GetALocalPlayerController() != none && GetALocalPlayerController().Player != none)
		LocalPlayer(GetALocalPlayerController().Player).ClearPostProcessSettingsOverride();

	//`RecordPlayerSpawn(NewPlayer, NewPlayer.Pawn.Class, NewPlayer.GetTeamNum());
}

/** Calling this advances the cycle and thus should not be called just to get the name of the next map, use GetNextMapInRotationName() */
function string GetNextMap()
{
	local int GameIndex;

	/** Yosh: Had to comment this out for the sake of getting patch 5003 out in a timely manner. 
	From what I could tell by looking at it quickly, the game never sets an active map list for the manager, so you just get thrown back on the same map.
	if (MapListManager != none) {
		`log(MapListManager.GetNextMap());
		return MapListManager.GetNextMap();
	}
	*/

	if (bFixedMapRotation)
	{
		GameIndex = class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', Class.Name);
		if (GameIndex != INDEX_NONE)
		{
			MapCycleIndex = GetNextMapInRotationIndex();
			//TODO: Add to fixed map rotation to cycle between day/night maps. 
			class'UTGame'.default.MapCycleIndex = MapCycleIndex;
			class'UTGame'.static.StaticSaveConfig();

			return class'UTGame'.default.GameSpecificMapCycles[GameIndex].Maps[MapCycleIndex];
		}
	}
	else
	{	
		return Rx_Gri(GameReplicationInfo).GetMapVoteName();
	}

	return "";
}

function int GetNextMapInRotationIndex()
{
	local int MapIndex, GameIndex;
	local array<string> MapList;
	
	GameIndex = class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', Class.Name);
	MapList = class'UTGame'.default.GameSpecificMapCycles[GameIndex].Maps;
	MapIndex = GetCurrentMapCycleIndex(MapList);
	if (MapIndex == INDEX_NONE)
	{
		// assume current map is actually zero
		MapIndex = 0;
	}
	return (MapIndex + 1 < class'UTGame'.default.GameSpecificMapCycles[GameIndex].Maps.length) ? (MapIndex + 1) : 0;
}

function string GetNextMapInRotationName()
{
	return class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', Class.Name)].Maps[GetNextMapInRotationIndex()];
}

function RecordToMapHistory(string LatestMap)
{
	local int i;

	if (MapHistory.Length < MapHistoryMax)
		i = MapHistory.Length;
	else
		i = MapHistoryMax - 1;

	while (i>0)
	{
		MapHistory[i] = MapHistory[i-1];
		--i;
	}
	MapHistory[0] = LatestMap;
	SaveConfig();
}

function array<string> BuildMapVoteList()
{
	local array<string> MapPool;
	local int i;

	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps;
	for (i=0; i<RecentMapsToExclude && i<MapHistory.Length; ++i)
		MapPool.RemoveItem(MapHistory[i]);

	while (MapPool.Length > MaxMapVoteSize)
		MapPool.Remove(Rand(MapPool.Length), 1);

	return MapPool;
}

/*Functions added to add/remove maps from the rotation while in-game*/

exec function bool AddMapToRotation(string MapName) /*Return if the given map name was a valid map, then add a map to the map rotation*/
{	
	local array<string> MapPool;
	
	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps;	
	
	if(bDoesMapExist(MapName))
	{
		//`log("Did not find map, adding to rotation");
		
		if( !MapPackageExists(MapName) ) return false; 
		
		MapPool.AddItem(MapName); 
		EditMapArray(MapPool);
		saveconfig();
		return true; 
	}
	return false; 
}

exec function bool RemoveMapFromRotation(string MapName) /*Return if the given map name was a valid map, then remove a map from the map rotation*/
{
	local array<string> MapPool;
	
	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps;	
	
	if(bDoesMapExist(MapName))
	{
		`log("Found map"@MapName$", removing from rotation.");
		//insert code to verify is legitimate map 
		MapPool.RemoveItem(MapName);
		EditMapArray(MapPool);
		saveconfig(); 
		return true; 
	}
	return false; 
}

function bool bDoesMapExist(string MapName)
{
	local array<string> MapPool;
	
	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps;	

	if (MapPool.Find(MapName) != -1)
	{
		`log(MapName@"does exist.");
		return true; 
	}

	return false; 
}

function EditMapArray(array<string> NewMapList)
{
	local int i; 
	
	GameSpecificMapCycles[GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps.Length=0; //Delete the old map list
	
	for(i = 0; i < NewMapList.Length; i++)
	{
		`log("Adding item" @ NewMapList[i]) ;
		GameSpecificMapCycles[GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps.AddItem(NewMapList[i]) ; //create the new map list
	}
}

exec function GetMapRotation() //Obviously get the map-rotation
{
	local array<string> MapPool;
	local int i;
		
	MapPool = default.GameSpecificMapCycles[default.GameSpecificMapCycles.Find('GameClassName', class'Rx_Game'.Name)].Maps;	
	
		RxLog("Generating Map List");
		for(i = 0; i < MapPool.Length; i++)
		{
			RxLog("Map"`s i `s ":" `s MapPool[i]); 
		}
}

exec function ExitGameAndOpenLauncher()	// For the time being, just exit the game. Will open launcher/reopen launcher to prompt for download at a later date.
{
	//ConsoleCommand("Exit");
	`log("Attempting to close game and open launcher now"@Rx_GameEngine(class'Engine'.static.GetEngine()).DllCore.UpdateGame());
	Rx_GameEngine(class'Engine'.static.GetEngine()).DllCore.UpdateGame();
}

/** Modifeid version of UTGame::ProcessServerTravel and supercall to GameInfo. Adds map change Rxlog and Seamless travel control. */
function ProcessServerTravel(string URL, optional bool bAbsolute)
{
	// GameInfo Locals
	local PlayerController LocalPlayer;
	local bool bSeamless;
	local string NextMap;
	local Guid NextMapGuid;
	local int OptionStart;
	// UTGame Locals
	local Controller C;

	if (!IsInState('MatchOver'))
	{
		foreach WorldInfo.AllControllers(class'Controller', C)
		{
			C.GameHasEnded();
		}
		GotoState('MatchOver');
	}

	// SUPER CALL TO GAMEINFO
	bLevelChange = true;
	EndLogging("mapchange");

	bSeamless = false;

	if (InStr(Caps(URL), "?RESTART") != INDEX_NONE)
	{
		NextMap = string(WorldInfo.GetPackageName());
	}
	else
	{
		OptionStart = InStr(URL, "?");
		if (OptionStart == INDEX_NONE)
		{
			NextMap = URL;
		}
		else
		{
			NextMap = Left(URL, OptionStart);
		}
	}
	NextMapGuid = GetPackageGuid(name(NextMap));

	if (bSeamless)
		RxLog("MAP"`s"Changing;"`s NextMap `s "seamless");
	else
		RxLog("MAP"`s"Changing;"`s NextMap `s "nonseamless");

	// Set the teams for the next round
	switch (TeamMode)
	{
	case 0: // Static
		RetainTeamsNextMatch();
		break;
	case 1: // Swap
		SwapTeamsNextMatch();
		break;
	case 2: // Random swap
		if (Rand(2) != 0)
			SwapTeamsNextMatch();
		break;
	case 3: // Shuffle
		ShuffleTeamsNextMatch();
		break;
	case 4: // Default (do nothing)
		break;
	default: // Invalid value; do nothing
		break;
	}

	// Remove bots
	DesiredPlayerCount = NumPlayers;
	KillBots();

	// Notify clients we're switching level and give them time to receive.
	LocalPlayer = ProcessClientTravel(URL, NextMapGuid, bSeamless, bAbsolute);

	`log("ProcessServerTravel:"@URL);
	WorldInfo.NextURL = URL;
	if (WorldInfo.NetMode == NM_ListenServer && LocalPlayer != None)
	{
		WorldInfo.NextURL $= "?Team="$LocalPlayer.GetDefaultURL("Team")
							$"?Name="$LocalPlayer.GetDefaultURL("Name")
							$"?Class="$LocalPlayer.GetDefaultURL("Class")
							$"?Character="$LocalPlayer.GetDefaultURL("Character");
	}

	// Notify access control, to cleanup online subsystem references
	if (AccessControl != none)
	{
		AccessControl.NotifyServerTravel(bSeamless);
	}

	// Trigger cleanup of online delegates
	ClearOnlineDelegates();

	if (bSeamless)
	{
		WorldInfo.SeamlessTravel(WorldInfo.NextURL, bAbsolute);
		WorldInfo.NextURL = "";
	}
	// Switch immediately if not networking.
	else if (WorldInfo.NetMode != NM_DedicatedServer && WorldInfo.NetMode != NM_ListenServer)
	{
		WorldInfo.NextSwitchCountdown = 0.0;
	}
	// END OF SUPER CALL

	// on dedicated servers, add a delay to the travel process to give clients a little more time to construct any meshes
	// since that process will get cut off when the server completely finishes travelling
	if (WorldInfo.NetMode == NM_DedicatedServer && WorldInfo.IsInSeamlessTravel())
	{
		WorldInfo.SetSeamlessTravelMidpointPause(true);
		SetTimer(7.0, false, 'ContinueSeamlessTravel');
	}
}

function Rx_Mutator GetBaseRxMutator()
{
	local Mutator M;

	for (M = BaseMutator; M != None; M = M.NextMutator)
	{
		if (Rx_Mutator(M) != None)
			return Rx_Mutator(M);
	}

	return None;
}

simulated function GiveTeamCredits(float Credits, byte TeamNum) 
{
	local PlayerReplicationInfo pri;
	local int index;
	
	for (index = 0; index < WorldInfo.GRI.PRIArray.Length; ++index)
	{
		pri = WorldInfo.GRI.PRIArray[index];
		if (Rx_PRI(pri) != None && pri.GetTeamNum() == TeamNum)
			Rx_PRI(pri).addCredits(Credits);
	}
}

function bool AreTeamRefineriesDestroyed(byte teamNum)
{
	local int i;

	if(TeamCredits[teamNum].Refinery.length <= 0)
		return true;

	for(i=0; i<TeamCredits[teamNum].Refinery.length; i++)
	{
		if(!TeamCredits[teamNum].Refinery[i].IsDestroyed())
			return false;
	}

	return true;
}

function float GetTeamRefineryCreditsSum(byte teamNum)
{
	local int i;
	local float Credits;

	if(TeamCredits[teamNum].Refinery.length <= 0)
		return 0;

	for(i=0; i<TeamCredits[teamNum].Refinery.length; i++)
	{
		if(!TeamCredits[teamNum].Refinery[i].IsDestroyed())
			Credits += TeamCredits[teamNum].Refinery[i].CreditsPerTick;

	}
	return Credits;
}

function TickCredits(byte TeamNum)
{
	local float CreditTickAmount;
	
	CreditTickAmount = Rx_MapInfo(WorldInfo.GetMapInfo()).BaseCreditsPerTick;

	CreditTickAmount += GetTeamRefineryCreditsSum(TeamNum);
	
	GiveTeamCredits(CreditTickAmount, TeamNum);
	
	//Sync Credit and CP ticks 
	Rx_TeamInfo(Teams[0]).AddCommandPoints(default.CP_TickRate+(DestroyedBuildings_GDI*0.5)) ;
	Rx_TeamInfo(Teams[1]).AddCommandPoints(default.CP_TickRate+(DestroyedBuildings_Nod*0.5)) ;
}

function Tick(float DeltaTime)
{
	if(!(worldinfo.IsPlayInEditor() || worldinfo.IsPlayInPreview()))
		Rx_GameEngine(class'Engine'.static.GetEngine()).RxTick(DeltaTime);
	
	// Credit ticking
	CreditTickTimer -= DeltaTime;

	LANBroadcast.Tick(DeltaTime);

	if (CreditTickTimer <= 0 && WorldInfo.GRI.bMatchHasBegun)
	{
		TickCredits(TEAM_GDI);
		TickCredits(TEAM_NOD);
		
		// Reset timer
		CreditTickTimer = CreditTickRate;
	}
}

function LANRecievedLineSubscriber(string Line)
{
	`log("Rx_Game: LANRecievedLineSubscriber:" @ Line);
}

function bool MapPackageHasDayNight (string ThePackage)
{
	return false;
}

function bool PickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup)
{
	local bool ret;
	
	ret = super.PickupQuery(Other,ItemClass,Pickup);
	if(!ret)
		return false;
		
	if(ItemClass == class'Rx_Weapon_IonCannonBeacon' && Other.GetTeamNum() == TEAM_NOD) 
	{
		return false;
	}
	if(ItemClass == class'Rx_Weapon_NukeBeacon' && Other.GetTeamNum() == TEAM_GDI) 
	{
		return false;
	}
	return ret;
}

function RxConsFail(PlayerController Con)
{
	if(Con != none) 
	{
		Rx_Controller(Con).ResetRxConsole(); 
		RxLog("Player" `s `PlayerLog(Con.PlayerReplicationInfo) `s"Kicked for CONSOLE MISMATCH;");
		AccessControl.KickPlayer(Con, "CONSOLE MISMATCH");
	}
}

exec function QueueDownload(string PackageName)
{
	`RxEngineObject.PackageDownloader.QueueDownload(PackageName);
}

function CalculateEndGameAwards(byte ForTeam)
{
local PlayerReplicationInfo PRI;
local Rx_PRI RxPRI, Offensive_PRI, Defensive_PRI, Support_PRI, MVP_PRI;
local float HighestOffensiveScore, HighestDefensiveScore, HighestSupportScore, HighestTotalScore;

	foreach GameReplicationInfo.PRIArray(PRI)
		{
		
		if(Rx_PRI(PRI) != none && PRI.GetTeamNum() == ForTeam) 
			{
				RxPRI=Rx_PRI(PRI); 

				RxPRI.UpdateAllScores(); //Refresh all scores
				
				//Is its offensive score higher than the current? If so, set it to the highest
				if(RxPRI.Score_Offense > HighestOffensiveScore) 
				{
					HighestOffensiveScore = RxPRI.Score_Offense; 	
					Offensive_PRI = RxPRI; 
				}
				//Same For Defense
				if(RxPRI.Score_Defense > HighestDefensiveScore) 
				{
					HighestDefensiveScore = RxPRI.Score_Defense; 	
					Defensive_PRI = RxPRI; 
				}
				//Same For Defense
				if(RxPRI.Score_Support > HighestSupportScore) 
				{
					HighestSupportScore = RxPRI.Score_Support; 	
					Support_PRI = RxPRI; 
				}
				//Lastly, for the grand total to find MVP 
				if(RxPRI.GetTotalScore() > HighestTotalScore) 
				{
					HighestTotalScore = RxPRI.GetTotalScore(); 	
					MVP_PRI = RxPRI; 
				}
			}
		}
		
	if(MVP_PRI != none)
		{
			Award_MVP[ForTeam] = MVP_PRI;	
			//`log("MVP Score:" @ Award_MVP[ForTeam].GetTotalScore() @ Award_MVP[ForTeam].PlayerName  );
		}
	if(Offensive_PRI != none)
		{
			Award_Offense[ForTeam] = Offensive_PRI;
			//`log("Offense Score: " @ Award_Offense[ForTeam].Score_Offense );	
		}
	if(Defensive_PRI != none)
		{
			Award_Defense[ForTeam] = Defensive_PRI;
			//`log("Defense Score: " @ Award_Defense[ForTeam].Score_Defense);
		}
	if(Support_PRI != none)
		{
			Award_Support[ForTeam] = Support_PRI; 
			//`log("Support Score: " @ Award_Support[ForTeam].Score_Support);
		}



	
}

function AssignAwards(byte ForTeam)
{
	local string RMVP, RBO,RBD,RBS;
	if(ForTeam > 1) return;
	
	if(Award_MVP[ForTeam] != none) RMVP = Award_MVP[ForTeam].PlayerName;
	if(Award_Offense[ForTeam] != none) RBO = Award_Offense[ForTeam].PlayerName;
	if(Award_Defense[ForTeam] != none) RBD = Award_Defense[ForTeam].PlayerName;
	if(Award_Support[ForTeam] != none) RBS = Award_Support[ForTeam].PlayerName;
	
	Rx_GRI(GameReplicationInfo).SetAwards(ForTeam,RMVP,RBO,RBD,RBS); 
}

/*****************************************************
*********************Team Management******************
******************************************************/

function bool RTCDisabled()
{
	return WorldInfo.TimeSeconds < RTC_DisableTime; 
}

function string GetRTCDisabledTimeString()
{
	return max(0,RTC_DisableTime - WorldInfo.TimeSeconds)/60 $ ":" $ int((RTC_DisableTime - WorldInfo.TimeSeconds) % 60) ; 
	
}

function AddTeamChangeRequest(Rx_PRI PRI)
{
	local TC_Request RTC_Ticket;
	local bool bCanSwitch;
	local Rx_Controller RxC; 
	local string TeamString;
	
	bCanSwitch = true; 
	
	RTC_Ticket.PPRI = PRI; 
	RTC_Ticket.TimeStamp = WorldInfo.TimeSeconds;
	
	if(RTC_GDI.Find('PPRI', PRI) != -1) bCanSwitch = false; 
	else
	if(RTC_Nod.Find('PPRI', PRI) != -1) bCanSwitch = false; 
	
	if(!bCanSwitch) 
	{
		Rx_Controller(PRI.Owner).CTextMessage("You already have a change request"); 
		return; 
	}
	
	if(PRI.GetTeamNum() == 0) 
	{
		RTC_GDI.AddItem(RTC_Ticket); 
		TeamString = "To Nod"; 
	}
	else
	{
		RTC_Nod.AddItem(RTC_Ticket); 
		TeamString = "To GDI"; 
	}
	
	
	foreach WorldInfo.AllControllers(class'Rx_Controller', RxC)
	{
		RxC.CTextMessage(PRI.PlayerName @ "Wants to swap" @ TeamString, 'Orange', 80); 
	}
	
	CleanupRTC(); 
	if(TeamsAreEven()) ProcessRTC(); 
	
}

function bool TeamsAreEven()
{
	local int T1_Players, T2_Players; 
	local PlayerReplicationInfo PRI;
	
	if(WorldInfo.NetMode == NM_StandAlone) return false; 
	else
	{
		CleanupRTC();
		
		foreach WorldInfo.GRI.PRIArray(PRI)
		{
			if(PRI.bBot) continue; 
			else
			if(PRI.GetTeamNum() == 0) T1_Players++; 
			else
			if(PRI.GetTeamNum() == 1) T2_Players++;
		}
	
	}
	//`log(T1_Players @ "/" @ T2_Players);
	
	if(T1_Players == T2_Players) return true; 
}

function CleanupRTC()
{
	local TC_Request RT; 

	//Clean out GDI RTCs
	foreach RTC_GDI(RT)
		{
			if(WorldInfo.TimeSeconds - RT.TimeStamp >= RTC_TimeLimit) 
			{
				Rx_Controller(RT.PPRI.Owner).CTextMessage("-Team change request expired-") ;
				RTC_GDI.RemoveItem(RT);
			}
		}
		//Clean out Nod RTCs
		foreach RTC_Nod(RT)
		{
			if(WorldInfo.TimeSeconds - RT.TimeStamp >= RTC_TimeLimit) 
			{
				Rx_Controller(RT.PPRI.Owner).CTextMessage("-Team change request expired-") ;
				RTC_Nod.RemoveItem(RT);	
			}
		}
}

function ProcessRTC()
{
	local int i; 
	local int CredAmount;
	for(i=0;i<RTC_GDI.Length;i++)
	{
	if(RTC_GDI[i].PPRI != none && RTC_Nod[i].PPRI !=none) 
		{
			/*Process GDI Player*/ 
			
			//Remove commander status from either of them 
			if(RTC_GDI[i].PPRI == Commander_PRI[0]) RemoveCommander(0);
			if(RTC_Nod[i].PPRI == Commander_PRI[1]) RemoveCommander(1);
			
			CredAmount = RTC_GDI[i].PPRI.GetCredits();
			SetTeam(Controller(RTC_GDI[i].PPRI.Owner),Teams[TEAM_Nod], true);
			
			if (Controller(RTC_GDI[i].PPRI.Owner).Pawn != None)
				Controller(RTC_GDI[i].PPRI.Owner).Pawn.Destroy();
		
			RTC_GDI[i].PPRI.SetCredits(CredAmount);
			
			/*Process Nod Player*/ 
			
			
			CredAmount = RTC_Nod[i].PPRI.GetCredits();
			SetTeam(Controller(RTC_Nod[i].PPRI.Owner),Teams[TEAM_GDI], true);
			
			if (Controller(RTC_Nod[i].PPRI.Owner).Pawn != None)
				Controller(RTC_Nod[i].PPRI.Owner).Pawn.Destroy();
			
			RTC_Nod[i].PPRI.SetCredits(CredAmount);
			
			//SetTeam(Controller(RTC_Nod[i].PPRI.Owner) ,Teams[TEAM_GDI], true);
			CTextBroadcast(255, Caps("SWAPPED:" @ RTC_GDI[i].PPRI.PlayerName @ "and" @ RTC_Nod[i].PPRI.PlayerName)); 
			RTC_GDI.Remove(i,1);
			RTC_Nod.Remove(i,1);
		}		
	}

}

function CTextBroadcast(byte TeamByte,string TEXT, optional name Colour = 'LightBlue', optional float TIME = 60.0, optional float Size = 1.0, optional bool bWarning)
{
	local Rx_Controller P; 
	
	if(TeamByte == 0 || TeamByte == 1)
	{
		foreach WorldInfo.AllControllers(class'Rx_Controller', P)
		{
			if(P.GetTeamNum() == TeamByte) 
				P.CTextMessage(TEXT,Colour,TIME, Size,,bWarning) ; 
			else
				continue;
		}
	}
	else
	{
	foreach WorldInfo.AllControllers(class'Rx_Controller', P)
		{
			P.CTextMessage(TEXT,Colour,TIME, Size) ;
		}
	}
}

function CTextSquadBroadcast(byte TeamByte, byte SquadNumber,string TEXT, optional name Colour = 'LightBlue', optional float TIME = 60.0, optional float Size = 1.0)
{
	local Rx_Controller P; 
	
	if(TeamByte == 0 || TeamByte == 1)
	{
		foreach WorldInfo.AllControllers(class'Rx_Controller', P)
		{
			if(P.GetTeamNum() == TeamByte && Rx_PRI(P.PlayerReplicationInfo).CurrentControlGroup == SquadNumber)  P.CTextMessage(TEXT,Colour,TIME, Size) ;
			else
			continue;
		}
	}
	else
	return; 
}

function bool TeamHasSurrendered()
{
	return bGDIHasSurrendered || bNodHasSurrendered ; 
}

/****************************
*Commander Functions 
****************************/

function ChangeCommander(byte ToTeam, Rx_PRI RxPRI, optional bool bIsInitialSetting = false)
{
	local Rx_PRI PRIi;
	
	if(!bEnableCommanders) return; 
	
	RemoveCommander(ToTeam);
	
	Commander_PRI[ToTeam] = RxPRI; 
	
	if(bUseStaticCommanders && !bIsInitialSetting) `RxEngineObject.SetStaticCommanderID(ToTeam, RxPRI);
	
	foreach AllActors(class'Rx_PRI', PRIi)
	{
	if(PRIi.GetTeamNum() == ToTeam )	
		{
			PRIi.SetCommander(RxPRI); 	
		}
	}
}

function RemoveCommander(byte ToTeam)
{
	local Rx_PRI PRIi;
	
	Commander_PRI[ToTeam] = none; 
	
	//if(bUseStaticCommanders) `RxEngineObject.ClearStaticCommanderID(ToTeam);
	
	foreach AllActors(class'Rx_PRI', PRIi)
	{
	if(PRIi.GetTeamNum() == ToTeam )	
		{
			PRIi.RemoveCommander(ToTeam); 	
		}
	}
}

function int GetFreeTarget(byte TeamByte, byte TargetType, PlayerReplicationInfo RxPRI)
{
	
	//local byte AntiTeamByte; 
	//local Rx_PRI PRIi; 
	local int i; 
	
	//NOTE: For now, only attack targets are numbered
	
	//AntiTeamByte = TeamByte == 0 ? 1 : 0 ;
	//Geeds
	if(TeamByte == 1 && TargetType == 1)
	{
		/**if(TargetedPlayers_Nod.Length == 0 || TargetedPlayers_Nod[0] == none) 
		{
			TargetedPlayers_Nod.InsertItem(0, RxPRI); 
			return 1; 	
		}
		else*/ //Find a number that isn't being used, or add one.
		//{
			if(TargetedPlayers_Nod.Find(RxPRI) != -1) 
			{
				return -1 ; //Found, tell PRI to just refresh its timer 	
			}
			else
			{
				/**TargetedPlayers_Nod.RemoveItem(none); //Get rid of null items 
				TargetedPlayers_Nod.AddItem(RxPRI); 
				*/
				for (i=0;i<=TargetedPlayers_Nod.Length;i++)
				{
					if(i==TargetedPlayers_Nod.Length) 
					{
						//`log("Adding new target" $ i);
						TargetedPlayers_Nod.AddItem(RxPRI);
						return i+1; //TargetedPlayers_Nod.Length; 
					}
					else
					if(TargetedPlayers_Nod[i] == none)
					{
						//`log("Found occurrence NONE - I is " $ i);
						TargetedPlayers_Nod[i] = RxPRI; 
						return i+1; 
					}
				}
				
				
			}
		//}	
	}
	else
	//Nod's Attack target logic 
	if(TeamByte == 0 && TargetType == 1)
	{
		/**if(TargetedPlayers_Nod.Length == 0 || TargetedPlayers_Nod[0] == none) 
		{
			TargetedPlayers_Nod.InsertItem(0, RxPRI); 
			return 1; 	
		}
		else*/ //Find a number that isn't being used, or add one.
		//{
			if(TargetedPlayers_GDI.Find(RxPRI) != -1) 
			{
				return -1 ; //Found, tell PRI to just refresh its timer 	
			}
			else
			{
				/**TargetedPlayers_GDI.RemoveItem(none); //Get rid of null items 
				TargetedPlayers_GDI.AddItem(RxPRI); 
				*/
				for (i=0;i<=TargetedPlayers_GDI.Length;i++)
				{
					if(i==TargetedPlayers_GDI.Length) 
					{
						//`log("Adding new target" $ i);
						TargetedPlayers_GDI.AddItem(RxPRI);
						return i+1; //TargetedPlayers_GDI.Length; 
					}
					else
					if(TargetedPlayers_GDI[i] == none)
					{
						//`log("Found occurrence NONE - I is " $ i);
						TargetedPlayers_GDI[i] = RxPRI; 
						return i+1; 
					}
				}
				
				
			}
		//}	
	}
	
	return 9999; 
}

function RemoveTarget(byte TeamByte, PlayerReplicationInfo RxPRI, optional byte Special) //Special (USed for a target being destroyed or what not)
{

	local int i;
	local bool bPlayDecayMsg; //Don't spam decay messages. We get it, Yosh! We done fucked up! 

	bPlayDecayMsg = (WorldInfo.TimeSeconds - LastDecayMsgTime[TeamByte]) >= 3.0 ; 
	 
	if(TeamByte == 0 ) 
	{ 
		i = TargetedPlayers_GDI.Find(RxPRI);

		if (i != -1) TargetedPlayers_GDI[i] = none ; //.Remove(i,1) ;

		switch (Special)
		{
			//0-9 Infantry
			case 0:
			if(bPlayDecayMsg)
			{
				CTextBroadcast(1,"--Infantry Target Decayed--",'White');
				LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
			}  
			break; 
			case 1: 
				CTextBroadcast(1,"--Infantry Target Eliminated--",'Green'); 
				Rx_TeamInfo(Teams[1]).AddCommandPoints(CPReward_Infantry, "Command Target Elimination&" $ CPReward_Infantry $ "&") ; 
				break;
			
			//10's Ground vehicles 
			
				case 10:			
				if(bPlayDecayMsg) 
				{
					CTextBroadcast(1,"--Vehicle Target Decayed--",'White'); 
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}
				break;
			
			case 11:			
				CTextBroadcast(1,"--Vehicle Target Eliminated--",'Green');
				Rx_TeamInfo(Teams[1]).AddCommandPoints(CPReward_Vehicle, "Command Target Elimination&" $ CPReward_Vehicle $ "&") ;
				break;
			
			//30's Emplacement messages
			
			case 30 :
				if(bPlayDecayMsg)
				{
					CTextBroadcast(1,"--Emplacement Target Decayed--",'White'); 
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}				
				break;
			
			case 31 :
				CTextBroadcast(1,"--Emplacement Target Destroyed--",'Green');
				Rx_TeamInfo(Teams[1]).AddCommandPoints(CPReward_Emplacement, "Command Target Elimination&" $ CPReward_Emplacement $ "&") ;
				break;
			
			//40's = Aircraft messages
			case 40 :
				if(bPlayDecayMsg) 
				{
					CTextBroadcast(1,"--Aircraft Target Decayed--",'White');
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}
			
				break;
			
			case 41 :
				CTextBroadcast(1,"--Aircraft Target Destroyed--",'Green');
				Rx_TeamInfo(Teams[1]).AddCommandPoints(CPReward_Vehicle, "Command Target Elimination&" $ CPReward_Vehicle $ "&") ;			
				break;
				
				//100+ for special messages 
			case 100: 
				if(bPlayDecayMsg) 
				{
					CTextBroadcast(1,"--Stealth Target Lost--",'LightBlue'); 
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}
			
			break;
			
			default: 
			break; 
		}
	}
	else
	if(TeamByte == 1 ) 
	{ 
		i = TargetedPlayers_Nod.Find(RxPRI);

		if (i != -1) TargetedPlayers_Nod[i] = none ; //.Remove(i,1) ;

		switch (Special)
		{
			//0-9 Infantry
			case 0:
				if(bPlayDecayMsg)
				{
					CTextBroadcast(0,"--Infantry Target Decayed--",'White');
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}
			
			break; 
			
			case 1:
				CTextBroadcast(0,"--Infantry Target Eliminated--",'Green'); 
				Rx_TeamInfo(Teams[0]).AddCommandPoints(CPReward_Infantry, "Command Target Elimination&" $ CPReward_Infantry $ "&") ;
				break;
				
				//10's Ground vehicles 
			
			case 10:
				if(bPlayDecayMsg)
				{
					CTextBroadcast(0,"--Vehicle Target Decayed--",'White'); 
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}
				break;
			
			case 11:			
				CTextBroadcast(0,"--Vehicle Target Eliminated--",'Green');
				Rx_TeamInfo(Teams[0]).AddCommandPoints(CPReward_Vehicle, "Command Target Elimination&" $ CPReward_Vehicle $ "&") ;
				break;
			
			//30's Emplacement messages
			
			case 30 :
				if(bPlayDecayMsg)
				{
					CTextBroadcast(0,"--Emplacement Target Decayed--",'White'); 
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}
				break;
			
			case 31 :
				CTextBroadcast(0,"--Emplacement Target Destroyed--",'Green');
				Rx_TeamInfo(Teams[0]).AddCommandPoints(CPReward_Emplacement, "Command Target Elimination&" $ CPReward_Emplacement $ "&") ;
				break;
				
				//40's = Aircraft messages
			case 40 :
				if(bPlayDecayMsg)
				{
					CTextBroadcast(0,"--Aircraft Target Decayed--",'White'); 
					LastDecayMsgTime[TeamByte] = WorldInfo.TimeSeconds; 
				}
				break;
			
			case 41 :
				CTextBroadcast(0,"--Aircraft Target Destroyed--",'Green');
				Rx_TeamInfo(Teams[0]).AddCommandPoints(CPReward_Vehicle, "Command Target Elimination&" $ CPReward_Vehicle $ "&") ;
				break;
				
				//100+ for special messages 
			case 100: 
				CTextBroadcast(0,"--Stealth Target Lost--",'LightBlue'); 
				break;
			
			default: 
				break; 
		}
	}
	else
	`log("-------RECIEVED INAPPROPRIATE TEAM BYTE-------" @ TeamByte);

}


function int GetDefenceID() //Are there ever going to be over like ... 10billion defences on a map? Unlikely.Assign as they come 
{
	Defence_IDs++;
	return Defence_IDs; 
	
}

/*Squad Stuff*/

function bool AddPlayerToSquad(Rx_PRI RxPRI, byte TeamByte, byte SquadNumber)
{
	
	//Geeds
	if(TeamByte == 0)
	{
		if(GDIControlGroups[SquadNumber].Members.Length == 0) 
		{
			GDIControlGroups[SquadNumber].Members.AddItem(RxPRI); 
			return true; //Added successfully 	
		}
		else //Find a number that isn't being used, or add one.
		{
			if(GDIControlGroups[SquadNumber].Members.Find(RxPRI) != -1) 
			{
				return false ; //User Already In This Squad
			}
			else
			{
				GDIControlGroups[SquadNumber].Members.AddItem(RxPRI);
				RxPRI.SetControlGroup(SquadNumber);
				CTextSquadBroadcast(TeamByte, SquadNumber, RxPRI.PlayerName @ "joined group" @ GDIControlGroups[SquadNumber].GroupTitle, 'LightBlue'); 			
				return true; 
			}
		}
	}
	
	else
	//NAHD!
	if(TeamByte == 1)
	{
		if(NodControlGroups[SquadNumber].Members.Length == 0) 
		{
			NodControlGroups[SquadNumber].Members.AddItem(RxPRI); 
			return true; //Added successfully 	
		}
		else //Find a number that isn't being used, or add one.
		{
			if(NodControlGroups[SquadNumber].Members.Find(RxPRI) != -1) 
			{
				return false ; //User Already In This Squad
			}
			else
			{
				NodControlGroups[SquadNumber].Members.AddItem(RxPRI); 
				RxPRI.SetControlGroup(SquadNumber);
				CTextSquadBroadcast(TeamByte, SquadNumber, RxPRI.PlayerName @ "joined group" @ NodControlGroups[SquadNumber].GroupTitle, 'LightBlue'); 
				return true; 
			}
		}
	}
	
	return false; 
	
}

function bool RemovePlayerFromSquad(Rx_PRI RxPRI, byte TeamByte, byte SquadNumber)
{

local int PRIPosition; 
	
	//Geeds
	if(TeamByte == 0)
	{
		if(GDIControlGroups[SquadNumber].Members.Length == 0) return false; 
		else
		{
			PRIPosition=GDIControlGroups[SquadNumber].Members.Find(RxPRI); 
			
			if(PRIPosition == -1) return false; 
			else
			{
				GDIControlGroups[SquadNumber].Members.Remove(PRIPosition, 1);
				RxPRI.SetControlGroup(255);
				CTextSquadBroadcast(TeamByte, SquadNumber, RxPRI.PlayerName @ "left group" @ GDIControlGroups[SquadNumber].GroupTitle, 'LightBlue' ); 
				return true; 
			}
			
		}
		
	}
	else
	//NAHD!
	if(TeamByte == 1)
	{
		if(NodControlGroups[SquadNumber].Members.Length == 0) return false; 
		else
		{
			PRIPosition=NodControlGroups[SquadNumber].Members.Find(RxPRI); 
			
			if(PRIPosition == -1) return false; 
			else
			{
				NodControlGroups[SquadNumber].Members.Remove(PRIPosition, 1);
				RxPRI.SetControlGroup(255);
				CTextSquadBroadcast(TeamByte, SquadNumber, RxPRI.PlayerName @ "left group" @ NodControlGroups[SquadNumber].GroupTitle, 'LightBlue' ); 
				return true; 
			}
			
		}
		
	}
	
	return false; 
	
}


function bool CanSpectate( PlayerController Viewer, PlayerReplicationInfo ViewTarget )
{
	if(Rx_PRI(ViewTarget) == None)
	{
		return false;
	}
	
	return true;
}

DefaultProperties
{	

	MapListManagerClassName="RenX_game.Rx_MapListManager";

	EndgameCamDelay = 1.0f
	EndgameSoundDelay = 1.0f

	UsePurchaseSystem = true;

	buildingArmorPercentage = 50 
	
	bUseSeamlessTravel = true

	MaxPlayerNameLength        = 20

	DisallowedNames[0]          = "---"
	DisallowedNames[1]          = "----"
	DisallowedNames[2]          = "-----"
	DisallowedNames[3]          = "------"
	DisallowedNames[4]          = "-------"
	DisallowedNames[5]          = "--------"
	DisallowedNames[6]          = "Host"

	CountDown				   = 11
	EndGameDelay			   = 45.0	
	bMustHaveMultiplePlayers   = false
	bPauseable                 = true
	bUseClassicHUD             = true
	bSpawnInTeamArea		   = true
	bFirstBlood                = true
	Port 				       = 7777

	HudClass                   = class'Rx_HUD'
	VictoryMessageClass        = class'Rx_VictoryMessage'
	DeathMessageClass          = class'Rx_DeathMessage'
	bUndrivenVehicleDamage	   = true
	PlayerControllerClass	   = class'Rx_Controller'
	DefaultPawnClass           = class'Rx_Pawn'
	PlayerReplicationInfoClass = class'Rx_PRI'
	BroadcastHandlerClass      = class'Rx_BroadcastHandler'
	AccessControlClass         = class'Rx_AccessControl'
	TeamInfoClass			   = class'Rx_TeamInfo'
	
	GameReplicationInfoClass   = class'Rx_GRI'
	PurchaseSystemClass        = class'Rx_PurchaseSystem'
	HelipadPurchaseSystemClass = class'Rx_HelipadPurchaseSystem'
	VehicleManagerClass        = class'Rx_VehicleManager'
	HelipadVehicleManagerClass = class'Rx_HelipadVehicleManager'
	CommanderControllerClass   = class'Rx_CommanderController'
	
	BoinkSound				   = SoundCue'RX_SoundEffects.SFX.SC_Boink'
	
	MapPrefixes.Empty
	MapPrefixes.Add("CNC")
	Acronym						= "RxGame"

	NumBots						= 0 
	NumPlayers					= 0
	bPlayersVsBots				= false	
	MineLimit					= 30
	VehicleLimit				= 8
	
	/** class setup props */
	BotClass                      = class'RenX_Game.Rx_Bot_Waypoints'

	TeamAIType(0)                 = class'Rx_TeamAI'
	TeamAIType(1)                 = class'Rx_TeamAI'
	
	/** DefaultInventory */
	DefaultInventory(0)           = class'Rx_Weapon_AutoRifle_GDI'	
	
	bDelayedStart=true 
	bSkipPlaySound=true
	
	MaxPlayersAllowed			  = 64

	MapHistoryMax                 = 10       
	VotePersonalCooldown          = 60
	VoteTeamCoolDown_GDI		  = 180
	VoteTeamCoolDown_Nod		  = 180
	
	//SurrenderDisabledTime		= 600
	RTC_DisableTime				= 0
	RTC_TimeLimit				= 20
	
	VPMilestones(0) = 100 //VP needed for Veteran 
	VPMilestones(1) = 300 //VP Needed for Elite
	VPMilestones(2) = 650 //VP Needed for Heroic

	GameType = 1 // 1 = Rx_Game

	PowerUpClasses.Add(class'Rx_Pickup_Ammo');
	MaxInitialVeterancy = 400
	CurrentBuildingVPModifier = 1.0
	CreditTickRate = 1.0
	CP_TickRate	   = 1.0
	
	CPReward_Emplacement= 50 
	CPReward_Infantry	= 10
	CPReward_Vehicle	= 10
	
	/*Squad Default Naming Conventions*/
	
	GDIControlGroups(0) = (GroupTitle = "Offense-1") 
	GDIControlGroups(1) = (GroupTitle = "Offense-2") 
	GDIControlGroups(2) = (GroupTitle = "Offense-3") 
	GDIControlGroups(3) = (GroupTitle = "Support-1") 
	GDIControlGroups(4) = (GroupTitle = "Support-2") 
	GDIControlGroups(5) = (GroupTitle = "Defense-1")
	
	NodControlGroups(0) = (GroupTitle = "Offense-1") 
	NodControlGroups(1) = (GroupTitle = "Offense-2") 
	NodControlGroups(2) = (GroupTitle = "Offense-3") 
	NodControlGroups(3) = (GroupTitle = "Support-1") 
	NodControlGroups(4) = (GroupTitle = "Support-2") 
	NodControlGroups(5) = (GroupTitle = "Defense-1") 
}
