class Rx_Weapon_PersonalIonCannon extends Rx_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

simulated state BoltActionReloading
{
    simulated function BeginState( name PreviousState )
    {
        if(WorldInfo.NetMode == NM_StandAlone)
        {
        	PlayWeaponBoltReloadAnim();
        	PlaySound( BoltReloadSound[CurrentFireMode], false,true);
        }
        super.BeginState(PreviousState);
    }
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
	
	LeftHandIK_Offset=(X=0,Y=0,Z=0)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	
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
    FireInterval(0)=+0.5
    FireInterval(1)=+0.0
    ReloadTime(0) = 3.5
    ReloadTime(1) = 3.5
    
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

    Spread(0)=0.01
	IronSightAndScopedSpread(0)= 0.0

    ClipSize = 4
    InitalNumClips = 8
    MaxClips = 8
	
	bAutoFire = false
	BoltActionReload=true
	bUnzoomDuringBoltActionReloading=false
	BoltReloadTime(0) = 2.5f
	BoltReloadTime(1) = 2.5f

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"
	
	BoltReloadAnimName(0) = "WeaponBolt"
	BoltReloadAnimName(1) = "WeaponBolt"
	BoltReloadArmAnimName(0) = "WeaponBolt"
	BoltReloadArmAnimName(1) = "WeaponBolt"

	RefireBoltReloadInterrupt(0) = 1.1f
	RefireBoltReloadInterrupt(1) = 1.1f

    WeaponFireSnd[0]=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Fire'
    WeaponFireSnd[1]=None
	
	WeaponDistantFireSnd=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PersonalIonCannon_DistantFire'

    WeaponPutDownSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Equip'
	ReloadSound(0)=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Reload'
	ReloadSound(1)=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_Reload'
	BoltReloadSound(0)=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_BoltReload'
	BoltReloadSound(1)=SoundCue'RX_WP_PersonalIonCannon.Sounds.SC_PIC_BoltReload'

    PickupSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Equip'

    FireSocket="MuzzleFlashSocket"

    MuzzleFlashSocket="MuzzleFlashSocket"
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_PersonalIonCannon.Effects.P_MuzzleFlash_1P'
    MuzzleFlashDuration=3.3667
    MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'
  
	CrosshairWidth = 256
	CrosshairHeight = 256
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'

    InventoryGroup=2.1
    GroupWeight=1
    InventoryMovieGroup=11
    
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
}
