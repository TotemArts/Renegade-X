/**
 * UDK specific data store base class for online game searches.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKDataStore_GameSearchBase extends UIDataStore_OnlineGameSearch
	native
	abstract;

cpptext
{
	/**
	 * Initializes the dataproviders for all of the various character parts.
	 */
	virtual void InitializeDataStore();
}

/** Reference to the dataprovider that will provide details for a specific search result. */
var transient	UDKUIDataProvider_ServerDetails	ServerDetailsProvider;

/**
 * Registers the delegate with the online subsystem
 */
event Init()
{
	Super.Init();

	// since we have two game search data stores active at the same time, we'll need to register this delegate only when
	// we're actively performing a search..
	if ( GameInterface != None )
	{
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnSearchComplete);
	}
}

/**
 * Called to kick off an online game search and set up all of the delegates needed
 *
 * @param ControllerIndex the ControllerId for the player to perform the search for
 * @param bInvalidateExistingSearchResults	specify FALSE to keep previous searches (i.e. for other gametypes) in memory; default
 *											behavior is to clear all search results when switching to a different item in the game search list
 *
 * @return TRUE if the search call works, FALSE otherwise
 */
event bool SubmitGameSearch(byte ControllerIndex, optional bool bInvalidateExistingSearchResults=true)
{
	local bool bResult;

	// Set the function to call when the search is done
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnSearchComplete);

	bResult = Super.SubmitGameSearch(ControllerIndex, bInvalidateExistingSearchResults);
	if ( !bResult )
	{
		// should never return false, but just to be safe
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnSearchComplete);
	}

	return bResult;
}

/**
 * Called by the online subsystem when the game search has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnSearchComplete(bool bWasSuccessful)
{
	// regardless of whether the query was successful, if we don't have any queries pending, unregister the delegate
	// so that we don't receive callbacks when the other game search data store is performing a query
	if ( !HasOutstandingQueries(true) )
	{
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnSearchComplete);
	}

	Super.OnSearchComplete(bWasSuccessful);
}

/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries( optional bool bRestrictCheckToSelf )
{
	local bool bResult;
	local int i;

	for ( i = 0; i < GameSearchCfgList.Length; i++ )
	{
		if ( GameSearchCfgList[i].Search != None && GameSearchCfgList[i].Search.bIsSearchInProgress )
		{
			bResult = true;
			break;
		}
	}

	return bResult;
}

/**
 * @return	TRUE if the current game search has completed a query.
 */
function bool HasExistingSearchResults()
{
	local bool bQueryCompleted;

	// ok, this is imprecise - we may have already issued a query, but no servers were found...
	// could add a bool
	if ( SelectedIndex >=0 && SelectedIndex < GameSearchCfgList.Length )
	{
		bQueryCompleted = GameSearchCfgList[SelectedIndex].Search.Results.Length > 0;
	}

	return bQueryCompleted;
}

defaultproperties
{
}
