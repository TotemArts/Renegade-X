/*********************************************************
*
* File: Rx_Vehicle_Hovercraft_GDI_Weapon.uc
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
class Rx_Vehicle_Hovercraft_GDI_Weapon extends Rx_Vehicle_MultiWeapon;

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


simulated function GetFireStartLocationAndRotation(out vector SocketLocation, out rotator SocketRotation) {
    
    super.GetFireStartLocationAndRotation(SocketLocation, SocketRotation);    
    
    if( (Rx_Bot(MyVehicle.Controller) != None) && (Rx_Bot(MyVehicle.Controller).GetFocus() != None) ) {
        if(class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.7) {
    		if(VSizeSq(Rx_Bot(MyVehicle.Controller).GetFocus().location - MyVehicle.location) < Square(CloseRangeAimAdjustRange))
    			MaxFinalAimAdjustment = 0.450;	
			else            
            	MaxFinalAimAdjustment = 0.990;
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}

simulated function SetWeaponRecoil() {
	DeltaPitchX = 0.0;
	recoiltime = 1.6;
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
		DeltaPitchX += (Deltatime*(10.0-RandRecoilIncrease/2.0));
		DeltaPitch = (20.0+RandRecoilIncrease)*sin(DeltaPitchX);

		if(DeltaPitch>0) {		
			if(bWasNegativeRecoil) {
				DeltaPitch = DeltaPitch*2.4;
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
	InventoryGroup=11
	
	SecondaryLockingDisabled=false
    
    ClipSize(0) = 24
    ClipSize(1) = 8

    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 8.0
    ReloadTime(1) = 8.0
    
    FireInterval(0)=0.25
    FireInterval(1)=0.15
    bFastRepeater = false
    
    Spread(0)=0.0025
    Spread(1)=0.6
    
	CloseRangeAimAdjustRange = 600  
 
    // gun config
    FireTriggerTags(0)="FireCannonR"
	FireTriggerTags(1)="FireCannonL"
   
    AltFireTriggerTags(0)="FireR"
	AltFireTriggerTags(1)="FireL"
	
	RecoilImpulse = -0.0f
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
   
    VehicleClass=Class'RenX_Game.Rx_Vehicle_HoverCraft_GDI'

    WeaponFireSnd(0)     = SoundCue'RX_VH_HoverCraft.Sounds.SC_Hovercraft_CannonFire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_HoverCraft_Cannon'
    WeaponFireSnd(1)     = SoundCue'RX_VH_HoverCraft.Sounds.SC_Hovercraft_Missile'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_HoverCraft_Rockets'
	
	WeaponDistantFireSnd(0)=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_DistantFire'
	WeaponDistantFireSnd(1)=SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
	  
    //==========================================
    // LOCKING PROPERTIES
    //==========================================
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance		 = 0.6 			// 0.5		// How many seconds to stay locked

    LockRange            = 10
    ConsoleLockAim       = 0.997		// 0.997000
    LockAim              = 1.0			// 0.998000
    LockCheckTime        = 0.1			// 0.1
    LockAcquireTime      = 0.25 			// 0.7
    StayLocked           = 0.1 			// 0.1		// This does nothing    

    
     // AI
    bRecommendSplashDamage = True
    bTargetLockingActive = true

    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True
    bOkAgainstBuildings = True

}
