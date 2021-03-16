class Rx_Rcon_Command_MakeAdmin extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local string error;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters, error);
	
	if (PRI == None)
		return error;

	// Target must be human
	if (PlayerController(PRI.Owner) == None)
		return "Error: Player is not human";

	// Check if they're already logged in as an admin
	if (PRI.bAdmin) {
		if (PRI.bModeratorOnly) {
			PRI.bModeratorOnly = false;
			return "";
		}

		return "Error: Player already admin";
	}

	// Mark target an admin
	PRI.bAdmin = true;
	Rx_Game(`WorldInfoObject.Game).AccessControl.AdminEntered(PlayerController(PRI.Owner));
	return "";
}

function string getHelp(string parameters)
{
	return "Gives a player admin permissions." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("makeadmin");
	Syntax="Syntax: MakeAdmin Player[String]";
}
