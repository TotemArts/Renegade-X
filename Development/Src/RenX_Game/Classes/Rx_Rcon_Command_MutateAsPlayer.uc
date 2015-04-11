class Rx_Rcon_Command_MutateAsPlayer extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	local string Player;
	local Rx_PRI PRI;
	local string error;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	pos = InStr(parameters," ",,true);
	if (pos != -1)
	{
		Player = Left(parameters,pos);
		parameters = Mid(parameters, pos+1);
	}
	else
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(WorldInfo.Game).ParsePlayer(Player, error);
	if (PRI == None)
		return error;
	if (PlayerController(PRI.Owner) == None)
		return "Selected player not a human player.";
	
	WorldInfo.Game.Mutate(parameters, PlayerController(PRI.Owner));

	return "";
}

function string getHelp(string parameters)
{
	return "Calls Mutate() on all mutators with a player as the sender." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("mutateasplayer");
	Syntax="Syntax: MutateAsPlayer Player[String] MutateString[String]";
}