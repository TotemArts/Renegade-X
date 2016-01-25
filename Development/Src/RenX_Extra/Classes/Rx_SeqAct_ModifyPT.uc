//Custom SeqAct in Kismet for usage with the custom Purchase Terminal in Ren X. Made by Ruud033 and Handepsilon. www.renegade-x.com

class Rx_SeqAct_ModifyPT extends SequenceAction;

var bool bAccessible;
var string Tooltip;
var string PTName;
var int TeamNumber;

event Activated()
{
local SeqVar_Object ObjVar;
local Rx_BuildingAttachment_PT_Customizable TestActor;

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "ModifiedActor")
	{
		  TestActor = Rx_BuildingAttachment_PT_Customizable(ObjVar.GetObjectValue());
		  if (TestActor != None)
		  {
				TestActor.OnModifyPT(self); // 'self' is to pass the SeqAct to have the rest of params
		  }
	}
}

defaultproperties
{
   ObjName="Modify Purchase Terminal"
   ObjCategory="Ren X"
   Variablelinks(4)=(ExpectedType=class'SeqVar_Int', LinkDesc="Team Number",MinVars=1,MaxVars=1,PropertyName=TeamNumber)
   Variablelinks(3)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Accessible",MinVars=1,MaxVars=1,PropertyName=bAccessible)
   Variablelinks(2)=(ExpectedType=class'SeqVar_String', LinkDesc="PT Name",MinVars=1,MaxVars=1,PropertyName=PTName)
   Variablelinks(1)=(ExpectedType=class'SeqVar_String', LinkDesc="Tooltip",MinVars=1,MaxVars=1,PropertyName=Tooltip)
   Variablelinks(0)=(ExpectedType=class'SeqVar_Object', LinkDesc="ModifiedActor",PropertyName=ModifiedActor)
   bCallHandler=false
}