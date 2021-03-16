class S_Attachment_Railgun extends Rx_Attachment_Railgun;


DefaultProperties
{

    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'S_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    DefaultImpactEffect_Heroic=(ParticleTemplate=ParticleSystem'S_FX_Munitions.Beams.P_Railgun_Impact_Heroic',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')

    BeamTemplate=ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Railgun'
    BeamTemplate_Heroic=ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Railgun_Heroic'

    WeaponClass = class'S_Weapon_Railgun'
    MuzzleFlashSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'S_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_3P'
    MuzzleFlashPSCTemplate_Heroic=ParticleSystem'S_WP_Railgun.Effects.P_Railgun_MuzzleFlash_Heroic'
}
