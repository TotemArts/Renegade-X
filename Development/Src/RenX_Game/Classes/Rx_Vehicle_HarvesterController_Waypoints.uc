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
class Rx_Vehicle_HarvesterController_Waypoints extends Rx_Vehicle_HarvesterController;
    


var Rx_Tib_NavigationPoint tibNode;
var Rx_Ref_NavigationPoint refNode;


var NavigationPoint BlockedNavPointBehindMe;
var vector refineryLoc,loc;
var rotator refineryRot;
var Rx_BuildingAttachment DockingStation;
var bool bTurnLeftToFaceRef;



var Rx_BlockedForHarvesterPathnode	Nav;

//Commander variables for halting the harvester
var name StateWhenLastMoving; 
var Actor NavPointWhenHalted;
var bool bIgnoreBlockHarvNodes; 

var bool bHasntCheckedForIntialStop; //Check the team info for if we need to stop on creation 

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
	SetTimer(0.05, false, 'CheckRadarVisibility'); 	
	bQueuedStop = Rx_TeamInfo(PlayerReplicationInfo.Team).bGetHarvStopped(); 
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	SetRadarVisibility(RadarVisibility);
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
	function bool ToggleHaltHarv(Rx_Controller InstigatingController, optional bool bForce) 
	{
		SetQueuedStop(InstigatingController);
		return true; 
	}
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

	/***Handle Harvester Commander commands***/
	function bool ToggleHaltHarv(Rx_Controller InstigatingController, optional bool bForce = false) 
	{
		if(!bForce && (InstigatingController == none || Rx_PRI(InstigatingController.PlayerReplicationInfo).bGetIsCommander() == false)) 
		{
			return false; //Failed
		}
		else
		{
			ClearQueuedStop();
			bHasntCheckedForIntialStop = false; 
			
			if(ScriptedMoveTarget == GetHaltedWaypoint()) //Already Blocked. Unblock us  
			{
				GotoState(StateWhenLastMoving);
				ClearTimer('CloseToHaltedWaypoint');
				bIgnoreBlockHarvNodes = false; 
				return true; 
			}
			else //Enter Halted state
			{
				GotoState('HarvesterHalted');
				return true;
			}
			
		}
		
	}
	
	function UpdateHaltedHarvWaypoint(bool bNeedsPush)
	{
		local Rx_CommanderWayPoint Halt_Destination; 
		
		Halt_Destination = GetHaltedWaypoint(); 
		
		if(ScriptedMoveTarget == refNode || ScriptedMoveTarget == tibNode) return; 
		
		if(Halt_Destination != none) ScriptedMoveTarget = Halt_Destination;
		
	}
	
	
	function CloseToHaltedWaypoint()
	{
		local Rx_CommanderWayPoint Halted_Waypoint; 
		
		Halted_Waypoint = GetHaltedWaypoint(); 
		
		if(Halted_Waypoint != none && VSizeSq(Halted_Waypoint.location-location) <= 1000000)
			{
				StopMovement();
				//ClearTimer('CloseToHaltedWaypoint');
				PopState(); //Go back to being blocked
			}
	}	
	
	
Begin:

	if(bQueuedStop){
		ToggleHaltHarv(QueuedStopController, bHasntCheckedForIntialStop); 
	}
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
			if(!bIgnoreBlockHarvNodes)
			{
				foreach WorldInfo.AllNavigationPoints(class'Rx_BlockedForHarvesterPathnode',Nav)
				{
					Nav.TransientCost = 10000000.0; // so that the Harv avoids this kind of pathnodes. The cost is cleared automatically after the next FindPathToward 
				}
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
				// FindPathToward failed. Try detouring
				MoveTarget = FindBetterPathToward(ScriptedMoveTarget);
				if(MoveTarget != None)
					MoveToward(MoveTarget, ScriptedFocus);
			}
			if(MoveTarget == None)
			{
				// abort the move
				if(Rx_CommanderWayPoint(ScriptedMoveTarget) != none) PopState(); //Getting all the way to the block waypoint isn't essential. Just near enough
				
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
/** ------- HANDEPSILON EXPERIMENTAL CODE INC. -------
 *	In many occassions the harvester will get a pathfinding derp. In these cases, we should try to detour
 *	This function will attempt to find any nearby path around the harvy and will pick the path that's both reachable
 *	And closest to the current final route.
 */
function NavigationPoint FindBetterPathToward(Actor Destination)
{
	local NavigationPoint N, BestN;
	local float BestDist, CurrentDist;

	foreach WorldInfo.RadiusNavigationPoints(class'NavigationPoint',N,Pawn.Location,5000.F)
	{
		if((Rx_BlockedForHarvesterPathnode(N) != None && !bIgnoreBlockHarvNodes) || !ActorReachable(N) || Pawn.Anchor == N)
			continue;

		CurrentDist = VSizeSq(Destination.Location - N.Location);

		if(BestN == None || BestDist > CurrentDist)
		{
			BestN = N;
			BestDist = CurrentDist;
		}
	}

	return BestN;
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

	function bool ToggleHaltHarv(Rx_Controller InstigatingController, optional bool bForce) {
		SetQueuedStop(InstigatingController);
		return true;} 

	function finishHarvesting()
	{
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

Begin:
	
	
	if (bLogTripTimes)
	{
		`log(((TeamNum == 0)? "GDI" : "Nod") @ " harvester took " @ tripTimer @ " to reach tiberium field.");
		tripTimer = 0;
	}
	
	harv_vehicle.SetFriendlyStateName("Harvesting Tiberium");
	harv_vehicle.bPlayOpeningAnim = false;
	harv_vehicle.bPlayHarvestingAnim = true;
	if(WorldInfo.NetMode != NM_DedicatedServer)
		Pawn.Mesh.PlayAnim('Harvesting',,true);

	SetTimer(refinery.HarvesterHarvestTime,,'finishHarvesting');   
}

state MovingToTib
{
   ignores SeePlayer, HearNoise, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling;

	function BeginState(Name PreviousStateName)
	{
		harv_vehicle.SetFriendlyStateName("Moving to Tiberium");
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

	function bool ToggleHaltHarv(Rx_Controller InstigatingController, optional bool bForce) {
		SetQueuedStop(InstigatingController);
		return true;} //Do not allow blocking whilst transitioning states
	
Begin:
	
   SetTimer(1.0,true,'CheckDistToTib');	
	if (tibNode != none)
		tibNode.bBlocked = false;
	if (refNode != none)
		refNode.bBlocked = false;
	StateWhenLastMoving = GetStateName();
   PushState('ScriptedMove');
   if(tibNode != none && Pawn.ReachedDestination(tibNode))
   {
        tibNode.bBlocked = true;
        WorldInfo.Game.NotifyNavigationChanged(tibNode);
        GotoState('Harvesting');
   }
}

function CheckDistToTib() {
	if(tibNode != none && VSizeSq(Pawn.location - tibNode.location) < 1000000.0) {
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
		harv_vehicle.SetFriendlyStateName("Returning to Refinery");
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
	
	function bool ToggleHaltHarv(Rx_Controller InstigatingController, optional bool bForce) {
		SetQueuedStop(InstigatingController);
		return true;} //Do not allow blocking whilst transitioning states
	
Begin:

   StateWhenLastMoving = GetStateName();
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
	if(harv_vehicle != none && harv_vehicle.bTurningToDock) 
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
	harv_vehicle.SetFriendlyStateName("Unloading");
	
	if (refNode != none)
		refNode.bBlocked = false;
	refinery.HarvesterDocked(self);

	if (bLogTripTimes)
	{
		`log(((TeamNum == 0)? "GDI" : "Nod")  @ " harvester took " @ tripTimer @ " to return to refinery.");
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

state HarvesterHalted
{
    
   ignores SeePlayer, HearNoise, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling;

   event PoppedState()
	{
		if (Pawn != None)
		{
			harv_vehicle.SetFriendlyStateName("Stopped");
			StopMovement();
			//SetTimer(1.0,true,'CloseToHaltedWaypoint');
			//UpdateHaltedHarvWaypoint(true);
		}
	}
   
	function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName); 
		
		//Save what we were doing so we can go back to it
		//StateWhenLastMoving = PreviousStateName;
		if(ScriptedMoveTarget == refNode || ScriptedMoveTarget == tibNode) NavPointWhenHalted = ScriptedMoveTarget; 
		
		ClearTimer('destroyIfHarvSeemsToBeStuck');//Don't blow yourself up if you're hanging out for awhile
		StopMovement(); //Stop momentarily
		
		//SetTimer(1.0,true,'TimerLogState');
		
		harv_vehicle.SetFriendlyStateName("Stopped");
		UpdateHaltedHarvWaypoint(false);
		
		//SetTimer(1.0,true,'CloseToHaltedWaypoint');
		//Inform the team
		Rx_Game(WorldInfo.Game).CTextBroadCast(GetTeamNum(),"Harvester Stopped",'LightBlue');
		
		bIgnoreBlockHarvNodes = true; //Ignore blocking path nodes for now			
	}
	
	
	function bool ToggleHaltHarv(Rx_Controller InstigatingController, optional bool bForce) 
	{
		if(InstigatingController != none && Rx_PRI(InstigatingController.PlayerReplicationInfo).bGetIsCommander() == false) 
		{
			return false; //Failed
		}
		
		//if(StateWhenLastMoving !='') {}
			//`log("UnhaltHalt Harv"); 
			ScriptedMoveTarget=NavPointWhenHalted;
			Rx_Game(WorldInfo.Game).CTextBroadCast(GetTeamNum(),"Harvester Started",'LightBlue');
			bIgnoreBlockHarvNodes = false; 
			GotoState(StateWhenLastMoving);
			return true; 
		
	}
	
	
	function UpdateHaltedHarvWaypoint(bool bNeedsPush)
	{
		local Rx_CommanderWayPoint Halted_Waypoint; 
		
		Halted_Waypoint=GetHaltedWaypoint(); 
		
		//`log("Updated Harv Waypoint"); 
		
		if(Halted_Waypoint != none && VSizeSq(Halted_Waypoint.location-location) > 1000000) 
			{
				ScriptedMoveTarget = Halted_Waypoint;
				harv_vehicle.SetFriendlyStateName("Moving to stand by");
				PushState('ScriptedMove');
			}
			else
			if(Halted_Waypoint != none && VSizeSq(Halted_Waypoint.location-location) <= 1000000)
			{
				StopMovement(); 
				ClearTimer('CloseToHaltedWaypoint');
				harv_vehicle.SetFriendlyStateName("Standing by");
				//if(IsTimerActive('UpdateHaltedHarvWaypoint')) ClearTimer('UpdateHaltedHarvWaypoint'); 
			}
			else
			if(Halted_Waypoint == none) 
			{
				StopMovement();
				harv_vehicle.SetFriendlyStateName("Standing by");
				ClearTimer('CloseToHaltedWaypoint');				
			}
	}
	
	
	
}

function Rx_CommanderWayPoint GetHaltedWaypoint()
	{
		local Rx_CommanderWayPoint HW, Halted_Waypoint;
		
		foreach WorldInfo.AllActors(class'Rx_CommanderWayPoint', HW)
		{
			if(GetTeamNum() == 0 && HW.GetMetaTag() == "GDI_Harvester_Halt") 
			{
				Halted_Waypoint = HW;
				break; 
			}
			else
			if(GetTeamNum() == 1 && HW.GetMetaTag() == "Nod_Harvester_Halt") 
			{
				Halted_Waypoint = HW;
				break; 
			}
		}
		
		return Halted_Waypoint; 
	}
	
function TimerLogState()
{
	`log(GetStateName() @ IsTimerActive('CloseToHaltedWaypoint')); 
}

function CloseToHaltedWaypoint() 
{} 



defaultproperties
{
	bHasntCheckedForIntialStop = true 
}
