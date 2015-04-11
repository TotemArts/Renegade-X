class Rx_Rcon_Command_Team extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local UTTeamInfo Team;
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(WorldInfo.Game).ParsePlayer(parameters, parameters);
	if (PRI == None)
		return parameters;

	if (Controller(PRI.Owner) == None)
		return "Error: Player has no controller!";

	// Hey, maybe there'll be more than 2 teams in the future. -shrugs-
	if (PRI.GetTeamNum() + 1 >= ArrayCount(Rx_Game(WorldInfo.Game).Teams))
		Team = Rx_Game(WorldInfo.Game).Teams[0];
	else
		Team = Rx_Game(WorldInfo.Game).Teams[PRI.GetTeamNum() + 1];

	Rx_Game(WorldInfo.Game).SetTeam(Controller(PRI.Owner), Team, true);
	if (Controller(PRI.Owner).Pawn != None)
		Controller(PRI.Owner).Pawn.Destroy();

	return `PlayerLog(PRI) `s "moved to team" `s class'Rx_Game'.static.GetTeamName(Team.GetTeamNum());
}

function string getHelp(string parameters)
{
	return "Changes a player's team." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("team");
	triggers.Add("changeteam");
	Syntax="Syntax: Team Player[String]";
}