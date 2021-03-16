/*********************************************************
*
* File: Rx_Vehicle_MRLS_Projectile_Unguided.uc
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
class Rx_Vehicle_MRLS_Projectile_Unguided extends Rx_Vehicle_MRLS_Projectile;

DefaultProperties
{
	
	AccelRate=300
   
	LockWarningInterval			= 1.5
	BaseTrackingStrength		= 12.0 //6.0 //5.0 //2.0 		// 0.7 //Without a target 
	HomingTrackingStrength		= 12.0 //6.0 //6.0 		// 0.7 //With a target

	RocketStages(0) = (Stage_AccelRate = 300, Stage_HomingStrength = 36.0, Stage_BaseTrackingStrength = 36.0, Stage_MaxSpeed = 3000, Stage_Time = 0.5) ; 
	RocketStages(1) = (Stage_AccelRate = 0, Stage_HomingStrength = 0.0, Stage_BaseTrackingStrength = 0.0, Stage_MaxSpeed = 3000, bSeekFinalTarget = true) ;
}
