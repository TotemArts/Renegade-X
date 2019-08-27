class Rx_SeqAct_ModifyObjective extends SequenceAction;

var(Coop) bool bOptional;	// Whether or not this objective is not necessary for mission completion
var(Coop) bool bFinalGoal;
var(Coop) bool bAnnounceFinish;
var(Coop) bool bAnnounceCompletingPlayer;
var(Coop) string CompletionMessage;
var(Coop) bool bFailCompletion;
var(Coop) int BonusVP;
Var(Coop) int TeamBonusVP;

defaultproperties
{
	ObjName="Modify Objective"
	ObjCategory="Cooperative"

	HandlerName="OnModifyObjective"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Objective")
}