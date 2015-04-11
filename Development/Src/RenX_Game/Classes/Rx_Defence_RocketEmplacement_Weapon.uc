/*********************************************************
*
* File: Rx_Defence_RocketEmplacement_Weapon.uc
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
class Rx_Defence_RocketEmplacement_Weapon extends Rx_Vehicle_MultiWeapon;

var	SoundCue WeaponDistantFireSnd[2];					/* A second firing sound to be played when weapon fires. (Used for distant sound) */


simulated function FireAmmunition()
{
    Super.FireAmmunition();
	if( WeaponDistantFireSnd[CurrentFireMode] != None )
			WeaponPlaySound( WeaponDistantFireSnd[CurrentFireMode] );
}

simulated function bool UsesClientSideProjectiles(byte CurrFireMode)
{
	return CurrFireMode == 0;
}


DefaultProperties
{
    InventoryGroup=9
    
    ClipSize(0) = 12
    ClipSize(1) = 1

    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 6.0
    ReloadTime(1) = 6.0
    
    FireInterval(0)=0.15
    FireInterval(1)=0.15
    
    Spread(0)=0.4
    Spread(1)=0.05
 
    // gun config
    FireTriggerTags(0)="FireR"
   
    AltFireTriggerTags(0)="FireL"
	
	RecoilImpulse = -0.0f
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
   
    VehicleClass=Class'RenX_Game.Rx_Defence_RocketEmplacement'

    WeaponFireSnd(0)     = SoundCue'RX_DEF_GunEmplacement.Sounds.SC_RocketEmplacement_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Defence_RocketEmplacement_Rockets'
    WeaponFireSnd(1)     = SoundCue'RX_VH_Apache.Sounds.SC_Apache_Missile'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Defence_RocketEmplacement_Missile'
	
	WeaponDistantFireSnd(0)=none // SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
	WeaponDistantFireSnd(1)=SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
	  
    //==========================================
    // LOCKING PROPERTIES
    //==========================================
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance		 = 0.6 			// 0.5		// How many seconds to stay locked

    LockRange            = 10000
    ConsoleLockAim       = 0.997		// 0.997000
    LockAim              = 1.0			// 0.998000
    LockCheckTime        = 0.1			// 0.1
    LockAcquireTime      = 0.25 			// 0.7
    StayLocked           = 0.1 			// 0.1		// This does nothing    

    
     // AI
    bRecommendSplashDamage = True
    bTargetLockingActive = true
}
