/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the user related MCP APIs
 */
class TestMcpMessaging extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;
/** The message manager to test */
var McpMessageBase MsgManager;

/** Where we are in our tests */
var int TestState;

/** Users for sending/receiving messages */
var McpUserStatus TestUsers[3];
var int UserCreatedCount;

var McpMessage TestMessage;

/**
 * Initializes the test suite with the shared user manager
 *
 * @param UserMan the share user manager to test with
 */
function Init(McpUserManagerBase UserMan, McpMessageBase MsgMan)
{
	UserManager = UserMan;
	MsgManager = MsgMan;
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
			SendMessage();
			break;
		case 2:
			QueryMessages();
			break;
		case 3:
			QueryMessageContents();
			break;
		case 4:
			DeleteMessage();
			break;
		case 5:
			DeleteUsers();
			break;
		case 6:
			Done();
			break;
	}
	TestState++;
}

/**
 * Generates a user with internal auth so we can test that path
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

/**
 * This test sends a message from user 0 to 1 & 2
 */
function SendMessage()
{
	local array<String> ToMcpIds;
	local array<byte> Contents;
	local int Index;

	ToMcpIds.AddItem(TestUsers[1].McpId);
	ToMcpIds.AddItem(TestUsers[2].McpId);

	for (Index = 0; Index < 100; Index++)
	{
		Contents.AddItem(Index);
	}

	MsgManager.OnCreateMessageComplete = OnCreateMessageComplete;
	MsgManager.CreateMessage(ToMcpIds, TestUsers[0].McpId, "Test Friendly Name", "Fake test msg", "You have a new message!", "2020-07-31", Contents);
}

function OnCreateMessageComplete(String McpId, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		`Log("Successfully sent the message");
	}
	else
	{
		`Log("Failed to send message with error:\n" $ Error);
	}
	RunNextTest();
}

/**
 * Reads the set of messages for user 1 (should be 1 message)
 */
function QueryMessages()
{
	`Log("Querying for TestUsers[1] messages");
	MsgManager.OnQueryMessagesComplete = OnQueryMessagesComplete;
	MsgManager.QueryMessages(TestUsers[1].McpId);
}

function OnQueryMessagesComplete(string UserId, bool bWasSuccessful, String Error)
{
	local McpMessageList MessageList;

	if (bWasSuccessful)
	{
		if (UserId != TestUsers[1].McpId)
		{
			`Log("Error: Wrong user was returned for QueryMessages(): got (" $ UserId $ "), expected (" $ TestUsers[1].McpId $ ")");
		}
		else
		{
			MsgManager.GetMessageList(TestUsers[1].McpId, MessageList);
			if  (MessageList.Messages.Length != 1)
			{
				`Log("Error: Wrong number of messages returned: got (" $ MessageList.Messages.Length $ "), expected 1");
			}
			else
			{
				TestMessage = MessageList.Messages[0];
				if (TestMessage.ToUniqueUserId != TestUsers[1].McpId)
				{
					`Log("Error: Wrong user was in the To for the message: got (" $ TestMessage.ToUniqueUserId $ "), expected (" $ TestUsers[1].McpId $ ")");
				}
				if (TestMessage.FromUniqueUserId != TestUsers[0].McpId)
				{
					`Log("Error: Wrong user was in the From for the message: got (" $ TestMessage.FromUniqueUserId $ "), expected (" $ TestUsers[0].McpId $ ")");
				}
				if (TestMessage.MessageType != "Fake test msg")
				{
					`Log("Error: Wrong Type for the message: got (" $ TestMessage.MessageType $ "), expected (Fake test msg)");
				}
				if (TestMessage.FromFriendlyName != "Test Friendly Name")
				{
					`Log("Error: Wrong From Friendly Name for the message: got (" $ TestMessage.FromFriendlyName $ "), expected (Test Friendly Name)");
				}
				if (TestMessage.ValidUntil != "2020-07-31")
				{
					`Log("Error: Wrong ValidUntil for the message: got (" $ TestMessage.ValidUntil $ "), expected (2020-07-31)");
				}
				if (TestMessage.MessageId == "")
				{
					`Log("Error: Empty message id for the message");
				}
				`Log("Finished reading messges for TestUsers[1]");
			}
		}
	}
	else
	{
		`Log("Failed to query messages with error:\n" $ Error);
	}
	RunNextTest();
}

/**
 * Reads the contents of the message for user 1
 */
function QueryMessageContents()
{
	`Log("Querying for the contents of message (" $ TestMessage.MessageId $ ")");
	MsgManager.OnQueryMessageContentsComplete = OnQueryMessageContentsComplete;
	MsgManager.QueryMessageContents(TestUsers[1].McpId, TestMessage.MessageId);
}

function OnQueryMessageContentsComplete(String MessageId, bool bWasSuccessful, String Error)
{
	local array<byte> Contents;
	local int ErrorAt;
	local int Index;

	if (bWasSuccessful)
	{
		if (MessageId != TestMessage.MessageId)
		{
			`Log("Error: Wrong MessageId for the contents: got (" $ MessageId $ "), expected (" $ TestMessage.MessageId $ ")");
		}
		MsgManager.GetMessageContents(TestMessage.MessageId, Contents);
		if (Contents.Length == 100)
		{
			ErrorAt = -1;
			// Loop through the array checking the data
			for (Index = 0; Index < 100; Index++)
			{
				if (Contents[Index] != Index)
				{
					ErrorAt = Index;
					break;
				}
			}
			// Check to see if there were errors and report where
			if (ErrorAt == -1)
			{
				`Log("Message contents match what was sent");
			}
			else
			{
				`Log("Message contents do not match what was sent at position " $ ErrorAt);
			}
		}
		else
		{
			`Log("Incorrect message length returned, got (" $ Contents.Length $ "), expected (100)");
		}
		`Log("Finished reading messge contents for MessageId (" $ TestMessage.MessageId $ ")");
	}
	else
	{
		`Log("Failed to query message contents with error:\n" $ Error);
	}
	RunNextTest();
}

/**
 * Deletes the message for user 1 from the server
 */
function DeleteMessage()
{
	`Log("Deleting message (" $ TestMessage.MessageId $ ")");
	MsgManager.OnDeleteMessageComplete = OnDeleteMessageComplete;
	MsgManager.DeleteMessage(TestUsers[1].McpId, TestMessage.MessageId);
}

function OnDeleteMessageComplete(String MessageId, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		if (MessageId != TestMessage.MessageId)
		{
			`Log("Error: Wrong MessageId returned from delete: got (" $ MessageId $ "), expected (" $ TestMessage.MessageId $ ")");
		}
		`Log("Finished deleting MessageId (" $ TestMessage.MessageId $ ")");
	}
	else
	{
		`Log("Failed to delete message with error:\n" $ Error);
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

/** Called once all of the tests have run */
delegate Done();
