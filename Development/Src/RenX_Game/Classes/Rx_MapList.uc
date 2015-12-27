/*********************************************************
*
* File: Rx_MapListManager.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class handles the MapList on any custom maps created by modders and map makers.
* Copied and modified from UT3 Script Source v1.3 under file UTMapList.uc
* It is created and called by Rx_MapList.uc.	
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/

class Rx_MapList extends Object
	perobjectconfig
	config(MapLists);


/** Struct for storing extra data within a map entry (implemented like this to maximize flexibility) */
struct PropertyStruct
{
	var name Key;
	var string Value;
};

/** An actual maplist entry, with an array 'ExtraData' which allows flexible association of data with a particular map */
struct MapEntry
{
	var string Map;
	var array<PropertyStruct> ExtraData;
};

var config array<MapEntry> Maps;
var config array<MapEntry> BadMaps;
var config string AutoLoadPrefixes;

var config int LastActiveMapIndex;
var config int MapReplayLimit;

var bool bInitialized;


function Initialize()
{
	local array<string> PrefixList;
	local int i, j;
	local bool bSaveConfig;

	// Only initialize once
	if (bInitialized)
		return;

	`log("MAP LIST WAS INITIALIZED" @ self);

	if (AutoLoadPrefixes != "")
	{
		if (InStr(AutoLoadPrefixes, ",") != INDEX_None)
			ParseStringIntoArray(AutoLoadPrefixes, PrefixList, ",", True);
		else
			PrefixList.AddItem(AutoLoadPrefixes);

		for (i=0; i<PrefixList.Length; ++i)
			PrefixList[i] = TrimWhitespace(PrefixList[i]);

		Class'Rx_MapListManager'.static.PopulateMapListByPrefix(Self, PrefixList, True);
		`log("MAp List is ME: " @ self);
		bSaveConfig = True;
	}


	// Verify all of the maps within the maplist
	for (i=0; i<Maps.Length; ++i)
	{
		// For some reason, spaces sometimes get added to the map strings in the .ini
		if (!MapExists(Maps[i].Map))
		{
			Maps[i].Map = TrimWhitespace(Maps[i].Map);//replace with functions
			bSaveConfig = True;
		}

		if (!MapExists(Maps[i].Map))
		{
			`log("Map '"$Maps[i].Map$"' can't be found, removing from maplist '"$Name$"'");


			// Move map to a different list, so that maps don't just disappear (e.g. so admins can fix up entries and copy them back))
			j = BadMaps.Length;
			BadMaps.Length = j+1;

			BadMaps[j] = Maps[i];


			Maps.Remove(i--, 1);
			bSaveConfig = True;
		}
	}


	if (bSaveConfig)
		SaveConfig();

	bInitialized = True;
}

// Member access functions

final function string GetMap(int Index)
{
	return Maps[Index].Map;
}

final function SetMap(int Index, string Map, optional bool bPreserveExtraData)
{
	Maps[Index].Map = Map;

	if (!bPreserveExtraData)
		Maps[Index].ExtraData.Length = 0;
}

/** @NOTE: When 'Options' is specified, this function only returns an index if the 'Options' string contains the options within the maplist entry
    this is mainly used with WAR maps that specify link setups */
final function int GetMapIndex(string Map, optional int StartIdx, optional string Options)
{
	local int i, j, BestIdx;

	if (Options == "")
	{
		if (StartIdx == 0)
			return Maps.Find('Map', Map);


		for (i=StartIdx; i<Maps.Length; ++i)
			if (Maps[i].Map ~= Map)
				return i;
	}
	else
	{
		BestIdx = INDEX_None;

		for (i=StartIdx; i<Maps.Length; ++i)
		{
			j = InStr(Maps[i].Map, "?");

			if (j == INDEX_None)
			{
				// If only the map option was matched, then keep searching to see if there is an entry with options
				if (Maps[i].Map ~= Map && BestIdx == INDEX_None)
					BestIdx = i;
			}
			else
			{
				if (Left(Maps[i].Map, j) ~= Map && Class'Rx_MapListManager'.static.ContainsOptions(Options, Mid(Maps[i].Map, j)))
					return i;
			}
		}

		return BestIdx;
	}

	return INDEX_None;
}

final function string GetExtraMapData(int Index, name Key)
{
	local int i;

	i = Maps[Index].ExtraData.Find('Key', Key);

	if (i == INDEX_None)
		return "";

	return Maps[Index].ExtraData[i].Value;
}

final function SetExtraMapData(int Index, name Key, string Value)
{
	local int i;

	i = Maps[Index].ExtraData.Find('Key', Key);

	if (i == INDEX_None)
	{
		i = Maps[Index].ExtraData.Length;
		Maps[Index].ExtraData.Length = i + 1;

		Maps[Index].ExtraData[i].Key = Key;
	}

	Maps[Index].ExtraData[i].Value = Value;
}

final function int GetLastActiveIndex()
{
	if (LastActiveMapIndex >= Maps.Length)
	{
		LastActiveMapIndex = -1;
		SaveConfig();
	}

	return LastActiveMapIndex;
}

final function SetLastActiveIndex(int Index)
{
	if (Index >= Maps.Length || Index < 0)
		return;

	LastActiveMapIndex = Index;
	SaveConfig();
}

final function int GetNextMapIndex(optional int Start=-1)
{
	if (Start != INDEX_None)
	{
		if (++Start >= Maps.Length)
			return 0;

		return Start;
	}

	if (LastActiveMapIndex == -1 || LastActiveMapIndex >= Maps.Length-1)
		return 0;

	return LastActiveMapIndex + 1;
}

//helper functions

/** Trims whitespace from the beginning and end of a string. */
function string TrimWhitespace(string InString)
{
	local int StartIdx;
	local int EndIdx;
	local string FinalString;

	for(StartIdx=0; StartIdx<Len(InString); StartIdx++)
	{
		if(Asc(Mid(InString,StartIdx,1))!=32)
		{
			break;
		}
	}

	for(EndIdx=Len(InString)-1; EndIdx>=0; EndIdx--)
	{
		if(Asc(Mid(InString,EndIdx,1))!=32)
		{
			break;
		}
	}

	if(StartIdx<=EndIdx)
	{
		FinalString=Mid(InString,StartIdx,EndIdx-StartIdx+1);
	}

	return FinalString;
}

final function bool MapExists(string MapName) 
{
	return MapName == Class'WorldInfo'.static.GetWorldInfo().GetURLMap();
}


DefaultProperties
{
}
