class Rx_ParticleField extends Actor
	abstract;

var ParticleSystemComponent Particles;
var ParticleSystem ParticlesTemplate;
var repnotify bool bStopParticles;
var float StopParticlesTime;
var bool bClientInitialised;

replication
{
	if (bNetDirty)
		bStopParticles;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bStopParticles' && bStopParticles)
	{
		StopParticles();
	}
	else
		super.ReplicatedEvent(VarName);
}

event PostBeginPlay()
{
	SetTimer(LifeSpan-StopParticlesTime, false, 'StopParticles');

	if (WorldInfo.NetMode == NM_DedicatedServer)
		bClientInitialised = true;  // So Dedicated doesn't try spawn Particle Effect.

	super.PostBeginPlay();
}

simulated event Tick( float DeltaTime )
{
	if (!bClientInitialised)    // true implies WorldInfo.NetMode != NM_DedicatedServer
	{
		if (!bStopParticles)
		{
			Particles = WorldInfo.MyEmitterPool.SpawnEmitter(ParticlesTemplate, Location, Rotation);
		}
		bClientInitialised=true;
	}
}

simulated function StopParticles()
{
	if (WorldInfo.NetMode != NM_Client)
		bStopParticles = true;
		
	if (WorldInfo.NetMode != NM_DedicatedServer)
		Particles.DeactivateSystem();
}

DefaultProperties
{
	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=256.0
		CollisionHeight=256.0
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		CollideActors=true
		bDrawBoundingBox=true
		bDrawNonColliding=true
		HiddenGame=false
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bOnlyDirtyReplication=true
	NetUpdateFrequency=8
	RemoteRole=ROLE_SimulatedProxy
	bHidden=false
	NetPriority=+1.0
	bCollideActors=true
	bCollideWorld=false
	bBlockActors=false

	//bOrientOnSlope=true
	//bShouldBaseAtStartup=true
	bIgnoreEncroachers=true
	bIgnoreRigidBodyPawns=true
	bUpdateSimulatedPosition=true
}
