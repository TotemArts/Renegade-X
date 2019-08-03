class Rx_Rcon_Command_BotList extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_Bot C;
	parameters = "Team,PlayerID,Name";
	foreach `WorldInfoObject.AllControllers(class'Rx_Bot', C)
		parameters $= "\n" $ `PlayerLog(C.PlayerReplicationInfo);

	return parameters;
}

function string getHelp(string parameters)
{
	return "Lists all of the bots in-game." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("botlist");
	Syntax="Syntax: BotList";
}
