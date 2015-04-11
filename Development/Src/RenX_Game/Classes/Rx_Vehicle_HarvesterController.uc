/*********************************************************
*
* File: Rx_Vehicle_Harvester.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_HarvesterController extends AIController;
    
var byte TeamNum;

var Rx_Tib_NavigationPoint tibNode;
var Rx_Ref_NavigationPoint refNode;

var Rx_Vehicle_Harvester harv_vehicle;
var NavigationPoint BlockedNavPointBehindMe;
var Rx_Building_Refinery refinery;
var vector refineryLoc,loc;
var rotator refineryRot;
var Rx_BuildingAttachment DockingStation;
//var Rx_Building_AdvancedGuardTower agt;
var bool bTurnLeftToFaceRef;

var bool                            bLogTripTimes;
var float							tripTimer;
var Rx_BlockedForHarvesterPathnode	Nav;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	InitPlayerReplicationInfo();
}

event SetTeam(int inTeamIdx)
{
    TeamNum = inTeamIdx;
}

function InitPlayerReplicationInfo()
{
	if(PlayerReplicationInfo != none)
	{
		CleanupPRI();
	}
	PlayerReplicationInfo = Spawn(class'Rx_DefencePRI', self);

	if (PlayerReplicationInfo != none) {
		PlayerReplicationInfo.SetPlayerName(Rx_Vehicle_Harvester(Owner).GetHumanReadableName());
		PlayerReplicationInfo.SetPlayerTeam(WorldInfo.GRI.Teams[Owner.GetTeamNum()]);
	}
}

function StopMovement()
{
	local Vehicle V;

	if (Pawn.Physics != PHYS_Flying)
	{
		Pawn.Acceleration = vect(0,0,0);
	}
	V = Vehicle(Pawn);
	if (V != None)
	{
		V.Steering = 0;
		V.Throttle = 0;
		V.Rise = 0;
	}
}


auto state idle
{	
}


/*
 * Extends State ScriptedMove from Superclass AIController
 */
state ScriptedMove
{
	ignores SeePlayer, SeeMonster, HearNoise, NotifyHitWall;

	event PoppedState()
	{
		Super(ScriptedMove).PoppedState();
		if (Pawn != None)
		{
			StopMovement();
		}
	}

Begin:
	// while we have a valid pawn and move target, and
	// we haven't reached the target yet
	while (Pawn != None &&
		   ScriptedMoveTarget != None &&
		   !Pawn.ReachedDestination(ScriptedMoveTarget))
	{
		// check to see if it is directly reachable
		if (ActorReachable(ScriptedMoveTarget))
		{
			// then move directly to the actor
			MoveToward(ScriptedMoveTarget, ScriptedFocus);
		}
		else
		{
			
			foreach WorldInfo.AllNavigationPoints(class'Rx_BlockedForHarvesterPathnode',Nav)
			{
				Nav.TransientCost = 10000000.0; // so that the Harv avoids this kind of pathnodes. The cost is cleared automatically after the next FindPathToward 
			}
			
			// attempt to find a path to the target
			MoveTarget = FindPathToward(ScriptedMoveTarget, false);
			if (MoveTarget != None)
			{
				// move to the first node on the path
				MoveToward(MoveTarget, ScriptedFocus);
			}
			else
			{
				// abort the move
				`warn("Failed to find path to"@ScriptedMoveTarget);
				Sleep(3.0);
				GoTo('Begin');
				//ScriptedMoveTarget = None;
			}
		}
	}
	// return to the previous state
	PopState();
}

/**
 * Called by APawn::moveToward when the point is unreachable
 * due to obstruction or height differences.
 */
event MoveUnreachable(vector AttemptedDest, Actor AttemptedTarget)
{
	LogInternal("=== Rx_Vehicle_HarvesterController: Point"@AttemptedDest@AttemptedTarget@"unreachable ===");
}

/** called when a ReachSpec the AI wants to use is blocked by a dynamic obstruction
 * gives the AI an opportunity to do something to get rid of it instead of trying to find another path
 * @note MoveTarget is the actor the AI wants to move toward, CurrentPath the ReachSpec it wants to use
 * @param BlockedBy the object blocking the path
 * @return true if the AI did something about the obstruction and should use the path anyway, false if the path
 * is unusable and the bot must find some other way to go
 */
event bool HandlePathObstruction(Actor BlockedBy){
	
	//LogInternal("=== Rx_Vehicle_HarvesterController: Path"@movetarget@"Obstructed ===");
	return true; // We are the harvester. We try to ram our way through !
}

state Harvesting
{
	ignores SeePlayer, SeeMonster, HearNoise;


Begin:
	
	
	if (bLogTripTimes)
	{
		`log(((TeamNum == 0)? "GDI" : "Nod") @ " harvester took " @ tripTimer @ " to reach tiberium field.");
		tripTimer = 0;
	}

	harv_vehicle.bPlayOpeningAnim = false;
	harv_vehicle.bPlayHarvestingAnim = true;
	if(WorldInfo.NetMode != NM_DedicatedServer)
		Pawn.Mesh.PlayAnim('Harvesting',,true);
    sleep(refinery.HarvesterHarvestTime);

    if (bLogTripTimes)
	{
		`log(((TeamNum == 0)? "GDI" : "Nod") @ " harvester took " @ refinery.HarvesterHarvestTime @ " to harvest from tiberium field.");
		tripTimer = 0;
	}
	if (tibNode != none)
		tibNode.bBlocked = false;
    harv_vehicle.bPlayHarvestingAnim = false;  
	GotoState('MovingToRaf');
}

state MovingToTib
{
   ignores SeePlayer, HearNoise, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling;

	function BeginState(Name PreviousStateName)
	{
		ClearTimer('destroyIfHarvSeemsToBeStuck');
		setTimer(480.0, false, 'destroyIfHarvSeemsToBeStuck');
		// get all the nav points first
		if(refNode == None) {
			refNode = GetRefNode();
		}
		if(tibNode == None) {
			tibNode = GetTibNode();
		}
		Enemy = None;
		Focus = None;

        ScriptedMoveTarget = tibNode;
	}

Begin:
	
   SetTimer(1.0,true,'CheckDistToTib');	
	if (tibNode != none)
		tibNode.bBlocked = false;
	if (refNode != none)
		refNode.bBlocked = false;
   PushState('ScriptedMove');
   if(tibNode != none && Pawn.ReachedDestination(tibNode))
   {
        tibNode.bBlocked = true;
        WorldInfo.Game.NotifyNavigationChanged(tibNode);
        GotoState('Harvesting');
   }
}

function CheckDistToTib() {
	if(tibNode != none && VSize(Pawn.location - tibNode.location) < 1000.0) {
		harv_vehicle.bPlayClosingAnim = false;
		harv_vehicle.bPlayOpeningAnim = true;
		if(WorldInfo.NetMode != NM_DedicatedServer)
			Pawn.Mesh.PlayAnim('Opening');
		ClearTimer('CheckDistToTib');
	}	
}

state MovingToRaf
{
   ignores SeePlayer, HearNoise, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling;

	function BeginState(Name PreviousStateName)
	{
		if(WorldInfo.NetMode != NM_DedicatedServer)
			Pawn.Mesh.PlayAnim('Opening',,,,,true);
		harv_vehicle.bPlayClosingAnim = true;
		if(refNode == None) {
			refNode = GetRefNode();
		}
		if(tibNode == None) {
			tibNode = GetTibNode();
		}
		Enemy = None;
		Focus = None;

        ScriptedMoveTarget = refNode;
	}

Begin:

   PushState('ScriptedMove');
   if(Pawn.ReachedDestination(refNode))
   {
	    
	  refinery.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('RefNodeSocket', refineryLoc, refineryRot);      
	  if (refNode != none)
	  {
		refNode.bBlocked = true;
		WorldInfo.Game.NotifyNavigationChanged(refNode);
	  }
      loc = refineryLoc;
      loc.z -= 70;
      
	  foreach refinery.BuildingInternals.BuildingAttachments(DockingStation) 
	  	if(DockingStation.isA('Rx_BuildingAttachment_RefDockingStation')) 
	  		break;  
      
	  if(class'Rx_Utils'.static.LeftRightOrientationOfAtoB(refinery, Pawn) < 0.0)
	  	bTurnLeftToFaceRef = true;
	  if(bTurnLeftToFaceRef)	      
      	harv_vehicle.Steering = 1.0;
      else	
      	harv_vehicle.Steering = -1.0;
  	  
  	  SetTimer(1.0,false,'CheckIfOrientedRight');
   }
}

simulated function GetRefinery()
{
	foreach AllActors(class'Rx_Building_Refinery', refinery)
	  {
		if (refinery.GetTeamNum() == TeamNum)
		{
			break;
		}
	  }
}

function CheckIfOrientedRight()
{
	harv_vehicle.bTurningToDock = true;
}

function Tick(float DeltaTime)
{
	local float orient, orient2;
	local Rx_BuildingAttachment ba;

	if (refinery == none)
		GetRefinery();

	if (bLogTripTimes)
	{
		tripTimer += DeltaTime;
	}
	
	Super.Tick(DeltaTime);
	if(harv_vehicle.bTurningToDock) 
	{
		orient = class'Rx_Utils'.static.LeftRightOrientationOfAtoB(DockingStation,Pawn);
		orient2 = class'Rx_Utils'.static.OrientationToB(Pawn,DockingStation);
		
	 	if(orient2 <= 0 && ((bTurnLeftToFaceRef && orient >= 0.0) || (!bTurnLeftToFaceRef && orient <= 0.0))) 
	 	{
			harv_vehicle.bTurningToDock = false;
			harv_vehicle.Steering = 0.0;
			harv_vehicle.Throttle = -1.0;
			
			foreach refinery.BuildingInternals.BuildingAttachments(ba) 
				if(ba.isA('Rx_BuildingAttachment_RefDockingStation'))
			{
					Rx_BuildingAttachment_RefDockingStation(ba).Activate(true);
					break;
				}
			if (WorldInfo.NetMode != NM_DedicatedServer) 
			{
				Rx_BuildingAttachment_RefDockingStation(ba).Activate(true);
			}
			SetTimer(3.0,false,'StartUnload');
		}
	}
}

function StartUnload()
{
	harv_vehicle.Throttle = 0.0;
	if (refNode != none)
		refNode.bBlocked = false;
	refinery.HarvesterDocked(self);

	if (bLogTripTimes)
	{
		`log(((TeamNum == 0)? "GDI" : "Nod")  @ " harvester took " @ tripTimer @ " to return to refinery.");
		tripTimer = 0;
	}
}

function GotoTib()
{
	harv_vehicle.Throttle = 1.0;
	SetTimer(1.0,false,'GotoTib2');

	if (bLogTripTimes)
	{
		`log(((TeamNum == 0)? "GDI" : "Nod") @ " harvester took " @ tripTimer @ " to unload.");
		tripTimer = 0;
	}
}

function GotoTib2()
{
	local Rx_BuildingAttachment ba;
	
	harv_vehicle.Throttle = 0.0;
	foreach refinery.BuildingInternals.BuildingAttachments(ba) 
		if(ba.isA('Rx_BuildingAttachment_RefGarageDoor'))
			Rx_BuildingAttachment_RefGarageDoor(ba).Close();
		else if(ba.isA('Rx_BuildingAttachment_RefDockingStation'))
			Rx_BuildingAttachment_RefDockingStation(ba).Activate(false);			

	GotoState('MovingToTib');
}

function Rx_Tib_NavigationPoint GetTibNode()
{
   local Rx_Tib_NavigationPoint Node;
   local byte Num;

   foreach AllActors(class'Rx_Tib_NavigationPoint', Node)
   {
      Num++;
      if (Node.TeamNum == TeamNum)
      {
         return Node;
      }

      if (Num == 3)
         `Log ("Warning: there are more than 2 Rx_Tib_NavigationPoint <Harvester could get Problems> !!!!");
   }
   `Log ("Warning: no RenX_Tib_Nodes found! harvester won't work!!!!!");
   return none;
}

function destroyIfHarvSeemsToBeStuck() {
	harv_vehicle.BlowupVehicle();
}

function Rx_Ref_NavigationPoint GetRefNode()
{
   local Rx_Ref_NavigationPoint Node;
   local byte Num;

   foreach AllActors(class'Rx_Ref_NavigationPoint', Node)
   {
      Num++;
      if (Node.TeamNum == TeamNum)
      {
         return Node;
      }

      if (Num == 3)
         `Log ("Warning: there are more than 2 Rx_Ref_NavigationPoint <Harvester could get Problems> !!!!");
   }
   `Log ("Warning: no RenX_Tib_Nodes found! harvester won't work!!!!!");
   return none;
}

function bool IsTurningToDock() {
	return harv_vehicle.bTurningToDock;
}

defaultproperties
{
	bIsPlayer 					= false
	bLogTripTimes = false
}
