class Rx_Attachment_TiberiumAutoRifle extends Rx_WeaponAttachment_Varying;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumAutoRifle.Mesh.SK_TiberiumAutolRifle_3P'
		Scale=1.0
	End Object

	WeaponClass = class'Rx_Weapon_TiberiumAutoRifle'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TiberiumFlechetteRifle.Effects.P_MuzzleFlash_3P'
	MuzzleFlashLightClass=class'Rx_Light_TiberiumFlechetteRifle_MuzzleFlash'
	MuzzleFlashDuration=3.0
//	ImpactLightClass=none

	BeamTemplate_Heroic	= ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_InstantHit_Tracer_TibRed'
	MuzzleFlashPSCTemplate_Heroic= ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_MuzzleFlash_3P_Red'
	MuzzleFlashLightClass_Heroic=class'Rx_Light_TiberiumFlechetteRifle_MuzzleFlashRed'
	
	ShellEjectPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.P_ShellCasing'
	ShellEjectDuration = 1.0
	ShellEjectSocket = ShellEjectSocket
	
	AimProfileName = TacticalRifle
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_AutoRifle'
}
