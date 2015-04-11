/** 
 * Base interface for HttpResponses.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class McpUserAuthResponseWrapper extends HttpResponseInterface;

var int ResponseCode;
var String ErrorString;

/**
 * Inits the error code and response string
 */
function Init(int InResponseCode, String InErrorString)
{
	ResponseCode = InResponseCode;
	ErrorString = InErrorString;
}

/**
 * Returns the response code returned by the requested server.
 * See HttpStatusCodes.uci for a complete list.
 *
 * @return	the response code.
 */
function int GetResponseCode()
{
	return ResponseCode;
}

/**
 * Returns the payload as a string, assuming the payload is UTF8.
 *
 * @return	The payload as a string.
 */
function String GetContentAsString()
{
	return ErrorString;
}
