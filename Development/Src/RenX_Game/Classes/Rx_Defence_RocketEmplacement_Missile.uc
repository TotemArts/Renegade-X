/*********************************************************
*
* File: Rx_Defence_RocketEmplacement_Missile.uc
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
class Rx_Defence_RocketEmplacement_Missile extends Rx_Vehicle_Projectile_SeekingRocket;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(0.6f); //(2.5f);
}

DefaultProperties
{
    DrawScale            = 1.25f

	AmbientSound=SoundCue'RX_SoundEffects.Missiles.SC_Missile_FlyBy'

	ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_RocketLauncher'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_AirStrike_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	
    
   bCollideWorld=True
   bNetTemporary=False
   bWaitForEffects=True
   bRotationFollowsVelocity=true
   
   Physics = PHYS_Projectile

   ExplosionLightClass=Class'Rx_Light_Tank_MuzzleFlash'
   MaxExplosionLightDistance=7000.000000
   Speed=6000
   MaxSpeed=6000
   AccelRate=2000
   LifeSpan=1.5
   Damage=125
   DamageRadius=700
   MomentumTransfer=100000.000000
   
   LockWarningInterval=1.5
   BaseTrackingStrength= 12.0 //8.0
   HomingTrackingStrength=12.0 //8.0
   
   MyDamageType=Class'Rx_DmgType_RocketEmpl_Missile'

   bCheckProjectileLight=true
   ProjectileLightClass=class'UDKExplosionLight'
}
