/*********************************************************
*
* File: Rx_MapListManager.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class manages the MapList and provide the map list based on game class that we're playing.
* Copied and modified from UT3 Script Source v1.3 under file UTMapListManager.uc
* It is created and called by Rx_MapListManager.uc.	
*
* 
* 
* NOTE: If you subclass this then don't specify a new config file name, otherwise there will be duplicates of the globalconfig
* properties from here, in your new config file. These duplicates wont be updated when setting up a maplist from the menus,
* because the menus can only update variables for the [RxGame.Rx_MapListManager] section in UDKMapLists.ini.
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/

class Rx_MapListManager extends Info
	config(MapLists);

/** A struct for describing a gametype and it's corresponding settings */
struct GameProfile
{
	/** The game class this profile uses, must be in the format: 'Package.Class' */
	var string GameClass;
	/** The displayed gametype name (e.g "Warfare", "Capture The Flag") */
	var string GameName;
	/** The name of the maplist this gametype uses (maplists are defined in UDKMapLists.ini) */
	var name MapListName;
	/** Added URL options used with this game profile */
	var string Options;
	/** A list of default mutators which are used with this game profile, format: 'Pkg.Class,Pkg2.Class2' */
	var string Mutators;
	/** A list of mutators which are disallowed when playing under this game profile */
	var string ExcludedMuts;
	/** Whether this gametype is a team game (saves loading gametype to find out) */
	var bool bIsTeamGame;

	structdefaultproperties
	{
		bIsTeamGame=true; //err on the side of making team skins
	}
};

/** The list of available game profiles */
var globalconfig array<GameProfile> GameProfiles;

/** The currently active game profile; used to help determine the current map cycle */
var globalconfig string ActiveGameProfileName;

/** A list of URL options which are automatically removed from the URL upon map change */
var globalconfig string AutoStripOptions;

/** The same as 'AutoStripOptions', except these options are given an empty value on the URL */
var globalconfig string AutoEmptyOptions;

/** The index of the current game session, incremented upon map switch (used to keep track of when maps have been played) */
var globalconfig int PlayIndex;

/** After a map has been played, this many matches must pass before the map can be played again */
var globalconfig int MapReplayLimit;


// Runtime variables


/** Cache of loaded maplists */
var array<Rx_MapList> LoadedMapLists;

/** List of maplist names from UDKMapLists.ini which have not been loaded into 'MapListCache' */
var array<string> UnloadedMapLists;

/** If true, 'UnLoadedMapLists' has been filled from UDKMapLists.ini */
var bool bGotMapListSections;

/** Used to help detect bad maps */
var bool bPendingMapChange;

/** Forces the current GameInfo to use the map supplies by this object, instead of e.g. that supplied by the vote collector */
var bool bOverrideNextMap;


/** The currently active maplist for this gametype */
var Rx_MapList ActiveMapList;

/** Runtime copy of the 'GameProfiles' list, so that editing through webadmin doesn't break the code */
var array<GameProfile> AvailableGameProfiles;

/** The currently active game profile; used to determine the current map cycle */
var int ActiveGameProfile;

/** The game profile that was active when the maplist manager was initialized */
var int StartupGameProfile;

/** Mutators added to the URL in 'AddDefaultOptions'; used by 'ModifyOptions' when switching between game profiles */
var array<string> AddedMutators;


function Initialize()
{
	local int CurMapIdx, i;

	// Initialize the runtime copy of 'GameProfiles'
	AvailableGameProfiles.Length = GameProfiles.Length;

	for (i=0; i<GameProfiles.Length; ++i)
		AvailableGameProfiles[i] = GameProfiles[i];


	// Sync ActiveGameProfile with the current game class
	GetCurrentGameProfileIndex();

	StartupGameProfile = ActiveGameProfile;

	// Determine whether or not the current map is the maplists 'active' map, and if not, increment the maps playcount
	if (GetCurrentMapList() != none)
	{
		CurMapIdx = ActiveMapList.GetMapIndex(WorldInfo.GetMapName(True),, WorldInfo.Game.ServerOptions);

		if (CurMapIdx != ActiveMapList.LastActiveMapIndex)
		{
			// Update the play index
			++PlayIndex;

			// Now update the maplist
			if (CurMapIdx != INDEX_None)
			{
				`log("Current map is not the maplist's active map, updating maplist");
				ActiveMapList.SetLastActiveIndex(CurMapIdx);
				UpdateMapHistory(ActiveMapList, CurMapIdx);
			}
			else
			{
				`log("Current map was not found within the active map list");
			}
		}
	}

	SaveConfig();
}

/** Used to retrieve the next map in the cycle (does not modify map history) */
function string GetNextMap(optional Rx_MapList InMapList=ActiveMapList)
{
	local int CurMapIdx, NextMapIdx, i, LastPlayDiff, FallbackIdx;//, FallbackPlayDiff;
	local bool bFound;

	if (InMapList == none)
		InMapList = GetCurrentMapList();

	if (InMapList == none)
		return "";


	CurMapIdx = InMapList.LastActiveMapIndex;
	NextMapIdx = InMapList.GetNextMapIndex();

	// This should only ever happen when the maplist length is 0 (and that shouldn't ever happen)
	if (NextMapIdx >= InMapList.Maps.Length)
		return "";


	// If the next map is disabled, then keep iterating until a selectable one is found
	if (!bMapEnabled(InMapList, NextMapIdx))
	{
		// Iterate all the maps
		i = InMapList.GetNextMapIndex(NextMapIdx);

		while (i != NextMapIdx)
		{
			if (bMapEnabled(InMapList, i) && i != CurMapIdx)
			{
				NextMapIdx = i;
				bFound = True;
				break;
			}

			i = InMapList.GetNextMapIndex(i);
		}

		// No valid map was found, reiterate the list with more leniant checks
		if (!bFound)
		{
			FallbackIdx = INDEX_None;
			i = InMapList.GetNextMapIndex(NextMapIdx);

			while (i != NextMapIdx)
			{
				if (bMapEnabled(InMapList, i, False) && i != CurMapIdx)
				{
					LastPlayDiff = GetMapLastPlayDiff(InMapList, i);

					// If the map has never been played, return immediately
					if (LastPlayDiff == INDEX_None)
					{
						FallbackIdx = i;
						break;
					}

					if (FallbackIdx == INDEX_None)// || LastPlayDiff > FallbackPlayDiff)
					{
						FallbackIdx = i;
						//FallbackPlayDiff = LastPlayDiff;
					}
				}

				i = InMapList.GetNextMapIndex(i);
			}

			// If there are still no valid maps, then just use the next map in the list
			if (FallbackIdx == INDEX_None)
				NextMapIdx = InMapList.GetNextMapIndex();
			else
				NextMapIdx = FallbackIdx;
		}
	}


	return InMapList.GetMap(NextMapIdx);
}

/** Used to track map changes and modify map history, including disabling of maps and playcount tracking etc. */
function NotifyMapChange(string NextMap)
{
	local int CurMapIdx, i;
	local Rx_MapList PendingMaplist;

	++PlayIndex;
	SaveConfig();

	bPendingMapChange = True;


	// Determine what maplist will be in use next game (i.e. when the vote collector changes the active game profile)
	if (ActiveGameProfile != INDEX_None && ActiveGameProfile < AvailableGameProfiles.Length)
		PendingMapList = GetMapListByName(AvailableGameProfiles[ActiveGameProfile].MapListName);

	if (PendingMapList == none)
		PendingMapList = ActiveMapList;

	if (PendingMapList == none)
		return;


	// Check for map options
	i = InStr(NextMap, "?");

	if (i == INDEX_None)
		CurMapIdx = PendingMapList.GetMapIndex(NextMap);
	else
		CurMapIdx = PendingMapList.GetMapIndex(Left(NextMap, i),, Mid(NextMap, i+1));

	if (CurMapIdx == INDEX_None)
		return;

	// Update the stored map info
	UpdateMapHistory(PendingMapList, CurMapIdx);
}

/** Notification used for detecting bad maps */
function NotifyTravelFailed(string TravelURL, string Error, optional string ErrorCode)
{
`if(`notdefined(FINAL_RELEASE))
	local int i;
	local string BadMap;
`endif

	// Don't try to deal with unexpected map changes
	if (!bPendingMapChange)
		return;


`if(`notdefined(FINAL_RELEASE))
	i = InStr(TravelURL, "?");

	if (i == INDEX_None)
		BadMap = TravelURL;
	else
		BadMap = Left(TravelURL, i);

	`log("Travel to '"$BadMap$"' failed, moving on to the next map in list");
`endif


	bOverrideNextMap = True;
	WorldInfo.NextURL = "";
	WorldInfo.Game.bGameRestarted = False;
	WorldInfo.Game.bAlreadyChanged = False;

	WorldInfo.Game.RestartGame();
}


/** Used to add default URL options upon map change, must NOT be used to remove options, as that should be done in ModifyOptions instead */
function string AddDefaultOptions(string CurOptions)
{
	local string MutStr;

	// If there is no active game profile, there are no checks to be made
	if (ActiveGameProfile == INDEX_None)
		return CurOptions;


	// Parse the current game profiles default mutator lists
	MutStr = GetDefaultMutators(ActiveGameProfile);

	// If the list is not empty, parse the mutators and modify the URL
	if (Len(MutStr) > 1)
	{
		ParseStringIntoArray(MutStr, AddedMutators, ",", True);
		ModifyMutatorOptions(CurOptions, AddedMutators);
	}


	return CurOptions;
}

/** Used to alter or remove URL options, after all the default options have been set */
function ModifyOptions(out string CurOptions)
{
	local string MutStr, RemainingOptions, NewOpt, GrabbedOpt;
	local array<string> RemoveMuts, RemoveOptions;
	local int i;

	// Parse the 'AutoStripOptions' list and go through it
	ParseStringIntoArray(AutoStripOptions, RemoveOptions, ",", True);

	for (i=0; i<RemoveOptions.Length; ++i)
		CurOptions = StripOption(CurOptions, RemoveOptions[i]);

	// Now do the same with 'AutoEmptyOptions'
	ParseStringIntoArray(AutoEmptyOptions, RemoveOptions, ",", True);

	for (i=0; i<RemoveOptions.Length; ++i)
		CurOptions = StripOption(CurOptions, RemoveOptions[i], True);


	// If the active game profile is not set, there are no checks to be made
	if (ActiveGameProfile == INDEX_None)
		return;


	// Parse the excluded mutator list for the active game profile
	MutStr = AvailableGameProfiles[ActiveGameProfile].ExcludedMuts;

	if (MutStr != "")
	{
		ParseStringIntoArray(MutStr, RemoveMuts, ",", True);
		ModifyMutatorOptions(CurOptions,, RemoveMuts);
	}


	// If switching between game profiles, disable mutators which were added by the old game profile
	if (StartupGameProfile != INDEX_None && ActiveGameProfile != StartupGameProfile)
	{
		MutStr = GetDefaultMutators(StartupGameProfile);

		if (Len(MutStr) > 1)
		{
			// Strip the newly added mutators (those being added by the new game profile) from the 'RemoveMuts' list
			ParseStringIntoArray(MutStr, RemoveMuts, ",", True);
			RemoveMuts = GetDisabledDefaultMutators(RemoveMuts, AddedMutators);

			if (RemoveMuts.Length > 0)
				ModifyMutatorOptions(CurOptions,, RemoveMuts);
		}
	}


	// Append the game profile's options and game class
	RemainingOptions = StripOption(StripOption(AvailableGameProfiles[ActiveGameProfile].Options, "Mutator"), "Game");

	while (Class'GameInfo'.static.GrabOption(RemainingOptions, NewOpt))
	{
		GrabbedOpt = Left(NewOpt, InStr(NewOpt, "="));

		// Override options which are already present
		if (Class'GameInfo'.static.HasOption(CurOptions, GrabbedOpt))
			CurOptions = StripOption(CurOptions, GrabbedOpt)$"?"$NewOpt;
		else
			CurOptions $= "?"$NewOpt;
	}

	CurOptions = StripOption(CurOptions, "Game")$"?Game="$AvailableGameProfiles[ActiveGameProfile].GameClass;


	// If switching from a non-team gametype into a different gametype, then make sure the teams get rebalanced after travelling
	if (UTTeamGame(WorldInfo.Game) == none && !(PathName(WorldInfo.Game.Class) ~= AvailableGameProfiles[ActiveGameProfile].GameClass))
	{
		Class'Rx_Game'.default.bPlayersBalanceTeams = True;
		Class'Rx_Game'.static.StaticSaveConfig();
	}

	// If going from a non team game to a team game, force non-seamless server travel to fixup team skins
 	if (WorldInfo.Game.bTeamGame != AvailableGameProfiles[ActiveGameProfile].bIsTeamGame)
 	{
 		WorldInfo.Game.bUseSeamlessTravel = false;
  	}
}


// Maplist management functions


/** Returns or creates a maplist with the specified name */
function Rx_MapList GetMapListByName(name MapListName, optional bool bCreate)
{
	local int i;
	local Rx_MapList NewMapList;
	local string sMapList;

	for (i=0; i<LoadedMapLists.Length; ++i)
		if (LoadedMapLists[i].Name == MapListName)
			return LoadedMapLists[i];


	if (!bGotMapListSections)
	{
		GetPerObjectConfigSections(Class'Rx_MapList', UnloadedMapLists);
		bGotMapListSections = True;

		// GetPerObjectConfigSections returns values like so 'ConfigName ClassName'; strip out the class names
		for (i=0; i<UnloadedMapLists.Length; ++i)
			UnloadedMapLists[i] = Left(UnloadedMapLists[i], InStr(UnloadedMapLists[i], " "));
	}

	if (UnloadedMapLists.Length != 0)
	{
		// Check if the desired maplist exists
		sMapList = string(MapListName);
		i = UnloadedMapLists.Find(sMapList);

		// If so, load the maplist and remove its name from 'UnloadedMapLists'
		if (i != INDEX_None)
		{
			UnloadedMapLists.Remove(i, 1);

			NewMapList = new(none, sMapList) Class'Rx_MapList';
			NewMapList.Initialize();
			LoadedMapLists.AddItem(NewMapList);

			return NewMapList;
		}
	}


	// If the maplist has not been found (i.e. doesn't exist yet), then create it
	if (bCreate)
	{
		NewMapList = new(none, sMapList) Class'Rx_MapList';
		NewMapList.Initialize();
		LoadedMapLists.AddItem(NewMapList);

		return NewMapList;
	}


	`log("Unable to find named maplist '"$MapListName$"'");

	return none;
}

/** Static, non-cached version of the above (mainly used by the map selection menus) */
static final function Rx_MapList StaticGetMapListByName(name MapListName, optional bool bCreate)
{
	local Rx_MapList MLObj;
	local array<string> AvailableMapLists;
	local string sMapList;
	local int i;

	sMapList = string(MapListName);


	// If creating a maplist instead of searching for one, return immediately
	if (bCreate)
	{
		MLObj = new(none, sMapList) Class'Rx_MapList';
		MLObj.Initialize();

		return MLObj;
	}


	GetPerObjectConfigSections(Class'Rx_MapList', AvailableMaplists);
	i = AvailableMapLists.Find(sMapList@Class'Rx_MapList'.Name);

	if (i != INDEX_None)
	{
		MLObj = new(none, sMapList) Class'Rx_MapList';
		MLObj.Initialize();

		return MLObj;
	}


	`log("Unable to find named maplist '"$MapListName$"'");

	return none;
}

/** Finds all maps with the specified prefixes, and populates the specified maplist with those maps */
static final function PopulateMapListByPrefix(Rx_MapList MapList, array<string> Prefixes, optional bool bAppend)
{
	local array<UDKUIResourceDataProvider> MapProviders;
	local int i, j, k;
	local string CurMap;

	if (!bAppend)
		MapList.Maps.Length = 0;

	Class'UDKUIDataStore_MenuItems'.static.GetAllResourceDataProviders(Class'UDKUIDataProvider_MapInfo', MapProviders);
	i = MapProviders.Length;

	for (j=0; j<i; ++j)
	{
		CurMap = UTUIDataProvider_MapInfo(MapProviders[j]).MapName;
		k = InStr(CurMap, "-");

		if (k != INDEX_None && Prefixes.Find(Left(CurMap, k)) != INDEX_None && (!bAppend || MapList.GetMapIndex(CurMap) == INDEX_None))
		{
			k = MapList.Maps.Length;
			MapList.Maps.Length = k+1;

			MapList.SetMap(k, CurMap);
		}
	}
}

/** Caches and returns the active game profiles maplist in the 'ActiveMapList' variable */
function Rx_MapList GetCurrentMapList(optional bool bForceUpdate)
{
	local int GameProfileIdx;

	if (!bForceUpdate && ActiveMapList != none)
		return ActiveMapList;


	GameProfileIdx = GetCurrentGameProfileIndex();

	if (GameProfileIdx == INDEX_None)
		return none;


	ActiveMapList = GetMapListByName(AvailableGameProfiles[GameProfileIdx].MapListName);

	return ActiveMapList;
}

/** Returns whether or not the specified map is enabled (i.e. whether or not switching to the map is allowed) */
function bool bMapEnabled(Rx_MapList MapList, int MapIdx, optional bool bStrict=True)
{
	local string CurMapData;
	local int LastPlayDiff, ReplayLimit;

	if (MapList == none || MapIdx >= MapList.Maps.Length)
		return False;


	CurMapData = MapList.GetExtraMapData(MapIdx, 'bDisabled');

	if (CurMapData != "" && bool(CurMapData))
		return False;


	if (bStrict)
	{
		ReplayLimit = (MapList.MapReplayLimit != INDEX_None ? MapList.MapReplayLimit : MapReplayLimit);

		if (ReplayLimit > 0)
		{
			LastPlayDiff = GetMapLastPlayDiff(MapList, MapIdx);

			if (LastPlayDiff != INDEX_None && LastPlayDiff < ReplayLimit)
				return False;
		}
	}


	return True;
}

/** Returns an integer which represents the number of games since the map was last played (or INDEX_None if the map was never played) */
function int GetMapLastPlayDiff(Rx_MapList MapList, int MapIdx)
{
	local string LastPlayIndex;
	local int LastPlayDiff;

	LastPlayIndex = MapList.GetExtraMapData(MapIdx, 'LastPlayIdx');

	if (LastPlayIndex == "")
		return INDEX_None;

	LastPlayDiff = PlayIndex - int(LastPlayIndex);

	if (LastPlayDiff < 0)
		return INDEX_None;

	return LastPlayDiff;
}

/** Updates various per-map values, e.g. the number of times the map has been played */
function UpdateMapHistory(Rx_MapList MapList, int MapIdx)
{
	local int NewPlayCount;

	// Update the maps playcount
	NewPlayCount = int(MapList.GetExtraMapData(MapIdx, 'PlayCount')) + 1;
	MapList.SetExtraMapData(MapIdx, 'PlayCount', string(NewPlayCount));

	MapList.SetExtraMapData(MapIdx, 'LastPlayIdx', string(PlayIndex));

	// Now update the maplists 'last active map' index
	MapList.SetLastActiveIndex(MapIdx);
}

// Game profile helper functions

/** Returns the currently active 'AvailableGameProfile' index (or the best match) */
function int GetCurrentGameProfileIndex()
{
	local string ClassPath;

	ClassPath = PathName(WorldInfo.Game.Class);

	if (ActiveGameProfile == INDEX_None && ActiveGameProfileName != "")
		ActiveGameProfile = AvailableGameProfiles.Find('GameName', ActiveGameProfileName);


	// If 'ActiveGameProfile' is set the respective 'AvailableGameProfiles' entry matches the current gametype, return it's index
	if (ActiveGameProfile != INDEX_None && AvailableGameProfiles[ActiveGameProfile].GameClass == ClassPath)
		return ActiveGameProfile;


	// Otherwise, set 'ActiveGameProfile' to the first gametype in the list which matches this one (or -1 if there are none), and return
	SetCurrentGameProfileIndex(AvailableGameProfiles.Find('GameClass', ClassPath));

	return ActiveGameProfile;
}

/** Static version of the above, for map selection menus */
static final function int StaticGetCurrentGameProfileIndex()
{
	return default.GameProfiles.Find('GameName', default.ActiveGameProfileName);
}

/** Changes the currently active game profile */
function SetCurrentGameProfileIndex(int Idx)
{
	ActiveGameProfile = Idx;

	if (Idx >= 0 && Idx < AvailableGameProfiles.Length)
		ActiveGameProfileName = AvailableGameProfiles[Idx].GameName;
	else
		ActiveGameProfileName = "";

	SaveConfig();
}

/** Find the first game profile with the matching game class */
function int FindGameProfileIndex(string GameClass)
{
	return AvailableGameProfiles.Find('GameClass', GameClass);
}

/** Static version of the above, mainly used by map selection menus */
static final function int StaticFindGameProfileIndex(string GameClass)
{
	return default.GameProfiles.Find('GameClass', GameClass);
}

/** Create and setup values for a new game profile entry (used by map selection menus) */
static final function GameProfile CreateNewGameProfile(string InGameClass, optional string InGameName, optional name InMapListName,
									optional string InOptions, optional string InMutators)
{
	local GameProfile NewProfile;
	local int i;

	NewProfile.GameClass = InGameClass;

	if (InGameName == "")
	{
		i = InStr(InGameClass, ".");

		// Get 'GameName' without actually loading the class
		InGameName = Localize(Mid(InGameClass, i+1), "GameName", Left(InGameClass, i));

		// If localization failed, then just use the game classname
		if (InStr(InGameName, "?"$InGameClass$".GameName?") != INDEX_None)
			InGameName = Mid(InGameClass, i+1);
	}

	NewProfile.GameName = InGameName;
	NewProfile.MapListName = InMapListName;
	NewProfile.Options = InOptions;
	NewProfile.Mutators = InMutators;


	return NewProfile;
}


// URL helper functions

static final function string StripOption(string Options, string InKey, optional bool bAddEmptyValue)
{
	local int i, j;
	local string sTempStr;

ReStrip:

	i = InStr(Caps(Options), "?"$Caps(InKey));

	if (i == INDEX_None)
	{
		if (bAddEmptyValue)
			return Options$"?"$InKey$"=";
		else
			return Options;
	}


	sTempStr = Mid(Options, i+1);
	j = InStr(sTempStr, "?");

	if (j == INDEX_None)
		Options = Left(Options, i);
	else
		Options = Left(Options, i)$Mid(Options, i+j+1);

	goto 'ReStrip';
}

/** Returns true if the options in string A contain all of the options in string B */
static final function bool ContainsOptions(string A, string B)
{
	local int i, j;
	local string Pair;

	if (Left(B, 1) != "?")
		return True;

	if (Left(A, 1) != "?")
		return False;


	// Convert A to caps for use with InStr (which is case-sensitive)
	A = Caps(A);

	while (B != "")
	{
		// Strip out the initial '?'
		B = Mid(B, 1);

		// Find the next '?' and make sure it's not before the next '=' (i.e. if someone types "??Game=Blah.Blah")
		i = InStr(B, "?");
		j = InStr(B, "=");

		if (i < j && i != INDEX_None)
			continue;

		// Grab the key/value pair and search for that within A
		if (i != INDEX_None)
		{
			Pair = Caps(Left(B, i));

			if (Pair == "")
				return True;

			B = Mid(B, i+1);
		}
		else
		{
			Pair = Caps(B);
			B = "";
		}


		if (InStr(A, Pair) == INDEX_None)
			return False;
	}

	return True;
}

/** Parses the value of the "?Mutator=" option in the URL (if any), and adds/removes mutators as specified */
static final function ModifyMutatorOptions(out string CurOptions, optional out const array<string> AddMuts, optional out const array<string> RemoveMuts)
{
	local string MutStr;
	local array<string> MutatorList;
	local int i, j, PreLen;
	local bool bModifiedList;

	// Get the previous URL mutator list
	if (CurOptions != "")
	{
		MutStr = Class'GameInfo'.static.ParseOption(CurOptions, "Mutator");

		if (MutStr != "")
			ParseStringIntoArray(MutStr, MutatorList, ",", True);
	}

	// Iterate the mutator lists and add/remove as appropriate
	for (i=0; i<AddMuts.Length; ++i)
	{
		if (MutatorList.Find(AddMuts[i]) == INDEX_None)
		{
			MutatorList.AddItem(AddMuts[i]);
			bModifiedList = True;
		}
	}

	for (i=0; i<RemoveMuts.Length; ++i)
	{
		j = InStr(RemoveMuts[i], ".");

		// Checks are performed differently, depending upon whether the current RemoveMut entry contains the package name
		if (j != INDEX_None)
		{
			PreLen = MutatorList.Length;
			MutatorList.RemoveItem(RemoveMuts[i]);

			if (MutatorList.Length != PreLen)
				bModifiedList = True;
		}
		else
		{
			for (j=0; j<MutatorList.Length; ++j)
			{
				if (InStr(Caps(MutatorList[j]), "."$Caps(RemoveMuts[i])) != INDEX_None)
				{
					MutatorList.Remove(j--, 1);
					bModifiedList = True;
				}
			}
		}
	}

	// Now reconstruct the mutator list
	if (bModifiedList)
	{
		if (MutatorList.Length != 0)
		{
			MutStr = "?Mutator=";

			for (i=0; i<MutatorList.Length; ++i)
			{
				if (i != 0)
					MutStr $= ",";

				MutStr $= MutatorList[i];
			}
		}
		else
		{
			MutStr = "?Mutator=";
		}

		// Remove the current mutator list, and add the modifed one
		if (CurOptions != "")
			CurOptions = StripOption(CurOptions, "Mutator")$MutStr;
		else
			CurOptions = MutStr;
	}
}

/** Returns the default mutators for a particular game profile */
final function string GetDefaultMutators(int Idx)
{
	local string ReturnStr;

	if (Idx < 0 || Idx >= AvailableGameProfiles.Length)
		return ReturnStr;

	ReturnStr = AvailableGameProfiles[Idx].Mutators;
	ReturnStr $= ","$Class'GameInfo'.static.ParseOption(AvailableGameProfiles[Idx].Options, "Mutator");

	if (ReturnStr == ",")
		return "";


	return ReturnStr;
}

/** Returns the list of default mutators from one game profile, which should be removed when moving to another game profile
 *  (only moved here, due to also being used by the vote code)
 *  @NOTE: Expects both lists to contain the full package and class names */
final function array<string> GetDisabledDefaultMutators(const out array<string> OldDefaults, const out array<string> NewDefaults)
{
	local int i;
	local array<string> ReturnVal;

	for (i=0; i<OldDefaults.Length; ++i)
		if (NewDefaults.Find(OldDefaults[i]) == INDEX_None)
			ReturnVal.AddItem(OldDefaults[i]);

	return ReturnVal;
}



DefaultProperties
{
}
