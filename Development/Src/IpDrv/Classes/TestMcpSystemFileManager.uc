/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the system file related MCP APIs
 */
class TestMcpSystemFileManager extends Object;

/** The system file manager to test */
var OnlineTitleFileInterface SystemFileManager;

/** Where we are in our tests */
var int TestState;

/** Holds the list of files we are downloading */
var array<EmsFile> FileList;
var int FilesRead;

/**
 * Initializes the test suite with the system file interface
 *
 * @param SystemFileMan the system interface to test with
 */
function Init(OnlineTitleFileInterface SystemFileMan)
{
	SystemFileManager = SystemFileMan;
}

/**
 * Uses the state machine to execute a series of tests
 */
function RunNextTest()
{
	switch (TestState)
	{
		case 0:
			ReadTitleFileList();
			break;
		case 1:
			ReadFiles();
			break;
		case 2:
			Done();
			break;
	}
	TestState++;
}

/** Gets the list of available files to download */
function ReadTitleFileList()
{
	`Log("Running test - ReadTitleFileList");

	SystemFileManager.AddRequestTitleFileListCompleteDelegate(OnRequestTitleFileListComplete);
	SystemFileManager.RequestTitleFileList();
}

function OnRequestTitleFileListComplete(bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		`Log("ReadTitleFileList completed successfully");
	}
	else
	{
		`Log("ReadTitleFileList failed with Error = " $ Error);
	}
	RunNextTest();
}

/** Requests each file from the backend */
function ReadFiles()
{
	local int FileIndex;
	`Log("Running test - ReadFiles");

	SystemFileManager.AddReadTitleFileCompleteDelegate(OnReadTitleFileComplete);
	SystemFileManager.GetTitleFileList(FileList);
	for (FileIndex = 0; FileIndex < FileList.Length; FileIndex++)
	{
		SystemFileManager.ReadTitleFile(FileList[FileIndex].FileName);
	}
}

function OnReadTitleFileComplete(bool bWasSuccessful, String FileName)
{
	FilesRead++;
	if (bWasSuccessful)
	{
		`Log("Read file (" $ FileName $ ") successfully");
	}
	else
	{
		`Log("Failed to read file (" $ FileName $ ")");
	}
	if (FilesRead == FileList.Length)
	{
		RunNextTest();
	}
}

/** Used to get a notification when all of the tests are complete */
delegate Done();
