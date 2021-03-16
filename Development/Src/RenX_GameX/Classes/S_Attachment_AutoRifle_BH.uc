class S_Attachment_AutoRifle_BH extends Rx_Attachment_AutoRifle_Nod;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		Materials(0)=MaterialInterface'S_WP_AutoRifle.Materials.MI_WP_AR_Nod'
		Materials(1)=MaterialInstanceConstant'S_WP_AutoRifle.Materials.MI_WP_Counter_Nod'
	End Object
	
	BeamTemplate=ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Nod'
	BeamTemplate_Heroic=ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Nod_Large_Heroic'

	MuzzleFlashPSCTemplate=ParticleSystem'S_WP_AutoRifle.Effects.MuzzleFlash_Nod'
}