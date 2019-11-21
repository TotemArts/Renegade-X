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
var array<Rx_UIDataProvider_MapInfo> AvailableMapDataProviders;

var Rx_UIDataProvider_MapInfo SkirmishMapSettings;

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

struct GameModeInfo
{
    var string Prefix;
    var string GameModeName;
};

var config array<GameModeInfo> GameModes;
var array <GameModeInfo> AvailableGameModes;


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
    GetAvailableGameModes();
    GetAvailableMapDataProviders();
	SkirmishMapSettings =  AvailableMapDataProviders[0];

	SaveConfig();
    //SaveSkirmishOption();
	ActionScriptVoid("validateNow");
}

function GetAvailableGameModes()
{
    local int i,j;

    for(j = 0; j < GameModes.Length; j++)
    {
        for (i = 0; i < MapDataProviderList.Length; i++) 
        {
            if(Mid(MapDataProviderList[i].MapName,0,Len(GameModes[j].Prefix)) ~= GameModes[j].Prefix)
            {
                AvailableGameModes.AddItem(GameModes[j]);
                break;
            }
        } 
    }      
}

function GetAvailableMapDataProviders()
{
    local int i;

    for (i = 0; i < MapDataProviderList.Length; i++) 
    {
        if(Mid(MapDataProviderList[i].MapName,0,Len(AvailableGameModes[LastGameModeItemPosition].Prefix)) ~= AvailableGameModes[LastGameModeItemPosition].Prefix)
        {
            AvailableMapDataProviders.AddItem(MapDataProviderList[i]);
        }
    }   
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;

	`log("Rx_GFxFrontEnd_Skirmish::WidgetInitialized"@`showvar(WidgetName),true,'DevGFxUI');

	bWasHandled = false;

    switch(WidgetName)
    {
		case 'SkirmishActionBar':
			if (SkirmishActionBar == none || SkirmishActionBar != Widget) {
				SkirmishActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(SkirmishActionBar);
			SkirmishActionBar.AddEventListener('CLIK_buttonClick', OnSkirmishActionBarItemClick);
			bWasHandled = true;
			break;

        case 'GameModeDropDown':
			if (GameModeDropDown == none || GameModeDropDown != Widget) {
				GameModeDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(GameModeDropDown);
            GetLastSelection(GameModeDropDown);
            GameModeDropDown.AddEventListener('CLIK_change', OnGameModeDropDownChange);
			bWasHandled = true;
            break;
        case 'MapScrollBar':
			if (MapScrollBar == none || MapScrollBar != Widget) {
				MapScrollBar = GFxClikWidget(Widget);
			}
			//MapScrollBar.SetVisible(false);
			bWasHandled = true;
            break;
        case 'MapImageLoader':
			if (MapImageLoader == none || MapImageLoader != Widget) {
				MapImageLoader = GFxClikWidget(Widget);
			}

			if (AvailableMapDataProviders[LastMapListItemPosition].PreviewImageMarkup != "") {
				MapImageLoader.SetString("source", "img://" $ AvailableMapDataProviders[LastMapListItemPosition].PreviewImageMarkup);
			} 
            else 
            {
				//MapImageLoader.SetString("source", "Mockup_MissingCameo");
				MapImageLoader.SetString("source", "img://RenXFrontEnd.MapImage.___map-pic-missing-cameo");
			}
			bWasHandled = true;
			break;
        case 'MapList':
			if (MapList == none || MapList != Widget) {
				MapList = GFxClikWidget(Widget);
			}
            SetUpDataProvider(MapList);
            GetLastSelection(MapList);
            MapList.AddEventListener('CLIK_listIndexChange', OnMapListItemClick);
			bWasHandled = true;
            break;
        case 'MapSizeLabel':
			if (MapSizeLabel == none || MapSizeLabel != Widget) {
				MapSizeLabel = GFxClikWidget(Widget);
			}
            MapSizeLabel.SetText("Size: " $ AvailableMapDataProviders[LastMapListItemPosition].Size);
			bWasHandled = true;
            break;
			if (MapImageLoader == none || MapImageLoader != Widget) {
				MapImageLoader = GFxClikWidget(Widget);
			}
        case 'MapStyleLabel':
			if (MapStyleLabel == none || MapStyleLabel != Widget) {
				MapStyleLabel = GFxClikWidget(Widget);
			}
            MapStyleLabel.SetText("Style: " $ AvailableMapDataProviders[LastMapListItemPosition].Style);
			bWasHandled = true;
            break;
        case 'MapPlayerCountLabel':
			if (MapPlayerCountLabel == none || MapPlayerCountLabel != Widget) {
				MapPlayerCountLabel = GFxClikWidget(Widget);
			}
            MapPlayerCountLabel.SetText("Recommended Players: " $ AvailableMapDataProviders[LastMapListItemPosition].NumPlayers);
			bWasHandled = true;
            break;
        case 'MapHasAirVehiclesLabel':
			if (MapHasAirVehiclesLabel == none || MapHasAirVehiclesLabel != Widget) {
				MapHasAirVehiclesLabel = GFxClikWidget(Widget);
			}
            MapHasAirVehiclesLabel.SetText("Air Vehicles: " $ AvailableMapDataProviders[LastMapListItemPosition].AirVehicles);
			bWasHandled = true;
            break;
        case 'MapTechBuildingsLabel':
			if (MapTechBuildingsLabel == none || MapTechBuildingsLabel != Widget) {
				MapTechBuildingsLabel = GFxClikWidget(Widget);
			}
            MapTechBuildingsLabel.SetText("Tech Buildings: " $ AvailableMapDataProviders[LastMapListItemPosition].TechBuildings);
			bWasHandled = true;
            break;
        case 'MapBaseDefencesLabel':
			if (MapBaseDefencesLabel == none || MapBaseDefencesLabel != Widget) {
				MapBaseDefencesLabel = GFxClikWidget(Widget);
			}
            MapBaseDefencesLabel.SetText("Base Defences: " $ AvailableMapDataProviders[LastMapListItemPosition].BaseDefences);
			bWasHandled = true;
            break;

        case 'GDIBotDropDown': 
			if (GDIBotDropDown == none || GDIBotDropDown != Widget) {
				GDIBotDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(GDIBotDropDown);
            GetLastSelection(GDIBotDropDown);
            GDIBotDropDown.AddEventListener('CLIK_change', OnGDIBotDropDownChange);
			bWasHandled = true;
            break;
        case 'GDITacticStyleDropDown':
			if (GDITacticStyleDropDown == none || GDITacticStyleDropDown != Widget) {
				GDITacticStyleDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(GDITacticStyleDropDown);
            GetLastSelection(GDITacticStyleDropDown);
            GDITacticStyleDropDown.AddEventListener('CLIK_change', OnGDITacticStyleDropDownChange);
			bWasHandled = true;
            break;
        case 'GDIAttackingSlider':
			if (GDIAttackingSlider == none || GDIAttackingSlider != Widget) {
				GDIAttackingSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(GDIAttackingSlider);
            GDIAttackingSlider.AddEventListener('CLIK_valueChange', OnGDIAttackingSliderChange);
			bWasHandled = true;
            break;
        case 'GDIAttackingLabel':
			if (GDIAttackingLabel == none || GDIAttackingLabel != Widget) {
				GDIAttackingLabel = GFxClikWidget(Widget);
			}
            GDIAttackingLabel.SetText(""$ AvailableMapDataProviders[LastMapListItemPosition].GDIAttackingValue $" %");
			bWasHandled = true;
            break;
        case 'GDIBotSlider':
			if (GDIBotSlider == none || GDIBotSlider != Widget) {
				GDIBotSlider = GFxClikWidget(Widget);
			}
            GDIBotSlider = GFxClikWidget(Widget);
            GetLastSelection(GDIBotSlider);
            GDIBotSlider.AddEventListener('CLIK_valueChange', OnGDIBotSliderChange);
			bWasHandled = true;
            break;
        case 'GDIBotCountLabel':
			if (GDIBotCountLabel == none || GDIBotCountLabel != Widget) {
				GDIBotCountLabel = GFxClikWidget(Widget);
			}
            GDIBotCountLabel.SetText(AvailableMapDataProviders[LastMapListItemPosition].GDIBotValue);
			bWasHandled = true;
            break;
        case 'NodBotDropDown':
			if (NodBotDropDown == none || NodBotDropDown != Widget) {
				NodBotDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(NodBotDropDown);
            GetLastSelection(NodBotDropDown);
            NodBotDropDown.AddEventListener('CLIK_change', OnNodBotDropDownChange);
			bWasHandled = true;
            break;
        case 'NodTacticStyleDropDown':
			if (NodTacticStyleDropDown == none || NodTacticStyleDropDown != Widget) {
				NodTacticStyleDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(NodTacticStyleDropDown);
            GetLastSelection(NodTacticStyleDropDown);
            NodTacticStyleDropDown.AddEventListener('CLIK_change', OnNodTacticStyleDropDownChange);
			bWasHandled = true;
            break;
        case 'NodAttackingSlider':
			if (NodAttackingSlider == none || NodAttackingSlider != Widget) {
				NodAttackingSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(NodAttackingSlider);
            NodAttackingSlider.AddEventListener('CLIK_valueChange', OnNodAttackingSliderChange);
			bWasHandled = true;
            break;
        case 'NodAttackingLabel':
			if (NodAttackingLabel == none || NodAttackingLabel != Widget) {
				NodAttackingLabel = GFxClikWidget(Widget);
			}
            NodAttackingLabel.SetText(""$ AvailableMapDataProviders[LastMapListItemPosition].NodAttackingValue $" %" );
			bWasHandled = true;
            break;
        case 'NodBotSlider':
			if (NodBotSlider == none || NodBotSlider != Widget) {
				NodBotSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(NodBotSlider);
            NodBotSlider.AddEventListener('CLIK_valueChange', OnNodBotSliderChange);
			bWasHandled = true;
            break;
        case 'NodBotCountLabel':
			if (NodBotCountLabel == none || NodBotCountLabel != Widget) {
				NodBotCountLabel = GFxClikWidget(Widget);
			}
            NodBotCountLabel.SetText(AvailableMapDataProviders[LastMapListItemPosition].NodBotValue);
			bWasHandled = true;
            break;
        case 'StartingTeamDropDown':
			if (StartingTeamDropDown == none || StartingTeamDropDown != Widget) {
				StartingTeamDropDown = GFxClikWidget(Widget);
			}
            SetUpDataProvider(StartingTeamDropDown);
            GetLastSelection(StartingTeamDropDown);
            StartingTeamDropDown.AddEventListener('CLIK_change', OnStartingTeamDropDownChange);
			bWasHandled = true;
            break;

        case 'StartingCreditsSlider':
			if (StartingCreditsSlider == none || StartingCreditsSlider != Widget) {
				StartingCreditsSlider = GFxClikWidget(Widget);
			}
            GetLastSelection(StartingCreditsSlider);
            StartingCreditsSlider.AddEventListener('CLIK_valueChange', OnStartingCreditsSliderChange);
			bWasHandled = true;
            break;
        case 'StartingCreditsLabel':
			if (StartingCreditsLabel == none || StartingCreditsLabel != Widget) {
				StartingCreditsLabel = GFxClikWidget(Widget);
			}
            StartingCreditsLabel.SetText(AvailableMapDataProviders[LastMapListItemPosition].StartingCreditsValue);
			bWasHandled = true;
            break;
        case 'TimeLimitStepper':
			if (TimeLimitStepper == none || TimeLimitStepper != Widget) {
				TimeLimitStepper = GFxClikWidget(Widget);
			}
            SetUpDataProvider(TimeLimitStepper);
            GetLastSelection(TimeLimitStepper);
            TimeLimitStepper.AddEventListener('CLIK_change', OnTimeLimitStepperChange);
			bWasHandled = true;
            break;
        case 'MineLimitStepper':
			if (MineLimitStepper == none || MineLimitStepper != Widget) {
				MineLimitStepper = GFxClikWidget(Widget);
			}
            SetUpDataProvider(MineLimitStepper);
            GetLastSelection(MineLimitStepper);
            MineLimitStepper.AddEventListener('CLIK_change', OnMineLimitStepperChange);
			bWasHandled = true;
            break;
        case 'VehicleLimitStepper':
			if (VehicleLimitStepper == none || VehicleLimitStepper != Widget) {
				VehicleLimitStepper = GFxClikWidget(Widget);
			}
            SetUpDataProvider(VehicleLimitStepper);
            GetLastSelection(VehicleLimitStepper);
            VehicleLimitStepper.AddEventListener('CLIK_change', OnVehicleLimitStepperChange);
			bWasHandled = true;
            break;
        case 'FriendlyFireCheckBox':
			if (FriendlyFireCheckBox == none || FriendlyFireCheckBox != Widget) {
				FriendlyFireCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(FriendlyFireCheckBox);
            FriendlyFireCheckBox.AddEventListener('CLIK_select', OnFriendlyFireCheckBoxSelect);
			bWasHandled = true;
            break;
        case 'CanRepairBuildingsCheckBox':
			if (CanRepairBuildingsCheckBox == none || CanRepairBuildingsCheckBox != Widget) {
				CanRepairBuildingsCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(CanRepairBuildingsCheckBox);
            CanRepairBuildingsCheckBox.AddEventListener('CLIK_select', OnCanRepairBuildingsCheckBoxSelect);
			bWasHandled = true;
            break;
        case 'BaseDestructionCheckBox':
			if (BaseDestructionCheckBox == none || BaseDestructionCheckBox != Widget) {
				BaseDestructionCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(BaseDestructionCheckBox);
            BaseDestructionCheckBox.AddEventListener('CLIK_select', OnBaseDestructionCheckBoxSelect);
			bWasHandled = true;
            break;
        case 'EndGamePedistalCheckBox':
			if (EndGamePedistalCheckBox == none || EndGamePedistalCheckBox != Widget) {
				EndGamePedistalCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(EndGamePedistalCheckBox);
            EndGamePedistalCheckBox.AddEventListener('CLIK_select', OnEndGamePedistalCheckBoxSelect);
			bWasHandled = true;
            break;
        case 'TimeLimitExpiryCheckBox':
			if (TimeLimitExpiryCheckBox == none || TimeLimitExpiryCheckBox != Widget) {
				TimeLimitExpiryCheckBox = GFxClikWidget(Widget);
			}
            GetLastSelection(TimeLimitExpiryCheckBox);
            TimeLimitExpiryCheckBox.AddEventListener('CLIK_select', OnTimeLimitExpiryCheckBoxSelect);
			bWasHandled = true;
            break;
        default:
            break;
    }
    return bWasHandled;
}


/** Populates dropdowns, selection lists, and button groups with appropriate data **/
function SetUpDataProvider(GFxClikWidget Widget)
{
    local byte i, j, k;
    local GFxObject DataProvider;
	local GFxObject TempObj;

	`log("Rx_GFxFrontEnd_Skirmish::SetupDataProvider"@Widget.GetString("name"),true,'DevGFxUI');

    DataProvider = CreateObject("scaleform.clik.data.DataProvider");
	
    switch(Widget)
    {
        /************************************
        *  Skirmish                         *
        ************************************/
        case (SkirmishActionBar):
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "BACK");
			TempObj.SetString("action", "back");
			DataProvider.SetElementObject(0, TempObj);
			TempObj = CreateObject("Object");
			TempObj.SetString("label", "LAUNCH");
			TempObj.SetString("action", "launch");
			DataProvider.SetElementObject(1, TempObj);
            break; 

        case (GameModeDropDown):
            k = 0;

            if(AvailableGameModes.Length <= 0)
            {
                for(i = 0; i < GameModes.Length; i++)
                {
                    for (j = 0; j < MapDataProviderList.Length; j++) 
                    {
                        if(Mid(MapDataProviderList[j].MapName,0,Len(GameModes[i].Prefix)) ~= GameModes[i].Prefix)
                        {
                            DataProvider.SetElementString(k, Caps(GameModes[i].GameModeName));
                            k++;
                            break;
                        }
                    }
                }
            }
            else
            {
                for(i = 0; i < AvailableGameModes.Length; i++)
                {
                    DataProvider.SetElementString(i, Caps(AvailableGameModes[i].GameModeName));
                }                
            }
            //DataProvider.SetElementString(1, "C&C Assault");
            break;
        case (MapList):
			Widget.SetInt("rowCount", 11);
            j = 0;
            AvailableMapDataProviders.Length = 0;

            if (GameModeDropDown != none) 
            {            
                for (i = 0; i < MapDataProviderList.Length; i++) 
                {
                    if(Mid(MapDataProviderList[i].MapName,0,Len(AvailableGameModes[LastGameModeItemPosition].Prefix)) ~= AvailableGameModes[LastGameModeItemPosition].Prefix)
                    {
                        AvailableMapDataProviders.AddItem(MapDataProviderList[i]);
				        `log("Name - " $ MapDataProviderList[i].FriendlyName);
                        DataProvider.SetElementString(j, MapDataProviderList[i].FriendlyName);                       
                        j++;
                    }
                }            
            } 
            else 
            {                
                for (i = 0; i < MapDataProviderList.Length; i++) 
                {
                    if(Mid(MapDataProviderList[i].MapName,0,Len(AvailableGameModes[LastGameModeItemPosition].Prefix)) ~= AvailableGameModes[LastGameModeItemPosition].Prefix)
                    {
                        AvailableMapDataProviders.AddItem(MapDataProviderList[i]);
                        `log("Name - " $ MapDataProviderList[i].FriendlyName);
                        DataProvider.SetElementString(j, MapDataProviderList[i].FriendlyName);
                        j++;
                    }
                }
            }
			if (j > 12) 
            {
				if (MapScrollBar != none) 
                {
					MapScrollBar.SetVisible(true);
				}
			} 
            else 
            {
				Widget.SetInt("rowCount", j);
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
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastGDIBotItemPosition);
            break;
        case (GDITacticStyleDropDown):
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastGDITacticStyleItemPosition);
            break;
        case (GDIAttackingSlider):
        	Widget.SetInt("value", SkirmishMapSettings.GDIAttackingValue);
        	break;

        case (GDIBotSlider):
            if (SkirmishMapSettings.LastStartingTeamItemPosition == 0) {
                //set the GDI slider value from 0 to 31
                SkirmishMapSettings.GDIBotValue = Clamp(SkirmishMapSettings.GDIBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				SkirmishMapSettings.SavePerObjectConfig();
                Widget.SetInt("value", SkirmishMapSettings.GDIBotValue);
            } else {
                SkirmishMapSettings.GDIBotValue = Clamp(SkirmishMapSettings.GDIBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				SkirmishMapSettings.SavePerObjectConfig();
                Widget.SetInt("value", SkirmishMapSettings.GDIBotValue);
            }
        	break;
        case (NodBotDropDown):
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastNodBotItemPosition);
        	break;
        case (NodTacticStyleDropDown):
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastNodTacticStyleItemPosition);
        	break;
        case (NodAttackingSlider):
        	Widget.SetInt("value", SkirmishMapSettings.NodAttackingValue);
        	break;
        case (NodBotSlider):
            if (SkirmishMapSettings.LastStartingTeamItemPosition == 0) {
                //set the GDI slider value from 0 to 31
                SkirmishMapSettings.NodBotValue = Clamp(SkirmishMapSettings.NodBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				SkirmishMapSettings.SavePerObjectConfig();
                Widget.SetInt("value", SkirmishMapSettings.NodBotValue);
            } else {
                SkirmishMapSettings.NodBotValue = Clamp(SkirmishMapSettings.NodBotValue, Widget.GetInt("minimum"), Widget.GetInt("maximum"));
				SkirmishMapSettings.SavePerObjectConfig();
                Widget.SetInt("value", SkirmishMapSettings.NodBotValue);
            }
        	break;
        case (StartingTeamDropDown):
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastStartingTeamItemPosition);
        	break;
        case (StartingCreditsSlider):
        	Widget.SetInt("value", SkirmishMapSettings.StartingCreditsValue);
        	break;
        case (TimeLimitStepper):
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastTimeLimitItemPosition);
        	break;
        case (MineLimitStepper):
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastMineLimitItemPosition);
        	break;
        case (VehicleLimitStepper):
        	Widget.SetInt("selectedIndex", SkirmishMapSettings.LastVehicleLimitItemPosition);
        	break;
        case (FriendlyFireCheckBox):
        	Widget.SetBool("selected", SkirmishMapSettings.bFriendlyFire);
        	break;
        case (CanRepairBuildingsCheckBox):
        	Widget.SetBool("selected", SkirmishMapSettings.bCanRepairBuildings);
        	break;
        case (BaseDestructionCheckBox):
        	Widget.SetBool("selected", SkirmishMapSettings.bBaseDestruction);
        	break;
        case (EndGamePedistalCheckBox):
        	Widget.SetBool("selected", SkirmishMapSettings.bEndGamePedistal);
        	break;
        case (TimeLimitExpiryCheckBox):
        	Widget.SetBool("selected", SkirmishMapSettings.bTimeLimitExpiry);
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

	SelectedMap = SkirmishMapSettings;
	
	
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
    switch (ev._this.GetObject("target").GetObject("data").GetString("action"))
    {
      case "back": MainFrontEnd.ReturnToBackground(); break;
      case "launch": LaunchSkirmishGame(); break;
      default: break;
    }
}


function OnGameModeDropDownChange(GFxClikWidget.EventData ev)
{
    MapList.RemoveAllEventListeners("CLIK_itemClick");
	LastGameModeItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
    SetUpDataProvider(MapList);
    MapList.AddEventListener('CLIK_itemClick', OnMapListItemClick);
    UpdateMapLabels(0);
}

function OnMapListItemClick(GFxClikWidget.EventData ev)
{
    if (ev._this.GetInt("index") == Clamp(ev._this.GetInt("index"), 0, AvailableMapDataProviders.Length)) 
    {	
        UpdateMapLabels(ev._this.GetInt("index"));
    } 
    else 
    {
        UpdateMapLabels(0);
    }
}

function UpdateMapLabels(int i)
{
    local texture2D mapImage;
    
    mapImage = texture2d(DynamicLoadObject(AvailableMapDataProviders[i].PreviewImageMarkup, class'texture2d', true));
    if (AvailableMapDataProviders[i].PreviewImageMarkup != "" && mapImage != none) 
    {
    MapImageLoader.SetString("source", "img://" $ AvailableMapDataProviders[i].PreviewImageMarkup);
    } 
    else 
    {
        MapImageLoader.SetString("source", "img://RenXFrontEnd.MapImage.___map-pic-missing-cameo");
    }

    MapSizeLabel.SetText("Size: "$ AvailableMapDataProviders[i].Size);
    MapStyleLabel.SetText("Style: "$ AvailableMapDataProviders[i].Style);
    MapPlayerCountLabel.SetText("Recommended Players: "$ AvailableMapDataProviders[i].NumPlayers);
    MapHasAirVehiclesLabel.SetText("Air Vehicles: "$ AvailableMapDataProviders[i].AirVehicles);
    MapTechBuildingsLabel.SetText("Tech Buildings: "$ AvailableMapDataProviders[i].TechBuildings);
    MapBaseDefencesLabel.SetText("Base Defences: "$ AvailableMapDataProviders[i].BaseDefences);
    LastMapListItemPosition = i;
    SkirmishMapSettings.MapName = AvailableMapDataProviders[i].MapName;
 
}



function OnGDIBotDropDownChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.LastGDIBotItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
	SkirmishMapSettings.SavePerObjectConfig();
}

function OnGDITacticStyleDropDownChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.LastGDITacticStyleItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
	SkirmishMapSettings.SavePerObjectConfig();
}

function OnGDIAttackingSliderChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.GDIAttackingValue = ev._this.GetObject("target").GetInt("value");
	SkirmishMapSettings.SavePerObjectConfig();
    GDIAttackingLabel.SetString("text", ""$ev._this.GetObject("target").GetInt("value") $" %");


}
function OnGDIBotSliderChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.GDIBotValue = ev._this.GetObject("target").GetInt("value");
	SkirmishMapSettings.SavePerObjectConfig();
    GDIBotCountLabel.SetString("text", ""$ev._this.GetObject("target").GetInt("value"));
// 	if (MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition == 0 && MapDataProviderList[LastMapListItemPosition].GDIBotValue == 16){
// 		MapDataProviderList[LastMapListItemPosition].GDIBotValue = 15;
// 	}
}

function OnNodBotDropDownChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.LastNodBotItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnNodTacticStyleDropDownChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.LastNodTacticStyleItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnNodAttackingSliderChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.NodAttackingValue = ev._this.GetObject("target").GetInt("value");
	SkirmishMapSettings.SavePerObjectConfig();
    NodAttackingLabel.SetString("text", ""$ev._this.GetObject("target").GetInt("value") $" %");
}
function OnNodBotSliderChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.NodBotValue = ev._this.GetObject("target").GetInt("value");
	SkirmishMapSettings.SavePerObjectConfig();
    NODBotCountLabel.SetString("text", ""$ev._this.GetObject("target").GetInt("value"));
// 	if (MapDataProviderList[LastMapListItemPosition].LastStartingTeamItemPosition == 1 && MapDataProviderList[LastMapListItemPosition].NodBotValue == 16) {
// 		MapDataProviderList[LastMapListItemPosition].NodBotValue = 15;
// 	}
}


function OnStartingTeamDropDownChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.LastStartingTeamItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");

    if (ev._this.GetObject("target").GetInt("selectedIndex") == 0) {
        //set the GDI slider value from 0 to 15
        SkirmishMapSettings.GDIBotValue = Clamp(SkirmishMapSettings.GDIBotValue, 0, 15);
        GDIBotSlider.SetInt("value", SkirmishMapSettings.GDIBotValue);
        GDIBotCountLabel.SetText(""$ SkirmishMapSettings.GDIBotValue);
        // set the Nod slider value from 1 to 16
        SkirmishMapSettings.NodBotValue = Clamp(SkirmishMapSettings.NodBotValue, 1, 16);
        NodBotSlider.SetInt("value", SkirmishMapSettings.NodBotValue);
        NodBotCountLabel.SetText(""$ SkirmishMapSettings.NodBotValue);
    } else if (ev._this.GetObject("target").GetInt("selectedIndex") == 1) {
        //set the Nod slider value from 0 to 15
        SkirmishMapSettings.NodBotValue = Clamp(SkirmishMapSettings.NodBotValue, 0, 15);
        NodBotSlider.SetInt("value", SkirmishMapSettings.NodBotValue);
        NodBotCountLabel.SetText("" $ SkirmishMapSettings.NodBotValue);
        // set the GDI slider value from 1 to 16
        SkirmishMapSettings.GDIBotValue = Clamp(SkirmishMapSettings.GDIBotValue, 1, 16);
        GDIBotSlider.SetInt("value", SkirmishMapSettings.GDIBotValue);
        GDIBotCountLabel.SetText(""$ SkirmishMapSettings.GDIBotValue);
    } else {
		//SkirmishMapSettings.LastStartingTeamItemPosition = Rand(1);
    }
	//MapDataProviderList[LastMapListItemPosition].SavePerObjectConfig();
}
function OnStartingCreditsSliderChange (GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.StartingCreditsValue = ev._this.GetObject("target").GetInt("value");
	SkirmishMapSettings.SavePerObjectConfig();
    StartingCreditsLabel.SetString("text", ""$ev._this.GetObject("target").GetInt("value"));
}
function OnTimeLimitStepperChange(GFxClikWidget.EventData ev)
{
	// if the player choose the infinite settings, set up the logic to implement the correct work on it.
	SkirmishMapSettings.LastTimeLimitItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnMineLimitStepperChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.LastMineLimitItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnVehicleLimitStepperChange(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.LastVehicleLimitItemPosition = ev._this.GetObject("target").GetInt("selectedIndex");
	SkirmishMapSettings.SavePerObjectConfig();
}

function OnFriendlyFireCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.bFriendlyFire = ev._this.GetBool("selected");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnCanRepairBuildingsCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.bCanRepairBuildings = ev._this.GetBool("selected");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnBaseDestructionCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.bBaseDestruction = ev._this.GetBool("selected");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnEndGamePedistalCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.bEndGamePedistal = ev._this.GetBool("selected");
	SkirmishMapSettings.SavePerObjectConfig();
}
function OnTimeLimitExpiryCheckBoxSelect(GFxClikWidget.EventData ev)
{
	SkirmishMapSettings.bTimeLimitExpiry = ev._this.GetBool("selected");
	SkirmishMapSettings.SavePerObjectConfig();
}

function bool MapPackageHasDayNight(string ThePackage)
{
	return false;
}

function string PickDayorNight(string BasePackageName)
{
	if(Rand(2) == 0)
		return BasePackageName$"_Day";
	else
		return BasePackageName$"_Night";
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