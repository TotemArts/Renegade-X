class Rx_AuthenticationService extends TcpLink;

var int ListenPort;
var int MaxClients;
var int NumClients;

event PostBeginPlay()
{
    local int res;
    super.PostBeginPlay();
    // first bind the port you want to listen on
    res = BindPort(ListenPort, false);
    if (res == 0)
    {
        `log("[TcpLinkServer] Failed binding port "$ListenPort);
    }
    else {
        // start listening for connections
        if (Listen())
        {
            `log("[TcpLinkServer] Listening on port "$res$" for incoming connections");
        }
        else {
            `log("[TcpLinkServer] Failed listening on port "$ListenPort);
        }
    }
}

event GainedChild( Actor C )
{
    `Log("[TcpLinkServer] GainedChild");
	super.GainedChild(C);
	++NumClients;
	
	// if too many clients, stop accepting new connections
	if(MaxClients > 0 && NumClients >= MaxClients && LinkState == STATE_Listening)
	{
		`log("[TcpLinkServer] Maximum  number of clients connected, rejecting new clients");
 		Close();
	}
}

event LostChild( Actor C )
{
    `Log("[TcpLinkServer] LostChild");
	Super.LostChild(C);
	--NumClients;
	
	// Check if there is room for accepting new clients
	if(NumClients < MaxClients && LinkState != STATE_Listening)
	{
		`log("[TcpLinkServer] Listening for incoming connections");
 		Listen();
	}
}


defaultproperties
{
    ListenPort=3742
    MaxClients=100    
    AcceptClass=Class'Rx_AuthenticationServiceAcceptor'
}