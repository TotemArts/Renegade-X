class Rx_SeqAct_CompleteObjective extends SequenceAction;

defaultproperties
{
	ObjName="Complete Objective"
	ObjCategory="Cooperative"


	HandlerName="OnCompleteObjective"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Objective")
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Instigator")
}