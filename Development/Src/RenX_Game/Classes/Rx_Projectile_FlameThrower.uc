class Rx_Projectile_FlameThrower extends Rx_Projectile_Spray;

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
    Speed=2500
    MaxSpeed=2500
    AccelRate=0
    LifeSpan=0.48 //0.75
    Damage=12 //11
    //DamageRadius= 0.0
	HeadShotDamageMult=1.15 //1.0 //1.25
    MomentumTransfer=1
	
	MaxSprayRadii = (X=4,Y=4,Z=4) //You're THIS big in the end 
	MinSprayRadii =  (X=4,Y=4,Z=4) //You're this big to start with 
	//SprayRadii = (X=0.0,Y=0.0,Z=0.0)
	
	/**Begin Object Name=CollisionCylinder
		CollisionRadius=10
		CollisionHeight=10
		//Don't waste server resources on tracing for a client side projectile 
		CollideActors = false
		AlwaysLoadOnServer=false
	End Object*/
    
    bWaitForEffects=true
    bWaitForEffectsAtEndOfLifetime=true
    bAttachExplosionToVehicles=true
    bCheckProjectileLight=false
    bSuppressExplosionFX=True // Do not spawn hit effect in mid air
    
    // ProjectileLightClass=class'Rx_Light_FlameThrower'
    // ExplosionLightClass=class'Rx_Light_FlameThrower'
	
	/*************************/
	/*VETERANCY*/
	/************************/
	
	Vet_DamageIncrease(0)=1 //Normal (should be 1)
	Vet_DamageIncrease(1)=1.10 //Veteran 
	Vet_DamageIncrease(2)=1.25 //Elite
	Vet_DamageIncrease(3)=1.50 //Heroic

	Vet_SpeedIncrease(0)=1 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1.05 //Veteran 
	Vet_SpeedIncrease(2)=1.10 //Elite
	Vet_SpeedIncrease(3)=1.15 //Heroic 
	
	/***********************/
}
