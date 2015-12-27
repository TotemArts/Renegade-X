class Rx_Attachment_SMG_Silenced_GDI extends Rx_Attachment_SMG_Silenced;

DefaultProperties
{
	WeaponClass = class'Rx_Weapon_SMG_Silenced_GDI'
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash'
	
	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI'
}
