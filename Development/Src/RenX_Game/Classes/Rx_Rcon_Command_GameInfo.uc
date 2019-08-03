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
				ret $= `RxGameObject.GetGameProperty(parameters);
				break;
			}
			ret $= `RxGameObject.GetGameProperty(Left(parameters, pos)) $ `rcon_delim;
			parameters = Mid(parameters, pos + 1);
		}
		return ret;
	}

	// Limits, booleans, others
	// PlayerLimit, VehicleLimit, MineLimit, TimeLimit, bSteamRequired, bPrivateMessageTeamOnly, bAllowPrivateMessaging, TeamMode, bSpawnCrates, CrateRespawnAfterPickup
	return "PlayerLimit" `s `WorldInfoObject.Game.MaxPlayers `s "VehicleLimit" `s `RxGameObject.VehicleLimit `s "MineLimit" `s `RxGameObject.MineLimit `s "TimeLimit" `s `WorldInfoObject.Game.TimeLimit `s "bPassworded" `s `WorldInfoObject.Game.AccessControl.RequiresPassword() `s "bSteamRequired" `s Rx_AccessControl(`WorldInfoObject.Game.AccessControl).bRequireSteam `s "bPrivateMessageTeamOnly" `s `RxGameObject.bPrivateMessageTeamOnly `s "bAllowPrivateMessaging" `s `RxGameObject.bAllowPrivateMessaging `s "TeamMode" `s `RxGameObject.TeamMode `s "bSpawnCrates" `s `RxGameObject.SpawnCrates `s "CrateRespawnAfterPickup" `s `RxGameObject.CrateRespawnAfterPickup `s "bIsCompetitive" `s `RxGameObject.bIsCompetitive `s "MatchState" `s string(`RxGameObject.GetStateName()) `s "bBots" `s string(!`RxGameObject.bBotsDisabled) `s "GameType" `s `RxGameObject.GameType;
}

function string getHelp(string parameters)
{
	return "Fetches some information about the game in progress." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("gameinfo");
	triggers.Add("ginfo");
	Syntax="Syntax: GameInfo Parameters[String]";
}