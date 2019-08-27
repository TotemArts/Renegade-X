class Rx_SeqAct_ScriptedBotForceSpawn extends SequenceAction;

defaultproperties
{
	ObjName="Force Spawner"
	ObjCategory="Ren X Scripted Bots"
	
	InputLinks(0)=(LinkDesc="Spawn")
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="SpawnerObject")

	HandlerName = "OnForceSpawn"
	bEnabled=true
}