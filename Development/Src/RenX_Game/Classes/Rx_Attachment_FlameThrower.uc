class Rx_Attachment_FlameThrower extends Rx_WeaponAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_FlameThrower.Mesh.SK_WP_FlameThrower_3p'
		Scale=1.0
	End Object

	WeaponClass = class'Rx_Weapon_FlameThrower'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=none	// ParticleSystem'RX_WP_FlameThrower.Effects.FX_FireThrower_MuzzleFlash'
//	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'
//	MuzzleFlashDuration=0.1
	
	AimProfileName = Shotgun
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Shotgun'
}
