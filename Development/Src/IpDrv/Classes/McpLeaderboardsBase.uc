/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * This is the base interface for reading & writing to leaderboards for users
 */
class McpLeaderboardsBase extends McpServiceBase
	abstract
	config(Engine);

/** The class name to use in the factory method to create our instance */
var config string McpLeaderboardsClassName;

enum McpLeaderboardColumnType
{
	MLCT_SUM,
	MLCT_MAX_VAL,
	MLCT_MIN_VAL,
	MLCT_LAST
};

enum McpLeaderboardTimeframe
{
	MLT_ALL_TIME,
	MLT_DAILY,
	MLT_WEEKLY,
	MLT_MONTHLY
};

struct McpLeaderboardColumn
{
	/** The name of the column that is used when writing/reading values */
	var String Name;
	/** How the column is processed on the backend */
	var McpLeaderboardColumnType Type;
};

struct McpLeaderboardColumnEntry
{
	/** The name of the column that is used when writing/reading values */
	var String Name;
	/** The value for this column */
	var int Value;
};

struct McpLeaderboardEntry
{
	/** The user this entry is for */
	var String McpId;
	/** The name of the leaderboard this entry is for */
	var String LeaderboardName;
	/** The timeframe this entry is for */
	var McpLeaderboardTimeframe Timeframe;
	/** The list of columns and their values for this leaderboard entry */
	var Array<McpLeaderboardColumnEntry> Values;
	/** The value that this entry is rated on */
	var int RatingValue;
	/** Where this entry rates of all entries */
	var int Ranking;
	/** Where this entry rates via percentile */
	var int Percentile;
};

struct McpLeaderboard
{
	/** The name/id of the leaderboard that is used when writing/reading values */
	var String LeaderboardName;
	/** The list of columns the leaderboard supports */
	var Array<McpLeaderboardColumn> Columns;
	/** The name of the column the leaderboard is rated on */
	var String RatingColumn;
	/** The set of timeframes this leaderboard supports */
	var Array<McpLeaderboardTimeframe> Timeframes;
};

/**
 * @return the object that implements this interface or none if missing or failed to create/load
 */
final static function McpLeaderboardsBase CreateInstance()
{
	local class<McpLeaderboardsBase> McpLeaderboardsBaseClass;
	local McpLeaderboardsBase NewInstance;

	McpLeaderboardsBaseClass = class<McpLeaderboardsBase>(DynamicLoadObject(default.McpLeaderboardsClassName, class'Class'));
	// If the class was loaded successfully, create a new instance of it
	if (McpLeaderboardsBaseClass != None)
	{
		NewInstance = McpLeaderboardsBase(GetSingleton(McpLeaderboardsBaseClass));
	}

	return NewInstance;
}

/**
 * Reads the list of leaderboards for this game
 */
function ReadLeaderboards();

/**
 * Called once the read completes
 *
 * @param bWasSuccessful whether the creation succeeded or not
 * @param Error string information about the error (if an error)
 */
delegate OnReadLeaderboardsComplete(bool bWasSuccessful, String Error);

/**
 * Get the list of leaderboards for the game
 */
function GetLeaderboards(out array<McpLeaderboard> Leaderboards);

/**
 * Read the leaderboard entries for a list of people
 *
 * @param McpIds the list of ids of the users that are being read
 * @param LeaderboardName the name of the leaderboard being read
 * @param Timeframe the timeframe that the entry request is for
 * @param bSkipRankAndPercentile an optimization to skip the rank/percentile lookups
 */
function ReadLeaderboardEntries(const out array<String> McpIds, String LeaderboardName, McpLeaderboardTimeframe Timeframe, optional bool bSkipRankAndPercentile);

/**
 * Called once the read completes
 *
 * @param bWasSuccessful whether the creation succeeded or not
 * @param Error string information about the error (if an error)
 * @param LeaderboardName the name of the leaderboard read
 * @param Timeframe the timeframe that the entry request was for
 */
delegate OnReadLeaderboardEntriesComplete(bool bWasSuccessful, String Error, String LeaderboardName, McpLeaderboardTimeframe Timeframe);

/**
 * Get the entries for a single person
 *
 * @param McpId the user to copy entries for
 * @param Entries the out value to add them to
 * @param LeaderboardName optional leaderboard to restrict the array population to
 */
function GetLeaderboardEntries(String McpId, out array<McpLeaderboardEntry> Entries, optional String LeaderboardName);

/**
 * Get the leaderboard entries for a list of people
 *
 * @param McpId the user to copy entries for
 * @param Entries the out value to add them to
 * @param LeaderboardName optional leaderboard to restrict the array population to
 */
function GetLeaderboardEntriesForUsers(const out array<String> McpIds, out array<McpLeaderboardEntry> Entries, optional String LeaderboardName);

/**
 * Get all of the leaderboard entries for a single leaderboard
 *
 * @param LeaderboardName leaderboard to restrict the array population to
 * @param Entries the out value to add them to
 */
function GetEntriesForLeaderboard(String LeaderboardName, out array<McpLeaderboardEntry> Entries);

/**
 * Write to a leaderboard
 *
 * @param McpId the id of the user that is being updated
 * @param LeaderboardName the name of the leaderboard being updated
 * @param Columns the leaderboard columns being updated
 */
function WriteLeaderboardEntry(String McpId, String LeaderboardName, const out array<McpLeaderboardColumnEntry> Columns);

/**
 * Called once the write completes
 *
 * @param bWasSuccessful whether the creation succeeded or not
 * @param Error string information about the error (if an error)
 * @param McpId the id of the user that was updated
 * @param LeaderboardName the name of the leaderboard updated
 */
delegate OnWriteLeaderboardEntryComplete(bool bWasSuccessful, String Error, String McpId, String LeaderboardName);

/**
 * Read a leaderboard for a specific column range. This returns the most recent entries that meet the min/max value
 *
 * @param LeaderboardName the name of the leaderboard being updated
 * @param Timeframe the timeframe to read (weekly, daily, etc.)
 * @param ColumnName the name of the column that is being range checked
 * @param Min the min value to filter on
 * @param Max the max value to filter on
 * @param NumToRead the number of results to return
 */
function ReadLeaderboardColumnByRange(String LeaderboardName, McpLeaderboardTimeframe Timeframe, String ColumnName, int Min, int Max, int NumToRead);

/**
 * Get all of the leaderboard entries for a single leaderboard that matches the column range specified
 *
 * @param LeaderboardName leaderboard to restrict the array population to
 * @param Timeframe the timeframe to read (weekly, daily, etc.)
 * @param ColumnName the name of the column that is being range checked
 * @param Min the min value to filter on
 * @param Max the max value to filter on
 * @param Entries the out value to add them to
 */
function GetLeaderboardByColumnByRange(String LeaderboardName, McpLeaderboardTimeframe Timeframe, String ColumnName, int Min, int Max, out array<McpLeaderboardEntry> Entries);

/** Clears all entries for all leaderboards */
function ClearAllLeaderboardEntries();

/**
 * Clears all entries for a specific leaderboard
 *
 * @param LeaderboardName the leaderboard to empty
 */
function ClearLeaderboardEntriesForLeaderboard(String LeaderboardName);

/**
 * Clears all entries for a specific player across all leaderboards
 *
 * @param McpId the player to remove entries for
 */
function ClearLeaderboardEntriesForMcpId(String McpId);
