/*********************************************************
*
* File: Rx_Vehicle_Harvester_Weapon.uc
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
class Rx_Vehicle_Harvester_Weapon extends Rx_Vehicle_Weapon_Reloadable;

DefaultProperties
{
    InventoryGroup=10
    
    // reload config
    ClipSize = 1
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
     
    ReloadTime(0) = 1.0
    ReloadTime(1) = 1.0

    FireTriggerTags(0)="MainGun"
    AltFireTriggerTags(0)="MainGun"
    VehicleClass=Class'RenX_Game.Rx_Vehicle_Harvester'

    FireInterval(0)=1.0
    FireInterval(1)=1.0

    Spread(0)=0.00
    Spread(1)=0.00
  
//  WeaponFireSnd(0)     = SoundCue'RX_VH_APC_Nod.Sounds.SC_APC_Fire'
    WeaponFireTypes(0)   = EWFT_None
//  WeaponFireSnd(1)     = SoundCue'RX_VH_APC_Nod.Sounds.SC_APC_Fire'
    WeaponFireTypes(1)   = EWFT_None
//  WeaponProjectiles(1) = Class'Rx_Vehicle_APC_Nod_Projectile'
    // AI
    bRecommendSplashDamage=False
}
