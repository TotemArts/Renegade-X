class Rx_Rcon_Command_DisarmC4 extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local string error;
	local Rx_Weapon_DeployedC4 c4;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters, error);
	
	if (PRI == None)
		return error;

	PRI.DestroyRemoteC4();
	PRI.DestroyATMines();

	if (Controller(PRI.Owner) != None)
		foreach `WorldInfoObject.AllActors(class'Rx_Weapon_DeployedC4', c4)
			if (c4.InstigatorController == Controller(PRI.Owner))
				c4.Destroy();

	return "";
}

function string getHelp(string parameters)
{
	return "Disarms all of a player's C4." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("disarmc4");
	Syntax="Syntax: DisarmC4 Player[String]";
}
