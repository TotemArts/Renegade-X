/*********************************************************
*
* File: Rx_Vehicle_StealthTank_Projectile.uc
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
class Rx_Vehicle_StealthTank_Projectile extends Rx_Vehicle_Projectile_SeekingRocket;


simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.0f);
}

simulated state Homing
{
	simulated function Timer()
	{
		local vector TargetLocation;
		local bool bDontLock;
		
		if(bDontLockAnymore) {
			return;
		}
		
		if(SeekTarget != none) {
			TargetLocation = SeekTarget.GetTargetLocation();
		} else {
			TargetLocation = Target;		
		}	
		
		/*if(class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Location,Rotation,TargetLocation) > 0.0) { 
			bDontLock = true;*/	
			// else we already are past the target}
		
		if(GetTimerCount('ShutDownBeforeEndOfLife',self) < 2.0)
			bDontLock = false;	
		
		if(!bDontLock) {
			if(RxIfc_SeekableTarget(SeekTarget) != none && VSize(SeekTarget.Velocity) > 150 && RxIfc_SeekableTarget(SeekTarget).GetAimAheadModifier() > 0.0) { 
				TargetLocation = TargetLocation + Normal(SeekTarget.Velocity) * RxIfc_SeekableTarget(SeekTarget).GetAimAheadModifier();
			}
			if(RxIfc_SeekableTarget(SeekTarget) != none && RxIfc_SeekableTarget(SeekTarget).GetAccelrateModifier() > 0.0) { 
				AccelRate = default.AccelRate * RxIfc_SeekableTarget(SeekTarget).GetAccelrateModifier();
			}
			Acceleration = 16.0 * AccelRate * Normal(TargetLocation - Location);
		} else {
			bDontLockAnymore = true;
		}		
	}

	simulated function BeginState(name PreviousStateName)
	{
		InitialState = 'Homing';
		Timer();
		SetTimer(0.1, true);
	}
}

simulated static function float GetRange() //Wasn't working correctly with the acceleration set, so I just set it manually.-Yosh
{
return 5800 ;	
}


DefaultProperties
{
   DrawScale            = 0.65f

    AmbientSound=SoundCue'RX_SoundEffects.Missiles.SC_Missile_FlyBy'
//   ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells'

//   ProjExplosionTemplate=ParticleSystem'RX_FX_Munitions.Explosions.P_Explosion_Medium_Dirt'
   ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Crude'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')	
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')

	
   
   bCollideWorld=True
   bNetTemporary=False
   bWaitForEffects=True
   bRotationFollowsVelocity=true
   
   Physics = PHYS_Projectile

   ExplosionLightClass=Class'Rx_Light_Tank_Explosion'
   MaxExplosionLightDistance=7000.000000
   Speed=500 //2000
   MaxSpeed=5000 //3500
   AccelRate=425 //425
   LifeSpan=1.5 //1.5
   HeadShotDamageMult=2.0 // 5.0
   Damage=45
   DamageRadius=380//280
   MomentumTransfer=100000.000000
   
   
   
   LockWarningInterval=1.5
   BaseTrackingStrength=5.0
   HomingTrackingStrength=5.0 //3.5

   MyDamageType=Class'Rx_DmgType_StealthTank'

   bCheckProjectileLight=true
   ProjectileLightClass=class'RenX_Game.Rx_Light_Rocket'
   
   /*************************/
	/*VETERANCY*/
	/************************/
	
	Vet_DamageIncrease(0)=1.0 //Normal (should be 1)
	Vet_DamageIncrease(1)=1.0 //Veteran 
	Vet_DamageIncrease(2)=1.0 //Elite
	Vet_DamageIncrease(3)=1.0//Heroic

	Vet_SpeedIncrease(0)=1 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1.10 //Veteran 
	Vet_SpeedIncrease(2)=1.25 //Elite
	Vet_SpeedIncrease(3)=1.5 //Heroic 
	
	/***********************/
}
