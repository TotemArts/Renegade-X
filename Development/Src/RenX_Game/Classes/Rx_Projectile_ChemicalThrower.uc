class Rx_Projectile_ChemicalThrower extends Rx_Projectile;

DefaultProperties
{

    ProjFlightTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem'
    
    ProjExplosionTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode'
  
    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(17)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
	ImpactEffects(18)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_Chem_Explode',Sound=none)
   
    MyDamageType=class'Rx_DmgType_ChemicalThrower'

    DrawScale= 1.0f
/*	
	Physics=PHYS_Falling
	
	CustomGravityScaling=0.4
	bRotationFollowsVelocity=true
	TossZ=30
*/
    bCollideComplex=true
    Speed=2000
    MaxSpeed=2000
    AccelRate=0
    LifeSpan=0.80
    Damage=12.0
    DamageRadius=100
	HeadShotDamageMult=1.3
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
}
