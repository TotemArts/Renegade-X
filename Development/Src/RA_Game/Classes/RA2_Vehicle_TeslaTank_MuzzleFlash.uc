/*********************************************************
*
* File: RA2_Vehicle_TeslaTank_MuzzleFlash.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class RA2_Vehicle_TeslaTank_MuzzleFlash extends UDKExplosionLight;

DefaultProperties
{
	HighDetailFrameTime=+0.02
	Brightness=5
	Radius=1024
	LightColor=(R=89,G=156,B=255,A=255)
	TimeShift=((StartTime=0.2,Radius=1024,Brightness=20,LightColor=(R=180,G=156,B=255,A=255)),(StartTime=0.3,Radius=1024,Brightness=0,LightColor=(R=189,G=156,B=255,A=255)))
}
