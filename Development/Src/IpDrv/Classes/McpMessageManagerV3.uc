/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Concrete implementation for the new UnrealMCP3 services
 */
class McpMessageManagerV3 extends McpMessageBase
	config(Engine);

`include(Engine\Classes\HttpStatusCodes.uci)

/**
 * Operates on the following resource paths
 *
 * /api/messaging/{epicId}/outbox
 * /api/messaging/{epicId}/inbox
 * /api/messaging/{epicId}/inbox/{messageId}/header
 * /api/messaging/{epicId}/inbox/{messageId}
 *
 * Stored in the vars below
 */
var config String OutboxPath;
var config String InboxPath;
var config String HeaderPath;
var config String MessagePath;
 
/** Holds the context for the create */
struct UserBasedRequest
{
	var HttpRequestInterface Request;
	var String McpId;
};

/** Holds the context for the delete */
struct MessageBasedRequest
{
	var HttpRequestInterface Request;
	var String MessageId;
};

/** The set of requests that are pending */
var array<UserBasedRequest> UserBasedRequests;
var array<MessageBasedRequest> MessageBasedRequests;

/** Holds the contents for given messages */
var array<McpMessageContents> Contents;

/**
  * Creates the URL and sends the request to create a Message.
  *
  * @param ToUniqueUserIds the ids of users to send a message to
  * @param FromUniqueUserId of the user who sent the message
  * @param FromFriendlyName The friendly name of the user sending the data
  * @param MessageType The application specific message type
  * @param PushMessage to be sent to user via push notifications
  * @param ValidUntil The date until this message is no longer valid (should be deleted)
  * @param Body payload of the message
  */
function CreateMessage(const out array<String> ToUniqueUserIds, String FromUniqueUserId, String FromFriendlyName, String MessageType, String PushMessage, String ValidUntil, const out array<byte> Body)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String Json;
	local int ToIndex;
	local String BodyString;

	Request = CreateHttpRequest(FromUniqueUserId);
	if (Request != none)
	{
		Url = GetBaseURL() $ Repl(OutboxPath, "{epicId}", FromUniqueUserId);

		Json = "{ \"type\": \"" $ MessageType $ "\"," $
			" \"validUntil\": \"" $ ValidUntil $ "\"," $
			" \"fromName\": \"" $ FromFriendlyName $ "\"," $
			" \"pushMessage\": \"" $ PushMessage $ "\"," $
			" \"toEpicIds\": [ ";
		for (ToIndex = 0; ToIndex < ToUniqueUserIds.Length; ToIndex++)
		{
			Json $= "\"" $ ToUniqueUserIds[ToIndex] $ "\"";
			// Only add the string if this isn't the last item
			if (ToIndex + 1 < ToUniqueUserIds.Length)
			{
				Json $= ",";
			}
		}
		BodyString = class'Base64'.static.Encode(Body);
		Json $= " ], \"body\": \"" $ BodyString $ "\" }";
		`LogMcp("URL is " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnCreateMessageRequestComplete);
		// Store off the data for reporting later
		AddAt = UserBasedRequests.Length;
		UserBasedRequests.Length = AddAt + 1;
		UserBasedRequests[AddAt].Request = Request;
		UserBasedRequests[AddAt].McpId = FromUniqueUserId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start CreateMessage web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnCreateMessageRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;

	Index = UserBasedRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (!bWasSuccessful)
		{
			ErrorString = "Failed call or invalid response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnCreateMessageComplete(UserBasedRequests[Index].McpId, bWasSuccessful, ErrorString);
		UserBasedRequests.Remove(Index,1);
	}
}

/**
 * Deletes a Message by MessageId
 * 
 * @param McpId the person issuing the delete
 * @param MessageId Id of the group
 */
function DeleteMessage(String McpId, String MessageId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String ResourcePath;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		ResourcePath = Repl(MessagePath, "{epicId}", McpId);
		ResourcePath = Repl(ResourcePath, "{messageId}", MessageId);
		Url = GetBaseURL() $ ResourcePath;
		`LogMcp("URL is " $ Url);

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("DELETE");
		Request.SetProcessRequestCompleteDelegate(OnDeleteMessageRequestComplete);
		
		// Store off the data for reporting later
		AddAt = MessageBasedRequests.Length;
		MessageBasedRequests.Length = AddAt + 1;
		MessageBasedRequests[AddAt].Request = Request;
		MessageBasedRequests[AddAt].MessageId = MessageId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start DeleteMessage web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnDeleteMessageRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;

	Index = MessageBasedRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (!bWasSuccessful)
		{
			ErrorString = "Failed call or invalid response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnCreateMessageComplete(MessageBasedRequests[Index].MessageId, bWasSuccessful, ErrorString);
		MessageBasedRequests.Remove(Index,1);
	}
}

/**
 * Queries the backend for the Messages belonging to the supplied McpId
 * 
 * @param McpId the id of the user to get the messages for
 */
function QueryMessages(String McpId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = GetBaseURL() $ Repl(InboxPath, "{epicId}", McpId);
		`LogMcp("URL is " $ Url);

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnQueryMessagesRequestComplete);
		
		// Store off the data for reporting later
		AddAt = UserBasedRequests.Length;
		UserBasedRequests.Length = AddAt + 1;
		UserBasedRequests[AddAt].Request = Request;
		UserBasedRequests[AddAt].McpId = McpId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start QueryMessages web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Parses a message from the specified JsonObject
 *
 * @param ParsedJson the json node to parse
 *
 * @return the index of the user's message list entry
 */
protected function int ParseMessage(JsonObject ParsedJson)
{
	local int UserIndex;
	local int MessageIndex;
	local string MessageId;
	local String McpId;

	// Example JSON:
	//{
	//	"messageId":"1234",
	//	"messageType":"gift",
	//	"toEpicId":"someId",
	//	"fromEpicId":"anotherId",
	//	"fromName":"Test User",
	//	"timestamp":"2020-07-31",
	//}
	// If it doesn't have this field, this is bogus JSON
	if (ParsedJson.HasKey("messageId") && ParsedJson.HasKey("toEpicId"))
	{
		McpId = ParsedJson.GetStringValue("toEpicId");
		// See if we already have a user
		UserIndex = MessageLists.Find('ToUniqueUserId', McpId);
		if (UserIndex == INDEX_NONE)
		{
			// Not stored yet, so add one
			UserIndex = MessageLists.Length;
			MessageLists.Length = UserIndex + 1;
			MessageLists[UserIndex].ToUniqueUserId = McpId;
		}
		MessageId = ParsedJson.GetStringValue("messageId");
		MessageIndex = MessageLists[UserIndex].Messages.Find('MessageId', MessageId);
		if (MessageIndex == INDEX_NONE)
		{
			MessageIndex = MessageLists[UserIndex].Messages.Length;
			MessageLists[UserIndex].Messages.Length = MessageIndex + 1;
			MessageLists[UserIndex].Messages[MessageIndex].ToUniqueUserId = McpId;
			MessageLists[UserIndex].Messages[MessageIndex].MessageId = MessageId;
		}
		MessageLists[UserIndex].Messages[MessageIndex].FromUniqueUserId = ParsedJson.GetStringValue("fromEpicId");
		MessageLists[UserIndex].Messages[MessageIndex].FromFriendlyName = ParsedJson.GetStringValue("fromName");
		MessageLists[UserIndex].Messages[MessageIndex].ValidUntil = ParsedJson.GetStringValue("timestamp");
		MessageLists[UserIndex].Messages[MessageIndex].MessageType = ParsedJson.GetStringValue("messageType");
	}
	else
	{
		UserIndex = INDEX_NONE;
	}
	// Tell the caller which record was updated
	return UserIndex;
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnQueryMessagesRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local JsonObject ParsedJson, JsonElement;
	local int JsonIndex;
	local int ListIndex;

	Index = UserBasedRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
			// Parse each message, adding them if needed
			for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length && bWasSuccessful; JsonIndex++)
			{
				JsonElement = ParsedJson.ObjectArray[JsonIndex];
				ListIndex = ParseMessage(JsonElement);
				if (ListIndex == INDEX_NONE)
				{
					bWasSuccessful = false;
					ErrorString = "Failed to parse JSON for QueryMessages with payload:\n" $ ResponseString;
				}
			}
		}
		else
		{
			ErrorString = "Failed call or invalid response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnQueryMessagesComplete(UserBasedRequests[Index].McpId, bWasSuccessful, ErrorString);
		UserBasedRequests.Remove(Index,1);
	}
}

/**
 * Returns the set of messages that sent to the specified McpId
 * 
 * @param McpId the user the messages were sent to
 * @param MessageList collection of messages
 */
function GetMessageList(string McpId, out McpMessageList MessageList)
{
	local int UserIndex;

	UserIndex = MessageLists.Find('ToUniqueUserId', McpId);
	if (UserIndex != INDEX_NONE)
	{
		MessageList = MessageLists[UserIndex];
	}
}

/**
 * Queries the back-end for the Messages Contents belonging to the specified group
 * 
 * @param McpId the person issuing the contents query
 * @param MessageId the id of the owner of the groups to return
 */
function QueryMessageContents(String McpId, String MessageId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String ResourcePath;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		ResourcePath = Repl(MessagePath, "{epicId}", McpId);
		ResourcePath = Repl(ResourcePath, "{messageId}", MessageId);
		Url = GetBaseURL() $ ResourcePath;
		`LogMcp("URL is " $ Url);

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnQueryMessageContentsRequestComplete);
		
		// Store off the data for reporting later
		AddAt = MessageBasedRequests.Length;
		MessageBasedRequests.Length = AddAt + 1;
		MessageBasedRequests[AddAt].Request = Request;
		MessageBasedRequests[AddAt].MessageId = MessageId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start QueryMessageContents web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnQueryMessageContentsRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local JsonObject ParsedJson;
	local int ContentsIndex;
	local String MessageId;
	local array<byte> TempContents;
	local String BodyString;

	Index = MessageBasedRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
			if (ParsedJson.HasKey("MessageId"))
			{
				MessageId = ParsedJson.GetStringValue("MessageId");
				ContentsIndex = Contents.Find('MessageId', MessageId);
				if (ContentsIndex == INDEX_NONE)
				{
					ContentsIndex = Contents.Length;
					Contents.Length = ContentsIndex + 1;
					Contents[ContentsIndex].MessageId = MessageId;
				}
				BodyString = ParsedJson.GetStringValue("body");
				class'Base64'.static.Decode(BodyString, TempContents);
				Contents[ContentsIndex].MessageContents = TempContents;
			}
			else
			{
				bWasSuccessful = false;
				ErrorString = "Failed to parse JSON for QueryMessageContents with payload:\n" $ ResponseString;
			}
		}
		else
		{
			ErrorString = "Failed call or invalid response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnQueryMessageContentsComplete(MessageBasedRequests[Index].MessageId, bWasSuccessful, ErrorString);
		MessageBasedRequests.Remove(Index,1);
	}
}

/**
 * Returns a copy of the Message Contents that belong to the specified MessageId
 * 
 * @param MessageId the message to get the contents for
 * @param MessageContents the out array to copy them into
 */
function bool GetMessageContents(String MessageId, out array<byte> MessageContents)
{
	local int MessageIndex;

	MessageIndex = Contents.Find('MessageId', MessageId);
	if (MessageIndex != INDEX_NONE)
	{
		MessageContents = Contents[MessageIndex].MessageContents;
	}
	return MessageIndex != INDEX_NONE;
}
