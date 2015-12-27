class Rx_Projectile_TiberiumAutoRifle_Blue extends Rx_Projectile;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(0.5f);
}

DefaultProperties
{

    ProjFlightTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Projectile_TiberiumAutoRifle_Blue'
	
	AmbientSound=SoundCue'RX_WP_GrenadeLauncher.Sounds.SC_GrenadeLauncher_Ambient'

	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Explosion_TiberiumBlue',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Tiberium')

	
    DrawScale= 0.5f
	
	Physics=PHYS_Falling
    
CustomGravityScaling=0.8
	
//	TossZ=100.0
//    TerminalVelocity=5000.0

    bCollideComplex=true
//    bCollideWorld=true
    Speed= 6000 //4000 			// 11200
    MaxSpeed= 6000//4000 		// 11200
    AccelRate=0
    LifeSpan=1.5		// 0.6
    Damage=40
    DamageRadius=100
	HeadShotDamageMult=2.0
    MomentumTransfer=10000
	bWaitForEffects=true
    bAttachExplosionToVehicles=false
    bCheckProjectileLight=false
    bSuppressExplosionFX=false // Do not spawn hit effect in mid air
    
    ProjectileLightClass=class'Rx_Light_Blue_MuzzleFlash'
    ExplosionLightClass=class'Rx_Light_Blue_MuzzleFlash'
    MyDamageType=class'Rx_DmgType_TiberiumAutoRifle_Blue'
}
