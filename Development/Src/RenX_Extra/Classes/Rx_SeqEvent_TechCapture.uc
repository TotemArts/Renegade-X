class Rx_SeqEvent_TechCapture extends SequenceEvent;

defaultproperties
{
   ObjName="Tech Building Event"
   ObjCategory="Renegade X Buildings"

// There OutputLinks correspond to the TriggerEventClass function parameter. So if there should be more output links, it can be added at will

   OutputLinks[0]=(LinkDesc="Captured")
   OutputLinks[1]=(LinkDesc="Neutralized")
   bPlayerOnly=false
   MaxTriggerCount=0
}