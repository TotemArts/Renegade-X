/*********************************************************
*
* File: Rx_Vehicle_MediumTank_Weapon.uc
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
class Rx_Vehicle_MediumTank_Weapon extends Rx_Vehicle_MultiWeapon;

var	SoundCue WeaponDistantFireSnd[2];					/* A second firing sound to be played when weapon fires. (Used for distant sound) */


simulated function FireAmmunition()
{
    Super.FireAmmunition();
	
	if( WeaponDistantFireSnd[CurrentFireMode] != None )
			WeaponPlaySound( WeaponDistantFireSnd[CurrentFireMode] );
			
	if (CurrentFireMode == 0)
	{
		RecoilImpulse = -0.03f;
	}
	if (CurrentFireMode == 1)
	{
		RecoilImpulse = 0.0;
	}
}

simulated function bool UsesClientSideProjectiles(byte CurrFireMode)
{
	return true;
}

simulated function GetFireStartLocationAndRotation(out vector SocketLocation, out rotator SocketRotation) {
    
    super.GetFireStartLocationAndRotation(SocketLocation, SocketRotation);    
    
    if( (Rx_Bot(MyVehicle.Controller) != None) && (Rx_Bot(MyVehicle.Controller).GetFocus() != None) ) {

    	if(CloseRangeAimAdjustRange != 0.0 
        		&& class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.9) {
        			MaxFinalAimAdjustment = 0.450;	
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}

simulated function SetWeaponRecoil() {
	
	DeltaPitchX = 0.0;
	if(CurrentFireMode == 0) 
	{
		super.SetWeaponRecoil();
	} 
	else 
	{
		return; //Recoil on a coaxial gun just looks weird 
	}
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local float DeltaPitch;
	
	if(recoiltime > 0) {
		recoiltime -= Deltatime;
		if(CurrentFireMode == 0) 
		{
			super.ProcessViewRotation(DeltaTime, out_ViewRotation, out_DeltaRot);
		} 
		else 
		{
			DeltaPitchX += (Deltatime*(20.0 - RandRecoilIncrease/2.0));
			DeltaPitch = (0.0+RandRecoilIncrease)*sin(DeltaPitchX);
		}

		if(DeltaPitch>0) {		
			if(bWasNegativeRecoil) {
				bWasPositiveRecoilSecondTime = true;
				return;
			} else {
				DeltaPitch = Deltapitch;
			}
		}
		if(DeltaPitch<0) {
			if(bWasPositiveRecoilSecondTime) {
				return;
			}		
			bWasNegativeRecoil = true;
		}
		out_DeltaRot.Pitch += DeltaPitch;
	}
}

simulated function SetCurrentFireMode(byte FiringModeNum)
{
	if(FiringModeNum == 0 && Rx_Vehicle_MediumTank(MyVehicle) != none)
	{
		Rx_Vehicle_MediumTank(MyVehicle).FiringAmbient.Stop();
	}
		
	super.SetCurrentFireMode(FiringModeNum);
}

DefaultProperties
{
    InventoryGroup=19
    
    ClipSize(0) = 1
	ClipSize(1) = 30
    
    ShotCost(0)=1
    ShotCost(1)=1

    ReloadTime(0) = 1.4 //Adjust for not being bReloadAfterEveryShot
	ReloadTime(1) = 3.0

    ReloadSound(0)=SoundCue'RX_VH_MediumTank.Sounds.SC_MediumTank_Reload'
    ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Gun'

    // gun config
    FireTriggerTags(0)="MainGun"
    AltFireTriggerTags(0)="AltGun"
    VehicleClass=Class'Rx_Vehicle_MediumTank'

    FireInterval(0)=0.1 
    FireInterval(1)=0.14
    
    Spread(0)=0.0025
    Spread(1)=0.01
	
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
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	
	Vet_SecondaryClipSizeModifier(0)=0 //Normal +X
	Vet_SecondaryClipSizeModifier(1)=10 //Veteran 
	Vet_SecondaryClipSizeModifier(2)=25 //Elite
	Vet_SecondaryClipSizeModifier(3)=50 //Heroic
	
	Vet_SecondaryReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
	Vet_SecondaryReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_SecondaryReloadSpeedModifier(2)=0.90 //Elite
	Vet_SecondaryReloadSpeedModifier(3)=0.85 //Heroic
	
	Vet_SecondaryROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
	Vet_SecondaryROFSpeedModifier(1)=0.95 //Veteran 
	Vet_SecondaryROFSpeedModifier(2)=0.9 //Elite
	Vet_SecondaryROFSpeedModifier(3)=0.85 //Heroic 
	
	
	/********************************/
	
//	RecoilImpulse = -0.3f
	bHasRecoil = true
	bCheckIfBarrelInsideWorldGeomBeforeFiring = true
	

	WeaponFireSnd(0)     = SoundCue'RX_VH_MediumTank.Sounds.SC_MediumTank_Fire_1P'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_MediumTank_Projectile'
    WeaponFireSnd(1)     = none // SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_MediumTank_Gun'
    
	WeaponDistantFireSnd(0)=None=SoundCue'RX_SoundEffects.Cannons.SC_Cannon_DistantFire'
	WeaponDistantFireSnd(1)=None
  
    //CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5'
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'
    

    // AI
    bRecommendSplashDamage=True
	bOkAgainstLightVehicles = True
	bOkAgainstArmoredVehicles = True
	bOkAgainstBuildings = True
}
