/**
 * Rx_UIDataProvider_MapInfo
 *     Provides data for a Rx Map
 * */
class Rx_UIDataProvider_MapInfo extends UTUIDataProvider_MapInfo
	PerObjectConfig;

/**
 * Inherited data
 *  MapId
 *  MapName
 *  NumPlayers (RecommendedPlayers)
 *  Description
 *  PreviewImageMarkup (mapImageFilename) (MapImage)
 * */

/**
 * Data to be considered
 *  MineLimit
 *  VehicleLimit
 *  MapAlias (friendly name) (description)
 *  Size
 *  Style
 *  AirVehicles
 *  TechBuildings
 *  BaseDefences
 * */


var config int MineLimit;
var config int VehicleLimit;

/** Friendly displayable name to the player. */
//var config string FriendlyName;

var config string Size;
var config string Style;
var config string AirVehicles;
var config int TechBuildings;
var config string BaseDefences;

/** Override to support out prefix
 *  @return Returns whether or not this provider is supported by the current game mode */
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
		ThisMapPrefix = "CNC";
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

DefaultProperties
{
}
