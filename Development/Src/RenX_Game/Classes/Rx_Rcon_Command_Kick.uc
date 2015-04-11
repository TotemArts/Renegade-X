class Rx_Rcon_Command_Kick extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	WorldInfo.Game.AccessControl.Kick(parameters);
	return "";
}

function string getHelp(string parameters)
{
	return "Kicks a player from the game." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("kick");
	Syntax="Syntax: Kick Player[String]";
}