class Rx_Pickup_Ammo extends Rx_Pickup;

auto state Pickup
{
	function bool ValidTouch( Pawn Other )
	{
		if(Rx_InventoryManager(Other.InvManager) != none)
		{
			return !Rx_InventoryManager(Other.InvManager).IsAmmoFull();
		}
		else return false;
	}
}

function SpawnCopyFor(Pawn Recipient)
{   
	if(Rx_InventoryManager(Recipient.InvManager) != none)
    {
		Rx_InventoryManager(Recipient.InvManager).PerformWeaponRefill();
    }

	super.SpawnCopyFor(Recipient);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=HealthMesh
		StaticMesh=StaticMesh'Rx_Pickups.Ammo.SM_Ammo_Medium'
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

	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Pickup_Ammo'
}