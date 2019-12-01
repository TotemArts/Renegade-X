/*********************************************************
*
* File: Rx_GfxMinimap.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class handles the creation and modification of the 
* Minimap in the Rx_GfxHud.uc
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/

class Rx_GFxMinimap extends GFxObject;

var		 Rx_GfxHUD               RxHUD;
var		 WorldInfo				 ThisWorld;
var		 Rx_MapInfo				 RxMapInfo;
var      UTPlayerController      RxPC;
var		 int                     MapTexSize;
//var 	 float					 UIScale;

var		 GFxObject               player_icon;

enum ENUM_ICON
{
	ICON_INFANTRY,
	ICON_VEHICLE,
	ICON_MISC 
};

var		 GFxObject               compass;
var		 GFxObject               icons_NavMarker;
var		 GFxObject               icons_Neutral;
var		 GFxObject               icons_Enemy;
var		 GFxObject               icons_Friendly;
var		 GFxObject               icons_NeutralVehicle;
var		 GFxObject               icons_NodVehicle;
var		 GFxObject               icons_GDIVehicle;
var		 GFxObject               map;
var		 string                  mapImagePath;
var		 array<GFxObject>        iconCounts;
var		 matrix                  IconMatrix;

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

/**Use this only for debugging blips*/
var     Texture                 DebugBlipTexture;
var 	byte					Update_Cycler ; //Used to keep Update() from trying to always do everything every tick. 
var		bool					UseUpdateCycle;
var     float					CompassDir;

function init(Rx_GFxHud h)
{
	RxHUD                =  h;
	RxPC                 =  UTPlayerController(GetPC());
	ThisWorld            =  RxPC.WorldInfo;
	RxMapInfo            =  Rx_MapInfo(ThisWorld.GetMapInfo());

	player_icon          =  GetObject("player");
	compass              =  GetObject("compass");


	map = GetObject("map"); 
	if (RxMapInfo.MapTexture != none) {
		MapTexSize       =  Texture2D(RxMapInfo.MapTexture).SizeX;
		LoadMapTexture("img://" $PathName(RxMapInfo.MapTexture));
	}

	icons_Enemy          =  GetObject("icons_Nod");
	icons_Friendly       =  GetObject("icons_GDI");
	icons_Neutral        =  GetObject("icons_Neutral");
	icons_NodVehicle     =  GetObject("icons_NodVehicle");                       
	icons_GDIVehicle     =  GetObject("icons_GDIVehicle");                       
	icons_NeutralVehicle =	GetObject("icons_NeutralVehicle");               
	icons_NavMarker      =  GetObject("icons_nav");

}

function LoadMapTexture(string mapPathName)
{
	map.ActionScriptVoid("loadMapTexture");
}

function LoadTexture(string pathName, GFxObject widget) 
{
	widget.ActionScriptVoid("loadTexture");
}

/**Updates the Minimap as well as the location of the blips.*/
function Update()
{
	// TODO: Height Adjustment
	//
	// TEMP: Hardcoded Values.
	//          Radius = 124
	//          Scale = 1/64
	// 

	// Calling functions in Flash while the movie is closed can cause a crash.
	if (!bMovieIsOpen)
		return;	


	//	Scale = 1.0/Scale;

	if (RxPC == None || Pawn(RxPC.ViewTarget) == none) 
	{
		return;
	}
	
	if(UseUpdateCycle) 
	{
		if(Update_Cycler < 3) 
			Update_Cycler+=1;
		else
			Update_Cycler=0;
	}
	
	//player compass rotation
	UpdateIconLocations();

	//terrain map texture
	//UpdateMap();

	//update the player's marker
	UpdatePlayerBlip();

	// Generate markers for other pawns
	UpdateActorBlips();
}

function UpdateIconLocations()
{
	local float Scale;

	local float f;
	
	if(RxMapInfo == None)
		return;
	
	Scale =  1.34 / RxMapInfo.MinimapCurrentZoom;


	CompassDir = -((RxPC.Rotation.Yaw) & 65535) * (360.0/65536.0);	
	f = -((RxPC.Rotation.Yaw + 16384) & 65535) * (Pi/32768.0);
	IconMatrix.XPlane.X = cos(f) * Scale;//(1.0/32);//Scale;
	IconMatrix.XPlane.Y = sin(f) * Scale;//(1.0/32);//Scale;
	IconMatrix.YPlane.X = -sin(f) * Scale;//(1.0/32);//Scale;
    IconMatrix.YPlane.Y = cos(f) * Scale;////Scale;
    IconMatrix.WPlane.X = 0;
    IconMatrix.WPlane.Y = 0;
    IconMatrix.WPlane.Z = 0;
    IconMatrix.WPlane.W = 1;
    IconMatrix.WPlane = TransformVector(IconMatrix, -Pawn(RxPC.ViewTarget).Location);

}

function UpdateMap()
{
	local vector Vect;
	local matrix Mtrx;
	local float MapScale;
	local vector MapOffset;

	local float f;
	
	if(RxMapInfo == None || Pawn(RxPC.ViewTarget) == none)
		return;

	f = -((RxPC.Rotation.Yaw + 16384) & 65535) * (Pi/32768.0);

	if (RxMapInfo != none && RxMapInfo.MapTexture != none) {
		f -= Pi*0.5;
		MapScale =  RxMapInfo.MinimapNormalZoom/(2.0 * RxMapInfo.MinimapCurrentZoom); //Scale is calculated by = (normalZoom / 2.0 * currentZoom)
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
		Vect = (RxMapInfo.MapCenter - Pawn(RxPC.ViewTarget).Location) * MapTexSize/RxMapInfo.MapExtent;
		MapScale = RxMapInfo.MinimapNormalZoom/(2.0 * RxMapInfo.MinimapCurrentZoom); //Scale is calculated by = (normalZoom / 2.0 * currentZoom)
		Mtrx.WPlane.X += (Vect.X * cos(f) + Vect.Y * sin(f)) * MapScale;
		Mtrx.WPlane.Y += (Vect.Y * cos(f) - Vect.X * sin(f)) * MapScale;
		map.SetDisplayMatrix(Mtrx);
	}
}

function uLog2(string s)
{
	loginternal(s);
}

function UpdatePlayerBlip()
{
	local ASDisplayInfo displayInfo;
	if (Rx_Vehicle(Pawn(RxPC.ViewTarget)) != none) {
		//player_icon.GetObject("playerG").GotoAndStop (GetVehicleIconName(Rx_Vehicle(Pawn(RxPC.ViewTarget))));
		if (Rx_Vehicle(Pawn(RxPC.ViewTarget)).MinimapIconTexture != none) {
			LoadTexture("img://" $ PathName(Rx_Vehicle(Pawn(RxPC.ViewTarget)).MinimapIconTexture), player_icon.GetObject("playerG"));
		} else {
			LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Vehicle_Player'), player_icon.GetObject("playerG"));
		}		
	} else {
		//player_icon.GetObject("playerG").GotoAndStop ("Infrantry");
		LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Infantry_Player'), player_icon.GetObject("playerG"));
	}
	displayInfo.hasRotation = true;
	displayInfo.Rotation = Pawn(RxPC.ViewTarget).Rotation.Yaw * UnrRotToDeg + CompassDir;

	//player_icon.SetDisplayInfo(displayInfo);
	player_icon.SetDisplayInfo(displayInfo);

}

function UpdateActorBlips()
{
	local Actor P;
	
	local RxIfc_RadarMarker Marker; 
	local ENUM_ICON IconType; 
	
	//local Rx_Pawn RxP;
	//local Rx_Vehicle RxV;
	local byte TeamVisibility; 
	//local Rx_Weapon_DeployedBeacon B;//(nBab)
	local Rx_GRI	rxGRI; 
	local PlayerReplicationInfo	RxPRI; 
	
	local array<PlayerReplicationInfo> IgnoredPRIs; //Don't double dip with PRIs in netplay / If the pawn exists just use its location, don't replicate with PRI;  
	local array<Actor> GDI;
	local array<Actor> GDIVehicle;
	local array<Actor> Nod;
	local array<Actor> NodVehicle;
	local array<Actor> Neutral;
	local array<Actor> NeutralVehicle;
	
	if(Update_Cycler == 1) return; //1 of every 3 cycles, don't bother update
	
	rxGRI = Rx_GRI(ThisWorld.GRI);
	
	foreach ThisWorld.DynamicActors(class'Actor', P, class'RxIfc_RadarMarker')
	{	
		//if(!P.isA('Pawn') && !P.isA('Rx_BasicPawn')) continue; 
		
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
			if ((P.bHidden && PlayerReplicationInfo(P) == none)
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
				||Pawn(P) != none && (Pawn(P).DrivenVehicle != none
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
	
	if(UseUpdateCycle)
	{
		if(Update_Cycler == 0)
		{
			UpdateIcons(GDI, GDITeamIcons, TEAM_GDI, false);
			UpdateIcons(GDIVehicle, GDIVehicleIcons, TEAM_GDI, true);	
		}
		else
		if(Update_Cycler == 2)
		{
			UpdateIcons(Nod, NodTeamIcons, TEAM_NOD, false);
			UpdateIcons(NodVehicle, NodVehicleIcons, TEAM_NOD, true);	
		}
		else
		{
			UpdateIcons(Neutral, NeutralIcons, TEAM_UNOWNED, false);
			UpdateIcons(NeutralVehicle, NeutralVehicleIcons, TEAM_UNOWNED, true);	
		}
	}
	else
	{
		UpdateIcons(GDI, GDITeamIcons, TEAM_GDI, false);
		UpdateIcons(GDIVehicle, GDIVehicleIcons, TEAM_GDI, true);		
		UpdateIcons(Nod, NodTeamIcons, TEAM_NOD, false);
		UpdateIcons(NodVehicle, NodVehicleIcons, TEAM_NOD, true);	
		UpdateIcons(Neutral, NeutralIcons, TEAM_UNOWNED, false);
		UpdateIcons(NeutralVehicle, NeutralVehicleIcons, TEAM_UNOWNED, true);	
	}
}

function array<GFxObject> GenGDIIcons(int IconCount)
{
   	local array<GFxObject> Icons;
   	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("FriendlyBlips", "GDI_Player"$IconsFriendlyCount++);
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
		
		CurrentMarker = RxIfc_RadarMarker(Actors[i]); 
		
		V = TransformVector(IconMatrix, CurrentMarker.GetRadarActorLocation());

		// Display only within the range of the minimap radius
		// Handepsilon tweaked the thing a bit because.... box
		displayInfo.Visible = (WithinMinimapBox(V));

		// Sets up the blips coordinates
		displayInfo.X = V.X;
		displayInfo.Y = V.Y;

		//@shahman: icon rotation = actor's rotation + compass's rotation + rotation offset
		displayInfo.Rotation = (CurrentMarker.GetRadarActorRotation().Yaw * UnrRotToDeg) +  CompassDir + IconRotationOffset ;
		
		//Condition for other blips that is not the same team as the player owner
		if (rxGRI != none && (Pawn(GetPC().viewtarget).GetTeamNum() != Actors[i].GetTeamNum()) ) {
			if ( (Actors[i].GetTeamNum() == TEAM_GDI || Actors[i].GetTeamNum() == TEAM_NOD)) {
				
				//No need to go through all of this if it is a stealth tank or SBH that's cloaked
				if (Actors[i].IsInState('Stealthed'))
				{
					displayInfo.Visible = false;
					ActorIcons[i].SetDisplayInfo(displayInfo);
					continue;
				}
	
				displayInfo.Visible = false; // init false, as most instances will be false.
				
				if(CurrentMarker.GetRadarVisibility() == 2 || 
					CurrentMarker.ForceVisible())
				{
						displayInfo.Visible = true;		
				}
				
				if (RxHUD.RenxHud.TargetingBox.TargetedActor == Actors[i]) 
						{
							displayInfo.Visible = true;
						}
			} else {
				//`log("Display Info set for FALSE at end") ; 
				displayInfo.Visible = true;
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

function bool WithinMinimapBox(Vector V)
{
	if(V.x > RxMapInfo.MinimapRadius || V.x < (RxMapInfo.MinimapRadius * -1))
		return false;

	if(V.y > RxMapInfo.MinimapRadius || V.y < (RxMapInfo.MinimapRadius * -1))
		return false;

	return true;
}

DefaultProperties
{
	IconsFriendlyCount = 0
	IconsVehicleFriendlyCount = 0
	IconsEnemyCount = 0
	IconsVehicleEnemyCount = 0
	IconsNeutralCount = 0;
	IconsVehicleNeutralCount = 0;

	DebugBlipTexture = Texture2D'RenxHud.T_Radar_Blip_Debug'
//	UIScale	= 1.f
}
