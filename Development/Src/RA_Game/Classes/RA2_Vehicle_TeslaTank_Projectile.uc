/*********************************************************
*
* File: RA2_Vehicle_TeslaTank_Projectile.uc
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
class RA2_Vehicle_TeslaTank_Projectile extends Rx_Vehicle_Projectile;

DefaultProperties
{
    AmbientSound=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_FlyBy'
//    ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_2'
 
//    ProjExplosionTemplate=ParticleSystem'RX_FX_Munitions.Explosions.P_Explosion_Medium_Dirt'
    ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.shells.P_Shell_Incendiary'	// ParticleSystem'RX_FX_Munitions.Shells.P_Shell_Basic'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')	
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Big')
	
    DrawScale = 1.1f
    
    DecalWidth=300.000000
    DecalHeight=300.000000
    ExplosionLightClass=Class'Rx_Light_Tank_Explosion'
    Speed=25000
    MaxSpeed=25000
    LifeSpan=0.5
    Damage=200
    DamageRadius=600
    MomentumTransfer=100000.000000
	HeadShotDamageMult=10.0 // 5.0

    MyDamageType=Class'RA2_DmgType_TeslaTank_Coil'

    bCheckProjectileLight=true
    ProjectileLightClass=class'RenX_Game.Rx_Light_Tank_Shell'
    bWaitForEffectsAtEndOfLifetime = true
}
