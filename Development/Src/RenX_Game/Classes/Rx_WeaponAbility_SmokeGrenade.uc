class Rx_WeaponAbility_SmokeGrenade extends Rx_WeaponAbility_Grenade;

DefaultProperties
{
	FlashMovieIconNumber	=3
	
	RechargeRate 	= 20.0 //Seconds between re-adding charges

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_SmokeGrenade_1P'
		AnimSets(0)=AnimSet'RX_WP_Grenade.Anims.AS_Grenade_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_SmokeGrenade_3P'
		Scale=2.5
	End Object
	
	AttachmentClass = class'Rx_Attachment_SmokeGrenade'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_SmokeGrenade'

    WeaponProjectiles(0)=class'Rx_Projectile_SmokeGrenade'
    WeaponProjectiles(1)=class'Rx_Projectile_SmokeGrenade'
	
	
	InventoryMovieGroup=38  // TODO

	WeaponIconTexture=Texture2D'RX_WP_Grenade.UI.T_WeaponIcon_SmokeGrenade'
}
