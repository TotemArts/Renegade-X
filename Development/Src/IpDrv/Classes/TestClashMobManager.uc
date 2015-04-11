/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the ClashMob related MCP APIs
 */
class TestClashMobManager extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;
var McpClashMobBase ClashMobManager;

/** Where we are in our tests */
var int TestState;

var McpUserStatus TestUser;

var array<McpClashMobChallengeEvent> ChallengeEvents;
var int FileCount;

var String ParentId;
var String ChildId;

/**
 * Initializes the test suite with the user file interface
 *
 * @param UserMan the user manager to test with
 * @param ClashMobMan the ClashMob interface to test with
 */
function Init(McpUserManagerBase UserMan, McpClashMobBase ClashMobMan, optional String InParentId, optional String InChildId)
{
	UserManager = UserMan;
	ClashMobManager = ClashMobMan;
	ParentId = InParentId;
	if (ParentId != "")
	{
		`Log("ParentId is " $ ParentId);
	}
	ChildId = InChildId;
	if (ChildId != "")
	{
		`Log("ChildId is " $ ChildId);
	}
}

/**
 * Uses the state machine to execute a series of tests
 */
function RunNextTest()
{
	switch (TestState)
	{
		case 0:
			CreateUserForTest();
			break;
		case 1:
			QueryClashMobs();
			break;
		case 2:
			DownloadChallengeFiles();
			break;
		case 3:
			AcceptClashMob();
			break;
		case 4:
			UpdateProgress();
			break;
		case 5:
			UpdateReward();
			break;
		case 6:
			QueryUserStatus();
			break;
		case 7:
			DeleteUser();
			break;
		case 8:
			Done();
			break;
	}
	TestState++;
}

/**
 * Generates a user
 */
function CreateUserForTest()
{
	`Log("Creating user for ClashMob tests");
	UserManager.OnRegisterUserComplete = OnRegisterUserComplete;
	UserManager.RegisterUserGenerated();
}

function OnRegisterUserComplete(string McpId, bool bWasSuccessful, string Error)
{
	if (bWasSuccessful)
	{
		UserManager.GetUser(McpId, TestUser);
		if (TestUser.McpId != "")
		{
			`Log("User created successfully");
		}
 	}
	RunNextTest();
}

/** Lists the files in the cloud for the user */
function QueryClashMobs()
{
	`Log("Querying ClashMob data");
	ClashMobManager.OnQueryChallengeListComplete = OnQueryChallengeListComplete;
	ClashMobManager.QueryChallengeList(TestUser.McpId);
}

function OnQueryChallengeListComplete(bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		`Log("Querying ClashMob data succeeded");
		ClashMobManager.GetChallengeList(ChallengeEvents);
	}
	else
	{
		`Log("Failed to get ClashMob data");
	}
	RunNextTest();
}

/** Downloads all of the files for a challenge if there are any */
function DownloadChallengeFiles()
{
	local int FileIndex;

	`Log("Downloading ClashMob files...");
	ClashMobManager.OnDownloadChallengeFileComplete = OnDownloadChallengeFileComplete;
	if (ChallengeEvents.Length > 0 && ChallengeEvents[0].file_list.Length > 0)
	{
		for (FileIndex = 0; FileIndex < ChallengeEvents[0].file_list.Length; FileIndex++)
		{
			FileCount++;
			ClashMobManager.DownloadChallengeFile(ChallengeEvents[0].unique_challenge_id, ChallengeEvents[0].file_list[FileIndex].dl_name);
		}
	}
	else
	{
		`Log("No files to download");
		TestState++;
		RunNextTest();
	}
}

function OnDownloadChallengeFileComplete(bool bWasSuccessful, String ChallengeId, String DlName, String FileName, String ErrorString)
{
	if (bWasSuccessful)
	{
		`Log("Downloaded file (" $ DlName $ ") for challenge (" $ ChallengeId $ ")");
	}
	else
	{
		`Log("Failed to download file (" $ DlName $ ") for challenge (" $ ChallengeId $ ") with error: " $ ErrorString);
	}
	FileCount--;
	if (FileCount <= 0)
	{
		// Due to caching, the callback can happen immediately
		if (TestState == 2)
		{
			TestState++;
		}
		RunNextTest();
	}
}

/** Accept a ClashMob for a user if there is one */
function AcceptClashMob()
{
	`Log("Running test - AcceptClashMob");
	if (ChallengeEvents.Length > 0)
	{
		ClashMobManager.OnAcceptChallengeComplete = OnAcceptChallengeComplete;
		if (ParentId != "")
		{
			ClashMobManager.AcceptChallenge(ParentId, TestUser.McpId, "SaveSlot1");
		}
		else
		{
			ClashMobManager.AcceptChallenge(ChallengeEvents[0].unique_challenge_id, TestUser.McpId, "SaveSlot1");
		}
	}
	else
	{
		`Log("No ClashMob to join");
		TestState++;
		RunNextTest();
	}
}

function OnAcceptChallengeComplete(bool bWasSuccessful, String ChallengeId, String McpId, String Error)
{
	`Log("AcceptClashMob for ChallengeId (" $ ChallengeId $ ") for user (" $ McpId $ ") " $ bWasSuccessful ? "succeeded" : "failed");
	RunNextTest();
}

/** Update progress for the user */
function UpdateProgress()
{
	`Log("Running test - UpdateProgress");
	if (ChallengeEvents.Length > 0)
	{
		ClashMobManager.OnUpdateChallengeUserProgressComplete = OnUpdateChallengeUserProgressComplete;
		if (ChildId != "")
		{
			ClashMobManager.UpdateChallengeUserProgress(ChildId, TestUser.McpId, "SaveSlot1", true, 1);
		}
		else
		{
			ClashMobManager.UpdateChallengeUserProgress(ChallengeEvents[0].unique_challenge_id, TestUser.McpId, "SaveSlot1", true, 1);
		}
	}
	else
	{
		`Log("No ClashMob to update progress for");
		TestState++;
		RunNextTest();
	}
}

function OnUpdateChallengeUserProgressComplete(bool bWasSuccessful, String ChallengeId, String McpId, String Error)
{
	`Log("UpdateProgress for ChallengeId (" $ ChallengeId $ ") for user (" $ McpId $ ") " $ bWasSuccessful ? "succeeded" : "failed");
	RunNextTest();
}

/** Update the reward count for the user */
function UpdateReward()
{
	`Log("Running test - UpdateReward");
	if (ChallengeEvents.Length > 0)
	{
		ClashMobManager.OnUpdateChallengeUserRewardComplete = OnUpdateChallengeUserRewardComplete;
		if (ChildId != "")
		{
			ClashMobManager.UpdateChallengeUserReward(ChildId, TestUser.McpId, "SaveSlot1", 1);
		}
		else
		{
			ClashMobManager.UpdateChallengeUserReward(ChallengeEvents[0].unique_challenge_id, TestUser.McpId, "SaveSlot1", 1);
		}
	}
	else
	{
		`Log("No ClashMob to update reward for");
		TestState++;
		RunNextTest();
	}
}

function OnUpdateChallengeUserRewardComplete(bool bWasSuccessful, String ChallengeId, String McpId, String Error)
{
	`Log("UpdateReward for ChallengeId (" $ ChallengeId $ ") for user (" $ McpId $ ") " $ bWasSuccessful ? "succeeded" : "failed");
	RunNextTest();
}

/** Query for the clashmob progress for the user */
function QueryUserStatus()
{
	`Log("Running test - QueryUserStatus");
	if (ChallengeEvents.Length > 0)
	{
		ClashMobManager.OnQueryChallengeUserStatusComplete = OnQueryChallengeUserStatusComplete;
		if (ChildId != "")
		{
			ClashMobManager.QueryChallengeUserStatus(ChildId, TestUser.McpId);
		}
		else
		{
			ClashMobManager.QueryChallengeUserStatus(ChallengeEvents[0].unique_challenge_id, TestUser.McpId);
		}
	}
	else
	{
		`Log("No ClashMob to query status for");
		TestState++;
		RunNextTest();
	}
}

function OnQueryChallengeUserStatusComplete(bool bWasSuccessful, String ChallengeId, String McpId, String Error)
{
	local array<McpClashMobChallengeUserStatus> Status;
	local int StatusIndex;

	`Log("QueryUserStatus for ChallengeId (" $ ChallengeId $ ") for user (" $ McpId $ ") " $ bWasSuccessful ? "succeeded" : "failed");
	if (bWasSuccessful)
	{
		ClashMobManager.GetChallengeUserStatus(ChallengeId, McpId, Status);
		for (StatusIndex = 0; StatusIndex < Status.Length; StatusIndex++)
		{
			`Log("Status[" $ StatusIndex $ "] contains:");
			`Log("  save_slot_id = " $ Status[StatusIndex].save_slot_id);
			`Log("  num_attempts = " $ Status[StatusIndex].num_attempts);
			`Log("  num_successful_attempts = " $ Status[StatusIndex].num_successful_attempts);
			`Log("  goal_progress = " $ Status[StatusIndex].goal_progress);
			`Log("  did_complete = " $ Status[StatusIndex].did_complete);
			`Log("  last_update_time = " $ Status[StatusIndex].last_update_time);
			`Log("  user_award_given = " $ Status[StatusIndex].user_award_given);
			`Log("  accept_time = " $ Status[StatusIndex].accept_time);
			`Log("  did_preregister = " $ Status[StatusIndex].did_preregister);
			`Log("  facebook_like_time = " $ Status[StatusIndex].facebook_like_time);
			`Log("  enrolled_via_facebook = " $ Status[StatusIndex].enrolled_via_facebook);
			`Log("  liked_via_facebook = " $ Status[StatusIndex].liked_via_facebook);
			`Log("  commented_via_facebook = " $ Status[StatusIndex].commented_via_facebook);
			`Log("  twitter_retweet_time = " $ Status[StatusIndex].twitter_retweet_time);
			`Log("  enrolled_via_twitter = " $ Status[StatusIndex].enrolled_via_twitter);
			`Log("  retweeted = " $ Status[StatusIndex].retweeted);
		}
	}
	RunNextTest();
}

/** Delete our temp users from the database since they aren't needed anymore */
function DeleteUser()
{
	`Log("Deleting temp user");
	UserManager.OnDeleteUserComplete = OnDeleteUserComplete;
	UserManager.DeleteUser(TestUser.McpId);
}

function OnDeleteUserComplete(bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		`Log("Deleted temp user");
		RunNextTest();
	}
}

/** Called once all of the tests have run */
delegate Done();
