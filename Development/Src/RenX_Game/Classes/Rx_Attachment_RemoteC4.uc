class Rx_Attachment_RemoteC4 extends Rx_WeaponAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_RemoteC4.Mesh.WP_RemoteC4_3P'
	End Object

	WeaponClass = class'Rx_Weapon_RemoteC4'
	MuzzleFlashSocket=MuzzleFlashSocket
	
	AimProfileName = Unarmed
	bDontAim = true
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
}
