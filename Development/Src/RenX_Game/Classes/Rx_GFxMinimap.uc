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
var      Rx_Controller           RxPC;
var		 int                     MapTexSize;

var		 GFxObject               DirCompassIcon;

var		 GFxObject               player_icon;


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

function init(Rx_GFxHud h)
{
	RxHUD                =  h;
	RxPC                 =  Rx_Controller(GetPC());
	ThisWorld            =  RxPC.WorldInfo;
	RxMapInfo            =  Rx_MapInfo(ThisWorld.GetMapInfo());

	player_icon          =  GetObject("player");
	DirCompassIcon       =  GetObject("dirCompass");
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

	if (RxPC == None || RxPC.Pawn == none) {
		return;
	}

	//player compass rotation
	UpdateCompass();

	//terrain map texture
	UpdateMap();

	//update the player's marker
	UpdatePlayerBlip();

	// Generate markers for other pawns
	UpdateActorBlips();
}
function UpdateCompass()
{
	local ASDisplayInfo displayInfo;
	local float Scale;

	local float f;
	
	if(RxMapInfo == None)
		return;
	
	Scale = 1 / RxMapInfo.MinimapCurrentZoom;

	if(DirCompassIcon != none) {
		displayInfo.hasRotation = true;
		displayInfo.Rotation = -((RxPC.Rotation.Yaw) & 65535) * (360.0/65536.0);
		DirCompassIcon.SetDisplayInfo(displayInfo);
		
	    f = -((RxPC.Rotation.Yaw + 16384) & 65535) * (Pi/32768.0);
	    IconMatrix.XPlane.X = cos(f) * Scale;//(1.0/32);//Scale;
	    IconMatrix.XPlane.Y = sin(f) * Scale;//(1.0/32);//Scale;
	    IconMatrix.YPlane.X = -sin(f) * Scale;//(1.0/32);//Scale;
	    IconMatrix.YPlane.Y = cos(f) * Scale;////Scale;
	    IconMatrix.WPlane.X = 0;
	    IconMatrix.WPlane.Y = 0;
	    IconMatrix.WPlane.Z = 0;
	    IconMatrix.WPlane.W = 1;
        IconMatrix.WPlane = TransformVector(IconMatrix, -RxPC.Pawn.Location);
	}
}
function UpdateMap()
{
	local vector Vect;
	local matrix Mtrx;
	local float MapScale;
	local vector MapOffset;

	local float f;
	
	if(RxMapInfo == None)
		return;

	f = -((RxPC.Rotation.Yaw + 16384) & 65535) * (Pi/32768.0);

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
		Vect = (RxMapInfo.MapCenter - RxPC.Pawn.Location) * MapTexSize/RxMapInfo.MapExtent;
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
	if (Rx_Vehicle(RxPC.Pawn) != none) {
		//player_icon.GetObject("playerG").GotoAndStop (GetVehicleIconName(Rx_Vehicle(RxPC.Pawn)));
		if (Rx_Vehicle(RxPC.Pawn).MinimapIconTexture != none) {
			LoadTexture("img://" $ PathName(Rx_Vehicle(RxPC.Pawn).MinimapIconTexture), player_icon.GetObject("playerG"));
		} else {
			LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Vehicle_Player'), player_icon.GetObject("playerG"));
		}		
	} else {
		//player_icon.GetObject("playerG").GotoAndStop ("Infrantry");
		LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Infantry_Player'), player_icon.GetObject("playerG"));
	}
	displayInfo.hasRotation = true;
	displayInfo.Rotation = RxPC.Pawn.Rotation.Yaw * UnrRotToDeg + DirCompassIcon.GetDisplayInfo().Rotation + 0;

	//player_icon.SetDisplayInfo(displayInfo);
	player_icon.SetDisplayInfo(displayInfo);

}

function UpdateActorBlips()
{
	local Pawn P;
	local Rx_Pawn RxP;
	local Rx_Vehicle RxV;


	local array<Actor> GDI;
	local array<Actor> GDIVehicle;
	local array<Actor> Nod;
	local array<Actor> NodVehicle;
	local array<Actor> Neutral;
	local array<Actor> NeutralVehicle;

	foreach ThisWorld.AllPawns(class'Pawn', P)
	{		
		if (P.bHidden  
			|| (P.Health <= 0) 
			|| (P.DrivenVehicle != none)
			//|| P.PlayerReplicationInfo == none    (NOTE: enabling this cause the vehicle to exit early.)
			|| P == RxPC.Pawn)
		{ 
			continue;
		}
		RxP = Rx_Pawn(P);
		RxV = Rx_Vehicle(P);
		
		if ((RxP == none) && (RxV == none)) continue;

		if (Rx_Defence(P) != none) continue;

		switch (P.GetTeamNum())
		{
			case TEAM_GDI:
				if (RxP != none)
				{
					GDI.AddItem(P);
				}
				else if (RxV != none)
				{
					GDIVehicle.AddItem(P);
				}
				break;
			case TEAM_NOD:
				if (RxP != none)
				{
					Nod.AddItem(P);
				}
				else if (RxV != none)
				{
					NodVehicle.AddItem(P);
				}
				break;
			default:
				if (RxP != none)
				{
					Neutral.AddItem(P);
				}
				else if (RxV != none)
				{
					NeutralVehicle.AddItem(P);
				}
				break;
		}	
		IconRotationOffset = 0;//180;
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
		V = TransformVector(IconMatrix, Actors[i].Location);

		// Display only within the range of the minimap radius
		displayInfo.Visible = (VSize2d(V) < RxMapInfo.MinimapRadius);
		
		// Sets up the blips coordinates
		displayInfo.X = V.X;
		displayInfo.Y = V.Y;

		//Change the vehicle blips to the actor's corresponding vehicles
		if (Rx_Vehicle(Actors[i]) != none) {
			//ActorIcons[i].GetObject("vehicleG").GotoAndStop(GetVehicleIconName(Actors[i]));
			if (Rx_Vehicle(Actors[i]).MinimapIconTexture != none) {
				LoadTexture("img://" $ PathName(Rx_Vehicle(Actors[i]).MinimapIconTexture), ActorIcons[i].GetObject("vehicleG"));
			} else {
				LoadTexture("img://" $ PathName(Texture2D'RenxHud.T_Radar_Blip_Vehicle_Neutral'), ActorIcons[i].GetObject("vehicleG"));
			}	
		} 

		//@shahman: icon rotation = actor's rotation + compass's rotation + rotation offset
		displayInfo.Rotation = (Actors[i].Rotation.Yaw * UnrRotToDeg) + DirCompassIcon.GetDisplayInfo().Rotation + IconRotationOffset ;

		//Condition for other blips that is not the same team as the player owner
		if (rxGRI != none && !ThisWorld.GRI.OnSameTeam(GetPC().Pawn, Actors[i]) ) {
			if (Actors[i].GetTeamNum() == TEAM_GDI || Actors[i].GetTeamNum() == TEAM_NOD ){
				displayInfo.Visible = false;
				if (!Actors[i].IsInState('Stealthed') && !Actors[i].IsInState('BeenShot') && !(Rx_Pawn_SBH(Actors[i]) != none && Rx_Pawn_SBH(Actors[i]).bStealthRecoveringFromBeeingShotOrSprinting)) {
					if (RxHUD.RenxHud.SpotTargets.Find(Actors[i]) != -1) {
						displayInfo.Visible = true;
					} 
// 					else if ( (Rx_Pawn(Actors[i]) != none && Rx_Pawn(Actors[i]).bTargetted ) || (Rx_Vehicle(Actors[i]) != none && Rx_Vehicle(Actors[i]).bTargetted)) {
// 						displayInfo.Visible = true;
// 					}
					else if (RxHUD.RenxHud.TargetingBox.TargetedActor == Actors[i]) {
						displayInfo.Visible = true;
					}
				}
			} else {
				displayInfo.Visible = false;
			}
		}

// 		if (ThisWorld.GRI != none && !ThisWorld.GRI.OnSameTeam(GetPC().Pawn, Actors[i])) {
// 			if ((Actors[i].GetTeamNum() == TEAM_GDI || Actors[i].GetTeamNum() == TEAM_NOD)) {
// 				displayInfo.Visible = false;
// 				if (!Actors[i].IsInState('Stealthed') && !Actors[i].IsInState('BeenShot')) {
// 					if ( (Rx_Pawn(Actors[i]) != none && Rx_Pri(Rx_Pawn(Actors[i]).PlayerReplicationInfo) != None && Rx_Pri(Rx_Pawn(Actors[i]).PlayerReplicationInfo).isSpotted() )
// 						|| (Rx_Vehicle(Actors[i]) != none 
// 								&& Rx_Pawn(Rx_Vehicle(Actors[i]).driver) != None 
// 								&& Rx_Pri(Rx_Pawn(Rx_Vehicle(Actors[i]).driver).PlayerReplicationInfo) != None
// 								&& Rx_Pri(Rx_Pawn(Rx_Vehicle(Actors[i]).driver).PlayerReplicationInfo).isSpotted()))
// 					{
// 						displayInfo.Visible = true;
// 					}
// 					if ((Rx_Pawn(Actors[i]) != none && Rx_Pawn(Actors[i]).bTargetted )
// 						|| (Rx_Vehicle(Actors[i]) != none && Rx_Vehicle(Actors[i]).bTargetted))
// 					{
// 						displayInfo.Visible = true;
// 					} 
// 				} else {
// 					displayInfo.Visible = false;
// 				}
// 				
// 			}		
// 		}
	
		ActorIcons[i].SetDisplayInfo(displayInfo);
	}

}

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
}
