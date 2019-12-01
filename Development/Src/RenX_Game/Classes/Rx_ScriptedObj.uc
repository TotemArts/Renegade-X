class Rx_ScriptedObj extends Rx_GameObjective
	ClassGroup(Scripted);

var(ScriptedObjective) Rx_ScriptedObj NextScriptedObj;

function bool DoTaskFor(Rx_Bot_Scripted_Customizeable B)
{
	return false;
}

function bool DoNextObjectiveFor(Rx_Bot_Scripted_Customizeable B)
{
		if(NextScriptedObj != None)
		{
			B.MyObjective = NextScriptedObj;
			return NextScriptedObj.DoTaskFor(B);	
		}

		return false;
}