/*********************************************************
*
* File: Rx_Defence_GunEmplacement_Weapon.uc
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
class Rx_Defence_GunEmplacement_Weapon extends Rx_Vehicle_MultiWeapon;

var	SoundCue WeaponDistantFireSnd[2];					/* A second firing sound to be played when weapon fires. (Used for distant sound) */


simulated function FireAmmunition()
{
    Super.FireAmmunition();
	if( WeaponDistantFireSnd[CurrentFireMode] != None )
			WeaponPlaySound( WeaponDistantFireSnd[CurrentFireMode] );
}

/**
simulated function bool UsesClientSideProjectiles(byte CurrFireMode)
{
	return CurrFireMode == 0;
}
*/


DefaultProperties
{
	InventoryGroup=9
    
    ClipSize(0) = 100
    ClipSize(1) = 6

    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 4.0
    ReloadTime(1) = 4.0
    
    FireInterval(0)=0.08
    FireInterval(1)=0.15
    
    Spread(0)=0.01
    Spread(1)=0.01
 
    // gun config
    FireTriggerTags(0)="GattlingGun"
   
    AltFireTriggerTags(0)="FireR1"
	AltFireTriggerTags(1)="FireR2"
	
	RecoilImpulse = -0.0f
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
   
    VehicleClass=Class'RenX_Game.Rx_Defence_GunEmplacement'

    WeaponFireSnd(0)     = none
//    WeaponFireTypes(0)   = EWFT_Projectile
//    WeaponProjectiles(0) = Class'Rx_Defence_GunEmplacement_Projectile'
    WeaponFireSnd(1)     = SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Defence_GunEmplacement_Cannon'
	
	WeaponDistantFireSnd(0)=none // SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
	WeaponDistantFireSnd(1)=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_DistantFire'
	
	
    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True

	WeaponRange=10000.0

	WeaponFireTypes(0)=EWFT_InstantHit

	InstantHitDamage(0)=10
	
	HeadShotDamageMult=2.0

	InstantHitDamageTypes(0)=class'Rx_DmgType_GunEmpl'

	InstantHitMomentum(0)=10000
	
	bInstantHit=true
	
	
	BeamTemplates[0]=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI_Large'

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Dirt_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Metal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Glass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Wood_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Wood')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Flesh',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Mud_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Mud')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_WhiteSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Grass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Grass')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowStone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Snow')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	
/***********************/
/*Veterancy*/
/**********************/
Vet_ClipSizeModifier(0)=0 //Normal +X
Vet_ClipSizeModifier(1)=10 //Veteran 
Vet_ClipSizeModifier(2)=25 //Elite
Vet_ClipSizeModifier(3)=50 //Heroic


Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_ReloadSpeedModifier(1)=1 //Veteran 
Vet_ReloadSpeedModifier(2)=0.90 //Elite
Vet_ReloadSpeedModifier(3)=0.80 //Heroic

Vet_SecondaryClipSizeModifier(0)=0 //Normal +X
Vet_SecondaryClipSizeModifier(1)=2 //Veteran 
Vet_SecondaryClipSizeModifier(2)=4 //Elite
Vet_SecondaryClipSizeModifier(3)=6 //Heroic


Vet_SecondaryReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_SecondaryReloadSpeedModifier(1)=0.95 //Veteran 
Vet_SecondaryReloadSpeedModifier(2)=0.90 //Elite
Vet_SecondaryReloadSpeedModifier(3)=0.85 //Heroic 

//missiles
Vet_ROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_ROFSpeedModifier(1)=1 //Veteran 
Vet_ROFSpeedModifier(2)=1 //Elite
Vet_ROFSpeedModifier(3)=1 //Heroic

//Gun
Vet_SecondaryROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_SecondaryROFSpeedModifier(1)=1 //Veteran 
Vet_SecondaryROFSpeedModifier(2)=1 //Elite
Vet_SecondaryROFSpeedModifier(3)=1 //Heroic

/***********************************/

}
