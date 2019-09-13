class Rx_ScriptedObj_PatrolPoint extends Rx_ScriptedObj
	placeable;

var(ScriptedObjective) bool bWalkingPatrol;
var(ScriptedObjective) bool bGroupPatrol;

function bool DoTaskFor(Rx_Bot_Scripted B)
{
	if((!bGroupPatrol && !B.Pawn.ReachedDestination(Self)) || (bGroupPatrol && !AreAllBotsInHere(B)))
		return FindPatrolPathTowards(Self, B);

	else if(NextScriptedObj != None)
	{
		`log(B.GetHumanReadableName()@" : Change objective to"@NextScriptedObj);

		return DoNextObjectiveFor(B);

	}

	return false;
}

function bool FindPatrolPathTowards(Actor PatrolPoint, Rx_Bot_Scripted B)
{
	local Actor BestPath;

	if(B.RouteGoal == PatrolPoint && !B.Pawn.ReachedDestination(B.MoveTarget))
	{
		B.GoToState('Patrolling');
		return true;
	}
	else
	{
		B.RouteGoal = PatrolPoint;
	}

	BestPath = B.FindPathToward(PatrolPoint);

	if(BestPath == None)
		BestPath = PatrolPoint;

	B.MoveTarget = BestPath;
	B.GoToState('Patrolling');

	return true;



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
			if(Bots.RouteGoal == Self && Bots.Pawn.ReachedDestination(Self))
				return false;
		}
	}

	return true;
}