/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Common functionality for all MCP web service interfaces
 */
class McpServiceBase extends Object
	native
	config(Engine);

/** Class to load and instantiate for the handling configuration options for MCP services */
var config string McpConfigClassName;
/** Contains all the configuration options common to MCP services. Protocol, URL, access key, etc */
var McpServiceConfig McpConfig;

/* Initialize always called after constructing a new MCP service subclass instance via its factory method */
protected event Init()
{
	local class<McpServiceConfig> McpConfigClass;

	`log("Loading McpServerBase McpConfigClass:" $ default.McpConfigClassName);
	// load the configuration class and instantiate it
	McpConfigClass = class<McpServiceConfig>(DynamicLoadObject(default.McpConfigClassName,class'Class'));
	if (McpConfigClass != None)
	{
		McpConfig = new McpConfigClass;
		McpConfig.Init(IsProduction());
	}
}

/** Returns true if this is meant to go to production, otherwise dev should be used */
final native function bool IsProduction();

/**
 * Mechanism for having a singleton in script (no statics). Searches for an existing object
 * with a particular name (<ClassName>_Singleton) and returns that if found. Otherwise it
 * creates a new instance of the class with that specific name
 *
 * @param SingletonClass the class to get the singleton for
 *
 * @return the singleton object
 */
final native static function McpServiceBase GetSingleton(class SingletonClass);

/**
 * @return Base protocol and domain for communicating with MCP server
 */
function string GetBaseURL()
{
	local string Url;
	Url = McpConfig.Protocol $ "://" $ McpConfig.Domain;
	if (Len(McpConfig.ServiceName) > 0)
	{
		Url $= "/" $ McpConfig.ServiceName;
	}
	return Url;
}

/** @return true if the status code is in the 200-206 range or not modified */
static function bool IsSuccessCode(int StatusCode)
{
	return (StatusCode >= 200 && StatusCode <= 206) || StatusCode == 304;
}

/**
 * @return Access rights for app including title id
 */
function string GetAppAccessURL()
{
	return "?appKey=" $ McpConfig.AppKey $ "&appSecret=" $ McpConfig.AppSecret;
}

/**
 * Build the URL for auth ticket access
 * 
 * @param McpId user id to build auth access for
 * 
 * @return URL parameters needed for user auth ticket usage
 */
function string GetUserAuthURL(string McpId)
{
	local string AuthTicket;

	AuthTicket = McpConfig.GetUserAuthTicket(McpId);
	if (Len(AuthTicket) > 0)
	{
		return "&authTicket=" $ AuthTicket;
	}
	return "";
}

/**
 * Adds the authorization header for the specified user
 *
 * @param Request the request to add to
 * @param McpId the user to add this for
 */
function AddUserAuthorization(HttpRequestInterface Request, String McpId)
{
	local McpUserManagerBase UserManager;
	local String AuthToken;

	if (Request != none && McpId != "")
	{
		UserManager = class'McpUserManagerBase'.static.CreateInstance();
		if (UserManager != None)
		{
			AuthToken = UserManager.GetAuthToken(McpId);
		}
		if (AuthToken != "")
		{
`if(`notdefined(FINAL_RELEASE))
			if (AuthToken == "ADMIN")
			{
				UseGameServiceAuth(Request);
			}
			else
			{
				Request.SetHeader("Authorization", "mcp " $ AuthToken);
			}
`else
			Request.SetHeader("Authorization", "mcp " $ AuthToken);
`endif
		}
		else
		{
			// Fall back to game auth
			UseGameServiceAuth(Request);
		}
	}
}

/**
 * @return the user agent to use for the request
 */
function string GetUserAgent()
{
	return "game=" $ McpConfig.GameName $ ", engine=UE3, version=" $ GetEngineVersionToReport();
}

/** @return the engine version or the override version if specified */
native function int GetEngineVersionToReport();

/**
 * Helper function that returns an HttpRequest object with the agent/content type set
 *
 * @param McpId optional user to get the auth token for
 *
 * @return the newly created http request object
 */
function HttpRequestInterface CreateHttpRequest(optional String McpId)
{
	local HttpRequestInterface Request;
	local McpUserAuthRequestWrapper WrappingRequest;

	Request = class'HttpFactory'.static.CreateRequest();
	if (Request != none)
	{
		// Wrap this object in one that validates the auth ticket before processing the request
		if (McpId != "")
		{
			WrappingRequest = new class'McpUserAuthRequestWrapper';
			WrappingRequest.Init(McpId, Request);
			Request = WrappingRequest;
		}
		// Set all of the common headers
		Request.SetHeader("X-Game-Agent", GetUserAgent());
		Request.SetHeader("Content-Type", "application/json");
		AddUserAuthorization(Request, McpId);
	}
	return Request;
}

/**
 * Sets the Authorization header with the basic auth, "Base <UserName:Password>Base64"
 *
 * @param Request the request object being updated
 * @param UserName the user that is sending the password
 * @param Password the password for this user
 */
function UseBasicAuth(HttpRequestInterface Request, String UserName, String Password)
{
	Request.SetHeader("Authorization", "Basic " $ class'Base64'.static.EncodeString(UserName $ ":" $ Password));
}

/**
 * Helper function that returns an HttpRequest object with the agent/content type set
 *
 * @param McpId optional user to get the auth token for
 *
 * @return the newly created http request object
 */
function HttpRequestInterface CreateHttpRequestGameAuth()
{
	local HttpRequestInterface Request;

	Request = class'HttpFactory'.static.CreateRequest();
	if (Request != none)
	{
		// Set all of the common headers
		Request.SetHeader("X-Game-Agent", GetUserAgent());
		Request.SetHeader("Content-Type", "application/json");
		UseGameServiceAuth(Request);
	}
	return Request;
}

/** Sets the game auth header */
function UseGameServiceAuth(HttpRequestInterface Request)
{
	UseBasicAuth(Request, McpConfig.GameUser, McpConfig.GamePassword);
}

/**
 * Converts the server time/date format to Unreal's time/date format
 *
 * @param ServerDateTime time/date to convert
 *
 * @return the converted time/date
 */
function String ServerDateTimeToUnrealDateTime(String ServerDateTime)
{
	local String ConvertedDateTime;
	local string Time;
	local string Date;
	local int Index;

	if (Len(ServerDateTime) > 0)
	{
		// Convert to "Unreal format" (yyyy.MM.dd-HH.mm.ss)
		// Example: "2013-05-28T21:58:33.605Z"
		// Strip off the quotes on either side - sometimes there are quotes, sometimes not. Must have fixed server.
		ServerDateTime = Repl(ServerDateTime, "\"", "");
		// Split into date and time chunks
		Index = InStr(ServerDateTime, "T");
		Date = Left(ServerDateTime, Index);
		Time = Mid(ServerDateTime, Index + 1);
		// Swap - with .
		Date = Repl(Date, "-", ".", false);
		// Strip off the millis and the timezone info
		Index = InStr(Time, ".", true);
		if (Index != INDEX_NONE)
		{
			Time = Left(Time, Index);
		}
		Time = Repl(Time, ":", ".");
		ConvertedDateTime = Date $ "-" $ Time;
	}
	return ConvertedDateTime;
}

/**
 * Converts the Unreal time/date format to the Server's time/date format
 *
 * @param UnrealDateTime time/date to convert
 *
 * @return the converted time/date
 */
function String UnrealDateTimeToServerDateTime(String UnrealDateTime)
{
	local String ConvertedDateTime;
	local string Time;
	local string Date;
	local int Index;

	if (Len(UnrealDateTime) > 0)
	{
		// Convert from "Unreal format" (yyyy.MM.dd-HH.mm.ss)
		// to: "2013-05-28T21:58:33.605Z"
		// Split into date and time chunks
		Index = InStr(UnrealDateTime, "-");
		Date = Left(UnrealDateTime, Index);
		Time = Mid(UnrealDateTime, Index + 1);
		// Swap . with - in the date info
		Date = Repl(Date, ".", "-", false);
		// Swap . with : in the time info
		Time = Repl(Time, ".", ":");
		// Add millis and the time zone (UTC)
		Time $= ".000Z";
		ConvertedDateTime = Date $ "T" $ Time;
	}
	return ConvertedDateTime;
}
