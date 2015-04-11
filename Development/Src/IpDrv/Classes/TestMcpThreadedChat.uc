/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the threaded chat interactions
 */
class TestMcpThreadedChat extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;
/** The user file manager to test */
var McpThreadedChatBase ChatManager;

/** Where we are in our tests */
var int TestState;

var McpUserStatus TestUsers[3];
var int UserCreatedCount;

var array<McpSystemChatThread> SystemChatThreads;

var String SystemThreadId;
var String SystemPostId[2];
var int SystemPostCount;

var array<McpUserChatThread> UserChatThreads;
var String UserThreadId;
var String UserPostId;

var array<McpChatPost> SystemChatPosts;
var array<McpChatPost> UserChatPosts;

/**
 * Initializes the test suite with the user file interface
 *
 * @param UserMan the user manager to test with
 * @param ChatMan the chat interface to test with
 */
function Init(McpUserManagerBase UserMan, McpThreadedChatBase ChatMan)
{
	UserManager = UserMan;
	ChatManager = ChatMan;
}

/**
 * Uses the state machine to execute a series of tests
 */
function RunNextTest()
{
	switch (TestState)
	{
		case 0:
			CreateUsersForTest();
			break;
		case 1:
			ReadSystemChatThreads();
			break;
		case 2:
			PostToSystemChatThread();
			break;
		case 3:
			VoteUpPost();
			break;
		case 4:
			ReportPost();
			break;
		case 5:
			CreateUserThread();
			break;
		case 6:
			PostToUserThread();
			break;
		case 7:
			VoteDownPost();
			break;
		case 8:
			GetPostsForUserThread();
			break;
		case 9:
			GetPostsForSystemThread();
			break;
		case 10:
			GetPostsForUserThreadByPopularity();
			break;
		case 11:
			GetPostsForSystemThreadByPopularity();
			break;
		case 12:
			DeleteUserData();
			break;
		case 13:
			DeleteUsers();
			break;
		case 14:
			Done();
			break;
	}
	TestState++;
}

/**
 * Generates the users
 */
function CreateUsersForTest()
{
	`Log("Creating users for account mapping tests");
	UserManager.OnRegisterUserComplete = OnRegisterUserComplete;
	UserManager.RegisterUserGenerated();
	UserManager.RegisterUserGenerated();
	UserManager.RegisterUserGenerated();
}

function OnRegisterUserComplete(string McpId, bool bWasSuccessful, string Error)
{
	if (bWasSuccessful)
	{
		UserManager.GetUser(McpId, TestUsers[UserCreatedCount]);
 	}
	UserCreatedCount++;
	// Once all three users have created their accounts, run the next test
	if (UserCreatedCount == 3)
	{
		if (TestUsers[0].McpId != "" && TestUsers[1].McpId != "" && TestUsers[2].McpId != "")
		{
			`Log("All users created successfully");
		}
		RunNextTest();
	}
}


/** Gets a list of system wide threads */
function ReadSystemChatThreads()
{
	`Log("Running test - ReadSystemChatThreads");
	ChatManager.OnReadSystemChatThreadsComplete = OnReadSystemChatThreadsComplete;
	ChatManager.ReadSystemChatThreads();
}

function OnReadSystemChatThreadsComplete(bool bWasSuccessful, String Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("ReadSystemChatThreads completed successfully");
		ChatManager.GetSystemChatThreads(SystemChatThreads);
		for (Index = 0; Index < SystemChatThreads.Length; Index++)
		{
			`Log("SystemChatThreads[" $ Index $ "].ThreadName = " $ SystemChatThreads[Index].ThreadName);
			`Log("SystemChatThreads[" $ Index $ "].ThreadId = " $ SystemChatThreads[Index].ThreadId);
			if (SystemThreadId == "")
			{
				SystemThreadId = SystemChatThreads[Index].ThreadId;
			}
		}
	}
	else
	{
		`Log("ReadSystemChatThreads failed with " $ Error);
	}
	RunNextTest();
}

/** Posts 2 messages to a system thread */
function PostToSystemChatThread()
{
	`Log("Running test - PostToSystemChatThread");
	ChatManager.OnPostToThreadComplete = OnPostToThreadComplete;
	ChatManager.PostToThread(SystemThreadId, TestUsers[0].McpId, "Joe G.", "Wello Horld!");
	ChatManager.PostToThread(SystemThreadId, TestUsers[1].McpId, "Sam Z.", "Sam says Hi!");
}

function OnPostToThreadComplete(bool bWasSuccessful, String ThreadId, String McpId, String Error)
{
	local int Index;

	SystemPostCount++;
	if (SystemPostCount == 2)
	{
		if (bWasSuccessful)
		{
			`Log("PostToSystemChatThread completed successfully");
			ChatManager.GetChatPosts(ThreadId, SystemChatPosts);
			for (Index = 0; Index < SystemChatPosts.Length; Index++)
			{
				`Log("");
				`Log("SystemChatPosts[" $ Index $ "].ThreadId = " $ SystemChatPosts[Index].ThreadId);
				`Log("SystemChatPosts[" $ Index $ "].PostId = " $ SystemChatPosts[Index].PostId);
				`Log("SystemChatPosts[" $ Index $ "].OwnerId = " $ SystemChatPosts[Index].OwnerId);
				`Log("SystemChatPosts[" $ Index $ "].OwnerName = " $ SystemChatPosts[Index].OwnerName);
				`Log("SystemChatPosts[" $ Index $ "].Message = " $ SystemChatPosts[Index].Message);
				`Log("SystemChatPosts[" $ Index $ "].bReported = " $ SystemChatPosts[Index].bReported);
				`Log("SystemChatPosts[" $ Index $ "].bProfanityChecked = " $ SystemChatPosts[Index].bProfanityChecked);
				`Log("SystemChatPosts[" $ Index $ "].VoteUpCount = " $ SystemChatPosts[Index].voteUpCount);
				`Log("SystemChatPosts[" $ Index $ "].VoteDownCount = " $ SystemChatPosts[Index].voteDownCount);
				`Log("SystemChatPosts[" $ Index $ "].Popularity = " $ SystemChatPosts[Index].Popularity);
				`Log("SystemChatPosts[" $ Index $ "].Timestamp = " $ SystemChatPosts[Index].Timestamp);
				`Log("");
				SystemPostId[Index] = SystemChatPosts[Index].PostId;
			}
		}
		else
		{
			`Log("PostToSystemChatThread failed with " $ Error);
		}
		RunNextTest();
	}
}

/** Vote up post 2 with user 1 */
function VoteUpPost()
{
	`Log("Running test - VoteUpPost");
	ChatManager.OnVoteOnPostComplete = OnVoteUpPostComplete;
	ChatManager.VoteUpPost(SystemThreadId, SystemPostId[1], TestUsers[0].McpId);
}

function OnVoteUpPostComplete(bool bWasSuccessful, String PostId, String Error)
{
	if (bWasSuccessful)
	{
		`Log("VoteUpPost for post (" $ PostId $ ") was successful");
	}
	else
	{
		`Log("VoteUpPost for post (" $ PostId $ ") failed");
	}
	RunNextTest();
}

/** Report post 1 with user 2 */
function ReportPost()
{
	`Log("Running test - ReportPost");
	ChatManager.OnReportPostComplete = OnReportPostComplete;
	ChatManager.ReportPost(SystemThreadId, SystemPostId[0], TestUsers[1].McpId);
}

function OnReportPostComplete(bool bWasSuccessful, String PostId, String Error)
{
	if (bWasSuccessful)
	{
		`Log("ReportPost for post (" $ PostId $ ") was successful");
	}
	else
	{
		`Log("ReportPost for post (" $ PostId $ ") failed");
	}
	RunNextTest();
}

/** Creates a thread for user 3 */
function CreateUserThread()
{
	`Log("Running test - CreateUserThread");
	ChatManager.OnCreateUserChatThreadComplete = OnCreateUserChatThreadComplete;
	ChatManager.CreateUserChatThread(TestUsers[2].McpId, "ClanChat");
}

function OnCreateUserChatThreadComplete(bool bWasSuccessful, String McpId, String ThreadName, String Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("CreateUserThread for McpId (" $ McpId $ "), ThreadName (" $ ThreadName $ ") completed successfully");
		ChatManager.GetUserChatThreads(McpId, UserChatThreads);
		for (Index = 0; Index < UserChatThreads.Length; Index++)
		{
			`Log("UserChatThreads[" $ Index $ "].ThreadId = " $ UserChatThreads[Index].ThreadId);
			`Log("UserChatThreads[" $ Index $ "].ThreadName = " $ UserChatThreads[Index].ThreadName);
			`Log("UserChatThreads[" $ Index $ "].OwnerId = " $ UserChatThreads[Index].OwnerId);
			if (UserThreadId == "")
			{
				UserThreadId = UserChatThreads[Index].ThreadId;
			}
		}
	}
	else
	{
		`Log("CreateUserThread for McpId (" $ McpId $ "), ThreadName (" $ ThreadName $ ") failed with error\n" $ Error);
	}
	RunNextTest();
}

/** Post to another person's thread */
function PostToUserThread()
{
	`Log("Running test - PostToUserThread");
	ChatManager.OnPostToThreadComplete = OnPostToUserThreadComplete;
	ChatManager.PostToThread(UserThreadId, TestUsers[0].McpId, "Joe G.", "Wello Horld!");
}

function OnPostToUserThreadComplete(bool bWasSuccessful, String ThreadId, String McpId, String Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("PostToUserThread completed successfully");
		ChatManager.GetChatPosts(UserThreadId, UserChatPosts);
		for (Index = 0; Index < UserChatPosts.Length; Index++)
		{
			`Log("");
			`Log("UserChatPosts[" $ Index $ "].ThreadId = " $ UserChatPosts[Index].ThreadId);
			`Log("UserChatPosts[" $ Index $ "].PostId = " $ UserChatPosts[Index].PostId);
			`Log("UserChatPosts[" $ Index $ "].OwnerId = " $ UserChatPosts[Index].OwnerId);
			`Log("UserChatPosts[" $ Index $ "].OwnerName = " $ UserChatPosts[Index].OwnerName);
			`Log("UserChatPosts[" $ Index $ "].Message = " $ UserChatPosts[Index].Message);
			`Log("UserChatPosts[" $ Index $ "].bReported = " $ UserChatPosts[Index].bReported);
			`Log("UserChatPosts[" $ Index $ "].bProfanityChecked = " $ UserChatPosts[Index].bProfanityChecked);
			`Log("UserChatPosts[" $ Index $ "].VoteUpCount = " $ UserChatPosts[Index].voteUpCount);
			`Log("UserChatPosts[" $ Index $ "].VoteDownCount = " $ UserChatPosts[Index].voteDownCount);
			`Log("UserChatPosts[" $ Index $ "].Popularity = " $ UserChatPosts[Index].Popularity);
			`Log("UserChatPosts[" $ Index $ "].Timestamp = " $ UserChatPosts[Index].Timestamp);
			UserPostId = UserChatPosts[Index].PostId;
		}
	}
	else
	{
		`Log("PostToUserThread failed with \n" $ Error);
	}
	RunNextTest();
}

/** User 3 votes down user 1's post */
function VoteDownPost()
{
	`Log("Running test - VoteDownPost");
	ChatManager.OnVoteOnPostComplete = OnVoteDownPostComplete;
	ChatManager.VoteDownPost(UserThreadId, UserPostId, TestUsers[2].McpId);
}

function OnVoteDownPostComplete(bool bWasSuccessful, String PostId, String Error)
{
	if (bWasSuccessful)
	{
		`Log("VoteDownPost for post (" $ PostId $ ") was successful");
	}
	else
	{
		`Log("VoteDownPost for post (" $ PostId $ ") failed");
	}
	RunNextTest();
}

/** Refreshes the posts for the system thread */
function GetPostsForSystemThread()
{
	`Log("Running test - GetPostsForSystemThread");
	ChatManager.OnReadChatPostsComplete = OnReadSystemChatPostsComplete;
	ChatManager.ReadChatPostsByTime(SystemThreadId);
}

function OnReadSystemChatPostsComplete(bool bWasSuccessful, String ThreadId, String Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("GetPostsForSystemThread completed successfully");
		ChatManager.GetChatPosts(ThreadId, SystemChatPosts);
		for (Index = 0; Index < SystemChatPosts.Length; Index++)
		{
			`Log("");
			`Log("SystemChatPosts[" $ Index $ "].ThreadId = " $ SystemChatPosts[Index].ThreadId);
			`Log("SystemChatPosts[" $ Index $ "].PostId = " $ SystemChatPosts[Index].PostId);
			`Log("SystemChatPosts[" $ Index $ "].OwnerId = " $ SystemChatPosts[Index].OwnerId);
			`Log("SystemChatPosts[" $ Index $ "].OwnerName = " $ SystemChatPosts[Index].OwnerName);
			`Log("SystemChatPosts[" $ Index $ "].Message = " $ SystemChatPosts[Index].Message);
			`Log("SystemChatPosts[" $ Index $ "].bReported = " $ SystemChatPosts[Index].bReported);
			`Log("SystemChatPosts[" $ Index $ "].bProfanityChecked = " $ SystemChatPosts[Index].bProfanityChecked);
			`Log("SystemChatPosts[" $ Index $ "].VoteUpCount = " $ SystemChatPosts[Index].voteUpCount);
			`Log("SystemChatPosts[" $ Index $ "].VoteDownCount = " $ SystemChatPosts[Index].voteDownCount);
			`Log("SystemChatPosts[" $ Index $ "].Popularity = " $ SystemChatPosts[Index].Popularity);
			`Log("SystemChatPosts[" $ Index $ "].Timestamp = " $ SystemChatPosts[Index].Timestamp);
		}
	}
	else
	{
		`Log("GetPostsForSystemThread failed with \n" $ Error);
	}
	RunNextTest();
}

/** Refreshes the posts for the system thread */
function GetPostsForSystemThreadByPopularity()
{
	`Log("Running test - GetPostsForSystemThreadByPopularity");
	ChatManager.OnReadChatPostsComplete = OnReadSystemChatPostsByPopularityComplete;
	ChatManager.ReadChatPostsByPopularity(SystemThreadId);
}

function OnReadSystemChatPostsByPopularityComplete(bool bWasSuccessful, String ThreadId, String Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("GetPostsForSystemThreadByPopularity completed successfully");
		ChatManager.GetChatPosts(ThreadId, SystemChatPosts);
		for (Index = 0; Index < SystemChatPosts.Length; Index++)
		{
			`Log("");
			`Log("SystemChatPosts[" $ Index $ "].ThreadId = " $ SystemChatPosts[Index].ThreadId);
			`Log("SystemChatPosts[" $ Index $ "].PostId = " $ SystemChatPosts[Index].PostId);
			`Log("SystemChatPosts[" $ Index $ "].OwnerId = " $ SystemChatPosts[Index].OwnerId);
			`Log("SystemChatPosts[" $ Index $ "].OwnerName = " $ SystemChatPosts[Index].OwnerName);
			`Log("SystemChatPosts[" $ Index $ "].Message = " $ SystemChatPosts[Index].Message);
			`Log("SystemChatPosts[" $ Index $ "].bReported = " $ SystemChatPosts[Index].bReported);
			`Log("SystemChatPosts[" $ Index $ "].bProfanityChecked = " $ SystemChatPosts[Index].bProfanityChecked);
			`Log("SystemChatPosts[" $ Index $ "].VoteUpCount = " $ SystemChatPosts[Index].voteUpCount);
			`Log("SystemChatPosts[" $ Index $ "].VoteDownCount = " $ SystemChatPosts[Index].voteDownCount);
			`Log("SystemChatPosts[" $ Index $ "].Popularity = " $ SystemChatPosts[Index].Popularity);
			`Log("SystemChatPosts[" $ Index $ "].Timestamp = " $ SystemChatPosts[Index].Timestamp);
		}
	}
	else
	{
		`Log("GetPostsForSystemThreadByPopularity failed with \n" $ Error);
	}
	RunNextTest();
}

/** Refreshes the posts for the user thread */
function GetPostsForUserThread()
{
	`Log("Running test - GetPostsForUserThread");
	ChatManager.OnReadChatPostsComplete = OnReadUserChatPostsComplete;
	ChatManager.ReadChatPostsByTime(UserThreadId);
}

function OnReadUserChatPostsComplete(bool bWasSuccessful, String ThreadId, String Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("GetPostsForUserThread completed successfully");
		ChatManager.GetChatPosts(ThreadId, UserChatPosts);
		for (Index = 0; Index < UserChatPosts.Length; Index++)
		{
			`Log("");
			`Log("UserChatPosts[" $ Index $ "].ThreadId = " $ UserChatPosts[Index].ThreadId);
			`Log("UserChatPosts[" $ Index $ "].PostId = " $ UserChatPosts[Index].PostId);
			`Log("UserChatPosts[" $ Index $ "].OwnerId = " $ UserChatPosts[Index].OwnerId);
			`Log("UserChatPosts[" $ Index $ "].OwnerName = " $ UserChatPosts[Index].OwnerName);
			`Log("UserChatPosts[" $ Index $ "].Message = " $ UserChatPosts[Index].Message);
			`Log("UserChatPosts[" $ Index $ "].bReported = " $ UserChatPosts[Index].bReported);
			`Log("UserChatPosts[" $ Index $ "].bProfanityChecked = " $ UserChatPosts[Index].bProfanityChecked);
			`Log("UserChatPosts[" $ Index $ "].VoteUpCount = " $ UserChatPosts[Index].voteUpCount);
			`Log("UserChatPosts[" $ Index $ "].VoteDownCount = " $ UserChatPosts[Index].voteDownCount);
			`Log("UserChatPosts[" $ Index $ "].Popularity = " $ UserChatPosts[Index].Popularity);
			`Log("UserChatPosts[" $ Index $ "].Timestamp = " $ UserChatPosts[Index].Timestamp);
		}
	}
	else
	{
		`Log("GetPostsForUserThread failed with \n" $ Error);
	}
	RunNextTest();
}

/** Refreshes the posts for the user thread */
function GetPostsForUserThreadByPopularity()
{
	`Log("Running test - GetPostsForUserThreadByPopularity");
	ChatManager.OnReadChatPostsComplete = OnReadUserChatPostsByPopularityComplete;
	ChatManager.ReadChatPostsByPopularity(UserThreadId);
}

function OnReadUserChatPostsByPopularityComplete(bool bWasSuccessful, String ThreadId, String Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("GetPostsForUserThreadByPopularity completed successfully");
		ChatManager.GetChatPosts(ThreadId, UserChatPosts);
		for (Index = 0; Index < UserChatPosts.Length; Index++)
		{
			`Log("");
			`Log("UserChatPosts[" $ Index $ "].ThreadId = " $ UserChatPosts[Index].ThreadId);
			`Log("UserChatPosts[" $ Index $ "].PostId = " $ UserChatPosts[Index].PostId);
			`Log("UserChatPosts[" $ Index $ "].OwnerId = " $ UserChatPosts[Index].OwnerId);
			`Log("UserChatPosts[" $ Index $ "].OwnerName = " $ UserChatPosts[Index].OwnerName);
			`Log("UserChatPosts[" $ Index $ "].Message = " $ UserChatPosts[Index].Message);
			`Log("UserChatPosts[" $ Index $ "].bReported = " $ UserChatPosts[Index].bReported);
			`Log("UserChatPosts[" $ Index $ "].bProfanityChecked = " $ UserChatPosts[Index].bProfanityChecked);
			`Log("UserChatPosts[" $ Index $ "].VoteUpCount = " $ UserChatPosts[Index].voteUpCount);
			`Log("UserChatPosts[" $ Index $ "].VoteDownCount = " $ UserChatPosts[Index].voteDownCount);
			`Log("UserChatPosts[" $ Index $ "].Popularity = " $ UserChatPosts[Index].Popularity);
			`Log("UserChatPosts[" $ Index $ "].Timestamp = " $ UserChatPosts[Index].Timestamp);
		}
	}
	else
	{
		`Log("GetPostsForUserThreadByPopularity failed with \n" $ Error);
	}
	RunNextTest();
}

/** Delete our temp users from the database since they aren't needed anymore */
function DeleteUsers()
{
	`Log("Deleting temp users");
	UserManager.OnDeleteUserComplete = OnDeleteUserComplete;
	UserManager.DeleteUser(TestUsers[0].McpId);
	UserManager.DeleteUser(TestUsers[1].McpId);
	UserManager.DeleteUser(TestUsers[2].McpId);
}

function OnDeleteUserComplete(bool bWasSuccessful, String Error)
{
	UserCreatedCount--;
	if (UserCreatedCount == 0)
	{
		`Log("Deleted temp users");
		RunNextTest();
	}
}

/** Delete our user users from the database since they aren't needed anymore */
function DeleteUserData()
{
	`Log("Deleting data for user");
	ChatManager.OnDeleteUserDataComplete = OnDeleteUserDataComplete;
	ChatManager.DeleteUserData(TestUsers[0].McpId);
}

function OnDeleteUserDataComplete(bool bWasSuccessful, String McpId, String Error)
{
	if (McpId == TestUsers[0].McpId)
	{
		`Log("Deleted user data was successful = " $ bWasSuccessful $ " and error string = " $ Error);
		RunNextTest();
	}
}

/** Called once all of the tests have run */
delegate Done();
