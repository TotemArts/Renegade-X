class Rx_SeqEvent_ScriptedSpawnerEvent extends SequenceEvent;

defaultproperties
{
   ObjName="Scripted Spawner Event"
   ObjCategory="Scripted Bots"

// There OutputLinks correspond to the TriggerEventClass function parameter. So if there should be more output links, it can be added at will

   OutputLinks[0]=(LinkDesc="Spawned")
   OutputLinks[1]=(LinkDesc="Finished Spawning")
   OutputLinks[2]=(LinkDesc="Bot Died")
   OutputLinks[3]=(LinkDesc="All Bots Killed")

   bPlayerOnly=false
   MaxTriggerCount=0


}