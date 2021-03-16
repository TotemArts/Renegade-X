class S_Weapon_AutoRifle_BH extends Rx_Weapon_AutoRifle_Nod;

DefaultProperties
{
	TeamSkin=MaterialInterface'S_WP_AutoRifle.Materials.MI_WP_AR_Nod'
	TeamIndex = 0

	AttachmentClass = class'S_Attachment_AutoRifle_BH'

	WeaponProjectiles(0)=class'S_Projectile_AutoRifle_BH'
	WeaponProjectiles(1)=class'S_Projectile_AutoRifle_BH'

	MuzzleFlashPSCTemplate=ParticleSystem'S_WP_AutoRifle.Effects.MuzzleFlash_Nod_1P'

	Begin Object Name=FirstPersonMesh
		Materials[1]=Material'S_WP_AutoRifle.Materials.Counter_Ones'
		Materials[2]=Material'S_WP_AutoRifle.Materials.Counter_Tens'
		Materials[3]=Material'S_WP_AutoRifle.Materials.Counter_Hundreds'
	End Object
	
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_AutoRifle.Mesh.SK_WP_AR_Back'
		Materials(0)=MaterialInterface'S_WP_AutoRifle.Materials.MI_WP_AR_Nod'
		Scale=1.0
	End Object
	
}
