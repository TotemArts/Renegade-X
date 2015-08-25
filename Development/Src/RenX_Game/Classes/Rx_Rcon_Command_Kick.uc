class Rx_Rcon_Command_Kick extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	local Controller player;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	pos = InStr(parameters," ",,true);
	if (pos != -1)
	{
		player = WorldInfo.Game.AccessControl.GetControllerFromString(Left(parameters,pos));
		if (player == None)
			return "Error: Player not found.";

		if (UTBot(player) != None)
		{
			UTGame(WorldInfo.Game).DesiredPlayerCount = WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots - 1;
			UTGame(WorldInfo.Game).KillBot(UTBot(player));
			return "";
		}
		if (PlayerController(player) == None)
			return "Error: Player not found. (Non-PlayerController returned)";

		parameters = Mid(parameters, pos+1);
		WorldInfo.Game.AccessControl.KickPlayer(PlayerController(player), parameters);
	}
	else
	{
		player = WorldInfo.Game.AccessControl.GetControllerFromString(parameters);
		if (player == None)
			return "Error: Player not found.";

		if (UTBot(player) != None)
		{
			UTGame(WorldInfo.Game).DesiredPlayerCount = WorldInfo.Game.NumPlayers + WorldInfo.Game.NumBots - 1;
			UTGame(WorldInfo.Game).KillBot(UTBot(player));
			return "";
		}
		if (PlayerController(player) == None)
			return "Error: Player not found. (Non-PlayerController returned)";

		WorldInfo.Game.AccessControl.KickPlayer(PlayerController(player), WorldInfo.Game.AccessControl.DefaultKickReason);
	}

	return "";
}

function string getHelp(string parameters)
{
	return "Kicks a player from the game." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("kick");
	Syntax="Syntax: Kick Player[String] Reason[String]";
}