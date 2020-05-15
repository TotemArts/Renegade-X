class Rx_Targetable_StaticMeshActor extends StaticMeshActor
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
	begin object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'RX_Deco_Rock.Mesh.SM_BasaltMain01'
	end object
}	