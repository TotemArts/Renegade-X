/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class SimpleGame extends FrameworkGame 
	native;

/** 
 * Strips the "play on X" prefixes added to autsaved maps.  
 */
static function string StripPlayOnPrefix( String MapName )
{
	if (Left(MapName, 6) ~= "UEDPIE")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if ( Left(MapName, 5) ~= "UEDPC" )
	{
		return Right(MapName, Len(MapName) - 5);
	}
	else if (Left(MapName, 6) ~= "UEDPS3")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if (Left(MapName, 6) ~= "UED360")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if (Left(MapName, 6) ~= "UEDIOS")
	{
		return Right(MapName, Len(MapName) - 6);
	}

	return MapName;
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	local string NewMapName,GameTypeName,ThisMapPrefix,GameOption;
	local int PrefixIndex, MapPrefixPos,GameTypePrefixPos;
	local class<GameInfo> UTGameType;

	// Let UTGame decide the mode for UT entry maps.
	if (Left(MapName, 9) ~= "EnvyEntry" || Left(MapName, 14) ~= "UDKFrontEndMap" )
	{
		UTGameType = class<GameInfo>(DynamicLoadObject("UTGame.UTGame",class'Class'));
		if( UTGameType != None )
		{
			return UTGameType.static.SetGameType( MapName, Options, Portal );
		}
	}

	// allow commandline to override game type setting
	GameOption = ParseOption( Options, "Game");
	if ( GameOption != "" )
	{
		return Default.class;
	}

	// strip the "play on" prefixes from the filename, if it exists (meaning this is a Play in Editor game)
	NewMapName = StripPlayOnPrefix( MapName );

	// Get the prefix for this map
	MapPrefixPos = InStr(NewMapName,"-");
	ThisMapPrefix = left(NewMapName,MapPrefixPos);

	// Change game type 
	for ( PrefixIndex=0; PrefixIndex<Default.DefaultMapPrefixes.Length; PrefixIndex++ )
	{
		GameTypePrefixPos = InStr(Default.DefaultMapPrefixes[PrefixIndex].GameType ,".");
		GameTypeName = left(Default.DefaultMapPrefixes[PrefixIndex].GameType,GameTypePrefixPos);
		if ( Default.DefaultMapPrefixes[PrefixIndex].Prefix ~= ThisMapPrefix && ( GameTypeName ~= "UTGame" || GameTypeName ~= "UTGameContent" ) )
		{
			// If this is a UTGame type, let UTGame figure out the name
			UTGameType = class<GameInfo>(DynamicLoadObject("UTGame.UTGame",class'Class'));
			if( UTGameType != None )
			{
				return UTGameType.static.SetGameType( MapName, Options, Portal );
			}
		}
	}

	return Default.class;
}

defaultproperties
{
	PlayerControllerClass=class'UDKBase.SimplePC'
	DefaultPawnClass=class'UDKBase.SimplePawn'
	PopulationManagerClass=class'GameFramework.GameCrowdPopulationManager'
	HUDType=class'UDKBase.UDKHUD'
	bRestartLevel=false
	bWaitingToStartMatch=true
	bDelayedStart=false
}


