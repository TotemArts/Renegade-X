//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Rx_GFxFrontEnd_Skirmish extends Rx_GFxFrontEnd_View
    config(Menu);


/************************************
*  Skirmish                         *
************************************/

var Rx_GFXFrontEnd MainFrontEnd;
var GFxClikWidget SkirmishActionBar;

// Skirmish Map
var GFxClikWidget GameModeDropDown;
var GFxClikWidget MapScrollBar;
var GFxClikWidget MapList;
var GFxClikWidget MapSizeLabel;
var GFxClikWidget MapStyleLabel;
var GFxClikWidget MapPlayerCountLabel;
var GFxClikWidget MapHasAirVehiclesLabel;
var GFxClikWidget MapTechBuildingsLabel;
var GFxClikWidget MapBaseDefencesLabel;
var GFxClikWidget MapImageLoader;
var GFxClikWidget GDIBotDropDown;
var GFxClikWidget GDITacticStyleDropDown;
var GFxClikWidget GDIAttackingSlider;
var GFxClikWidget GDIAttackingLabel;
var GFxClikWidget GDIBotSlider;
var GFxClikWidget GDIBotCountLabel;
var GFxClikWidget NodBotDropDown;
var GFxClikWidget NodTacticStyleDropDown;
var GFxClikWidget NodAttackingSlider;
var GFxClikWidget NodAttackingLabel;
var GFxClikWidget NodBotSlider;
var GFxClikWidget NodBotCountLabel;
var GFxClikWidget StartingTeamDropDown;
var GFxClikWidget StartingCreditsSlider;
var GFxClikWidget StartingCreditsLabel;
var GFxClikWidget TimeLimitStepper;
var GFxClikWidget MineLimitStepper;
var GFxClikWidget VehicleLimitStepper;
var GFxClikWidget FriendlyFireCheckBox;
var GFxClikWidget CanRepairBuildingsCheckBox;
var GFxClikWidget BaseDestructionCheckBox;
var GFxClikWidget EndGamePedistalCheckBox;
var GFxClikWidget TimeLimitExpiryCheckBox;


var array<Rx_UIDataProvider_MapInfo> MapDataProviderList;
//Deprecated
struct SkirmishOption
{
    var int LastGDIBotItemPosition;
    var int LastGDITacticStyleItemPosition;
    var int GDIAttackingValue;
    var int GDIBotValue;
    var int LastNodBotItemPosition;
    var int LastNodTacticStyleItemPosition;
    var int NodAttackingValue;
    var int NodBotValue;
    var int LastStartingTeamItemPosition;
	var int StartingCreditsValue;
    var int LastTimeLimitItemPosition;
    var int LastMineLimitItemPosition;
    var int LastVehicleLimitItemPosition;
    var bool bFriendlyFire;
    var bool bCanRepairBuildings;
    var bool bBaseDestruction;
    var bool bEndGamePedistal;
    var bool bTimeLimitExpiry;
};
//Deprecated
//var config array<SkirmishOption> SkirmishMapSettings;
//var SkirmishOption SkirmishMapSettings[8];
var int LastGameModeItemPosition;
var int LastMapListItemPosition;

struct MapOption
{
    var string Filename;
    var string Description;
    var string Size;
    var string Style;
    var string RecommendedPlayers;
    var string AirVehicles;
    var string TechBuildings;
    var string BaseDefences;
	var string MapImage;
};

var config array<int> TimeLimitPresets;
var config array<int> MineLimitPresets;
var config int VehicleLimit;

struct Difficulty
{
    var string Level;
    var string Description;
	var string ButtonText;
};
var config array<Difficulty> Difficulties;

struct TacticStyle
{
    var string Description;
};
var config array<TacticStyle> TacticStyles;

/** Configures the view when it is first loaded. */
function OnViewLoaded(Rx_GFXFrontEnd FrontEnd)
{
	MainFrontEnd = FrontEnd;
	MapDataProviderList = Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList;
	SaveConfig();
    //SaveSkirmishOption();
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch(WidgetName)
    {
		case 'SkirmishActionBar':
			if (SkirmishActionBar == none || SkirmishActionBar != Widget) {
				SkirmishActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SkirmishActionBar);
			SkirmishActionBar.AddEventListener('CLIK_itemClick', OnSkirmishActionBarItemClick);
			break;

        case 'GameModeDropDown':
			if (GameModeDropDown == none || GameModeDropDown != Widget) {
				GameModeDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(GameModeDropDown);
            GetLastSelection(GameModeDropDown);
            GameModeDropDown.AddEventListener('CLIK_change', OnGameModeDropDownChange);
            break;
        case 'MapScrollBar':
			if (MapScrollBar == none || MapScrollBar != Widget) {
				MapScrollBar = GFxClikWidget(Widget);
			}
			MapScrollBar.SetVisible(false);
            break;
        case 'MapImageLoader':
			if (MapImageLoader == none || MapImageLoader != Widget) {
				MapImageLoader = GFxClikWidget(Widget);
			}

			if (MapDataProviderList[LastMapListItemPosition].PreviewImageMarkup != "") {
				MapImageLoader.SetString("source", "img://" $ MapDataProviderList[LastMapListItemPosition].PreviewImageMarkup);
			} else {
				//MapImageLoader.SetString("source", "Mockup_MissingCameo");
				MapImageLoader.SetString("source", "img://RenXFrontEnd.MapImage.___map-pic-missing-cameo");
			}
			break;
        case 'MapList':
			if (MapList == none || MapList != Widget) {
				MapList = GFxClikWidget(Widget);
			}
            SetUpDataProvider(MapList);
            GetLastSelection(MapList);
            MapList.AddEventListener('CLIK_itemClick', OnMapListItemClick);
            break;
        case 'MapSizeLabel':
			if (MapSizeLabel == none || MapSizeLabel != Widget) {
				MapSizeLabel = GFxClikWidget(Widget);
			}
            MapSizeLabel.SetText("Size: " $ MapDataProviderList[LastMapListItemPosition].Size);
            break;
			if (MapImageLoader == none || MapImageLoader != Widget) {
				MapImageLoader = GFxClikWidget(Widget);
			}
        case 'MapStyleLabel':
			if (MapStyleLabel == none || MapStyleLabel != Widget) {
				MapStyleLabel = GFxClikWidget(Widget);
			}
            MapStyleLabel.SetText("Style: " $ MapDataProviderList[LastMapListItemPosition].Style);
            break;
        case 'MapPlayerCountLabel':
			if (MapPlayerCountLabel == none || MapPlayerCountLabel != Widget) {
				MapPlayerCountLabel = GFxClikWidget(Widget);
			}
            MapPlayerCountLabel.SetText("Recommended Players: " $ MapDataProviderList[LastMapListItemPosition].NumPlayers);
            break;
        case 'MapHasAirVehiclesLabel':
			if (MapHasAirVehiclesLabel == none || MapHasAirVehiclesLabel != Widget) {
				MapHasAirVehiclesLabel = GFxClikWidget(Widget);
			}
            MapHasAirVehiclesLabel.SetText("Air Vehicles: " $ MapDataProviderList[LastMapListItemPosition].AirVehicles);
            break;
        case 'MapTechBuildingsLabel':
			if (MapTechBuildingsLabel == none || MapTechBuildingsLabel != Widget) {
				MapTechBuildingsLabel = GFxClikWidget(Widget);
			}
            MapTechBuildingsLabel.SetText("Tech Buildings: " $ MapDataProviderList[LastMapListItemPosition].TechBuildings);
            break;
        case 'MapBaseDefencesLabel':
			if (MapBaseDefencesLabel == none || MapBaseDefencesLabel != Widget) {
				MapBaseDefencesLabel = GFxClikWidget(Widget);
			}
            MapBaseDefencesLabel.SetText("Base Defences: " $ MapDataProviderList[LastMapListItemPosition].BaseDefences);
            break;

        case 'GDIBotDropDown':
			if (GDIBotDropDown == none || GDIBotDropDown != Widget) {
				GDIBotDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(GDIBotDropDown);
            GetLastSelection(GDIBotDropDown);
            GDIBotDropDown.AddEventListener('CLIK_change', OnGDIBotDropDownChange);
            break;
        case 'GDITacticStyleDropDown':
			if (GDITacticStyleDropDown == none || GDITacticStyleDropDown != Widget) {
				GDITacticStyleDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(GDITacticStyleDropDown);
            GetLastSelection(GDITacticStyleDropDown);
            GDITacticStyleDropDown.AddEventListener('CLIK_change', OnGDITacticStyleDropDownChange);
            break;
        case 'GDIAttackingSlider':
			if (GDIAttackingSlider == none || GDIAttackingSlider != Widget) {
				GDIAttackingSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(GDIAttackingSlider);
            GDIAttackingSlider.AddEventListener('CLIK_change', OnGDIAttackingSliderChange);
            break;
        case 'GDIAttackingLabel':
			if (GDIAttackingLabel == none || GDIAttackingLabel != Widget) {
				GDIAttackingLabel = GFxClikWidget(Widget);
			}
            GDIAttackingLabel.SetText(""$ MapDataProviderList[LastMapListItemPosition].GDIAttackingValue $" %");
            break;
        case 'GDIBotSlider':
			if (GDIBotSlider == none || GDIBotSlider != Widget) {
				GDIBotSlider = GFxClikWidget(Widget);
			}
            GDIBotSlider = GFxClikWidget(Widget);
            GetLastSelection(GDIBotSlider);
            GDIBotSlider.AddEventListener('CLIK_change', OnGDIBotSliderChange);
            break;
        case 'GDIBotCountLabel':
			if (GDIBotCountLabel == none || GDIBotCountLabel != Widget) {
				GDIBotCountLabel = GFxClikWidget(Widget);
			}
            GDIBotCountLabel.SetText(MapDataProviderList[LastMapListItemPosition].GDIBotValue);
            break;
        case 'NodBotDropDown':
			if (NodBotDropDown == none || NodBotDropDown != Widget) {
				NodBotDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(NodBotDropDown);
            GetLastSelection(NodBotDropDown);
            NodBotDropDown.AddEventListener('CLIK_change', OnNodBotDropDownChange);
            break;
        case 'NodTacticStyleDropDown':
			if (NodTacticStyleDropDown == none || NodTacticStyleDropDown != Widget) {
				NodTacticStyleDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(NodTacticStyleDropDown);
            GetLastSelection(NodTacticStyleDropDown);
            NodTacticStyleDropDown.AddEventListener('CLIK_change', OnNodTacticStyleDropDownChange);
            break;
        case 'NodAttackingSlider':
			if (NodAttackingSlider == none || NodAttackingSlider != Widget) {
				NodAttackingSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(NodAttackingSlider);
            NodAttackingSlider.AddEventListener('CLIK_change', OnNodAttackingSliderChange);
            break;
        case 'NodAttackingLabel':
			if (NodAttackingLabel == none || NodAttackingLabel != Widget) {
				NodAttackingLabel = GFxClikWidget(Widget);
			}
            NodAttackingLabel.SetText(""$ MapDataProviderList[LastMapListItemPosition].NodAttackingValue $" %" );
            break;
        case 'NodBotSlider':
			if (NodBotSlider == none || NodBotSlider != Widget) {
				NodBotSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(NodBotSlider);
            NodBotSlider.AddEventListener('CLIK_change', OnNodBotSliderChange);
            break;
        case 'NodBotCountLabel':
			if (NodBotCountLabel == none || NodBotCountLabel != Widget) {
				NodBotCountLabel = GFxClikWidget(Widget);
			}
            NodBotCountLabel.SetText(MapDataProviderList[LastMapListItemPosition].NodBotValue);
            break;
        case 'StartingTeamDropDown':
			if (StartingTeamDropDown == none || StartingTeamDropDown != Widget) {
				StartingTeamDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(StartingTeamDropDown);
            GetLastSelection(StartingTeamDropDown);
            StartingTeamDropDown.AddEventListener('CLIK_change', OnStartingTeamDropDownChange);
            break;

        case 'StartingCreditsSlider':
			if (StartingCreditsSlider == none || StartingCreditsSlider != Widget) {
				StartingCreditsSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(StartingCreditsSlider);
            StartingCreditsSlider.AddEventListener('CLIK_change', OnStartingCreditsSliderChange);
            break;
        case 'StartingCreditsLabel':
			if (StartingCreditsLabel == none || StartingCreditsLabel != Widget) {
				StartingCreditsLabel = GFxClikWidget(Widget);
			}
            StartingCreditsLabel.SetText(MapDataProviderList[LastMapListItemPosition].StartingCreditsValue);
            break;
        case 'TimeLimitStepper':
			if (TimeLimitStepper == none || TimeLimitStepper != Widget) {
				TimeLimitStepper = GFxClikWidget(Widget);
			}
            SetUpDataProvider(TimeLimitStepper);
            GetLastSelection(TimeLimitStepper);
            TimeLimitStepper.AddEventListener('CLIK_change', OnTimeLimitStepperChange);
            break;
        case 'MineLimitStepper':
			if (MineLimitStepper == none || MineLimitStepper != Widget) {
				MineLimitStepper = GFxClikWidget(Widget);
			}
            SetUpDataProvider(MineLimitStepper);
            GetLastSelection(MineLimitStepper);
            MineLimitStepper.AddEventListener('CLIK_change', OnMineLimitStepperChange);
            break;
        case 'VehicleLimitStepper':
			if (VehicleLimitStepper == none || VehicleLimitStepper != Widget) {
				VehicleLimitStepper = GFxClikWidget(Widget);
			}
            SetUpDataProvider(VehicleLimitStepper);
            GetLastSelection(VehicleLimitStepper);
            VehicleLimitStepper.AddEventListener('CLIK_change', OnVehicleLimitStepperChange);
            break;
        case 'FriendlyFireCheckBox':
			if (FriendlyFireCheckBox == none || FriendlyFireCheckBox != Widget) {
				FriendlyFireCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(FriendlyFireCheckBox);
            FriendlyFireCheckBox.AddEventListener('CLIK_select', OnFriendlyFireCheckBoxSelect);
            break;
        case 'CanRepairBuildingsCheckBox':
			if (CanRepairBuildingsCheckBox == none || CanRepairBuildingsCheckBox != Widget) {
				CanRepairBuildingsCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(CanRepairBuildingsCheckBox);
            CanRepairBuildingsCheckBox.AddEventListener('CLIK_select', OnCanRepairBuildingsCheckBoxSelect);
            break;
        case 'BaseDestructionCheckBox':
			if (BaseDestructionCheckBox == none || BaseDestructionCheckBox != Widget) {
				BaseDestructionCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(BaseDestructionCheckBox);
            BaseDestructionCheckBox.AddEventListener('CLIK_select', OnBaseDestructionCheckBoxSelect);
            break;
        case 'EndGamePedistalCheckBox':
			if (EndGamePedistalCheckBox == none || EndGamePedistalCheckBox != Widget) {
				EndGamePedistalCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(EndGamePedistalCheckBox);
            EndGamePedistalCheckBox.AddEventListener('CLIK_select', OnEndGamePedistalCheckBoxSelect);
            break;
        case 'TimeLimitExpiryCheckBox':
			if (TimeLimitExpiryCheckBox == none || TimeLimitExpiryCheckBox != Widget) {
				TimeLimitExpiryCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(TimeLimitExpiryCheckBox);
            TimeLimitExpiryCheckBox.AddEventListener('CLIK_select', OnTimeLimitExpiryCheckBoxSelect);
            break;
        default:
            break;
    }
    return false;
}


/** Populates dropdowns, selection lists, and button groups with appropriate data **/
function SetUpDataProvider(GFxClikWidget Widget)
{
    local byte i;
    local GFxObject DataProvider;

    DataProvider = CreateArray();
	
    switch(Widget)
    {
        /************************************
        *  Skirmish                         *
        ************************************/
        case (SkirmishActionBar):
            DataProvider.SetElementString(0, "BACK");
            DataProvider.SetElementString(1, "LAUNCH");
            break; 

        case (GameModeDropDown):
            DataProvider.SetElementString(0, Caps("Command & Conquer"));
            //DataProvider.SetElementString(1, "C&C Assault");
            break;
        case (MapList):
			Widget.SetInt("rowCount", 12);
            if (GameModeDropDown != none) {
                if (LastGameModeItemPosition == 0) {
                    for (i = 0; i < Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList.Length; i++) {
						
						`log("Name - " $ MapDataProviderList[i].FriendlyName);
                        DataProvider.SetElementString(i, MapDataProviderList[i].FriendlyName);
                    }
                }
            } else {
                if (LastGameModeItemPosition == 0) {
                    for (i = 0; i < MapDataProviderList.Length; i++) {
                        DataProvider.SetElementString(i, MapDataProviderList[i].FriendlyName);
                    }
                }
            }
			if (MapDataProviderList.Length > 12) {
				if (MapScrollBar != none) {
					MapScrollBar.SetVisible(true);
				}
			} else {
				Widget.SetInt("rowCount", MapDataProviderList.Length);
			}

            break;

        case (GDIBotDropDown):
            for (i = 0; i < Difficulties.Length; i++) {
                DataProvider.SetElementString(i, Difficulties[i].Level);
            }
            break;
        case (GDITacticStyleDropDown):
            for (i = 0; i < TacticStyles.Length; i++) {
                DataProvider.SetElementString(i, TacticStyles[i].Description);
            }
            break;
        case (NodBotDropDown):
            for (i = 0; i < Difficulties.Length; i++) {
                DataProvider.SetElementString(i, Difficulties[i].Level);
            }
            break;
        case (NodTacticStyleDropDown):
            for (i = 0; i < TacticStyles.Length; i++) {
                DataProvider.SetElementString(i, TacticStyles[i].Description);
            }
            break;
        case (StartingTeamDropDown):
            DataProvider.SetElementString(0, "GDI");
            DataProvider.SetElementString(1, "Nod");
            DataProvider.SetElementString(2, "RANDOM");
            break;

        case (TimeLimitStepper):
        	for (i=0;i<TimeLimitPresets.length; i++) {
				if (i < TimeLimitPresets.Length - 1) {
        			DataProvider.SetElementString(i, "" $TimeLimitPresets[i] $" MINUTES");
				} else {
					DataProvider.setelementstring(i, "NO TIME LIMIT");
				}
        	}
            break;
        case (MineLimitStepper):
        	for (i=0;i<MineLimitPresets.length; i++) {
        		DataProvider.SetElementString(i, "" $MineLimitPresets[i]);
        	}
            break;
        case (VehicleLimitStepper):
        	for (i=0;i<=VehicleLimit-7; i++) {
        		DataProvider.SetElementString(i, ""$i+7);
        	}
            break;
        default:
			`log("[Rx_GFxFrontEnd_Skirmish]: widget: " $ Widget.GetString("_name"));
            return;
    }
    Widget.SetObject("dataProvider", DataProvider);
}

function GetLastSelection(out GFxClikWidget Widget)
{
	
    switch (Widget)
    {
        case (GameModeDropDown):
        	Widget.SetInt("selectedIndex", LastGameModeItemPosition);
            break;
        case (MapList):
        	Widget.SetInt("selectedIndex", LastMapListItemPosition);
            break;
        case (GDIBotDropDown):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastGDIBotItemPosition);
            break;
        case (GDITacticStyleDropDown):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastGDITacticStyleItemPosition);
            break;
        case (GDIAttackingSlider):
        	Widget.SetInt("value", MapDataProviderList[LastMapListItemPosition].GDIAttackingValue);
        	break;

        case (GDIBotSlider):
            if (MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition == 0) {
                //set the GDI slider value from 0 to 31
                MapDataProviderList[LastMapListItemPosition].GDIBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].GDIBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
                Widget.SetInt("value", MapDataProviderList[LastMapListItemPosition].GDIBotValue);
            } else {
                MapDataProviderList[LastMapListItemPosition].GDIBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].GDIBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
                Widget.SetInt("value", MapDataProviderList[LastMapListItemPosition].GDIBotValue);
            }
        	break;
        case (NodBotDropDown):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastNodBotItemPosition);
        	break;
        case (NodTacticStyleDropDown):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastNodTacticStyleItemPosition);
        	break;
        case (NodAttackingSlider):
        	Widget.SetInt("value", MapDataProviderList[LastMapListItemPosition].NodAttackingValue);
        	break;
        case (NodBotSlider):
            if (MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition == 0) {
                //set the GDI slider value from 0 to 31
                MapDataProviderList[LastMapListItemPosition].NodBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].NodBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
                Widget.SetInt("value", MapDataProviderList[LastMapListItemPosition].NodBotValue);
            } else {
                MapDataProviderList[LastMapListItemPosition].NodBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].NodBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
                Widget.SetInt("value", MapDataProviderList[LastMapListItemPosition].NodBotValue);
            }
        	break;
        case (StartingTeamDropDown):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition);
        	break;
        case (StartingCreditsSlider):
        	Widget.SetInt("value", MapDataProviderList[LastMapListItemPosition].StartingCreditsValue);
        	break;
        case (TimeLimitStepper):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastTimeLimitItemPosition);
        	break;
        case (MineLimitStepper):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastMineLimitItemPosition);
        	break;
        case (VehicleLimitStepper):
        	Widget.SetInt("selectedIndex", MapDataProviderList[LastMapListItemPosition].LastVehicleLimitItemPosition);
        	break;
        case (FriendlyFireCheckBox):
        	Widget.SetBool("selected", MapDataProviderList[LastMapListItemPosition].bFriendlyFire);
        	break;
        case (CanRepairBuildingsCheckBox):
        	Widget.SetBool("selected", MapDataProviderList[LastMapListItemPosition].bCanRepairBuildings);
        	break;
        case (BaseDestructionCheckBox):
        	Widget.SetBool("selected", MapDataProviderList[LastMapListItemPosition].bBaseDestruction);
        	break;
        case (EndGamePedistalCheckBox):
        	Widget.SetBool("selected", MapDataProviderList[LastMapListItemPosition].bEndGamePedistal);
        	break;
        case (TimeLimitExpiryCheckBox):
        	Widget.SetBool("selected", MapDataProviderList[LastMapListItemPosition].bTimeLimitExpiry);
        	break;
        default:
            return;
    }
}

function SaveSkirmishOption()
{
	
}

/** Loads the selected map **/
function LaunchSkirmishGame()
{
    local string OutURL;
	local Rx_UIDataProvider_MapInfo SelectedMap;

	SelectedMap = MapDataProviderList[LastMapListItemPosition];
	
	
	if (SelectedMap.LastStartingTeamItemPosition == 2) {
		SelectedMap.LastStartingTeamItemPosition = Rand(2);
	}
	SelectedMap.SavePerObjectConfig();


	
	
    //and finally...
	
	if(MapPackageHasDayNight(SelectedMap.MapName)) //OutURL=PickDayorNight(SelectedMap.MapName)//Make an exception for Day/Night Maps
	
	{
		OutURL =  ""$ PickDayorNight(SelectedMap.MapName)
                $"?Team=" $ SelectedMap.LastStartingTeamItemPosition
                $"?Numplay=" $ (SelectedMap.GDIBotValue + SelectedMap.NodBotValue)
                //$"?Difficulty=" $BotDifficulty
                $"?GDIBotCount=" $ SelectedMap.GDIBotValue - (SelectedMap.LastStartingTeamItemPosition == 0 ? 1 : 0)
                $"?NODBotCount=" $ SelectedMap.NodBotValue - (SelectedMap.LastStartingTeamItemPosition == 1 ? 1 : 0)
                $"?GDIDifficulty=" $ SelectedMap.LastGDIBotItemPosition
                $"?NODDifficulty=" $ SelectedMap.LastNodBotItemPosition
                $"?GDIAttackingStrengh=" $ SelectedMap.GDIAttackingValue
                $"?NodAttackingStrengh=" $ SelectedMap.NodAttackingValue
				$"?StartingCredits=" $ SelectedMap.StartingCreditsValue
                $"?TimeLimit=" $TimeLimitPresets[SelectedMap.LastTimeLimitItemPosition]
                $"?MineLimit=" $MineLimitPresets[SelectedMap.LastMineLimitItemPosition]
                $"?VehicleLimit=" $ SelectedMap.LastVehicleLimitItemPosition + 7
                $"?IsFriendlyfire=" $ SelectedMap.bFriendlyFire
                $"?CanRepairBuildings=" $ SelectedMap.bCanRepairBuildings
                $"?HasBaseDestruction=" $ SelectedMap.bBaseDestruction
                $"?HasEndGamePedistal=" $ SelectedMap.bEndGamePedistal
                $"?HasTimeLimitExpiry=" $ SelectedMap.bTimeLimitExpiry;
	}
	else
	{
    OutURL =  ""$ SelectedMap.MapName
                $"?Team=" $ SelectedMap.LastStartingTeamItemPosition
                $"?Numplay=" $ (SelectedMap.GDIBotValue + SelectedMap.NodBotValue)
                //$"?Difficulty=" $BotDifficulty
                $"?GDIBotCount=" $ SelectedMap.GDIBotValue - (SelectedMap.LastStartingTeamItemPosition == 0 ? 1 : 0)
                $"?NODBotCount=" $ SelectedMap.NodBotValue - (SelectedMap.LastStartingTeamItemPosition == 1 ? 1 : 0)
                $"?GDIDifficulty=" $ SelectedMap.LastGDIBotItemPosition
                $"?NODDifficulty=" $ SelectedMap.LastNodBotItemPosition
                $"?GDIAttackingStrengh=" $ SelectedMap.GDIAttackingValue
                $"?NodAttackingStrengh=" $ SelectedMap.NodAttackingValue
				$"?StartingCredits=" $ SelectedMap.StartingCreditsValue
                $"?TimeLimit=" $TimeLimitPresets[SelectedMap.LastTimeLimitItemPosition]
                $"?MineLimit=" $MineLimitPresets[SelectedMap.LastMineLimitItemPosition]
                $"?VehicleLimit=" $ SelectedMap.LastVehicleLimitItemPosition + 7
                $"?IsFriendlyfire=" $ SelectedMap.bFriendlyFire
                $"?CanRepairBuildings=" $ SelectedMap.bCanRepairBuildings
                $"?HasBaseDestruction=" $ SelectedMap.bBaseDestruction
                $"?HasEndGamePedistal=" $ SelectedMap.bEndGamePedistal
                $"?HasTimeLimitExpiry=" $ SelectedMap.bTimeLimitExpiry;
	}
	//Last second, see if this selected map has a day/night variant, and randomly choose one.
	
	`log("OutURL is: " @  Right(OutURL,Len(OutURL)-1) @ MapPackageHasDayNight( Right(OutURL,1))) ; 
	
	
				
				
	`log("Command: ->> " @ "open " $ OutURL);
    ConsoleCommand("open " @ OutURL);
}



//=============================================================================
//   Rx_GFxFrontEnd_Skirmish event Listener Callbacks
//=============================================================================

function OnSkirmishActionBarItemClick(GFxClikWidget.EventData ev)
{
    switch (ev.index)
    {
      case 0: MainFrontEnd.ReturnToBackground(); break;
      case 1: LaunchSkirmishGame(); break;
      default: break;
    }
}


function OnGameModeDropDownChange(GFxClikWidget.EventData ev)
{
    MapList.RemoveAllEventListeners("CLIK_itemClick");
	LastGameModeItemPosition = ev.index;
    SetUpDataProvider(MapList);
    MapList.AddEventListener('CLIK_itemClick', OnMapListItemClick);

}

function OnMapListItemClick(GFxClikWidget.EventData ev)
{

    if (ev.index == Clamp(ev.index, 0, MapDataProviderList.Length)) {	
		
		if (MapDataProviderList[ev.index].PreviewImageMarkup != "") {
			MapImageLoader.SetString("source", "img://" $ MapDataProviderList[ev.index].PreviewImageMarkup);
		} else {
			MapImageLoader.SetString("source", "img://RenXFrontEnd.MapImage.___map-pic-missing-cameo");
		}
        MapSizeLabel.SetText("Size: "$ MapDataProviderList[ev.index].Size);
        MapStyleLabel.SetText("Style: "$ MapDataProviderList[ev.index].Style);
        MapPlayerCountLabel.SetText("Recommended Players: "$ MapDataProviderList[ev.index].NumPlayers);
        MapHasAirVehiclesLabel.SetText("Air Vehicles: "$ MapDataProviderList[ev.index].AirVehicles);
        MapTechBuildingsLabel.SetText("Tech Buildings: "$ MapDataProviderList[ev.index].TechBuildings);
        MapBaseDefencesLabel.SetText("Base Defences: "$ MapDataProviderList[ev.index].BaseDefences);
	    LastMapListItemPosition = ev.index;
    } else {
		MapImageLoader.SetString("source", "img://RenXFrontEnd.MapImage.___map-pic-missing-cameo");
        MapSizeLabel.SetText("Size: Unknown");
        MapStyleLabel.SetText("Style: Unknown");
        MapPlayerCountLabel.SetText("Recommended Players: Unknown");
        MapHasAirVehiclesLabel.SetText("Air Vehicles: Unknown");
        MapTechBuildingsLabel.SetText("Tech Buildings: Unknown");
        MapBaseDefencesLabel.SetText("Base Defences: Unknown");
	    LastMapListItemPosition = 0;
    }
}


function OnGDIBotDropDownChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].LastGDIBotItemPosition = ev.index;
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}

function OnGDITacticStyleDropDownChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].LastGDITacticStyleItemPosition = ev.index;
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}

function OnGDIAttackingSliderChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].GDIAttackingValue = ev.target.GetInt("value");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
    GDIAttackingLabel.SetString("text", ""$ev.target.GetInt("value") $" %");


}
function OnGDIBotSliderChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].GDIBotValue = ev.target.GetInt("value");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
    GDIBotCountLabel.SetString("text", ""$ev.target.GetInt("value"));
// 	if (MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition == 0 && MapDataProviderList[LastMapListItemPosition].GDIBotValue == 16){
// 		MapDataProviderList[LastMapListItemPosition].GDIBotValue = 15;
// 	}
}

function OnNodBotDropDownChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].LastNodBotItemPosition = ev.index;
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnNodTacticStyleDropDownChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].LastNodTacticStyleItemPosition = ev.index;
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnNodAttackingSliderChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].NodAttackingValue = ev.target.GetInt("value");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
    NodAttackingLabel.SetString("text", ""$ev.target.GetInt("value") $" %");
}
function OnNodBotSliderChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].NodBotValue = ev.target.GetInt("value");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
    NODBotCountLabel.SetString("text", ""$ev.target.GetInt("value"));
// 	if (MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition == 1 && MapDataProviderList[LastMapListItemPosition].NodBotValue == 16) {
// 		MapDataProviderList[LastMapListItemPosition].NodBotValue = 15;
// 	}
}


function OnStartingTeamDropDownChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition = ev.index;

    if (ev.index == 0) {
        //set the GDI slider value from 0 to 15
        MapDataProviderList[LastMapListItemPosition].GDIBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].GDIBotValue, 0, 15);
        GDIBotSlider.SetInt("value", MapDataProviderList[LastMapListItemPosition].GDIBotValue);
        GDIBotCountLabel.SetText(""$ MapDataProviderList[LastMapListItemPosition].GDIBotValue);
        // set the Nod slider value from 1 to 16
        MapDataProviderList[LastMapListItemPosition].NodBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].NodBotValue, 1, 16);
        NodBotSlider.SetInt("value", MapDataProviderList[LastMapListItemPosition].NodBotValue);
        NodBotCountLabel.SetText(""$ MapDataProviderList[LastMapListItemPosition].NodBotValue);
    } else if (ev.index == 1) {
        //set the Nod slider value from 0 to 15
        MapDataProviderList[LastMapListItemPosition].NodBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].NodBotValue, 0, 15);
        NodBotSlider.SetInt("value", MapDataProviderList[LastMapListItemPosition].NodBotValue);
        NodBotCountLabel.SetText("" $ MapDataProviderList[LastMapListItemPosition].NodBotValue);
        // set the GDI slider value from 1 to 16
        MapDataProviderList[LastMapListItemPosition].GDIBotValue = Clamp(MapDataProviderList[LastMapListItemPosition].GDIBotValue, 1, 16);
        GDIBotSlider.SetInt("value", MapDataProviderList[LastMapListItemPosition].GDIBotValue);
        GDIBotCountLabel.SetText(""$ MapDataProviderList[LastMapListItemPosition].GDIBotValue);
    } else {
		//MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition = Rand(1);
    }
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnStartingCreditsSliderChange (GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].StartingCreditsValue = ev.target.GetInt("value");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
    StartingCreditsLabel.SetString("text", ""$ev.target.GetInt("value"));
}
function OnTimeLimitStepperChange(GFxClikWidget.EventData ev)
{
	// if the player choose the infinite settings, set up the logic to implement the correct work on it.
	MapDataProviderList[LastMapListItemPosition].LastTimeLimitItemPosition = ev.target.GetInt("selectedIndex");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnMineLimitStepperChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].LastMineLimitItemPosition = ev.target.GetInt("selectedIndex");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnVehicleLimitStepperChange(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].LastVehicleLimitItemPosition = ev.target.GetInt("selectedIndex");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}

function OnFriendlyFireCheckBoxSelect(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].bFriendlyFire = ev._this.GetBool("selected");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnCanRepairBuildingsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].bCanRepairBuildings = ev._this.GetBool("selected");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnBaseDestructionCheckBoxSelect(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].bBaseDestruction = ev._this.GetBool("selected");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnEndGamePedistalCheckBoxSelect(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].bEndGamePedistal = ev._this.GetBool("selected");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnTimeLimitExpiryCheckBoxSelect(GFxClikWidget.EventData ev)
{
	MapDataProviderList[LastMapListItemPosition].bTimeLimitExpiry = ev._this.GetBool("selected");
	MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}

function bool MapPackageHasDayNight (string ThePackage)
{
	`log("Package: " @ caps(ThePackage));
	return 
	caps(ThePackage) == "CNC-MESA_II" ||
	caps(ThePackage) == "CNC-FIELD"  ||	
	caps(ThePackage) == "CNC-CANYON" ; 
	
}

function string PickDayorNight(string BasePackageName)
{
	local int DorN;
	
	DorN=rand(3);
	
	`log("Random Seed was: " @ DorN) ;
		
	if(DorN > 0) return BasePackageName$"_Day" ;
	else
	return BasePackageName$"_Night";
	
		return BasePackageName; //Incase for some reason this gets called out of place.
	
}

DefaultProperties
{
	
	SubWidgetBindings.Add((WidgetName="SkirmishActionBar",WidgetClass=class'GFxClikWidget'))

    SubWidgetBindings.Add((WidgetName="GameModeDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapScrollBar",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapImageLoader",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapList",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapSizeLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapStyleLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapPlayerCountLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapHasAirVehiclesLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapTechBuildingsLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MapBaseDefencesLabel",WidgetClass=class'GFxClikWidget'))

    SubWidgetBindings.Add((WidgetName="GDIBotDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="GDITacticStyleDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="GDIAttackingSlider",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="GDIAttackingLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="GDIBotSlider",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="GDIBotCountLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="NodBotDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="NodTacticStyleDropDown",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="NodAttackingSlider",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="NodAttackingLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="NodBotSlider",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="NodBotCountLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="StartingTeamDropDown",WidgetClass=class'GFxClikWidget'))

    SubWidgetBindings.Add((WidgetName="StartingCreditsSlider",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="StartingCreditsLabel",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="TimeLimitStepper",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="MineLimitStepper",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="VehicleLimitStepper",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="FriendlyFireCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="CanRepairBuildingsCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="BaseDestructionCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="EndGamePedistalCheckBox",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="TimeLimitExpiryCheckBox",WidgetClass=class'GFxClikWidget'))
}