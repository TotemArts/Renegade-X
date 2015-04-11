/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Provides the interface for posting to and creating chat threads with the server
 */
class McpThreadedChatBase extends McpServiceBase
	abstract
	config(Engine);

/** The class name to use in the factory method to create our instance */
var config String McpThreadedChatClassName;

struct McpSystemChatThread
{
	/** Name of the thread for synchronizing with the game */
	var String ThreadName;
	/** Unique id of the thread on the backend */
	var String ThreadId;
};

struct McpUserChatThread extends McpSystemChatThread
{
	/** The McpId of the person that created this thread */
	var String OwnerId;
};

struct McpChatPost
{
	/**
	 * The id of the post
	 */
	var String PostId;
	/**
	 * The thread this post corresponds to
	 */
	var String ThreadId;
	/**
	 * The user that sent the message
	 */
	var String OwnerId;
	/**
	 * The name of the user that is posting this message
	 */
	var String OwnerName;
	/**
	 * Some ranking value associated with this user's posting habits
	 */
	var float ownerRank;
	/**
	 * The contents of the message
	 */
	var String Message;
	/**
	 * Whether this message has been checked for profanity or not
	 */
	var bool bProfanityChecked;
	/**
	 * Whether this was reported by a user or not
	 */
	var bool bReported;
	/**
	 * The number of times this was voted up
	 */
	var int VoteUpCount;
	/**
	 * The number of times this was voted down
	 */
	var int VoteDownCount;
	/**
	 * Always holds the difference between up count and down count
	 */
	var int Popularity;
	/**
	 * The time this message was created
	 */
	var String Timestamp;
	/**
	 * The user that this is in reply to
	 */
	var String ReplyToOwnerId;
	/**
	 * The name of the user that this is in reply to
	 */
	var String ReplyToOwnerName;
	/**
	 * The post that this is in reply to
	 */
	var String ReplyToPostId;
};

/**
 * @return the object that implements this interface or none if missing or failed to create/load
 */
final static function McpThreadedChatBase CreateInstance()
{
	local class<McpThreadedChatBase> McpThreadedChatBaseClass;
	local McpThreadedChatBase NewInstance;

	McpThreadedChatBaseClass = class<McpThreadedChatBase>(DynamicLoadObject(default.McpThreadedChatClassName, class'Class'));
	// If the class was loaded successfully, create a new instance of it
	if (McpThreadedChatBaseClass != None)
	{
		NewInstance = McpThreadedChatBase(GetSingleton(McpThreadedChatBaseClass));
	}

	return NewInstance;
}

/**
 * Initiates a query with the backend to get the list of system chat threads
 */
function ReadSystemChatThreads();

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param Error string representing the error condition
 */
delegate OnReadSystemChatThreadsComplete(bool bWasSuccessful, String Error);

/**
 * Returns the set of known system wide chat threads
 */
function GetSystemChatThreads(out array<McpSystemChatThread> SystemChatThreads);

/**
 * Initiates a query with the backend to get the list of a particular user's chat threads
 */
function ReadUserChatThreads(String McpId);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param Error string representing the error condition
 */
delegate OnReadUserChatThreadsComplete(bool bWasSuccessful, String McpId, String Error);

/**
 * Returns the set of chat threads owned by the specified id
 */
function GetUserChatThreads(String McpId, out array<McpUserChatThread> UserChatThreads);

/**
 * Creates a new user chat thread with the specified name
 */
function CreateUserChatThread(String McpId, String ThreadName);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param Error string representing the error condition
 */
delegate OnCreateUserChatThreadComplete(bool bWasSuccessful, String McpId, String ThreadName, String Error);

/**
 * Reads a chunk of posts from a thread based upon time and count
 *
 * @param ThreadId the thread to read the posts for
 * @param Before the time of the last message that you want to read from
 * @param Count the number of posts to read
 */
function ReadChatPostsByTime(String ThreadId, String Before = "", int Count = 20);

/**
 * Reads a chunk of posts from a thread based by or in reply to a set of users
 *
 * @param ThreadId the thread to read the posts for or empty to request all threads for the user
 * @param McpIds the list of users that we're querying posts for
 * @param Start the post to start from (0 is first post)
 * @param Count the number of posts to read
 */
function ReadChatPostsForUsers(String ThreadId, const out array<String> McpIds, optional int Start = 0, optional int Count = 20);

/**
 * Reads a chunk of posts from a thread based upon time and count
 *
 * @param ThreadId the thread to read the posts for
 * @param Start the post to start from (0 is first post)
 * @param Count the number of posts to read
 */
function ReadChatPostsByPopularity(String ThreadId, int Start = 0, int Count = 20);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param Error string representing the error condition
 */
delegate OnReadChatPostsComplete(bool bWasSuccessful, String ThreadId, String Error);

/**
 * Reads a chunk of posts from a thread based by or in reply to a user
 *
 * @param McpId the user that we're querying posts for
 * @param ThreadId the thread to read the posts for or empty to request all threads for the user
 * @param Start the post to start from (0 is first post)
 * @param Count the number of posts to read
 */
function ReadChatPostsConcerningUser(String McpId, optional String ThreadId, optional int Start = 0, optional int Count = 20);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param ThreadId empty if this was for all threads or the thread id if a specific thread
 * @param McpId the user that the query was for
 * @param Error string representing the error condition
 */
delegate OnReadChatPostsConcerningUserComplete(bool bWasSuccessful, String ThreadId, String McpId, String Error);

/**
 * Returns the set of chat posts for a given user in a given thread or all threads
 */
function GetChatPostsForUser(String McpId, out array<McpChatPost> ChatPosts, optional String ThreadId);

/**
 * Returns the set of chat posts in a given thread
 */
function GetChatPosts(String ThreadId, out array<McpChatPost> ChatPosts);

/**
 * Empties the set of chat posts in a specific thread (save memory)
 */
function ClearChatPosts(String ThreadId);

/**
 * Posts a message to a thread
 *
 * @param ThreadId the thread to post to
 * @param McpId the user posting the message
 * @param OwnerName the nickname to use with the message
 * @param Message the message to post
 * @param ReplyToOwnerId the id of the owner of the previous post
 * @param ReplyToOwnerName the name of the owner of the previous post
 */
function PostToThread(String ThreadId, String McpId, String OwnerName, String Message, optional String ReplyToMessageId, optional String ReplyToOwnerId, optional String ReplyToOwnerName);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param Error string representing the error condition
 */
delegate OnPostToThreadComplete(bool bWasSuccessful, String ThreadId, String McpId, String Error);

/**
 * Marks a post as being questionable
 *
 * @param ThreadId the thread to post to
 * @param PostId the id of the post being flagged
 * @param McpId the user posting the message
 */
function ReportPost(String ThreadId, String PostId, String McpId);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param Error string representing the error condition
 */
delegate OnReportPostComplete(bool bWasSuccessful, String PostId, String Error);

/**
 * Gives a post a thumbs up
 *
 * @param ThreadId the thread to post to
 * @param PostId the id of the post being flagged
 * @param McpId the user posting the message
 */
function VoteUpPost(String ThreadId, String PostId, String McpId);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param Error string representing the error condition
 */
delegate OnVoteOnPostComplete(bool bWasSuccessful, String PostId, String Error);

/**
 * Gives a post a thumbs down
 *
 * @param ThreadId the thread to post to
 * @param PostId the id of the post being flagged
 * @param McpId the user posting the message
 */
function VoteDownPost(String ThreadId, String PostId, String McpId);

/**
 * Deletes all data for this user from the chat system on the server
 *
 * @param McpId the user that we're querying posts for
 */
function DeleteUserData(String McpId);

/**
 * Called when the request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param McpId the user that the query was for
 * @param Error string representing the error condition
 */
delegate OnDeleteUserDataComplete(bool bWasSuccessful, String McpId, String Error);

