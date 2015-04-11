/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Handles updating leaderboard values for DM
 */
Class UTStatsWriteDM extends OnlineStatsWrite;

`include(UTOnlineStats.uci)


defaultproperties
{
	ViewIds=(`STATS_GROUP_LEADERBOARDS_DM)

	// Property used for leaderboard ratings
	RatingId=`LEADERBOARDS_SCORE

	// Properties and their types
	Properties.Add((PropertyId=`LEADERBOARDS_SCORE,Data=(Type=SDT_Int32,Value1=0)))
}
