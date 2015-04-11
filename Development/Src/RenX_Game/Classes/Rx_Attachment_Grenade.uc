class Rx_Attachment_Grenade extends Rx_WeaponAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_Grenade_3P'
		Scale=2.0
	End Object

	WeaponClass = class'Rx_Weapon_Grenade'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=none
	MuzzleFlashLightClass=none
	MuzzleFlashDuration=2.5
	
	AimProfileName = Unarmed
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
}
