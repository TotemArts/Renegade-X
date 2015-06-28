class Rx_Rcon_Command_ForceKick extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	local Rx_Controller player;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	pos = InStr(parameters," ",,true);
	if (pos != -1)
	{
		player = Rx_Controller(WorldInfo.Game.AccessControl.GetControllerFromString(Left(parameters,pos)));
		if (player == None)
			return "Error: Player not found.";
		parameters = Mid(parameters, pos+1);
		WorldInfo.Game.AccessControl.ForceKickPlayer(player, parameters);
	}
	else
	{
		player = Rx_Controller(WorldInfo.Game.AccessControl.GetControllerFromString(parameters));
		if (player == None)
			return "Error: Player not found.";
		WorldInfo.Game.AccessControl.ForceKickPlayer(player, WorldInfo.Game.AccessControl.DefaultKickReason);
	}

	return "";
}

function string getHelp(string parameters)
{
	return "Forcefully kicks a player (including administrators) from the game. \"Reason\" is not prepended with an explanatory message." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("fkick");
	triggers.Add("forcekick");
	Syntax="Syntax: FKick Player[String] Reason[String]";
}