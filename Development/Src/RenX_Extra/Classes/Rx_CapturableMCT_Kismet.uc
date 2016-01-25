class Rx_CapturableMCT_Kismet extends Rx_CapturableMCT
   placeable;

defaultproperties
{
   
   BuildingInternalsClass  = Rx_CapturableMCT_Internals_Kismet

        //This is the essential so the actor can be assigned to this event. You can now right click and 'Create event with selected actor'
   SupportedEvents.Add(class'Rx_SeqEvent_TechCapture')
}