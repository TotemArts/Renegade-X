class Rx_Attachment_VoltAutoRifle_GDI extends Rx_Attachment_VoltAutoRifle;

DefaultProperties
{
    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Volt_Impact_Small_Blue',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Impact')
	DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Volt_Impact_Small_Blue',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Impact')

    WeaponClass = class'Rx_Weapon_VoltAutoRifle_GDI'
    
    BeamTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Lightning_Blue'
	AltBeamTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Lightning_Blue'

    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltRifle_MuzzleFlash_3P_Blue'
	
	//Heroic Stats
	BeamTemplate_Heroic	= ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Lightning_Heroic'
	MuzzleFlashPSCTemplate_Heroic= ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltRifle_MuzzleFlash_3P_Blue'
	MuzzleFlashLightClass_Heroic=class'RenX_Game.Rx_Light_VoltRifle_MuzzleFlash'
	DefaultImpactEffect_Heroic=(ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Volt_Impact_Small_Blue_Heroic',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Impact')

}
