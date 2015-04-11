/**
 * Inherited version of the game resource datastore that has UT specific dataproviders.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKUIDataStore_MenuItems extends UIDataStore_GameResource
	native
	Config(Game);
	
var class<UDKUIDataProvider_MapInfo> MapInfoDataProviderClass;

cpptext
{
	/**
	 * Finds or creates the UIResourceDataProvider instances referenced by ElementProviderTypes, and stores the result
	 * into the ListElementProvider map.
	 */
	virtual void InitializeListElementProviders();

protected:
	/**
	 * Sorts the list of map and mutator data providers according to whether they're official or not, then alphabetically.
	 */
	void SortRelevantProviders();

public:
}

/** Array of enabled mutators, the available mutators list will not contain any of these mutators. */
var array<int> EnabledMutators;

/** Array of maps, the available maps list will not contain any of these maps. */
var array<int> MapCycle;

/** Priority listing of the weapons, index 0 being highest priority. */
var array<int> WeaponPriority;

/** finds all UIResourceDataProvider objects defined in all .ini files in the game's config directory
 * static and script exposed to allow access to map/mutator/gametype/weapon lists outside of the menus
 */
native static final function GetAllResourceDataProviders(class<UDKUIResourceDataProvider> ProviderClass, out array<UDKUIResourceDataProvider> Providers);

/** 
 * Attempts to retrieve all providers with the specified provider field name.
 *
 * @param ProviderFieldName		Name of the provider set to search for
 * @param OutProviders			A set of providers with the given name
 * 
 * @return	TRUE if the set was found, FALSE otherwise.
 */
native function bool GetProviderSet(name ProviderFieldName, out array<UDKUIResourceDataProvider> OutProviders);

/**
 * Finds or creates the UIResourceDataProvider instances referenced by ElementProviderTypes, and stores the result
 * into the ListElementProvider map.
 * Script event called after C++ version has created base map
 */
event InitializeListElementProviders()
{
	local array<UDKUIResourceDataProvider> WeaponProviders;
	local UDKUIResourceDataProvider Provider;
	local int WeaponIdx;

	// Generate DropDownWeapons provider set
	GetProviderSet('Weapons', WeaponProviders);
	RemoveListElementProvidersKey('DropDownWeapons');

	for( WeaponIdx=0; WeaponIdx<WeaponProviders.Length; WeaponIdx++ )
	{
		Provider = WeaponProviders[WeaponIdx];

		if( Provider != None )
		{
			AddListElementProvidersKey('DropDownWeapons', Provider);
		}
	}
}

/**
  * Remove key from ListElementProviders multimap
  */
native function RemoveListElementProvidersKey(Name KeyName);

/**
  * Add to ListElementProviders multimap
  */
native function AddListElementProvidersKey(Name KeyName, UDKUIResourceDataProvider Provider);

DefaultProperties
{
	Tag=UDKMenuItems
	MapInfoDataProviderClass=class'UDKUIDataProvider_MapInfo'
}
