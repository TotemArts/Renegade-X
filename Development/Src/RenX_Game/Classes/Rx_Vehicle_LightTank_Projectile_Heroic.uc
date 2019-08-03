/*********************************************************
*
* File: Rx_Vehicle_LightProjectile.uc
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
class Rx_Vehicle_LightTank_Projectile_Heroic extends Rx_Vehicle_LightTank_Projectile;


simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.25f);
}


DefaultProperties
{
	AmbientSound=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_FlyBy'

	ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.shells.P_Shell_Heroic'

	/**
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
	*/
	
	
	
}
