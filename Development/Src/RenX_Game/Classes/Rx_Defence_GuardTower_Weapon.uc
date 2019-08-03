
class Rx_Defence_GuardTower_Weapon extends Rx_Vehicle_Weapon_Reloadable;

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return false;
}

DefaultProperties
{
    
    InventoryGroup=9
    
    // reload config
    ClipSize = 60
    InitalNumClips = 999
    MaxClips = 999
     
    ShotCost(0)=1
    ShotCost(1)=1
     
    ReloadTime(0) = 3.0
    ReloadTime(1) = 3.0
     
    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
     
    ReloadSound(0)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Gun'
    ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Gun'
    
    // gun config
    FireTriggerTags(0)="MainGun"
    AltFireTriggerTags(0)="MainGun"
    VehicleClass=Class'Rx_Defence_GuardTower'

    FireInterval(0)=0.08
    FireInterval(1)=0.08

    Spread(0)=0.015
    Spread(1)=0.015
  
    WeaponFireSnd(0)     = none //SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Defence_GuardTower_Projectile'
    WeaponFireSnd(1)     = none //SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Defence_GuardTower_Projectile'
    // AI
    bRecommendSplashDamage=False
    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True
	
	
	/****************************************/
	/*Veterancy*/
	/****************************************/
	
	
	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ROFModifier(0) = 1 //Normal
	Vet_ROFModifier(1) = 0.95  //Veteran
	Vet_ROFModifier(2) = 0.90  //Elite
	Vet_ROFModifier(3) = 0.85  //Heroic
 
	//+X
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
	Vet_ClipSizeModifier(1)=10 //Veteran 
	Vet_ClipSizeModifier(2)=20 //Elite
	Vet_ClipSizeModifier(3)=30 //Heroic

	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	
	
	/********************************/
}
