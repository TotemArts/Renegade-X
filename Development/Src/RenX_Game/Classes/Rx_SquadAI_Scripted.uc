class Rx_SquadAI_Scripted extends Rx_SquadAI_Waypoints;

var string SquadID;
var Rx_ScriptedBotSpawner Spawner;

function bool AssignSquadResponsibility(UTBot B)
{
	if ( CheckSquadObjectives(B) )
		return true;

	return false;
}

function bool CheckSquadObjectives(UTBot B)
{
	local Rx_ScriptedObj_PatrolPoint PatrolObj;
	local Actor N, BestN;
	local int i, BestI;
	local float Dist,BestDist;
	local Rx_Bot_Scripted ScriptB;

	ScriptB = Rx_Bot_Scripted(B);

	PatrolObj = Rx_ScriptedObj_PatrolPoint(SquadObjective);

	if(PatrolObj != None)
	{
		if(ScriptB.PatrolTask == PatrolObj)
		{
			return ScriptB.StartPatrol();
		}
		
		ScriptB.PatrolTask = PatrolObj;

		if(PatrolObj.bUseSpecificStart)
		{
			ScriptB.RouteGoal = PatrolObj.PatrolPoints[PatrolObj.StartNum];
			ScriptB.PatrolNumber = PatrolObj.StartNum; 
			return ScriptB.StartPatrol();
		}

		for(i = 0; i < PatrolObj.PatrolPoints.length; i++)
		{
			N = PatrolObj.PatrolPoints[i];
			Dist = VSize(B.Pawn.Location - PatrolObj.PatrolPoints[i].Location);

			if(BestN == None || Dist < BestDist)
			{
				BestN = N;
				BestDist = Dist;
				BestI = i;
			}

		}

		ScriptB.RouteGoal = BestN;
		ScriptB.PatrolNumber = BestI;

		return ScriptB.StartPatrol();
	}

	return false;
}

function RemoveBot (UTBot B)
{
	local UTBot Prev;

	if ( B.Squad != self )
		return;

	B.Squad = None;
	Size --;

	if ( SquadMembers == B )
	{
		SquadMembers = B.NextSquadMember;
		if ( SquadMembers == None && Spawner != None && Spawner.BotRemaining <= 0)
		{
			destroy();
			return;
		}
	}
	else
	{
		for ( Prev=SquadMembers; Prev!=None; Prev=Prev.NextSquadMember )
			if ( Prev.NextSquadMember == B )
			{
				Prev.NextSquadMember = B.NextSquadMember;
				break;
			}
	}
	if ( SquadLeader == B )
		PickNewLeader();

	if(Spawner != None)
	{
		Spawner.BotRemaining -= 1;
		Spawner.NotifyPawnDeath();
	}
}