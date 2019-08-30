class Rx_SeqEvent_BuildingEvent extends SequenceEvent;

defaultproperties
{
   ObjName="Team Building Event"
   ObjCategory="Renegade X Buildings"

// There OutputLinks correspond to the TriggerEventClass function parameter. So if there should be more output links, it can be added at will

   OutputLinks[0]=(LinkDesc="Destroyed")
   OutputLinks[1]=(LinkDesc="Being Repaired")
   OutputLinks[2]=(LinkDesc="Under Attack")
   OutputLinks[3]=(LinkDesc="Armor Broken")
   OutputLinks[4]=(LinkDesc="Fully Repaired")
   bPlayerOnly=false
   MaxTriggerCount=0
}