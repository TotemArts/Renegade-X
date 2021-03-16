class S_Attachment_MarksmanRifle_BH extends Rx_Attachment_MarksmanRifle;


DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		Materials[0]=MaterialInstanceConstant'RX_WP_SniperRifle.Materials.MI_WP_SniperRifle_Nod'
		Materials[2]=MaterialInstanceConstant'S_WP_SniperRifle.Materials.MI_DSR50_Lens_Nod'
	End Object

	WeaponClass = class'S_Weapon_MarksmanRifle_BH'
	
	BeamTemplate=ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Nod'
	BeamTemplate_Heroic=ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Nod_Large_Heroic'
}
