class Rx_Pickup_Health extends Rx_Pickup
	abstract;

var int HealthGain;

auto state Pickup
{
	function bool ValidTouch( Pawn Other )
	{
		local Rx_Pawn RenPawn;
		RenPawn = Rx_Pawn(Other);

		if (RenPawn != none)
		{
			return RenPawn.Health < RenPawn.HealthMax && RenPawn.Health > 0;
		}
		else return false;
	}
}

function SpawnCopyFor(Pawn Recipient)
{
	local Rx_Pawn RenPawn;
	RenPawn = Rx_Pawn(Recipient);

	if (RenPawn != none)
	{
		RenPawn.GiveHealth(HealthGain,RenPawn.HealthMax);
		RenPawn.DamageRate = 0; 
		
	}

	super.SpawnCopyFor(Recipient);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=HealthMesh
		StaticMesh=StaticMesh'Rx_Pickups.Health.SM_Health_Small'
		Scale=1.0f
		CollideActors = false
		BlockActors = false
		BlockZeroExtent = false
		BlockNonZeroExtent = false
		BlockRigidBody = false
		LightEnvironment = PickupLightEnvironment
	End Object
	
	PickupMesh=HealthMesh
	Components.Add(HealthMesh)

	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Pickup_Health'
}
