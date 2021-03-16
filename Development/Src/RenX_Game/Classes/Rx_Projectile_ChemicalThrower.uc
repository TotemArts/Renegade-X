class Rx_Projectile_ChemicalThrower extends Rx_Projectile_Spray;


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
    Speed=2000 //2000
    MaxSpeed=2000 //2000
    AccelRate=0
    LifeSpan=0.7
    Damage=16 //13.2
    DamageRadius=0 //50 //150 //Needs no damage radius. Use SprayRadii vector to make he spray more shapes
	HeadShotDamageMult=1.10//1.2//1.0 //1.3
    MomentumTransfer=1
	
	MaxSprayRadii = (X=5,Y=5,Z=5) //You're THIS big in the end 
	MinSprayRadii =  (X=5,Y=5,Z=5) //You're this big to start with 
	//SprayRadii = (X=0.0,Y=0.0,Z=0.0)
	
	//Use something less taxing every tick 
	/**Begin Object Name=CollisionCylinder
		CollisionRadius=10 //20
		CollisionHeight=10 //20
		//Don't waste server resources on tracing for a client side projectile 
		CollideActors = false
		AlwaysLoadOnServer=false
	End Object*/ 
    
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
	Vet_SpeedIncrease(1)=1.05 //Veteran 
	Vet_SpeedIncrease(2)=1.10 //Elite
	Vet_SpeedIncrease(3)=1.15 //Heroic 
	
	/***********************/
}
