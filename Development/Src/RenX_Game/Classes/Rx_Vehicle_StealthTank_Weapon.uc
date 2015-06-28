/*********************************************************
*
* File: Rx_Vehicle_StealthTank_Weapon.uc
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
class Rx_Vehicle_StealthTank_Weapon extends Rx_Vehicle_Weapon_Reloadable;


var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)
//	var int      MissileRecoilCount;
//	var int 	 i;


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
        if(class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.6) {
			MaxFinalAimAdjustment = 0.450;	
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}

/**
simulated function SetWeaponRecoil() {
	DeltaPitchX = 0.0;
	if(recoiltime > 0) {
		MissileRecoilCount += 2;
	} else {
        MissileRecoilCount = 0;
	}
	recoiltime = 1.2;
	bWasNegativeRecoil = false;
	bWasPositiveRecoilSecondTime = false;
	RandRecoilIncrease = Rand(2);
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local float DeltaPitch;
	
	if(recoiltime > 0) {
		recoiltime -= Deltatime;
		DeltaPitchXOld = DeltaPitchX;
		DeltaPitchX += (Deltatime*(20.0-MissileRecoilCount-RandRecoilIncrease/2.0));
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
			if(MissileRecoilCount > 0) {	
				DeltaPitch = Deltapitch*1.8;	
			}
		}
		if(DeltaPitch > 1.5 || DeltaPitch < -1.5)
			out_DeltaRot.Pitch += DeltaPitch*2.0;
		//loginternal("DeltaPitchX"$DeltaPitchX-DeltaPitchXOld);
		//loginternal("DeltaPitch"$DeltaPitch);
	}
}

simulated function rotator AddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float CurrentSpread, RandY, RandZ;

	CurrentSpread = Spread[CurrentFireMode];
	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		//RandY = FRand() - 0.5;
		//RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		
		if(i++ == 0)
			RandY = -0.4;
		else
			RandY = 0.4;
		if(i > 1)
			i = 0;	
		RandZ = 0.1;
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}
*/

DefaultProperties
{
    InventoryGroup=17

    // reload config
    ClipSize = 2
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
    
    ReloadTime(0) = 1.5
    ReloadTime(1) = 1.5
    
	CloseRangeAimAdjustRange = 600    
    
    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
 
    // gun config
    FireTriggerTags(0) = "TurretFireRight"
    FireTriggerTags(1) = "TurretFireLeft"
    AltFireTriggerTags(0) = "TurretFireRight"
    AltFireTriggerTags(1) = "TurretFireLeft"
    VehicleClass=Class'RenX_Game.Rx_Vehicle_StealthTank'

    FireInterval(0)=0.15
    FireInterval(1)=0.15
    bFastRepeater=true

    Spread(0)=0.03
    Spread(1)=0.03

    WeaponFireSnd(0)     = SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_StealthTank_Projectile'
    WeaponFireSnd(1)     = SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_StealthTank_Projectile'
	
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

    LockRange            = 4500
    ConsoleLockAim       = 0.997			// 0.997000
    LockAim              = 0.997			// 0.998000
    LockCheckTime        = 0.1			// 0.1
    LockAcquireTime      = 0.5 			// 0.7
    StayLocked           = 0.1 			// 0.1		// This does nothing

    bTargetLockingActive = true
    bHasRecoil = true
    bIgnoreDownwardPitch = true
    bCheckIfFireStartLocInsideOtherVehicle = true
}
