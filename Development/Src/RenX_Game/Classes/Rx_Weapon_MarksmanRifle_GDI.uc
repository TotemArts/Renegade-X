class Rx_Weapon_MarksmanRifle_GDI extends Rx_Weapon_MarksmanRifle;

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		Materials[2]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_DSR50_Lens'
	End Object

	AttachmentClass=class'Rx_Attachment_MarksmanRifle_GDI'
	
	WeaponProjectiles(0)=class'Rx_Projectile_MarksmanRifle_GDI'

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_MarksmanRifle_GDI'
}
