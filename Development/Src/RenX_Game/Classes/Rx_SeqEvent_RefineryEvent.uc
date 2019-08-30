class Rx_SeqEvent_RefineryEvent extends SequenceEvent;

defaultproperties
{
   ObjName="Refinery Event"
   ObjCategory="Renegade X Buildings"

// There OutputLinks correspond to the TriggerEventClass function parameter. So if there should be more output links, it can be added at will

   OutputLinks[0]=(LinkDesc="Harvester Docked")
   OutputLinks[1]=(LinkDesc="Harvester Unloaded")

   bPlayerOnly=false
   MaxTriggerCount=0
}