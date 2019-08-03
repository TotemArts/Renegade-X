/*********************************************************
*
* File: Rx_Vehicle_Chinook_Weapon_GDI_Right.uc
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
class Rx_Vehicle_Chinook_Weapon_GDI_Right extends Rx_Vehicle_Chinook_Weapon_Right;

DefaultProperties
{
    // gun config
	InstantHitDamageTypes(0)=class'Rx_DmgType_Chinook_GDI'
	InstantHitDamageTypes(1)=class'Rx_DmgType_Chinook_GDI'
	VehicleClass=Class'RenX_Game.Rx_Vehicle_Chinook_GDI'
	
	BeamTemplates[0]=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI_Large'
	
	/****************************************/
	/*Veterancy*/
	/****************************************/
	
	//*X (Applied to instant-hits only) Modify Projectiles separately
	Vet_DamageModifier(0)=1  //Normal
	Vet_DamageModifier(1)=1.10  //Veteran
	Vet_DamageModifier(2)=1.25  //Elite
	Vet_DamageModifier(3)=1.50  //Heroic
	
	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ROFModifier(0) = 1 //Normal
	Vet_ROFModifier(1) = 1  //Veteran
	Vet_ROFModifier(2) = 1  //Elite
	Vet_ROFModifier(3) = 1  //Heroic
 
	//+X
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=25 //Elite
	Vet_ClipSizeModifier(3)=50 //Heroic

	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=1 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.75 //Heroic
	
	
	/********************************/
/*
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_Chinook_Projectile_GDI'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_Chinook_Projectile_GDI'
*/
}
