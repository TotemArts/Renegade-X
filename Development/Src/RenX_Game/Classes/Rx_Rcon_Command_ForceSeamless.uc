class Rx_Rcon_Command_ForceSeamless extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	Rx_Game(WorldInfo.Game).bForceNonSeamless=false;
	return "";
}

function string getHelp(string parameters)
{
	return "Un-Forces the server to use non-seamless travel when the game is over." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("forceseamless");
	Syntax="Syntax: ForceSeamless";
}