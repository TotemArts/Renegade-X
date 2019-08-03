class TS_Vehicle_Wolverine_MG extends Rx_Projectile;

DefaultProperties
{

    ProjFlightTemplate=ParticleSystem'TS_VH_Wolverine.Effects.P_Projectile'
	
	AmbientSound=SoundCue'RX_SoundEffects.Bullet_WhizBy.SC_Bullet_WhizBy'

	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Dirt_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Stone'),DecalWidth=8.0,DecalHeight=8.0)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Concrete'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Metal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Metal'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Glass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass',DecalMaterials=(DecalMaterial'RX_FX_Munitions.Bullet_Decals.MDecal_Bullet_Glass'),DecalWidth=20.0,DecalHeight=20.0)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Wood_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Wood',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Wood_01'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Flesh',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Mud_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Mud')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_WhiteSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Grass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Grass')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowStone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Snow')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')

	
    DrawScale= 1.0f

    bCollideComplex=true
//    bCollideWorld=true
    Speed=10000
    MaxSpeed=10000
    AccelRate=0
    LifeSpan=0.6
    Damage=16
    DamageRadius=0
	HeadShotDamageMult=2.5
    MomentumTransfer=10000
    bAttachExplosionToVehicles=false
    bCheckProjectileLight=false
    bSuppressExplosionFX=True // Do not spawn hit effect in mid air
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=10
		CollisionHeight=10
	End Object
    
    ProjectileLightClass=none
    ExplosionLightClass=none
    MyDamageType=class'TS_Vehicle_Wolverine_DmgType'
	
	Vet_DamageIncrease(0)=1 //Normal (should be 1)
	Vet_DamageIncrease(1)=1.10 //Veteran 
	Vet_DamageIncrease(2)=1.25 //Elite
	Vet_DamageIncrease(3)=1.50 //Heroic

	Vet_SpeedIncrease(0)=1 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1.25 //Veteran 
	Vet_SpeedIncrease(2)=1.50 //Elite
	Vet_SpeedIncrease(3)=2.0 //Heroic
}
