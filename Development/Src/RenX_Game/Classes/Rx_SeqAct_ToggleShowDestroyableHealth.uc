
class Rx_SeqAct_ToggleShowDestroyableHealth extends SequenceAction;


defaultproperties
{
	ObjName="Toggle Show Destroyable Health"
	ObjCategory="Toggle"
	HandlerName="ToggleShowDestroyableHealth"

	InputLinks(0)=(LinkDesc="Turn On")
	InputLinks(1)=(LinkDesc="Turn Off")
	InputLinks(2)=(LinkDesc="Toggle")

	VariableLinks(0)=(bModifiesLinkedObject=true)
}
