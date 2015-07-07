/*********************************************************
*
* File: TS_Vehicle_Buggy_Weapon.uc
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
class TS_Vehicle_Buggy_Weapon extends Rx_Vehicle_Weapon_Reloadable;

DefaultProperties
{
    InventoryGroup=4
    
    // reload config
    ClipSize = 50
    InitalNumClips = 999
    MaxClips = 999

    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 2.0
    ReloadTime(1) = 2.0

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"

    ReloadSound(0)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Gun'
    ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Gun'
	
	CrosshairWidth = 180 	// 256
	CrosshairHeight = 180 	// 256
	
    // gun config
    FireTriggerTags(0)="FireRight"
	FireTriggerTags(1)="FireLeft"
    AltFireTriggerTags(0)="FireRight"
	AltFireTriggerTags(2)="FireLeft"
    VehicleClass=Class'RenX_Game.TS_Vehicle_Buggy'

    FireInterval(0)=0.12
    FireInterval(1)=0.12
    bFastRepeater=true
 
    Spread(0)=0.01
    Spread(1)=0.01
	
	RecoilImpulse = -0.01f
 
    WeaponFireSnd(0)     = none //SoundCue'RX_VH_Buggy.Sounds.SC_Buggy_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'TS_Vehicle_Buggy_Gun'
    WeaponFireSnd(1)     = none //SoundCue'RX_VH_Buggy.Sounds.SC_Buggy_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'TS_Vehicle_Buggy_Gun'
    // AI
    bRecommendSplashDamage=False
}
