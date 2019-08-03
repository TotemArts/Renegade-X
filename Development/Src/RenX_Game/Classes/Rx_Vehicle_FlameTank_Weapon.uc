/*********************************************************
*
* File: Rx_Vehicle_FlameTank_Weapon.uc
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
class Rx_Vehicle_FlameTank_Weapon extends Rx_Vehicle_Weapon;

simulated function GetFireStartLocationAndRotation(out vector SocketLocation, out rotator SocketRotation) {
    
    super.GetFireStartLocationAndRotation(SocketLocation, SocketRotation);    
    
    if( (Rx_Bot(MyVehicle.Controller) != None) && (Rx_Bot(MyVehicle.Controller).GetFocus() != None) ) {
        if(class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.9) {
			MaxFinalAimAdjustment = 0.450;	
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}



simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return true;
}

DefaultProperties
{
    InventoryGroup=7

    // gun config
    FireTriggerTags(0)="FlameLeft"
    FireTriggerTags(1)="FlameRight"
    AltFireTriggerTags(0)="FlameLeft"
    AltFireTriggerTags(1)="FlameRight"
    VehicleClass=Class'Rx_Vehicle_FlameTank'
	bCheckIfBarrelInsideWorldGeomBeforeFiring=true 
	
    FireInterval(0)=0.05
    FireInterval(1)=0.05
    bFastRepeater=true
	
	
    Spread(0)=0.0
    Spread(1)=0.0
	
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
	Vet_ROFModifier(1) = 0.95  //Veteran
	Vet_ROFModifier(2) = 0.90  //Elite
	Vet_ROFModifier(3) = 0.85  //Heroic
	
	
	/********************************/
	
	RecoilImpulse = -0.0f
    
	CloseRangeAimAdjustRange = 800    

    WeaponFireSnd(0)     = none
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_FlameTank_Projectile'
    WeaponFireSnd(1)     = none
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_FlameTank_Projectile'
  
	WeaponProjectiles_Heroic(0)= Class'Rx_Vehicle_FlameTank_Projectile_Heroic'
	WeaponProjectiles_Heroic(1)= Class'Rx_Vehicle_FlameTank_Projectile_Heroic'
  
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'

    // AI
    bRecommendSplashDamage=false
    bIgnoreDownwardPitch = true

    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True
    bOkAgainstBuildings = True
}
