class Rx_Rcon_Command_Disarm extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local string error;
	local Rx_Weapon_DeployedActor obj;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(WorldInfo.Game).ParsePlayer(parameters, error);
	
	if (PRI == None)
		return error;

	PRI.DestroyRemoteC4();
	PRI.DestroyATMines();

	if (Controller(PRI.Owner) != None)
		foreach AllActors(class'Rx_Weapon_DeployedActor', obj)
			obj.Destroy();

	return "";
}

function string getHelp(string parameters)
{
	return "Disarms all of a player's C4 and beacons." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("disarm");
	Syntax="Syntax: Disarm Player[String]";
}
