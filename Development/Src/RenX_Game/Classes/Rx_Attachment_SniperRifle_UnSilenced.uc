class Rx_Attachment_SniperRifle_UnSilenced extends Rx_Attachment_SniperRifle;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_DSR50_UnSilenced_3P'
		Scale=1.0
	End Object

	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_Heavy'

	WeaponClass = class'Rx_Weapon_SniperRifle'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TacticalRifle.Effects.P_MuzzleFlash_3P'
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'
	MuzzleFlashDuration=0.1
//	ImpactLightClass=none
	
	ShellEjectPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.P_ShellCasing'
	ShellEjectDuration = 1.0
	ShellEjectSocket = ShellEjectSocket
	
	AimProfileName = AutoRifle
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_AutoRifle'
}
