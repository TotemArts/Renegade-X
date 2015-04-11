/**
 * Provides data for a UT3 map.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_MapInfo extends UDKUIDataProvider_MapInfo
	PerObjectConfig;

/** Script interface for determining whether or not this provider should be filtered */
event bool ShouldBeFiltered()
{
	return super.ShouldBeFiltered() || !SupportedByCurrentGameMode();
}

/** @return Returns whether or not this provider is supported by the current game mode */
function bool SupportedByCurrentGameMode()
{
	local int Pos, i;
	local string ThisMapPrefix, GameModePrefixes;
	local array<string> PrefixList;
	local bool bResult;
	local UIDataStore_Registry Registry;

	Registry = UIDataStore_Registry(class'UIRoot'.static.StaticResolveDataStore('Registry'));

	bResult = true;

	// Get our map prefix.
	Pos = InStr(MapName,"-");
	ThisMapPrefix = left(MapName,Pos);

	// maps show up as DM if no prefix
	if ( ThisMapPrefix == "" )
	{
		ThisMapPrefix = "DM";
	}
	if (Registry.GetData("SelectedGameModePrefix",GameModePrefixes) && GameModePrefixes != "")
	{
		bResult = false;
		ParseStringIntoArray(GameModePrefixes, PrefixList, "|", true);
		for (i = 0; i < PrefixList.length; i++)
		{
			bResult = (ThisMapPrefix ~= PrefixList[i]);
			if (bResult)
			{
				break;
			}
		}
	}

	return bResult;
}

defaultproperties
{
}
