class Rx_SmokeScreen_Large extends Rx_SmokeScreen;

simulated function InitSmokeScreen(byte Rank, Rx_Pawn InstigatorPawn) //No VEt
{
TeamNum = InstigatorPawn.GetTeamNum();
SetTimer(LifeSpan-StopParticlesTime, false, 'StopParticles');	 
++Rx_Game(WorldInfo.Game).SmokeScreenCount;
SetTimer(BeginTargetBlockTime, false, 'EnableTargetBlock');
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=1440.0f //+480.0f
		CollisionHeight=1536.0f //+512.0f
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		CollideActors=false
	End Object

	ParticlesTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeScreen_Large'

	LifeSpan=18.0   // Time for SmokeScreen to exist. Target block length = Lifespan - BeginTargetBlockTime
	
}
