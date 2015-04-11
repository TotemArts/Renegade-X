class Rx_Attachment_ATMine extends Rx_WeaponAttachment;


DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_ATMine.Mesh.SK_WP_ATMine_3P'
	End Object

	WeaponClass = class'Rx_Weapon_ATMine'
	MuzzleFlashSocket=MuzzleFlashSocket

	/**
	Begin Object Name=WeaponSocketMesh0
		SkeletalMesh=SkeletalMesh'RX_WP_RemoteC4.Mesh.WP_RemoteC4'
	End Object
	*/
	
	AimProfileName = Unarmed
	bDontAim = true
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
}
