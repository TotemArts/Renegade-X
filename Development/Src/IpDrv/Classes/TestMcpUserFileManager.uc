/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the system file related MCP APIs
 */
class TestMcpUserFileManager extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;
/** The user file manager to test */
var UserCloudFileInterface UserFileManager;

/** Where we are in our tests */
var int TestState;

/** Holds the list of files we are downloading */
var array<EmsFile> UserFiles;

var McpUserStatus TestUser;

/**
 * Initializes the test suite with the user file interface
 *
 * @param UserMan the user manager to test with
 * @param UserFileMan the file interface to test with
 */
function Init(McpUserManagerBase UserMan, UserCloudFileInterface UserFileMan)
{
	UserManager = UserMan;
	UserFileManager = UserFileMan;
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
			WriteFileForUser();
			break;
		case 2:
			EnumerateFilesForUser();
			break;
		case 3:
			ReadFileForUser();
			break;
		case 4:
			ReadLastNOwners();
			break;
		case 5:
			DeleteFileForUser();
			break;
		case 6:
			DeleteUser();
			break;
		case 7:
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
	`Log("Creating user for cloud file tests");
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
			`Log("All user created successfully");
		}
 	}
	RunNextTest();
}

/** Saves a file to the cloud for the user */
function WriteFileForUser()
{
	local array<byte> Contents;
	local int Index;

	for (Index = 0; Index < 100; Index++)
	{
		Contents.AddItem(Index);
	}

	`Log("Saving 100 byte file CloudSave.sav for user (" $ TestUser.McpId $ ")");
	UserFileManager.AddWriteUserFileCompleteDelegate(OnWriteUserFileComplete);
	UserFileManager.WriteUserFile(TestUser.McpId, "CloudSave.sav", Contents);
}

function OnWriteUserFileComplete(bool bWasSuccessful,string UserId,string FileName)
{
	if (bWasSuccessful)
	{
		`Log("Writing for file (" $ FileName $ ") for user (" $ UserId $ ") was successful");
	}
	else
	{
		`Log("Failed to write file (" $ FileName $ ") for user (" $ UserId $ ")");
	}
	RunNextTest();
}

/** Lists the files in the cloud for the user */
function EnumerateFilesForUser()
{
	`Log("Enumerating cloud files for user (" $ TestUser.McpId $ ")");
	UserFileManager.AddEnumerateUserFileCompleteDelegate(OnEnumerateUserFilesComplete);
	UserFileManager.EnumerateUserFiles(TestUser.McpId);
}

function OnEnumerateUserFilesComplete(bool bWasSuccessful,string UserId)
{
	if (bWasSuccessful)
	{
		`Log("Enumerated files for user (" $ UserId $ ")");
		UserFileManager.GetUserFileList(UserId, UserFiles);
		if (UserFiles.Length != 1)
		{
			`Log("Wrong number of files returned for user: got (" $ UserFiles.Length $ "), expected (1)");
		}
		else
		{
			if (UserFiles[0].FileName != "CloudSave.sav")
			{
				`Log("Wrong file name returned for user file: got (" $ UserFiles[0].FileName $ "), expected (CloudSave.sav)");
			}
			if (UserFiles[0].FileSize != 100)
			{
				`Log("Wrong file size returned for user file: got (" $ UserFiles[0].FileSize $ "), expected (100)");
			}
			`Log("Unique file name is (" $ UserFiles[0].DLName $ ")");
		}
	}
	else
	{
		`Log("Failed to enumerate files for user (" $ UserId $ ")");
	}
	RunNextTest();
}

/** Lists the files in the cloud for the user */
function ReadFileForUser()
{
	`Log("Reading cloud file (CloudSave.sav) for user (" $ TestUser.McpId $ ")");
	UserFileManager.AddReadUserFileCompleteDelegate(OnReadUserFileComplete);
	UserFileManager.ReadUserFile(TestUser.McpId, "CloudSave.sav");
}

function OnReadUserFileComplete(bool bWasSuccessful,string UserId, String FileName)
{
	local array<byte> Contents;
	local int ErrorAt;
	local int Index;

	if (bWasSuccessful)
	{
		`Log("Read file (" $ FileName $ ") for user (" $ UserId $ ")");
		UserFileManager.GetFileContents(UserId, FileName, Contents);
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
				`Log("File contents match what was written");
			}
			else
			{
				`Log("File contents do not match what was written at position " $ ErrorAt);
			}
		}
		else
		{
			`Log("Incorrect file length returned, got (" $ Contents.Length $ "), expected (100)");
		}
		// Clear the file data and double check that worked
		UserFileManager.ClearFile(UserId, FileName);
		UserFileManager.GetFileContents(UserId, FileName, Contents);
		if (Contents.Length != 0)
		{
			`Log("Incorrect file length returned after clear file contents, got (" $ Contents.Length $ "), expected (0)");
		}
	}
	else
	{
		`Log("Failed to read file (" $ FileName $ ") for user (" $ UserId $ ")");
	}
	RunNextTest();
}

function ReadLastNOwners()
{
	`Log("Reading the last 15 people to write cloud save files");
	UserFileManager.AddReadLastNCloudSaveOwnersCompleteDelegate(OnReadLastNOwnersComplete);
	UserFileManager.ReadLastNCloudSaveOwners(15);
}

function OnReadLastNOwnersComplete(bool bWasSuccessful)
{
	local array<String> McpIds;
	local int Index;

	UserFileManager.ClearReadLastNCloudSaveOwnersCompleteDelegate(OnReadLastNOwnersComplete);
	if (bWasSuccessful)
	{
		UserFileManager.GetLastNCloudSaveOwners(McpIds);
		`Log("Read last (" $ McpIds.Length $ ") people to write cloud saves");
		for (Index = 0; Index < McpIds.Length; Index++)
		{
			`Log("McpIds[" $ Index $ "] = " $ McpIds[Index]);
		}
	}
	else
	{
		`Log("Failed to read last N people to write cloud saves");
	}
	RunNextTest();
}

/** Lists the files in the cloud for the user */
function DeleteFileForUser()
{
	`Log("Deleting cloud file (CloudSave.sav) for user (" $ TestUser.McpId $ ")");
	UserFileManager.AddDeleteUserFileCompleteDelegate(OnDeleteUserFileComplete);
	UserFileManager.DeleteUserFile(TestUser.McpId, "CloudSave.sav", true, true);
}

function OnDeleteUserFileComplete(bool bWasSuccessful,string UserId, String FileName)
{
	if (bWasSuccessful)
	{
		`Log("Deleted file (" $ FileName $ ") for user (" $ UserId $ ")");
	}
	else
	{
		`Log("Failed to delete file (" $ FileName $ ") for user (" $ UserId $ ")");
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
