class Rx_Rcon_Command_PlayerInfo extends Rx_Rcon_Command;

function string ParsePlayerTokens(string format, Rx_PRI PRI)
{
	local string r;
	local array<string> tokens;
	local int index;
	
	ParseStringIntoArray(format, tokens, `nbsp, true);
	if (tokens.Length == 0)
		return "";

	r = tokens[0] `s class'Rx_Rcon_Command_ClientVarList'.static.ParseTokenPRIi(PRI, tokens[0]);
	for (index = 1; index != tokens.Length; index++)
		r $= `nbsp $ tokens[index] `s class'Rx_Rcon_Command_ClientVarList'.static.ParseTokenPRIi(PRI, tokens[index]);
	return r;
}

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local string error;
	local int pos;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	pos = InStr(parameters," ",,true);
	if (pos != -1)
	{
		PRI = Rx_Game(WorldInfo.Game).ParsePlayer(Left(parameters, pos), error);
		if (PRI == None)
			return error;

		return ParsePlayerTokens(Locs(Mid(parameters, pos+1)), PRI);
	}
	else
	{
		PRI = Rx_Game(WorldInfo.Game).ParsePlayer(parameters, error);
		
		if (PRI == None)
			return error;

		parameters = "id" `s PRI.PlayerID `s "name" `s PRI.PlayerName `s "team" `s class'Rx_Game'.static.GetTeamName(PRI.GetTeamNum()) `s "isbot" `s PRI.bBot `s "kills" `s PRI.GetRenKills() `s "deaths" `s PRI.Deaths `s "score" `s PRI.GetRenScore() `s "credits" `s PRI.GetCredits() `s "character" `s PRI.CharClassInfo;
		if (Controller(PRI.Owner) != None)
		{
			parameters $= `nbsp $ "vehicle" `s Controller(PRI.Owner).Pawn == None ? "" : Rx_Vehicle(Controller(PRI.Owner).Pawn) == None ? "" : string(Controller(PRI.Owner).Pawn.Class.name);
			if (Rx_Controller(PRI.Owner) != None)
				parameters $= `nbsp $ "steam" `s WorldInfo.Game.OnlineSub.UniqueNetIdToString(Rx_Controller(PRI.Owner).PlayerReplicationInfo.UniqueId) `s "ip" `s Rx_Controller(PRI.Owner).GetPlayerNetworkAddress() `s "ping" `s PRI.Ping * 4;
		}
	}

	return parameters;
}

function string getHelp(string parameters)
{
	return "Gives information about a player; see PlayerVarList for a list of format tokens." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("playerinfo");
	Syntax="Syntax: PlayerInfo Player[String] Format[String]";
}
