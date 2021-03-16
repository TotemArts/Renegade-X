class Rx_Spline_CollidableActor extends SplineLoftActor;

var array<Rx_Spline_ColliderMesh> Colliders;
var vector loc,rot;
var (SplineCollision) Vector collisionScale;
var (SplineCollision) int CollisionMeshNumber; // How many collision mesh would be present. The more number, the 
var (SplineCollision) PhysicalMaterial MeshPhysicalMaterial;

event PostBeginPlay()
{
	local float splineLength;
	local int i, splineGaps;
	local Rotator MeshRotation;
	local float NextActorRoll;
	
	if(self.Connections.Length <= 0)
		return;

	splineLength = self.Connections[0].SplineComponent.GetSplineLength();
	CollisionMeshNumber = Max(CollisionMeshNumber,1); //to avoid the 0 number
	splineGaps = Round(splineLength) / CollisionMeshNumber;
	
	if(Rx_Spline_CollidableActor(self.Connections[0].ConnectTo) != None)
		NextActorRoll = Rx_Spline_CollidableActor(self.Connections[0].ConnectTo).Roll;

	else
		NextActorRoll = Roll;

	for(i=0; i<CollisionMeshNumber; i++) {
		loc = Connections[0].SplineComponent.GetLocationAtDistanceAlongSpline(i*splineGaps);
		rot = Connections[0].SplineComponent.GetTangentAtDistanceAlongSpline(i*splineGaps);
		MeshRotation = Rotator(Rot);
		MeshRotation.Roll += Lerp(Roll,NextActorRoll,float(i) / float(CollisionMeshNumber)) * DegToUnrRot;
		`log(Self@": Creating Mesh with Roll :"@MeshRotation.Roll@"from"@Self@"to"@self.Connections[0].ConnectTo);

		spawnColliderInstance(loc,MeshRotation,collisionScale);
	}
}

function spawnColliderInstance(Vector argLocation, Rotator argRotation, Vector argScale)
{
	local Rx_Spline_ColliderMesh spawnedCollider;
	local staticMeshComponent spawnedColliderMeshComponent;
	
	spawnedCollider = Spawn(class'Rx_Spline_ColliderMesh', self, , argLocation, argRotation,,true);
	spawnedCollider.setDrawScale3D(argScale);
	
	spawnedColliderMeshComponent = new () class'StaticMeshComponent';
	if(spawnedColliderMeshComponent != None)
	{
		spawnedColliderMeshComponent.SetPhysMaterialOverride(MeshPhysicalMaterial);
		spawnedCollider.AttachComponent(spawnedColliderMeshComponent);
	}
}

defaultproperties
{
	collisionScale=(X=0.5 ,Y=0.9 ,Z=0.09)
	CollisionMeshNumber=10

	WorldXDir=(X=0.0,Y=0.0,Z=1.0)

	// let collider mesh handle collisions...

	bCollideActors=false
	bBlockActors=false
	bWorldGeometry=true
}