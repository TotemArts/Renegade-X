class Rx_Rcon_Command_HostSay extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local PlayerController P;
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	parameters = Left(parameters, 128);
	foreach WorldInfo.AllControllers(class'PlayerController', P)
		WorldInfo.Game.BroadcastHandler.BroadcastText(None, P, parameters, 'Say');

	return "";
}

function string getHelp(string parameters)
{
	return "Sends a message as the Host." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("hostsay");
	triggers.Add("say");
	Syntax="Syntax: HostSay Message[String]";
}
