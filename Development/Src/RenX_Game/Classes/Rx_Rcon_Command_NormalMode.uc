class Rx_Rcon_Command_NormalMode extends Rx_Rcon_Command;

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

	if (Controller(PRI.Owner).Pawn != None)
		Controller(PRI.Owner).Pawn.KilledBy(None);
	
	Controller(PRI.Owner).Reset();
	if (Rx_Game(`WorldInfoObject.Game).Teams[1].Size >= Rx_Game(`WorldInfoObject.Game).Teams[0].Size)
		Rx_Game(`WorldInfoObject.Game).Teams[0].AddToTeam(Controller(PRI.Owner));
	else
		Rx_Game(`WorldInfoObject.Game).Teams[1].AddToTeam(Controller(PRI.Owner));
	Controller(PRI.Owner).GotoState('Dead');

	return "";
}

function string getHelp(string parameters)
{
	return "Puts a player into normal game playing mode." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("normalmode");
	triggers.Add("nmode");
	Syntax="Syntax: NormalMode Player[String]";
}
