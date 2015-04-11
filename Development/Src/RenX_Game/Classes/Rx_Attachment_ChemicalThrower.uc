class Rx_Attachment_ChemicalThrower extends Rx_WeaponAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_ChemicalThrower.Mesh.SK_ChemicalThrower_3P'
		Scale=1.0
	End Object

	WeaponClass = class'Rx_Weapon_ChemicalThrower'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=none	// ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_ChemicalThrower_MuzzleFlash'
//	MuzzleFlashLightClass=None
//	MuzzleFlashDuration=0.1
	
	AimProfileName = Shotgun
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Shotgun'
}
