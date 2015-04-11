/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * This is the base class for Google integration
 */
class GoogleIntegration extends PlatformInterfaceBase
	native(PlatformInterface)
	config(Engine);

struct native GoogleFriend
{
	var string DisplayName;
	var string Id;
};

struct native YouTubeChannel
{
	var String ChannelId;
	var String ChannelTitle;
	var String Description;
};

enum EGoogleIntegrationDelegate
{
	GDEL_AuthorizationComplete,
	GDEL_FriendsListComplete,
	GDEL_YouTubeSubscriptionListComplete,
	GDEL_YouTubeSubscriptionAddComplete
};

/** The list of API scopes that you are requesting access to via OAuth2 */
var config array<String> Scopes;

/** The id generated for your application by Google */
var config String ClientId;

/** The secret generated for your application by Google */
var config String ClientSecret;

/** The name you want your app known as in Google */
var config String ClientName;

/** The auth token for Google's OAuth2 */
var transient String UserAuthToken;

/** The user id for google plus */
var transient String UserId;

/** The email address that Google provides */
var transient String UserEmail;

/** The display name from querying for the user profile */
var transient String UserName;

/** The friends list for the signed in user */
var transient array<GoogleFriend> Friends;

/** The list of channels that the signed in user is subscribed to */
var transient array<YouTubeChannel> Subscriptions;

/**
 * Perform any needed initialization
 */
native event bool Init();

/**
 * Starts the process of allowing the app to use Facebook
 */
native event bool Authorize();

/**
 * @return true if the app has been authorized by the current user
 */
native event bool IsAuthorized();

/**
 * @return true if the app cleared the authorization successfully
 */
native event bool RevokeAuthorization();

/**
 * Used to subscribe to a YouTube channel
 *
 * @param ChannelId the channel to subsribe to
 */
native event SubscribeToYouTubeChannel(String ChannelId);
