class Rx_Weapon_PersonalIonCannon extends Rx_Weapon_Charged ; //Rx_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
	//WeaponPlaySound( WeaponFireSnd[1] ); /*Small Hack for the PIC, as its reload sound clips off its fire sound for... reasons*/
}

/**simulated state BoltActionReloading
{
    simulated function BeginState( name PreviousState )
    {
        if(WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_Client)
        {
        	PlayWeaponBoltReloadAnim();
        	PlaySound( BoltReloadSound[CurrentFireMode], false,true);
        }
        super.BeginState(PreviousState);
    }
}*/

simulated function bool IsInstantHit()
{
	return true; 
}

DefaultProperties
{
    // Weapon SkeletalMesh
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_PersonalIonCannon.Mesh.SK_PersonalIonCannon_1P'
        AnimSets(0)=AnimSet'RX_WP_PersonalIonCannon.Anims.AS_PersonalIonCannon_1P'
        Animations=MeshSequenceA
        FOV=55
		Scale=2.0
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_PersonalIonCannon.Mesh.SK_PersonalIonCannon_Back'
        Scale=1.0
    End Object

    AttachmentClass = class'Rx_Attachment_PersonalIonCannon'
	
	ArmsAnimSet=AnimSet'RX_WP_PersonalIonCannon.Anims.AS_PersonalIonCannon_Arms'
	
	PlayerViewOffset=(X=-2.0,Y=0.0,Z=-1.0)
	
	LeftHandIK_Offset=(X=0,Y=-1,Z=-0.5)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	LeftHandIK_Relaxed_Offset = (X=2.0,Y=-2.5,Z=4.0)

	//Burst Fire Variables//
	bBurstFire = true  //If true, the weapon will use burst fire mechanics
	TimeBetweenBursts = 0.06
	bConstantFire = false 
	BurstNum = 1
	Burst_Cooldown(0) = 0.1
	Burst_Cooldown(1) = 0.1
	
	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.1
	MinRecoil = 400.0
	MaxRecoil = 600.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 40.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 2.0
	RecoilSpread = 0.0
	MaxSpread = 0.1
	RecoilSpreadIncreasePerShot = 0.0
	RecoilSpreadDeclineSpeed = 0.02
	RecoilSpreadCrosshairScaling = 3000;

    ShotCost(0)=1
    ShotCost(1)=0
	ShouldFireOnRelease(0)=1
	ShouldFireOnRelease(1)=0
    FireInterval(0)=+0.9 //+0.75 //+0.5
    FireInterval(1)=+0.9 //+0.0
    ReloadTime(0) = 2.8 //4.0 //3.5
    ReloadTime(1) = 2.8 //4.0 //3.5
    
    EquipTime=1.0
//	PutDownTime=0.75
    
    WeaponRange=5600.0

	
    LockerRotation=(pitch=0,yaw=0,roll=-16384)

    WeaponFireTypes(0)=EWFT_InstantHit
    WeaponFireTypes(1)=EWFT_None

    InstantHitDamage(0)=200
    InstantHitDamage(1)=0
    
    BotDamagePercentage = 0.6;

    InstantHitDamageTypes(0)=class'Rx_DmgType_PersonalIonCannon'
    InstantHitDamageTypes(1)=None

    InstantHitMomentum(0)=30000
    InstantHitMomentum(1)=0

	HeadShotDamageMult=2.0 //1.5
	
    Spread(0)=0.0
	IronSightAndScopedSpread(0)= 0.0

    ClipSize = 1 //4
    InitalNumClips = 48 //12
    MaxClips = 48 //12
	
	bAutoFire = false
	BoltActionReload= false //true
	bUnzoomDuringBoltActionReloading=false
	BoltReloadTime(0) = 2.5f
	BoltReloadTime(1) = 2.5f

	ReloadAnimName(0) = "WeaponBolt" //"weaponreload"
	ReloadAnimName(1) = "WeaponBolt" //"weaponreload"
	ReloadArmAnimName(0) = "WeaponBolt" //"weaponreload"
	ReloadArmAnimName(1) = "WeaponBolt" //"weaponreload"
	BoltReloadAnim3PName(0) = "H_M_BoltReload"
	BoltReloadAnim3PName(1) = "H_M_BoltReload"
	ReloadAnim3PName(0) = "H_M_BoltReload"
	ReloadAnim3PName(1) = "H_M_BoltReload"
	
	BoltReloadAnimName(0) = "WeaponBolt"
	BoltReloadAnimName(1) = "WeaponBolt"
	BoltReloadArmAnimName(0) = "WeaponBolt"
	BoltReloadArmAnimName(1) = "WeaponBolt"

	RefireBoltReloadInterrupt(0) = 1.1f
	RefireBoltReloadInterrupt(1) = 1.1f
	
	/**Charged Weapon Variables*/
	
	WeaponPreFireAnim(0) 	= "WeaponIdle" //"WeaponBolt"
	WeaponFireAnim(0)		= "WeaponFire"
	WeaponPostFireAnim(0) 	= "WeaponIdle"//"WeaponBolt"
	
	ArmPreFireAnim(0) = "WeaponIdle" //"WeaponBolt" 
	ArmFireAnim(0)	= "WeaponFire"
	ArmPostFireAnim(0) = "WeaponIdle" //"WeaponBolt" 

	/** Extra firing sounds */
	WeaponPreFireSnd(0) = SoundCue'RX_WP_PersonalIonCannon.Sounds.S_PIC_PreFire_Cue'
	WeaponPostFireSnd(0) = none 

	//ProjectileCount

	/** The time to delay firing */
	FireDelayTime = 0.33
	bCharge = true
	
	
    WeaponFireSnd[0]=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Fire' //SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Fire'
    WeaponFireSnd[1]=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Fire'
	
	WeaponDistantFireSnd=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PersonalIonCannon_DistantFire'

    WeaponPutDownSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Equip'
	ReloadSound(0)= SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_BoltReload' //SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Reload'
	ReloadSound(1)= SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_BoltReload' //SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Reload'
	
	BoltReloadSound(0)=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_BoltReload'
	BoltReloadSound(1)=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_BoltReload'

    PickupSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Equip'

    FireSocket="MuzzleFlashSocket"

    MuzzleFlashSocket="MuzzleFlashSocket"
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_PersonalIonCannon.Effects.P_MuzzleFlash_1P'
    MuzzleFlashPSCTemplate_Heroic=ParticleSystem'RX_WP_PersonalIonCannon.Effects.P_MuzzleFlash_1P_Heroic'
    MuzzleFlashDuration=3.3667
    MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'
  
	CrosshairWidth = 256
	CrosshairHeight = 256
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'

    InventoryGroup=2.1
    GroupWeight=1
    InventoryMovieGroup=11

	WeaponIconTexture=Texture2D'RX_WP_PersonalIonCannon.UI.T_WeaponIcon_PersonalIonCannon'
    
    // AI Hints:
    //MaxDesireability=0.7
    AIRating=+0.4
    CurrentRating=+0.4
    bFastRepeater=false
    bInstantHit=true
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=false
	bOkAgainstBuildings=true	
	bOkAgainstVehicles=true	 

	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	bDisplayCrosshairInIronsight = false
	IronSightViewOffset=(X=-10.0,Y=-6.39,Z=0.83)
	IronSightFireOffset=(X=0,Y=0,Z=-5)
	IronSightBobDamping=6
	IronSightPostAnimDurationModifier=1.0
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=60.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=100.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 2
	IronSightMaxRecoilDamping = 2
	IronSightMaxTotalRecoilDamping = 2
	IronSightRecoilYawDamping = 1
	IronSightMaxSpreadDamping = 2
	IronSightSpreadIncreasePerShotDamping = 4

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_PersonalIonCannon'
	
	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.15 //1.10 
	Vet_DamageModifier(2)=1.25 
	Vet_DamageModifier(3)=1.50 
	
	Vet_ROFModifier(0) = 1.0
	Vet_ROFModifier(1) = 1.0
	Vet_ROFModifier(2) = 1.0 
	Vet_ROFModifier(3) = 1.0 
	
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)	
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=0 //Elite
	Vet_ClipSizeModifier(3)=0 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	bLocSync = true; 
	
	ROFTurnover = 2;
	
	bOverrideFireIntervalForReload = false //Don't clip your sounds together
	
	//For instant hit weapons 
	bPierceInfantry = true
	bPierceVehicles = true
	MaximumPiercingAbility  =  5
	CurrentPiercingPower	=  5
	
	Ammo_Increment = 4
}
