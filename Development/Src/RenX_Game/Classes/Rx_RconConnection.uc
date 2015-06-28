/** Child class spawned from Rx_Rcon to handle a connection. */
class Rx_RconConnection extends TcpLink;

`include(RconProtocol.uci)

`define SendError(ErrorMsg) SendText(`ERROR$`ErrorMsg)

`define ForceDC bForceDisconnect=true;Close()

/** Has the client logged in with a valid password yet. */
var bool bAuthd;

var bool bForceDisconnect;

/** Rcon object that spawned us. */
var Rx_Rcon Rcon;

/** IP Address this Rcon Connection is coming from in string form for logging. */
var string IPstring;

event Accepted()
{
	LinkMode = MODE_Line;
	OutLineMode = LMODE_UNIX;
	//InLineMode left as auto to deal with silly people possibly sending \n\r

	Rcon = Rx_Rcon(Owner);
	IPstring = "Conn"$++Rcon.connectionId;
	/*
	IPstring = IpAddrToString(RemoteAddr);
	IPstring = Left( IPstring, InStr(IPstring,":"));

	// Check that the IP is allowed.
	
	if ( !WorldInfo.Game.AccessControl.CheckIPPolicy(IPstring) )
	{
		`LogRx("RCON"`s "Blocked;" `s IPstring `s "(Denied by IP Policy)");
		`SendError(`Err_PolicyDenied);
		`ForceDC;
	}
	else if ( Rcon.bWhitelistOnly && !Rcon.OnWhitelist(IPstring) )
	{
		`LogRx("RCON"`s "Blocked;" `s IPstring `s "(Not on Whitelist)");
		`SendError(`Err_NotWhitelisted);
		`ForceDC;
	}*/
	//else
	//{
		`LogRx("RCON"`s "Connected;" `s IPstring);

		SendText(`VERSION$`ProtocolVersion$Rx_Game(WorldInfo.Game).GameVersion);
		SetTimer(10.0f, false, 'AuthTimeout');    // if the client doesn't auth, drop them.
	//}
}

event ReceivedLine( string Text )
{
	local string type;
	local int authResult;
	local string temp;

	type = `PacketType(Text);
	
	if (type == `AUTH)
	{
		authResult = Rcon.Authenticate(IPstring, `PacketContent(Text));
		if (authResult == 0)
		{
			`LogRx("RCON"`s "Authenticated;" `s IPstring);
			ClearTimer('AuthTimeout');
			bAuthd = true;
			SendText(`AUTH$IPstring);
		}
		else if (authResult == -1)
		{
			`LogRx("RCON"`s "Banned;" `s IPstring `s "reason"`s "(Too many password attempts)");
			`SendError(`Err_TooManyAttempts);
			`ForceDC;
		}
		else
		{
			//`LogRx("RCON:"`s Pstring `s"invalid password"`s"(Attempt "$authResult$" of "$Rcon.MaxPasswordAttemptsActual$")");
			`LogRx("RCON"`s "InvalidPassword;" `s IPstring);
			SetTimer(10.0f, false, 'AuthTimeout');
			//if (Rcon.bHideAttempts)
				`SendError(`Err_InvalidPass);
			//else
			//	`SendError(`Err_InvalidPass$" - Attempt "$authResult$" of "$Rcon.MaxPasswordAttemptsActual);
		}
	}
	else
	{
		if (!bAuthd)
			`SendError(`Err_NotAuthd);
		else
		{
			if (type == `COMMAND)
			{
				`LogRx("RCON" `s "Command;"`s IPstring `s "executed:"`s `PacketContent(Text));
				temp = Rx_Game(WorldInfo.Game).RconCommand(`PacketContent(Text));
				if (temp != "")
					SendMultiLine(`RESPONSE,temp);
				SendText( `COMMAND );
			}
			else if (type == `SUB)
			{
				if (!Rcon.Subscribe(self))
					`SendError(`Err_TooManySubs);
			}
			else if (type == `UNSUB)
				Rcon.UnSubscribe(self);
			else
				`SendError(`Err_UnknownOperation);
		}
	}
}

/** Send message to the client, and supports the sending of multiple lines.
 *  As an optimisation: if you can guarantee the message won't contain new lines, just use SendText instead.
 *  @param Header The first characters to send (on each line).
 *  @param Content The packet content. */
function SendMultiLine(string Header, string Content)
{
	//local string Message;
	local int i;
	local array<string> Lines;
	
	ParseStringIntoArray(Content, Lines, "\n", false);
	/*for (i=0; i<Lines.Length-1; ++i)
		Message = Message$ Header$Lines[i]$"\n";
	Message = Message$ Header$Lines[i];
	SendText(Message);*/
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
			str $= "\\u" $ codepointToHex(value);
		else if (value == Asc("\\"))
			str $= "\\\\";
		else
			str $= Chr(value);
	}
	return super.SendText(str);
}

static function string quadToHex(byte in)
{
	switch (in & 0x0F)
	{
	case 0:
		return "0";
	case 1:
		return "1";
	case 2:
		return "2";
	case 3:
		return "3";
	case 4:
		return "4";
	case 5:
		return "5";
	case 6:
		return "6";
	case 7:
		return "7";
	case 8:
		return "8";
	case 9:
		return "9";
	case 10:
		return "A";
	case 11:
		return "B";
	case 12:
		return "C";
	case 13:
		return "D";
	case 14:
		return "E";
	case 15:
		return "F";
	default:
		return "";
	}
}

static function string byteToHex(byte in)
{
	return quadToHex(in >> 4) $ quadToHex(in);
}

static function string codepointToHex(int value)
{
	return byteToHex(value >> 8) $ byteToHex(value & 0xFF);
}

function AuthTimeout()
{
	`LogRx("RCON"`s "Dropped;" `s IPstring `s "reason"`s"(Auth Timeout)");
	`SendError(`Err_AuthTimeout);
	`ForceDC;
}

event Closed()
{
	Rcon.UnSubscribe(self, true);
	// Don't log disconnect message if the server caused the disconnect, as it will have already been logged (with specifics).
	if (!bForceDisconnect)
		`LogRx("RCON"`s "Disconnected;" `s IPstring);
	Destroy();
}

DefaultProperties
{
	bAuthd=false
	bForceDisconnect=false
}
