/*********************************************************
*
* File: Rx_Vehicle_A10_Weapon.uc
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
class Rx_Vehicle_A10_Weapon extends Rx_Vehicle_MultiWeapon;


DefaultProperties
{
    
    InventoryGroup=0
    
    ClipSize(0) = 100
    ClipSize(1) = 4

    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 4.0
    ReloadTime(1) = 6.0
    
    FireInterval(0)=0.05
    FireInterval(1)=0.2
    
    Spread(0)=0.015
    Spread(1)=0.0
	
	RecoilImpulse = -0.0f
    
    // gun config
    FireTriggerTags(0)="GattlingGunFire"
   
    AltFireTriggerTags(0)="MissileFireLeft"
    AltFireTriggerTags(1)="MissileFireRight"
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5'
   
    VehicleClass=Class'RenX_Game.Rx_Vehicle_A10'

    WeaponFireSnd(0)     = None 	// SoundCue'RX_VH_A-10.Sounds.SC_A-10_Gun'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_A10_GattlingGun'
    WeaponFireSnd(1)     = SoundCue'RX_VH_A-10.Sounds.SC_A-10_Missile'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_A10_Missile'
   
    //==========================================
    //LOCKING PROPERTIES
    //==========================================
    
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance=0.5

    LockRange            = 60000 //2360
    ConsoleLockAim       = 0.992000
    LockAim              = 0.997000
    LockCheckTime        = 0.1
    LockAcquireTime      = 0.2 // change this!!!!!!!!!
    StayLocked           = 0.3 // change this, too

    
     // AI
    bRecommendSplashDamage=True
    bTargetLockingActive = true;
}
