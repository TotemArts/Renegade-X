class Rx_BuildingManager extends Actor
dependson(Rx_Building)
notplaceable;

// Team numbers stored easily
enum TeamEnum
{
	TEAM_GDI,
	TEAM_NOD,
	TEAM_UNOWNED
};

// Building type and a pointer to the actor
struct BuildingElement
{
   var byte Type;
   var Rx_Building Building;
};

/*
	BT_None,
	BT_Power,
	BT_Money,
	BT_Veh,
	BT_Inf,
	BT_Def,
	BT_Air,
	BT_Tech
*/

var private array<BuildingElement> GDI_Buildings, Nod_Buildings;
var private Rx_Game RGame;
var private UTTeamInfo Teams[2];
var private Rx_MapInfo MapInfo;

/**
 *
 * Checks for all existing buidlings and assign it to the team
 *
 */
function Initialize(UTTeamInfo GDITeamInfo, UTTeamInfo NodTeamInfo)
{
    local Rx_Building Build;

	RGame = Rx_Game(WorldInfo.Game);
   
	Teams[TEAM_GDI] = GDITeamInfo;
  	Teams[TEAM_NOD] = NodTeamInfo;

  	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());

	ForEach AllActors(class'Rx_Building', Build)
	{
		BuildingCreated(Build);
	}
}

/**
 * This function exists with the sole purpose of maybe having more events added to buildings being created
 *
 * @param InBuilding The building that was created
 * 
 */
function BuildingCreated(Rx_Building InBuilding) 
{
	AddBuilding(InBuilding);

}

/**
 * Adds a building to the array of it's own team. Builds a struct then adds to array
 *
 * @param InBuilding The building we are adding
 * 
 */
function AddBuilding(Rx_Building InBuilding)
{
	local BuildingElement NewBuilding;

	NewBuilding.Type = InBuilding.GetBuildingType();
	NewBuilding.Building = InBuilding;

	switch (InBuilding.GetTeamNum())
	{
		case TEAM_GDI:
			GDI_Buildings.AddItem(NewBuilding);
		break;

		case TEAM_NOD:
			Nod_Buildings.AddItem(NewBuilding);
		break;

		default:
			ScriptTrace();
			`log("Rx_BuildingManager::AddBuilding WARNING UNOWNED TEAM FOUND"@InBuilding.GetHumanReadableName());
		break;
	}
}

/**
 * Removes a building from its own team's array. Finds the correct index by searching for the building object itself
 *
 * @param InBuilding Building to remove from the array
 * 
 */
function RemoveBuilding(Rx_Building InBuilding)
{
	switch (InBuilding.GetTeamNum())
	{
		case TEAM_GDI:
			GDI_Buildings.Remove(GDI_Buildings.Find('Building', InBuilding), 1);
		break;

		case TEAM_NOD:
			Nod_Buildings.Remove(Nod_Buildings.Find('Building', InBuilding), 1);
		break;

		default:
			ScriptTrace();
			`log("Rx_BuildingManager::RemoveBuilding WARNING UNOWNED TEAM FOUND"@InBuilding.GetHumanReadableName());
		break;
	}
}

/**
 * Checks if a team has a type of building
 *
 * @param Team The team to search on
 * @param Type The type of building to search for
 * 
 * @return bool Does the team have this type of building? (true = it has at least 1, false = it has none)
 */
function bool HasBuilding(byte Team, byte Type)
{

	switch (Team)
	{
		case TEAM_GDI:
			if (GDI_Buildings.Find('Type', Type) >= 0)
				return true;
			else 
				return false;
		break;

		case TEAM_NOD:
			if (Nod_Buildings.Find('Type', Type) >= 0)
				return true;
			else 
				return false;
		break;

		default:
			ScriptTrace();
			`log("Rx_BuildingManager::HasBuilding WARNING UNOWNED TEAM ATTEMPTED CALL");
	}
}

function bool NoActiveBuildingOfType(byte Team, byte Type)
{
	local Array<Rx_Building> BuildingList;
	local Rx_Building B;

	BuildingList = GetBuildingByType(Team,Type);

	if(BuildingList.Length <= 0)
		return true;

	foreach BuildingList(B)
	{
		if(!B.IsDestroyed())
			return false;
	}

	return true;

}

/**
 * Checks for a specific type of a team, returns the building(s) in an array
 *
 * @param Team The team to search on
 * @param Type The type of building to search for
 * 
 * @return array<Rx_Building> All of the team's buildings of the type, or empty if none
 */
function array<Rx_Building> GetBuildingByType(byte Team, byte Type)
{
	local array<Rx_Building> tempArray, outArray;
	local Rx_Building B;

	tempArray = GetBuildingByTeam(Team);


	if(tempArray.Length > 0)
	{
		foreach tempArray(B)
		{
			if(B.GetBuildingType() == Type)
				OutArray.AddItem(B);
		}
	}

	return OutArray;
}

/**
 * Returns all the building(s) of that team in an array
 *
 * @param Team The team to search for
 *
 * @return array<Rx_Building> All of the team's buildings, or empty if none 
 */
function array<Rx_Building> GetBuildingByTeam(byte Team)
{
	local int i;
	local array<Rx_Building> outArray;

	switch (Team)
	{
		case TEAM_GDI:
			For (i = 0; GDI_Buildings.Length > i; i++)
				outArray.AddItem(GDI_Buildings[i].Building);
		break;

		case TEAM_NOD:
			For (i = 0; Nod_Buildings.Length > i; i++)
				outArray.AddItem(Nod_Buildings[i].Building);
		break;

		default:
			ScriptTrace();
			`log("Rx_BuildingManager::GetBuildingByTeam WARNING UNOWNED TEAM ATTEMPTED CALL");
	}

	return outArray;
}

/**
 * Gets all the buildings from both teams
 *
 * @return array<Rx_Building> All of the buildings, or empty if none
 */
function array<Rx_Building> GetAllBuildings()
{
	local int i;
	local array<Rx_Building> outArray;

	For (i = 0; GDI_Buildings.Length > i; i++)
		outArray.AddItem(GDI_Buildings[i].Building);

	For (i = 0; Nod_Buildings.Length > i; i++)
		outArray.AddItem(Nod_Buildings[i].Building);

	return outArray;
}

function array<Rx_Building_Refinery> GetActiveRefineries()
{
	local array<Rx_Building_Refinery> outArray;
	local int i;

			For (i = 0; GDI_Buildings.Length > i; i++)
			{
				if (GDI_Buildings[i].Type == BT_Money && !GDI_Buildings[i].Building.IsDestroyed())
				{
					outArray.AddItem(Rx_Building_Refinery(GDI_Buildings[i].Building));
				}
			}

			For (i = 0; Nod_Buildings.Length > i; i++)
			{
				if (Nod_Buildings[i].Type == BT_Money && !Nod_Buildings[i].Building.IsDestroyed())
				{
					outArray.AddItem(Rx_Building_Refinery(Nod_Buildings[i].Building));
				}
			}
			return outArray;

		default:
			ScriptTrace();
			`log("Rx_BuildingManager::GetBuildingByType WARNING UNOWNED TEAM ATTEMPTED CALL");
}