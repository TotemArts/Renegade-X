class Rx_Rcon_Command_DumpKillLog extends Rx_Rcon_Command;

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

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(Player, error);
	if (PRI == None)
		return error;

	Rx_Controller(PRI.Owner).DumpKillLog(bool(parameters));
	return "Dumping Player's Kill log";
}

function string getHelp(string parameters)
{
	return "Dumps a player's last 5 kills. If DumpInputs is set to true, it will also dump the the last keys the player pressed" @ getSyntax();
}

DefaultProperties
{
	triggers.Add("dumpkilllog");
	triggers.Add("dumpkills");
	Syntax="Syntax: dumpkilllog Player[String] DumpInputs[bool]";
}