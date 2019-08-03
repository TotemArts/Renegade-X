//Custom SeqAct in Kismet for usage with the custom Purchase Terminal in Ren X. Made by Ruud033 and Handepsilon. www.renegade-x.com

class Rx_SeqAct_ToggleDefenses extends SequenceAction;

var Rx_Building ObOrAgt;

event Activated()
{
local SeqVar_Object ObjVar;

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "ModifiedActor")
	{
		  ObOrAgt = Rx_Building(ObjVar.GetObjectValue());
		  if (Rx_Building_Defense(ObOrAgt) != None)
		  {			
				if(Rx_Building_Team_Internals(ObOrAgt.BuildingInternals).bNoPower)
					Rx_Building_Team_Internals(ObOrAgt.BuildingInternals).PowerRestore();
				else
					Rx_Building_Team_Internals(ObOrAgt.BuildingInternals).PowerLost(true);
		  }
	}
}

defaultproperties
{
   ObjName="Activate/Deactivate Ob/AGT"
   ObjCategory="Ren X"
   Variablelinks(0)=(ExpectedType=class'SeqVar_Object', LinkDesc="ModifiedActor",PropertyName=ModifiedActor)
   bCallHandler=false
}