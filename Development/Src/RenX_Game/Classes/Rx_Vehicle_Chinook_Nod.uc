/*********************************************************
*
* File: Rx_Vehicle_Chinook_Nod.uc
* Author: RenegadeX-Team
* Poject: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_Chinook_Nod extends Rx_Vehicle_Chinook
    placeable;


defaultproperties
{


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

    Begin Object name=SVehicleMesh
		AnimTreeTemplate=AnimTree'RX_VH_Chinook.Anims.AT_VH_Chinook_Nod'
        Materials(0)=MaterialInstanceConstant'RX_VH_Chinook.Materials.MI_VH_Chinook_Nod'
    End Object
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_Chinook.Mesh.SK_PTVH_Chinook_Nod'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\

    Seats(0)={( GunClass=None,
                CameraTag=CamView3P,
                CameraBaseOffset=(X=0, Z=0),
                CameraOffset=-800, //-700,
                bSeatVisible=true,
                SeatBone=MT_F,
                SeatOffset=(X=-75,Y=-27,Z=-3),
                SeatRotation=(Pitch=0,Yaw=0),
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=None
                )}

    Seats(1)={( GunClass=class'Rx_Vehicle_Chinook_Weapon_Nod_Left',
				TurretVarPrefix="GunnerLeft",
                GunSocket=(Fire_Left),
                TurretControls=(TurretPitch_Left,TurretRotate_Left),
                GunPivotPoints=(CGL_Yaw),
                CameraTag=CGL_ViewSocket,
                CameraBaseOffset=(Z=10),
                CameraOffset=-20,
                CameraEyeHeight=0,
                ViewPitchMin=0,
                ViewPitchMax=0,
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}

    Seats(2)={( GunClass=class'Rx_Vehicle_Chinook_Weapon_Nod_Right',
				TurretVarPrefix="GunnerRight",
                GunSocket=(Fire_Right),
                TurretControls=(TurretPitch_Right,TurretRotate_Right),
                GunPivotPoints=(CGR_Yaw),
                CameraTag=CGR_ViewSocket,
                CameraBaseOffset=(Z=10),
                CameraOffset=-20,
                CameraEyeHeight=0,
                ViewPitchMin=0,
                ViewPitchMax=0,
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}
				
	Seats(3)={( CameraTag=CamView3P,
				TurretVarPrefix="Passenger1",
                CameraBaseOffset=(X=0, Z=0),
                CameraOffset=-800, //-700,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=None
                )}
				
	Seats(4)={( CameraTag=CamView3P,
				TurretVarPrefix="Passenger2",
                CameraBaseOffset=(X=0, Z=0),
                CameraOffset=-800, //-700,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=None
                )}
         
            
//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

}
