class Rx_CommanderController extends ReplicationInfo;

/**
Rx_CC exists only on the server to hold Commander information, and eventually objective information. 
All information that is actually REPLICATED is sent to Rx_ORI
**/

/** ******************************************
struct CommanderHUD 
{

var Rx_HUD C_HUD ;
var Rx_GfxObject CommanderSymbol ;
var Rx_GfxObject Current_Objective ; 

}
**************************************************** */


struct Commander 
{
var Rx_Pawn CPawn				;
var int ControllerTeamIndex		;	
var string C_Objective	;
var int Pid 					; 
var Rx_PRI CPRI 				; 
var string CName 				;
var Rx_Controller Controller	;
var bool Init_Phase				;
//var Rx_CObjective  TObjective	;

	structDefaultProperties 
	{
	Init_Phase = true	
	}
};

var Commander GDI_Commander[3]	;

var Commander Nod_Commander[3] 	; 

var class ObjectiveReplicationClass ; 
//Types of orders commanders can give 
enum CALL_TYPE 
{
	CT_ATTACK,
	CT_DEFEND,
	CT_REPAIR,
	CT_TAKEPOINT
};

var int ControllerTeamIndex		;

var SoundCue ElectedSound_GDI 	;

var SoundCue ElectedSound_Nod 	;

var color Warning_Color, Caution_Color, Update_Color, Announcment_Color			;

var Rx_ORI ORI;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/

/**function UpdateObjective(byte Team, byte ObjNum)
{	
	/-Update Objectives if they exist
	if(GDI_Commander[ObjNum].TObjective != none)
		{
		GDI_Commander[ObjNum].TObjective.Update();
		if(GDI_Commander[ObjNum].TObjective != none && GDI_Commander[ObjNum].TObjective.Update() == false) DeleteObjective(ObjNum, 0);
		}
		
	if(Nod_Commander[ObjNum].TObjective != none) 
		{
		Nod_Commander[ObjNum].TObjective.Update();
		if(Nod_Commander[ObjNum].TObjective != none && NOD_Commander[ObjNum].TObjective.Update() == false) DeleteObjective(ObjNum, 1);	
		}
}
*/

function Init()
{
	ORI=spawn(class'Rx_ORI',self); 
}

//Called whenever GDI Commanders need to be updated switched/removed/etc
function UpdateGDICommanders()
{
	local int i; 
	
	for(i=0;i<3;i++)
	{
		if(GDI_Commander[i].CPRI != none && GDI_Commander[i].Pid != -1 && !GDI_Commander[i].Init_Phase) 
		{
			if(!CommanderInGame("GDI", i) || !CommanderOnRightTeam("GDI", i))
			EraseCommander("GDI", i);
		}
	}
}

function UpdateNodCommanders()
{
	local int i; 
	
	for(i=0;i<3;i++)
	{
		if(Nod_Commander[i].CPRI != none && Nod_Commander[i].Pid != -1 && !Nod_Commander[i].Init_Phase) 
		{
			if(!CommanderInGame("Nod", i) || !CommanderOnRightTeam("Nod", i))
			EraseCommander("Nod", i);
		}
	}
}

/***************************************************************************************************************
*Function that when called, updates the objective for a team, then sends it to Rx_ORI to actually process targets
*and handle targeting information.
****************************************************************************************************************/

reliable server function Update_Obj (
	int Team,	//0 = GDI, 1=Nod
	int rank, //Same rank 0-2 to define primary/secondary and support commanders/Objectives  
	int CT,	//Call type. Type of objective being passed: 0:Attack 1:Defend 3:TakePoint
	bool IsWaypointUpdate, //Is this a waypoint being updated? When this is true, there should be no actor or anything else needed. 
	bool IsActualUpdate, //Says whether or not this warrants updating the objective in the objective box, as well as giving the "Primary/Secondary Objective Updated" message
	optional Actor A,	//Actor the main command is directed at.
	optional Actor B, //Actor that is more than likely a building, only used when ItActualUpdate is true.
	optional Vector WP_Coord,	//Coordinates of the waypoint if this is a waypoint update
	optional string A_String, 	//string used as a workaround in multiplayer since the actors designated by the binoculars can't be directly passed to the server.
	optional Vector V_Loc,		//Second workaround for multiplayer, since vehicles have a tendency to get totally out of sync.
	optional int P_ID			//3rd workround for multiplayer. Use the player ID of the pawn's PRI to determine what pawn to draw targets on on all clients. 
	)
//string S,	Start of "optional" components. These are "optional" only in that they are only used depending on what type of call it is.
{
	
	local string T_String;
	
	switch (Team)
	{
		case 0: 
		T_String="GDI" ;
		break;
		
		case 1: 
		T_String="NOD" ; //Capitalized throughout for consistency
		break;
	}
	switch(CT)
		{
		
		
		
		case 0: //CT_ATTACK :
				ORI.Update_Markers (T_String, CT, rank, IsWaypointUpdate, IsActualUpdate, A, B, WP_Coord, A_String, V_Loc, P_ID) ;
			break;
			
		case 1: // CT_DEFEND : 
				
				ORI.Update_Markers (T_String, CT, rank, IsWaypointUpdate, IsActualUpdate, A, B, WP_Coord, A_String, V_Loc, P_ID) ;
				
				break;
			
		case 2: //CT_WP1
			
			
			ORI.Update_Markers (T_String, CT, rank, IsWaypointUpdate, IsActualUpdate, A, B, WP_Coord, A_String,V_Loc, P_ID) ;
			break;
				
		case 3: //CT_TAKEPOINT : //Not finished
		
			ORI.Update_Markers (T_String, CT, rank, IsWaypointUpdate, IsActualUpdate, A, B, WP_Coord, A_String, V_Loc, P_ID) ;
			break;
		}
}

reliable server function SetCommander(Rx_Controller PC, int Team, int rank)
{

//rank 0: Commander 
//rank 1: CoCommander
//rank 2: SupportCommander 

local Rx_Pawn P ;
P = Rx_Pawn(PC.Pawn) ;

if (rank > 2) return ;

if(Team == 0) 
	{
	GDI_Commander[rank].CPawn = P ;
	GDI_Commander[rank].C_Objective = "NULL" ;
	GDI_Commander[rank].Pid = PC.PlayerReplicationInfo.PlayerID ;
	GDI_Commander[rank].CPRI = Rx_PRI(PC.PlayerReplicationInfo) ;
	GDI_Commander[rank].CName = PC.PlayerReplicationInfo.PlayerName ;
	GDI_Commander[rank].Controller = PC;
	GDI_Commander[rank].Init_Phase = false	;
	

	PC.ClientPlaySound(ElectedSound_GDI) ;
	
	} 
		
		
if(Team == 1) 
	{
	NOD_Commander[rank].CPawn = P ;
	NOD_Commander[rank].C_Objective = "NULL" ;
	NOD_Commander[rank].Pid = PC.PlayerReplicationInfo.PlayerID  ;
	NOD_Commander[rank].CPRI = Rx_PRI(PC.PlayerReplicationInfo) ;
	NOD_Commander[rank].CName = PC.PlayerReplicationInfo.PlayerName ;
	NOD_Commander[rank].Controller = PC;
	Nod_Commander[rank].Init_Phase = false	;
	PC.ClientPlaySound(ElectedSound_Nod) ;
	} 
		
		
}
	
function string GetCommanderName(string Team, int rank) 
{
	switch (Team) 
	{
		case "GDI": 
		return GDI_Commander[rank].CName ;
		break;
		
		case "Nod":
		return Nod_Commander[rank].CName ;
		break;
	
	default: 
	return "NULL" ;
	break;
	}
	
}
	
simulated function bool CommanderInGame(string Team, int rank)

{
	
	//Look in the game replication info to see if the commander's PRI is still around
	switch (Team)
	{
	case ("GDI"):
	//`log ("GRI found PRI: " $(Rx_Game(WorldInfo.Game).FindPlayerByID(GDI_Commander[rank].Pid)));
		if(Rx_Game(WorldInfo.Game).FindPlayerByID(GDI_Commander[rank].Pid) != GDI_Commander[rank].CPRI)
			{
			return false;
			}
		else
		return true;
		
		break;
	
	case ("Nod"):
	
		if(Rx_Game(WorldInfo.Game).FindPlayerByID(NOD_Commander[rank].Pid) != NOD_Commander[rank].CPRI)
			return false;
		else
			return true;
			break;
	default: 
	
	return true;
	break;
	}		
		
		
}
	
simulated function bool CommanderOnRightTeam(string Team, int rank) 
{
	
	//Look in the game replication info to see if the commander's PRI still has him on the right team
	switch (Team)
	{
	case ("GDI"):
		if(Rx_Game(WorldInfo.Game).FindPlayerByID(GDI_Commander[rank].Pid).Team.TeamIndex == 0)
			{
			return true;
			}
		else
		return false;
		
		break;
	
	case ("Nod"):
	
		if(Rx_Game(WorldInfo.Game).FindPlayerByID(NOD_Commander[rank].Pid).Team.TeamIndex == 1)
			return true;
		else
			return false;
			break;
	default: 
	
	return true;
	break;
	}
	
}

unreliable server function SendTargetsClear(int OType, int rank, int ITeam)
{	
	ORI.EraseTargets(OType,rank,ITeam);	
}


reliable server function EraseCommander (string Team, int rank) //Set to server function as it will simply replicate the change to all clients. Trying to have all clients perform this ends up with ineffective results.
{
	
switch (Team)
	{
	case "GDI":
	GDI_Commander[rank].CPawn = none ;
	GDI_Commander[rank].C_Objective = "" ;
	GDI_Commander[rank].Pid = -1 ;
	GDI_Commander[rank].CPRI = none ;
	GDI_Commander[rank].CName = "NULL" ;
	GDI_Commander[rank].Controller = none;
	break;

	case "Nod":
	
	Nod_Commander[rank].CPawn = none ;
	Nod_Commander[rank].CPawn = none ;
	Nod_Commander[rank].C_Objective = "" ;
	Nod_Commander[rank].Pid = -1 ;
	Nod_Commander[rank].CPRI = none ;
	Nod_Commander[rank].CName = "NULL" ;
	Nod_Commander[rank].Controller = none;
	break;
	
	default:
	break;
	}
}

simulated function HUD GetHUD(Rx_Controller C)
{
	return C.myHUD;
}

//Jacked from Rx_Controller for finding the nearest spot target. It also makes the string grammatically correct with 'the'
simulated function string GetSpottargetLocationInfo(Vector WaypointTarget) 
{
	local string LocationInfo;
	local Rx_GRI WGRI; 
	local RxIfc_SpotMarker SpotMarker;
	local Actor TempActor;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	
	WGRI = Rx_GRI(WorldInfo.GRI);
	if(WGRI == none) return "";
	
	//`log("STarted looking for nearest spot marker");
	foreach WGRI.SpottingArray(TempActor) {
		SpotMarker = RxIfc_SpotMarker(TempActor);
		DistToSpot = VSizeSq(TempActor.location - WaypointTarget);
		if(NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist) {
			NearestSpotDist = DistToSpot;	
			NearestSpotMarker = SpotMarker;
		}
	}
	
	LocationInfo = NearestSpotMarker.GetSpotName();	
	//Correct the string grammatically before returning it
	if(Left(LocationInfo, 3) != "The" && Left(LocationInfo, 3) != "the") LocationInfo="the"@LocationInfo; 
	
	return LocationInfo;
}


/**********************************************************************************
* Rewarded objective handling information
*
* Includes information to create objective classes on the server, and to force the objective update. 
*
*
*Will re-add later
***********************************************************************************/

DefaultProperties	

{

ObjectiveReplicationClass  = class'Rx_ORI'
ElectedSound_GDI = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_EstablishingBattleFieldControl_Cue'
ElectedSound_Nod = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_EstablishingBattleFieldControl_Cue'

}
