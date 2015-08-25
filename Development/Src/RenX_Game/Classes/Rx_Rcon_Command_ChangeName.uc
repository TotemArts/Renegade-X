class Rx_Rcon_Command_ChangeName extends Rx_Rcon_Command;

simulated function SetName(PlayerReplicationInfo PRI, string parameters)
{
	PRI.PlayerName = parameters;
}

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

	Recipient = `PlayerLog(PRI);
	SetName(PRI, parameters);
	return Recipient `s "is now" `s `PlayerLog(PRI);
}

function string getHelp(string parameters)
{
	return "Changes a player's name." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("changename");
	triggers.Add("changeplayername");
	Syntax="Syntax: ChangeName Player[String] Name[String]";
}
