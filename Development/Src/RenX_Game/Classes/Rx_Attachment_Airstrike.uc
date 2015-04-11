class Rx_Attachment_Airstrike extends Rx_WeaponAttachment
	abstract;

var private ParticleSystemComponent Beam;

simulated function SpawnBeam(vector aslocation)
{
	local vector start;

	// do not spawn beam for local player, because we did that already
	if (Instigator.IsLocallyControlled()) return;

	// get starting point of beam
	if (!Mesh.GetSocketWorldLocationAndRotation('MuzzleFlashSocket', start, , 0))
		start = Instigator.Location;

    Beam = WorldInfo.MyEmitterPool.SpawnEmitter(class<Rx_Weapon_Airstrike>(WeaponClass).default.BeamEffect, start);
    Beam.SetVectorParameter('BeamEnd', aslocation);
	Beam.SetDepthPriorityGroup(SDPG_World);
}

simulated function DestroyBeam()
{
	if (Beam != none)
		Beam.ResetToDefaults();
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_Binoculars.Mesh.SK_Binoculars_3P'
	End Object
	
	bDontAim = true
	AimProfileName = Unarmed
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
}
