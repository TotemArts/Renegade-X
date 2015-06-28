class Rx_Rcon_Out extends TCPLink;

`include(RconProtocol.uci)
`define SendError(ErrorMsg) SendText(`ERROR$`ErrorMsg)

var const string address;
var const string IPstring;
var bool subscribed;

function connect()
{
	LinkMode = MODE_Line;
	OutLineMode = LMODE_UNIX;
	Resolve(address);
}

event Resolved(IpAddr Addr)
{
	Addr.Port = 21337;
	`log("RCON: Bound to port: " $ BindPort());
	`log("RCON: Attempting to connect to: \"" $ IpAddrToString(Addr) $ "\"...");
	if (Open(addr) == false)
		`log("RCON ERROR: Failed to connect to \"" $ IpAddrToString(Addr) $ "\"!");
	else
		`log("RCON: Outgoing connection established.");
}

event ResolveFailed()
{
	`log("ERROR: Failed to resolve \"" $ address $ "\"!");
}

event Opened()
{
	SendText(`LOGMSG $ "RCON"`s "Connected;" `s IPstring);
	SendText(`VERSION$`ProtocolVersion$Rx_Game(WorldInfo.Game).GameVersion);
}

event ReceivedLine( string Text )
{
	local string type;
	local string temp;

	type = `PacketType(Text);
	
	if (type == `AUTH)
	{
		if (`PacketContent(Text) == "RenXStatsBot")
		{
			SendText(`LOGMSG $ "RCON"`s "Authenticated;" `s IPstring);
			SendText(`AUTH$IPstring);
		}
		else
		{
			SendText(`LOGMSG $ "RCON"`s "InvalidPassword;" `s IPstring);
			`SendError(`Err_InvalidPass);
		}
	}
	else
	{
		if (type == `COMMAND)
		{
			SendText(`LOGMSG $ "RCON" `s "Command;"`s IPstring `s "executed:"`s `PacketContent(Text));
			temp = Rx_Game(WorldInfo.Game).RconCommand(`PacketContent(Text));
			if (temp != "")
				SendMultiLine(`RESPONSE,temp);
			SendText( `COMMAND );
		}
		else if (type == `SUB)
			subscribed = true;
		else if (type == `UNSUB)
			subscribed = false;
		else
			`SendError(`Err_UnknownOperation);
	}
}

function SendLog(string txt)
{
	SendText(`LOGMSG $ txt);
}

function SendMultiLine(string Header, string Content)
{
	local int i;
	local array<string> Lines;
	
	ParseStringIntoArray(Content, Lines, "\n", false);
	for (i=0; i<Lines.Length; ++i)
		SendText(Header$Lines[i]);
}

function int SendText(coerce string txt)
{
	local string str;
	local int size, index, value;
	size = Len(txt);
	for (index = 0; index != size; ++index)
	{
		value = Asc(Mid(txt, index, 1));
		if (value > 255)
			str $= "\\u" $ class'Rx_RconConnection'.static.codepointToHex(value);
		else if (value == Asc("\\"))
			str $= "\\\\";
		else
			str $= Chr(value);
	}
	return super.SendText(str);
}

DefaultProperties
{
	//address = "localhost"
	address = "devbot.jessicajames.me"
	IPString = "DevBot"
	subscribed = false
}
