/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the id mapping related MCP APIs
 */
class TestMcpIdMapping extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;

/** The id mapping manager to test */
var McpIdMappingBase IdMappingManager;

/** Where we are in our tests */
var int TestState;

/** Cached users for tests */
var McpUserStatus TestUser1;
var McpUserStatus TestUser2;
var McpUserStatus TestUser3;
var int UserCreatedCount;

/** Cached account mappings for tests */
var McpIdMapping TestMapping[3];
var int MappingsCreatedCount;
var int MappingsQueriedCount;

/**
 * Initializes the test suite with the shared user manager
 *
 * @param UserMan the share user manager to test with
 * @param IdMappingMan the id mapping manager to test with
 */
function Init(McpUserManagerBase UserMan, McpIdMappingBase IdMappingMan)
{
	UserManager = UserMan;
	IdMappingManager = IdMappingMan;
}

/**
 * Uses the state machine to execute a series of tests
 */
function RunNextTest()
{
	switch (TestState)
	{
		case 0:
			RegisterUsers();
			break;
		case 1:
			CreateAccountMappings();
			break;
		case 2:
			QueryAccountMappings();
			break;
		case 3:
			DeleteUsers();
			break;
		case 4:
			Done();
			break;
	}
	TestState++;
}

/**
 * Generates a user with internal auth so we can test that path
 */
function RegisterUsers()
{
	`Log("Creating users for account mapping tests");
	UserManager.OnRegisterUserComplete = OnRegisterUserComplete;
	UserManager.RegisterUserGenerated();
	UserManager.RegisterUserGenerated();
	UserManager.RegisterUserGenerated();
}

function OnRegisterUserComplete(string McpId, bool bWasSuccessful, string Error)
{
	UserCreatedCount++;
	if (bWasSuccessful)
	{
		switch (UserCreatedCount)
		{
			case 1:
				UserManager.GetUser(McpId, TestUser1);
				break;
			case 2:
				UserManager.GetUser(McpId, TestUser2);
				break;
			case 3:
				UserManager.GetUser(McpId, TestUser3);
				break;
		}
 	}
	// Once all three users have created their accounts, run the next test
	if (UserCreatedCount == 3)
	{
		if (TestUser1.McpId != "" && TestUser2.McpId != "" && TestUser3.McpId != "")
		{
			`Log("All users created successfully");
		}
		RunNextTest();
	}
}

/** Creates a GameCenter account mapping for each test user */
function CreateAccountMappings()
{
	`Log("Creating game center account mappings for test users");
	IdMappingManager.OnAddMappingComplete = OnAddMappingComplete;
	IdMappingManager.AddMapping(TestUser1.McpId, String(123456789 * FRand()), "gamecenter");
	IdMappingManager.AddMapping(TestUser2.McpId, String(123456789 * FRand()), "gamecenter");
	IdMappingManager.AddMapping(TestUser3.McpId, String(123456789 * FRand()), "gamecenter");
}

function OnAddMappingComplete(String McpId, String ExternalId, String ExternalType, bool bWasSuccessful, String Error)
{
	local int ValidatedCount;
	local int Index;

	if (bWasSuccessful)
	{
		TestMapping[MappingsCreatedCount].McpId = McpId;
		TestMapping[MappingsCreatedCount].ExternalId = ExternalId;
		TestMapping[MappingsCreatedCount].ExternalType = ExternalType;
		`Log("Account mapping added: McpId = (" $ McpId $ "), ExternalId = ("$ ExternalId $ "), ExternalType = (" $ ExternalType $ ")");
 	}
	else
	{
		`Log("Failed to add mapping with error:\n" $ Error);
	}
	MappingsCreatedCount++;
	// Once all three users have created their accounts, run the next test
	if (MappingsCreatedCount == 3)
	{
		for (Index = 0; Index < MappingsCreatedCount; Index++)
		{
			ValidatedCount += int(TestMapping[Index].McpId != "" && TestMapping[Index].ExternalId != "" && TestMapping[Index].ExternalType == "gamecenter");
		}
		if (ValidatedCount == 3)
		{
			`Log("All account mappings created successfully");
		}
		else
		{
			`Log("Failed to create all account mappings");
		}
		RunNextTest();
	}
}

/** Reads the account mappings for the test users */
function QueryAccountMappings()
{
	local array<String> ExternalIds;
	local int Index;

	for (Index = 0; Index < 3; Index++)
	{
		ExternalIds.AddItem(TestMapping[Index].ExternalId);
	}

	IdMappingManager.OnQueryMappingsComplete = OnQueryMappingsComplete;
	IdMappingManager.QueryMappings(TestUser1.McpId, ExternalIds, "gamecenter");
}

function OnQueryMappingsComplete(String ExternalType, bool bWasSuccessful, String Error)
{
	local array<McpIdMapping> Mappings;
	local int Index;
	local int FoundAt;

	if (bWasSuccessful)
	{
		if (ExternalType != "gamecenter")
		{
			`Log("Error: wrong external type was returned, expected \"gamecenter\", got \"" $ ExternalType $ "\"");
		}
		IdMappingManager.GetIdMappings(ExternalType, Mappings);
		if (Mappings.Length != 3)
		{
			`Log("Error: wrong number of mappings were returned, expected \"3\", got \"" $ Mappings.Length $ "\"");
		}
		for (Index = 0; Index < 3; Index++)
		{
			FoundAt = Mappings.Find('McpId', TestMapping[Index].McpId);
			if (FoundAt != INDEX_NONE)
			{
				if (TestMapping[Index].ExternalId != Mappings[FoundAt].ExternalId)
				{
					`Log("Error: External ids for test mapping " $ Index $ " do not match");
				}
				if (TestMapping[Index].ExternalType != Mappings[FoundAt].ExternalType)
				{
					`Log("Error: External types for test mapping " $ Index $ " do not match");
				}
			}
			else
			{
				`Log("Error: Failed to find test mapping " $ Index $ "'s account in the queried list");
			}
		}
		`Log("Query completed successfully");
	}
	else
	{
		`Log("Failed to query for account mappings with error: \n" $ Error);
	}
	RunNextTest();
}

/** Delete our temp users from the database since they aren't needed anymore */
function DeleteUsers()
{
	`Log("Deleting temp users");
	UserManager.OnDeleteUserComplete = OnDeleteUserComplete;
	UserManager.DeleteUser(TestUser1.McpId);
	UserManager.DeleteUser(TestUser2.McpId);
	UserManager.DeleteUser(TestUser3.McpId);
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

/** Called once all of the tests have run */
delegate Done();
