class Rx_Rcon_Command_ClientVarList extends Rx_Rcon_Command;

static function string getAdminStatus(Rx_PRI PRI)
{
	if (PRI.bModeratorOnly)
		return "Mod";
	if (PRI.bAdmin)
		return "Admin";
	return "None";
}

static function string ParseTokeni(Rx_Controller C, string token)
{
	return ParseToken(C, Caps(Token));
}

static function string ParseToken(Rx_Controller C, string token)
{
	switch (token)
	{
	case "PLAYERLOG":
		return `PlayerLog(C.PlayerReplicationInfo);
	case "KILLS":
		return string(Rx_PRI(C.PlayerReplicationInfo).GetRenKills());
	case "PLAYERKILLS":
		return string(Rx_PRI(C.PlayerReplicationInfo).GetRenPlayerKills());
	case "BOTKILLS":
		return string(Rx_PRI(C.PlayerReplicationInfo).GetRenKills() - Rx_PRI(C.PlayerReplicationInfo).GetRenPlayerKills());
	case "DEATHS":
		return string(C.PlayerReplicationInfo.Deaths);
	case "SCORE":
		return string(Rx_PRI(C.PlayerReplicationInfo).GetRenScore());
	case "CREDITS":
		return string(Rx_PRI(C.PlayerReplicationInfo).GetCredits());
	case "CHARACTER":
		return string(UTPlayerReplicationInfo(C.PlayerReplicationInfo).CharClassInfo.name);
	case "BOUNDVEHICLE":
		if (C.BoundVehicle != None)
			return string(C.BoundVehicle.Class.name);
		break;
	case "VEHICLE":
		if (C.Pawn != None && Rx_Vehicle(C.Pawn) != None)
			return string(C.Pawn.Class.name);
		break;
	case "SPY":
		return string(Rx_PRI(C.PlayerReplicationInfo).IsSpy());
	case "REMOTEC4":
		return string(Rx_PRI(C.PlayerReplicationInfo).RemoteC4.Length);
	case "ATMINE":
		return string(Rx_PRI(C.PlayerReplicationInfo).ATMines.Length);
	case "KDR":
		return string(Rx_PRI(C.PlayerReplicationInfo).GetKDRatio());
	case "PING":
		return string(C.PlayerReplicationInfo.Ping * 4);
	case "ADMIN":
		return getAdminStatus(Rx_PRI(C.PlayerReplicationInfo));
	case "STEAM":
		return `WorldInfoObject.Game.OnlineSub.UniqueNetIdToString(C.PlayerReplicationInfo.UniqueId);
	case "IP":
		return C.GetPlayerNetworkAddress();
	case "HWID":
		return C.PlayerUUID;
	case "ID":
		return string(C.PlayerReplicationInfo.PlayerID);
	case "NAME":
		return C.PlayerReplicationInfo.PlayerName;
	case "TEAM":
		return class'Rx_Game'.static.GetTeamName(C.PlayerReplicationInfo.Team.GetTeamNum());
	case "TEAMNUM":
		return string(C.PlayerReplicationInfo.Team.GetTeamNum());
	default:
		return "ERR_UNKNOWNVAR \"" $ token $ "\"";
	}
	return "";
}

static function string ParseTokenPRIi(Rx_PRI PRI, string token)
{
	return ParseTokenPRI(PRI, Caps(token));
}

static function string ParseTokenPRI(Rx_PRI PRI, string token)
{
	switch (token)
	{
	case "PLAYERLOG":
		return `PlayerLog(PRI);
	case "KILLS":
		return string(PRI.GetRenKills());
	case "PLAYERKILLS":
		return string(PRI.GetRenPlayerKills());
	case "BOTKILLS":
		return string(PRI.GetRenKills() - PRI.GetRenPlayerKills());
	case "DEATHS":
		return string(PRI.Deaths);
	case "SCORE":
		return string(PRI.GetRenScore());
	case "CREDITS":
		return string(PRI.GetCredits());
	case "CHARACTER":
		return string(PRI.CharClassInfo.name);
	case "BOUNDVEHICLE":
		if (Rx_Controller(PRI.Owner) != None && Rx_Controller(PRI.Owner).BoundVehicle != None)
			return string(Rx_Controller(PRI.Owner).BoundVehicle.Class.name);
		break;
	case "VEHICLE":
		if (Controller(PRI.Owner) != None && Controller(PRI.Owner).Pawn != None && Vehicle(Controller(PRI.Owner).Pawn) != None)
			return string(Controller(PRI.Owner).Pawn.Class.name);
		break;
	case "SPY":
		return string(PRI.IsSpy());
	case "REMOTEC4":
		return string(PRI.RemoteC4.Length);
	case "ATMINE":
		return string(PRI.ATMines.Length);
	case "KDR":
		return string(PRI.GetKDRatio());
	case "PING":
		return string(PRI.Ping * 4);
	case "ADMINSTATUS":
	case "ADMIN":
		return getAdminStatus(PRI);
	case "STEAM":
		return `WorldInfoObject.Game.OnlineSub.UniqueNetIdToString(PRI.UniqueId);
	case "IP":
		if (PlayerController(PRI.Owner) != None)
			return PlayerController(PRI.Owner).GetPlayerNetworkAddress();
	case "ID":
		return string(PRI.PlayerID);
	case "NAME":
		return PRI.PlayerName;
	case "TEAM":
		return class'Rx_Game'.static.GetTeamName(PRI.Team.GetTeamNum());
	case "TEAMNUM":
		return string(PRI.Team.GetTeamNum());
	default:
		return "ERR_UNKNOWNVAR \"" $ token $ "\"";
	}
	return "";
}

function string trigger(string parameters)
{
	local Rx_Controller C;
	local int index;
	local Array<string> format;
	ParseStringIntoArray(parameters, format, " ", true);

	if (format.Length == 0)
	{
		format = Rx_Game(`WorldInfoObject.Game).BuildClientList(`rcon_delim);
		parameters = "PlayerID"`s"IP"`s"SteamID"`s"AdminStatus"`s"Team"`s"Name";
		for (index = 0; index != format.Length; index++)
			parameters $= "\n" $ format[index];
		return parameters;
	}

	parameters = format[0];
	for (index = 1; index != format.Length; ++index)
		parameters $= `rcon_delim $ format[index];

	foreach `WorldInfoObject.AllControllers(class'Rx_Controller', C)
	{
		parameters $= "\n";

		parameters $= ParseToken(C, format[0]);
		for (index = 1; index != format.Length; ++index)
			parameters $= `rcon_delim $ ParseToken(C, format[index]);
	}

	return parameters;
}

function string getHelp(string parameters)
{
	parameters = Caps(parameters);
	switch (parameters)
	{
	case "TOKENS":
		return "PlayerLog" `s "Kills" `s "PlayerKills" `s "BotKills" `s "Deaths" `s "Score" `s "Credits" `s "Character" `s "BoundVehicle" `s "Vehicle" `s "Spy" `s "RemoteC4" `s "ATMine" `s "KDR" `s "Ping" `s "Admin" `s "Steam" `s "IP" `s "ID" `s "Name" `s "Team" `s "TeamNum";
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
	case "BOUNDVEHICLE":
		return "Bound vehicle";
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
	case "PING":
		return "Ping";
	case "ADMINSTATUS":
	case "ADMIN":
		return "Admin level";
	case "STEAM":
		return "Steam ID";
	case "IP":
		return "IP address";
	case "ID":
		return "ID number";
	case "NAME":
		return "Name";
	case "TEAM":
		return "Team name";
	case "TEAMNUM":
		return "Team number";
	case "":
		return "Lists all of the players in-game. Add \"Tokens\" after help to get a string of format tokens." @ getSyntax();
	default:
		return "Error: Invalid help token." @ getSyntax();
	}
}

DefaultProperties
{
	triggers.Add("clientvarlist");
	Syntax="Syntax: ClientVarList Format[String]";
}
