class Rx_Pickup extends UTItemPickupFactory
	abstract;

var int PickupsRemaining;
var float DespawnTime;

auto state Pickup
{
   function float DetourWeight(Pawn Other,float PathWeight)
   {
      return 1.0; // TODO: add some weight logic for bots
   }

   function bool ValidTouch( Pawn Other )
   {
      return (Rx_Pawn(Other) != None && Other.Controller != None && Rx_Bot_Scripted(Other.Controller) == None && Other.Health > 0);
   }
}

function SetRespawn()
{
	if (PickupsRemaining < 0)
		Super.SetRespawn();
	else if (PickupsRemaining == 0) // This should never happen
		Destroy();
	else if (PickupsRemaining == 1) // No uses remaining
	{
		--PickupsRemaining;
		GotoState('Disabled');
		Destroy();
	}
	else if (PickupsRemaining > 1) // Additional uses remaining
	{
		--PickupsRemaining;
		StartSleeping();
	}
}

function Expire()
{
	GotoState('Disabled');
	Destroy();
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
	DespawnTime=20
	PickupsRemaining = -1
	bNoDelete = false;
	TickGroup=TG_PreAsyncWork;
}
