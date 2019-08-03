/**
 * Basic HTTP 1.0 client
 * 
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class Rx_HTTPClient extends Rx_TCPLink;

enum ERequestType
{
	REQUEST_GET,
	REQUEST_POST
};

/** Request */
var ERequestType RequestType;
var string RequestResource;
var privatewrite string RequestHostname;
var array<string> RequestHeaders;

/** Response */
var int ResponseCode;
var array<byte> Response;
var int ExpectedResponseSize;
var string Header;

/** Internal */
var private bool m_ResponseStarted;
var const string HTTP_NEWLINE;

event Resolved(IpAddr Addr)
{
	`log("Rx_HTTPClient: Attempting to connect to " $ RequestHostname $ ":" $ string(Addr.Port) $ "...");
	if (Open(Addr) == false)
		`log("Rx_HTTPClient: Failed to connect.");
}

event ResolveFailed(bool forced)
{
	if (forced)
		`log("Rx_HTTPClient: DNS resolution prematurely halted");
	else
		`log("Rx_HTTPClient: Failed to resolve address");
}

event Opened()
{
	local string Request;
	local int index;

	ExpectedResponseSize = -1;

	Request = RequestTypeAsString(RequestType) $ " " $ RequestResource $ " http/1.0" $ HTTP_NEWLINE;
	Request $= "Host: " $ RequestHostname $ HTTP_NEWLINE;
	for (index = 0; index != RequestHeaders.Length; ++index)
	{
		Request $= RequestHeaders[index];
		Request $= HTTP_NEWLINE;
	}
	Request $= HTTP_NEWLINE;

	SendText(Request);
}

/** Called when the HTTP response is finished */
event ReceivedResponse();

/** Called when the HTTP request fails */
event RequestFailed();

event Closed()
{
	// Check if full response received
	if (m_ResponseStarted && (ExpectedResponseSize < 0 || Response.Length == ExpectedResponseSize))
		ReceivedResponse();
	else
		RequestFailed();
}

/** Static */

final static function string RequestTypeAsString(ERequestType In_RequestType)
{
	switch (In_RequestType)
	{
	case REQUEST_GET:
		return "GET";
	case REQUEST_POST:
		return "POST";
	default:
		return "";
	}
}

/** Internal */

function Resolve(string in_address)
{
	local int index;

	index = InStr(in_address, ":");
	if (index >= 0)
		RequestHostname = Left(in_address, index);
	else
		RequestHostname = in_address;

	Super.Resolve(in_address);
}

private final function bool IsValidHeaderChr(byte In_Data)
{
	// [32, 127]
	return In_Data >= 32 && In_Data <= 127;
}

private final function ProcessHeader()
{
	local array<string> Tokens;

	ParseStringIntoArray(Header, Tokens, " ", true);

	if (Left(Tokens[0], 5) ~= "HTTP/")
		ResponseCode = int(Tokens[1]);
	else if (Left(Header, 15) ~= "Content-Length:") // Payload size
		ExpectedResponseSize = int(Mid(Header, 15));

	Header = "";
}

event ReceivedBinary(int Count, byte B[255])
{
	local int index;
	local byte data;

	for (index = 0; index != Count; ++index)
	{
		data = B[index];

		if (m_ResponseStarted) // Response payload
		{
			Response.AddItem(data);

			if (Response.Length == ExpectedResponseSize)
				Close();
		}
		else // Headers
		{
			switch (data)
			{
			case ASC_CR:
				break;

			case ASC_NL:
				if (Len(Header) == 0) // END OF HTTP HEADERS
					m_ResponseStarted = true;
				else
					ProcessHeader();

				break;

			default:
				Header $= Chr(data);
				break;
			}
		}
	}
}

DefaultProperties
{
	RequestType = REQUEST_GET;

	LinkMode = MODE_Binary
	HTTP_NEWLINE = "\r\n"
}
