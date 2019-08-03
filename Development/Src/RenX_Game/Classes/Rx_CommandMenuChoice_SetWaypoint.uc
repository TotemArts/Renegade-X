class Rx_CommandMenuChoice_SetWaypoint extends Rx_CommandMenuChoice;


function bool DoStuff(optional byte AbilityNumber, optional bool bHeld)
{
	if(!bHeld) return SetWaypoint(AbilityNumber);
	else
	{
	RemoveWayPoint(AbilityNumber);
	return true; 
	}

}

function bool DoSecondaryStuff(optional byte AbilityNumber)

{
	CancelSelection() ; //RemoveWaypoint(AbilityNumber);
	return true; //You can pretty much always try remove a waypoint even if it doesn't exist 
}

function bool SetWaypoint(byte WP)
{
	local string WayPointName; 
	
	WaypointName = SubChoices[WP].Title; 
	
	return Control.SetWaypoint(WayPointName); 
}

function RemoveWaypoint(byte WP)
{
	local string WayPointName; 
	
	WaypointName = SubChoices[WP].Title; 
	
	Control.RemoveWaypoint(WayPointName); 
}

DefaultProperties 
{
CommandTitle = "Manage Waypoints"

SubChoices(0) = (Title = "Meet Here", bChoiceSelected = false, bInstant = false)
SubChoices(1) = (Title = "DEFEND", bChoiceSelected = false, bInstant = false)
SubChoices(2) = (Title = "ATTACK", bChoiceSelected = false, bInstant = false)
SubChoices(3) = (Title = "Hold Position", bChoiceSelected = false, bInstant = false) 
SubChoices(4) = (Title = "Take the Area", bChoiceSelected = false, bInstant = false) 
SubChoices(5) = (Title = "Plant Beacon Here", bChoiceSelected = false, bInstant = false)
SubChoices(6) = (Title = "FOCUS FIRE", bChoiceSelected = false, bInstant = false)

Steps = 1 //Number of Steps to this ability
CurrentStep = 1 //Current step in the process of activating this option.  
bImmediateActivation = false //When selected does this choice immediately respond
bExitOnActivation = false 
bQCast = true // Is this ability casts with Q-spot 
bSelected = false //When true, draw in green and also maybe do other things.

ETextStr = "Cancel"
QTextStr = "Set Waypoint"
QTextHoldStr = "Remove Waypoint"
}