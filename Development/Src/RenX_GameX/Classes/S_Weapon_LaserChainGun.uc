class S_Weapon_LaserChainGun extends Rx_Weapon_LaserChainGun;

DefaultProperties
{
	Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'S_WP_LaserChaingun.Materials.SK_LaserChainGun_1P'
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'S_WP_LaserChaingun.Materials.SK_WP_LaserChaingun_Back'
    End Object

    MuzzleFlashPSCTemplate=ParticleSystem'S_WP_LaserChaingun.Effects.P_LaserChainGun_MuzzleFlash_1P'
	MuzzleFlashPSCTemplate_Heroic=ParticleSystem'S_WP_LaserChaingun.Effects.P_LaserChainGun_MuzzleFlash_1P_Blue'
	MuzzleFlashLightClass=class'S_Light_BlueMuzzleFlash'

    AttachmentClass = class'S_Attachment_LaserChainGun'
    BackWeaponAttachmentClass = class'S_BackWeaponAttachment_LaserChainGun'
}