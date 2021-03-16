class S_Vehicle_APC extends Rx_Vehicle_APC_Nod //_Treaded
    placeable;

DefaultProperties
{
    Seats(0)={(GunClass=class'S_Vehicle_APC_Weapon',
                GunSocket=(Fire01),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraBaseOffset=(Z=-30),
                CameraOffset=-350,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}

    Begin Object name=SVehicleMesh
        Materials[0]=MaterialInstanceConstant'S_VehicleCamos.Materials.MI_VH_Nod_APC'
        Materials[2]=MaterialInstanceConstant'S_VehicleCamos.Materials.MI_VH_Gun'
    End Object
}