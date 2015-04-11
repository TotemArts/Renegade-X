class Rx_Attachment_Chaingun_GDI extends Rx_Attachment_Chaingun;

DefaultProperties
{
    WeaponClass = class'Rx_Weapon_Chaingun_GDI'
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_ChainGun.Effects.P_MuzzleFlash_3P'
	
	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI'
}
