class Rx_ScriptedObj_AttackTarget extends Rx_ScriptedObj
	placeable;

var(ScriptedObjective) Actor Target;

function bool DoTaskFor(Rx_Bot_Scripted_Customizeable B)
{
	if(Target != None)
	{
		B.DoRangedAttackOn(Target);
		return true;
	}
	
	return DoNextObjectiveFor(B);
}