/**
 * RxGame
 *
 * */
class Rx_Game extends UTTeamGame
	config(RenegadeX);

`define SupressNullDamageType(Statement) if (DamageType != class'DamageType') `Statement

/** one1: Current vote in progress. */
var Rx_VoteMenuChoice GlobalVote;
var Rx_VoteMenuChoice GDIVote;
var Rx_VoteMenuChoice NODVote;
var float VotePersonalCooldown;

var config bool bFixedMapRotation;

var globalconfig array<string> MapHistory; // In order of most recent (0 = Most Recent)
var int MapHistoryMax; // Max number of recently played maps to hold in memory

var config int RecentMapsToExclude;
var config int MaxMapVoteSize;
var config int CnCModeTimeLimit;

/** Team Numbers in handy ENUM form */
enum TEAM
{
	TEAM_GDI,
	TEAM_NOD,
	TEAM_UNOWNED
};

struct TeamCreditStruct 
{
	var Rx_Building_Refinery    Refinery;
	var array<Rx_PRI>           PlayerRI;
};
	
var class<UTHudBase>					HudClass;
var float								EndGameDelay;
var float								RenEndTime;
var int									MineLimit;
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
var config int 						    VehicleLimit;
var config bool	                        SpawnCrates; // whether or not to spawn crates in this game
var config float                        CrateRespawnAfterPickup; // interval for crate respawn (after pickup)
var config bool                         bBotsDisabled;
var config int                          DonationsDisabledTime;
var config bool                         bReserveVehiclesToBuyer;
var config bool                         bAllowWeaponDrop;

var Rx_PurchaseSystem                   PurchaseSystem;
var Rx_VehicleManager                   VehicleManager;
var bool							    bCanPlayEvaBuildingUnderAttackGDI;
var bool							    bCanPlayEvaBuildingUnderAttackNOD;
var byte						        WinnerTeamNum;
var Rx_Building_Obelisk					Obelisk;
var Rx_Building_AdvancedGuardTower		AGT;
var int SmokeScreenCount;   // Optimisation - Used to track if there is an active SmokeScreen and allows AI to skip traces for SmokeScreens if there are none.

var GeminiOnlineService ServiceBrowser;

var const float EndgameCamDelay, EndgameSoundDelay;

var Rx_AuthenticationService authenticationService;
var config bool bHostsAuthenticationService;

/**Provides Map Information stored in the .ini file. (expensive to get, so cache here). */
var array<Rx_UIDataProvider_MapInfo> MapDataProviderList;

// Skirmish options:
var int GDIBotCount;
var int NODBotCount;
var int GDIDifficulty;
var int NODDifficulty;
var int PlayerTeam;
var int NodAttackingValue;
var int GDIAttackingValue;

var int Port;
var config array<string> SteamLogins;

var config bool bIsCompetitive;
var bool bIsClanWars;
var Rx_MatchInfo MatchInfo;

var array<Rx_CratePickup> AllCrates;

/** Does the server allow non-admin clients to PM each other. */
var config bool bAllowPrivateMessaging;
/** Restrict PMing to just teammates. */
var config bool bPrivateMessageTeamOnly;

/** Should the server perform an auto team shuffle on new rounds. */
var config bool bAutoShuffleOnNewRound;

var config bool bRandomTeamSwap;

struct Server
{
	var string ServerName;
	var string ServerIP;
	var string ServerPass;
	var string ServerPort;
	var int Gametype;
	var string Mapname;
	var string GameVersion;
	var int NumPlayers;
	var int MaxPlayers;
	var int Ranked;
	var int Ping;
	var bool bInGame;
	var bool bPassword;
};

var array<Server> ListServers;
var string ServerListRawData;

/**@Shahman: Version of this build*/
var config string GameVersion;
/**@Shahman: Game Version Number*/
var config int GameVersionNumber;
/**@MPalko: Retrieves latest version from the website*/
var Rx_VersionCheck VersionCheck;


var int curIndPinged;

var Rx_Rcon Rcon;
var Rx_Rcon_Commands_Container RconCommands;
var Rx_Rcon_Out RconOut;

var globalconfig bool bDisableDemoRequests;
var bool ClientDemoInProgress;

var globalconfig float MaxSeamlessTravelServerTime; // If the server has been up longer than this amount, then force a non-seamless travel.
var bool bForceNonSeamless;

enum BuildingCheck
{
	BC_TeamsHaveBuildings,
	BC_GDIDestroyed,
	BC_NodDestroyed,
	BC_TeamsHaveNoBuildings
}; 


//var Rx_SystemSettingsHandler SystemSettingsHandler;

function PreBeginPlay()
{
	MaxSeamlessTravelServerTime = Clamp(MaxSeamlessTravelServerTime, 0, 172800); // 172800 seconds == 48 hours. No higher than 48hrs so TimeSeconds doesn't overflow.

	Super.PreBeginPlay();
	if ( Role == ROLE_Authority )
	{
		PurchaseSystem = spawn(class'Rx_PurchaseSystem',self,'PurchaseSystem',Location,Rotation);
		VehicleManager = spawn(class'Rx_VehicleManager',self,'VehicleManager',Location,Rotation);
		PurchaseSystem.SetVehicleManager(VehicleManager);
	}
	/**
	CreateTeam(TEAM_GDI);
	CreateTeam(TEAM_NOD);
	Teams[TEAM_GDI].AI.EnemyTeam = Teams[TEAM_NOD];
	Teams[TEAM_NOD].AI.EnemyTeam = Teams[TEAM_GDI];
	*/
	VehicleManager.Initialize(self, Teams[TEAM_GDI], Teams[TEAM_NOD]);
	
	if(bHostsAuthenticationService) {
		authenticationService = Spawn(class'Rx_AuthenticationService');
	}
	
	if(ServiceBrowser == None && (WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_DedicatedServer))
	{
		ServiceBrowser = Spawn(class'GeminiOnlineService');
		ServiceBrowser.Initialize(self, none);
	}
	
	// Create our version check class.
	VersionCheck = Spawn(class'Rx_VersionCheck');

// 	// Create our Graphic Adapter check class.
// 	GraphicAdapterCheck = Spawn(class'Rx_GraphicAdapterCheck');
// 	GraphicAdapterCheck.CheckGraphicAdapter();

	ListServers.length = 0;

	//Create our systemsettingshandler here
	//SystemSettingsHandler = Spawn(class'Rx_SystemSettingsHandler');
	

	// Forced settings for Clan Wars
	if (bIsClanWars)
	{
		bPlayersBalanceTeams=false;
		bAutoShuffleOnNewRound=false;
	}

	MaxMapVoteSize = Clamp(MaxMapVoteSize, 1, 9);
	RecentMapsToExclude = Clamp(RecentMapsToExclude, 0, 8);
	

	//Get out map info here
	SetupMapDataList();
}

function SetupMapDataList()
{
	local array<UDKUIResourceDataProvider> ProviderList; 
	local int i;

	// make sure default map exists
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'Rx_UIDataProvider_MapInfo', ProviderList);
	
	//hack until we solve the sorting issue
	for (i = ProviderList.length; i >= 0; i--)
	{		
		if (Rx_UIDataProvider_MapInfo(ProviderList[i]) == none) {
			`log("NONE - ProviderList[i]? " $ Rx_UIDataProvider_MapInfo(ProviderList[i]).MapName);
			continue;
		}
		MapDataProviderList.AddItem(Rx_UIDataProvider_MapInfo(ProviderList[i]));
	} 
}

/** one1: added */
function PostBeginPlay()
{
	local Rx_Rcon r;
	//local Rx_MatchInfo m;

	super.PostBeginPlay();

	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		if (RconOut == None)
		{
			RconOut = Spawn(class'Rx_Rcon_Out');
			RconOut.connect();
		}
		if (class'Rx_Rcon'.default.bEnableRcon)
		{
			foreach DynamicActors(class'Rx_Rcon', r)
			{
				Rcon = r;
				break;
			}

			if (Rcon == None)
				Rcon = Spawn(class'Rx_Rcon');
		}
		if (RconCommands == None)
		{
			RconCommands = Spawn(class'Rx_Rcon_Commands_Container');
			RconCommands.InitRconCommands();
		}
		/*
		if (bIsClanWars)
		{
			foreach DynamicActors(class'Rx_MatchInfo', m)
			{
				MatchInfo = m;
				break;
			}

			if (MatchInfo == None)
				MatchInfo = Spawn(class'Rx_MatchInfo');

			MatchInfo.Game = self;
		}*/
	}
	else
	{
		if (bIsClanWars)
			bIsClanWars=false;
	}

	SetTimer(1.f, true, 'VoteTimer');
	SetTimer(2.f, false, 'SendServerStats');

	if (bIsClanWars)
		MatchInfo.GameInfoPostBeginPlay();
	else
	{
		if (WorldInfo.NetMode != NM_Standalone && bAutoShuffleOnNewRound)
			ShuffleTeams();
		else if (WorldInfo.NetMode != NM_Standalone && bRandomTeamSwap)
		{
			if (Rand(2) != 0)
				SwapTeams();
		}
	}

	RecordToMapHistory(string(WorldInfo.GetPackageName()));

	if (bFixedMapRotation)
		Rx_GRI(GameReplicationInfo).SetFixedNextMap(GetNextMapInRotationName());
	else
		Rx_GRI(GameReplicationInfo).SetupEndMapVote(BuildMapVoteList(), true);

	RxLog("MAP"`s"Loaded;"`s GetPackageName() );
}

function ShuffleTeams()
{
	local Array<Rx_Controller> Team1, Team2, All;
	local int Team1Score, Team2Score;
	local int GDICount, NodCount;
	local Rx_Controller PC, Highest;

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
			if (PC.PlayerReplicationInfo.Team.TeamIndex != 0)
				SetTeam(PC, Teams[0], false);
		foreach Team2(PC)
			if (PC.PlayerReplicationInfo.Team.TeamIndex != 1)
				SetTeam(PC, Teams[1], false);
	}
	else
	{
		// Team 1 go Nod, Team 2 go GDI
		foreach Team1(PC)
			if (PC.PlayerReplicationInfo.Team.TeamIndex != 1)
				SetTeam(PC, Teams[1], false);
		foreach Team2(PC)
			if (PC.PlayerReplicationInfo.Team.TeamIndex != 0)
				SetTeam(PC, Teams[0], false);
	}

	// Terribly unoptimized, but done.

}

function SwapTeams()
{
	local Controller PC;

	foreach WorldInfo.AllControllers(class'Controller', PC)
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

function byte PickTeam(byte num, Controller C)
{
	if (bIsClanWars)
		return MatchInfo.PickTeam(Rx_Controller(C));
	return super.PickTeam(num, C);
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	if (super.ChangeTeam(Other, num, bNewTeam))
	{
		if (Rx_Controller(Other) != None)
		{
			Rx_Controller(Other).BindVehicle(None);
		}
		if (Rx_PRI(Other.PlayerReplicationInfo) != None)
		{
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
	}

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
function RxLog(string Msg)
{
	`log(Msg,true,'Rx');
	if (RconOut != None)
		RconOut.SendLog(Msg);
	if (Rcon != None)
		Rcon.SendLog(Msg);
}

function RxLogPub(string Msg)
{
	`log(Msg,true,'Rx');
	if (RconOut != None)
		RconOut.SendLog(Msg);
	if (!bIsCompetitive && Rcon != None)
		Rcon.SendLog(Msg);
}

function LogBuildingDestroyed(PlayerReplicationInfo Destroyer, Actor Building, class<DamageType> DamageType)
{
	RxLog("GAME"`s "Destroyed;"`s "building"`s Building.Class `s "by"`s `PlayerLog(Destroyer)`s "with"`s DamageType);
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

event SendServerStats()
{
	if(WorldInfo.NetMode == NM_DedicatedServer)
	{
		UpdateServerStats();
	}	
}

function UpdateServerStats()
{
	
	if(WorldInfo.NetMode == NM_DedicatedServer)
	{		
		if(!IsTimerActive('SendNewServerInfoTimer'))
			SetTimer(2000,true,'SendNewServerInfoTimer');
		
		if(IsTimerActive('UpdateServerStatsTimer'))
			return;
			
		SetTimer(3.0,false,'UpdateServerStatsTimer');
	}
}

function UpdateServerStatsTimer() 
{
	local String ServerSettings;	
	
	/**
	PlayerNames = "";
	foreach WorldInfo.GRI.PRIArray(pri)
	{
		PlayerNames = PlayerNames$pri.PlayerName;	
	}
	*/
	ServerSettings = MaxPlayers $ ";" $ VehicleLimit $ ";" $ MineLimit $ ";" $ SpawnCrates $ ";"
						$ 0 $ ";" 
						$ bAutoShuffleOnNewRound $ ";"
						$ TimeLimit $ ";"
						$ bAllowPrivateMessaging $ ";"
						$ bPrivateMessageTeamOnly $ ";"
						$ Rx_AccessControl(AccessControl).bRequireSteam $ ";"
						$ GameVersion $ ";"
						$ bBotsDisabled;
						
	ServiceBrowser.PostToServer(Port,WorldInfo.GRI.ServerName,AccessControl.RequiresPassword(),string(WorldInfo.GetPackageName()),ServerSettings,GetNumPlayers(),MaxPlayersAllowed,0,true,NumBots);
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
	
function SendNewServerInfoTimer()
{
	UpdateServerStats();		
}

event PostLogin( PlayerController NewPlayer )
{
	local string SteamID;

	SteamID = OnlineSub.UniqueNetIdToString(NewPlayer.PlayerReplicationInfo.UniqueId);
	if (SteamID == `BlankSteamID || SteamID == "")
		RxLog("PLAYER"`s "Enter;"`s `PlayerLog(NewPlayer.PlayerReplicationInfo)`s"from"`s NewPlayer.GetPlayerNetworkAddress()`s"nosteam");
	else
		RxLog("PLAYER"`s "Enter;"`s `PlayerLog(NewPlayer.PlayerReplicationInfo)`s"from"`s NewPlayer.GetPlayerNetworkAddress()`s"steamid"`s SteamID);

	AnnounceTeamJoin(NewPlayer.PlayerReplicationInfo, NewPlayer.PlayerReplicationInfo.Team, None, false);

	super.PostLogin(NewPlayer);
	if(WorldInfo.NetMode == NM_DedicatedServer)
		UpdateServerStats();
				
	Rx_Pri(NewPlayer.PlayerReplicationInfo).ReplicatedNetworkAddress = NewPlayer.PlayerReplicationInfo.SavedNetworkAddress;	
	
	if(ServiceBrowser != None && WorldInfo.NetMode == NM_DedicatedServer)
		ServiceBrowser.GetServiceCheckIp(NewPlayer.PlayerReplicationInfo.SavedNetworkAddress, SteamID, false);
		
	if(bDelayedStart) // we want bDelayedStart, but still want players to spawn immediatly upon connect
		RestartPlayer(newPlayer);		
}

function Logout( Controller Exiting )
{
	local String playerstats;
	if (Rx_Controller(Exiting) != None)
	{
		Rx_Controller(Exiting).BindVehicle(None);
	}
	if (Rx_PRI(Exiting.PlayerReplicationInfo) != None)
	{
		Rx_PRI(Exiting.PlayerReplicationInfo).DestroyATMines();
		Rx_PRI(Exiting.PlayerReplicationInfo).DestroyRemoteC4();
	}
	super.Logout(Exiting);
	RxLog("PLAYER"`s "Exit;"`s `PlayerLog(Exiting.PlayerReplicationInfo));
	if(ServiceBrowser != None && WorldInfo.NetMode == NM_DedicatedServer) {
		UpdateServerStats();
		if(Rx_Controller(Exiting) != None) {
			playerstats = getPlayerStatsStringFromPri(Rx_Pri(Exiting.PlayerReplicationInfo));
			if(playerstats != "") {
				ServiceBrowser.SendPlayerStats(playerstats);
			}
		}
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
	case "BAUTOSHUFFLEONNEWROUND":
		return string(bAutoShuffleOnNewRound);
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
	case "BALLOWWEAPONDROP":
		return string(bAllowWeaponDrop);
	case "BISCOMPETITIVE":
		return string(bIsCompetitive);
	case "BISCLANWARS":
		return string(bIsClanwars);
	case "BRANDOMTEAMSWAP":
		return string(bRandomTeamSwap);
	case "GAMEVERSION":
		return GameVersion;
	case "GAMEVERSIONNUMBER":
		return string(GameVersionNumber);
	case "BDISABLEDEMOREQUESTS":
		return string(bDisableDemoRequests);
	case "MAXSEAMLESSTRAVELSERVERTIME":
		return string(MaxSeamlessTravelServerTime);

		// Not found
	default:
		return "ERR_UNKNOWNVAR";
	}
}

event GameEnding()
{
	
	//M.Palko endgame crash track log.
	`log("------------------------------Game Ending Event Called");

	if(WorldInfo.NetMode == NM_DedicatedServer)
		ServiceBrowser.RemoveServer();
	super.GameEnding();
	loginternal("<<GameEnding>>");
}

event InitGame( string Options, out string ErrorMessage )
{	
	local int MapIndex;
	
	if(Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap)
	{
		if(TimeLimit != 10)
			CnCModeTimeLimit = TimeLimit;
		TimeLimit = 10;
		//bAllowWeaponDrop = true; // deactivated till weapondrop is more fleshed out
		bSpawnInTeamArea = false;
	} else if(CnCModeTimeLimit > 0 && CnCModeTimeLimit != TimeLimit)
	{
		TimeLimit = CnCModeTimeLimit;
	}
		
	super.InitGame(Options, ErrorMessage);
	TeamFactions[TEAM_GDI] = "GDI";
	TeamFactions[TEAM_NOD] = "Nod";
	DesiredPlayerCount = 1;
	bCanPlayEvaBuildingUnderAttackGDI = true;
	bCanPlayEvaBuildingUnderAttackNOD = true;

	if (Role == ROLE_Authority )
	{
		FindRefineries(); // Find the refineries so we can give players credits
	}
	GDIBotCount = GetIntOption( Options, "GDIBotCount",0);
	NODBotCount = GetIntOption( Options, "NODBotCount",0);
	AdjustedDifficulty = 5;
	GDIDifficulty = GetIntOption( Options, "GDIDifficulty",4);
	NODDifficulty = GetIntOption( Options, "NODDifficulty",4);
	GDIDifficulty += 3;
	NODDifficulty += 3;
	
	
	MapIndex = class'Rx_Game'.default.MapSpecificMineAndVehLimit.Find('MapName', WorldInfo.GetPackageName());
	MineLimit = class'Rx_Game'.default.MapSpecificMineAndVehLimit[MapIndex].MineLimit;
	VehicleLimit = class'Rx_Game'.default.MapSpecificMineAndVehLimit[MapIndex].VehicleLimit;


	//mapindex = -1;
	//for (i=0; i < mapdataproviderlist.length; i++) {
	//	if (mapdataproviderlist[i].mapname != string(worldinfo.getpackagename())) {
	//		continue;
	//	}
	//	mapindex = i;
	//}
	//MineLimit = MapDataProviderList[MapIndex].MineLimit;
	//VehicleLimit = MapDataProviderList[MapIndex].VehicleLimit;

	InitialCredits = GetIntOption(Options, "StartingCredits", InitialCredits);
	MineLimit = GetIntOption( Options, "MineLimit", MineLimit);
	VehicleLimit = GetIntOption( Options, "VehicleLimit", VehicleLimit);
	PlayerTeam = GetIntOption( Options, "Team",0);
	GDIAttackingValue = GetIntOption( Options, "GDIAttackingStrengh",0.7);
	NodAttackingValue = GetIntOption( Options, "NodAttackingStrengh",0.7);
	//Port = GetIntOption( Options, "PORT",7777);
	Port = `GamePort;
	//GamePassword = ParseOption( Options, "GamePassword");
	
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
}

function CreateTeam(int TeamIndex) 
{
	if (TeamIndex > 2) // only 2: GDI and NOD
	  return;

	Teams[TeamIndex] = spawn(class'Rx_TeamInfo');
	Teams[TeamIndex].Initialize(TeamIndex);
	
	Rx_TeamInfo(Teams[TeamIndex]).VehicleLimit = VehicleLimit;
	Rx_TeamInfo(Teams[TeamIndex]).mineLimit = MineLimit;
	
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

function SetPlayerDefaults(Pawn PlayerPawn)
{
	if(Rx_Pri(PlayerPawn.PlayerReplicationInfo) != none)
	{ 
		Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.GetStartClass(PlayerPawn.GetTeamNum());
		`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PlayerPawn.PlayerReplicationInfo) `s "character" `s UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo).CharClassInfo);
		PlayerPawn.NotifyTeamChanged();
	}
	
	if(Rx_Bot(PlayerPawn.Controller) != None) 
	{
		if(PurchaseSystem.AirTower != None) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = Rx_Bot(PlayerPawn.Controller).BotBuy(Rx_Bot(PlayerPawn.Controller), true);
		} else if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_GDI) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.GDIInfantryClasses[Rand(15)];
			`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PlayerPawn.PlayerReplicationInfo) `s "character" `s UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo).CharClassInfo);
		} else if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_NOD) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.NodInfantryClasses[Rand(15)];
			`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PlayerPawn.PlayerReplicationInfo) `s "character" `s UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo).CharClassInfo);
		}
		//Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = class'Rx_FamilyInfo_Nod_StealthBlackHand';
		//Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = class'Rx_FamilyInfo_Nod_RocketSoldier';
		PlayerPawn.NotifyTeamChanged();
	} else if(Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap)
	{
		if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_GDI) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.GDIInfantryClasses[Rand(15)];
		} else if(PlayerPawn.PlayerReplicationInfo.GetTeamNum() == TEAM_NOD) {
			Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = PurchaseSystem.NodInfantryClasses[Rand(15)];
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

// managed extra score for kills and destruction (only player and vehicles)
function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
	local Rx_PRI PlayerPRI;
	local string KillerLogStr;

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
		else if ( Rx_Pawn(KilledPawn) != None)
		{
			if (PlayerPRI != None)
			{
				if (KilledPlayer.GetTeamNum() != Killer.GetTeamNum() )
				{
					PlayerPRI.AddScoreToPlayerAndTeam(class<Rx_FamilyInfo>(Rx_Pawn(KilledPawn).CurrCharClassInfo).default.PointsForKill);
					Rx_TeamInfo(PlayerPRI.Team).AddKill();
					Rx_TeamInfo(KilledPlayer.PlayerReplicationInfo.Team).AddDeath();
				}
				if(Killer != KilledPlayer && PlayerController(Killer) != none) 
				{
					PlayerController(Killer).ClientPlaySound(BoinkSound);
				}
			}

			if (Killer != KilledPlayer)
				RxLog("GAME"`s "Death;"`s "player"`s `PlayerLog(KilledPlayer.PlayerReplicationInfo)`s "by"`s KillerLogStr `s "with"`s damageType);
			else
				RxLog("GAME"`s "Death;"`s "player"`s KillerLogStr`s "suicide by"`s damageType);
		}
	}
	else if (Rx_PRI(KilledPlayer.PlayerReplicationInfo) != None)    // ignore ai being destroyed (notably harvester death due to refinery lost)
	{
		`SupressNullDamageType(RxLog("GAME"`s "Death;"`s "player"`s `PlayerLog(KilledPlayer.PlayerReplicationInfo)`s "died by"`s damageType));
	}
	
	super.Killed(Killer,KilledPlayer,KilledPawn,damageType);

	ScoreRenKill(Killer,KilledPlayer);
}

function ScoreRenKill(Controller Killer, Controller Other)
{
	if ( Killer != None && killer.PlayerReplicationInfo != None && Rx_PRI(killer.PlayerReplicationInfo) != None &&
		 Other != None && Other.PlayerReplicationInfo != None && Rx_PRI(Other.PlayerReplicationInfo) != None && Killer != Other)
	{
		Rx_PRI(Killer.PlayerReplicationInfo).AddRenKill(,!Other.bIsPlayer);
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
		`LogRxPub("GAME" `s "Spawn;" `s "bot" `s `PlayerLog(bot.PlayerReplicationInfo));
	return bot;
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
	return false;
}

function CheckBuildingsDestroyed(Actor destroyedBuilding)
{
	local BuildingCheck Check;
	local PlayerReplicationInfo pri;
	
	if( Role == ROLE_Authority )
	{
		Check = CheckBuildings();
		if ( Check == BC_GDIDestroyed || Check == BC_NodDestroyed || Check == BC_TeamsHaveNoBuildings )
		{
			if(Check == BC_GDIDestroyed)
				EndRxGame("Buildings",TEAM_NOD);
			else if(Check == BC_NodDestroyed)
				EndRxGame("Buildings",TEAM_GDI); 	
			else 
				EndRxGame("Buildings",255);
		}
		
		if(Rx_Building_AirTower_Internals(destroyedBuilding) != None)
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
		else if(Rx_Building_WeaponsFactory_Internals(destroyedBuilding) != None)
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
		//`log("################################ -( MatchOver:BeginState() )-");
		RenEndTime = WorldInfo.RealTimeSeconds + EndGameDelay;
		`log("RenEndTime: " $ RenEndTime);
		//M.Palko endgame crash track log.
		`log("------------------------------Now in state: MatchOver");
		UTGameReplicationInfo(GameReplicationInfo).bMatchIsOver = true;
		//M.Palko endgame crash track log.
		`log("------------------------------Game rep info bMatchIsOver set to true");
		super.BeginState(PreviousState);
	}


	function RestartGame()
	{
		if( RenEndTime < WorldInfo.RealTimeSeconds )
		{			
			super(GameInfo).RestartGame();
		}
	}
}

function RestartGame()
{
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
			TeamCredits[TEAM_GDI].Refinery = ref;
		}
		else if (ref.GetTeamNum() == TEAM_NOD ) // Nod
		{
			TeamCredits[TEAM_NOD].Refinery = ref;
		}
	}
}

function StartMatch()
{
	local Controller PC;
	
	if(!WorldInfo.IsPlayInEditor() && InStr(string(WorldInfo.GetPackageName()), "CNC-") < 0)
		return;
	
	RxLog("MAP" `s "Start;" `s GetPackageName());

	super.StartMatch();
	
	if(TeamCredits[TEAM_GDI].PlayerRI.Length > 0) {
		TeamCredits[TEAM_GDI].PlayerRI.Remove(0, TeamCredits[TEAM_GDI].PlayerRI.Length-1);
	}
	if(TeamCredits[TEAM_NOD].PlayerRI.Length > 0) {
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
	}
	
	if(!Rx_MapInfo(WorldInfo.GetMapInfo()).bIsDeathmatchMap)
		VehicleManager.SpawnInitialHarvesters();
	
}

function Rx_PurchaseSystem GetPurchaseSystem()
{
	return PurchaseSystem;
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
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
	// MPalko: This no longer calles Super(). Was extremely messy, so everything is done right here now.

	//M.Palko endgame crash track log.
	`log("------------------------------EndRxGame called, Reason: " @ Reason @ " Winning Team Num: " @ WinningTeamNum);
	
	
	// Make sure end game is a valid reason, and then verify the game is over.
	if ( ((Reason ~= "Buildings") || (Reason ~= "TimeLimit") || (Reason ~= "triggered")) && !bGameEnded) {
		// From super(), manualy integrated.
		bGameEnded = true;
		//EndTime = WorldInfo.RealTimeSeconds + EndTimeDelay;
		EndTime = 0;//WorldInfo.RealTimeSeconds + EndTimeDelay;
		EndLogging(Reason);

		// Allow replication to happen before reporting scores, stats, etc.
		// @Shahman: Ensure that the timer is longer than camera end game delay, otherwise the transition would not be as smooth.
		SetTimer( EndgameCamDelay + 0.5f,false,nameof(PerformEndGameHandling) );

		// Set winning team and endgame reason.
		WinnerTeamNum = WinningTeamNum;
		Rx_GRI(WorldInfo.GRI).WinnerTeamNum = WinnerTeamNum;

		if (WinnerTeamNum == 0 || WinnerTeamNum == 1)
			GameReplicationInfo.Winner = Teams[WinnerTeamNum];
		else
			GameReplicationInfo.Winner = none;

		if(Reason ~= "TimeLimit")
			Rx_GRI(WorldInfo.GRI).WinnerReason = "By Points";
		else if(Reason ~= "Buildings")
			Rx_GRI(WorldInfo.GRI).WinnerReason = "By Base Destruction";
		else 
			Rx_GRI(WorldInfo.GRI).WinnerReason = "triggered";

		// Set everyone's camera focus
		SetTimer(EndgameCamDelay,false,nameof(SetEndgameCam));

		// Send game result to RxLog
		if (WinningTeamNum == TEAM_GDI || WinningTeamNum == TEAM_NOD)
			RxLog("GAME"`s "MatchEnd;"`s "winner"`s GetTeamName(WinningTeamNum)`s  Reason `s"GDI="$Rx_TeamInfo(Teams[TEAM_GDI]).GetDisplayRenScore()`s"Nod="$Rx_TeamInfo(Teams[TEAM_NOD]).GetDisplayRenScore());
		else
			RxLog("GAME"`s "MatchEnd;"`s "tie"`s Reason `s"GDI="$Rx_TeamInfo(Teams[TEAM_GDI]).GetDisplayRenScore()`s"Nod="$Rx_TeamInfo(Teams[TEAM_NOD]).GetDisplayRenScore());

		// More than one player, and game was not ended prematurely, then send stats.
		if(NumPlayers > 0 && !(Reason ~= "triggered"))
			SendRxStats();

		//M.Palko endgame crash track log.
		`log("------------------------------Triggering game ended kismet events");

		// trigger any Kismet "Game Ended" events
		TriggerKismetGameEnded();

		//@Shahman: Match over state will be called after the camera transition has been made.
	}
}

function PerformEndGameHandling()
{
	//`log("################################ -( PerformEndGameHandling() )-");
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
	local Rx_Controller P;
	//`log("################################ -( SetRxEndGameFocus() )-");
	EndGameFocus = Focus;

	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;
	
	foreach WorldInfo.AllControllers(class'Rx_Controller', P)
	{
		P.GameHasEnded( EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
	
	//M.Palko endgame crash track log.
	`log("------------------------------Sending to match over state");

	// Finally, go to match over state...after 9 seconds delay
	//SetTimer(9.0, false, nameof(SetMatchOverState));
	GotoState('MatchOver');
	
}
private function SetMatchOverState()
{
	GotoState('MatchOver');
}

private function SendRxStats()
{
	local PlayerReplicationInfo pri;
	local string playerStats;

	if ( WorldInfo.NetMode != NM_DedicatedServer)
		return;

	/**
	ServiceBrowser.PostToService("perform0,op1,num1");
	if(WinnerTeamNum == TEAM_GDI)
		ServiceBrowser.PostToService("perform1,op1,num1");
	else
		ServiceBrowser.PostToService("perform2,op1,num1");
	*/	

	//M.Palko endgame crash track log.
	`log("------------------------------Posted to service");
				 	
	foreach WorldInfo.GRI.PRIArray(pri)
	{
		if(!pri.bIsInactive && !pri.bBot && getPlayerStatsStringFromPri(Rx_Pri(pri)) != "") 
		{
			playerStats = playerStats $ getPlayerStatsStringFromPri(Rx_Pri(pri));	
		}
		if (Rx_PRI(pri) != None)
			Rx_PRI(pri).OldRenScore = Rx_PRI(pri).GetRenScore();
	}
 	ServiceBrowser.SendPlayerStats(playerStats);

	//M.Palko endgame crash track log.
	`log("------------------------------Player stats sent");
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
	local Rx_Controller PC;


	//M.Palko endgame crash track log.
	`log("------------------------------Playing end of match message");

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		if (IsAWinner(PC))
		{
			if ( PC.GetTeamNum() == 0 )
			{
				PC.ClientPlayAnnouncement(VictoryMessageClass, 0); // GDI Win
			}
			else
			{
				PC.ClientPlayAnnouncement(VictoryMessageClass, 1); // Nod Win
			}
		}
		else
		{
			if ( PC.GetTeamNum() == 0 )
			{
				PC.ClientPlayAnnouncement(VictoryMessageClass, 2); // GDI Defeat
			}
			else
			{
				PC.ClientPlayAnnouncement(VictoryMessageClass, 3); // Nod Defeat
			}
		}
	}
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

function HandleServiceData(string Text)
{
	local int i,len;
	local array<string> Messages;

	ParseStringIntoArray(Text, Messages, "<@>", true);
	len = Messages.length;
	Messages[len - 1] = Left(Messages[len - 1],InStr(Messages[len - 1],"<form"));
	for(i = 1; i < len; i++)
		`Log("[GeminiLinkClient] Message " $ i $ ": " $ Messages[i]);
}

function HandleBannedIP(string BannedIP)
{
	local int len;
	local array<string> Messages;
	local PlayerReplicationInfo PRI;


	ParseStringIntoArray(BannedIP, Messages, "<@>", true);
	if(Messages.length < 2)
		return;
	
	len = Messages.length;
	Messages[len - 1] = Left(Messages[len - 1],InStr(Messages[len - 1],"<form"));
	
	BannedIP = Messages[1];
	
	if(BannedIP == "")
		return;
		
	if(InStr(BannedIP, "Dev") >= 0 || InStr(BannedIP, "::") >= 0)
	{
		Rx_BroadcastHandler(BroadcastHandler).Broadcast(None, BannedIP);
		return;
	}
		
	loginternal("Kick-Banned cause player is on global ban list: "$BannedIP);	
	Rx_AccessControl(AccessControl).BanIP(BannedIP);
	foreach GameReplicationInfo.PRIArray(PRI)
		if (PRI.SavedNetworkAddress == BannedIP)
		{
			AccessControl.KickPlayer(PlayerController(PRI.Owner), PRI.GetHumanReadableName() $" was kickbanned for cheating. Boink!");
			return;	
		}
}

function HandleServerData(string Text)
{
	local int i, leng, actualAdd;
	local array<string> Messages;
	local array<string> ServerParts;
	local array<string> DetailInfo;
	local string ServersIpString;

	actualAdd = 0;
	ServersIpString = "";
	ListServers.length = 0;
	ServerListRawData = ServerListRawData $ Text;
	
	//parse the data when the fetching is complete.
	if (Right(ServerListRawData, 7) == "</html>") {
		ParseStringIntoArray(ServerListRawData, Messages, "<@>", true);
		leng = Messages.length;
		Messages[leng - 1] = Left(Messages[leng - 1],InStr(Messages[leng - 1],"<form"));

		for(i = 1; i < (leng-1); i++)
		{
			//`Log("[GeminiLinkClient] Server " $ i $ ": " $ Messages[i]);
			ParseStringIntoArray(Messages[i], ServerParts, "~", false);
			ParseStringIntoArray(ServerParts[5], DetailInfo, ";", true);

			// only add if same version, else ignore
			//if (isSameVersion(DetailInfo[10], GameVersion))
			//if (DetailInfo.Find(GameVersion))
			//{
				actualAdd++;
				ServersIpString $= ServerParts[1]$"-"$(actualAdd-1)$",";
				ListServers.Add(1);
				ListServers[actualAdd-1].ServerName=ServerParts[0];
				ListServers[actualAdd-1].ServerIP=ServerParts[1];
				ListServers[actualAdd-1].ServerPort=ServerParts[2];
				ListServers[actualAdd-1].bPassword=bool(ServerParts[3]);
				//ListServers[i-1].Gametype=int(ServerParts[4]);
				ListServers[actualAdd-1].Mapname = ServerParts[4];
				ListServers[actualAdd-1].GameVersion = DetailInfo[10];
				ListServers[actualAdd-1].NumPlayers=int(ServerParts[6]);
				ListServers[actualAdd-1].MaxPlayers=int(ServerParts[7]);
				ListServers[actualAdd-1].Ranked=int(ServerParts[8]);
				ListServers[actualAdd-1].bInGame=bool(Left(ServerParts[9], 4));
			//
		}
		
		if (ListServers.Length > 0)
		{
			// start pinging async
			leng = Len(ServersIpString) - 1;
			ServersIpString = Left(ServersIpString, leng);
			VersionCheck.StartPingAll(ServersIpString);

			// start polling process for pings
			curIndPinged = 0;
			SetTimer(0.5f, false, 'PingServers');
		}
	}
}

function bool isSameVersion(string V1, string V2)
{
	return V1 ~= V2;
}

function PingServers()
{
	local string currentPingedIds;
	local array<string> finishedIds;
	local int i, leng;
	local int PingedId;

	if(curIndPinged >= ListServers.Length - 1)
	{
		ClearTimer('PingServers');
		curIndPinged = 0;
		return;
	}

	currentPingedIds = VersionCheck.GetPingedIDs();
	ParseStringIntoArray(currentPingedIds, finishedIds, ",", true);
	leng = finishedIds.Length;

	for(i = 0; i < leng; i++)
	{
		PingedId = Int(finishedIds[i]);
		ListServers[PingedId].Ping = VersionCheck.GetPingFor(ListServers[PingedId].ServerIP);
	}

	curIndPinged = VersionCheck.GetPingStatus() - 1;

	if (curIndPinged >= ListServers.Length - 1)
	{
		for(i = 0; i < ListServers.Length; i++)
		{
			if (ListServers[i].Ping <= 0)
				ListServers[i].Ping = VersionCheck.GetPingFor(ListServers[i].ServerIP);
		}
		NotifyPingFinished(curIndPinged);
	}

	SetTimer(0.1f, false, 'PingServers');
}

delegate NotifyPingFinished(int SrvIndex);

function RegisterPingFinished(delegate<NotifyPingFinished> MyNotifyDelegate)
{
	NotifyPingFinished = MyNotifyDelegate;
}

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
	local Actor a;

	super.GetSeamlessTravelActorList(bToEntry, ActorList);

	if (Rcon != None)
	{
		ActorList.AddItem(Rcon);
		foreach Rcon.Children(a)
			ActorList.AddItem(a);
	}
	if (RconCommands != None)
		ActorList.AddItem(RconCommands);
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
	ForEach AllActors(class'Rx_Building_Obelisk', Obelisk) {
		break;
	}
}

function SetAGT()
{
	ForEach AllActors(class'Rx_Building_AdvancedGuardTower', AGT) {
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
		 
	    if(Rx_Bot(NewPlayer).IsInBuilding()) {
	   		Rx_Bot(NewPlayer).setStrafingDisabled(true);	
	    }
	} else if(PlayerController(NewPlayer) != None) {
		RxHUD = Rx_Hud(PlayerController(NewPlayer).myHUD);
		if (WorldInfo.NetMode != NM_DedicatedServer && RxHUD != None)
			RxHUD.ClearPlayAreaAnnouncement();
		else
			Rx_Pawn(NewPlayer.Pawn).ClearPlayAreaAnnouncementClient();
	}
	if(TeamCredits[NewPlayer.GetTeamNum()].PlayerRI.Find(Rx_PRI(NewPlayer.PlayerReplicationInfo)) < 0) {
		TeamCredits[NewPlayer.GetTeamNum()].PlayerRI.AddItem(Rx_PRI(NewPlayer.PlayerReplicationInfo));
		Rx_PRI(NewPlayer.PlayerReplicationInfo).SetCredits( Rx_Game(WorldInfo.Game).InitialCredits ); 
	}	
}

/** Calling this advances the cycle and thus should not be called just to get the name of the next map, use GetNextMapInRotationName() */
function string GetNextMap()
{
	local int GameIndex;

	if (bFixedMapRotation)
	{
		GameIndex = class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', Class.Name);
		if (GameIndex != INDEX_NONE)
		{
			MapCycleIndex = GetNextMapInRotationIndex();
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

function VersionCheckComplete(bool OutOfDate)
{
	if (OutOfDate)
	{
		`warn("Game is out of date, visit www.Renegade-X.com to update.");
		// Do something here if our game is out of date.
		VersionCheck.NotifyDelegate();

	}
}

exec function CheckVersion ()
{
	VersionCheck.BroadcastVersion();
	VersionCheck.LogVersion();
}

exec function OpenDownloadLink ()
{
	VersionCheck.CloseGameAndOpenDownloadURL();
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

	if (bForceNonSeamless)
		bSeamless = false;
	else
		bSeamless = (bUseSeamlessTravel && WorldInfo.TimeSeconds < MaxSeamlessTravelServerTime);

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
	{
		RxLog("MAP"`s"Changing;"`s NextMap `s "seamless");
	}
	else
	{
		RxLog("MAP"`s"Changing;"`s NextMap `s "nonseamless");
		if (Rcon != None)
			Rcon.NotifyNonSeamless();
	}

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

/* RCON COMMANDS */

function string RconCommand(string CommandLine)
{
	local string command, parameters;
	local Rx_Rcon_Command cmd;
	//local string feedback;
	//local Rx_Mutator mut;

	if (InStr(CommandLine," ") >= 0)
	{
		command = Left(CommandLine,InStr(CommandLine," "));
		parameters = Split(CommandLine," ",true);
	}
	else
	{
		command = CommandLine;
		parameters = "";
	}
	command = Locs(command);
	
	// Check dynamic command list
	cmd = RconCommands.GetCommand(command);
	if (cmd != None)
		return cmd.trigger(parameters);

	// existing UDK/UT commands to block:
	if (RconCommands.IsBlockedCommand(command))
		return "Blocked ConsoleCommand";

	// Not a Rcon implemented command, try as ConsoleCommand.
	ConsoleCommand(CommandLine);
	return "Non-existent RconCommand - executed as ConsoleCommand";
}

DefaultProperties
{	
	EndgameCamDelay = 1.0f
	EndgameSoundDelay = 1.0f

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
	
	GameReplicationInfoClass   = class'Rx_GRI'

	BoinkSound				   = SoundCue'RX_SoundEffects.SFX.SC_Boink'
	

	MapPrefixes[0]                = "CNC"
	Acronym                       = "RxGame"

	NumBots						  = 0 
	NumPlayers					  = 0
	bPlayersVsBots				  = false	
	MineLimit					  = 30	
	
	/** class setup props */
	BotClass                      = class'RenX_Game.Rx_Bot'

	TeamAIType(0)                 = class'Rx_TeamAI'
	TeamAIType(1)                 = class'Rx_TeamAI'
	
	/** DefaultInventory */
	DefaultInventory(0)           = class'Rx_Weapon_AutoRifle_GDI'	
	
	bDelayedStart=true 
	bSkipPlaySound=true
	
	MaxPlayersAllowed			  = 40

	MapHistoryMax                 = 10       
	VotePersonalCooldown          = 60

	/**
	GameVersion = "Open Beta 1 RC" -> its in the config now
	*/
}
