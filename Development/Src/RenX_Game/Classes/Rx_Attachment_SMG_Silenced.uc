class Rx_Attachment_SMG_Silenced extends Rx_Attachment_SMG;

DefaultProperties
{
Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_Pistol.Mesh.SK_MachinePistol_3P_Silenced'	
	End Object

	WeaponClass = class'Rx_Weapon_SMG_Silenced'
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash'
	
	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer'
}
