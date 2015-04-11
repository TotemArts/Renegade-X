class Rx_Rcon_Command_KickBan extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	Rx_Game(WorldInfo.Game).AccessControl.KickBan(parameters);
	return "";
}

function string getHelp(string parameters)
{
	return "Kicks a player from the game." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("kickban");
	Syntax="Syntax: KickBan Player[String]";
}