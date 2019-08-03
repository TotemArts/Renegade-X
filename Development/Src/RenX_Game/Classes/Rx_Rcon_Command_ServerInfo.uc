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
				ret $= Rx_Game(`WorldInfoObject.Game).GetGameProperty(parameters);
				break;
			}
			ret $= Rx_Game(`WorldInfoObject.Game).GetGameProperty(Left(parameters, pos)) $ `rcon_delim;
			parameters = Mid(parameters, pos + 1);
		}
		return ret;
	}

	// Game Version intentionally excluded from default (passed on connect).
	// Port, Name, Level, Players, Bots
	return "Port" `s Rx_Game(`WorldInfoObject.Game).Port `s "Name" `s `WorldInfoObject.GRI.ServerName `s "Level" `s string(`WorldInfoObject.GetPackageName()) `s "Players" `s `WorldInfoObject.Game.NumPlayers `s "Bots" `s `WorldInfoObject.Game.NumBots `s "LevelGUID" `s class'Rx_Game'.static.GuidToHex(`WorldInfoObject.GetPackageGuid(GetPackageName()));
}

function string getHelp(string parameters)
{
	return "Fetches some information about the server." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("serverinfo");
	triggers.Add("sinfo");
	Syntax="Syntax: ServerInfo Parameters[String]";
}