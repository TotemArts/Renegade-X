/** Class for running RemoteConsole. */
class Rx_Rcon extends Rx_TCPLink
	config(RenegadeX);

`include(RconProtocol.uci)

var config bool bEnableRcon;

/** TCP Port to Listen for Rcon connections on. -1 = Same as number as the UDP Game Port */
var config int RconPort;

/** The maximum amount of simultaneous subscribers allowed. 0 = No Limit - dependent on ConnectionLimit (ILL ADVISED IF ConnectionLimit IS HIGH). */
var globalconfig int SubscriberLimit;

/** Rcon Connections that are subscribed to logs. */
var Array<Rx_RconConnection> Subscribers;

var int connectionId;

function InitRcon()
{
	local int ListenPort;

	if (RconPort < 0)
		ListenPort = `GamePort;
	else
		ListenPort = RconPort;

	if (BindPort(ListenPort) > 0 && Listen());
	else
	{
		`LogRxObject("ERROR;"`s"Could not open TCP Port"@ListenPort@"- Rcon Disabled");
		Destroy();
	}
}

function CloseAll(string Message)
{
	local Rx_TCPLink connection;

	foreach Children(connection)
	{
		if (Rx_RconConnection(connection) != None && Message != "")
			Rx_RconConnection(connection).SendText(`ERROR $ Message);

		connection.Close();
	}
}

function bool Subscribe(Rx_RconConnection connection)
{
	if (Subscribers.Length >= SubscriberLimit)
		return false;

	if (Subscribers.Find(connection) == -1)
	{
		Subscribers.AddItem(connection);
		`LogRxObject("RCON"`s "Subscribed;" `s connection.ConnectionID);
	}

	return true;
}

function UnSubscribe(Rx_RconConnection connection, optional bool isDisconnect=false)
{
	if (Subscribers.Find(connection) != -1)
	{
		Subscribers.RemoveItem(connection);
		if (!isDisconnect)
			`LogRxObject("RCON"`s "Unsubscribed;" `s connection.ConnectionID );
	}
}

function SendLog(string Text)
{
	local Rx_RconConnection r;
	foreach Subscribers(r)
		r.SendText(`LOGMSG $ Text);
}

/** 
 *  @return 0 = Success, -1 = Banned, Positive number = Saved attempts count */
function int Authenticate(string IP, string Password)
{
	if (`WorldInfoObject.Game.AccessControl.ValidLogin("",Password))
		return 0;

	return 1;
}

DefaultProperties
{
	AcceptClass=class'RenX_Game.Rx_RconConnection'
}
