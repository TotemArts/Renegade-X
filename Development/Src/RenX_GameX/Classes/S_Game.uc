class S_Game extends Rx_Game;

event InitGame(string Options, out string ErrorMessage)
{
    super.InitGame(Options, ErrorMessage);

	AddMutator("RenX_GameX.S_CrateReplacer");
	BaseMutator.InitMutator(Options, ErrorMessage);
    AddMutator("RenX_GameX.S_Nod_EVA");
    BaseMutator.InitMutator(Options, ErrorMessage);
}

function static string GetTeamName(byte Index)
{
	switch (Index)
	{
	case TEAM_GDI:
		return "Black Hand";
	case TEAM_NOD:
		return "Nod";
	default:
		return "Neutral";
	}
}

//Changed to make BH Airdrops work
function CheckBuildingsDestroyed(Actor destroyedBuilding, Rx_Controller StarPC)
{
	local BuildingCheck Check;
	local PlayerReplicationInfo pri;
	local Rx_Controller PC;
	
	/*Show message where people will actually see it -Yosh (Remember the outrage when destruction and beacon messages were moved to the middle left? Yeah.. neither do the people that ranted about it.)*/
	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		if(!Rx_Building(destroyedBuilding).bSignificant)
		{
			if(StarPC != None && PC.GetTeamNum() == StarPC.GetTeamNum())
				PC.DisseminateVPString("[Team Building Kill Bonus]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingDestroyed*Rx_Game(WorldInfo.Game).CurrentBuildingVPModifier[StarPC.GetTeamNum()] $ "&");
			continue;
		}

		if (StarPC == none && !bPedestalDetonated)
			PC.CTextMessage(Caps("The"@destroyedBuilding.GetHumanReadableName()@ "was destroyed!"),'Red', 180);
		else if (PC.GetTeamNum() == StarPC.GetTeamNum())
		{
			if(!bPedestalDetonated)
				PC.CTextMessage(Caps("The"@destroyedBuilding.GetHumanReadableName()@ "was destroyed!"),'Green',180);
			
			PC.DisseminateVPString("[Team Building Kill Bonus]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingDestroyed*Rx_Game(WorldInfo.Game).CurrentBuildingVPModifier[StarPC.GetTeamNum()] $ "&");
		}
		else if (!bPedestalDetonated)
		{
			PC.CTextMessage(Caps("The"@destroyedBuilding.GetHumanReadableName()@ "was destroyed!"),'Red',180);
		}
	}
	//End show message where people will actually look at it.

	if (Role == ROLE_Authority)
	{
		CurrentBuildingVPModifier[destroyedBuilding.GetTeamNum()] +=1.0;
		if(!bPedestalDetonated && Rx_Building(destroyedBuilding).bSignificant)	// don't check victory for insignificant buildings
		{
			Check = CheckBuildings();
			if (Check == BC_GDIDestroyed || Check == BC_NodDestroyed || Check == BC_TeamsHaveNoBuildings)
			{
				if(Check == BC_GDIDestroyed)
					EndRxGame("Buildings",TEAM_NOD);
				else if(Check == BC_NodDestroyed)
					EndRxGame("Buildings",TEAM_GDI); 	
				else 
					EndRxGame("Buildings",255);
			}
		}
		
		if (RxIfc_FactoryVehicle(destroyedBuilding) != None || Rx_Building_AirTower(destroyedBuilding) != none && Rx_Building_Helipad_Nod(destroyedBuilding) == None)
		{
			if(PurchaseSystem.AreTeamFactoriesDestroyed(TEAM_NOD))
			{
				foreach WorldInfo.GRI.PRIArray(pri)
				{
					if(Rx_Pri(pri) != None && (Rx_Pri(pri).GetTeamNum() == TEAM_NOD) && Rx_Pri(pri).AirdropCounter == 0)
					{
						Rx_Pri(pri).AirdropCounter++;
						Rx_Pri(pri).LastAirdropTime=WorldInfo.TimeSeconds;
					}
				}
				VehicleManager.bNodIsUsingAirdrops = true;
				VehicleManager.NodAdditionalAirdropProductionDelay = 20.0;
			}
		}
		else if (RxIfc_FactoryVehicle(destroyedBuilding) != None || S_Building_AirTower_BlackHand(destroyedBuilding) != none && Rx_Building_Helipad_GDI(destroyedBuilding) == None)
		{
			if(PurchaseSystem.AreTeamFactoriesDestroyed(TEAM_GDI))
			{
				foreach WorldInfo.GRI.PRIArray(pri)
				{
					if(Rx_Pri(pri) != None && (Rx_Pri(pri).GetTeamNum() == TEAM_GDI) && Rx_Pri(pri).AirdropCounter == 0)
					{	
						Rx_Pri(pri).AirdropCounter++;
						Rx_Pri(pri).LastAirdropTime=WorldInfo.TimeSeconds;
					}
				}
				VehicleManager.bGDIIsUsingAirdrops = true;
				VehicleManager.GDIAdditionalAirdropProductionDelay = 20.0;
			}
		}
	
	if(Rx_Building(destroyedBuilding).GetTeamNum() == 0) 
			DestroyedBuildings_GDI++; 
		else
			DestroyedBuildings_Nod++; 
	
	}
	
	
}

/** Calling this advances the cycle and thus should not be called just to get the name of the next map, use GetNextMapInRotationName() */
function string GetNextMap()
{
	local int GameIndex;

	if (bFixedMapRotation)
	{
		GameIndex = class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game');
		if (GameIndex != INDEX_NONE)
		{
			MapCycleIndex = GetNextMapInRotationIndex();
			//TODO: Add to fixed map rotation to cycle between day/night maps. 
			class'UTGame'.default.MapCycleIndex = MapCycleIndex;
			class'UTGame'.static.StaticSaveConfig();

			return class'UTGame'.default.GameSpecificMapCycles[GameIndex].Maps[MapCycleIndex];
		}
	}
	else
	{	
		return Rx_Gri(GameReplicationInfo).GetMapVoteName();
	}

	return "";
}

function int GetNextMapInRotationIndex()
{
	local int MapIndex, GameIndex;
	local array<string> MapList;
	
	GameIndex = class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game');
	MapList = class'UTGame'.default.GameSpecificMapCycles[GameIndex].Maps;
	MapIndex = GetCurrentMapCycleIndex(MapList);
	if (MapIndex == INDEX_NONE)
	{
		// assume current map is actually zero
		MapIndex = 0;
	}
	return (MapIndex + 1 < class'UTGame'.default.GameSpecificMapCycles[GameIndex].Maps.length) ? (MapIndex + 1) : 0;
}

function string GetNextMapInRotationName()
{
	return class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps[GetNextMapInRotationIndex()];
}

function RecordToMapHistory(string LatestMap)
{
	local int i;

	if (MapHistory.Length < MapHistoryMax)
		i = MapHistory.Length;
	else
		i = MapHistoryMax - 1;

	while (i>0)
	{
		MapHistory[i] = MapHistory[i-1];
		--i;
	}
	MapHistory[0] = LatestMap;
	SaveConfig();
}

function array<string> BuildMapVoteList()
{
	local array<string> MapPool;
	local int i;

	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps;
	for (i=0; i<RecentMapsToExclude && i<MapHistory.Length; ++i)
		MapPool.RemoveItem(MapHistory[i]);	


	for (i=0; i < MapsWithPlayerNumLimits.Length; ++i)
	{
		if(MapPool.Find(MapsWithPlayerNumLimits[i].MapName) != -1 && (MapsWithPlayerNumLimits[i].MapMinPlayers > NumPlayers || MapsWithPlayerNumLimits[i].MapMaxPlayers < NumPlayers))
			MapPool.RemoveItem(MapsWithPlayerNumLimits[i].MapName);  
	}

	while (MapPool.Length > MaxMapVoteSize)
		MapPool.Remove(Rand(MapPool.Length), 1);

	return MapPool;
}

/*Functions added to add/remove maps from the rotation while in-game*/

exec function bool AddMapToRotation(string MapName) /*Return if the given map name was a valid map, then add a map to the map rotation*/
{	
	local array<string> MapPool;
	
	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps;	
	
	if(bDoesMapExist(MapName))
	{
		//`log("Did not find map, adding to rotation");
		
		if( !MapPackageExists(MapName) ) return false; 
		
		MapPool.AddItem(MapName); 
		EditMapArray(MapPool);
		saveconfig();
		return true; 
	}
	return false; 
}

exec function bool RemoveMapFromRotation(string MapName) /*Return if the given map name was a valid map, then remove a map from the map rotation*/
{
	local array<string> MapPool;
	
	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps;	
	
	if(bDoesMapExist(MapName))
	{
		`log("Found map"@MapName$", removing from rotation.");
		//insert code to verify is legitimate map 
		MapPool.RemoveItem(MapName);
		EditMapArray(MapPool);
		saveconfig(); 
		return true; 
	}
	return false; 
}

function bool bDoesMapExist(string MapName)
{
	local array<string> MapPool;
	
	MapPool = class'UTGame'.default.GameSpecificMapCycles[class'UTGame'.default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps;	

	if (MapPool.Find(MapName) != -1)
	{
		`log(MapName@"does exist.");
		return true; 
	}

	return false; 
}

function EditMapArray(array<string> NewMapList)
{
	local int i; 
	
	GameSpecificMapCycles[GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps.Length=0; //Delete the old map list
	
	for(i = 0; i < NewMapList.Length; i++)
	{
		`log("Adding item" @ NewMapList[i]) ;
		GameSpecificMapCycles[GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps.AddItem(NewMapList[i]) ; //create the new map list
	}
}

exec function GetMapRotation() //Obviously get the map-rotation
{
	local array<string> MapPool;
	local int i;
		
	MapPool = default.GameSpecificMapCycles[default.GameSpecificMapCycles.Find('GameClassName', 'Rx_Game')].Maps;	
	
		RxLog("Generating Map List");
		for(i = 0; i < MapPool.Length; i++)
		{
			RxLog("Map"`s i `s ":" `s MapPool[i]); 
		}
}

DefaultProperties
{
	VehicleManagerClass = class'S_VehicleManager'
	HelipadVehicleManagerClass = class'S_HelipadVehicleManager'
	HUDClass = class'S_HUD'
	PlayerControllerClass = class'S_Controller'
	PurchaseSystemClass = class'S_PurchaseSystem'
	HelipadPurchaseSystemClass = class'S_HelipadPurchaseSystem'
	TeamInfoClass = class'S_TeamInfo'
	VictoryMessageClass        = class'S_VictoryMessage'
}