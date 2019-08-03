class Rx_Rcon_Command_Kill extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local string error;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters, error);
	
	if (PRI == None)
		return error;

	if (Controller(PRI.Owner) == None)
		return "Error: Player has no controller!";

	if (Controller(PRI.Owner).Pawn == None)
		return "Error: Player is not alive.";

	Controller(PRI.Owner).Pawn.KilledBy(None);

	return "";
}

function string getHelp(string parameters)
{
	return "Kills a player." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("kill");
	Syntax="Syntax: Kill Player[String]";
}
