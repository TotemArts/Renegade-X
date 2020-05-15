class Rx_Targetable_SkeletalMeshActor extends SkeletalMeshActor
	placeable
	implements (RxIfc_TargetedSubstitution);

var(TargetingBox) Actor TargetedActor;

simulated function Actor GetActualActorTarget()
{
	return TargetedActor;
}

simulated function bool ShouldSubstitute()
{
	return true;
}

DefaultProperties
{
	begin object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_DEF_SamSite.Mesh.SK_SamSite'
	end object
}	