class Rx_SeqAct_ChangeObjectiveIndicator extends SequenceAction;

var(Coop) bool bShowObjective;	// Whether or not this objective is not necessary for mission completion
var(Coop) Actor VisualIndicatedActor;


defaultproperties
{
	ObjName="Change Objective Indicator"
	ObjCategory="Cooperative"

	HandlerName="OnChangeVisualIndicator"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Objective")
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Visual Indicated Actor",PropertyName=VisualIndicatedActor,MaxVars=1)
}