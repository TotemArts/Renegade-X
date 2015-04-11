class Rx_Attachment_VoltAutoRifle_Nod extends Rx_Attachment_VoltAutoRifle;

DefaultProperties
{
    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Volt_Impact_Small',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Impact')
	DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Volt_Impact_Small',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Impact')

    WeaponClass = class'Rx_Weapon_VoltAutoRifle_Nod'
    
    BeamTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Lightning_Thick'
	AltBeamTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Lightning'

    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltRifle_MuzzleFlash_3P'

}
