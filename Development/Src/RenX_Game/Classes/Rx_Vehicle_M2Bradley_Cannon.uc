/*********************************************************
*
* File: Rx_Vehicle_M2Bradley_Cannon.uc
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
class Rx_Vehicle_M2Bradley_Cannon extends Rx_Vehicle_Projectile;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(0.7f); //(1.25f);
}

DefaultProperties
{
	DrawScale            = 1.0f

	AmbientSound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_FlyBy'
	ProjFlightTemplate=ParticleSystem'RX_VH_M2Bradley.Effects.P_Cannon'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Water')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Flak',Sound=SoundCue'RX_VH_M2Bradley.Sounds.SC_Cannon_Impact_Default')
	  
	bCollideWorld=True
	bNetTemporary=False
	bWaitForEffects=True
	bRotationFollowsVelocity=true
   
	Physics=PHYS_Projectile

	ExplosionLightClass=Class'Rx_Light_Tank_MuzzleFlash'
	MaxExplosionLightDistance=7000.000000
	Speed=12500
	MaxSpeed=12500
	LifeSpan=0.66
	Damage=35
	DamageRadius=300
	HeadShotDamageMult=3.0
	MomentumTransfer=1000.000000

	MyDamageType=Class'Rx_DmgType_M2Bradley'

	bCheckProjectileLight=true
	ProjectileLightClass=class'UDKExplosionLight' // TODO
	bWaitForEffectsAtEndOfLifetime = true
	
	Vet_LifespanModifier(0)=1 //Normal (should be 1)
	Vet_LifespanModifier(1)=1.05 //Veteran 
	Vet_LifespanModifier(2)=1.10 //Elite
	Vet_LifespanModifier(3)=1.15 //Heroic
}
