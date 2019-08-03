class Rx_Rcon_Command_Map extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	return string(`WorldInfoObject.GetPackageName()) `s class'Rx_Game'.static.GuidToHex(`WorldInfoObject.GetPackageGuid(`WorldInfoObject.GetPackageName()));
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