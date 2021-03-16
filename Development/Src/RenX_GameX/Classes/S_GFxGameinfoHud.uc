class S_GFxGameinfoHud extends Rx_GFxGameinfoHud;

function bool IsBuildingAmountMismatched()
{
	local int BuildingAmount;
	local Rx_Building Building;


	foreach GetPC().WorldInfo.AllActors(class'Rx_Building', Building)
	{
		if(Rx_Building_Team_Internals(Building.BuildingInternals) == None || !Building.bSignificant)
			continue;

		if(Rx_Building_TechBuilding(Building) != None)
			continue;

		if(Rx_Building_AirTower(Building) != None)
			continue;	// also don't count the tower and instead take from the Strip

		if(S_Building_AirTower_BlackHand(Building) != None)
			continue;	// also don't count the tower and instead take from the Strip

		BuildingAmount++;
		// start counting
	}

	if(BuildingInfo_GDI.Length + BuildingInfo_Nod.Length != BuildingAmount)
	{
		`log("Client has run into a mismatch, resetting building informations....");
		return true;
	}


	return false;
}

function SetupBuildings()
{
	local Rx_Building Building;
	local BuildingInfo CurrentBuilding;
	local float BuildPosX,BuildPosY;
	local Array<Rx_Building> BList;
	local Vector BLocs;
	local Array<BuildingInfo> BuildingInfo_GDI_OLD;
	local Array<BuildingInfo> BuildingInfo_Nod_OLD;

	if(bBuildingSetup)
		return;

	bBuildingSetup = true;

	if(BuildingInfo_GDI.Length > 0)
		BuildingInfo_GDI_OLD = BuildingInfo_GDI;

	if(BuildingInfo_Nod.Length > 0)
		BuildingInfo_Nod_OLD = BuildingInfo_Nod;

	BuildingInfo_GDI.Length = 0;
	BuildingInfo_Nod.Length = 0;

	foreach GetPC().WorldInfo.AllActors(class'Rx_Building', Building)
	{
		if(Rx_Building_Team_Internals(Building.BuildingInternals) == None || !Building.bSignificant)
			continue;

		if(Rx_Building_TechBuilding(Building) != None)
			continue;

		if(Rx_Building_AirTower(Building) != None)
			continue;	// also don't count the tower and instead take from the Strip

		if(S_Building_AirTower_BlackHand(Building) != None)
			continue;	// also don't count the tower and instead take from the Strip

		BList.AddItem(Building);
		BLocs += Building.Location;

		// cache these in our parent HUD for later use...
	}
	if(BList.Length <= 0)
		return;

	BuildingDistanceAverage = BLocs / BList.Length;

	BList.Sort(SortBuildingDelegate);

	foreach BList(Building)
	{
		// Don't list tech buildings and insignificant ones


		CurrentBuilding.RelatedBuilding = Building;
		CurrentBuilding.LastArmor = Building.GetArmor();
		CurrentBuilding.LastHealth = Building.GetHealth();

		if(Building.GetTeamNum() == 0)
		{
			if(BuildingInfo_GDI.length + 1 <= BuildingInfo_GDI_OLD.Length)
				CurrentBuilding.Icon = BuildingInfo_GDI_OLD[BuildingInfo_GDI.length].Icon;
			else	
				CurrentBuilding.Icon = SBBuildContainer[0].AttachMovie("BuildingInfo_Icon", "GDIBuilding"$BuildingInfo_GDI.Length);
			
			LoadTexture("img://" $ PathName(Building.IconTexture), CurrentBuilding.Icon);

			BuildPosX = 0 - (25 * (BuildingInfo_GDI.Length));
			BuildPosY = 0;

			CurrentBuilding.Icon.SetPosition(BuildPosX, BuildPosY);
			CurrentBuilding.LastStatus = AssessBuildingStatus(CurrentBuilding.RelatedBuilding);
			CurrentBuilding.Icon.SetColorTransform(BColor[CurrentBuilding.LastStatus]);
			BuildingInfo_GDI.AddItem(CurrentBuilding);
		}

		else if (Building.GetTeamNum() == 1)
		{
			if(BuildingInfo_Nod.length + 1 <= BuildingInfo_Nod_OLD.Length)
				CurrentBuilding.Icon = BuildingInfo_Nod_OLD[BuildingInfo_Nod.length].Icon;
			else	
				CurrentBuilding.Icon = SBBuildContainer[1].AttachMovie("BuildingInfo_Icon", "NodBuilding"$BuildingInfo_Nod.Length);
			LoadTexture("img://" $ PathName(Building.IconTexture), CurrentBuilding.Icon);

			BuildPosX = 0 + (25 * (BuildingInfo_Nod.Length));
			BuildPosY = 0;

			CurrentBuilding.Icon.SetPosition(BuildPosX, BuildPosY);
			CurrentBuilding.LastStatus = AssessBuildingStatus(CurrentBuilding.RelatedBuilding);
			CurrentBuilding.Icon.SetColorTransform(BColor[CurrentBuilding.LastStatus]);
			BuildingInfo_Nod.AddItem(CurrentBuilding);
		}
	}
}

DefaultProperties
{
	MovieInfo           = SwfMovie'SXHud.SGameinfoHud'
}