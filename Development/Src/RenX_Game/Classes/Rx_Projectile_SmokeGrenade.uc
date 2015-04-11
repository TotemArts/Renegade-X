class Rx_Projectile_SmokeGrenade extends Rx_Projectile_Grenade;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (WorldInfo.NetMode != NM_Client)
		Spawn(class'Rx_SmokeScreen',self,,HitLocation,,,);
	super.Explode(HitLocation, HitNormal);
}

// No Damage
simulated function bool HurtRadius
(
	float				DamageAmount,
	float				InDamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	optional Actor		IgnoredActor,
	optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
	optional bool       bDoFullDamage
);

DefaultProperties
{

	ProjFlightTemplate=ParticleSystem'RX_WP_Grenade.Effects.P_Grenade_Smoke'
	
	// TODO
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_SmokeGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade_Smoke')

	
	BounceDamping=0.3
	BounceDampingZ=0.4
	ArmTime=2.5
	LifeSpan=4.0
	bLogExplosion=true
	MyDamageType=class'DamageType'
	bExplodeOnPawnImpact=false
	bWaitForEffects=true
	ExplosionLightClass=none
}
