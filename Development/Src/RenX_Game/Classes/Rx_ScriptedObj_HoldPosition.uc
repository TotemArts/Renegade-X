class Rx_ScriptedObj_HoldPosition extends Rx_ScriptedObj
	placeable;

var(ScriptedObjective) bool bRootPawn;
var(ScriptedObjective) float HoldDuration;		// Time for which this bot should hold here before proceeding to next objective. Set to 0 or less for infinity 
var bool bSwapObjective;

function bool DoTaskFor(Rx_Bot_Scripted B)
{
	if(!bSwapObjective)
		B.GoToState('WaitForTactics');
	else
	{
		if(!IsTimerActive('ResetTimer'))
			SetTimer(1.f,false,'ResetTimer');
		return DoNextObjectiveFor(B);
	}

	if(HoldDuration > 0 && NextScriptedObj != None && !IsTimerActive('NextObjectiveTimer'))
		SetTimer(HoldDuration,false,'NextObjectiveTimer');


	return true;
}

function NextObjectiveTimer ()
{
	bSwapObjective = true;
}

function ResetTimer ()
{
	bSwapObjective = false;
}