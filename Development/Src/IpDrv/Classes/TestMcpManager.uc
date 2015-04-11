/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Cheat manager that exercises the MCP integration APIs
 */
class TestMcpManager extends CheatManager;

/** Classes that test the APIs */
var TestMcpUser UserTest;
var TestMcpGroups GroupsTest;
var TestMcpIdMapping IdMappingTest;
var TestMcpMessaging MessagingTest;
var TestMcpUserInventory InventoryTest;
var TestMcpSystemFileManager SystemFileTest;
var TestMcpUserFileManager UserFileTest;
var TestClashMobManager ClashMobTest;
var TestMcpThreadedChat ChatTest;
var TestMcpLeaderboards LeaderboardsTest;

/** Singletons for tests */
var McpUserManagerBase UserManager;
var McpGroupsBase GroupManager;
var McpIdMappingBase IdManagerManager;
var McpMessageBase MessagingManager;
var McpServerTimeBase ServerTimeManager;
var McpUserInventoryBase InventoryManager;
var OnlineTitleFileInterface TitleFileManager;
var UserCloudFileInterface UserFileManager;
var McpClashMobBase ClashMobManager;
var McpThreadedChatBase ChatManager;
var McpLeaderboardsBase LeaderboardManager;

/** @return the singleton to use for user interaction */
function McpUserManagerBase GetUserManager()
{
	if (UserManager == None)
	{
		UserManager = class'McpUserManagerBase'.static.CreateInstance();
	}
	return UserManager;
}

/** @return the singleton to use for group interaction */
function McpGroupsBase GetGroupManager()
{
	if (GroupManager == None)
	{
		GroupManager = class'McpGroupsBase'.static.CreateInstance();
	}
	return GroupManager;
}

/** @return the singleton to use for mapping interaction */
function McpIdMappingBase GetIdMappingManager()
{
	if (IdManagerManager == None)
	{
		IdManagerManager = class'McpIdMappingBase'.static.CreateInstance();
	}
	return IdManagerManager;
}

/** @return the singleton to use for messaging interaction */
function McpMessageBase GetMessagingManager()
{
	if (MessagingManager == None)
	{
		MessagingManager = class'McpMessageBase'.static.CreateInstance();
	}
	return MessagingManager;
}

/** @return the singleton to use for server time interaction */
function McpServerTimeBase GetServerTimeManager()
{
	if (ServerTimeManager == None)
	{
		ServerTimeManager = class'McpServerTimeBase'.static.CreateInstance();
	}
	return ServerTimeManager;
}

/** @return the singleton to use for server time interaction */
function McpUserInventoryBase GetInventoryManager()
{
	if (InventoryManager == None)
	{
		InventoryManager = class'McpUserInventoryBase'.static.CreateInstance();
	}
	return InventoryManager;
}

/** @return the singleton to use for system cloud files interaction */
function OnlineTitleFileInterface GetTitleFileManager()
{
	if (TitleFileManager == None)
	{
		TitleFileManager = class'GameEngine'.static.GetOnlineSubsystem().TitleFileInterface;
	}
	return TitleFileManager;
}

/** @return the singleton to use for user cloud files interaction */
function UserCloudFileInterface GetUserFileManager()
{
	if (UserFileManager == None)
	{
		UserFileManager = class'GameEngine'.static.GetOnlineSubsystem().UserCloudInterface;
	}
	return UserFileManager;
}

/** @return the singleton to use for ClashMob interaction */
function McpClashMobBase GetClashMobManager()
{
	if (ClashMobManager == None)
	{
		ClashMobManager = class'McpClashMobBase'.static.CreateInstance();
	}
	return ClashMobManager;
}

/** @return the singleton to use for chat interaction */
function McpThreadedChatBase GetChatManager()
{
	if (ChatManager == None)
	{
		ChatManager = class'McpThreadedChatBase'.static.CreateInstance();
	}
	return ChatManager;
}

/** @return the singleton to use for leaderboard interaction */
function McpLeaderboardsBase GetLeaderboardManager()
{
	if (LeaderboardManager == None)
	{
		LeaderboardManager = class'McpLeaderboardsBase'.static.CreateInstance();
	}
	return LeaderboardManager;
}

/** Starts the user tests */
exec function RunUserTests()
{
	UserTest = new class'TestMcpUser';
	UserTest.Init(GetUserManager());
	UserTest.Done = OnUserTestsComplete;
	UserTest.RunNextTest();
}

function OnUserTestsComplete()
{
	`Log("All user tests have completed");
}

/** Starts the group tests */
exec function RunGroupTests()
{
	GroupsTest = new class'TestMcpGroups';
	GroupsTest.Init(GetUserManager(), GetGroupManager());
	GroupsTest.Done = OnGroupTestsComplete;
	GroupsTest.RunNextTest();
}

function OnGroupTestsComplete()
{
	`Log("All group tests have completed");
}

/** Starts the id mapping tests */
exec function RunIdMappingTests()
{
	IdMappingTest = new class'TestMcpIdMapping';
	IdMappingTest.Init(GetUserManager(), GetIdMappingManager());
	IdMappingTest.Done = OnIdMappingTestsComplete;
	IdMappingTest.RunNextTest();
}

function OnIdMappingTestsComplete()
{
	`Log("All id mapping tests have completed");
}

/** Starts the messaging tests */
exec function RunMessagingTests()
{
	MessagingTest = new class'TestMcpMessaging';
	MessagingTest.Init(GetUserManager(), GetMessagingManager());
	MessagingTest.Done = OnMessagingTestsComplete;
	MessagingTest.RunNextTest();
}

function OnMessagingTestsComplete()
{
	`Log("All messaging tests have completed");
}

/** Runs the base64 encoding/decoding tests */
exec function RunBase64Tests()
{
	class'Base64'.static.TestStringVersion();
}

/** Queries the server for the time */
exec function RunServerTimeTest()
{
	GetServerTimeManager().OnQueryServerTimeComplete = OnQueryServerTimeComplete;
	GetServerTimeManager().QueryServerTime();
}

function OnQueryServerTimeComplete(bool bWasSuccessful, string DateTimeStr, string Error)
{
	if (bWasSuccessful)
	{
		`Log("Server time is: " $ GetServerTimeManager().GetLastServerTime());
	}
	else
	{
		`Log("Failed to get server time");
	}
}

/** Starts the inventory tests */
exec function RunInventoryTests()
{
	InventoryTest = new class'TestMcpUserInventory';
	InventoryTest.Init(GetUserManager(), GetInventoryManager());
	InventoryTest.Done = OnInventoryTestsComplete;
	InventoryTest.RunNextTest();
}

function OnInventoryTestsComplete()
{
	`Log("All inventory tests have completed");
}

/** Starts the system file tests */
exec function RunSystemCloudFileTests()
{
	SystemFileTest = new class'TestMcpSystemFileManager';
	SystemFileTest.Init(GetTitleFileManager());
	SystemFileTest.Done = OnSystemFileTestsComplete;
	SystemFileTest.RunNextTest();
}

function OnSystemFileTestsComplete()
{
	`Log("All system file tests have completed");
}

/** Starts the user cloud file tests */
exec function RunUserCloudFileTests()
{
	UserFileTest = new class'TestMcpUserFileManager';
	UserFileTest.Init(GetUserManager(), GetUserFileManager());
	UserFileTest.Done = OnUserFileTestsComplete;
	UserFileTest.RunNextTest();
}

function OnUserFileTestsComplete()
{
	`Log("All user cloud file tests have completed");
}

/** Starts the ClashMob tests */
exec function RunClashMobTests(optional String ParentId, optional String ChildId)
{
	ClashMobTest = new class'TestClashMobManager';
	ClashMobTest.Init(GetUserManager(), GetClashMobManager(), ParentId, ChildId);
	ClashMobTest.Done = OnClashMobTestsComplete;
	ClashMobTest.RunNextTest();
}

function OnClashMobTestsComplete()
{
	`Log("All ClashMob tests have completed");
}

/** Starts the chat thread tests */
exec function RunChatTests()
{
	ChatTest = new class'TestMcpThreadedChat';
	ChatTest.Init(GetUserManager(), GetChatManager());
	ChatTest.Done = OnChatTestsComplete;
	ChatTest.RunNextTest();
}

function OnChatTestsComplete()
{
	`Log("All chat tests have completed");
}

/** Starts the leaderboard tests */
exec function RunLeaderboardTests()
{
	LeaderboardsTest = new class'TestMcpLeaderboards';
	LeaderboardsTest.Init(GetUserManager(), GetLeaderboardManager());
	LeaderboardsTest.Done = OnLeaderboardTestsComplete;
	LeaderboardsTest.RunNextTest();
}

function OnLeaderboardTestsComplete()
{
	`Log("All leaderboard tests have completed");
}
