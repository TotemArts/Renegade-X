/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Provides the interface for registering for push notifications
 */
class McpRemoteNotificationV3 extends McpRemoteNotificationBase;

var config String PushNotificationPath;

struct UserRequest
{
	/** The user that this call is for */
	var string McpId;
	/** The push notification token to register */
	var String PushNotificationToken;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

var array<UserRequest> UserRequests;

/**
 * Registers the push notification token with remote service. This is a 2 step process.
 * First associates the token as a device and then adds the token
 */
function RegisterPushNotificationToken(String McpId, String PushNotificationToken)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);

	Url = GetBaseURL() $ PushNotificationPath $ "/" $ PushNotificationToken;
	`LogMcp("RegisterPushNotificationToken URL is PUT " $ Url);

	Request.SetURL(Url);
	Request.SetVerb("PUT");
	Request.SetContentAsString(McpId);
	Request.SetProcessRequestCompleteDelegate(OnPushNotificationRequestComplete);

	AddAt = UserRequests.Length;
	UserRequests.Length = AddAt + 1;
	UserRequests[AddAt].Request = Request;
	UserRequests[AddAt].McpId = McpId;
	UserRequests[AddAt].PushNotificationToken = PushNotificationToken;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start RegisterPushNotificationToken web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnPushNotificationRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local String PushToken;
	local String McpId;
	local int RequestIndex;

	RequestIndex = UserRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		PushToken = UserRequests[RequestIndex].PushNotificationToken;
		McpId = UserRequests[RequestIndex].McpId;
		UserRequests.Remove(RequestIndex, 1);
	}
	ResponseCode = 500;
	if (Response != none)
	{
		ResponseCode = Response.GetResponseCode();
		ResponseString = Response.GetContentAsString();
	}
	// Both of these need to be true for the request to be a success
	bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode) && RequestIndex != INDEX_NONE;
	if (bWasSuccessful)
	{
		// Now do the second part
		AssociatePushNotificationToken(McpId, PushToken);
	}
	else
	{
		ErrorString = "OnPushNotificationRequestComplete failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		OnRegisterPushNotificationTokenComplete(false, McpId, PushToken);
	}
	if (!bWasSuccessful && Len(ErrorString) > 0)
	{
		`LogMcp(ErrorString);
	}
}

/**
 * Performs the second part of the 2 part process
 */
function AssociatePushNotificationToken(String McpId, String PushNotificationToken)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(McpId);

	Url = GetBaseURL() $ PushNotificationPath $ "/" $ PushNotificationToken;
	`LogMcp("AssociatePushNotificationToken URL is POST " $ Url);

	Request.SetURL(Url);
	Request.SetVerb("POST");
	Request.SetContentAsString(PushNotificationToken);
	Request.SetProcessRequestCompleteDelegate(OnAssociatePushNotificationTokenRequestComplete);

	AddAt = UserRequests.Length;
	UserRequests.Length = AddAt + 1;
	UserRequests[AddAt].Request = Request;
	UserRequests[AddAt].McpId = McpId;
	UserRequests[AddAt].PushNotificationToken = PushNotificationToken;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start AssociatePushNotificationToken web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnAssociatePushNotificationTokenRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local String PushToken;
	local String McpId;
	local int RequestIndex;

	RequestIndex = UserRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		PushToken = UserRequests[RequestIndex].PushNotificationToken;
		McpId = UserRequests[RequestIndex].McpId;
		UserRequests.Remove(RequestIndex, 1);
	}
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
		ErrorString = "OnAssociatePushNotificationTokenRequestComplete failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
	}
	if (!bWasSuccessful && Len(ErrorString) > 0)
	{
		`LogMcp(ErrorString);
	}
	else
	{
		`Log("Push notification registration completed successfully");
	}
	OnRegisterPushNotificationTokenComplete(bWasSuccessful, McpId, PushToken);
}
