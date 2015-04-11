/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * This is the MCP3 version of the inventory manager
 */
class McpUserInventoryManagerV3 extends McpUserInventoryBase
	config(Engine);

/** The URL to send game commands to */
var config String ProcessCommandUrl;
var config String ProfileResourcePath;
var config String IapResourcePath;

/** Id used on the backend to create your default profile data */
var config String ProfileTemplateId;

/** Holds the context for the create */
struct UserRequest
{
	var HttpRequestInterface Request;
	var String McpId;
};

/** Holds the context for the create */
struct SaveSlotRequest extends UserRequest
{
	var String SaveSlotId;
};

/** The set of requests that are pending */
var array<SaveSlotRequest> SaveSlotRequests;
var array<UserRequest> UserRequests;

/** The set of save slots that are known about */
var array<McpInventorySaveSlot> SaveSlots;

/** The list of IAPs for a given user */
var array<McpIapList> IapLists;

/**
 * Builds the path to a user's profile
 *
 * @param McpId the user manipulating their profile
 * @param ProfileId the profile being manipulated
 *
 * @return the path to the profile resource
 */
function String BuildProfileResourcePath(String McpId, optional String ProfileId)
{
	local String Path;

	Path = Repl(ProfileResourcePath, "{epicId}", McpId);
	Path = Repl(Path, "{profileId}", ProfileId);
	return GetBaseURL() $ Path;
}

/**
 * Builds the path to a user's IAP data
 *
 * @param McpId the user manipulating their profile
 * @param ProfileId the profile being manipulated
 *
 * @return the path to the profile resource
 */
function String BuildIapResourcePath(String McpId, optional String ProfileId)
{
	local String Path;

	Path = Repl(ProfileResourcePath, "{epicId}", McpId);
	Path = Repl(Path, "{profileId}", ProfileId);
	return GetBaseURL() $ Path;
}

/**
 * Creates a new save slot for the user
 * 
 * @param McpId the id of the user that made the request
 * @param SaveSlotId the save slot that is being created
 * @param ParentSaveSlotId ignored
 */
function CreateSaveSlot(string McpId, string SaveSlotId, optional string ParentSaveSlotId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String Json;

	if (McpId != "")
	{
		Request = CreateHttpRequest(McpId);
		if (Request != none)
		{
			Url = GetBaseURL() $ ProcessCommandUrl;

			Json = "[ { \"action\": \"safeCreateProfile\", " $
				"\"epicId\": \"" $ McpId $ "\", " $
				"\"profileId\": \"" $ SaveSlotId $ "\", " $
				"\"templateId\": \"" $ ProfileTemplateId $ "\" } ]";

			`LogMcp("CreateSaveSlot JSON is " $ Json);
			`LogMcp("CreateSaveSlot URL is POST " $ Url);
			// Build our web request with the above URL
			Request.SetURL(Url);
			Request.SetVerb("POST");
			Request.SetContentAsString(Json);
			Request.SetProcessRequestCompleteDelegate(OnCreateSaveSlotRequestComplete);

			// Store off the data for reporting later
			AddAt = SaveSlotRequests.Length;
			SaveSlotRequests.Length = AddAt + 1;
			SaveSlotRequests[AddAt].Request = Request;
			SaveSlotRequests[AddAt].McpId = McpId;

			// Now kick off the request
			if (!Request.ProcessRequest())
			{
				`LogMcp("Failed to start CreateSaveSlot web request for URL(" $ Url $ ")");
			}
		}
	}
	else
	{
		OnCreateSaveSlotComplete(McpId, SaveSlotId, false, "No user specified for create");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnCreateSaveSlotRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;

	Index = SaveSlotRequests.Find('Request', Request);
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
			ErrorString = "CreateSaveSlot failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnCreateSaveSlotComplete(SaveSlotRequests[Index].McpId, SaveSlotRequests[Index].SaveSlotId, bWasSuccessful, ErrorString);
		SaveSlotRequests.Remove(Index,1);
	}
}

/**
 * Deletes an existing user save slot and all the inventory items that belong to it
 * 
 * @param McpId the id of the user that made the request
 * @param SaveSlotId the save slot that is being deleted
 */
function DeleteSaveSlot(string McpId, string SaveSlotId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String Json;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = GetBaseURL() $ ProcessCommandUrl;

		Json = "[ { \"action\": \"deleteProfile\", " $
			"\"epicId\": \"" $ McpId $ "\", " $
			"\"profileId\": \"" $ SaveSlotId $ "\" } ]";

		`LogMcp("DeleteSaveSlot JSON is " $ Json);
		`LogMcp("DeleteSaveSlot URL is POST " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("POST");
		Request.SetContentAsString(Json);
		Request.SetProcessRequestCompleteDelegate(OnDeleteSaveSlotRequestComplete);

		// Store off the data for reporting later
		AddAt = SaveSlotRequests.Length;
		SaveSlotRequests.Length = AddAt + 1;
		SaveSlotRequests[AddAt].Request = Request;
		SaveSlotRequests[AddAt].McpId = McpId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start DeleteSaveSlot web request for URL(" $ Url $ ")");
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
function OnDeleteSaveSlotRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;

	Index = SaveSlotRequests.Find('Request', Request);
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
			ErrorString = "DeleteSaveSlot failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		OnDeleteSaveSlotComplete(SaveSlotRequests[Index].McpId, SaveSlotRequests[Index].SaveSlotId, bWasSuccessful, ErrorString);
		SaveSlotRequests.Remove(Index,1);
	}
}

/**
 * Record an IAP (In App Purchase) by sending receipt to server for validation
 * Results in list of items being added to inventory if successful
 * 
 * @param McpId the id of the user that made the request
 * @param SaveSlotId the save slot that the item(s) will be placed in once validated
 * @param Vendor the provider of the purchasing system (Apple, Xbox Live, etc.)
 * @param Receipt IAP receipt to validate the purchase on the server
 */
function RecordIap(String McpId, String SaveSlotId, String Vendor, String Receipt)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local String Json;
	local array<McpIapItem> UpdatedItems;

	if (McpId != "")
	{
		Request = CreateHttpRequest(McpId);
		if (Request != none)
		{
			Url = GetBaseURL() $ ProcessCommandUrl;

			Json = "[ { \"action\": \"iapPurchase\", " $
				"\"epicId\": \"" $ McpId $ "\", " $
				"\"profileId\": \"" $ SaveSlotId $ "\", " $
				"\"vendor\": \"" $ Vendor $ "\", " $
				"\"vendorReceipt\": \"" $ Receipt $ "\" } ]";

			`LogMcp("RecordIap JSON is " $ Json);
			`LogMcp("RecordIap URL is POST " $ Url);
			// Build our web request with the above URL
			Request.SetURL(Url);
			Request.SetVerb("POST");
			Request.SetContentAsString(Json);
			Request.SetProcessRequestCompleteDelegate(OnRecordIapRequestComplete);

			// Store off the data for reporting later
			AddAt = SaveSlotRequests.Length;
			SaveSlotRequests.Length = AddAt + 1;
			SaveSlotRequests[AddAt].Request = Request;
			SaveSlotRequests[AddAt].McpId = McpId;
			SaveSlotRequests[AddAt].SaveSlotId = SaveSlotId;

			// Now kick off the request
			if (!Request.ProcessRequest())
			{
				`LogMcp("Failed to start RecordIap web request for URL(" $ Url $ ")");
			}
		}
	}
	else
	{
		UpdatedItems.Length = 0;
		OnRecordIapComplete(McpId, SaveSlotId, UpdatedItems, false, "No user specified to record the IAP for");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnRecordIapRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local array<McpIapItem> UpdatedItems;
	local McpIapItem Item;
	local JsonObject ParsedJson, JsonElement;
	local int JsonIndex;
	local String ActionString;
	local String SaveSlot;
	local AnalyticEventsBase Analytics;

	Index = SaveSlotRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
`Log("");
`Log("ResponseCode = " $ ResponseCode);
`Log("ResponseString = " $ ResponseString);
`Log("");
		Analytics = class'PlatformInterfaceBase'.static.GetAnalyticEventsInterface();
		if (Analytics != None)
		{
			Analytics.LogStringEventParam("MCP.RecordIap.HTTPCode", "HTTPCode", String(ResponseCode), false);
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			// Parse the JSON into the array of updated ids
			//[{"action":"addedItem","epicId":"895b2d6e3bae47e687bfb184cccfb648","profileId":"3","item":{"id":"11fa1f12e860446bb2a752a5516471d3","templateId":"com.chair.IB3.goldbag.A","attributes":{},"quantity":25000}},
			//{"action":"itemQuantityChanged","epicId":"895b2d6e3bae47e687bfb184cccfb648","profileId":"2","itemId":"cbeb4bad655f417f8ea553e287ec4f7c","templateId":"com.chair.IB3.goldbag.A","quantity":150000,"deltaQuantity":25000}]
			ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
			// Parse each returned inventory change
			for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
			{
				JsonElement = ParsedJson.ObjectArray[JsonIndex];
				// Only process the entry if it is for this save slot
				SaveSlot = JsonElement.GetStringValue("profileId");
				if (SaveSlot == SaveSlotRequests[Index].SaveSlotId)
				{
					// See if this is a quantity change or an add
					ActionString = JsonElement.GetStringValue("action");
					switch (ActionString)
					{
						case "addedItem":
							JsonElement = JsonElement.GetObject("item");
							if (JsonElement.HasKey("templateId"))
							{
								Item.ItemId = JsonElement.GetStringValue("templateId");
								Item.Quantity = JsonElement.GetIntValue("quantity");
								UpdatedItems.AddItem(Item);
							}
							break;
						case "itemQuantityChanged":
							if (JsonElement.HasKey("templateId"))
							{
								Item.ItemId = JsonElement.GetStringValue("templateId");
								Item.Quantity = JsonElement.GetIntValue("deltaQuantity");
								UpdatedItems.AddItem(Item);
							}
							break;
						default:
							`Log("Unknown action type (" $ ActionString $ ") found parsing IAP results");
							break;
					}
				}
			}
		}
		else
		{
			ErrorString = "RecordIap failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnRecordIapComplete(SaveSlotRequests[Index].McpId, SaveSlotRequests[Index].SaveSlotId, UpdatedItems, bWasSuccessful, ErrorString);
		SaveSlotRequests.Remove(Index,1);
	}
}

/**
 * Query for the list of save slots that exist for the user
 * 
 * @param McpId the id of the user that made the request
 */
function QuerySaveSlotList(string McpId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);
	if (Request != none)
	{
		Url = BuildProfileResourcePath(McpId);
		`LogMcp("QuerySaveSlotList URL is GET " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnQuerySaveSlotsRequestComplete);

		// Store off the data for reporting later
		AddAt = SaveSlotRequests.Length;
		SaveSlotRequests.Length = AddAt + 1;
		SaveSlotRequests[AddAt].Request = Request;
		SaveSlotRequests[AddAt].McpId = McpId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start QuerySaveSlotList web request for URL(" $ Url $ ")");
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
function OnQuerySaveSlotsRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;

	Index = SaveSlotRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
`LogMcp("");
`LogMcp("ResponseCode = " $ ResponseCode);
`LogMcp("ResponseString = " $ ResponseString);
`LogMcp("");
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (!bWasSuccessful)
		{
			ErrorString = "QuerySaveSlotList failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnQuerySaveSlotListComplete(SaveSlotRequests[Index].McpId, bWasSuccessful, ErrorString);
		SaveSlotRequests.Remove(Index,1);
	}
}

/**
 * Get the cached list of save slot ids for a user
 * 
 * @param McpId the id of the user that made the request
 *
 * @return the list of save slot ids for the user
 */
function array<string> GetSaveSlotList(string McpId);

/**
 * Read the user's save slot data
 *
 * @param McpId the user's id
 * @param SaveSlotId the save slot to read for the user
 */
function ReadSaveSlot(String McpId, String SaveSlotId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);
	if (Request != None)
	{
		Url = BuildProfileResourcePath(McpId, SaveSlotId);
		`LogMcp("ReadSaveSlot URL is GET " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnReadSaveSlotRequestComplete);

		// Store off the data for reporting later
		AddAt = SaveSlotRequests.Length;
		SaveSlotRequests.Length = AddAt + 1;
		SaveSlotRequests[AddAt].Request = Request;
		SaveSlotRequests[AddAt].McpId = McpId;
		SaveSlotRequests[AddAt].SaveSlotId = SaveSlotId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start ReadSaveSlot web request for URL(" $ Url $ ")");
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
function OnReadSaveSlotRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local JsonObject ParsedJson;

	Index = SaveSlotRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != None)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
`LogMcp("");
`LogMcp("ResponseCode = " $ ResponseCode);
`LogMcp("ResponseString = " $ ResponseString);
`LogMcp("");
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			if (ResponseString != "")
			{
				ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
				// Parse the json data for the profile
				ParseSaveSlot(ParsedJson);
			}
		}
		else
		{
			ErrorString = "ReadSaveSlot failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnReadSaveSlotComplete(SaveSlotRequests[Index].McpId, SaveSlotRequests[Index].SaveSlotId, bWasSuccessful, ErrorString);
		SaveSlotRequests.Remove(Index,1);
	}
}

/**
 * Parses all of the save slot data from its json form
 */
protected function ParseSaveSlot(JsonObject ParsedJson)
{
	local int FoundAt;
	local int SlotIndex;
	local int ItemIndex;
	local String McpId;
	local String SaveSlotId;
	local JsonObject ItemsArray;

	// Sample JSON:
	//{"epicId":"a5d0ba1744194d7dab48ea667cec4b7f","profileId":"0","templateId":"saveSlotTemplate","stats":[],"items":[{"id":"f0c30c53189a406aac25c5ba02035106","templateId":"Gold","attributes":{},"quantity":26000}]}
	if (ParsedJson.HasKey("epicId") && ParsedJson.HasKey("profileId"))
	{
		McpId = ParsedJson.GetStringValue("epicId");
		SaveSlotId = ParsedJson.GetStringValue("profileId");
		SlotIndex = INDEX_NONE;
		// Find the existing entry if present
		for (FoundAt = 0; FoundAt < SaveSlots.Length; FoundAt++)
		{
			if (SaveSlots[FoundAt].OwningMcpId == McpId && SaveSlots[FoundAt].SaveSlotId == SaveSlotId)
			{
				SlotIndex = FoundAt;
				break;
			}
		}
		if (SlotIndex == INDEX_NONE)
		{
			SlotIndex = SaveSlots.Length;
			SaveSlots.Length = SlotIndex + 1;
		}
		// Now fill in the entry
		SaveSlots[SlotIndex].OwningMcpId = McpId;
		SaveSlots[SlotIndex].SaveSlotId = SaveSlotId;

		//@todo joeg -- Parse the stats if present

		// Parse all of the array items
		SaveSlots[SlotIndex].Items.Length = 0;
		ItemsArray = ParsedJson.GetObject("items");
		SaveSlots[SlotIndex].Items.Length = ItemsArray.ObjectArray.Length;
		for (ItemIndex = 0; ItemIndex < ItemsArray.ObjectArray.Length; ItemIndex++)
		{
			SaveSlots[SlotIndex].Items[ItemIndex].GlobalItemId = ItemsArray.ObjectArray[ItemIndex].GetStringValue("templateId");
			SaveSlots[SlotIndex].Items[ItemIndex].InstanceItemId = ItemsArray.ObjectArray[ItemIndex].GetStringValue("id");
			SaveSlots[SlotIndex].Items[ItemIndex].Quantity = ItemsArray.ObjectArray[ItemIndex].GetIntValue("quantity");
			SaveSlots[SlotIndex].Items[ItemIndex].QuantityIAP = ItemsArray.ObjectArray[ItemIndex].GetIntValue("quantity");
			//@todo joeg -- Parse the attributes if present
		}
	}
}

/**
 * Copies the data for a user's save slot
 *
 * @param McpId the user's id
 * @param SaveSlotId the save slot being copied
 * @param SaveSlot the out value to copy into
 *
 * @return true if it was found, false otherwise
 */
function bool GetSaveSlot(String McpId, String SaveSlotId, out McpInventorySaveSlot SaveSlot)
{
	local int FoundAt;

	for (FoundAt = 0; FoundAt < SaveSlots.Length; FoundAt++)
	{
		if (SaveSlots[FoundAt].OwningMcpId == McpId && SaveSlots[FoundAt].SaveSlotId == SaveSlotId)
		{
			SaveSlot = SaveSlots[FoundAt];
			return true;
		}
	}
	return false;
}

/**
 * Queries the server for the list of IAPs for a specific user
 *
 * @param McpId the user to query them for
 */
function QueryIapList(String McpId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);
	if (Request != None)
	{
		Url = BuildIapResourcePath(McpId);
		`LogMcp("QueryIapList URL is GET " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnQueryIapListRequestComplete);

		// Store off the data for reporting later
		AddAt = UserRequests.Length;
		UserRequests.Length = AddAt + 1;
		UserRequests[AddAt].Request = Request;
		UserRequests[AddAt].McpId = McpId;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start QueryIapList web request for URL(" $ Url $ ")");
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
function OnQueryIapListRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int Index;
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local JsonObject ParsedJson;

	Index = UserRequests.Find('Request', Request);
	if (Index != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != None)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
`LogMcp("");
`LogMcp("ResponseCode = " $ ResponseCode);
`LogMcp("ResponseString = " $ ResponseString);
`LogMcp("");
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			if (ResponseString != "")
			{
				ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
				// Parse the json data for the profile
				ParseIapList(UserRequests[Index].McpId, ParsedJson);
			}
		}
		else
		{
			ErrorString = "ReadSaveSlot failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		// Notify anyone waiting on this
		OnQueryIapListComplete(UserRequests[Index].McpId, bWasSuccessful, ErrorString);
		UserRequests.Remove(Index,1);
	}
}

/**
 * Parses an array of iaps from its json form
 */
protected function ParseIapList(String McpId, JsonObject ParsedJson)
{
	local int ListIndex;
	local int IapIndex;
	local JsonObject Element;

	ListIndex = IapLists.Find('McpId', McpId);
	if (ListIndex == INDEX_NONE)
	{
		ListIndex = IapLists.Length;
		IapLists.Length = ListIndex + 1;
		IapLists[ListIndex].McpId = McpId;
	}
	IapLists[ListIndex].Iaps.Length = 0;
	IapLists[ListIndex].Iaps.Length = ParsedJson.ObjectArray.Length;
	// Sample JSON:
	//[{"vendor":"APPLE","vendorProductId":"com.chair.IB3.goldbag.A","vendorTransactionId":"710000026820584","epicId":"a5d0ba1744194d7dab48ea667cec4b7f","profileId":"","itemTemplateId":"Gold","quantity":26000}]
	for (IapIndex = 0; IapIndex < ParsedJson.ObjectArray.Length; IapIndex++)
	{
		Element = ParsedJson.ObjectArray[IapIndex];
		IapLists[ListIndex].Iaps[IapIndex].ItemId = Element.GetStringValue("itemTemplateId");
		IapLists[ListIndex].Iaps[IapIndex].SaveSlotId = Element.GetStringValue("profileId");
		IapLists[ListIndex].Iaps[IapIndex].Quantity = Element.GetIntValue("quantity");
	}
}

/**
 * Copies the data for a user's IAP list
 *
 * @param McpId the user's id
 * @param Iaps the out value to copy into
 *
 * @return true if it was found, false otherwise
 */
function bool GetIapList(String McpId, out McpIapList Iaps)
{
	local int ListIndex;

	ListIndex = IapLists.Find('McpId', McpId);
	if (ListIndex != INDEX_NONE)
	{
		Iaps = IapLists[ListIndex];
		return true;
	}
	return false;
}
