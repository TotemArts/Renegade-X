class Rx_SeqEvent_DefenseEvent extends SequenceEvent;

defaultproperties
{
   ObjName="Defense Event"
   ObjCategory="Renegade X Buildings"

// There OutputLinks correspond to the TriggerEventClass function parameter. So if there should be more output links, it can be added at will

   OutputLinks[0]=(LinkDesc="Power Down")
   OutputLinks[1]=(LinkDesc="Power Up")

   bPlayerOnly=false
   MaxTriggerCount=0
}