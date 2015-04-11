/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the user related MCP APIs
 */
class TestMcpUser extends Object
	config(Engine);

/** The user manager to test */
var McpUserManagerBase UserManager;

/** Where we are in our tests */
var int TestState;

/** Cached internal auth user for tests */
var McpUserStatus InternalAuthUser;

/** Cached external auth user for tests */
var McpUserStatus ExternalAuthUser;

/** Used to run Facebook auth tests without prompting the user */
var config string FacebookId;
var config string FacebookToken;

var string GameCenterId;

/**
 * Initializes the test suite with the shared user manager
 *
 * @param UserMan the share user manager to test with
 */
function Init(McpUserManagerBase UserMan)
{
	UserManager = UserMan;
}

/**
 * Uses the state machine to execute a series of tests
 */
function RunNextTest()
{
	switch (TestState)
	{
		case 0:
			RegisterUserGenerated();
			break;
		case 1:
			AuthUserGenerated();
			break;
		case 2:
			RegisterUserFacebook();
			break;
		case 3:
			AuthUserFacebook();
			break;
		case 4:
			RegisterUserGameCenter();
			break;
		case 5:
			AuthUserGameCenter();
			break;
		case 6:
			QueryUser();
			break;
		case 7:
			QueryUsers();
			break;
		case 8:
			DeleteUser();
			break;
		case 9:
			Done();
			break;
	}
	TestState++;
}

/**
 * Generates a user with internal auth so we can test that path
 */
function RegisterUserGenerated()
{
	`Log("Running test - RegisterUserGenerated");
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

/**
 * Perform authentication using the data returned from the internal registration attempt
 */
function AuthUserGenerated()
{
	`Log("Running test - AuthUserGenerated");
	UserManager.OnAuthenticateUserComplete = OnAuthUserComplete;
	UserManager.AuthenticateUserMcp(InternalAuthUser.McpId, InternalAuthUser.SecretKey, "");
}

function OnAuthUserComplete(string McpId, string Token, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		if (McpId == InternalAuthUser.McpId)
		{
			InternalAuthUser.Ticket = Token;
			`Log("Successfully authenticated a user");
		}
		else
		{
			`Log("Wrong user returned from the auth request");
		}
	}
	else
	{
		`Log("Failed to authenticate the user with Error = " $ Error);
	}
	RunNextTest();
}

/**
 * Generates a user with external auth so we can test that path
 */
function RegisterUserFacebook()
{
	`Log("Running test - RegisterUserFacebook");
	UserManager.OnRegisterUserComplete = OnRegisterUserFacebookComplete;
	UserManager.RegisterUserFacebook(FacebookId, FacebookToken);
}

function OnRegisterUserFacebookComplete(string McpId, bool bWasSuccessful, string Error)
{
	if (bWasSuccessful && UserManager.GetUser(McpId, ExternalAuthUser))
	{
		`Log("Successfully registered a user via Facebook");
	}
	else
	{
		`Log("Failed to register a user with Error = " $ Error);
	}
	RunNextTest();
}

/**
 * Perform authentication using the data returned from the external registration attempt
 */
function AuthUserFacebook()
{
	`Log("Running test - AuthUserFacebook");
	UserManager.OnAuthenticateUserComplete = OnAuthUserFacebookComplete;
	UserManager.AuthenticateUserFacebook(FacebookId, FacebookToken, "");
}

function OnAuthUserFacebookComplete(string McpId, string Token, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		if (McpId == ExternalAuthUser.McpId)
		{
			ExternalAuthUser.Ticket = Token;
			`Log("Successfully authenticated a user via Facebook");
		}
		else
		{
			`Log("Wrong user returned from the auth request");
		}
	}
	else
	{
		`Log("Failed to authenticate the user with Error = " $ Error);
	}
	RunNextTest();
}

/**
 * Generates a user with external auth so we can test that path
 */
function RegisterUserGameCenter()
{
	`Log("Running test - RegisterUserGameCenter");
	UserManager.OnRegisterUserComplete = OnRegisterUserGameCenterComplete;
	GameCenterId = "GameCenterId_" $ Rand(10000);
	UserManager.RegisterUserGameCenter(GameCenterId);
}

function OnRegisterUserGameCenterComplete(string McpId, bool bWasSuccessful, string Error)
{
	if (bWasSuccessful && UserManager.GetUser(McpId, ExternalAuthUser))
	{
		`Log("Successfully registered a user via GameCenter");
	}
	else
	{
		`Log("Failed to register a user with Error = " $ Error);
	}
	RunNextTest();
}

/**
 * Perform authentication using the data returned from the external registration attempt
 */
function AuthUserGameCenter()
{
	`Log("Running test - AuthUserGameCenter");
	UserManager.OnAuthenticateUserComplete = OnAuthUserGameCenterComplete;
	UserManager.AuthenticateUserGameCenter(GameCenterId);
}

function OnAuthUserGameCenterComplete(string McpId, string Token, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		if (McpId == ExternalAuthUser.McpId)
		{
			ExternalAuthUser.Ticket = Token;
			`Log("Successfully authenticated a user via GameCenter");
		}
		else
		{
			`Log("Wrong user returned from the auth request");
		}
	}
	else
	{
		`Log("Failed to authenticate the user with Error = " $ Error);
	}
	RunNextTest();
}

/** Performs a query for the internal user we already have cached */
function QueryUser()
{
	`Log("Running test - QueryUser");
	UserManager.OnQueryUsersComplete = OnQueryUserComplete;
	UserManager.QueryUser(InternalAuthUser.McpId);
}

function OnQueryUserComplete(bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		`Log("QueryUser completed successfully");
	}
	else
	{
		`Log("QueryUser failed with Error = " $ Error);
	}
	RunNextTest();
}

/** Performs a query for the both users we already have cached */
function QueryUsers()
{
	local array<String> McpIds;

	`Log("Running test - QueryUsers");
	
	if (InternalAuthUser.McpId != "")
	{
		McpIds.AddItem(InternalAuthUser.McpId);
	}
	if (ExternalAuthUser.McpId != "")
	{
		McpIds.AddItem(ExternalAuthUser.McpId);
	}
	
	UserManager.OnQueryUsersComplete = OnQueryUsersComplete;
	UserManager.QueryUsers(InternalAuthUser.McpId, McpIds);
}

function OnQueryUsersComplete(bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		`Log("QueryUsers completed successfully");
	}
	else
	{
		`Log("QueryUsers failed with Error = " $ Error);
	}
	RunNextTest();
}

/**
 * Delete the generated user
 */
function DeleteUser()
{
	`Log("Running test - DeleteUser");

	UserManager.OnDeleteUserComplete = OnDeleteUserComplete;
	UserManager.DeleteUser(InternalAuthUser.McpId);
}

function OnDeleteUserComplete(bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		`Log("DeleteUser completed successfully");
	}
	else
	{
		`Log("DeleteUser failed with Error = " $ Error);
	}
	RunNextTest();
}

/** Used to get a notification when all of the tests are complete */
delegate Done();

