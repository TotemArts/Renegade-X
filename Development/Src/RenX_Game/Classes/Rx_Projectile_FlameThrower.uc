class Rx_Projectile_FlameThrower extends Rx_Projectile;

DefaultProperties
{

    ProjFlightTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.FX_FireBall'
    
    ProjExplosionTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode'
 
    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(17)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(18)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode',Sound=none)

 
    MyDamageType=class'Rx_DmgType_FlameThrower'

    DrawScale= 1.0f
/*	
	Physics=PHYS_Falling
	
	CustomGravityScaling=0.4
	bRotationFollowsVelocity=true
	TossZ=50
*/
    bCollideComplex=true
    Speed=2000
    MaxSpeed=2000
    AccelRate=0
    LifeSpan=0.75
    Damage=10
    DamageRadius=100
	HeadShotDamageMult=1.25
    MomentumTransfer=1
	Begin Object Name=CollisionCylinder
		CollisionRadius=20
		CollisionHeight=20
	End Object
    
    bWaitForEffects=true
    bWaitForEffectsAtEndOfLifetime=true
    bAttachExplosionToVehicles=true
    bCheckProjectileLight=false
    bSuppressExplosionFX=True // Do not spawn hit effect in mid air
    
    // ProjectileLightClass=class'Rx_Light_FlameThrower'
    // ExplosionLightClass=class'Rx_Light_FlameThrower'
}
