/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Performs custom game searches, with configurable gametype filters etc.
 * NOTE: This class only works with OnlineSubsystemSteamworks
 * NOTE: Previously this code made use of FilterQuery, but FilterQuery is not capable of multiple comparisons on the same value, so it's not used
 */
Class UTGameSearchCustom extends UTGameSearchDM;


/** Represents an OR filter parameter, which is pending inclusion in the filter list */
struct PendingORFilter
{
	var string				Id;
	var EOnlineGameSearchEntryType		Type;
	var EOnlineGameSearchComparisonType	Operator;
	var string				Value;

	// If true, Type is ignored, and the Id string is used as the raw filter key
	var bool				bRawFilter;
};

/** Represents an AND filter, which is pending inclusion in the filter list, and is referenced by name while setting up the list */
struct PendingANDFilter
{
	var array<PendingORFilter>	ORFilters;
	var name			GroupName;
};

/**
 * The list of filters pending inclusion into the filter list
 * NOTE: The structure of this list is slightly confusing; all OR filters have to placed within AND filters, e.g:
 * (Key1==Value1 || Key2==Value2) && (Key3==Value3 || Key4==Value4)
 */
var array<PendingANDFilter> PendingFilters;


/**
 * Sets up an AND filter (which contains a collection of OR filters), and associates a name with it;
 * after the full filter list is setup, this must be committed to the filter list using CommitFilters
 *
 * @param GroupName	The name to associate with this AND filter, and its group of OR parameters
 * @return		The name used for referencing this AND filter, if no name was specified
 */
function name AddANDFilter(optional name GroupName)
{
	local int i;

	if (GroupName == 'none')
		GroupName = name("PendingFilter"$PendingFilters.Length);

	if (PendingFilters.Find('GroupName', GroupName) == INDEX_None)
	{
		i = PendingFilters.Length;
		PendingFilters.Length = i+1;

		PendingFilters[i].GroupName = GroupName;
	}

	return GroupName;
}

/**
 * Sets up an OR filter, and adds it to a particular AND filter;
 * after the full filter list is setup, this must be committed to the filter list using CommitFilters
 *
 * @param GroupName		The AND filter this OR filter will become a part of
 * @param FilterId		The id of the filter to be added (corresponds to EntryId, as used in FilterQuery)
 * @param FilterType		The type of filter which id is mapped to (corresponds to EntryType, as used in FilterQuery)
 * @param FilterOperator	The operator to use for comparing the filter specified by id, against FilterValue
 * @param FilterValue		The value to compare against
 */
function AddORFilter(name GroupName, coerce string FilterId, EOnlineGameSearchEntryType FilterType,
			EOnlineGameSearchComparisonType FilterOperator, coerce string FilterValue)
{
	local int i, j;

	i = PendingFilters.Find('GroupName', GroupName);

	if (i == INDEX_None)
	{
		`log("UTGameSearchCustom: Group name '"$GroupName$"' does not exist in PendingFilters list");
		return;
	}


	j = PendingFilters[i].ORFilters.Length;
	PendingFilters[i].ORFilters.Length = j+1;

	PendingFilters[i].ORFilters[j].Id = FilterId;
	PendingFilters[i].ORFilters[j].Type = FilterType;
	PendingFilters[i].ORFilters[j].Operator = FilterOperator;
	PendingFilters[i].ORFilters[j].Value = FilterValue;
}

/**
 * Sets up an OR filter, with the key specified by a raw string instead of id/type mapping, and adds it to a particular AND filter;
 * after the full filter list is setup, this must be committed to the filter list using CommitFilters
 *
 * @param GroupName		The AND filter this OR filter will become a part of
 * @param FilterKey		The raw filter key to use for comparison
 * @param FilterOperator	The operator to use for comparing the key specified by FilterKey, against FilterValue
 * @param FilterValue		The value to compare against
 */
function AddRawORFilter(name GroupName, coerce string FilterKey, EOnlineGameSearchComparisonType FilterOperator, coerce string FilterValue)
{
	local int i, j;

	i = PendingFilters.Find('GroupName', GroupName);

	if (i == INDEX_None)
	{
		`log("UTGameSearchCustom: Group name '"$GroupName$"' does not exist in PendingFilters list");
		return;
	}


	j = PendingFilters[i].ORFilters.Length;
	PendingFilters[i].ORFilters.Length = j+1;

	PendingFilters[i].ORFilters[j].Id = FilterKey;
	PendingFilters[i].ORFilters[j].Operator = FilterOperator;
	PendingFilters[i].ORFilters[j].Value = FilterValue;
	PendingFilters[i].ORFilters[j].bRawFilter = True;
}


/**
 * Commits all pending filters to the filter list, adding them to AdditionalSearchCriteria
 */
function CommitFilters()
{
	local PendingORFilter CurORFilter;
	local int i, j;

	// Format of AdditionalSearchCriteria, for OnlineSubsystemSteamworks:
	//	(OrParameters)&&(OrParameters)&&(OrParameters)
	//	NOTE: All OR parameters, MUST be encased with brackets; you can only use && outside of brackets
	// Format of OrParameters:
	//	Key1==Value1||Key2!=Value2 etc.
	//	NOTE: There must be no brackets; you can only use || operators inside the brackets
	// Full example:
	//	(Key1==Value1||Key2>Value2)&&(Key3!=Value3||Key4<Value4)

	// Iterate the AND filters
	for (i=0; i<PendingFilters.Length; i++)
	{
		// Skip empty filters
		if (PendingFilters[i].ORFilters.Length == 0)
			continue;


		if (AdditionalSearchCriteria != "")
			AdditionalSearchCriteria $= "&&";

		AdditionalSearchCriteria $= "(";

		// Iterate the OR filters
		foreach PendingFilters[i].OrFilters(CurORFilter, j)
		{
			if (j != 0)
				AdditionalSearchCriteria $= "||";


			// Put in the filter name
			if (CurORFilter.bRawFilter)
				AdditionalSearchCriteria $= CurORFilter.Id;
			else
				AdditionalSearchCriteria $= GetFilterPropertyName(CurORFilter.Id, CurORFilter.Type);

			// Now the operator
			switch (CurORFilter.Operator)
			{
			case OGSCT_Equals:
				AdditionalSearchCriteria $= "==";
				break;

			case OGSCT_NotEquals:
				AdditionalSearchCriteria $= "!=";
				break;

			case OGSCT_GreaterThan:
				AdditionalSearchCriteria $= ">";
				break;

			case OGSCT_GreaterThanEquals:
				AdditionalSearchCriteria $= ">=";
				break;

			case OGSCT_LessThan:
				AdditionalSearchCriteria $= "<";
				break;

			case OGSCT_LessThanEquals:
				AdditionalSearchCriteria $= "<=";
				break;

			default:
				AdditionalSearchCriteria $= "==";
				break;
			}


			// Then the value
			AdditionalSearchCriteria $= CurORFilter.Value;
		}

		AdditionalSearchCriteria $= ")";
	}

	`log("Committed AdditionalSearchCriteria:"@AdditionalSearchCriteria,, 'DevNet');
}

/**
 * Resets the game search object back to its default state, removing all added filters (but retaining those from default properties)
 */
function ResetFilters()
{
	AdditionalSearchCriteria = default.AdditionalSearchCriteria;
	PendingFilters.Length = 0;
}


// ===== Helper functions

/**
 * Returns the raw name of filter property keys, as they are formatted by the internal OnlineSubsystem code
 */
function string GetFilterPropertyName(string FilterId, EOnlineGameSearchEntryType FilterType)
{
	switch (FilterType)
	{
	case OGSET_Property:
		return "p"$FilterId;

	case OGSET_LocalizedSetting:
		return "s"$FilterId;

	case OGSET_ObjectProperty:
		return FilterId;
	}

	return "";
}


defaultproperties
{
	// Wipe the game class to disable inbuilt game class filtering
	GameClass=""

	// NOTE: If you add modifications of these filters, then remove them from FilterQuery altogether, so that it will work nicely with
	//		advanced filters (in cases where you need to do multiple different comparisons on the same id/key)
	FilterQuery={
	(
		OrClauses=
		(
			(
				OrParams=((EntryId=CONTEXT_PURESERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))
			),
			(
				OrParams=((EntryId=CONTEXT_LOCKEDSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))
			),
			(
				OrParams=((EntryId=CONTEXT_ALLOWKEYBOARD,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))
			),
			(
				OrParams=((EntryId=CONTEXT_FULLSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))
			),
			(
				OrParams=((EntryId=CONTEXT_EMPTYSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))
			),
			(
				OrParams=((EntryId=CONTEXT_DEDICATEDSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))
			)
		)
	)}
}

