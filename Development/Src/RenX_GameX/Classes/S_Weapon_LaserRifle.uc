class S_Weapon_LaserRifle extends Rx_Weapon_LaserRifle;

DefaultProperties
{   
    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'S_WP_LaserRifle.Mesh.SK_WP_LaserRifle_1P'
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'S_WP_LaserRifle.Mesh.SK_WP_LaserRifle_Back'
    End Object

    AttachmentClass = class'S_Attachment_LaserRifle'

    MuzzleFlashPSCTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_1P'
    MuzzleFlashPSCTemplate_Heroic=ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_1P_Blue'
    MuzzleFlashLightClass=class'S_Light_BlueMuzzleFlash'

    BackWeaponAttachmentClass = class'S_BackWeaponAttachment_LaserRifle'
}