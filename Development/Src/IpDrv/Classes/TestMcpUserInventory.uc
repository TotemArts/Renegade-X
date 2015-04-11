/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the user related MCP APIs
 */
class TestMcpUserInventory extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;
/** The inventory manager to test */
var McpUserInventoryBase InventoryManager;

/** Where we are in our tests */
var int TestState;

/** Test user */
var McpUserStatus TestUser;

/**
 * Initializes the test suite with the shared user manager
 *
 * @param UserMan the share user manager to test with
 * @param InventoryMan the inventory manager to test with
 */
function Init(McpUserManagerBase UserMan, McpUserInventoryBase InventoryMan)
{
	UserManager = UserMan;
	InventoryManager = InventoryMan;
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
			CreateSaveSlot();
			break;
		case 2:
			RecordIap();
			break;
		case 3:
			DeleteSaveSlot();
			break;
		case 4:
			DeleteUser();
			break;
		case 5:
			Done();
			break;
	}
	TestState++;
}

/**
 * Generates a user with internal auth so we can test that path
 */
function CreateUserForTest()
{
	`Log("Creating users for tests");
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
			`Log("Test user created successfully");
		}
		else
		{
			`Log("Test user create failed");
		}
 	}
	else
	{
		`Log("Test user create failed");
	}
	RunNextTest();
}

/** Create a save slot for the user */
function CreateSaveSlot()
{
	`Log("Creating a save slot for temp user");
	InventoryManager.OnCreateSaveSlotComplete = OnCreateSaveSlotComplete;
	InventoryManager.CreateSaveSlot(TestUser.McpId, "SaveSlot1");
}

function OnCreateSaveSlotComplete(string McpId, string SaveSlotId, bool bWasSuccessful, string Error)
{
	if (bWasSuccessful)
	{
		`Log("Created a save slot successfully for temp user");
	}
	else
	{
		`Log("Failed to create a save slot for user with error:\n" $ Error);
	}
	RunNextTest();
}

/** Record an IAP for the user */
function RecordIap()
{
	local String IapReceipt;

	`Log("Recording an IAP for user " $ TestUser.McpId);

	// The receipt data is too large to be a constant
	IapReceipt = "ewoJInNpZ25hdHVyZSIgPSAiQXNSREtYZ2MwcjIvUk0veGptVmtlenJ6VzJBeVlzOWNHM2JodHNTeFh2RGRJZDJYSzBFVGMvcDVQc0VrN09SaGNWNzByRmdZem9sUlIvWWYwcjRMQ0xRUTdHdi9GeXc0dnJLVVlHWWxJcHEyRE10MmI1cUxDV1hyQ05";
	IapReceipt $= "zOERDcDhtUlNIdFVudXJTVlpYWGJCTnhHU3JCc1hlTmVvRzZrc25qWXYwRlFPem5wRkFBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpi";
	IapReceipt $= "bU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvW";
	IapReceipt $= "ERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE";
	IapReceipt $= "1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFR";
	IapReceipt $= "ldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgv";
	IapReceipt $= "QkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQO";
	IapReceipt $= "TNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdl";
	IapReceipt $= "hqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJ";
	IapReceipt $= "jaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREV6TFRBMkxURTVJREV4T2pJd09qTTJJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluVnVhWEYxWlMxcFpHVnVkR2xtYVdWeUlpQTlJQ0l3";
	IapReceipt $= "Wm1VeVpUazBaREUzWWpkbU9HVXdNemRrWXpJelpXUTJNalUxTmpVd1pUWTVORGc0TWpCaElqc0tDU0p2Y21sbmFXNWhiQzEwY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTVRBd01EQXdNREEzTnprME16RXhNU0k3Q2draVluWnljeUlnUFNBaU1URXpNRGN1TVRNMUlqc";
	IapReceipt $= "0tDU0owY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTVRBd01EQXdNREEzTnprME16RXhNU0k3Q2draWNYVmhiblJwZEhraUlEMGdJakVpT3dvSkltOXlhV2RwYm1Gc0xYQjFjbU5vWVhObExXUmhkR1V0YlhNaUlEMGdJakV6TnpFMk5qWXdNell6TmpVaU93b0pJbkJ5Yj";
	IapReceipt $= "JSMVkzUXRhV1FpSUQwZ0ltTnZiUzVqYUdGcGNpNUpRak11WTJocGNITXVNVEl3TUNJN0Nna2lhWFJsYlMxcFpDSWdQU0FpTmpRM09UazBPRFE0SWpzS0NTSmlhV1FpSUQwZ0ltTnZiUzVqYUdGcGNtVnVkR1Z5ZEdGcGJtMWxiblF1U1VJeklqc0tDU0p3ZFhKamFHRnpa";
	IapReceipt $= "UzFrWVhSbExXMXpJaUE5SUNJeE16Y3hOalkyTURNMk16WTFJanNLQ1NKd2RYSmphR0Z6WlMxa1lYUmxJaUE5SUNJeU1ERXpMVEEyTFRFNUlERTRPakl3T2pNMklFVjBZeTlIVFZRaU93b0pJbkIxY21Ob1lYTmxMV1JoZEdVdGNITjBJaUE5SUNJeU1ERXpMVEEyTFRFNU";
	IapReceipt $= "lERXhPakl3T2pNMklFRnRaWEpwWTJFdlRHOXpYMEZ1WjJWc1pYTWlPd29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVWlJRDBnSWpJd01UTXRNRFl0TVRrZ01UZzZNakE2TXpZZ1JYUmpMMGROVkNJN0NuMD0iOwoJImVudmlyb25tZW50IiA9ICJTYW5kYm94";
	IapReceipt $= "IjsKCSJwb2QiID0gIjEwMCI7Cgkic2lnbmluZy1zdGF0dXMiID0gIjAiOwp9";
	
	InventoryManager.OnRecordIapComplete = OnRecordIapComplete;
	InventoryManager.RecordIap(TestUser.McpId, "SaveSlot1", "APPLE", IapReceipt);
}

function OnRecordIapComplete(string McpId, string SaveSlotId, array<McpIapItem> UpdatedItemIds, bool bWasSuccessful, string Error)
{
	local int Index;

	if (bWasSuccessful)
	{
		`Log("Record IAP for user succeeded");
		for (Index = 0; Index < UpdatedItemIds.Length; Index++)
		{
			`Log("    Item added to inventory is (" $ UpdatedItemIds[Index].ItemId $ ") with quantity (" $ UpdatedItemIds[Index].Quantity $ ")");
		}
 	}
	else
	{
		`Log("Record IAP for user failed:\n" $ Error);
	}
	RunNextTest();
}

/** Delete a save slot for the user */
function DeleteSaveSlot()
{
	`Log("Deleting a save slot for temp user");
	InventoryManager.OnDeleteSaveSlotComplete = OnDeleteSaveSlotComplete;
	InventoryManager.DeleteSaveSlot(TestUser.McpId, "SaveSlot1");
}

function OnDeleteSaveSlotComplete(string McpId, string SaveSlotId, bool bWasSuccessful, string Error)
{
	if (bWasSuccessful)
	{
		`Log("Deleted a save slot successfully for temp user");
	}
	else
	{
		`Log("Failed to delete a save slot for user with error:\n" $ Error);
	}
	RunNextTest();
}

/** Delete our temp users from the database since they aren't needed anymore */
function DeleteUser()
{
	`Log("Deleting temp users");
	UserManager.OnDeleteUserComplete = OnDeleteUserComplete;
	UserManager.DeleteUser(TestUser.McpId);
}

function OnDeleteUserComplete(bool bWasSuccessful, String Error)
{
	`Log("Deleted temp users");
	RunNextTest();
}

/** Called once all of the tests have run */
delegate Done();
