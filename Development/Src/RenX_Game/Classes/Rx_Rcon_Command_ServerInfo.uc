class Rx_Rcon_Command_ServerInfo extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local int pos;
	local string ret;
	if (parameters != "")
	{
		while (true)
		{
			pos = InStr(parameters," ",,true);
			if (pos == -1)
			{
				// last word
				Rx_Game(WorldInfo.Game).GetGameProperty(parameters);
				break;
			}
			ret $= Rx_Game(WorldInfo.Game).GetGameProperty(Left(parameters, pos));
			parameters = Mid(parameters, pos + 1);
		}
		return ret;
	}

	// Game Version intentionally excluded from default (passed on connect).
	// Port, Name, Level, Players, Bots
	return "Port" `s Rx_Game(WorldInfo.Game).Port `s "Name" `s WorldInfo.GRI.ServerName `s "Level" `s string(WorldInfo.GetPackageName()) `s "Players" `s WorldInfo.Game.NumPlayers `s "Bots" `s WorldInfo.Game.NumBots;
}

function string getHelp(string parameters)
{
	return "Fetches some information out the server." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("serverinfo");
	triggers.Add("sinfo");
	Syntax="Syntax: ServerInfo Parameters[String]";
}