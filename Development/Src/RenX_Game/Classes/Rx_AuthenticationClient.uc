class Rx_AuthenticationClient extends TcpLink config(Input);

var string TargetHost;
var int TargetPort;

event PostBeginPlay()
{
    super.PostBeginPlay();
    // Start by resolving the hostname to an IP so we can connect to it
    // Note: the TcpLink modes have been set in the defaultproperties
    `Log("[TcpLinkClient] Resolving: "$TargetHost);
    resolve(TargetHost);
}

event Resolved( IpAddr Addr )
{
    // The hostname was resolved succefully
    `Log("[TcpLinkClient] "$TargetHost$" resolved to "$ IpAddrToString(Addr));
    
    // Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
    Addr.Port = TargetPort;
    
    `Log("[TcpLinkClient] Bound to port: "$ BindPort() );
    if (!Open(Addr))
    {
        `Log("[TcpLinkClient] Open failed");
    }
}

event ResolveFailed()
{
    `Log("[TcpLinkClient] Unable to resolve "$TargetHost);
    // You could retry resolving here if you have an alternative
    // remote host.
}

event Opened()
{
    // A connection was established
    `Log("[TcpLinkClient] event opened");
    `Log("[TcpLinkClient] login data");

    /**
    SendText("GET / HTTP/1.0"$chr(13)$chr(10));
    SendText("Host: "$TargetHost$chr(13)$chr(10));
    SendText("Connection: Close"$chr(13)$chr(10));
    SendText(chr(13)$chr(10));
    */
}

event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
    `Log("[TcpLinkClient] event closed");
    //ConsoleCommand("Exit",true);
    
    // After the connection was closed we could establish a new
    // connection using the same TcpLink instance.
}

event ReceivedText( string Text )
{
    // receiving some text, note that the text includes line breaks
    `Log("[TcpLinkClient] ReceivedText Client:: "$Text);
    if(InStr(Text, "Client authentication failed") > -1){
    	Close();
    	ConsoleCommand("Quit",true);
    }
}

defaultproperties
{
    //TargetHost="69.162.64.92"
    TargetHost="37.252.127.187"
    TargetPort=3742    
}
