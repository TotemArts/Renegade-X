/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Test object that checks all of the groups related MCP APIs
 */
class TestMcpGroups extends Object;

/** The user manager to test */
var McpUserManagerBase UserManager;

/** The user manager to test */
var McpGroupsBase GroupManager;

/** Where we are in our tests */
var int TestState;

/** Cached users for tests */
var McpUserStatus TestUser1;
var McpUserStatus TestUser2;
var McpUserStatus TestUser3;
var int UserCreatedCount;

/** Cached group (owned by TestUser1) for member tests */
var McpGroup TestGroup;

/**
 * Initializes the test suite with the shared managers
 *
 * @param UserMan the shared user manager to test with
 * @param GroupMan the shared group manager to test with
 */
function Init(McpUserManagerBase UserMan, McpGroupsBase GroupMan)
{
	UserManager = UserMan;
	GroupManager = GroupMan;
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
			CreateGroup();
			break;
		case 2:
			AddMembers();
			break;
		case 3:
			QueryGroupMembers();
			break;
		case 4:
			RemoveMembers();
			break;
		case 5:
			QueryGroups();
			break;
		case 6:
			DeleteGroup();
			break;
		case 7:
			DeleteUsers();
			break;
		case 8:
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
	`Log("Creating users for group tests");
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

/** Creates a group for test user 1 so we can add test users 2 & 3 to it */
function CreateGroup()
{
	`Log("Creating group for user 1");
	GroupManager.OnCreateGroupComplete = OnCreateGroupComplete;
	GroupManager.CreateGroup(TestUser1.McpId, "MyMob");
}

function OnCreateGroupComplete(McpGroup Group, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		TestGroup = Group;
		if (TestGroup.OwnerId != TestUser1.McpId)
		{
			`Log("Error: Group owner changed during create, expected \"" $ TestUser1.McpId $ "\", got \"" $ TestGroup.OwnerId $ "\"");
		}
		if (TestGroup.GroupName != "MyMob")
		{
			`Log("Error: Group name changed during create, expected \"MyMob\", got \"" $ TestGroup.GroupName $ "\"");
		}
		`Log("Group (" $ TestGroup.GroupId $ ") was successfully created");
	}
	else
	{
		`Log("Failed to create group for TestUser1 with error:\n" $ Error);
	}
	RunNextTest();
}

/** Adds users 2 & 3 to the group owned by 1 */
function AddMembers()
{
	local array<String> MemberIds;

	`Log("Adding test users 2 & 3 to group (" $ TestGroup.GroupId $ ")");
	MemberIds.AddItem(TestUser2.McpId);
	MemberIds.AddItem(TestUser3.McpId);

	GroupManager.OnAddGroupMembersComplete = OnAddGroupMembersComplete;
	GroupManager.AddGroupMembers(TestUser1.McpId, TestGroup.GroupId, MemberIds, false);
}

function OnAddGroupMembersComplete(String GroupId, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		if (TestGroup.GroupId != GroupId)
		{
			`Log("Error: Group id changed during member add, expected \"" $ TestGroup.GroupId $ "\", got \"" $ GroupId $ "\"");
		}
		`Log("Adding group members completed successfully");
	}
	else
	{
		`Log("Failed to add group members for Group (" $ TestGroup.GroupId $ ")");
	}
	RunNextTest();
}

/** Queries for the group members we just added */
function QueryGroupMembers()
{
	`Log("Querying group (" $ TestGroup.GroupId $ ") for members");
	GroupManager.OnQueryGroupMembersComplete = OnQueryGroupMembersComplete;
	GroupManager.QueryGroupMembers(TestUser1.McpId, TestGroup.GroupId);
}

function OnQueryGroupMembersComplete(String GroupId, bool bWasSuccessful, String Error)
{
	local int Index;
	local bool bFoundTestUser2;
	local bool bFoundTestUser3;

	if (bWasSuccessful)
	{
		if (TestGroup.GroupId != GroupId)
		{
			`Log("Error: Group id changed during member query, expected \"" $ TestGroup.GroupId $ "\", got \"" $ GroupId $ "\"");
		}
		else
		{
			// Verify users
			GroupManager.GetGroupMembers(GroupId, TestGroup.Members);
			for (Index = 0; Index < TestGroup.Members.Length; Index++)
			{
				if (TestGroup.Members[Index].MemberId == TestUser2.McpId)
				{
					if (bFoundTestUser2)
					{
						`Log("Error: Found user 2 more than once in the query group members results");
					}
					bFoundTestUser2 = true;
				}
				if (TestGroup.Members[Index].MemberId == TestUser3.McpId)
				{
					if (bFoundTestUser3)
					{
						`Log("Error: Found user 3 more than once in the query group members results");
					}
					bFoundTestUser3 = true;
				}
			}
			if (!bFoundTestUser2)
			{
				`Log("Error: Failed to find user 2 in the query group members results");
			}
			if (!bFoundTestUser3)
			{
				`Log("Error: Failed to find user 3 in the query group members results");
			}
		}
		`Log("Querying group members completed successfully");
	}
	else
	{
		`Log("Failed to query group members for Group (" $ TestGroup.GroupId $ ") with error:\n" $ Error);
	}
	RunNextTest();
}

/** Removes test user 2 from the list */
function RemoveMembers()
{
	local array<String> McpIds;

	`Log("Removing test user 2 from group (" $ TestGroup.GroupId $ ")");
	McpIds.AddItem(TestUser2.McpId);

	GroupManager.OnRemoveGroupMembersComplete = OnRemoveGroupMembersComplete;
	GroupManager.RemoveGroupMembers(TestUser1.McpId, TestGroup.GroupId, McpIds);
}

function OnRemoveGroupMembersComplete(String GroupId, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		if (TestGroup.GroupId != GroupId)
		{
			`Log("Error: Group id changed during member remove, expected \"" $ TestGroup.GroupId $ "\", got \"" $ GroupId $ "\"");
		}
		`Log("Removing group members completed successfully");
	}
	else
	{
		`Log("Failed to remove group members for Group (" $ TestGroup.GroupId $ ")");
	}
	RunNextTest();
}

/** Queries for the list of groups for test user 1 */
function QueryGroups()
{
	`Log("Querying group list for user (" $ TestUser1.McpId $ ")");
	GroupManager.OnQueryGroupsComplete = OnQueryGroupsComplete;
	GroupManager.QueryGroups(TestUser1.McpId);
}

function OnQueryGroupsComplete(string UserId, bool bWasSuccessful, String Error)
{
	local int Index;
	local McpGroupList GroupList;
	local bool bFoundTestUser2;
	local bool bFoundTestUser3;

	if (bWasSuccessful)
	{
		if (TestUser1.McpId != UserId)
		{
			`Log("Error: Mcp id changed during groups query, expected \"" $ TestUser1.McpId $ "\", got \"" $ UserId $ "\"");
		}
		else
		{
			// Verify groups
			GroupManager.GetGroupList(UserId, GroupList);
			if (GroupList.Groups.Length != 1)
			{
				`Log("Error: Wrong number of group members in group, expected \"1\", got \"" $ GroupList.Groups.Length $ "\"");
			}
			else if (TestGroup.GroupId != GroupList.Groups[0].GroupId)
			{
				`Log("Error: Wrong group id for group, expected \"" $ TestGroup.GroupId $"\", got \"" $ GroupList.Groups[0].GroupId $ "\"");
			}
			// Verify users
			GroupManager.GetGroupMembers(TestGroup.GroupId, TestGroup.Members);
			for (Index = 0; Index < TestGroup.Members.Length; Index++)
			{
				if (TestGroup.Members[Index].MemberId == TestUser2.McpId)
				{
					if (bFoundTestUser2)
					{
						`Log("Error: Found user 2 more than once in the query group members results");
					}
					bFoundTestUser2 = true;
				}
				if (TestGroup.Members[Index].MemberId == TestUser3.McpId)
				{
					if (bFoundTestUser3)
					{
						`Log("Error: Found user 3 more than once in the query group members results");
					}
					bFoundTestUser3 = true;
				}
			}
			if (bFoundTestUser2)
			{
				`Log("Error: Found user 2 after they have been deleted");
			}
			if (!bFoundTestUser3)
			{
				`Log("Error: Failed to find user 3 in the query group list results");
			}
		}
		`Log("Querying group list completed successfully");
	}
	else
	{
		`Log("Failed to query group list for User (" $ TestUser1.McpId $ ") with error:\n" $ Error);
	}
	RunNextTest();
}

/** Deletes the group for the test user */
function DeleteGroup()
{
	`Log("Deleting group (" $ TestGroup.GroupId $ ") for user (" $ TestUser1.McpId $ ")");
	GroupManager.OnDeleteGroupComplete = OnDeleteGroupComplete;
	GroupManager.DeleteGroup(TestUser1.McpId, TestGroup.GroupId);
}

function OnDeleteGroupComplete(String GroupId, bool bWasSuccessful, String Error)
{
	if (bWasSuccessful)
	{
		if (TestGroup.GroupId != GroupId)
		{
			`Log("Error: Group id changed during delete, expected \"" $ TestGroup.GroupId $ "\", got \"" $ GroupId $ "\"");
		}
		`Log("Group (" $ GroupId $ ") was successfully deleted");
	}
	else
	{
		`Log("Failed to delete group (" $ TestGroup.GroupId $ " for TestUser1 with error:\n" $ Error);
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
