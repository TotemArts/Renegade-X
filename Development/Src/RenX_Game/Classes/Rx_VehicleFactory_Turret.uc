/*********************************************************
*
* File: Rx_VehicleFactory_Turret.uc
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
class Rx_VehicleFactory_Turret extends UTVehicleFactory;

DefaultProperties
{
    Begin Object Name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_DEF_Turret.Mesh.SK_DEF_Turret'
    End Object

    Components.Remove(Sprite)

    Begin Object Name=CollisionCylinder
        CollisionHeight=+120.0
        CollisionRadius=+128.0
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

    VehicleClassPath="RenX_Game.Rx_Defence_Turret"
    DrawScale=1.0
}
