/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Concrete implementation for managing groups through the groups web API
 */
class McpGroupsManagerV3 extends McpGroupsBase
	config(Engine);

`include(Engine\Classes\HttpStatusCodes.uci)

/** The URL of group resource on the server */
var config string GroupsUrl;

/** The URL of group member resource on the server */
var config string GroupMembersUrl;

/** Holds the list of groups that we know about */
var array<McpGroup> Groups;

/** Holds the state information for an outstanding user request */
struct GroupRequest
{
	/** The Group id that was returned by the backend */
	var string GroupId;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

struct GroupUserRequest
{
	/** The user performing the action */
	var string McpId;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

struct GroupMemberRequest
{
	/** The user performing the action */
	var string McpId;
	/** The group being operated upon */
	var string GroupId;
	/** The set of members being operated on */
	var array<String> Members;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

/** The set of delete requests that are pending */
var array<GroupRequest> DeleteGroupRequests;

/** The set of delete all requests that are pending */
var array<GroupUserRequest> DeleteAllRequests;

/** The set of group member operations in flight */
var array<GroupMemberRequest> GroupMemberRequests;

/**
 * @return the path to the user's groups resource
 */
function String BuildGroupResourcePath(String McpId)
{
	return GetBaseURL() $ Repl(GroupsUrl, "{epicId}", McpId);
}

/**
 * @return the path to the user's group's members resource
 */
function String BuildGroupMemberResourcePath(String GroupId, String McpId)
{
	local String Path;

	Path = Repl(GroupMembersUrl, "{epicId}", McpId);
	Path = Repl(Path, "{groupId}", GroupId);

	return GetBaseURL() $ Path;
}

/**
 * Creates the URL and sends the request to create a group.
 *
 * @param UniqueUserId the UserId that will own the group
 * @param GroupName The name the group will be created with
 */
function CreateGroup(String UniqueUserId, String GroupName)
{
	local String Url;
	local HttpRequestInterface Request;
	local McpGroup FailedGroup;
	
	// Ensure that UniqueUserId and GroupName both have values
	if (Len(UniqueUserId) > 0 && Len(GroupName) > 0)
	{
		Request = CreateHttpRequest(UniqueUserId);
		if (Request != none)
		{
			// Build the REST path and JSON payload
			Url = BuildGroupResourcePath(UniqueUserId);
			// Build our web request with the above URL
			Request.SetURL(URL);
			Request.SetVerb("POST");
			Request.SetContentAsString(GroupName);
			Request.SetProcessRequestCompleteDelegate(OnCreateGroupRequestComplete);
			// Call Web Request
			if (!Request.ProcessRequest())
			{
				`LogMcp(`Location@"Failed to process web request for URL(" $ Url $ ")");
			}
			`LogMcp("CreateGroup URL is POST " $ Url);
		}
		else
		{
			OnCreateGroupComplete(FailedGroup, false, "HttpRequest was not be created");
		}
	}
	else
	{
		OnCreateGroupComplete(FailedGroup, false, "UserId or GroupName wasn't specified");
	}
}

/**
 * Parses the group json
 * 
 * @param ParsedJson the json DOM
 * 
 * @return the index of the group that was parsed
 */
protected function int ParseGroup(JsonObject ParsedJson)
{
	local JsonObject MembersArray;
	local JsonObject JsonElement;
	local int GroupIndex;
	local int JsonIndex;
	local string GroupId;
	local McpGroupMember Member;

	GroupIndex = INDEX_NONE;
	// Example JSON:
	//{
	//	"id":"someBigId",
	//	"ownerEpicId": "someBigId",
	//	"name":"MyMob",
	//	"members":
	//	{
	//		[
	//			"epicId": "someBigId",
	//			...
	//		]
	//	}
	//}
	// If it doesn't have this field, this is bogus JSON
	if (ParsedJson.HasKey("id"))
	{
		GroupId = ParsedJson.GetStringValue("id");
		// See if we already have a user
		GroupIndex = Groups.Find('GroupId', GroupId);
		if (GroupIndex == INDEX_NONE)
		{
			// Not stored yet, so add one
			GroupIndex = Groups.Length;
			Groups.Length = GroupIndex + 1;
			Groups[GroupIndex].GroupId = GroupId;
			Groups[GroupIndex].AccessLevel = MGAL_Owner;
		}
		Groups[GroupIndex].OwnerId = ParsedJson.GetStringValue("ownerEpicId");
		Groups[GroupIndex].GroupName = ParsedJson.GetStringValue("name");
		MembersArray = ParsedJson.GetObject("members");
		if (MembersArray != none)
		{
			Member.AcceptState = MGAS_Accepted;
			// Add all of the members
			for (JsonIndex = 0; JsonIndex < MembersArray.ObjectArray.Length; JsonIndex++)
			{
				JsonElement = MembersArray.ObjectArray[JsonIndex];
				Member.MemberId = JsonElement.GetStringValue("epicId");
				// Don't add if it already exists
				if (Groups[GroupIndex].Members.Find('MemberId', Member.MemberId) == INDEX_NONE)
				{
					Groups[GroupIndex].Members.AddItem(Member);
				}
			}
		}
	}
	return GroupIndex;
}

/**
 * Called once the request/response has completed. 
 * Used to return any errors and notify any registered delegate
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnCreateGroupRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local McpGroup CreatedGroup;
	local String JsonString;
	local JsonObject ParsedJson;
	local String Error;
	local int GroupIndex;

	ResponseCode = `HTTP_STATUS_SERVER_ERROR;
	if (Response != none && Request != none)
	{
		ResponseCode = Response.GetResponseCode();
		JsonString = Response.GetContentAsString();
		// All of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode) && JsonString != "";
		if (bWasSuccessful)
		{
			// Parse the json and store in our array
			ParsedJson = class'JsonObject'.static.DecodeJson(JsonString);
			GroupIndex = ParseGroup(ParsedJson);
			// Copy for the callback
			CreatedGroup = Groups[GroupIndex];
		}
		else
		{
			Error = "Couldn't parse the JSON payload from the group create with status code (" $ ResponseCode $ ") and payload of:\n" $ JsonString;
		}
	}
	OnCreateGroupComplete(CreatedGroup, bWasSuccessful, Error);
}

/**
 * Deletes a Group by GroupId
 * 
 * @param UniqueUserId UserId of the owner of the Group
 * @param GroupId Id of the group
 */
function DeleteGroup(String UniqueUserId, String GroupId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	
	// Ensure that UniqueUserId and GroupId both have values
	if (Len(UniqueUserId) > 0 && Len(GroupId) > 0)
	{
		Request = CreateHttpRequest(UniqueUserId);
		if (Request != none)
		{
			// Build the REST path and JSON payload
			Url = BuildGroupResourcePath(UniqueUserId) $ "/" $ GroupId;
			// Build our web request with the above URL
			Request.SetURL(URL);
			Request.SetVerb("DELETE");
			Request.SetProcessRequestCompleteDelegate(OnDeleteGroupRequestComplete);
			// Store off the data for reporting later
			AddAt = DeleteGroupRequests.Length;
			DeleteGroupRequests.Length = AddAt + 1;
			DeleteGroupRequests[AddAt].GroupId = GroupId;
			DeleteGroupRequests[AddAt].Request = Request;
			// Call Web Request
			if (!Request.ProcessRequest())
			{
				`LogMcp(`Location@"Failed to process web request for URL(" $ Url $ ")");
			}
			`LogMcp("DeleteGroup URL is DELETE " $ Url);
		}
		else
		{
			OnDeleteGroupComplete(GroupId, false, "HttpRequest was not be created");
		}
	}
	else
	{
		OnDeleteGroupComplete(GroupId, false, "UserId or GroupName wasn't specified");
	}
}

/**
 * Called once the request/response has completed. 
 * Used to process the response and notify any
 * registered delegate
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnDeleteGroupRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local int Index;
	local String GroupId;
	local int GroupIndex;
	local String Error;

	ResponseCode = `HTTP_STATUS_SERVER_ERROR;
	if (Response != None)
	{
		ResponseCode = Response.GetResponseCode();
	}

	// Find our cached data in our outstanding list
	Index = DeleteGroupRequests.Find('Request', Request);
	bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode) && Index != INDEX_NONE && Response != None;
	if (bWasSuccessful)
	{
		GroupId = DeleteGroupRequests[Index].GroupId;
		GroupIndex = Groups.Find('GroupId', GroupId);
		if (GroupIndex != INDEX_NONE)
		{
			// Remove this from our cache
			Groups.Remove(GroupIndex, 1);
		}
	}
	else
	{
		if (Index != INDEX_NONE)
		{
			Error = "Failed to delete group (" $ DeleteGroupRequests[Index].GroupId $ ") with status code (" $ ResponseCode $ ")";
		}
		else
		{
			Error = "Unknown request with status code (" $ ResponseCode $ ")";
		}
	}
	// Notify anyone waiting on this
	OnDeleteGroupComplete(GroupId, bWasSuccessful, Error);
	DeleteGroupRequests.Remove(Index, 1);
}


/**
 * Queries the backend for the Groups belonging to the supplied UserId
 * 
 * @param UniqueUserId the id of the owner of the groups to return
 */
function QueryGroups(String UniqueUserId)
{
	local String Url;
	local HttpRequestInterface Request;
	
	if (Len(UniqueUserId) > 0)
	{
		Request = CreateHttpRequest(UniqueUserId);
		if (Request != none)
		{
			// Build the REST path
			Url = BuildGroupResourcePath(UniqueUserId) $ "?owner=true";
			// Build our web request with the above URL
			Request.SetURL(Url);
			Request.SetVerb("GET");
			Request.SetProcessRequestCompleteDelegate(OnQueryGroupsRequestComplete);
			if(!Request.ProcessRequest())
			{
				`LogMcp(`Location@"Failed to process web request for URL(" $ Url $ ")");
			}
			`LogMcp("QueryGroups URL is GET " $ Url);
		}
		else
		{
			OnQueryGroupsComplete(UniqueUserId, false, "Http Request could not be created");
		}
	}
	else
	{
		OnQueryGroupsComplete(UniqueUserId, false, "UniqueUserId was not specified");
	}
}

/**
 * Called once the request/response has completed. Used to process the returned data and notify any
 * registered delegate
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
delegate OnQueryGroupsRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string Error;
	local string JsonString;
	local JsonObject ParsedJson;
	local int JsonIndex;
	local string RequesterId;
	local int GroupIndex;
	
	ResponseCode = `HTTP_STATUS_SERVER_ERROR;
	if (Response != none && Request != none)
	{
		ResponseCode = Response.GetResponseCode();
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			JsonString = Response.GetContentAsString();
			if (JsonString != "")
			{
				// Convert the JSON results into group objects
				ParsedJson = class'JsonObject'.static.DecodeJson(JsonString);
				for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
				{
					GroupIndex = ParseGroup(ParsedJson.ObjectArray[JsonIndex]);
					if (RequesterId == "" && GroupIndex != INDEX_NONE)
					{
						RequesterId = Groups[GroupIndex].OwnerId;
					}
				}
			}
			else
			{
				Error = "Query did not return any content in it's response.";
			}
		}
		else
		{
			Error = "Failed to query groups with status code (" $ ResponseCode $ ") and payload of:\n" $ JsonString;
		}
	}
	OnQueryGroupsComplete(RequesterId, bWasSuccessful, Error);
}

/**
 * Returns the set of groups that related to the specified UserId
 * 
 * @param UserId the request object that was used
 * @param GroupList the response object that was generated
 */
function GetGroupList(string UserId, out McpGroupList GroupList)
{
	local int GroupIndex;

	GroupList.RequesterId = UserId;
	for (GroupIndex = 0; GroupIndex < Groups.Length; GroupIndex++)
	{
		if (Groups[GroupIndex].OwnerId == UserId)
		{
			GroupList.Groups.AddItem(Groups[GroupIndex]);
		}
	}
}

/**
 * Queries the backend for the group which includes the members
 * 
 * @param UniqueUserId the id of the owner of the group being queried
 * @param GroupId the id of the owner of the groups to return
 */
function QueryGroupMembers(String UniqueUserId, String GroupId)
{
	local String Url;
	local HttpRequestInterface Request;
	
	// Ensure that UniqueUserId and GroupId both have values
	if (Len(UniqueUserId) > 0 && Len(GroupId) > 0)
	{
		Request = CreateHttpRequest(UniqueUserId);
		if (Request != none)
		{
			// Build the REST path and JSON payload
			Url = BuildGroupResourcePath(UniqueUserId) $ "/" $GroupId;
			// Build our web request with the above URL
			Request.SetURL(Url);
			Request.SetVerb("GET");
			Request.SetProcessRequestCompleteDelegate(OnQueryGroupMembersRequestComplete);
			// Call Web Request
			if (!Request.ProcessRequest())
			{
				`LogMcp(`Location@"Failed to process web request for URL(" $ Url $ ")");
			}
			`LogMcp("QueryGroupMembers URL is GET " $ Url);
		}
		else
		{
			OnQueryGroupMembersComplete(GroupId, false, "HttpRequest not created");
		}
	}
	else
	{
		OnQueryGroupMembersComplete(GroupId, false, "UserId and/or GroupId not specified");
	}
}

/**
 * Called once the request/response has completed. Used to process the returned data and notify any
 * registered delegate
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
delegate OnQueryGroupMembersRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local String JsonString;
	local JsonObject ParsedJson;
	local String Error;
	local int GroupIndex;
	local String GroupId;

	ResponseCode = `HTTP_STATUS_SERVER_ERROR;
	if (Response != none && Request != none)
	{
		ResponseCode = Response.GetResponseCode();
		JsonString = Response.GetContentAsString();
		// All of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode) && JsonString != "";
		if (bWasSuccessful)
		{
			// Parse the json and store in our array
			ParsedJson = class'JsonObject'.static.DecodeJson(JsonString);
			GroupIndex = ParseGroup(ParsedJson);
			GroupId = Groups[GroupIndex].GroupId;
		}
		else
		{
			Error = "Couldn't parse the JSON payload from the group GET with status code (" $ ResponseCode $ ") and payload of:\n" $ JsonString;
		}
	}
	OnQueryGroupMembersComplete(GroupId, bWasSuccessful, Error);
}

/**
 * Returns the set of Group Members that belong to the specified GroupId
 * 
 * @param GroupId the request object that was used
 * @param GroupList the response object that was generated
 */
function GetGroupMembers(String GroupId, out array<McpGroupMember> GroupMembers)
{
	local int GroupIndex;

	GroupIndex = Groups.Find('GroupId', GroupId);
	if (GroupIndex != INDEX_NONE)
	{
		GroupMembers = Groups[GroupIndex].Members;
	}
}

/**
 * Adds an Group Members to the specified Group. Sends this request to MCP to be processed
 *
 * @param UniqueUserId the user that owns the group
 * @param GroupId the group id
 * @param MemberIds list of member ids to add to the group
 * @param bRequiresAcceptance whether or not members need to accept an invitation to a group
 */
function AddGroupMembers(String UniqueUserId, String GroupId, const out array<String> MemberIds, bool bRequiresAcceptance)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;
	local int MemberIndex;
	
	// Ensure that UniqueUserId and GroupId both have values
	if (Len(UniqueUserId) > 0 && Len(GroupId) > 0)
	{
		Request = CreateHttpRequest(UniqueUserId);
		if (Request != none)
		{
			// Build the REST path and JSON payload
			Url = BuildGroupMemberResourcePath(GroupId, UniqueUserId);
			Json = "[";
			for (MemberIndex = 0; MemberIndex < MemberIds.Length; MemberIndex++)
			{
				Json $= "{ \"epicId\": \"" $ MemberIds[MemberIndex] $ "\" }";
				if (MemberIndex + 1 < MemberIds.Length)
				{
					Json $= ", ";
				}
			}
			Json $= "]";
			// Build our web request with the above URL
			Request.SetURL(URL);
			Request.SetVerb("POST");
			Request.SetContentAsString(Json);
			Request.SetProcessRequestCompleteDelegate(OnAddGroupMembersRequestComplete);
			// Store off the data for reporting later
			AddAt = GroupMemberRequests.Length;
			GroupMemberRequests.Length = AddAt + 1;
			GroupMemberRequests[AddAt].McpId = UniqueUserId;
			GroupMemberRequests[AddAt].GroupId = GroupId;
			GroupMemberRequests[AddAt].Members = MemberIds;
			GroupMemberRequests[AddAt].Request = Request;
			// Call Web Request
			if (!Request.ProcessRequest())
			{
				`LogMcp(`Location@"Failed to process web request for URL(" $ Url $ ")");
			}
			`LogMcp("AddGroupMembers URL is POST " $ Url);
		}
		else
		{
			OnAddGroupMembersComplete(GroupId, false, "HttpRequest was not created");
		}
	}
	else
	{
		OnAddGroupMembersComplete(GroupId, false, "UserId and/or GroupId not specified");
	}
}

/**
 * Called once the request/response has completed. Used to process the add mapping result and notify any
 * registered delegate
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
delegate OnAddGroupMembersRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local String GroupId;
	local McpGroupMember Member;
	local String Error;
	local int Index;
	local int GroupMemberIndex;
	local int MemberIndex;
	local int GroupIndex;

	Member.AcceptState = MGAS_Accepted;
	ResponseCode = `HTTP_STATUS_SERVER_ERROR;
	if (Response != None)
	{
		ResponseCode = Response.GetResponseCode();
	}
	// Both of these need to be true for the request to be a success
	bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
	// Find our cached data in our outstanding list
	Index = GroupMemberRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		if (bWasSuccessful)
		{
			GroupId = GroupMemberRequests[Index].GroupId;
			GroupIndex = Groups.Find('GroupId', GroupId);
			if (GroupIndex != INDEX_NONE)
			{
				// Add all of the members to our local cache
				for (MemberIndex = 0; MemberIndex < GroupMemberRequests[Index].Members.Length; MemberIndex++)
				{
					Member.MemberId = GroupMemberRequests[Index].Members[MemberIndex];
					GroupMemberIndex = Groups[GroupIndex].Members.Find('MemberId', Member.MemberId);
					if (GroupMemberIndex == INDEX_NONE)
					{
						Groups[GroupIndex].Members.AddItem(Member);
					}
				}
			}
		}
		else
		{
			Error = "Failed to add group memebers to group (" $ GroupId $ ") with status code (" $ ResponseCode $ ")";
		}
		GroupMemberRequests.Remove(Index, 1);
	}

	OnAddGroupMembersComplete(GroupId, bWasSuccessful, Error);
}

/**
 * Remove Group Members from the specified Group. Sends this request to MCP to be processed
 *
 * @param UniqueUserId the user that owns the group
 * @param GroupId the group id
 * @param MemberIds list of member ids to add to the group
 */
function RemoveGroupMembers(String UniqueUserId, String GroupId, const out array<String> MemberIds)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;
	local int MemberIndex;
	
	// Ensure that UniqueUserId and GroupId both have values
	if (Len(UniqueUserId) > 0 && Len(GroupId) > 0)
	{
		Request = CreateHttpRequest(UniqueUserId);
		if (Request != none)
		{
			// Build the REST path and JSON payload
			Url = BuildGroupMemberResourcePath(GroupId, UniqueUserId);
			Json = "[";
			for (MemberIndex = 0; MemberIndex < MemberIds.Length; MemberIndex++)
			{
				Json $= "{ \"epicId\": \"" $ MemberIds[MemberIndex] $ "\" }";
				if (MemberIndex + 1 < MemberIds.Length)
				{
					Json $= ", ";
				}
			}
			Json $= "]";
			// Build our web request with the above URL
			Request.SetURL(URL);
			Request.SetVerb("DELETE");
			Request.SetContentAsString(Json);
			Request.SetProcessRequestCompleteDelegate(OnRemoveGroupMembersRequestComplete);
			// Store off the data for reporting later
			AddAt = GroupMemberRequests.Length;
			GroupMemberRequests.Length = AddAt + 1;
			GroupMemberRequests[AddAt].McpId = UniqueUserId;
			GroupMemberRequests[AddAt].GroupId = GroupId;
			GroupMemberRequests[AddAt].Members = MemberIds;
			GroupMemberRequests[AddAt].Request = Request;
			// Call Web Request
			if (!Request.ProcessRequest())
			{
				`LogMcp(`Location@"Failed to process web request for URL(" $ Url $ ")");
			}
			`LogMcp("RemoveGroupMembers URL is DELETE " $ Url);
		}
		else
		{
			OnRemoveGroupMembersComplete(GroupId, false, "Http request was not created");
		}
	}
	else
	{
		OnRemoveGroupMembersComplete(GroupId, false, "UniqueUserId and/or GroupId was not specified");
	}
}

/**
 * Called once the request/response has completed. Used to process the add mapping result and notify any
 * registered delegate
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnRemoveGroupMembersRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local String GroupId;
	local String Error;
	local String MemberId;
	local int Index;
	local int MemberIndex;
	local int GroupIndex;
	local int GroupMemberIndex;

	ResponseCode = `HTTP_STATUS_SERVER_ERROR;
	if (Response != None)
	{
		ResponseCode = Response.GetResponseCode();
	}
	// Both of these need to be true for the request to be a success
	bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
	// Find our cached data in our outstanding list
	Index = GroupMemberRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		if (bWasSuccessful)
		{
			GroupId = GroupMemberRequests[Index].GroupId;
			GroupIndex = Groups.Find('GroupId', GroupId);
			if (GroupIndex != INDEX_NONE)
			{
				// Remove all of the members from our local cache
				for (MemberIndex = 0; MemberIndex < GroupMemberRequests[Index].Members.Length; MemberIndex++)
				{
					MemberId = GroupMemberRequests[Index].Members[MemberIndex];
					GroupMemberIndex = Groups[GroupIndex].Members.Find('MemberId', MemberId);
					if (GroupMemberIndex != INDEX_NONE)
					{
						Groups[GroupIndex].Members.Remove(GroupMemberIndex, 1);
					}
				}
			}
		}
		else
		{
			Error = "Failed to remove group memebers from group (" $ GroupId $ ") with status code (" $ ResponseCode $ ")";
		}
		GroupMemberRequests.Remove(Index, 1);
	}

	OnRemoveGroupMembersComplete(GroupId, bWasSuccessful, Error);
}

/**
 * Deletes all Groups that belong to UniqueUserId
 * 
 * @param UniqueUserId UserId of the owner of the Group
 */
function DeleteAllGroups(String UniqueUserId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	
	// Ensure that UniqueUserId and GroupName both have values
	if (Len(UniqueUserId) > 0)
	{
		Request = CreateHttpRequest(UniqueUserId);
		if (Request != none)
		{
			// Build the REST path
			Url = BuildGroupResourcePath(UniqueUserId);
			// Build our web request with the above URL
			Request.SetURL(URL);
			Request.SetVerb("DELETE");
			Request.SetProcessRequestCompleteDelegate(OnDeleteGroupRequestComplete);
			// Store off the data for reporting later
			AddAt = DeleteAllRequests.Length;
			DeleteAllRequests.Length = AddAt + 1;
			DeleteAllRequests[AddAt].McpId = UniqueUserId;
			DeleteAllRequests[AddAt].Request = Request;
			// Call Web Request
			if (!Request.ProcessRequest())
			{
				`LogMcp(`Location@"Failed to process web request for URL(" $ Url $ ")");
			}
			`LogMcp("DeleteAllGroups URL is DELETE " $ Url);
		}
		else
		{
			OnDeleteAllGroupsComplete(UniqueUserId, false, "HttpRequest was not be created");
		}
	}
	else
	{
		OnDeleteAllGroupsComplete(UniqueUserId, false, "UserId wasn't specified");
	}
}

/**
 * Called once the results come back from the server to indicate success/failure of the operation
 *
 * @param bWasSuccessful whether the operation succeeded or not
 * @param Error string information about the error (if an error)
 */
function OnDeleteAllGroupsRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local String McpId;
	local String Error;
	local int ResponseCode;
	local int GroupIndex;

	if (Response != None)
	{
		ResponseCode = Response.GetResponseCode();
	}

	// Both of these need to be true for the request to be a success
	bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);

	Index = DeleteAllRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		if (bWasSuccessful)
		{
			McpId = DeleteAllRequests[Index].McpId;
			// Remove the groups for this user
			for (GroupIndex = 0; GroupIndex < Groups.Length; GroupIndex++)
			{
				if (Groups[GroupIndex].OwnerId == McpId)
				{
					Groups.Remove(GroupIndex, 1);
					GroupIndex--;
				}
			}
		}
		else
		{
			Error = "Failed to delete all groups for user (" $ McpId $ ") with status code (" $ ResponseCode $ ")";
		}
		DeleteAllRequests.Remove(Index, 1);
	}

	OnDeleteAllGroupsComplete(McpId, bWasSuccessful, Error);
}

/**
 * Not supported
 */
function AcceptGroupInvite(String UniqueUserId, String GroupId, bool bShouldAccept)
{
	OnAcceptGroupInviteComplete(GroupId, false, "Not supported");
}
