class Rx_Weapon_MarksmanRifle_Nod extends Rx_Weapon_MarksmanRifle;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_MarksmanRifle_1P_Nod'
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		Materials[0]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_WP_SniperRifle_Nod'
		Materials[2]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_Lense_Translucent'
	End Object

	AttachmentClass=class'Rx_Attachment_MarksmanRifle_Nod'
	
	WeaponProjectiles(0)=class'Rx_Projectile_MarksmanRifle_Nod'

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_MarksmanRifle_Nod'
}
