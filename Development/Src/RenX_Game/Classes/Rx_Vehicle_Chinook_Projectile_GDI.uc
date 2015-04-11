/*********************************************************
*
* File: Rx_Vehicle_Chinook_Projectile_GDI.uc
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
class Rx_Vehicle_Chinook_Projectile_GDI extends Rx_Vehicle_Chinook_Projectile;


DefaultProperties
{
    ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Bullets.P_Bullet_GDI'
    
    MyDamageType=Class'Rx_DmgType_Chinook_GDI'
    
    ProjectileLightClass=class'Rx_Light_Bullet_GDI'
}
