class Rx_Rcon_Command_TeamInfo extends Rx_Rcon_Command;

function string ProcessToken(int TeamIndex, string token)
{
	local Rx_TeamInfo team;
	team = Rx_TeamInfo(Rx_Game(`WorldInfoObject.Game).Teams[TeamIndex]);
	token = Caps(token);

	switch (token)
	{
	case "SCORE":
		return string(team.GetRenScore());
	case "KILLS":
		return string(team.GetKills());
	case "DEATHS":
		return string(team.GetDeaths());
	case "MINECOUNT":
		return string(team.mineCount);
	case "MINELIMIT":
		return string(team.mineLimit);
	case "VEHICLECOUNT":
		return string(team.vehicleCount);
	case "VEHICLELIMIT":
		return string(team.VehicleLimit);
	case "NAME":
		return team.GetHumanReadableName();
	case "COLOR":
		return string(team.GetTeamColor().R) $ "," $ string(team.GetTeamColor().G) $ "," $ string(team.GetTeamColor().B) $ "," $ string(team.GetTeamColor().A);
	case "":
		return "";
	default:
		return "ERR_UNKNOWNVAR";
	}
}

function string GetTeamInfo(int TeamIndex)
{
	local Rx_TeamInfo team;
	team = Rx_TeamInfo(Rx_Game(`WorldInfoObject.Game).Teams[TeamIndex]);

	return team.GetHumanReadableName() `s team.GetRenScore() `s team.GetKills() `s team.GetDeaths() `s team.mineCount `s team.mineLimit `s team.vehicleCount `s team.vehicleLimit;
}

function string trigger(string parameters)
{
	local int pos, num;
	local string ret, NumToken, token;

	if (parameters == "")
	{
		num = ArrayCount(UTTeamGame(`WorldInfoObject.Game).Teams);
		ret = "0" `s GetTeamInfo(0);

		pos = 1;
		while (pos != num)
		{
			ret $= "\n" $ string(pos) `s GetTeamInfo(pos);
			++pos;
		}

		return ret;
	}

	pos = InStr(parameters," ",,true);

	if (pos == -1)
	{
		if (parameters ~= "gdi")
			num = TEAM_GDI;
		else if (parameters ~= "nod")
			num = TEAM_NOD;
		else
			num = int(parameters);

		if (num < 0 || num >= ArrayCount(UTTeamGame(`WorldInfoObject.Game).Teams))
			return "Error: Invalid Team";

		return GetTeamInfo(int(parameters));
	}

	NumToken = Left(parameters, pos);
	if (NumToken ~= "gdi")
		num = TEAM_GDI;
	else if (NumToken ~= "nod")
		num = TEAM_NOD;
	else
		num = int(NumToken);

	if (num < 0 || num >= ArrayCount(UTTeamGame(`WorldInfoObject.Game).Teams))
		return "Error: Invalid Team";

	parameters = Mid(parameters, pos + 1);
	ret = "TeamNum" `s num;
	while (true)
	{
		pos = InStr(parameters," ",,true);
		if (pos == -1)
		{
			ret $= `rcon_delim $ parameters `s ProcessToken(num, parameters);
			return ret;
		}

		token = Left(parameters, pos);
		ret $= `rcon_delim $ token `s ProcessToken(num, token);
		parameters = Mid(parameters, pos + 1);
	}
	return ret;
}

function string getHelp(string parameters)
{
	switch (Caps(parameters))
	{
	case "":
		return "Fetches some information about a team. Add \"Tokens\" after help to get a string of format tokens." @ getSyntax();
	case "TOKENS":
		return "Score" `s "Kills" `s "Deaths" `s "MineCount" `s "MineLimit" `s "VehicleCount" `s "VehicleLimit" `s "Name" `s "Color";
	case "SCORE":
		return "Total score";
	case "KILLS":
		return "Total number of kills";
	case "DEATHS":
		return "Total number of deaths";
	case "MINECOUNT":
		return "Total proximity mines currently deployed";
	case "MINELIMIT":
		return "Maximum number of proximity mines that can be simultaneously deployed";
	case "VEHICLECOUNT":
		return "Total number of vehicles";
	case "VEHICLELIMIT":
		return "Maximum number of vehicles that a team can own at a given moment";
	case "NAME":
		return "Name";
	case "COLOR":
		return "Color (r,g,b,a)";
	default:
		return "Unknown token";
	}
}

DefaultProperties
{
	triggers.Add("teaminfo");
	triggers.Add("tinfo");
	Syntax="Syntax: TeamInfo TeamNum[Int] Parameters[String]";
}