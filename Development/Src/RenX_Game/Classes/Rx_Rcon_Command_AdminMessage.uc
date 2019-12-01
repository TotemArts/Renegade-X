class Rx_Rcon_Command_AdminMessage extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	parameters = Left(parameters, 128);
	`WorldInfoObject.Game.BroadcastHandler.Broadcast(None, parameters, 'AdminMsg');

	return "";
}

function string getHelp(string parameters)
{
	return "Sends an admin message to all players." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("amsg");
	Syntax="Syntax: amsg Message[String]";
}
