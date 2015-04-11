/** 
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Class that forwards to an underlying HttpRequestInterface after providing extra checks
 */
class McpUserAuthRequestWrapper extends HttpRequestInterface;

/** The id of the user this request is on behalf of */
var String McpId;

/** The object that calls are forwarded to */
var HttpRequestInterface WrappedObject;

/**
 * Sets the object that we are wrapping so we can intercept some calls for extra processing
 */
function Init(String InMcpId, HttpRequestInterface RequestObject)
{
	McpId = InMcpId;
	WrappedObject = RequestObject;
}

/**
 * Gets the verb (GET, PUT, POST) used by the request.
 * 
 * @return	The verb
 */
function String GetVerb()
{
	if (WrappedObject != None)
	{
		return WrappedObject.GetVerb();
	}
	return "";
}

/**
 * Sets the verb (GET, PUT, POST) used by the request.
 * Should be set before calling ProcessRequest.
 * Defaults to GET.
 *
 * @param	Verb - Verb to use.
 * @return this
 */
function HttpRequestInterface SetVerb(String Verb)
{
	if (WrappedObject != None)
	{
		WrappedObject.SetVerb(Verb);
	}
	return self;
}

/**
 * Sets the URL for the request (http://my.domain.com/something.ext?key=value&key2=value).
 * Must be set before calling ProcessRequest.
 *
 * @param	URL - URL to use
 * @return this
 */
function HttpRequestInterface SetURL(String URL)
{
	if (WrappedObject != None)
	{
		WrappedObject.SetURL(URL);
	}
	return self;
}

/**
 * Sets the content of the request (optional data).
 * Usually only set for POST requests.
 *
 * @param	ContentPayload - payload to set.
 * @return this
 */
function HttpRequestInterface SetContent(const out array<byte> ContentPayload)
{
	if (WrappedObject != None)
	{
		WrappedObject.SetContent(ContentPayload);
	}
	return self;
}

/**
 * Sets the content of the request as a string encoded as UTF8.
 *
 * @param	ContentString - payload to set.
 * @return this
 */
function HttpRequestInterface SetContentAsString(String ContentString)
{
	if (WrappedObject != None)
	{
		WrappedObject.SetContentAsString(ContentString);
	}
	return self;
}

/**
 * Sets optional header info.
 * Content-Length is the only header set for you.
 * Required headers depends on the request itself.
 *
 * @param	HeaderName - Name of the header (ie, Content-Type)
 * @param	HeaderValue - Value of the header
 * @return this
 */
function HttpRequestInterface SetHeader(String HeaderName, String HeaderValue)
{
	if (WrappedObject != None)
	{
		WrappedObject.SetHeader(HeaderName, HeaderValue);
	}
	return self;
}

/**
 * Called to begin processing the request.
 * When a response is recevied, the OnProcessRequestComplete
 * delegate is called with the response.
 * Even if the request is invalid, the OnProcessRequestComplete delegate is still called.
 * In that case, the HttpResponse parameter will be None.
 *
 * @return	if the request was successfully sent. If false, the delegate will not fire.
 */
function bool ProcessRequest()
{
	local McpUserManagerBase UserManager;
	local String AuthToken;

	if (WrappedObject != None && McpId != "")
	{
		UserManager = class'McpUserManagerBase'.static.CreateInstance();
		if (UserManager != None)
		{
			AuthToken = UserManager.GetAuthToken(McpId);
		}
		if (AuthToken != "")
		{
			return WrappedObject.ProcessRequest();
		}
		else
		{
			// Send a 401 error, since they haven't been authorized
			ReportError(401, "User (" $ McpId $ ") does not have an auth ticket");
		}
	}
	else
	{
		// Send a 500 error
		ReportError(500, "Invalid call to ProcessRequest() due to missing request object or missing user id");
	}
	return false;
}

/**
 * Constructs a response object and passes the error codes to it
 */
protected function ReportError(int ResponseCode, String ErrorString)
{
	local McpUserAuthResponseWrapper Response;

	Response = new class'McpUserAuthResponseWrapper';
	Response.Init(ResponseCode, ErrorString);

	if (WrappedObject != None && WrappedObject.OnProcessRequestComplete != None)
	{
		WrappedObject.OnProcessRequestComplete(self, Response, false);
	}
}

/**
 * Used to re-route the callback with the proper source object
 */
function WrappedOnProcessRequestComplete(HttpRequestInterface OriginalRequest, HttpResponseInterface Response, bool bDidSucceed)
{
	if (OnProcessRequestComplete != None)
	{
		OnProcessRequestComplete(self, Response, bDidSucceed);
	}
}

/**
 * Sets the delegate as a convenience function for chaining expressions.
 *
 * @param	ProcessRequestCompleteDelegate - the delegate to set
 * @return	self
 */
function HttpRequestInterface SetProcessRequestCompleteDelegate(delegate<OnProcessRequestComplete> ProcessRequestCompleteDelegate)
{
	OnProcessRequestComplete = ProcessRequestCompleteDelegate;
	if (WrappedObject != None)
	{
		WrappedObject.OnProcessRequestComplete = WrappedOnProcessRequestComplete;
	}
	return self;
}
