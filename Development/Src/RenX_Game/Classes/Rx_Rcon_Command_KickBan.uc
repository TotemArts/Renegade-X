class Rx_Rcon_Command_KickBan extends Rx_Rcon_Command;

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
		Rx_AccessControl(WorldInfo.Game.AccessControl).KickBanPlayer(PlayerController(player), parameters);
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

		Rx_AccessControl(WorldInfo.Game.AccessControl).KickBanPlayer(PlayerController(player), WorldInfo.Game.AccessControl.DefaultKickReason);
	}

	return "";
}

function string getHelp(string parameters)
{
	return "Kicks and bans a player from the game." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("kickban");
	Syntax="Syntax: KickBan Player[String] Reason[String]";
}