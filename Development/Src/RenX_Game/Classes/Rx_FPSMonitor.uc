class Rx_FPSMonitor extends Actor
config(FPSMonitor);

struct Capture
{
	var float TPS;
	var float DeltaTime;
};

var private float TPS;
var private float ServerDeltaTime;
var config float LogFrequency; 		    // Seconds of time between each logging message
var config int PreviousCapturesToLog;   // How many seconds of TPS/DT to display per log
var config float CaptureFrequency;		// How often to capture TPS/DT
var array<Capture> Captures;

function PostBeginPlay()
{
	if (LogFrequency > 0)
	{
		SetTimer(1, true, nameof(RecordInfo));
		SetTimer(LogFrequency, true, nameof(LogToConsole));
	}
}

event Tick(float DeltaTime)
{
	TPS = 1 / DeltaTime;
	ServerDeltaTime = DeltaTime;
}

final function RecordInfo()
{
	local Capture NewCapture;

	NewCapture.TPS = TPS;
	NewCapture.DeltaTime = ServerDeltaTime;

	Captures.AddItem(NewCapture);

	if (Captures.Length > PreviousCapturesToLog)
		Captures.Remove(0, Captures.Length - PreviousCapturesToLog);
}

final function LogToConsole()
{
	local string NewLog;
	local Capture C;

	ForEach Captures(C)
	{
		NewLog @= C.TPS $ "/" $ C.DeltaTime;
	}

	`log(NewLog,, 'TPS DT');
}