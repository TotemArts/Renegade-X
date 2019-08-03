class Rx_Projectile_TiberiumGrenade extends Rx_Projectile_Grenade; 

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(2.0f);
}

DefaultProperties
{

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
    
    MyDamageType=class'Rx_DmgType_TiberiumGrenade'
    
    LifeSpan=2.0
    Damage=100 //100//80
    DamageRadius=500
    MomentumTransfer=50000
//ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Tiberium'
	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
	
	StatEffectClass = class'Rx_StatModifierInfo_ChemGrenadeDebuff'; 
}

