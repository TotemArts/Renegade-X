class Rx_Rcon_Command_ChangeMap extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	`WorldInfoObject.ServerTravel(parameters);
}

function string getHelp(string parameters)
{
	return "Changes the map immediately." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("changemap");
	triggers.Add("setmap");
	Syntax="Syntax: ChangeMap URL[String]";
}