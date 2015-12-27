class Rx_Attachment_Carbine_Silencer extends Rx_Attachment_Carbine;


DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_Carbine.Mesh.SK_Carbine_3P'
		Scale=1.0
	End Object

	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer'

	WeaponClass = class'Rx_Weapon_Carbine_Silencer'
}
