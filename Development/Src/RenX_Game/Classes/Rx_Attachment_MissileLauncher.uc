class Rx_Attachment_MissileLauncher extends Rx_WeaponAttachment;

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	super.ThirdPersonFireEffects(HitLocation);
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_MissileLauncher.Meshes.SK_WP_MissileLauncher_3P'
		//Translation=(Y=-3,Z=0)
		//Rotation=(Roll=-1000,Pitch=6000,Yaw=-1000)
		Scale=1.0
	End Object

	WeaponClass = class'Rx_Weapon_MissileLauncher'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_MissileLauncher.Effects.P_MuzzleFlash'
	MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
	MuzzleFlashDuration=2.5
	
	AimProfileName = Autorifle
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Autorifle'
}
