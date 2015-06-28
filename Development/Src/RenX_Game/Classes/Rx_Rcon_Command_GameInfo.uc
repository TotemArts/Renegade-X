class Rx_Rcon_Command_GameInfo extends Rx_Rcon_Command;

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

	// Limits, booleans, others
	// PlayerLimit, VehicleLimit, MineLimit, TimeLimit, bSteamRequired, bPrivateMessageTeamOnly, bAllowPrivateMessaging, bAutoBalanceTeams, bSpawnCrates, CrateRespawnAfterPickup
	return "PlayerLimit" `s WorldInfo.Game.MaxPlayers `s "VehicleLimit" `s Rx_Game(WorldInfo.Game).VehicleLimit `s "MineLimit" `s Rx_Game(WorldInfo.Game).MineLimit `s "TimeLimit" `s WorldInfo.Game.TimeLimit `s "bPassworded" `s WorldInfo.Game.AccessControl.RequiresPassword() `s "bSteamRequired" `s Rx_AccessControl(WorldInfo.Game.AccessControl).bRequireSteam `s "bPrivateMessageTeamOnly" `s Rx_Game(WorldInfo.Game).bPrivateMessageTeamOnly `s "bAllowPrivateMessaging" `s Rx_Game(WorldInfo.Game).bAllowPrivateMessaging `s "bAutoBalanceTeams" `s Rx_Game(WorldInfo.Game).bAutoShuffleOnNewRound `s "bSpawnCrates" `s Rx_Game(WorldInfo.Game).SpawnCrates `s "CrateRespawnAfterPickup" `s Rx_Game(WorldInfo.Game).CrateRespawnAfterPickup;
}

function string getHelp(string parameters)
{
	return "Fetches some information out the game in progress." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("gameinfo");
	triggers.Add("ginfo");
	Syntax="Syntax: GameInfo Parameters[String]";
}