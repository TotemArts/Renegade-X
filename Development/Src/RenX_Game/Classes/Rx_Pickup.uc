class Rx_Pickup extends UTItemPickupFactory
	abstract;

auto state Pickup
{
   function float DetourWeight(Pawn Other,float PathWeight)
   {
      return 1.0; // TODO: add some weight logic for bots
   }

   function bool ValidTouch( Pawn Other )
   {
      return Other.IsA('Rx_Pawn') && Other.Health > 0;
   }
}

DefaultProperties
{
	RespawnSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Respawn_Cue'
	YawRotationRate=10000
	bRotatingPickup=true
	bFloatingPickup=true
	bRandomStart=true
	BobSpeed=4.0f
	BobOffset=5.0f
	RespawnTime=10
}
