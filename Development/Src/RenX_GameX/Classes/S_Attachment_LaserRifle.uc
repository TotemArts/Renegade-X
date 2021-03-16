class S_Attachment_LaserRifle extends Rx_Attachment_LaserRifle;

DefaultProperties
{
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'S_WP_LaserRifle.Mesh.SK_WP_LaserRifle_3P'    
    End Object

    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_Laser_Impact',Sound=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Impact')
	
	DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_Laser_Impact',Sound=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Impact')

    BeamTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_Beam'

    WeaponClass = class'S_Weapon_LaserRifle'
    MuzzleFlashPSCTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_3P'
    MuzzleFlashLightClass=class'S_Light_BlueMuzzleFlash'    
	
	BeamTemplate_Heroic	= ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_Beam_Blue'
	MuzzleFlashPSCTemplate_Heroic= ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_3P_Blue'
	MuzzleFlashLightClass_Heroic=class'Rx_Light_Blue_MuzzleFlash'
	DefaultImpactEffect_Heroic=(ParticleTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_Laser_Impact_Blue',Sound=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Impact')
}
