/*********************************************************
*
* File: Rx_Vehicle_FlameTank_Projectile.uc
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
class Rx_Vehicle_FlameTank_Projectile extends Rx_Vehicle_Projectile_Spray;

/**
simulated function PostBeginPlay()
{
	super.PostBeginPlay(); 
	
	if(WorldInfo.NetMode == NM_DedicatedServer) //Not on client, so lower your collision box
	{
		CylinderComponent.SetCylinderSize(1,1);
	}
}*/

simulated function InitializeSpray()
{
	//Set our initial Spray Radii 
	SprayRadii = MinSprayRadii;
	
	//`log("Radii InitL (" $ MaxSprayRadii.X @ "-" @ MinSprayRadii.X @ ")" @ "/" @ LifeSpan $ "/0.1"); 
	SprayRadiiIncrement.X = 3.65; //(MaxSprayRadii.X - MinSprayRadii.X)/(LifeSpan/0.15);
	SprayRadiiIncrement.Y = 3.65; //(MaxSprayRadii.Y - MinSprayRadii.Y)/(LifeSpan/0.15);
	SprayRadiiIncrement.Z = 3.65; //(MaxSprayRadii.Z - MinSprayRadii.Z)/(LifeSpan/0.15);
} 
	
DefaultProperties
{
//    AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
//    ExplosionSound=none
 
//    ProjExplosionTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode'
    ProjFlightTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_FireBall'
 
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_Flame_Explode',Sound=none)
	
	MyDamageType=Class'RenX_Game.Rx_DmgType_FlameTank'

	DrawScale= 1.0f

//	Physics=PHYS_Falling
	
//	CustomGravityScaling=0.35
//	bRotationFollowsVelocity=true
//	TossZ=50
    
    Speed=3000			// 1500Int
    MaxSpeed=3000 		// 1500
    LifeSpan=0.7		// 1.0
    Damage=7 			// 13
    DamageRadius=0//200
	HeadShotDamageMult=1
    MomentumTransfer=1
	
	MaxSprayRadii = (X=25.0,Y=25.0,Z=25.0) //You're THIS big in the end 
	MinSprayRadii =  (X=8.0,Y=8.0,Z=8.0) //You're this big to start with 
	
	
	/**Begin Object Name=CollisionCylinder
		CollisionRadius=30
		CollisionHeight=30
	End Object*/
	
	

	Vet_SpeedIncrease(0)=1 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1 //Veteran 
	Vet_SpeedIncrease(2)=1.1 //Elite
	Vet_SpeedIncrease(3)=1.25 //Heroic
	
    bWaitForEffects=true
	bWaitForEffectsAtEndOfLifetime = true
	bAttachExplosionToVehicles=true    
    bCheckProjectileLight=false
	bSuppressExplosionFX=true
	
	bCollideWorld = true; 

    ProjectileLightClass=class'RenX_Game.Rx_Light_FlameThrower'
    // ExplosionLightClass=Class'RenX_Game.Rx_Light_FlameThrower'
    
}
