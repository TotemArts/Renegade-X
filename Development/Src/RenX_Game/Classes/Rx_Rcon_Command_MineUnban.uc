class Rx_Rcon_Command_MineUnban extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;


	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters, parameters);
	if (PRI == None)
		return parameters;

	if (Controller(PRI.Owner) == None)
		return "Error: Player has no controller!";
	
	if(PRI.GetMineStatus())
		return "Error: Player not mine-banned";

	PRI.bCanMine = true;

	if (Rx_Controller(PRI.Owner) != None)
		Rx_Controller(PRI.Owner).CTextMessage(PRI.PlayerName @ "'s Mine Ban Lifted",,180);
	
	return "";
}

function string getHelp(string parameters)
{
	return "Unbans a player from mining" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("mineunban");
	triggers.Add("unmineban");
	triggers.Add("munban");
	triggers.Add("unmban");
	Syntax="Syntax: mineunban Player[String]";
}