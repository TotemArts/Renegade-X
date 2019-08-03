class Rx_Rcon_Command_SwapTeams extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	Rx_Game(`WorldInfoObject.Game).SwapTeams();
	return "";
}

function string getHelp(string parameters)
{
	return "Swaps the teams." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("swapteams");
	triggers.Add("teamswap");
	Syntax="Syntax: SwapTeams";
}