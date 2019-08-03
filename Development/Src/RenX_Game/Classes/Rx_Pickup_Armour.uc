class Rx_Pickup_Armour extends Rx_Pickup
	abstract;

var int ArmourGain;

auto state Pickup
{
	function bool ValidTouch( Pawn Other )
	{
		local Rx_Pawn RenPawn;
		RenPawn = Rx_Pawn(Other);

		if (RenPawn != none)
		{
			return RenPawn.Armor < RenPawn.ArmorMax && RenPawn.Health > 0;
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
		RenPawn.GiveArmor(ArmourGain);
		RenPawn.DamageRate = 0; 
	}

	super.SpawnCopyFor(Recipient);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=ArmourMesh
		StaticMesh=StaticMesh'Rx_Pickups.Armour.SM_Armour_Small'
		Scale=1.0f
		CollideActors = false
		BlockActors = false
		BlockZeroExtent = false
		BlockNonZeroExtent = false
		BlockRigidBody = false
		LightEnvironment = PickupLightEnvironment
	End Object
	
	PickupMesh=ArmourMesh
	Components.Add(ArmourMesh)

	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Pickup_Armour'
}
