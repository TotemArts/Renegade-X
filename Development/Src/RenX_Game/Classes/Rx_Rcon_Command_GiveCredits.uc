class Rx_Rcon_Command_GiveCredits extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	local string Player;
	local string error;
	local Rx_PRI PRI;
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	pos = InStr(parameters, " ");
	if (pos < 0)
		return "Error: Too few parameters." @ getSyntax();

	Player = Left(parameters,pos);
	parameters = Mid(parameters, pos+1);

	PRI = Rx_Game(WorldInfo.Game).ParsePlayer(Player, error);
	if (PRI == None)
		return error;

	PRI.AddCredits(float(parameters));
	return `PlayerLog(PRI) `s "has been given" `s float(parameters) `s "credits.";
}

function string getHelp(string parameters)
{
	return "Gives a player credits." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("givecredits");
	triggers.Add("refund");
	Syntax="Syntax: GiveCredits Player[String] Credits[Int]";
}