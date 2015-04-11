/*********************************************************
*
* File: Rx_Defence_RocketEmplacement_Rockets.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Defence_RocketEmplacement_Rockets extends Rx_Vehicle_Projectile_SeekingRocket;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(0.5f); //(1.25f);
}

DefaultProperties
{
	DrawScale            = 1.0f

	AmbientSound=SoundCue'RX_SoundEffects.Missiles.SC_Missile_FlyBy'
	ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Micro'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')	
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4')
	  
	bCollideWorld=True
	bNetTemporary=False
	bWaitForEffects=True
	bRotationFollowsVelocity=true
   
	Physics=PHYS_Projectile

	ExplosionLightClass=Class'Rx_Light_Tank_MuzzleFlash'
	MaxExplosionLightDistance=7000.000000
	Speed=3000
	MaxSpeed=3000
	AccelRate=800
	LifeSpan=2.5
	Damage=18
	DamageRadius=450
	MomentumTransfer=100000.000000
   
	LockWarningInterval			= 1.5
	BaseTrackingStrength		= 2.0 		// 0.7
	HomingTrackingStrength		= 2.0 		// 0.7

	MyDamageType=Class'Rx_DmgType_RocketEmpl_Swarm'

	bCheckProjectileLight=true
	ProjectileLightClass=class'UDKExplosionLight' // TODO
	bWaitForEffectsAtEndOfLifetime = true
}
