/*********************************************************
*
* File: TS_Vehicle_ReconBike_Weapon.uc
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
class TS_Vehicle_ReconBike_Weapon extends Rx_Vehicle_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

DefaultProperties
{
    InventoryGroup=17

    // reload config
    ClipSize = 6
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
    
    ReloadTime(0) = 4.0
    ReloadTime(1) = 4.0
    
	CloseRangeAimAdjustRange = 50    
    
    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
 
    // gun config
    FireTriggerTags(1) = "FireRight"
    FireTriggerTags(0) = "FireLeft"
    AltFireTriggerTags(1) = "FireRight"
    AltFireTriggerTags(0) = "FireLeft"
    VehicleClass=Class'RenX_Game.TS_Vehicle_ReconBike'

    FireInterval(0)=0.15
    FireInterval(1)=0.15
    bFastRepeater=false

    Spread(0)=0.35
    Spread(1)=0.35
	
	RecoilImpulse = -0.0f

    WeaponFireSnd(0)     = SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'TS_Vehicle_ReconBike_Projectile'
    WeaponFireSnd(1)     = SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'TS_Vehicle_ReconBike_Projectile'
	
	ReloadSound(0)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
    ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
	
	WeaponDistantFireSnd=SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
   
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'

    // AI
    bRecommendSplashDamage=True
    
    //==========================================
    // LOCKING PROPERTIES
    //==========================================
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance		 = 0.2 			// 0.5		// How many seconds to stay locked

    LockRange            = 8000
    ConsoleLockAim       = 0.997			// 0.997000
    LockAim              = 0.997			// 0.998000
    LockCheckTime        = 0.1			// 0.1
    LockAcquireTime      = 0.5 			// 0.7
    StayLocked           = 0.1 			// 0.1		// This does nothing

    bTargetLockingActive = true
    bHasRecoil = true
    bIgnoreDownwardPitch = false
    bCheckIfFireStartLocInsideOtherVehicle = true
}
