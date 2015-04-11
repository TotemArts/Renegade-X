/** Class for running RemoteConsole. */
class Rx_Rcon extends TcpLink
	config(RenegadeX);

`include(RconProtocol.uci)

var config bool bEnableRcon;

/** TCP Port to Listen for Rcon connections on. 0 = Same as number as the UDP Game Port */
var config int RconPort;

/** Restricts Rcon access to only those manually added to the rcon whitelist. */
var globalconfig bool bWhitelistOnly;

/** List of IPs allowed to use Rcon if bWhitelistOnly is true. Doesn't support masks (yet). */
var globalconfig array<string> Whitelist;

/** The maximum amount of simultaneous connections allowed. Range is clamped 1 - MAX_RCON_CONNECTION. */
var globalconfig int ConnectionLimit;

var int ConnectionLimitActual;

var int ConnectionCount;

var const int MAX_RCON_CONNECTIONS;

/** The maximum amount of simultaneous subscribers allowed. 0 = No Limit - dependent on ConnectionLimit (ILL ADVISED IF ConnectionLimit IS HIGH). */
var globalconfig int SubscriberLimit;

/** Rcon Connections that are subscribed to logs. */
var Array<Rx_RconConnection> Subscribers;

var bool bBlockListen;

struct IPAttempt
{
	var string IP;
	var byte Count;
	var byte PruneChecks;

	structdefaultproperties
	{
		Count=1
		PruneChecks=0;
	}
};

/** How many chances for password attempts are allowed before being banned. The number given is the last and banning attempt. Valid range is 1 to 10. */
var globalconfig int MaxPasswordAttempts;
var int MaxPasswordAttemptsActual;

/** If true, the number of attemps taken and avaliable are not shown. */
var globalconfig bool bHideAttempts;

/** How often to prune attempt records. */
var int AttemptsPruneFrequency;

/** How many times a record gets checked during pruning before being removed. */
var int AttemptsPruneCount;

var Array<IPAttempt> Attempts;

var bool bMaxAttemptRecordsHit;

var const int MAX_ATTEMPT_RECORDS;

var int connectionId;

function PostBeginPlay()
{
	local int ListenPort;

	if (RconPort < 0)
		ListenPort = `GamePort;
	else
		ListenPort = RconPort;

	ConnectionLimitActual = Clamp(ConnectionLimit, 1, MAX_RCON_CONNECTIONS);
	MaxPasswordAttemptsActual = Clamp(MaxPasswordAttempts, 1, 10);

	// Setup prune times if we are going to be keeping track of Attempts
	if (MaxPasswordAttemptsActual > 1)
	{
		// TODO Hardcoded for now. Will added configuration later when I can be arsed making an algorithm to convert it reasonably well (if people even want it). 
		AttemptsPruneFrequency = 1800;   // 30 minutes
		AttemptsPruneCount = 6;          // 30 * 6 = 3 hours.
	}

	if (BindPort(ListenPort) > 0 && Listen());
	else
	{
		`LogRx("ERROR;"`s"Could not open TCP Port"@ListenPort@"- Rcon Disabled");
		Destroy();
	}
}

event GainedChild( Actor C )
{
	Super.GainedChild(C);
	ConnectionCount++;
	
	if (ConnectionCount >= ConnectionLimitActual && LinkState == STATE_Listening)
	{
		Close();
		`LogRx("RCON"`s"StoppedListen;"`s"(Reached Connection Limit)");
	}
}

event LostChild( Actor C )
{
	Super.LostChild(C);
	ConnectionCount--;

	if (bBlockListen)
		return;
	
	if (ConnectionCount < ConnectionLimitActual && LinkState != STATE_Listening)
	{
		`LogRx("RCON"`s"ResumedListen;"`s"(No longer at Connection Limit)");
		Listen();
	}
}

function CloseAll(string Message)
{
	local Rx_RconConnection connection;

	BlockListen();

	foreach ChildActors(class'Rx_RconConnection',connection)
	{
		if (Message != "")
			connection.SendText(`ERROR $ Message);
		connection.Close();
	}
}

function BlockListen()
{
	bBlockListen=true;
	Close();
}

function LockOut()
{
	CloseAll(`Err_RconLocked);
}

function NotifyNonSeamless()
{
	CloseAll(`Err_NonSeamless);
}

function bool Subscribe(Rx_RconConnection connection)
{
	if (Subscribers.Length >= SubscriberLimit)
		return false;
	if (Subscribers.Find(connection) == -1)
	{
		Subscribers.AddItem(connection);
		`LogRx("RCON"`s "Subscribed;" `s connection.IPstring);
	}
	return true;
}

function UnSubscribe(Rx_RconConnection connection, optional bool isDisconnect=false)
{
	if (Subscribers.Find(connection) != -1)
	{
		Subscribers.RemoveItem(connection);
		if (!isDisconnect)
			`LogRx("RCON"`s "Unsubscribed;" `s connection.IPstring );
	}
}

function SendLog(string Text)
{
	local Rx_RconConnection r;
	foreach Subscribers(r)
		r.SendText(`LOGMSG $ Text);
}

function bool OnWhitelist(string IP)
{
	local string s;

	// TODO Implement masks

	foreach Whitelist(s)
		if (s == IP)
			return true;
	return false;
}

/** 
 *  @return 0 = Success, -1 = Banned, Positive number = Saved attempts count */
function int Authenticate(string IP, string Password)
{
	local int i;
	local IPAttempt Temp;

	if (WorldInfo.Game.AccessControl.ValidLogin("",Password))
		return 0;
	else
		return 1;   // TEMPORARILY DID THIS ELSE TILL IP FIX

	// deal with special case
	if (MaxPasswordAttemptsActual == 1)
	{
		Rx_AccessControl(WorldInfo.Game.AccessControl).BanIP(IP);
		return -1;
	}
	// Attempts are stored in order of attempt time oldest to newest, so iterate backwards for optimally supporting subsequent attempts from same guy.
	for (i=Attempts.Length-1; i>=0; --i)
	{
		if (Attempts[i].IP == IP)
		{
			if (++Attempts[i].Count < MaxPasswordAttemptsActual)
			{
				// if not last on the list, move to last as it is now the latest attempt.
				if (i != Attempts.Length-1)
				{
					Temp.IP = Attempts[i].IP;
					Temp.Count = Attempts[i].Count;
					Attempts.Remove(i,1);
					Attempts[Attempts.Length] = Temp;
				}
				else
					Attempts[i].PruneChecks = 0;
				return Attempts[Attempts.Length-1].Count;
			}
			else
			{
				Rx_AccessControl(WorldInfo.Game.AccessControl).BanIP(IP);
				Attempts.Remove(i,1);
				return -1;
			}
		}
	}
	// Didn't already exist, add new record.
	Temp.IP = IP;
	Attempts[Attempts.Length] = Temp;

	if (Attempts.Length == 1)
		// No attempts were on record before we added this one, so prune timer ain't running, start it up.
		SetTimer(AttemptsPruneFrequency, false, 'Prune');
	// If we hit max records, report to log and then start dropping off the oldest records.
	else if (Attempts.Length >= MAX_ATTEMPT_RECORDS)
	{
		if (!bMaxAttemptRecordsHit)
		{
			bMaxAttemptRecordsHit = true;
			`LogRx("RCON"`s"Warning;"`s"(Hit Max Attempt Records - You should investigate Rcon attempts and/or decrease prune time)");
		}
		Attempts.Remove(0,1);
	}
	return 1;
}

function Prune()
{
	local int i;

	for (i=Attempts.Length-1; i>=0; --i)
	{
		if (++Attempts[i].PruneChecks >= AttemptsPruneCount)
		{
			Attempts.Remove(0, i+1);
			break;
		}
	}
	if (Attempts.Length > 0)
		SetTimer(AttemptsPruneFrequency, false, 'Prune');
}

DefaultProperties
{
	AcceptClass=class'RenX_Game.Rx_RconConnection'

	MAX_RCON_CONNECTIONS=10
	MAX_ATTEMPT_RECORDS=20
}
