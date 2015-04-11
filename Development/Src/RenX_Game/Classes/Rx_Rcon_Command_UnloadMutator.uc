class Rx_Rcon_Command_UnloadMutator extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Mutator M;
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	else
	{
		for (M = WorldInfo.Game.BaseMutator; M != None; M = M.NextMutator)
			if (string(M.Class) ~= parameters)
			{
				WorldInfo.Game.RemoveMutator(M);
				return "Mutator unloaded; please see the log files for any errors.";
			}
		return "Error: Mutator not found." @ getSyntax();
	}
}

function string getHelp(string parameters)
{
	return "Unloads a mutator." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("removemutator");
	triggers.Add("mutatorremove");
	triggers.Add("unloadmutator");
	triggers.Add("mutatorunload");
	Syntax="Syntax: UnloadMutator Mutator[String]";
}
