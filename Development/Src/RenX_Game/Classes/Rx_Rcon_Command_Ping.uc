class Rx_Rcon_Command_Ping extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	return "PONG" `s parameters;
}

function string getHelp(string parameters)
{
	return "Pings the server." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("ping");
	Syntax="Syntax: Ping Data[String]";
}