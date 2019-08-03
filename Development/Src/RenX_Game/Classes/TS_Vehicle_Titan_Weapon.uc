/*********************************************************
*
* File: TS_Vehicle_Titan_Weapon.uc
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
class TS_Vehicle_Titan_Weapon extends Rx_Vehicle_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

DefaultProperties
{
    InventoryGroup=15
    
    // reload config
    ClipSize = 1
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
     
    bReloadAfterEveryShot = true
    ReloadTime(0) = 0.75
    ReloadTime(1) = 0.75

    ReloadSound(0)=SoundCue'TS_VH_Titan.Sounds.SC_Reload'
    ReloadSound(1)=SoundCue'TS_VH_Titan.Sounds.SC_Reload'

    // gun config
    FireTriggerTags(0)="MainGun"
    AltFireTriggerTags(0)="MainGun"
    VehicleClass=Class'TS_Vehicle_Titan'

    FireInterval(0)=1.5
    FireInterval(1)=1.5
    
    Spread(0)=0.0025000
    Spread(1)=0.0025000
	
	RecoilImpulse = -0.0f
	bHasRecoil = true
	bCheckIfBarrelInsideWorldGeomBeforeFiring = true
	

	WeaponFireSnd(0)     = SoundCue'TS_VH_Titan.Sounds.SC_Cannon_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'TS_Vehicle_Titan_Cannon'
    WeaponFireSnd(1)     = SoundCue'TS_VH_Titan.Sounds.SC_Cannon_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'TS_Vehicle_Titan_Cannon'
    
	WeaponDistantFireSnd=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_DistantFire'
  
    //CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5'
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
    

    // AI
    bRecommendSplashDamage=True
	
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=0 //Elite
	Vet_ClipSizeModifier(3)=0 //Heroic


	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	
    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True
    bOkAgainstBuildings = True
}
