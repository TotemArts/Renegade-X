/**
 * RxController
 *
 * */
class Rx_Controller extends UTPlayerController;

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

//--------------Radio commands
var() array<SoundCue>       RadioCommands;
var() array<String>         RadioCommandsText;
var int                     numberOfRadioCommandsLastXSeconds;
var bool                    spotMessagesBlocked;
var bool                    bSpotting;
var Rx_Vehicle              BoundVehicle;

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
var class<GFxMoviePlayer> PTMenuClass;
var Rx_GFxPurchaseMenu PTMenu;

var SoundCue                            TeamVictorySound[2];
var SoundCue                            TeamDefeatSound[2];
var SoundCue							WeaponSwitchSoundCue; 

//-------------Vaulting Variables
var int ClimbHeight;

var name VaultStartSocketName;
var name VaultEndSocketName;
var Rx_Pawn Pv;
var bool bVaulted;
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
var GeminiOnlineService OnlineService;
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
var privatewrite bool bIsDev;
var privatewrite int ladder_rank;

replication
{
	// Things the server should send to the client.
	if ( bNetOwner && Role==ROLE_Authority && bNetDirty )
		ReplicatedHitIndicator;

	if (bNetDirty)
		VoteTopString, VotesYes, VotesNo, VoteTimeLeft, VotersTotal, YesVotesNeeded, ladder_rank, RefillCooldownTime;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(Worldinfo.NetMode != NM_DedicatedServer) {
		SetTimer(CPCheckTime,true,'CheckTouchingCapturePoints');
		//SetTimer(1.0,false,'CheckAuthentication');     
	}
	SetTimer(15.0f,true,'resetRadioCommandCountTimer');  

	/**
	if(InStr(string(WorldInfo.GetPackageName()), "CNC-Complex") == 0 && ((WorldInfo.NetMode == NM_Client) || (WorldInfo.NetMode == NM_Standalone)))
		SetTimer(0.2f,true,'AdjustHdrToneMappingScale');  
	*/
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
	ClientSetProgressMessage(PMT_ConnectionFailure, reason);
}

/** Modified version of PlayerController::CleanupPawn. Replaces 'self' and 'DmgType_Suicided' with 'None' and 'DamageType' so that death messages on disconnect get suppressed. */
function CleanupPawn()
{
	local Vehicle	DrivenVehicle;
	local Pawn		Driver;

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
	if(amount < 0)
		return;
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

	if (Rx_PRI(PlayerReplicationInfo).GetCredits() < amount) return; // not enough money
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
	if(Credits < 0)	return;
	ServerTeamDonate(Credits);
}

reliable server function ServerTeamDonate(float Credits)
{
	
	if(Worldinfo.GRI.ElapsedTime < Rx_Game(Worldinfo.Game).DonationsDisabledTime)
	{
		ClientMessage("Donations are disallowed for the first " $ Rx_Game(Worldinfo.Game).DonationsDisabledTime $ " seconds.");		
		return;
	}
	
	if (Rx_PRI(PlayerReplicationInfo).GetCredits() < Credits) return; // not enough money
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
	if (Rx_Game(WorldInfo.Game).GlobalVote != none)
		Rx_Game(WorldInfo.Game).GlobalVote.PlayerVoteYes(self);

	if (Rx_Game(WorldInfo.Game).GDIVote != none && PlayerReplicationInfo.Team.TeamIndex == 0)
		Rx_Game(WorldInfo.Game).GDIVote.PlayerVoteYes(self);
	else if (Rx_Game(WorldInfo.Game).NODVote != none && PlayerReplicationInfo.Team.TeamIndex == 1)
		Rx_Game(WorldInfo.Game).NODVote.PlayerVoteYes(self);
}

reliable server function ServerVoteNo()
{
	if (Rx_Game(WorldInfo.Game).GlobalVote != none)
		Rx_Game(WorldInfo.Game).GlobalVote.PlayerVoteNo(self);

	if (Rx_Game(WorldInfo.Game).GDIVote != none && PlayerReplicationInfo.Team.TeamIndex == 0)
		Rx_Game(WorldInfo.Game).GDIVote.PlayerVoteNo(self);
	else if (Rx_Game(WorldInfo.Game).NODVote != none && PlayerReplicationInfo.Team.TeamIndex == 1)
		Rx_Game(WorldInfo.Game).NODVote.PlayerVoteNo(self);
}

/** one1: Added function for enabling vote menu. */
function EnableVoteMenu(bool donate)
{
	// just in case, turn off previous one
	DisableVoteMenu();

	if (!donate && WorldInfo.TimeSeconds < NextVoteTime)
	{
		ClientMessage("You must wait"@ int(NextVoteTime - WorldInfo.TimeSeconds) @"more seconds before you can start another vote.");
		return;
	}

	if (donate) VoteHandler = new (self) class'Rx_CreditDonationHandler';
	else VoteHandler = new (self) class'Rx_VoteMenuHandler';
	VoteHandler.Enabled(self);
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

/** one1: Disables vote menu or go back 1 step. */
function DisableVoteMenu()
{
	if (VoteHandler != none)
	{
		if (VoteHandler.Disabled())
			VoteHandler = none;
	}
}

/** one1: Overriden so that vote menu can get key input. */
exec function SwitchWeapon(byte T)
{
	if (VoteHandler != none) {
		VoteHandler.KeyPress(T);
	} else if(!Rx_PlayerInput(PlayerInput).bAltPressed && !Rx_PlayerInput(PlayerInput).bCntrlPressed && Rx_Weapon(Pawn.Weapon).InventoryGroup != T) {
		super.SwitchWeapon(T);
	}
}


/** one1: Called from VoteMenuChoice objects, when vote is ready to be sent to server. */
function SendVote(class<Rx_VoteMenuChoice> VoteChoiceClass, string param, int t)
{
	ServerVote(VoteChoiceClass, param, t);
}

/** one1: Replicate vote to server. */
reliable server function ServerVote(class<Rx_VoteMenuChoice> VoteChoiceClass, string param, int t)
{
	local Rx_Game g;
	local color MyColor;
	
	MyColor=MakeColor(111,255,157,255);
	
	
	if(WorldInfo.TimeSeconds < NextChangeMapTime)
	{
		
		if(
		string(VoteChoiceClass) == "Rx_VoteMenuChoice_Surrender" ||
		string(VoteChoiceClass) == "Rx_VoteMenuChoice_ChangeMap" ||
		string(VoteChoiceClass) == "Rx_VoteMenuChoice_RestartMap")
			{
			UpdateMapOrSurrenderCooldown();
			CTextMessage("GDI",45, "Map-related Vote Rejected: You've started one too recently ",MyColor,180, 255, true, 2, 0.75);
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
	CTextMessage("GDI",45, "Can Not Surrender for the first 15 minutes",MyColor,180, 255, true, 2, 0.75);	
	return ; 	
	}
	
	g = Rx_Game(WorldInfo.Game);
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
		
	if(isMapRelatedVote(VoteChoiceClass) )	UpdateMapOrSurrenderCooldown();
			
		UpdateVoteCooldown();
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
		
		if(isMapRelatedVote(VoteChoiceClass) )	UpdateMapOrSurrenderCooldown();

		UpdateVoteCooldown();
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
		if(isMapRelatedVote(VoteChoiceClass) )	UpdateMapOrSurrenderCooldown();
		UpdateVoteCooldown();
	}
}

function bool isMapRelatedVote(coerce string VType)
		
{
	if(
	VType == "Rx_VoteMenuChoice_Surrender" ||
	VType == "Rx_VoteMenuChoice_ChangeMap" ||
	VType == "Rx_VoteMenuChoice_RestartMap")
	return true; 
	else 
	return false; 
		
	}

function UpdateVoteCooldown()
{
	NextVoteTime = WorldInfo.TimeSeconds + Rx_Game(WorldInfo.Game).VotePersonalCooldown;
	UpdateClientVoteCooldown(Rx_Game(WorldInfo.Game).VotePersonalCooldown);
}

reliable client function UpdateClientVoteCooldown(float cooldown)
{
	NextVoteTime = WorldInfo.TimeSeconds + cooldown;
}

function UpdateMapOrSurrenderCooldown()
{
	
	NextChangeMapTime = (WorldInfo.TimeSeconds + Rx_Game(WorldInfo.Game).VotePersonalCooldown*5) ; //At least 5 minutes between surrender votes by one player. 
	UpdateClientMapOrSurrenderCooldown(Rx_Game(WorldInfo.Game).VotePersonalCooldown);
}

reliable client function UpdateClientMapOrSurrenderCooldown(float cooldown)
{
	NextChangeMapTime = (WorldInfo.TimeSeconds + 5*cooldown);
}

/** one1: Console input for vote choices. */
function ShowVoteMenuConsole(string preappendtext)
{
	local Console PlayerConsole;
	local LocalPlayer LP;

	LP = LocalPlayer( Player );
	if( ( LP != None ) && ( LP.ViewportClient.ViewportConsole != None ) )
	{
		PlayerConsole = LocalPlayer( Player ).ViewportClient.ViewportConsole;
		PlayerConsole.StartTyping(preappendtext);
	}
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
	ClientMessage("Use the AdminRcon command.");
}

exec function AdminRcon(string CommandLine)
{
	if (PlayerReplicationInfo.bAdmin && !Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
		ServerAdminRcon(CommandLine);
}

reliable server function ServerAdminRcon( string CommandLine )
{
	if (PlayerReplicationInfo.bAdmin && !Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
	{
		`LogRx("ADMIN"`s "Rcon;"`s `PlayerLog(PlayerReplicationInfo) `s"executed:"`s CommandLine);
		ClientMessage(Rx_Game(WorldInfo.Game).RconCommand(CommandLine));
	}
}

exec function AdminAddAdministrator(string target)
{
	local PlayerReplicationInfo PRI;
	local string error;
	if (PlayerReplicationInfo.bAdmin && !Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
	{
		PRI = ParsePlayer(target, error);
		if (PRI != None)
			ServerAddAdmin(PRI.PlayerID, false);
		else
			ClientMessage(error);
	}
}

exec function AdminAddModerator(string target)
{
	local PlayerReplicationInfo PRI;
	local string error;
	if (PlayerReplicationInfo.bAdmin && !Rx_PRI(PlayerReplicationInfo).bModeratorOnly)
	{
		PRI = ParsePlayer(target, error);
		if (PRI != None)
			ServerAddAdmin(PRI.PlayerID, true);
		else
			ClientMessage(error);
	}
}

reliable server function ServerAddAdmin(int PlayerID, bool AsModerator)
{
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
		return Match;
	}
	Error = "No player matches on \""$in$"\" found.";
	return None;
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
	local Console PlayerConsole;
	local LocalPlayer LP;

	LP = LocalPlayer( Player );
	if( ( LP != None ) && CanCommunicate() && ( LP.ViewportClient.ViewportConsole != None ) )
	{
		PlayerConsole = LocalPlayer( Player ).ViewportClient.ViewportConsole;
		PlayerConsole.StartTyping( "PrivateSay " );
	}
}

exec function PrivateMessage(int PlayerID, String Msg)
{
	if (Len(Msg) > 0)
	{
		Msg = Left(Msg,128);
		if (AllowTextMessage(Msg))
			ServerPrivateMessage(PlayerID, Msg);
	}
}

unreliable server function ServerPrivateMessage(int PlayerID, String Msg)
{
	LastActiveTime = WorldInfo.TimeSeconds;

	//if (!bServerMutedText)
	//{
	Rx_Game(WorldInfo.Game).SendPM(self, PlayerID, Msg);
	//}

}

/** Copy of PlayerController::TeamMessage(...) with PMing supported added. */
reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
	local bool bIsUserCreated;
	local string from;

	if( CanCommunicate() )
	{
		if (PRI != None)
			from = PRI.PlayerName;
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

//Sends a fancy little message to the upper/middle portion of the client's screen. :Yosh 
reliable client function CTextMessage(string Team, float TIME, string TEXT,color C,byte Alpha_MIN, byte Alpha_MAX, bool LOOP, optional int LOOPNUM = 1, float Size = 0.75)
{
	if( myHUD != None )
	{
		//Team, the first argument, literally does not matter (right now. Leaving it around on the off chance it becomes a necessity).
		Rx_HUD(myHUD).CommandText.SetFlashText("GDI",TIME, TEXT,C,Alpha_MIN, Alpha_MAX, LOOP, LOOPNUM,Size);
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

function CheckAuthentication() {
	
	local string SteamID;
	
	if(IsLocalPlayerController()) {
		SteamID = OnlineSub.UniqueNetIdToString(PlayerReplicationInfo.UniqueId);	
		OnlineService = Spawn(class'GeminiOnlineService');
		OnlineService.Initialize(none,self);
		OnlineService.GetServiceCheckIp(PlayerReplicationInfo.SavedNetworkAddress, SteamID, true);				
		SetTimer(5.0,false,'CheckAuthenticationResult');
	}	
}

function AuthResponse(string Text)
{
	local int len;
	local array<string> Messages;

	ParseStringIntoArray(Text, Messages, "<@>", true);
	if(Messages.length < 2)
		return;
	
	len = Messages.length;
	Messages[len - 1] = Left(Messages[len - 1],InStr(Messages[len - 1],"<form"));
	
	Text = Messages[1];
		
	if(InStr(Text, "auth") >= 0) 
		bAuth=true;
}

function CheckAuthenticationResult() {	
	if(!bAuth) {
		loginternal("no auth:"$OnlineSub.UniqueNetIdToString(PlayerReplicationInfo.UniqueId));
		ConsoleCommand("Exit",false);
	}
}

event InitInputSystem()
{
	
	super.InitInputSystem();
	SetOurCameraMode(camMode);
	
	
}

reliable server function ServerEndGame() 
{
	Rx_Game(WorldInfo.Game).EndRxGame("TimeLimit", GetTeamNum());
}

reliable server function ServerAllRelevant() 
{
	local Rx_Controller C;
	
	bAllPawnsRelevant = !bAllPawnsRelevant;
	foreach WorldInfo.AllControllers(class'Rx_Controller', C)
	{
		C.pawn.bAlwaysRelevant = bAllPawnsRelevant;
	} 
}

reliable server function ServerAddThreeGDIBots()
{
	Rx_Game(WorldInfo.Game).AddRedBots(3);
	WorldInfo.Game.Broadcast( pawn, pawn.PlayerReplicationInfo.PlayerName$" added 3 GDI Bots");
}

reliable server function ServerAddThreeNodBots()
{
	Rx_Game(WorldInfo.Game).AddBlueBots(3);
	WorldInfo.Game.Broadcast( pawn, pawn.PlayerReplicationInfo.PlayerName$" added 3 Nod Bots");
}

reliable server function ServerKillBots()
{
	Rx_Game(WorldInfo.Game).KillBots();
	WorldInfo.Game.Broadcast( pawn, pawn.PlayerReplicationInfo.PlayerName$" killed all Bots");
}

function CheckJumpOrDuck()
{
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
		if(Rx_Pawn(Pawn) != None && Rx_Pawn(Pawn).bSprinting && Rx_Weapon(Pawn.Weapon) != None && Rx_Weapon(Pawn.Weapon).bIronsightActivated )
		{
			Rx_Pawn(Pawn).StopSprinting();
		}
		
		super.StartFire(FireModeNum);
	}

	exec function StartSprint()
	{
		if (Rx_Pawn(Pawn) != None)
			Rx_Pawn(Pawn).StartSprint();
	}

	exec function StopSprinting()
	{
		if (Rx_Pawn(Pawn) != None)
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


	exec function EndGame()
	{
		//SetTimer(1.0, false, nameof(ServerEndGame));
		//ServerEndGame();
	}

	
	exec function AllRelevant(int i)
	{
		if(i == 2492) 
			ServerAllRelevant();
		
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if(!Rx_Pawn(Pawn).bDodging) {
			Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
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
		if (Rx_Vehicle(Pawn) != None)
			Rx_Vehicle(Pawn).StartSprint();
	}
	exec function StopSprinting()
	{
		if (Rx_Vehicle(Pawn) != None)
			Rx_Vehicle(Pawn).StopSprinting();
	}
}

state Dead
{
	ignores SeePlayer, HearNoise, KilledBy, NextWeapon, PrevWeapon;

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

	/** one: added. */
	simulated event GetPlayerViewPoint( out vector POVLocation, out Rotator POVRotation )
	{
		local vector HitLocation, HitNormal, off;
		local Actor a;
		local rotator rot;

		super.GetPlayerViewPoint(POVLocation, POVRotation);

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
		
		if(LastKiller != None && LastKiller.Pawn != None)
		{
			SetRotation(rotator(LastKiller.Pawn.location - ViewTarget.Location));
			ClientSetRotation(rotation);
		}			

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
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist < P.CylinderComponent.CollisionRadius + P.CylinderComponent.CollisionHeight )
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
					newdist = VSize(cameraLoc - ViewTarget.Location);
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
	if ( (ViewTarget == None) || (ViewTarget == self) || (VSize(ViewTarget.Velocity) < 1.0) )
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

	MinRespawnDelay = default.MinRespawnDelay + (WorldInfo.TimeSeconds/TimeSecondsTillMaxRespawnTime * (default.MaxRespawnDelay - default.MinRespawnDelay));
	
	if(MinRespawnDelay < default.MinRespawnDelay)
		MinRespawnDelay = default.MinRespawnDelay;
	else if(MinRespawnDelay > default.MaxRespawnDelay)
		MinRespawnDelay = default.MaxRespawnDelay;	
		
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

function EquipNuke() {
 	ServerEquipNuke();	
}

function EquipION() {
 	ServerEquipION();	
}

exec function GiveCredits() 
{
	if (WorldInfo.NetMode == NM_Standalone) 
		Rx_PRI(PlayerReplicationInfo).AddCredits(10000);
}

/** 
 *  Switches to the Grenade weapon (if it exists) in the InventoryManager and 'fires' the weapon.
 */
exec function ThrowGrenade()
{
	ServerThrowGrenade();
}
reliable server function ServerThrowGrenade()
{
	if(Rx_Pawn(Pawn) != None)
	{
		Rx_Pawn(Pawn).bThrowingGrenade = true;
		Rx_Pawn(Pawn).SwitchWeapon(4); //Switch to the corresponding InventoryGroup for Grenades.
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

reliable server function ServerEquipION() 
{
	if (Rx_PRI(PlayerReplicationInfo).GetCredits() >= 1000 )
	{
		Rx_PRI(PlayerReplicationInfo).RemoveCredits(1000);
		Rx_InventoryManager(Pawn.InvManager).AddWeaponOfClass(class'Rx_Weapon_IonCannonBeacon',CLASS_ITEM);
	}
}

reliable server function ServerEquipNuke() 
{ 
	if (Rx_PRI(PlayerReplicationInfo).GetCredits() >= 1000 )
	{
		Rx_PRI(PlayerReplicationInfo).RemoveCredits(1000);
		Rx_InventoryManager(Pawn.InvManager).AddWeaponOfClass(class'Rx_Weapon_NukeBeacon',CLASS_ITEM);
	}
}


function ChangeToSBH(bool sbh) 
{
	local pawn p, NewP; //Let us try NOT destroying our initial pawn till after the new one is made... may solve the changing to SBH issue where Rx_Controller suddenly controls nothing
	local vector l;
	local rotator r; 
	local InventoryManager i;
	
	p = Pawn;
	if(bDebugging) `log("Set P to " @ Pawn); 
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
			NewP = Spawn(class'Rx_Pawn_SBH', , ,l,r);
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
			NewP = Spawn(Rx_Game(WorldInfo.Game).DefaultPawnClass, , ,l,r);
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
			if(bDebugging) `log("Attempting to spawn new pawn");
			NewP = Spawn(class'Rx_Pawn_SBH', , ,Saved_Location,Saved_Rotation);
			if(bDebugging) `log("Spawned New Pawn" @ NewP);
			//restore the inventory back
			NewP.InvManager = Saved_Inv;
			if(bDebugging) `log("Inventory manager set to " @ Saved_Inv);
			NewP.bForceNetUpdate = true;
			
			Possess(NewP, false);	
			bForceNetUpdate = true;
			
			Rx_PRI(PlayerReplicationInfo).equipStartWeapons();
			SetTimer(0.4f, false, 'ConfirmPawnSwitchToSBHTimer');
		}
	else
	if(Rx_Pawn_SBH(Pawn) != none)
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
			NewP = Spawn(Rx_Game(WorldInfo.Game).DefaultPawnClass, , ,Saved_Location,Saved_Rotation);
			//restore the inventory back
			NewP.InvManager = Saved_Inv;
			
		
			Possess(NewP, false);	
			bForceNetUpdate = true;
			
			Rx_PRI(PlayerReplicationInfo).equipStartWeapons();
			SetTimer(0.4f, false, 'ConfirmPawnSwitchFromSBHTimer');
			}
			else
			if(Rx_Pawn(Pawn) != none && Rx_Pawn_SBH(Pawn) == none)
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
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Driver_Locked,,,BoundVehicle.Class);
		else
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Driver_Unlocked,,,BoundVehicle.Class);
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
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Unbound,,,Saved.Class);
	}
	if (NewVehicle != None)
	{
		if (NewVehicle.Bind(self))
			ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Bound,,,BoundVehicle.Class);
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
	if(spotMessagesBlocked)
		return;
	bSpotting = true;	
	if(IsTimerActive('RemoveSpotTargets'))	{
		ClearTimer('RemoveSpotTargets');
	}
	RemoveSpotTargets();
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
	
	bSpotting = false;  
	if(spotMessagesBlocked)
		return;	
		
	if ( Rx_Hud(MyHUD) != None && Rx_Hud(MyHUD).SpotTargets.Length > 0) {
	
		if(Rx_Building(Rx_Hud(MyHUD).SpotTargets[0]) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				Building = Rx_Building(Rx_Hud(MyHUD).SpotTargets[0]);
				BroadcastBuildingSpotMessages(Building);
			}
		} else if(Rx_Defence(Rx_Hud(MyHUD).SpotTargets[0]) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				BroadcastBaseDefenseSpotMessages(Rx_Defence(Rx_Hud(MyHUD).SpotTargets[0]));
			}
		} else if(Rx_Weapon_DeployedBeacon(Rx_Hud(MyHUD).SpotTargets[0]) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				if(Rx_Hud(MyHUD).SpotTargets[0].GetTeamNum() == GetTeamNum())
					BroadCastSpotMessage(15, "Defend BEACON"@GetSpottargetLocationInfo(Rx_Weapon_DeployedBeacon(Rx_Hud(MyHUD).SpotTargets[0]))@"!!!");
				else
					BroadCastSpotMessage(-1, "Spotted ENEMY BEACON"@GetSpottargetLocationInfo(Rx_Weapon_DeployedBeacon(Rx_Hud(MyHUD).SpotTargets[0]))@"!!!");	
			}
		}  else if(Rx_Weapon_DeployedC4(Rx_Hud(MyHUD).SpotTargets[0]) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				BuildingName = Rx_Weapon_DeployedC4(Rx_Hud(MyHUD).SpotTargets[0]).ImpactedActor.GetHumanReadableName();
				if(BuildingName == "MCT" || Rx_Building(Rx_Weapon_DeployedC4(Rx_Hud(MyHUD).SpotTargets[0]).ImpactedActor) != None)
				{	
					if(BuildingName == "MCT")
						BuildingName = "MCT"@GetSpottargetLocationInfo(Rx_Weapon_DeployedC4(Rx_Hud(MyHUD).SpotTargets[0]));			
					if(Rx_Hud(MyHUD).SpotTargets[0].GetTeamNum() == GetTeamNum())
						BroadCastSpotMessage(15, "Defend >>C4<< at "@BuildingName@"!!!");
					else
						BroadCastSpotMessage(-1, "Spotted ENEMY >>C4<< at "@BuildingName@"!!!");
				}	
			}
		} else if(Rx_Vehicle_Harvester(Rx_Hud(MyHUD).SpotTargets[0]) != None) {
			if (numberOfRadioCommandsLastXSeconds++ < 5) {
				if(Rx_Hud(MyHUD).SpotTargets[0].GetTeamNum() == GetTeamNum())
					RadioCommand(26);
				else
					RadioCommand(21);
			}
			return;
		} else if(Pawn(Rx_Hud(MyHUD).SpotTargets[0]).GetTeamNum() == GetTeamNum()) {
			bot = Rx_Bot(Pawn(Rx_Hud(MyHUD).SpotTargets[0]).Controller);
			if(bot != None) {
				if(bot.Squad != None && Rx_SquadAI(bot.squad).SquadLeader == Self && bot.GetOrders() == 'Follow') {
					UTTeamInfo(bot.Squad.Team).AI.SetBotOrders(bot);
					BroadCastSpotMessage(17, "Stop following me"@Pawn(Rx_Hud(MyHUD).SpotTargets[0]).Controller.GetHumanReadableName());
					RespondingBot = bot;
					SetTimer(0.5 + FRand(), false, 'BotSayAffirmativeToplayer');
				} else {
					bot.SetBotOrders('Follow', self, true);
					BroadCastSpotMessage(13, "Follow me"@Pawn(Rx_Hud(MyHUD).SpotTargets[0]).Controller.GetHumanReadableName());
					RespondingBot = bot;
					SetTimer(0.5 + FRand(), false, 'BotSayAffirmativeToplayer');
				}
			} else {
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
	local String msg;
	local int nr;
		
	if(DefenceStructure.GetTeamNum() == GetTeamNum()) {
		
		
		if(DefenceStructure.GetHealth(0) == DefenceStructure.HealthMax) { 
			msg = "Defend Defence Structure"@DefenceStructure.GetHumanReadableName();
			nr = 27;
		}
		else if(DefenceStructure.GetHealth(0) > DefenceStructure.HealthMax/3) {
			msg = "Defence Structure"@DefenceStructure.GetHumanReadableName()@" needs repair!";
			nr = 0;
		} else {
			msg = "Defence Structure"@DefenceStructure.GetHumanReadableName()@" needs repair immediately!";	
			nr = 0;
		}	
	} else {
		msg = "Attack Defence Structure"@DefenceStructure.GetHumanReadableName()@"!"; 
		nr = 20;
	}
	BroadCastSpotMessage(nr, msg);	
}
function BroadcastBuildingSpotMessages(Rx_Building Building) 
{
	local String msg;
	local int nr;
	if(Building.GetTeamNum() == GetTeamNum()) {
		
		if(Building.GetMaxArmor() <= 0) { /*We're not using armour*/
		
		if(Building.GetHealth() == Building.GetMaxHealth()) { 
			
			msg = "Defend the"@Building.GetHumanReadableName()@"!";
			
			if(Rx_Building_Refinery(Building) != None)
				nr = 28;
			else if(Rx_Building_PowerPlant(Building) != None)
				nr = 29;
			else
				nr = 27;
		}
		else if((Building.GetHealth() + Building.GetArmor()) > Building.GetMaxHealth()/3) {
			msg = "The"@Building.GetHumanReadableName()@"needs repair!";
			nr = 0;
		} else {
			msg = "The"@Building.GetHumanReadableName()@"needs repair immediatly!";	
			nr = 0;
			}
		
									}
			else /*We are using armour*/
			
		 { 
		
		if((Building.GetArmor()) == Building.GetMaxArmor()) { 
			
			msg = "Defend the"@Building.GetHumanReadableName()@"!";
			
			if(Rx_Building_Refinery(Building) != None)
				nr = 28;
			else if(Rx_Building_PowerPlant(Building) != None)
				nr = 29;
			else
				nr = 27;
		}
		else if((Building.GetArmor()) > Building.GetMaxArmor()/4) {
			msg = "The"@Building.GetHumanReadableName()@"needs repair!";
			nr = 0;
		} else {
			msg = "The"@Building.GetHumanReadableName()@"needs repair immediatly!";	
			nr = 0;
			}
			
	}
	} else { //Enemy building
		msg = "Attack the"@Building.GetHumanReadableName()@"!";
		if(Rx_Building_Refinery(Building) != None)
			nr = 23;
		else if(Rx_Building_PowerPlant(Building) != None)
			nr = 24;
		else
			nr = 22;		
	}
	BroadCastSpotMessage(nr, msg);
}

function BroadcastEnemySpotMessages() 
{
	local int i,j;
	local int SpottedVehicles[15]; 
	local int SpottedInfs[30]; 
	local int NumVehicles;
	local int NumInfs;
	local Actor SpotTarget;
	local Actor FirstSpotTarget;
	local string LocationInfo;
	local string SpottingMsg;
	local UTPlayerReplicationInfo PRI;
			
	SpottingMsg = "";
	foreach Rx_Hud(MyHUD).SpotTargets(SpotTarget)
	{
		if(Pawn(SpotTarget) == None)
			continue;
		if(Pawn(SpotTarget).GetTeamNum() == GetTeamNum())
			continue;	
		if(Rx_Vehicle(SpotTarget) != None && Rx_Vehicle_Harvester(SpotTarget) == None)
		{
			NumVehicles++;
			
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
			}
		}
		
		if(Rx_Pawn(SpotTarget) != None)
		{
			NumInfs++;
			if(UTPlayerReplicationInfo(Rx_Pawn(SpotTarget).PlayerReplicationInfo) == None)
				continue; 
			PRI = UTPlayerReplicationInfo(Rx_Pawn(SpotTarget).PlayerReplicationInfo);
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
			}	
		}
			
		if (Rx_Pawn(SpotTarget) != none)
		{
			SetPlayerSpotted(Rx_Pawn(SpotTarget).PlayerReplicationInfo.PlayerID);
		}
		else if (Rx_Vehicle(SpotTarget) != none && Rx_Vehicle(SpotTarget).driver != None && Rx_Vehicle_Harvester(SpotTarget) == None)
		{
			/**
			foreach WorldInfo.AllPawns(class'Pawn', P)
			{
				if(P.DrivenVehicle == Rx_Vehicle(SpotTarget))
					SetPlayerSpotted2(P);		
			}
			*/
		}
	}
	
	FirstSpotTarget = Rx_Hud(MyHUD).SpotTargets[0];
	
	LocationInfo = GetSpottargetLocationInfo(FirstSpotTarget);
	
	spotMessagesBlocked = true;
	SetTimer(5.0, false, 'resetSpotMessageCountTimer');
	if(NumVehicles > 0)
	{
		for(i=14; i>=0; i--)
		{
			if(j > 5)
				break;
			if(SpottedVehicles[i] > 0)
				j++;
			if(i==0 && SpottedVehicles[0] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[0] @ "Humvee";
			else if(i==1 && SpottedVehicles[1] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[1] @ "APC";				
			else if(i==2 && SpottedVehicles[2] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[2] @ "MRLS";				
			else if(i==3 && SpottedVehicles[3] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[3] @ "Med.Tank";				
			else if(i==4 && SpottedVehicles[4] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[4] @ "Mam.Tank";				
			else if(i==5 && SpottedVehicles[5] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[5] @ "Chinook";				
			else if(i==6 && SpottedVehicles[6] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[6] @ "Orca";				
			else if(i==7 && SpottedVehicles[7] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[7] @ "Buggy";				
			else if(i==8 && SpottedVehicles[8] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[8] @ "APC";				
			else if(i==9 && SpottedVehicles[9] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[9] @ "Artillerie";				
			else if(i==10 && SpottedVehicles[10] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[10] @ "L.Tank";				
			else if(i==11 && SpottedVehicles[11] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[11] @ "F.Tank";				
			else if(i==12 && SpottedVehicles[12] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[12] @ "S.Tank";				
			else if(i==13 && SpottedVehicles[13] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[13] @ "Chinook";				
			else if(i==14 && SpottedVehicles[14] > 0)
				SpottingMsg = SpottingMsg @ SpottedVehicles[14] @ "Apache";	
			
			if(SpottedVehicles[i] > 1)
				SpottingMsg = SpottingMsg @ "s";	
			if(SpottedVehicles[i] > 0 && (NumInfs+NumVehicles) > j)
				SpottingMsg = SpottingMsg @ ",";								
		}
	}
	
	if(NumInfs > 0)
	{
		for(i=29; i>=0; i--)
		{
			if(j > 5)
				break;
			if(SpottedInfs[i] > 0)
				j++;
						
			if(i==0 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Soldier";
			else if(i==1 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Shotgunner";					
			else if(i==2 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Grenadier";					
			else if(i==3 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Marksman";					
			else if(i==4 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Engineer";					
			else if(i==5 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Officer";					
			else if(i==6 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "RocketSoldier";					
			else if(i==7 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "McFarland";					
			else if(i==8 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Deadeye";					
			else if(i==9 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Gunner";					
			else if(i==10 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Patche";					
			else if(i==11 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Havoc";					
			else if(i==12 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Sydney";					
			else if(i==13 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Mobius";					
			else if(i==14 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Hotwire";					
			else if(i==15 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Soldier";					
			else if(i==16 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Shotgunner";					
			else if(i==17 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "FlameTrooper";					
			else if(i==18 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Marksman";					
			else if(i==19 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Engineer";					
			else if(i==20 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Officer";					
			else if(i==21 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Rock.Soldier";					
			else if(i==22 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Chem.Trooper";					
			else if(i==23 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Blackh.Sniper";					
			else if(i==24 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "SBH";					
			else if(i==25 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "LCG";					
			else if(i==26 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Sakura";					
			else if(i==27 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Raveshaw";					
			else if(i==28 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Mendoza";					
			else if(i==29 && SpottedInfs[i] > 0)
				SpottingMsg = SpottingMsg @ SpottedInfs[i] @ "Tech";	
				
			if(SpottedInfs[i] > 1)
				SpottingMsg = SpottingMsg @ "s";				
			if(SpottedInfs[i] > 0 && (NumInfs+NumVehicles) > j)
				SpottingMsg = SpottingMsg @ ",";												
		}
	}	
	
	if( (NumVehicles + NumInfs) > 6)
		SpottingMsg = SpottingMsg @ " and more"; 	
	BroadCastSpotMessage(9, "Spotted"@SpottingMsg@LocationInfo);	
}

function string GetSpottargetLocationInfo(Actor FirstSpotTarget) 
{
	local string LocationInfo;
	local RxIfc_SpotMarker SpotMarker;
	local Actor TempActor;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	
	foreach AllActors(class'Actor',TempActor,class'RxIfc_SpotMarker') {
		SpotMarker = RxIfc_SpotMarker(TempActor);
		DistToSpot = VSize(TempActor.location - FirstSpotTarget.location);
		if(NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist) {
			NearestSpotDist = DistToSpot;	
			NearestSpotMarker = SpotMarker;
		}
	}
	
	LocationInfo = "near"@NearestSpotMarker.GetSpotName();		
	return LocationInfo;
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
      	if (WorldInfo.NetMode == NM_Client) 
      	{ 
         	ServerDoReloadWeapon();
     	}
   	} else {
		if (Rx_VehicleSeatPawn(Pawn) != none) {
			VehWeap = Rx_Vehicle_Weapon(Rx_VehicleSeatPawn(Pawn).MyVehicleWeapon);
		} else {
	   		VehWeap = Rx_Vehicle_Weapon(Rx_Vehicle(Pawn).Seats[0].Gun);
		}
	   	if(Rx_Vehicle_Weapon_Reloadable(VehWeap) == None && Rx_Vehicle_MultiWeapon(VehWeap) == None)
	   		return;
	   	if((Rx_Vehicle(Pawn) != none || Rx_Vehicle(Rx_VehicleSeatPawn(Pawn).MyVehicle) != none) && VehWeap != none && !VehWeap.bReloadAfterEveryShot && !VehWeap.IsInState('WeaponFiring')) 
	   	{
			  if(WorldInfo.NetMode == NM_Client) {
			 	
				//Added better support for Multi Weapons:8AUG2015
			 	if(Rx_Vehicle_MultiWeapon(VehWeap) == none)
				{
				//`log("DID NORMAL RELOAD");
				VehWeap.SetCurrentlyReloadingClientside(true);
				VehWeap.SetTimer(Max(VehWeap.ReloadTime[0],VehWeap.ReloadTime[1]),false,'SetCurrentlyReloadingClientsideToFalseTimer');
				}
				else
				{
				//`log("DID CORRECT RELOAD For MultiWeapon ClientSide");
				Rx_Vehicle_MultiWeapon(VehWeap).HandleClientReload(); 
				}
				
			 }
			 ServerDoReloadWeapon();
		}
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

exec function OpenTauntMenu();

exec function CloseTauntMenu();

/*Weapon Switching*/
exec function ToggleWeaponFireMode()/*Specifically for the tac-rifle unless it becomes a thing for multiple weapons.*/
{
	if( Rx_Weapon_TacticalRifle(Pawn.Weapon) != none) 
	{
		ClientPlaySound(WeaponSwitchSoundCue); 
		Rx_Weapon_TacticalRifle(Pawn.Weapon).SwitchMode();		
	} 
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

reliable server function ServerDoReloadWeapon() //Log information for debugging reload bug (commented out)8AUG2015
{
	local Rx_Vehicle_Weapon_Reloadable vehWeapon;
	if (Pawn != none && Pawn.Weapon != none && Rx_Weapon_Reloadable(Pawn.Weapon) != none) 
	{
		Rx_Weapon_Reloadable(Pawn.Weapon).ReloadWeapon(); 
		//`log("DID BAD RELOAD");
	}
   	else if(Rx_Vehicle(Pawn) != none && Rx_Vehicle_Weapon_Reloadable(Rx_Vehicle(Pawn).Seats[0].Gun) != none) 
   	{
		//`log("Problems may occur as this is not a reloadable weapon");
		vehWeapon = Rx_Vehicle_Weapon_Reloadable(Rx_Vehicle(Pawn).Seats[0].Gun);
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
	if(bBehindView)
		if(Rx_Pawn(Pawn) != None) Rx_Pawn(Pawn).CalcThirdPersonCam(0,ViewLocationTemp,ViewRotationTemp,fov);  	
	SetRotation(rotator(LocationLookedAtBeforeSwitch - ViewLocationTemp));
	
	// Adjust a second time for more precision since the first time also dislocated ViewLocationTemp a bit due to camera pivoting
	GetPlayerViewPoint(ViewLocationTemp, ViewRotationTemp);
	if(bBehindView)
		if(Rx_Pawn(Pawn) != None) Rx_Pawn(Pawn).CalcThirdPersonCam(0,ViewLocationTemp,ViewRotationTemp,fov);  	
	SetRotation(rotator(LocationLookedAtBeforeSwitch - ViewLocationTemp));
}

function SetOurCameraMode(CameraMode newCameraMode) {
	if(Rx_Weapon(Pawn.Weapon) != None && Rx_Weapon(Pawn.Weapon).bIronsightActivated)
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
	local float extendedDist;
	local Actor HitActor;
	
	GetPlayerViewPoint(CameraOrigin,CameraDirectionRot);
	CameraDirection = vector(CameraDirectionRot);
	
	TraceEnd = CameraOrigin + CameraDirection * 10000;
	extendedDist = VSize(CameraOrigin - ViewTarget.location);
	TraceEnd += CameraDirection * extendedDist;

	foreach TraceActors(class'actor',HitActor,HitLoc,HitNormal,TraceEnd,CameraOrigin,vect(0,0,0),,1)
	{
		if (HitActor != ViewTarget)
			break;
	}
	if(HitActor == None)
		HitLoc = TraceEnd;
	return HitLoc;
}


function SetBehindView(bool bNewBehindView)
{
	if(Pawn == None)
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

	else if (Index >= WeaponList.Length)
		Index = 0;	

	if (Index >= 0)
		return WeaponList[Index];
	return None;	
}

function FixFOV()
{
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
reliable server function ServerPurchaseCharacter(int CharID, Rx_BuildingAttachment_PT PT)
{
	if (ValidPTUse(PT))
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseCharacter(self,GetTeamNum(),CharID);
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
	loginternal("client spotted"$playerID);
	ServerSetPlayerSpotted(playerID);	
}

reliable server function ServerSetPlayerSpotted( int playerID )
{
	local int i;

	loginternal("server spotted"$playerID);
	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(Rx_Pri(WorldInfo.GRI.PRIArray[i]) == None)
			continue;
		if (WorldInfo.GRI.PRIArray[i].PlayerID == playerID)
		{
			Rx_Pri(WorldInfo.GRI.PRIArray[i]).SetSpotted();
			return;
		}
	}
}

function PurchaseCharacter(int teamnum, int CharID)
{

	if(Role == ROLE_Authority)
	{
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().PurchaseCharacter(self,teamnum,CharID);
		return;
	}

	if(CharID == 14) {
		bJustBaughtEngineer = true;
		bJustBaughtHavocSakura = false;
	} else if (CharID == 11) {
		bJustBaughtEngineer = false;
		bJustBaughtHavocSakura = true;
	} else {
		bJustBaughtEngineer = false;
		bJustBaughtHavocSakura = false;
	}	

	ServerPurchaseCharacter(CharID,PTUsed);
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

unreliable client function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> DamageType)
{
	DamageShake(Damage, DamageType);
	
	HitLoc += Pawn.Location;

	if ( Rx_Hud(MyHUD) != None )
	{
		Rx_Hud(MyHUD).DisplayHit(HitLoc, Damage, DamageType);
	}
}

//toggles the layout of the scoreboard in game
exec function ToggleScoreboard()
{
	Rx_Hud(MyHUD).ToggleScoreboard();
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

	if(WorldInfo.NetMode != NM_DedicatedServer) {
		ResetRepGunEmitters();
	}
	LastClientpositionUpdates = 0; 
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
		Rx_HUD(myHUD).PTMovie = new class'Rx_GFxPurchaseMenu';
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
	if (AttemptOpenPT())
		return;
	else
		super.Use();
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
		if ( AllowTextMessage(RadioCommandsText[nr]) && numberOfRadioCommandsLastXSeconds < 5) {
			numberOfRadioCommandsLastXSeconds++;
			
			if(nr == 0 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && Rx_Building(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
				AdditionalText = Rx_Building(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
			else if(nr == 1 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
				AdditionalText = UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
			else if(nr == 2 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
				AdditionalText = UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
			else if(nr == 3 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None && UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()) != None)
				AdditionalText = UTVehicle(Rx_Hud(MyHUD).GetActorAtScreenCentre()).GetHumanReadableName();		
			else if(nr == 9 && Rx_Hud(MyHUD).GetActorAtScreenCentre() != None 
							&& Rx_Hud(MyHUD).TargetingBox.TargetedActor != none
							&& (Rx_Hud(MyHUD).GetActorAtScreenCentre().GetTeamNum() != GetTeamNum()))
				AdditionalText = Rx_Hud(MyHUD).GetActorAtScreenCentre().GetHumanReadableName();	
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

	// see if allowed (limit to prevent spamming)
	if ( !WorldInfo.Game.BroadcastHandler.AllowsBroadcast(Self, Len(RadioCommandsText[nr])) )
		return;
	
	if(nr == 1 || nr == 4 || nr == 5 || nr == 6 || nr == 7 || nr == 8 || nr == 9 || nr == 10 || nr == 12 
			|| nr == 13 || nr == 14 || nr == 15 || nr == 16 || nr == 17 || nr == 18 || nr == 19 || nr == 20 || nr == 21 
			|| nr == 22 || nr == 23 || nr == 24 || nr == 25 || nr == 26 || nr == 27 || nr == 28 || nr == 29)
		{	
			if (Rx_Pawn(Pawn) != None)
				Rx_Pawn(Pawn).setBlinkingName();
			else if (Rx_Vehicle(Pawn) != None)
				Rx_Vehicle(Pawn).setBlinkingName();		
		}
		
	FinalText = RadioCommandsText[nr]@AdditionalText;
	`LogRx("CHAT" `s "Radio;" `s `PlayerLog(PlayerReplicationInfo) `s "said:" `s FinalText);
	foreach WorldInfo.AllControllers(class'PlayerController', PC) {
		if (PC.PlayerReplicationInfo.Team ==  PlayerReplicationInfo.Team) {
			PC.ClientPlaySound(RadioCommands[nr]);
			WorldInfo.Game.BroadcastHandler.BroadcastText(PlayerReplicationInfo, PC, FinalText, 'TeamSay');
		}
	}
}

unreliable server function BroadCastSpotMessage(int nr, String Text)
{
	local PlayerController PC;

	// see if allowed (limit to prevent spamming)
	if ( !WorldInfo.Game.BroadcastHandler.AllowsBroadcast(Self, Len(Text)) )
		return;
		
	foreach WorldInfo.AllControllers(class'PlayerController', PC) {
		if (PC.PlayerReplicationInfo.Team ==  PlayerReplicationInfo.Team) {
			if(nr > -1)
				PC.ClientPlaySound(RadioCommands[nr]);
			WorldInfo.Game.BroadcastHandler.BroadcastText(PlayerReplicationInfo, PC, Text, 'TeamSay');
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
	if (Rx_HUD(myHUD).Scoreboard == none) {
		Rx_HUD(myHUD).SetShowScores(true);
	}
	Rx_HUD(myHUD).Scoreboard.Scoreboard.SetVisible(false);
	Rx_HUD(myHUD).Scoreboard.ServerName.SetVisible(false);
	Rx_HUD(myHUD).Scoreboard.FadeMC.GotoAndPlay("FadeIn");
	Rx_HUD(myHUD).Scoreboard.bHasFadeIn = false;
}

function FadeOutScoreboard() {
	//`log("################################ -( RxController:FadeOutScoreboard() )-");
	if (Rx_HUD(myHUD).Scoreboard == none) {
		return;
	}
	if (!Rx_HUD(myHUD).Scoreboard.bHasFadeIn) {
		//Scoreboard.SetVisible(true);
		//ServerName.SetVisible(true);
		Rx_HUD(myHUD).Scoreboard.FadeMC.GotoAndPlay("FadeOut");
		Rx_HUD(myHUD).Scoreboard.bCaptureInput = true;
		Rx_HUD(myHUD).Scoreboard.bHasFadeIn = true;
	}
}

function PlayEndGameSound()
{
// 	`log("################################ -( PlayEndGameSound() )-");
// 	`log("################################ -( Winning Team: " $ WorldInfo.GRI.Winner $" )-");
// 	`log("################################ -( Winning Team Num: " $ WorldInfo.GRI.Winner.GetTeamNum() $" )-");
	if (Rx_HUD(myHUD) != none && Rx_HUD(myHUD).JukeBox != none) {
		Rx_HUD(myHUD).JukeBox.Stop();
	}
	if (GetTeamNum() == WorldInfo.GRI.Winner.GetTeamNum()) {
		PlaySound(TeamVictorySound[GetTeamNum()]);
	} else {
		PlaySound(TeamDefeatSound[GetTeamNum()]);
	}
}

state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide, DrawHud;
	
	function BeginState(Name PreviousStateName)
	{
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
			//ShowScoreboard();
			//myHUD.SetShowScores(true);
		}
	}
	
	//the game no longer can be restarted by firing.
	exec function StartFire( optional byte FireModeNum );

	function ShowScoreboard()
	{
		local UTGameReplicationInfo GRI;

		
		GRI = UTGameReplicationInfo(WorldInfo.GRI);
		if (GRI != None && GRI.bMatchIsOver && !GRI.bStoryMode)
		{
			//ShowMidGameMenu('ScoreTab',true);
			// Rx_HUD(myHUD).Scoreboard.Scoreboard.SetBool("enabled", true);
			if (Rx_HUD(myHUD).Scoreboard == none) {
				Rx_HUD(myHUD).SetShowScores(true);
			}
			Rx_HUD(myHUD).Scoreboard.EndGameTime = WorldInfo.RealTimeSeconds + 45.0f;
			Rx_HUD(myHUD).Scoreboard.Scoreboard.SetVisible(true);
			Rx_HUD(myHUD).Scoreboard.ServerName.SetVisible(true);
			Rx_HUD(myHUD).Scoreboard.RootMC.GotoAndStopI(10);
		}
		else if (myHUD != None)
		{
			if (Rx_HUD(myHUD).Scoreboard == none) {
				Rx_HUD(myHUD).SetShowScores(true);
			}
			// Rx_HUD(myHUD).Scoreboard.Scoreboard.SetBool("enabled", true);
			Rx_HUD(myHUD).Scoreboard.EndGameTime = WorldInfo.RealTimeSeconds + 45.0f;
			Rx_HUD(myHUD).Scoreboard.Scoreboard.SetVisible(true);
			Rx_HUD(myHUD).Scoreboard.ServerName.SetVisible(true);
			Rx_HUD(myHUD).Scoreboard.RootMC.GotoAndStopI(10);
			//myHUD.SetShowScores(true);
			//Rx_HUD(myHUD).Scoreboard.FadeMC.GotoAndPlay("FadeIn");
		}
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
	CurrentSidearmWeapon = none;
	CurrentExplosiveWeapon = none;
	if(!bIsInPurchaseTerminal)
		super.ChangeTeam(TeamName);
}

reliable server function ServerChangeTeam(int N)
{
	local Rx_Building_Internals buildingInternals;	

	CurrentSidearmWeapon = none;
	CurrentExplosiveWeapon = none;

	RemoveAllPurchaseInformation();

	if (Rx_Game(WorldInfo.Game).bIsClanWars)
		return;		
		
	super.ServerChangeTeam(N);
	
	Rx_PRI(PlayerReplicationInfo).LastAirdropTime = 0;
	Rx_PRI(PlayerReplicationInfo).AirdropCounter=0;
	ResetLastAirdropTimeClient();	
	
	ForEach AllActors(class'Rx_Building_Internals', buildingInternals) {
		if(!buildingInternals.IsDestroyed())
			continue;
		if((Rx_Building_AirTower_Internals(buildingInternals) != None && GetTeamNum() == TEAM_NOD)
			 	|| (Rx_Building_WeaponsFactory_Internals(buildingInternals) != None && GetTeamNum() == TEAM_GDI))
		{
			Rx_PRI(PlayerReplicationInfo).LastAirdropTime = WorldInfo.TimeSeconds;
			Rx_PRI(PlayerReplicationInfo).AirdropCounter++;	
		}
	}	
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
	

	if(WorldInfo.NetMode == NM_DedicatedServer) {
		RemoveAllPurchaseInformationClient();
	}

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


//------------ TheAgent's Vaulting system ------------//

function ResetbJustExitedVehicle() {
	bJustExitedVehicle = false;	
}



// *********** Vault STATE********************************************
// Contains stop functions and special case vaults.
// handles animations and movement

state Vaulting
{

 function Check()
 {
   local VaultActor VA;
   local Actor TraceHit;
   local Vector StartLoc, EndLoc;

   local Vector HitNormal, HitLocation;



   foreach VisibleCollidingActors (class'VaultActor', VA,90,Pawn.Location)
   {

   // Trace from pawn sockets.
	Pawn.Mesh.GetSocketWorldLocationAndRotation(VaultStartSocketName, StartLoc);
	Pawn.Mesh.GetSocketWorldLocationAndRotation(VaultEndSocketName, EndLoc);

	TraceHit = Trace(HitLocation, HitNormal, StartLoc, EndLoc, true,,,
	TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes |
	TRACEFLAG_SkipMovers | TRACEFLAG_Blocking);
//	DrawDebugLine(StartLoc, EndLoc, 255, 250, 0, true);


      if(TraceHit.IsA('VaultActor'))
      {

           if(VA.Type == Tall)
            {
              bVaulted = true;
              Pawn.DoJump(bUpdating);
              Pawn.Velocity.Z = VA.Height;
              Pv = Rx_Pawn(Pawn);
              Pv.FullBodyAnimSlot.PlayCustomAnim('H_M_Vault_Tall', 1.0, 0.2, 0.2, FALSE, TRUE);
              SetTimer(0.5, false, 'Grounded');
            }
           else if(VA.Type == Medium )
            {
              bVaulted = true;
              Pawn.DoJump(bUpdating);
              Pawn.Velocity.Z = VA.Height;
              Pv = Rx_Pawn(Pawn);
              Pv.FullBodyAnimSlot.PlayCustomAnim('H_M_Vault_Medium', 1.0, 0.2, 0.2, FALSE, TRUE);
              SetTimer(0.4, false, 'Grounded');
            }

            else if(VA.Type == Small)
            {
              bVaulted = true;
              Pawn.DoJump(bUpdating);
              Pawn.Velocity.Z = VA.Height;
              Pv = Rx_Pawn(Pawn);
              Pv.FullBodyAnimSlot.PlayCustomAnim('H_M_Vault_Small', 1.0, 0.2, 0.2, FALSE, TRUE);
              SetTimer(0.3, false, 'Grounded');
            }

      }
      else
      {
        PushState('PlayerWalking');
      }

   }

 }

 function Grounded()
 {
    local VaultActor VA;

    //Set forward 'push' velocity depending on the direction of the wall. determined by level designer.
   foreach VisibleCollidingActors (class'VaultActor', VA, 90, Pawn.Location)
   {
     if(VA.Direction == Left)
     {
       Pawn.Velocity.Y = VA.PushDistance;
     }
     else if(VA.Direction == Right)
     {
       Pawn.Velocity.Y = - VA.PushDistance;
     }
     else if(VA.Direction == Forward)
     {
       Pawn.Velocity.X = VA.PushDistance;
     }
     else if(VA.Direction == Back)
     {
       Pawn.Velocity.X = - VA.PushDistance;
     }
     PushState('PlayerWalking');
   }

   bVaulted = false;
 }


  Begin:
  
  Check();

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
		if(VSize(CalcViewLocationTemp-POVLocation) > 1000) {
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
		if ( Rx_HUD(myHUD) != None && (MinRespawnDelay+1 - GetTimerCount() > 1) && (MinRespawnDelay - GetTimerCount()) <= MinRespawnDelay)
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
	if(bIsInPurchaseTerminal) {
		`log("=======================" $self.Class $"=========================");
		ScriptTrace();
		if (Rx_HUD(myHUD).PTMovie.bMovieIsOpen) {
			Rx_HUD(myHUD).PTMovie.ClosePTMenu(false);	
		}
	}

	IsInPlayArea = true;
	BoundaryVolumes.Length = 0;
	LastLeftBoundaryTime = 0;

	if(Rx_Hud(myHUD) != None)
		Rx_Hud(myHUD).ClearPlayAreaAnnouncement();

	super.ClientPawnDied();	
	Rx_HUD(myHUD).ClearCapturePoint();
}

function float GetLastDiedTime()
{
	return LastDiedTime;
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
	if(WorldInfo.NetMode == NM_DedicatedServer) {
		SetJustBaughtEngineerClient(value);
	}

}

reliable client function SetJustBaughtEngineerClient(bool value) 
{
	SetJustBaughtEngineer(value);
}

function SetJustBaughtHavocSakura (bool value) 
{   
	bJustBaughtHavocSakura = false;
	if(WorldInfo.NetMode == NM_DedicatedServer) {
		SetJustBaughtHavocSakuraClient(value);
	}

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
	if(WorldInfo.NetMode == NM_DedicatedServer)
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
	
	if(!bMatchcountdownStarted && StartupStage == 0)
		Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "Waiting for other players ");
	else if(StartupStage >= 250)
	{			
		Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "Match begins in " $ 261 - StartupStage );	
		bMatchcountdownStarted = true;
	}
	else if(bMatchcountdownStarted && StartupStage >= 0)
		Rx_HUD(myHUD).HudMovie.GameplayTipsText.SetString("htmlText", "Match begins in " $ 5 - StartupStage );
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
	else if(LastClientpositionUpdates > 8 && VSize(Pawn.Location - ClientLocTemp) > 150)
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

exec function FutureSoldier()
{
	if (Pawn != None && Vehicle(Pawn) == None)
	{
		if (Worldinfo.NetMode == NM_Standalone)
		{
			if (GetTeamNum() == TEAM_GDI)
				Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'ts_ch_gdi_soldier.Mesh.SK_CH_GDI_Soldier_TE');
			else
				Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'ts_ch_nod_soldier.Mesh.SK_CH_Nod_Soldier_TE');
		}
		else
			FutureSoldierServer();
	}
}

reliable server function FutureSoldierServer()
{
	local Rx_Controller PC;
	if (bIsDev)
	{
		if (GetTeamNum() == TEAM_GDI)
		{
			Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'ts_ch_gdi_soldier.Mesh.SK_CH_GDI_Soldier_TE');
			foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
				PC.FutureSoldierClient(Pawn, SkeletalMesh'ts_ch_gdi_soldier.Mesh.SK_CH_GDI_Soldier_TE');
		}
		else
		{
			Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'ts_ch_nod_soldier.Mesh.SK_CH_Nod_Soldier_TE');
			foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
				PC.FutureSoldierClient(Pawn, SkeletalMesh'ts_ch_nod_soldier.Mesh.SK_CH_Nod_Soldier_TE');
		}
	}
}

reliable client function FutureSoldierClient(Pawn P, SkeletalMesh skel)
{
	P.Mesh.SetSkeletalMesh(skel);
}

exec function Nuke(string PlayerName)
{
	NukeServer(PlayerName);
}

reliable server function NukeServer(string PlayerName)
{
	local Rx_Weapon_DevNuke Beacon;
	local Rx_PRI PRI;

	if (bIsDev && PlayerName != "")
	{
		PRI = Rx_Game(WorldInfo.Game).ParsePlayer(PlayerName);

		if (PRI != None && Controller(PRI.Owner) != None)
		{
			Beacon = Controller(PRI.Owner).Pawn.Spawn(class'Rx_Weapon_DevNuke',,, Controller(PRI.Owner).Pawn.Location, Controller(PRI.Owner).Pawn.Rotation);
			Beacon.TeamNum = TEAM_UNOWNED;
		}
	}
}


exec function ReconnectDevBot()
{
	ServerReconnectDevBot();
}

reliable server function ServerReconnectDevBot()
{
	Rx_Game(WorldInfo.Game).ReconnectDevBot(self);
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

	//--------------Vaulting Options
	ClimbHeight = 0
	bVaulted = false
	EndgameScoreboardDelay = 10.0
	
	VaultStartSocketName = VaultStart
	VaultEndSocketName =   VaultEnd
	
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
	

	RadioCommandsText(0)     =   "Building needs repair!"
	RadioCommandsText(1)     =   "Get in the vehicle!"
	RadioCommandsText(2)     =   "Get out of the vehicle!"
	RadioCommandsText(3)     =   "Destroy that vehicle!" 
	RadioCommandsText(4)     =   "Watch where you´re pointing that!"
	RadioCommandsText(5)     =   "Don´t get in my way!"
	RadioCommandsText(6)     =   "Affirmative"
	RadioCommandsText(7)     =   "Negative."
	RadioCommandsText(8)     =   "I´m in position."
	RadioCommandsText(9)     =   "Enemy spotted!"
	
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
	

	RadioCommandsText(10)    =   "I need repairs!"
	RadioCommandsText(11)    =   "Take the point."
	RadioCommandsText(12)    =   "Move out."
	RadioCommandsText(13)    =   "Follow me."
	RadioCommandsText(14)    =   "Hold position."
	RadioCommandsText(15)    =   "Cover me."
	RadioCommandsText(16)    =   "Take cover."
	RadioCommandsText(17)    =   "Fall back."
	RadioCommandsText(18)    =   "Return to base."
	RadioCommandsText(19)    =   "Destroy it now!"
	
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
	

	RadioCommandsText(20)    =   "Attack the base defenses!"
	RadioCommandsText(21)    =   "Attack the Harvester!"
	RadioCommandsText(22)    =   "Attack that structure!"
	RadioCommandsText(23)    =   "Attack the Refinery!" 
	RadioCommandsText(24)    =   "Attack the Power Plant!"
	RadioCommandsText(25)    =   "Defend the base!"
	RadioCommandsText(26)    =   "Defend the Harvester!"
	RadioCommandsText(27)    =   "Defend that structure!"
	RadioCommandsText(28)    =   "Defend the Refinery!"
	RadioCommandsText(29)    =   "Defend the Power Plant!"
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
}

