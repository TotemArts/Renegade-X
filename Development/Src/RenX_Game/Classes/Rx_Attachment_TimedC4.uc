class Rx_Attachment_TimedC4 extends Rx_WeaponAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_TimedC4.Mesh.SK_WP_Timed_3P'	
	End Object

	WeaponClass = class'Rx_Weapon_TimedC4'
	MuzzleFlashSocket=MuzzleFlashSocket
	
	AimProfileName = Unarmed
	bDontAim = true
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
}
