class Rx_SmokeScreen extends Rx_ParticleField;

var float BeginTargetBlockTime	;
var repnotify bool bTargetBlock	;	
var int TeamNum;

var float Vet_TimeModifier[4]; //+X seconds

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
	

	//Super call with init of lifespan. Lifespan done in InitSmokeScreen so VRank is properly applied 
	if (WorldInfo.NetMode == NM_DedicatedServer)
		bClientInitialised = true;  // So Dedicated doesn't try spawn Particle Effect.

	//Skip the usual setting of Lifespan and what not
	super(Actor).PostBeginPlay();
}



simulated function InitSmokeScreen(byte Rank, Rx_Pawn InstigatorPawn)
{
	LifeSpan+=Vet_TimeModifier[Rank]; 
	TeamNum = InstigatorPawn.GetTeamNum(); 
	SetTimer(LifeSpan-StopParticlesTime, false, 'StopParticles');	
	++Rx_Game(WorldInfo.Game).SmokeScreenCount;
	SetTimer(BeginTargetBlockTime, false, 'EnableTargetBlock');
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

simulated function StopParticles()
{
	super.StopParticles();
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
	
	
	
	//+X seconds
	Vet_TimeModifier(0) = 0 
	Vet_TimeModifier(1) = 3.0 
	Vet_TimeModifier(2) = 6.0 
	Vet_TimeModifier(3) = 9.0 
	
}
