class Rx_CommanderWaypoint extends Actor
	implements(RxIfc_RadarMarker)
	placeable;
	

var() String MyName;
var protected string MetaTag;  
var() byte TeamIndex;

var Texture MinimapIconTexture;





replication 
{
	if(bnetdirty || bNetInitial)
		MyName, TeamIndex; 
}

simulated function InitWaypoint(string NewName, byte TI, optional string NewMT = "")
{
	local Rx_CommanderWaypoint WP; 
	foreach WorldInfo.AllActors(class'Rx_CommanderWaypoint', WP)
	{
		if(WP.TeamIndex == TI && (WP.GetName() == NewName || (NewMT != "" && WP.GetMetaTag() == NewMT))) 
		{
			WP.Destroy();
			break; 	
		}
	}
	
	SetWayPointName(NewName) ;
	SetWayPointMetaTag(NewMT);
	TeamIndex=TI; 
}

simulated function SetWayPointName(string NewName)
{
	MyName = NewName; 
}

simulated function String GetName(){
	return MyName;
}

function string GetMetaTag()
{
	return MetaTag;
}

function SetWayPointMetaTag(string NewTag)
{
	MetaTag = NewTag; 
}

simulated event byte ScriptGetTeamNum()
{
	return TeamIndex;
}



/******************
*RxIfc_RadarMarker*
*******************/

//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int GetRadarIconType()
{
	return 2; //Miscellaneous
} 

simulated function bool ForceVisible()
{
	return false;  
}

simulated function vector GetRadarActorLocation() 
{
	return location; 
} 
simulated function rotator GetRadarActorRotation()
{
	local rotator NoRotation;
	NoRotation.Roll  = 0;
	NoRotation.Yaw   = 0;
	NoRotation.Pitch = 0;
	return NoRotation; 
}

simulated function byte GetRadarVisibility()
{
	return 1; 
} 
simulated function Texture GetMinimapIconTexture()
{
	return MinimapIconTexture; 
}

/******************
*END RadarMarker***
*******************/




DefaultProperties
{
	MinimapIconTexture = Texture2D'RenXTargetSystem.T_NavMarker_Max_Green'
	bCollideActors = false; 
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant = true; //Draw through walls and over the river and through the woods
}
