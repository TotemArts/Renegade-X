/**
 * Provides menu items for the multiplayer menu.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_MultiplayerMenuItem extends UTUIResourceDataProvider
	PerObjectConfig;

/** Localized description of the map */
var config localized string Description;

/** Indicates that this menu item should only be shown if the user is online, signed in, and has the required priveleges */
var	config	bool	bRequiresOnlineAccess;


/** 
  * Script interface for determining whether or not this provider should be filtered 
  * @return 	TRUE if this data provider requires online access but is not able or allowed to play online
  */
event bool ShouldBeFiltered()
{
	local PlayerController PC;
	
	if (super.ShouldBeFiltered())
	{
		return true;
	}

	if ( bRequiresOnlineAccess )
	{
		ForEach class'Engine'.static.GetCurrentWorldInfo().LocalPlayerControllers(class'PlayerController', PC)
		{
			return !PC.CanAllPlayersPlayOnline();
		}
	}

	return false;
}