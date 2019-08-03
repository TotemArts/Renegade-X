
class Rx_SeqAct_Waypoint extends SequenceAction;

var() bool	bEnabled; 		
var() byte	TeamNum;		// Team: 0=GDI, 1=Nod

var() string WPText; 		// Text to display
var() vector WPLoc; 		// Location of waypoint
var() Actor  WPActor; 		// Actor at which location to place waypoint
	

// Kismet Events


event Activated()
{
	
	if(InputLinks[0].bHasImpulse)		// Set Waypoint
	{	
		if(bEnabled)
		{
			Kismet_SetWaypoint(GetWPText(), GetWPLocation());
			OutputLinks[0].bHasImpulse = true;
		}
	}
	else if(InputLinks[1].bHasImpulse)	// Remove Waypoint
		if(bEnabled)
		{
			Kismet_RemoveWaypoint(GetWPText());
			OutputLinks[1].bHasImpulse = true;
		}
	else if(InputLinks[2].bHasImpulse)	// Enable
		bEnabled=true;
	else if(InputLinks[3].bHasImpulse)	// Disable
		bEnabled=false;
}


event bool Update(float DT)
{
	//return true; remain active
	return false; // finished
}



// Functions
function vector GetWPLocation()
{

	local SeqVar_Vector VecVar;		// local needed for attached vectors
	local SeqVar_Object ObjVar;		// local needed for attached spawnpoints
	
	
	foreach LinkedVariables(class'SeqVar_Vector', VecVar, "Waypoint Location")		
	{
		WPLoc=VecVar.VectValue; // Get coordinates from vector from Kismet References
	}

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Waypoint Actor")		
	{
		WPActor=Actor(ObjVar.GetObjectValue()); // Get Actor for location from Kismet References
	}
	
	
	// override vectors with those of SpawnPoint Actor
	if(WPActor!=None)
	{
		return  WPActor.Location;
	}
	else
	{
		return WPLoc;
	}

}


function string GetWPText()
{
	local SeqVar_String StringVar;		// local needed for attached Strings

	foreach LinkedVariables(class'SeqVar_String', StringVar, "Waypoint Text")		
	{
		WPText=StringVar.StrValue; // Get String Value from Kismet References
	}

	return WPText;
}




reliable server function Kismet_SetWaypoint(string WayPointName, vector WaypointLocation, optional string MetaTag)
{
	local Rx_CommanderWaypoint WP; 
	

	WP=GetWorldInfo().Game.spawn(class'Rx_CommanderWaypoint',,,WaypointLocation,,, true); 
	
	WP.InitWaypoint(WayPointName, TeamNum, MetaTag);
	
}


reliable server function Kismet_RemoveWaypoint(string WayPointName, optional string MetaTag)
{
	local Rx_CommanderWaypoint WP; 
	foreach GetWorldInfo().AllActors(class'Rx_CommanderWaypoint', WP)
	{
		if(WP.GetTeamNum() != TeamNum) continue ; 
		
		if(WP.GetName() == WayPointName || (MetaTag != "" && WP.GetMetaTag() == MetaTag) ) 
		{
			WP.Destroy();
			break; 	
		}
	}
}



defaultproperties
{
	ObjName="Update Waypoint"
	ObjCategory="Ren X"
	
	InputLinks(0)=(LinkDesc="Set Waypoint")
	InputLinks(1)=(LinkDesc="Remove Waypoint")
	InputLinks(2)=(LinkDesc="Enable")
	InputLinks(3)=(LinkDesc="Disable")
	
	OutputLinks(0)=(LinkDesc="Waypoint Added")
	OutputLinks(1)=(LinkDesc="Waypoint Removed")
	
	VariableLinks.Empty
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="Waypoint Text",PropertyName=WPText,bWriteable=false)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Waypoint at Actor",PropertyName=WPActor,bWriteable=false)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Waypoint Location",PropertyName=WPLoc,bWriteable=false)
	
	bCallHandler=false
	bAutoActivateOutputLinks=false
	
	bEnabled=true
}
