/*********************************************************
*
* File: Rx_Vehicle_Orca_Weapon.uc
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
class Rx_Vehicle_Orca_Weapon extends Rx_Vehicle_MultiWeapon;

var	SoundCue WeaponDistantFireSnd[2];					/* A second firing sound to be played when weapon fires. (Used for distant sound) */


simulated function FireAmmunition()
{
    Super.FireAmmunition();
	if( WeaponDistantFireSnd[CurrentFireMode] != None )
			WeaponPlaySound( WeaponDistantFireSnd[CurrentFireMode] );
}

simulated function bool UsesClientSideProjectiles(byte CurrFireMode)
{
	return CurrFireMode == 1;
}

simulated function GetFireStartLocationAndRotation(out vector SocketLocation, out rotator SocketRotation) {
    
    super.GetFireStartLocationAndRotation(SocketLocation, SocketRotation);    
    
    if( (Rx_Bot(MyVehicle.Controller) != None) && (Rx_Bot(MyVehicle.Controller).GetFocus() != None) ) {
        if(class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.6) {
			MaxFinalAimAdjustment = 0.350;	
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}

function byte BestMode()
{
	if(bLockedOnTarget && !PrimaryReloading)
		return 0;
	
	if(!SecondaryReloading)
		return 1;
	
	return 0;	
}


DefaultProperties
{
  	bIgnoreDownwardPitch = true
  	bFastRepeater=true
  
    InventoryGroup=19
    
    ClipSize(0) = 8
	ClipSize(1) = 100
    
    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 8.0
	ReloadTime(1) = 3.0
        
    FireInterval(0)=0.4
	FireInterval(1)=0.05
    
    Spread(0)=0.05
	Spread(1)=0.015
	
	RecoilImpulse = -0.0f
   
    // gun config
    FireTriggerTags(0)="FireLeft"
	FireTriggerTags(1)="FireRight"
   
    AltFireTriggerTags(0)="GunFire"
//  AltFireTriggerTags(1)="FireRight"

	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
 
    VehicleClass=Class'RenX_Game.Rx_Vehicle_Orca'

    WeaponFireSnd(0)     = SoundCue'RX_VH_Orca.Sounds.SC_Orca_Missile'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_Orca_Missile'
	WeaponFireSnd(1)     = none // SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire'
	WeaponFireTypes(1)   = EWFT_Projectile
	WeaponProjectiles(1) = Class'Rx_Vehicle_Orca_Gun'
	
//	ReloadSound(0)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
//	ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Gun'
	
	WeaponProjectiles_Heroic(0)= Class'Rx_Vehicle_Orca_Missile_Heroic'
	WeaponProjectiles_Heroic(1)= Class'Rx_Vehicle_Orca_Gun'
 
	WeaponFireSounds_Heroic(0)=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Missile_Heroic'
	
	WeaponDistantFireSnd(0)=SoundCue'RX_VH_Orca.Sounds.SC_Missile_DistantFire'
	WeaponDistantFireSnd(1)=None		// The gun sound is being handled in the vehicle class
	
	
	
/*	
	WeaponRange=4500.0

	WeaponFireTypes(1)=EWFT_InstantHit

	InstantHitDamage(0)=12
	InstantHitDamage(1)=12
	
	HeadShotDamageMult=2.5

	InstantHitDamageTypes(0)=class'Rx_DmgType_Orca_Gun'
	InstantHitDamageTypes(1)=class'Rx_DmgType_Orca_Gun'

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=10000
	
	bInstantHit=true
	

	BeamTemplates[1]=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI_Large'
	
	DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	
	AltImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Dirt_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
    AltImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	AltImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
    AltImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Metal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal')
    AltImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Glass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
    AltImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Wood_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Wood')
    AltImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
    AltImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
	AltImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Flesh',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh')
	AltImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	AltImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	AltImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	AltImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	AltImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Mud_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Mud')
	AltImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_WhiteSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	AltImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	AltImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Grass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Grass')
	AltImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowStone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	AltImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Snow')
	AltImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
*/
	
	
	
     
    //==========================================
    //LOCKING PROPERTIES
    //==========================================
    
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance=0.25

    LockRange            = 4500
    ConsoleLockAim       = 0.997000
    LockAim              = 0.998000
    LockCheckTime        = 0.1
    LockAcquireTime      = 0.7 // change this!!!!!!!!!
    StayLocked           = 0.1 // change this, too

    
     // AI
    bRecommendSplashDamage=True
    bTargetLockingActive = true;
	
/***********************/
/*Veterancy*/
/**********************/
Vet_ClipSizeModifier(0)=0 //Normal +X
Vet_ClipSizeModifier(1)=0 //Veteran 
Vet_ClipSizeModifier(2)=2 //Elite
Vet_ClipSizeModifier(3)=2 //Heroic


Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_ReloadSpeedModifier(1)=0.90 //Veteran 
Vet_ReloadSpeedModifier(2)=0.85 //Elite
Vet_ReloadSpeedModifier(3)=0.75 //Heroic

Vet_SecondaryClipSizeModifier(0)=0 //Normal +X
Vet_SecondaryClipSizeModifier(1)=20 //Veteran 
Vet_SecondaryClipSizeModifier(2)=50 //Elite
Vet_SecondaryClipSizeModifier(3)=100 //Heroic


Vet_SecondaryReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_SecondaryReloadSpeedModifier(1)=1.0 //Veteran 
Vet_SecondaryReloadSpeedModifier(2)=0.90 //Elite
Vet_SecondaryReloadSpeedModifier(3)=0.80 //Heroic 

//missiles
Vet_ROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_ROFSpeedModifier(1)=0.9 //Veteran 
Vet_ROFSpeedModifier(2)=0.85 //Elite
Vet_ROFSpeedModifier(3)=0.85 //Heroic

//Gun
Vet_SecondaryROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_SecondaryROFSpeedModifier(1)=1 //Veteran 
Vet_SecondaryROFSpeedModifier(2)=1 //Elite
Vet_SecondaryROFSpeedModifier(3)=1 //Heroic

/***********************************/

SF_Tolerance = 120; //For now, till it becomes an issue


FM0_ROFTurnover = 4; //9 for most automatics. Single shot weapons should be more, except the shotgun
FM1_ROFTurnover = 6; 

    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True
    bOkAgainstBuildings = True
}
