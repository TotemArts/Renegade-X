class Rx_LANBroadcast extends Rx_UDPLink
	config(RenegadeX);

var int probePort;
var int LastBroadcastTick;
var bool LookingForServer;
var JsonObject ServerData;
var InternetLink iL;
var string strServerInfo;
var string ipaddress;

// ReceivedLine: Called when data is received and connection mode is MODE_Line.
// \r\n is stripped from the line
event ReceivedLine(string inLine)
{
	local JsonObject ParsedJson;

	`Entry(,'DevNetTraffic');

	ParsedJson = class'JsonObject'.static.DecodeJson(inLine);
	if(ParsedJson != none)
	{
		If(`RxGameObject.ProcessNewServerInfo(ParsedJson, true))
			`RxGameObject.NotifyServerListUpdate();
	}
	else
		`Log(`Location@"Failed to parse Json");
}

function Start(bool isServer)
{
	local IpAddr addr;
	
	local int i;

	`log("Rx_LANBroadcast: Binding on port:" @ probePort,,'DevNet');

	il = `RxGameObject.spawn(class'InternetLink');

	il.GetLocalIP(addr);
	ipaddress = il.IpAddrToString(addr);
	//ipaddresstostring returns port aswell, need to get just ip.
	i = InStr(ipaddress, ":");
		if(i != -1)
			ipaddress = Left(ipaddress, i);

	`log("Rx_LANBroadcast: Local IP:" @ ipaddress,,'DevNet');

	if(isServer)
		BuildServerInfo();

	if(SocketState != STATE_Open)
	{
		if(isServer)
			BindPort(ipaddress, probePort+1, false);
		else
			BindPort(ipaddress, probePort, false);
	}

	EnableBroadcast();
}

function SendBroadcast()
{	
	`Logd("Rx_LANBroadcast: Sending:" @ strServerInfo,,'DevNetTraffic');

	if(SocketState == STATE_Open)
		SendText(strServerInfo, probePort, "255.255.255.255");
	else
		`Log("Rx_LANBroadcast: Socket not open");

}

function buildServerInfo()
{
	local JsonObject ServerMoreData;

	ServerData = new class'JsonObject';
	ServerMoreData = new class'JsonObject';
	
	ServerData.SetStringValue("Current Map", string(`WorldInfoObject.GetPackageName()));
	ServerData.SetIntValue("Players", `WorldInfoObject.Game.NumPlayers);
	ServerData.SetIntValue("Port", Rx_Game(`WorldInfoObject.Game).Port);
	ServerData.SetStringValue("Name", `WorldInfoObject.GRI.ServerName);
	ServerData.SetStringValue("IP", ipaddress);
	ServerData.SetStringValue("Game Version", `RxGameObject.GameVersion);

	ServerData.SetObject("Variables", ServerMoreData);
	
	ServerMoreData.SetIntValue("Player Limit", `WorldInfoObject.Game.MaxPlayers);
	ServerMoreData.SetIntValue("Vehicle Limit", `RxGameObject.VehicleLimit);
	ServerMoreData.SetIntValue("Mine Limit", `RxGameObject.MineLimit);
	ServerMoreData.SetIntValue("Time Limit", `WorldInfoObject.Game.TimeLimit);
	ServerMoreData.SetBoolValue("bPassworded", `WorldInfoObject.Game.AccessControl.RequiresPassword());
	ServerMoreData.SetBoolValue("bSteamRequired", Rx_AccessControl(`WorldInfoObject.Game.AccessControl).bRequireSteam);
	ServerMoreData.SetIntValue("Team Mode", `RxGameObject.TeamMode);
	ServerMoreData.SetBoolValue("bSpawnCrates", `RxGameObject.SpawnCrates);
	ServerMoreData.SetIntValue("Game Type", `RxGameObject.GameType);
	ServerMoreData.SetBoolValue("bRanked", false);

	strServerInfo = class'JsonObject'.static.EncodeJson(ServerData);
}

DefaultProperties
{
	probePort = 45542;
	LinkMode = MODE_Line;
	InLineMode = LMODE_UNIX;
	OutLineMode = LMODE_UNIX;
}
