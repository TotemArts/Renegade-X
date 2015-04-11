/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Handles writing of achievement progress using the stats system
 */
Class UTStatsWriteAchievements extends OnlineStatsWrite
	dependson(UTAchievements);

`include(UTOnlineStats.uci)


defaultproperties
{
	ViewIds=(`STATS_GROUP_ACHIEVEMENTS)


	// Properties and their types
	Properties.Add((PropertyId=EUTA_EXPLORE_EveryMutator,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId=EUTA_WEAPON_DontTaseMeBro,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId=EUTA_WEAPON_StrongestLink,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId=EUTA_WEAPON_HaveANiceDay,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId=EUTA_VEHICLE_Armadillo,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId=EUTA_POWERUP_DeliveringTheHurt,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId=EUTA_HUMILIATION_SerialKiller,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId=EUTA_HUMILIATION_OffToAGoodStart,Data=(Type=SDT_Int32,Value1=0)))
}
