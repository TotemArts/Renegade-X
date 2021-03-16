class S_Weapon_Railgun extends Rx_Weapon_Railgun;		//Rx_Weapon_Reloadable ;


DefaultProperties
{


    AttachmentClass = class'S_Attachment_Railgun'

    MuzzleFlashPSCTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_1P'
    MuzzleFlashPSCTemplate_Heroic=ParticleSystem'S_WP_Railgun.Effects.P_Railgun_MuzzleFlash_Heroic'
   	MuzzleFlashLightClass=class'S_Light_BlueMuzzleFlash'
 
}
