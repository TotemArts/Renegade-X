/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the leaderboard related MCP APIs
 */
class TestMcpLeaderboards extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;

/** The leaderboard manager to test */
var McpLeaderboardsBase LeaderboardManager;

/** Where we are in our tests */
var int TestState;

/** Cached internal auth user for tests */
var McpUserStatus InternalAuthUser;


/** Called once all of the tests have run */
delegate Done();

/**
 * Initializes the test suite with the shared managers
 *
 * @param UserMan the shared user manager to test with
 * @param LeaderboardMan the shared leaderboard manager to test with
 */
function Init(McpUserManagerBase UserMan, McpLeaderboardsBase LeaderboardMan)
{
	UserManager = UserMan;
	LeaderboardManager = LeaderboardMan;
}

/**
 * Uses the state machine to execute a series of tests
 */
function RunNextTest()
{
	switch (TestState)
	{
		case 0:
			ReadLeaderboards();
			break;
		case 1:
			CreateUser();
			break;
		case 2:
			WriteLeaderboardEntry();
			break;
		case 3:
			ReadLeaderboardByColumn();
			break;
		case 4:
			ReadLeaderboardEntry();
			break;
		case 5:
			Done();
			break;
	}
	TestState++;
}

/** Read the game's leaderboard list */
function ReadLeaderboards()
{
	LeaderboardManager.OnReadLeaderboardsComplete = OnReadLeaderboardsComplete;
	LeaderboardManager.ReadLeaderboards();
}

function OnReadLeaderboardsComplete(bool bWasSuccessful, String Error)
{
	local array<McpLeaderboard> Leaderboards;
	local int Index, ColumnIndex, TimeframeIndex;

	if (bWasSuccessful)
	{
		LeaderboardManager.GetLeaderboards(Leaderboards);
		for (Index = 0; Index < Leaderboards.Length; Index++)
		{
			`Log("");
			`Log("Leaderboard = " $ Leaderboards[Index].LeaderboardName);
			`Log("  RatingColumn = " $ Leaderboards[Index].RatingColumn);
			`Log("  Columns = " $ Leaderboards[Index].Columns.Length);
			for (ColumnIndex = 0; ColumnIndex < Leaderboards[Index].Columns.Length; ColumnIndex++)
			{
				`Log("    Name = " $ Leaderboards[Index].Columns[ColumnIndex].Name);
				`Log("    Type = " $ Leaderboards[Index].Columns[ColumnIndex].Type);
			}
			`Log("  Timeframes = " $ Leaderboards[Index].Timeframes.Length);
			for (TimeframeIndex = 0; TimeframeIndex < Leaderboards[Index].Timeframes.Length; TimeframeIndex++)
			{
				`Log("    Timeframe = " $ Leaderboards[Index].Timeframes[TimeframeIndex]);
			}
		}
	}
	else
	{
		`Log("Failed to read leaderboards with error (" $ Error $ ")");
	}
	RunNextTest();
}

function CreateUser()
{
	UserManager.OnRegisterUserComplete = OnRegisterUserComplete;
	UserManager.RegisterUserGenerated();
}

function OnRegisterUserComplete(string McpId, bool bWasSuccessful, string Error)
{
	if (bWasSuccessful && UserManager.GetUser(McpId, InternalAuthUser))
	{
		`Log("Successfully registered a user");
	}
	else
	{
		`Log("Failed to register a user with Error = " $ Error);
	}
	RunNextTest();
}

function WriteLeaderboardEntry()
{
	local array<McpLeaderboardColumnEntry> Columns;
	local int Index;

	Index = Columns.Length;
	Columns.Length = Index + 1;
	Columns[Index].Name = "Col1";
	Columns[Index].Value = Rand(100);

	Index = Columns.Length;
	Columns.Length = Index + 1;
	Columns[Index].Name = "Col2";
	Columns[Index].Value = Rand(100);

	LeaderboardManager.OnWriteLeaderboardEntryComplete = OnWriteLeaderboardEntryComplete;
	LeaderboardManager.WriteLeaderboardEntry(InternalAuthUser.McpId, "JoeTest", Columns);
}

function OnWriteLeaderboardEntryComplete(bool bWasSuccessful, String Error, String McpId, String LeaderboardName)
{
	if (bWasSuccessful)
	{
		`Log("Successfully wrote a leaderboard entry for user (" $ McpId $ ") to leaderboard (" $ LeaderboardName $ ")");
	}
	else
	{
		`Log("WriteLeaderboardEntry - failed with Error = " $ Error);
	}
	LeaderboardManager.OnWriteLeaderboardEntryComplete = None;

	RunNextTest();
}

function ReadLeaderboardEntry()
{
	local array<String> Users;

	Users.AddItem(InternalAuthUser.McpId);

	LeaderboardManager.OnReadLeaderboardEntriesComplete = OnReadLeaderboardEntriesComplete;
	LeaderboardManager.ReadLeaderboardEntries(Users, "JoeTest", MLT_DAILY);
}

function OnReadLeaderboardEntriesComplete(bool bWasSuccessful, String Error, String LeaderboardName, McpLeaderboardTimeframe Timeframe)
{
	local array<McpLeaderboardEntry> Entries;
	local int Index, ValueIndex;

	if (bWasSuccessful)
	{
		`Log("Successfully read leaderboard entries for leaderboard (" $ LeaderboardName $ ") with timeframe = " $ Timeframe);
		LeaderboardManager.GetLeaderboardEntries(InternalAuthUser.McpId, Entries, LeaderboardName);
		for (Index = 0; Index < Entries.Length; Index++)
		{
			`Log("");
			`Log("Leaderboard = " $ Entries[Index].LeaderboardName);
			`Log("  McpId = " $ Entries[Index].McpId);
			`Log("  Timeframe = " $ Entries[Index].Timeframe);
			`Log("  RatingValue = " $ Entries[Index].RatingValue);
			`Log("  Percentile = " $ Entries[Index].Percentile);
			`Log("  Ranking = " $ Entries[Index].Ranking);
			`Log("  Values = " $ Entries[Index].Values.Length);
			for (ValueIndex = 0; ValueIndex < Entries[Index].Values.Length; ValueIndex++)
			{
				`Log("    Name = " $ Entries[Index].Values[ValueIndex].Name);
				`Log("    Value = " $ Entries[Index].Values[ValueIndex].Value);
			}
		}
	}
	else
	{
		`Log("ReadLeaderboardEntry - failed with Error = " $ Error);
	}
	RunNextTest();
}

function ReadLeaderboardByColumn()
{
	LeaderboardManager.OnReadLeaderboardEntriesComplete = OnReadLeaderboardByColumnComplete;
	LeaderboardManager.ReadLeaderboardColumnByRange("JoeTest", MLT_DAILY, "Col2", 0, 100, 5);
}

function OnReadLeaderboardByColumnComplete(bool bWasSuccessful, String Error, String LeaderboardName, McpLeaderboardTimeframe Timeframe)
{
	local array<McpLeaderboardEntry> Entries;
	local int Index, ValueIndex;

	if (bWasSuccessful)
	{
		`Log("Successfully read leaderboard entries for leaderboard (" $ LeaderboardName $ ") with timeframe = " $ Timeframe $ " and colum named (Col2)");
		LeaderboardManager.GetLeaderboardByColumnByRange(LeaderboardName, MLT_DAILY, "Col2", 0, 100, Entries);
		for (Index = 0; Index < Entries.Length; Index++)
		{
			`Log("");
			`Log("Leaderboard = " $ Entries[Index].LeaderboardName);
			`Log("  McpId = " $ Entries[Index].McpId);
			`Log("  Timeframe = " $ Entries[Index].Timeframe);
			`Log("  RatingValue = " $ Entries[Index].RatingValue);
			`Log("  Percentile = " $ Entries[Index].Percentile);
			`Log("  Ranking = " $ Entries[Index].Ranking);
			`Log("  Values = " $ Entries[Index].Values.Length);
			for (ValueIndex = 0; ValueIndex < Entries[Index].Values.Length; ValueIndex++)
			{
				`Log("    Name = " $ Entries[Index].Values[ValueIndex].Name);
				`Log("    Value = " $ Entries[Index].Values[ValueIndex].Value);
			}
		}
	}
	else
	{
		`Log("ReadLeaderboardByColumn - failed with Error = " $ Error);
	}
	RunNextTest();
}

