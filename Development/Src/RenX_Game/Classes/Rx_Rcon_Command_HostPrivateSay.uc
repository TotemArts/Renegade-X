class Rx_Rcon_Command_HostPrivateSay extends Rx_Rcon_Command;

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

	PRI = Rx_Game(WorldInfo.Game).ParsePlayer(Recipient, error);
	if (PRI == None)
		return error;
	if (PRI.bBot)
		return "Can't PM bots.";
	Rx_BroadcastHandler(WorldInfo.Game.BroadcastHandler).BroadcastPM(None, Rx_Controller(PRI.Owner), parameters);
	return "";
}

function string getHelp(string parameters)
{
	return "Sends a private message to a player as Host." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("hostprivatesay");
	triggers.Add("page");
	Syntax="Syntax: HostPrivateSay Recipient[String] Message[String]";
}