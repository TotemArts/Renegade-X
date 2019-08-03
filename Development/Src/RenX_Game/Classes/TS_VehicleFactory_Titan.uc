/*********************************************************
*
* File: TS_VehicleFactory_Titan.uc
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
class TS_VehicleFactory_Titan extends UTVehicleFactory;

DefaultProperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'TS_VH_Titan.Mesh.SK_VH_Titan_Reborn'
		Translation=(X=0.0,Y=0.0,Z=-350.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+350.0
		CollisionRadius=+200.0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
	End Object

	VehicleClassPath="RenX_Game.TS_Vehicle_Titan"
	DrawScale=1.0
}
