class Rx_Weapon_AutoRifle_Nod extends Rx_Weapon_AutoRifle;

DefaultProperties
{
	TeamSkin=MaterialInterface'RX_WP_AutoRifle.Materials.MI_WP_AR_Nod'
	TeamIndex = 0

	AttachmentClass = class'Rx_Attachment_AutoRifle_Nod'

	WeaponProjectiles(0)=class'Rx_Projectile_AutoRifle_Nod'
	WeaponProjectiles(1)=class'Rx_Projectile_AutoRifle_Nod'

	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash_Nod_1P'
	
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_AutoRifle.Mesh.SK_WP_AR_Back'
		Materials(0)=MaterialInterface'RX_WP_AutoRifle.Materials.MI_WP_AR_Nod'
		Scale=1.0
	End Object
	
	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_AutoRifle_Nod'
}
