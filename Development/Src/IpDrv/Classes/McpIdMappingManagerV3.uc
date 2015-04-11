/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Concrete implementation for the new UnrealMCP3 services
 */
class McpIdMappingManagerV3 extends McpIdMappingBase;

/**
 * Holds the set of mapped accounts that we've downloaded
 */
var array<McpIdMapping> AccountMappings;

/** The URL to use when making add mapping requests */
var config String AddMappingUrl;

/** The URL to use when making query mapping requests */
var config String QueryMappingUrl;

/** Holds the state information for an outstanding add mapping request */
struct AddMappingRequest
{
	var McpIdMapping Mapping;
	/** The McpId the add is happening to */
	var string McpId;
	/** The external account id that is being mapped to a MCP id */
	var string ExternalId;
	/** The account type that is being mapped */
	var string ExternalType;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

/** The set of add mapping requests that are pending */
var array<AddMappingRequest> AddMappingRequests;

/** Holds the state information for an outstanding query mapping request */
struct QueryMappingRequest
{
	/** The account type that is being mapped */
	var string ExternalType;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

/** The set of query mapping requests that are pending */
var array<QueryMappingRequest> QueryMappingRequests;

/**
 * @return the path to the login service's mapping resource
 */
function String BuildAddMappingResourcePath(String McpId)
{
	return GetBaseURL() $ Repl(AddMappingUrl, "{epicId}", McpId);
}

/**
 * @return the path to the game service's mapping resource
 */
function String BuildQueryMappingResourcePath(String Type)
{
	local String Path;

	Path = Repl(QueryMappingUrl, "{type}", Type);

	return GetBaseURL() $ Path;
}

/**
 * Adds an external account mapping. Sends this request to MCP to be processed
 *
 * @param McpId the account to add the mapping to
 * @param ExternalId the external account that is being mapped to this account
 * @param ExternalType the type of account for disambiguation
 */
function AddMapping(String McpId, String ExternalId, String ExternalType, optional String ExternalToken)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String Json;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = BuildAddMappingResourcePath(McpId);
		Json = "{ \"externalId\": \"" $ ExternalId $ "\", \"type\": \"" $ ExternalType $ "\", \"externalToken\": ";
		// Special hack that uses gamecenter as the token for all accounts since there's zero verification
		if (ExternalType == "gamecenter")
		{
			Json $= "\"gamecenter\"";
		}
		else
		{
			Json $= "\"" $ ExternalToken $ "\"";
		}
		Json $= " }";

		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnAddMappingRequestComplete);
		// Store off the data for reporting later
		AddAt = AddMappingRequests.Length;
		AddMappingRequests.Length = AddAt + 1;
		AddMappingRequests[AddAt].Mapping.McpId = McpId;
		AddMappingRequests[AddAt].Mapping.ExternalId = ExternalId;
		AddMappingRequests[AddAt].Mapping.ExternalType = ExternalType;
		AddMappingRequests[AddAt].Mapping.ExternalToken = ExternalToken;
		AddMappingRequests[AddAt].Request = Request;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start AddMapping web request for URL(" $ Url $ ")");
		}
		`LogMcp("AddMapping URL is POST " $ Url);
		`LogMcp("AddMapping JSON is  " $ Json);
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
function OnAddMappingRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int AddAt;
	local int ResponseCode;

	// Search for the corresponding entry in the array
	Index = AddMappingRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		// Add this item to our list
		if (bWasSuccessful)
		{
			AddAt = AccountMappings.Length;
			AccountMappings.Length = AddAt + 1;
			AccountMappings[AddAt].McpId = AddMappingRequests[Index].Mapping.McpId;
			AccountMappings[AddAt].ExternalId = AddMappingRequests[Index].Mapping.ExternalId;
			AccountMappings[AddAt].ExternalType = AddMappingRequests[Index].Mapping.ExternalType;
			AccountMappings[AddAt].ExternalToken = AddMappingRequests[Index].Mapping.ExternalToken;
		}
		else
		{
			`LogMcp("AddMapping failed with error code (" $ ResponseCode $ ") and error reason: " $ Response.GetContentAsString());
		}
		// Notify anyone waiting on this
		OnAddMappingComplete(AddMappingRequests[Index].Mapping.McpId,
			AddMappingRequests[Index].Mapping.ExternalId,
			AddMappingRequests[Index].Mapping.ExternalType,
			bWasSuccessful,
			Response.GetContentAsString());
		// Done with the pending request
		AddMappingRequests.Remove(Index,1);
	}
}

/**
 * Queries the backend for the McpIds of the list of external ids of a specific type
 * 
 * @param McpId the issuer of the request
 * @param ExternalIds the set of ids to get McpIds for
 * @param ExternalType the type of account that is being mapped to McpIds
 */
function QueryMappings(String McpId, const out array<String> ExternalIds, String ExternalType)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local string JsonPayload;
	local int Index;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = BuildQueryMappingResourcePath(ExternalType);
		// Make a json string from our list of ids
		JsonPayload = "[ ";
		for (Index = 0; Index < ExternalIds.Length; Index++)
		{
			if (Len(ExternalIds[Index]) > 0)
			{
				JsonPayload $= "\"" $ ExternalIds[Index] $ "\"";
				if (Index + 1 < ExternalIds.Length)
				{
					JsonPayload $= ",";
				}
			}
		}
		JsonPayload $= " ]";
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetContentAsString(JsonPayload);
		Request.SetVerb("POST");
		Request.SetProcessRequestCompleteDelegate(OnQueryMappingsRequestComplete);

		// Store off the data for reporting later
		AddAt = QueryMappingRequests.Length;
		QueryMappingRequests.Length = AddAt + 1;
		QueryMappingRequests[AddAt].ExternalType = ExternalType;
		QueryMappingRequests[AddAt].Request = Request;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start QueryMappings web request for URL(" $ Url $ ")");
		}
		`LogMcp("QueryMappings URL is POST " $ Url);
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
function OnQueryMappingsRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int AddAt;
	local int ResponseCode;
	local string JsonString;
	local JsonObject ParsedJson;
	local int JsonIndex;
	local int AccountIndex;
	local bool bWasFound;
	local string McpId;
	local string ExternalId;
	local string ExternalType;
	local JsonObject JsonElement;
	local String Error;

	// Search for the corresponding entry in the array
	Index = QueryMappingRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		// Add this item to our list
		if (bWasSuccessful)
		{
			JsonString = Response.GetContentAsString();
			if (JsonString != "")
			{
				// Parse the json
				ParsedJson = class'JsonObject'.static.DecodeJson(JsonString);
				// Add each mapping in the json packet if missing
				for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length && bWasSuccessful; JsonIndex++)
				{
					if (ParsedJson.ObjectArray[JsonIndex].HasKey("gameAccountId"))
					{
						McpId = ParsedJson.ObjectArray[JsonIndex].GetStringValue("gameAccountId");
						JsonElement = ParsedJson.ObjectArray[JsonIndex].GetObject("externalAccount");
						if (JsonElement != None)
						{
							if (JsonElement.HasKey("externalId") && JsonElement.HasKey("type"))
							{
								ExternalId = JsonElement.GetStringValue("externalId");
								ExternalType = JsonElement.GetStringValue("type");
								bWasFound = false;
								// Search the array for any existing adding only when missing
								for (AccountIndex = 0; AccountIndex < AccountMappings.Length && !bWasFound; AccountIndex++)
								{
									bWasFound = McpId == AccountMappings[AccountIndex].McpId &&
										ExternalId == AccountMappings[AccountIndex].ExternalId &&
										ExternalType == AccountMappings[AccountIndex].ExternalType;
								}
								// Add this one since it wasn't found
								if (!bWasFound)
								{
									AddAt = AccountMappings.Length;
									AccountMappings.Length = AddAt + 1;
									AccountMappings[AddAt].McpId = McpId;
									AccountMappings[AddAt].ExternalId = ExternalId;
									AccountMappings[AddAt].ExternalType = ExternalType;
								}
							}
							else
							{
								Error = "Malformed JSON returned for QueryMappings(), missing externalId or type. JSON is:\n" $ JsonString;
								bWasSuccessful = false;
							}
						}
						else
						{
							Error = "Malformed JSON returned for QueryMappings(), missing externalAccount. JSON is:\n" $ JsonString;
							bWasSuccessful = false;
						}
					}
					else
					{
						Error = "Malformed JSON returned for QueryMappings(), missing gameAccountId. JSON is:\n" $ JsonString;
						bWasSuccessful = false;
					}
				}
			}
		}
		else
		{
			Error = "Request failed with status code (" $ ResponseCode $ ") and payload:\n" $ JsonString;
		}
		// Notify anyone waiting on this
		OnQueryMappingsComplete(QueryMappingRequests[Index].ExternalType, bWasSuccessful, Error);
		// Done with the pending request
		QueryMappingRequests.Remove(Index,1);
	}
}

/**
 * Returns the set of id mappings that match the requested account type
 * 
 * @param ExternalType the account type that we want the mappings for
 * @param IdMappings the out array that gets the copied data
 */
function GetIdMappings(String ExternalType, out array<McpIdMapping> IdMappings)
{
	local int Index;
	local int AddAt;

	IdMappings.Length = 0;

	// Search through for all mappings that match the desired type
	for (Index = 0; Index < AccountMappings.Length; Index++)
	{
		if (AccountMappings[Index].ExternalType == ExternalType)
		{
			AddAt = IdMappings.Length;
			IdMappings.Length = AddAt + 1;
			IdMappings[AddAt] = AccountMappings[Index];
		}
	}
}
