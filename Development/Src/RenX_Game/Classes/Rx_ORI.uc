//Used to replicate all info the player actually needs.

class Rx_ORI extends ReplicationInfo ;

//var Rx_HUD_Ext LHUD;

/***********************************
Both team's target information
**************************************/
struct AgingTarget 
{
	var Actor T_Actor ;
	var string T_Actor_Name;
	var float   T_Age; //Used as a precise measurement just to tell who was Oldest
	var float T_StartTime;
	var float T_EndTime;
	var bool  Oldest;
	var int Pawn_ID;
	var Vector VehLoc;
	var byte KillFlag; //0 Updated 1: Removed 2: Destroyed 3: Decayed 
	var byte LastKillFlag; //Set when Kill Flag is set, however this one only resets when the Kill flag has been removed. 
	var bool RemoveFlag; //Special Case for removal done by keybind.
};

struct AgingBTarget 
{
	var Rx_Building T_Building ;
	var float   T_Age;
	
};

struct Target_Array //used by the server (and to tell clients when things have changed)
{
	var AgingTarget 		T_Attack[3]; //Need the server actors, as we'll need to reference and update their location/stats
	var AgingTarget 		T_Defend[3];
	var AgingTarget 		T_Repair[3];
	var AgingBTarget B_Attack;
	var AgingBTarget B_Defend;
	var AgingBTarget B_Repair;
	var vector 		T_Waypoint; //Waypoints don't move on their own, so they just need to be a location
	var vector 		T_Waypoint2;
	
	structDefaultProperties
	{
		T_Attack(0)=(T_Actor=none, T_Age=2, Oldest=true)  //Make sure 0 is the default oldest
		T_Defend(0)=(T_Actor=none, T_Age=2, Oldest=true) //Same goes for Defence targets 
		T_Repair(0)=(T_Actor=none, T_Age=2, Oldest=true) //Same goes for Repair targets 
	}
};

struct Local_TargetInfo 
{
	var AgingTarget 		T_Attack[3]; //Used by clients to draw targets locally. Only used for vehicles and pawns, as they differ from client to client. e.g, what is Rx_Pawn_0 to one is Rx_Pawn_12 to some other guy.
	var AgingTarget 		T_Defend[3];
	var AgingTarget 		T_Repair[3];
};

var Local_TargetInfo GDI_LocalInfo[3], NOD_LocalInfo[3]			; 

var repnotify Target_Array GDI_Targets[3], NOD_Targets[3]		;

var int TickFilter												;

var float AttackT_DecayTime, BuildingT_DecayTime, WayPointZOffset;

var int MaxTargets;

var repnotify string Commander_GDI, Commander_Nod ; //Make an array if ever need be

/**********************************************************
Both team's objective information
**********************************************************/
struct OBJECTIVE_INFO 
{
var	string 		OText		;
var int			O_Type		;
	
	structDefaultproperties 
	{
	OText="No Objective Set" 					
	O_Type=0
		
	}
};


var repnotify OBJECTIVE_INFO	Objective_GDI[3], Objective_NOD[3];

replication 
{
//if( bNetInitial && Role == ROLE_Authority )
	
if (bNetDirty && Role == ROLE_Authority)
GDI_Targets, NOD_Targets, Objective_GDI, Objective_NOD, Commander_GDI, Commander_Nod;

}
/**
simulated event ReplicatedEvent(name VarName)
{
		if(VarName == 'Commander_GDI')
		{
		HUDVisuals.UpdateGDICommander; 
		}
		else
		if(VarName == 'Commander_Nod')
		{
		HUDVisuals.UpdateNodCommander; 
		}
		else
		super.ReplicatedEvent(VarName);
}
*/

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

TickFilter++;

if(TickFilter >=4) 
{
UpdateTargetAgeNod();
UpdateTargetAgeGDI();
}

	
if(TickFilter >=5) TickFilter=0;
	
	
}


reliable server function StoreObjective(string TeamS, int CT, int rank, string Obj)
{
	
	switch(TeamS)
	{
		case "GDI":
		Objective_GDI[rank].OText=Obj ;
		Objective_GDI[rank].O_Type=CT ;
		break;
		
		case "NOD":
		Objective_NOD[rank].OText=Obj ;
		Objective_NOD[rank].O_Type=CT ;
		break;
			
	}
	`log(TeamS@"Objective Stored");
}

reliable server function Update_Markers (
string TeamS, //String of what team we're updating these for. The object keeps track of GDI/Nod targets, but only displays the targets that correspond with the 
int CT, //Type of call getting passed down. 0:Attack 1: Defend 2: Repair 3: Waypoint
int rank, //Whether to update Commander/CoCommander or Support Targets
bool isWaypointUpdate, // If we're looking to update a waypoint. If this is true, and CT is equal to 1, we'll update the defensive waypoint.
bool isBuildingUpdate, //If this is a building being targeted
optional Actor A,	//Actor we'll be marking
optional Actor B, //Actor that is more than likely a building, only used for specific instances
optional Vector WP_Coord, //Coordinates of the waypoint if this is a waypoint update (Everything below this can be deleted)
optional string A_String,	
optional Vector V_Loc,		//Second workaround for multiplayer, since vehicles have a tendency to get totally out of sync.
optional int P_ID			//3rd workround for multiplayer. Use the player ID of the pawn's PRI to determine what pawn to draw targets on on all clients. 	
)
{
local int i;
local bool Penetrated; //Used to tell if the updated target was able to just find an open spot.
local bool TryString;
local Pawn Converted_A;
local float WorldSeconds;

WorldSeconds=WorldInfo.TimeSeconds;

Penetrated = false;
TryString = false; 
Converted_A=Pawn(A);
		
		`log("Run Update in ORI"); 
		
	switch (CT) 
	{
		case 0:
		
		///////////////////////////Attack section for GDI/////////////////////////
		//If it's for GDI, update GDI attack markers
		if(TeamS == "GDI") 
		{
		//Find an open attack marker spot and put it there. If you can't find one, override the oldest
		if(!isBuildingUpdate)
			{
				`log("--------Recieved Actor as target: "$A $Converted_A);
				if(A == none && Converted_A == none) return;
				for (i=0;i<MaxTargets;i++) //Initially, just see if there's an open spot
				{
				
				if(GDI_Targets[rank].T_Attack[i].T_Actor == none) //Is there nothing here?
				
					{
					if(!TryString) GDI_Targets[rank].T_Attack[i].T_Actor = A ; //unoccupied, so take it
					else
					{
						
					GDI_Targets[rank].T_Attack[i].KillFlag=0;
					GDI_Targets[rank].T_Attack[i].T_Actor = Converted_A ;	
					GDI_Targets[rank].T_Attack[i].T_Actor_Name = string (Converted_A.name);
					}
					//Set  target info 
					if(Rx_Pawn(Converted_A) != none ) 
						{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(0,0, i);
						}
					else
					if(Rx_Vehicle(Converted_A) != none ) 
						{
						Rx_Vehicle(Converted_A).bIsTarget=true; 
						Rx_Vehicle(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Vehicle(Converted_A).ClientNotifyTarget(0,0, i);
						}
					
					GDI_Targets[rank].T_Attack[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					GDI_Targets[rank].T_Attack[i].T_StartTime = WorldSeconds;
					GDI_Targets[rank].T_Attack[i].T_EndTime = WorldSeconds+AttackT_DecayTime;
					
					GDI_Targets[rank].T_Attack[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					break;
					}		
				}
				
				//I didn't make it in, so get hostile
			if(!Penetrated) 
				{
					for (i=0;i<MaxTargets;i++) //Find the oldest then, and kick his ass.
					{
				
					if(GDI_Targets[rank].T_Attack[i].T_Actor != none && GDI_Targets[rank].T_Attack[i].Oldest==true) //You old? GTFO
				
						{
							
					if(!TryString) GDI_Targets[rank].T_Attack[i].T_Actor = A ; //GTFO
					else
					{
					GDI_Targets[rank].T_Attack[i].KillFlag=0;
					GDI_Targets[rank].T_Attack[i].T_Actor = Converted_A ; 
					GDI_Targets[rank].T_Attack[i].T_Actor_Name = string (Converted_A.name);
					}
				
				//Set  target info 
					if(Rx_Pawn(Converted_A) != none )
					{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(0,0, i);
					}
					else
					if(Rx_Vehicle(Converted_A) != none ) 
						{
						Rx_Vehicle(Converted_A).bIsTarget=true; 
						Rx_Vehicle(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Vehicle(Converted_A).ClientNotifyTarget(0,0, i);
						}
				
				GDI_Targets[rank].T_Attack[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					GDI_Targets[rank].T_Attack[i].T_StartTime = WorldSeconds;
					GDI_Targets[rank].T_Attack[i].T_EndTime = WorldSeconds+AttackT_DecayTime;
					
					GDI_Targets[rank].T_Attack[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					UpdateTargetAgeGDI();	//Force an update call here, otherwise when this statement reiterates, nothing will be the Oldest.
					break;
						}		
					}
				}			
			}
			
			if(isBuildingUpdate) 
			{
				GDI_Targets[rank].B_Attack.T_Building=Rx_Building(B); //Can't really think of needing to do much more with this
				GDI_Targets[rank].B_Attack.T_Age=0;
			}
			
			
			
		}
		
		///////////////////////////Attack section for NOD/////////////////////////
		//If it's for NOD, update NOD attack markers
		if(TeamS == "NOD") 
		{
		//Find an open attack marker spot and put it there. If you can't find one, override the oldest
		if(!isBuildingUpdate)
			{
				`log("--------Recieved Actor as target: "$A $Converted_A);
				if(A == none && Converted_A == none) return;
				for (i=0;i<MaxTargets;i++) //Initially, just see if there's an open spot
				{
				
				if(NOD_Targets[rank].T_Attack[i].T_Actor == none) //Is there nothing here?
				
					{
					if(!TryString) NOD_Targets[rank].T_Attack[i].T_Actor = A ; //unoccupied, so take it
					else
					{
					NOD_Targets[rank].T_Attack[i].KillFlag=0;
					NOD_Targets[rank].T_Attack[i].T_Actor = Converted_A ;	
					NOD_Targets[rank].T_Attack[i].T_Actor_Name = string (Converted_A.name);
					}
				
				//Set  target info 
					if(Rx_Pawn(Converted_A) != none )
					{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(1,0, i);
					}
					else
					if(Rx_Vehicle(Converted_A) != none) Rx_Vehicle(Converted_A).bIsTarget=true; 
				
					NOD_Targets[rank].T_Attack[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					NOD_Targets[rank].T_Attack[i].T_StartTime = WorldSeconds;
					NOD_Targets[rank].T_Attack[i].T_EndTime = WorldSeconds+AttackT_DecayTime;
					
					NOD_Targets[rank].T_Attack[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					break;
					}		
				}
				
				//I didn't make it in, so get hostile
			if(!Penetrated) 
				{
					for (i=0;i<MaxTargets;i++) //Find the oldest then, and kick his ass.
					{
				
					if(NOD_Targets[rank].T_Attack[i].T_Actor != none && NOD_Targets[rank].T_Attack[i].Oldest==true) //You old? GTFO
				
						{
							
					if(!TryString) NOD_Targets[rank].T_Attack[i].T_Actor = A ; //GTFO
					else
					{
					NOD_Targets[rank].T_Attack[i].KillFlag=0;
					NOD_Targets[rank].T_Attack[i].T_Actor = Converted_A ; 
					NOD_Targets[rank].T_Attack[i].T_Actor_Name = string (Converted_A.name);
					}
				
				//Set  target info 
					if(Rx_Pawn(Converted_A) != none )
					{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(1,0, i);
					}
					else
					if(Rx_Vehicle(Converted_A) != none) Rx_Vehicle(Converted_A).bIsTarget=true; 
				
				NOD_Targets[rank].T_Attack[i].T_StartTime = WorldSeconds;
				NOD_Targets[rank].T_Attack[i].T_EndTime = WorldSeconds+AttackT_DecayTime;
				NOD_Targets[rank].T_Attack[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					NOD_Targets[rank].T_Attack[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					UpdateTargetAgeNOD();	//Force an update call here, otherwise when this statement reiterates, nothing will be the Oldest.
					break;
						}		
					}
				}			
			}
			
			if(isBuildingUpdate) 
			{
				NOD_Targets[rank].B_Attack.T_Building=Rx_Building(B); //Can't really think of needing to do much more with this. We just need to know which building
				NOD_Targets[rank].B_Attack.T_Age=0;
			}
			
		}
		break;
		
		
		case 1: // Defence update 
		
		///////////////////////////Defend section for GDI/////////////////////////
		//If it's for GDI, update GDI Defend markers
		if(TeamS == "GDI") 
		{
			
		//[REDACTED] Use 2 different Nav Waypoints
			
			//Find an open Defend marker spot and put it there. If you can't find one, override the oldest
		if(!isBuildingUpdate)
			{
				`log("--------Recieved Actor as target: "$A $Converted_A);
				if(A == none && Converted_A == none) return;
				for (i=0;i<MaxTargets;i++) //Initially, just see if there's an open spot
				{
				
				if(GDI_Targets[rank].T_Defend[i].T_Actor == none) //Is there nothing here?
				
					{
					if(!TryString) GDI_Targets[rank].T_Defend[i].T_Actor = A ; //unoccupied, so take it
					else
					{
					GDI_Targets[rank].T_Defend[i].KillFlag=0;
					GDI_Targets[rank].T_Defend[i].T_Actor = Converted_A ;	
					GDI_Targets[rank].T_Defend[i].T_Actor_Name = string (Converted_A.name);
					}
				
				//Set  target info 
					if(Rx_Pawn(Converted_A) != none )
					{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(0,1, i);
					}
					else
					if(Rx_Vehicle(Converted_A) != none) Rx_Vehicle(Converted_A).bIsDefensiveTarget=true; 
				
					GDI_Targets[rank].T_Defend[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					GDI_Targets[rank].T_Defend[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					break;
					}		
				}
				
				//I didn't make it in, so get hostile
			if(!Penetrated) 
				{
					for (i=0;i<MaxTargets;i++) //Find the oldest then, and kick his ass.
					{
				
					if(GDI_Targets[rank].T_Defend[i].T_Actor != none && GDI_Targets[rank].T_Defend[i].Oldest==true) //You old? GTFO
				
						{
							
					if(!TryString) GDI_Targets[rank].T_Defend[i].T_Actor = A ; //GTFO
					else
					{
					GDI_Targets[rank].T_Defend[i].KillFlag=0;
					GDI_Targets[rank].T_Defend[i].T_Actor = Converted_A ; 
					GDI_Targets[rank].T_Defend[i].T_Actor_Name = string (Converted_A.name);
					}
					
					//Set  target info 
					if(Rx_Pawn(Converted_A) != none )
					{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(0,1, i);
					}
					else
					if(Rx_Vehicle(Converted_A) != none) Rx_Vehicle(Converted_A).bIsDefensiveTarget=true; 
				
				
				GDI_Targets[rank].T_Defend[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					GDI_Targets[rank].T_Defend[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					UpdateTargetAgeGDI();	//Force an update call here, otherwise when this statement reiterates, nothing will be the Oldest.
					break;
						}		
					}
				}			
			}
			
			if(isBuildingUpdate) 
			{
				GDI_Targets[rank].B_Defend.T_Building=Rx_Building(B); //Can't really think of needing to do much more with this but tell what building to draw at
				GDI_Targets[rank].B_Defend.T_Age=0;
			}
			
			
			
			
		}
		
		///////////////////////////Defend section for NOD/////////////////////////
		//If it's for NOD, update NOD Defend markers
		if(TeamS == "NOD") 
		{
			
				
			//Find an open Defend marker spot and put it there. If you can't find one, override the oldest
		if(!isBuildingUpdate)
			{
				`log("--------Recieved Actor as target: "$A $Converted_A);
				if(A == none && Converted_A == none) return;
				for (i=0;i<MaxTargets;i++) //Initially, just see if there's an open spot
				{
				
				if(NOD_Targets[rank].T_Defend[i].T_Actor == none) //Is there nothing here?
				
					{
					if(!TryString) NOD_Targets[rank].T_Defend[i].T_Actor = A ; //unoccupied, so take it
					else
					{
					NOD_Targets[rank].T_Defend[i].KillFlag=0;
					NOD_Targets[rank].T_Defend[i].T_Actor = Converted_A ;	
					NOD_Targets[rank].T_Defend[i].T_Actor_Name = string (Converted_A.name);
					}
				
				//Set  target info 
					if(Rx_Pawn(Converted_A) != none )
					{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(1,1, i);
					}
					else
					if(Rx_Vehicle(Converted_A) != none) Rx_Vehicle(Converted_A).bIsDefensiveTarget=true; 
				
				
					NOD_Targets[rank].T_Defend[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					NOD_Targets[rank].T_Defend[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					break;
					}		
				}
				
				//I didn't make it in, so get hostile
			if(!Penetrated) 
				{
					for (i=0;i<MaxTargets;i++) //Find the oldest then, and kick his ass.
					{
				
					if(NOD_Targets[rank].T_Defend[i].T_Actor != none && NOD_Targets[rank].T_Defend[i].Oldest==true) //You old? GTFO
				
						{
							
					if(!TryString) NOD_Targets[rank].T_Defend[i].T_Actor = A ; //GTFO
					else
					{
					NOD_Targets[rank].T_Defend[i].KillFlag=0;
					NOD_Targets[rank].T_Defend[i].T_Actor = Converted_A ; 
					NOD_Targets[rank].T_Defend[i].T_Actor_Name = string (Converted_A.name);
					}
				
				//Set  target info 
					if(Rx_Pawn(Converted_A) != none )
					{
						Rx_Pawn(Converted_A).bIsTarget=true; 
						Rx_Pawn(Converted_A).SetTargetAlarm(AttackT_DecayTime);
						Rx_Pawn(Converted_A).ClientNotifyTarget(1,0, i);
					}
					else
					if(Rx_Vehicle(Converted_A) != none) Rx_Vehicle(Converted_A).bIsDefensiveTarget=true; 
				
				
				NOD_Targets[rank].T_Defend[i].T_Age = i+WorldSeconds ; //set its age (Use i so initial setting of 3 targets will all have staggered values, with the 1st target run across being counted as the oldest)
					NOD_Targets[rank].T_Defend[i].Oldest = false ; //Not the Oldest until proven
					Penetrated = true;
					UpdateTargetAgeNOD();	//Force an update call here, otherwise when this statement reiterates, nothing will be the Oldest.
					break;
						}		
					}
				}			
			}
			
			if(isBuildingUpdate) 
			{
				NOD_Targets[rank].B_Defend.T_Building=Rx_Building(B); //Can't really think of needing to do much more with this but tell what building to draw at
				NOD_Targets[rank].B_Defend.T_Age=0;
			}
			
		}
		
		
		break;
		
		case 2:
		//[REDACTED]
		
		//Add in WP1
		if(TeamS == "GDI") 
		{
					
			if(isWaypointUpdate)
			{
			//Set defensive waypoint if that's what this is
			GDI_Targets[rank].T_Waypoint.X = WP_Coord.X ;
			GDI_Targets[rank].T_Waypoint.Y = WP_Coord.Y ;
			GDI_Targets[rank].T_Waypoint.Z = WP_Coord.Z+WayPointZOffset ;
			}
			
			
		}
		
		///////////////////////////TakePoint section for NOD/////////////////////////
		//If it's for NOD, update NOD Waypoint////
		if(TeamS == "NOD") 
		{
		
		
		if(isWaypointUpdate)
			{
			
			//Set defensive waypoint if that's what this is
			NOD_Targets[rank].T_Waypoint.X = WP_Coord.X ;
			NOD_Targets[rank].T_Waypoint.Y = WP_Coord.Y ;
			NOD_Targets[rank].T_Waypoint.Z = WP_Coord.Z+WayPointZOffset ;
			}
		
		
	
		}
		
		
		break;
	
		case 3:
		//WP2
		if(TeamS == "GDI") 
		{
					
			if(isWaypointUpdate)
			{
			//Set defensive waypoint if that's what this is
			GDI_Targets[rank].T_Waypoint2.X = WP_Coord.X ;
			GDI_Targets[rank].T_Waypoint2.Y = WP_Coord.Y ;
			GDI_Targets[rank].T_Waypoint2.Z = WP_Coord.Z+WayPointZOffset ;
			}
			
			
		}
		
		///////////////////////////TakePoint section for NOD/////////////////////////
		//If it's for NOD, update NOD Waypoint////
		if(TeamS == "NOD") 
		{
		
		
		if(isWaypointUpdate)
			{
			//Set defensive waypoint if that's what this is
			NOD_Targets[rank].T_Waypoint2.X = WP_Coord.X ;
			NOD_Targets[rank].T_Waypoint2.Y = WP_Coord.Y ;
			NOD_Targets[rank].T_Waypoint2.Z = WP_Coord.Z+WayPointZOffset ;
			}
		
		
	
		}
	break;
	
	default:
	return;
	}
}


/******************************************************
* Functions to handle Target Ages/Deaths... reasons to override or erase them
******************************************************/

reliable server function EraseTargets(int OType, int rank, int ITeam)
{

local int U;

if(ITeam==0) //GDI
{
	switch(OType)
	{
	case 0: 
		for(U=0;U<3;U++)
		{
		//reset Attack targets
				GDI_Targets[rank].T_Attack[U].KillFlag=1;				//0: Updated 1: Removed 2: Destroyed 3: Decayed 
				GDI_Targets[rank].T_Attack[U].T_Actor = none;
				GDI_Targets[rank].T_Attack[U].T_Age=0;
				GDI_Targets[rank].T_Attack[U].Oldest=false;
				GDI_Targets[rank].T_Attack[U].Pawn_ID=0;
				GDI_Targets[rank].T_Attack[U].T_Actor_Name="";
				GDI_Targets[rank].T_Attack[U].RemoveFlag=true;
				GDI_Targets[rank].T_Attack[U].VehLoc.X=0;
				GDI_Targets[rank].T_Attack[U].VehLoc.Y=0;
				GDI_Targets[rank].T_Attack[U].VehLoc.Z=0;
		}
		break;
	
	case 1: 
		for(U=0;U<3;U++)
		{
		//reset Defend targets 
				GDI_Targets[rank].T_Defend[U].KillFlag=1; //0: Updated 1: Removed 2: Destroyed 3: Decayed 
				GDI_Targets[rank].T_Defend[U].T_Actor = none;
				GDI_Targets[rank].T_Defend[U].T_Age=0;
				GDI_Targets[rank].T_Defend[U].Oldest=false;
				GDI_Targets[rank].T_Defend[U].Pawn_ID=0;
				GDI_Targets[rank].T_Defend[U].T_Actor_Name="";
				GDI_Targets[rank].T_Defend[U].RemoveFlag=true;
				GDI_Targets[rank].T_Defend[U].VehLoc.X=0;
				GDI_Targets[rank].T_Defend[U].VehLoc.Y=0;
				GDI_Targets[rank].T_Defend[U].VehLoc.Z=0;
			
		
		}
		break;
	case 2: 
		for(U=0;U<3;U++)
		{
		//reset waypoint
		//Waypoints don't use killflags, they just look to see if it's 0,0,0 and if so assume it was removed.
			GDI_Targets[rank].T_Waypoint.X =0 ;
			GDI_Targets[rank].T_Waypoint.Y = 0 ;
			GDI_Targets[rank].T_Waypoint.Z = 0 ;
		
		}
		break;
		
		case 3: 
		for(U=0;U<3;U++)
		{
		//reset waypoint
		//Waypoints don't use killflags, they just look to see if it's 0,0,0 and if so assume it was removed.
			GDI_Targets[rank].T_Waypoint2.X =0 ;
			GDI_Targets[rank].T_Waypoint2.Y = 0 ;
			GDI_Targets[rank].T_Waypoint2.Z = 0 ;
		
		}
		break;
	
	}
	
	
}


if(ITeam==1) //NOD	

{
	switch(OType)
	{
	case 0: 
		for(U=0;U<3;U++)
		{
		//reset Attack targets
				NOD_Targets[rank].T_Attack[U].KillFlag=1;
				NOD_Targets[rank].T_Attack[U].T_Actor = none;
				NOD_Targets[rank].T_Attack[U].T_Age=0;
				NOD_Targets[rank].T_Attack[U].Oldest=false;
				NOD_Targets[rank].T_Attack[U].Pawn_ID=0;
				NOD_Targets[rank].T_Attack[U].T_Actor_Name="";
				NOD_Targets[rank].T_Attack[U].RemoveFlag=true;
				`log("KillFlag in function:"@NOD_Targets[rank].T_Attack[U].KillFlag);
				NOD_Targets[rank].T_Attack[U].VehLoc.X=0;
				NOD_Targets[rank].T_Attack[U].VehLoc.Y=0;
				NOD_Targets[rank].T_Attack[U].VehLoc.Z=0;
		}
		break;
	
	case 1: 
		for(U=0;U<3;U++)
		{
		//reset Defend targets 
				NOD_Targets[rank].T_Defend[U].KillFlag=1;
				NOD_Targets[rank].T_Defend[U].T_Actor = none;
				NOD_Targets[rank].T_Defend[U].T_Age=0;
				NOD_Targets[rank].T_Defend[U].Oldest=false;
				NOD_Targets[rank].T_Defend[U].Pawn_ID=0;
				NOD_Targets[rank].T_Defend[U].T_Actor_Name="";
				NOD_Targets[rank].T_Defend[U].RemoveFlag=true;
				NOD_Targets[rank].T_Defend[U].VehLoc.X=0;
				NOD_Targets[rank].T_Defend[U].VehLoc.Y=0;
				NOD_Targets[rank].T_Defend[U].VehLoc.Z=0;
		}
		break;
	case 2: 
		for(U=0;U<3;U++)
		{
		//reset Repair targets 
				NOD_Targets[rank].T_Repair[U].KillFlag=1;
				NOD_Targets[rank].T_Repair[U].T_Actor = none;
				NOD_Targets[rank].T_Repair[U].T_Age=0;
				NOD_Targets[rank].T_Repair[U].Oldest=false;
				NOD_Targets[rank].T_Repair[U].Pawn_ID=0;
				NOD_Targets[rank].T_Repair[U].T_Actor_Name="";
				NOD_Targets[rank].T_Repair[U].RemoveFlag=true;
				NOD_Targets[rank].T_Repair[U].VehLoc.X=0;
				NOD_Targets[rank].T_Repair[U].VehLoc.Y=0;
				NOD_Targets[rank].T_Repair[U].VehLoc.Z=0;
		}
		break;
		
		case 3: 
		for(U=0;U<3;U++)
		{
		//reset Take Waypoint targets 
				NOD_Targets[rank].T_Waypoint.X =0 ;
			NOD_Targets[rank].T_Waypoint.Y = 0 ;
			NOD_Targets[rank].T_Waypoint.Z = 0 ;
		
		}
		break;
	
	}
	
	
}

	
	
	
}


function UpdateTargetAgeGDI()
{
local int T,U;

//Full variant
for(T=0;T<3;T++) //Find who's oldest... 
	{
	for(U=0;U<MaxTargets;U++) 
		{
		//GDI//
		
		//Attack Targets 
		if(GDI_Targets[T].T_Attack[U].T_Age == MaxofThree(GDI_Targets[T].T_Attack[0].T_Age, GDI_Targets[T].T_Attack[1].T_Age, GDI_Targets[T].T_Attack[2].T_Age)) GDI_Targets[T].T_Attack[U].Oldest=true ;		
		else
		GDI_Targets[T].T_Attack[U].Oldest=false ;
		
		//Defence Targets
		if(GDI_Targets[T].T_Defend[U].T_Age == MaxofThree(GDI_Targets[T].T_Defend[0].T_Age, GDI_Targets[T].T_Defend[1].T_Age, GDI_Targets[T].T_Defend[2].T_Age)) GDI_Targets[T].T_Defend[U].Oldest=true ;		
		else
		GDI_Targets[T].T_Defend[U].Oldest=false ;
		
		}
	}	

}

function UpdateTargetAgeNod()
{
local int T,U;

//Full variant
for(T=0;T<3;T++) //Find who's oldest... 
	{
	for(U=0;U<MaxTargets;U++) 
		{
	
		//NOD//
		//Attack Targets 
		if(NOD_Targets[T].T_Attack[U].T_Age == MaxofThree(NOD_Targets[T].T_Attack[0].T_Age, NOD_Targets[T].T_Attack[1].T_Age, NOD_Targets[T].T_Attack[2].T_Age)) NOD_Targets[T].T_Attack[U].Oldest=true ;		
		else
		NOD_Targets[T].T_Attack[U].Oldest=false ;
		
		//Defence Targets
		if(NOD_Targets[T].T_Defend[U].T_Age == MaxofThree(NOD_Targets[T].T_Defend[0].T_Age, NOD_Targets[T].T_Defend[1].T_Age, NOD_Targets[T].T_Defend[2].T_Age)) NOD_Targets[T].T_Defend[U].Oldest=true ;		
		else
		NOD_Targets[T].T_Defend[U].Oldest=false ;
	
		}
	}
}


simulated function float MaxofThree(float X, float Y, float Z)

{
if(X >= Fmax(Y,Z)) return X;
else
if(Y >= Fmax(X,Z)) return Y;
else
return Z;
	
}

function NotifyTargetKilled(Actor SentActor)
{
	local int i, j;
	
	j=0 ; //Till multiple
	//Iterate GDI targets to find the target
		
		for(i=0;i<MaxTargets;i++)
				{
				if(GDI_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					GDI_Targets[i].T_Attack[j].KillFlag=2;
					GDI_Targets[i].T_Attack[j].T_Actor = none;
					GDI_Targets[i].T_Attack[j].T_Age=0;
					GDI_Targets[i].T_Attack[j].Oldest=false;
					GDI_Targets[i].T_Attack[j].Pawn_ID=0;
					GDI_Targets[i].T_Attack[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					GDI_Targets[i].T_Attack[j].VehLoc.X=0;
					GDI_Targets[i].T_Attack[j].VehLoc.Y=0;
					GDI_Targets[i].T_Attack[j].VehLoc.Z=0;
					break; 
					}	
				else
				if(GDI_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					GDI_Targets[i].T_Defend[j].KillFlag=2;
					GDI_Targets[i].T_Defend[j].T_Actor = none;
					GDI_Targets[i].T_Defend[j].T_Age=0;
					GDI_Targets[i].T_Defend[j].Oldest=false;
					GDI_Targets[i].T_Defend[j].Pawn_ID=0;
					GDI_Targets[i].T_Defend[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					GDI_Targets[i].T_Defend[j].VehLoc.X=0;
					GDI_Targets[i].T_Defend[j].VehLoc.Y=0;
					GDI_Targets[i].T_Defend[j].VehLoc.Z=0;
					break; 
					}	
					else
					continue;
				}
			//Iterate Nod Targets to find the target if it exists there
				
			for(i=0;i<MaxTargets;i++)
				{
				if(Nod_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Attack[j].KillFlag=2;
					Nod_Targets[i].T_Attack[j].T_Actor = none;
					Nod_Targets[i].T_Attack[j].T_Age=0;
					Nod_Targets[i].T_Attack[j].Oldest=false;
					Nod_Targets[i].T_Attack[j].Pawn_ID=0;
					Nod_Targets[i].T_Attack[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					Nod_Targets[i].T_Attack[j].VehLoc.X=0;
					Nod_Targets[i].T_Attack[j].VehLoc.Y=0;
					Nod_Targets[i].T_Attack[j].VehLoc.Z=0;
					break; 
					}	
				else
					if(Nod_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Defend[j].KillFlag=2;
					Nod_Targets[i].T_Defend[j].T_Actor = none;
					Nod_Targets[i].T_Defend[j].T_Age=0;
					Nod_Targets[i].T_Defend[j].Oldest=false;
					Nod_Targets[i].T_Defend[j].Pawn_ID=0;
					Nod_Targets[i].T_Defend[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					Nod_Targets[i].T_Defend[j].VehLoc.X=0;
					Nod_Targets[i].T_Defend[j].VehLoc.Y=0;
					Nod_Targets[i].T_Defend[j].VehLoc.Z=0;
					break; 
					}
				else
				continue;
				}		
}

function NotifyTargetDecayed(Actor SentActor)
{
	local int i, j;
	
	i=0; 
	
	//Iterate GDI targets to find the target
		for(j=0;j<MaxTargets;j++)
				{
				if(GDI_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					`log("--YL-- Target Decayed " @ SentActor);
					GDI_Targets[i].T_Attack[j].KillFlag=3;
					GDI_Targets[i].T_Attack[j].T_Actor = none;
					GDI_Targets[i].T_Attack[j].T_Age=0;
					GDI_Targets[i].T_Attack[j].Oldest=false;
					GDI_Targets[i].T_Attack[j].Pawn_ID=0;
					GDI_Targets[i].T_Attack[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					GDI_Targets[i].T_Attack[j].VehLoc.X=0;
					GDI_Targets[i].T_Attack[j].VehLoc.Y=0;
					GDI_Targets[i].T_Attack[j].VehLoc.Z=0;
					GDI_Targets[i].T_Attack[j].T_StartTime = 0;
					GDI_Targets[i].T_Attack[j].T_EndTime = 0;
					break; 
					}	
				else
				if(GDI_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					GDI_Targets[i].T_Defend[j].KillFlag=3;
					GDI_Targets[i].T_Defend[j].T_Actor = none;
					GDI_Targets[i].T_Defend[j].T_Age=0;
					GDI_Targets[i].T_Defend[j].Oldest=false;
					GDI_Targets[i].T_Defend[j].Pawn_ID=0;
					GDI_Targets[i].T_Defend[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					GDI_Targets[i].T_Defend[j].VehLoc.X=0;
					GDI_Targets[i].T_Defend[j].VehLoc.Y=0;
					GDI_Targets[i].T_Defend[j].VehLoc.Z=0;
					GDI_Targets[i].T_Defend[j].T_StartTime = 0;
					GDI_Targets[i].T_Defend[j].T_EndTime = 0;
					break; 
					}	
					else
					continue;
				}
			//Iterate Nod Targets to find the target if it exists there
				
			for(i=0;i<MaxTargets;i++)
				{
				if(Nod_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Attack[j].KillFlag=3;
					Nod_Targets[i].T_Attack[j].T_Actor = none;
					Nod_Targets[i].T_Attack[j].T_Age=0;
					Nod_Targets[i].T_Attack[j].Oldest=false;
					Nod_Targets[i].T_Attack[j].Pawn_ID=0;
					Nod_Targets[i].T_Attack[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					Nod_Targets[i].T_Attack[j].VehLoc.X=0;
					Nod_Targets[i].T_Attack[j].VehLoc.Y=0;
					Nod_Targets[i].T_Attack[j].VehLoc.Z=0;
					Nod_Targets[i].T_Attack[j].T_StartTime = 0;
					Nod_Targets[i].T_Attack[j].T_EndTime = 0;
					break; 
					}	
				else
					if(Nod_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Defend[j].KillFlag=3;
					Nod_Targets[i].T_Defend[j].T_Actor = none;
					Nod_Targets[i].T_Defend[j].T_Age=0;
					Nod_Targets[i].T_Defend[j].Oldest=false;
					Nod_Targets[i].T_Defend[j].Pawn_ID=0;
					Nod_Targets[i].T_Defend[j].T_Actor_Name="";
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					Nod_Targets[i].T_Defend[j].VehLoc.X=0;
					Nod_Targets[i].T_Defend[j].VehLoc.Y=0;
					Nod_Targets[i].T_Defend[j].VehLoc.Z=0;
					Nod_Targets[i].T_Defend[j].T_StartTime = 0;
					Nod_Targets[i].T_Defend[j].T_EndTime = 0;
					break; 
					}
				else
				continue;
				}		
}

DefaultProperties
{
	
	AttackT_DecayTime = 25 //seconds
	BuildingT_DecayTime = 2.5
	WayPointZOffset = 100
	MaxTargets=3
}