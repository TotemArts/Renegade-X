class Rx_Rcon_Command_Warn extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	local string Recipient;
	local Rx_PRI PRI;
	local string error;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	pos = InStr(parameters," ",,true);
	if (pos != -1)
	{
		Recipient = Left(parameters,pos);
		parameters = Mid(parameters, pos+1);
	}
	else
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(Recipient, error);
	if (PRI == None)
		return error;
	if (PRI.bBot)
		return "Error: Can't PM bots.";

	Rx_BroadcastHandler(`WorldInfoObject.Game.BroadcastHandler).BroadcastPM(None, Rx_Controller(PRI.Owner), parameters, 'PM_AdminWarn');
	return "";
}

function string getHelp(string parameters)
{
	return "Sends an admin message to a player." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("warn");
	Syntax="Syntax: warn Player[String] Message[String]";
}
