class Rx_Vehicle_Bus_Weapon extends Rx_Vehicle_Weapon_Reloadable;

DefaultProperties
{
    
    InventoryGroup=12
    
    // reload config
    ClipSize = 999
    InitalNumClips = 999
    MaxClips = 999
     
    ShotCost(0)=0
    ShotCost(1)=0
     
    ReloadTime(0) = 2.0
    ReloadTime(1) = 2.0
     
    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
     
    ReloadSound(0)=SoundCue'RX_VH_Bus.Sounds.SC_Bus_Fire_Stop'
    ReloadSound(1)=SoundCue'RX_VH_Bus.Sounds.SC_Bus_Fire_Stop'
	
	CrosshairWidth = 180 	// 256
	CrosshairHeight = 180 	// 256
     
    // gun config
    FireTriggerTags(0)="MainGun"
    AltFireTriggerTags(0)="MainGun"
    VehicleClass=Class'Rx_Vehicle_Bus'

    FireInterval(0)=1
    FireInterval(1)=1
    bFastRepeater=true
	
    Spread(0)=0
    Spread(1)=0
	
	RecoilImpulse = 0f
	
    WeaponFireSnd(0)     = none //SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire'
//    WeaponFireTypes(0)   = EWFT_Projectile
//    WeaponProjectiles(0) = Class'Rx_Vehicle_Humvee_Projectile'
    WeaponFireSnd(1)     = none //SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire'
//    WeaponFireTypes(1)   = EWFT_Projectile
//    WeaponProjectiles(1) = Class'Rx_Vehicle_Humvee_Projectile'
    // AI
    bRecommendSplashDamage=False
	
	WeaponRange=6000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=0
	InstantHitDamage(1)=0
	
	HeadShotDamageMult=1

	InstantHitDamageTypes(0)=none
	InstantHitDamageTypes(1)=none

	InstantHitMomentum(0)=0
	InstantHitMomentum(1)=0
	
	bInstantHit=true
}
