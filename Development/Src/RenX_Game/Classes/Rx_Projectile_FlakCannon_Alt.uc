class Rx_Projectile_FlakCannon_Alt extends Rx_Projectile;



DefaultProperties
{

    ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.shells.P_Flak_Shards'
//	AmbientSound=SoundCue'RX_SoundEffects.Bullet_WhizBy.SC_Bullet_WhizBy'
	
    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Dirt',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Dirt')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Stone',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Stone')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Stone',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Stone')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Metal',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Metal')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Glass',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Glass')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Wood',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Wood')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Incendiary_Impact_Water',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Incendiary_Impact_Water',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Incendiary_Impact_Flesh',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Flesh')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_TibGround_Green',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Dirt')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_TibCrystal_Green',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Glass')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_TibGround_Blue',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Dirt')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_TibCrystal_Blue',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Glass')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Mud',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Water')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_WhiteSand',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Dirt')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_YellowSand',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Dirt')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Grass',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Dirt')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_YellowSand',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Stone')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Snow',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Dirt')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Snow',Sound=SoundCue'RX_WP_TacticalRifle.Sounds.Impact.SC_BulletImpact_Stone')


    DrawScale= 1.0
    
    MyDamageType=class'Rx_DmgType_FlakCannon_Alt'
    
//    TossZ=100.0
    Speed=6000
    MaxSpeed=6000
    AccelRate=0
    LifeSpan=0.53
    Damage=12
    DamageRadius=0
	HeadShotDamageMult=2.0
    MomentumTransfer=10000
	
//	TossZ=100.0
	
//	Physics=PHYS_Falling
    
//    CustomGravityScaling=1.0

    bCollideComplex=true
    bCollideWorld=true
    bBounce=false
    bNetTemporary=false
    bRotationFollowsVelocity=true
    bBlockedByInstigator=true
    bSuppressExplosionFX=true // Do not spawn hit effect in mid air
	bWaitForEffectsAtEndOfLifetime = true
    bWaitForEffects=true
}
