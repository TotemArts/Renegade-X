/**********************************************************************

Filename    :   GFxUDKFrontEnd_ServerSettings.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   Implementation of the Settings view.
                Associated Flash content: udk_settings.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxUDKFrontEnd_ServerSettings extends GFxUDKFrontEnd_SettingsBase
    config(UI);

var bool bDataChangedByReqs;

/** Defines the set of data/options which we will retrieved for this view. */
function SetSelectedOptionSet()
{
    SelectedOptionSet = "Server";
}

/** 
 *  When a server setting changes, update all of the server settings and force any
 *  changes which are required including ensuring that Max/Min # players do not conflict.
 */
function OnOptionChanged(GFxClikWidget.EventData ev)
{     
    local string OptionName;
    local UTGameSettingsCommon GameSettings;

	// Setup server options based on server type.
	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());       
    OptionName = String(SettingsList[ev.index].Name);    
    bDataChangedByReqs = false;

	if ( OptionName=="MaxPlayers_PC" || OptionName=="MaxPlayers_Console" || OptionName=="PrivateSlots" 
			|| OptionName=="MinNumPlayers_PC" || OptionName=="MinNumPlayers_Console")
	{        
        SaveState();
		        
		if(GameSettings.MaxPlayers < GameSettings.NumPrivateConnections)
		{            
			GameSettings.NumPrivateConnections = GameSettings.MaxPlayers;            
            bDataChangedByReqs = true;
		}

		if(GameSettings.MinNetPlayers > GameSettings.MaxPlayers)
		{
			GameSettings.MinNetPlayers = GameSettings.MaxPlayers;                   
            bDataChangedByReqs = true;
		}     

        SaveState();
	}   
    
    if ( bDataChangedByReqs )
    {
        UpdateListDataProvider(); 
    }
}

/** Saves the state of the settings to the GameSettings object. */
function SaveState()
{
    local int i;
    local int StepperSelectedIndex;
    local String ValueToSave;
    local String ControlType;
    local String SettingName;
    local GFxObject Data;
	local DataStoreClient DSClient;
	local string LocationPart, RelevantPart;
	local UIDataStore_Registry Registry;
	local UTUIDataStore_StringList StringListDataStore;
	local name MatchTypeName;

    local UTGameSettingsCommon LocalGameSettings;
	LocalGameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());    

    for (i = 0; i < SettingsList.Length; i++)
    {   
        // Retrieve the data at the index from the list's dataProvider.
        Data = ListDataProvider.GetElementObject(i);

		//Get the part to the right of the :
		RelevantPart = Split(SettingsList[i].DataStoreMarkup, ":",true);
		//Get the part to the left of the :
		LocationPart = Left(SettingsList[i].DataStoreMarkup, Len(SettingsList[i].DataStoreMarkup) - (Len(RelevantPart)+1));
		//Remove the < from the left end;
		LocationPart = Right(LocationPart, Len(LocationPart)-1);
		//Remove the > from the right end
		RelevantPart = Left(RelevantPart, Len(RelevantPart)-1);

        // Check what type of control we're dealing with.
        ControlType = Data.GetString("control");
        switch(ControlType)
        {
            case("stepper"):                                
                // Retrieve the name for this setting to retrieve its index.
                SettingName = Data.GetString("name");

				// Retrieve the selectedIndex for this optionStepper.
				StepperSelectedIndex = Data.GetFloat("optIndex");   

				if (SettingName == "ServerType")
				{
					MatchTypeName = class'WorldInfo'.static.IsConsoleBuild(CONSOLE_XBox360) ? 'ServerType360' : 'ServerType';

					// Get the global data store client
					DSClient = class'UIInteraction'.static.GetDataStoreClient();
					StringListDataStore = UTUIDataStore_StringList(DSClient.FindDataStore('UTStringList'));

					// LAN = 0 Internet = 1
					StringListDataStore.SetCurrentValueIndex(MatchTypeName, (StepperSelectedIndex == 0) ? class'GFxUDKFrontEnd_HostGame'.const.SERVERTYPE_LAN : class'GFxUDKFrontEnd_HostGame'.const.SERVERTYPE_UNRANKED);
				}
				else
				{
					// Retrieve the value that should be saved.
					ValueToSave = Data.GetObject("dataProvider").GetElementString(StepperSelectedIndex);

					if (bDataChangedByReqs)
					{                    
						if ( SettingName == "MaxPlayers_PC" || SettingName == "MaxPlayers_Console" )
						{
							ValueToSave = String(LocalGameSettings.MaxPlayers);
						}
						else if ( SettingName == "MinNumPlayers_PC" || SettingName == "MinNumPlayers_Console" )
						{
							ValueToSave = String(LocalGameSettings.MinNetPlayers);
						}
					}

					if ( SettingName == "MaxPlayers_PC" || SettingName == "MaxPlayers_Console" )
					{
						LocalGameSettings.MaxPlayers = Int(ValueToSave);
					}
					else if ( SettingName == "MinNumPlayers_PC" || SettingName == "MinNumPlayers_Console" )
					{
						LocalGameSettings.MinNetPlayers = Int(ValueToSave);
					} 

					SettingsList[i].RangeData.CurrentValue = Int(ValueToSave);
					LocalGameSettings.SetPropertyFromStringByName(name(RelevantPart), ValueToSave);
				}

                break;
            
            case("input"):
                SettingName = StrinG(SettingsList[i].Name);
                ValueToSave = Data.GetString("text");

				if (LocationPart == "Registry")
				{
					Registry = UIDataStore_Registry(class'UIRoot'.static.StaticResolveDataStore('Registry'));

					Registry.SetData(RelevantPart,ValueToSave);
				}

                if ( SettingName == "ServerDescription" )
                {
					LocalGameSettings.SetPropertyFromStringByName('ServerDescription', ValueToSave);
                }
                break;
            default:
                break;
        }
    }
}



/** Updates the list's dataProvider. */
function UpdateListDataProvider()
{
    local byte i, j;
    local string ControlType;
    local string DefaultValue;
    local int DefaultIndex;
    local GFxObject RendererDataProvider;
    local GFxObject DataProvider;
    local GFxObject TempObj;
	local UTGameSettingsCommon GameSettings;
	local string LocationPart, RelevantPart;
	local name MatchTypeName;
	local int StringIndex;
	local int StringIter, ChoiceIter;
	local bool bFoundDefault;

	local DataStoreClient DSClient;
	local UTUIDataStore_StringList StringListDataStore;

	local UIDataStore_Registry Registry;

	Registry = UIDataStore_Registry(class'UIRoot'.static.StaticResolveDataStore('Registry'));

	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	StringListDataStore = UTUIDataStore_StringList(DSClient.FindDataStore('UTStringList'));

	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());
    
    DataProvider = Outer.CreateArray();
    for ( i = 0; i < SettingsList.Length; i++)
    {        
		bFoundDefault = false;

        // Create a AS object to hold the data for SettingsList[i].
        TempObj = CreateObject("Object");              

        // We need to keep track of the name so that we can update Min/Max players
        // if they are changed and become conflicting. OnSettingListChange will be
        // fired by the list, which will check which control fired the event and
        // update both steppers if one of them is the source.
        TempObj.SetString("name", String(SettingsList[i].Name));

        // Parse SettingsList[i] into TempObj.
        TempObj.SetString("label", Caps(SettingsList[i].FriendlyName));

        ControlType = FindControlByUTClassName(SettingsList[i].OptionType);
        TempObj.SetString("control", ControlType);  

		//Get the part to the right of the :
		RelevantPart = Split(SettingsList[i].DataStoreMarkup, ":",true);
		//Get the part to the left of the :
		LocationPart = Left(SettingsList[i].DataStoreMarkup, Len(SettingsList[i].DataStoreMarkup) - (Len(RelevantPart)+1));
		//Remove the < from the left end;
		LocationPart = Right(LocationPart, Len(LocationPart)-1);
		//Remove the > from the right end
		RelevantPart = Left(RelevantPart, Len(RelevantPart)-1);

        if (ControlType == "stepper")
        {
			RendererDataProvider = Outer.CreateArray();            
			if ( String(SettingsList[i].Name) == "ServerType" || String(SettingsList[i].Name) == "ServerType360" )
			{	
				for (StringIter = 0; StringIter < StringListDataStore.StringData.Length; StringIter++)
				{
					// Populate the server types with the friendly names of "LAN=0/Internet=1"
					if (string(StringListDataStore.StringData[StringIter].Tag) == RelevantPart)
					{
						// Default LAN option
						RendererDataProvider.SetElementString(0, StringListDataStore.StringData[StringIter].Strings[0]);
						if (!class'WorldInfo'.static.IsConsoleBuild(CONSOLE_PS3))
						{
							// "Other" options if supported
							for (ChoiceIter = 1; ChoiceIter < StringListDataStore.StringData[StringIter].Strings.Length; ChoiceIter++)
							{
								RendererDataProvider.SetElementString(ChoiceIter, StringListDataStore.StringData[StringIter].Strings[ChoiceIter]);
							}
						}

						MatchTypeName = class'WorldInfo'.static.IsConsoleBuild(CONSOLE_XBox360) ? 'ServerType360' : 'ServerType';
						DefaultIndex = StringListDataStore.GetCurrentValueIndex(MatchTypeName);
						bFoundDefault = true;
						break;
					}
				}		
			}       
			else 
			{
				PopulateOptionDataProviderForIndex(i, RendererDataProvider, DefaultValue, DefaultIndex);             
			}

            // Set the dataProvider and the selectedIndex for the embeddedOptionStepper control.
			TempObj.SetBool("bUpdateFromUnreal", true);
            TempObj.SetObject("dataProvider", RendererDataProvider);  
            TempObj.SetFloat("optIndex", DefaultIndex);
        }

		//Is it a setting?
		if (!bFoundDefault)
		{
			for (j = 0; j < GameSettings.LocalizedSettings.Length; j++)
			{        
				StringIndex = InStr(RelevantPart, String(GameSettings.LocalizedSettingsMappings[j].Name));
				if (StringIndex > -1)
				{
					DefaultValue = String(GameSettings.LocalizedSettingsMappings[j].ValueMappings[GameSettings.LocalizedSettings[j].ValueIndex].Name);
					bFoundDefault = true;
					break;
				}
			}
		}

		//Is it in the registry?
		if (!bFoundDefault)
		{
			if (LocationPart == "Registry")
			{
				 Registry.GetData(RelevantPart, DefaultValue);
				 bFoundDefault = true;
			}
		}

		//Is it in the settings directly?
		if (!bFoundDefault)
		{
			if (LocationPart == "UTGameSettings")
			{
				if (RelevantPart == "MinNetPlayers")
				{
					DefaultValue = String(GameSettings.MinNetPlayers);
					bFoundDefault = true;
				}
				else if (RelevantPart == "MaxPlayers")
				{
					DefaultValue = String(GameSettings.MaxPlayers);
					bFoundDefault = true;
				}
				else if (RelevantPart == "NumPrivateConnections")
				{
					DefaultValue = String(GameSettings.NumPrivateConnections);
					bFoundDefault = true;
				}
			}
		}

		//Is it a property?
		//NOTE: This will return a blank string if it cannot find it, so use this as the last resort
		if (!bFoundDefault)
		{
			DefaultValue = GameSettings.GetPropertyAsStringByName(name(RelevantPart));
		}

        TempObj.SetString("text", DefaultValue);
        TempObj.SetBool("bNumericCombo", SettingsList[i].bNumericCombo);
        TempObj.SetBool("bEditableCombo", SettingsList[i].bEditableCombo);
        TempObj.SetFloat("editBoxMaxLength", SettingsList[i].EditBoxMaxLength);   
        DataProvider.SetElementObject(i, TempObj);
    }

    ListMC.SetObject("dataProvider", DataProvider);   
    ListDataProvider = ListMC.GetObject("dataProvider");

}

/** 
 *  Populates a dataProvider with option data based on the list retrieved using LoadDataFromDataStore().
 *  Requires the index of the dataSet, a GFxObject to populate with data, and a defaultIndex / defaultString
 */
function PopulateOptionDataProviderForIndex(const int Index, out GFxObject OutDataProvider, out string OutDefaultValue, out int OutDefaultIndex)
{   
    local int i, j;    
    local UTUIDataProvider_MenuOption CurrentSetting;
	local UTGameSettingsCommon GameSettings;
	local int SettingIndex;

	GameSettings = UTGameSettingsCommon(SettingsDataStore.GetCurrentGameSettings());
	OutDefaultIndex = 0;

	// Create a dataProvider for the embedded component.

	// Check if this setting has associated localized labels.
	SettingIndex = FindLocalizedSettingIndexByName(SettingsList[Index].Name);
	if (SettingIndex > -1)
	{
		// If it does, use those localized strings as the labels for the control.
		for (i = 0; i <  GameSettings.LocalizedSettingsMappings[SettingIndex].ValueMappings.Length; i++)
		{
			OutDataProvider.SetElementString(i, String(GameSettings.LocalizedSettingsMappings[SettingIndex].ValueMappings[i].Name));
		}
		OutDefaultIndex = GameSettings.LocalizedSettings[SettingIndex].ValueIndex;
	}
	else
	{
		CurrentSetting = SettingsList[Index];
		j = 0;
		for (i = CurrentSetting.RangeData.MinValue; i < CurrentSetting.RangeData.MaxValue; i = i + CurrentSetting.RangeData.NudgeValue)
		{
			OutDataProvider.SetElementString(j, String(i));
			if (i == CurrentSetting.RangeData.CurrentValue)
			{
				OutDefaultIndex = j;
			}
			j++;
		}
	}
}

/** Converts the class name for a UTUIObject to a name that can be handled by AS class for the list's itemRenderers. */
function string FindControlByUTClassName(byte UTUIControlClass)
{
    switch(UTUIControlClass)
    {
        case (UTOT_Slider):
            return "stepper";
            break;
        
        case (UTOT_EditBox):
            return "input";
            break;

        default:
            return "stepper";
            break;
    }
}