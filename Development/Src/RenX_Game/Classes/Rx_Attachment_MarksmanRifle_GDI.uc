class Rx_Attachment_MarksmanRifle_GDI extends Rx_Attachment_MarksmanRifle;


DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		Materials[2]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_Lense_Translucent_GDI'
	End Object

	WeaponClass = class'Rx_Weapon_MarksmanRifle_GDI'
	
	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI'
	BeamTemplate_Heroic=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI_Large_Heroic'
}
