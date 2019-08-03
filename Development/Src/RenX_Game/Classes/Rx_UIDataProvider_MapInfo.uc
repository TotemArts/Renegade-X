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

var config int MinNumPlayers;
var config int MineLimit;
var config int VehicleLimit;

/** Friendly displayable name to the player. */
//var config string FriendlyName;

var config string Size;
var config string Style;
var config string AirVehicles;
var config int TechBuildings;
var config string BaseDefences;

//skirmish settings
var config int LastGDIBotItemPosition;
var config int LastGDITacticStyleItemPosition;
var config int GDIAttackingValue;
var config int GDIBotValue;
var config int LastNodBotItemPosition;
var config int LastNodTacticStyleItemPosition;
var config int NodAttackingValue;
var config int NodBotValue;
var config int LastStartingTeamItemPosition;
var config int StartingCreditsValue;
var config int LastTimeLimitItemPosition;
var config int LastMineLimitItemPosition;
var config int LastVehicleLimitItemPosition;
var config bool bFriendlyFire;
var config bool bCanRepairBuildings;
var config bool bBaseDestruction;
var config bool bEndGamePedistal;
var config bool bTimeLimitExpiry;

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

function SavePerObjectConfig()
{
// 	local Rx_UIDataProvider_MapInfo data;
// 	local Object  TempObj;
// 	
// 
// 	TempObj = new(none, "CNC-LOL9GAG") Class'Package'; // I need to do this so that the data provider is written to the correct package
// 	data = new(TempObj, "CNC-KISSMYASS") Class'Rx_UIDataProvider_MapInfo';
// 
// 	//data = new(self, "CNC-LOL9GAG") class'Rx_UIDataProvider_MapInfo';
// 
// 
// 	data.MineLimit = self.MineLimit;
// 	data.VehicleLimit = self.VehicleLimit;
// 	//data.MapName = self.MapName;
// 	//data.NumPlayers = self.NumPlayers;
// 	//data.Description = self.Description;
// 	//data.PreviewImageMarkup = self.PreviewImageMarkup;
// 	//data.FriendlyName = self.FriendlyName;
// 	data.Size = self.Size;
// 	data.Style = self.Style;
// 	data.AirVehicles = self.AirVehicles;
// 	data.TechBuildings = self.TechBuildings;
// 	data.BaseDefences = self.BaseDefences;
// 	data.LastGDIBotItemPosition = self.LastGDIBotItemPosition;
// 	data.LastGDITacticStyleItemPosition = self.LastGDITacticStyleItemPosition;
// 	data.GDIAttackingValue = self.GDIAttackingValue;
// 	data.GDIBotValue = self.GDIBotValue;
// 	data.LastNodBotItemPosition = self.LastNodBotItemPosition;
// 	data.LastNodTacticStyleItemPosition = self.LastNodTacticStyleItemPosition;
// 	data.NodAttackingValue = self.NodAttackingValue;
// 	data.NodBotValue = self.NodBotValue;
// 	data.LastStartingTeamItemPosition = self.LastStartingTeamItemPosition;
// 	data.StartingCreditsValue = self.StartingCreditsValue;
// 	data.LastTimeLimitItemPosition = self.LastTimeLimitItemPosition;
// 	data.LastMineLimitItemPosition = self.LastMineLimitItemPosition;
// 	data.LastVehicleLimitItemPosition = self.LastVehicleLimitItemPosition;
// 	data.bFriendlyFire = self.bFriendlyFire;
// 	data.bCanRepairBuildings = self.bCanRepairBuildings;
// 	data.bBaseDestruction = self.bBaseDestruction;
// 	data.bEndGamePedistal = self.bEndGamePedistal;
// 	data.bTimeLimitExpiry = self.bTimeLimitExpiry;
// 
// 	data.SaveConfig();

	//SaveConfig();
}
DefaultProperties
{
}
