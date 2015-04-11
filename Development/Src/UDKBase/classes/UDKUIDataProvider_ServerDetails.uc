/**
 * Dataprovider that gives a key/value list of details for a server given its search result row.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKUIDataProvider_ServerDetails extends UDKUIDataProvider_SimpleElementProvider
	native;

cpptext
{
public:
	/**
	 * Determines whether the specified field should be included when the user requests to see a list of this server's details.
	 */
	static UBOOL ShouldDisplayField( FName FieldName );
}

/** Provider that has server information. */
var transient int	SearchResultsRow;

DefaultProperties
{
}
