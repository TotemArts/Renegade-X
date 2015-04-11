class Rx_AccessControl extends AccessControl
	config(RenegadeX);

/** Whether clients required to be logged into Steam to play on this server. */
var config bool bRequireSteam;

/** Password to login as moderator.  */
var private globalconfig string	ModPassword;

/** Whether to announce if a admin/mod logs in/out. */
var config bool bBroadcastAdminIdentity;

/** If admins/moderators need to be on the SteamID auth lists. */
var config bool bSteamAuthAdmins;

/** List of SteamIDs authorised for Administator. */
var config Array<string> AdministratorSteamIDs;

/** List of SteamIDs authorised for Moderator. */
var config Array<string> ModeratorSteamIDs;

// Kick blocking stuff
struct TempBan {
	var UniqueNetID UID;
	var int ExpireMinute;
	var int ExpireHour;
	var int ExpireDayOfWeek;
};

struct Priors {
	var UniqueNetID UID;
	var int Count;

	structdefaultproperties
	{
		Count=1
	}
};

var Array<TempBan> TempBans;
var Array<Priors> BanPriors;
// end block

function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();
	//Fix up Steam IDs into right format if they're incorrect.
	for (i=0; i<AdministratorSteamIDs.Length; ++i)
		AdministratorSteamIDs[i] = FixSteamID(AdministratorSteamIDs[i]);
	for (i=0; i<ModeratorSteamIDs.Length; ++i)
		ModeratorSteamIDs[i] = FixSteamID(ModeratorSteamIDs[i]);
	SaveConfig();
}

/** Corrects Steam IDs into the format if the given ID has less than 16 digits, is missing the 0x prefix and/or the hexadecimal is not in capitals. */
function static string FixSteamID(string ID)
{
	if (Len(ID) != 18 || !(Mid(ID,2) == Caps(Mid(ID,2))) )
	{
		if ( Left(ID,2) ~= "0x" )
			ID = Mid(ID, 2);
		ID = Caps(ID);
		while (Len(ID) < 16)
			ID = "0"$ID;
		ID = "0x"$ID;
	}
	return ID;
}

event PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string OutError, bool bSpectator)
{
	if (bRequireSteam && OnlineSub.UniqueNetIdToString(UniqueId) == `BlankSteamID)
		OutError = "Engine.Errors.SteamClientRequired";
	else
		super.PreLogin(Options, Address, UniqueId, bSupportsAuth, OutError, bSpectator);
}

/** Temporary "Moderator". Admin without access to the Admin command. */
function bool AdminLogin( PlayerController P, string Password )
{
	local string SteamID;

	// Can't login if already logged in.
	if ( P.PlayerReplicationInfo.bAdmin )
		return false;

	SteamID = OnlineSub.UniqueNetIdToString(P.PlayerReplicationInfo.UniqueId);

	// Try logging in as Admin first.
	if ( super.AdminLogin(P, Password) )
	{
		if (bSteamAuthAdmins && !IsAdminSteamID(SteamID))
			P.PlayerReplicationInfo.bAdmin = false;
		else
			return true;
	}

	// If failure, try logging in as Moderator.
	if (ModPassword == "")
		return false;
	if (Password == ModPassword)
	{
		if (bSteamAuthAdmins && !IsModSteamID(SteamID) && !IsAdminSteamID(SteamID) )
			return false;
		P.PlayerReplicationInfo.bAdmin = true;
		Rx_PRI(P.PlayerReplicationInfo).bModeratorOnly = true;
		return true;
	}
	return false;
}

function bool IsAdminSteamID(String ID)
{
	local int i;
	for (i=0; i<AdministratorSteamIDs.Length; ++i)
		if (ID == AdministratorSteamIDs[i])
			return true;
	return false;
}

function bool IsModSteamID(String ID)
{
	local int i;
	for (i=0; i<ModeratorSteamIDs.Length; ++i)
		if (ID == ModeratorSteamIDs[i])
			return true;
	return false;
}

function bool AdminLogout(PlayerController P)
{
	if (super.AdminLogout(P))
	{
		if (Rx_PRI(P.PlayerReplicationInfo).bModeratorOnly)
			Rx_PRI(P.PlayerReplicationInfo).bModeratorOnly = false;
		return true;
	}
	return false;
}

function ModEntered( PlayerController P )
{
	local string LoginString;

	`LogRx("ADMIN"`s "Login;" `s `PlayerLog(P.PlayerReplicationinfo)`s"as"`s"moderator");

	if (!bBroadcastAdminIdentity)
	{
		P.ClientMessage("Logged in as server moderator.");
		return;
	}

	LoginString = P.PlayerReplicationInfo.PlayerName@"logged in as a server moderator.";

	`log(LoginString);
	WorldInfo.Game.Broadcast( P, LoginString );
}
function ModExited( PlayerController P )
{
	local string LogoutString;

	`LogRx("ADMIN"`s "Logout;" `s `PlayerLog(P.PlayerReplicationinfo)`s "as"`s "moderator");

	if (!bBroadcastAdminIdentity)
	{
		P.ClientMessage("No longer logged in as a server moderator.");
		return;
	}

	LogoutString = P.PlayerReplicationInfo.PlayerName$"is no longer logged in as a server moderator.";

	`log(LogoutString);
	WorldInfo.Game.Broadcast( P, LogoutString );
}

function AdminEntered( PlayerController P )
{
	`LogRx("ADMIN"`s "Login;" `s `PlayerLog(P.PlayerReplicationinfo)`s "as"`s "administrator");
	if (!bBroadcastAdminIdentity)
	{
		P.ClientMessage("Logged in as a server administrator.");
		return;
	}
	super.AdminEntered(P);
}

function AdminExited( PlayerController P )
{
	`LogRx("ADMIN"`s "Logout;" `s `PlayerLog(P.PlayerReplicationinfo)`s "as"`s "administrator");
	if (!bBroadcastAdminIdentity)
	{
		P.ClientMessage("No longer logged in as a server administrator.");
		return;
	}
	super.AdminExited(P);
}

function AddAdmin( PlayerController Caller, PlayerReplicationInfo NewAdmin, bool AsModerator )
{
	local string SteamID;
	local int i;

	SteamID = OnlineSub.UniqueNetIdToString(NewAdmin.UniqueId);

	if ( SteamID == `BlankSteamID )
	{
		Caller.ClientMessage(NewAdmin.Name@"is not using Steam.");
		return;
	}

	if ( IsAdminSteamID(SteamID) )
	{
		Caller.ClientMessage(NewAdmin.Name@"is already an Administrator.");
		return;
	}

	if (AsModerator)
	{
		if ( IsModSteamID(SteamID) )
		{
			Caller.ClientMessage(NewAdmin.Name@"is already a Moderator.");
			return;
		}

		ModeratorSteamIDs[ModeratorSteamIDs.Length] = SteamID;
		SaveConfig();
		`LogRx("ADMIN"`s "Granted;"`s `PlayerLog(NewAdmin)`s "as"`s "moderator");
		Caller.ClientMessage(NewAdmin.Name@" successfully added as a Moderator.");
	}
	else
	{
		AdministratorSteamIDs[AdministratorSteamIDs.Length] = SteamID;

		for (i=0; i<ModeratorSteamIDs.Length; ++i)
		{
			if (ModeratorSteamIDs[i] == SteamID)
			{
				ModeratorSteamIDs.Remove(i,1);
				break;
			}
		}
		SaveConfig();
		`LogRx("ADMIN"`s "Granted;"`s `PlayerLog(NewAdmin)`s "as"`s "administrator");
		Caller.ClientMessage(NewAdmin.Name@" successfully added as an Administrator.");
	}
}

// Jacked version of AccessControl::KickBan(...), fixes a problem with the way it gets the IP.
function KickBan( string Target )
{
	local PlayerController P;
	local string IP;

	P =  PlayerController( GetControllerFromString(Target) );
	if ( NetConnection(P.Player) != None )
	{
		if (!WorldInfo.IsConsoleBuild())
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIPPolicy(IP) )
			{
				`Log("Adding IP Ban for: "$IP);
				IPPolicies[IPPolicies.length] = "DENY," $ IP;
				SaveConfig();
			}
		}

		if ( P.PlayerReplicationInfo.UniqueId != P.PlayerReplicationInfo.default.UniqueId &&
			!IsIDBanned(P.PlayerReplicationInfo.UniqueID) )
		{
			BannedIDs.AddItem(P.PlayerReplicationInfo.UniqueId);
			SaveConfig();
		}
		KickPlayer(P, DefaultKickReason);
		return;
	}
}

function Controller GetControllerFromString(string Target)
{
	local Controller C;
	local Rx_PRI P;

	// Make it behave like the Rx implemented commands.
	P = Rx_Game(WorldInfo.Game).ParsePlayer(Target);
	if (P != None)
	{
		foreach WorldInfo.AllControllers(class'Controller', C)
		{
			if (C.PlayerReplicationInfo == P)
				return C;
		}
	}

	// Just rely on original implementation if fail.
	return super.GetControllerFromString(Target);
}


/** The IP Banning part of AccessControl::KickBan made standalone. DOES NOT VERIFY PARAMETER IS AN ACTUAL IP.
 *  @return true = Ban added. false = Already banned. */
function bool BanIP(string IP)
{
	if( CheckIPPolicy(IP) )
	{
		`Log("Adding IP Ban for: "$IP);
		IPPolicies[IPPolicies.length] = "DENY," $ IP;
		SaveConfig();
		return true;
	}
	return false;
}

function FlushTempBans()
{
	local int DayOfWeek, Hour, Min, i;
	GetSystemTime(i,i,DayOfWeek,i,Hour,Min,i,i);

	for (i=0; i<TempBans.Length; ++i)
	{
	}
}

DefaultProperties
{
}
