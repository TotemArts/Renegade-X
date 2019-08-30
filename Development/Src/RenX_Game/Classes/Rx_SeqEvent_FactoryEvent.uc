class Rx_SeqEvent_FactoryEvent extends SequenceEvent;

defaultproperties
{
   ObjName="Factory Event"
   ObjCategory="Renegade X Buildings"

// There OutputLinks correspond to the TriggerEventClass function parameter. So if there should be more output links, it can be added at will

   OutputLinks[0]=(LinkDesc="Vehicle Purchased")
   OutputLinks[1]=(LinkDesc="Vehicle Created")

   bPlayerOnly=false
   MaxTriggerCount=0
}