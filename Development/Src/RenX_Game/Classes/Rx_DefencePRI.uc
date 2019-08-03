class Rx_DefencePRI extends PlayerReplicationInfo; 
//implements(RxIfc_RadarMarker);

var bool bSpotted, bFocused; 

/**************************
*Commander oriented stuff**
***************************/
var repnotify byte Unit_TargetStatus[2]; // Array: [0 GDI, 1 is Nod] | Value 1 for attack   
var repnotify byte Unit_TargetNumber[2]; //Number they show up as to the enemy for ID purposes 
var float TargetDecayTime ;
var float ClientTargetUpdatedTime; 
var int	  Defence_ID; //Sick of Defences not having specific player IDs.. Makes working with them utterly stupid sometimes. 
var repnotify bool bUpdateTargetTimeFlag; 

replication
{
	//if(bNetDirty)
	if(bNetInitial)
		Defence_ID; 

	if(bNetDirty && !bNetOwner)
	Unit_TargetStatus, Unit_TargetNumber, bSpotted, bFocused, bUpdateTargetTimeFlag ;
	
}

simulated function PreBeginPlay()
{
	super.PreBeginPlay(); 
	if(ROLE == ROLE_Authority) Defence_ID = Rx_Game(WorldInfo.Game).GetDefenceID();
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

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	return false;
}

simulated static function String LogNameOf(PlayerReplicationInfo PRI)
{
	return class'Rx_Game'.static.GetTeamName(PRI.GetTeamNum())$",ai,"$PRI.PlayerName;
}

function SetSpotted(float SpottedTime)
{
	if(GetTimerRate('ResetSpotted') - GetTimerCount('ResetSpotted') >= SpottedTime) return; //Already spotted for longer by something else
	
	if(ROLE < ROLE_Authority) ServerSetSpotted(SpottedTime); 
	else
	{
	bSpotted = true;
	SetTimer(SpottedTime,false,'ResetSpotted');	
	}
	
}

reliable server function ServerSetSpotted(float SpottedTime)
{
	bSpotted = true; 
	SetTimer(SpottedTime,false,'ResetSpotted');
}

function ResetSpotted()
{
	bSpotted = false;
}

simulated function bool isSpotted()
{
	return bSpotted;
}

function SetFocused()
{
	if(ROLE < ROLE_Authority) ServerSetFocused(); 
	else
	{
	bFocused = true;
	SetTimer(10.0,false,'ResetFocused');	
	}
	
}


reliable server function ServerSetFocused()
{
	bFocused = true; 
	SetTimer(10.0,false,'ResetFocused');
}

function ResetFocused()
{
	bFocused=false;
}

simulated function bool IsFocused()
{
	return bFocused;
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
			ClientTargetUpdatedTime = WorldInfo.TimeSeconds;
			bUpdateTargetTimeFlag = !bUpdateTargetTimeFlag; 
		}
	}
} 

function ResetEnemyTargetStatus()
{
	local byte TeamByte; 
	
	TeamByte = Owner.GetTeamNum();

	
	if(Unit_TargetStatus[TeamByte] != 0) 
	{
		Unit_TargetStatus[TeamByte] = 0; 
		Unit_TargetNumber[TeamByte] = 255; 
		if( Rx_Vehicle_Harvester(Controller(Owner).Pawn) == none  ) Rx_Game(WorldInfo.Game).RemoveTarget(GetTeamNum(), self, 30);
		else
		Rx_Game(WorldInfo.Game).RemoveTarget(GetTeamNum(), self, 10);
	}
}

function SetTargetEliminated(byte TTYPE)
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
	//Decay time of attack targets in seconds 
	TargetDecayTime = 20.0 //12.0
}
