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
	
	/****************************************/
	/*Veterancy*/
	/****************************************/
	
	//*X (Applied to instant-hits only) Modify Projectiles separately
	Vet_DamageModifier(0)=1  //Normal
	Vet_DamageModifier(1)=1.10  //Veteran
	Vet_DamageModifier(2)=1.25  //Elite
	Vet_DamageModifier(3)=1.50  //Heroic
	
	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ROFModifier(0) = 1 //Normal
	Vet_ROFModifier(1) = 1.10  //Veteran
	Vet_ROFModifier(2) = 1.25  //Elite
	Vet_ROFModifier(3) = 1.50  //Heroic
 
	//+X
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=0 //Elite
	Vet_ClipSizeModifier(3)=0 //Heroic

	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	
	Vet_SecondaryClipSizeModifier(0)=0 //Normal +X
	Vet_SecondaryClipSizeModifier(1)=0 //Veteran 
	Vet_SecondaryClipSizeModifier(2)=2 //Elite
	Vet_SecondaryClipSizeModifier(3)=4 //Heroic
	
	Vet_SecondaryReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
	Vet_SecondaryReloadSpeedModifier(1)=1 //Veteran 
	Vet_SecondaryReloadSpeedModifier(2)=1 //Elite
	Vet_SecondaryReloadSpeedModifier(3)=0.9 //Heroic
	
	Vet_SecondaryROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
	Vet_SecondaryROFSpeedModifier(1)=1 //Veteran 
	Vet_SecondaryROFSpeedModifier(2)=1.0 //Elite
	Vet_SecondaryROFSpeedModifier(3)=1.0 //Heroic 
	
	
	/********************************/
    bOkAgainstLightVehicles = True
	bOkAgainstArmoredVehicles = True
	bOkAgainstBuildings = False
}
