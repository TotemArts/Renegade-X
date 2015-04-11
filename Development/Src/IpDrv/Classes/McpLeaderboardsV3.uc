/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * This is the base interface for manipulating a user's inventory
 */
class McpLeaderboardsV3 extends McpLeaderboardsBase;

/** Resource path config strings */
var config String LeaderboardEntriesPath;
var config String BaseLeaderboardPath;
var config String LeaderboardEntryPath;
var config String LeaderboardEntriesByColumnRangePath;

struct LeaderboardRequest
{
	var HttpRequestInterface Request;
	var String LeaderboardName;
};

struct LeaderboardTimeframeRequest extends LeaderboardRequest
{
	var McpLeaderboardTimeframe Timeframe;
};

struct UserLeaderboardRequest extends LeaderboardRequest
{
	var String McpId;
};

/** The set of requests that are pending */
var array<LeaderboardTimeframeRequest> LeaderboardTimeframeRequests;
var array<UserLeaderboardRequest> UserLeaderboardRequests;

/** The list of leaderboards we know about */
var array<McpLeaderboard> Leaderboards;

/** The list of leaderboard entries we know about */
var array<McpLeaderboardEntry> Entries;

/**
 * Reads the list of leaderboards for this game
 */
function ReadLeaderboards()
{
	local String Url;
	local HttpRequestInterface Request;

	Request = CreateHttpRequestGameAuth();
	if (Request != none)
	{
		Url = GetBaseURL() $ BaseLeaderboardPath;
		`LogMcp("ReadLeaderboards URL is GET " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnReadLeaderboardsRequestComplete);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start ReadLeaderboards web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnReadLeaderboardsRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;

	ResponseCode = 500;
	if (Response != none)
	{
		ResponseCode = Response.GetResponseCode();
		ResponseString = Response.GetContentAsString();
	}
	// Both of these need to be true for the request to be a success
	bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
	if (bWasSuccessful)
	{
		// Parse the leaderboard data
		ParseLeaderboards(ResponseString);
	}
	else
	{
		ErrorString = "ReadLeaderboards failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		`LogMcp(ErrorString);
	}
	// Notify anyone waiting on this
	OnReadLeaderboardsComplete(bWasSuccessful, ErrorString);
}

/**
 * Parses a JSON string of leaderboard data
 *
 * @param Json the string to turn into struct entries
 */
private function ParseLeaderboards(String Json)
{
	local JsonObject ParsedJson;
	local int JsonIndex;

	ParsedJson = class'JsonObject'.static.DecodeJson(Json);
	if (ParsedJson != None)
	{
		for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
		{
			ParseLeaderboard(ParsedJson.ObjectArray[JsonIndex]);
		}
	}
}

/**
 * Converts the json tree into a struct
 *
 * @param LeaderboardObject the object to convert
 */
private function ParseLeaderboard(JsonObject LeaderboardObject)
{
	local int Index, ColumnIndex, TimeframeIndex;
	local JsonObject ColumnObject, TimeframeObject;

	if (LeaderboardObject.HasKey("name"))
	{
		Index = Leaderboards.Find('LeaderboardName', LeaderboardObject.GetStringValue("name"));
		if (Index == INDEX_NONE)
		{
			Index = Leaderboards.Length;
			Leaderboards.Length = Index + 1;
		}
		// Sample json:
		//	{
		//		"name" : "SKB_1113_All_2001_0",
		//		"columns" : [
		//			{
		//				"name":"progress",
		//				"type":"MAX"
		//			}],
		//		"ratingColumn" : "progress",
		//		"timeframes" : [
		//			"ALL_TIME"
		//			]}
		//	}
		// Update the fields for this
		Leaderboards[Index].LeaderboardName = LeaderboardObject.GetStringValue("name");
		Leaderboards[Index].RatingColumn = LeaderboardObject.GetStringValue("ratingColumn");
		// Update the columns
		Leaderboards[Index].Columns.Length = 0;
		ColumnObject = LeaderboardObject.GetObject("columns");
		if (ColumnObject != None)
		{
			Leaderboards[Index].Columns.Length = ColumnObject.ObjectArray.Length;
			for (ColumnIndex = 0; ColumnIndex < ColumnObject.ObjectArray.Length; ColumnIndex++)
			{
				Leaderboards[Index].Columns[ColumnIndex].Name = ColumnObject.ObjectArray[ColumnIndex].GetStringValue("name");
				switch (ColumnObject.ObjectArray[ColumnIndex].GetStringValue("type"))
				{
					case "SUM":
						Leaderboards[Index].Columns[ColumnIndex].Type = MLCT_SUM;
						break;
					case "MAX":
						Leaderboards[Index].Columns[ColumnIndex].Type = MLCT_MAX_VAL;
						break;
					case "MIN":
						Leaderboards[Index].Columns[ColumnIndex].Type = MLCT_MIN_VAL;
						break;
					case "LAST":
						Leaderboards[Index].Columns[ColumnIndex].Type = MLCT_LAST;
						break;
				}
			}
		}
		// Update the timeframes
		Leaderboards[Index].Timeframes.Length = 0;
		TimeframeObject = LeaderboardObject.GetObject("timeframes");
		if (TimeframeObject != None)
		{
			for (TimeframeIndex = 0; TimeframeIndex < TimeframeObject.ValueArray.Length; TimeframeIndex++)
			{
				Leaderboards[Index].Timeframes.AddItem(StringToTimeframe(TimeframeObject.ValueArray[TimeframeIndex]));
			}
		}
	}
}

/**
 * Get the list of leaderboards for the game
 */
function GetLeaderboards(out array<McpLeaderboard> OutLeaderboards)
{
	OutLeaderboards = Leaderboards;
}

/** @return converts a string into the enum form */
private function McpLeaderboardTimeframe StringToTimeframe(String Timeframe)
{
	switch (Timeframe)
	{
		case "ALL_TIME":
			return MLT_ALL_TIME;
		case "DAILY":
			return MLT_DAILY;
		case "WEEKLY":
			return MLT_WEEKLY;
		case "MONTHLY":
			return MLT_MONTHLY;
	}
	return MLT_MAX;
}

/** @return converts the enum to a server string */
private function String TimeframeToString(McpLeaderboardTimeframe Timeframe)
{
	switch (Timeframe)
	{
		case MLT_ALL_TIME:
			return "ALL_TIME";
		case MLT_DAILY:
			return "DAILY";
		case MLT_WEEKLY:
			return "WEEKLY";
		case MLT_MONTHLY:
			return "MONTHLY";
	}
	return "";
}

/**
 * Read the leaderboard entries for a list of people
 *
 * @param McpIds the list of ids of the users that are being read
 * @param LeaderboardName the name of the leaderboard being read
 * @param Timeframe the timeframe that the entry request is for
 * @param bSkipRankAndPercentile an optimization to skip the rank/percentile lookups
 */
function ReadLeaderboardEntries(const out array<String> McpIds, String LeaderboardName, McpLeaderboardTimeframe Timeframe, optional bool bSkipRankAndPercentile)
{
	local String Url;
	local HttpRequestInterface Request;
	local String JsonPayload;
	local int Index, AddAt;

	Request = CreateHttpRequestGameAuth();
	if (Request != none)
	{
		Url = GetBaseURL() $ Repl(LeaderboardEntriesPath, "{leaderboardName}", LeaderboardName) $ "?timeframe=" $ TimeframeToString(Timeframe);
		if (bSkipRankAndPercentile)
		{
			Url $= "&wantsRankAndPercentile=false";
		}
		`LogMcp("ReadLeaderboardEntries URL is POST " $ Url);
		// Make a json string from our list of ids
		JsonPayload = "[ ";
		for (Index = 0; Index < McpIds.Length; Index++)
		{
			if (Len(McpIds[Index]) > 0)
			{
				JsonPayload $= "\"" $ McpIds[Index] $ "\"";
				if (Index + 1 < McpIds.Length)
				{
					JsonPayload $= ",";
				}
			}
		}
		JsonPayload $= " ]";
		`LogMcp("ReadLeaderboardEntries JSON is " $ JsonPayload);
		Request.SetContentAsString(JsonPayload);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetProcessRequestCompleteDelegate(OnReadLeaderboardEntriesRequestComplete);

		// Store off the data for reporting later
		AddAt = LeaderboardTimeframeRequests.Length;
		LeaderboardTimeframeRequests.Length = AddAt + 1;
		LeaderboardTimeframeRequests[AddAt].Request = Request;
		LeaderboardTimeframeRequests[AddAt].LeaderboardName = LeaderboardName;
		LeaderboardTimeframeRequests[AddAt].Timeframe = Timeframe;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start ReadLeaderboardEntries web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnReadLeaderboardEntriesRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode, Index;
	local string ErrorString;
	local String ResponseString;

	Index = LeaderboardTimeframeRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			// Parse the leaderboard entry data
			ParseLeaderboardEntries(ResponseString);
		}
		else
		{
			ErrorString = "ReadLeaderboards failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnReadLeaderboardEntriesComplete(bWasSuccessful, ErrorString, LeaderboardTimeframeRequests[Index].LeaderboardName, LeaderboardTimeframeRequests[Index].Timeframe);
		LeaderboardTimeframeRequests.Remove(Index, 1);
	}
}

/**
 * Parses a JSON string of leaderboard entry data
 *
 * @param Json the string to turn into struct entries
 */
private function ParseLeaderboardEntries(String Json)
{
	local JsonObject ParsedJson;
	local int JsonIndex;

	ParsedJson = class'JsonObject'.static.DecodeJson(Json);
	if (ParsedJson != None)
	{
		for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
		{
			ParseLeaderboardEntry(ParsedJson.ObjectArray[JsonIndex]);
		}
	}
}

/**
 * Converts the json tree into a struct
 *
 * @param LeaderboardObject the object to convert
 */
private function ParseLeaderboardEntry(JsonObject LeaderboardObject)
{
	local int Index;
	local String LeaderboardName, McpId;
	local McpLeaderboardTimeframe Timeframe;

	Timeframe = StringToTimeframe(LeaderboardObject.GetStringValue("timeframe"));
	McpId = LeaderboardObject.GetStringValue("gameAccountId");
	LeaderboardName = LeaderboardObject.GetStringValue("leaderboardName");
	// Search an existing entry
	for (Index = 0; Index < Entries.Length; Index++)
	{
		if (Entries[Index].McpId == McpId &&
			Entries[Index].LeaderboardName == LeaderboardName &&
			Entries[Index].Timeframe == Timeframe)
		{
			break;
		}
	}
	if (Index == Entries.Length)
	{
		// Not found so add space for the new entry
		Entries.Length = Index + 1;
	}

	// Sample json:
	//	{
	//		"gameAccountId" : "someId",
	//		"leaderboardName" : "SKB_1113_All_2001_0",
	//		"timeframe" : "ALL_TIME",
	//		"ratingValue" : "value",
	//		"ranking" : "value",
	//		"percentile" : "value",
	//		"values" : [
	//			{
	//				"colName" : "value",
	//				"colName" : "value",
	//				"colName" : "value",
	//				...
	//			}],
	//	}
	// Update the fields for this
	Entries[Index].McpId = McpId;
	Entries[Index].LeaderboardName = LeaderboardName;
	Entries[Index].Timeframe = Timeframe;
	Entries[Index].RatingValue = LeaderboardObject.GetIntValue("ratingValue");
	Entries[Index].Ranking = LeaderboardObject.GetIntValue("ranking");
	Entries[Index].Percentile = LeaderboardObject.GetIntValue("percentile");
	// Parse all of the values
	Entries[Index].Values = ParseLeaderboardEntryValues(LeaderboardName, LeaderboardObject);
}

/**
 * Parses an entry's list of values
 *
 * @param LeaderboardName the leaderboard to look up for column mapping
 * @param LeaderboardEntry the JSON object to parse the values from
 *
 * @return the array of values that were parsed
 */
private function array<McpLeaderboardColumnEntry> ParseLeaderboardEntryValues(String LeaderboardName, JsonObject LeaderboardEntry)
{
	local int LbIndex, ColumnIndex, Index;
	local JsonObject ValuesObject;
	local array<McpLeaderboardColumnEntry> Values;

	LbIndex = Leaderboards.Find('LeaderboardName', LeaderboardName);
	if (LbIndex == INDEX_NONE)
	{
		return Values;
	}
	ValuesObject = LeaderboardEntry.GetObject("values");
	if (ValuesObject == None)
	{
		return Values;
	}
	// Look for each column in the leaderboard for its corresponding value
	for (ColumnIndex = 0; ColumnIndex < Leaderboards[LbIndex].Columns.Length; ColumnIndex++)
	{
		if (ValuesObject.HasKey(Leaderboards[LbIndex].Columns[ColumnIndex].Name))
		{
			Index = Values.Length;
			Values.Length = Index + 1;
			Values[Index].Name = Leaderboards[LbIndex].Columns[ColumnIndex].Name;
			Values[Index].Value = ValuesObject.GetIntValue(Values[Index].Name);
		}
	}
	return Values;
}

/**
 * Get the entries for a single person
 *
 * @param McpId the user to copy entries for
 * @param OutEntries the out value to add them to
 * @param LeaderboardName optional leaderboard to restrict the array population to
 */
function GetLeaderboardEntries(String McpId, out array<McpLeaderboardEntry> OutEntries, optional String LeaderboardName)
{
	local int Index;

	if (LeaderboardName == "")
	{
		for (Index = 0; Index < Entries.Length; Index++)
		{
			if (Entries[Index].McpId == McpId)
			{
				OutEntries.AddItem(Entries[Index]);
			}
		}
	}
	else
	{
		for (Index = 0; Index < Entries.Length; Index++)
		{
			if (Entries[Index].McpId == McpId && Entries[Index].LeaderboardName == LeaderboardName)
			{
				OutEntries.AddItem(Entries[Index]);
			}
		}
	}
}

/**
 * Get the leaderboard entries for a list of people
 *
 * @param McpId the user to copy entries for
 * @param OutEntries the out value to add them to
 * @param LeaderboardName optional leaderboard to restrict the array population to
 */
function GetLeaderboardEntriesForUsers(const out array<String> McpIds, out array<McpLeaderboardEntry> OutEntries, optional String LeaderboardName)
{
	local int Index;

	for (Index = 0; Index < McpIds.Length; Index++)
	{
		GetLeaderboardEntries(McpIds[Index], OutEntries, LeaderboardName);
	}
}

/**
 * Get all of the leaderboard entries for a single leaderboard
 *
 * @param LeaderboardName leaderboard to restrict the array population to
 * @param OutEntries the out value to add them to
 */
function GetEntriesForLeaderboard(String LeaderboardName, out array<McpLeaderboardEntry> OutEntries)
{
	local int Index;

	for (Index = 0; Index < Entries.Length; Index++)
	{
		if (Entries[Index].LeaderboardName == LeaderboardName)
		{
			OutEntries.AddItem(Entries[Index]);
		}
	}
}

/**
 * Write to a leaderboard
 *
 * @param McpId the id of the user that is being updated
 * @param LeaderboardName the name of the leaderboard being updated
 * @param Columns the leaderboard columns being updated
 */
function WriteLeaderboardEntry(String McpId, String LeaderboardName, const out array<McpLeaderboardColumnEntry> Columns)
{
	local String Url;
	local HttpRequestInterface Request;
	local String JsonPayload;
	local int Index, AddAt;
	local String Path;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Path = Repl(LeaderboardEntryPath, "{leaderboardName}", LeaderboardName);
		Path = Repl(Path, "{gameAccountId}", McpId);
		Url = GetBaseURL() $ Path;
		`LogMcp("WriteLeaderboardEntry URL is POST " $ Url);
		// Make a json string from our list of columns to update
		JsonPayload = "{ ";
		for (Index = 0; Index < Columns.Length; Index++)
		{
			JsonPayload $= "\"" $ Columns[Index].Name $ "\": " $ Columns[Index].Value;
			if (Index + 1 < Columns.Length)
			{
				JsonPayload $= ",";
			}
		}
		JsonPayload $= " }";
		`LogMcp("WriteLeaderboardEntry JSON is " $ JsonPayload);
		Request.SetContentAsString(JsonPayload);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetProcessRequestCompleteDelegate(OnWriteLeaderboardEntryRequestComplete);

		// Store off the data for reporting later
		AddAt = UserLeaderboardRequests.Length;
		UserLeaderboardRequests.Length = AddAt + 1;
		UserLeaderboardRequests[AddAt].Request = Request;
		UserLeaderboardRequests[AddAt].LeaderboardName = LeaderboardName;
		UserLeaderboardRequests[AddAt].McpId = McpId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start WriteLeaderboardEntry web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnWriteLeaderboardEntryRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int Index;

	Index = UserLeaderboardRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (!bWasSuccessful)
		{
			ErrorString = "WriteLeaderboardEntry failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnWriteLeaderboardEntryComplete(bWasSuccessful, ErrorString, UserLeaderboardRequests[Index].McpId, UserLeaderboardRequests[Index].LeaderboardName);
		UserLeaderboardRequests.Remove(Index, 1);
	}
}

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
function ReadLeaderboardColumnByRange(String LeaderboardName, McpLeaderboardTimeframe Timeframe, String ColumnName, int Min, int Max, int NumToRead)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequestGameAuth();
	if (Request != none)
	{
		Url = GetBaseURL() $ Repl(LeaderboardEntriesByColumnRangePath, "{leaderboardName}", LeaderboardName);
		Url = Repl(Url, "{timeframe}", TimeframeToString(Timeframe));
		Url = Repl(Url, "{columnName}", ColumnName);
		Url $= "?min=" $ Min $ "&max=" $ Max $ "&count=" $ NumToRead;
		`LogMcp("ReadLeaderboardColumnByRange URL is GET " $ Url);

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnReadLeaderboardEntriesRequestComplete);

		// Store off the data for reporting later
		AddAt = LeaderboardTimeframeRequests.Length;
		LeaderboardTimeframeRequests.Length = AddAt + 1;
		LeaderboardTimeframeRequests[AddAt].Request = Request;
		LeaderboardTimeframeRequests[AddAt].LeaderboardName = LeaderboardName;
		LeaderboardTimeframeRequests[AddAt].Timeframe = Timeframe;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start ReadLeaderboardEntries web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Get all of the leaderboard entries for a single leaderboard that matches the column range specified
 *
 * @param LeaderboardName leaderboard to restrict the array population to
 * @param Timeframe the timeframe to read (weekly, daily, etc.)
 * @param ColumnName the name of the column that is being range checked
 * @param Min the min value to filter on
 * @param Max the max value to filter on
 * @param OutEntries the out value to add them to
 */
function GetLeaderboardByColumnByRange(String LeaderboardName, McpLeaderboardTimeframe Timeframe, String ColumnName, int Min, int Max, out array<McpLeaderboardEntry> OutEntries)
{
	local int Index;
	local int ValueIndex;

	for (Index = 0; Index < Entries.Length; Index++)
	{
		if (Entries[Index].LeaderboardName == LeaderboardName &&
			Entries[Index].Timeframe == Timeframe)
		{
			// Search for the column and match the value range before copying out
			for (ValueIndex = 0; ValueIndex < Entries[Index].Values.Length; ValueIndex++)
			{
				if (Entries[Index].Values[ValueIndex].Name == ColumnName)
				{
					if (Entries[Index].Values[ValueIndex].Value >= Min &&
						Entries[Index].Values[ValueIndex].Value <= Max)
					{
						OutEntries.AddItem(Entries[Index]);
					}
					// No matter what, we're done with this iteration
					break;
				}
			}
		}
	}
}

/** Clears all entries for all leaderboards */
function ClearAllLeaderboardEntries()
{
	Entries.Length = 0;
}

/**
 * Clears all entries for a specific leaderboard
 *
 * @param LeaderboardName the leaderboard to empty
 */
function ClearLeaderboardEntriesForLeaderboard(String LeaderboardName)
{
	local int Index;

	for (Index = 0; Index < Entries.Length; Index++)
	{
		if (Entries[Index].LeaderboardName == LeaderboardName)
		{
			Entries.Remove(Index, 1);
			Index--;
		}
	}
}

/**
 * Clears all entries for a specific player across all leaderboards
 *
 * @param McpId the player to remove entries for
 */
function ClearLeaderboardEntriesForMcpId(String McpId)
{
	local int Index;

	for (Index = 0; Index < Entries.Length; Index++)
	{
		if (Entries[Index].McpId == McpId)
		{
			Entries.Remove(Index, 1);
			Index--;
		}
	}
}
