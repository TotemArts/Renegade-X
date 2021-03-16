class Rx_Pickup_Ammo extends Rx_Pickup;

auto state Pickup
{
	function bool ValidTouch(Pawn Other)
	{
		if(Rx_InventoryManager(Other.InvManager) != none)
			return !Rx_InventoryManager(Other.InvManager).IsAmmoFull();

		else return false;
	}
}

function SpawnCopyFor(Pawn Recipient)
{   
	local Rx_Weapon Weap;
	local Rx_Weapon_Reloadable RWeap;
	local int AddAmount;

	ForEach Rx_InventoryManager(Recipient.InvManager).InventoryActors(class'Rx_Weapon', Weap)
	{
		if (Rx_Weapon_Deployable(Weap) == None)
		{
			if(Rx_Weapon_Reloadable(Weap) != none)
			{
				RWeap = Rx_Weapon_Reloadable(Weap); 
				AddAmount = fmin(RWeap.AmmoCount+RWeap.ClipSize*RWeap.Ammo_Increment, RWeap.MaxAmmoCount);
				RWeap.AmmoCount = AddAmount; 
				if(WorldInfo.NetMode == NM_DedicatedServer) RWeap.ClientUpdateAmmoCount(AddAmount);
			}				
			else
				Weap.PerformRefill(); 
			
			Weap.bForceHidden = false;
		}
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