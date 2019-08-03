/*********************************************************
*
* File: Rx_Vehicle_Artillery_B.uc
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
class Rx_Vehicle_Artillery_B extends Rx_Vehicle_Artillery
    placeable;
	
/** These values are used in positioning the weapons */
var repnotify	rotator	GunnerWeaponRotation;
var	repnotify	vector	GunnerFlashLocation;
var	repnotify	byte	GunnerFlashCount;
var repnotify	byte	GunnerFiringMode;
	
replication
{
	if (bNetDirty)
		GunnerFlashLocation;
	if (!IsSeatControllerReplicationViewer(1) || bDemoRecording)
		GunnerFlashCount, GunnerFiringMode, GunnerWeaponRotation;
}

/**
 *	Because WeaponRotation is used to drive seat 1 - it will be replicated when you are in the big turret because bNetOwner is FALSE.
 *	We don't want it replicated though, so we discard it when we receive it.
 */
simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'WeaponRotation' && Seats[0].SeatPawn != None && Seats[1].SeatPawn.Controller != None )
	{
		return;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}


DefaultProperties
{

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\

	bHasAlternateTargetLocation=true
	
	TurretExplosiveForce=2000
	
    Seats(0)={(GunClass=class'Rx_Vehicle_Artillery_Weapon_B',
                GunSocket=(Fire01),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
				TurretVarPrefix="Gunner",
                CameraTag=CamView3P,
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-600,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-600,
                )}
}