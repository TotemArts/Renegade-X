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
		if (Rx_Game(`WorldInfoObject.Game).GlobalVote != None)
		{
			`LogRxObject("VOTE" `s "Cancelled;" `s "Global" `s Rx_Game(`WorldInfoObject.Game).GlobalVote.Class);
			Rx_Game(`WorldInfoObject.Game).DestroyVote(Rx_Game(`WorldInfoObject.Game).GlobalVote);
			return "";
		}
		return "Error: No Global Vote in progress";

	case "0":
	case "GDI":
		if (Rx_Game(`WorldInfoObject.Game).GDIVote != None)
		{
			`LogRxObject("VOTE" `s "Cancelled;" `s "GDI" `s Rx_Game(`WorldInfoObject.Game).GDIVote.Class);
			Rx_Game(`WorldInfoObject.Game).DestroyVote(Rx_Game(`WorldInfoObject.Game).GDIVote);
			return "";
		}
		return "Error: No GDI Vote in progress";

	case "1":
	case "NOD":
		if (Rx_Game(`WorldInfoObject.Game).NodVote != None)
		{
			`LogRxObject("VOTE" `s "Cancelled;" `s "Nod" `s Rx_Game(`WorldInfoObject.Game).NodVote.Class);
			Rx_Game(`WorldInfoObject.Game).DestroyVote(Rx_Game(`WorldInfoObject.Game).NodVote);
			return "";
		}
		return "Error: No Nod Vote in progress";
	}
	return "Error: Invalid parameters - accepted parameters are: 'Global', 'GDI' or 'Nod'";
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