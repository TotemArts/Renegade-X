/*********************************************************
*
* File: Rx_Vehicle_Artillery_Projectile_Arc.uc
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
class Rx_Vehicle_Artillery_Projectile_Arc_B extends Rx_Vehicle_Artillery_Projectile;


DefaultProperties
{

    bRotationFollowsVelocity=true
	bProjTarget=true
	bNetTemporary=false
    Physics=PHYS_Falling

	Speed=5000
    MaxSpeed=5000
    TerminalVelocity=5000.0

    LifeSpan=20.0
}
