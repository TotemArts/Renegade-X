class Rx_DeathMatch extends UTDeathmatch
	config(RenegadeX);

var class<UTHudBase>					HudClass;
var float								EndGameDelay;
var float								RenEndTime;
var int									MineLimit;
var int 							    VehicleLimit;
var	SoundCue							BoinkSound;
var class<Rx_VehicleManager>			VehicleManagerClass;
var Rx_VehicleManager                   VehicleManager;

var const array<class<Rx_FamilyInfo> >	InfantryClasses;

var Rx_AuthenticationService authenticationService;
var config bool bHostsAuthenticationService;

/** one1: Current vote in progress. */
var Rx_VoteMenuChoice GlobalVote;
var Rx_VoteMenuChoice GDIVote;
var Rx_VoteMenuChoice NODVote;
var float VotePersonalCooldown;
var float VoteTeamCooldown_GDI, VoteTeamCoolDown_Nod, NextChangeMapTime_GDI, NextChangeMapTime_Nod; 

var config bool bFixedMapRotation;

var globalconfig array<string> MapHistory; // In order of most recent (0 = Most Recent)
var int MapHistoryMax; // Max number of recently played maps to hold in memory

var config int RecentMapsToExclude;
var config int MaxMapVoteSize;

var int VPMilestones[3]; //Config
var int MaxInitialVeterancy; //Maximum veterancy you can be given at the beginning of a game
var float CurrentBuildingVPModifier; //Modifier based on number buildings currently destroyed. 1st building kill awards the least, and gradually rises with each kill

var const float EndgameCamDelay, EndgameSoundDelay;

/** Name of the class that manages maplists and map cycles */
var globalconfig string MapListManagerClassName;
var Rx_MapListManager MapListManager;

var int				                    MaxPlayerNameLength;
var array<string>                       DisallowedNames;

event PostLogin( PlayerController NewPlayer )
{
	`LogRx("PLAYER" `s "Enter;" `s `PlayerLog(NewPlayer.PlayerReplicationInfo) `s "from" `s NewPlayer.GetPlayerNetworkAddress() `s "hwid" `s Rx_Controller(NewPlayer).PlayerUUID);

	super.PostLogin(NewPlayer);
				
	Rx_Pri(NewPlayer.PlayerReplicationInfo).ReplicatedNetworkAddress = NewPlayer.PlayerReplicationInfo.SavedNetworkAddress;
	Rx_Controller(NewPlayer).RequestDeviceUUID();
		
	if(bDelayedStart) // we want bDelayedStart, but still want players to spawn immediatly upon connect
		RestartPlayer(newPlayer);		
	
	/**Needed anything that happened when a player first joined. If the team is using airdrops, it'll update them correctly **/	
}

function GenericPlayerInitialization(Controller C)
{
	HUDType = HudClass;
	super(GameInfo).GenericPlayerInitialization(C);
}	

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if ( Role == ROLE_Authority )
	{
		VehicleManager = spawn(VehicleManagerClass, self,'VehicleManager',Location,Rotation);
	}
	
	if(bHostsAuthenticationService) {
		authenticationService = Spawn(class'Rx_AuthenticationService');
	}

	MaxMapVoteSize = Clamp(MaxMapVoteSize, 1, 9);
	RecentMapsToExclude = Clamp(RecentMapsToExclude, 0, 8);
}

function Logout( Controller Exiting )
{
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
	`LogRx("PLAYER"`s "Exit;"`s `PlayerLog(Exiting.PlayerReplicationInfo));
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
	loginternal(ret);
	return ret;
}

event InitGame( string Options, out string ErrorMessage )
{	
	//local int MapIndex;

	super.InitGame(Options, ErrorMessage);
	DesiredPlayerCount = 1;

	AdjustedDifficulty = 5;
	
	if (WorldInfo.NetMode == NM_DedicatedServer) //Static limits on-line
	{
		MineLimit = Rx_MapInfo(WorldInfo.GetMapInfo()).MineLimit;
		VehicleLimit= Rx_MapInfo(WorldInfo.GetMapInfo()).VehicleLimit;
	}
	else if(WorldInfo.NetMode == NM_Standalone)
	{
		MineLimit = GetIntOption( Options, "MineLimit", MineLimit);
		VehicleLimit = GetIntOption( Options, "VehicleLimit", VehicleLimit);
		AddInitialBots();	
	}

	//InitialCredits = GetIntOption(Options, "StartingCredits", InitialCredits);
	
	// Initialize the maplist manager
	InitializeMapListManager();
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

function StartMatch()
{	
	`LogRx("MAP" `s "Start;" `s GetPackageName());

	super.StartMatch();
}

exec function QuickStart()
{
	StartMatch();
}

function RestartPlayer(Controller NewPlayer)
{
	local Rx_Hud RxHUD;

	local Rx_InventoryManager InvManager;
	local class<Rx_Weapon> WeaponClass;
	local int SelectedCharInt;
	local class<Rx_FamilyInfo> ChosenClass;

	SelectedCharInt = Rand(InfantryClasses.Length);
	`log("Rx_DeathMatch: SelectedCharInt=" $ SelectedCharInt);
	ChosenClass = InfantryClasses[SelectedCharInt];

	Rx_Pri(NewPlayer.PlayerReplicationInfo).CharClassInfo = ChosenClass;

	super.RestartPlayer(NewPlayer);


	if(Rx_Bot(NewPlayer) != None) {		 
	    if(Rx_Bot(NewPlayer).IsInBuilding()) {
	   		Rx_Bot(NewPlayer).setStrafingDisabled(true);	
	    }
	} else if(PlayerController(NewPlayer) != None) {
		RxHUD = Rx_Hud(PlayerController(NewPlayer).myHUD);
		if (WorldInfo.NetMode != NM_DedicatedServer && RxHUD != None)
			RxHUD.ClearPlayAreaAnnouncement();
		else
			Rx_Controller(NewPlayer).ClearPlayAreaAnnouncementClient();
		if(Rx_Controller(NewPlayer) != None)
			Rx_Controller(NewPlayer).RefillCooldownTime=0;	
	}

	InvManager = Rx_InventoryManager(newplayer.Pawn.InvManager);
	WeaponClass = class'Rx_Weapon_Pistol';

	InvManager.PrimaryWeapons.AddItem(WeaponClass);
	InvManager.SetCurrentWeapon(Rx_Weapon(InvManager.FindInventoryType(WeaponClass)));
}

function SetPlayerDefaults(Pawn PlayerPawn)
{
	if(Rx_Pri(PlayerPawn.PlayerReplicationInfo) != none)
	{ 	
		//Rx_Pri(PlayerPawn.PlayerReplicationInfo).CharClassInfo = ChosenClass;
		`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PlayerPawn.PlayerReplicationInfo) `s "character" `s UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo).CharClassInfo);
	}	
	
	super.SetPlayerDefaults(PlayerPawn);
}

/**
 * Returns the default pawn class for the specified controller,
 *
 * @param	C - controller to figure out pawn class for
 *
 * @return	default pawn class
 */
/*function class<Pawn> GetDefaultPlayerClass(Controller C)
{
	local int CharCount;
	local int SelectedCharInt;
	local class<Rx_FamilyInfo> ChosenClass;
	local class<pawn> ClassPawn;

	CharCount = PurchaseSystem.GDIInfantryClasses.Length + PurchaseSystem.NodInfantryClasses.Length;
	SelectedCharInt = Rand(CharCount);
	`log("Rx_DeathMatch: SelectedCharInt=" $ SelectedCharInt);
		
	if(SelectedCharInt > PurchaseSystem.GDIInfantryClasses.Length)
	{
		SelectedCharInt = SelectedCharInt - PurchaseSystem.GDIInfantryClasses.Length - 1;
		ChosenClass = PurchaseSystem.NodInfantryClasses[SelectedCharInt];
	} else {
		ChosenClass = PurchaseSystem.GDIInfantryClasses[SelectedCharInt];
	}

	`log("Rx_DeathMatch: Selected Class=" $ ChosenClass);

	//ClassPawn = ChosenClass;

	`log("Rx_DeathMatch: Returning Class<Pawn>=" $ ClassPawn);
	return ClassPawn;
}*/

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
	//bSpawnInTeamArea		   = true
	bFirstBlood                = true
	//Port 				       = 7777

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
	VehicleManagerClass        = class'Rx_VehicleManager'
	//CommanderControllerClass   = class'Rx_CommanderController'
	
	BoinkSound				   = SoundCue'RX_SoundEffects.SFX.SC_Boink'
	

	MapPrefixes[0]				= "DM"
	Acronym						= "RxDM"

	NumBots						= 0 
	NumPlayers					= 0
	bPlayersVsBots				= false	
	MineLimit					= 30
	VehicleLimit				= 8
	
	/** class setup props */
	BotClass                      = class'RenX_Game.Rx_Bot'
	
	/** DefaultInventory */
	DefaultInventory(0)           = class'Rx_Weapon_Pistol'	
	
	bDelayedStart=true 
	bSkipPlaySound=true
	
	MaxPlayersAllowed			  = 40

	MapHistoryMax                 = 10       
	VotePersonalCooldown          = 60
	VoteTeamCoolDown_GDI		  = 180
	VoteTeamCoolDown_Nod		  = 180
	
	//SurrenderDisabledTime		= 600
	//RTC_TimeLimit				= 20
	
	VPMilestones(0) = 100 //VP needed for Veteran 
	VPMilestones(1) = 300 //VP Needed for Elite
	VPMilestones(2) = 650 //VP Needed for Heroic
	/**
	GameVersion = "Open Beta 1 RC" -> its in the config now
	*/

	//PowerUpClasses.Add(class'Rx_Pickup_Ammo');
	MaxInitialVeterancy = 400
	CurrentBuildingVPModifier = 1.0
	
	//SurrenderLength = 600

	InfantryClasses[0]  = class'Rx_FamilyInfo_GDI_Soldier'	
	InfantryClasses[1]  = class'Rx_FamilyInfo_GDI_Shotgunner'
	InfantryClasses[2]  = class'Rx_FamilyInfo_GDI_Grenadier'
	InfantryClasses[3]  = class'Rx_FamilyInfo_GDI_Marksman'
	InfantryClasses[4]  = class'Rx_FamilyInfo_GDI_Engineer'
	InfantryClasses[5]  = class'Rx_FamilyInfo_GDI_Officer'
	InfantryClasses[6]  = class'Rx_FamilyInfo_GDI_RocketSoldier'
	InfantryClasses[7]  = class'Rx_FamilyInfo_GDI_McFarland'
	InfantryClasses[8]  = class'Rx_FamilyInfo_GDI_Deadeye'
	InfantryClasses[9]  = class'Rx_FamilyInfo_GDI_Gunner'
	InfantryClasses[10] = class'Rx_FamilyInfo_GDI_Patch'
	InfantryClasses[11] = class'Rx_FamilyInfo_GDI_Havoc'
	InfantryClasses[12] = class'Rx_FamilyInfo_GDI_Sydney'
	InfantryClasses[13] = class'Rx_FamilyInfo_GDI_Mobius'
	InfantryClasses[14] = class'Rx_FamilyInfo_GDI_Hotwire'
	InfantryClasses[15]  = class'Rx_FamilyInfo_Nod_Soldier'
	InfantryClasses[16]  = class'Rx_FamilyInfo_Nod_Shotgunner'
	InfantryClasses[17]  = class'Rx_FamilyInfo_Nod_FlameTrooper'
	InfantryClasses[18]  = class'Rx_FamilyInfo_Nod_Marksman'
	InfantryClasses[19]  = class'Rx_FamilyInfo_Nod_Engineer'
	InfantryClasses[20]  = class'Rx_FamilyInfo_Nod_Officer'
	InfantryClasses[21]  = class'Rx_FamilyInfo_Nod_RocketSoldier'	
	InfantryClasses[22]  = class'Rx_FamilyInfo_Nod_ChemicalTrooper'
	InfantryClasses[23]  = class'Rx_FamilyInfo_Nod_blackhandsniper'
	InfantryClasses[24]  = class'Rx_FamilyInfo_Nod_Stealthblackhand'
	InfantryClasses[25] = class'Rx_FamilyInfo_Nod_LaserChainGunner'
	InfantryClasses[26] = class'Rx_FamilyInfo_Nod_Sakura'		
	InfantryClasses[27] = class'Rx_FamilyInfo_Nod_Raveshaw'
	InfantryClasses[28] = class'Rx_FamilyInfo_Nod_Mendoza'
	InfantryClasses[29] = class'Rx_FamilyInfo_Nod_Technician'
}
