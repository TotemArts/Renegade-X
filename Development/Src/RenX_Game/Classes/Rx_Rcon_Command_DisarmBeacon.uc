class Rx_Rcon_Command_DisarmBeacon extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local string error;
	local Rx_Weapon_DeployedBeacon beacon;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters, error);
	
	if (PRI == None)
		return error;

	if (Controller(PRI.Owner) != None)
		foreach `WorldInfoObject.AllActors(class'Rx_Weapon_DeployedBeacon', beacon)
			if (beacon.InstigatorController == Controller(PRI.Owner))
				beacon.Destroy();

	return "";
}

function string getHelp(string parameters)
{
	return "Disarms all of a player's beacons." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("disarmbeacon");
	triggers.Add("disarmb");
	Syntax="Syntax: DisarmBeacon Player[String]";
}
