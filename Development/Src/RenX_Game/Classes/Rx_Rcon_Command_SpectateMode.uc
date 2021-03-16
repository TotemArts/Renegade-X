class Rx_Rcon_Command_SpectateMode extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local string error;
	local Pawn P;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters, error);
	
	if (PRI == None)
		return error;

	if (Controller(PRI.Owner) == None)
		return "Error: Player has no controller!";

	if (Controller(PRI.Owner).Pawn != None)
		P = Controller(PRI.Owner).Pawn;
	
	Controller(PRI.Owner).GoToState('Spectating');
	if (PRI.Team != None)
		PRI.Team.RemoveFromTeam(Controller(PRI.Owner));

	if (Rx_Controller(PRI.Owner) != None)
	{
		Rx_Controller(PRI.Owner).BindVehicle(None);
	}
	PRI.DestroyATMines();
	PRI.DestroyRemoteC4();

	if (P != None)
		P.KilledBy(None);

	return "";
}

function string getHelp(string parameters)
{
	return "Puts a player into spectate mode." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("spectatemode");
	triggers.Add("smode");
	Syntax="Syntax: SpectateMode Player[String]";
}
