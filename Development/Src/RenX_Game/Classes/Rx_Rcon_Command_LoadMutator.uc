class Rx_Rcon_Command_LoadMutator extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	else
	{
		WorldInfo.Game.AddMutator(parameters);
		return "Mutator loaded; please see the log files for any errors.";
	}
}

function string getHelp(string parameters)
{
	return "Loads a mutator." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("loadmutator");
	triggers.Add("mutatorload");
	Syntax="Syntax: LoadMutator Mutator[String]";
}
