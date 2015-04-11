/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Handles reading leaderboard information
 */
Class UTLeaderboardRead extends OnlineStatsRead;

`include(UTOnlineStats.uci)

// NOTE: ViewId is setup automatically based on the gametypes OnlineStatsWrite objects ViewIds array

final function int GetScore(UniqueNetId Player)
{
	local int ReturnVal;

	GetIntStatValueForPlayer(Player, `LEADERBOARDS_SCORE, ReturnVal);

	return ReturnVal;
}


defaultproperties
{
	ViewName="Leaderboard"

	// Column names
	ColumnIds.Add(`LEADERBOARDS_SCORE);

	// Column metadata
	ColumnMappings.Add((Id=`LEADERBOARDS_SCORE,Name="LeaderboardScore"))
}


