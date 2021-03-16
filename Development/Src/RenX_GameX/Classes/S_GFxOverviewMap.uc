class S_GFxOverviewMap extends Rx_GFxOverviewMap;

function UpdatePawnInfoCount()
{
	local array<class> GDIPlayerClasses, NodPlayerClasses; 
	local class			WorkingClass;
	local PlayerReplicationInfo PRII; 
	local byte team_num;

	local int gdi_spiesCount, nod_spiesCount; 
	//TODO: Iterate once and get all info from there

	foreach ThisWorld.GRI.PRIArray(PRII) {
	
		if(Rx_PRI(PRII) == none) 
			continue; 
		
		WorkingClass = Rx_PRI(PRII).GetPawnClass(); 
		
		if(WorkingClass == none) 
			continue; 

		team_num = PRII.GetTeamNum(); 
		
		switch (team_num){
			case TEAM_GDI:
				if(Rx_PRI(PRII).isSpy()) {
					gdi_spiesCount++;
					break;
				}
				GDIPlayerClasses.AddItem(WorkingClass);
				break;
		
			case TEAM_NOD:
				if(Rx_PRI(PRII).isSpy()) {
						nod_spiesCount++;
						break;
					}
				NodPlayerClasses.AddItem(WorkingClass);
				break;
		}
	}
	switch (GetPC().GetTeamNum())
	{
		case TEAM_GDI:
			    SetInfoLabelCount (gdi_soldier, GetNumOf(class'S_FamilyInfo_BlackHand_Soldier', GDIPlayerClasses));
				SetInfoLabelCount (gdi_shotgunner, GetNumOf(class'S_FamilyInfo_BlackHand_Shotgunner', GDIPlayerClasses));
				SetInfoLabelCount (gdi_grenadier, GetNumOf(class'S_FamilyInfo_BlackHand_FlameTrooper', GDIPlayerClasses));
				SetInfoLabelCount (gdi_marksman, GetNumOf(class'S_FamilyInfo_BlackHand_Marksman', GDIPlayerClasses));
				SetInfoLabelCount (gdi_engineer, GetNumOf(class'S_FamilyInfo_BlackHand_Engineer', GDIPlayerClasses));
				SetInfoLabelCount (gdi_officer, GetNumOf(class'S_FamilyInfo_BlackHand_Officer', GDIPlayerClasses));
				SetInfoLabelCount (gdi_rocket_soldier, GetNumOf(class'S_FamilyInfo_BlackHand_RocketSoldier', GDIPlayerClasses));
				SetInfoLabelCount (gdi_mcfarland, GetNumOf(class'S_FamilyInfo_BlackHand_ChemicalTrooper', GDIPlayerClasses));
				SetInfoLabelCount (gdi_gunner, GetNumOf(class'S_FamilyInfo_BlackHand_BlackhandSniper', GDIPlayerClasses));
				SetInfoLabelCount (gdi_patch, GetNumOf(class'S_FamilyInfo_BlackHand_StealthBlackhand', GDIPlayerClasses));
				SetInfoLabelCount (gdi_deadeye, GetNumOf(class'S_FamilyInfo_BlackHand_LaserChainGunner', GDIPlayerClasses));
				SetInfoLabelCount (gdi_havoc, GetNumOf(class'S_FamilyInfo_BlackHand_Sakura', GDIPlayerClasses));
				SetInfoLabelCount (gdi_sydney, GetNumOf(class'S_FamilyInfo_BlackHand_Raveshaw', GDIPlayerClasses));
				SetInfoLabelCount (gdi_mobius, GetNumOf(class'S_FamilyInfo_BlackHand_Mendoza', GDIPlayerClasses));
				SetInfoLabelCount (gdi_hotwire, GetNumOf(class'S_FamilyInfo_BlackHand_Technician', GDIPlayerClasses));
				SetInfoLabelCount (gdi_spies, gdi_spiesCount);
				SetInfoLabelCount (humvee, GetNumOf(class'S_Vehicle_Buggy', GDIPlayerClasses) + GetNumOf(class'Rx_Vehicle_Buggy', GDIPlayerClasses));
				SetInfoLabelCount (gdi_apc, GetNumOf(class'S_Vehicle_APC', GDIPlayerClasses) + GetNumOf(class'Rx_Vehicle_APC_Nod', GDIPlayerClasses));
				SetInfoLabelCount (mrls, GetNumOf(class'S_Vehicle_Artillery', GDIPlayerClasses) + GetNumOf(class'Rx_Vehicle_Artillery', GDIPlayerClasses));
				SetInfoLabelCount (medium_tank, GetNumOf(class'S_Vehicle_FlameTank', GDIPlayerClasses) + GetNumOf(class'Rx_Vehicle_FlameTank', GDIPlayerClasses));
				SetInfoLabelCount (mammoth_tank, GetNumOf(class'S_Vehicle_LightTank', GDIPlayerClasses) + GetNumOf(class'Rx_Vehicle_LightTank', GDIPlayerClasses));
				SetInfoLabelCount (gdi_chinook, GetNumOf(class'S_Vehicle_StealthTank', GDIPlayerClasses) + GetNumOf(class'Rx_Vehicle_StealthTank', GDIPlayerClasses));
				SetInfoLabelCount (orca, GetNumOf(class'S_Vehicle_Apache', GDIPlayerClasses) + GetNumOf(class'Rx_Vehicle_Apache', GDIPlayerClasses));
				//SetInfoLabelCount (gdi_other, gdi_otherCount);
			break;
		case TEAM_NOD:
				SetInfoLabelCount (nod_soldier, GetNumOf(class'Rx_FamilyInfo_Nod_Soldier', NodPlayerClasses));
				SetInfoLabelCount (nod_shotgunner, GetNumOf(class'Rx_FamilyInfo_Nod_Shotgunner', NodPlayerClasses));
				SetInfoLabelCount (nod_flame_trooper, GetNumOf(class'Rx_FamilyInfo_Nod_FlameTrooper', NodPlayerClasses));
				SetInfoLabelCount (nod_marksman, GetNumOf(class'Rx_FamilyInfo_Nod_Marksman', NodPlayerClasses));
				SetInfoLabelCount (nod_engineer, GetNumOf(class'Rx_FamilyInfo_Nod_Engineer', NodPlayerClasses));
				SetInfoLabelCount (nod_officer, GetNumOf(class'Rx_FamilyInfo_Nod_Officer', NodPlayerClasses));
				SetInfoLabelCount (nod_rocket_soldier, GetNumOf(class'Rx_FamilyInfo_Nod_RocketSoldier', NodPlayerClasses));
				SetInfoLabelCount (nod_chemical_trooper, GetNumOf(class'Rx_FamilyInfo_Nod_ChemicalTrooper', NodPlayerClasses));
				SetInfoLabelCount (nod_blackhand_sniper, GetNumOf(class'Rx_FamilyInfo_Nod_BlackHandSniper', NodPlayerClasses));
				SetInfoLabelCount (nod_stealth_blackhand, GetNumOf(class'Rx_FamilyInfo_Nod_StealthBlackHand', NodPlayerClasses));
				SetInfoLabelCount (nod_laser_chaingunner, GetNumOf(class'Rx_FamilyInfo_Nod_LaserChainGunner', NodPlayerClasses));
				SetInfoLabelCount (nod_sakura, GetNumOf(class'Rx_FamilyInfo_Nod_Sakura', NodPlayerClasses));
				SetInfoLabelCount (nod_ravenshaw, GetNumOf(class'Rx_FamilyInfo_Nod_Raveshaw', NodPlayerClasses));
				SetInfoLabelCount (nod_mendoza, GetNumOf(class'Rx_FamilyInfo_Nod_Mendoza', NodPlayerClasses));
				SetInfoLabelCount (nod_technician, GetNumOf(class'Rx_FamilyInfo_Nod_Technician', NodPlayerClasses));
				SetInfoLabelCount (nod_spies, nod_spiesCount);
				SetInfoLabelCount (buggy, GetNumOf(class'Rx_Vehicle_Buggy', NodPlayerClasses) + GetNumOf(class'S_Vehicle_Buggy', NodPlayerClasses));
				SetInfoLabelCount (nod_apc, GetNumOf(class'Rx_Vehicle_APC_Nod', NodPlayerClasses) + GetNumOf(class'S_Vehicle_APC', NodPlayerClasses));
				SetInfoLabelCount (artillery, GetNumOf(class'Rx_Vehicle_Artillery', NodPlayerClasses) + GetNumOf(class'S_Vehicle_Artillery', NodPlayerClasses));
				SetInfoLabelCount (flame_tank, GetNumOf(class'Rx_Vehicle_FlameTank', NodPlayerClasses) + GetNumOf(class'S_Vehicle_FlameTank', NodPlayerClasses));
				SetInfoLabelCount (light_tank, GetNumOf(class'Rx_Vehicle_LightTank', NodPlayerClasses) + GetNumOf(class'S_Vehicle_LightTank', NodPlayerClasses));
				SetInfoLabelCount (stealth_tank, GetNumOf(class'Rx_Vehicle_StealthTank', NodPlayerClasses) + GetNumOf(class'S_Vehicle_StealthTank', NodPlayerClasses));
				SetInfoLabelCount (nod_chinook, GetNumOf(class'Rx_Vehicle_Chinook_Nod', NodPlayerClasses) + GetNumOf(class'S_Vehicle_Chinook', NodPlayerClasses));
				SetInfoLabelCount (apache, GetNumOf(class'Rx_Vehicle_Apache', NodPlayerClasses) + GetNumOf(class'S_Vehicle_Apache', NodPlayerClasses));
				//SetInfoLabelCount (nod_other, nod_otherCount);
			break;
	}
}

function array<GFxObject> GenGDIIcons(int IconCount, optional bool bSquad)
{
	local ASColorTransform ColorTransform;
   	local array<GFxObject> Icons;
   	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("FriendlyBlips", "GDI_Player"$IconsFriendlyCount++);
		//@roxez: Debugging blips
        //IconMC = icons_Friendly.AttachMovie("DebugBlips", "GDI_Player"$IconsFriendlyCount++);
        ColorTransform.multiply.R = 0.25;
		ColorTransform.multiply.G = 0.25;
		ColorTransform.multiply.B = 0.25;
		ColorTransform.add.R = 0.0;
		ColorTransform.add.G = 0.0;
		ColorTransform.add.B = 0.75;
		IconMC.SetColorTransform(ColorTransform);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenGDIVehicleIcons(int IconCount, optional bool bSquad)
{
	local ASColorTransform ColorTransform;
   	local array<GFxObject> Icons;
   	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("VehicleMarker", "GDI_Vehicle"$IconsVehicleFriendlyCount++);
		ColorTransform.multiply.R = 0.25;
		ColorTransform.multiply.G = 0.25;
		ColorTransform.multiply.B = 0.25;
		ColorTransform.add.R = 0.0;
		ColorTransform.add.G = 0.0;
		ColorTransform.add.B = 0.75;
		IconMC.SetColorTransform(ColorTransform);
        Icons[i] = IconMC;
    }
    return Icons;
}

function UpdateTechIcons()
{
	local Vector TempIconLoc;
	local ASColorTransform CT;
	local int i;
	local ASDisplayInfo DI;

	DI.HasY = true;
	DI.HasX = true;
	DI.HasXScale = true;
	DI.HasYScale = true;
	DI.XScale = 150.f;
	DI.YScale = 150.f;

	for(i=0;i < TechList.length;i++)
	{
		TempIconLoc = TransformVector(IconMatrix, TechList[i].Building.Location);



		if(TechList[i].IconLoc.X != TempIconLoc.X || TechList[i].IconLoc.Y != TempIconLoc.Y)
		{
			TechList[i].IconLoc.X = TempIconLoc.X;
			TechList[i].IconLoc.Y = TempIconLoc.Y;
			DI.X = TempIconLoc.X;
			DI.Y = TempIconLoc.Y;

			`log(TechList[i].Building@"icon replaced on coordinate X:"$(TempIconLoc.X)$"Y"$(TempIconLoc.Y));
			TechList[i].TechIcon.SetDisplayInfo(DI);
			TechList[i].TechIcon.SetVisible(True);

			LoadTexture("img://" $ PathName(TechList[i].Building.IconTexture), TechList[i].TechIcon);
		}


		if(TechList[i].Building.GetTeamNum() != TechList[i].TeamOwner)
		{
			if(TechList[i].Building.GetTeamNum() == 0)
			{
				CT.multiply.R = 0.f;
				CT.multiply.G = 0.f;
				CT.multiply.B = 0.25f;
				CT.add.R = 0.f;
				CT.add.G = 0.f;
				CT.add.B = 0.75f;			
				TechList[i].TechIcon.SetColorTransform(CT);
			}
			else if(TechList[i].Building.GetTeamNum() == 1)
			{
				CT.multiply.R = 1.f;
				CT.multiply.G = 0.f;
				CT.multiply.B = 0.f;
				CT.add.R = 0.25;
				CT.add.G = 0.f;
				CT.add.B = 0.f;
				TechList[i].TechIcon.SetColorTransform(CT);
			}			
			else
			{
				CT.multiply.R = 1.f;
				CT.multiply.G = 1.f;
				CT.multiply.B = 1.f;
				CT.add.R = 0.f;
				CT.add.G = 0.f;
				CT.add.B = 0.f;
				TechList[i].TechIcon.SetColorTransform(CT);
			}			
		}
	}
}

function int GetBuildingPicIndex(Rx_Building B)
{
	if(Rx_Building_Nod_InfantryFactory(B) != None || Rx_Building_GDI_InfantryFactory(B) != None) return 4;
	if(Rx_Building_Nod_VehicleFactory(B) != None || Rx_Building_GDI_VehicleFactory(B) != None) return 2;
	if(Rx_Building_Nod_MoneyFactory(B) != None || Rx_Building_GDI_MoneyFactory(B) != None) return 7;
	if(Rx_Building_Nod_PowerFactory(B) != None || Rx_Building_GDI_PowerFactory(B) != None) return 6;
	if(Rx_Building_Nod_Defense(B) != None || Rx_Building_GDI_Defense(B) != None) return 5;
	return -1;
}

function SetInfrantryGfxObjects()
{
	infrantry_class_info = GetVariableObject("_root.infrantry_class_info");

	infrantry_class_info.GotoAndStopI(1);
    gdi_soldier = GetVariableObject("_root.infrantry_class_info.gdi_soldier");
    gdi_shotgunner = GetVariableObject("_root.infrantry_class_info.gdi_shotgunner");
    gdi_grenadier = GetVariableObject("_root.infrantry_class_info.gdi_grenadier");
    gdi_marksman = GetVariableObject("_root.infrantry_class_info.gdi_marksman");
    gdi_engineer = GetVariableObject("_root.infrantry_class_info.gdi_engineer");
    gdi_officer = GetVariableObject("_root.infrantry_class_info.gdi_officer");
    gdi_rocket_soldier = GetVariableObject("_root.infrantry_class_info.gdi_rocket_soldier");
    gdi_mcfarland = GetVariableObject("_root.infrantry_class_info.mcfarland");
    gdi_gunner = GetVariableObject("_root.infrantry_class_info.gunner");
    gdi_patch = GetVariableObject("_root.infrantry_class_info.patch");
    gdi_deadeye = GetVariableObject("_root.infrantry_class_info.deadeye");
    gdi_havoc = GetVariableObject("_root.infrantry_class_info.havoc");
    gdi_sydney = GetVariableObject("_root.infrantry_class_info.sydney");
    gdi_mobius = GetVariableObject("_root.infrantry_class_info.mobius");
    gdi_hotwire = GetVariableObject("_root.infrantry_class_info.hotwire");
    gdi_spies = GetVariableObject("_root.infrantry_class_info.gdi_spies");

	infrantry_class_info.GotoAndStopI(2);
	
    nod_soldier = GetVariableObject("_root.infrantry_class_info.nod_soldier");
    nod_shotgunner = GetVariableObject("_root.infrantry_class_info.nod_shotgunner");
    nod_flame_trooper = GetVariableObject("_root.infrantry_class_info.flame_trooper");
    nod_marksman = GetVariableObject("_root.infrantry_class_info.nod_marksman");
    nod_engineer = GetVariableObject("_root.infrantry_class_info.nod_engineer");
    nod_officer = GetVariableObject("_root.infrantry_class_info.nod_officer");
    nod_rocket_soldier = GetVariableObject("_root.infrantry_class_info.nod_rocket_soldier");
    nod_chemical_trooper = GetVariableObject("_root.infrantry_class_info.chemical_trooper");
    nod_blackhand_sniper = GetVariableObject("_root.infrantry_class_info.blackhand_sniper");
    nod_stealth_blackhand = GetVariableObject("_root.infrantry_class_info.stealth_blackhand");
    nod_laser_chaingunner = GetVariableObject("_root.infrantry_class_info.laser_chaingunner");
    nod_sakura = GetVariableObject("_root.infrantry_class_info.sakura");
    nod_ravenshaw = GetVariableObject("_root.infrantry_class_info.ravenshaw");
    nod_mendoza = GetVariableObject("_root.infrantry_class_info.mendoza");
    nod_technician = GetVariableObject("_root.infrantry_class_info.technician");
    nod_spies = GetVariableObject("_root.infrantry_class_info.nod_spies");

	
	infrantry_class_info.GotoAndStopI(GetPC().PlayerReplicationInfo.GetTeamNum() + 1);
	if (GetPC().PlayerReplicationInfo.GetTeamNum() == TEAM_GDI) {
		SetInfoLabelName(gdi_soldier, "Soldier");
		SetInfoLabelName(gdi_shotgunner, "Shotgunner");
		SetInfoLabelName(gdi_grenadier, "Flame Trooper");
		SetInfoLabelName(gdi_marksman, "Marksman");
		SetInfoLabelName(gdi_engineer, "Engineer");
		SetInfoLabelName(gdi_officer, "Officer");
		SetInfoLabelName(gdi_rocket_soldier, "Rocket Soldier");
		SetInfoLabelName(gdi_mcfarland, "Chemical Trooper");
		SetInfoLabelName(gdi_gunner, "Black Hand Sniper");
		SetInfoLabelName(gdi_patch, "Stealth Black Hand");
		SetInfoLabelName(gdi_deadeye, "Laser Chaingunner");
		SetInfoLabelName(gdi_havoc, "Sakura");
		SetInfoLabelName(gdi_sydney, "Raveshaw");
		SetInfoLabelName(gdi_mobius, "Mendoza");
		SetInfoLabelName(gdi_hotwire, "Technician");
		SetInfoLabelName(gdi_spies, "Spies");
	} else {
		SetInfoLabelName(nod_soldier, "Soldier");
		SetInfoLabelName(nod_shotgunner, "Shotgunner");
		SetInfoLabelName(nod_flame_trooper, "Flame Trooper");
		SetInfoLabelName(nod_marksman, "Marksman");
		SetInfoLabelName(nod_engineer, "Engineer");
		SetInfoLabelName(nod_officer, "Officer");
		SetInfoLabelName(nod_rocket_soldier, "Rocket Soldier");
		SetInfoLabelName(nod_chemical_trooper, "Chemical Trooper");
		SetInfoLabelName(nod_blackhand_sniper, "Black Hand Sniper");
		SetInfoLabelName(nod_stealth_blackhand, "Stealth Black Hand");
		SetInfoLabelName(nod_laser_chaingunner, "Laser Chaingunner");
		SetInfoLabelName(nod_sakura, "Sakura");
		SetInfoLabelName(nod_ravenshaw, "Raveshaw");
		SetInfoLabelName(nod_mendoza, "Mendoza");
		SetInfoLabelName(nod_technician, "Technician");
		SetInfoLabelName(nod_spies, "Spies");
	}
}


function SetVehicleGfxObjects() 
{
	vehicle_class_info = GetVariableObject("_root.vehicle_class_info");
	//_root.vehicle_class_info.*
	vehicle_class_info.GotoAndStopI(1);
    humvee = GetVariableObject("_root.vehicle_class_info.humvee");    
    gdi_apc = GetVariableObject("_root.vehicle_class_info.apc");    
    mrls = GetVariableObject("_root.vehicle_class_info.mrls");    
    medium_tank = GetVariableObject("_root.vehicle_class_info.medium_tank");    
    mammoth_tank = GetVariableObject("_root.vehicle_class_info.mammoth_tank");    
    gdi_chinook = GetVariableObject("_root.vehicle_class_info.chinook");    
    orca = GetVariableObject("_root.vehicle_class_info.orca");        
    gdi_other = GetVariableObject("_root.vehicle_class_info.crate");

	vehicle_class_info.GotoAndStopI(2);
    buggy = GetVariableObject("_root.vehicle_class_info.buggy");
    nod_apc = GetVariableObject("_root.vehicle_class_info.apc");
    artillery = GetVariableObject("_root.vehicle_class_info.artillery");
    flame_tank = GetVariableObject("_root.vehicle_class_info.flame_tank");
    light_tank = GetVariableObject("_root.vehicle_class_info.light_tank");
    stealth_tank = GetVariableObject("_root.vehicle_class_info.stealth_tank");
    nod_chinook = GetVariableObject("_root.vehicle_class_info.chinook");
    apache = GetVariableObject("_root.vehicle_class_info.apache");
    nod_other = GetVariableObject("_root.vehicle_class_info.crate");

	
	vehicle_class_info.GotoAndStopI(GetPC().PlayerReplicationInfo.GetTeamNum() + 1);
	if (GetPC().PlayerReplicationInfo.GetTeamNum() == TEAM_GDI) {
		SetInfoLabelName(humvee, "Buggy");
		SetInfoLabelName(gdi_apc, "APC");
		SetInfoLabelName(mrls, "Artillery");
		SetInfoLabelName(medium_tank, "Flame Tank");
		SetInfoLabelName(mammoth_tank, "Light Tank");
		SetInfoLabelName(gdi_chinook, "Stealth Tank");
		SetInfoLabelName(orca, "Apache");
		SetInfoLabelName(gdi_other, "Other");
	} else {
		 SetInfoLabelName(buggy, "Buggy");
		 SetInfoLabelName(nod_apc, "APC");
		 SetInfoLabelName(artillery, "Artillery");
		 SetInfoLabelName(flame_tank, "Flame Tank");
		 SetInfoLabelName(light_tank, "Light Tank");
		 SetInfoLabelName(stealth_tank, "Stealth Tank");
		 SetInfoLabelName(nod_chinook, "Transport Helicopter");
		 SetInfoLabelName(apache, "Apache");
		 SetInfoLabelName(nod_other, "Other");
	}
}


function SetTechBuildingMapGfxObjects()
{
	local Rx_Building_Techbuilding Tech;
	local TechStatus TempTechStatus;
	local ASColorTransform CT;

	if(Rx_HUD(RxPC.myHUD).TechBuildings.Length <= 0)
	{
		`log("Map cannot find tech buildings, aborting");
		return;
	}

	foreach Rx_HUD(RxPC.myHUD).TechBuildings(Tech)
	{
		TempTechStatus.Building = Tech;
		TempTechStatus.TeamOwner = Tech.GetTeamNum();
		TempTechStatus.TechIcon = icons_TechBuilding.AttachMovie("TechBlips","TechBuilding"$(TechList.Length + 1));
		TempTechStatus.TechIcon.SetVisible(true);

		if(TempTechStatus.Building.GetTeamNum() == 0)
		{
			CT.multiply.R = 0.25;
			CT.multiply.G = 0.25;
			CT.multiply.B = 0.25;
			CT.add.R = 0;
			CT.add.G = 0;
			CT.add.B = 0.75;			
			TempTechStatus.TechIcon.SetColorTransform(CT);
		}
		else if(TempTechStatus.Building.GetTeamNum() == 1)
		{
			CT.multiply.R = 0.25;
			CT.multiply.G = 0.25;
			CT.multiply.B = 0.25;
			CT.add.R = 0.75;
			CT.add.G = 0;
			CT.add.B = 0;
			TempTechStatus.TechIcon.SetColorTransform(CT);
		}

		TechList.AddItem(TempTechStatus);
	}
}
