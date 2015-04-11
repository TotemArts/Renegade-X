/*********************************************************
*
* File: Rx_Vehicle_Chinook_Weapon_GDI_Left.uc
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
class Rx_Vehicle_Chinook_Weapon_GDI_Left extends Rx_Vehicle_Chinook_Weapon_Left;

DefaultProperties
{
    // gun config
	InstantHitDamageTypes(0)=class'Rx_DmgType_Chinook_GDI'
	InstantHitDamageTypes(1)=class'Rx_DmgType_Chinook_GDI'
	
	BeamTemplates[0]=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI_Large'
/*
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_Chinook_Projectile_GDI'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_Chinook_Projectile_GDI'
*/
}
