class Rx_AuthenticationServiceAcceptor extends TcpLink config(RenegadeX);


event Accepted()
{
    `log("[TcpLinkServerAcceptor] New client connected");
    // make sure the proper mode is set
    LinkMode=MODE_Line;
}

event ReceivedLine( string Line )
{
    local string str;
    `log("[TcpLinkServerAcceptor] Received line: "$line);
    //if (line ~= "close")
    str = Mid(Line,0,18);
    if(Rx_Game(WorldInfo.Game).SteamLogins.Find(str) == -1)
    {
        SendText("Client authentication failed");
        //Close();
        return;
    }
    //SendText(line);
}

event Closed()
{
    `Log("[TcpLinkServerAcceptor] Connection closed");
    // It's important to destroy the object so that the parent knows
    // about it and can handle the closed connection. You can not
    // reuse acceptor instances.
 	Destroy();
}