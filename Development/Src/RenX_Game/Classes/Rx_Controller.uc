/**
 * RxController
 *
 *
 *
 *	TODO LIST - insert your todo lists here
 *	todo todo.... todo.... todo todo todo todo todooooooo~ tododo
 *
 *	HANDEPSILON : 
 *	- Clean up bot commanding functions to be called on Rx_TeamAI instead
 *	- More bot commands
 *
 *
 */
class Rx_Controller extends UTPlayerController
	dependson(Rx_InventoryManager)
	dependson(Rx_GameEngine);

enum CameraMode
{
    FirstPerson,
    ThirdPerson
};

enum DodgeDirections
{
	BACKWARD,
	LEFT,
	RIGHT,
	EMPTY
};

var bool bDebugging; 
var bool bIsFreeView; // whether player pressed and hold the freeview key
var Rotator FreeAimRot;
var bool InterruptWeaponSwap;
var PostProcessChain DamagePostProcessChain; //Damage vignette post-process chain effect
var array<PostProcessChain> OldPostProcessChain; //Previous post-process chain effect
var LocalPlayer OldPlayer;
var CameraAnim HealthCameraAnim;
var CameraMode camMode;
var bool bMoveForwardButtonPressed; 
var bool bCanOneClickDodge;
var bool bDodgeDirectionButtonPressed;
var DodgeDirections pressedDodgeDirection;
var bool bisAFK;			// HANDEPSILON - This indicates whether or not the player is AFK at the moment

//--------------Radio commands
var localized array<string> RadioCommandsText;
var() array<SoundCue>       RadioCommands;
var int                     numberOfRadioCommandsLastXSeconds;
var bool                    spotMessagesBlocked;
var bool					WhisperSpotMessagesBlocked;
var bool                    bSpotting;
var Rx_Vehicle              BoundVehicle;

var bool					bCanPlayEnemySpotted; 
var float					EnemySpotSndCooldown; //Cooldown on Enemy spotted sound (As it gets spammed a lot)

var bool bVehicleLockPressed;

var int     NameChanges;
var float   NextNameChangeTime;

/** one1: Vote related stuff. */
var string VoteCommandText;
var Rx_VoteMenuHandler VoteHandler;
var string VoteTopString;
var byte VotesYes;
var byte VotesNo;
var byte YesVotesNeeded;
var byte VotersTotal;
var byte VoteTimeLeft;

var float NextVoteTime;

var string DonateCommandText;
var string HowMuchCreditsString;

/** one1: death camera */
var vector DeathCameraOffset;

var int currentCharIndex; // temporary. only for testing characterswapping
var bool bIsInPurchaseTerminal;
var bool bIsInPurchaseTerminalVehicleSection;
var const float PTShortDelay;
var const float PTLongDelay;
var const float PTCooldownDelay;
var const int PTShortAccessMax; // amount of PT access you can have with only short cooldown.
var int PTAccessCount;
var bool bCanAccessPT;
var Rx_BuildingAttachment_PT PTUsed;
var class<Rx_GFxPurchaseMenu> PTMenuClass;
var Rx_GFxPurchaseMenu PTMenu;

var SoundCue                            TeamVictorySound[2];
var SoundCue                            TeamDefeatSound[2];
var SoundCue							WeaponSwitchSoundCue; 

var Rx_Pawn Pv;
var bool bJustExitedVehicle;
var bool bInVehicle;
var int MapVote;
var float NextChangeMapTime; //Used to prevent spamming of map votes in particular
var Rx_Bot RespondingBot; // bot that should respond to a command given by the player
var int ReplicatedHitIndicator;
var int CurrentClientHitIndicNumber;
var float LastDiedTime;
var Rx_AuthenticationClient authenticationClient;

var Rx_CameraActor ptPlayerCamera;
var bool bAllPawnsRelevant;
var bool bZoomed;

var const float EndgameScoreboardDelay;

//we could have our recorded purchase list here. 
var array < class <Rx_Weapon> > PreviousSidearmTransactionRecords;
var array < class <Rx_Weapon> > PreviousExplosiveTransactionRecords;
var class<Rx_Weapon> CurrentSidearmWeapon;
var class<Rx_Weapon> CurrentExplosiveWeapon;
var bool bJustBaughtEngineer; // in PT buying an engineer is a async call but the client has to continue instantly knowing he baught an engineer. so save that here
var bool bJustBaughtHavocSakura;
var int RefillCooldownTime;
var float MaxRespawnDelay;
var float TimeSecondsTillMaxRespawnTime;

var bool bHasChangedFocus;
// @Shahman: TODO: currently I am unable to get the current weapons in multiplayer.

var Actor EndGameActor;
var bool bMatchcountdownStarted;
var bool bTogglePost;
var float DesiredToneMapperScale;

var float CPCheckTime;

var int VehicleMessageInt;
var Controller LastKiller;
var bool bAuth;

var bool bDisplayingAirdropReadyMsg;
var int TempInt;

// Vars used for anti cheat:
var int LastClientpositionUpdates;
var vector ClientLocTemp;
var float ClientLocErrorDuration;

/** Rx_SoftLevelBoundaryVolume related variables */
var int PlayAreaLeaveDamageWaitCounter;
var int	PlayAreaLeaveDamageWait;
var bool IsInPlayArea;
var array<Rx_SoftLevelBoundaryVolume> BoundaryVolumes;
var Rx_SoftLevelBoundaryVolume LastLeftBoundary;
var float LastLeftBoundaryTime;

/*Used when changing to an SBH fails (Till something better is instated)*/
var vector Saved_Location;
var InventoryManager Saved_Inv;
var rotator Saved_Rotation;

/** Variables controlled by the DevBot */
var privatewrite repnotify bool bIsDev;
var privatewrite int ladder_rank;
var privatewrite string PlayerUUID;

var bool bHoldSprint;
var float LastSprintTime;
var bool bTauntMenuOpen; 
var bool bLockRotationToViewTarget; // for spectator mode

var float RespawnTimeModifier;
var vector LastHitLoc;
var float LastHitLocBlendPct;

/*Begin Commander Variables [in a severely less convoluted manner than the actual Commander Mod]*/

struct AttackTarget 
{
var Actor AT_Actor;
var Pawn AT_Pawn;
};

struct Spotted
{
	var string SpottedName;
	var int Amount;
	var byte Team;
	var bool bSpy;
};

var bool bFocusSpotting; 
var bool bCanFocusSpot;
//Types of orders commanders can give (Used sparingly, but helpful where it can be) 
enum CALL_TYPE 
{
	CT_ATTACK,
	CT_DEFEND,
	CT_WP1,
	CT_WP2,
	//CT_WP3 Maybe later
};

var bool bCommandSpotting, bCanCommandSpot; 
var Vector RepLocation1, RepLocation2, RepLocation3; //These could be arrays....... but that'd make sense
var int RepID1, RepID2, RepID3					;
var AttackTarget A_Target[3]; //Can have up to three ATTACK/DEFEND targets selected at any time
var CALL_TYPE Spotting_Mode; 
var Vector Potential_Waypoint;

var Rx_Hud_ObjectiveVisuals HudVisuals;
var Rx_ORI myORI; 
//var byte PlayerControlGroup; Possibly add in functionality to have squads. 
var float MaxCommanderSpottingRange; 


/*End Commander variables*/

var array<Rx_PRI> IgnoredPlayers;
var bool		  bSuspect; 
var bool		  bCanThrowSF_Flag; 
var int			  StartFire_FLAGs;
var int			  StartFiresThisSecond, LastStartFireTime;
var int			  LastHitSomethingTime;
 
struct K_Log
{
	var string KillInputs;  
	var int Hits, Shots, HeadShots ;
	var string KillString;
};

var K_Log K_Logs[5]; //Hold 5 
var byte Current_K_Log;  


//Comm Centre
var byte RadarVisibility, LastRadarVisibility; //Set radar visibility. 0: Invisible to all 1: visible to your team 2: visible to enemy team 

//Veterancy
var Rx_VeterancyMenu Vet_Menu;  //DEPRECATED FUNCTION; Remove soon 

//Player Game Stats 
var float Acc_Hits, Acc_Shots, Acc_HS; //Accuracy
var bool bCanTaunt; 

var string NodColor, GDIColor, HostColor, ArmourColor;

var Rx_CommanderMenuHandler Com_Menu;

var bool bQHeld; //For casting support powers. Was Q held long enough 
var bool bDisableBotOrdering;

var Rx_CommanderSupport_TargetingParticleSystem CommanderTargetingReticule; 

//Healing Related Variables//
var int	LastSupportHealTime;
var ByteArrayWrapper SSData;
var int SSDataChunksSent;
var int SSDataPending;
var bool SSDataRequested;
var PlayerReplicationInfo SSInvoker;

struct ByteBufferWrapper {
	var byte data[256];
};

//Buff/Debuff modifiers//

var repnotify float Misc_SpeedModifier; 

//Weapons
var float Misc_DamageBoostMod; 
var repnotify float Misc_RateOfFireMod;
var float Misc_ReloadSpeedMod;

//Survivablity
var float Misc_DamageResistanceMod;
var float Misc_RegenerationMod; 

var int MaxPlayers;

struct ActiveModifier
{
	var class<Rx_StatModifierInfo> ModInfo; 
	var float				EndTime; 
	var bool				Permanent; 
};

var array<ActiveModifier> ActiveModifications; 
var bool bJumpReleased; 
var bool bDodgePressed;
var bool bUseDoubleClickDodge; //Use legacy double-tap dodge (False by default )

replication
{
	// Things the server should send to the client.
	if ( bNetOwner && Role == ROLE_Authority && bNetDirty )
		ReplicatedHitIndicator, bDisableBotOrdering, bIsAFK;

	if (bNetDirty)
		VoteTopString, VotesYes, VotesNo, VoteTimeLeft, VotersTotal, bSuspect, YesVotesNeeded, bIsDev, bCanThrowSF_Flag, RefillCooldownTime, RadarVisibility,
		Misc_SpeedModifier, Misc_RateOfFireMod, Misc_ReloadSpeedMod, RespawnTimeModifier; //The ones the Client actually needs to know 
}

event ClearOnlineDelegates()
{
	`RxGameObject.ServiceBrowser.ClearDelegates();
	super.ClearOnlineDelegates();
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'Misc_SpeedModifier')
	{
		if(Rx_Pawn(Pawn) != none) Rx_Pawn(Pawn).UpdateRunSpeedNode(); 	 
		else
		if(Rx_Vehicle(Pawn) != none) 
		{
			Rx_Vehicle(Pawn).UpdateThrottleAndTorqueVars();
		}
	}
	else if(VarName == 'Misc_RateOfFireMod')
	{
		if(Rx_Pawn(Pawn) != none && Rx_Weapon(Pawn.Weapon) != none) 
			Rx_Weapon(Pawn.Weapon).SetROFChanged(true);	
		else if(Rx_Vehicle(Pawn) != none && Rx_Vehicle_Weapon(Pawn.Weapon) != none)
			Rx_Vehicle_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

exec function ToggleADSSens()
{
	Rx_PlayerInput(PlayerInput).ToggleADSSens();
}

function PlayHitMarkerSound(optional bool bIsHeadshot = false)
{
	if (bIsHeadshot)
		ClientPlaySound(SoundCue'RX_SoundEffects.HitMarker.SC_HitMarker_Headshot');
	else
		ClientPlaySound(SoundCue'RX_SoundEffects.HitMarker.SC_HitMarker_Body');
}

reliable client function RequestDeviceUUID()
{
	SetDeviceUUID(`RxEngineObject.HWID);
}

reliable server function SetDeviceUUID(string InUUID)
{
	if (PlayerUUID == "")
	{
		PlayerUUID = InUUID;
		`LogRx("PLAYER" `s "HWID;" `s "player" `s `PlayerLog(PlayerReplicationInfo) `s "hwid" `s InUUID);
	}
}

function OnEMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
{
	`logd("Player EMPd");
	Rx_PRI(PlayerReplicationInfo).AddEMPHit(); 
}

function OnEMPBleed(bool finish=false)
{

}

function SetRadarVisibility(byte Visibility)
{
	//`log("Controller set Pawn Radar Visibility" @ Visibility) ; 
	//scripttrace();
	RadarVisibility = Visibility; 
	
	if(isTimerActive('ResetRadarVisibility')) ClearTimer('ResetRadarVisibility');
	
	if(Rx_Pawn(Pawn) != none ) Rx_Pawn(Pawn).SetRadarVisibility(Visibility); 
	else
	if(Rx_Vehicle(Pawn) != none ) Rx_Vehicle(Pawn).SetRadarVisibility(Visibility); 
}

function SetSpottedRadarVisibility()
{
	LastRadarVisibility = RadarVisibility; 
	
	SetRadarVisibility(2); //Set full visible from spotting
	
	SetTimer(8.0,false, 'ResetRadarVisibility' ); //8 seconds just seems fair
}

function ResetRadarVisibility()
{
	SetRadarVisibility(LastRadarVisibility); 
}

function byte GetRadarVisibility()
{
	return RadarVisibility; 
}

reliable client function GetConsole();

function UpdateDiscordPresence(int InMaxPlayers) {
	local int elapsedTime,currentPlayers;
	local PlayerReplicationInfo aPRI;

	// Set MaxPlayers if provided
	if (InMaxPlayers != 0) {
		MaxPlayers = InMaxPlayers;
	}

	// If the match has begun, include elapsed time
	if (WorldInfo.GRI.bMatchHasBegun) {
		elapsedTime = WorldInfo.GRI.ElapsedTime;
	}

	ForEach WorldInfo.GRI.PRIArray(aPRI)
		if(Rx_PRI(aPRI) != None && !aPRI.bBot) // Remove sentinels and bots from the player count
			currentPlayers++;

	if(WorldInfo.IsPlayInEditor())
		`RxEngineObject.DllCore.UpdateDiscordRPC("Software Development Kit", WorldInfo.GetMapName(), currentPlayers, MaxPlayers, GetTeamNum(), elapsedTime, WorldInfo.GRI.RemainingTime);
	else
		`RxEngineObject.DllCore.UpdateDiscordRPC(WorldInfo.GRI.ServerName, WorldInfo.GetMapName(), currentPlayers, MaxPlayers, GetTeamNum(), elapsedTime, WorldInfo.GRI.RemainingTime);
}

reliable client function ClientUpdateDiscordPresence(int InMaxPlayers) {
	UpdateDiscordPresence(InMaxPlayers);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if(Worldinfo.NetMode != NM_DedicatedServer) {
		SetTimer(CPCheckTime,true,'CheckTouchingCapturePoints');
		//SetTimer(1.0,false,'CheckAuthentication');     
	}
	SetTimer(15.0f,true,'resetRadioCommandCountTimer');

	/**if(myORI == none)
		{
		SetTimer(0.01,true,'FindORI'); 
		}
		*/
		//Catch initial spawns for visibility on radar
	if(ROLE == ROLE_Authority)
	{
	SetTimer(0.05, false, 'CheckRadarVisibility');
	SetTimer(0.1,true,'CheckActiveModifiers'); 
	/**if(PlayerReplicationInfo != none) Rx_PRI(PlayerReplicationInfo).InitVP(
				Rx_Game(WorldInfo.Game).VPMilestones[0], 
				Rx_Game(WorldInfo.Game).VPMilestones[1], 
				Rx_Game(WorldInfo.Game).VPMilestones[2]);*/

	
				
	}
	
	/**
	if(InStr(string(WorldInfo.GetPackageName()), "CNC-Complex") == 0 && ((WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone)))
		SetTimer(0.2f,true,'AdjustHdrToneMappingScale');  
	*/
	
	if(Worldinfo.NetMode != NM_Standalone)
		ResetAFKTimer();
	
	UpdateDiscordPresence(0);
}

//exec function FogDensity()
//{}

/** Verify Console */
reliable client function VerCon()
{
	local Console PlayerConsole;
	local LocalPlayer LP;

	LP = LocalPlayer( Player );
	if( ( LP != None ) && ( LP.ViewportClient.ViewportConsole != None ) )
	{
		PlayerConsole = LocalPlayer( Player ).ViewportClient.ViewportConsole;
		if(Rx_Console(PlayerConsole) == none) ServerVerCon(false); 
	}
}

reliable server function ServerVerCon(bool Verdict)
{
	if(!Verdict) Rx_Game(Worldinfo.Game).RxConsFail(self); 
}

function ResetRxConsole();

simulated function CheckRadarVisibility()
{
	local Actor CommTower;
	local Rx_GRI GRI; 
	
	GRI = Rx_GRI(WorldInfo.GRI); 
	
		foreach GRI.TechBuildingArray(CommTower) {
			if(CommTower.isA('Rx_Building_CommCentre_Internals') == false)
				continue; 
			
			if(GetTeamNum() != 0 && GetTeamNum() != 1) {
				SetTimer(0.05, false, 'CheckRadarVisibility');
				return	;
			}
			
			if(CommTower.GetTeamNum() != TEAM_GDI && CommTower.GetTeamNum() != TEAM_NOD  ) 
				return; 

			if(CommTower.GetTeamNum() == GetTeamNum() ) 
				SetRadarVisibility(1);
			else if(CommTower.GetTeamNum() != GetTeamNum() )
				SetRadarVisibility(2);
			
		}
}


function Reset()
{
	super.Reset();
	LastKiller = None;
}	

simulated function CheckTouchingCapturePoints()
{
	local Rx_CapturePoint CP;

	if(Rx_HUD(myHUD) == None)
		return;
	
	if (Pawn != None)
	{
		foreach Pawn.TouchingActors(class'Rx_CapturePoint', CP)
		{
			if (CP.TryDisplayHUD(Pawn))
				return;
		}
	}
	Rx_HUD(myHUD).ClearCapturePoint();
}

event KickWarning()
{
	if ( WorldInfo.TimeSeconds - LastKickWarningTime > 1 )
	{
		ClientMessage("AFK WARNING - You are about to be kicked for being idle unless you show activity!");
		LastKickWarningTime = WorldInfo.TimeSeconds;
	}
}

reliable client function ClientWasKickedReason(string reason)
{
	ClientSetProgressMessage(PMT_ConnectionFailure, reason, "Kicked");
}

reliable client function ClientWasKicked()
{
	ClientSetProgressMessage(PMT_ConnectionFailure, "You were kicked from the server.", "Kicked");
}

/** Modified version of PlayerController::CleanupPawn. Replaces 'self' and 'DmgType_Suicided' with 'None' and 'DamageType' so that death messages on disconnect get suppressed. */
function CleanupPawn()
{
	local Vehicle	DrivenVehicle;
	local Pawn		Driver;

	if(Vet_Menu != none)
		{
			DestroyOldVetMenu(); //Kill Vet menu on death
		}
	
	if(Com_Menu != none)
		{
			DestroyOldComMenu(); //Kill Vet menu on death
		}
	
	// If its a vehicle, just destroy the driver, otherwise do the normal.
	DrivenVehicle = Vehicle(Pawn);
	if (DrivenVehicle != None)
	{
		Driver = DrivenVehicle.Driver;
		DrivenVehicle.DriverLeave(TRUE); // Force the driver out of the car
		if ( Driver != None )
		{
			Driver.Health = 0;
			Driver.Died(None, class'DamageType', Driver.Location);
		}
	}
	else if (Pawn != None)
	{
		Pawn.Health = 0;
		Pawn.Died(None, class'DamageType', Pawn.Location);
	}
}


/** one1: Donations. */
exec function DonateCredits(int playerID, float amount)
{
	ServerDonateCredits(playerID, amount);
}

exec function Donate(string PlayerName, int Credits)
{
	local PlayerReplicationInfo PRI;
	local string error;
	PRI = ParsePlayer(PlayerName, error);
	if (PRI != None)
		DonateCredits(PRI.PlayerID, Credits);
	else
		ClientMessage(error);
}	

reliable server function ServerDonateCredits(int playerID, float amount)
{
	local int i;

	if(Worldinfo.GRI.ElapsedTime < Rx_Game(Worldinfo.Game).DonationsDisabledTime)
	{
		ClientMessage("Donations are disallowed for the first " $ Rx_Game(Worldinfo.Game).DonationsDisabledTime $ " seconds.");	
		return;
	}

	if (amount < 0 || Rx_PRI(PlayerReplicationInfo).GetCredits() < amount) return; // not enough money
	else if (amount == 0) amount = Rx_PRI(PlayerReplicationInfo).GetCredits();

	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if (WorldInfo.GRI.PRIArray[i].PlayerID == playerID)
		{
			Rx_PRI(WorldInfo.GRI.PRIArray[i]).AddCredits(amount);
			Rx_PRI(PlayerReplicationInfo).RemoveCredits(amount);
			`LogRxPub("GAME" `s "Donated;" `s amount `s "to" `s `PlayerLog(WorldInfo.GRI.PRIArray[i]) `s "by" `s `PlayerLog(PlayerReplicationInfo));
			if (Rx_Controller(WorldInfo.GRI.PRIArray[i].Owner) != none)
			{
				Rx_Controller(WorldInfo.GRI.PRIArray[i].Owner).ClientMessage(PlayerReplicationInfo.PlayerName $ " donated you " $ amount $" credits.");
			}

			return;
		}
	}
}

exec function TeamDonate(int Credits)
{
	ServerTeamDonate(Credits);
}

reliable server function ServerTeamDonate(float Credits)
{
	
	if(Worldinfo.GRI.ElapsedTime < Rx_Game(Worldinfo.Game).DonationsDisabledTime)
	{
		ClientMessage("Donations are disallowed for the first " $ Rx_Game(Worldinfo.Game).DonationsDisabledTime $ " seconds.");		
		return;
	}
	
	if (Credits < 0 || Rx_PRI(PlayerReplicationInfo).GetCredits() < Credits) return; // not enough money
	else if (Credits == 0) Credits = Rx_PRI(PlayerReplicationInfo).GetCredits();

	Rx_Game(WorldInfo.Game).TeamDonate(self, Credits);
}

exec function VoteYes()
{
	ServerVoteYes();
}

exec function VoteNo()
{
	ServerVoteNo();
}

reliable server function ServerVoteYes()
{
	local Rx_Game RxG; 
	
	RxG = Rx_Game(WorldInfo.Game); 
	
	if (RxG.GlobalVote != none)
		RxG.GlobalVote.PlayerVoteYes(self);

	if (RxG.GDIVote != none && PlayerReplicationInfo.Team.TeamIndex == 0)
		RxG.GDIVote.PlayerVoteYes(self);
	else if (RxG.NODVote != none && PlayerReplicationInfo.Team.TeamIndex == 1)
		RxG.NODVote.PlayerVoteYes(self);
}

reliable server function ServerVoteNo()
{
	local Rx_Game RxG; 
	
	RxG = Rx_Game(WorldInfo.Game); 
	
	if (RxG.GlobalVote != none)
		RxG.GlobalVote.PlayerVoteNo(self);

	if (RxG.GDIVote != none && PlayerReplicationInfo.Team.TeamIndex == 0)
		RxG.GDIVote.PlayerVoteNo(self);
	else if (RxG.NODVote != none && PlayerReplicationInfo.Team.TeamIndex == 1)
		RxG.NODVote.PlayerVoteNo(self);
}

/** one1: Added function for enabling vote menu. */
function EnableVoteMenu(bool donate)
{
	if(Com_Menu != none) return; 
	// just in case, turn off previous one
	DisableVoteMenu(true);

	if (!donate && WorldInfo.TimeSeconds < NextVoteTime)
	{
		ClientMessage("You must wait"@ int(NextVoteTime - WorldInfo.TimeSeconds) @"more seconds before you can start another vote.");
		return;
	}

	if (donate) VoteHandler = new (self) class'Rx_CreditDonationHandler';
	else VoteHandler = new (self) class'Rx_VoteMenuHandler';
	VoteHandler.Enabled(self);
}
 



/** one1: Added function for enabling vote menu. */
function EnableVeterancyMenu()
{
	local bool inVehicle; 
	
	if(Vet_Menu != none) 
	{
		DestroyOldVetMenu() ;
		return; 
	}
	
	if(Rx_Vehicle(Pawn) != none ) inVehicle = true; 
	// just in case, turn off previous one
	//DestroyOldVetMenu();

	Vet_Menu = new (self) class'Rx_VeterancyMenu';
	Vet_Menu.Init(self, inVehicle);
}

/** one1: Added function for enabling commander menu. */
function EnableCommanderMenu()
{
	
	if(VoteHandler != none || Rx_GRI(WorldInfo.GRI).bEnableCommanders == false) return; 
	
	if(Com_Menu != none ) 
	{
		DestroyOldComMenu() ;
		return; 
	}

	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander", 'Red'); 
		return; 
	}
	
	Com_Menu = new (self) class'Rx_CommanderMenuHandler';
	Com_Menu.Enabled(self);
}

function BuyRank(byte Iterator, int Cost) 
{
	if(!CanPromote()) return; 
	ServerBuyRank(Iterator, Cost);	
}

reliable server function ServerBuyRank(byte Iterator,int Cost)
{
	local Rx_PRI PRI; 
	local Rx_Pawn P; 
	P=Rx_Pawn(Pawn);
	
	if(!CanPromote()) return; 
	
	PRI = Rx_PRI(PlayerReplicationInfo); 
	if(class<Rx_Vehicle>(Pawn.class) != none ) //Get vehicle vet cost and promote if criteria are met. 
	{
	 if(class<Rx_Vehicle>(Pawn.class).static.VerifyVPPrice(Iterator, Cost))  //client vehicle out of sync, update it.
		{
			PRI.AddVP(-Cost);  
			PromoteMe(Iterator+1); 
			ClientUpdateVPMenu(true); 
		}
		else
		{
			ClientUpdateVPMenu(false);
		}
		return; //Was vehicle. 
	}
	
	if(P.GetRxFamilyInfo().static.VerifyVPPrice(Iterator, Cost) )  //client vehicle out of sync, update it.
	{
		PRI.AddVP(-Cost);
		PromoteMe(Iterator+1);
		ClientUpdateVPMenu(true); 
	
	}
	else
	{
	
		ClientUpdateVPMenu(false);
		ClientUpdateVPCosts();
	}
}

reliable client function ClientUpdateVPCosts()
{
	local bool inVehicle;
	if(Rx_Vehicle(Pawn) != none ) inVehicle = true; 
	if(Vet_Menu != none) Vet_Menu.Init(self,inVehicle); //Get your shit together.
}

function bool CanVoteMapChange()
{
	if(WorldInfo.TimeSeconds < NextChangeMapTime ) 
	{
		ClientMessage("You must wait"@ int(NextChangeMapTime - WorldInfo.TimeSeconds) @"more seconds before you can start another MAP related vote.");
		return false; 
	}
	else
		return true; 
}

function bool CanVoteBots()
{
	return Rx_GRI(WorldInfo.GRI).bEnableBotVotes;
}

function bool CanSurrender()
{
	
if(Worldinfo.GRI.ElapsedTime < Rx_Game(Worldinfo.Game).SurrenderDisabledTime)		
		return false;
	else
		return true;
}
/** one1: Returns true if vote menu is enabled. */
function bool IsVoteMenuEnabled()
{
	if (VoteHandler != none) return true;
	else return false;
}

function bool IsCommanderMenuEnabled()
{
	if (Com_Menu != none) return true;
	else return false;
}

simulated function bool CanPromote()
{
	local Rx_Pawn P ; 
	local Rx_Vehicle V; 
	local string loc; 
	
	if(Rx_Pawn(Pawn) != none ) 
	{	
		P = Rx_Pawn(Pawn); 
		if(P.PawnInFriendlyBase(P.SpotLocation,P) )
			return true;
	}
	else if(Rx_Vehicle(Pawn) != none) 
	{
		V = Rx_Vehicle(Pawn);
		loc = V.GetPawnLocation(V); 
		if(V.PawnInFriendlyBase(loc,V) ) 
			return true;
	}
	
		return false; 
}

/** one1: Disables vote menu or go back 1 step. */
function DisableVoteMenu(optional bool Destroy = false)
{
	if(VoteHandler != none && Destroy) 
	{
		VoteHandler = none;
		return; 
	}
	
	if (VoteHandler != none && !Rx_HUD(myHUD).FlipPageBackward())  
	{
		if (VoteHandler.Disabled())
			VoteHandler = none;
	}
	Rx_HUD(myHUD).HudMovie.SideMenuVis(false);
}

function CancelCommandMenuSelection()
{
	if (Com_Menu != none)
	{
		Com_Menu.CancelSelection();
	}
}


reliable client function ClientUpdateVPMenu(bool Success)
{
	
	if(Vet_Menu != none )
	{
	switch (Success)
		{
		case true:
		
		ClientUpdateVPCosts();
		Vet_Menu.UpdateTileStatus() ;
		Vet_Menu.PeelOff(); 
		ClientPlaySound(Vet_Menu.Success_Snd);
		//KillVPMenu
		//DestroyOldVetMenu(); 
		break;
		
		case false:
		Vet_Menu.UpdateTileStatus() ;
		ClientPlaySound(Vet_Menu.Failed_Snd);
		
		break;
		
		}
	
	} 
	
}

function DestroyOldVetMenu()
{
	if(Vet_Menu != none)
	{
		//`log("Killed") ; 
		Vet_Menu.PeelOff(); 
		Vet_Menu = none; 
	}
}

function DestroyOldComMenu()
{
	if(Com_Menu != none)
	{
		Com_Menu = none; 
	}
	
	if(CommanderTargetingReticule != none)
	{
		CommanderTargetingReticule.LinkedController = none; 
		CommanderTargetingReticule = none; 
	}
}

/** one1: Overriden so that vote menu can get key input. */
exec function SwitchWeapon(byte T)
{
	if (VoteHandler != none) {
		VoteHandler.KeyPress(T);
	} 
	else 
	if(Vet_Menu != none && !Vet_Menu.bPeeling)
	{
		Vet_Menu.ParseInput(T);
		//`log("Vet input" @ T);
	}
	else if(Com_Menu != none)
	{
		Com_Menu.KeyPress(T);
	}	
	else if(bTauntMenuOpen && Rx_Pawn(Pawn) != none) 
	{
		if(T <= class<Rx_FamilyInfo>(Rx_PRI(PlayerReplicationInfo).CharClassInfo).default.PawnVoiceClass.default.TauntSounds.Length)
			PlayTaunt(T-1);
	}
	else if(bTauntMenuOpen && Rx_Vehicle(Pawn) != none) 
	{
		if(class<Rx_Vehicle>(Rx_PRI(PlayerReplicationInfo).GetPawnVehicleClass()).default.VehicleVoiceClass != none && T <= class<Rx_Vehicle>(Rx_PRI(PlayerReplicationInfo).GetPawnVehicleClass()).default.VehicleVoiceClass.default.TauntSounds.Length)
			PlayTaunt(T-1);
		else
			if(T <= class<Rx_FamilyInfo>(Rx_PRI(PlayerReplicationInfo).CharClassInfo).default.PawnVoiceClass.default.TauntSounds.Length)
			PlayTaunt(T-1);
		
	}
	else //&& Rx_Weapon(Pawn.Weapon).InventoryGroup != T
	if(!Rx_PlayerInput(PlayerInput).bRadio1Pressed && !Rx_PlayerInput(PlayerInput).bRadio0Pressed ) {
	super.SwitchWeapon(T);
	}
}

/** one1: Called from VoteMenuChoice objects, when vote is ready to be sent to server. */
function SendVote(class<Rx_VoteMenuChoice> VoteChoiceClass, string param, int t)
{
	ServerVote(VoteChoiceClass, param, t);
}

function UpdateVoteCooldown(class<Rx_VoteMenuChoice> VoteChoiceClass, out float NextMapChangeTime, float Cooldown) {
	local Rx_Game game;
	
	game = Rx_Game(WorldInfo.Game);
	
	if (game.NumPlayers > 1) {
		if(isMapRelatedVote(VoteChoiceClass)) {
			NextMapChangeTime = WorldInfo.TimeSeconds + Cooldown;
			UpdateMapOrSurrenderCooldown();
		}	
	
		NextVoteTime = WorldInfo.TimeSeconds + game.VotePersonalCooldown;
		UpdateClientVoteCooldown(game.VotePersonalCooldown);
	}
}

/** one1: Replicate vote to server. */
reliable server function ServerVote(class<Rx_VoteMenuChoice> VoteChoiceClass, string param, int t)
{
	local Rx_Game g;
	
	if (bServerMutedText)
	{
		ClientMessage("Vote rejected - you are muted from chat, including starting votes.");
		return;
	}
	
	g = Rx_Game(WorldInfo.Game);
	
	if (g.NumPlayers > 1) {
		if( (GetTeamNum() == 0 && (WorldInfo.TimeSeconds <  Rx_Game(WorldInfo.Game).NextChangeMapTime_GDI)) ||(GetTeamNum() == 1 && (WorldInfo.TimeSeconds <  Rx_Game(WorldInfo.Game).NextChangeMapTime_Nod)))	//NextChangeMapTime)
		{
		
			if(string(VoteChoiceClass) == "Rx_VoteMenuChoice_Surrender"
				|| string(VoteChoiceClass) == "Rx_VoteMenuChoice_ChangeMap"
				|| string(VoteChoiceClass) == "Rx_VoteMenuChoice_RestartMap") {
				//UpdateMapOrSurrenderCooldown();
				if(GetTeamNum() == 0)
					CTextMessage("Map-related Vote Rejected: Team Cooldown in Effect for" @ "[" $ (Rx_Game(WorldInfo.Game).NextChangeMapTime_GDI - WorldInfo.TimeSeconds) $ "]",,120);
				else
					CTextMessage("Map-related Vote Rejected: Team Cooldown in Effect for" @ "[" $ (Rx_Game(WorldInfo.Game).NextChangeMapTime_Nod - WorldInfo.TimeSeconds) $ "s]",,120);

				return;
			}
		}
	
		if (WorldInfo.TimeSeconds < NextVoteTime)
		{
			ClientMessage("Vote rejected - you've started one too recently.");
			return;
		}
	
		if(VoteChoiceClass == class'Rx_VoteMenuChoice_Surrender' && !CanSurrender()) 
		{
			CTextMessage("Surrender unlocks in " $ string(Rx_Game(Worldinfo.Game).SurrenderDisabledTime - Worldinfo.GRI.ElapsedTime) $ " seconds",'White', 45);
			return; 	
		}
	}
	
	if (g.GlobalVote != none)
	{
		// report that vote is already in progress...
		return;
	}
	
	if (t == -1)
	{
		// global vote
		if (g.GDIVote != none || g.NODVote != none)
		{
			// report, GDI or NOD vote already in progress
			return;
		}

		g.GlobalVote = new (self) VoteChoiceClass;
		g.GlobalVote.ServerInit(self, param, t);

		if(GetTeamNum() == TEAM_GDI) {
			UpdateVoteCooldown(VoteChoiceClass, g.NextChangeMapTime_GDI, g.VoteTeamCooldown_GDI);
		}
		else {
			UpdateVoteCooldown(VoteChoiceClass, g.NextChangeMapTime_Nod, g.VoteTeamCooldown_Nod);
		}
	}
	else if (t == 0)
	{
		if (g.GDIVote != none)
		{
			// report, GDI vote already in progress
			return;
		}

		g.GDIVote = new (self) VoteChoiceClass;
		g.GDIVote.ServerInit(self, param, t);
		UpdateVoteCooldown(VoteChoiceClass, g.NextChangeMapTime_GDI, g.VoteTeamCooldown_GDI);
	}
	else if (t == 1)
	{
		if (g.NODVote != none)
		{
			// report, NOD vote already in progress
			return;
		}

		g.NODVote = new (self) VoteChoiceClass;
		g.NODVote.ServerInit(self, param, t);
		UpdateVoteCooldown(VoteChoiceClass, g.NextChangeMapTime_Nod, g.VoteTeamCooldown_Nod);
	}
}

function bool isMapRelatedVote(coerce string VType)	{
	return VType == "Rx_VoteMenuChoice_Surrender"
		|| VType == "Rx_VoteMenuChoice_ChangeMap"
		|| VType == "Rx_VoteMenuChoice_RestartMap";
}

reliable client function UpdateClientVoteCooldown(float cooldown)
{
	NextVoteTime = WorldInfo.TimeSeconds + cooldown;
}

function UpdateMapOrSurrenderCooldown()
{
	
	NextChangeMapTime = (WorldInfo.TimeSeconds + Rx_Game(WorldInfo.Game).VotePersonalCooldown*5) ; //At least 5 minutes between surrender votes by one player. 
	//Rx_Game(WorldInfo.Game).NextChangeMapTime = (WorldInfo.TimeSeconds + Rx_Game(WorldInfo.Game).VoteTeamCooldown*3) ; //Three minutes between teams voting for surrender/ChangeMap
	UpdateClientMapOrSurrenderCooldown(Rx_Game(WorldInfo.Game).VotePersonalCooldown);
}

reliable client function UpdateClientMapOrSurrenderCooldown(float cooldown)
{
	NextChangeMapTime = (WorldInfo.TimeSeconds + 5*cooldown);
}

/** one1: Console input for vote choices. */
function ShowVoteMenuConsole(string Text)
{
	StartTyping(Text);
}

/** one1: Vote specific exec functions. */
exec function Amount(string text) { VoteSpecificConsoleCommand(text); }
exec function Survey(string text) { VoteSpecificConsoleCommand(text); }
exec function PlayerID(string text) { VoteSpecificConsoleCommand(text); }
exec function How(string text) { VoteSpecificConsoleCommand(text); }

function VoteSpecificConsoleCommand(string text)
{
	if (VoteHandler == none) return;
	if (VoteHandler.VoteChoice == none) return;
	VoteHandler.VoteChoice.InputFromConsole(text);
}

/* Temporary Moderator Stuff. */

reliable server function ServerAdminLogin(string Password)
{
	if ( (WorldInfo.Game.AccessControl != none) && AdminCmdOk() )
	{
		if ( WorldInfo.Game.AccessControl.AdminLogin(self, Password) )
		{
			if (Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
				Rx_AccessControl(WorldInfo.Game.AccessControl).ModEntered(Self);
			else
				WorldInfo.Game.AccessControl.AdminEntered(Self);
		}
	}
}

reliable server function ServerAdminLogOut()
{
	local bool wasMod;
	if ( WorldInfo.Game.AccessControl != none )
	{
		wasMod = Rx_PRI(PlayerReplicationInfo).bModeratorOnly;
		if ( WorldInfo.Game.AccessControl.AdminLogOut(self) )
		{
			if (wasMod)
				Rx_AccessControl(WorldInfo.Game.AccessControl).ModExited(Self);
			else
				WorldInfo.Game.AccessControl.AdminExited(Self);
		}
	}
}

exec function Admin( string CommandLine )
{
	AdminRcon(CommandLine);
}

exec function AdminRcon(string CommandLine)
{
	if (WorldInfo.NetMode == NM_StandAlone)
		ClientMessage(Repl(`RxEngineObject.RconCommand(CommandLine), `rcon_delim, " ", true));
	else if (PlayerReplicationInfo.bAdmin && !Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
		ServerAdminRcon(CommandLine);
	else if (Left(CommandLine, 6) ~= "login ")
		AdminLogin(Mid(CommandLine, 6));
	else
		ClientMessage("Error: You are not an administrator.");
}

reliable server function ServerAdminRcon( string CommandLine )
{
	if (PlayerReplicationInfo.bAdmin && !Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
	{
		`LogRx("ADMIN"`s "Rcon;"`s `PlayerLog(PlayerReplicationInfo) `s"executed:"`s CommandLine);
		ClientMessage(Repl(`RxEngineObject.RconCommand(CommandLine), `rcon_delim, " ", true));
	}
}

exec function AdminAddAdministrator(string target)
{
	local PlayerReplicationInfo PRI;
	local string error;

	PRI = ParsePlayer(target, error);
	if (PRI != None)
		ServerAddAdmin(PRI.PlayerID, false);
	else
		ClientMessage(error);
}

exec function AdminAddModerator(string target)
{
	local PlayerReplicationInfo PRI;
	local string error;

	PRI = ParsePlayer(target, error);
	if (PRI != None)
		ServerAddAdmin(PRI.PlayerID, true);
	else
		ClientMessage(error);
}

reliable server function ServerAddAdmin(int PlayerID, bool AsModerator)
{
	if (PlayerReplicationInfo.bAdmin && !Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
		Rx_AccessControl(WorldInfo.Game.AccessControl).AddAdmin(self, Rx_Game(WorldInfo.Game).FindPlayerByID(PlayerID), AsModerator);
}

exec function AdminClientList()
{
	ServerClientList();
}

reliable server function ServerClientList()
{
	local string msg, s;
	local Array<string> list;
	if (PlayerReplicationInfo.bAdmin)
	{
		//ClientMessage( "PlayerID, IP, SteamID, Team, Name:\n" $ Rx_Game(WorldInfo.Game).ClientList() );
		list = Rx_Game(WorldInfo.Game).BuildClientList("  ");
		msg = "PlayerID, IP, SteamID, Admin, Team, Name:\n";
		foreach list(s)
			msg $= s$"\n";
		ClientMessage(msg);
	}
}

/* End of Moderator stuffs. */

// For Clients, use Rx_Game::ParsePlayer as server. ANY CHANGES HERE SHOULD BE MADE TO THE RX_GAME FUNCTION AS WELL.
function Rx_PRI ParsePlayer(String in, optional out string Error)
{
	//local int id;
	local string temp;
	local int id;
	local Rx_PRI PRI, Match;
	local int matches;

	// If the first chars are pid, then try to parse by player id.
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
				foreach DynamicActors(class'Rx_PRI', PRI)
					if (PRI.PlayerID == id)
						return PRI;
			}
		}
	}
	

	// Failed to find by ID, Attempt to find by Name
	temp = Caps(in); // make case insensitive
	foreach DynamicActors(class'Rx_PRI', PRI)
	{
		if (InStr(Caps(PRI.PlayerName), temp) != -1)
		{
			++matches;
			Match = PRI;
			
			if (Caps(Match.PlayerName) == temp)
				return Match; // Exact match by name
		}
	}
	
	if (matches > 1)
	{
		// Multiple matches by name
		Error = "Multiple player matches on \""$in$"\", please be more specific.";
		return None;
	}
	
	if (Match != None)
		return Match; // We found one match by name.
	
	Error = "No player matches on \""$in$"\" found.";
	return None;
}

function StartTyping(string Text) {
	local LocalPlayer LP;

	LP = LocalPlayer(Player);
	if(LP != None && LP.ViewportClient.ViewportConsole != None) {
		LP.ViewportClient.ViewportConsole.StartTyping(Text);
	}
}

exec function StartDotCommand()
{
	if (WorldInfo.GRI.bMatchIsOver)
		return;
	else
		StartTyping(".");
}

exec function StartSlashCommand() {
	StartTyping("/");
}

exec function PrivateSay(String Recipient, String Message)
{
	local PlayerReplicationInfo PRI;
	local string error;
	PRI = ParsePlayer(Recipient, error);
	if (PRI != None)
		PrivateMessage(PRI.PlayerID, Message);
	else
		ClientMessage(error);
}


exec function PrivateTalk()
{
	StartTyping("PrivateSay ");
}

exec function PrivateMessage(int PlayerID, String Msg)
{
	ServerPrivateMessage(PlayerID, Msg);
}

unreliable server function ServerPrivateMessage(int PlayerID, String Msg)
{
	if (Len(Msg) > 0)
	{
		Msg = Left(Msg,128);
		
		if (AllowTextMessage(Msg))
		{
			LastActiveTime = WorldInfo.TimeSeconds;

			//if (!bServerMutedText)
			//{
			Rx_Game(WorldInfo.Game).SendPM(self, PlayerID, Msg);
			//}
		}
	}
}

/** Copy of PlayerController::TeamMessage(...) with PMing supported added. */
reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
	local bool bIsUserCreated;
	local string from;

	if( CanCommunicate() )
	{
		if (PRI != None)
		{
			if (IgnoredPlayers.Find(Rx_PRI(PRI)) >= 0)
				return;
				
			from = PRI.PlayerName;
		}
		else
			from = "Host";

		if( ( ( Type == 'Say' ) || (Type == 'TeamSay' ) ) && ( PRI != None ) && AllowTTSMessageFrom( PRI ) )
		{
			if( !bIsUserCreated || ( bIsUserCreated && CanViewUserCreatedContent() ) )
			{
				SpeakTTS( S, PRI );
			}
		}

		if( myHUD != None )
		{
			myHUD.Message( PRI, S, Type, MsgLifeTime );
		}

		if( Type == 'Say' || Type == 'TeamSay' )
		{
			S = from$": "$S;
			// This came from a user so flag as user created
			bIsUserCreated = true;
		}
		else if ( Type == 'PM')
		{
			S = "Private from"@from$": "$S;
			if (PRI != None)
				bIsUserCreated = true;
		}
		else if ( Type == 'PM_Loopback')
		{
			S = "Private to"@from$": "$S;
			bIsUserCreated = true;
		}

		// since this is on the client, we can assume that if Player exists, it is a LocalPlayer
		if( Player != None )
		{
			// Don't allow this if the parental controls block it
			if( !bIsUserCreated || ( bIsUserCreated && CanViewUserCreatedContent() ) )
			{
				LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( S );
			}
		}
	}
}

//Sends a fancy little message to the upper/middle portion of the client's screen. :Yosh  -- EDIT: Cleaned up this ugly SOB
reliable client function CTextMessage(string TEXT, optional name Colour = 'White', optional float TIME = 60.0, optional float Size = 1.0, optional bool bIsCommandMessage, optional bool bWarning)
{
	local color ColorToUse;

		switch(Colour)
		{
			case 'White':
			ColorToUse=MakeColor(255,255,255,255);
			break;
			case 'Red':
			ColorToUse=MakeColor(255,0,0,255);
			break;
			case 'Green':
			ColorToUse=MakeColor(0,255,0,255);
			break;
			case 'LightGreen':
			ColorToUse=MakeColor(100,255,50,255);
			break;
			case 'Blue':
			ColorToUse=MakeColor(0,0,255,255);
			break;
			case 'LightBlue':
			ColorToUse=MakeColor(50,255,255,255);
			break;
			case 'Pink':
			ColorToUse=MakeColor(255,85,140,255);
			break;
			case 'Yellow':
			ColorToUse=MakeColor(255,255,0,255);
			break;
			case 'Orange':
			ColorToUse=MakeColor(255,200,120, 255);
			break;
			default:
			ColorToUse=MakeColor(255,255,255,255);
			break;
		}	
		
	

	if( myHUD != None )
	{
		
		Rx_HUD(myHUD).CommandText.SetFlashText(TEXT,ColorToUse, Time, Size, bIsCommandMessage, bWarning);
	}
	// since this is on the client, we can assume that if Player exists, it is a LocalPlayer
	if( Player != None )
	{
		LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( TEXT );
	}
}

// These two functions are from PlayerController, added in here again because they are private,
// thus couldn't be called from the Copy Paste TeamMessage function above.
simulated private function bool CanCommunicate()
{
	return TRUE;
}
simulated private function bool AllowTTSMessageFrom( PlayerReplicationInfo PRI )
{
	return TRUE;
}

/** Improved PlayerList for RenX, shows Team and does not display Sentinels. */
exec function PlayerList()
{
	local Rx_PRI PRI;
	local string Msg;

	ClientMessage("PlayerID  Name  Team  Ping");
	foreach DynamicActors(class'Rx_PRI', PRI)
	{
		if(Rx_Bot_Scripted(PRI.Owner) != None)		//Handepilon - Don't count the scripted bots
			continue;

		Msg = PRI.PlayerID$"  "$PRI.PlayerName $"  "$ class'Rx_Game'.static.GetTeamName(PRI.Team.TeamIndex) $"  ";
		if (PRI.bBot)
			Msg = Msg$"BOT";
		else
			Msg = Msg$ INT((float(PRI.Ping) / 250.0 * 1000.0));
		ClientMessage(Msg);
	}
}

/** one1: Added functions for locking input methods (airstrike) */
function AirstrikeLock()
{
	//IgnoreMoveInput(true);
	IgnoreLookInput(true);
	Rx_PlayerInput(PlayerInput).AirstrikeLock = true;
}

function AirstrikeUnlock()
{
	//IgnoreMoveInput(false);
	IgnoreLookInput(false);
	Rx_PlayerInput(PlayerInput).AirstrikeLock = false;
}

/** one1: called from PlayerInput, forward to Rx_Weapon_Airstrike class. */
function AdjustAirstrikeRotation(float X, float Y)
{
	local Rx_Weapon_Airstrike aw;

	aw = Rx_Weapon_Airstrike(Pawn.Weapon);
	if (aw == none) return;

	aw.AdjustRotation(X, Y);
}

/** one1: Added test functions for modifying inventory. Delete them before game release! */
function SetPrimaryWeapon(class<Rx_Weapon> classname)
{
		ServerSetPrimaryWeapon(classname);
}

reliable server function ServerSetPrimaryWeapon(class<Rx_Weapon> classname)
{
	local Rx_InventoryManager invmngr;
	local array<class<Rx_Weapon> > wclasses;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	// check if primary weapon is allowed
	if (!invmngr.IsPrimaryWeaponAllowed(classname)) return;

	// get current primary weapons
	wclasses = invmngr.GetWeaponsOfClassification(CLASS_PRIMARY);

	// check number of slots for primary weapon
	if (invmngr.GetPrimaryWeaponSlots() == wclasses.Length)
	{
		// we have to replace one weapon
		invmngr.RemoveWeaponOfClass(wclasses[wclasses.Length - 1]);
	}

	// add requested weapon
	invmngr.AddWeaponOfClass(classname, CLASS_PRIMARY);
}

function SetSecondaryWeapon(class<Rx_Weapon> classname)
{
		ServerSetSecondaryWeapon(classname);
}

reliable server function ServerSetSecondaryWeapon(class<Rx_Weapon> classname)
{
	local Rx_InventoryManager invmngr;
	local array<class<Rx_Weapon> > wclasses;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	if (!invmngr.IsSecondaryWeaponAllowed(classname)) return;
	wclasses = invmngr.GetWeaponsOfClassification(CLASS_SECONDARY);
	if (invmngr.GetSecondaryWeaponSlots() == wclasses.Length)
	{
		invmngr.RemoveWeaponOfClass(wclasses[wclasses.Length - 1]);
	}

	// add requested weapon
	invmngr.AddWeaponOfClass(classname, CLASS_SECONDARY);
}

function SetItem(class<Rx_Weapon> classname)
{
		ServerSetItem(classname);
}

function bool IsEquiped(class<Rx_weapon> weap, optional Rx_InventoryManager.EClassification Classification)
{
	local Rx_InventoryManager invmngr;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	
	if (invmngr == none)
		return false;

	return invmngr.IsEquiped(weap, Classification);
}

reliable server function ServerSetItem(class<Rx_Weapon> classname)
{
	local Rx_InventoryManager invmngr;
	local array<class<Rx_Weapon> > wclasses;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	if (!invmngr.IsItemAllowed(classname)) return;
	wclasses = invmngr.GetWeaponsOfClassification(CLASS_ITEM);
	if (invmngr.GetItemSlots() == wclasses.Length)
		invmngr.RemoveWeaponOfClass(wclasses[wclasses.Length - 1]);

	// add requested weapon
	invmngr.AddWeaponOfClass(classname, CLASS_ITEM);
}

reliable client function SetAdvEngineerExplosives(class<Rx_Weapon> classname)
{
	local byte i;
	local Rx_InventoryManager invmngr;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	
	for (i=0; i < invmngr.PrimaryWeapons.Length; i++) {
		// `log("CLIENT invmngr.PrimaryWeapons[" $ i $ "]" $ invmngr.PrimaryWeapons[i]);
		if (invmngr.PrimaryWeapons[i] != class'Rx_Weapon_Grenade' 
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ProxyC4'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_EMPGrenade'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ATMine'){
			continue;
		}
		invmngr.RemoveWeaponOfClass(invmngr.PrimaryWeapons[i]);
	}

		`log("#### classname " $ classname);
	CurrentExplosiveWeapon = classname; 
	ServerSetAdvEngineerExplosives(classname);
}

reliable server function ServerSetAdvEngineerExplosives(class<Rx_Weapon> classname)
{
	local Rx_InventoryManager invmngr;
	// local int removeSlotIndex;
	local byte i;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	// check if allowed
	//if (!invmngr.IsSidearmWeaponAllowed(classname)) return;

	// remove hotwire's or technician's 'explosives' if we do own the following

	for (i=0; i < invmngr.PrimaryWeapons.Length; i++) {
		// `log("SERVER invmngr.PrimaryWeapons[" $ i $ "]" $ invmngr.PrimaryWeapons[i]);
		if (invmngr.PrimaryWeapons[i] != class'Rx_Weapon_Grenade' 
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ProxyC4'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_EMPGrenade'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ATMine'){
			continue;
		}
		invmngr.RemoveWeaponOfClass(invmngr.PrimaryWeapons[i]);
	}

// 	removeSlotIndex = invmngr.PrimaryWeapons.Find(class'Rx_Weapon_ProxyC4');
// 	if (removeSlotIndex != -1) {
// 		invmngr.RemoveWeaponOfClass(invmngr.PrimaryWeapons[removeSlotIndex]);
// 	} 


	// add requested weapon
	invmngr.AddWeaponOfClass(classname, CLASS_PRIMARY);
}

exec function RemoveAllExplosives()
{
	local Rx_InventoryManager invmngr;
	local byte i;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	for (i=0; i < invmngr.PrimaryWeapons.Length; i++) {
			//`log("CLIENT invmngr.PrimaryWeapons[" $ i $ "]" $ invmngr.PrimaryWeapons[i]);
		if (invmngr.PrimaryWeapons[i] != class'Rx_Weapon_Grenade' 
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ProxyC4'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_EMPGrenade'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ATMine'){
			continue;
		}
		invmngr.RemoveWeaponOfClass(invmngr.PrimaryWeapons[i]);
	}
	invmngr.RemoveWeaponsOfClassification(CLASS_EXPLOSIVE);		
	ServerRemoveAllExplosives();
}

exec function ShowTeamVP()
{
	local Rx_PRI PRI;
	local int Gdi_vp;
	local int Gdi_off_vp;
	local int Nod_vp;
	local int Nod_off_vp;	

	ClientMessage("TeamID  VP  Offensive_VP");
	foreach DynamicActors(class'Rx_PRI', PRI)
	{
		if(PRI.Team.TeamIndex == TEAM_GDI)
		{
			Gdi_vp	+= PRI.Veterancy_Points;
			Gdi_off_vp	+= PRI.NonDefensiveVeterancy_Points;
		}
		else if(PRI.Team.TeamIndex == TEAM_NOD) 
		{
			Nod_vp	+= PRI.Veterancy_Points;
			Nod_off_vp	+= PRI.NonDefensiveVeterancy_Points;	
		}
	}	
	
	ClientMessage("GDI"$"  "$Gdi_vp$"  "$Gdi_off_vp);
	ClientMessage("Nod"$"  "$Nod_vp$"  "$Nod_off_vp);	
}


exec function IsInsideBase()
{
	local Volume V; 

	foreach Pawn.TouchingActors(class'Volume', V)
	{
		if(Rx_Volume_TeamBase_GDI(V) != none)
		{ 
			ClientMessage("GDI-Base"); 
			return;
		}
		else if(Rx_Volume_TeamBase_Nod(V) != none) 
		{ 
			ClientMessage("Nod-Base");
			return;
		}			
	}
	ClientMessage("IsOutsideBase"); 
}

exec function bool CheckIfInNoBeaconPlacementVolume()
{
	local Volume v;

	foreach Pawn.TouchingActors(class'Volume', v)
	{
		if(Rx_Volume_NoBeaconPlacement(v) != none)
			return true;
		else 
			continue;
	}
	return false;
}

reliable server function ServerRemoveAllExplosives()
{
	local Rx_InventoryManager invmngr;
	local byte i;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;
	
	for (i=0; i < invmngr.PrimaryWeapons.Length; i++) {
			//`log("SERVER invmngr.PrimaryWeapons[" $ i $ "]" $ invmngr.PrimaryWeapons[i]);
		if (invmngr.PrimaryWeapons[i] != class'Rx_Weapon_Grenade' 
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ProxyC4'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_EMPGrenade'
				&& invmngr.PrimaryWeapons[i] != class'Rx_Weapon_ATMine'){
			continue;
		}
		invmngr.RemoveWeaponOfClass(invmngr.PrimaryWeapons[i]);
	}
	invmngr.RemoveWeaponsOfClassification(CLASS_EXPLOSIVE);
			`log("#### Current Weapon is none");
	CurrentExplosiveWeapon = none;
}

function AddExplosives(class<Rx_Weapon> expl)
{
	local Rx_InventoryManager invmngr;
	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	/** More shite that's unnecessary 
	if(expl == class'Rx_Weapon_TimedC4') {
		if (bJustBaughtEngineer) {
			expl = class'Rx_Weapon_TimedC4_Multiple';
			bJustBaughtEngineer = false; 
			//class'Rx_Weapon_TimedC4_Multiple'
		} 
// 		else if (bJustBaughtHavocSakura) {
// 			expl = class'Rx_Weapon_RemoteC4';
// 			bJustBaughtHavocSakura = false;
// 		} 
		else if (invmngr.default.AvailableExplosiveWeapons.Find(class'Rx_Weapon_TimedC4_Multiple') != -1) {
			expl = class'Rx_Weapon_TimedC4_Multiple';
		}
	} */
		`log("#### expl " $ expl);
	CurrentExplosiveWeapon = expl; 
	ServerAddExplosives(expl);
}

reliable server function ServerAddExplosives(class<Rx_Weapon> expl)
{
	local Rx_InventoryManager invmngr;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	invmngr.AddWeaponOfClass(expl, CLASS_EXPLOSIVE);
}

function SetSidearmWeapon(class<Rx_Weapon> classname)
{
	CurrentSidearmWeapon = classname; 
	ServerSetSidearmWeapon(classname);
}

reliable server function ServerSetSidearmWeapon(class<Rx_Weapon> classname)
{
	local Rx_InventoryManager invmngr;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	// check if allowed
	if (!invmngr.IsSidearmWeaponAllowed(classname)) return;

	// remove all current weapons of same classification
	invmngr.RemoveWeaponsOfClassification(CLASS_SIDEARM);

	// add requested weapon
	invmngr.AddWeaponOfClass(classname, CLASS_SIDEARM);
}


/** one1: End.                                 */

event InitInputSystem()
{
	
	super.InitInputSystem();
	SetOurCameraMode(camMode);
	
	
}

reliable server function ServerEndGame() 
{
	if(PlayerReplicationInfo.bAdmin && !Rx_PRI(Playerreplicationinfo).bModeratorOnly)
		Rx_Game(WorldInfo.Game).EndRxGame("TimeLimit", GetTeamNum());
}

reliable server function ServerAllRelevant() 
{
	local Rx_Controller C;

	if(PlayerReplicationInfo.bAdmin && !Rx_PRI(Playerreplicationinfo).bModeratorOnly)
	{
		bAllPawnsRelevant = !bAllPawnsRelevant;
		foreach WorldInfo.AllControllers(class'Rx_Controller', C)
		{
			C.pawn.bAlwaysRelevant = bAllPawnsRelevant;
		} 
	}
}

reliable server function ServerAddThreeGDIBots()
{
	if(PlayerReplicationInfo.bAdmin && !Rx_PRI(Playerreplicationinfo).bModeratorOnly)
	{
		Rx_Game(WorldInfo.Game).AddRedBots(3);
		WorldInfo.Game.Broadcast( pawn, pawn.PlayerReplicationInfo.PlayerName$" added 3 GDI Bots");
	}
}

reliable server function ServerAddThreeNodBots()
{
	if(PlayerReplicationInfo.bAdmin && !Rx_PRI(Playerreplicationinfo).bModeratorOnly)
	{
		Rx_Game(WorldInfo.Game).AddBlueBots(3);
		WorldInfo.Game.Broadcast( pawn, pawn.PlayerReplicationInfo.PlayerName$" added 3 Nod Bots");
	}
}

reliable server function ServerKillBots()
{
	if(PlayerReplicationInfo.bAdmin && !Rx_PRI(Playerreplicationinfo).bModeratorOnly)
	{
		Rx_Game(WorldInfo.Game).KillBots();
		WorldInfo.Game.Broadcast( pawn, pawn.PlayerReplicationInfo.PlayerName$" killed all Bots");
	}
}

state PlayerClimbing
{
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local rotator OldRotation, ViewRotation;

		GetAxes(Rotation,X,Y,Z);

		// Update acceleration.
		if ( Pawn.OnLadder != None )
		{
			NewAccel = PlayerInput.aForward*Pawn.OnLadder.ClimbDir;
		    if ( Pawn.OnLadder.bAllowLadderStrafing )
				NewAccel += PlayerInput.aStrafe*Y;
		}
		else
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);

		if(Rx_Pawn(Pawn) != None) //Ladder Animation Fix (WORKING THAT ARSENAL! WOO!)
		{
			if(PlayerInput.aForward < 0)
				Rx_Pawn(Pawn).bClimbDown = true;
			else if(PlayerInput.aForward > 0)
				Rx_Pawn(Pawn).bClimbDown = false;
		}

		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);

		bPressedJump = false;
	}
}

state PlayerWalking
{
	exec function StartFire( optional byte FireModeNum )
	{
		LogStartFire();
		
		if(Rx_Pawn(Pawn) != None && Rx_Pawn(Pawn).bSprinting && Rx_Weapon(Pawn.Weapon) != None && Rx_Weapon(Pawn.Weapon).bIronsightActivated )
			Rx_Pawn(Pawn).StopSprinting();
		
		super.StartFire(FireModeNum);
	}

	exec function StartSprint()
	{
		if(RxIfc_PassiveAbility(Pawn) != none)
			RxIfc_PassiveAbility(Pawn).NotifyPassivesSprint(true); 
		
		if (Rx_Pawn(Pawn) != None)
		{
			
			if(bZoomed) 
				return; 
			
			if (bHoldSprint)
			{
				bHoldSprint = false;
				StopSprinting();
				return;
			}

			Rx_Pawn(Pawn).StartSprint();

			if ( Rx_PlayerInput(PlayerInput).bToggleSprint || WorldInfo.TimeSeconds - LastSprintTime < PlayerInput.DoubleClickTime )
				bHoldSprint = true;

			LastSprintTime = WorldInfo.TimeSeconds;
		}
	}

	exec function StopSprinting()
	{
		if(RxIfc_PassiveAbility(Pawn) != none)
			RxIfc_PassiveAbility(Pawn).NotifyPassivesSprint(false); 
		
		if (Rx_Pawn(Pawn) != None && bHoldSprint == false)
			Rx_Pawn(Pawn).StopSprinting();
	}

	exec function StartWalking()
	{
		if (Rx_Pawn(Pawn) != None)
			Rx_Pawn(Pawn).StartWalking();
	}

	exec function StopWalking()
	{
		if (Rx_Pawn(Pawn) != None)
			Rx_Pawn(Pawn).StopWalking();
	}

	exec function ToggleNightVision()
	{
		if (Rx_Pawn(Pawn) != None)
			Rx_Pawn(Pawn).ToggleNightVision();
	}

	simulated function EndState(Name NextStateName)
	{
		bHoldSprint = false;
		Super.EndState(NextStateName);
	}

	exec function EndGame()
	{
		//SetTimer(1.0, false, nameof(ServerEndGame));
		//ServerEndGame();
	}

	
	exec function AllRelevant(int i)
	{
		ServerAllRelevant();
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if(!Rx_Pawn(Pawn).bDodging) {
			if (!bUseDoubleClickDodge && bDodgePressed )
			{
				TryDodge();
			} 	
			if(bUseDoubleClickDodge)
				Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
			else
			{
				Super.ProcessMove(DeltaTime,NewAccel,DCLICK_None,DeltaRot);
				bDodgePressed = false; 
			}
				
		}
	}	
	
	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump;

		GroundPitch = 0; // from UTPlayerController.PlayerMove()
		
		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			// Update acceleration.
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}
			
			DoubleClickMove = CheckForOneClickDodge();
			
			if(DoubleClickMove == DCLICK_None)
				DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			UpdateRotation( DeltaTime );
			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;

			// Update Parachute
			if (Rx_Pawn(Pawn) != none)
			{
				Rx_Pawn(Pawn).TargetParachuteAnimState.X =  FClamp(PlayerInput.aForward, -1,1);
				Rx_Pawn(Pawn).TargetParachuteAnimState.Y =  FClamp(PlayerInput.aStrafe, -1,1);
			}
			
		}
	}
}

/******************** Driving *******************/
state PlayerDriving
{
	/** Sprinting System */
	exec function StartSprint()
	{
		if(RxIfc_PassiveAbility(Pawn) != none)
			RxIfc_PassiveAbility(Pawn).NotifyPassivesSprint(true); 
		
		if (Rx_Vehicle(Pawn) != None && !Rx_Vehicle(Pawn).bEMPd) 
		{
			if (bHoldSprint)
			{
				bHoldSprint = false;
				StopSprinting();
				return;
			}

			Rx_Vehicle(Pawn).StartSprint();

			if ( Rx_PlayerInput(PlayerInput).bToggleSprint || WorldInfo.TimeSeconds - LastSprintTime < PlayerInput.DoubleClickTime )
				bHoldSprint = true;

			LastSprintTime = WorldInfo.TimeSeconds;
		}
	}

	exec function StopSprinting()
	{
		if(RxIfc_PassiveAbility(Pawn) != none)
			RxIfc_PassiveAbility(Pawn).NotifyPassivesSprint(false); 
		
		if (Rx_Vehicle(Pawn) != None && bHoldSprint == false)
			Rx_Vehicle(Pawn).StopSprinting();
	}

	simulated function EndState(Name NextStateName)
	{
		bHoldSprint = false;
		
		Super.EndState(NextStateName);
	}
}


state Dead
{
	ignores SeePlayer, HearNoise, KilledBy, NextWeapon, PrevWeapon;
	
	exec function Spotting(){} //Do not allow spotting while dead
	exec function SwitchWeapon(byte T){}
	exec function ToggleMelee() {}
	exec function StartFire( optional byte FireModeNum )
	
	{
		if ( bFrozen )
		{
			if ( !IsTimerActive() || GetTimerCount() > MinRespawnDelay )
				bFrozen = false;
			return;
		}
		if ( PlayerReplicationInfo.bOutOfLives )
			ServerSpectate();
		else
			super.StartFire( FireModeNum );
	}

	function Timer()
	{
		if (!bFrozen)
			return;

		// force garbage collection while dead, to avoid GC during gameplay
		if ( (WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone) )
		{
			WorldInfo.ForceGarbageCollection();
		}
		bFrozen = false;
		bUsePhysicsRotation = false;
		bPressedJump = false;
		LastHitLoc = vect(0,0,0);
	}

	reliable client event ClientSetViewTarget( Actor A, optional ViewTargetTransitionParams TransitionParams )
	{
		if( A == None )
		{
			ServerVerifyViewTarget();
			return;
		}
		// don't force view to self while dead (since server may be doing it having destroyed the pawn)
		if ( A == self )
			return;
		SetViewTarget( A, TransitionParams );
	}

	event PlayerTick( float DeltaTime )
	{
		super.PlayerTick(DeltaTime);
        if(LastHitLoc != vect(0,0,0) && LastHitLocBlendPct < 2.0f)
        	LastHitLocBlendPct += 2.5f * DeltaTime;

        if(LastHitLoc != vect(0,0,0) && LastHitLocBlendPct < 1.0f && DesiredFOV > 10.0f)	
        	DesiredFOV -= DeltaTime * (VSize(LastHitLoc - Viewtarget.location) / 100.0f);	

	}

	/** one: added. */
	simulated event GetPlayerViewPoint( out vector POVLocation, out Rotator POVRotation )
	{
		local vector HitLocation, HitNormal, off;
		local Actor a;
		local rotator rot;
		local rotator targetRot;

		super.GetPlayerViewPoint(POVLocation, POVRotation);

        if(LastHitLoc != vect(0,0,0))
        {
	        targetRot = rotator(LastHitLoc - ViewTarget.Location);
	  
	        if(POVRotation != targetRot && LastHitLocBlendPct < 1.0f)
	        {
	            POVRotation = RLerp(POVRotation,  targetRot, LastHitLocBlendPct);
	        }
	        else if(LastHitLocBlendPct < 2.0f)
	        {
	        	setRotation(targetRot);
	        	POVRotation = targetRot;
	        	LastHitLocBlendPct = 2.0f;
	        }
        }

		off = POVLocation;
		off.Z += DeathCameraOffset.Z;
		rot = POVRotation;
		rot.Pitch = 0;
		off -= vector(rot) * DeathCameraOffset.X;
		a = Trace(HitLocation, HitNormal, off, POVLocation, true);
		if (a == none) HitLocation = off;

		POVLocation = HitLocation - (0.1f * (HitLocation - POVLocation));
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation, RealRotation;
		local int tries, besttry;
		local float bestdist, newdist, RealCameraScale;
		local int startYaw;
		local UTPawn P;

		LastHitLocBlendPct = 0.0f;	

		if ( UTVehicle(ViewTarget) != None )
		{
			if (Pawn!=none)
			{
				Pawn.SetDesiredRotation(Rotation);
			}
			bUsePhysicsRotation = false;
			return;
		}

		ViewRotation = Rotation;
		RealRotation = ViewRotation;
		ViewRotation.Pitch = 56000;

		SetRotation(ViewRotation);
		P = UTPawn(ViewTarget);
		if ( P != None )
		{
			RealCameraScale = P.CurrentCameraScale;
			P.CurrentCameraScale = P.CameraScale;
		}

		// use current rotation if possible
		CalcViewActor = None;
		cameraLoc = ViewTarget.Location;
		GetPlayerViewPoint( cameraLoc, cameraRot );
		if ( P != None )
		{
			newdist = VSizeSq(cameraLoc - ViewTarget.Location);
			if (newdist < Square(P.CylinderComponent.CollisionRadius + P.CylinderComponent.CollisionHeight) )
			{
				// find alternate camera rotation
				tries = 0;
				besttry = 0;
				bestdist = 0.0;
				startYaw = ViewRotation.Yaw;

				for (tries=1; tries<16; tries++)
				{
					CalcViewActor = None;
					cameraLoc = ViewTarget.Location;
					ViewRotation.Yaw += 4096;
					SetRotation(ViewRotation);
					GetPlayerViewPoint( cameraLoc, cameraRot );
					newdist = VSizeSq(cameraLoc - ViewTarget.Location);
					if (newdist > bestdist)
					{
						bestdist = newdist;
						besttry = tries;
					}
				}
				ViewRotation.Yaw = startYaw + besttry * 4096;
			}
			P.CurrentCameraScale = RealCameraScale;
		}
		SetRotation(RealRotation);
		if (Pawn!=none)
		{
			Pawn.SetDesiredRotation(MakeRotator(ViewRotation.Pitch, ViewRotation.Yaw, 0));
		}
		bUsePhysicsRotation = false;
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator DeltaRot, ViewRotation;

		//if ( !bFrozen )
		//{
			if ( bPressedJump )
			{
				StartFire( 0 );
				bPressedJump = false;
			}
			GetAxes(Rotation,X,Y,Z);
			// Update view rotation.
			ViewRotation = Rotation;
			// Calculate Delta to be applied on ViewRotation
			DeltaRot.Yaw	= PlayerInput.aTurn;
			DeltaRot.Pitch	= PlayerInput.aLookUp;
			ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
			SetRotation(ViewRotation);
			if ( Role < ROLE_Authority ) // then save this move and replicate it
					ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		//}
		//else 
		if ( !IsTimerActive() || GetTimerCount() > MinRespawnDelay )
		{
			bFrozen = false;
		}

		ViewShake(DeltaTime);
	}

	function BeginState(Name PreviousStateName)
	{
		local UTWeaponLocker WL;
		local UTWeaponPickupFactory WF;

		if(Vet_Menu != none) 
		{
			DestroyOldVetMenu(); //Kill Vet menu on death 
		}
		
		if(Com_Menu != none)
		{
			DestroyOldComMenu(); //Kill Vet menu on death	
		}
		
		LastAutoObjective = None;
		if ( Pawn(Viewtarget) != None )
		{
			Super(UtPlayerController).SetBehindView(true);
		}

		/** one1: modified */
		//Super.BeginState(PreviousStateName);
		if ( (Pawn != None) && (Pawn.Controller == self) )
			Pawn.Controller = None;
		Pawn = None;
		FOVAngle = DesiredFOV;
		Enemy = None;
		bFrozen = true;
		bPressedJump = false;
		FindGoodView();
		MinRespawnDelay = CalcNewMinRespawnDelay();
	    SetTimer(MinRespawnDelay, false);

	    //set timer for respawn hud counter (nBab)
		if(WorldInfo.NetMode != NM_DedicatedServer)
		{
			SetTimer(1,true,'setRespawnUiCounter');
			Rx_HUD(myHUD).HudMovie.setRespawnCounter(MinRespawnDelay);	
		}

		CleanOutSavedMoves();

		if ( LocalPlayer(Player) != None )
		{
			ForEach WorldInfo.AllNavigationPoints(class'UTWeaponLocker',WL)
				WL.NotifyLocalPlayerDead(self);
			ForEach WorldInfo.AllNavigationPoints(class'UTWeaponPickupFactory',WF)
				WF.NotifyLocalPlayerDead(self);
		}

		if (Role == ROLE_Authority && UTGame(WorldInfo.Game) != None && UTGame(WorldInfo.Game).ForceRespawn())
		{
			SetTimer(MinRespawnDelay, true, 'DoForcedRespawn');
		}
	}

	//set the respawn hud counter (nBab)
	function setRespawnUiCounter()
	{
		//if the main timer is running
		if (GetTimerCount() != -1)
		{
			Rx_HUD(myHUD).HudMovie.setRespawnCounter( int(MinRespawnDelay - FFloor(GetTimerCount())) );
		}
		else
		{
			Rx_HUD(myHUD).HudMovie.setRespawnCounter(0);
		}
	}

	/** forces player to respawn if it is enabled */
	function DoForcedRespawn()
	{
		if (PlayerReplicationInfo.bOnlySpectator)
		{
			ClearTimer('DoForcedRespawn');
		}
		else
		{
			ServerRestartPlayer();
		}
	}

	function EndState(name NextStateName)
	{
		bUsePhysicsRotation = false;
		Super.EndState(NextStateName);
		SetBehindView(false);
		StopViewShaking();
		ClearTimer('DoForcedRespawn');
	}

Begin:
    Sleep(5.0);
	if ( (ViewTarget == None) || (ViewTarget == self) || (VSizeSq(ViewTarget.Velocity) < 1.0) )
	{
		Sleep(1.0);
		if (myHUD != None)
		{
			//@FIXME: disabled temporarily for E3 due to scoreboard stealing input
			//myHUD.SetShowScores(true);
		}
	}
	else
		Goto('Begin');
}

/** Gradually increases with time till MaxRespawnDelay is reached */
function float CalcNewMinRespawnDelay()
{	
	MinRespawnDelay = default.MinRespawnDelay + (Rx_GRI(WorldInfo.GRI).ElapsedTime/default.TimeSecondsTillMaxRespawnTime * (default.MaxRespawnDelay - default.MinRespawnDelay));
	
	if(MinRespawnDelay < default.MinRespawnDelay)
		MinRespawnDelay = default.MinRespawnDelay;
	else if(MinRespawnDelay > default.MaxRespawnDelay)
		MinRespawnDelay = default.MaxRespawnDelay;	
		
	if(MinRespawnDelay * RespawnTimeModifier > MinRespawnDelay)	
		return MinRespawnDelay * RespawnTimeModifier;
	else 
		return MinRespawnDelay;		
}

function UpdateRotation( float DeltaTime )
{
	local rotator DeltaRot;

	// if free aim dont rotate view
	if (bIsFreeView)
	{
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aMouseY;
		FreeAimRot += DeltaRot;
		
		ViewShake( deltaTime );

		if (Pawn != none)
			Pawn.FaceRotation(Pawn.Rotation + DeltaRot, DeltaTime);
	}
	else
		super.UpdateRotation(DeltaTime);
}

//-----------------------------------------------------------------------------
// exec functions
//-----------------------------------------------------------------------------

//function EquipNuke() {
// 	ServerEquipNuke();	
//}

//function EquipION() {
// 	ServerEquipION();	
//}

exec function GiveCredits() 
{
	if (WorldInfo.NetMode == NM_Standalone) 
		Rx_PRI(PlayerReplicationInfo).AddCredits(10000);
}

/** 
 *  Switches to the Grenade weapon (if it exists) in the InventoryManager and 'fires' the weapon. 
	Deprecated 
 */
exec function ThrowGrenade()
{
	BeginGrenadeThrow() ;//ServerThrowGrenade();
}
reliable server function ServerThrowGrenade()
{
	if(Rx_Pawn(Pawn) != None )
	{
		//Rx_Pawn(Pawn).bThrowingGrenade = true;
		Rx_Pawn(Pawn).SwitchWeapon(12); //Switch to the corresponding InventoryGroup for Grenades.
	}
}

exec function BeginGrenadeThrow() //Switches to grenade and waits for release
{
	ServerBeginGrenadeThrow();
}

exec function EndGrenadeThrow() //On release of the button, throw the grenade
{
ServerEndGrenadeThrow(); 	
}


reliable server function ServerBeginGrenadeThrow() 
{
	if(Rx_Pawn(Pawn) != none && Rx_Weapon(Pawn.Weapon).InventoryGroup != 12 && Rx_Pawn(Pawn).MyGrenade != none) //Again '12' is used exclusively for recharging grenades or whatever else is added. 
	{
		//Rx_Pawn(Pawn).bThrowingGrenade = true; 
		Rx_Pawn(Pawn).SwitchWeapon(12); //Only recharging grenades should ever be in the 12 inventory slot
	}
}

reliable server function ServerEndGrenadeThrow()
{
	if(Rx_Pawn(Pawn) != none && Rx_Weapon(Pawn.Weapon).InventoryGroup == 12) 
	{
		Rx_Pawn(Pawn).ThrowGrenade(); 
		
	}
}

exec function SetBotSkill(float skill) 
{
	local Rx_Bot B;
	 
	foreach WorldInfo.AllControllers(class'Rx_Bot', B)
	{
		B.Skill = skill;
	}
}

//reliable server function ServerEquipION() 
//{
//	if (Rx_PRI(PlayerReplicationInfo).GetCredits() >= 1000 )
//	{
//		Rx_PRI(PlayerReplicationInfo).RemoveCredits(1000);
//		Rx_InventoryManager(Pawn.InvManager).AddWeaponOfClass(class'Rx_Weapon_IonCannonBeacon',CLASS_ITEM);
//	}
//}

//reliable server function ServerEquipNuke() 
//{ 
//	if (Rx_PRI(PlayerReplicationInfo).GetCredits() >= 1000 )
//	{
//		Rx_PRI(PlayerReplicationInfo).RemoveCredits(1000);
//		Rx_InventoryManager(Pawn.InvManager).AddWeaponOfClass(class'Rx_Weapon_NukeBeacon',CLASS_ITEM);
//	}
//}


function ChangeToSBH(bool sbh) 
{
	local pawn p, NewP; //Let us try NOT destroying our initial pawn till after the new one is made... may solve the changing to SBH issue where Rx_Controller suddenly controls nothing
	local vector l;
	local rotator r; 
	local InventoryManager i;
	
	p = Pawn;
	//if(bDebugging) `log("Set P to " @ Pawn); 
	//store the inventory info if we were to transfer over to SBH or vice versa
	i = p.InvManager;
	l = p.Location;//Pawn.Location;
	r = p.Rotation; //Pawn.Rotation; 
	
	Saved_Location=l;
	Saved_Rotation=r;
	Saved_Inv=i; 
	
	if(isTimerActive('ConfirmPawnSwitchToSBHTimer')) ClearTimer('ConfirmPawnSwitchToSBHTimer'); 
	if(isTimerActive('ConfirmPawnSwitchFromSBHTimer')) ClearTimer('ConfirmPawnSwitchFromSBHTimer'); 
	
	if(sbh) 
	{
		if(bDebugging) `log("Changing to SBH "); 
		if(self.Pawn.class != class'Rx_Pawn_SBH' )
		{
			if(bDebugging) `log("Unprepossessing"); 
			UnPossess();
			
			if(bDebugging) `log("destroying" @ p);
			 p.Destroy(); // Changed this to kill just the old pawn. The new one will be a new reference to see if this resolves the old SBH issue. (see above)
			
			if(bDebugging) `log("Attempting to spawn new pawn");
			
			NewP = Spawn(class'Rx_Pawn_SBH', , ,l,r,,true); //ignore collissions when spawning this in.
			if(bDebugging) `log("Spawned New Pawn" @ NewP);
			//restore the inventory back
			NewP.InvManager = i;
			if(bDebugging) `log("Inventory manager set to " @ i);
			NewP.bForceNetUpdate = true;
			SetTimer(0.4f, false, 'ConfirmPawnSwitchToSBHTimer');
		}
		else
		{
			return;
		}
	}
	else 
	{
		if(self.Pawn.class != Rx_Game(WorldInfo.Game).DefaultPawnClass )
		{
			UnPossess();
			p.Destroy(); 
			NewP = Spawn(Rx_Game(WorldInfo.Game).DefaultPawnClass, , ,l,r,,true);
			//restore the inventory back
			NewP.InvManager = i;
			
		}
		else
		{
			return;
		}
		
	}
	Possess(NewP, false);	
	bForceNetUpdate = true;
	
}

function ConfirmPawnSwitchToSBHTimer()
{ 
	local pawn NewP; 
	
	if(Pawn == none || self.Pawn.class != class'Rx_Pawn_SBH' ) //Failed
		{
			if(bDebugging) `log("Unprepossessing"); 
			UnPossess();
			
			if(bDebugging) `log("destroying" @ Pawn);
			 Pawn.Destroy(); 
			if(bDebugging) `log("Attempting to spawn new pawn using alt method");
			//NewP = Spawn(class'Rx_Pawn_SBH', , ,Saved_Location,Saved_Rotation);
			NewP = Spawn(class'Rx_Pawn_SBH', , ,Saved_Location,Saved_Rotation,, true);
			if(bDebugging) `log("Spawned New Pawn" @ NewP);
			//restore the inventory back
			NewP.InvManager = Saved_Inv;
			
				NewP.setlocation(Saved_Location); 
			
			if(bDebugging) `log("Inventory manager set to " @ Saved_Inv);
			NewP.bForceNetUpdate = true;
			
			Possess(NewP, false);	
			bForceNetUpdate = true;
			
			Rx_PRI(PlayerReplicationInfo).equipStartWeapons();
			SetTimer(0.4f, false, 'ConfirmPawnSwitchToSBHTimer');
		}
	else
	if(Rx_Pawn_SBH(Pawn) != none && bDebugging)
	{
		`log("Should have succeeded changing to SBH"); 
	
	}	
}

function ConfirmPawnSwitchFromSBHTimer()
{
	local pawn NewP; 
	
	
	if(Pawn == none || self.Pawn.class != Rx_Game(WorldInfo.Game).DefaultPawnClass ) //Failed
		{
			UnPossess();
			Pawn.Destroy(); 
			//NewP = Spawn(Rx_Game(WorldInfo.Game).DefaultPawnClass, , ,Saved_Location,Saved_Rotation);
			NewP = Spawn(Rx_Game(WorldInfo.Game).DefaultPawnClass, , ,Saved_Location,Saved_Rotation,,true);

			//restore the inventory back
			NewP.InvManager = Saved_Inv;
			if(NewP != none) NewP.setlocation(Saved_Location); 
		
			Possess(NewP, false);	
			bForceNetUpdate = true;
			
			Rx_PRI(PlayerReplicationInfo).equipStartWeapons();
			SetTimer(0.4f, false, 'ConfirmPawnSwitchFromSBHTimer');
			}
			else
			if(bDebugging && Rx_Pawn(Pawn) != none && Rx_Pawn_SBH(Pawn) == none)
	{
		`log("Should have succeeded changing from SBH"); 
	
	}	
}


exec function FreeView(bool bEnabled)
{
	// not usable in first person
	if (bEnabled && UsingFirstPersonCamera())
		return;

	bIsFreeView = bEnabled;
	
	// fix rotation if in FreeView to current rotation
	if(bEnabled)
		FreeAimRot = Rotation;
}

exec function VehicleLockPressed()
{
	bVehicleLockPressed = true;
	SetTimer(1, false, 'VehicleLockHeldTimer');
}

exec function VehicleLockReleased()
{
	if (bVehicleLockPressed)
	{
		ClearTimer('VehicleLockHeldTimer');
		PerformVehicleLockPressed();
		bVehicleLockPressed = false;
	}
}

function VehicleLockHeldTimer()
{
	bVehicleLockPressed = false;
	PerformVehicleLockHeld();
}

reliable server function PerformVehicleLockPressed()
{
	if (BoundVehicle != None)
	{
		if (BoundVehicle.ToggleDriverLock())
		{
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Driver_Locked,,,BoundVehicle.Class);	
			CTextMessage("-Locked Vehicle-",'LightGreen');
		}
		else
		{
			CTextMessage("-Unlocked Vehicle-",'LightGreen');
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Driver_Unlocked,,,BoundVehicle.Class);	
		}
			
	}

}

reliable server function PerformVehicleLockHeld()
{
	if(Rx_Vehicle(Pawn) != None && IsInState('PlayerDriving')) 
	{
		if (Rx_Vehicle(Pawn).BoundPRI == None)
			BindVehicle(Rx_Vehicle(Pawn));
		else if (Rx_Vehicle(Pawn).BoundPRI == PlayerReplicationInfo)
			BindVehicle(None);
		else
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_CannotBind,Rx_Vehicle(Pawn).BoundPRI,,Pawn.Class);
	}
	else if (BoundVehicle != None)
	{
		BindVehicle(None);
	}
}

function BindVehicle(Rx_Vehicle NewVehicle)
{
	local Rx_Vehicle Saved;
	if (BoundVehicle != None)
	{
		Saved = BoundVehicle;
		if (BoundVehicle.UnBind(self))
		{
			CTextMessage("-Unbound Vehicle-",'LightGreen');
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Unbound,,,Saved.Class);	
		}
			
	}
	if (NewVehicle != None)
	{
		if (NewVehicle.Bind(self))
		{
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Bound,,,BoundVehicle.Class);	
			CTextMessage("-Bound Vehicle-",'LightGreen');
		}
			
	}
}

function NotifyBindAllowed(Rx_Vehicle V, bool bWasBuyer)
{
	if (BoundVehicle == None)
	{
		if (bWasBuyer && V.Bind(self))
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Bound_Auto,,,BoundVehicle.Class);
		else
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_CanBind);
	}
	else
	{
		ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_CanBind_Replace,,,BoundVehicle.Class);
	}
}

reliable client function ReceiveVehicleMessageWithInt( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional int Integer )
{
	VehicleMessageInt = Integer;
	ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

// Due to lazy. Should be integrated via the Rx_DeathMessage, but can't be bother dealing with the switch that uses raw numbers instead of a meaningful const.. or macro.. or enum. So really they were lazy first.
reliable client function ReceiveVehicleDeathMessage(PlayerReplicationInfo Killer, class<DamageType> DmgType)
{
	if (Rx_Hud(MyHUD) != None)
		Rx_Hud(MyHUD).AddVehicleDeathMessage(Killer, DmgType);
}

exec function Spotting()
{

	
	if(isTimerActive('QHeldTimer')) ClearTimer('QHeldTimer');
	
	if(Com_Menu != none && Com_Menu.MenuTab != none && Com_Menu.MenuTab.bQCast) SetTimer(0.5,false,'QHeldTimer');
	
	if(!bCanFocusSpot) 
	{
		//Wait for a second Q press. 
		bCanFocusSpot = true;
		SetTimer(0.25,false,'ClearFocusWaitTimer');
	}
	else
	if(bCanFocusSpot) 
	{
		bFocusSpotting = true;  
		bCanFocusSpot=false; 
		ClearTimer('ClearFocusWaitTimer');
		return;
	}
	
	if(spotMessagesBlocked)
		return;
	bSpotting = true;	
	
	if(IsTimerActive('RemoveSpotTargets'))	{
		ClearTimer('RemoveSpotTargets');
	}
	RemoveSpotTargets();
}

function ClearCommandSpotWaitTime()
{
	bCanCommandSpot = false; 
}

function ClearFocusWaitTimer()
{
	bCanFocusSpot=false;
	//if(bFocusSpotting) ReportSpotted();
}

exec function recordDemo()
{
	demorecstart();
}

reliable server function demorecstart()
{
	Rx_Game(WorldInfo.Game).ClientRequestDemoRec(self);
}

exec function AdminRecordDemo()
{
	ServerAdminRecord();
}

reliable server function ServerAdminRecord()
{
	if (PlayerReplicationInfo.bAdmin)
		Rx_Game(WorldInfo.Game).AdminDemoRec(self);
}

exec function ReportSpotted()
{
	local Rx_Building Building;
	local Rx_Bot bot;
	local string BuildingName;
	local Actor PrimarySpot; 
	local string RMSG, CMSG; //Remote message, and Client Message  
	local int	nr; 
	local byte UIS; 
	
	if(isTimerActive('QHeldTimer')) ClearTimer('QHeldTimer');
	if(Com_Menu != none && Com_Menu.MenuTab != none && Com_Menu.MenuTab.bQCast && !bQHeld) 
	{
		Com_Menu.MenuTab.QCast(false); 
		return; 
	}
	else
	if(VoteHandler != none && Rx_HUD(myHUD).FlipPageForward()) 
	{
		return;
	}

	bQHeld = false ; //Reset the held status 
	
	ClearTimer('ReportSpotted'); 
	/**if(bCommandSpotting) 
	{
	ProcessCommandSpot(); 
	ClearCommandSpotWaitTime();
	return;
	}*/
	
	if(isTimerActive('ClearFocusWaitTimer') && bCanFocusSpot) 
	{
		SetTimer((GetTimerRate('ClearFocusWaitTimer') - GetTimerCount('ClearFocusWaitTimer')), false, 'ReportSpotted');	
		return; 	
	}
	
	bSpotting = false;  
	if(spotMessagesBlocked) // && !bFocusSpotting)
	{
		bCanFocusSpot=false;
		return;		
	}
		
		
	nr = -1; 
	if ( Rx_Hud(MyHUD) != None && Rx_Hud(MyHUD).SpotTargets.Length > 0) {
	
		PrimarySpot = Rx_Hud(MyHUD).SpotTargets[0] ;//Eliminate spamming the hell out of this line. 
		
		if(PrimarySpot == none || Rx_DestroyableObstaclePlus(PrimarySpot) != none) 
		{
			bCanFocusSpot=false;
			return; 
		}
		
		if(Rx_CratePickup(PrimarySpot) != none && numberOfRadioCommandsLastXSeconds++ < 5)
		{
			BroadCastSpotMessage(11, "CRATE SPOTTED:" @ GetSpottargetLocationInfo(PrimarySpot));	
		}
		else 
		if(Rx_BasicPawn(PrimarySpot) != none && Rx_BasicPawn(PrimarySpot).GetTeamNum() != GetTeamNum() && numberOfRadioCommandsLastXSeconds++ < 5)
		{
			BroadCastSpotMessage(11, Rx_BasicPawn(PrimarySpot).GetHumanReadableName() @ "SPOTTED:" @ GetSpottargetLocationInfo(PrimarySpot));
		}
		else
		if(Rx_Building(Rx_Hud(MyHUD).SpotTargets[0]) != None) {
			
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				Building = Rx_Building(Rx_Hud(MyHUD).SpotTargets[0]);
				BroadcastBuildingSpotMessages(Building);
			}
		} else if(Rx_Defence(PrimarySpot) != none) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				BroadcastBaseDefenseSpotMessages(Rx_Defence(PrimarySpot));
				if(Rx_DefencePRI(Rx_Defence(PrimarySpot).PlayerReplicationInfo) != none) 
				{
					SetPlayerSpotted(Rx_DefencePRI(Rx_Defence(PrimarySpot).PlayerReplicationInfo).Defence_ID) ;
					if(bCommandSpotting || bPlayerIsCommander()) 
						SetPlayerCommandSpotted(Rx_DefencePRI(Rx_Defence(PrimarySpot).PlayerReplicationInfo).Defence_ID);
					
				}
				
				
			}
		} else if(Rx_Weapon_DeployedBeacon(PrimarySpot) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				if(PrimarySpot.GetTeamNum() == GetTeamNum())
					BroadCastSpotMessage(15, "Defend BEACON"@GetSpottargetLocationInfo(Rx_Weapon_DeployedBeacon(PrimarySpot))@"!!!");
				else
				{
					BroadCastSpotMessage(-1, "Spotted ENEMY BEACON"@GetSpottargetLocationInfo(Rx_Weapon_DeployedBeacon(PrimarySpot))@"!!!");	
					TellBotsToDisarmDeployable(Rx_Weapon_DeployedBeacon(PrimarySpot));
				}
			}
		}  else if(Rx_Weapon_DeployedC4(PrimarySpot) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				BuildingName = Rx_Weapon_DeployedC4(PrimarySpot).ImpactedActor.GetHumanReadableName();
				if(BuildingName == "MCT" || Rx_Building(Rx_Weapon_DeployedC4(PrimarySpot).ImpactedActor) != None)
				{	
					if(BuildingName == "MCT")
						BuildingName = "MCT"@GetSpottargetLocationInfo(Rx_Weapon_DeployedC4(PrimarySpot));			
					if(PrimarySpot.GetTeamNum() == GetTeamNum())
						BroadCastSpotMessage(15, "Defend &gt;&gt;C4&lt;&lt; at "@BuildingName@"!!!");
					else
					{
						BroadCastSpotMessage(-1, "Spotted ENEMY &gt;&gt;C4&lt;&lt; at "@BuildingName@"!!!");
						TellBotsToDisarmDeployable(Rx_Weapon_DeployedBeacon(PrimarySpot));
					}
				}	
			}
		} else if(Rx_Vehicle_Harvester(PrimarySpot) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				if(PrimarySpot.GetTeamNum() == GetTeamNum())
					RadioCommand(26);
				else
				{
				RadioCommand(21);
				if(Rx_DefencePRI(Rx_Vehicle_Harvester(PrimarySpot).PlayerReplicationInfo) != none) 
				{
				SetPlayerSpotted(Rx_DefencePRI(Rx_Vehicle_Harvester(PrimarySpot).PlayerReplicationInfo).Defence_ID) ;	
				if(bCommandSpotting || bPlayerIsCommander()) 
					SetPlayerCommandSpotted(Rx_DefencePRI(Rx_Vehicle_Harvester(PrimarySpot).PlayerReplicationInfo).Defence_ID);				
				}
				if(bFocusSpotting) SetPlayerFocused(Rx_DefencePRI(Rx_Vehicle_Harvester(PrimarySpot).PlayerReplicationInfo).Defence_ID) ;
				bFocusSpotting = false; 
				}
					
			}
			bCanFocusSpot=false;
			return;
		} else 
		if(Pawn(PrimarySpot).GetTeamNum() == GetTeamNum()) {
			bot = Rx_Bot(Pawn(PrimarySpot).Controller);
			if(bot != None) {
				if(bot.Squad != None && Rx_SquadAI(bot.squad).SquadLeader == Self && bot.GetOrders() == 'Follow') {
					UTTeamInfo(bot.Squad.Team).AI.SetBotOrders(bot);
					BroadCastSpotMessage(17, "Stop following me"@Pawn(PrimarySpot).Controller.GetHumanReadableName());
					RespondingBot = bot;
					SetTimer(0.5 + FRand(), false, 'BotSayAffirmativeToplayer');
				} 
				else
				{
					bot.SetBotOrders('Follow', self, true);
					BroadCastSpotMessage(13, "Follow me"@Pawn(PrimarySpot).Controller.GetHumanReadableName());
					RespondingBot = bot;
					SetTimer(0.5 + FRand(), false, 'BotSayAffirmativeToplayer');
				}
			} 
			else 
			{
				
				/*Spotting Friendly Pawn*/
				
				if(numberOfRadioCommandsLastXSeconds++ < 5 && Rx_Pawn(PrimarySpot) != none && Rx_Pawn(PrimarySpot).PlayerReplicationInfo !=none) 
				{
					/*Infantry To Infantry*/
					if(Rx_Pawn(Pawn) != none && Rx_Pawn(Pawn).Armor <= Rx_Pawn(Pawn).ArmorMax/1.5 && Rx_Pawn(PrimarySpot).IsHealer() ) //Send "I need repairs"
					{
						nr=10; 
						RMSG=PlayerReplicationInfo.PlayerName @ "Needs Repairs" ;
						CMSG="-Requested Repairs-"; 
						UIS=1; 
					}
					else
					if (Rx_Weapon_Beacon(Pawn.Weapon) != none) //Send "Cover Me" 
					{
						nr=15; 
						RMSG=PlayerReplicationInfo.PlayerName @ "Needs Cover" ;
						CMSG="-Requested Cover-"; 
						UIS=3; 
					}
					else /*Vehicle to Infantry*/
					if(Rx_Vehicle(Pawn) != none && Rx_Vehicle(Pawn).Health <= Rx_Vehicle(Pawn).HealthMax*0.85 && Rx_Pawn(PrimarySpot).IsHealer() ) //Send "I need repairs"
					{
						nr=10; 
						RMSG=PlayerReplicationInfo.PlayerName @ "Needs Repairs" ;
						CMSG="-Requested Repairs-"; 
						UIS=1; 
					}
					else //Send "Get in the vehicle"
					if(Rx_Vehicle(Pawn) != none && Rx_Pawn(PrimarySpot) != none)
					{
						nr=1; 
						RMSG=PlayerReplicationInfo.PlayerName @ ": Requested Passenger" ;
						CMSG="-Requested Passenger-"; 
						UIS=2; 
					}
					else
					{
						nr=13; 
						RMSG=PlayerReplicationInfo.PlayerName @ ": Follow Me" ;
						CMSG="-Requested Follow-"; 
						UIS=2; 
					}
					
					
				}
				else
				if(numberOfRadioCommandsLastXSeconds++ < 5 && Rx_Vehicle(PrimarySpot) != none && Rx_Vehicle(PrimarySpot).PlayerReplicationInfo !=none)
				{
					//Bacon
					if (Rx_Weapon_Beacon(Pawn.Weapon) != none) //Send "Cover Me" 
					{
						nr=15; 
						RMSG=PlayerReplicationInfo.PlayerName @ "needs beacon cover" ;
						CMSG="-Requested Cover-"; 
						UIS=3; 
					}
					else
					if(Pawn(PrimarySpot).PlayerReplicationInfo != none && Rx_Vehicle(Pawn) == none) 
					{
						nr=14; 
						RMSG=PlayerReplicationInfo.PlayerName @ "needs a ride" ;
						CMSG="-Requested a Ride-"; 
						UIS=2; 
					}
					else
					if(Rx_Vehicle(Pawn) != none)
					{
						//Send "Follow Me"
						nr=13; 
						RMSG=PlayerReplicationInfo.PlayerName @ ": Follow Me" ;
						CMSG="-Requested Follow-"; 
						UIS=2; 
					}
					
					
					
				}
					if(Pawn(PrimarySpot) != none && Rx_DefencePRI(Pawn(PrimarySpot).PlayerReplicationInfo) == none && nr > -1 )
					{
						numberOfRadioCommandsLastXSeconds++; 
						WhisperSpotMessage(Pawn(PrimarySpot).PlayerReplicationInfo.PlayerID, nr, RMSG, UIS);
						CTextMessage(CMSG,'Green',30);
						ClientPlaySound(RadioCommands[nr]);
						
						spotMessagesBlocked = true;
						SetTimer(1.5, false, 'resetSpotMessageCountTimer');
					}
				//BroadCastSpotMessage(13, "Follow me"@Pawn(Rx_Hud(MyHUD).SpotTargets[0]).Controller.GetHumanReadableName());
			}
		} else {
			BroadcastEnemySpotMessages();
		}
		//@Shahman: SpotTargets Will be removed after 10 seconds.
		//TODO: editor controllers
		if(IsTimerActive('RemoveSpotTargets'))	{
			ClearTimer('RemoveSpotTargets');
		}
		SetTimer (10.0, false, 'RemoveSpotTargets'); 
	}
	bCanFocusSpot=false; 
	bFocusSpotting= false; 
}

function ProcessCommandSpot()
{
	local Actor Targs;
	local int i;
	local string TeamString; 
	
	if(GetTeamNum() == 0 ) TeamString="GDI" ; 
	else
	if(GetTeamNum() == 1 ) TeamString="Nod" ;
	else
	TeamString="NULL" ; 
	
	i=0;
	
	//First, send the targets their cue to be sent up as targets
		foreach Rx_HUD(myHUD).CommandSpotTargets(Targs)
		{
			if(Rx_Pawn(Targs) != none ) Rx_Pawn(Targs).ClientSetAsTarget(Spotting_Mode,TeamString,i); 
			else
			if(Rx_Vehicle(Targs) != none ) Rx_Vehicle(Targs).ClientSetAsTarget(Spotting_Mode,TeamString,i); 
		}
	
	//Lastly, remove the HUD's spotted targets
	Rx_HUD(myHUD).CommandSpotTargets.Length = 0; 
	Rx_Hud(MyHUD).LastSpotTarget = None;
	//bCommandSpotting = false; 
}

function TellBotsToDisarmDeployable(Rx_Weapon_DeployedActor Deployable)
{
	if(!bDisableBotOrdering)
		ServerTellBotsToDisarmDeployable(Deployable);
}

reliable server function ServerTellBotsToDisarmDeployable(Rx_Weapon_DeployedActor Deployable)
{
	if(bDisableBotOrdering)
		return;

	Rx_TeamAI(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).RequestDisarm(Self, Deployable);
	bDisableBotOrdering = true;
	SetTimer(1.0,false,'ReEnableBotOrdering');

}

function ReEnableBotOrdering()
{
	bDisableBotOrdering = false;
}

function RemoveSpotTargets(){
	Rx_Hud(MyHUD).NumSpotTargetDots = 0;		
	Rx_Hud(MyHUD).SpotTargets.Remove(0,Rx_Hud(MyHUD).SpotTargets.Length);	
	Rx_Hud(MyHUD).LastSpotTarget = None;
}

function BotSayAffirmativeToplayer() {
	ClientPlaySound(RadioCommands[6]);
	TeamMessage( RespondingBot.playerreplicationinfo, RadioCommandsText[6], 'TeamSay' );
}

function BroadcastBaseDefenseSpotMessages(Rx_Defence DefenceStructure) 
{
	local String msg,TeamColor;
	local int nr;
		
	if(DefenceStructure.GetTeamNum() == TEAM_GDI)
		TeamColor = GDIColor;
	else if(DefenceStructure.GetTeamNum() == TEAM_NOD)
		TeamColor = NodColor;
	else
		TeamColor = ArmourColor;

	if(DefenceStructure.GetTeamNum() == GetTeamNum()) 
	{
		
		
		if(DefenceStructure.GetHealth(0) == DefenceStructure.HealthMax) { 
			msg = "Defend the <font color='"$TeamColor$"'>"@DefenceStructure.GetHumanReadableName()$"</font>!";
			nr = 27;
		}
		else if(DefenceStructure.GetHealth(0) > DefenceStructure.HealthMax/3) {
			msg = "The <font color='"$TeamColor$"'>"@DefenceStructure.GetHumanReadableName()$"</font> needs repair!";
			nr = 0;
		} else {
			msg = "The <font color='"$TeamColor$"'>"@DefenceStructure.GetHumanReadableName()$"</font> needs repair immediately!";	
			nr = 0;
		}	
	} else {
		msg = "Attack the <font color='"$TeamColor$"'>"@DefenceStructure.GetHumanReadableName()$"</font>!"; 
		nr = 20;
	}
	BroadCastSpotMessage(nr, msg);	
}
function BroadcastBuildingSpotMessages(Rx_Building Building) 
{
	local String msg;
	local int nr;
	if(Building.GetTeamNum() == GetTeamNum()) 
	{
		
		if(Building.GetMaxArmor() <= 0) 
		{ /*We're not using armour*/
		
			if(Building.GetHealth() == Building.GetMaxHealth() || Rx_Building_Techbuilding(Building) != none) { 
			
				msg = "Defend the "$Building.GetHumanReadableName()$"!";
			
				if(Rx_Building_Refinery(Building) != None)
					nr = 28;
				else if(Rx_Building_PowerPlant(Building) != None)
					nr = 29;
				else
					nr = 27;

				TellBotsToDefend(Building);
			}
			else 
			{
				if((Building.GetHealth() + Building.GetArmor()) > Building.GetMaxHealth()/3) 
				{
					msg = "The"@Building.GetHumanReadableName()@ "<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair!";
					nr = 0;
				} 
				else 
				{
					msg = "The"@Building.GetHumanReadableName()@ "<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair immediately!";	
					nr = 0;
				}
				TellBotsToRepair(Building);
				

			}
		
		}
		else /*We are using armour*/			
		{ 
		
			if((Building.GetArmor()) == Building.GetMaxArmor() || Rx_Building_Techbuilding(Building) != none) 
			{ 
			
				if(Rx_Building_Techbuilding(Building) != none) 
				{
					msg = "Defend the "$Building.GetHumanReadableName()$"!";
					BroadCastSpotMessage(0, msg);
					return;
				}

				msg = "Defend the"@Building.GetHumanReadableName()@"<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"$"!";
			
				if(Rx_Building_Refinery(Building) != None)
					nr = 28;
				else if(Rx_Building_PowerPlant(Building) != None)
					nr = 29;
				else
					nr = 27;
			}
			else
			{ 
				if((Building.GetArmor()) > Building.GetMaxArmor()/4) 
				{
					msg = "The"@Building.GetHumanReadableName()@"<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair!";
					nr = 0;
				} 
				else 
				{
				msg = "The"@Building.GetHumanReadableName()@"<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair immediately!";	
				nr = 0;
				}

				TellBotsToRepair(Building);
			}
		}
	} 
	else  //Enemy building
	{ 
		if(Rx_Building_Techbuilding(Building) != none)
		{
			msg="Capture the"@Building.GetHumanReadableName()$"!";
			nr=11;
		}
		msg = "Attack the"@Building.GetHumanReadableName()$"!";
		if(Rx_Building_Refinery(Building) != None)
			nr = 23;
		else if(Rx_Building_PowerPlant(Building) != None)
			nr = 24;
		else
			nr = 22;		
	}
	BroadCastSpotMessage(nr, msg);
}

function TellBotsToRepair(Rx_Building Building)
{
	if(!bDisableBotOrdering)
		ServerTellBotsToRepair(Building);
}

reliable server function ServerTellBotsToRepair(Rx_Building Building)
{
	if(bDisableBotOrdering)
		return;

	Rx_TeamAI(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).OnBuildingDefenseRequest(Self,Building);
	bDisableBotOrdering = true;
	SetTimer(1.0,false,'ReEnableBotOrdering');
}

function TellBotsToDefend(Rx_Building Building)
{
	if(!bDisableBotOrdering)
		ServerTellBotsToDefend(Building);
}

reliable server function ServerTellBotsToDefend(Rx_Building Building)
{
	if(bDisableBotOrdering)
		return;

	Rx_TeamAI(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).OnBuildingDefenseRequest(Self,Building);
	bDisableBotOrdering = true;
	SetTimer(1.0,false,'ReEnableBotOrdering');
}


function BroadcastEnemySpotMessages() 
{
	local int i;
	//Adding TS Vehicles (nBab)
	//local int SpottedVehicles[15];
//	local int SpottedVehicles[22];
//	local int SpottedInfs[32]; 
//	local int NumVehicles;
//	local int NumInfs;
	local Actor SpotTarget;
	local Actor FirstSpotTarget;
	local string LocationInfo;
	local string SpottingMsg;
//	local UTPlayerReplicationInfo PRI;
	local Spotted CurrentSpot;
	local Array<Spotted>SpottedList;
	local bool bItemFound;
	//local Pawn P; 

	FirstSpotTarget = Rx_Hud(MyHUD).SpotTargets[0];		
	SpottingMsg = "";
	
	foreach Rx_Hud(MyHUD).SpotTargets(SpotTarget)
	{
		bItemFound = false;

		if(Pawn(SpotTarget) == None || Pawn(SpotTarget).Health <= 0)
			continue;
		if(Pawn(SpotTarget).GetTeamNum() == GetTeamNum())
			continue;	
		if(Rx_Vehicle(SpotTarget) != None && Rx_Vehicle_Harvester(SpotTarget) == None)
		{
//			NumVehicles++;
			
			//Tell the spot target to activate its controller and set its visibility 
			Rx_Vehicle(SpotTarget).SetSpotted(10.0);
/*			
			if(Rx_Vehicle_Humvee(SpotTarget) != None) {
				SpottedVehicles[0]++;
			} else if(Rx_Vehicle_APC_GDI(SpotTarget) != None) {
				SpottedVehicles[1]++;
			} else if(Rx_Vehicle_MRLS(SpotTarget) != None) {
				SpottedVehicles[2]++;
			} else if(Rx_Vehicle_MediumTank(SpotTarget) != None) {
				SpottedVehicles[3]++;
			} else if(Rx_Vehicle_MammothTank(SpotTarget) != None) {
				SpottedVehicles[4]++;
			} else if(Rx_Vehicle_Chinook_GDI(SpotTarget) != None) {
				SpottedVehicles[5]++;
			} else if(Rx_Vehicle_Orca(SpotTarget) != None) {
				SpottedVehicles[6]++;
			} else if(Rx_Vehicle_Buggy(SpotTarget) != None) {
				SpottedVehicles[7]++;
			} else if(Rx_Vehicle_APC_Nod(SpotTarget) != None) {
				SpottedVehicles[8]++;
			} else if(Rx_Vehicle_Artillery(SpotTarget) != None) {
				SpottedVehicles[9]++;
			} else if(Rx_Vehicle_LightTank(SpotTarget) != None) {
				SpottedVehicles[10]++;
			} else if(Rx_Vehicle_FlameTank(SpotTarget) != None) {
				SpottedVehicles[11]++;
			} else if(Rx_Vehicle_StealthTank(SpotTarget) != None) {
				SpottedVehicles[12]++;
			} else if(Rx_Vehicle_Chinook_Nod(SpotTarget) != None) {
				SpottedVehicles[13]++;
			} else if(Rx_Vehicle_Apache(SpotTarget) != None) {
				SpottedVehicles[14]++;
			} else if(TS_Vehicle_Buggy(SpotTarget) != None) {
				SpottedVehicles[15]++;
			} else if(TS_Vehicle_ReconBike(SpotTarget) != None) {
				SpottedVehicles[16]++;
			} else if(TS_Vehicle_TickTank(SpotTarget) != None) {
				SpottedVehicles[17]++;
			} else if(TS_Vehicle_HoverMRLS(SpotTarget) != None) {
				SpottedVehicles[18]++;
			} else if(TS_Vehicle_Wolverine(SpotTarget) != None) {
				SpottedVehicles[19]++;
			} else if(TS_Vehicle_Titan(SpotTarget) != None) {
				SpottedVehicles[20]++;
			} else if(Rx_Vehicle_M2Bradley(SpotTarget) != None) {
				SpottedVehicles[21]++;
			}
*/

			if(SpottedList.length <= 0)
			{
				CurrentSpot.SpottedName = SpotTarget.GetHumanReadableName();
				CurrentSpot.Amount += 1;
				CurrentSpot.Team = SpotTarget.GetTeamNum();
				CurrentSpot.bSpy = Rx_Vehicle(SpotTarget).IsVehicleStolen();	
				if(CurrentSpot.bSpy)
				{
					CurrentSpot.SpottedName = "STOLEN" @ CurrentSpot.SpottedName;
				}			

				SpottedList.AddItem(CurrentSpot);
			}
			else
			{
				for(i=0; i < SpottedList.Length; i++)
				{
					if(IsSpotNameMatching(SpotTarget,SpottedList[i].SpottedName,Rx_Vehicle(SpotTarget).IsVehicleStolen()) && SpottedList[i].Team == SpotTarget.GetTeamNum())
					{
						bItemFound = true;
						SpottedList[i].Amount += 1;
						break;
					}
				}

				if(!bItemFound)
				{
					CurrentSpot.SpottedName = SpotTarget.GetHumanReadableName();
					CurrentSpot.Amount += 1;
					CurrentSpot.Team = SpotTarget.GetTeamNum();
					CurrentSpot.bSpy = Rx_Vehicle(SpotTarget).IsVehicleStolen();	
					if(CurrentSpot.bSpy)
					{
						CurrentSpot.SpottedName = "STOLEN" @ CurrentSpot.SpottedName;
					}	
					SpottedList.AddItem(CurrentSpot);
				}
			}
		}
		
		else if(Rx_Pawn(SpotTarget) != None)
		{

//			NumInfs++;
			if(UTPlayerReplicationInfo(Rx_Pawn(SpotTarget).PlayerReplicationInfo) == None)
				continue; 
//			PRI = UTPlayerReplicationInfo(Rx_Pawn(SpotTarget).PlayerReplicationInfo);
			
			Rx_PRI(Rx_Pawn(SpotTarget).PlayerReplicationInfo).SetSpotted(10.0); 
				if((bCommandSpotting || bPlayerIsCommander()) && SpotTarget == FirstSpotTarget)  
					SetPlayerCommandSpotted(Rx_PRI(Rx_Pawn(SpotTarget).PlayerReplicationInfo).PlayerID); //Rx_PRI(Rx_Pawn(SpotTarget).PlayerReplicationInfo).SetAsTarget(1);
/*			
			if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Soldier') {
				SpottedInfs[0]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Shotgunner') {
				SpottedInfs[1]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Grenadier') {
				SpottedInfs[2]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Marksman') {
				SpottedInfs[3]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Engineer') {
				SpottedInfs[4]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Officer') {
				SpottedInfs[5]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_RocketSoldier') {
				SpottedInfs[6]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_McFarland') {
				SpottedInfs[7]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Deadeye') {
				SpottedInfs[8]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Gunner') {
				SpottedInfs[9]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Patch') {
				SpottedInfs[10]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Havoc') {
				SpottedInfs[11]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Sydney') {
				SpottedInfs[12]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Mobius') {
				SpottedInfs[13]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Hotwire') {
				SpottedInfs[14]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Soldier') {
				SpottedInfs[15]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Shotgunner') {
				SpottedInfs[16]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_FlameTrooper') {
				SpottedInfs[17]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Marksman') {
				SpottedInfs[18]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Engineer') {
				SpottedInfs[19]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Officer') {
				SpottedInfs[20]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_RocketSoldier') {
				SpottedInfs[21]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_ChemicalTrooper') {
				SpottedInfs[22]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_blackhandsniper') {
				SpottedInfs[23]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Stealthblackhand') {
				SpottedInfs[24]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_LaserChainGunner') {
				SpottedInfs[25]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Sakura') {
				SpottedInfs[26]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Raveshaw') {
				SpottedInfs[27]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Mendoza') {
				SpottedInfs[28]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Technician') {
				SpottedInfs[29]++;
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_GDI_Sydney_Suit') {
				SpottedInfs[30]++; 
			} else if(PRI.CharClassInfo == class'Rx_FamilyInfo_Nod_Raveshaw_Mutant') {
				SpottedInfs[31]++;
			}
*/

			if(SpottedList.length <= 0)
			{
				CurrentSpot.SpottedName = Rx_Pawn(SpotTarget).GetCharacterClassName();
				CurrentSpot.Amount = 1;
				CurrentSpot.Team = SpotTarget.GetTeamNum();
				CurrentSpot.bSpy = Rx_PRI(Rx_Pawn(SpotTarget).PlayerReplicationInfo).IsSpy();
				if(CurrentSpot.bSpy)
				{
					CurrentSpot.SpottedName = "SPY" @ CurrentSpot.SpottedName;
				}

				SpottedList.AddItem(CurrentSpot);
			}
			else
			{
				for(i=0; i < SpottedList.Length; i++)
				{
					if(IsSpotNameMatching(SpotTarget,SpottedList[i].SpottedName,Rx_PRI(Rx_Pawn(SpotTarget).PlayerReplicationInfo).IsSpy()) && SpottedList[i].Team == SpotTarget.GetTeamNum())
					{
						bItemFound = true;
						SpottedList[i].Amount += 1;
						break;
					}
				}

				if(!bItemFound)
				{
					CurrentSpot.SpottedName = Rx_Pawn(SpotTarget).GetCharacterClassName();
					CurrentSpot.Amount = 1;
					CurrentSpot.Team = SpotTarget.GetTeamNum();
					CurrentSpot.bSpy = Rx_Vehicle(SpotTarget).IsVehicleStolen();	
					if(CurrentSpot.bSpy)
					{
						CurrentSpot.SpottedName = "STOLEN" @ CurrentSpot.SpottedName;
					}	

					SpottedList.AddItem(CurrentSpot);
				}
			}
		}
			
		if (Rx_Pawn(SpotTarget) != none)
		{
			SetPlayerSpotted(Rx_Pawn(SpotTarget).PlayerReplicationInfo.PlayerID);
		}
		else if (Rx_Vehicle(SpotTarget) != none && (Rx_PRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo) != none || Rx_DefencePRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo) != none))
		{
			if(Rx_PRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo) != none)
			{
				//`log("Set Vehicle Spotted");
				SetPlayerSpotted(Rx_PRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo).PlayerID );
				if((bCommandSpotting || bPlayerIsCommander()) && SpotTarget == FirstSpotTarget) 
					SetPlayerCommandSpotted(Rx_PRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo).PlayerID); //Rx_PRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo).SetAsTarget(1);
			}
			else
			if(Rx_DefencePRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo) != none)
			{
				//`log("Set Defense Spotted");
				SetPlayerSpotted(Rx_DefencePRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo).PlayerID);
				
				if((bCommandSpotting || bPlayerIsCommander()) && SpotTarget == FirstSpotTarget) 
					SetPlayerCommandSpotted(Rx_DefencePRI(Rx_Vehicle(SpotTarget).PlayerReplicationInfo).PlayerID);
			}
			/**foreach WorldInfo.AllPawns(class'Pawn', P)
			{
				if(P.DrivenVehicle == Rx_Vehicle(SpotTarget))
					SetPlayerSpotted(P.PlayerReplicationInfo.PlayerID);		
			}*/
			
		}
	}

	//to prevent blank spotting, cancel out if none is found
	if(SpottedList.Length <= 0)
		return;
	
	//Moved uppies
	//FirstSpotTarget = Rx_Hud(MyHUD).SpotTargets[0];
	
	if(BuildingActorIsIn(FirstSpotTarget) != None)
		LocationInfo = "INSIDE"@Rx_Building(FirstSpotTarget).GetHumanReadableName();
	else
		LocationInfo = GetSpottargetLocationInfo(FirstSpotTarget);
	
	if(numberOfRadioCommandsLastXSeconds++ > 5) 
	{
		spotMessagesBlocked = true;
		SetTimer(2.5, false, 'resetSpotMessageCountTimer'); //5.0 seconds is REALLY annoying and sometimes game breaking. 	
	}
/*	if(NumVehicles > 0)
	{
		for(i=20; i>=0; i--)
		{
			if(j > 5)
				break;
			if(SpottedVehicles[i] > 0)
				j++;
			if(i==0 && SpottedVehicles[0] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedVehicles[0] @ "Humvee</font>";
			else if(i==1 && SpottedVehicles[1] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedVehicles[1] @ "APC</font>";				
			else if(i==2 && SpottedVehicles[2] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedVehicles[2] @ "MRLS</font>";				
			else if(i==3 && SpottedVehicles[3] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedVehicles[3] @ "Medium Tank</font>";				
			else if(i==4 && SpottedVehicles[4] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedVehicles[4] @ "Mammoth Tank</font>";				
			else if(i==5 && SpottedVehicles[5] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedVehicles[5] @ "Chinook</font>";				
			else if(i==6 && SpottedVehicles[6] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedVehicles[6] @ "Orca</font>";				
			else if(i==7 && SpottedVehicles[7] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[7] @ "Buggy</font>";				
			else if(i==8 && SpottedVehicles[8] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[8] @ "APC</font>";				
			else if(i==9 && SpottedVehicles[9] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[9] @ "Artillery</font>";				
			else if(i==10 && SpottedVehicles[10] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[10] @ "Light Tank</font>";				
			else if(i==11 && SpottedVehicles[11] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[11] @ "Flame Tank</font>";				
			else if(i==12 && SpottedVehicles[12] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[12] @ "Stealth Tank</font>";				
			else if(i==13 && SpottedVehicles[13] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[13] @ "Chinook</font>";				
			else if(i==14 && SpottedVehicles[14] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[14] @ "Apache</font>";
			else if(i==15 && SpottedVehicles[15] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedVehicles[15] @ "Attack Buggy</font>";
			else if(i==16 && SpottedVehicles[16] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedVehicles[16] @ "Attack Cycle</font>";
			else if(i==17 && SpottedVehicles[17] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedVehicles[17] @ "Tick Tank</font>";
			else if(i==18 && SpottedVehicles[18] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedVehicles[18] @ "Hover MRLS</font>";
			else if(i==19 && SpottedVehicles[19] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedVehicles[19] @ "Wolverine</font>";
			else if(i==20 && SpottedVehicles[20] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedVehicles[20] @ "Titan</font>";
			else if(i==21 && SpottedVehicles[21] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedVehicles[21] @ "Light Tank [M2]</font>";
			
			if(SpottedVehicles[i] > 1)
				SpottingMsg = SpottingMsg @ "s";	
			if(SpottedVehicles[i] > 0 && (NumInfs+NumVehicles) > j)
				SpottingMsg = SpottingMsg @ ",";								
		}
	}
	
	if(NumInfs > 0)
	{
		for(i=31; i>=0; i--)
		{
			if(j > 5)
				break;
			if(SpottedInfs[i] > 0)
				j++;
						
			if(i==0 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedInfs[i] @ "Soldier</font>";		
			else if(i==1 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $ SpottedInfs[i] @ "Shotgunner </font>";					
			else if(i==2 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Grenadier</font>";					
			else if(i==3 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Marksman</font>";					
			else if(i==4 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Engineer</font>";					
			else if(i==5 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Officer</font>";					
			else if(i==6 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Rocket Soldier</font>";					
			else if(i==7 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "McFarland</font>";					
			else if(i==8 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Deadeye</font>";					
			else if(i==9 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Gunner</font>";					
			else if(i==10 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Patch</font>";					
			else if(i==11 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Havoc</font>";					
			else if(i==12 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Sydney</font>";					
			else if(i==13 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Mobius</font>";					
			else if(i==14 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Hotwire</font>";					
			else if(i==15 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedInfs[i] @ "Soldier</font>";					
			else if(i==16 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $ SpottedInfs[i] @ "Shotgunner</font>";					
			else if(i==17 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Flame Trooper</font>";					
			else if(i==18 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Marksman</font>";					
			else if(i==19 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Engineer</font>";					
			else if(i==20 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Officer</font>";					
			else if(i==21 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Rocket Soldier</font>";					
			else if(i==22 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Chemical Trooper</font>";					
			else if(i==23 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Black Hand Sniper</font>";					
			else if(i==24 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Stealth Black Hand</font>";					
			else if(i==25 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Laser Chain Gunner</font>";					
			else if(i==26 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Sakura</font>";					
			else if(i==27 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Raveshaw</font>";					
			else if(i==28 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Mendoza</font>";					
			else if(i==29 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Technician</font>";
			else if(i==30 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $GDIColor$ "'>" $  SpottedInfs[i] @ "Sydney [EPIC]</font>";	
			else if(i==31 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg $  "<font color ='" $NodColor$ "'>" $  SpottedInfs[i] @ "Raveshaw [EPIC]</font>";	
				
			if(SpottedInfs[i] > 1)
				SpottingMsg = SpottingMsg @ "s";				
			if(SpottedInfs[i] > 0 && (NumInfs+NumVehicles) > j)
				SpottingMsg = SpottingMsg @ ",";												
		}
	}	
*/

	if(SpottedList.Length == 1)
	{
		if(SpottedList[0].Amount > 1)
			SpottedList[0].SpottedName $= "s";

		if(SpottedList[0].Team == 0 || (SpottedList[0].bSpy && GetTeamNum() == TEAM_GDI))
		{
				SpottingMsg =  SpottingMsg $ "<font color ='" $GDIColor$ "'>" $ SpottedList[0].Amount @ SpottedList[0].SpottedName $ "</font>";
		}
		else if(SpottedList[0].Team == 1 || (SpottedList[0].bSpy && GetTeamNum() == TEAM_NOD))
		{
			SpottingMsg =  SpottingMsg $ "<font color ='" $NodColor$ "'>" $ SpottedList[0].Amount @ SpottedList[0].SpottedName $ "</font>";
		}
	}
	else if(SpottedList.Length > 1)
	{
		for(i=0; i<6; i++)
		{
			if(SpottedList[i].Amount <= 0)
				break;

			if(SpottedList[i].Amount > 1)
				SpottedList[i].SpottedName $= "s";

			if(SpottedList[i].bSpy)
			{
				if(GetTeamNum() == TEAM_GDI)
				{
					if(i < SpottedList.Length - 1)
						SpottingMsg =  SpottingMsg $ "<font color ='" $GDIColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>, ";
					else
						SpottingMsg =  SpottingMsg $ "and <font color ='" $GDIColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>";
				}
				else
				{
					if(i < SpottedList.Length - 1)
						SpottingMsg =  SpottingMsg $ "<font color ='" $NodColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>, ";
					else
						SpottingMsg =  SpottingMsg $ "and <font color ='" $NodColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>";
					
				}
			}
			else
			{
				if(SpottedList[i].Team == 0)
				{
					if(i < SpottedList.Length - 1)
						SpottingMsg =  SpottingMsg $ "<font color ='" $GDIColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>, ";
					else
						SpottingMsg =  SpottingMsg $ "and <font color ='" $GDIColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>";
				}
				else
				{	if(i < SpottedList.Length - 1)
						SpottingMsg =  SpottingMsg $ "<font color ='" $NodColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>, ";
					else
						SpottingMsg =  SpottingMsg $ "and <font color ='" $NodColor$ "'>" $ SpottedList[i].Amount @ SpottedList[i].SpottedName $ "</font>";
				}
			}
		}
	}

	if( (SpottedList.Length) > 6)
		SpottingMsg = SpottingMsg @ " and more"; 
	if(Rx_Vehicle(FirstSpotTarget) != none && bFocusSpotting && SpottedList.Length == 1) 
	{
		BroadCastSpotMessage(3, "FOCUS FIRE:"@SpottingMsg@LocationInfo);
		if(Rx_PRI(Rx_Vehicle(FirstSpotTarget).PlayerReplicationInfo) != none) 
			SetPlayerFocused(Rx_PRI(Rx_Vehicle(FirstSpotTarget).PlayerReplicationInfo).PlayerID);

		TellNearbyBotsToFocusFire(Pawn(FirstSpotTarget));
	}
	else if(Rx_Pawn(FirstSpotTarget) != none && bFocusSpotting && SpottedList.Length == 1)
	{
		BroadCastSpotMessage(19, "FOCUS FIRE:"@SpottingMsg@LocationInfo);
		if(Rx_PRI(Rx_Pawn(FirstSpotTarget).PlayerReplicationInfo) != none) 
			SetPlayerFocused(Rx_PRI(Rx_Pawn(FirstSpotTarget).PlayerReplicationInfo).PlayerID);
	
		TellNearbyBotsToFocusFire(Pawn(FirstSpotTarget));
	}	
	else
		BroadCastSpotMessage(9, "Spotted"@SpottingMsg@LocationInfo);	
}

function bool IsSpotNameMatching(Actor SpottedActor, String StringCheck, bool bSpottedIsSpy)
{
	local Rx_Pawn P;
	local Rx_Vehicle V;
	local string ActualSpotName;

	if(Rx_Pawn(SpottedActor) != None)
		P = Rx_Pawn(SpottedActor);
	else if (Rx_Vehicle(SpottedActor) != None)
		V = Rx_Vehicle(SpottedActor);
	else
		return false;		// Invalid spotting


	if(V != None)
	{
		if(bSpottedIsSpy)
			ActualSpotName = "STOLEN"@V.GetHumanReadableName();

		else
			ActualSpotName = V.GetHumanReadableName();
	}
	else if (P != None)
	{
		if(bSpottedIsSpy)
			ActualSpotName = "SPY"@P.GetCharacterClassName();

		else
			ActualSpotName = P.GetCharacterClassName();

	}

	return (StringCheck == ActualSpotName);

}

reliable server function TellNearbyBotsToFocusFire(Pawn Target)
{
	local Rx_Bot B;
	
	if(Target.GetTeamNum() == GetTeamNum())
		return;

	if(Rx_TeamInfo(PlayerReplicationInfo.Team).AI.Squads != None) // If there's no bots in team, ignore everything to save up performance
	{
		foreach WorldInfo.AllControllers(class'Rx_Bot',B)
		{
			if(B.GetTeamNum() == GetTeamNum() && (VSizeSq(Pawn.Location - B.Pawn.Location) <= 2250000 || B.CanAttack(Target)))
			B.OnFocusFire(Self, Target);
		}
	}
}

function string GetSpottargetLocationInfo(Actor FirstSpotTarget) 
{
	local string LocationInfo;
	local Rx_GRI WGRI;
	local RxIfc_SpotMarker SpotMarker;
	local Actor TempActor;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	
	WGRI = Rx_GRI(WorldInfo.GRI);
	
	if(WGRI == none) return "";
	
	foreach WGRI.SpottingArray(TempActor) {
		SpotMarker = RxIfc_SpotMarker(TempActor);
		DistToSpot = VSizeSq(TempActor.location - FirstSpotTarget.location);
		if(NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist) {
			NearestSpotDist = DistToSpot;	
			NearestSpotMarker = SpotMarker;
		}
	}
	
	if(BuildingActorIsIn(FirstSpotTarget) != None)
		LocationInfo = "INSIDE"@Rx_Building(FirstSpotTarget).GetHumanReadableName();
	else
		LocationInfo = "near"@NearestSpotMarker.GetSpotName();		
	return LocationInfo;
}

function Rx_Building BuildingActorIsIn(Actor TraceActor) 
{
	local Vector TraceStart;
	local Vector TraceEnd;
	local Vector TraceExtent;
	local Vector OutHitLocation, OutHitNormal;
	local TraceHitInfo HitInfo;
	local Actor theBuilding;
	
	TraceStart = TraceActor.Location;
	TraceEnd = TraceActor.Location;
	TraceEnd.Z += 400.0f;
	// trace up and see if we are hitting a building ceiling  
	theBuilding = TraceActor.Trace(OutHitLocation, OutHitNormal, TraceEnd, TraceStart, TRUE, TraceExtent, HitInfo, TRACEFLAG_Bullet);
	if(Rx_Building(theBuilding) != None)
		return Rx_Building(TraceActor);
	else
		return None;
}

exec function ReloadWeapon()
{
   	local Rx_Vehicle_Weapon VehWeap;
   	
   	if (Pawn != none && Pawn.Weapon != none && Rx_Weapon_Reloadable(Pawn.Weapon) != none) 
   	{
		if (Rx_Weapon_Reloadable(Pawn.Weapon).IsInState('WeaponFiring'))
			return;
		if (Rx_Weapon_Reloadable(Pawn.Weapon).IsReloading()) {
			return;
		}
      	Rx_Weapon_Reloadable(Pawn.Weapon).ReloadWeapon();
	}
      	/**if (WorldInfo.NetMode == NM_Client) 
      	{ 
         	ServerDoReloadWeapon();
     	}
   	} else*/ 
		
		if (Rx_VehicleSeatPawn(Pawn) != none) {
			VehWeap = Rx_Vehicle_Weapon(Rx_VehicleSeatPawn(Pawn).MyVehicleWeapon);
		} 
		else if (Rx_Vehicle(Pawn) != none)
		{
	   		VehWeap = Rx_Vehicle_Weapon(Rx_Vehicle(Pawn).Seats[0].Gun);
		}
	   	if(Rx_Vehicle_Weapon_Reloadable(VehWeap) == None && Rx_Vehicle_MultiWeapon(VehWeap) == None)
	   		return;
	   	if((Rx_Vehicle(Pawn) != none || Rx_Vehicle(Rx_VehicleSeatPawn(Pawn).MyVehicle) != none) && VehWeap != none && !VehWeap.bReloadAfterEveryShot && !VehWeap.IsInState('WeaponFiring')) 
	   	{
			//[REDACTED CODE WUZ HUR]
			
			 DoReloadWeapon(); //ServerDoReloadWeapon();
		}
	
}

// keeps track off if a forward move direction button is pressed 
exec function ChangeForwardButtonPressedStatus(bool status)
{
	bMoveForwardButtonPressed = status;
}

// get executed when a dodge direction button is pressed. 
exec function DodgeDirectionButtonPressed(DodgeDirections dir)
{
	if (pressedDodgeDirection != EMPTY)
		bDodgeDirectionButtonPressed = true;

	pressedDodgeDirection = dir;
}

exec function RemoveDodgeDirection()
{
	if(bDodgeDirectionButtonPressed)
	{
		bDodgeDirectionButtonPressed = false;
		return;
	}
	else if(pressedDodgeDirection != EMPTY)
		pressedDodgeDirection = EMPTY;
}

exec function SetDodgePressed()
{
	bDodgePressed = true; 
}

function bool TryDodge()
{
	local vector2D DodgeVector; 
	
	DodgeVector.X = PlayerInput.aForward; 
	DodgeVector.Y = PlayerInput.aStrafe; 
	
	//Strafing.... right? 
	if(DodgeVector.X > 0) 
	{
		return UTPawn(Pawn).Dodge(DCLICK_Forward);
	}
	else if(DodgeVector.X < 0){
		//Dodge Left
		return UTPawn(Pawn).Dodge(DCLICK_Back);
	}
	else if(DodgeVector.Y > 0) 
	{
		//Walking Forward 
		return UTPawn(Pawn).Dodge(DCLICK_Right);
	}
	else if(DodgeVector.Y < 0){
		//Dodge Back
		return UTPawn(Pawn).Dodge(DCLICK_Left);
	}
	
	return false; 
}

exec function EnableOneClickDodge()
{
	if (!bCanOneClickDodge)
		bCanOneClickDodge = true;
}

exec function DisableOneClickDodge()
{	
	if(bCanOneClickDodge)
		bCanOneClickDodge = false;
}

/*TODO: Add info box, ala Commander Mod*/
exec function OpenInfoBox(); 

exec function CloseInfoBox();

/*Possible exec functions that will come with the Commander Mod*/
exec function OpenCommandWindow();

exec function CloseCommandWindow();

/*Taunt Button*/

exec function OpenTauntMenu()
{
	
	if(Com_Menu != none || VoteHandler != none)
		return; 
	
	if(!bCanTaunt) 
	{
		ClientPlaySound(WeaponSwitchSoundCue); 
		return; 	
	}
	if(bTauntMenuOpen)	
		bTauntMenuOpen=false;
	else 
		if(!bTauntMenuOpen)	
			bTauntMenuOpen=true;	
}

exec function CloseTauntMenu()
{}

/**Overview Map*/
exec function ToggleOverviewMap()
{
	if(WorldInfo.GRI != None && WorldInfo.GRI.bMatchIsOver) 
		return;
	Rx_Hud(MyHUD).ToggleOverviewMap();
}

// checks if it is possible to one click dodge and if it is possible returns the direction
function eDoubleClickDir CheckForOneClickDodge()
{
	local eDoubleClickDir oneClickDodgeDirection;
	
	if(pressedDodgeDirection != EMPTY && bCanOneClickDodge && !bMoveForwardButtonPressed && Pawn != none)
	{	
		switch (pressedDodgeDirection) 
		{
			case BACKWARD:
				oneClickDodgeDirection = DCLICK_Back;
			break;	
		
			case LEFT:
				oneClickDodgeDirection = DCLICK_Left;
		  	break;
		  
			case RIGHT:
				oneClickDodgeDirection = DCLICK_Right;
			break;
								  
		  default:
			`log("ERROR: Unknown direction argument, DodgeCheck");
		}	
   	}

	return oneClickDodgeDirection;
}

simulated function DoReloadWeapon() //Log information for debugging reload bug (commented out)8AUG2015 reliable server function ServerDoReloadWeapon
{
	local Rx_Vehicle_Weapon_Reloadable vehWeapon;
	//`log("DoReloadWeapon"); 
	if (Pawn != none && Pawn.Weapon != none && Rx_Weapon_Reloadable(Pawn.Weapon) != none) 
	{
		Rx_Weapon_Reloadable(Pawn.Weapon).ReloadWeapon(); 
		//`log("DID BAD RELOAD");
	}
   	else if(Rx_Vehicle(Pawn) != none && Rx_Vehicle_Weapon_Reloadable(Rx_Vehicle(Pawn).Seats[0].Gun) != none) 
   	{
		//`log("Problems may occur as this is not a reloadable weapon");
		vehWeapon = Rx_Vehicle_Weapon_Reloadable(Rx_Vehicle(Pawn).Seats[0].Gun);
		//`log(vehWeapon); 
		if(vehWeapon.IsReloading() == false) 
		{
			//`log("Did Reload for reloadable weapon");
   			vehWeapon.ReloadWeapon();
		}
   	}
   	else if(Rx_Vehicle(Rx_VehicleSeatPawn(Pawn).MyVehicle) != none && Rx_Vehicle_Weapon_Reloadable(Rx_VehicleSeatPawn(Pawn).MyVehicleWeapon) != none) 
   	{
		vehWeapon = Rx_Vehicle_Weapon_Reloadable(Rx_VehicleSeatPawn(Pawn).MyVehicleWeapon);
		if(vehWeapon.IsReloading() == false) 
		{
			//`log("DID BAD RELOAD");
   			vehWeapon.ReloadWeapon();
		}
   	}
   	else if (Rx_Vehicle(Pawn) != none && Rx_Vehicle_MultiWeapon(Rx_Vehicle(Pawn).Seats[0].Gun) != none)
   	{
		//`log("DID GOOD RELOAD ServerSide");
		 Rx_Vehicle_MultiWeapon(Rx_Vehicle(Pawn).Seats[0].Gun).PlayerRelaod();
   	}
}

function AcknowledgePossession(Pawn P)
{
	local rotator NewViewRotation;

	Super(UDKPlayerController).AcknowledgePossession(P);

	if ( LocalPlayer(Player) != None )
	{
		ClientEndZoom();
		if (bUseVehicleRotationOnPossess && Vehicle(P) != None && UTWeaponPawn(P) == None)
		{
			NewViewRotation = P.Rotation;
			NewViewRotation.Roll = 0;
			SetRotation(NewViewRotation);
		}
		ServerPlayerPreferences(WeaponHandPreference, bAutoTaunt, bCenteredWeaponFire, AutoObjectivePreference, VehicleControlType);
	}

	SetHand(WeaponHandPreference);
	
}

/**
 * ToggleCamera - toggle between 3rd and 1st cam modes
 */
exec function ToggleCam()
{
	local Rx_Vehicle vehicle;
	local Vector LocationLookedAtBeforeSwitch;
	local vector ViewLocationTemp;
	local rotator ViewRotationTemp;	
	local float fov;
	
	LocationLookedAtBeforeSwitch = LookedAtLocation();
	vehicle = Rx_Vehicle(Pawn);
	if(vehicle != none) {
		vehicle.ToggleCam();
	}
	else 
	{
		SetBehindView(!bBehindView);
		if(bBehindView) {
			camMode = CameraMode.ThirdPerson;
		} else {
			camMode = CameraMode.FirstPerson;
		}
		ResetRepGunEmitters();
	}
	
	GetPlayerViewPoint(ViewLocationTemp, ViewRotationTemp);	
	if(bBehindView && Rx_Pawn(Pawn) != None)
	{
	//ViewLocationTemp = ViewLocationTemp + ViewRotationTemp * VSize(ViewLocationTemp - ViewTarget.Location);
	Rx_Pawn(Pawn).CalcThirdPersonCam(0,ViewLocationTemp,ViewRotationTemp,fov);  		
	}
		
	SetRotation(rotator(LocationLookedAtBeforeSwitch - ViewLocationTemp));
	
	//Adjust a second time for more precision since the first time also dislocated ViewLocationTemp a bit due to camera pivoting
	GetPlayerViewPoint(ViewLocationTemp, ViewRotationTemp);
	if(bBehindView && Rx_Pawn(Pawn) != None) Rx_Pawn(Pawn).CalcThirdPersonCam(0,ViewLocationTemp,ViewRotationTemp,fov);  	
	SetRotation(rotator(LocationLookedAtBeforeSwitch - ViewLocationTemp));
	
	}

function SetOurCameraMode(CameraMode newCameraMode) {
	if(Pawn != none && (Rx_Weapon(Pawn.Weapon) != None && Rx_Weapon(Pawn.Weapon).bIronsightActivated))
		return;
	camMode = newCameraMode;
	if(camMode == ThirdPerson) {
		SetBehindView(true);
	} else {
		SetBehindView(false);
	}
	ResetRepGunEmitters();
}


function Vector LookedAtLocation()
{
	local Vector CameraOrigin, CameraDirection, HitLoc,HitNormal,TraceEnd;
	local rotator CameraDirectionRot;
	//local float extendedDist;
	local Actor HitActor;
	
	GetPlayerViewPoint(CameraOrigin,CameraDirectionRot);
	CameraDirection = vector(CameraDirectionRot);
	
	CameraOrigin = CameraOrigin + vector(CameraDirectionRot) *  VSize(CameraOrigin - ViewTarget.location);
	
	TraceEnd = CameraOrigin + CameraDirection * 10000;
	//extendedDist = VSize(CameraOrigin - ViewTarget.location);
	//TraceEnd += CameraDirection * extendedDist;

	foreach TraceActors(class'actor',HitActor,HitLoc,HitNormal,TraceEnd,CameraOrigin,vect(0,0,0),,1)
	{
		if (HitActor != ViewTarget)
			break;
	}
	if(HitActor == None)
		HitLoc = TraceEnd;
	return TraceEnd; //HitLoc;
}


simulated function SetBehindView(bool bNewBehindView) //Originally not simulated 
{
	if(Pawn == None && !IsInState('Spectating'))
		return;
	if(Rx_Weapon(Pawn.Weapon) != None && (Rx_Weapon(Pawn.Weapon).bIronsightActivated || (Rx_Weapon_Scoped(Pawn.Weapon) != None && bZoomed)) )
		return;	
	super.SetBehindView(bNewBehindView);
	if(Pawn != None && Rx_Weapon(Pawn.Weapon) != None && Rx_Weapon(Pawn.Weapon).bIronsightActivated) {
		if(!bNewBehindView) {
			Rx_Weapon(Pawn.Weapon).FireOffset=Rx_Weapon(Pawn.Weapon).IronSightFireOffset;	
			if(!Rx_Weapon(Pawn.Weapon).bDisplayCrosshairInIronsight) {
				Rx_Weapon(Pawn.Weapon).bDisplayCrosshair = false;	
			}
		} else {
			Rx_Weapon(Pawn.Weapon).FireOffset=Rx_Weapon(Pawn.Weapon).default.FireOffset;
			Rx_Weapon(Pawn.Weapon).bDisplayCrosshair = true;
		}
	}
	if(!bNewBehindView && Pawn != None && Rx_Weapon(Pawn.Weapon) != None && Rx_Pawn(Pawn).bSprinting)
	{
		SetTimer(0.01,false,'EnableRunningAnimsTimer');
	} 
	if(WorldInfo.NetMode == NM_Client) {
		ServerSetBehindView(bNewBehindView);
	}
}

function EnableRunningAnimsTimer()
{
	Rx_Weapon(Pawn.weapon).PlayWeaponAnimation(Rx_Pawn(pawn).WeaponSprintAnim, 0.0,true);
	Rx_Weapon(Pawn.weapon).PlayArmAnimation(Rx_Pawn(pawn).WeaponSprintAnim, 0.0,,true);		
}

reliable server function ServerSetBehindView(bool bNewBehindView)
{
	bBehindView = bNewBehindView;
}


// Removes the log beep sounds ingame
simulated function PlayBeepSound()
{
	// PlaySound(SoundCue'A_Gameplay.Gameplay.MessageBeepCue', false);
} 

simulated function UTWeapon GetPrevWeapon(UTWeapon CurWeapon)
{
	return GetWeapon(-1);
}

simulated function UTWeapon GetNextWeapon(UTWeapon CurWeapon)
{
	return GetWeapon(1);
}

simulated function UTWeapon GetWeapon(int Direction)
{
	local Rx_InventoryManager invManager;
	local UTWeapon	CurrentWeapon;
	local array<UTWeapon> WeaponList;
	local int i, Index;	
	
	invManager = Rx_InventoryManager(Pawn.InvManager); 

	if (invManager == none)
		return none;
	
	CurrentWeapon = UTWeapon(Pawn.Weapon);	

	//scripttrace();
	
   	invManager.GetWeaponList(WeaponList,,, false);
   	if (WeaponList.length == 0)   	
   		return None;

	
	for (i = 0; i < WeaponList.Length; i++)
	{
		if (WeaponList[i] == CurrentWeapon)
		{
			Index = i;
			break;
		}
	}
	Index += Direction*-1;

	if (Index < 0)	
		Index = WeaponList.Length - 1;	

	else if (Index >= WeaponList.Length || Rx_WeaponAbility(CurrentWeapon) != none)
		Index = 0;	
	
	if (Index >= 0)
		return WeaponList[Index];
	return None;	
}

function FixFOV()
{
	//`log('---RUN FIX FOV---');
	if ( OnFootDefaultFOV < 40 )
	{
		OnFootDefaultFOV = 80.0;
	}
	OnFootDefaultFOV = FClamp(OnFootDefaultFOV, 40, 120);
	FOVAngle = OnFootDefaultFOV;
	DesiredFOV = OnFootDefaultFOV;
	DefaultFOV = OnFootDefaultFOV;
}

// Conduit to access the purchase system server side
reliable server function ServerPurchaseCharacter(class<Rx_FamilyInfo> CharacterClass, Rx_BuildingAttachment_PT PT)
{
	if (ValidPTUse(PT))
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseCharacter(self,GetTeamNum(),CharacterClass);
}

reliable server function ServerPurchaseWeapon(int CharID, Rx_BuildingAttachment_PT PT)
{
	if (ValidPTUse(PT))
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseWeapon(self,GetTeamNum(),CharID);
}

reliable server function ServerPurchaseItem(int CharID, Rx_BuildingAttachment_PT PT)
{
	if (ValidPTUse(PT))
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseItem(self,GetTeamNum(),CharID);
}

reliable server function ServerPurchaseVehicle(int VehicleID, Rx_BuildingAttachment_PT PT )
{
	if (ValidPTUse(PT))
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseVehicle(Rx_PRI(PlayerReplicationInfo),GetTeamNum(),VehicleID);
}

reliable server function ServerPerformRefill(Rx_BuildingAttachment_PT PT)
{
	if (ValidPTUse(PT))
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PerformRefill(self);
}

function SetPlayerSpotted( int playerID )
{
	//loginternal("client spotted"$playerID);
	ServerSetPlayerSpotted(playerID);	
}

function SetPlayerFocused(int PlayerID)
{
loginternal("client focused"$playerID);
	ServerSetPlayerFocused(playerID);		
}

reliable server function ServerSetPlayerFocused( int playerID )
{
	local int i;

	//loginternal("server Focused"$playerID);
	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(Rx_Pri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (WorldInfo.GRI.PRIArray[i].PlayerID == playerID)
			{
				Rx_Pri(WorldInfo.GRI.PRIArray[i]).SetFocused();
				return;
			}
		}
		else
		if(Rx_DefencePri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).Defence_ID == playerID)
			{
				Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).SetFocused();
				return;
			}
		}
		else
		continue;
	}
}

reliable server function ServerSetPlayerSpotted( int playerID )
{
	local int i;

	//loginternal("server spotted"$playerID);
	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(Rx_Pri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (WorldInfo.GRI.PRIArray[i].PlayerID == playerID)
			{
				Rx_Pri(WorldInfo.GRI.PRIArray[i]).SetSpotted(10.0);
				return;
			}
		}
		else
		if(Rx_DefencePri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).Defence_ID == playerID)
			{
				Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).SetSpotted(10.0);
				return;
			}
		}
		else
		continue;
	}
}

function SetPlayerCommandSpotted( int playerID )
{
	ServerSetPlayerCommandSpotted(playerID);	
}

reliable server function ServerSetPlayerCommandSpotted(int playerID) //Use Defence_ID for RX_Defences, since they don't have player IDs
{
		local int i;

	//loginternal("server Command spotted"$playerID);
	
	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(Rx_Pri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (WorldInfo.GRI.PRIArray[i].PlayerID == playerID)
			{
				Rx_Pri(WorldInfo.GRI.PRIArray[i]).SetAsTarget(1);
				return;
			}
		}
		else
		if(Rx_DefencePri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).Defence_ID == playerID)
			{
				Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).SetAsTarget(1);
				return;
			}
		}
		else
		continue; 
		
	}
}


function PurchaseCharacter(int teamnum, class<Rx_FamilyInfo> CharacterClass)
{
	if (Role == ROLE_Authority)
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseCharacter(self,teamnum,CharacterClass);
	else
		ServerPurchaseCharacter(CharacterClass,PTUsed);
}

function AddPurchaseTransaction(int teamnum, int CharID)
{
	local Rx_PurchaseSystem rxPurchaseSystem;

	rxPurchaseSystem = (WorldInfo.NetMode == NM_StandAlone || (WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) ) 
			? Rx_Game(WorldInfo.Game).PurchaseSystem 
			: Rx_GRI(WorldInfo.GRI).PurchaseSystem ;

	if (CharID < 4) {
		if (PreviousSidearmTransactionRecords.Find(rxPurchaseSystem.GetWeaponClass(teamnum, CharID)) == -1) {
			PreviousSidearmTransactionRecords.AddItem(rxPurchaseSystem.GetWeaponClass(teamnum, CharID));
		} else {
			PreviousSidearmTransactionRecords.RemoveItem(rxPurchaseSystem.GetWeaponClass(teamnum, CharID));
			PreviousSidearmTransactionRecords.AddItem(rxPurchaseSystem.GetWeaponClass(teamnum, CharID));
		}
		CurrentSidearmWeapon = rxPurchaseSystem.GetWeaponClass(teamnum, CharID);
	} else {
		if (PreviousExplosiveTransactionRecords.Find(rxPurchaseSystem.GetWeaponClass(teamnum, CharID)) == -1) {
			PreviousExplosiveTransactionRecords.AddItem(rxPurchaseSystem.GetWeaponClass(teamnum, CharID));
		} else {
			PreviousExplosiveTransactionRecords.RemoveItem(rxPurchaseSystem.GetWeaponClass(teamnum, CharID));
			PreviousExplosiveTransactionRecords.AddItem(rxPurchaseSystem.GetWeaponClass(teamnum, CharID));
		}
		`log("#### rxPurchaseSystem.GetWeaponClass(teamnum, CharID) " $ rxPurchaseSystem.GetWeaponClass(teamnum, CharID));
		CurrentExplosiveWeapon = rxPurchaseSystem.GetWeaponClass(teamnum, CharID);
	}
}

function PurchaseWeapon(int teamnum, int CharID)
{
	AddPurchaseTransaction(teamnum, CharID);

	if(Role == ROLE_Authority)
	{
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseWeapon(self,teamnum,CharID);
		return;
	}

	ServerPurchaseWeapon(CharID,PTUsed);
}

function PurchaseItem(int teamnum, int CharID)
{
	if(Role == ROLE_Authority)
	{
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseItem(self,teamnum,CharID);
		return;
	}
//
	ServerPurchaseItem(CharID,PTUsed);
}

function PurchaseVehicle( int TeamNum, int VehicleID )
{
	if ( Role == ROLE_Authority )
	{
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseVehicle(Rx_PRI(PlayerReplicationInfo),TeamNum,VehicleID);
		return;
	}

	ServerPurchaseVehicle(VehicleID,PTUsed);
}

function PerformRefill( Rx_Controller cont )
{	
	if ( Role == ROLE_Authority )
	{
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PerformRefill(cont);
		return;
	}
	ServerPerformRefill(PTUsed);
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;

	Super(UDKPlayerController).NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

	iDam = Clamp(Damage,0,250);
	if ( (iDam > 0 || bGodMode) && (Pawn != None) )
	{
		if(class<Rx_DmgType_Explosive>(damageType) != None)
		    ClientPlayTakeHit(hitLocation - Pawn.Location, iDam, damageType);
		else
		    ClientPlayTakeHit(InstigatedBy.Pawn.Location - Pawn.Location, iDam, damageType);
	}
}

unreliable client function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> DamageType)
{
	DamageShake(Damage, DamageType);
	
	HitLoc += Pawn.Location;
	if(class<Rx_DmgType_Explosive>(damageType) == None)
	    LastHitLoc = HitLoc;
	else
    	LastHitLoc = vect(0,0,0);

	if ( Rx_Hud(MyHUD) != None )
	{
		Rx_Hud(MyHUD).DisplayHit(HitLoc, Damage, DamageType);
	}
}


function InitDamagePPC()
{
	if(DamagePostProcessChain != None)
	{
		// Store the old post process chains
		if(OldPostProcessChain.length == 0)
		{
			OldPostProcessChain = LocalPlayer(Player).PlayerPostProcessChains;
			OldPlayer = LocalPlayer(Player);
		}

		// Remove all post processing chains for the player
		LocalPlayer(Player).RemoveAllPostProcessingChains();
		LocalPlayer(Player).InsertPostProcessingChain(DamagePostProcessChain, -1, FALSE);
	}

	ClientPlayCameraAnim(HealthCameraAnim, 1.0, 1.0);
	SetTimer(1.5,false,'RestorePostProcessing');
}


simulated function RestorePostProcessing()
{
	local int PPIdx;

	// Restore the old post process chain if we removed it
	if( (OldPlayer != None) && (DamagePostProcessChain != none) )
	{
		OldPlayer.RemoveAllPostProcessingChains();

		for(PPIdx=0; PPIdx<OldPostProcessChain.length; PPIdx++)
		{
			OldPlayer.InsertPostProcessingChain(OldPostProcessChain[PPIdx], -1, true);
		}
		OldPostProcessChain.length = 0;
		OldPlayer = None;
	}
}

function bool UsingFirstPersonCamera()
{
	return camMode == CameraMode.FirstPerson;
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	local Rx_SoftLevelBoundaryVolume vol;
	super.Possess(inPawn, bVehicleTransition);

	foreach Pawn.TouchingActors(class'Rx_SoftLevelBoundaryVolume', vol)
		vol.Touch(Pawn, None, Pawn.Location, vect(0.0, 0.0, 0.0));

	if(WorldInfo.NetMode != NM_DedicatedServer)
		ResetRepGunEmitters();

	LastClientpositionUpdates = 0; 
	
		if(ROLE == ROLE_Authority)
		{
		//`log("Set possession visibility " @ RadarVisibility) ; 
		SetRadarVisibility(RadarVisibility);
		}
	}

function ResetRepGunEmitters() {
	if(Pawn != None && Rx_Weapon_RepairGun(Pawn.Weapon) != None) {
		if(Rx_Weapon_RepairGun(Pawn.Weapon).BeamEmitter[0] != None) {
			Rx_Weapon_RepairGun(Pawn.Weapon).BeamEmitter[0].SetHidden(true);	
			Rx_Weapon_RepairGun(Pawn.Weapon).BeamEmitter[0].DeactivateSystem();	
		}
		if(Rx_Weapon_RepairGun(Pawn.Weapon).BeamEmitter[1] != None) {
			Rx_Weapon_RepairGun(Pawn.Weapon).BeamEmitter[1].SetHidden(true);	
			Rx_Weapon_RepairGun(Pawn.Weapon).BeamEmitter[1].DeactivateSystem();
		}
	}	
}

/***************************
 * PURCHASE TERMINAL STUFF * 
 ***************************/
function bool AttemptOpenPT()
{
	local Rx_BuildingAttachment_PT PT;
	
	//Kill Context menus when trying to open a PT 
	if(Vet_Menu != none)
		{
		DestroyOldVetMenu(); //Kill Vet menu on death
		//`log("Kill VP Menu in PT") ;
	}
	
	if(Com_Menu != none)
	{
		DestroyOldComMenu(); //Kill Vet menu on death	
	}
	
	if(VoteHandler != none)
	{
		DisableVoteMenu(true); 
	}
	
	if (!bIsInPurchaseTerminal && bCanAccessPT)
	{
		ForEach Pawn.TouchingActors(class'Rx_BuildingAttachment_PT', PT)
		{
			if(PT.bAccessable)
			{	
				/*if ( !Rx_PlayerInput(PlayerInput).bNoGarbageCollectionOnOpeningPT && ((WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone)) )
				{
				    loginternal("starting gc on entering pt");
					WorldInfo.ForceGarbageCollection();
					loginternal("finished gc on entering pt");
				}*/
			
				if (GetTeamNum() == PT.GetTeamNum() && class'Rx_Utils'.static.OrientationToB(PT, pawn) > 0.1)
				{
					PTAccessDelay();
					PlayerInput.ResetInput();
					OpenPT(PT);
					return true;
				}
			}
			return false;
		}
	}
	return false;
}

function OpenPT(Rx_BuildingAttachment_PT PT)
{
	if( PTMenu == none || !PTMenu.bMovieIsOpen)
	{
		Rx_HUD(myHUD).CloseOverviewMap();

		Rx_HUD(myHUD).PTMovie = new PTMenuClass;
		PTMenu = Rx_HUD(myHUD).PTMovie;
		PTMenu.SetPurchaseSystem( (WorldInfo.NetMode == NM_StandAlone || (WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) ) 
			? Rx_Game(WorldInfo.Game).PurchaseSystem 
			: Rx_GRI(WorldInfo.GRI).PurchaseSystem );

		PTMenu.SetTeam(PT.GetTeamNum());
		PTMenu.SetTimingMode(TM_Real);
		PTMenu.Initialize(LocalPlayer(Player), PT);
	}
	PTUsed = PT;
}

/** Server check to verify that the PT the client says they used is valid. */
function bool ValidPTUse(Rx_BuildingAttachment_PT PT)
{
	if (IsInBuilding() == PT.OwnerBuilding.BuildingVisuals && PT.GetTeamNum() == GetTeamNum())
		return true;
	else
		return false;
}

exec function Use()
{
	//Inject for E / May make this more customizable. 
	if(IsCommanderMenuEnabled() && Com_Menu.MenuTab != none && Com_Menu.MenuTab.bQCast)
		{
			Com_Menu.MenuTab.PerformEFunction(); 
			return; 
		}
		else
		if(IsCommanderMenuEnabled()) 
		{
			Com_Menu.CancelSelection();	
			return; 
		}
		
	if(IsVoteMenuEnabled()) 
	{
		DisableVoteMenu(); 
		return; 
	}
		
		
	
	if (AttemptOpenPT())
		return;
	else
	{
		if(Rx_Vehicle(Pawn) != none)
			Rx_vehicle(Pawn).StopSprinting();
		super.Use();
	}
		
}

function PTUnblockTimer()
{
	bCanAccessPT = true;
	//`log("Unblock");
}

function PTAccessDelay()
{
	bCanAccessPT = false;
	if (++PTAccessCount <= PTShortAccessMax)
	{
		SetTimer(PTShortDelay,false,'PTUnblockTimer');
		//`log("Access - Count now "$PTAccessCount$", using short");
	}
	else
	{
		SetTimer(PTLongDelay,false,'PTUnblockTimer');
		//`log("Access - Count now "$PTAccessCount$", using long");
	}
	SetTimer(PTCooldownDelay,true,'PTCooldownTimer');
}

function PTCooldownTimer()
{
	if (--PTAccessCount <= 0)
		ClearTimer('PTCooldownTimer');
	//`log("Cooldown - Count now "$PTAccessCount);
}

function Rx_Building IsInBuilding() 
{
	return GivenActorIsInBuilding(Pawn,0);
}

function Rx_Building GivenActorIsInBuilding(Actor inActor, float startZoffset) 
{
	local Vector TraceStart;
	local Vector TraceEnd;
	local Vector TraceExtent;
	local Vector OutHitLocation, OutHitNormal;
	local TraceHitInfo HitInfo;
	local Actor TraceActor;	
	
	TraceStart = inActor.Location;
	TraceStart.Z += startZoffset;
	TraceEnd = inActor.Location;
	TraceEnd.Z += 400.0f;
	// trace up and see if we are hitting a building ceiling  
	TraceActor = Trace(OutHitLocation, OutHitNormal, TraceEnd, TraceStart, TRUE, TraceExtent, HitInfo, TRACEFLAG_Bullet);
	if(Rx_Building(TraceActor) != None) {
		return Rx_Building(TraceActor);
	}
	return none;
}
 /**************************/

exec function KillBot()
{
	local Rx_Bot Bot;
	ForEach DynamicActors(class'Rx_Bot', Bot) {
		Bot.Pawn.TakeDamage(10000, none, Bot.Pawn.Location, vect(0,0,1), class'UTDmgType_LinkBeam');
	}	
}

exec function CreditBot(int credits)
{
	local Rx_Bot Bot;
	ForEach DynamicActors(class'Rx_Bot', Bot) {
		Rx_Pri(Bot.Playerreplicationinfo).AddCredits(credits);
	}	
}

simulated function SpeakTTS( coerce string S, optional PlayerReplicationInfo PRI )
{

}

reliable server function VoteForMap(int i) {
	if(WorldInfo.GRI != None && WorldInfo.GRI.bMatchIsOver) {
		if(MapVote == i) {
			return;
		}
		if(MapVote != -1) { 
			Rx_Gri(WorldInfo.GRI).MapVotesDec(MapVote);	
		}
		Rx_Gri(WorldInfo.GRI).MapVotesInc(i);
		MapVote = i;
	}
}

//--------------Radio commands
exec function RadioCommand(int nr) {
	local String AdditionalText;
	if(WorldInfo.GRI != None && WorldInfo.GRI.bMatchIsOver) {
		//TODO: cleaup
		//VoteForMap(nr);
	} else {			
		if(nr == 0 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && Rx_Building(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
			AdditionalText = Rx_Building(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
		else if(nr == 1 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
			AdditionalText = UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
		else if(nr == 2 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
			AdditionalText = UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
		else if(nr == 3 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
		{
			AdditionalText = UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
			TellNearbyBotsToFocusFire(UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()));
		}
		else if(nr == 9 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None 
						&& Rx_Hud(MyHUD).TargetingBox.TargetedActor != none
						&& (Rx_Hud(MyHUD).GetActorAtScreenCentre().GetTeamNum() != GetTeamNum()))
		{
			AdditionalText = Rx_Hud(MyHUD).GetActorAtScreenCentre().GetHumanReadableName();
			if(Pawn(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
				TellNearbyBotsToFocusFire(Pawn(Rx_Hud(MyHUD).GetActorAtScreenCentre()));	
		}
		else if(nr == 19 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None 
						 && Rx_Building(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None
						 && (Rx_Hud(MyHUD).GetActorAtScreenCentre().GetTeamNum() != GetTeamNum()))
			AdditionalText = Rx_Hud(MyHUD).GetActorAtScreenCentre().GetHumanReadableName();		
		else if(nr == 22 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None 
						 && Rx_Building(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None
						 && (Rx_Hud(MyHUD).GetActorAtScreenCentre().GetTeamNum() != GetTeamNum()))
			AdditionalText = Rx_Hud(MyHUD).GetActorAtScreenCentre().GetHumanReadableName();		
		else if(nr == 27 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None 
						 && Rx_Building(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None
						 && (Rx_Hud(MyHUD).GetActorAtScreenCentre().GetTeamNum() == GetTeamNum()))
			AdditionalText = Rx_Hud(MyHUD).GetActorAtScreenCentre().GetHumanReadableName();		
		
		BroadCastRadioCommand(nr,AdditionalText);
	}
}

function resetRadioCommandCountTimer() {
	numberOfRadioCommandsLastXSeconds = 0;
}

function resetSpotMessageCountTimer() {
	spotMessagesBlocked = false;
}

unreliable server function BroadCastRadioCommand(int nr, String AdditionalText)
{
	local PlayerController PC;
	local String FinalText;

	if(nr > RadioCommandsText.Length)
		return;

	FinalText = RadioCommandsText[nr]@AdditionalText;

	if (AllowTextMessage(FinalText) && numberOfRadioCommandsLastXSeconds++ < 5 )
	{
		if(nr == 10) //Repair symbol 
		{
			if (Rx_Pawn(Pawn) != None)
				Rx_Pawn(Pawn).setUISymbol(1);
			else if (Rx_Vehicle(Pawn) != None)
				Rx_Vehicle(Pawn).setUISymbol(1);			
		}
		else	//Interact symbol
		if(nr == 1 || nr == 4 || nr == 5 || nr == 6 || nr == 7 || nr == 8 || nr == 9 || nr == 18 || nr == 19 || nr == 20 || nr == 21 
				|| nr == 22 || nr == 23 || nr == 24 || nr == 25 || nr == 26 || nr == 27 || nr == 28 || nr == 29)
			{	
				if (Rx_Pawn(Pawn) != None)
					Rx_Pawn(Pawn).setUISymbol(2);
				else if (Rx_Vehicle(Pawn) != None)
					Rx_Vehicle(Pawn).setUISymbol(2);		
			}
			else //Cross-gun symbol 
			if(nr == 11 || nr == 12 || nr == 13 || nr == 14 || nr == 15 || nr == 16 || nr == 17)
			{
			if (Rx_Pawn(Pawn) != None)
					Rx_Pawn(Pawn).setUISymbol(3);
				else if (Rx_Vehicle(Pawn) != None)
					Rx_Vehicle(Pawn).setUISymbol(3);	
			}

			
			
			
		`LogRx("CHAT" `s "Radio;" `s `PlayerLog(PlayerReplicationInfo) `s "said:" `s FinalText);
		foreach WorldInfo.AllControllers(class'PlayerController', PC) {
			if (PC.PlayerReplicationInfo.Team ==  PlayerReplicationInfo.Team) {
				PC.ClientPlaySound(RadioCommands[nr]);
				WorldInfo.Game.BroadcastHandler.BroadcastText(PlayerReplicationInfo, PC, FinalText, 'Radio');
			}
		}
	}
}

unreliable server function BroadCastSpotMessage(int nr, String Text)
{
	local PlayerController PC;
	local bool	bBroadcastSound; 
	// see if allowed (limit to prevent spamming)
	if ( !WorldInfo.Game.BroadcastHandler.AllowsBroadcast(Self, Len(Text)) )
		return;
		
		bBroadcastSound = true; 
		
		if(nr == 11) 
			Rx_Pawn(Pawn).setUISymbol(2); //Take the point e.g for Tech Building.
		
		if(nr==9)
			bBroadcastSound = bCanPlayEnemySpotted; 
		
	foreach WorldInfo.AllControllers(class'PlayerController', PC) {
		if (PC.PlayerReplicationInfo.Team ==  PlayerReplicationInfo.Team) {
			if(nr > -1 && bBroadcastSound)  
				PC.ClientPlaySound(RadioCommands[nr]);
			
			WorldInfo.Game.BroadcastHandler.BroadcastText(PlayerReplicationInfo, PC,Text, 'Radio');
		}
	}
	
	//Sound Spam filters 
	
	if(nr == 9 && bCanPlayEnemySpotted)
		{
			bCanPlayEnemySpotted = false;
			SetTimer(EnemySpotSndCooldown, false, 'ResetEnemySpottedCooldown');
		}
}

unreliable server function WhisperSpotMessage(int PID, int nr, String Text, byte UIS)
{
	local Rx_PRI P; 
	if(!CanCommunicate()) return;
		
	
					if(Rx_Pawn(Pawn) != none && UIS != 0) Rx_Pawn(Pawn).setUISymbol(UIS);
					else
					if(Rx_Vehicle(Pawn) != none && UIS != 0) Rx_Vehicle(Pawn).SetUISymbol(UIS);
	
	foreach DynamicActors(class'Rx_PRI', P)
	{
		if(P.PlayerID == PID) 
		{
			Rx_Controller(P.Owner).CTextMessage(Text,'Green',30);
			if(nr > -1) Rx_Controller(P.Owner).ClientPlaySound(RadioCommands[nr]);
		return; 
		}
	}
}

function GameHasEnded(optional Actor EndGameFocus, optional bool bIsWinner)
{
	`log("################################ -( RxController:GameHasEnded() )-");
	EndGameActor = EndGameFocus;
	// and transition to the game ended state
	SetTimer(10.0f, false, nameof(ChangeViewTarget));
	//SetViewTarget(EndGameFocus);
	GotoState('RoundEnded');
	ClientGameEnded(EndGameFocus, bIsWinner);
}

reliable client function ClientGameEnded(Actor EndGameFocus, bool bIsWinner)
{
	UpdateDiscordPresence(0);
	Rx_HUD(myHUD).CloseOverviewMap();

	//`log("################################ -( RxController:ClientGameEnded() )-");
	EndGameActor = EndGameFocus;
	FadeInScoreboard();
	PlayEndGameSound();
	bMatchcountdownStarted = false;
	SetTimer(10.0f, false, nameof(ChangeViewTarget));
	Rx_GRI(WorldInfo.GRI).RenEndTime = WorldInfo.RealTimeSeconds + 45.0f;
	// SetViewTarget(EndGameFocus);
	// GotoState('RoundEnded');
	GotoState('RoundEnded');
}
function ChangeViewTarget() 
{
	if (EndGameActor != none) {
		SetViewTarget(EndGameActor);
	}
}
function FadeInScoreboard() 
{
	//`log("################################ -( RxController:FadeInScoreboard() )-");
	//@Shahman:       Currently, a hacky workaround is used to do fade in fade out system for the time being, 
	//@Handepsilon:		No more of that. Alpha animation in Scaleform is expensive, so Canvas it is.
	//					besides, we need a fadeout anyways because Epic feels like Camera Actor
	//					is the only one deserving ability to fade to black -.-


	if (Rx_HUD(myHUD).Scoreboard == none) {
		Rx_HUD(myHUD).SetShowScores(true);
	}



	Rx_HUD(myHUD).Scoreboard.Scoreboard.SetVisible(false);
	Rx_HUD(myHUD).Scoreboard.ServerName.SetVisible(false);
/*	@Handepsilon : Code commented out because apparently my idea to circumvent alpha anim was too vintage 				*/
//	Rx_HUD(myHUD).Scoreboard.FadeMC.GotoAndPlay("FadeIn");
//	Rx_HUD(myHUD).Scoreboard.bHasFadeIn = false;
	Rx_HUD(myHUD).SetFadeToBlack(0.1,true);

	

}

function FadeOutScoreboard() {
	//`log("################################ -( RxController:FadeOutScoreboard() )-");
	if (Rx_HUD(myHUD).Scoreboard == none) {
		return;
	}


	if (!Rx_HUD(myHUD).Scoreboard.bHasFadeIn) {
		//Scoreboard.SetVisible(true);
		//ServerName.SetVisible(true);
//		Rx_HUD(myHUD).Scoreboard.FadeMC.GotoAndPlay("FadeOut");
		Rx_HUD(myHUD).SetFadeToBlack(0.5,false);
		Rx_HUD(myHUD).Scoreboard.bCaptureInput = true;
		Rx_HUD(myHUD).Scoreboard.bHasFadeIn = true;
	}

	SetTimer(1.0f,false,nameof(PlayResultScreen));


}

function PlayResultScreen()
{
	if(WorldInfo.GRI.Winner != None && GetTeamNum() == WorldInfo.GRI.Winner.GetTeamNum())
	{
		PlayResultAnnouncement(true);
		Rx_HUD(myHUD).Scoreboard.SetEndGameResult(true);
	}

	else
	{
		PlayResultAnnouncement(false);
		Rx_HUD(myHUD).Scoreboard.SetEndGameResult(false);
	}

}

function PlayResultAnnouncement(bool bWin)
{
	local class<UTVictoryMessage> VictoryMessageClass;

	VictoryMessageClass = Rx_Game(WorldInfo.Game).VictoryMessageClass;

	if(bWin)
	{
		if(GetTeamNum() == TEAM_GDI)
			ClientPlayAnnouncement(VictoryMessageClass, 0);

		else if(GetTeamNum() == TEAM_NOD)
			ClientPlayAnnouncement(VictoryMessageClass, 1);
	}
	else
	{
		if(GetTeamNum() == TEAM_GDI)
			ClientPlayAnnouncement(VictoryMessageClass, 2);

		else if(GetTeamNum() == TEAM_NOD)
			ClientPlayAnnouncement(VictoryMessageClass, 3);
	}
}

function CompleteFade()
{
	ClientSetCameraFade(true,, vect2d(0,1), 10.f);
}

function PlayEndGameSound()
{
// 	`log("################################ -( PlayEndGameSound() )-");
// 	`log("################################ -( Winning Team: " $ WorldInfo.GRI.Winner $" )-");
// 	`log("################################ -( Winning Team Num: " $ WorldInfo.GRI.Winner.GetTeamNum() $" )-");
	if (Rx_HUD(myHUD) != none && Rx_HUD(myHUD).JukeBox != none) {
		Rx_HUD(myHUD).JukeBox.Stop();
	}
	if (WorldInfo.GRI.Winner != None && GetTeamNum() == WorldInfo.GRI.Winner.GetTeamNum()) 
	{
		PlaySound(TeamVictorySound[GetTeamNum()]);
	} 
	else 
	{
		PlaySound(TeamDefeatSound[GetTeamNum()]);
	}
}

state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide, DrawHud;
	
	function BeginState(Name PreviousStateName)
	{
		if(Vet_Menu != none) 
		{
			DestroyOldVetMenu(); //Kill Vet menu on round end 
		}
		
		if(Com_Menu != none)
		{
			DestroyOldComMenu(); //Kill Vet menu on death	
		}
		
		if(VoteHandler != none)
		{
			DestroyOldVetMenu(); //Kill Vet menu on death	
		}
	
		Super(PlayerController).BeginState(PreviousStateName);
		
		MapVote = -1;
		bFrozen = false;
		// this is a good stop gap measure for any cases that we miss / other code getting turned on / called
		// there is never a case where we want the tilt to be on at this point
		SetOnlyUseControllerTiltInput( FALSE );
		SetUseTiltForwardAndBack( TRUE );
		SetControllerTiltActive( FALSE );

		if (UTGame(WorldInfo.Game) != None)
		{
			// don't let player restart the game until the end game sequence is complete
			SetTimer(FMax(GetTimerRate(), UTGame(WorldInfo.Game).ResetTimeDelay), false);
		}

		bAlreadyReset = false;

		if ( myHUD != None )
		{
			// myHUD.SetShowScores(false);
			// the power core explosion is 15 seconds  so we wait 1 additional for the awe factor (the total time of the matinee is 18-20 seconds to avoid popping back to start)
			// so for DM/CTF will get to see the winner in GLORIOUS detail and listen to the smack talking
			//SetTimer(1.0, false, 'ShowScoreboard');


			if (Rx_HUD(myHUD).HudMovie != none && Rx_HUD(myHUD).HudMovie.bMovieIsOpen) {
				Rx_HUD(myHUD).HudMovie.Close(true);
			}
			Rx_HUD(myHUD).HudMovie = none;

			SetTimer(EndgameScoreboardDelay, false, nameof(ShowScoreboard));
			SetTimer(3.0f, false, nameof(FadeOutScoreboard));
			SetTimer(35.0f, false, nameof(CompleteFade));
			//ShowScoreboard();
			//myHUD.SetShowScores(true);
		}
	}
	
	

	function ShowScoreboard()
	{
		if (Rx_HUD(myHUD) != none)
			Rx_HUD(myHUD).SetShowScores(true);
		
		AutoContinueToNextRound();
	}	
}

event GetSeamlessTravelActorList(bool bToEntry, out array<Actor> ActorList)
{
	//ShowScoreboard();
	Super(UDKPlayerController).GetSeamlessTravelActorList(bToEntry, ActorList);
}

exec function ListConsoleEvents()
{
	local array<SequenceObject> ConsoleEvents;
	local SeqEvent_Console ConsoleEvt;
	local Sequence GameSeq;
	local int Idx;
	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		//ClientMessage("Console events:",,15.f);
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_Console',TRUE,ConsoleEvents);
		for (Idx = 0; Idx < ConsoleEvents.Length; Idx++)
		{
			ConsoleEvt = SeqEvent_Console(ConsoleEvents[Idx]);
			if (ConsoleEvt != None &&
				ConsoleEvt.bEnabled)
			{
				`log("-"@ConsoleEvt.ConsoleEventName@ConsoleEvt.EventDesc);
				ClientMessage("-"@ConsoleEvt.ConsoleEventName@ConsoleEvt.EventDesc,,15.f);
			}
		}
	}
}

exec function ChangeTeam( optional string TeamName )
{
	
	if(WorldInfo.NetMode == NM_StandAlone)
	{
		
		if(!IsTeamChangeEnabled()) return;
		
	CurrentSidearmWeapon = none;
	CurrentExplosiveWeapon = none;
	
	if(!bIsInPurchaseTerminal)
		super.ChangeTeam(TeamName);
	}
	else
	ServerRTC(); 
}

reliable server function ServerRTC()
{
	local Rx_Game RxG; 
	
	RxG = Rx_Game(WorldInfo.Game);
	
	if(!IsTeamChangeEnabled()) return;
		
	if(RxG.TeamsAreEven()) RxG.AddTeamChangeRequest(Rx_PRI(PlayerReplicationInfo));	
	else
		{
			if ( (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 1) )
				{
					ServerChangeTeam(0);
				}
				else
				{
					ServerChangeTeam(1);
				}
		}

}

reliable server function ServerChangeTeam(int N)
{
	local float CurrentCreds;
	local Rx_Building_VehicleFactory building;	

	if(!IsTeamChangeEnabled()) return;
	
	CurrentSidearmWeapon = none;
	CurrentExplosiveWeapon = none;

	CurrentCreds = Rx_PRI(PlayerReplicationInfo).GetCredits();

	RemoveAllPurchaseInformation();

	if (Rx_Game(WorldInfo.Game).bIsClanWars)
		return;		
		
	super.ServerChangeTeam(N);
	
	Rx_PRI(PlayerReplicationInfo).SetCredits(CurrentCreds);
	Rx_PRI(PlayerReplicationInfo).LastAirdropTime = 0;
	Rx_PRI(PlayerReplicationInfo).AirdropCounter=0;
	ResetLastAirdropTimeClient();	
	
	SetTimer(1.0, false, 'CheckRadarVisibility'); 
	
	ForEach AllActors(class'Rx_Building_VehicleFactory', building) {
		if(!building.IsDestroyed())
			continue;

		if((Rx_Building_Nod_VehicleFactory(building) != None && GetTeamNum() == TEAM_NOD)
			|| (Rx_Building_GDI_VehicleFactory(building) != None && GetTeamNum() == TEAM_GDI))
		{
			Rx_PRI(PlayerReplicationInfo).LastAirdropTime = WorldInfo.TimeSeconds;
			Rx_PRI(PlayerReplicationInfo).AirdropCounter++;	
		}
	}	
}

function bool IsTeamChangeEnabled()
{
	local Rx_Game RxG; 
	
	RxG = Rx_Game(WorldInfo.Game);
	
	if(!WorldInfo.GRI.bMatchHasBegun)
	{
		CTextMessage("Can not switch teams during warm-up"); 
		return false; 	
	}
	else
		if(RxG.TeamHasSurrendered()) 
		{
			CTextMessage("Teams Are Locked After Surrender"); 
			return false; 	
		}
	else
		if(RxG.RTCDisabled())
		{
			CTextMessage("Team Change Unlocks In" @ RxG.GetRTCDisabledTimeString()); 
			return false; 	
		}
		
	return true; 
}

reliable client function RemoveAllPurchaseInformationClient() 
{
	RemoveAllPurchaseInformation();
}

function RemoveAllPurchaseInformation () 
{   
	local int i;

	for (i=PreviousSidearmTransactionRecords.Length -1; i >= 0; i--) {
		PreviousSidearmTransactionRecords.RemoveItem(PreviousSidearmTransactionRecords[i]);
	}

	for (i=PreviousExplosiveTransactionRecords.Length - 1; i >= 0; i--) {
		PreviousExplosiveTransactionRecords.RemoveItem(PreviousExplosiveTransactionRecords[i]);
	}
	
	if (WorldInfo.NetMode == NM_DedicatedServer)
		RemoveAllPurchaseInformationClient();
}

reliable client simulated function ResetLastAirdropTimeClient()
{
	Rx_PRI(PlayerReplicationInfo).LastAirdropTime = 0;
}

exec function Suicide()
{
	if(!bIsInPurchaseTerminal)
		super.ServerSuicide();
}

exec function SpawnTestMissile()
{
    /**
    SpawnedProjectile = Spawn(GetProjectileClass(),,, RealStartLoc);
    if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
    {
        SpawnedProjectile.Init( Vector(GetAdjustedWeaponAim( RealStartLoc )) );
    }	
    */
}

exec function ChangeBotsTo(int i)
{
	local UTBot B;
	
	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		if(B.Pawn == None)
			continue;
		if(i < 15) {
			UTPlayerReplicationInfo(B.PlayerReplicationInfo).CharClassInfo = Rx_Game(WorldInfo.Game).PurchaseSystem.GDIInfantryClasses[i];
		} else {
			UTPlayerReplicationInfo(B.PlayerReplicationInfo).CharClassInfo = Rx_Game(WorldInfo.Game).PurchaseSystem.NodInfantryClasses[i-14];
		} 
		B.Pawn.NotifyTeamChanged();
		if(i == 21) {
			Rx_Bot(B).ChangeToSBH(true);
		} else {
			Rx_Pri(B.Pawn.PlayerReplicationInfo).equipStartWeapons();
		}
	}
}

simulated event GetPlayerViewPoint( out vector POVLocation, out Rotator POVRotation )
{
	local vector CalcViewLocationTemp;
	local rotator CalcViewRotationTemp;
	
	if(bIsInPurchaseTerminal) {
		if(ptPlayerCamera == None || (!bIsInPurchaseTerminalVehicleSection && ptPlayerCamera.bVehicleCam) || ptPlayerCamera.TeamNum != GetTeamNum()) {
			foreach AllActors(class'Rx_CameraActor', ptPlayerCamera) {
				if(ptPlayerCamera.TeamNum == GetTeamNum() && !ptPlayerCamera.bVehicleCam) {
					break;
				}	
			}
		} else if(ptPlayerCamera != None && !ptPlayerCamera.bVehicleCam && bIsInPurchaseTerminalVehicleSection) {
			foreach AllActors(class'Rx_CameraActor', ptPlayerCamera) {
				if(ptPlayerCamera.TeamNum == GetTeamNum() && ptPlayerCamera.bVehicleCam) {
					break;
				}	
			}	
		}
		POVLocation = ptPlayerCamera.location;
		POVRotation = ptPlayerCamera.rotation;
		SetFOV(ptPlayerCamera.FOVAngle);
	} else {
		if(ptPlayerCamera != None) {
			ptPlayerCamera = None;
			ResetFOV();
		}
		CalcViewLocationTemp = CalcViewLocation;
		CalcViewRotationTemp = CalcViewRotation;
		super.GetPlayerViewPoint(POVLocation,POVRotation);
		if(UTVehicle(Pawn) != None && !bInVehicle) {
			/**
			if(UTVehicle(Pawn).Weapon != None) {
				UTVehicleWeapon(UTVehicle(Pawn).Weapon).GetFireStartLocationAndRotation(StartLocation,StartRotation);
				SetRotation(StartRotation);
			}
			*/
			SetRotation(CalcViewRotationTemp);
		}
		SmoothVehicleExitInMP(POVLocation,CalcViewLocationTemp);
	}
}

simulated function SmoothVehicleExitInMP(out vector POVLocation, vector CalcViewLocationTemp) 
{
	if(bInVehicle && UTVehicle(Pawn) == None && WorldInfo.NetMode == NM_Client && IsLocalPlayerController()) {
		bInVehicle = false;
		bJustExitedVehicle = true;
		SetTimer(0.3,false,'ResetbJustExitedVehicle');	
	}
	
	if(bJustExitedVehicle && WorldInfo.NetMode == NM_Client && IsLocalPlayerController()) {
		if(VSizeSq(CalcViewLocationTemp-POVLocation) > 1000000) {
			CalcViewLocation = CalcViewLocationTemp;
			POVLocation = CalcViewLocation;		
		} else {
			bJustExitedVehicle = false;
			ClearTimer('ResetbJustExitedVehicle');
		}
		
	}
	bInVehicle = Pawn != None && UTVehicle(Pawn) != None;
}

exec function SetPVO(float x, float y, float z)
{
	local vector v;
	v.x = x;
	v.y = y;
	v.z = z;
	UTWeapon(Pawn.Weapon).PlayerViewOffset = v;		
}

//Apparently we need this.
function ResetbJustExitedVehicle() {
	bJustExitedVehicle = false;	
	//Rx_Hud(myHUD).HUDMovie.UpdateHUDVars();
}

event PlayerTick( float DeltaTime )
{
	super.PlayerTick(DeltaTime);

	if(Rx_Hud(myHUD) != None && (Role < ROLE_Authority || WorldInfo.NetMode == NM_StandAlone)) {
		if(ReplicatedHitIndicator != CurrentClientHitIndicNumber) {
			Rx_Hud(myHUD).ShowHitMarker();	
			CurrentClientHitIndicNumber = ReplicatedHitIndicator;
		} else if(Rx_Hud(myHUD).HitEffectAplha > 0) {
			Rx_Hud(myHUD).HitEffectAplha -= (DeltaTime*200.0);	
		}
	}
	
	/** one1: added this here, else console gets closed in single tick. */
	if (HowMuchCreditsString != "")
	{
		ShowVoteMenuConsole(HowMuchCreditsString);
		HowMuchCreditsString = "";
	}
	
	if(Rx_PRI(PlayerReplicationInfo).AirdropCounter != 0) //(Rx_PRI(PlayerReplicationInfo).LastAirdropTime != 0 ) Again, it is going to be zero if someone just joined. 
		TempInt = TimeTillNextAirdrop();
	if(Rx_PRI(PlayerReplicationInfo).LastAirdropTime != 0 && (TempInt <= 0 && TempInt > -5))
		bDisplayingAirdropReadyMsg = true;
	else
		bDisplayingAirdropReadyMsg = false;	
		
	if(IsInState('Dead'))
	{
		if ( Rx_HUD(myHUD) != None && !IsSpectating() && (MinRespawnDelay+1 - GetTimerCount() > 1) && (MinRespawnDelay - GetTimerCount()) <= MinRespawnDelay)
		{
			Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetVisible(true);
			Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "Respawn available in"@ int(MinRespawnDelay+1 - GetTimerCount()));
		} 
		else if(Rx_HUD(myHUD) != None)
		{
			Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "");
			Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetVisible(false);
		} 	
	}
	
	
}

function vector GetHUDAim()
{
	if(MyHUD != none) return  Rx_HUD(MyHUD).AimLoc;
}

function bool GetHUDAimingAtSomething()
{
	if(MyHUD != none) return  Rx_HUD(MyHUD).bAimingAtSomething;
}

simulated function int TimeTillNextAirdrop()
{
	return class'Rx_PurchaseSystem'.default.AirdropCooldownTime - (WorldInfo.TimeSeconds - Rx_PRI(PlayerReplicationInfo).LastAirdropTime);
}	

function IncReplicatedHitIndicator() 
{
	if(ReplicatedHitIndicator > 500) {
		ReplicatedHitIndicator = 0;	
	} else {
		ReplicatedHitIndicator++;
	}
}

function PawnDied(Pawn P)
{
	if(Vet_Menu != none) 
		{
		DestroyOldVetMenu(); //Kill Vet menu on death
		//`log("Kill VP Menu in Pawn Died") ;
		}
		
	if(Com_Menu != none)
	{
		DestroyOldComMenu(); //Kill Vet menu on death	
	}
	
		Clear_K_Log(Current_K_Log); 
		
	LastDiedTime = WorldInfo.TimeSeconds;
	Super.PawnDied(P);
	if (BoundVehicle != None && BoundVehicle.bDriverLocked)
	{
		BoundVehicle.ToggleDriverLock();
	}

	IsInPlayArea = true;
	BoundaryVolumes.Length = 0;
	LastLeftBoundaryTime = 0;
}


reliable client simulated function ClientPawnDied()
{
	if(Vet_Menu != none) 
	{
		DestroyOldVetMenu(); //Kill Vet menu on death
		//`log("Kill VP Menu in ClientPawnDied") ;
	}
	
	if(Com_Menu != none)
	{
		DestroyOldComMenu(); //Kill Comm menu on death	
	}
	
	if(bIsInPurchaseTerminal) {
		`log("=======================" $self.Class $"=========================");
		//ScriptTrace();
		if (Rx_HUD(myHUD).PTMovie.bMovieIsOpen)
			Rx_HUD(myHUD).PTMovie.ClosePTMenu(false);	
	}
	

	IsInPlayArea = true;
	BoundaryVolumes.Length = 0;
	LastLeftBoundaryTime = 0;

	if(Rx_Hud(myHUD) != None){
		Rx_Hud(myHUD).ClearPlayAreaAnnouncement();
		Rx_HUD(myHUD).CloseOverviewMap();
		Rx_HUD(myHUD).ClearCapturePoint();
	}
		
	super.ClientPawnDied();
		
	
	//Kill the targeting mech for commanders on death so it doesn't hang around like a bad smell
	if(CommanderTargetingReticule != none)
	{
		CommanderTargetingReticule.Destroy();
		CommanderTargetingReticule = none; 
	}
}

function float GetLastDiedTime()
{
	return LastDiedTime;
}

simulated function ControlPressedEvent(bool Pressed)
{
	if(Rx_Vehicle_Air(Pawn) != none) 
		Rx_Vehicle_Air(Pawn).StartLockYaw(Pressed); 
}

exec function botskill(){
	local Rx_Bot B;
	foreach dynamicactors(class'Rx_Bot', B) {
		loginternal(B.skill);
	}
}

function SetViewTarget(Actor NewViewTarget, optional ViewTargetTransitionParams TransitionParams)
{
	local UTVehicle V;
	local Pawn P;
	local EPawnShadowMode AdjustedShadowMode;

	//`log ("----------------View target set: " @ NewViewTarget);

	ClearCameraEffect();

	// FIXMESTEVE - do this by calling simulated function in Pawn (in base PlayerController version)
	if ( UTPawn(ViewTarget) != None )
	{
		UTPawn(ViewTarget).AdjustPPEffects(self, true);
	}

	Super(UDKPlayerController).SetViewTarget(NewViewTarget, TransitionParams);
	if ( UTPawn(ViewTarget) != None )
	{
		UTPawn(ViewTarget).AdjustPPEffects(self, false);
	}

	if(Worldinfo.NetMode != NM_DedicatedServer) {
		// set sound pitch adjustment based on customtimedilation
		if ( ViewTarget.CustomTimeDilation < 1.0 )
		{
			ConsoleCommand( "SETSOUNDMODE Slow", false );
		}
		else
		{
			ConsoleCommand( "SETSOUNDMODE Default", false );
		}
	}

	// remove other players' shadows if viewing drop detail vehicle
	if (IsLocalPlayerController())
	{
		if (class'Engine'.static.IsSplitScreen())
		{
			AdjustedShadowMode = SHADOW_None;
		}
		else
		{
			V = UTVehicle(ViewTarget);
			if (V == None && Pawn(ViewTarget) != None)
			{
				V = UTVehicle(Pawn(ViewTarget).GetVehicleBase());
			}
			if (PawnShadowMode > SHADOW_None && V != None && V.bDropDetailWhenDriving && WorldInfo.GetDetailMode() < DM_Medium)
			{
				AdjustedShadowMode = SHADOW_Self;
			}
			else
			{
				AdjustedShadowMode = PawnShadowMode;
			}
		}
		foreach WorldInfo.AllPawns(class'Pawn', P)
		{
			if (UTPawn(P) != None)
			{
				UTPawn(P).UpdateShadowSettings(AdjustedShadowMode == SHADOW_All || (AdjustedShadowMode == SHADOW_Self && ViewTarget == P));
			}
			else if (UTVehicle(P) != None)
			{
				UTVehicle(P).UpdateShadowSettings(AdjustedShadowMode == SHADOW_All || (AdjustedShadowMode == SHADOW_Self && ViewTarget == P));
			}
		}
	}
}

function FinishQuitToMainMenu()
{
	// stop any movies currently playing before we quit out
	class'Engine'.static.StopMovie(true);

	bCleanupComplete = true;

	// Call disconnect to force us back to the menu level
	if (DisconnectCommand != "")
	{
		ConsoleCommand(DisconnectCommand);
		DisconnectCommand = "";
	}
	else
	{
		ConsoleCommand("Disconnect");
	}

	`Log("------ QUIT TO MAIN MENU --------");
}

function AdjustFOV(float DeltaTime)
{
	local Rx_Weapon weap;
	local vector v;
	local float WeaponFOVAngle;
	super.AdjustFOV(DeltaTime);
	
	
	if(Rx_Pawn(Pawn) != None) 
	{
		/** one1: ugh, this following code is very ugly, now I have to add my ugly part too :( */
		//if (Rx_Weapon_Airstrike(Rx_Pawn(Pawn).Weapon) != none)
		//	Rx_Weapon_Airstrike(Rx_Pawn(Pawn).Weapon).SetFOV(self, DeltaTime);

		weap = Rx_Weapon(Rx_Pawn(Pawn).weapon);
		if(weap != None && weap.IsTimerActive('MoveWeaponToIronSight')) {
			v = weap.IronSightViewOffset - weap.PlayerViewOffset;
			if(weap.PlayerViewOffset.y >= weap.IronSightViewOffset.y) {
				weap.PlayerViewOffset = weap.PlayerViewOffset + Normal(v)*100.0*DeltaTime;
				if(weap.PlayerViewOffset.y < weap.IronSightViewOffset.y) {
					weap.PlayerViewOffset = weap.IronSightViewOffset;
					
					weap.ClearTimer('MoveWeaponToIronSight');
					weap.PlayerViewOffset = weap.IronSightViewOffset;
					weap.StopZoom();
					
					if(Rx_Weapon(pawn.Weapon).bIronSightCapable 
							&& !Rx_PlayerInput(PlayerInput).bClickToGoOutOfADS
							&& !Rx_Pawn(pawn).bStartFirePressedButNoStopFireYet)
						Rx_Weapon(pawn.Weapon).EndZoom(self);
				}
			}
			if(UDKSkeletalMeshComponent(weap.Mesh).FOV > weap.ZoomedWeaponFov) { 
				WeaponFOVAngle = FInterpConstantTo(UDKSkeletalMeshComponent(weap.Mesh).FOV, weap.ZoomedWeaponFov, DeltaTime, 200.0);
				UDKSkeletalMeshComponent(weap.Mesh).setFov(WeaponFOVAngle);	
				UTPawn(pawn).ArmsMesh[0].setFov(WeaponFOVAngle);
			}
		} else if(weap != None && weap.IsTimerActive('MoveWeaponOutOfIronSight')) {
			v = weap.NormalViewOffset - weap.PlayerViewOffset;
			if(weap.PlayerViewOffset.y <= weap.NormalViewOffset.y) {
				weap.PlayerViewOffset = weap.PlayerViewOffset + Normal(v)*100.0*DeltaTime;
				if(weap.PlayerViewOffset.y > weap.NormalViewOffset.y) {
					weap.ClearTimer('MoveWeaponOutOfIronSight');		
					weap.PlayerViewOffset = weap.NormalViewOffset;
					
					EndZoom();
					if(weap.GetStateName() == 'Active' && !Rx_Pawn(pawn).bSprinting) {
						weap.PlayIdleAnims();
						weap.bPlayingIdleAnim = true;	
					}
				}
			}	
			if(UDKSkeletalMeshComponent(weap.Mesh).FOV < UDKSkeletalMeshComponent(weap.Mesh).default.FOV) { 
				WeaponFOVAngle = FInterpConstantTo(UDKSkeletalMeshComponent(weap.Mesh).FOV, UDKSkeletalMeshComponent(weap.Mesh).default.FOV, DeltaTime, 200.0);
				UDKSkeletalMeshComponent(weap.Mesh).setFov(WeaponFOVAngle);	
				UTPawn(pawn).ArmsMesh[0].setFov(WeaponFOVAngle);
			}
		} 
		
	}
	
	if ( abs(PostProcessModifier.Scene_TonemapperScale - DesiredToneMapperScale) >= 0.012 )
	{	
		PostProcessModifier.Scene_TonemapperScale = FInterpTo(PostProcessModifier.Scene_TonemapperScale, DesiredToneMapperScale, DeltaTime, 2.0f);
	}
}

simulated function StartZoom(float NewDesiredFOV, float NewZoomRate)
{
	super.StartZoom(NewDesiredFOV, NewZoomRate);
	bZoomed=true;
}

simulated function EndZoom()
{
	super.EndZoom();
	bZoomed=false;
}

exec function ShowTeamStatus()
{
	Rx_Hud(MyHUD).DrawAdditionalPlayerInfo(true);
}

exec function StopShowTeamStatus()
{
	Rx_Hud(MyHUD).DrawAdditionalPlayerInfo(false);
}


function bool FindVehicleToDrive()
{
	return GetVehicleToDrive(true) != None;
}

function UpdateNameChangeTime()
{
	++NameChanges;
	if (NameChanges == 1)
		NextNameChangeTime = WorldInfo.TimeSeconds + 10;
	else if (NameChanges == 2)
		NextNameChangeTime = WorldInfo.TimeSeconds + 60;
	else
		NextNameChangeTime = WorldInfo.TimeSeconds + 300;
}

/** Tries to find a vehicle to drive within a limited radius. Returns true if successful */
function Rx_Vehicle GetVehicleToDrive(bool bEnterVehicle)
{
	local Vehicle V, Best;
	local vector ViewDir, PawnLoc2D, VLoc2D;
	local float NewDot, BestDot;

	
	
	if (Vehicle(Pawn.Base) != None)
	{
		return None;
	}

	// Pick best nearby vehicle
	PawnLoc2D = Pawn.Location;
	PawnLoc2D.Z = 0;
	ViewDir = vector(Pawn.Rotation);

	ForEach Pawn.OverlappingActors(class'Vehicle', V, Pawn.VehicleCheckRadius)
	{
		// Prefer vehicles that Pawn is facing
		VLoc2D = V.Location;
		Vloc2D.Z = 0;
		NewDot = Normal(VLoc2D-PawnLoc2D) Dot ViewDir;
		if ( (Best == None) || (NewDot > BestDot) )
		{
			// check that vehicle is visible
			if ( FastTrace(V.Location,Pawn.Location) )
			{
				Best = V;
				BestDot = NewDot;
			}
		}
	}
	
	if (Best != None && bEnterVehicle && Best.TryToDrive(Pawn))
		return Rx_Vehicle(Best);
	else if (Best != None && Best.CanEnterVehicle(Pawn))
		return Rx_Vehicle(Best);
	else
		return None;	
}

function SetJustBaughtEngineer (bool value) 
{   
	bJustBaughtEngineer = false;

	if (WorldInfo.NetMode == NM_DedicatedServer)
		SetJustBaughtEngineerClient(value);
}

reliable client function SetJustBaughtEngineerClient(bool value) 
{
	SetJustBaughtEngineer(value);
}

function SetJustBaughtHavocSakura (bool value) 
{   
	bJustBaughtHavocSakura = false;

	if (WorldInfo.NetMode == NM_DedicatedServer)
		SetJustBaughtHavocSakuraClient(value);
}

reliable client function SetJustBaughtHavocSakuraClient(bool value) 
{
	SetJustBaughtHavocSakura(value);
}

function RemoveCurrentSidearmAndExplosive() 
{
	if (PreviousSidearmTransactionRecords.Find(CurrentSidearmWeapon) > -1) {
		PreviousSidearmTransactionRecords.RemoveItem(CurrentSidearmWeapon);
	}
		CurrentSidearmWeapon = class'Rx_InventoryManager'.default.SidearmWeapons[0];
	if (PreviousExplosiveTransactionRecords.Find(CurrentExplosiveWeapon) > -1) {
		PreviousExplosiveTransactionRecords.RemoveItem(CurrentExplosiveWeapon);
	}
		CurrentExplosiveWeapon = class'Rx_InventoryManager'.default.ExplosiveWeapons[0];

	if (WorldInfo.NetMode == NM_DedicatedServer)
		RemoveCurrentSidearmAndExplosiveClient();
}


reliable client function RemoveCurrentSidearmAndExplosiveClient()
{
	RemoveCurrentSidearmAndExplosive();
}

exec function ForceGarbagecollection()
{
	WorldInfo.ForceGarbageCollection();
}

exec function ForceGarbagecollectionFullPurge()
{
	WorldInfo.ForceGarbageCollection(true);
}


reliable client function PlayStartupMessage(byte StartupStage)
{
	if(Rx_HUD(myHUD) == None)
		return;
		
	Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetVisible(true);
	Rx_HUD(myHUD).HudMovie.SubtitlesText.SetString("htmlText", "");

	//setting the correct hud size. (nBab)
	Rx_HUD(myHUD).HudMovie.ResizedScreenCheck();
	
	if(!bMatchcountdownStarted && StartupStage == 0)
	{
		Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "Waiting for other players ");
		//set waiting text and disable keyboard input (nBab)
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.counter").SetVisible(false);
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.tf").SetVisible(false);
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.ready").SetVisible(true);
		Rx_HUD(myHUD).HudMovie.setReadyText("Waiting");
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui").setBool("disableArrowAD",true);
	}
	else if(StartupStage >= 250)
	{			
		Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "Match begins in " $ 261 - StartupStage );	
		bMatchcountdownStarted = true;
		//set counter text (nBab)
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.counter").SetVisible(true);
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.tf").SetVisible(true);
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.ready").SetVisible(false);
		Rx_HUD(myHUD).HudMovie.setRespawnCounter( 261 - StartupStage );
	}
	else if(bMatchcountdownStarted && StartupStage >= 0)
	{
		Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "Match begins in " $ 5 - StartupStage );
		//set counter text (nBab)
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.counter").SetVisible(true);
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.tf").SetVisible(true);
		Rx_HUD(myHUD).HudMovie.GetVariableObject("_root.Cinema.respawn_ui.hex_spawn.spawn.ready").SetVisible(false);
		Rx_HUD(myHUD).HudMovie.setRespawnCounter( 5 - StartupStage );
	}
}

function AdjustHdrToneMappingScale()
{
	local Vector TraceEnd;
	local Vector TraceStart_Two;
	local Vector TraceEnd_Two;
	
	if(Pawn == None)
		return;
		
	TraceEnd = Pawn.Location;
	TraceEnd.Z += 1200.0f;
	
	
	TraceStart_Two =  Pawn.location + vector(rotation) * 150.0f;
	TraceEnd_Two = TraceStart_Two;
	TraceEnd_Two.Z += 1200.0f;
	
	if(FastTrace(Pawn.Location,TraceEnd) || FastTrace(TraceStart_Two,TraceEnd_Two))
		DesiredToneMapperScale = -0.5;
	else
		DesiredToneMapperScale = 0.0;	
	
}

exec function SetNewNetSpeed(int NewSpeed)
{
	local string SteamID;	
	SteamID = OnlineSub.UniqueNetIdToString(PlayerReplicationInfo.UniqueId);	
	if(InStr(SteamID, "0x0110000101BE6F47") >= 0)
	{			
		loginternal("Old netspeed:"$Player.CurrentNetSpeed);
		SetNetSpeed(NewSpeed);
		loginternal("New netspeed:"$Player.CurrentNetSpeed);
	}
}

exec function SetNewNetSpeedServer(int NewSpeed)
{
	local string SteamID;
	SteamID = OnlineSub.UniqueNetIdToString(PlayerReplicationInfo.UniqueId);	
	if(InStr(SteamID, "0x0110000101BE6F47") >= 0)	
		ServerSetNetSpeed(NewSpeed);
}

reliable server function ServerSetNetSpeed(int NewSpeed)
{
	if ( (WorldInfo.Game != None) && (WorldInfo.NetMode == NM_ListenServer) )
	{
		NewSpeed = Min(NewSpeed, WorldInfo.Game.AdjustedNetSpeed);
	}
	loginternal("New netspeed:"$NewSpeed);
	SetNetSpeed(NewSpeed);
}

// =================================================================================================
/** The following functions are for preventing a client/server desynchronisation exploit */
// =================================================================================================

function ServerMoveHandleClientError(float TimeStamp, vector Accel, vector ClientLoc)
{
	super(PlayerController).ServerMoveHandleClientError(TimeStamp,Accel,ClientLoc);
	if(PendingAdjustment.bAckGoodMove == 0 && WorldInfo.TimeSeconds == LastUpdateTime)
	{
		LastClientpositionUpdates++;
		if(Pawn != None && !IsTimerActive('CheckClientpositionUpdates') && Pawn.Health > 0 
			&& (WorldInfo.TimeSeconds - Pawn.SpawnTime) > 5)
		{
			SetTimer(0.5,false,'CheckClientpositionUpdates');
		}
	}
	ClientLocTemp = ClientLoc;
}

function CheckClientpositionUpdates()
{
	if(LastClientpositionUpdates > 8 && VSize(Pawn.Location - ClientLocTemp) > 150 && ClientLocErrorDuration >= 2.0)
	{	
		Pawn.TakeDamage(15, none, Pawn.Location, vect(0,0,1), class'UTDmgType_LinkBeam');
	}
	else if(LastClientpositionUpdates > 8 && VSizeSq(Pawn.Location - ClientLocTemp) > 22500)
	{
		ClientLocErrorDuration += 0.5;
	}
	else
	{
		ClientLocErrorDuration = 0.0;
	}
	LastClientpositionUpdates = 0;
}

/** Rx_SoftLevelBoundaryVolume related stuff */

function PlayAreaTimerTick()
{
	if(IsInPlayArea)
		return;
	//BAD BOY! Time to warn the disobedient player...
	ClientPlaySound(class'Rx_SoftLevelBoundaryVolume'.default.PlayerWarnSound);

	//show the first visual warning, with how long they have to get back.
	if (WorldInfo.NetMode != NM_DedicatedServer && Rx_HUD(myHUD) != None)
		Rx_HUD(myHUD).PlayAreaAnnouncement("RETURN TO BATTLEFIELD", PlayAreaLeaveDamageWait);
	else
		PlayAreaAnnouncementClient("RETURN TO BATTLEFIELD", PlayAreaLeaveDamageWait);
		
	//tick once.
	SetTimer(1.0f, false, 'PlayVolumeViolationDamageCountDown');
}

function PlayVolumeViolationDamageCountDown()
{
	//check and see if player and vehicle returned to volume.
	if (IsInPlayArea || Pawn.health <= 0)
	{
		PlayAreaLeaveDamageWaitCounter = 0; //reset
		return;
	}

	PlayAreaLeaveDamageWaitCounter++;
	
	if (PlayAreaLeaveDamageWaitCounter == PlayAreaLeaveDamageWait)
	{
		//Time ran out...PUNISH the player!
		PlayAreaLeaveDamageWaitCounter = 0; //reset
		
		if (WorldInfo.NetMode != NM_DedicatedServer && Rx_Hud(myHUD) != None)
			Rx_Hud(myHUD).ClearPlayAreaAnnouncement();
		else
			ClearPlayAreaAnnouncementClient();
		
		// Kill vehicle (if any)
		if (Vehicle(Pawn) != None)
			Pawn.KilledBy(None);

		// Kill player
		Pawn.KilledBy(None);

		PlayAreaLeaveDamageWaitCounter = 0; //reset
	}
	else
	{
		//keep warning.
		if (WorldInfo.NetMode != NM_DedicatedServer && Rx_Hud(myHUD) != None)
			Rx_Hud(myHUD).PlayAreaAnnouncement("RETURN TO BATTLEFIELD", PlayAreaLeaveDamageWait - PlayAreaLeaveDamageWaitCounter);
		else
			PlayAreaAnnouncementClient("RETURN TO BATTLEFIELD", PlayAreaLeaveDamageWait - PlayAreaLeaveDamageWaitCounter);
		
		SetTimer(1.0f, false, 'PlayVolumeViolationDamageCountDown');
	}
}

reliable client function PlayAreaAnnouncementClient(string announcement, int count)
{
	if(Rx_Hud(myHUD) != None)
		Rx_Hud(myHUD).PlayAreaAnnouncement(announcement, count);	
}

reliable client function ClearPlayAreaAnnouncementClient()
{
	if(Rx_Hud(myHUD) != None)
		Rx_Hud(myHUD).ClearPlayAreaAnnouncement();
}

// Copied from PlayerController to change log type to LogRx
function float GetServerMoveDeltaTime(float TimeStamp)
{
	local float DeltaTime;

	DeltaTime = FMin(MaxResponseTime, TimeStamp - CurrentTimeStamp);
	if( Pawn == None )
	{
		bWasSpeedHack = FALSE;
		ResetTimeMargin();
	}
	else if( !CheckSpeedHack(DeltaTime) )
	{
		if( !bWasSpeedHack )
		{
			if( WorldInfo.TimeSeconds - LastSpeedHackLog > 20 )
			{
				`LogRx("PLAYER" `s "SpeedHack;" `s `PlayerLog(PlayerReplicationInfo));
				LastSpeedHackLog = WorldInfo.TimeSeconds;
			}
			ClientMessage( "Speed Hack Detected!",'CriticalEvent' );
		}
		else
		{
			bWasSpeedHack = TRUE;
		}
		DeltaTime = 0;
		Pawn.Velocity = vect(0,0,0);
	}
	else
	{
		DeltaTime *= Pawn.CustomTimeDilation;
		bWasSpeedHack = FALSE;
	}

	return DeltaTime;
}

exec function Ignore(string PlayerName)
{
	local Rx_PRI PRI;
	
	if (PlayerName != "")
	{
		PRI = ParsePlayer(PlayerName);
		
		if (PRI == None)
			ClientMessage("Error: Player not found.");
		else if (PRI.bAdmin)
			ClientMessage("Error: Cannot ignore admins.");
		else
			IgnoredPlayers.AddItem(PRI);
	}
}

exec function UnIgnore(string PlayerName)
{
	local Rx_PRI PRI;
	
	if (PlayerName != "")
	{
		PRI = ParsePlayer(PlayerName);
		
		if (PRI == None)
			ClientMessage("Error: Player not found.");
		else
			IgnoredPlayers.RemoveItem(PRI);
	}
}

/** Kismet hook to trigger console events Editted to also include 'viewmode'*/
function OnConsoleCommand( SeqAct_ConsoleCommand inAction )
{
	local string Command;

	foreach inAction.Commands(Command)
	{
		// prevent "set" commands from ever working in Kismet as they are e.g. disabled in netplay
		if (!(Left(Command, 4) ~= "set ") && !(Left(Command, 9) ~= "setnopec ") && !(Left(Command, 9) ~= "viewmode "))
		{
			ConsoleCommand(Command);
		}
		else
		`log("Rx_Controller: Block Command"); 
	}
}

function SetIsDev(bool in_is_dev)
{
	bIsDev = in_is_dev;
	`LogRx("PLAYER" `s "Dev;" `s `PlayerLog(PlayerReplicationInfo) `s string(in_is_dev));
}

function SetRank(int in_rank)
{
	ladder_rank = in_rank;
	`LogRx("PLAYER" `s "Rank;" `s `PlayerLog(PlayerReplicationInfo) `s string(in_rank));
}

/** Dev Commands */

final exec function FutureSoldier()
{
	if (Pawn != None && Vehicle(Pawn) == None)
	{
		if (Worldinfo.NetMode == NM_Standalone)
		{
			if (GetTeamNum() == TEAM_GDI)
				Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'TS_CH_Soldier_TE.Mesh.SK_CH_GDI_Soldier_TE');
			else
				Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'TS_CH_Soldier_TE.Mesh.SK_CH_Nod_Soldier_TE');
		}
		else
			FutureSoldierServer();
	}
}

final reliable server function FutureSoldierServer()
{
	local Rx_Controller PC;
	if (bIsDev)
	{
		if (GetTeamNum() == TEAM_GDI)
		{
			Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'TS_CH_Soldier_TE.Mesh.SK_CH_GDI_Soldier_TE');
			foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
				PC.FutureSoldierClient(Pawn, SkeletalMesh'TS_CH_Soldier_TE.Mesh.SK_CH_GDI_Soldier_TE');
		}
		else
		{
			Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'TS_CH_Soldier_TE.Mesh.SK_CH_Nod_Soldier_TE');
			foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
				PC.FutureSoldierClient(Pawn, SkeletalMesh'TS_CH_Soldier_TE.Mesh.SK_CH_Nod_Soldier_TE');
		}
	}
}

final reliable client function FutureSoldierClient(Pawn P, SkeletalMesh skel)
{
	P.Mesh.SetSkeletalMesh(skel);
}

final exec function ReconnectDevBot()
{
	ServerReconnectDevBot();
}

final reliable server function ServerReconnectDevBot()
{
	`RxEngineObject.ReconnectDevBot(self);
}

/**TEMP Remind me to remove -If hit-boxes don't work out, we may still need this-  

exec function SetCylinder(float NewRadius, float NewHeight)
{
	if( UTPawn(Pawn).CylinderComponent != none) 
	{
		UTPawn(Pawn).CylinderComponent.SetCylinderSize(NewRadius, NewHeight);
	}
	
}

*/

simulated function int RefillCooldown()
{
	return RefillCooldownTime;	
}

simulated function RefillCooldownTimer()
{
	if(RefillCooldownTime > 0)
		RefillCooldownTime--;
	else
		ClearTimer('RefillCooldownTimer');
}

simulated function FindORI()
{
	local Rx_ORI ORI;
	
	if(myORI == none) //Find my ORI
	{
		
		foreach AllActors(class'Rx_ORI', ORI)
		{
			myORI = ORI ;
			ClearTimer('FindORI'); //found, stop. 
			break;
		
		}
		
	}
}

exec function GiveVP(float amount)
{
	if (WorldInfo.NetMode == NM_Standalone)
		Rx_PRI(PlayerReplicationInfo).AddVP(amount);
}

exec function GiveCP(float amount)
{
	if (WorldInfo.NetMode == NM_Standalone)
	{
		Rx_TeamInfo(PlayerReplicationInfo.Team).AddCommandPoints(amount);
	}
}

exec function GivePromotion()
{
	if (WorldInfo.NetMode == NM_Standalone && Rx_PRI(PlayerReplicationInfo).VRank < ArrayCount(Rx_Game(WorldInfo.Game).default.VPMilestones))
		Rx_PRI(PlayerReplicationInfo).AddVP(Rx_Game(WorldInfo.Game).default.VPMilestones[Rx_PRI(PlayerReplicationInfo).VRank] - Rx_PRI(PlayerReplicationInfo).Veterancy_Points);
}

function PromoteMe(byte rank)
{
	if (rank < 0)
		rank = 0;
	else if(rank > 3)
		rank = 3; 

	if(Rx_Vehicle(Pawn) != None)
		Rx_Vehicle(Pawn).PromoteUnit(rank) ; 
	else if(Rx_Pawn(Pawn) != None)
		Rx_Pawn(Pawn).PromoteUnit(rank) ; 
}

function DisseminateVPString(coerce string VPString)
{
	local int VP_Total, WorkingLength; 
	local string CurStr; //Hold our string as it's broken up
	local string StringPiece; //Current piece of string we're working with
	local bool isVetGainedInOwnBase; 
	
	CurStr = VPString ;
	while ( Instr(CurStr,"&") != -1) 
	{
		//First piece should ALWAYS be a string
		StringPiece = Left(CurStr, InStr(CurStr, "&"));
	
		if(InStr(StringPiece,"Defensive") > 0)
		{
			isVetGainedInOwnBase = true;	 	
		}
	
		//Feat_List.AddItem(StringPiece); 
		CurStr=Right(CurStr, (Len(CurStr)-(Len(StringPiece)+1) )); //Delete the piece we were working with

		//Second piece should ALWAYS be a number
		StringPiece = Left(CurStr, InStr(CurStr, "&"));
	
		WorkingLength=int(StringPiece);  //Repurposed variable
		VP_Total+=WorkingLength;
	 
		CurStr=Right(CurStr, (Len(CurStr)-(Len(StringPiece)+1) )); //Delete the piece we were working with
	}
	
	if(VP_Total > 0) 
	{
		Rx_PRI(PlayerReplicationInfo).AddVP(VP_Total);
		if(!isVetGainedInOwnBase)
		{
			Rx_PRI(PlayerReplicationInfo).RecordNonDefensiveVP(VP_Total);
		}
	}
	
	ClientSendFeelGoodMessage(VPString);
}

/*Can be called directly to just send other messages to subtitles (which is where VP is displayed)*/
/*E.G: CP gained messages can use this to have feedback for CP gained. Just make sure to pay attention to your & delimiters*/
unreliable client function ClientSendFeelGoodMessage(coerce string VPString, optional string MessageSuffix)
{
	local int WorkingLength; 
	local string CurStr; //Hold our string as it's broken up
	local string StringPiece, FeatStr; //Current piece of string we're working with 
	//local array<string> Feat_List; 

	if(MessageSuffix == "") MessageSuffix = "VP" ; 
	
	CurStr = VPString ;
	
	while ( Instr(CurStr,"&") != -1) 
	{
		FeatStr = "";
		
		StringPiece = Left(CurStr, InStr(CurStr, "&"));
		
		FeatStr = StringPiece;

		CurStr=Right(CurStr, (Len(CurStr)-(Len(StringPiece)+1) )); //Delete the piece we were working with
		
		StringPiece = Left(CurStr, InStr(CurStr, "&"));
		
		WorkingLength=int(StringPiece);  //Repurposed variable
	
		if(WorkingLength < 0) FeatStr = "<font color='#ff0000'>"$ FeatStr @ WorkingLength $ MessageSuffix $ "</font>" ; // '-' is already provided just by it being negative. 
		else
		FeatStr = FeatStr @ "+" $ WorkingLength $ MessageSuffix;

		CurStr=Right(CurStr, (Len(CurStr)-(Len(StringPiece)+1) )); //Delete the piece we were working with
		
		if(MessageSuffix == "CP") FeatStr = "<font color='#00FF7F'>" $ FeatStr $ "</font>" ; 
		
		Rx_HUD(myHud).HudMovie.Subtitle_Messages.AddItem(FeatStr); 
	}
	
	
}

 
reliable server function SendRconOutCommand(string Command)
{
	`RxEngineObject.RconOutLog("PLAYER" `s "Command;" `s `PlayerLog(PlayerReplicationInfo) `s Command);
}

reliable client function PlayKillSound()
{
	//play kill sound based on settings (nBab)
	switch (Rx_HUD(myHUD).SystemSettingsHandler.GetKillSound())
	{
		case 0:		
			ClientPlaySound(SoundCue'RX_SoundEffects.SFX.SC_Boink');
			break;
		case 1:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Boink_Modern');
			break;
		case 2:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Kill_Alert_Cue');
			break;
		case 3:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_Havoc');
			break;
		case 4:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.SC_McFarland');
			break;
		case 5:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Gotchya_Cue');
			break;
		case 6:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Aww_Too_Easy_Cue');
			break;
		case 7:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_For_Kane_Cue');
			break;
		case 8:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Die_Infidel_Cue');
			break;
		case 9:
			ClientPlaySound(SoundCue'RX_SoundEffects.Kill_Sounds.S_Goat_Cue');
			break;
		default:
			//no sound
			break;
	}
}

simulated function AddHit()
{
	
	if(WorldInfo.TimeSeconds - LastHitSomethingTime > 15.0) ResetCurrentTrackAccuracy(); 
	LastHitSomethingTime = WorldInfo.TimeSeconds;
	K_Logs[Current_K_Log].Hits+=1.0 ; 
}

simulated function AddHSHit()
{
	if(WorldInfo.TimeSeconds - LastHitSomethingTime > 15.0) ResetCurrentTrackAccuracy(); 
	LastHitSomethingTime = WorldInfo.TimeSeconds;
	//Trade one hit for a headshot hit
	K_Logs[Current_K_Log].Hits-=1.0 ; 
	K_Logs[Current_K_Log].HeadShots++ ; 
	
}

simulated function AddShot()
{
	K_Logs[Current_K_Log].Shots++ ; 
}

simulated function ResetCurrentTrackAccuracy()
{
	K_Logs[Current_K_Log].Hits = 0 ;
	K_Logs[Current_K_Log].Shots = 0 ;
	K_Logs[Current_K_Log].HeadShots = 0; 	
}

simulated function PlayTaunt(byte Option = 0)
{
	if(Rx_Pawn(Pawn) != none) 
	{
		Rx_Pawn(Pawn).PlayTaunt(Option); 
		bTauntMenuOpen=false;
		bCanTaunt=false; 
		SetTimer(5.0,false, 'ResetCanTaunt');	
	}
	else if(Rx_Vehicle(Pawn) != none && Rx_Pawn( Rx_Vehicle(Pawn).Driver) != none) 
	{
		Rx_Pawn( Rx_Vehicle(Pawn).Driver).PlayTaunt(Option);
		bTauntMenuOpen=false;
		bCanTaunt=false; 
		SetTimer(5.0,false, 'ResetCanTaunt');	
	}
}

function ResetCanTaunt()
{
	bCanTaunt=true;
}

exec event SetAudioGroupVolume( name GroupName, float Volume )
{

if(GroupName == 'SFX') 
{
	super.SetAudioGroupVolume(GroupName, Volume); 
	super.SetAudioGroupVolume('Weapon', Volume);
	super.SetAudioGroupVolume('UI', Volume);  
	super.SetAudioGroupVolume('Item', Volume); 
	super.SetAudioGroupVolume('Character', Volume);
	super.SetAudioGroupVolume('WeaponBulletEffects', Volume);  
}
else
super.SetAudioGroupVolume(GroupName, Volume);

}

function AddToKeyString (coerce string KeyInput)
{

	if(KeyInput ~= "LeftMouseButton") KeyInput = "LMB";	
	else
	if(KeyInput ~= "RightMouseButton") KeyInput = "RMB";
	else
	if(KeyInput ~= "RightShift") KeyInput = "RSh";
	else
	if(KeyInput ~= "LeftShift") KeyInput = "LSh";
	else
	if(KeyInput ~= "RightControl") KeyInput = "RCnt";
	else	
	if(KeyInput ~= "LeftControl") KeyInput = "LCnt";
	else
	if(KeyInput ~= "LeftAlt") KeyInput = "LAlt";	
	else
	if(KeyInput ~= "RightAlt") KeyInput = "RAlt";
	else
	if(KeyInput ~= "CapsLock") KeyInput = "Caps";
	else
	if(KeyInput ~= "MouseScrollDown") KeyInput = "MWD";
	else
	if(KeyInput ~= "MouseScrollUp") KeyInput = "MWU";	
	else
	if(KeyInput ~= "MiddleMouseButton") KeyInput = "MMB";
	else
	if(KeyInput ~= "SpaceBar") KeyInput = "SpBr";						
		
	if(Len(K_Logs[Current_K_Log].KillInputs) < 128) K_Logs[Current_K_Log].KillInputs = K_Logs[Current_K_Log].KillInputs @ KeyInput;
	else
	K_Logs[Current_K_Log].KillInputs = Right(K_Logs[Current_K_Log].KillInputs, 8) @ KeyInput; 
}

reliable client function SLogKill(class<DamageType> damageType, string KilledPlayer)
{
	local string ROFString; 

	if(KilledPlayer == "") 
		return; 
	
	if(Rx_Vehicle_Weapon(Pawn.Weapon) != none) 
		ROFString = Rx_Vehicle_Weapon(Pawn.Weapon).GetROFAVG();
	else
		ROFString = Rx_Weapon(Pawn.Weapon).GetROFAVG()	; 

	if(K_Logs[Current_K_Log].Shots < 1 && Rx_Weapon_Deployable(Pawn.Weapon) == none) K_Logs[Current_K_Log].Shots=1; //Accuracy was likely reset from not shooting anything in forever. 
		
		//Probably a bot or something weird
	
	K_Logs[Current_K_Log].KillString = "Killed" @ KilledPlayer @ "with" @ Pawn.Weapon.class @ 
	"-- Shots:" @ K_Logs[Current_K_Log].Shots $ " | BodyShots:" @ K_Logs[Current_K_Log].Hits $ " | HeadShots:" @ K_Logs[Current_K_Log].HeadShots @ "ROF Sway:" @ ROFString ;
		
	ServerSendKillLog(K_Logs[Current_K_Log], Current_K_Log);
		
	//`log("---KILL LOG:" @ K_Logs[Current_K_Log].KillString);

	if(Current_K_Log < 4) 
	{
		Clear_K_Log(Current_K_Log+1);
		Current_K_Log+=1;
	}
	else
	{
		Current_K_Log = 0; 
		Clear_K_Log(0); 
	}
}

function Clear_K_Log(byte num)
{
	K_Logs[num].KillInputs = "";
	K_Logs[num].KillString = "";
	//K_Logs[num].Kills = 0 ;
	K_Logs[num].Hits = 0 ;
	K_Logs[num].Shots = 0 ;
	K_Logs[num].HeadShots = 0; 
}

function LogStartFire()
{
	if(Worldinfo.TimeSeconds - LastStartFireTime >= 1) 
		{
		StartFiresThisSecond=0; 	
		}
		
		LastStartFireTime = Worldinfo.TimeSeconds;
		
		StartFiresThisSecond++;	
		
		if(StartFiresThisSecond > 8 && bCanThrowSF_Flag) 
		{
			ServerSendStartFireFlag(); 
			StartFiresThisSecond=0; 
		}
}
	
reliable server function ServerSendKillLog(K_Log KL, byte num)
{
	K_Logs[num] = KL;
	//log(K_Logs[num]) ;
	//`LogRx("PLAYER" `s "[KILL]" `s K_Logs[num].KillString `s " ----- Inputs: " `s K_Logs[num].KillInputs `s `PlayerLog(PlayerReplicationInfo));		
}

reliable server function ServerSendStartFireFlag()
{
	`LogRx("[FLAG]" `s "PLAYER" `s "Excessive StartFires Called;" `s `PlayerLog(PlayerReplicationInfo));
	StartFire_FLAGs++;
	if(StartFire_FLAGs >= 8) 
		bCanThrowSF_Flag=false; 
}

function ToggleSuspect()
{
	if(bSuspect) 
	{
		bSuspect=false;	
		return;
	}
	else
	{
		bSuspect=true;	
		return;
	}
}

simulated function DumpKillLog(bool WithInputs)
{
	local int i;
	
	if(WorldInfo.NetMode == NM_Client)
	{
		ServerDumpKillLog(WithInputs);	
		return;
	}
	
	for(i=0;i<5;i++)
	{
	 if(WithInputs)
		`LogRx("PLAYER" `s "[KILL_LOG]" `s K_Logs[i].KillString `s " ----- Inputs: " `s K_Logs[i].KillInputs `s `PlayerLog(PlayerReplicationInfo));	
	 else
		`LogRx("PLAYER" `s "[KILL_LOG]" `s K_Logs[i].KillString `s `PlayerLog(PlayerReplicationInfo));	
	}
}

reliable server function ServerDumpKillLog(bool WithInputs)
{
	DumpKillLog(WithInputs);
}

//"Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift Shift [Kill] [Headshot] [Last 5 seconds] 5 Hits 40 shots 6 Headshots Health at 40%"

/**exec function ChangeCommander()
{
	Rx_Game(WorldInfo.Game).ChangeCommander(GetTeamNum(), Rx_PRI(PlayerReplicationInfo)) ;
}*/

simulated function bool bPlayerIsCommander()
{
	return Rx_PRI(PlayerReplicationInfo).bISCommander;
}

/**exec function ToggleCommandSpot()
{
	if(bPlayerIsCommander()) 
	{
		ClientPlaySound(WeaponSwitchSoundCue);
		if(bCommandSpotting) bCommandSpotting = false;
		else
		bCommandSpotting = true; 
	};
}
*/

exec function ToggleAbility(optional byte AbilityNumber = 0) 
{	
	if(Pawn != none && Rx_Weapon(Pawn.weapon).AttachedWeaponAbility != none) 
			AbilityNumber = Rx_Weapon(Pawn.weapon).AttachedWeaponAbility.AssignedSlot;
	Rx_InventoryManager(Pawn.InvManager).ClientSwitchToWeaponAbility(AbilityNumber) ; 
} 

/***************************************
******Start of Commander Abilities********
***************************************/

function QHeldTimer()
{
	if(Com_Menu != none && Com_Menu.MenuTab != none && Com_Menu.MenuTab.bQCast) 
	{
		
	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		DestroyOldComMenu(); 
		return; 
	}
		
		Com_Menu.MenuTab.QCast(true);
		bQHeld=true; 
	}
}

function bool SetWaypoint(string WayPointName, optional string MetaTag)
{

	local vector startL, normthing, endL;
	local rotator ADir					;
	local Actor Actor_Discard			;
	// get aiming direction from our instigator (Assume this is the pawn from what I've read.)

	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		return false; 
	}
	
	ADir = Pawn.GetBaseAimRotation();
	
	if(Rx_Vehicle(Pawn) != none && Rx_Vehicle_Weapon(Pawn.Weapon) != none) startL=Rx_Vehicle_Weapon(Pawn.Weapon).InstantFireStartTrace(); //Using function out of Rx_weapon to find the end of our weapon, or just our own location
	else 
	if(Rx_Vehicle(Pawn) != none && Rx_Vehicle_Weapon(Pawn.Weapon) == none) startL = Rx_Vehicle(Pawn).location; 
	else //Not in a vehicle 
	if(Rx_Pawn(Pawn) != none && Rx_Weapon(Pawn.Weapon) != none) startL=Rx_Weapon(Pawn.Weapon).InstantFireStartTrace(); //Using function out of Rx_weapon to find the end of our weapon, or just our own location
	
	//.......... Yosh need learn math. Working in 3D space is making me twitchy X.x. Comment from the commander mod 2 years ago. And I still haven't learned how to math
	
	Actor_Discard=Trace(endL, normthing, startL + vector(Adir) * MaxCommanderSpottingRange, startL, true) ;
	
	if(Actor_Discard == none) 
	{
		return false;	
	}
	
	endL.Z+=50; //Don't sit right on the ground... It's weird.
	
	ServerSetWaypoint(WaypointName, endL, MetaTag);
	return true; 
}

reliable server function ServerSetWaypoint(string WayPointName, vector WaypointLocation, optional string MetaTag)
{
	local Rx_CommanderWaypoint WP; 
	
	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		return; 
	}
	
	WP=spawn(class'Rx_CommanderWaypoint',,,WaypointLocation,,, true); 
	
	WP.InitWaypoint(WayPointName, GetTeamNum(), MetaTag);
	
}

function RemoveWaypoint(string WayPointName, optional string MetaTag)
{
	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		return; 
	}
	
	ServerRemoveWaypoint(WayPointName, MetaTag);
}

reliable server function ServerRemoveWaypoint(string WayPointName, optional string MetaTag)
{
	local Rx_CommanderWaypoint WP; 
	foreach WorldInfo.AllActors(class'Rx_CommanderWaypoint', WP)
	{
		if(WP.GetTeamNum() != GetTeamNum()) continue ; 
		
		if(WP.GetName() == WayPointName || (MetaTag != "" && WP.GetMetaTag() == MetaTag) ) 
		{
			WP.Destroy();
			break; 	
		}
	}
}

function RemoveMinesFromBuilding(byte BuildingType)
{
	
	ServerRemoveMinesFromBuilding(BuildingType);
	
}

reliable server function ServerRemoveMinesFromBuilding(byte BuildingType)
{
	local byte TeamByte; 
	local Rx_Building BLDG;
	local Rx_Weapon_DeployedProxyC4 Proxies;

	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		return; 
	}

	TeamByte = GetTeamNum();
	
	if(BuildingType == 0) //PP
	{
		foreach WorldInfo.AllActors(class'Rx_Building', BLDG)
		{
			if(TeamByte == 0 && Rx_Building_GDI_PowerFactory(BLDG) != none) 
			{
				BLDG.RemoveMyMines(self);
				return; 
			}  
			else
			if(TeamByte == 1 && Rx_Building_Nod_PowerFactory(BLDG) != none) 
			{
				BLDG.RemoveMyMines(self);
				return; 
			}  
			
		}
	}
	else
	if(BuildingType == 1) //Refineries
	{
		foreach WorldInfo.AllActors(class'Rx_Building', BLDG)
		{
			if(TeamByte == 0 && Rx_Building_GDI_MoneyFactory(BLDG) != none) 
			{
				BLDG.RemoveMyMines(self);
				return; 
			}  
			else
			if(TeamByte == 1 && Rx_Building_Nod_MoneyFactory(BLDG) != none)
			{
				BLDG.RemoveMyMines(self);
				return; 
			}   
		}
	}
	else
	if(BuildingType == 2)				//Infantry Factories
	{
		foreach WorldInfo.AllActors(class'Rx_Building', BLDG) 
		{
				if(TeamByte == 0 && Rx_Building_GDI_InfantryFactory(BLDG) != none)
				{
					BLDG.RemoveMyMines(self);
					return; 
				}
			else
				if(TeamByte == 1 && Rx_Building_Nod_InfantryFactory(BLDG) != none)
				{
					BLDG.RemoveMyMines(self);
					return; 
				}  
			}
		}
		else
		if(BuildingType == 3)//Vehicle Factories
		{
			foreach WorldInfo.AllActors(class'Rx_Building', BLDG)
			{
				if(TeamByte == 0 && Rx_Building_GDI_VehicleFactory(BLDG) != none)
				{
					BLDG.RemoveMyMines(self);
					return; 
				}  
				else
				if(TeamByte == 1 && (Rx_Building_Nod_VehicleFactory(BLDG) != none || Rx_Building_AirTower(BLDG) != none)) 
				{
					BLDG.RemoveMyMines(self);
					return; 
				}  
			}
		}
		else
		if(BuildingType == 4)//Defense Factories
		{
			foreach WorldInfo.AllActors(class'Rx_Building', BLDG)
			{
				if(TeamByte == 0 && Rx_Building_GDI_Defense(BLDG) != none)
				{
					BLDG.RemoveMyMines(self);
					return; 
				}  
				else
				if(TeamByte == 1 && Rx_Building_Nod_Defense(BLDG) != none)
				{
					BLDG.RemoveMyMines(self);
					return; 
				}  
			}
		}
		else
		if(BuildingType == 5) //All other mines on any surface not a building
		{
			foreach WorldInfo.AllActors(class'Rx_Weapon_DeployedProxyC4', Proxies)
			{
				if(Proxies.GetTeamNum() == TeamByte && Rx_Building(Proxies.Base) == none )
				{
					Proxies.TakeDamage(500, self, vect(0,0,0), vect(0,0,0), class'Rx_DmgType_EMP') ; 
				}
			}
		}
}

function bool TrySupportPowerCast(class<Rx_CommanderSupport_BeaconInfo> BeaconInfo) //(byte AbilityNumber)
{
	local vector startL, normthing, endL;
	local rotator ADir,FlatRotation					;  
	local Actor Actor_Discard;

	//NOTE : 65536 RUU  360degrees 
	
	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		return false; 
	}

	FlatRotation = rotation;

	FlatRotation.Pitch	= 0	;  
	FlatRotation.Roll	= 0	;

	// get aiming direction from our instigator (Assume this is the pawn from what I've read.)
	 ADir = Pawn.GetBaseAimRotation();
		
		if(Rx_Vehicle(Pawn) != none && Rx_Vehicle_Weapon(Pawn.Weapon) != none) 
			startL=Rx_Vehicle_Weapon(Pawn.Weapon).InstantFireStartTrace(); //Using function out of Rx_weapon to find the end of our weapon, or just our own location
		else //Not in a vehicle 
		if(Rx_Vehicle(Pawn) != none && Rx_Vehicle_Weapon(Pawn.Weapon) == none) 
			startL = Rx_Vehicle(Pawn).location; 
		else
		if(Rx_Pawn(Pawn) != none && Rx_Weapon(Pawn.Weapon) != none) 
			startL=Rx_Weapon(Pawn.Weapon).InstantFireStartTrace(); //Using function out of Rx_weapon to find the end of our weapon, or just our own location
		
		//.......... Yosh need learn math. Working in 3D space is making me twitchy X.x. Comment from the commander mod 2 years ago. And I still haven't learned how to math
		
		/*Is this a ranged support power?*/
		if(CommanderTargetingReticule.MaxSpotRange > 0) 
		{
			Actor_Discard=Trace(endL, normthing, GetHUDAim() + vector(ADir) * 10, startL, true,,,1) ; //startL + vector(Adir) * GetWeapon, startL, true) ;
			
			if(Actor_Discard == none) 
			{
				CTextMessage("Casting Failed"); 
				return false;	
			}
		}
		else
		{
			endL=Pawn.location;
			endL.Z-=20;
		}
		
		
		if(BeaconInfo.default.VerticalClearanceNeeded > 0 && !SufficientVerticalSpace(endL, BeaconInfo.default.VerticalClearanceNeeded))
		{
			CTextMessage("Insufficient vertical clearance"); 
			return false;
		}
		else if(!BeaconInfo.static.bCanFire(self))
				return false; 
		else if(BeaconInfo.static.IsEntryVectorClear(endL, FlatRotation, self) )
				{
					ServerSupportPowerCast(BeaconInfo, endL) ;
					return true ; 
				}
		else
			{
				CTextMessage("Insufficient Flight Path Clearance"); 
				return false;	
			}
		
	return false; 
}

reliable server function ServerSupportPowerCast(class<Rx_CommanderSupport_BeaconInfo> BeaconInfo, vector PowerLocation)
{
	local Rx_CommanderSupportBeacon SB;
	local vector ZAdjust; 
	local rotator FlatRotation; 
	
	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		return; 
	}
	
	 if(!BeaconInfo.static.bCanFire(self))
				return; 
	
	FlatRotation.Yaw = rotation.Yaw;
	
	/*Inject to check if we have appropriate Command Points to do this*/
	if(Rx_TeamInfo(PlayerReplicationInfo.Team).GetCommandPoints() < BeaconInfo.default.CPCost) 
	{
		CTextMessage("Insufficient Command Points");
		return ;	
	}
	
	Rx_TeamInfo(PlayerReplicationInfo.Team).AddCommandPoints(-1*BeaconInfo.default.CPCost); 
	
	ZAdjust.Z = 20; 
	
	PowerLocation.Z += ZAdjust.Z;
	
	//`log("RXCS:" @ BeaconInfo); 
	if(GetTeamNum() == 0) SB=spawn(class'Rx_CommanderSupportBeacon_GDI',,,PowerLocation,FlatRotation,, true); 
	else
	SB=spawn(class'Rx_CommanderSupportBeacon_Nod',,,PowerLocation,FlatRotation,, true); 

	SB.Init(GetTeamNum(), BeaconInfo, self);
	
	
	//`log("Cast Power: " @ AbilityNumber @ "At" @ PowerLocation);
	
	
}

function bool SufficientVerticalSpace(vector Locale, int TraceHeight)
{
	local vector  endL; //startL, normthing,
	//local rotator ADir					;
	//local Actor Vertical_Actor	;

	//ADir.Pitch = 16384 ;	//Vertical rotator

	Locale.Z = Locale.Z + 510;//+ 10; //Don't trace right on the ground

	endL = Locale; 

	endL.Z = endL.Z+TraceHeight; 


	//Vertical_Actor=Trace(endL, normthing, startL + vector(Adir) * TraceHeight, startL, true) ; 



	return FastTrace(Locale, endL); //Vertical_Actor == none ;


}


function SetLastSupportHealTime()
{
	LastSupportHealTime = int(WorldInfo.TimeSeconds);
	
}

function CommandHarvester(byte AbilityNumber)
{
	ServerCommandHarvester(AbilityNumber);
} 

reliable server function ServerCommandHarvester(byte AbilityNumber)
{
	local Rx_Vehicle_Harvester TH;
	local Rx_Vehicle_HarvesterController TeamHarvesterController;
	local bool	bCommandSuccess; 
	
	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander",'Red'); 
		return; 
	}
	
	foreach DynamicActors(class'Rx_Vehicle_Harvester', TH)
	{
		if(TH.GetTeamNum() == GetTeamNum() && TH.Controller != none) 
		{
			TeamHarvesterController = Rx_Vehicle_HarvesterController(TH.Controller);
			break; 
		}
	}
	
	if(TeamHarvesterController == none && AbilityNumber != 2) 
	{
		CTextMessage("Command Failed",'Red');
		return;
	}
	
	if(AbilityNumber == 0)
	{
		bCommandSuccess = TeamHarvesterController.ToggleHaltHarv(self);
		
		if(bCommandSuccess)
			SetTeamHarvesterStopped(); 
	}
	else
	if(AbilityNumber == 1)
	{
		if(GetTeamNum() == 0) 
		{
			bCommandSuccess = SetWaypoint("Harvester Standby","GDI_Harvester_Halt");
			TeamHarvesterController.UpdateHaltedHarvWaypoint(false);
		}
		else
		if(GetTeamNum() == 1) 
		{
			bCommandSuccess = SetWaypoint("Harvester Standby","Nod_Harvester_Halt");
			TeamHarvesterController.UpdateHaltedHarvWaypoint(false);
		}
		else
		bCommandSuccess = false; 
	}
	else
	if(AbilityNumber == 2)
	{
			if(GetTeamNum() == 0) 
			{
				RemoveWaypoint("Harvester Standby","GDI_Harvester_Halt");
				if(TeamHarvesterController != none) 
					TeamHarvesterController.UpdateHaltedHarvWaypoint(false);
				
				bCommandSuccess = true; 
			}
			else
			if(GetTeamNum() == 1) 
			{
				RemoveWaypoint("Harvester Standby","Nod_Harvester_Halt");
				
				if(TeamHarvesterController != none) 
					TeamHarvesterController.UpdateHaltedHarvWaypoint(false);
				bCommandSuccess = true;
			}
	}
	else
	if(AbilityNumber == 3)
	{
		if(TeamHarvesterController != none) 
		{
			TeamHarvesterController.ToggleSelfDestructTimer(self); 
			bCommandSuccess = true; 
		}
	}
	else
	bCommandSuccess = false;

	if(!bCommandSuccess) CTextMessage("Command Failed", 'Red'); 
	
	
}

/***************************************
******End of Commander Abilities********
***************************************/

exec function ToggleTargettingBox()
{
	Rx_PlayerInput(PlayerInput).ToggleTargettingBox();
}

exec function BumpGrenadeMC(int B)
{
	local Rx_HUD rxhud; 

	rxhud=Rx_HUD(MyHUD); 
	rxhud.HUDMovie.BumpGrenadeMC(B);
}

/**Set modifiers**/

function AddActiveModifier(class<Rx_StatModifierInfo> Info)//class<Rx_StatModifierInfo> Info) 
{
	local int FindI; 
	local ActiveModifier TempModifier; 
	//local class<Rx_StatModifierInfo> Info; 
	
	//Info = class'Rx_StatModifierInfo_Nod_PTP';
	
	FindI = ActiveModifications.Find('ModInfo', Info);
	
	//Do not allow stacking of the same modification. Instead, reset the end time of said modification
	if(FindI != -1) 
	{
		//`log("Found in array");
		ActiveModifications[FindI].EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length; 
		//return; 	
	}
	else //New modifier, so add it in and re-update modification numbers
	{
		CTextMessage("Modifier Received: "$ Info.default.ModificationName, 'LightBlue');
		
		//`log("Adding to array"); 
		TempModifier.ModInfo = Info; 
		if(Info.default.Mod_Length > 0) TempModifier.EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length;
		else
		TempModifier.Permanent = true; 
		ActiveModifications.AddItem(TempModifier);	
	}
	
	UpdateModifiedStats();
}

function UpdateModifiedStats()
{
	local ActiveModifier TempMod;
	local byte			 HighestPriority; 
	//local LinearColor	 PriorityColor; 
	local bool			 bAffectsWeapon;
	local class<Rx_StatModifierInfo> PriorityModClass; /*Highest priority modifier class (For deciding what overlay to use)*/
	
	ClearAllModifications(); //start from scratch
	HighestPriority = 255 ; // 255 for none
	
	if(ActiveModifications.Length < 1) 
	{
		if(Rx_Pawn(Pawn) != none) 
		{
			//In case speed was modified. Update animation info
			Rx_Pawn(Pawn).SetSpeedUpgradeMod(0.0);
			Rx_Pawn(Pawn).UpdateRunSpeedNode(); 
			Rx_Pawn(Pawn).SetGroundSpeed();
			Rx_Pawn(Pawn).ClearOverlay();
		}
		else if(Rx_Vehicle(Pawn) != none)
		{
			Rx_Vehicle(Pawn).ClearOverlay();
		}
		//TODO: Insert code to handle vehicles 
		return; 	
	}
	
	foreach ActiveModifications(TempMod) //Build all buffs
	{
		Misc_SpeedModifier+=TempMod.ModInfo.default.SpeedModifier;	
		Misc_DamageBoostMod+=TempMod.ModInfo.default.DamageBoostMod;	
		Misc_RateOfFireMod-=TempMod.ModInfo.default.RateOfFireMod;
		Misc_ReloadSpeedMod-=TempMod.ModInfo.default.ReloadSpeedMod;
		Misc_DamageResistanceMod-=TempMod.ModInfo.default.DamageResistanceMod;
		Misc_RegenerationMod+=TempMod.ModInfo.default.RegenerationMod;
		bAffectsWeapon=TempMod.ModInfo.static.bAffectsWeapons();
		if(TempMod.ModInfo.default.EffectPriority < HighestPriority || TempMod.ModInfo.default.EffectPriority == 0) 
		{
			HighestPriority = TempMod.ModInfo.default.EffectPriority;
			//PriorityColor = TempMod.ModInfo.default.EffectColor;
			PriorityModClass = TempMod.ModInfo;
		}
	}
	
	
	if(Rx_Pawn(Pawn) != none) 
	{
		//In case speed was modified. Update animation info
		Rx_Pawn(Pawn).SetSpeedUpgradeMod(Misc_SpeedModifier);
		Rx_Pawn(Pawn).UpdateRunSpeedNode();
		Rx_Pawn(Pawn).SetGroundSpeed();
		Rx_Pawn(Pawn).SetOverlay(PriorityModClass, bAffectsWeapon) ; 
		
		if(Rx_Weapon(Pawn.Weapon) != none) Rx_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
	else if(Rx_Vehicle(Pawn) != none) 
	{
		//Misc_SpeedModifier+=1.0; //Add one to account for vehicles not operating like Rx_Pawn 
		Rx_Vehicle(Pawn).UpdateThrottleAndTorqueVars();
		Rx_Vehicle(Pawn).SetOverlay(PriorityModClass.default.EffectColor) ; 
		
		if(Rx_Vehicle_Weapon(Pawn.Weapon) != none) Rx_Vehicle_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
	
	ClientPlaySound(SoundCue'Rx_Pickups.Sounds.SC_Pickup_Health'); 
}

function ClearAllModifications()
{
	//Buff/Debuff modifiers
	Misc_SpeedModifier 			= default.Misc_SpeedModifier;

	//Weapons
	Misc_DamageBoostMod 		= default.Misc_DamageBoostMod; 
	Misc_RateOfFireMod 			= default.Misc_RateOfFireMod; 
	Misc_ReloadSpeedMod 		= default.Misc_ReloadSpeedMod; 

	//Survivablity
	Misc_DamageResistanceMod 	= default.Misc_DamageResistanceMod;
	Misc_RegenerationMod 		= default.Misc_RegenerationMod; 	
}

function RemoveAllEffects()
{
	ActiveModifications.Length = 0; 
	
	UpdateModifiedStats(); 
}

function CheckActiveModifiers()
{
	local ActiveModifier TempMod;
	local float			 TimeS; 
	
	if(ActiveModifications.Length < 1) return; 
	
	TimeS=WorldInfo.TimeSeconds; 
	
	//Should never be more than 1 or 2 of these at any given time, so shouldn't affect tick, though can be moved to a timer if necessary. 
	foreach ActiveModifications(TempMod) 
	{
		if(!TempMod.Permanent && TimeS >= TempMod.EndTime) 
		{
			ActiveModifications.RemoveItem(TempMod);
			
			UpdateModifiedStats(); 
		}
	}
}


state Spectating
{
	
	exec function ViewPlayerByName(string PlayerName)
	{
		ServerViewPlayerByName(PlayerName);
	}
	
	event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		PlayerReplicationInfo.bIsSpectator = true;
		SetTimer( 1.0, false, 'ServerViewNextPlayer');
	}

	event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		PlayerReplicationInfo.bIsSpectator = false;
	}	
	
	event PlayerTick( float DeltaTime )
	{
		Global.PlayerTick( DeltaTime );
		if (Pawn(ViewTarget) != None)
		{
			if(UtVehicle(ViewTarget) != None)
			{
				TargetViewRotation = UtVehicle(ViewTarget).WeaponRotation;
			}
			else
			{	
				TargetViewRotation = ViewTarget.Rotation;
				TargetViewRotation.Pitch = Pawn(ViewTarget).RemoteViewPitch << 8;
			}
		}
	}	
	
	simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
	{
		super.GetPlayerViewPoint(out_Location, out_Rotation);
		
		if(Rx_Pawn(ViewTarget) != None)
		{
			out_Location.Z += 50; 
		}	
	}	
	
	function UpdateRotation(float DeltaTime)
	{
		if(bLockRotationToViewTarget && Pawn(ViewTarget) != None)
			SetRotation(BlendedTargetViewRotation);				
		else
			super.UpdateRotation(DeltaTime);
	}	
	
	exec function StartAltFire( optional byte FireModeNum )
	{
		local vector loc;
		loc = ViewTarget.Location;
		super.StartAltFire(FireModeNum);
		loc.Z += 150;
		SetLocation(loc);
	}	
	
}


exec function QuickSupport(optional byte Key=0){
	
	EnableCommanderMenu();
	
	if(Com_Menu == none)
		return;
	
	Com_Menu.KeyPress(3); 
	
	Com_Menu.KeyPress(Key); 
	
}

/** Simply Shitty code */

exec function TakeSS(string target) {
	local PlayerReplicationInfo PRI;
	local string error;

	PRI = ParsePlayer(target, error);

	if (PRI != None)
		TakeSSServer(PRI);
	else
		ClientMessage(error);
}

reliable server function TakeSSServer(PlayerReplicationInfo target) {
	if (bIsDev || PlayerReplicationInfo.bAdmin) {
		if (target == PlayerReplicationInfo) {
			ClientMessage("SSERROR: Cannot request screenshot of self");
			return;
		}

		if (Rx_Controller(target.Owner).SSDataRequested) {
			ClientMessage("SSERROR: Request already in progress");
			return;
		}

		TakeSSInvoker();
		Rx_Controller(target.Owner).SSInvoker = PlayerReplicationInfo;
		Rx_Controller(target.Owner).SSDataRequested = true;
		Rx_Controller(target.Owner).RequestSS();
	}
}

reliable client function TakeSSInvoker() {
	SSDataRequested = true;
}

reliable client function RequestSS() {
	local LocalPlayer LP;

	LP = LocalPlayer(Player);
	if (LP != None && Rx_GameViewportClient(LP.ViewportClient) != None) {
		Rx_GameViewportClient(LP.ViewportClient).bTakeSS = true;
	}
}

function HandleSSCap(ByteArrayWrapper cap) {
	SSData = cap;
	SSDataChunksSent = 0;
	StartReplySS(cap.array.Length);
}

function bool PrepReplySS(int length) {
	// Verify that a SS was requested from this player
	if (!SSDataRequested) {
		`log("Unexpected SS Reply");
		return false;
	}

	// Sanity check length
	if (length < 8 || length > 1000000) {
		// SS size must be [8B, 1MB]
		`log("SS attempted with size: " $ length);
		return false;
	}

	SSData.array.Length = length;
	SSDataPending = length;
	return true;
}

reliable server function StartReplySS(int length) {
	if (PrepReplySS(length)) {
		// Prep invoker for reply
		if (SSInvoker != None && Rx_Controller(SSInvoker.Owner) != None) {
			Rx_Controller(SSInvoker.Owner).StartReplySSInvoker(length);
		}

		// Request chunks from client
		RequestChunksClient();
	}
	// else // TODO: kick client? cancel request?
}

reliable client function StartReplySSInvoker(int length) {
	PrepReplySS(length);
}

reliable client function RequestChunksClient() {
	local ByteBufferWrapper data;
	local int length, id, chunks;

	`RxEngineObject.DllCore.set_cap(data, SSData);

	chunks = Min(SSData.array.Length / ArrayCount(data.data) + 1, SSDataChunksSent + 16);
	for (id = SSDataChunksSent; id < chunks; ++id) {
		// Copy bytes from SSData.array to data
		length = `RxEngineObject.DllCore.read_cap(id * ArrayCount(data.data));
		ChunkReplySS(data.data, length, id);
		++SSDataChunksSent;
	}
}

function HandleChunkReply(byte data[256], int length, int id) {
	local int arrayIndex, dataIndex;

	// Verify that a SS was requested from this player
	if (!SSDataRequested) {
		`log("SSERROR: Unexpected SS Reply");
		return;
	}

	// Sanity check id
	if (id * ArrayCount(data) > SSData.array.Length) {
		`log("SSERROR: Bad id received; id: " $ id);
		return;
	}

	// Sanity check length
	if (length > ArrayCount(data) // length can't exceed size of data
		|| length > SSDataPending) { // length can't exceed size of pending data
		`log("SSERROR: Bad length received; length: " $ length $ "; SSDataPending: " $ SSDataPending);
		return;
	}

	// Sanity check length + id
	if (length + id * ArrayCount(data) > SSData.array.Length) { // length plus id offset can't exceed size of data
		`log("SSERROR: Bad length + id received; length: " $ length $ "; id: " $ id);
		return;
	}

	// Copy data from buffer into SSData array
	arrayIndex = ArrayCount(data) * id;
	while (dataIndex < length) {
		SSData.array[arrayIndex] = data[dataIndex];

		++dataIndex;
		++arrayIndex;
	}

	// Update tracking variables
	++SSDataChunksSent;
	SSDataPending -= length;

	if (SSDataPending == 0) {
		// All SS data has been received; write it
		WriteSSData();
		CleanupSSData();
	}
	else if (SSDataPending < 0) {
		`log("SSERROR: SSDataPending < 0: " $ SSDataPending);
	}
}

reliable server function ChunkReplySS(byte data[256], int length, int id) {
	// Replicate chunk to invoker
	if (SSInvoker != None && Rx_Controller(SSInvoker.Owner) != None) {
		Rx_Controller(SSInvoker.Owner).ChunkReplySSInvoker(data, length, id);
	}

	// Handle chunk
	HandleChunkReply(data, length, id);

	// Request more chunks from client if ready
	if (SSDataPending > 0 && SSDataChunksSent % 16 == 0) {
		// Request more chunks
		RequestChunksClient();
	}
}

reliable client function ChunkReplySSInvoker(byte data[256], int length, int id) {
	HandleChunkReply(data, length, id);
}

function CleanupSSData() {
	// Cleanup
	SSDataRequested = false;
	SSData.array.Length = 0;
	SSDataChunksSent = 0;
	SSInvoker = None;
}

function WriteSSData() {
	`RxEngineObject.DllCore.write_ss(SSData);
}

function ResetEnemySpottedCooldown(){
	bCanPlayEnemySpotted = true; 
}

//toggles the layout of the scoreboard in game
exec function ToggleScoreboard()
{
	Rx_Hud(MyHUD).ToggleScoreboard();
}

reliable client function ClientSetLocationAndKeepRotation( vector NewLocation )
{
	if ( Pawn != None )
		Pawn.SetLocation( NewLocation );
}

function ResetAFKTimer ()
{
	if(bIsAFK)
		UndeclareAFK();

	SetTimer(180.0,false,'DeclareAFK');
}

function DeclareAFK ()
{
	ServerDeclareAFK();
}

reliable server function ServerDeclareAFK()
{
	bIsAFK = true;
}

function UndeclareAFK ()
{
	ServerUndeclareAFK();
}

reliable server function ServerUndeclareAFK()
{
	bIsAFK = false;
}

function CheckJumpOrDuck()
{
	local RxIfc_PassiveAbility PassivesPawn; 
	//Check for abilities tied to jumping (EG, jump...boots. RIP Jumpie boots.)
	
	if(RxIfc_PassiveAbility(Pawn) != none)
		PassivesPawn = RxIfc_PassiveAbility(Pawn);
	if(PassivesPawn != none)
	{
		if(bPressedJump)
		{
			PassivesPawn.ActivateJumpAbility(true);
		}
			
		if(bJumpReleased && RxIfc_PassiveAbility(Pawn) != none)
		{
			PassivesPawn.ActivateJumpAbility(false);
		}	
		
		//Check for abilities tied to crouching 
		if(bDuck !=0)
		{
			PassivesPawn.NotifyPassivesCrouched(true);
		}
			
		if(bDuck == 1)
		{
			PassivesPawn.NotifyPassivesCrouched(false); 
		}	
	}
	
	
	//Parachute Logic 
	if (Rx_Pawn(Pawn)!= none && bPressedJump && Pawn.Physics == PHYS_Falling)
	{
		Rx_Pawn(Pawn).TryParachute();
	}
	else if (Rx_Pawn(Pawn)!= none && Rx_Pawn(Pawn).bBeaconDeployAnimating)
	{
		Pawn.ShouldCrouch(true);
	}
	else
	{
		super.CheckJumpOrDuck();
	}
	//Jump was released now
	bJumpReleased = false; 
}

exec function JumpReleased()
{
	bJumpReleased = true;
}

function SetTeamHarvesterStopped()
{
	if(Rx_TeamInfo(PlayerReplicationInfo.Team) != none)
	{
		Rx_TeamInfo(PlayerReplicationInfo.Team).ToggleHarvStopped();
	}
}

/** Properties */

DefaultProperties
{
	DamagePostProcessChain=PostProcessChain'RenXHud.PostProcess.PPC_HitEffect'
	MinRespawnDelay=3.0
	MaxRespawnDelay=8.0
	TimeSecondsTillMaxRespawnTime=2400 // 40 mins	
	RefillCooldownTime=8
	bRotateMiniMap=true
	InputClass=class'RenX_Game.RX_PlayerInput'
	currentCharIndex=1	
	camMode = ThirdPerson
	pressedDodgeDirection = EMPTY
	AchievementHandler = None	
	bIsDev = false
	RadarVisibility = 1 
	bDebugging = true 
	
	PTShortDelay = 0.3f
	PTLongDelay = 1.5f
	PTCooldownDelay = 1.5f
	PTShortAccessMax = 3

	PTAccessCount = 0
	bCanAccessPT = true
	PTMenuClass = class'Rx_GFxPurchaseMenu'

	bHasChangedFocus = false;

	CPCheckTime=1.0

	IsInPlayArea = true

	EndgameScoreboardDelay = 10.0
	
	//--------------Radio commands	
	// CTRL + Number
	
	RadioCommands(0)     =   SoundCue'RX_RadioSounds.Ctrl.01_BuildingNeedsRepairCue'
	RadioCommands(1)     =   SoundCue'RX_RadioSounds.Ctrl.02_GetInTheVehicleCue'
	RadioCommands(2)     =   SoundCue'RX_RadioSounds.Ctrl.03_GetOutofVehCue'
	RadioCommands(3)     =   SoundCue'RX_RadioSounds.Ctrl.04_DestroyThatVehCue'
	RadioCommands(4)     =   SoundCue'RX_RadioSounds.Ctrl.05_WatchWhereYourPointingThatCue'
	RadioCommands(5)     =   SoundCue'RX_RadioSounds.Ctrl.06_DontGetInMyWayCue'
	RadioCommands(6)     =   SoundCue'RX_RadioSounds.Ctrl.07_AffermativeCue'
	RadioCommands(7)     =   SoundCue'RX_RadioSounds.Ctrl.08_NegativeCue'
	RadioCommands(8)     =   SoundCue'RX_RadioSounds.Ctrl.09_ImInPositionCue'
	RadioCommands(9)     =   SoundCue'RX_RadioSounds.Ctrl.10_EnemySpotedCue'
	
	// ALT + Number
	
	RadioCommands(10)    =   SoundCue'RX_RadioSounds.Alt.01_INeedRepairsCue'
	RadioCommands(11)    =   SoundCue'RX_RadioSounds.Alt.02_TakeThePointCue'
	RadioCommands(12)    =   SoundCue'RX_RadioSounds.Alt.03_MoveOutCue'
	RadioCommands(13)    =   SoundCue'RX_RadioSounds.Alt.04_FollowMeCue'
	RadioCommands(14)    =   SoundCue'RX_RadioSounds.Alt.05_HoldPosisitionCue'
	RadioCommands(15)    =   SoundCue'RX_RadioSounds.Alt.06_CoverMeCue'
	RadioCommands(16)    =   SoundCue'RX_RadioSounds.Alt.07_TakeCoverCue'
	RadioCommands(17)    =   SoundCue'RX_RadioSounds.Alt.08_FallBackCue'
	RadioCommands(18)    =   SoundCue'RX_RadioSounds.Alt.09_ReturnToBaseCue'
	RadioCommands(19)    =   SoundCue'RX_RadioSounds.Alt.10_DestroyItNowCue'
	
	// CTRL+ALT + Number
	
	RadioCommands(20)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.01_AttackTheBaseDefencesCue'
	RadioCommands(21)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.02_AttackTheHarvCue'
	RadioCommands(22)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.03_AttachThatStructureCue'
	RadioCommands(23)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.04_AttackTheRefinaryCue'
	RadioCommands(24)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.05_AttackThePowerPlantCue'
	RadioCommands(25)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.06_DefendTheBaseCue'
	RadioCommands(26)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.07_DefendTheHarvesterCue'
	RadioCommands(27)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.08_DefendThatStrustureCue'
	RadioCommands(28)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.09_DefendTheRefinaryCue'
	RadioCommands(29)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.10_DefentThePowerplantCue'

	//Some Antispam measures
	EnemySpotSndCooldown = 3.0 //Lower the number of times "ENEMY SPOTTED" is broadcast 
	bCanPlayEnemySpotted = true 
	
	MapVote = -1	

	/** one1: added */
	VoteCommandText = "Vote Menu"
	DonateCommandText = "Donate"
	DeathCameraOffset = (X=150.0f, Y=0.0f, Z=20.0f)
	
	
	TeamVictorySound[0]        = SoundCue'RX_MusicTrack_2.Cue.SC_Endgame_Victory_GDI'
	TeamVictorySound[1]        = SoundCue'RX_MusicTrack_2.Cue.SC_Endgame_Victory_Nod'

	TeamDefeatSound[0]         = SoundCue'RX_MusicTrack_2.Cue.SC_Endgame_Defeat_GDI'
	TeamDefeatSound[1]         = SoundCue'RX_MusicTrack_2.Cue.SC_Endgame_Defeat_Nod'
	
	WeaponSwitchSoundCue	   = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue'
	
	Acc_Shots=1.0
	Acc_Hits=1.0
	
	bCanTaunt=true;
	bCanThrowSF_Flag=true
	
	NodColor            = "#FF0000"
	GDIColor            = "#FFC600"
	HostColor           = "#22BBFF"
	ArmourColor         = "#05DAFD"
	
	MaxCommanderSpottingRange = 99999
	
	//Buff/Debuff modifiers//

	Misc_SpeedModifier 			= 0.0 

	//Weapons
	Misc_DamageBoostMod 		= 0.0  
	Misc_RateOfFireMod 			= 0.0f //1.0 
	Misc_ReloadSpeedMod 		= 0.0f //1.0 

	//Survivablity
	Misc_DamageResistanceMod 	= 1.0 
	Misc_RegenerationMod 		= 1.0  
		
	RespawnTimeModifier			= 1.0

	CheatClass=class'Rx_CheatManager'
	bLockRotationToViewTarget   = true
	
	DamageCameraAnim = CameraAnim'RX_FX_Munitions2.Camera_FX.DamageViewShake'
}

