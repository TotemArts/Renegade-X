class Rx_BuildingAttachment_Glass extends Rx_BuildingAttachment;
    
var SkeletalMeshComponent   SkeletalGlassMesh;
var StaticMeshComponent     StaticGlassMesh;

function PostBeginPlay()
{
	SetCollisionSize(120.0f, 140.0f);
	SetCollision(true, true);
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	LifeSpan = 0.001f;
	self.Destroy(); 
}

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) {
	LifeSpan = 0.001f;  
	self.Destroy(); 
}

defaultproperties
{
	//RemoteRole      = ROLE_SimulatedProxy
	
	Begin Object Class=SkeletalMeshComponent Name=SkelGlassMesh
		CollideActors   = True
		BlockActors     = True
	End Object
	SkeletalGlassMesh = SkelGlassMesh
	
	Begin Object Class=StaticMeshComponent Name=GlassMesh
		CollideActors       = True
		BlockActors         = True
		bCastDynamicShadow  = True
	End Object
	StaticGlassMesh    = GlassMesh
	CollisionComponent = GlassMesh

	bProjTarget                = True
	bDestroyedByInterpActor    = True
	bCollideActors             = True
	bBlockActors               = True
}
