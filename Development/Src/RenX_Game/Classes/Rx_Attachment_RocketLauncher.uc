class Rx_Attachment_RocketLauncher extends Rx_WeaponAttachment;

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	super.ThirdPersonFireEffects(HitLocation);
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
		//Translation=(Y=-3,Z=0)
		//Rotation=(Roll=-1000,Pitch=6000,Yaw=-1000)
		Scale=1.0
	End Object

	WeaponClass = class'Rx_Weapon_RocketLauncher'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_ChainGun.Effects.P_MuzzleFlash_3P'
	MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
	MuzzleFlashDuration=2.5
	
	AimProfileName = RocketLauncher
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_RocketLauncher'
}
