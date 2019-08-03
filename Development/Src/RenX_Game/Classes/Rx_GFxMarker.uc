/*********************************************************
*
* File: Rx_GFxMarker.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: This class handles the creation and modification of the 
* Marker system in the Rx_GfxHud.uc
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/
class Rx_GFxMarker extends GFxObject;

var		 Rx_GfxHUD               RxHUD;
var		 WorldInfo				 ThisWorld;
var      Rx_Controller           RxPC;


var		 GFxObject               markers_Friendly;
var		 GFxObject               markers_Enemy;
var		 GFxObject               markers_Neutral;

var		 array<GFxObject>        GDITeamMarkers;
var		 array<GFxObject>        NodTeamMarkers;
var		 array<GFxObject>        NeutralTeamMarkers;

var		 int                     MarkersFriendlyCount;
var		 int                     MarkersEnemyCount;
var		 int                     MarkersNeutralCount;

function init(Rx_GFxHud h)
{

	RxHUD                =  h;
	RxPC                 =  Rx_Controller(GetPC());
	ThisWorld            =  RxPC.WorldInfo;
	
	markers_Friendly     =  GetObject("markers_Friendly");
	markers_Enemy        =  GetObject("markers_Enemy");
	markers_Neutral      =  GetObject("markers_Neutral");



}

/**Updates the Marker as well as the location of the marker.*/
function Update()
{
	if (!bMovieIsOpen) {
		return;
	}

	if (RxPC == none || RxPC.Pawn == none) {
		return;
	}

	//`log("Rx_GFxMarker::Update() - UpdatingActorMarkers");
	UpdateActorMarkers();
}

function UpdateActorMarkers()
{

	local Pawn P;

	local Canvas canvas;
	local vector ScreenLoc;

	local array<Actor> GDI;
	local array<Actor> Nod;
	local array<Actor> Neutral;

	local actor target;

	canvas = RxHUD.RenxHud.Canvas;

	/*
	 * foreach Markers (Val) {
			ActorMarkers.AddItem(Val);
		}
	 * */

	foreach RxHUD.RenxHud.SpotTargets (target) {
		P = Pawn(target);
		if (P == none || P.bHidden || (P.Health <= 0) || (P.DrivenVehicle != none) || P == RxPC.Pawn) { 
			continue;
		}

// 		`log ("P.PRI? " $ P.PlayerReplicationInfo);
// 		`log ("P.PRI_HumanName? " $ P.PlayerReplicationInfo.GetHumanReadableName());
// 		`log ("P.PRI_Owner? " $ P.PlayerReplicationInfo.Owner);
// 		`log ("***");
		//getting the Pawn's height position
 		ScreenLoc = canvas.Project(P.Location + P.GetCollisionHeight()*vect(0,0,1));
		
		//Check if the screen location is off screen to make sure not clipped out
		if (screenLoc.X < 0 || screenLoc.X >= Canvas.ClipX 
			|| screenLoc.Y < 0 || screenLoc.Y >= Canvas.ClipY
			|| screenLoc.Z <= 0)
		{
			continue;
		}


		if (Rx_Pawn(P) == none && Rx_Vehicle(P) == none) {
			continue;
		}
		
		if (Rx_Building(target) != none || Rx_Vehicle_Harvester(P) != none || Rx_Defence(P) != none) {
			continue;
		}

		if (RxIfc_Stealth(p) != none && RxIfc_Stealth(p).GetIsinTargetableState() == false ) {
				continue;
			}

		//TODO: remove calculation of vehicle if we ourselves

		switch (P.GetTeamNum())
		{
			case TEAM_GDI:
				GDI.AddItem(P);
				break;
			case TEAM_NOD:
				Nod.AddItem(P);
				break;
			default:
				Neutral.AddItem(P);
				break;
		}	
	}

// 	foreach ThisWorld.AllPawns(class'Pawn', P) {
// 		if (P.bHidden || (P.Health <= 0) || (P.DrivenVehicle != none) || P == RxPC.Pawn) { 
// 			continue;
// 		}
// 
// // 		`log ("P.PRI? " $ P.PlayerReplicationInfo);
// // 		`log ("P.PRI_HumanName? " $ P.PlayerReplicationInfo.GetHumanReadableName());
// // 		`log ("P.PRI_Owner? " $ P.PlayerReplicationInfo.Owner);
// // 		`log ("***");
// 		//getting the Pawn's height position
//  		ScreenLoc = canvas.Project(P.Location + P.GetCollisionHeight()*vect(0,0,1));
// 		
// 		//Check if the screen location is off screen to make sure not clipped out
// 		if (screenLoc.X < 0 || screenLoc.X >= Canvas.ClipX 
// 			|| screenLoc.Y < 0 || screenLoc.Y >= Canvas.ClipY
// 			|| screenLoc.Z <= 0)
// 		{
// 			continue;
// 		}
// 
// 
// 		if (Rx_Pawn(P) == none && Rx_Vehicle(P) == none) {
// 			continue;
// 		}
// 		
// 		if (Rx_Defence(P) != none) {
// 			continue;
// 		}
// 
// 		//TODO: remove calculation of vehicle if we ourselves
// 
// 		switch (P.GetTeamNum())
// 		{
// 			case TEAM_GDI:
// 				GDI.AddItem(P);
// 				break;
// 			case TEAM_NOD:
// 				Nod.AddItem(P);
// 				break;
// 			default:
// 				Neutral.AddItem(P);
// 				break;
// 		}	
// 	}
	UpdateMarkers(GDI, GDITeamMarkers, TEAM_GDI);
	UpdateMarkers(Nod, NodTeamMarkers, TEAM_NOD);
	UpdateMarkers(Neutral, NeutralTeamMarkers, TEAM_UNOWNED);
}

function array<GFxObject> GenFriendlyMarkers(int MarkerCount)
{
	local array<GFxObject> Markers;
	local GFxObject MarkerMC;
    local byte i;
	for (i = 0; i < MarkerCount; i++)
	{
        MarkerMC = markers_Friendly.AttachMovie("FriendlyMarkers", "Friendly_Player" $MarkersFriendlyCount++);
        Markers[i] = MarkerMC;
	}
	return Markers;
}
function array<GFxObject> GenEnemyMarkers(int MarkerCount)
{
	local array<GFxObject> Markers;
	local GFxObject MarkerMC;
    local byte i;
	for (i = 0; i < MarkerCount; i++)
	{
        MarkerMC = markers_Enemy.AttachMovie("EnemyMarkers", "Enemy_Player" $MarkersEnemyCount++);
        Markers[i] = MarkerMC;
	}
	return Markers;
}
function array<GFxObject> GenNeutralMarkers(int MarkerCount)
{
	local array<GFxObject> Markers;
	local GFxObject MarkerMC;
    local byte i;
	for (i = 0; i < MarkerCount; i++)
	{
        MarkerMC = markers_Neutral.AttachMovie("NeutralMarkers", "Neutral_Player" $MarkersNeutralCount++);
        Markers[i] = MarkerMC;
	}
	return Markers;
}

function UpdateMarkers(out array<Actor> Actors, out array<GFxObject> ActorMarkers, TEAM TeamInfo)
{
	local ASDisplayInfo displayInfo;
	local array<GFxObject> Markers;
	local GFxObject Val;
	local Canvas canvas;
	local vector ScreenLoc;
	local Rx_GRI rxGRI;
    local byte i;
	local float x0, y0, x1, y1;
	local Vector2D HudMovieSize;
	local float HudScaleFactorWidth;
	local float HudScaleFactorHeight;
	local float distMin, distMax, alphaMin, alphaMax, scalar;
	local bool bIsBehindMe;

	rxGRI = Rx_GRI(ThisWorld.GRI);
	canvas = RxHUD.RenxHud.Canvas;

	RxHUD.GetVisibleFrameRect(x0, y0, x1, y1);
	HudMovieSize.X = x1;
	HudMovieSize.Y = y1;
	
	HudScaleFactorWidth = HudMovieSize.X / canvas.ClipX;
	HudScaleFactorHeight = HudMovieSize.Y / canvas.ClipY;

	displayInfo.hasVisible = true;
	displayInfo.hasX = true; 
	displayInfo.hasY = true;

	distMin = 3000;//xmin
	distMax = 4500;//xmax
	alphaMin = 0.75;//ymin
	alphaMax = 0.2;//ymax
	scalar = (alphaMax-alphaMin)/(distMax-distMin);

	// Generate new markers if the actor markers is not equal to total specified actor count. 
	// Else, hide them all and show them until it reach the specified actor count.
	if (ActorMarkers.Length < Actors.Length) {
		if (TeamInfo == TEAM_UNOWNED) {
			Markers = GenNeutralMarkers (Actors.Length - ActorMarkers.Length);
		} else {
			if (TeamInfo == RxPC.GetTeamNum() ){
				Markers = GenFriendlyMarkers (Actors.Length - ActorMarkers.Length);
			} else {
				Markers = GenEnemyMarkers (Actors.Length - ActorMarkers.Length);
			}
		}

		foreach Markers (Val) {
			ActorMarkers.AddItem(Val);
		}
	} else {
		displayInfo.Visible = false;
		for (i = Actors.Length; i < ActorMarkers.Length; i++) {
			ActorMarkers[i].SetDisplayInfo(displayInfo);
		}
	}

	//sets the Markers Visibility condition here
	for (i = 0; i < Actors.Length; i++) {
	
		if (Pawn(Actors[i]) == none) {
			continue;
		}
		//getting the Pawn's height position
 		ScreenLoc = canvas.Project(Actors[i].Location + (Pawn(Actors[i]).GetCollisionHeight() * 1.5)*vect(0,0,1));
		bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(GetPC().ViewTarget.Location,GetPC().Rotation,Actors[i].location) < -0.5;

		//Check if the screen location is off screen
		if (screenLoc.X < 0 || screenLoc.X >= Canvas.ClipX || screenLoc.Y < 0 || screenLoc.Y >= Canvas.ClipY || screenLoc.Z <= 0) {
			displayInfo.Visible = false;
		} else {
			displayInfo.X = ScreenLoc.X * HudScaleFactorWidth;
			displayInfo.Y = ScreenLoc.Y * HudScaleFactorHeight; //probably need offset
		}
		
		//Condition for other blips that is not the same team as the player owner
		if (rxGRI != none ) {
			if (ThisWorld.GRI.OnSameTeam(RxPC.Pawn, Actors[i])) {
				//if this is friendly
				displayInfo.Visible = true;
			} else {
				//enemy logic here
				displayInfo.Visible = true;
			}

			if (Actors[i].GetTeamNum() == TEAM_UNOWNED ) {
				displayInfo.Visible = false;
			}
		}

		if (bIsBehindMe || (Rx_Building(Actors[i]) == None && !RxHUD.RenxHud.FastTrace(Actors[i].location,GetPC().ViewTarget.Location,,true))) {
			displayInfo.Visible = false;
		}

		ActorMarkers[i].SetDisplayInfo(displayInfo);
		ActorMarkers[i].SetFloat("alpha", FClamp((scalar * (VSize(Actors[i].Location - RxPC.Pawn.Location) - distMin)) + alphaMin, 0.2, 0.75));
	}

}



DefaultProperties
{
	MarkersFriendlyCount = 0
	MarkersEnemyCount = 0
	MarkersNeutralCount = 0
}
