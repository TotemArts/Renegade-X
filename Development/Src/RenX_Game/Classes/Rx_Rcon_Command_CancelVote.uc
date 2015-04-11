class Rx_Rcon_Command_CancelVote extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	parameters = Caps(parameters);
	switch(parameters)
	{
	case "-1":
	case "GLOBAL":
		if (Rx_Game(WorldInfo.Game).GlobalVote != None)
		{
			`LogRx("VOTE" `s "Cancelled;" `s "Global" `s Rx_Game(WorldInfo.Game).GlobalVote.Class);
			Rx_Game(WorldInfo.Game).DestroyVote(Rx_Game(WorldInfo.Game).GlobalVote);
			return "";
		}
		else
			return "No Global Vote in progress";
	case "0":
	case "GDI":
		if (Rx_Game(WorldInfo.Game).GDIVote != None)
		{
			`LogRx("VOTE" `s "Cancelled;" `s "GDI" `s Rx_Game(WorldInfo.Game).GDIVote.Class);
			Rx_Game(WorldInfo.Game).DestroyVote(Rx_Game(WorldInfo.Game).GDIVote);
			return "";
		}
		else
			return "No GDI Vote in progress";
	case "1":
	case "NOD":
		if (Rx_Game(WorldInfo.Game).NodVote != None)
		{
			`LogRx("VOTE" `s "Cancelled;" `s "Nod" `s Rx_Game(WorldInfo.Game).NodVote.Class);
			Rx_Game(WorldInfo.Game).DestroyVote(Rx_Game(WorldInfo.Game).NodVote);
			return "";
		}
		else
			return "No Nod Vote in progress";
	}
	return "Invalid parameter - accepted parameters are: 'Global', 'GDI' or 'Nod'";
}

function string getHelp(string parameters)
{
	return "Forces the current vote to cancel." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("cancelvote");
	triggers.Add("votestop");
	Syntax="Syntax: CancelVote Team[String]";
}