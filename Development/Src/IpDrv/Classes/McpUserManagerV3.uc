/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Concrete implementation for the new UnrealMCP3 services
 */
class McpUserManagerV3 extends McpUserManagerBase;

/**
 * Holds the set of user statuses that were downloaded
 */
var array<McpUserStatus> UserStatuses;

/** The URL to use when making user registration requests to generate an id */
var config String AccountUrl;

/** The URL to use when making user authentication requests */
var config String AuthUrl;

/** The URL to use when making querying for users */
var config String QueryUrl;

/** Holds the state information for an outstanding user request */
struct UserRequest
{
	/** The MCP id that was returned by the backend */
	var string McpId;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

/** The set of add mapping requests that are pending */
var array<HttpRequestInterface> RegisterUserRequests;

/** The set of query requests that are pending */
var array<HttpRequestInterface> QueryUsersRequests;

/** The set of delete requests that are pending */
var array<UserRequest> DeleteUserRequests;

/** The set of delete requests that are pending */
var array<HttpRequestInterface> AuthUserRequests;

/**
 * Creates a new user mapped to the UDID that is specified
 */
function RegisterUserGenerated()
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest();
	if (Request != none)
	{
		Url = GetBaseURL() $ AccountUrl;

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetProcessRequestCompleteDelegate(OnRegisterUserRequestComplete);
		// Store off the data for reporting later
		AddAt = RegisterUserRequests.Length;
		RegisterUserRequests.Length = AddAt + 1;
		RegisterUserRequests[AddAt] = Request;
		`LogMcp("RegisterUserGenerated URL is POST " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start RegisterUserGenerated web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * @return a JSON payload for an external account given the parameters
 */
function string BuildExternalOnlineAccountJSON(string Id, string Type, String Token)
{
	return "{ \"externalId\":\"" $ Id $ "\", \"type\":\"" $ Type $ "\", \"externalToken\":\"" $ Token $ "\" }";
}

/** Common routine for creating via an external account */
private function RegisterExternalUserAccount(String ExternalId, String Token, String Type)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest();
	if (Request != none)
	{
		Url = GetBaseURL() $ AccountUrl;

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetProcessRequestCompleteDelegate(OnRegisterUserRequestComplete);
		// Build the JSON payload for the external auth request
		Json = BuildExternalOnlineAccountJSON(ExternalId, Type, Token);
		`Log("JSON for external account is: " $ Json);
		Request.SetContentAsString(Json);
		// Store off the data for reporting later
		AddAt = RegisterUserRequests.Length;
		RegisterUserRequests.Length = AddAt + 1;
		RegisterUserRequests[AddAt] = Request;
		`LogMcp("RegisterExternalUser" $ Type $ " URL is POST " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start RegisterExternalUserAccount web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Maps a newly generated or existing Mcp id to the Facebook id/token requested.
 * Note: Facebook id authenticity is verified via the token
 * 
 * @param FacebookId user's FB id to generate Mcp id for
 * @param FacebookAuthToken FB auth token obtained by signing in to FB
 */
function RegisterUserFacebook(string FacebookId, string FacebookAuthToken)
{
	RegisterExternalUserAccount(FacebookId, FacebookAuthToken, "facebook");
}

/**
 * Maps a newly generated or existing Mcp id to the Game Center id
 * 
 * @param GameCenterId user's Game Center id to generate Mcp id for
 */
function RegisterUserGameCenter(string GameCenterId)
{
	RegisterExternalUserAccount(GameCenterId, "gamecenter", "gamecenter");
}

/**
 * Maps a newly generated or existing Mcp id to the Google+ id/token requested.
 * Note: Google+ id authenticity is verified via the token
 * 
 * @param GoogleId user's Google+ id to generate Mcp id for
 * @param GoogleAuthToken Google+ auth token obtained by signing in to Google+
 */
function RegisterUserGoogle(string GoogleId, string GoogleAuthToken)
{
	RegisterExternalUserAccount(GoogleId, GoogleAuthToken, "google");
}

/**
 * Parses the user json
 * 
 * @param JsonPayload the json data to parse
 * 
 * @return the index of the user that was parsed
 */
protected function int ParseUser(JsonObject ParsedJson)
{
	local int UserIndex;
	local string McpId;
	local JsonObject ExternalAccounts;
	local JsonObject ExternalAccount;
	local int JsonIndex;
	local int AccountIndex;

	// Example JSON:
	//{
	//	"gameAccountId":"21db2cd3581d4dbaad99313ccc48eb04",
	//	"internalToken":"VMOtWYLgRO8Dosl2bs48OYooEmwIzkpC",
	//	"authTicket":"WhQQ5NoV2LGha00A/y2D95vZtBcCZrsHwOFBtZFoxlmeNEPiFDYqG1L50t8E4Jt0pus/EJSNDDGtYN9/JitlZw==",
	//	"additionalAuthData":{}
	//}
	// If it doesn't have this field, this is bogus JSON
	if (ParsedJson.HasKey("gameAccountId") || ParsedJson.HasKey("epicId"))
	{
		// Grab the McpId first, since that is our key
		McpId = ParsedJson.GetStringValue("gameAccountId");
		if (McpId == "")
		{
			McpId = ParsedJson.GetStringValue("epicId");
		}
		// See if we already have a user
		UserIndex = UserStatuses.Find('McpId', McpId);
		if (UserIndex == INDEX_NONE)
		{
			// Not stored yet, so add one
			UserIndex = UserStatuses.Length;
			UserStatuses.Length = UserIndex + 1;
			UserStatuses[UserIndex].McpId = McpId;
		}
		// These values are only there for the owner and not friends
		if (ParsedJson.HasKey("internalToken"))
		{
			UserStatuses[UserIndex].SecretKey = ParsedJson.GetStringValue("internalToken");
		}
		if (ParsedJson.HasKey("authTicket"))
		{
			UserStatuses[UserIndex].Ticket = ParsedJson.GetStringValue("authTicket");
		}
		if (ParsedJson.HasKey("registeredDate"))
		{
			UserStatuses[UserIndex].RegisteredDate = ParsedJson.GetStringValue("registeredDate");
		}
		if (ParsedJson.HasKey("registered"))
		{
			UserStatuses[UserIndex].RegisteredDate = ParsedJson.GetStringValue("registered");
		}
		if (ParsedJson.HasKey("lastActiveDate"))
		{
			UserStatuses[UserIndex].LastActiveDate = ParsedJson.GetStringValue("lastActiveDate");
		}
		if (ParsedJson.HasKey("lastActive"))
		{
			UserStatuses[UserIndex].LastActiveDate = ParsedJson.GetStringValue("lastActive");
		}
		if (ParsedJson.HasKey("daysInactive"))
		{
			UserStatuses[UserIndex].DaysInactive = ParsedJson.GetIntValue("daysInactive");
		}
		if (ParsedJson.HasKey("isBanned"))
		{
			UserStatuses[UserIndex].bIsBanned = ParsedJson.GetBoolValue("isBanned");
		}
		if (ParsedJson.HasKey("banned"))
		{
			UserStatuses[UserIndex].bIsBanned = ParsedJson.GetBoolValue("banned");
		}
		ExternalAccounts = ParsedJson.GetObject("externalAccounts");
		if (ExternalAccounts != None)
		{
			UserStatuses[UserIndex].ExternalAccounts.Length = 0;
			// Add each external account for the user
			for (JsonIndex = 0; JsonIndex < ExternalAccounts.ObjectArray.Length; JsonIndex++)
			{
				ExternalAccount = ExternalAccounts.ObjectArray[JsonIndex];
				AccountIndex = UserStatuses[UserIndex].ExternalAccounts.Length;
				UserStatuses[UserIndex].ExternalAccounts.Length = AccountIndex + 1;
				UserStatuses[UserIndex].ExternalAccounts[AccountIndex].ExternalType = ExternalAccount.GetStringValue("type");
				UserStatuses[UserIndex].ExternalAccounts[AccountIndex].ExternalId = ExternalAccount.GetStringValue("externalId");
			}
		}
	}
	else
	{
		UserIndex = INDEX_NONE;
	}
	// Tell the caller which record was updated
	return UserIndex;
}

/**
 * Called once the request/response has completed. Used to process the register user result and notify any
 * registered delegate
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnRegisterUserRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local int UserIndex;
	local string ResponseString;
	local string ErrorString;
	local string McpId;
	local JsonObject ParsedJson;

	// Search for the corresponding entry in the array
	Index = RegisterUserRequests.Find(Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// The response string is the JSON payload for the user
		ResponseString = Response.GetContentAsString();
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && ResponseCode == 200;
		if (bWasSuccessful)
		{
			ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
			// Parse the JSON payload into a user
			UserIndex = ParseUser(ParsedJson);
			if (UserIndex == INDEX_NONE)
			{
				bWasSuccessful = false;
				ErrorString = "RegisterUser failed to parse user from JSON:\n" $ ResponseString;
				`LogMcp(ErrorString);
			}
			else
			{
				`LogMcp("RegisterUser was successful for user (" $ UserStatuses[UserIndex].McpId $ ") with ticket (" $ UserStatuses[UserIndex].Ticket $ ")");
			}
		}
		else
		{
			ErrorString = "RegisterUser failed call or invalid response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
			`LogMcp(ErrorString);
		}
		McpId = bWasSuccessful ? UserStatuses[UserIndex].McpId : "";
		// Notify anyone waiting on this
		OnRegisterUserComplete(McpId,
			bWasSuccessful,
			ErrorString);
		RegisterUserRequests.Remove(Index,1);
	}
}

/**
 * Authenticates a user is who they claim themselves to be using Facebook as the authority
 * 
 * @param FacebookId the Facebook user that is being authenticated
 * @param FacebookToken the secret that authenticates the user
 * @param UDID the device id the user is logging in from
 */
function AuthenticateUserFacebook(string FacebookId, string FacebookToken, string UDID)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest();
	if (Request != none)
	{
		Url = GetBaseURL() $ AccountUrl;
		Json = BuildExternalOnlineAccountJSON(FacebookId, "facebook", FacebookToken);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("PUT");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnAuthenticateUserRequestComplete);
		// Store off the data for reporting later
		AddAt = AuthUserRequests.Length;
		AuthUserRequests.Length = AddAt + 1;
		AuthUserRequests[AddAt] = Request;
		`LogMcp("AuthenticateUserFacebook URL is PUT " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start AuthenticateUserFacebook web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Authenticates a user is who they claim themselves to be using Google+ as the authority
 * 
 * @param GoogleId user's Google+ id to validate
 * @param GoogleAuthToken Google+ auth token obtained by signing in to Google+
 */
function AuthenticateUserGoogle(string GoogleId, string GoogleAuthToken)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest();
	if (Request != none)
	{
		Url = GetBaseURL() $ AccountUrl;
		Json = BuildExternalOnlineAccountJSON(GoogleId, "google", GoogleAuthToken);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("PUT");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnAuthenticateUserRequestComplete);
		// Store off the data for reporting later
		AddAt = AuthUserRequests.Length;
		AuthUserRequests.Length = AddAt + 1;
		AuthUserRequests[AddAt] = Request;
		`LogMcp("AuthenticateUserGoogle URL is PUT " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start AuthenticateUserGoogle web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Authenticates a user is who they claim themselves to be using GameCenter as the authority
 * 
 * @param GameCenterId the GameCenter user that is being authenticated
 */
function AuthenticateUserGameCenter(string GameCenterId)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest();
	if (Request != none)
	{
		Url = GetBaseURL() $ AccountUrl;
		Json = BuildExternalOnlineAccountJSON(GameCenterId, "gamecenter", "gamecenter");
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("PUT");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnAuthenticateUserRequestComplete);
		// Store off the data for reporting later
		AddAt = AuthUserRequests.Length;
		AuthUserRequests.Length = AddAt + 1;
		AuthUserRequests[AddAt] = Request;
		`LogMcp("AuthenticateUserGameCenter URL is PUT " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start AuthenticateUserGameCenter web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Authenticates a user is the same as the one that was registered
 * 
 * @param McpId the user that is being authenticated
 * @param ClientSecret the secret that authenticates the user
 * @param UDID the device id the user is logging in from
 */
function AuthenticateUserMCP(string McpId, string ClientSecret, string UDID)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest();
	if (Request != none)
	{
		Url = GetBaseURL() $ Repl(AuthUrl, "{epicId}", McpId);
		Json = BuildExternalOnlineAccountJSON(McpId, "internal", ClientSecret);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("PUT");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnAuthenticateUserRequestComplete);
		// Store off the data for reporting later
		AddAt = AuthUserRequests.Length;
		AuthUserRequests.Length = AddAt + 1;
		AuthUserRequests[AddAt] = Request;
		`LogMcp("AuthenticateUserMCP URL is PUT " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start AuthenticateUserMCP web request for URL(" $ Url $ ")");
		}
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
function OnAuthenticateUserRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local int UserIndex;
	local string ResponseString;
	local string McpId;
	local string Ticket;
	local JsonObject ParsedJson;
	local String Error;

	// Search for the corresponding entry in the array
	Index = AuthUserRequests.Find(Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// The response string is the JSON payload for the user
		ResponseString = Response.GetContentAsString();
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && ResponseCode == 200;
		if (bWasSuccessful)
		{
			ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
			// Parse the JSON payload into a user
			UserIndex = ParseUser(ParsedJson);
			if (UserIndex == INDEX_NONE)
			{
				bWasSuccessful = false;
				Error = "User data failed to be parsed with ResponseCode (" $ ResponseCode $ ") and response of:\n" $ ResponseString;
				`LogMcp(Error);
			}
		}
		else
		{
			Error = "AuthenticateUser failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
			`LogMcp(Error);
		}
		// If it was successful, grab the id and ticket for notifying the caller
		if (bWasSuccessful)
		{
			McpId = UserStatuses[UserIndex].McpId;
			Ticket = UserStatuses[UserIndex].Ticket;
			`LogMcp("AuthenticateUser was successful for user (" $ McpId $ ") with ticket (" $ Ticket $ ")");
		}
		// Notify anyone waiting on this
		OnAuthenticateUserComplete(McpId, Ticket, bWasSuccessful, Error);
		AuthUserRequests.Remove(Index,1);
	}
}

/**
 * @return a JSON array payload for the ids
 */
protected function String BuildJsonForIds(const out array<string> McpIds)
{
	local String JsonPayload;
	local int Index;

	JsonPayload = "[ ";
	for (Index = 0; Index < McpIds.Length; Index++)
	{
		JsonPayload $= "\"" $ McpIds[Index] $ "\"";
		// Only add the string if this isn't the last item
		if (Index + 1 < McpIds.Length)
		{
			JsonPayload $= ",";
		}
	}
	JsonPayload $= " ]";
	return JsonPayload;
}

/**
 * Queries the backend for the status of a users
 * 
 * @param McpId the id of the user to get the status for
 * @param bShouldUpdateLastActive if true, the act of getting the status updates the active time stamp
 */
function QueryUser(string McpId, optional bool bShouldUpdateLastActive)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;
	local array<String> Ids;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = GetBaseURL() $ QueryUrl;
		Ids.AddItem(McpId);
		Json = BuildJsonForIds(Ids);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnQueryUserRequestComplete);
		// Store off the data for reporting later
		AddAt = QueryUsersRequests.Length;
		QueryUsersRequests.Length = AddAt + 1;
		QueryUsersRequests[AddAt] = Request;
		`LogMcp("QueryUser URL is POST " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start QueryUser web request for URL(" $ Url $ ")");
		}
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
function OnQueryUserRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ResponseString;

	// Search for the corresponding entry in the array
	Index = QueryUsersRequests.Find(Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// The response string is the JSON payload for the user
		ResponseString = Response.GetContentAsString();
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && ResponseCode == 200;
		if (bWasSuccessful)
		{
`LogMcp("QueryUser - " $ ResponseString);
			// Parse the JSON payload into a user
			ParseUsers(ResponseString);
		}
		else
		{
			ResponseString = "QueryUser failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
			`LogMcp(ResponseString);
		}
		// Notify anyone waiting on this
		OnQueryUsersComplete(bWasSuccessful, ResponseString);
		QueryUsersRequests.Remove(Index,1);
	}
}

/**
 * Queries the backend for the status of a list of users
 * 
 * @param McpId the id of the user issuing the request
 * @param McpIds the set of ids to get read the status of
 */
function QueryUsers(String McpId, const out array<String> McpIds)
{
	local String Url;
	local String Json;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = GetBaseURL() $ QueryUrl;
		Json = BuildJsonForIds(McpIds);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnQueryUsersRequestComplete);
		// Store off the data for reporting later
		AddAt = QueryUsersRequests.Length;
		QueryUsersRequests.Length = AddAt + 1;
		QueryUsersRequests[AddAt] = Request;
		`LogMcp("QueryUsers URL is POST " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start QueryUser web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Parses the json which contains an array of user data
 * 
 * @param JsonPayload the json data to parse
 * 
 * @return the index of the user that was parsed
 */
protected function ParseUsers(String JsonPayload)
{
	local JsonObject ParsedJson, JsonElement;
	local int JsonIndex;

	ParsedJson = class'JsonObject'.static.DecodeJson(JsonPayload);
	// Parse each user, adding them if needed
	for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
	{
		JsonElement = ParsedJson.ObjectArray[JsonIndex];
		ParseUser(JsonElement);
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
function OnQueryUsersRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ResponseString;

	// Search for the corresponding entry in the array
	Index = QueryUsersRequests.Find(Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// The response string is the JSON payload for the user
		ResponseString = Response.GetContentAsString();
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
`LogMcp("QueryUsers - " $ ResponseString);
			// Parse the JSON payload into a user
			ParseUsers(ResponseString);
		}
		// Notify anyone waiting on this
		OnQueryUsersComplete(bWasSuccessful, ResponseString);
		QueryUsersRequests.Remove(Index,1);
	}
}

/**
 * Returns the set of user statuses queried so far
 * 
 * @param Users the out array that gets the copied data
 */
function GetUsers(out array<McpUserStatus> Users)
{
	Users = UserStatuses;
}

/**
 * Gets the user status entry for a single user
 *
 * @param McpId the id of the user that we want to find
 * @param User the out result to copy user data
 *
 * @return true if user was found
 */
function bool GetUser(string McpId, out McpUserStatus User)
{
	local int UserIndex;

	UserIndex = UserStatuses.Find('McpId', McpId);
	if (UserIndex != INDEX_NONE)
	{
		User = UserStatuses[UserIndex];
		return true;
	}
	return false;
}

/**
 * Determines if the user has a given external account type
 *
 * @param McpId the id of the user that we want to find
 * @param ExternalAccountType the account type we are checking
 *
 * @return true if the user has the indicated account type
 */
function bool UserHasExternalAccount(string McpId, String ExternalAccountType)
{
	local int UserIndex;

	UserIndex = UserStatuses.Find('McpId', McpId);
	if (UserIndex != INDEX_NONE)
	{
		return UserStatuses[UserIndex].ExternalAccounts.Find('ExternalType', ExternalAccountType) != INDEX_NONE;
	}
	return false;
}

/**
 * Gets the requested external account id for a single user
 *
 * @param McpId the id of the user that we want to find
 * @param ExternalAccountType the account type we are checking
 * @param ExternalAccountId the out result
 *
 * @return true if user account type was found
 */
function bool GetUserExternalAccountId(string McpId, String ExternalAccountType, out String ExternalAccountId)
{
	local int AccountIndex;
	local int UserIndex;

	UserIndex = UserStatuses.Find('McpId', McpId);
	if (UserIndex != INDEX_NONE)
	{
		AccountIndex = UserStatuses[UserIndex].ExternalAccounts.Find('ExternalType', ExternalAccountType);
		if (AccountIndex != INDEX_NONE)
		{
			ExternalAccountId = UserStatuses[UserIndex].ExternalAccounts[AccountIndex].ExternalId;
			return true;
		}
	}
	return false;
}

/**
 * Deletes all data for a user
 * 
 * @param McpId the user that is being expunged from the system
 */
function DeleteUser(string McpId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = GetBaseURL() $ AccountUrl $ "/" $ McpId;

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("DELETE");
		Request.SetProcessRequestCompleteDelegate(OnDeleteUserRequestComplete);
		// Store off the data for reporting later
		AddAt = DeleteUserRequests.Length;
		DeleteUserRequests.Length = AddAt + 1;
		DeleteUserRequests[AddAt].McpId = McpId;
		DeleteUserRequests[AddAt].Request = Request;
		`LogMcp("URL is DELETE " $ Url);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start DeleteUser web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the delete request completes
 *
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnDeleteUserRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int UserIndex;
	local int ResponseCode;

	// Search for the corresponding entry in the array
	Index = DeleteUserRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && ResponseCode == 200;
		if (bWasSuccessful)
		{
			// Delete this user from our list
			UserIndex = UserStatuses.Find('McpId', DeleteUserRequests[Index].McpId);
			if (UserIndex != INDEX_NONE)
			{
				UserStatuses.Remove(UserIndex, 1);
			}
		}
		// Notify anyone waiting on this
		OnDeleteUserComplete(bWasSuccessful,
			Response.GetContentAsString());
		DeleteUserRequests.Remove(Index,1);
	}
}

/**
 * @returns the auth ticket for the specified user
 */
function String GetAuthToken(String McpId)
{
	local int Index;

	Index = UserStatuses.Find('McpId', McpId);
	if (Index != INDEX_NONE)
	{
		return UserStatuses[Index].Ticket;
	}
	return "";
}

/**
 * Used to load a user from a secure (encrypted) file
 */
function InjectUserCredentials(String McpId, String ClientSecret, String Token)
{
	local int Index;

	Index = UserStatuses.Find('McpId', McpId);
	if (Index == INDEX_NONE)
	{
		Index = UserStatuses.Length;
		UserStatuses.Length = Index + 1;
	}
	UserStatuses[Index].McpId = McpId;
	UserStatuses[Index].SecretKey = ClientSecret;
	UserStatuses[Index].Ticket = Token;
}

