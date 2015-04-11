class Rx_VersionCheck extends Actor
	DLLBind(Rx_VersionCheck_Lib);

var string VersionInfoURL;
var string DownloadURL;
var string LatestVersion;
var bool bVersionFound;
var int Timeout;

dllimport final function OpenWebsiteAndExit (string URL);
// Start our lib looking for our version string at the URL specified.
dllimport final function StartFindVersion(string URL);
// Poll our lib to see if it's found the version. Will return a blank string if it hasn't.
dllimport final function string PollVersion();
// ping from native (SYNC)
dllimport final function string PingIp(string IpString);
// start async pings from native
dllimport final function StartPingAll(string ServersString);
// get ping status (count) for finished pings
dllimport final function int GetPingStatus();
// get ping from async finished list for ip, returns -1 when failed or not arrived
dllimport final function int GetPingFor(string Ip);
// returns pinged ids list
dllimport final function string GetPingedIDs();

function CloseGameAndOpenDownloadURL()
{
	if (Rx_Game(WorldInfo.Game) != none && Rx_Game(WorldInfo.Game).GameVersion != "")
		OpenWebsiteAndExit (DownloadURL$Rx_Game(WorldInfo.Game).GameVersion);
	else
		OpenWebsiteAndExit (DownloadURL);
}


/* Allows this class to call functions in another class when out of version is flagged.
 * The function bound to this delegate must have no parameters or return types.
 * If parameters or return types are needed, they must be wrapped in the function
 * that is called.
 */
delegate NotifyDelegate();

function RegisterNotifyDelegate(delegate<NotifyDelegate> MyNotifyDelegate)
{
	NotifyDelegate = MyNotifyDelegate;
}


function PreBeginPlay()
{
	RefreshVersion();
}

function RefreshVersion()
{
	LatestVersion = "";
	bVersionFound = false;
	Timeout = 0;
	// Start the lib looking for the latest version string on the server
	StartFindVersion(VersionInfoURL);
	// Set a timer to check every 0.3 seconds if the lib has found it yet.
	SetTimer(0.3f,true,'CheckForVersionFound');
}

private function CheckForVersionFound()
{
	LatestVersion = PollVersion();

	if (!bVersionFound && LatestVersion != "")
	{
		bVersionFound = true;
		LatestVersion = PollVersion();
		VersionFound();
		ClearTimer('CheckForVersionFound');
	}
	else
	{
		Timeout++;
		if (Timeout > Default.Timeout)
		{
			ClearTimer('CheckForVersionFound');
		}
	}
}

function VersionFound()
{
	local bool bOutOfDate;
	bOutOfDate = IsOutOfDate();

	// Notify game of the result of the version check.
	if (Rx_Game(WorldInfo.Game) != none)
		Rx_Game(WorldInfo.Game).VersionCheckComplete(bOutOfDate);
}

function bool IsOutOfDate()
{
	local float GameVerFloat, LatestVerFloat;

	if (Rx_Game(WorldInfo.Game) != none && Rx_Game(WorldInfo.Game).GameVersion != "" && LatestVersion != "")
	{
		GameVerFloat = GetFloatVer(Rx_Game(WorldInfo.Game).GameVersion);
		LatestVerFloat = GetFloatVer(LatestVersion);

		if (LatestVerFloat > GameVerFloat)
			return true;
	}

	return false;
}

function bool IsPreReleaseBeta(string StringVer)
{
	if ( Left(StringVer,4) ~= "BETA")
		return true;
	else return false;
}

function bool IsReleaseCandidate(string StringVer)
{
	if ( Right(StringVer,2) ~= "RC")
		return true;
	else return false;
}

function bool IsOpenBeta(string StringVer)
{
	if (Left(StringVer,4) ~= "OPEN")
		return true;
	else return false;
}

function float GetFloatVer(string StringVer)
{
	local float valmod;
	valmod = 0;
	StringVer = Caps(StringVer);

	// Release candidates are always under non-RC of the same version.
	if (IsReleaseCandidate(StringVer))
	{
		valmod -= 0.00001;
	}

	// Open beta is after pre-release, but before non-beta
	if (IsOpenBeta(StringVer))
	{
		valmod -= 500;
	}
	// Pre-release betas are always under everything.
	else if (IsPreReleaseBeta(StringVer))
	{
		valmod -= 100;
	}
	StringVer -= "BETA";
	StringVer -= "OPEN";
	StringVer -= "ALPHA";
	StringVer -= "RC";
	StringVer -= " ";

	return float(StringVer) + valmod;
}

function BroadcastVersion ()
{
	if (Rx_Game(WorldInfo.Game) != none)
	{
		WorldInfo.Game.Broadcast(self,"Game Version:"@ Rx_Game(WorldInfo.Game).GameVersion);
		WorldInfo.Game.Broadcast(self,"Latest Release:"@ LatestVersion);
		if (IsOutOfDate())
		{
			WorldInfo.Game.Broadcast(self,"Game is out of Date");
		}
	}
}

function LogVersion ()
{
	if (Rx_Game(WorldInfo.Game) != none)
	{
		`log("Game Version:"@ Rx_Game(WorldInfo.Game).GameVersion);
		`log("Latest Release:"@ LatestVersion);
		if (IsOutOfDate())
		{
			`warn("Game is out of Date");
		}
	}
}

/**
 * Ping
 * given IP and returns ping (>=500 means usually fail)
 * 
 * @param - ip to ping
 * @return - ping for given ip
 */
public function string Ping(String Ip)
{
	return PingIp(Ip);
}


DefaultProperties
{
	// Check back this many times until we give up.
	Timeout = 20;
	// Where to look for our version string
	VersionInfoURL = "http://renegade-x.com/version/gameversion"
	// What webpage to open if player wants to download a new version
	DownloadURL = "http://renegade-x.com/download"
}
