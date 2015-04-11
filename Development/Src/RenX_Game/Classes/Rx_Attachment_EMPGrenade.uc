class Rx_Attachment_EMPGrenade extends Rx_WeaponAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_EMPGrenade.Mesh.SK_WP_EMPGrenade_3P'
		Scale=2.0
	End Object

	WeaponClass = class'Rx_Weapon_EMPGrenade'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=none
	MuzzleFlashLightClass=none
	MuzzleFlashDuration=2.5
	
	AimProfileName = Unarmed
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
}
