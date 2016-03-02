class Rx_Mutator extends UTMutator
	abstract;

/** Gets the next Rx_Mutator in the list (required for Rx_Mutator specific hooks) */
function Rx_Mutator GetNextRxMutator()
{
	local Mutator M;

	for (M = NextMutator; M != None; M = M.NextMutator)
	{
		if (Rx_Mutator(M) != None)
			return Rx_Mutator(M);
	}

	return None;
}

function String GetAdditionalServersettings();
function InitRconCommands();