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
class Rx_Vehicle_FlameTank_Projectile extends Rx_Vehicle_Projectile;


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
    
    Speed=3000			// 1500
    MaxSpeed=3000 		// 1500
    LifeSpan=0.7		// 1.0
    Damage=7 			// 13
    DamageRadius=200
	HeadShotDamageMult=1
    MomentumTransfer=1
	Begin Object Name=CollisionCylinder
		CollisionRadius=30
		CollisionHeight=30
	End Object

    bWaitForEffects=true
	bWaitForEffectsAtEndOfLifetime = true
	bAttachExplosionToVehicles=true    
    bCheckProjectileLight=false
	bSuppressExplosionFX=true

    ProjectileLightClass=class'RenX_Game.Rx_Light_FlameThrower'
    // ExplosionLightClass=Class'RenX_Game.Rx_Light_FlameThrower'
    
}
