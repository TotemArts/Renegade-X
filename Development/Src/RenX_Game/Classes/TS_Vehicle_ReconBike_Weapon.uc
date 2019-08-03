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

simulated event bool IsAimCorrect()
{
//Always return true since we cannot rely on the unrotateable turret
    return true;    
}

//OVERRIDE FOR BOT

simulated function SetRocketTarget(Rx_Projectile_Rocket Rocket)
{
    local vector CameraLocation, HitLocation, HitNormal, DesiredAimPoint;
    local rotator CameraRotation;   
    local Controller C;
    local Rx_Bot B;
    
    if (bLockedOnTarget && (!SecondaryLockingDisabled || CurrentFireMode != 1 || AIController(UTVehicle(Owner).Controller) != None ))
    {
        Rocket.SeekTarget = LockedTarget;
        Rocket.GotoState('Homing');
    }
    else
    {
        //Rocket.Target = GetDesiredAimPoint() // The Trace in GetDesiredAimPoint() sometimes wasent accurate enough in all situations and has been modified below
        
        C = (MyVehicle != None) ? MyVehicle.Seats[SeatIndex].SeatPawn.Controller : None;
        B = (Rx_Bot(C) != None) ? Rx_Bot(C) : None;
        if(PlayerController(C) != None)
        {
            PlayerController(Instigator.Controller).GetPlayerViewPoint(CameraLocation, CameraRotation);
            
            if(Rx_Controller(Instigator.Controller).bBehindView && Rx_Controller(Instigator.Controller).ViewTarget != none) CameraLocation = CameraLocation + vector(CameraRotation) * VSize(CameraLocation - MyVehicle.GetEffectLocation(SeatIndex) );//Rx_Controller(Instigator.Controller).ViewTarget.location); //Again, the camera is capable of getting stuck in both geometry and behind vehicles. Scan up closer to the actual vehicle so we don't shoot behind ourselves.
            //`log(VSize(CameraLocation -  MyVehicle.GetEffectLocation(SeatIndex)));//Rx_Controller(Instigator.Controller).ViewTarget.location));
            DesiredAimPoint = CameraLocation + Vector(CameraRotation) * GetTraceRange(); 
            if (GetTraceOwner().Trace(HitLocation, HitNormal, DesiredAimPoint, CameraLocation, true, vect(0,0,0),,TRACEFLAG_Bullet) != None)
            {
                DesiredAimPoint = HitLocation;
            }
        }
        else if ( C != None )
        {
            if (B != None)
            {
                DesiredAimPoint = GetRocketTarget(B);
            }
            else
                DesiredAimPoint = C.GetFocalPoint();
        }   
        Rocket.Target = DesiredAimPoint;    
        
        Rocket.GotoState('Homing');
    }
}

function Vector GetRocketTarget(Rx_Bot B)
{
    if(Pawn(B.Focus) != None && B.Focus == B.Enemy)   // to avoid aimbotting bot (lol) we will cause the target to miss the mark slightly 
    {
        if(B.Skill > 6)
            return B.Focus.Location + (VRand() * 10);
        else
            return B.Focus.Location + (VRand() * (20 + ((B.Skill - 6)) * 40));

    }
    else
        return B.Focus.Location;
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

    WeaponFireSnd(0)     = SoundCue'TS_VH_ReconBike.Sounds.SC_Missile_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'TS_Vehicle_ReconBike_Projectile'
    WeaponFireSnd(1)     = SoundCue'TS_VH_ReconBike.Sounds.SC_Missile_Fire'
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
	
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
	Vet_ClipSizeModifier(1)=2 //Veteran 
	Vet_ClipSizeModifier(2)=4 //Elite
	Vet_ClipSizeModifier(3)=6 //Heroic


	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic

    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True
    bOkAgainstBuildings = True

}
