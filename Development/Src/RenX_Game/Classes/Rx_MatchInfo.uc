/** Class for managing clan wars matches. Persistent across map changes in order to support series. */
class Rx_MatchInfo extends Info;

var Rx_Game Game;

// Whether the next map is a live round.
var bool bNextMapIsLive;

// Conditions for beginning a clan match are satisfied.
var bool bGoodToGo;

// Whether the current rounds is live.
var bool bLive;

// Current team that Clan0 is on.
var byte Clan0_Team;
var byte Clan1_Team;

// ID of the clans.
var int Clan0_ID;
var int Clan1_ID;

// Number of players on the server for each clan.
var int Clan0_PCount;
var int Clan1_PCount;

var Rx_ClanWarsConnection ClansServer;

struct RoundInfo
{
	var string MapName;         // Name of the map played
	var byte Clan0_Team;        // Which faction Clan 0 played as
	var byte Winner;            // Which Clan won.
	var string WinReason;       // Win reason.
	var float GDIPoints;
	var float NodPoints;
	var float MatchTime;
};

// History of matches played in this series.
var Array<RoundInfo> Series;

/** Called when the Gameinfo finishes post begin play. */
function GameInfoPostBeginPlay()
{
	if (bNextMapIsLive)
	{
		DetermineTeams();
	}
	bNextMapIsLive = false;
}

/** Decides which clan will play as which faction */
function DetermineTeams()
{
	local int i;

	// If we have already played this map in the series, make the clans play on the opposite teams of what they played last time.
	for (i=Series.Length-1; i>=0; --i)
	{
		if (Series[i].MapName == WorldInfo.GetMapName(true))
		{
			if (Series[i].Clan0_Team == Clan0_Team)
				Game.SwapTeams();
		}
	}

	// Otherwise random
	if (Rand(2) != 0)
		Game.SwapTeams();
}

function GameInfoMatchOver()
{
	local RoundInfo Round;
	Round.MapName = WorldInfo.GetMapName(true);
	Round.Clan0_Team = Clan0_Team;
	// TODO

	Series[Series.Length] = Round;

	//ClanWars.SendMatch();
}

function byte PickTeam(Rx_Controller c)
{
	if (Rx_PRI(c.PlayerReplicationInfo).ClanID == Clan0_ID)
	{
		if (Clan0_Team == 255)
		{
			// First of their clan to load
			if (Clan1_Team == TEAM_GDI)   // If Clan1 is in and on GDI, put Nod. Otherwise put GDI.
				Clan0_Team = TEAM_NOD;
			else
				Clan0_Team = TEAM_GDI;
		}
		return Clan0_Team;
	}
	else if (Rx_PRI(c.PlayerReplicationInfo).ClanID == Clan1_ID)
	{
		if (Clan1_Team == 255)
		{
			// First of their clan to load
			if (Clan0_Team == TEAM_GDI) // If Clan0 is in and on GDI, put Nod. Otherwise put GDI.
				Clan1_Team = TEAM_NOD;
			else
				Clan1_Team = TEAM_GDI;
		}
		return Clan1_Team;
	}

	`log("Shouldn't have got here :o");
	return TEAM_GDI;
}


DefaultProperties
{
	Clan0_ID=-1
	Clan1_ID=-1

	Clan0_Team=255
	Clan1_Team=255
}
