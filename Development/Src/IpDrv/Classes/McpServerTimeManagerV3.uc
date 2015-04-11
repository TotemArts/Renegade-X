/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Implementation of interface for requesting UTC time from the server
 */
class McpServerTimeManagerV3 extends McpServerTimeBase;

`include(Engine\Classes\HttpStatusCodes.uci)

/** The class name to use in the factory method to create our instance */
var config String TimeStampUrl;

/** String for the last valid server time response */
var String LastTimeStamp;

/** HTTP request object that is used for the server time query. None when no request is in flight */
var HttpRequestInterface HTTPRequestServerTime;

/**
 * Request current UTC time from the server
 */
function QueryServerTime()
{
	local string Url,ErrorStr;
	local bool bPending;

	if (HTTPRequestServerTime == None)
	{
		HTTPRequestServerTime = class'HttpFactory'.static.CreateRequest();
		if (HTTPRequestServerTime != None)
		{
			Url = GetBaseURL() $ TimeStampUrl;
			HTTPRequestServerTime.SetURL(Url);
			HTTPRequestServerTime.SetVerb("GET");
			HTTPRequestServerTime.OnProcessRequestComplete = OnQueryServerTimeHTTPRequestComplete;
			if (HTTPRequestServerTime.ProcessRequest())
			{
				bPending = true;
			}
			else
			{
				ErrorStr = "failed to start request, Url="$Url;
				`LogMcp(`StaticLocation@ErrorStr);
			}
			`LogMcp("QueryServerTime URL is GET " $ Url);
		}	
	}
	else
	{
		ErrorStr = "last request is still being processed";
		`LogMcp(`StaticLocation@ErrorStr);
	}
	if (!bPending)
	{
		OnQueryServerTimeComplete(false,"",ErrorStr);
	}
}

/**
 * Called once the request/response has completed for getting server time from Mcp
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
private function OnQueryServerTimeHTTPRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local string ResponseString;
	local string Error;
	local bool bResult;

	HTTPRequestServerTime = None;

	if (bWasSuccessful &&
		Response != None)
	{
		if (Response.GetResponseCode() == `HTTP_STATUS_OK)
		{
			ResponseString = Response.GetContentAsString();
			if (Len(ResponseString) > 0)
			{
				LastTimeStamp = ServerDateTimeToUnrealDateTime(ResponseString);
				bResult = true;
			}
			else
			{
				Error = "no response string";
				`LogMcp(`StaticLocation@Error);
			}
		}
		else
		{
			Error = "invalid server response code, status="$Response.GetResponseCode();
			`LogMcp(`StaticLocation@Error);
		}
	}
	else
	{
		Error = "no response";
		`LogMcp(`StaticLocation@Error);
	}
	OnQueryServerTimeComplete(bResult, LastTimeStamp, Error);
}

/**
 * Retrieve cached timestamp from last server time query 
 *
 * @return string representation of time (yyyy.MM.dd-HH.mm.ss)
 */
function String GetLastServerTime()
{
	return LastTimeStamp;
}