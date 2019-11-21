
class Rx_Defence_CeilingTurret_Weapon extends Rx_Vehicle_Weapon_Reloadable;

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return false;
}

DefaultProperties
{
    
    InventoryGroup=9
    
    // reload config
    ClipSize = 66
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
    VehicleClass=Class'Rx_Defence_CeilingTurret'

    FireInterval(0)=0.08
    FireInterval(1)=0.08

    Spread(0)=0.015
    Spread(1)=0.015
  
    WeaponFireSnd(0)     = none //SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Defence_CeilingTurret_Projectile'
    WeaponFireSnd(1)     = none //SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Defence_CeilingTurret_Projectile'
    // AI
    bRecommendSplashDamage=False
}
