class S_Vehicle_Buggy extends Rx_Vehicle_Buggy
    placeable;

DefaultProperties
{
    Seats(0)={(GunClass=class'S_Vehicle_Buggy_Weapon',
                GunSocket=(Fire_01),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw),
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-20),
                CameraOffset=-400,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}

    Begin Object name=SVehicleMesh
        Materials[0]=MaterialInstanceConstant'S_VehicleCamos.Materials.MI_VH_Buggy'
        Materials[2]=MaterialInstanceConstant'S_VehicleCamos.Materials.MI_VH_Gun'
    End Object
}