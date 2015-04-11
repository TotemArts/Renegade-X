/**
 * Extends the resource data provider to have a 'filter' accessor so we can decide whether or not to include the provider in a list of items.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKUIResourceDataProvider extends UIResourceDataProvider
	native
	config(Game);

/** Friendly name for menus. */
var config localized string FriendlyName;

/** whether to search all .inis for valid resource provider instances instead of just the our specified config file
 * this is used for lists that need to support additions via extra files, i.e. mods
 */
var() bool bSearchAllInis;
/** the .ini file that this instance was created from, if not the class default .ini (for bSearchAllInis classes) */
var const string IniName;

/** Options to remove certain menu items on a per platform basis. */
var config bool bRemoveOn360;
var config bool bRemoveOnPC;
var config bool bRemoveOnPS3;

/** Script interface for determining whether or not this provider should be filtered */
event bool ShouldBeFiltered()
{
	local WorldInfo WorldI;

	WorldI = class'WorldInfo'.static.GetWorldInfo();

	if (!WorldI.IsConsoleBuild())
	{
		return bRemoveOnPC;
	}
	else if (WorldI.IsConsoleBuild(CONSOLE_Xbox360))
	{
		return bRemoveOn360;
	}
	else if (WorldI.IsConsoleBuild(CONSOLE_PS3))
	{
		return bRemoveOnPS3;
	}
	else if (WorldI.IsConsoleBuild(CONSOLE_Mobile))
	{
		// @todo mobile: Add specific removal flags for mobile?
		return bRemoveOnPC;
	}
	else
	{
		`log("Invalid Platform!");
	}
}


