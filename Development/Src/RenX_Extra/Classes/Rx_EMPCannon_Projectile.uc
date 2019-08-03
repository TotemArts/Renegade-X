class Rx_EMPCannon_Projectile extends Rx_Vehicle_Projectile;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.0f);
}

DefaultProperties
{
    AmbientSound=SoundCue'RX_SoundEffects.Missiles.SC_Missile_FlyBy'
    ProjFlightTemplate=ParticleSystem'RX_BU_EMPCannon.Particles.P_EMPBall'

   ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	
    DrawScale = 6f
    Speed=3000
    MaxSpeed=3000
    LifeSpan=3.0
    Damage=100
    DamageRadius=600
    MomentumTransfer=100000.000000
    MyDamageType=class'Rx_DmgType_EMPGrenade'
    //RotationRate=(Pitch=0,Yaw=0,Roll=50000)
    bWaitForEffects=true
	ExplosionLightClass=Class'RenX_Game.Rx_Light_EMPExplosion'
	bLogExplosion=true
}