class Rx_Weapon_EMPGrenade_Rechargeable extends Rx_Weapon_RechargeableGrenade;

// EMP Grenades are non-refillable, players must purchase more. EDIT: Rechargeable Grenades are also non-refillable. 
simulated function PerformRefill();


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
	
	ReloadTime(0) = 60.0 //These should be pretty long 
	ReloadTime(1) = 60.0 //These should be pretty long
	
	
	
	InventoryMovieGroup=36

	WeaponIconTexture=Texture2D'RX_WP_EMPGrenade.UI.T_WeaponIcon_EMPGrenade'

	ClipSize = 1
	InitalNumClips = 5
	MaxClips = 5
}
