/*********************************************************
*
* File: Rx_Vehicle_LightWeapon.uc
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
class Rx_Vehicle_LightTank_Weapon extends Rx_Vehicle_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

DefaultProperties
{
    InventoryGroup=13
    
    // reload config
    ClipSize = 1
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
     
    bReloadAfterEveryShot = true
    ReloadTime(0) = 0.65 //0.75 //Closer to Med DPS at 0.65 
    ReloadTime(1) = 0.65 //0.75

    ReloadSound(0)=SoundCue'RX_VH_LightTank.Sounds.SC_LightTank_Reload'
    ReloadSound(1)=SoundCue'RX_VH_LightTank.Sounds.SC_LightTank_Reload'

	
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
	Vet_ClipSizeModifier(2)=0 //Elite
	Vet_ClipSizeModifier(3)=0 //Heroic

	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	
	
	
	/********************************/
    // gun config
    FireTriggerTags(0)="MainGun"
    AltFireTriggerTags(0)="MainGun"
    VehicleClass=Class'RenX_Game.Rx_Vehicle_LightTank'

    FireInterval(0)=1.5
    FireInterval(1)=1.5

    Spread(0)=0.0025000
    Spread(1)=0.0025000
	
	RecoilImpulse = -0.2f //-0.3f
	bHasRecoil = true
	bCheckIfBarrelInsideWorldGeomBeforeFiring = true

    WeaponFireSnd(0)     = SoundCue'RX_VH_LightTank.Sounds.SC_LightTank_Fire_1P'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_LightTank_Projectile'
    WeaponFireSnd(1)     = SoundCue'RX_VH_LightTank.Sounds.SC_LightTank_Fire_1P'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_LightTank_Projectile'
	
	WeaponProjectiles_Heroic(0)= Class'Rx_Vehicle_LightTank_Projectile_Heroic'
	WeaponProjectiles_Heroic(1)= Class'Rx_Vehicle_LightTank_Projectile_Heroic'
	
	WeaponFireSounds_Heroic(0)=SoundCue'RX_VH_LightTank.Sounds.SC_LightTank_Fire_1P_Heroic'
	WeaponFireSounds_Heroic(1)=SoundCue'RX_VH_LightTank.Sounds.SC_LightTank_Fire_1P_Heroic'
	
	
	WeaponDistantFireSnd=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_DistantFire'
   
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'

    // AI
    bRecommendSplashDamage=True
    bOkAgainstLightVehicles = True
	bOkAgainstArmoredVehicles = True
	bOkAgainstBuildings = True
	
	FM0_ROFTurnover = 2; //9 for most automatics. Single shot weapons should be more, except the shotgun
	CloseRangeAimAdjustRange=600
}
