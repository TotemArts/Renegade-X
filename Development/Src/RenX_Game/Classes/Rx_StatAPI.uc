class Rx_StatAPI extends Object
config(StatAPI);

`include(Engine\Classes\HttpStatusCodes.uci)

var config string StatAPIURL;
var config int APIUpdateInterval;
var config bool bPostToAPI;
var string gameID;

function GameStart(string ServerName, string MapName, string GameMode, string GameVersion)
{
	local JsonObject Payload;

	Payload = new class'JsonObject';
	Payload.SetStringValue("serverName", ServerName);
	Payload.SetStringValue("serverIP", "None");
	Payload.SetStringValue("map", MapName);
	Payload.SetStringValue("gameName", "renegadeX");
	Payload.SetStringValue("version", GameVersion);
	PostToAPI("GameStart", Payload);
}

function GameUpdate(string GDIScore, string NodScore, string GDIPlayers, string NodPlayers)
{
	local JsonObject Payload;

	Payload = new class'JsonObject';
	Payload.SetStringValue("gameId", gameID);
	Payload.SetStringValue("team1Score", GDIScore);
	Payload.SetStringValue("team2Score", NodScore);
	Payload.SetStringValue("team1Players", GDIPlayers);
	Payload.SetStringValue("team2Players", NodPlayers);
	PostToAPI("GameUpdate", Payload);
}

function GameEnd(string GDIScore, string NodScore, string GDIPlayers, string NodPlayers, int WinningTeam, string WinMethod)
{
	local string WinningTeamName;
	local JsonObject Payload;

	switch(WinningTeam)
	{
		case 0:
			WinningTeamName = "GDI";
		break;

		case 1:
			WinningTeamName = "Nod";
		break;

		default:
			WinningTeamName = "None";
	}

	Payload = new class'JsonObject';
	Payload.SetStringValue("gameId", gameID);
	Payload.SetStringValue("team1Score", GDIScore);
	Payload.SetStringValue("team2Score", NodScore);
	Payload.SetStringValue("team1Players", GDIPlayers);
	Payload.SetStringValue("team2Players", NodPlayers);
	Payload.SetStringValue("winner", WinningTeamName);
	Payload.SetStringValue("winMethod", WinMethod);
	PostToAPI("GameEnd", Payload);
}

function PostToAPI(string Type, JsonObject DataToSend)
{
	local HttpRequestInterface HTTPRequest;
	local string Payload;

	Payload = class'JsonObject'.static.EncodeJson(DataToSend);

	`log("Posting to API"@`showvar(Type));

	HTTPRequest = class'HttpFactory'.static.CreateRequest();
	HTTPRequest.SetURL(StatAPIURL);
	HTTPRequest.SetHeader("Content-Type", "application/json");
	HTTPRequest.SetVerb("POST");
	HTTPRequest.SetContentAsString(Payload);
	HTTPRequest.OnProcessRequestComplete = OnComplete;
	HTTPRequest.ProcessRequest();
}	

function OnComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface InHttpResponse, bool bDidSucceed)
{
	local JsonObject Response;

	if (!bDidSucceed)
	{
		`log("Post to Stat API failed."@`showvar(StatAPIURL));
		return;
	}

	if (InHttpResponse != None && InHttpResponse.GetResponseCode() == `HTTP_STATUS_OK)
	{
		Response = new class'JsonObject';
		Response = class'JsonObject'.static.DecodeJson(InHttpResponse.GetContentAsString());
	}

	if (Response != None && InHttpResponse.GetResponseCode() == `HTTP_STATUS_OK && Response.GetObject("data").HasKey("gameID"))
	{
		gameId = Response.GetObject("data").GetStringValue("gameID");
		`log("API Game ID:"@gameID);
	}
}
