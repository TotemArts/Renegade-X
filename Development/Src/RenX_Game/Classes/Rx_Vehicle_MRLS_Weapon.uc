/*********************************************************
*
* File: Rx_Vehicle_MRLSWeapon.uc
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
class Rx_Vehicle_MRLS_Weapon extends Rx_Vehicle_Weapon_Reloadable;



var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)


/*********************************************************************************************
 * Shoot methods
 *********************************************************************************************/

simulated function FireAmmunition()
{
    Super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

simulated function bool UsesClientSideProjectiles(byte CurrFireMode)
{
	return false;
}

simulated function GetFireStartLocationAndRotation(out vector SocketLocation, out rotator SocketRotation) {
    
    super.GetFireStartLocationAndRotation(SocketLocation, SocketRotation);    
    
    if( (Rx_Bot(MyVehicle.Controller) != None) && (Rx_Bot(MyVehicle.Controller).GetFocus() != None) ) {
        if(class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.7) {
			MaxFinalAimAdjustment = 0.450;	
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}

simulated function SetWeaponRecoil() {
	DeltaPitchX = 0.0;	
	recoiltime = 1.2;
	bWasNegativeRecoil = false;
	bWasPositiveRecoilSecondTime = false;
	RandRecoilIncrease = Rand(4);
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local float DeltaPitch;
	
	if(recoiltime > 0) {
		recoiltime -= Deltatime;
		DeltaPitchXOld = DeltaPitchX;
		DeltaPitchX += (Deltatime*(20.0-RandRecoilIncrease/2.0));
		DeltaPitch = (5.0+RandRecoilIncrease)*sin(DeltaPitchX);

		if(DeltaPitch>0) {		
			if(bWasNegativeRecoil) {
				bWasPositiveRecoilSecondTime = true;
				return;
			} else {
				DeltaPitch = Deltapitch;
			}
		}
		if(DeltaPitch<0) {
			if(bWasPositiveRecoilSecondTime) {
				return;
			}
			bWasNegativeRecoil = true;
			DeltaPitch = Deltapitch;	
		}
		out_DeltaRot.Pitch += DeltaPitch;
		//loginternal("DeltaPitchX"$DeltaPitchX-DeltaPitchXOld);
		//loginternal("DeltaPitch"$DeltaPitch);
	}
}

DefaultProperties
{
    InventoryGroup=16

    // reload config
    ClipSize = 6
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
    
    ReloadTime(0) = 3.5
    ReloadTime(1) = 3.5
	
	RecoilImpulse = -0.5f
	
	CloseRangeAimAdjustRange = 600    
    
    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
  
    // gun config
    FireTriggerTags(0)="TurretFire02"
    FireTriggerTags(1)="TurretFire03"
    FireTriggerTags(2)="TurretFire04"
    FireTriggerTags(3)="TurretFire05"
    FireTriggerTags(4)="TurretFire06"
    FireTriggerTags(5)="TurretFire07"
    FireTriggerTags(6)="TurretFire08"
    FireTriggerTags(7)="TurretFire09"
    FireTriggerTags(8)="TurretFire10"
    FireTriggerTags(9)="TurretFire11"
    FireTriggerTags(10)="TurretFire12"
    FireTriggerTags(11)="TurretFire01"
    
    AltFireTriggerTags(0)="TurretFire02"
    AltFireTriggerTags(1)="TurretFire03"
    AltFireTriggerTags(2)="TurretFire04"
    AltFireTriggerTags(3)="TurretFire05"
    AltFireTriggerTags(4)="TurretFire06"
    AltFireTriggerTags(5)="TurretFire07"
    AltFireTriggerTags(6)="TurretFire08"
    AltFireTriggerTags(7)="TurretFire09"
    AltFireTriggerTags(8)="TurretFire10"
    AltFireTriggerTags(9)="TurretFire11"
    AltFireTriggerTags(10)="TurretFire12"
    AltFireTriggerTags(11)="TurretFire01"
    
    VehicleClass=Class'RenX_Game.Rx_Vehicle_MRLS'
    
    FireInterval(0)=0.33
    FireInterval(1)=0.33
    bFastRepeater=true
    
    Spread(0)=0.05
    Spread(1)=0.05
   
    WeaponFireSnd(0)     = SoundCue'RX_VH_MRLS.Sounds.MRLS_FireCue'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_MRLS_Projectile'

    WeaponFireSnd(1)     = SoundCue'RX_VH_MRLS.Sounds.MRLS_FireCue'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_MRLS_Projectile'
	
	ReloadSound(0)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
    ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
	
	WeaponDistantFireSnd=SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
    
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
    
    // AI
    bRecommendSplashDamage=True

    bTargetLockingActive = true
    bHasRecoil = true
    
    //==========================================
    // LOCKING PROPERTIES
    //==========================================
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance		 = 0.2 			// 0.5		// How many seconds to stay locked

    LockRange            = 16000
    ConsoleLockAim       = 0.9975			// 0.997000
    LockAim              = 0.9975			// 0.998000
    LockCheckTime        = 0.1			// 0.1
    LockAcquireTime      = 1.0 			// 0.7
    StayLocked           = 0.1 			// 0.1		// This does nothing    
    
}