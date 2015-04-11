class Rx_Rcon_Command_Map extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	return string(GetPackageName());
}

function string getHelp(string parameters)
{
	return "Fetches the current map." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("map");
	triggers.Add("getmap");
	Syntax="Syntax: Map";
}