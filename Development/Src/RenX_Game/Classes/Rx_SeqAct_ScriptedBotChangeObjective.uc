class Rx_SeqAct_ScriptedBotChangeObjective extends SequenceAction;

defaultproperties
{
	ObjName="Change Objective"
	ObjCategory="Ren X Scripted Bots"
	
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawner Object")
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="New Objective",bWriteable=false)

	HandlerName = "OnChangeObjective"
	bEnabled=true
}