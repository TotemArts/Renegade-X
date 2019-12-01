class Rx_Rcon_Command_BotVarList extends Rx_Rcon_Command;

function string getAdminStatus(Rx_PRI PRI)
{
	if (PRI.bModeratorOnly)
		return "Mod";
	if (PRI.bAdmin)
		return "Admin";
	return "None";
}

function string trigger(string parameters)
{
	local Rx_Bot C;
	local int index;
	local Array<string> format;
	local string token;

	ParseStringIntoArray(Caps(parameters), format, " ", true);

	if (format.Length == 0)
	{
		parameters = "Team,PlayerID,Name";
		foreach `WorldInfoObject.AllControllers(class'Rx_Bot', C)
			parameters $= "\n" $ `PlayerLog(C.PlayerReplicationInfo);

		return parameters;
	}

	parameters = format[0];
	for (index = 1; index != format.Length; ++index)
		parameters $= `rcon_delim $ format[index];

	foreach `WorldInfoObject.AllControllers(class'Rx_Bot', C)
	{
		if(Rx_Bot_Scripted(C) != None || Rx_PRI(C.PlayerReplicationInfo) == None)
			continue;	// do not log non player bots

		parameters $= "\n";
		index = 0;
loop_do:
		// Has to be casted to a string first due to an unreal bug.
		token = format[index];
		switch (token)
		{
		case "PLAYERLOG":
			parameters $= `PlayerLog(C.PlayerReplicationInfo);
			break;
		case "KILLS":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).GetRenKills();
			break;
		case "PLAYERKILLS":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).GetRenPlayerKills();
			break;
		case "BOTKILLS":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).GetRenKills() - Rx_PRI(C.PlayerReplicationInfo).GetRenPlayerKills();
			break;
		case "DEATHS":
			parameters $= C.PlayerReplicationInfo.Deaths;
			break;
		case "SCORE":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).GetRenScore();
			break;
		case "CREDITS":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).GetCredits();
			break;
		case "CHARACTER":
			if (C.Pawn != None)
				parameters $= UTPlayerReplicationInfo(C.PlayerReplicationInfo).CharClassInfo;
			break;
		case "VEHICLE":
			if (C.Pawn != None && Rx_Vehicle(C.Pawn) != None)
				parameters $= C.Pawn.Class.name;
			break;
		case "SPY":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).IsSpy();
			break;
		case "REMOTEC4":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).RemoteC4.Length;
			break;
		case "ATMINE":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).ATMines.Length;
			break;
		case "KDR":
			parameters $= Rx_PRI(C.PlayerReplicationInfo).GetKDRatio();
			break;
		case "ID":
			parameters $= C.PlayerReplicationInfo.PlayerID;
			break;
		case "NAME":
			parameters $= C.PlayerReplicationInfo.PlayerName;
			break;
		case "TEAM":
			parameters $= class'Rx_Game'.static.GetTeamName(C.PlayerReplicationInfo.Team.GetTeamNum());
			break;
		case "TEAMNUM":
			parameters $= C.PlayerReplicationInfo.Team.GetTeamNum();
			break;
		default:
			parameters $= "ERR_UNKNOWNVAR \"" $ format[index] $ "\"";
			break;
		}

		// loop_while
		if (++index != format.Length)
		{
			parameters $= `rcon_delim;
			goto loop_do;
		}
	}
	return parameters;
}

function string getHelp(string parameters)
{
	parameters = Caps(parameters);
	switch (parameters)
	{
	case "TOKENS":
		return "PlayerLog" `s "Kills" `s "PlayerKills" `s "BotKills" `s "Deaths" `s "Score" `s "Credits" `s "Character" `s "Vehicle" `s "Spy" `s "RemoteC4" `s "ATMine" `s "KDR" `s "ID" `s "Name" `s "Team" `s "TeamNum";
	case "PLAYERLOG":
		return "Player log information. (Format: Team,ID,Name)";
	case "KILLS":
		return "Total number of kills";
	case "PLAYERKILLS":
		return "Number of player kills";
	case "BOTKILLS":
		return "Number of bot kills";
	case "DEATHS":
		return "Number of deaths";
	case "SCORE":
		return "Total score";
	case "CREDITS":
		return "Total credits";
	case "CHARACTER":
		return "Current character";
	case "VEHICLE":
		return "Occupied vehicle";
	case "SPY":
		return "Spy";
	case "REMOTEC4":
		return "Remote C4 count";
	case "ATMINE":
		return "Anti-Tank Mine count";
	case "KDR":
		return "Kill-Death ratio";
	case "ID":
		return "ID number";
	case "NAME":
		return "Name";
	case "TEAM":
		return "Team name";
	case "TEAMNUM":
		return "Team number";
	case "":
		return "Lists all of the bots in-game. Add \"Tokens\" after help to get a string of format tokens." @ getSyntax();
	default:
		return "Error: Invalid help token." @ getSyntax();
	}
}

DefaultProperties
{
	triggers.Add("botvarlist");
	Syntax="Syntax: BotVarList Format[String]";
}
