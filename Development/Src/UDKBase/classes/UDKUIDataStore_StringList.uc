/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class UDKUIDataStore_StringList extends UIDataStore_StringBase
	config(Game)
	native
	transient;

const INVALIDFIELD=-1;

struct native EStringListData
{
	/** the tag used for binding this data to a list cell */
	var name Tag;

	/** the string to use as the column header for cells bound to this field */
	var	localized string ColumnHeaderText;

	/** the currently selected value from the Strings array */
	var string CurrentValue;

	/** the index into the Strings array for the element that should be selected by default */
	var int DefaultValueIndex;

	/** the available value choices */
	var localized array<string> Strings;

	/** provider for the list of strings associated with this tag */
	var transient UDKUIDataProvider_StringArray	DataProvider;
};

var config array<EStringListData> StringData;

/**
 * Called when this data store is added to the data store manager's list of active data stores.
 *
 * @param	PlayerOwner		the player that will be associated with this DataStore.  Only relevant if this data store is
 *							associated with a particular player; NULL if this is a global data store.
 */
event Registered( LocalPlayer PlayerOwner )
{
	local int FieldIdx;

	Super.Registered(PlayerOwner);

	// Go through all of the config defined string items and set the default value string.
	for(FieldIdx=0; FieldIdx<StringData.length; FieldIdx++)
	{
		if(StringData[FieldIdx].Strings.length > StringData[FieldIdx].DefaultValueIndex && StringData[FieldIdx].DefaultValueIndex >= 0)
		{
			StringData[FieldIdx].CurrentValue = StringData[FieldIdx].Strings[StringData[FieldIdx].DefaultValueIndex];
		}
	}
}

/**
 * @param FieldName		Name of the String List to find
 * @return the index of a string list
 */
native function INT GetFieldIndex(Name FieldName);

/**
 * Remove a string from the list
 *
 * @Param FieldName		The string list to work on
 * @Param StringToRemove 	The string to remove
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function RemoveStr(name FieldName, string StringToRemove, optional bool bBatchOp);

/**
 * Remove a string (or multiple strings) by the index.
 *
 * @Param FieldName		The string list to work on
 * @Param Index			The index to remove
 * @Param Count			<Optional> # of strings to remove
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function RemoveStrByIndex(name FieldName, int Index, optional int Count=1, optional bool bBatchOp);

/**
 * Empty a string List
 *
 * @Param FieldName		The string list to work on
 * @param bBatchOp		if TRUE, doesn't call RefreshSubscribers()
 */
native function Empty(name FieldName, optional bool bBatchOp);

/**
 * Finds a string in the list
 *
 * @Param FieldName		The string list to add the new string to
 * @Param SearchStr		The string to find
 *
 * @returns the index in the list or INVALIDFIELD
 */
native function INT FindStr(name FieldName, string SearchString);

/**
 * Returns the a string by the index
 *
 * @Param FieldName		The string list to add the new string to
 * @Param StrIndex		The index of the string to get
 *
 * @returns the string.
 */
native function string GetStr(name FieldName, int StrIndex);

/**
 * Returns the current value of a field.
 *
 * @param FieldName		Field to search.
 * @param out_Value		Variable to store the result string in.
 *
 * @return TRUE if the field was found, FLASE otherwise.
 */
event bool GetCurrentValue(name FieldName, out string out_Value)
{
	local bool Result;
	local int FieldIndex;

	Result = FALSE;

	FieldIndex = GetFieldIndex(FieldName);

	if(FieldIndex!=INDEX_NONE)
	{
		Result = TRUE;
		out_Value = StringData[FieldIndex].CurrentValue;
	}

	return Result;
}

/**
 * Returns the current value index of a given field.
 *
 * @param FieldName		Field to search.
 */
event int GetCurrentValueIndex(name FieldName)
{
	local int Result;
	local int FieldIndex;

	Result = INDEX_NONE;

	FieldIndex = GetFieldIndex(FieldName);

	if(FieldIndex!=INDEX_NONE)
	{
		Result = FindStr(FieldName, StringData[FieldIndex].CurrentValue);
	}

	return Result;
}

/**
 * Sets the current value index of a given field.
 *
 * @param FieldName		Field to change.
 * @param int			NewValueIndex
 */
event int SetCurrentValueIndex(name FieldName, int NewValueIndex)
{
	local int Result;
	local int FieldIndex;

	Result = INDEX_NONE;

	FieldIndex = GetFieldIndex(FieldName);

	if(FieldIndex!=INDEX_NONE && StringData[FieldIndex].Strings.length > NewValueIndex)
	{
		StringData[FieldIndex].CurrentValue = StringData[FieldIndex].Strings[NewValueIndex];
	}

	//@fixme - should we call refresh subscribers here?
	return Result;
}

/**
 * Get the number of strings in a given list
 *
 * @Param FieldName		The string list to work on
 * @returns the # of strings or -1 if the list does not exist
 */
event int Num(name FieldName)
{
	local int FieldIndex;
	FieldIndex = GetFieldIndex(FieldName);
	if ( FieldIndex > INDEX_NONE )  // Found it, add the string
	{
		return StringData[FieldIndex].Strings.Length;
	}

	return -1;
}

defaultproperties
{
	Tag=UTStringList
}
