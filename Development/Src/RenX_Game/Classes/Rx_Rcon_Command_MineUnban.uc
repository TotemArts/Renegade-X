class Rx_Rcon_Command_MineUnban extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local color MyColor;

	MyColor = MakeColor(50,190,255,255);

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(WorldInfo.Game).ParsePlayer(parameters, parameters);
	if (PRI == None)
		return parameters;

	if (Controller(PRI.Owner) == None)
		return "Error: Player has no controller!";
	
	if(PRI.GetMineStatus() == false)
		return "Error: Player not mine-banned";

	PRI.bCanMine = true;

	if (Rx_Controller(PRI.Owner) != None)
		Rx_Controller(PRI.Owner).CTextMessage("GDI", 80, PRI.PlayerName @ "'s Mine Ban Lifted", MyColor, 255, 255, false, 1, 0.6);
	
	return "";
}

function string getHelp(string parameters)
{
	return "Unbans a player from mining" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("mineunban");
	triggers.Add("munban");
	triggers.Add("unmban");
	Syntax="Syntax: mineunban Player[String]";
}