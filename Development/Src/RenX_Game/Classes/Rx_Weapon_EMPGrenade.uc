class Rx_Weapon_EMPGrenade extends Rx_Weapon_Grenade;

// EMP Grenades are non-refillable, players must purchase more.
simulated function PerformRefill();

simulated state Active
{
	simulated function WeaponEmpty()
	{
		if(AmmoCount <= 0) {
			Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);
			if (Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.Find(self.Class) > -1) {
				Rx_Controller(Instigator.Controller).PreviousExplosiveTransactionRecords.RemoveItem(self.Class);
			}
			Rx_Controller(Instigator.Controller).CurrentExplosiveWeapon = none;
		} 
		super.WeaponEmpty();
	}
}

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_EMPGrenade.Mesh.SK_WP_EMPGrenade_1P'
		AnimSets(0)=AnimSet'RX_WP_Grenade.Anims.AS_Grenade_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_EMPGrenade.Mesh.SK_WP_EMPGrenade_3P'
		Scale=2.5
	End Object
	
	AttachmentClass = class'Rx_Attachment_EMPGrenade'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_EMPGreande'

    WeaponProjectiles(0)=class'Rx_Projectile_EMPGrenade'
    WeaponProjectiles(1)=class'Rx_Projectile_EMPGrenade'
	
	
	InventoryMovieGroup=36

	ClipSize = 1
	InitalNumClips = 1
	MaxClips = 1
}
