class Rx_Weapon_SniperRifle_GDI extends Rx_Weapon_SniperRifle;

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		Materials[3]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_DSR50_Lens'
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		Materials[3]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_DSR50_Lens'
	End Object

	AttachmentClass=class'Rx_Attachment_SniperRifle_GDI'

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_SniperRifle_GDI'
}