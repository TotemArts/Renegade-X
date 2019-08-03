
class Rx_Vehicle_MammothWeapon extends Rx_Vehicle_MultiWeapon;


var	SoundCue WeaponDistantFireSnd[2];	// A second firing sound to be played when weapon fires. (Used for distant sound)
var int MissileRecoilCount;


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
        //Dist = VSize(Rx_Bot(MyVehicle.Controller).GetFocus().location - MyVehicle.location);
    	if(CloseRangeAimAdjustRange != 0.0 
        		&& class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.9) {
        			MaxFinalAimAdjustment = 0.450;	
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}

simulated function SetWeaponRecoil() {
	DeltaPitchX = 0.0;
	if(CurrentFireMode == 0) {
		recoiltime = 1.2;
		bWasNegativeRecoil = false;
		bWasPositiveRecoilSecondTime = false;
		RandRecoilIncrease = Rand(10);
	} else {
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
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local float DeltaPitch;
	
	if(recoiltime > 0) {
		recoiltime -= Deltatime;
		DeltaPitchXOld = DeltaPitchX;
		if(CurrentFireMode == 0) {
			DeltaPitchX += (Deltatime*(30.0-RandRecoilIncrease/2.0));
			DeltaPitch = (10.0+RandRecoilIncrease)*sin(DeltaPitchX);
		} else {
			DeltaPitchX += (Deltatime*(20.0-MissileRecoilCount-RandRecoilIncrease/2.0));
			DeltaPitch = (5.0+RandRecoilIncrease)*sin(DeltaPitchX);
		}

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
		}
		out_DeltaRot.Pitch += DeltaPitch;
		//loginternal("DeltaPitchX"$DeltaPitchX-DeltaPitchXOld);
		//loginternal("DeltaPitch"$DeltaPitch);
	}
}



DefaultProperties
{
    InventoryGroup=14
    
    SecondaryLockingDisabled=false
    
    ClipSize(0) = 2
    ClipSize(1) = 4//4

    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 3.25// 3.0 2.0
    ReloadTime(1) = 6.0
    
    FireInterval(0)= 0.25//0.5//0.25
    FireInterval(1)=0.15
    bFastRepeater = true
    
    Spread(0)=0.0025
    Spread(1)=0.15
	
	RecoilImpulse = -1.0f
    
	CloseRangeAimAdjustRange = 600  
	bCheckIfBarrelInsideWorldGeomBeforeFiring = true  
 
    // gun config
    FireTriggerTags(0)="PrimaryFire_Right"
    FireTriggerTags(1)="PrimaryFire_Left"
   
    AltFireTriggerTags(1)="MissileFire01"
    AltFireTriggerTags(2)="MissileFire02"
    AltFireTriggerTags(3)="MissileFire03"
    AltFireTriggerTags(4)="MissileFire04"
    AltFireTriggerTags(5)="MissileFire05"
    AltFireTriggerTags(6)="MissileFire06"
    AltFireTriggerTags(7)="MissileFire07"
    AltFireTriggerTags(8)="MissileFire08"
    AltFireTriggerTags(9)="MissileFire09"
    AltFireTriggerTags(10)="MissileFire10"
    AltFireTriggerTags(11)="MissileFire11"
    AltFireTriggerTags(0)="MissileFire12"
   
    VehicleClass=Class'Rx_Vehicle_MammothTank'

    WeaponFireSnd(0)     = SoundCue'RX_VH_MammothTank.Sounds.Mammoth_FireCue'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_MammothProjectile'
    WeaponFireSnd(1)     = SoundCue'RX_VH_MammothTank.Sounds.Mammoth_Missile_FireCue'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_MammothProjectile_Missile'
	
	WeaponDistantFireSnd(0)=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_DistantFire'
	WeaponDistantFireSnd(1)=SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
	
	WeaponProjectiles_Heroic(0)= Class'Rx_Vehicle_MammothProjectile_Heroic'
	WeaponProjectiles_Heroic(1)= Class'Rx_Vehicle_MammothProjectile_Missile_Heroic'
 
	WeaponFireSounds_Heroic(0)=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_FireCue_Heroic'
	WeaponFireSounds_Heroic(1)=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_Missile_FireCue_Heroic'
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
    
     // AI
    bRecommendSplashDamage=True

    //==========================================
    // LOCKING PROPERTIES
    //==========================================
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance		 = 0.2 			// 0.5		// How many seconds to stay locked

    LockRange            = 7500 		// 6100
    ConsoleLockAim       = 0.997			// 0.997000
    LockAim              = 0.997			// 0.998000
    LockCheckTime        = 0.1			// 0.1
    LockAcquireTime      = 0.5 			// 0.7

    bTargetLockingActive = true
    bHasRecoil = true
	
/***********************/
/*Veterancy*/
/**********************/
Vet_ClipSizeModifier(0)=0 //Normal +X
Vet_ClipSizeModifier(1)=0 //Veteran 
Vet_ClipSizeModifier(2)=0 //Elite
Vet_ClipSizeModifier(3)=0 //Heroic


Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
Vet_ReloadSpeedModifier(2)=0.90 //Elite
Vet_ReloadSpeedModifier(3)=0.85 //Heroic

Vet_SecondaryClipSizeModifier(0)=0 //Normal +X
Vet_SecondaryClipSizeModifier(1)=0 //Veteran 
Vet_SecondaryClipSizeModifier(2)=0 //Elite
Vet_SecondaryClipSizeModifier(3)=2 //Heroic


Vet_SecondaryReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_SecondaryReloadSpeedModifier(1)=0.95 //Veteran 
Vet_SecondaryReloadSpeedModifier(2)=0.9 //Elite
Vet_SecondaryReloadSpeedModifier(3)=0.8 //Heroic

//Cannon
Vet_ROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_ROFSpeedModifier(1)=1 //Veteran 
Vet_ROFSpeedModifier(2)=1 //Elite
Vet_ROFSpeedModifier(3)=1 //Heroic

//Missiles
Vet_SecondaryROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
Vet_SecondaryROFSpeedModifier(1)=1 //Veteran 
Vet_SecondaryROFSpeedModifier(2)=1 //Elite
Vet_SecondaryROFSpeedModifier(3)=0.8 //Heroic 

/***********************************/

SF_Tolerance = 8


FM0_ROFTurnover = 2; //9 for most automatics. Single shot weapons should be more, except the shotgun
FM1_ROFTurnover = 4; 

bOkAgainstLightVehicles = True
bOkAgainstArmoredVehicles = True
bOkAgainstBuildings = True
}

