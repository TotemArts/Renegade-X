class Rx_Projectile_ChemicalThrowerBlob extends Rx_Projectile_ChemicalThrower;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(2.0f);
}

DefaultProperties
{

   
    ProjExplosionTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium'
  
    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(17)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
	ImpactEffects(18)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=none)
   
    DrawScale= 1.5f

	Physics=PHYS_Falling
	
	CustomGravityScaling=0.4
	bRotationFollowsVelocity=true
	//TossZ=30

    bCollideComplex=true
    Speed=2500 //2000
    MaxSpeed=2500 //2000
    AccelRate=0
    LifeSpan=1.5; 
    Damage=50.0
    DamageRadius=150
	HeadShotDamageMult=1.5
    MomentumTransfer=1
	Begin Object Name=CollisionCylinder
		CollisionRadius=20
		CollisionHeight=20
	End Object
    
    bWaitForEffects=true
    bWaitForEffectsAtEndOfLifetime=true
    bAttachExplosionToVehicles=true
//	bCheckProjectileLight=true
    bSuppressExplosionFX=True // Do not spawn hit effect in mid air
    
    ProjectileLightClass=none
    ExplosionLightClass=none
	
	/*************************/
	/*VETERANCY*/
	/************************/
	
	Vet_DamageIncrease(0)=1 //Normal (should be 1)
	Vet_DamageIncrease(1)=1.10 //Veteran 
	Vet_DamageIncrease(2)=1.25 //Elite
	Vet_DamageIncrease(3)=1.50 //Heroic

	Vet_SpeedIncrease(0)=1 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1.25 //Veteran 
	Vet_SpeedIncrease(2)=1.5 //Elite
	Vet_SpeedIncrease(3)=2.0 //Heroic 
	
	/***********************/
}
