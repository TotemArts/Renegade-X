/*********************************************************
*
* File: TS_Vehicle_HoverMRLS_Projectile.uc
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
class TS_Vehicle_HoverMRLS_Projectile extends Rx_Vehicle_Projectile_SeekingRocket;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.0f);
}

DefaultProperties
{
	DrawScale            = 1.0f

    AmbientSound=SoundCue'RX_SoundEffects.Missiles.SC_Missile_FlyBy'

	ProjFlightTemplate=ParticleSystem'TS_VH_HoverMRLS.Effects.P_Missiles'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')

	
   
	bCollideWorld=True
	bNetTemporary=False
	bWaitForEffects=True
	bRotationFollowsVelocity=true
   
	Physics = PHYS_Projectile

	ExplosionLightClass=Class'Rx_Light_Tank_MuzzleFlash'
	MaxExplosionLightDistance=7000.000000
	Speed=3500
	MaxSpeed=3500
	AccelRate=2400.0
	LifeSpan=4.0
	Damage=80
	DamageRadius=350
	MomentumTransfer=100000.000000
   
	LockWarningInterval			= 1.5
	BaseTrackingStrength		= 4.0	// 0.7
	HomingTrackingStrength		= 4.0 		// 0.7

	MyDamageType=Class'TS_Vehicle_HoverMRLS_DmgType'

	bCheckProjectileLight=true
	ProjectileLightClass=class'RenX_Game.Rx_Light_Rocket'
}
