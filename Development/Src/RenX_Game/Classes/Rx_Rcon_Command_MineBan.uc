class Rx_Rcon_Command_MineBan extends Rx_Rcon_Command;

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
	
	if(PRI.GetMineStatus() == false)
		return "Error: Player already mine-banned";

	PRI.bCanMine = false;

	if (Rx_Controller(PRI.Owner) != None)
		Rx_Controller(PRI.Owner).CTextMessage(PRI.PlayerName @ "Has Been Banned from Mining",, 180);
	
	return "";
}

function string getHelp(string parameters)
{
	return "Bans a player from mining" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("mineban");
	triggers.Add("mban");
	Syntax="Syntax: mineban Player[String]";
}