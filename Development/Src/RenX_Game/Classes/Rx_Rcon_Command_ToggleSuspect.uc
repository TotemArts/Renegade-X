class Rx_Rcon_Command_ToggleSuspect extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	local string Recipient;
	local Rx_PRI PRI;
	local string error;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();
	
	pos = InStr(parameters," ",,true);
	if (pos != -1)
	{
		Recipient = Left(parameters,pos);
		parameters = Mid(parameters, pos+1);
	}
	else
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(Recipient, error);
	if (PRI == None)
		return error;
	if (PRI.bBot)
		return "Bots all hack anyway";
	Rx_Controller(PRI.Owner).ToggleSuspect();
	return "Toggled Input Logging";
}

function string getHelp(string parameters)
{
	return "Toggles pushing RCON Logging for players Kill/Input logs" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("togglesuspect");
	Syntax="Syntax: Suspect Recipient[String] true/False[BOOL]";
}