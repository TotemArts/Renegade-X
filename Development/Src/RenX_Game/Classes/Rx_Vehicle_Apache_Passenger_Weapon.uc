/*********************************************************
*
* File: Rx_Vehicle_Apache_Passenger_Weapon.uc
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
class Rx_Vehicle_Apache_Passenger_Weapon extends Rx_Vehicle_Weapon_Reloadable;


DefaultProperties
{
    InventoryGroup=18
    
    // reload config
    ClipSize = 1
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
     
    ReloadTime(0) = 5.0
    ReloadTime(1) = 5.0
    
    FireInterval(0)=1.0
    FireInterval(1)=1.0
    
    Spread(0)=0.02
    Spread(1)=0.02
 
    // gun config
    FireTriggerTags(0)="HellFire_Left"
	FireTriggerTags(1)="HellFire_Right"
	
	AltFireTriggerTags(0)="HellFire_Left"
	AltFireTriggerTags(1)="HellFire_Right"

   
    VehicleClass=Class'RenX_Game.Rx_Vehicle_Apache'

    WeaponFireSnd(0)     = SoundCue'RX_VH_Apache.Sounds.SC_Apache_Missile'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_Apache_GuidedMissile'
    WeaponFireSnd(1)     = SoundCue'RX_VH_Apache.Sounds.SC_Apache_Missile'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_Apache_GuidedMissile'

}
