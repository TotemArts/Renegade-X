/*********************************************************
*
* File: RA2_Vehicle_ApocalypseTank_Projectile.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class RA2_Vehicle_ApocalypseTank_Projectile extends Rx_Vehicle_Projectile;


simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(0.8f);
}



DefaultProperties
{
	AmbientSound=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_FlyBy'

	ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Shells.P_Shell_Basic'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Rockets_Shells')
	
	
   
	Speed=7625
	MaxSpeed=7625
	LifeSpan=1.15
	Damage= 80//80 should be about 90
	DamageRadius=500
	MomentumTransfer=100000.000000
	HeadShotDamageMult=10.0 // 5.0

	MyDamageType=Class'RA2_DmgType_ApocalypseTank_Cannon'

	ExplosionLightClass=Class'Rx_Light_Tank_Explosion'
	MaxExplosionLightDistance=7000.000000
	
	bCheckProjectileLight=true	
	ProjectileLightClass=class'RenX_Game.Rx_Light_Tank_Shell'
	bWaitForEffectsAtEndOfLifetime = true
	
	Vet_LifespanModifier(0)=1 //Normal (should be 1)
	Vet_LifespanModifier(1)=1.05 //Veteran 
	Vet_LifespanModifier(2)=1.10 //Elite
	Vet_LifespanModifier(3)=1.15 //Heroic
}
