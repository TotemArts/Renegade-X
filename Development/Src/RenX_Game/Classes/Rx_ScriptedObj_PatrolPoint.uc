class Rx_ScriptedObj_PatrolPoint extends Rx_ScriptedObj
	placeable;

var(ScriptedPatrol) Rx_ScriptedObj_PatrolPoint NextPatrolPoint;
var(ScriptedPatrol) bool bWalkingPatrol;
var(ScriptedPatrol) int StartNum;
var(ScriptedPatrol) bool bGroupPatrol;

function bool DoTaskFor(Rx_Bot_Scripted B)
{
	if(!B.Pawn.ReachedDestination(Self) || (bGroupPatrol && !AreAllBotsInHere(B)))
		return B.FindPatrolPathTowards(Self);

	else if(NextPatrolPoint != None)
	{
		`log(B.GetHumanReadableName()@" : Change objective to"@NextPatrolPoint);


		B.MyObjective = NextPatrolPoint;
		return NextPatrolPoint.DoTaskFor(B);
	}

	return false;
}

function bool AreAllBotsInHere(Rx_Bot_Scripted B)
{
	local Rx_Bot_Scripted Bots;

	if(B.MySpawner == None)
		return true;

	else
	{
		foreach B.MySpawner.MyBots(Bots)
		{
			if(Bots == B)
				continue;

			if(Bots.RouteGoal == Self && Bots.Pawn.ReachedDestination(Self))
				return false;
		}
	}

	return true;
}