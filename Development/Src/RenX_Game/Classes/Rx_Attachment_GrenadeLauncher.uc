class Rx_Attachment_GrenadeLauncher extends Rx_WeaponAttachment;

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	super.ThirdPersonFireEffects(HitLocation);
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_GrenadeLauncher.Mesh.SK_GrenadeLauncher_3P'
		Scale=1.0
	End Object

	WeaponClass = class'Rx_Weapon_GrenadeLauncher'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_GrenadeLauncher.Effects.MuzzleFlash'
	MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
	MuzzleFlashDuration=2.5
	
	AimProfileName = AutoRifle
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_AutoRifle'
}
