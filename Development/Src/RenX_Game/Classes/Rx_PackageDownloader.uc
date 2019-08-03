/**
 * Manages HTTP connections to download packages
 * 
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class Rx_PackageDownloader extends Object;

enum EDownloaderState
{
	STATE_Uninitialized,
	STATE_FetchingMirrors,
	STATE_FetchingServer,
	STATE_Waiting,
	STATE_Downloading
};

var EDownloaderState DownloaderState;

// Mirror List
var Rx_PackageDownloadClient MirrorListClient;
var const string MirrorListHostname;
var const string MirrorListFile;
var array<string> MirrorList;

// Mirrors
var string DownloadMirrorHostname;
var const string DownloadMirrorPath;
var const string TestFile;

// Download management
var array<Rx_PackageDownloadClient> DownloadClients;
var array<string> PendingDownloads;
var int MaxDownloadClients;

function Initialize()
{
	// Fetch mirrors list
	DownloaderState = STATE_FetchingMirrors;

	MirrorListClient = new class'Rx_PackageDownloadClient';
	MirrorListClient.Connect(MirrorListHostname, MirrorListFile, self);
}

function MirrorListDownloaded()
{
	local int index;
	local string Mirror;
	local byte Data;

	`log("START MIRROR LIST!");
	Mirror = "";

	// Parse mirrors
	for (index = 0; index != MirrorListClient.Response.Length; ++index)
	{
		Data = MirrorListClient.Response[index];
		switch (Data)
		{
		case 10: // NL
			if (Mirror != "")
			{
				`log(Mirror);
				MirrorList.AddItem(Mirror);
				Mirror = "";
			}
			break;

		case 13: // CR (ignore)
			break;

		default:
			Mirror $= Chr(Data);
		}
	}

	if (Mirror != "")
		MirrorList.AddItem(Mirror);

	`log(Mirror);
	`log("END MIRROR LIST");

	MirrorListClient = None;

	// Fetch best server
	DownloaderState = STATE_FetchingServer;

	for (index = 0; index != MirrorList.Length; ++index)
	{
		DownloadClients.AddItem(new class'Rx_PackageDownloadClient');
		DownloadClients[index].Connect(MirrorList[index], TestFile, self);
	}
}

function CloseAllDownloadClients()
{
	local int index;

	index = DownloadClients.Length;
	while (index != 0 && DownloaderState == STATE_FetchingServer)
		DownloadClients[--index].Close();

	DownloadClients.Length = 0;
}

function RemoveClient(Rx_PackageDownloadClient DownloadClient)
{
	DownloadClients.RemoveItem(DownloadClient);

	if (PendingDownloads.Length != 0)
	{
		AddDownload(PendingDownloads[0]);
		PendingDownloads.Remove(0, 1);
	}
	else if (DownloadClients.Length == 0)
		DownloadsFinished();
}

function BestServerFound(Rx_PackageDownloadClient DownloadClient)
{
	DownloaderState = STATE_Waiting;

	DownloadMirrorHostname = DownloadClient.RequestHostname;
	CloseAllDownloadClients();

	`log("BEST MIRROR: " $ DownloadMirrorHostname);

	StartDownloading(); // Starts downloading IF any packages are available (otherwise, remains in STATE_Waiting).
}

function QueueDownload(string ResourceName)
{
	if (DownloaderState == STATE_Downloading && (MaxDownloadClients < 0 || DownloadClients.Length < MaxDownloadClients))
		AddDownload(ResourceName);
	else
	{
		PendingDownloads.AddItem(ResourceName);

		if (DownloaderState == STATE_Waiting)
			StartDownloading();
	}
}

function ReceivedPackage(Rx_PackageDownloadClient DownloadClient)
{
	// Send data to Rx_PackageManager
	`RxEngineObject.PackageManager.AddPackage(DownloadClient.RequestResource, DownloadClient.Response);

	// Remove from client list
	RemoveClient(DownloadClient);
}

function FailedDownload(Rx_PackageDownloadClient DownloadClient)
{
	if (DownloaderState == STATE_FetchingMirrors)
	{
		MirrorListClient = None;

		`log("Rx_PackageDownloader: ERROR! FAILED TO DOWNLOAD MIRROR LIST!");
	}
	else
		RemoveClient(DownloadClient);
}

function ReceivedResponse(Rx_PackageDownloadClient DownloadClient)
{
	switch (DownloaderState)
	{
	case STATE_FetchingMirrors:
		MirrorListDownloaded();
		return;

	case STATE_FetchingServer:
		BestServerFound(DownloadClient);
		return;

	case STATE_Downloading:
		ReceivedPackage(DownloadClient);
		return;

	default:
		return;
	}
}

function DownloadsFinished()
{
	DownloaderState = STATE_Waiting;

	// Inform the client to start connecting to server
}

function Tick(float DeltaTime)
{
	local int index;

	index = DownloadClients.Length;

	switch (DownloaderState)
	{
	case STATE_FetchingMirrors:
		MirrorListClient.Tick(DeltaTime);
		return;

	case STATE_FetchingServer:
		while (index != 0 && DownloaderState == STATE_FetchingServer)
			DownloadClients[--index].Tick(DeltaTime);
		return;

	case STATE_Downloading:
		while (index != 0)
			DownloadClients[--index].Tick(DeltaTime);
		return;

	default:
		return;
	}
}

private function StartDownloading()
{
	local int count;

	if (DownloaderState == STATE_Waiting && PendingDownloads.Length != 0)
	{
		DownloaderState = STATE_Downloading;

		while (PendingDownloads.Length != 0 && (count != MaxDownloadClients || MaxDownloadClients < 0))
		{
			AddDownload(PendingDownloads[0]);

			PendingDownloads.Remove(0, 1);
			++count;
		}
	}
}

private final function AddDownload(string ResourceName)
{
	local Rx_PackageDownloadClient DownloadClient;

	DownloadClient = new class'Rx_PackageDownloadClient';
	DownloadClients.AddItem(DownloadClient);
	DownloadClient.Connect(DownloadMirrorHostname, DownloadMirrorPath $ ResourceName, self);
}

DefaultProperties
{
	MirrorListHostname = "direct.renegade-x.com"
	MirrorListFile = "/patches/mirrors"
	DownloadMirrorPath = "/custom_packages/"
	TestFile = "/10kb_file"
	MaxDownloadClients = 2;

	DownloaderState = STATE_Uninitialized;
}
