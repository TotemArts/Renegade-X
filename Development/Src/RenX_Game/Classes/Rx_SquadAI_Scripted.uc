class Rx_SquadAI_Scripted extends Rx_SquadAI_Waypoints;

var string SquadID;

function bool AssignSquadResponsibility(UTBot B)
{
	if ( CheckSquadObjectives(B) )
		return true;

	return false;
}

function ChooseTactics()
{
	
}

function bool CheckSquadObjectives(UTBot B)
{
	local Rx_ScriptedObj ScriptedObj;
	local Rx_Bot_Scripted ScriptB;

	ScriptB = Rx_Bot_Scripted(B);

	ScriptedObj = Rx_ScriptedObj(SquadObjective);
	if(ScriptedObj != None)
	{
		return ScriptedObj.DoTaskFor(ScriptB);
	}

	return false;
}

function float VehicleDesireability(UTVehicle V, UTBot B)
{
	// will always return 0 so that the bots will not try to enter other vehicles

	return 0;
}

function PickNewLeader()
{
	local UTBot B;

	// pick a leader that isn't out of the game or in a vehicle turret
	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if (B.Pawn == None || !B.Pawn.bStationary || B.Pawn.GetVehicleBase() == None)
			break;

	if ( B == None )
		return;

	if ( SquadLeader != B )
	{
		SquadLeader = B;
		if ( SquadLeader == None )
			LeaderPRI = None;
		else
			LeaderPRI = UTPlayerReplicationInfo(SquadLeader.PlayerReplicationInfo);
		bForceNetUpdate = TRUE;
	}
}

function bool FriendlyToward(Pawn Other)
{
	return SquadLeader.GetTeamNum() == Other.GetTeamNum();
}

