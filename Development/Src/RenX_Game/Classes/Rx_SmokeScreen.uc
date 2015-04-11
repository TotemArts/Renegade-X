class Rx_SmokeScreen extends Rx_ParticleField;

var float BeginTargetBlockTime;
var repnotify bool bTargetBlock;

replication
{
	if (bNetDirty)
		bTargetBlock;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bTargetBlock' && bTargetBlock)
	{
		EnableTargetBlock();
	}
	else
		super.ReplicatedEvent(VarName);
}

event PostBeginPlay()
{
	++Rx_Game(WorldInfo.Game).SmokeScreenCount;
	SetTimer(BeginTargetBlockTime, false, 'EnableTargetBlock');
	super.PostBeginPlay();
}

simulated event Tick( float DeltaTime )
{
	if (!bClientInitialised && bTargetBlock)
		EnableTargetBlock();

	super.Tick(DeltaTime);
}

simulated function EnableTargetBlock()
{
	if (WorldInfo.NetMode != NM_Client)
		bTargetBlock=true;

	CollisionComponent.SetActorCollision(true, false);
}

event Destroyed()
{
	if (WorldInfo.NetMode != NM_Client)
		--Rx_Game(WorldInfo.Game).SmokeScreenCount;
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+480.0f
		CollisionHeight=+512.0f
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		CollideActors=false
	End Object

	ParticlesTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeScreen'

	// Gameplay variable settings
	BeginTargetBlockTime=1.0
	StopParticlesTime=2.0

	LifeSpan=11.0   // Time for SmokeScreen to exist. Target block length = Lifespan - BeginTargetBlockTime
}
