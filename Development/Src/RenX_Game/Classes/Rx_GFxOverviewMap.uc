class Rx_GFxOverviewMap extends GFxMoviePlayer;


var		 Rx_GfxHUD               RxHUD;
var		 WorldInfo				 ThisWorld;
var		 Rx_MapInfo				 RxMapInfo;
var		 int                     MapTexSize;
var      float                   MapContainerSize;
var		 float 					 MapScaling; //Used to control the zooming in of the map -to correct small maps showing up too small on the map overview' 
var      Rx_Controller           RxPC;
var		 matrix                  IconMatrix;

var array<Rx_UIDataProvider_MapInfo> MapDataProviderList; //Used to get the map name for the overview map.

var bool HasRunOnce;
var bool HasRunDelayTick;


var GFxObject RootMC;

var GFxObject buildings[10];
var GFxObject buildingsHp[10];
var GFxObject buildingsAp[10];
var GFxObject buildingsStatus[10];


//_root.overview_map.icons_nav
var		 GFxObject               icons_NavMarker;
//_root.overview_map.icons_Neutral
var		 GFxObject               icons_Neutral;
//_root.overview_map.icons_Nod
var		 GFxObject               icons_Enemy;
//_root.overview_map.icons_GDI
var		 GFxObject               icons_Friendly;
//_root.overview_map.icons_NeutralVehicle
var		 GFxObject               icons_NeutralVehicle;
//_root.overview_map.icons_NodVehicle
var		 GFxObject               icons_NodVehicle;
//_root.overview_map.icons_GDIVehicle
var		 GFxObject               icons_GDIVehicle;
// player blip
var		 GFxObject               player_icon;
//_root.overview_map.map
var		 GFxObject               map;

//_root.map_name.title
var GFxObject 					 map_name;

var GfxObject infrantry_class_info, vehicle_class_info ;
var GfxObject gdi_soldier, gdi_shotgunner, gdi_grenadier, gdi_marksman, gdi_engineer, gdi_officer, gdi_rocket_soldier, gdi_mcfarland, gdi_gunner, gdi_patch, gdi_deadeye, gdi_havoc, gdi_sydney, gdi_mobius, gdi_hotwire, gdi_spies;
var GfxObject nod_soldier, nod_shotgunner, nod_flame_trooper, nod_marksman, nod_engineer, nod_officer, nod_rocket_soldier, nod_chemical_trooper, nod_blackhand_sniper, nod_stealth_blackhand, nod_laser_chaingunner, nod_sakura, nod_ravenshaw, nod_mendoza, nod_technician, nod_spies;

var GFxObject humvee, gdi_apc, mrls, medium_tank, mammoth_tank, gdi_chinook, orca, gdi_other;
var GFxObject buggy, nod_apc, artillery, flame_tank, light_tank, stealth_tank, nod_chinook, apache, nod_other;

var		 array<GFxObject>        GDITeamIcons;
var		 array<GFxObject>        GDIVehicleIcons;
var		 array<GFxObject>        NodTeamIcons;
var		 array<GFxObject>        NodVehicleIcons;
var		 array<GFxObject>        NeutralIcons;
var		 array<GFxObject>        NeutralVehicleIcons;

var		 int                     IconsEnemyCount;
var		 int                     IconsVehicleEnemyCount;
var		 int                     IconsFriendlyCount;
var		 int                     IconsVehicleFriendlyCount;
var		 int                     IconsNeutralCount;
var		 int                     IconsVehicleNeutralCount;

var		 float                   IconRotationOffset;

var      int                     beaconStar;//nBab

/**Use this only for debugging blips*/
var     Texture                 DebugBlipTexture;

function bool Start(optional bool StartPaused = false)
{
	super.Start();
	Advance(0);
	SetAlignment(Align_Center);
	SetViewScaleMode(SM_ShowAll);

	RxPC                 =  Rx_Controller(GetPC());
	RxHUD				 =	Rx_HUD(RxPC.myHUD).HUDMovie ; 
	ThisWorld            =  RxPC.WorldInfo;
	RxMapInfo            =  Rx_MapInfo(ThisWorld.GetMapInfo());

	RunOnce();

	return true;
}

function RunOnce()
{
	if (!HasRunOnce) {
		HasRunOnce = true;
		RootMC = GetVariableObject("_root");
		SetBuildingGfxObjects();
		SetInfrantryGfxObjects();
		SetVehicleGfxObjects();
		SetOverviewMapGfxObjects();
		map_name = GetVariableObject("_root.map_name.title"); //Grab our map name text object on the overview map.
		map_name.SetText(GetMapFriendlyName(ThisWorld.GetMapName())); //Set our map name on the overview map.
		MapScaling=RxMapInfo.OverviewScale; 

	}
}

function Update() 
{
	local byte i;
	local Rx_Building B;
	local int health;
	local int armor;

	if (!bMovieIsOpen) {
		return;
	}

	for (i = 0; i < 10 ; i++) {
		buildings[i].SetVisible(false);
	}
	
	foreach GetPC().AllActors(class'Rx_Building', B) {
		if(GetBuildingIndex(B) == -1 || !B.bSignificant) {
			continue;
		}
		
		buildings[GetBuildingIndex(B)].SetVisible(true);
		health = Float(B.GetHealth())/Float(B.GetTrueMaxHealth())*100.0;
		if (B.GetMaxArmor() != 0) {
			armor = Float(B.GetArmor())/Float(B.GetMaxArmor())*100.0; 
		}
		if(health <= 0 && Armor <=0) {
			buildings[GetBuildingIndex(B)].GotoAndStopI(2);
		} else {
			buildingsHp[GetBuildingIndex(B)].GotoAndStopI(health);
			buildingsAp[GetBuildingIndex(B)].GotoAndStopI(armor);
		}
		buildingsStatus[GetBuildingIndex(B)].GotoAndStopI(GetBuildingPicIndex(B));
	}	


	//HasRunDelayTick = true;
	UpdateMapTexture();
	TestIconmatrix();
	UpdatePawnInfoCount();
	UpdatePlayerBlip();
	UpdateActorBlips();
	// Generate markers for other pawns
}

function TestIconmatrix() 
{
	local float Scale;

	local float f;

	if (RxMapInfo == none)
		return;

	Scale = (MapTexSize * RxMapInfo.MinimapNormalZoom) / (2 * RxMapInfo.MinimapCurrentZoom * RxMapInfo.MapExtent);

	f = -((/*RxPC.Rotation.Yaw*/0 + 16384) & 65535) * (Pi/32768.0);
	IconMatrix.XPlane.X = cos(f) * Scale; // Unused?
	IconMatrix.XPlane.Y = sin(f) * Scale; // Vertical
	IconMatrix.YPlane.X = -sin(f) * Scale; // Horizontal
	IconMatrix.YPlane.Y = cos(f) * Scale; // Unused?
	IconMatrix.WPlane.X = 0;
	IconMatrix.WPlane.Y = 0;
	IconMatrix.WPlane.Z = 0;
	IconMatrix.WPlane.W = 1;
    IconMatrix.WPlane = TransformVector(IconMatrix, -RxMapInfo.MapCenter);
}
function UpdatePawnInfoCount(  )
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
				    SetInfoLabelCount (gdi_soldier, GetNumOf(class'Rx_FamilyInfo_GDI_Soldier', GDIPlayerClasses));
					SetInfoLabelCount (gdi_shotgunner, GetNumOf(class'Rx_FamilyInfo_GDI_Shotgunner', GDIPlayerClasses));
					SetInfoLabelCount (gdi_grenadier, GetNumOf(class'Rx_FamilyInfo_GDI_Grenadier', GDIPlayerClasses));
					SetInfoLabelCount (gdi_marksman, GetNumOf(class'Rx_FamilyInfo_GDI_Marksman', GDIPlayerClasses));
					SetInfoLabelCount (gdi_engineer, GetNumOf(class'Rx_FamilyInfo_GDI_Engineer', GDIPlayerClasses));
					SetInfoLabelCount (gdi_officer, GetNumOf(class'Rx_FamilyInfo_GDI_Officer', GDIPlayerClasses));
					SetInfoLabelCount (gdi_rocket_soldier, GetNumOf(class'Rx_FamilyInfo_GDI_RocketSoldier', GDIPlayerClasses));
					SetInfoLabelCount (gdi_mcfarland, GetNumOf(class'Rx_FamilyInfo_GDI_McFarland', GDIPlayerClasses));
					SetInfoLabelCount (gdi_gunner, GetNumOf(class'Rx_FamilyInfo_GDI_Gunner', GDIPlayerClasses));
					SetInfoLabelCount (gdi_patch, GetNumOf(class'Rx_FamilyInfo_GDI_Patch', GDIPlayerClasses));
					SetInfoLabelCount (gdi_deadeye, GetNumOf(class'Rx_FamilyInfo_GDI_Deadeye', GDIPlayerClasses));
					SetInfoLabelCount (gdi_havoc, GetNumOf(class'Rx_FamilyInfo_GDI_Havoc', GDIPlayerClasses));
					SetInfoLabelCount (gdi_sydney, GetNumOf(class'Rx_FamilyInfo_GDI_Sydney', GDIPlayerClasses));
					SetInfoLabelCount (gdi_mobius, GetNumOf(class'Rx_FamilyInfo_GDI_Mobius', GDIPlayerClasses));
					SetInfoLabelCount (gdi_hotwire, GetNumOf(class'Rx_FamilyInfo_GDI_Hotwire', GDIPlayerClasses));
					SetInfoLabelCount (gdi_spies, gdi_spiesCount);
					SetInfoLabelCount (humvee, GetNumOf(class'Rx_Vehicle_Humvee', GDIPlayerClasses));
					SetInfoLabelCount (gdi_apc, GetNumOf(class'Rx_Vehicle_APC_GDI', GDIPlayerClasses));
					SetInfoLabelCount (mrls, GetNumOf(class'Rx_Vehicle_MRLS', GDIPlayerClasses));
					SetInfoLabelCount (medium_tank, GetNumOf(class'Rx_Vehicle_MediumTank', GDIPlayerClasses));
					SetInfoLabelCount (mammoth_tank, GetNumOf(class'Rx_Vehicle_MammothTank', GDIPlayerClasses));
					SetInfoLabelCount (gdi_chinook, GetNumOf(class'Rx_Vehicle_Chinook_GDI', GDIPlayerClasses));
					SetInfoLabelCount (orca, GetNumOf(class'Rx_Vehicle_Orca', GDIPlayerClasses));
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
					SetInfoLabelCount (buggy, GetNumOf(class'Rx_Vehicle_Buggy', NodPlayerClasses));
					SetInfoLabelCount (nod_apc, GetNumOf(class'Rx_Vehicle_APC_Nod', NodPlayerClasses));
					SetInfoLabelCount (artillery, GetNumOf(class'Rx_Vehicle_Artillery', NodPlayerClasses));
					SetInfoLabelCount (flame_tank, GetNumOf(class'Rx_Vehicle_FlameTank', NodPlayerClasses));
					SetInfoLabelCount (light_tank, GetNumOf(class'Rx_Vehicle_LightTank', NodPlayerClasses));
					SetInfoLabelCount (stealth_tank, GetNumOf(class'Rx_Vehicle_StealthTank', NodPlayerClasses));
					SetInfoLabelCount (nod_chinook, GetNumOf(class'Rx_Vehicle_Chinook_Nod', NodPlayerClasses));
					SetInfoLabelCount (apache, GetNumOf(class'Rx_Vehicle_Apache', NodPlayerClasses));
					//SetInfoLabelCount (nod_other, nod_otherCount);
				break;
		}
}

function int GetNumOf(class ClassToFind, array<class> Classes, optional class VariantClass=none)
{
	local int count; 
	local class CI; 
	
	foreach Classes(CI){
		if(CI == ClassToFind || (VariantClass != none && CI == VariantClass))
			count++; 
	}
		return count;
}

function UpdateActorBlips()
{
	local Actor P;
	local RxIfc_RadarMarker Marker; 
	local ENUM_ICON IconType; 
	local byte TeamVisibility; 
	local Rx_GRI	rxGRI; 
	local PlayerReplicationInfo	RxPRI; 
	
	local array<PlayerReplicationInfo> IgnoredPRIs; //Don't double dip with PRIs in netplay / If the pawn exists just use its location, don't replicate with PRI;  
	local array<Actor> GDI;
	local array<Actor> GDIVehicle;
	local array<Actor> Nod;
	local array<Actor> NodVehicle;
	local array<Actor> Neutral;
	local array<Actor> NeutralVehicle;
	
	rxGRI = Rx_GRI(ThisWorld.GRI);
	
	foreach ThisWorld.DynamicActors(class'Actor', P, class'RxIfc_RadarMarker')
	{		
		Marker = RxIfc_RadarMarker(P);
		
		//`log(Marker.GetRadarVisibility())
		
		IconType = ENUM_ICON(Marker.GetRadarIconType());
		
		TeamVisibility = Marker.GetRadarVisibility();
		
		if(Marker.ForceVisible()) 
			TeamVisibility = 2; //Forced to be visible to all by some means 
		
		//PRIs handle replication of location for their pawns in netplay, unless their pawns exist on the client
		if(ThisWorld.NetMode == NM_Client && (Rx_Pawn(P) != none || Rx_Vehicle(P) != none))
		{
			if(Pawn(P).PlayerReplicationInfo != none){
				IgnoredPRIs.AddItem(Pawn(P).PlayerReplicationInfo);
			}
			if (
				P.bHidden 
				|| (TeamVisibility == 0)
				|| Pawn(P).DrivenVehicle != none
				|| P == Pawn(RxPC.ViewTarget)
				){
					continue;
				}			
		}
		else if(ThisWorld.NetMode == NM_Standalone) {
			if ( PlayerReplicationInfo(P) != none
				|| (TeamVisibility == 0)
				|| Pawn(P) != none && (Pawn(P).DrivenVehicle != none
				|| P == Pawn(RxPC.ViewTarget))
				){
					continue;
				}			
		}
		
		if(TeamVisibility == 0)
			continue; 
		
		switch (P.GetTeamNum())
		{
			case TEAM_GDI:
				if (IconType == ICON_INFANTRY)
				{
					GDI.AddItem(P);
				}
				else if (IconType == ICON_VEHICLE)
				{
					GDIVehicle.AddItem(P);
				}
				else if (IconType == ICON_MISC)
				{
					NeutralVehicle.AddItem(P);
				}
				break;
			case TEAM_NOD:
				if (IconType == ICON_INFANTRY)
				{
					Nod.AddItem(P);
				}
				else if (IconType == ICON_VEHICLE)
				{
					NodVehicle.AddItem(P);
				}
				else if (IconType == ICON_MISC)
				{
					NeutralVehicle.AddItem(P);
				}
				break;
			default:
				if (IconType == ICON_INFANTRY)
				{
					Neutral.AddItem(P);
				}
				else if (IconType == ICON_VEHICLE)
				{
					NeutralVehicle.AddItem(P);
				}
				break;
		}
	
		IconRotationOffset = 0;//180;
	}

	//Check PRIs in netplay, incase irrelevant Pawns were missed 
	if(ThisWorld.NetMode == NM_Client)
	{
		foreach rxGRI.PRIArray(RxPRI)
		{
			if(IgnoredPRIs.find(RxPRI) != -1) 
				continue; 
			
			Marker = RxIfc_RadarMarker(RxPRI);
			
			if(Marker == none) 
				continue; 
			
			IconType = ENUM_ICON(Marker.GetRadarIconType());
			
				TeamVisibility = Marker.GetRadarVisibility();
			
			if(Marker.ForceVisible()) 
				TeamVisibility = 2; //Forced to be visible to all by some means 
			
			if (TeamVisibility == 0)
			{
				continue;
			}				
				
			
			switch (RxPRI.GetTeamNum())
			{
				case TEAM_GDI:
					if (IconType == ICON_INFANTRY)
						GDI.AddItem(RxPRI);
					else if (IconType == ICON_VEHICLE)
						GDIVehicle.AddItem(RxPRI);
					break;
				case TEAM_NOD:
					if (IconType == ICON_INFANTRY)
						Nod.AddItem(RxPRI);
					else if (IconType == ICON_VEHICLE)
						NodVehicle.AddItem(RxPRI);
					break;
				default:
					if (IconType == ICON_INFANTRY)
						Neutral.AddItem(RxPRI);
					else if (IconType == ICON_VEHICLE)
						NeutralVehicle.AddItem(RxPRI);
					break;
			}	
			IconRotationOffset = 0;//180;
		}
	}
	

	UpdateIcons(GDI, GDITeamIcons, TEAM_GDI, false);
	UpdateIcons(GDIVehicle, GDIVehicleIcons, TEAM_GDI, true);		
	UpdateIcons(Nod, NodTeamIcons, TEAM_NOD, false);
	UpdateIcons(NodVehicle, NodVehicleIcons, TEAM_NOD, true);	
	UpdateIcons(Neutral, NeutralIcons, TEAM_UNOWNED, false);
	UpdateIcons(NeutralVehicle, NeutralVehicleIcons, TEAM_UNOWNED, true);		

}

function array<GFxObject> GenGDIIcons(int IconCount)
{
   	local array<GFxObject> Icons;
   	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("FriendlyBlips", "GDI_Player"$IconsFriendlyCount++);
		//@roxez: Debugging blips
        //IconMC = icons_Friendly.AttachMovie("DebugBlips", "GDI_Player"$IconsFriendlyCount++);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenGDIVehicleIcons(int IconCount)
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
		ColorTransform.add.R = 0.75;
		ColorTransform.add.G = 0.58;
		ColorTransform.add.B = 0;
		IconMC.SetColorTransform(ColorTransform);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenNodIcons(int IconCount)
{
	local array<GFxObject> Icons;
	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Enemy.AttachMovie("EnemyBlips", "Nod_Player" $IconsEnemyCount++);
		//@roxez: Debugging blips
        //IconMC = icons_Enemy.AttachMovie("DebugBlips", "Nod_Player" $IconsEnemyCount++);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenNodVehicleIcons(int IconCount)
{
	local ASColorTransform ColorTransform;
	local array<GFxObject> Icons;
	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("VehicleMarker", "Nod_Vehicle"$IconsVehicleEnemyCount++);
		ColorTransform.multiply.R = 0.25;
		ColorTransform.multiply.G = 0.25;
		ColorTransform.multiply.B = 0.25;
		ColorTransform.add.R = 0.75;
		ColorTransform.add.G = 0;
		ColorTransform.add.B = 0;
		IconMC.SetColorTransform(ColorTransform);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenNeutralIcons(int IconCount)
{
	local array<GFxObject> Icons;
	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Enemy.AttachMovie("NeutralBlips", "Neutral_Player" $IconsNeutralCount++);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenNeutralVehicleIcons(int IconCount)
{
	local array<GFxObject> Icons;
	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("VehicleMarker", "Neutral_Vehicle"$IconsVehicleNeutralCount++);
        Icons[i] = IconMC;
    }
    return Icons;
}


function UpdateMapTexture()
{
	local matrix Mtrx;
	local float MapScale;
	local vector MapOffset;

	local float f;
	
	if(RxMapInfo == None)
		return;

	f = -((/*RxPC.Rotation.Yaw*/0 + 16384) & 65535) * (Pi/32768.0);

	if (RxMapInfo != none && RxMapInfo.MapTexture != none) {
		f -= Pi*0.5;
		MapScale = RxMapInfo.MinimapNormalZoom/(2.0 * RxMapInfo.MinimapCurrentZoom); //Scale is calculated by = (normalZoom / 2.0 * currentZoom)
	    Mtrx.XPlane.X = -cos(f) * MapScale;
		Mtrx.XPlane.Y = -sin(f) * MapScale;
	    Mtrx.YPlane.X = sin(f) * MapScale;
		Mtrx.YPlane.Y = -cos(f) * MapScale;
		MapOffset.X = -MapTexSize*0.5f;
		MapOffset.Y = -MapTexSize*0.5f;
		Mtrx.WPlane.X = 0;
		Mtrx.WPlane.Y = 0;
		Mtrx.WPlane.Z = 0;
		Mtrx.WPlane.W = 1;
		Mtrx.WPlane = TransformVector(Mtrx, MapOffset);
		f = Pi*1.5-f;
		map.SetDisplayMatrix(Mtrx);
	}
}

function UpdatePlayerBlip()
{
	local ASDisplayInfo displayInfo;
	local Rx_Pawn RxP;
	local Rx_Vehicle RxV;
	local byte TeamVisibility; 
	local vector V;

	if(RxPC != none ) 
		TeamVisibility = RxPC.RadarVisibility; 
		
	if(Rx_Pawn(RxPC.ViewTarget) != none ) 
		TeamVisibility = Rx_Pawn(RxPC.ViewTarget).RadarVisibility; 
	else 
		if(Rx_Vehicle(RxPC.ViewTarget) != none )  TeamVisibility = Rx_Vehicle(RxPC.ViewTarget).RadarVisibility; 

	if (RxPC.ViewTarget.bHidden  
		|| (Pawn(RxPC.ViewTarget).Health <= 0) 
		|| (Pawn(RxPC.ViewTarget).DrivenVehicle != none)
		//|| P.PlayerReplicationInfo == none    (NOTE: enabling this cause the vehicle to exit early.)
		//|| P == Pawn(RxPC.ViewTarget)
		|| (TeamVisibility == 0)) 
	{
		//`log("Skipped Pawn --- ---" @ P @ "for: Visibility" @ TeamVisibility @ "Health:" @ P.Health @ "Driving Vehicle:" @ P.DrivenVehicle @ "Was view target : " @  P == Pawn(RxPC.ViewTarget)); 
		return;
	}
	
	RxP = Rx_Pawn(RxPC.ViewTarget);
	RxV = Rx_Vehicle(RxPC.ViewTarget);
		
	if ((RxP == none) && (RxV == none)) return;

	if (Rx_Defence(RxPC.ViewTarget) != none) return;

	if(RxMapInfo == None)
		return;

	displayInfo.hasVisible = true;
	displayInfo.hasX = true; 
	displayInfo.hasY = true;

	V = TransformVector(IconMatrix, RxPC.ViewTarget.Location);
	displayInfo.Visible = true; //By default it will be displayed
		
		
	// Sets up the blips coordinates
	displayInfo.X =V.X;
	displayInfo.Y = V.Y;

	if (RxV != none) {
		if (RxV.MinimapIconTexture != none) {
			LoadTexture("img://" $ PathName(Rx_Vehicle(Pawn(RxPC.ViewTarget)).MinimapIconTexture), player_icon.GetObject("playerG"));
		} else {
			LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Vehicle_Player'), player_icon.GetObject("playerG"));
		}		
	} else {
		LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Infantry_Player'), player_icon.GetObject("playerG"));
	}
	displayInfo.hasRotation = true;
	displayInfo.Rotation = (RxPC.ViewTarget.Rotation.Yaw * UnrRotToDeg) + /*f*/0 + IconRotationOffset ;
	//displayInfo.Rotation = Pawn(RxPC.ViewTarget).Rotation.Yaw * UnrRotToDeg + DirCompassIcon.GetDisplayInfo().Rotation + 0;
	player_icon.SetDisplayInfo(displayInfo);

}

function UpdateIcons(out array<Actor> Actors, out array<GFxObject> ActorIcons, TEAM TeamInfo, bool bVehicle)
{
	// HARDCODED: Radius = 124

	local ASDisplayInfo displayInfo;
	local RxIfc_RadarMarker CurrentMarker;
	local array<GFxObject> Icons;
	local byte i;
	local vector V;
	local GFxObject Val;
	local Rx_GRI rxGRI;
	//local vector vect;
	//local Matrix mtrx;
	//local float MapScale;
	//local float f;
	//local vector blankvect;


	if(RxMapInfo == None)
		return;

	rxGRI = Rx_GRI(ThisWorld.GRI);
	
	displayInfo.hasVisible = true;
	displayInfo.hasX = true; 
	displayInfo.hasY = true;
	displayInfo.hasRotation = true;

	// Generate new icons if the actor icons is not equal to total specified actor count. 
	// Else, hide them all and show them until it reach the specified actor count.
	if (ActorIcons.Length < Actors.Length) {
		switch (TeamInfo) 
		{
			case TEAM_GDI:
				Icons = bVehicle ? GenGDIVehicleIcons(Actors.Length - ActorIcons.Length) : GenGDIIcons(Actors.Length - ActorIcons.Length);
				break;
			case TEAM_NOD:
				Icons = bVehicle ? GenNodVehicleIcons(Actors.Length - ActorIcons.Length) : GenNodIcons(Actors.Length - ActorIcons.Length);
				break;
			default:
				Icons = bVehicle ? GenNeutralVehicleIcons(Actors.Length - ActorIcons.Length) : GenNeutralIcons(Actors.Length - ActorIcons.Length);
				break;
		}
		
		foreach Icons(Val) {
			ActorIcons.AddItem(Val);
		}
	} else {
		displayInfo.Visible = false;
		for (i = Actors.Length; i < ActorIcons.Length; i++) {
			ActorIcons[i].SetDisplayInfo(displayInfo);
		}
	}


	//sets the Blips Visibility condition here
	for (i = 0; i < Actors.Length; i++) {
// 		MapScale = MapContainerSize / MapTexSize;
// 		
// 	    IconMatrix.XPlane.X = 1;
// 		IconMatrix.XPlane.Y = 0;
// 	    IconMatrix.YPlane.X = 0;
// 		IconMatrix.YPlane.Y = 1;
// 	    IconMatrix.WPlane.X = 0;
// 	    IconMatrix.WPlane.Y = 0;
// 	    IconMatrix.WPlane.Z = 0;
// 	    IconMatrix.WPlane.W = 1;
//         IconMatrix.WPlane = TransformVector(IconMatrix, -RxMapInfo.MapCenter);
// 	
// 		//f -= Pi*1.5;
// 
// 		vect = -(RxMapInfo.MapCenter - Actors[i].Location) * MapTexSize/RxMapInfo.MapExtent* MapScale ;
// 		V = TransformVector(IconMatrix, vect);
		CurrentMarker = RxIfc_RadarMarker(Actors[i]); 
		if(CurrentMarker == none)
			continue; 
		
		//IMPLEMENTATION #2
		V = TransformVector(IconMatrix, CurrentMarker.GetRadarActorLocation());


		// Display only within the range of the minimap radius
		//displayInfo.Visible = (VSize2d(V) < RxMapInfo.MinimapRadius);
		displayInfo.Visible = true; //By default it will be displayed
		
		
		// Sets up the blips coordinates
		displayInfo.X = V.X;
		displayInfo.Y = V.Y;	
		
		//@shahman: icon rotation = actor's rotation + compass's rotation + rotation offset
		//f = -((RxPC.Rotation.Yaw) & 65535) * (360.0/65536.0);
		displayInfo.Rotation = (CurrentMarker.GetRadarActorRotation().Yaw * UnrRotToDeg) + /*f*/0 + IconRotationOffset ;
		
		//Condition for other blips that is not the same team as the player owner
		if (rxGRI != none && (Pawn(GetPC().viewtarget).GetTeamNum() != Actors[i].GetTeamNum()) ) {
			if ( (Actors[i].GetTeamNum() == TEAM_GDI || Actors[i].GetTeamNum() == TEAM_NOD)) {
				
				if (Actors[i].IsInState('Stealthed'))
				{
					displayInfo.Visible = false;
					ActorIcons[i].SetDisplayInfo(displayInfo);
					continue;
				}
			
				displayInfo.Visible = false; // init false, as most instances will be false.
				
				if(CurrentMarker.ForceVisible())
				{
						displayInfo.Visible = true;		
				}
				
				if (RxHUD.RenxHud.TargetingBox.TargetedActor == Actors[i]) 
				{
					displayInfo.Visible = true;
				}
			} else {
				//`log("Display Info set for FALSE at end") ; 
				displayInfo.Visible = false;
			}
		}


		if(displayInfo.Visible && bVehicle)
		{
			if (CurrentMarker.GetMinimapIconTexture() != none) {
				LoadTexture("img://" $ PathName(CurrentMarker.GetMinimapIconTexture()), ActorIcons[i].GetObject("vehicleG"));
			} else {
				LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Vehicle_Neutral'), ActorIcons[i].GetObject("vehicleG"));
			}	
			
			//Specific instance for irrelevant pawns needing to check what they're driving through PRI 
			if(ThisWorld.NetMode == NM_Client && Rx_PRI(Actors[i]) != none && Rx_PRI(Actors[i]).PawnVehicleClass != none )
			{
				if (class<Rx_Vehicle>(Rx_PRI(Actors[i]).PawnVehicleClass).default.MinimapIconTexture != none) {
					LoadTexture("img://" $ PathName(class<Rx_Vehicle>(Rx_PRI(Actors[i]).PawnVehicleClass).default.MinimapIconTexture), ActorIcons[i].GetObject("vehicleG"));
				} else {
					LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Vehicle_Neutral'), ActorIcons[i].GetObject("vehicleG"));
				}	
			}
		}
		

        //displayInfo.Visible = true; //DEBUG
        ActorIcons[i].SetDisplayInfo(displayInfo);
        
	}

}
/**
function string GetVehicleIconName(Actor marker)
{
	local Rx_Vehicle RxV;

	RxV = Rx_Vehicle(marker);
	if (RxV == none) return "default";

	if(Rx_Vehicle_A10(RxV) != none) return "A-10";
	else if(Rx_Vehicle_Apache(RxV) != none) return "Apache";
	else if(Rx_Vehicle_APC_GDI(RxV) != none) return "APC GDI";
	else if(Rx_Vehicle_APC_Nod(RxV) != none) return "APC Nod";
	else if(Rx_Vehicle_Artillery(RxV) != none) return "Artillery";
	else if(Rx_Vehicle_Buggy(RxV) != none) return "Buggy";
	else if(Rx_Vehicle_C130(RxV) != none) return "C-130";
	else if(Rx_Vehicle_Chinook_GDI(RxV) != none) return "Chinook";
	else if(Rx_Vehicle_Chinook_Nod(RxV) != none) return "Chinook";
	else if(Rx_Vehicle_FlameTank(RxV) != none) return "Flame Tank";
	else if(Rx_Defence(RxV) != none) return "Gun Emplacement"; 
	else if(Rx_Vehicle_Harvester(RxV) != none) return "Harvester";
	else if(Rx_Vehicle_Humvee(RxV) != none) return "Humvee";
	else if(Rx_Vehicle_LightTank(RxV) != none) return "Light Tank";
	else if(Rx_Vehicle_MammothTank(RxV) != none) return "Mammoth Tank";
	else if(Rx_Vehicle_MediumTank(RxV) != none) return "Medium Tank";
	else if(Rx_Vehicle_MRLS(RxV) != none) return "MLRS";
	else if(Rx_Vehicle_Orca(RxV) != none) return "Orca";
	else if(Rx_Vehicle_StealthTank(RxV) != none) return "Stealth Tank";
	else return "default";
}*/

//toggle beacon star (nBab)
function togglebeaconstar ()
{
	if (beaconStar == 0)
		beaconStar = 1;
	else
		beaconStar = 0;
}

function int GetBuildingIndex(Rx_Building B)
{
	if(Rx_Building_GDI_InfantryFactory(B) != None) return 0;
	if(Rx_Building_GDI_VehicleFactory(B) != None) return 1;
	if(Rx_Building_GDI_MoneyFactory(B) != None) return 2;
	if(Rx_Building_GDI_PowerFactory(B) != None) return 3;
	if(Rx_Building_GDI_Defense(B) != None) return 4;
	
	if(Rx_Building_Nod_InfantryFactory(B) != None) return 5;
	if(Rx_Building_Nod_VehicleFactory(B) != None) return 6;
	if(Rx_Building_Nod_MoneyFactory(B) != None) return 7;
	if(Rx_Building_Nod_PowerFactory(B) != None) return 8;
	if(Rx_Building_Nod_Defense(B) != None) return 9;
	return -1;
}

function int GetBuildingPicIndex(Rx_Building B)
{
	if(Rx_Building_GDI_InfantryFactory(B) != None) return 3;
	if(Rx_Building_GDI_VehicleFactory(B) != None) return 8;
	if(Rx_Building_GDI_MoneyFactory(B) != None) return 7;
	if(Rx_Building_GDI_PowerFactory(B) != None) return 6;
	if(Rx_Building_GDI_Defense(B) != None) return 1;
	
	if(Rx_Building_Nod_InfantryFactory(B) != None) return 4;
	if(Rx_Building_Nod_VehicleFactory(B) != None) return 2;
	if(Rx_Building_Nod_MoneyFactory(B) != None) return 7;
	if(Rx_Building_Nod_PowerFactory(B) != None) return 6;
	if(Rx_Building_Nod_Defense(B) != None) return 5;
	return -1;
}

function SetBuildingGfxObjects()
{
	local byte i, j, k;
	for (i = 0; i < 10; i++) {
		j = i / 5;
		k = (i % 5) + 1;
		if (j <= 0) {
			//gdi
			buildings[i] = GetVariableObject("_root.Stats_GDI.building"$ k );
			buildingsHp[i] = GetVariableObject("_root.Stats_GDI.building"$ k $".hp");
			buildingsAp[i] = GetVariableObject("_root.Stats_GDI.building"$ k $".ap");
			buildingsStatus[i] = GetVariableObject("_root.Stats_GDI.building"$ k $".status");
		} else {
			//nod
			buildings[i] = GetVariableObject("_root.Stats_Nod.building"$ k $ "");
			buildingsHp[i] = GetVariableObject("_root.Stats_Nod.building"$ k $".hp");
			buildingsAp[i] = GetVariableObject("_root.Stats_Nod.building"$ k $".ap");
			buildingsStatus[i] = GetVariableObject("_root.Stats_Nod.building"$ k $".status");	
		}	
	}
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
		SetInfoLabelName(gdi_grenadier, "Grenadier");
		SetInfoLabelName(gdi_marksman, "Marksman");
		SetInfoLabelName(gdi_engineer, "Engineer");
		SetInfoLabelName(gdi_officer, "Officer");
		SetInfoLabelName(gdi_rocket_soldier, "Rocket Soldier");
		SetInfoLabelName(gdi_mcfarland, "McFarland");
		SetInfoLabelName(gdi_gunner, "Gunner");
		SetInfoLabelName(gdi_patch, "Patch");
		SetInfoLabelName(gdi_deadeye, "Deadeye");
		SetInfoLabelName(gdi_havoc, "Havoc");
		SetInfoLabelName(gdi_sydney, "Sydney");
		SetInfoLabelName(gdi_mobius, "Mobius");
		SetInfoLabelName(gdi_hotwire, "Hotwire");
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
		SetInfoLabelName(humvee, "Humvee");
		SetInfoLabelName(gdi_apc, "APC");
		SetInfoLabelName(mrls, "MRLS");
		SetInfoLabelName(medium_tank, "Medium Tank");
		SetInfoLabelName(mammoth_tank, "Mammoth Tank");
		SetInfoLabelName(gdi_chinook, "Transport Helicopter");
		SetInfoLabelName(orca, "Orca");
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

function SetOverviewMapGfxObjects()
{
	/*
	 * 
//_root.overview_map.icons_nav
var		 GFxObject               icons_NavMarker;
//_root.overview_map.icons_Neutral
var		 GFxObject               icons_Neutral;
//_root.overview_map.icons_Nod
var		 GFxObject               icons_Enemy;
//_root.overview_map.icons_GDI
var		 GFxObject               icons_Friendly;
//_root.overview_map.icons_NeutralVehicle
var		 GFxObject               icons_NeutralVehicle;
//_root.overview_map.icons_NodVehicle
var		 GFxObject               icons_NodVehicle;
//_root.overview_map.icons_GDIVehicle
var		 GFxObject               icons_GDIVehicle;
//_root.overview_map.map
var		 GFxObject               map;

	 * */
	map = GetVariableObject ("_root.overview_map.map");
	if (RxMapInfo.MapTexture != none) {
		MapTexSize       =  Texture2D(RxMapInfo.MapTexture).SizeX;
		LoadMapTexture("img://" $PathName(RxMapInfo.MapTexture));
		//UpdateMapTexture();
	}
	
	player_icon          =  GetVariableObject("_root.overview_map.player");
	icons_Enemy          =  GetVariableObject("_root.overview_map.icons_Nod");
	icons_Friendly       =  GetVariableObject("_root.overview_map.icons_GDI");
	icons_Neutral        =  GetVariableObject("_root.overview_map.icons_Neutral");
	icons_NodVehicle     =  GetVariableObject("_root.overview_map.icons_NodVehicle");                       
	icons_GDIVehicle     =  GetVariableObject("_root.overview_map.icons_GDIVehicle");                       
	icons_NeutralVehicle =	GetVariableObject("_root.overview_map.icons_NeutralVehicle");               
	icons_NavMarker      =  GetVariableObject("_root.overview_map.icons_nav");

}

function LoadMapTexture(string mapPathName)
{
	map.ActionScriptVoid("loadMapTexture");
}

function LoadTexture(string pathName, GFxObject widget) 
{
	//`log("pathName: " $ pathName $" | widget Name: " $ widget.GetString ("_name") $"" );
	widget.ActionScriptVoid("loadTexture");
}


function SetInfoLabelName(GfxObject labelInfo, string labelName) 
{
	//local GfxClikWidget class_name;
	local GfxObject class_name2;
	//local string debug_output;
	//class_name = GfxClikWidget(labelInfo.GetObject("class_name", class 'GfxClikWidget'));
	class_name2 = labelInfo.GetObject("class_name");
	//class_name.SetString("text", "TEST");
	class_name2.SetText(labelName);

	//debug_output = class_name.GetString("text");
	//`log("output for " $labelInfo.GetString("_name") $"("$ labelInfo $")" $": " $debug_output);
	//class_name.SetVisible(false);
}

function SetInfoLabelCount (GFxObject labelInfo, int count) 
{
	//local GfxClikWidget class_name;
	local GfxObject class_name2;
	//local string debug_output;
	//class_name = GfxClikWidget(labelInfo.GetObject("class_name", class 'GfxClikWidget'));
	class_name2 = labelInfo.GetObject("count");
	//class_name.SetString("text", "TEST");
	if (count == 0)
		class_name2.SetText("");
	else
		class_name2.SetText(string(count));

	//debug_output = class_name.GetString("text");
	//`log("output for " $labelInfo.GetString("_name") $"("$ labelInfo $")" $": " $debug_output);
	//class_name.SetVisible(false);
}


function uLog2(string s) 
{
	`log("------>> LOG FROM " $ MovieInfo $": " $ s);
}

function string GetMapFriendlyName(string MapName)
{

	local int p, i;

	if (MapDataProviderList.Length <= 0) {
		if (GetPC().WorldInfo.Game != none) {
			MapDataProviderList = Rx_Game(GetPC().WorldInfo.Game).MapDataProviderList;
		} else {
			MapDataProviderList = Rx_GRI(GetPC().WorldInfo.GRI).GetMapDataProviderList();
		}
	}

	for (i = 0; i < MapDataProviderList.Length; i++) {
		if (MapName ~= MapDataProviderList[i].MapName) {
			return MapDataProviderList[i].FriendlyName;
		}
	}
	// just strip the prefix
	p = InStr(MapName,"-");
	if (P > INDEX_NONE)
	{
		MapName = Right(MapName, Len(MapName) - P - 1);
	}
	if (Repl(MapName, "_", " ") != "") {
		MapName = Repl(MapName, "_", " ");
	}

	return MapName;
}

DefaultProperties
{
	MovieInfo=SwfMovie'RenXInfoScreen.RenXInfoScreen'
	MapContainerSize = 934
	MapScaling = 1.0 
	IconsFriendlyCount = 0
	IconsVehicleFriendlyCount = 0
	IconsEnemyCount = 0
	IconsVehicleEnemyCount = 0
	IconsNeutralCount = 0;
	IconsVehicleNeutralCount = 0;

	DebugBlipTexture = Texture2D'RenxHud.T_Radar_Blip_Debug'
}
