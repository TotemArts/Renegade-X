class Rx_Projectile_Railgun extends Rx_Projectile;

DefaultProperties
{

	ProjFlightTemplate=ParticleSystem'RX_WP_Railgun.Effects.P_Bullet_Railgun'
	
	AmbientSound=SoundCue'RX_SoundEffects.Bullet_WhizBy.SC_Bullet_WhizBy'

	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_Railgun_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')

	
    DrawScale= 1.0f

    bCollideComplex=true
//    bCollideWorld=true
    Speed=10000
    MaxSpeed=10000
    AccelRate=0
    LifeSpan=0.5
    Damage=200
    DamageRadius=100
	HeadShotDamageMult=5.0
    MomentumTransfer=120000
    bWaitForEffects=true
	bWaitForEffectsAtEndOfLifetime=true
    bAttachExplosionToVehicles=false
       bCheckProjectileLight=false
    bSuppressExplosionFX=true // Do not spawn hit effect in mid air
    
    ProjectileLightClass=class'Rx_Light_Bullet_Ramjet'
    // ExplosionLightClass=class'Rx_Light_Bullet_Ramjet'
    MyDamageType=class'Rx_DmgType_Railgun'
}
