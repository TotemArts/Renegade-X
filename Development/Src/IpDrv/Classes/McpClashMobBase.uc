/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Provides the interface for ClashMob Mcp services
 */
class McpClashMobBase extends McpServiceBase
	abstract
	config(Engine);

/** The class name to use in the factory method to create our instance */
var config String McpClashMobClassName;

enum McpChallengeFileStatus
{
	/** No action yet */
	MCFS_NotStarted,
	/** Cache load or web download pending */
	MCFS_Pending,
	/** Data was successfully loaded */
	MCFS_Success,
	/** Data was not successfully loaded */
	MCFS_Failed
};

/** Single file entry that can be downloaded for a challenge */
struct McpClashMobChallengeFile
{
	// JSON imported properties
	var bool should_keep_post_challenge;
	var string title_id;
	var string file_name;
	var string dl_name;
	var string hash_code;
	var string type;

	/** Status of file load/download */
	var McpChallengeFileStatus Status;
};

/** Parameters of a push notification */
struct McpClashMobPushNotificationParams
{
	// JSON imported properties
	var int bah;
};

/* Info about notifications that will be triggered for a challenge */
struct McpClashMobPushNotification
{
	// JSON imported properties
	var array<string> device_tokens;
	var string badge_type;
	var string sound;
	var string message;
	var McpClashMobPushNotificationParams params;
};

struct McpChildClashMobEntry
{
	/** The order the challenges will progress in */
	var int Order;
	/** The id of the child challenge */
	var String ChildChallengeId;
};

/**
 * Describes the various ways a player can progress to the next child challenge
 */
enum McpChildChallengeGatingType
{
	MCCGT_NONE, MCCGT_SUCCESS, MCCGT_RAW_SCORE, MCCGT_TOP_N_PERCENT, MCCGT_TOP_N_ENTRIES
};

/**
 * Describes the various ways a player can be ranked on "leaderboard"
 */
enum McpChallengeRatingType
{
	MCRT_NOT_RATED, MCRT_TOTAL_PROGRESS, MCRT_HIGH_PROGRESS
};

/** Single challenge event that is queried from the server */
struct McpClashMobChallengeEvent
{
	// JSON imported properties
	var string unique_challenge_id;
	var string visible_date;
	var string start_date;
	var string end_date;
	var string completed_date;
	var string purge_date;
	var string challenge_type;
	var int num_attempts;
	var int num_successful_attempts;
	var int goal_value;
	var int goal_start_value;
	var int goal_current_value;
	var bool has_started;
	var bool is_visible;
	var bool has_completed;
	var bool was_successful;
	var array<McpClashMobChallengeFile> file_list;
	var int facebook_likes;
	var int facebook_comments;
	var float facebook_like_scaler;
	var float facebook_comment_scaler;
	var int facebook_like_goal_progress;
	var int facebook_comment_goal_progress;
	var string facebook_id;
	var int twitter_retweets;
	var float twitter_retweets_scaler;
	var int twitter_goal_progress;
	var string twitter_id;
	// ClashMob 2.0 properties
	var String StartedAt;
	var String ParentChallengeId;
	var array<McpChildClashMobEntry> ChildChallengeList;
	var String ActiveChildChallengeId;
	var McpChildChallengeGatingType ChildChallengeGatingType;
	var float ChildChallengeGatingValue;
	var McpChallengeRatingType ChallengeRatingType;
	var int MinChallengeDuration;
};

/** Current user status with respect to a single challenge event that is queried from the server */
struct McpClashMobChallengeUserStatus
{
	// JSON imported properties
	var string unique_challenge_id;
	var string unique_user_id;
	var string save_slot_id;
	var int num_attempts;
	var int num_successful_attempts;
	var int goal_progress;
	var bool did_complete;
	var string last_update_time;
	var int user_award_given;
	var string accept_time;
	var bool did_preregister;
	var string facebook_like_time;
	var bool enrolled_via_facebook;
	var bool liked_via_facebook;
	var bool commented_via_facebook;
	var string twitter_retweet_time;
	var bool enrolled_via_twitter;
	var bool retweeted;
	// ClashMob 2.0 properties
	var int HighGoalProgress;
	var float PercentRank;
	var int Rank;
};

/**
 * @return the object that implements this interface or none if missing or failed to create/load
 */
final static function McpClashMobBase CreateInstance()
{
	local class<McpClashMobBase> McpClashMobBaseClass;
	local McpClashMobBase NewInstance;

	McpClashMobBaseClass = class<McpClashMobBase>(DynamicLoadObject(default.McpClashMobClassName,class'Class'));
	// If the class was loaded successfully, create a new instance of it
	if (McpClashMobBaseClass != None)
	{
		NewInstance = McpClashMobBase(GetSingleton(McpClashMobBaseClass));
	}

	return NewInstance;
}

/**
 * Delegate called when the challenge list query has completed
 *
 * @param bWasSuccessful true if the challenge list was retrieved from the server
 * @param Error info string about why the error occurred
 */
delegate OnQueryChallengeListComplete(bool bWasSuccessful, String Error);

/**
 * Initiates a web request to retrieve the list of available challenge events from the server.
 */
function QueryChallengeList(String McpId);

/**
 * Access the currently cached challenge list that was downloaded. Use QueryChallengeList first
 *
 * @param OutChallengeEvents the list of events that should be filled in
 */
function GetChallengeList(out array<McpClashMobChallengeEvent> OutChallengeEvents);

/**
 * Find a specific challenge.
 * 
 * @param UniqueChallengeId Id to look for
 * @param OutChallengeEvent the challenge found
 * @return bool true if found
 */
function bool GetChallenge(String UniqueChallengeId, out McpClashMobChallengeEvent OutChallengeEvent);

/**
 * Initiates a web request to retrieve the data for a specific challenge
 */
function QueryChallenge(String ChallengeId);

/**
 * Initiates a web request to retrieve the data for a specific parent challenge and all its children
 */
function QueryParentChallenge(String ChallengeId);

/**
 * Delegate called when the challenge list query has completed
 *
 * @param bWasSuccessful true if the challenge list was retrieved from the server
 * @param ChallengeId the challenge that was queried
 * @param Error info string about why the error occurred
 */
delegate OnQueryChallengeComplete(bool bWasSuccessful, String ChallengeId, String Error);


/**
 * Delegate called when a single challenge file is loaded/downloaded
 *
 * @param bWasSuccessful true if the file was loaded from cache or downloaded from server
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 * @param FileName logical name of the file
 * @param Error info string about why the error occurred
 */
delegate OnDownloadChallengeFileComplete(bool bWasSuccessful, string UniqueChallengeId, string DlName, string FileName, string Error);

/**
 * Get the list of files for a given challenge
 *
 * @param UniqueChallengeId id of challenge that may have files
 * @param OutChallengeFiles list of files that should be filled in
 */
function GetChallengeFileList(string UniqueChallengeId, out array<McpClashMobChallengeFile> OutChallengeFiles);

/**
 * Starts the load/download of a challenge file
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 */
function DownloadChallengeFile(string UniqueChallengeId, string DlName);

/**
 * Access the cached copy of the file data
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 * @param OutFileContents byte array filled in with the file contents
 */
function GetChallengeFileContents(string UniqueChallengeId, string DlName, out array<byte> OutFileContents);

/**
 * Clear the cached memory copy of a challenge file
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 */
function ClearCachedChallengeFile(string UniqueChallengeId, string DlName);

/**
 * Clear the cached memory copy of a challenge file
 *
 * @param UniqueChallengeId id of challenge that owns the file
 * @param DlName download name of the file
 */
function DeleteCachedChallengeFile(string UniqueChallengeId, string DlName);

/**
 * Called when the web request to have user accept a challenge completes
 *
 * @param bWasSuccessful true if request completed successfully
 * @param UniqueChallengeId id of challenge to accept
 * @param UniqueUserId id of user that wants to accept challenge
 * @param Error info string about why the error occurred
 */
delegate OnAcceptChallengeComplete(bool bWasSuccessful, string UniqueChallengeId, string UniqueUserId, String Error);

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
function AcceptChallenge(string UniqueChallengeId, string UniqueUserId, String SaveSlotId, bool bLiked=false, bool bCommented = false, bool bRetweeted=false);

/**
 * Called when the web request to retrieve the current status of a challenge for a user completes
 *
 * @param bWasSuccessful true if request completed successfully
 * @param UniqueChallengeId id of challenge to query
 * @param UniqueUserId id of user to retrieve challenge status for
 * @param Error info string about why the error occurred
 */
delegate OnQueryChallengeUserStatusComplete(bool bWasSuccessful, string UniqueChallengeId, string UniqueUserId, String Error);

/**
 * Initiates a web request to retrieve the current status of a challenge for a user
 *
 * @param UniqueChallengeId id of challenge to query
 * @param UniqueUserId id of user to retrieve challenge status for
 * @param bWantsParentChildData true to fetch parent and child information in one request, false to just get a single challenge's data
 */
function QueryChallengeUserStatus(string UniqueChallengeId, string UniqueUserId, optional bool bWantsParentChildData);

/**
 * Initiates a web request to retrieve the current status of a challenge for a list of users user
 *
 * @param UniqueChallengeId id of challenge to query
 * @param UniqueUserId id of user that is initiating the request
 * @param UserIdsToRead list of ids to read status for
 * @param AdditionalParticipantCount the number of recent participants to return in addition to the list
 * @param bWantsParentChildData true to fetch parent and child information in one request, false to just get a single challenge's data
 */
function QueryChallengeMultiUserStatus(string UniqueChallengeId, string UniqueUserId, const out array<string> UserIdsToRead, optional int AdditionalParticipantCount, optional bool bWantsParentChildData);

/**
 * Get the cached status of a user for a challenge. Use QueryChallengeUserStatus first
 *
 * @param UniqueChallengeId id of challenge to retrieve
 * @param UniqueUserId id of user to retrieve challenge status for
 * @param OutChallengeUserStatus user status values to be filled in
 */
function GetChallengeUserStatus(string UniqueChallengeId, string UniqueUserId, out array<McpClashMobChallengeUserStatus> OutChallengeUserStatuses);

/**
 * Get the cached status of a user for a challenge. Use QueryChallengeUserStatus first
 *
 * @param UniqueChallengeId id of challenge to retrieve
 * @param UniqueUserId id of user to retrieve challenge status for
 * @param OutChallengeUserStatus user status values to be filled in
 * @return true if record was found, false otherwise
  */
function bool GetChallengeUserStatusForSaveSlot(string UniqueChallengeId, string UniqueUserId, String SaveSlotId, out McpClashMobChallengeUserStatus OutChallengeUserStatus);

/**
 * Called when the web request to update the current progress of a challenge for a user completes
 *
 * @param bWasSuccessful true if request completed successfully
 * @param UniqueChallengeId id of challenge to update
 * @param UniqueUserId id of user to update challenge progress for
 * @param Error info string about why the error occurred
 */
delegate OnUpdateChallengeUserProgressComplete(bool bWasSuccessful, string UniqueChallengeId, string UniqueUserId, String Error);

/**
 * Initiates a web request to update the current progress of a challenge for a user
 *
 * @param UniqueChallengeId id of challenge to update
 * @param UniqueUserId id of user to update challenge progress for
 * @param SaveSlotId the save slot that is updating their progress
 */
function UpdateChallengeUserProgress(string UniqueChallengeId, string UniqueUserId, String SaveSlotId, bool bDidComplete, int GoalProgress);

/**
 * Called when the web request to update the current reward of a challenge for a user completes
 *
 * @param bWasSuccessful true if request completed successfully
 * @param UniqueChallengeId id of challenge to update
 * @param UniqueUserId id of user to update challenge progress for
 * @param Error info string about why the error occurred
 */
delegate OnUpdateChallengeUserRewardComplete(bool bWasSuccessful, string UniqueChallengeId, string UniqueUserId, String Error);

/**
 * Initiates a web request to update the current reward given to a user for a challenge
 *
 * @param UniqueChallengeId id of challenge to update
 * @param UniqueUserId id of user to update challenge progress for
 * @param SaveSlotId the save slot that is updating their progress
 */
function UpdateChallengeUserReward(string UniqueChallengeId, string UniqueUserId, String SaveSlotId, int UserReward);

