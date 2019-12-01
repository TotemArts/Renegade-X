class Rx_ScriptedBotPRI extends PlayerReplicationInfo;

var byte PawnRadarVis;
var byte RadarVisibility;
var bool bSpotted;
var float TargetDecayTime ;
var float ClientTargetUpdatedTime; 
var int Scripted_ID;

var repnotify bool bUpdateTargetTimeFlag; 
var repnotify byte Unit_TargetStatus[2]; // Array: [0 GDI, 1 is Nod] | Value 1 for attack   
var repnotify byte Unit_TargetNumber[2]; //Number they show up as to the enemy for ID purposes 

replication
{
	if(bNetDirty)
		PawnRadarVis,RadarVisibility, bSpotted;

	if(bNetDirty  && !bNetOwner)
		Unit_TargetStatus,Unit_TargetNumber,bUpdateTargetTimeFlag;

}


simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'bUpdateTargetTimeFlag' )
    {
		ClientTargetUpdatedTime = WorldInfo.TimeSeconds; 
    }
	else
    {
		Super.ReplicatedEvent(VarName);
	}
}

simulated function PreBeginPlay()
{
	super.PreBeginPlay(); 
	if(ROLE == ROLE_Authority)
	{ 
		Scripted_ID = Rx_Game(WorldInfo.Game).GetScriptedID();
	}
}

simulated static function String LogNameOf(PlayerReplicationInfo PRI)
{
	return class'Rx_Game'.static.GetTeamName(PRI.GetTeamNum())$",ai,"$PRI.PlayerName;
}

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	return false;
}

simulated function bool IsSpotted()
{
	return bSpotted;
}

simulated function byte GetRadarVisibility()
{
	if(bSpotted)
		return 2;

	return RadarVisibility;
}

function SetSpotted(float SpottedTime)
{
	if(ROLE < ROLE_Authority) 
		ServerSetSpotted(SpottedTime); 
	else
	{
		bSpotted = true;
		SetTimer(SpottedTime,false,'ResetSpotted');	
		//Controller(Owner).Pawn.bAlwaysRelevant = true;  
	}
	
}



reliable server function ServerSetSpotted(float SpottedTime)
{
	if(GetTimerRate('ResetSpotted') - GetTimerCount('ResetSpotted') >= SpottedTime) 
		return; //Already spotted for longer by something else	

	bSpotted = true; 
	//Controller(Owner).Pawn.bAlwaysRelevant = false;
	SetTimer(SpottedTime,false,'ResetSpotted');
}

function ResetSpotted()
{
	bSpotted = false;
}


reliable server function SetAsTarget(byte TType) //Type of target to be set as. Simplified from commander mod
{
	local byte TeamByte; 
	
	local int FreeNum; 
	
	TeamByte = GetTeamNum();

	FreeNum = Rx_Game(WorldInfo.Game).GetFreeTarget(TeamByte, TType, self);	

	if(FreeNum == -1) //Reset as we're already a target
	{
		SetTimer(TargetDecayTime, false, 'ResetEnemyTargetStatus'); 
		if(ROLE == ROLE_Authority) 
		{
			ClientTargetUpdatedTime = WorldInfo.TimeSeconds;
			bUpdateTargetTimeFlag = !bUpdateTargetTimeFlag; 
		}
		return; 
	}
	
	//Attack
	if(TType == 1) 
	{
		Unit_TargetStatus[TeamByte] = 1; 
		Unit_TargetNumber[TeamByte] = FreeNum; 
		SetTimer(TargetDecayTime, false, 'ResetEnemyTargetStatus'); 
		if(ROLE == ROLE_Authority) 
		{
			if(Controller(Owner).Pawn != none && Rx_Game(WorldInfo.Game) != none) 
			{
				if(Rx_Vehicle(Controller(Owner).Pawn) != none) 
					Rx_Vehicle(Controller(Owner).Pawn).SetTemporaryRelevance(TargetDecayTime);
				else if(Rx_Vehicle(Controller(Owner).Pawn) != none ) 
					Rx_Pawn(Controller(Owner).Pawn).SetTemporaryRelevance(TargetDecayTime);
			}
			ClientTargetUpdatedTime = WorldInfo.TimeSeconds;
			bUpdateTargetTimeFlag = !bUpdateTargetTimeFlag; 
		}
	}
} 

function ResetEnemyTargetStatus()
{
	local byte TeamByte, Special; 
	
	TeamByte = GetTeamNum();
	
	if(Unit_TargetStatus[TeamByte] != 0) 
	{
		Unit_TargetStatus[TeamByte] = 0; 
		Unit_TargetNumber[TeamByte] = 255; 
		
		if(Rx_Defence(Controller(Owner).Pawn) != none) 
			Special = 30; 
		else if(Rx_Vehicle_Air(Controller(Owner).Pawn) != none) 
			Special = 40;  
		else if(Rx_Vehicle(Controller(Owner).Pawn) != none)
			Special = 10;  
		
		Rx_Game(WorldInfo.Game).RemoveTarget(GetTeamNum(), self, Special);
	}
}

function SetTargetEliminated(byte TTYPE) //Blanket function for target doing anything but decaying: e.g: Going back into stealth or what not.
{
	local byte TeamByte; 
	
	TeamByte = GetTeamNum();
	
	if(Unit_TargetStatus[TeamByte] == 0) return; 
	else
	{
		Unit_TargetStatus[TeamByte] = 0; 
		Unit_TargetNumber[TeamByte] = 255; 
		Rx_Game(WorldInfo.Game).RemoveTarget(GetTeamNum(), self, TTYPE);
	}
	
}

DefaultProperties
{
	RadarVisibility = 1;
	TargetDecayTime = 20.0 //12.0
}