class Rx_Rcon_Out extends Rx_TCPLink config(RenegadeX);

`include(RconProtocol.uci)
`define SendError(ErrorMsg) SendText(`ERROR$`ErrorMsg)

var private config string Address;
var private config int Port;
var private const string ConnectionID;
var private bool subscribed;
var private int reconnect_delay;
var private bool reconnect_pending;
var private float reconnect_time_remaining;

function connect()
{
	reconnect_pending = false;
	Resolve(address);
}

event Resolved(IpAddr Addr)
{
	Addr.Port = Port;
	//`log("RCON: Bound to port: " $ BindPort());
	`log("RCON: Attempting to connect to DevBot...");
	if (Open(addr) == false)
		`log("RCON ERROR: Failed to connect.");
}

event ResolveFailed(bool forced)
{
	`log("ERROR: Failed to resolve \"" $ address $ "\"!");
}

event Opened()
{
	`log("RCON: Outgoing connection established.");
	`LogRxObject("RCON"`s "Connected;" `s ConnectionID);
	SendText(`VERSION $ `ProtocolVersion `s Rx_Game(class'Engine'.static.GetCurrentWorldInfo().Game).GameVersionNumber `s Rx_Game(class'Engine'.static.GetCurrentWorldInfo().Game).GameVersion);
}

event Closed()
{
	super.Closed();
	if (reconnect_delay >= 0)
	{
		reconnect_pending = true;
		reconnect_time_remaining = reconnect_delay;
	}
}

event OnTick(float DeltaTime)
{
	if (SocketState == STATE_Uninitialized && reconnect_pending)
	{
		reconnect_time_remaining -= DeltaTime;
		if (reconnect_time_remaining <= 0.0) // time to reconnect
			connect();
	}
}

private function string DevBotCommand(string CommandLine)
{
	local array<string> tokens;
	local string cmd;

	ParseStringIntoArray(CommandLine, tokens, " ", false);

	cmd = tokens[0];

	// Since this is devbot only stuff, I'm okay with leaving these as case-sensitive.
	switch (cmd)
	{
	case "set_dev":
		if (tokens.Length < 2)
			return "Err_TooFewParams";

		Rx_Controller(Rx_Game(class'Engine'.static.GetCurrentWorldInfo().Game).FindPlayerByID(int(tokens[1])).Owner).SetIsDev(true);
		return "";

	case "set_rank":
		if (tokens.Length < 3)
			return "Err_TooFewParams";

		Rx_Controller(Rx_Game(class'Engine'.static.GetCurrentWorldInfo().Game).FindPlayerByID(int(tokens[1])).Owner).SetRank(int(tokens[2]));
		return "";

	case "set_reconnect_delay":
		if (tokens.Length < 2)
			return "Err_TooFewParams";

		reconnect_delay = int(tokens[1]);
		return "";

	case "redirect":
		if (tokens.Length < 2)
			return "Err_TooFewParams";

		address = tokens[1];
		Close();
		connect();
		return "";
	}

	return "Non-existent DevBotCommand";
}

event ReceivedLine( string Text )
{
	local string type;
	local string temp;

	type = `PacketType(Text);
	
	if (type == `AUTH)
	{
		`LogRxObject("RCON"`s "Authenticated;" `s ConnectionID);
		SendText(`AUTH $ ConnectionID);
	}
	else
	{
		if (type == `COMMAND)
		{
			temp = `PacketContent(Text);
			SendLog("RCON" `s "Command;" `s ConnectionID `s "executed:" `s temp);
			temp = `RxEngineObject.RconCommand(temp);
			if (temp != "")
				SendMultiLine(`RESPONSE,temp);
			SendText( `COMMAND );
		}
		else if (type == `SUB)
			subscribed = true;
		else if (type == `UNSUB)
			subscribed = false;
		else if (type == "d")
		{
			temp = `PacketContent(Text);
			SendText("de" $ temp);
			temp = DevBotCommand(temp);
			if (temp != "")
				SendMultiLine("d" $ `RESPONSE, temp);
			SendText("d" $ `COMMAND);
		}
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
		if (value > 127)
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
	ConnectionID = "DevBot"
	subscribed = false
	reconnect_delay = 120;
	reconnect_pending = false;
	LinkMode = MODE_Line;
	InLineMode = LMODE_UNIX;
	OutLineMode = LMODE_UNIX;
}
