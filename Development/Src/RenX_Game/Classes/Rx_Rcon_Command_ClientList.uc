class Rx_Rcon_Command_ClientList extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Array<string> List;
	local string s, full;

	List = Rx_Game(WorldInfo.Game).BuildClientList(`nbsp);
	full = "PlayerID"`s"IP"`s"SteamID"`s"AdminStatus"`s"Team"`s"Name";
	foreach List(s)
		full $= "\n"$s;

	return full;
}

function string getHelp(string parameters)
{
	return "Lists all of the players in-game." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("clientlist");
	Syntax="Syntax: ClientList";
}
