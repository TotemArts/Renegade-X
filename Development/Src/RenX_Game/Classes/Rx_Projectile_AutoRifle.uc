class Rx_Projectile_AutoRifle extends Rx_Projectile
    abstract;

DefaultProperties
{

	AmbientSound=SoundCue'RX_SoundEffects.Bullet_WhizBy.SC_Bullet_WhizBy'

	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Dirt',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0 )
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Stone'),DecalWidth=8.0,DecalHeight=8.0)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Concrete'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Metal',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Metal'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Glass',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass',DecalMaterials=(DecalMaterial'RX_FX_Munitions.Bullet_Decals.MDecal_Bullet_Glass'),DecalWidth=20.0,DecalHeight=20.0)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Wood',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Wood',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Wood_01'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Flesh',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Blue',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Blue',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Mud',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Mud')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_WhiteSand',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowSand',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Grass',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Grass')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowStone',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Snow')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')


    MyDamageType=class'Rx_DmgType_AutoRifle'

    DrawScale= 0.75 //1.0f

    bCollideComplex=true
    Speed=18000	//14000 / 9000
    MaxSpeed=18000	//14000 / 9000
    AccelRate=0
    LifeSpan=0.3305	//0.425	/0.65 
    Damage=16 //8
    DamageRadius=0
	HeadShotDamageMult=1.5 //1.75 //4.0 //3.0
    MomentumTransfer=10000
    bAttachExplosionToVehicles=false
    bCheckProjectileLight=false
    bSuppressExplosionFX=True // Do not spawn hit effect in mid air
	
	/*************************/
	/*VETERANCY*/
	/************************/
	
	Vet_DamageIncrease(0)=1 //Normal (should be 1)
	Vet_DamageIncrease(1)=1.10 //Veteran 
	Vet_DamageIncrease(2)=1.25 //Elite
	Vet_DamageIncrease(3)=1.50 //Heroic

	Vet_SpeedIncrease(0)=1 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1.5 //Veteran 
	Vet_SpeedIncrease(2)=3.0 //Elite
	Vet_SpeedIncrease(3)=3.0 //Heroic (N/A for AutoRifle, as it gets hitscan...... LOL, I forgot I said that when veterancy was first release)
	
		
	Vet_LifespanModifier(0)=1 //Normal (should be 1)
	Vet_LifespanModifier(1)=0.75 //Veteran 
	Vet_LifespanModifier(2)=0.45 //Elite
	Vet_LifespanModifier(3)=1 //Heroic
	
	/***********************/
}
