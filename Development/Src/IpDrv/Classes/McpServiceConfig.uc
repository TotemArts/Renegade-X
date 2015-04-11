/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Base configuration for all MCP web services
 */
class McpServiceConfig extends Object
	config(Engine);

/** The protocol information to prefix when building the url (e.g. https) */
var config string DevProtocol;
var config string ProdProtocol;

/** The domain to prefix when building the url (e.g. localhost:8080) */
var config string DevDomain;
var config string ProdDomain;

/** Used to build the urls and is set by the config values above */
var transient String Domain;
var transient String Protocol;

/** AppKey for access privileges to the online services for the current title. Not config so it can be hidden */
var string AppKey;

/** AppSecret for access privileges to the online services for the current title. Not config so it can be hidden */
var string AppSecret;

/** The game name to pass as part of the requests */
var config string GameName;

/** The service name to pass as part of the requests */
var config string ServiceName;

/** Used to auth game with a password and no logged in user */
var String GameUser;
var String GamePassword;

function Init(bool bIsProduction)
{
	if (bIsProduction)
	{
		Domain = ProdDomain;
		Protocol = ProdProtocol;
	}
	else
	{
		Domain = DevDomain;
		Protocol = DevProtocol;
	}
}


/**
 * Get the auth ticket for a user
 * 
 * @param McpId user id to get auth access for
 * 
 * @return auth ticket string
 */
function string GetUserAuthTicket(string McpId);