/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Provides the interface for ClashMob Mcp3 services
 */
class McpClashMobManagerV3 extends McpClashMobBase
	config(Engine);

/** URLs for interacting with resources */
var config String ChallengePath;
var config String UserChallengePath;
var config String UserChallengeUpdatePath;
var config String ChallengeFilePath;

/** List of challenges that were enumerated from the server. Filled in with QueryChallengeList */
var array<McpClashMobChallengeEvent> ChallengeEvents;
/** The set of statuses for users in a set of challenges */
var array<McpClashMobChallengeUserStatus> ChallengeStatuses;

struct ChallengeRequest
{
	/** The challenge id they provided data for */
	var String ChallengeId;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

struct UserRequest extends ChallengeRequest
{
	/** The user that this call is for */
	var string McpId;
};

var array<ChallengeRequest> ChallengeRequests;
var array<UserRequest> UserRequests;

struct FileRequest
{
	/** The challenge id they provided data for */
	var String ChallengeId;
	/** The DLName for the file */
	var String DlName;
	/** The FileName for the file */
	var String FileName;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

var array<FileRequest> FileRequests;

struct ClashMobFileData
{
	/** The challenge id they provided data for */
	var String ChallengeId;
	/** The DLName for the file */
	var String DlName;
	/** The FileName for the file */
	var String FileName;
	/** The contents of the file */
	var array<byte> Data;
};

/** Holds the file data for the various challenges */
var array<ClashMobFileData> ChallengeFiles;

/** Interface that handles file caching */
var OnlineTitleFileCacheInterface FileCache;

/** Grab the file caching interface */
protected event Init()
{
	Super.Init();

	// Used to cache of files to/from disk
	if (FileCache == None)
	{
		FileCache = class'GameEngine'.static.GetOnlineSubsystem().TitleFileCacheInterface;
		if (FileCache != None)
		{
			FileCache.AddLoadTitleFileCompleteDelegate(OnLoadCachedFileComplete);
		}
	}
}

/**
 * Initiates a web request to retrieve the list of available challenge events from the server.
 */
function QueryChallengeList(String McpId)
{
	local String Url;
	local HttpRequestInterface Request;

	Request = CreateHttpRequest(McpId);

	Url = GetBaseURL() $ ChallengePath $ "?checkVisibility=true&haveExpired=false";
	`LogMcp("QueryChallengeList URL is GET " $ Url);

	Request.SetURL(Url);
	Request.SetVerb("GET");
	Request.SetProcessRequestCompleteDelegate(OnQueryChallengeListRequestComplete);

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start QueryChallengeList web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnQueryChallengeListRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
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
		bWasSuccessful = ParseChallenges(ResponseString);
		if (!bWasSuccessful)
		{
			ErrorString = "QueryChallengeList failed to parse JSON:\n" $ ResponseString;
		}
	}
	else
	{
		ErrorString = "QueryChallengeList failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
	}
	if (!bWasSuccessful && Len(ErrorString) > 0)
	{
		`LogMcp(ErrorString);
	}
	OnQueryChallengeListComplete(bWasSuccessful, ErrorString);
}

/**
 * Initiates a web request to retrieve the data for a specific challenge
 */
function QueryChallenge(String ChallengeId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequestGameAuth();

	Url = GetBaseURL() $ ChallengePath $ "/" $ ChallengeId $ "?infoOnly=true";
	`LogMcp("QueryChallenge URL is GET " $ Url);

	Request.SetURL(Url);
	Request.SetVerb("GET");
	Request.SetProcessRequestCompleteDelegate(OnQueryChallengeRequestComplete);
	
	AddAt = ChallengeRequests.Length;
	ChallengeRequests.Length = AddAt + 1;
	ChallengeRequests[AddAt].ChallengeId = ChallengeId;
	ChallengeRequests[AddAt].Request = Request;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start QueryChallenge web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnQueryChallengeRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local String ErrorString;
	local String ResponseString;
	local int RequestIndex;
	local String ChallengeId;
	local JsonObject ParsedJson;

	RequestIndex = ChallengeRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		ChallengeId = ChallengeRequests[RequestIndex].ChallengeId;
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
			ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
			bWasSuccessful = ParseChallenge(ParsedJson);
			if (!bWasSuccessful)
			{
				ErrorString = "QueryChallenge failed to parse JSON:\n" $ ResponseString;
			}
		}
		else
		{
			ErrorString = "QueryChallenge failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		OnQueryChallengeComplete(bWasSuccessful, ChallengeId, ErrorString);
		ChallengeRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Initiates a web request to retrieve the data for a specific parent challenge and all its children
 */
function QueryParentChallenge(String ChallengeId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequestGameAuth();

	Url = GetBaseURL() $ ChallengePath $ "/" $ ChallengeId $ "/children";
	`LogMcp("QueryParentChallenge URL is GET " $ Url);

	Request.SetURL(Url);
	Request.SetVerb("GET");
	Request.SetProcessRequestCompleteDelegate(OnQueryParentChallengeRequestComplete);
	
	AddAt = ChallengeRequests.Length;
	ChallengeRequests.Length = AddAt + 1;
	ChallengeRequests[AddAt].ChallengeId = ChallengeId;
	ChallengeRequests[AddAt].Request = Request;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start QueryParentChallenge web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnQueryParentChallengeRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local String ErrorString;
	local String ResponseString;
	local int RequestIndex;
	local String ChallengeId;

	RequestIndex = ChallengeRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		ChallengeId = ChallengeRequests[RequestIndex].ChallengeId;
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
			bWasSuccessful = ParseChallenges(ResponseString);
			if (!bWasSuccessful)
			{
				ErrorString = "QueryChallenge failed to parse JSON:\n" $ ResponseString;
			}
		}
		else
		{
			ErrorString = "QueryChallenge failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		OnQueryChallengeComplete(bWasSuccessful, ChallengeId, ErrorString);
		ChallengeRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Parses a JSON payload into a set of ClashMob entries
 *
 * @param Json the json string to parse
 *
 * @return true if the payload parsed correctly, false otherwise
 */
function bool ParseChallenges(String Json)
{
	local JsonObject ParsedJson, JsonElement;
	local int JsonIndex;

	ParsedJson = class'JsonObject'.static.DecodeJson(Json);
	// Parse each file, adding them if needed
	for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
	{
		JsonElement = ParsedJson.ObjectArray[JsonIndex];
		if (!ParseChallenge(JsonElement))
		{
			return false;
		}
	}
	return true;
}

/**
 * Copies the properties from a JSON node to a ClashMob struct entry
 *
 * @param JsonNode the json object to copy data from
 *
 * @return true if the payload parsed correctly, false otherwise
 */
function bool ParseChallenge(JsonObject JsonNode)
{
	local int Index;
	local String UniqueChallengeId;
	local String MissingKey;
	local JsonObject FilesArray;
	local JsonObject JsonElement;
	local McpClashMobChallengeFile File;
	local int JsonIndex;
	local int FileIndex;
	local McpChildClashMobEntry ChildChallenge;
	local JsonObject ChildArray;

	if (!JsonNode.HasKey("challengeId"))
	{
		return false;
	}
	UniqueChallengeId = JsonNode.GetStringValue("challengeId");

	Index = ChallengeEvents.Find('unique_challenge_id', UniqueChallengeId);
	if (Index == INDEX_NONE)
	{
		// Not in our list, so add it
		Index = ChallengeEvents.Length;
		ChallengeEvents.Length = Index + 1;
		ChallengeEvents[Index].unique_challenge_id = UniqueChallengeId;
	}
	if (JsonNode.HasKey("visibleDate"))
	{
		ChallengeEvents[Index].visible_date = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("visibleDate"));
	}
	else
	{
		MissingKey = "visibleDate";
	}
	if (JsonNode.HasKey("startDate"))
	{
		ChallengeEvents[Index].start_date = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("startDate"));
	}
	else
	{
		MissingKey = "startDate";
	}
	if (JsonNode.HasKey("endDate"))
	{
		ChallengeEvents[Index].end_date = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("endDate"));
	}
	else
	{
		MissingKey = "endDate";
	}
	if (JsonNode.HasKey("completedDate"))
	{
		ChallengeEvents[Index].completed_date = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("completedDate"));
	}
	if (JsonNode.HasKey("purgeDate"))
	{
		ChallengeEvents[Index].purge_date = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("purgeDate"));
	}
	else
	{
		MissingKey = "purgeDate";
	}
	if (JsonNode.HasKey("challengeType"))
	{
		ChallengeEvents[Index].challenge_type = JsonNode.GetStringValue("challengeType");
	}
	else
	{
		MissingKey = "challengeType";
	}
	if (JsonNode.HasKey("attempts"))
	{
		ChallengeEvents[Index].num_attempts = JsonNode.GetIntValue("attempts");
	}
	else
	{
		MissingKey = "attempts";
	}
	if (JsonNode.HasKey("successfulAttempts"))
	{
		ChallengeEvents[Index].num_successful_attempts = JsonNode.GetIntValue("successfulAttempts");
	}
	else
	{
		MissingKey = "successfulAttempts";
	}
	if (JsonNode.HasKey("goalValue"))
	{
		ChallengeEvents[Index].goal_value = JsonNode.GetIntValue("goalValue");
	}
	else
	{
		MissingKey = "goalValue";
	}
	if (JsonNode.HasKey("goalStartValue"))
	{
		ChallengeEvents[Index].goal_start_value = JsonNode.GetIntValue("goalStartValue");
	}
	else
	{
		MissingKey = "goalStartValue";
	}
	if (JsonNode.HasKey("goalCurrentValue"))
	{
		ChallengeEvents[Index].goal_current_value = JsonNode.GetIntValue("goalCurrentValue");
	}
	else
	{
		MissingKey = "goalCurrentValue";
	}
	if (JsonNode.HasKey("started"))
	{
		ChallengeEvents[Index].has_started = JsonNode.GetBoolValue("started");
	}
	else
	{
		MissingKey = "started";
	}
	if (JsonNode.HasKey("visible"))
	{
		ChallengeEvents[Index].is_visible = JsonNode.GetBoolValue("visible");
	}
	else
	{
		MissingKey = "visible";
	}
	if (JsonNode.HasKey("completed"))
	{
		ChallengeEvents[Index].has_completed = JsonNode.GetBoolValue("completed");
	}
	else
	{
		MissingKey = "completed";
	}
	if (JsonNode.HasKey("successful"))
	{
		ChallengeEvents[Index].was_successful = JsonNode.GetBoolValue("successful");
	}
	else
	{
		MissingKey = "successful";
	}
	ChallengeEvents[Index].facebook_id = JsonNode.GetStringValue("facebookId");
	if (ChallengeEvents[Index].facebook_id != "")
	{
		if (JsonNode.HasKey("facebookLikes"))
		{
			ChallengeEvents[Index].facebook_likes = JsonNode.GetIntValue("facebookLikes");
		}
		else
		{
			MissingKey = "facebookLikes";
		}
		if (JsonNode.HasKey("facebookComments"))
		{
			ChallengeEvents[Index].facebook_comments = JsonNode.GetIntValue("facebookComments");
		}
		else
		{
			MissingKey = "facebookComments";
		}
		if (JsonNode.HasKey("facebookLikeScalar"))
		{
			ChallengeEvents[Index].facebook_like_scaler = JsonNode.GetFloatValue("facebookLikeScalar");
		}
		else
		{
			MissingKey = "facebookLikeScalar";
		}
		if (JsonNode.HasKey("facebookCommentScalar"))
		{
			ChallengeEvents[Index].facebook_comment_scaler = JsonNode.GetFloatValue("facebookCommentScalar");
		}
		else
		{
			MissingKey = "facebookCommentScalar";
		}
		if (JsonNode.HasKey("facebookLikeGoalProgress"))
		{
			ChallengeEvents[Index].facebook_like_goal_progress = JsonNode.GetIntValue("facebookLikeGoalProgress");
		}
		else
		{
			MissingKey = "facebookLikeGoalProgress";
		}
		if (JsonNode.HasKey("facebookCommentGoalProgress"))
		{
			ChallengeEvents[Index].facebook_comment_goal_progress = JsonNode.GetIntValue("facebookLikeGoalProgress");
		}
		else
		{
			MissingKey = "facebookCommentGoalProgress";
		}
	}
	ChallengeEvents[Index].twitter_id = JsonNode.GetStringValue("twitterId");
	if (ChallengeEvents[Index].twitter_id != "")
	{
		if (JsonNode.HasKey("twitterRetweets"))
		{
			ChallengeEvents[Index].twitter_retweets = JsonNode.GetIntValue("twitterRetweets");
		}
		else
		{
			MissingKey = "twitterRetweets";
		}
		if (JsonNode.HasKey("twitterGoalProgress"))
		{
			ChallengeEvents[Index].twitter_goal_progress = JsonNode.GetIntValue("twitterGoalProgress");
		}
		else
		{
			MissingKey = "twitterGoalProgress";
		}
		if (JsonNode.HasKey("twitterRetweetsScalar"))
		{
			ChallengeEvents[Index].twitter_retweets_scaler = JsonNode.GetIntValue("twitterRetweetsScalar");
		}
		else
		{
			MissingKey = "twitterRetweetsScalar";
		}
	}

	// Check for child challenges
	if (JsonNode.HasKey("parentChallengeId"))
	{
		ChallengeEvents[Index].ParentChallengeId = JsonNode.GetStringValue("parentChallengeId");
	}
	if (JsonNode.HasKey("activeChildChallengeId"))
	{
		ChallengeEvents[Index].ActiveChildChallengeId = JsonNode.GetStringValue("activeChildChallengeId");
	}
	ChildArray = JsonNode.GetObject("childChallengeList");
	if (ChildArray != none)
	{
		ChallengeEvents[Index].ChildChallengeList.Length = 0;
		// Add each child challenge
		for (JsonIndex = 0; JsonIndex < ChildArray.ObjectArray.Length; JsonIndex++)
		{
			JsonElement = ChildArray.ObjectArray[JsonIndex];
			ChildChallenge.Order = JsonElement.GetIntValue("key");
			ChildChallenge.ChildChallengeId = JsonElement.GetStringValue("value");
			ChallengeEvents[Index].ChildChallengeList.AddItem(ChildChallenge);
		}
	}
	if (JsonNode.HasKey("childChallengeGatingType"))
	{
		switch (JsonNode.GetStringValue("childChallengeGatingType"))
		{
			case "SUCCESS":
				ChallengeEvents[Index].ChildChallengeGatingType = MCCGT_SUCCESS;
				break;
			case "RAW_SCORE":
				ChallengeEvents[Index].ChildChallengeGatingType = MCCGT_RAW_SCORE;
				break;
			case "TOP_N_PERCENT":
				ChallengeEvents[Index].ChildChallengeGatingType = MCCGT_TOP_N_PERCENT;
				break;
			case "TOP_N_ENTRIES":
				ChallengeEvents[Index].ChildChallengeGatingType = MCCGT_TOP_N_ENTRIES;
				break;
			default:
				ChallengeEvents[Index].ChildChallengeGatingType = MCCGT_NONE;
				break;
		}
	}
	if (JsonNode.HasKey("childChallengeGatingValue"))
	{
		ChallengeEvents[Index].ChildChallengeGatingValue = JsonNode.GetFloatValue("childChallengeGatingValue");
	}
	if (JsonNode.HasKey("challengeRatingType"))
	{
		switch (JsonNode.GetStringValue("challengeRatingType"))
		{
			case "TOTAL_PROGRESS":
				ChallengeEvents[Index].ChallengeRatingType = MCRT_TOTAL_PROGRESS;
				break;
			case "HIGH_PROGRESS":
				ChallengeEvents[Index].ChallengeRatingType = MCRT_HIGH_PROGRESS;
				break;
			default:
				ChallengeEvents[Index].ChallengeRatingType = MCRT_NOT_RATED;
				break;
		}
	}
	if (JsonNode.HasKey("startedAt"))
	{
		ChallengeEvents[Index].StartedAt = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("startedAt"));
	}
	if (JsonNode.HasKey("minChallengeDuration"))
	{
		ChallengeEvents[Index].MinChallengeDuration = JsonNode.GetIntValue("minChallengeDuration");
	}

	FilesArray = JsonNode.GetObject("files");
	if (FilesArray != none)
	{
		File.Status = MCFS_NotStarted;
		for (JsonIndex = 0; JsonIndex < FilesArray.ObjectArray.Length; JsonIndex++)
		{
			JsonElement = FilesArray.ObjectArray[JsonIndex];
			File.should_keep_post_challenge = JsonElement.GetBoolValue("shouldKeepPostChallenge");
			File.file_name = JsonElement.GetStringValue("filename");
			File.dl_name = JsonElement.GetStringValue("uniqueFileName");
			File.hash_code = JsonElement.GetStringValue("hash");
			File.type = JsonElement.GetStringValue("type");
			// Don't add if it already exists
			FileIndex = ChallengeEvents[Index].file_list.Find('dl_name', File.dl_name);
			if (FileIndex == INDEX_NONE)
			{
				ChallengeEvents[Index].file_list.AddItem(File);
			}
			else
			{
				ChallengeEvents[Index].file_list[FileIndex] = File;
			}
		}
	}

	if (MissingKey != "")
	{
		`LogMcp("JSON failed to parse missing key: " $ MissingKey);
		// Clear out any data that might be there from a partial parse
		ChallengeEvents.Remove(Index, 1);
	}
	return MissingKey == "";
}

/**
 * Access the currently cached challenge list that was downloaded. Use QueryChallengeList first
 *
 * @param OutChallengeEvents the list of events that should be filled in
 */
function GetChallengeList(out array<McpClashMobChallengeEvent> OutChallengeEvents)
{
	OutChallengeEvents = ChallengeEvents;
}

/**
 * Find a specific challenge.
 * 
 * @param UniqueChallengeId Id to look for
 * @param OutChallengeEvent the challenge found
 * @return bool true if found
 */
function bool GetChallenge(String UniqueChallengeId, out McpClashMobChallengeEvent OutChallengeEvent)
{
	local int Index;

	Index = ChallengeEvents.Find('unique_challenge_id', UniqueChallengeId);
	if (Index != INDEX_NONE)
	{
		OutChallengeEvent = ChallengeEvents[Index];
		return true;
	}
	return false;
}

/**
 * Get the list of files for a given challenge
 *
 * @param UniqueChallengeId id of challenge that may have files
 * @param OutChallengeFiles list of files that should be filled in
 */
function GetChallengeFileList(string UniqueChallengeId, out array<McpClashMobChallengeFile> OutChallengeFiles)
{
	local int Index;

	Index = ChallengeEvents.Find('unique_challenge_id', UniqueChallengeId);
	if (Index != INDEX_NONE)
	{
		OutChallengeFiles = ChallengeEvents[Index].file_list;
	}
}

/**
 * Starts the load/download of a challenge file by checking the cache first
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 */
function DownloadChallengeFile(string UniqueChallengeId, string DlName)
{
	local int AddAt;
	local int ChallengeIndex;
	local int FileIndex;

	AddAt = FileRequests.Length;
	FileRequests.Length = AddAt + 1;
	FileRequests[AddAt].ChallengeId = UniqueChallengeId;
	FileRequests[AddAt].DlName = DlName;

	ChallengeIndex = ChallengeEvents.Find('unique_challenge_id', UniqueChallengeId);
	if (ChallengeIndex != INDEX_NONE)
	{
		FileIndex = ChallengeEvents[ChallengeIndex].file_list.Find('dl_name', DlName);
		if (FileIndex != INDEX_NONE)
		{
			FileRequests[AddAt].FileName = ChallengeEvents[ChallengeIndex].file_list[FileIndex].file_name;
		}
	}

	if (FileCache != None)
	{
		FileCache.LoadTitleFile(FileRequests[AddAt].FileName);
	}
	else
	{
		// No cache interface so always download
		DownloadFile(UniqueChallengeId, DlName);
	}
}

/**
 * @return the hash for the specified file
 */
function String GetFileHash(String ChallengeId, String DlName)
{
	local int ChallengeIndex;
	local int FileIndex;

	ChallengeIndex = ChallengeEvents.Find('unique_challenge_id', ChallengeId);
	if (ChallengeIndex != INDEX_NONE)
	{
		FileIndex = ChallengeEvents[ChallengeIndex].file_list.Find('dl_name', DlName);
		if (FileIndex != INDEX_NONE)
		{
			return ChallengeEvents[ChallengeIndex].file_list[FileIndex].hash_code;
		}
	}
	return "";
}

/**
 * Called when the caching interface finishes loading a file
 */
function OnLoadCachedFileComplete(bool bWasSuccessful, string FileName)
{
	local bool bNeedsDownloading;
	local String TitleFileHash;
	local String ClashMobFileHash;
	local int RequestIndex;
	local int FileIndex;
	local array<byte> Data;
	local String ErrorString;

	RequestIndex = FileRequests.Find('FileName', FileName);
	if (RequestIndex != INDEX_NONE)
	{
		bNeedsDownloading = !bWasSuccessful;
		if (bWasSuccessful)
		{
			// Compare the title file hash versus what the ClashMob thinks
			TitleFileHash = FileCache.GetTitleFileHash(FileName);
			ClashMobFileHash = GetFileHash(FileRequests[RequestIndex].ChallengeId, FileRequests[RequestIndex].DlName);
			if (TitleFileHash == ClashMobFileHash)
			{
				`LogMcp("Hashes match so using the cached version of the file (" $ FileName $ ")");
				// This file is loaded, so copy the data and fire our delegate
				FileIndex = FindChallengeFileIndex(FileRequests[RequestIndex].ChallengeId, FileRequests[RequestIndex].DlName);
				if (FileIndex == INDEX_NONE)
				{
					FileIndex = ChallengeFiles.Length;
					ChallengeFiles.Length = FileIndex + 1;
				}
				// Store off the results
				ChallengeFiles[FileIndex].ChallengeId = FileRequests[RequestIndex].ChallengeId;
				ChallengeFiles[FileIndex].DlName = FileRequests[RequestIndex].DlName;
				FileCache.GetTitleFileContents(FileName, Data);
				ChallengeFiles[FileIndex].Data = Data;
				// Clear it so we don't keep multiple copies in memory
				FileCache.ClearCachedFile(FileName);
				OnDownloadChallengeFileComplete(true, FileRequests[RequestIndex].ChallengeId, FileRequests[RequestIndex].DlName, FileRequests[RequestIndex].FileName, "");
				FileRequests.Remove(RequestIndex, 1);
			}
			else
			{
				`LogMcp("Hashes did NOT match so downloading the file (" $ FileName $ ")");
				bNeedsDownloading = true;
			}
		}
		// If the file needs downloading, kick off the request
		if (bNeedsDownloading)
		{
			DownloadFile(FileRequests[RequestIndex].ChallengeId, FileRequests[RequestIndex].DlName);
		}
	}
	else
	{
		// This is bad
		ErrorString = "OnLoadCachedFileComplete - Missing information FileRequest for file (" $ FileName $ ")";
		OnDownloadChallengeFileComplete(false, "", FileName, "", ErrorString);
	}
}

/**
 * Starts the download of a challenge file
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 */
function DownloadFile(string UniqueChallengeId, string DlName)
{
	local String Url;
	local String Path;
	local HttpRequestInterface Request;
	local int RequestIndex;
	local String ErrorString;

	RequestIndex = FileRequests.Find('DlName', DlName);
	if (RequestIndex != INDEX_NONE)
	{
		Request = CreateHttpRequestGameAuth();
		FileRequests[RequestIndex].Request = Request;

		Path = Repl(ChallengeFilePath, "{challengeId}", UniqueChallengeId);
		Path = Repl(Path, "{fileName}", DlName);
		Url = GetBaseURL() $ Path;
		`LogMcp("DownloadChallengeFile URL is GET " $ Url);

		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnDownloadChallengeFileRequestComplete);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			ErrorString = "Failed to start DownloadChallengeFile web request for URL(" $ Url $ ")";
			`LogMcp(ErrorString);
			FileRequests.Remove(RequestIndex, 1);
			OnDownloadChallengeFileComplete(false, UniqueChallengeId, DlName, FileRequests[RequestIndex].FileName, ErrorString);
		}
	}
	else
	{
		// This is bad
		ErrorString = "Missing information FileRequest for file (" $ DlName $ ")";
		OnDownloadChallengeFileComplete(false, UniqueChallengeId, DlName, "", ErrorString);
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnDownloadChallengeFileRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local int RequestIndex;
	local int FileIndex;
	local array<byte> Data;

	RequestIndex = FileRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			// Store the data off for this file
			FileIndex = FindChallengeFileIndex(FileRequests[RequestIndex].ChallengeId, FileRequests[RequestIndex].DlName);
			if (FileIndex == INDEX_NONE)
			{
				FileIndex = ChallengeFiles.Length;
				ChallengeFiles.Length = FileIndex + 1;
			}
			// Store off the results
			ChallengeFiles[FileIndex].ChallengeId = FileRequests[RequestIndex].ChallengeId;
			ChallengeFiles[FileIndex].DlName = FileRequests[RequestIndex].DlName;
			Response.GetContent(Data);
			ChallengeFiles[FileIndex].Data = Data;
			// Write the file to the cache for re-use
			if (FileCache != None)
			{
				FileCache.SaveTitleFile(FileRequests[RequestIndex].FileName, FileRequests[RequestIndex].DlName, Data);
			}
		}
		else
		{
			ErrorString = "DownloadChallengeFile failed with response code (" $ ResponseCode $ ")";
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnDownloadChallengeFileComplete(bWasSuccessful, FileRequests[RequestIndex].ChallengeId, FileRequests[RequestIndex].DLName, FileRequests[RequestIndex].FileName, ErrorString);
		FileRequests.Remove(RequestIndex, 1);
	}
}

/** @return the index to the file if found */
function int FindChallengeFileIndex(string UniqueChallengeId, string DlName)
{
	local int FileIndex;

	// Search our list for the requested file
	for (FileIndex = 0; FileIndex < ChallengeFiles.Length; FileIndex++)
	{
		if (ChallengeFiles[FileIndex].ChallengeId == UniqueChallengeId &&
			ChallengeFiles[FileIndex].DlName == DlName)
		{
			return FileIndex;
		}
	}
	return INDEX_NONE;
}

/**
 * Access the cached copy of the file data
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 * @param OutFileContents byte array filled in with the file contents
 */
function GetChallengeFileContents(string UniqueChallengeId, string DlName, out array<byte> OutFileContents)
{
	local int FileIndex;

	OutFileContents.Length = 0;
	FileIndex = FindChallengeFileIndex(UniqueChallengeId, DlName);
	if (FileIndex != INDEX_NONE)
	{
		OutFileContents = ChallengeFiles[FileIndex].Data;
	}
}

/**
 * Clear the cached memory copy of a challenge file
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 */
function ClearCachedChallengeFile(string UniqueChallengeId, string DlName)
{
	local int FileIndex;

	FileIndex = FindChallengeFileIndex(UniqueChallengeId, DlName);
	if (FileIndex != INDEX_NONE)
	{
		ChallengeFiles[FileIndex].Data.Length = 0;
	}
}

/**
 * Clear the cached memory copy of a challenge file
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 */
function DeleteCachedChallengeFile(string UniqueChallengeId, string DlName)
{
	local int FileIndex;

	FileIndex = FindChallengeFileIndex(UniqueChallengeId, DlName);
	if (FileIndex != INDEX_NONE)
	{
		ChallengeFiles.Remove(FileIndex, 1);
	}
}

/**
 * Builds the URL for a specific challenge for a user
 */
function String BuildUserChallengePath(String ChallengeId)
{
	local String Path;
	
	Path = Repl(UserChallengePath, "{challengeId}", ChallengeId);

	return GetBaseURL() $ Path;
}

/**
 * Builds the URL for a specific challenge for a user
 */
function String BuildUserChallengeUpdatePath(String ChallengeId, String McpId, String SaveSlotId)
{
	local String Path;
	
	Path = Repl(UserChallengeUpdatePath, "{challengeId}", ChallengeId);
	Path = Repl(Path, "{epicId}", McpId);
	Path = Repl(Path, "{saveSlotId}", SaveSlotId);

	return GetBaseURL() $ Path;
}

/**
 * Initiates a web request to have user accept a challenge
 *
 * @param UniqueChallengeId id of challenge to accept
 * @param UniqueUserId id of user that wants to accept challenge
 * @param SaveSlotId a profile id
 * @param bLiked is this an update because the user liked a page?
 * @param bCommented is this an update because the user commented on a page?
 * @param bRetweeted is this an update because the user bRetweeted a message?
 */
function AcceptChallenge(string UniqueChallengeId, string UniqueUserId, String SaveSlotId, bool bLiked=false, bool bCommented = false, bool bRetweeted=false)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(UniqueUserId);

	Url = BuildUserChallengeUpdatePath(UniqueChallengeId, UniqueUserId, SaveSlotId) $ "?liked="$bLiked $ "&commented="$bCommented $ "&retweeted="$bRetweeted;
	`LogMcp("AcceptChallenge URL is POST " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("POST");
	Request.SetProcessRequestCompleteDelegate(OnAcceptChallengeRequestComplete);

	AddAt = UserRequests.Length;
	UserRequests.Length = AddAt + 1;
	UserRequests[AddAt].Request = Request;
	UserRequests[AddAt].McpId = UniqueUserId;
	UserRequests[AddAt].ChallengeId = UniqueChallengeId;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start AcceptChallenge web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnAcceptChallengeRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int RequestIndex;

	RequestIndex = UserRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
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
			ErrorString = "AcceptChallenge failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnAcceptChallengeComplete(bWasSuccessful, UserRequests[RequestIndex].ChallengeId, UserRequests[RequestIndex].McpId, ErrorString);
		UserRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Initiates a web request to retrieve the current status of a challenge for a user
 *
 * @param UniqueChallengeId id of challenge to query
 * @param UniqueUserId id of user to retrieve challenge status for
 * @param bWantsParentChildData true to fetch parent and child information in one request, false to just get a single challenge's data
 */
function QueryChallengeUserStatus(string UniqueChallengeId, string UniqueUserId, optional bool bWantsParentChildData)
{
	local array<String> McpIds;

	McpIds.AddItem(UniqueUserId);

	QueryChallengeMultiUserStatus(UniqueChallengeId, UniqueUserId, McpIds, 0, bWantsParentChildData);
}

/**
 * Initiates a web request to retrieve the current status of a challenge for a list of users user
 *
 * @param UniqueChallengeId id of challenge to query
 * @param UniqueUserId id of user that is initiating the request
 * @param UserIdsToRead list of ids to read status for
 * @param AdditionalParticipantCount the number of recent participants to return in addition to the list
 * @param bWantsParentChildData true to fetch parent and child information in one request, false to just get a single challenge's data
 */
function QueryChallengeMultiUserStatus(string UniqueChallengeId, string UniqueUserId, const out array<string> UserIdsToRead, optional int AdditionalParticipantCount, optional bool bWantsParentChildData)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String JsonPayload;
	local int Index;

	Request = CreateHttpRequest(UniqueUserId);

	Url = BuildUserChallengePath(UniqueChallengeId);
	if (AdditionalParticipantCount > 0)
	{
		Url $= "?additionalParticipantCount=" $ AdditionalParticipantCount;
	}
	if (bWantsParentChildData)
	{
		Url $= "?wantsParentChildInfo=" $ bWantsParentChildData;
	}
	`LogMcp("QueryChallengeUserStatus URL is POST " $ Url);

	// Make a json string from our list of ids
	JsonPayload = "[ ";
	for (Index = 0; Index < UserIdsToRead.Length; Index++)
	{
		if (Len(UserIdsToRead[Index]) > 0)
		{
			JsonPayload $= "\"" $ UserIdsToRead[Index] $ "\"";
			if (Index + 1 < UserIdsToRead.Length)
			{
				JsonPayload $= ",";
			}
		}
	}
	JsonPayload $= " ]";
	`log("QueryChallengeMultiUserStatus JsonPayLoad:"$JsonPayload);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("POST");
	Request.SetContentAsString(JsonPayload);
	Request.SetProcessRequestCompleteDelegate(OnQueryChallengeUserStatusRequestComplete);

	AddAt = UserRequests.Length;
	UserRequests.Length = AddAt + 1;
	UserRequests[AddAt].Request = Request;
	UserRequests[AddAt].McpId = UniqueUserId;
	UserRequests[AddAt].ChallengeId = UniqueChallengeId;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start QueryChallengeUserStatus web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnQueryChallengeUserStatusRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int RequestIndex;

	RequestIndex = UserRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
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
			bWasSuccessful = ParseUserChallengeStatuses(ResponseString);
			if (!bWasSuccessful)
			{
				ErrorString = "QueryChallengeUserStatus failed to parse JSON:\n" $ ResponseString;
			}
		}
		else
		{
			ErrorString = "QueryChallengeUserStatus failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnQueryChallengeUserStatusComplete(bWasSuccessful, UserRequests[RequestIndex].ChallengeId, UserRequests[RequestIndex].McpId, ErrorString);
		UserRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Parses a JSON payload into a set of user statuses for a ClashMob
 *
 * @param Json the json string to parse
 *
 * @return true if the payload parsed correctly, false otherwise
 */
function bool ParseUserChallengeStatuses(String Json)
{
	local JsonObject ParsedJson, JsonElement;
	local int JsonIndex;

	ParsedJson = class'JsonObject'.static.DecodeJson(Json);
	// Parse each file, adding them if needed
	for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
	{
		JsonElement = ParsedJson.ObjectArray[JsonIndex];
		if (!ParseUserChallengeStatus(JsonElement))
		{
			return false;
		}
	}
	return true;
}

/**
 * Copies the properties from a JSON node to a ClashMob struct entry
 *
 * @param JsonNode the json object to copy data from
 *
 * @return true if the payload parsed correctly, false otherwise
 */
function bool ParseUserChallengeStatus(JsonObject JsonNode)
{
	local int Index;
	local bool bWasFound;
	local String UniqueChallengeId;
	local String MissingKey;
	local String McpId;
	local String SaveSlotId;

	if (!JsonNode.HasKey("challengeId") || !JsonNode.HasKey("epicId") || !JsonNode.HasKey("saveSlotId"))
	{
		return false;
	}
	UniqueChallengeId = JsonNode.GetStringValue("challengeId");
	McpId = JsonNode.GetStringValue("epicId");
	SaveSlotId = JsonNode.GetStringValue("saveSlotId");

	// Search the array for challenge/user pair
	for (Index = 0; Index < ChallengeStatuses.Length; Index++)
	{
		if (ChallengeStatuses[Index].unique_challenge_id == UniqueChallengeId &&
			ChallengeStatuses[Index].unique_user_id == McpId &&
			ChallengeStatuses[Index].save_slot_id == saveSlotId)
		{
			bWasFound = true;
			break;
		}
	}

	if (!bWasFound)
	{
		// Not in our list, so add it
		Index = ChallengeStatuses.Length;
		ChallengeStatuses.Length = Index + 1;
		ChallengeStatuses[Index].unique_challenge_id = UniqueChallengeId;
		ChallengeStatuses[Index].unique_user_id = McpId;
		ChallengeStatuses[Index].save_slot_id = saveSlotId;
	}

	if (JsonNode.HasKey("numAttempts"))
	{
		ChallengeStatuses[Index].num_attempts = JsonNode.GetIntValue("numAttempts");
	}
	else
	{
		MissingKey = "numAttempts";
	}
	if (JsonNode.HasKey("numSuccessfulAttempts"))
	{
		ChallengeStatuses[Index].num_successful_attempts = JsonNode.GetIntValue("numSuccessfulAttempts");
	}
	else
	{
		MissingKey = "numSuccessfulAttempts";
	}
	if (JsonNode.HasKey("goalProgress"))
	{
		ChallengeStatuses[Index].goal_progress = JsonNode.GetIntValue("goalProgress");
	}
	else
	{
		MissingKey = "goalProgress";
	}
	if (JsonNode.HasKey("didComplete"))
	{
		ChallengeStatuses[Index].did_complete = JsonNode.GetBoolValue("didComplete");
	}
	else
	{
		MissingKey = "didComplete";
	}
	if (JsonNode.HasKey("lastUpdateTime"))
	{
		ChallengeStatuses[Index].last_update_time = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("lastUpdateTime"));
	}
	else
	{
		MissingKey = "lastUpdateTime";
	}
	if (JsonNode.HasKey("userAwardGiven"))
	{
		ChallengeStatuses[Index].user_award_given = JsonNode.GetIntValue("userAwardGiven");
	}
	else
	{
		MissingKey = "userAwardGiven";
	}
	if (JsonNode.HasKey("acceptTime"))
	{
		ChallengeStatuses[Index].accept_time = ServerDateTimeToUnrealDateTime(JsonNode.GetStringValue("acceptTime"));
	}
	else
	{
		MissingKey = "acceptTime";
	}
	if (JsonNode.HasKey("didPreregister"))
	{
		ChallengeStatuses[Index].did_preregister = JsonNode.GetBoolValue("didPreregister");
	}
	else
	{
		MissingKey = "didPreregister";
	}
	if (JsonNode.HasKey("likedViaFacebook"))
	{
		ChallengeStatuses[Index].liked_Via_Facebook = JsonNode.GetBoolValue("likedViaFacebook");
	}
	else
	{
		MissingKey = "likedViaFacebook";
	}
	if (JsonNode.HasKey("commentedViaFacebook"))
	{
		ChallengeStatuses[Index].commented_Via_Facebook = JsonNode.GetBoolValue("commentedViaFacebook");
	}
	else
	{
		MissingKey = "commentedViaFacebook";
	}
	if (JsonNode.HasKey("retweeted"))
	{
		ChallengeStatuses[Index].retweeted = JsonNode.GetBoolValue("retweeted");
	}
	else
	{
		MissingKey = "retweeted";
	}
	if (JsonNode.HasKey("highGoalProgress"))
	{
		ChallengeStatuses[Index].HighGoalProgress = JsonNode.GetIntValue("highGoalProgress");
	}
	if (JsonNode.HasKey("rank"))
	{
		ChallengeStatuses[Index].Rank = JsonNode.GetIntValue("rank");
	}
	if (JsonNode.HasKey("percentRank"))
	{
		ChallengeStatuses[Index].PercentRank = JsonNode.GetFloatValue("percentRank");
	}

	if (MissingKey != "")
	{
		`LogMcp("JSON failed to parse missing key: " $ MissingKey);
		// Clear out any data that might be there from a partial parse
		ChallengeStatuses.Remove(Index, 1);
	}
	return MissingKey == "";
}

/**
 * Get the cached status of a user for a challenge. Use QueryChallengeUserStatus first
 *
 * @param UniqueChallengeId id of challenge to retrieve
 * @param McpId id of user to retrieve challenge status for
 * @param OutChallengeUserStatus user status values to be filled in
 */
function GetChallengeUserStatus(string UniqueChallengeId, string McpId, out array<McpClashMobChallengeUserStatus> OutChallengeUserStatuses)
{
	local int Index;

	// Search the array for challenge/user pair
	for (Index = 0; Index < ChallengeStatuses.Length; Index++)
	{
		if (ChallengeStatuses[Index].unique_challenge_id == UniqueChallengeId &&
			ChallengeStatuses[Index].unique_user_id == McpId)
		{
			OutChallengeUserStatuses.AddItem(ChallengeStatuses[Index]);
			return;
		}
	}
}

/**
 * Get the cached status of a user for a challenge. Use QueryChallengeUserStatus first
 *
 * @param UniqueChallengeId id of challenge to retrieve
 * @param McpId id of user to retrieve challenge status for
 * @param OutChallengeUserStatus user status values to be filled in
 * @return true if record was found, false otherwise
 */
function bool GetChallengeUserStatusForSaveSlot(string UniqueChallengeId, string McpId, String SaveSlotId, out McpClashMobChallengeUserStatus OutChallengeUserStatus)
{
	local int Index;

	// Search the array for challenge/user pair
	for (Index = 0; Index < ChallengeStatuses.Length; Index++)
	{
		if (ChallengeStatuses[Index].unique_challenge_id == UniqueChallengeId &&
			ChallengeStatuses[Index].unique_user_id == McpId &&
			ChallengeStatuses[Index].save_slot_id == SaveSlotId)
		{
			OutChallengeUserStatus = ChallengeStatuses[Index];
			return true;
		}
	}
	return false;
}

/**
 * Initiates a web request to update the current progress of a challenge for a user
 *
 * @param UniqueChallengeId id of challenge to update
 * @param UniqueUserId id of user to update challenge progress for
 */
function UpdateChallengeUserProgress(string UniqueChallengeId, string UniqueUserId, String SaveSlotId, bool bDidComplete, int GoalProgress)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(UniqueUserId);

	Url = BuildUserChallengeUpdatePath(UniqueChallengeId, UniqueUserId, SaveSlotId) $ "/updateProgress?didComplete=" $ bDidComplete $ "&goalProgress=" $ GoalProgress;
	`LogMcp("UpdateChallengeUserProgress URL is POST " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("POST");
	Request.SetProcessRequestCompleteDelegate(OnUpdateChallengeUserProgressRequestComplete);

	AddAt = UserRequests.Length;
	UserRequests.Length = AddAt + 1;
	UserRequests[AddAt].Request = Request;
	UserRequests[AddAt].McpId = UniqueUserId;
	UserRequests[AddAt].ChallengeId = UniqueChallengeId;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start UpdateChallengeUserProgress web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnUpdateChallengeUserProgressRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int RequestIndex;

	RequestIndex = UserRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
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
			ErrorString = "UpdateChallengeUserProgress failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnUpdateChallengeUserProgressComplete(bWasSuccessful, UserRequests[RequestIndex].ChallengeId, UserRequests[RequestIndex].McpId, ErrorString);
		UserRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Initiates a web request to update the current reward given to a user for a challenge
 *
 * @param UniqueChallengeId id of challenge to update
 * @param UniqueUserId id of user to update challenge progress for
 */
function UpdateChallengeUserReward(string UniqueChallengeId, string UniqueUserId, String SaveSlotId, int UserReward)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(UniqueUserId);

	Url = BuildUserChallengeUpdatePath(UniqueChallengeId, UniqueUserId, SaveSlotId) $ "/updateReward?rewardValue=" $ UserReward;
	`LogMcp("UpdateChallengeUserReward URL is POST " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("POST");
	Request.SetProcessRequestCompleteDelegate(OnUpdateChallengeUserRewardRequestComplete);

	AddAt = UserRequests.Length;
	UserRequests.Length = AddAt + 1;
	UserRequests[AddAt].Request = Request;
	UserRequests[AddAt].McpId = UniqueUserId;
	UserRequests[AddAt].ChallengeId = UniqueChallengeId;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start UpdateChallengeUserReward web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnUpdateChallengeUserRewardRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int RequestIndex;

	RequestIndex = UserRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
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
			ErrorString = "UpdateChallengeUserReward failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnUpdateChallengeUserRewardComplete(bWasSuccessful, UserRequests[RequestIndex].ChallengeId, UserRequests[RequestIndex].McpId, ErrorString);
		UserRequests.Remove(RequestIndex, 1);
	}
}
