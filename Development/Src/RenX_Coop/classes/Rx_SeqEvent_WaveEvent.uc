class Rx_SeqEvent_WaveEvent extends SequenceEvent;

defaultproperties
{
   ObjName="Wave Event"
   ObjCategory="Survival"

// There OutputLinks correspond to the TriggerEventClass function parameter. So if there should be more output links, it can be added at will

   OutputLinks[0]=(LinkDesc="Started")
   OutputLinks[1]=(LinkDesc="Finished")
   VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Wave Number",bWriteable=true)
   bPlayerOnly=false
   MaxTriggerCount=0
}