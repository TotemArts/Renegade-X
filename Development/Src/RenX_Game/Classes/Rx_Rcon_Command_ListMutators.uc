class Rx_Rcon_Command_ListMutators extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local string mutatorList;
	local Mutator M;
	
	if (Rx_Game(`WorldInfoObject.Game).BaseMutator == None)
		return "No mutators are loaded.";

	mutatorList = "The following mutators are loaded:";
	for (M = `WorldInfoObject.Game.BaseMutator; M != None; M = M.NextMutator)
		mutatorList $= `rcon_delim $ M.Class;

	return mutatorList;
}

function string getHelp(string parameters)
{
	return "Lists all of the loaded mutators." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("listmutators");
	triggers.Add("listmutator");
	triggers.Add("mutatorlist");
	triggers.Add("mutatorslist");
	Syntax="Syntax: ListMutators";
}
