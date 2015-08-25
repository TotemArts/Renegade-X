class Rx_Rcon_Command_TeamInfo extends Rx_Rcon_Command;

function string ProcessToken(int TeamNumber, string token)
{
	local Rx_TeamInfo team;
	team = Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[TeamNumber]);
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

function string trigger(string parameters)
{
	local int pos, num;
	local string ret, NumToken, token;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	pos = InStr(parameters," ",,true);

	if (pos == -1)
		return "Error: Too few parameters." @ getSyntax();

	NumToken = Left(parameters, pos);
	if (NumToken ~= "gdi")
		num = TEAM_GDI;
	else if (NumToken ~= "nod")
		num = TEAM_NOD;
	else
		num = int(NumToken);

	if (num < 0 || num >= ArrayCount(UTTeamGame(WorldInfo.Game).Teams))
		return "Error: Invalid Team";

	parameters = Mid(parameters, pos + 1);
	ret = "TeamNum" `s num;
	while (true)
	{
		pos = InStr(parameters," ",,true);
		if (pos == -1)
		{
			ret $= `nbsp $ parameters `s ProcessToken(num, parameters);
			return ret;
		}

		token = Left(parameters, pos);
		ret $= `nbsp $ token `s ProcessToken(num, token);
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