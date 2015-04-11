/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Provides the interface for registering for push notifications
 */
class McpRemoteNotificationBase extends McpServiceBase
	abstract
	config(Engine);

/** The class name to use in the factory method to create our instance */
var config String McpRemoteNotificationClassName;

/**
 * @return the object that implements this interface or none if missing or failed to create/load
 */
final static function McpRemoteNotificationBase CreateInstance()
{
	local class<McpRemoteNotificationBase> McpRemoteNotificationClass;
	local McpRemoteNotificationBase NewInstance;

	McpRemoteNotificationClass = class<McpRemoteNotificationBase>(DynamicLoadObject(default.McpRemoteNotificationClassName,class'Class'));
	// If the class was loaded successfully, create a new instance of it
	if (McpRemoteNotificationClass != None)
	{
		NewInstance = McpRemoteNotificationBase(GetSingleton(McpRemoteNotificationClass));
	}

	return NewInstance;
}

/**
 * Registers the push notification token with remote service
 */
function RegisterPushNotificationToken(String McpId, String PushNotificationToken);

/**
 * Called when the time request from the server is complete
 *
 * @param bWasSuccessful true if server was contacted and a valid result received
 */
delegate OnRegisterPushNotificationTokenComplete(bool bWasSuccessful, String McpId, String PushToken);
