class Rx_Attachment_MarksmanRifle_Nod extends Rx_Attachment_MarksmanRifle;


DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		Materials[0]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_WP_SniperRifle_Nod'
		Materials[2]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_DSR50_Lens_Nod'
	End Object

	WeaponClass = class'Rx_Weapon_MarksmanRifle_Nod'
	
	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_Nod'
}
