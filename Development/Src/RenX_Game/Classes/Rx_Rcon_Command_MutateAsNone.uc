class Rx_Rcon_Command_MutateAsNone extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	WorldInfo.Game.Mutate(parameters, None);
	return "";
}

function string getHelp(string parameters)
{
	return "Calls Mutate() on all mutators with no sender information." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("mutateasnone");
	Syntax="Syntax: MutateAsNone MutateString[String]";
}