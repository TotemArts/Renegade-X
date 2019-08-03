
class Rx_TeamInfo extends UTTeamInfo;

var array<Vehicle>  Vehicles;
var int             vehicleCount;
var int             VehicleLimit;
var int             mineCount;
var int             mineLimit;
var int 			PlayerSize;
var color           TeamColors[3];
var string          TeamNames[3];
var byte            ReplicatedSize;    
var float           LastAttackTime; // to warn every 30sec for attacks on team
var repnotify int   LastAirstrikeTime;
var protected float RenScore;
var protected int   ReplicatedRenScore;
var protected int   Kills;  // total kills for the team
var protected int   Deaths; // total deaths for the team
var protected float	Command_Points, Maximum_CP; //The maximum CP you can have at any given time. Rises with the number of dead buildings you have
var bool			bHarvesterStopped; 

replication
{
	
	if( bNetDirty && (Role==ROLE_Authority) )
		ReplicatedSize, vehicleCount, mineCount, ReplicatedRenScore, Kills, Deaths, LastAirstrikeTime, VehicleLimit, mineLimit, Command_Points, Maximum_CP;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'LastAirstrikeTime' )
    {
		LastAirstrikeTime = WorldInfo.TimeSeconds;
    }
    else
    {
		Super.ReplicatedEvent(VarName);
	}
}


/** vehicle creation */
function addVehicle(Vehicle V)
{
   Vehicles.AddItem(V);
}

simulated function int GetVehicleCount()
{
	return VehicleCount;
}

simulated function string GetTeamName()
{
   return default.TeamNames[TeamIndex];
}

function Initialize(int NewTeamIndex)
{
   TeamIndex = NewTeamIndex;
}

simulated function byte GetTeamNum()
{
   return TeamIndex;
}

simulated function string GetHumanReadableName()
{
    return default.TeamNames[TeamIndex];
}
simulated function color GetHUDColor()
{
    return default.TeamColors[TeamIndex];
}
function color GetTextColor()
{
    return default.TeamColors[TeamIndex];
}
simulated function color GetTeamColor()
{
   return default.TeamColors[TeamIndex];
}

function bool AddToTeam( Controller Other )
{
   local bool bRet;
   
   bRet = super.AddToTeam(Other);
   if (Rx_Bot_Scripted(Other) == None && bRet && Other.bIsPlayer && Rx_PRI(Other.PlayerReplicationInfo) != None) {
      	ReplicatedSize++; // here we go.. replicated team size for everyone
    	Rx_PRI(Other.PlayerReplicationInfo).SetCredits( Rx_Game(WorldInfo.Game).InitialCredits );   
	    if(Rx_Game(WorldInfo.Game).TeamCredits[TeamIndex].PlayerRI.Find(Rx_PRI(Other.PlayerReplicationInfo)) < 0)
	    	Rx_Game(WorldInfo.Game).TeamCredits[TeamIndex].PlayerRI.AddItem(Rx_PRI(Other.PlayerReplicationInfo));
   }
   Size = ReplicatedSize;

   if(PlayerController(Other) != None)
  	 PlayerSize++;
   return bRet;
}

function RemoveFromTeam(Controller Other)
{
	if (Rx_Bot_Scripted(Other) == None && Other.bIsPlayer)
	   ReplicatedSize--;
   
	Rx_Game(WorldInfo.Game).TeamCredits[TeamIndex].PlayerRI.RemoveItem(Rx_PRI(Other.PlayerReplicationInfo));
	super.RemoveFromTeam(Other);
	Size = ReplicatedSize;

   if(PlayerController(Other) != None)
  	 PlayerSize--;
}

function DecreaseVehicleCount() 
{
	vehicleCount--;
}

function IncreaseVehicleCount() 
{
	vehicleCount++;
}

simulated function bool IsAtVehicleLimit()
{
	if (vehicleCount == VehicleLimit)
	{
		return true;
	}
	return false;
}

simulated function int GetDisplayRenScore()
{
	return ReplicatedRenScore;
}

simulated function int GetRenScore()
{
	return ReplicatedRenScore;
}

function AddRenScore( float inScore )
{
	RenScore += inScore;
	ReplicatedRenScore = RenScore;

	if (Rx_Game(WorldInfo.Game).UpcomingScoreEvent != None && Rx_Game(WorldInfo.Game).UpcomingScoreEvent.ScoreRequired < RenScore)
	{
		Rx_Game(WorldInfo.Game).UpcomingScoreEvent.ScoreReached(self);
		Rx_Game(WorldInfo.Game).UpcomingScoreEvent = Rx_Game(WorldInfo.Game).UpcomingScoreEvent.Next;
	}
}

simulated function AddKill( optional int numKills = 1 )
{
	Kills += numKills;
}

simulated function int GetKills()
{
	return Kills;
}

simulated function AddDeath( optional int numDeaths = 1)
{
	Deaths += numDeaths;
}

simulated function int GetDeaths()
{
	return Deaths;
}

simulated function float GetKDRatio()
{
	if (Deaths == 0)
	{
		return Kills;
	} 
	else
	{
		return float(int((float(Kills)/float(Deaths)) * 100) / 100);
	}	
}

function bool BotNameTaken(string BotName)
{
	local int i;
	local UTPlayerReplicationInfo PRI;
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	for (i=0;i<GRI.PRIArray.Length;i++)
	{
		PRI = UTPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]);
		if (PRI != None && PRI.PlayerName == BotName)
		{
			return true;
		}
	}
	return false;
}

/*Command Points*/
simulated function float GetCommandPoints()
{
	return Command_Points; 
}

simulated function AddCommandPoints(float CP, optional string AddMessage = "")
{
	local Rx_PRI CommandersPRI; 
	Command_Points=fmin(Command_Points+CP, Maximum_CP);  
	
	if(ROLE == ROLE_Authority && AddMessage != "") 
	{
		CommandersPRI = Rx_Game(WorldInfo.Game).Commander_PRI[GetTeamNum()];
		if(CommandersPRI != none) Rx_Controller(CommandersPRI.Owner).ClientSendFeelGoodMessage(AddMessage,"CP") ;
	}
}

function InitCommandPoints(float MaxNum, float Num)
{
	Maximum_CP = MaxNum; 
	Command_Points = Num;
}

simulated function float GetMaxCommandPoints()
{
	return Maximum_CP; 
} 

function ToggleHarvStopped()
{
	bHarvesterStopped = bHarvesterStopped ? false : true; 
}

function bool bGetHarvStopped(){
	return bHarvesterStopped; 
}

defaultproperties
{
	TeamNames(0)="GDI"
	TeamNames(1)="Nod"
	TeamNames(2)="Civilians"
	TeamIndex=2
	TeamColors(0)=(B=0,G=198,R=255,A=255)
	TeamColors(1)=(B=0,G=0,R=255,A=255)
	TeamColors(2)=(B=230,G=230,R=230,A=255)
	Name="Renegade_TeamInfo"
	bAlwaysRelevant=true
	LastAirstrikeTime=0
	
}
