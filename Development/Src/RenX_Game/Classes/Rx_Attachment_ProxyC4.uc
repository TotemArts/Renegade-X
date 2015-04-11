class Rx_Attachment_ProxyC4 extends Rx_WeaponAttachment;


DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'rx_wp_proxyc4.Mesh.SK_WP_Proxy_3P'
	End Object

	WeaponClass = class'Rx_Weapon_ProxyC4'
	MuzzleFlashSocket=MuzzleFlashSocket
	
	AimProfileName = Unarmed
	bDontAim = true
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
}
