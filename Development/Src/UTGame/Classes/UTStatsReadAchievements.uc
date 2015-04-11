/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Handles tracking of achievement progress using the stats system
 */
Class UTStatsReadAchievements extends OnlineStatsRead
	dependson(UTAchievements);

`include(UTOnlineStats.uci)


defaultproperties
{
	ViewId=`STATS_GROUP_ACHIEVEMENTS

	ViewName="Achievements"


	// Column names for the table view
	ColumnIds.Add(EUTA_EXPLORE_EveryMutator)
	ColumnIds.Add(EUTA_WEAPON_DontTaseMeBro)
	ColumnIds.Add(EUTA_WEAPON_StrongestLink)
	ColumnIds.Add(EUTA_WEAPON_HaveANiceDay)
	ColumnIds.Add(EUTA_VEHICLE_Armadillo)
	ColumnIds.Add(EUTA_POWERUP_DeliveringTheHurt)
	ColumnIds.Add(EUTA_HUMILIATION_SerialKiller)
	ColumnIds.Add(EUTA_HUMILIATION_OffToAGoodStart)


	// Column metadata
	ColumnMappings.Add((Id=EUTA_EXPLORE_EveryMutator,Name="EUTA_EXPLORE_EveryMutator"))
	ColumnMappings.Add((Id=EUTA_WEAPON_DontTaseMeBro,Name="EUTA_WEAPON_DontTaseMeBro"))
	ColumnMappings.Add((Id=EUTA_WEAPON_StrongestLink,Name="EUTA_WEAPON_StrongestLink"))
	ColumnMappings.Add((Id=EUTA_WEAPON_HaveANiceDay,Name="EUTA_WEAPON_HaveANiceDay"))
	ColumnMappings.Add((Id=EUTA_VEHICLE_Armadillo,Name="EUTA_VEHICLE_Armadillo"))
	ColumnMappings.Add((Id=EUTA_POWERUP_DeliveringTheHurt,Name="EUTA_POWERUP_DeliveringTheHurt"))
	ColumnMappings.Add((Id=EUTA_HUMILIATION_SerialKiller,Name="EUTA_HUMILIATION_SerialKiller"))
	ColumnMappings.Add((Id=EUTA_HUMILIATION_OffToAGoodStart,Name="EUTA_HUMILIATION_OffToAGoodStart"))
}
