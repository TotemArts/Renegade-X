/** Child class spawned from Rx_Rcon to handle a connection. */
class Rx_RconConnection extends Rx_TCPLink;

`include(RconProtocol.uci)

`define SendError(ErrorMsg) SendText(`ERROR$`ErrorMsg)

/** Has the client logged in with a valid password yet. */
var bool bAuthd;

var bool bForceDisconnect;

/** Rcon object that spawned us. */
var Rx_Rcon Rcon;

/** IP Address this Rcon Connection is coming from in string form for logging. */
var string ConnectionID;

var bool TimeoutPending;
var float TimeoutTimeRemaining;

event Accepted()
{
	Rcon = Rx_Rcon(Parent);
	ConnectionID = "Conn" $ ++Rcon.connectionId;

	`LogRxObject("RCON"`s "Connected;" `s ConnectionID);

	SendText(`VERSION $ `ProtocolVersion `s `RxGameObject.GameVersionNumber `s `RxGameObject.GameVersion);
}

event ReceivedLine( string Text )
{
	local string type;
	local int authResult;
	local string temp;

	type = `PacketType(Text);
	
	if (type == `AUTH)
	{
		authResult = Rcon.Authenticate(ConnectionID, `PacketContent(Text));
		if (authResult == 0)
		{
			`LogRxObject("RCON"`s "Authenticated;" `s ConnectionID);
			TimeoutPending = false;
			bAuthd = true;
			SendText(`AUTH $ ConnectionID);
		}
		else
		{
			`LogRxObject("RCON"`s "InvalidPassword;" `s ConnectionID);
			TimeoutTimeRemaining = 10;
			`SendError(`Err_InvalidPass);
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
				`LogRxObject("RCON" `s "Command;"`s ConnectionID `s "executed:"`s `PacketContent(Text));
				temp = `RxEngineObject.RconCommand(`PacketContent(Text));
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

// Assumes 16-bit codepoint
static function string codepointToHex(int value)
{
	return byteToHex(value >> 8) $ byteToHex(value & 0xFF);
}

// Assumes 32-bit integer
static function string intToHex(int value)
{
	return codepointToHex(value >> 16) $ codepointToHex(value & 0xFFFF);
}

static function int hexToInt(string hex)
{
	hex = left(hex, 1);

	switch (hex)
	{
	case "0":
		return 0x00;
	case "1":
		return 0x01;
	case "2":
		return 0x02;
	case "3":
		return 0x03;
	case "4":
		return 0x04;
	case "5":
		return 0x05;
	case "6":
		return 0x06;
	case "7":
		return 0x07;
	case "8":
		return 0x08;
	case "9":
		return 0x09;
	case "A":
	case "a":
		return 0x0A;
	case "B":
	case "b":
		return 0x0B;
	case "C":
	case "c":
		return 0x0C;
	case "D":
	case "d":
		return 0x0D;
	case "E":
	case "e":
		return 0x0E;
	case "F":
	case "f":
		return 0x0F;
	default:
		return 0;
	}
}

static function string ProcessEscapeSequences(string txt)
{
	local string str;
	local int size, index, value;
	size = Len(txt);

	for (index = 0; index < size; ++index)
	{
		value = Asc(Mid(txt, index, 1));
		if (value == Asc("\\"))
		{
			value = Asc(Mid(txt, ++index, 1));

			// process escape sequence
			switch (value)
			{
			case Asc("\\"):
				str $= "\\";
				break;
			case Asc("\""):
				str $= "\"";
				break;
			case Asc("\'"):
				str $= "\'";
				break;

			case Asc("U"):
			case Asc("u"):
				value = hexToInt(Mid(txt, ++index, 1)) << 12;
				value += hexToInt(Mid(txt, ++index, 1)) << 8;
				value += hexToInt(Mid(txt, ++index, 1)) << 4;
				value += hexToInt(Mid(txt, ++index, 1));

				str $= Chr(value);
				break;

			default:
				break;
			}
		}
		else
			str $= Chr(value);
	}

	return str;
}

event OnTick(float DeltaTime)
{
	if (SocketState == STATE_Initialized && TimeoutPending)
	{
		TimeoutTimeRemaining -= DeltaTime;
		if (TimeoutTimeRemaining <= 0.0) // time to timeout. I feel dirty.
		{
			`LogRxObject("RCON"`s "Dropped;" `s ConnectionID `s "reason"`s"(Auth Timeout)");
			`SendError(`Err_AuthTimeout);
	
			bForceDisconnect = true;
			Close();
		}
	}
}

event Closed()
{
	Rcon.UnSubscribe(self, true);

	if (!bForceDisconnect)
		`LogRxObject("RCON"`s "Disconnected;" `s ConnectionID);

	Destroy();
}

DefaultProperties
{
	bAuthd=false
	bForceDisconnect=false
	TimeoutPending = true;
	TimeoutTimeRemaining = 10;

	LinkMode = MODE_Line
	InLineMode = LMODE_UNIX
	OutLineMode = LMODE_UNIX
}
