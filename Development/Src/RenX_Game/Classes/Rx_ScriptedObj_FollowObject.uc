class Rx_ScriptedObj_FollowObject extends Rx_ScriptedObj
	placeable;

var(ScriptedObjective) Actor ObjectToFollow;

function bool DoTaskFor(Rx_Bot_Scripted_Customizeable B)
{		
	local actor BestPath;

	if(ObjectToFollow == None)
		return false;

	if(B.RouteGoal == ObjectToFollow && B.MoveTarget != None && !B.Pawn.ReachedDestination(B.MoveTarget))
	{
		B.GoToState('Roaming');
		return true;
	}
	else if(B.RouteGoal != ObjectToFollow)
		B.RouteGoal = ObjectToFollow;

	BestPath = B.FindPathToward(ObjectToFollow,true);

	if(BestPath == None)
	{
		BestPath = ObjectToFollow;		
	}

	B.MoveTarget = BestPath;


	B.GoToState('Roaming');
	return true;

}