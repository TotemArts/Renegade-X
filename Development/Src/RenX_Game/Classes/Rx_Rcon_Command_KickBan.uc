class Rx_Rcon_Command_KickBan extends Rx_Rcon_Command;

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
		Rx_AccessControl(WorldInfo.Game.AccessControl).KickBanPlayer(player, parameters);
	}
	else
	{
		player = Rx_Controller(WorldInfo.Game.AccessControl.GetControllerFromString(parameters));
		if (player == None)
			return "Error: Player not found.";
		Rx_AccessControl(WorldInfo.Game.AccessControl).KickBanPlayer(player, WorldInfo.Game.AccessControl.DefaultKickReason);
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