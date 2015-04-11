class GeminiLinkClient extends TcpLink;

var string TargetHost;
var int TargetPort;

/* A reference to the online service, which is the only class this class actually
 * communicates with. In this way GeminiOnlineService serves as a middleman...the
 * only way for data to get from Game <--> Gemini is through it.
 */
var GeminiOnlineService ServiceBrowser;

// The page on the TargetHost site to resolve to, and the data to send.
var string webpage, message;

// True if a POST, false if a GET.
var bool bPost;

// Whether to notify ServiceBrowser upon transmission completion.
var bool bNotifyOnComplete;

// To avoid multiple TCP connections from overriding each other.
var bool bIsBusy;

//function Initialize(GeminiOnlineService GOS, optional string THost = "geminionlinegs.appspot.com", optional int TPort = 80)
//function Initialize(GeminiOnlineService GOS, optional string THost = "localhost", optional int TPort = 8080)
function Initialize(GeminiOnlineService GOS, optional string THost = "renegadexgs.appspot.com", optional int TPort = 80)
{
	TargetHost = THost;
	TargetPort = TPort;
	//TargetPort = 8080;
	ServiceBrowser = GOS;
	
}

/* Begin the transmission process. You must specify whether this is a POST, whether to
 * notify upon transmission end, what webpage to send the data, and what data to send.
 * If no data is specified, the null string "" will be sent.
 */
function TransmitData(bool bPostData, bool bNotify, string page, optional string data)
{
	bIsBusy = true;
	webpage = page;
	message = data;
	bNotifyOnComplete = bNotify;
	bPost = bPostData;
	`log("[GeminiLinkClient] Resolving: " $ TargetHost);
	Resolve(TargetHost);
}

event Resolved(IpAddr Addr)
{
	`log("[GeminiLinkClient] " $ TargetHost $ " resolved to " $ IpAddrToString(Addr));
	Addr.Port = TargetPort;
	`log("[GeminiLinkClient] Bound to port: " $ BindPort());
	if(!Open(Addr))
		`log("[GeminiLinkClient] Open failed");
}

event ResolveFailed()
{
	`log("[GeminiLinkClient] Unable to resolve " $ TargetHost);
	// You could retry resolving here if you have an alternative remote host.
}

event Opened()
{
	`log("[GeminiLinkClient] TCP connection opened");
	if(bPost)
	{
		SendText("POST " $ webpage $ " HTTP/1.0" $ chr(13)$chr(10));
		SendText("Host: " $ TargetHost $ chr(13)$chr(10));
		SendText("User-Agent: GeminiLinkClient/1.0" $ chr(13)$chr(10));
		SendText("Content-Type: application/x-www-form-urlencoded" $ chr(13)$chr(10));
		SendText("Content-Length: " $ Len(message) $ chr(13)$chr(10));
		SendText(chr(13)$chr(10));
		SendText(message $ chr(13)$chr(10));
	}
	else
	{
		SendText("GET " $ webpage $ message $ " HTTP/1.0" $ chr(13)$chr(10));
		SendText("Host: " $ TargetHost $ chr(13)$chr(10));
		SendText(chr(13)$chr(10));
	}
	SendText(chr(13)$chr(10));
	SendText(chr(13)$chr(10));
	`log("[GeminiLinkClient] End TCP connection");
}

event Closed()
{
	`log("[GeminiLinkClient] TCP connection closed");
	// Connection closed, so we are not busy any more.
	bIsBusy = false;
	if(bNotifyOnComplete)
		ServiceBrowser.OnConnectionCompleted(message);
	ServiceBrowser.RetryPost();
}

event ReceivedText(string Text)
{
	// If this is a get request.
	if(!bPost)
	{
		ServiceBrowser.HandleGetResponse(webpage, Text);
	}
}

defaultproperties
{
	bIsBusy = false;
}
