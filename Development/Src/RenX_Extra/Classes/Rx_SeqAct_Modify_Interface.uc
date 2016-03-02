//Custom SeqAct in Kismet for usage with the custom buildings in Ren X. Made by Ruud033. www.renegade-x.com

class Rx_SeqAct_Modify_Interface extends SequenceAction;

var string BuildingName;
var int TeamNumber;
var Rx_Building_Interface TestActor;

event Activated()
{
local SeqVar_Object ObjVar;

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "ModifiedActor")
	{
		  TestActor = Rx_Building_Interface(ObjVar.GetObjectValue());
		  if (TestActor != None)
		  {
				TestActor.OnModifyBuilding(self); // 'self' is to pass the SeqAct to have the rest of params
		  }
	}
}

defaultproperties
{
   ObjName="Modify Building Interface"
   ObjCategory="Ren X"
   Variablelinks(2)=(ExpectedType=class'SeqVar_Int', LinkDesc="Team Number",MinVars=1,MaxVars=1,PropertyName=TeamNumber)
   Variablelinks(1)=(ExpectedType=class'SeqVar_String', LinkDesc="Building Name",MinVars=1,MaxVars=1,PropertyName=BuildingName)
   Variablelinks(0)=(ExpectedType=class'SeqVar_Object', LinkDesc="ModifiedActor",PropertyName=ModifiedActor)
   bCallHandler=false
}