class GeminiOnlineService extends Actor;

var GeminiLinkClient ConnClient;
var string AccountCode;
var string AccountPass;

/* Queue of POST/GET to handle multiple requests and prevent them from overriding
 * each other. They are in FIFO order, so PostQueue[0] is always executed next.
 */
var array<string> PostQueue;

/* Reference to your game class. Replace this with the actual name of your game
 * class. This completes the three-way handshake between MyGame, the link client,
 * and the online service.
 */
var Rx_Game Game;

var Rx_Controller RxContr;

/* Allows this class to call functions in another class when connection is done.
 * The function bound to this delegate must have no parameters or return types.
 * If parameters or return types are needed, they must be wrapped in the function
 * that is called.
 */
delegate NotifyDelegate();

function RegisterNotifyDelegate(delegate<NotifyDelegate> MyNotifyDelegate)
{
	NotifyDelegate = MyNotifyDelegate;
}

function Initialize(Rx_Game MG, Rx_Controller RC)
{
	Game = MG;
	RxContr = RC;
	ConnClient = Spawn(class'GeminiLinkClient');
	ConnClient.Initialize(self);
}

///THE ACTUAL POST AND GET FUNCTIONS///
function GeminiGet(string webpage, string message, bool bNotify)
{
	if(ConnClient.bIsBusy)
	{
		`log("[GeminiOnlineService] Client is busy, queueing GET request");
		PostQueue.AddItem("get~" $ webpage $ "~" $ message $ "~" $ string(bNotify));
	}
	else
	{
		`log("[GeminiOnlineService] Getting Data");
		ConnClient.TransmitData(false, bNotify, webpage, message);
	}
}

function GeminiPost(string webpage, string message, bool bNotify)
{
	if(ConnClient.bIsBusy)
	{
		`log("[GeminiOnlineService] Client is busy, queueing POST request");
		PostQueue.AddItem("post~" $ webpage $ "~" $ message $ "~" $ string(bNotify));
	}
	else
	{
		`log("[GeminiOnlineService] Posting Data: " $ message);
		ConnClient.TransmitData(true, bNotify, webpage, message);
	}
}
///END THE ACTUAL POST AND GET FUNCTIONS///


function string FormatPost(string Input)
{
	return "&content=" $ Repl(Input, " ", "+");
}


///POST AND GET FOR SERVICE///
function GetFromService(optional bool bNotify)
{
	GeminiGet("/service.jsp?", "pass="$AccountPass$"&code="$AccountCode, bNotify);
}

function PostToService(string Message, optional bool bNotify)
{
	GeminiPost("/sign", "checker="$AccountPass$"&code="$AccountCode$FormatPost(Message), bNotify);
}

function GetServiceCheckIp(String ip, String steamID, bool bc)
{
    if(bc)
		GeminiGet("/checkp.jsp?", "ip="$ip$"&steamid="$steamID$"&bc=1", true);
	else	
		GeminiGet("/checkp.jsp?", "ip="$ip$"&steamid="$steamID, true);
}
///END POST AND GET FOR SERVICE///


///POST AND GET FOR SERVER///
/* Gets a list of all servers currently on Gemini. They will be added to ListServers in MyGame.uc
 * You should use ListServers to display a list of all servers in a matchmaking screen. When the
 * player picks a server, grab its IP by doing MyGame.ListServers[ROW].ServerIP. Then you can do
 * ConsoleCommand("open "$IP).
 */
function GetFromServer()
{
	GeminiGet("/browser.jsp?", "pass="$AccountPass$"&code="$AccountCode$"&view=false", true);
}

/* Adds a server to the server list. You do not need to specify the IP; this will be
 * automatically calculated for you when the server is added. This can be called by
 * calling MyGame.ServiceBrowser.PostToServer() using a reference to MyGame when the
 * host player decides to host a match.
 */
function PostToServer(int ServerPort, string ServerName, bool RequiresPass, String MapName,
		string ServerSettings, int CurPlayers, int MaxPlayers, int Ranked, bool bInGame, int CurrBots)
{
	GeminiPost("/register", "password="$AccountPass$"&code="$AccountCode$
			"&port="$ string(ServerPort)$
			"&name="$ ServerName$
			"&pass="$ RequiresPass$
			"&type="$ MapName$
			"&list="$ ServerSettings$
			"&curr="$ string(CurPlayers)$
			"&maxp="$ string(MaxPlayers)$
			"&rank="$ string(Ranked)$
			"&bing="$ string(bInGame)$
			"&currBots="$ string(CurrBots), true);
}

/* Removes a server from the browser. This assumes that you cannot have more than one
 * server running at the same IP.
 */
function RemoveServer()
{
	GeminiPost("/register", "password="$AccountPass$"&code="$AccountCode$"&pass=delete", false);
}
///END POST AND GET FOR SERVER///


function RetryPost()
{
	local string NextPost;
	local array<string> Parts;
	if(PostQueue.Length != 0) {
		if(PostQueue[0] != "")
		{
			NextPost = PostQueue[0];
			PostQueue.Remove(0,1);
			ParseStringIntoArray(NextPost, Parts, "~", true);
			if(Parts[0] == "get")
			{
				GeminiGet(Parts[1], Parts[2], bool(Parts[3]));
			}
			else
			{
				GeminiPost(Parts[1], Parts[2], bool(Parts[3]));
			}
		}
	}
}


///GEMINI SPECIAL FUNCTIONS///
function FlushMessages(int Index, optional bool bNotify)
{
	PostToService("flush" $ Index, bNotify);
}

function ReplaceMessage(int Index, string NewMsg, optional bool bNotify)
{
	PostToService("replace" $ Index $ "," $ NewMsg, bNotify);
}

function DeleteMessage(int Index, optional bool bNotify)
{
	PostToService("delete" $ Index, bNotify);
}

function SetFieldSize(int Size, optional bool bNotify)
{
	PostToService("setfieldsize" $ Size, bNotify);
}

function PerformOp(int Index, int Oper, int Value, optional bool bNotify)
{
	PostToService("perform" $ Index $ ",op" $ Oper $ ",num" $ Value, bNotify);
}

function SendPlayerStats(String playerStats)
{
	PostToService("updatePlayerStats" $ playerStats, false);
}

function AppendToMessage(int Index, string ToAppend, optional bool bNotify)
{
	PostToService("append" $ Index $ "," $ ToAppend, bNotify);
}
///END GEMINI SPECIAL FUNCTIONS///


/* Called when the ConnClient has received a response from Gemini.
 * At the moment, responses are limited to GET requests only.
 */
function HandleGetResponse(string webpage, string Text)
{
	if(Game != None)
	{
		if(webpage == "/service.jsp?")
		{
			Game.HandleServiceData(Text);
		}
		else if(webpage == "/browser.jsp?")
		{
			Game.HandleServerData(Text);
		}
		else if(webpage == "/checkp.jsp?")
		{
			Game.HandleBannedIP(Text);
		}
	} 
	else if(RxContr != None)
	{
		if(webpage == "/checkp.jsp?")
		{
			RxContr.AuthResponse(Text);
		}
	}
}

/* Called when the ConnClient has completed a transmission, but only if
 * bNotify was true. This should be used for things like reducing the player
 * count before exiting the game: since the operation MUST be completed before
 * a quit is called, you can put ConsoleCommand("quit"); in here and know
 * that your game will safely exit.
 */
function OnConnectionCompleted(string message)
{
	// For now just call the delegate.
	NotifyDelegate();
}

defaultproperties
{
	//AccountCode = "f140224"; // First 7 characters of your code 
	//AccountPass = "k74nB9x"; // Your pass
	AccountCode = "1234567"; // First 7 characters of your code 
	AccountPass = "renegadex"; // Your pass
}
