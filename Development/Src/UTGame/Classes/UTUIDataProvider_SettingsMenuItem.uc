/**
 * Provides menu items for the settings menu.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_SettingsMenuItem extends UTUIResourceDataProvider
	PerObjectConfig;

/** Localized description of the map */
var localized string Description;

/** Only valid for front-end menus - will be hidden ingame */
var	config bool	bFrontEndOnly;

/** @return 	TRUE if this data provider requires online access but is not able or allowed to play online */
event bool ShouldBeFiltered()
{
	return super.ShouldBeFiltered() || ( bFrontEndOnly && !class'WorldInfo'.static.IsMenuLevel() );
}
