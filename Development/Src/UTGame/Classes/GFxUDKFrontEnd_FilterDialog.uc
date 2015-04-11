/**********************************************************************

Filename    :   GFxUDKFrontEnd_FilterDialog.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of the filter dialog spawned by the join 
				game view. Allows the player to change the search filters
				for multiplayer games.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_FilterDialog extends GFxUDKFrontEnd_Dialog
    config(UI);

/** Option list present on this tab page. */
var transient UTUIDataStore_StringList	StringListDataStore;

/** Reference to the game search datastore. */
var UTDataStore_GameSearchDM SearchDataStore;

/** Reference to the FilterList component which displays the filters as option steppers. */
var GFxClikWidget FilterListMC;

/** Tracks if the filters settings have been changed. */
var bool bFiltersHaveChanged;

/** Data provider for filter options list */
var GFxObject DataProvider;

/** Data item for the network type filter option */
var GFxObject NetworkTypeOptionItem;

/** Data item for the game type filter option */
var GFxObject GameTypeOptionItem;

/** Structure which defines a unique menu view to be loaded. */
struct Option
{
	var string OptionName;
	var string OptionLabel;
	var array<string> OptionData;
};

/** Array of all menu views to be loaded, defined in DefaultUI.ini. */
var config array<Option>		        ListOptions;

/** Delegate for when the game type has been changed. This is set by the parent view, GFxUDKFrontEnd_JoinGame. */
delegate transient OnSwitchedGameType();

function OnViewLoaded()
{
	// Retrieve references to relevant data stores.
	StringListDataStore = UTUIDataStore_StringList(class'UIRoot'.static.StaticResolveDataStore('UTStringList'));
	SearchDataStore = UTDataStore_GameSearchDM(class'UIRoot'.static.StaticResolveDataStore('UTGameSearch'));
}

function OnTopMostView(optional bool bPlayOpenAnimation = FALSE)
{
	bFiltersHaveChanged = false;

	// Setup the text and button listeners.
	TitleTxt.SetText("SEARCH FILTER");

	BackBtn.SetString("label", "BACK");
	BackBtn.RemoveAllEventListeners("CLIK_press");
	BackBtn.RemoveAllEventListeners("press");
	BackBtn.AddEventListener('CLIK_press', Select_Back);

	// Update the data provider for the filters.
	SetupListDataProvider();
	MenuManager.ASSetSelectionFocus(FilterListMC);


	// Check if the network type (LAN/Internet) should be editable
	ValidateServerType();
}

/** Fired when a dialog is popped from the stack. */
function OnViewClosed()
{
	Super.OnViewClosed();
	DisableSubComponents(false);
}

/** Mutator for enable/disable sub-components of the dialog. */
function DisableSubComponents(bool bEnableComponents)
{
	FilterListMC.SetBool("disabled", bEnableComponents);
	BackBtn.SetBool("disabled", bEnableComponents);
}

/** 
 * Sets the event listener for the back button. 
 *
 * @param	DelegateListener	The function that should be called when the back button is pressed.
*/
function SetBackButtonListener(delegate<GFxClikWidget.EventListener> DelegateListener)
{
	BackBtn.SetString("label", "BACK");
	BackBtn.RemoveAllEventListeners("CLIK_press");
	BackBtn.RemoveAllEventListeners("press");
	BackBtn.AddEventListener('CLIK_press', DelegateListener);
	BackBtn.AddEventListener('CLIK_press', Select_Back);
}

/**
 * Enables / disables the "match type" control based on whether we are signed in online.
 */
function ValidateServerType()
{
	local int PlayerIndex, PlayerControllerID, ValueIndex;
	local name MatchTypeName;

	// find the "MatchType" control (contains the "LAN" and "Internet" options); if we aren't signed in online,
	// don't have a link connection, or not allowed to play online, don't allow them to select one.
	PlayerIndex = GetPlayerIndex();
	PlayerControllerID = GetPlayerControllerId(PlayerIndex);

	if (!IsLoggedIn(PlayerControllerID, true) || class'WorldInfo'.static.IsConsoleBuild(CONSOLE_PS3))
	{
		if (MenuManager != none && MenuManager.JoinGameView != none)
		{
			MenuManager.JoinGameView.ForceLANOption();
		}
	}
	else
	{
		MatchTypeName = class'WorldInfo'.static.IsConsoleBuild(CONSOLE_XBox360) ? 'MatchType360' : 'MatchType';
		ValueIndex = StringListDataStore.GetCurrentValueIndex(MatchTypeName);

		SetFilterNetworkType(ValueIndex == Class'GFxUDKFrontEnd_JoinGame'.const.SERVERBROWSER_SERVERTYPE_LAN);
	}
}

/** 
  *  HACKY! Translate human readable string to game class.  Should be ini driven!
  */
function string GetGameClassByFriendlyName(string FriendlyName)
{
	if ( FriendlyName ~= "Deathmatch" )
	{
		return "UTGame.UTDeathmatch";
	}
	else if ( FriendlyName ~= "Team Deathmatch" )
	{
		return "UTGame.UTTeamGame";
	}
	else if ( FriendlyName ~= "Capture the Flag" )
	{
		return "UTGameContent.UTVehicleCTFGame_Content";
	}

	return FriendlyName;
}

/** Pass through the option callback. */
function OnFilterList_OptionChanged(GFxClikWidget.EventData ev)
{
	local GFxObject Data;
	local byte SelectedIndex;
	local string OptionName;
	local String OptionValue;
	local String GameClassName;
	local UIDataStore_OnlineGameSettings SettingsDataStore;
	local UTGameSettingsCommon GameSettings;
	local bool bIsLAN;

	// Publisher.SaveSubscriberValue(OutDataStores);
	bFiltersHaveChanged = true;
	OptionName = ListOptions[ev.index].OptionName;

	// Retrieve the selected option from the item that changed.
	Data = FilterListMC.GetObject("dataProvider").GetElementObject(ev.index);
	SelectedIndex = Data.GetFloat("optIndex");
	OptionValue = ListOptions[ev.index].OptionData[SelectedIndex];

	if (OptionName ~= "Mode")
	{
		// If the game mode changed, retrieve the proper class based on the friendly string.
		GameClassName = GetGameClassByFriendlyName(OptionValue);

		// Make sure to update the GameSettings value - this is used to build the join URL
		SettingsDataStore = UIDataStore_OnlineGameSettings(class'UIRoot'.static.StaticResolveDataStore('UTGameSettings'));
		GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());
		GameSettings.SetPropertyFromStringByName('CustomGameMode', GameClassName);

		// Fire the delegate
		OnSwitchedGameType();
	}
	else if (OptionName ~= "Type")
	{
		bIsLAN = OptionValue ~= "LAN" || class'WorldInfo'.static.IsConsoleBuild(CONSOLE_PS3);
		SetFilterNetworkType(bIsLAN, false);
	}
}

function SetFilterNetworkType(bool bLAN, optional bool bSkipUIUpdate)
{
	local name MatchTypeName;
	local int i, j;
	local UTGameSearchCustom CustomSearch;

	MatchTypeName = Class'WorldInfo'.Static.IsConsoleBuild(CONSOLE_XBox360) ? 'MatchType360' : 'MatchType';
	StringListDataStore.SetCurrentValueIndex(MatchTypeName, bLAN ? Class'GFxUDKFrontEnd_JoinGame'.const.SERVERBROWSER_SERVERTYPE_LAN :
									Class'GFxUDKFrontEnd_JoinGame'.const.SERVERBROWSER_SERVERTYPE_UNRANKED);

	GameTypeOptionItem.SetBool("controlDisabled", bLAN);

	i = SearchDataStore.FindSearchConfigurationIndex('UTGameSearchCustom');

	if (i != INDEX_None)
	{
		CustomSearch = UTGameSearchCustom(SearchDataStore.GameSearchCfgList[i].Search);
		CustomSearch.ResetFilters();

		SearchDataStore.SetCurrentByName('UTGameSearchCustom', true);
	}

	// Update the UI selection
	if (!bSkipUIUpdate)
	{
		for (i=0; i<ListOptions.Length; ++i)
		{
			if (ListOptions[i].OptionName ~= "Type")
			{
				break;
			}
		}

		if (i < ListOptions.Length)
		{
			for (j=0; j<ListOptions[i].OptionData.Length; ++j)
			{
				if (ListOptions[i].OptionData[j] ~= "LAN" ^^ !bLAN)
				{
					break;
				}
			}

			if (j < ListOptions[i].OptionData.Length)
			{
				NetworkTypeOptionItem.SetFloat("optIndex", j);
			}
		}
	}

	PushFilterListUpdate();
}

function SetupListDataProvider()
{
	local byte j;
	local string ControlType;
	local GFxObject RendererDataProvider;
	local GFxObject TempData;
	local array<ASValue> args;
	local ASValue ASVal;

	// Create the options list
	if (DataProvider == none)
	{
		DataProvider = CreateArray();

		// Both items for the Filter Dialog will use an option stepper..
		ControlType = "stepper";

		// Create data item for LAN/Internet stepper
		NetworkTypeOptionItem = CreateObject("Object");
		NetworkTypeOptionItem.SetString("name", ListOptions[0].OptionName);
		NetworkTypeOptionItem.SetString("label", Caps(ListOptions[0].OptionLabel));
		NetworkTypeOptionItem.SetString("control", ControlType);

		RendererDataProvider = Outer.CreateArray();
		for ( j = 0; j < ListOptions[0].OptionData.Length; j++)
		{
			TempData = Outer.CreateObject("Object");
			TempData.SetString("label", ListOptions[0].OptionData[j]);
			TempData.SetString("value", ListOptions[0].OptionData[j]);
			RendererDataProvider.SetElementObject(j, TempData);
		}
		NetworkTypeOptionItem.SetObject("dataProvider", RendererDataProvider);

		NetworkTypeOptionItem.SetFloat("optIndex", 0);

		DataProvider.SetElementObject(0, NetworkTypeOptionItem);

		// Create data item for Game type stepper: DM, TeamDM, VCTF
		GameTypeOptionItem = CreateObject("Object");
		GameTypeOptionItem.SetString("name", ListOptions[1].OptionName);
		GameTypeOptionItem.SetString("label", Caps(ListOptions[1].OptionLabel));
		GameTypeOptionItem.SetString("control", ControlType);

		RendererDataProvider = Outer.CreateArray();
		for ( j = 0; j < ListOptions[1].OptionData.Length; j++)
		{
			TempData = Outer.CreateObject("Object");
			TempData.SetString("label", ListOptions[1].OptionData[j]);
			TempData.SetString("value", ListOptions[1].OptionData[j]);
			RendererDataProvider.SetElementObject(j, TempData);
		}
		GameTypeOptionItem.SetObject("dataProvider", RendererDataProvider);
		
		GameTypeOptionItem.SetBool("controlDisabled", TRUE);

		GameTypeOptionItem.SetFloat("optIndex", 0);

		// LAN mode shows all games; does not allow filtering by game type
		DataProvider.SetElementObject(1, GameTypeOptionItem);

		// Commit changes
		FilterListMC.SetObject("dataProvider", DataProvider);

		ASVal.Type = AS_String;
		ASVal.s = "";
		Args[0] = ASVal;

		FilterListMC.Invoke("validateNow", args);
		FilterListMC.SetFloat("selectedIndex", 0);
	}
}

/** Pushes Unreal Script changes to Action Script (updates the UI) */
function PushFilterListUpdate()
{
	FilterListMC.ActionScriptVoid("validateNow");
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;
	bWasHandled = false;

	switch(WidgetName)
	{
	case ('list'):
		if (FilterListMC == none)
		{
			FilterListMC = GFxClikWidget(Widget);  
			FilterListMC.AddEventListener('CLIK_itemChange', OnFilterList_OptionChanged);
			bWasHandled = true;
		}

		break;

	case ('popup_title'):
		TitleTxt = Widget;
		TitleTxt.SetText("SEARCH FILTER");
		TitleTxt.SetString("label", "FILTER");
		bWasHandled = true;
		break;

	default:
		break;
	}

	if (!bWasHandled)
	{
		bWasHandled = Super.WidgetInitialized(WidgetName, WidgetPath, Widget);
	}

	return bWasHandled;
}
