class Rx_Rcon_Command_ForceNonSeamless extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	Rx_Game(`WorldInfoObject.Game).bForceNonSeamless=true;
	return "";
}

function string getHelp(string parameters)
{
	return "Forces the server to use non-seamless travel when the game ends." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("forcenonseamless");
	Syntax="Syntax: ForceNonSeamless";
}