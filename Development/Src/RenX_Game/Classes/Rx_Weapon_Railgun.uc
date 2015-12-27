class Rx_Weapon_Railgun extends Rx_Weapon_Reloadable;		// Rx_Weapon_Charged;

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
        SkeletalMesh=SkeletalMesh'RX_WP_Railgun.Mesh.SK_Railgun_1P'
        AnimSets(0)=AnimSet'RX_WP_Railgun.Anims.AS_Railgun_1P'
        Animations=MeshSequenceA
        FOV=55
		Scale=2.0
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_Railgun.Mesh.SK_Railgun_Back'
        Scale=1.0
    End Object
	
	PlayerViewOffset=(X=5.0,Y=0.0,Z=-1.0)		// (X=6.0,Y=2.0,Z=-2.0)
	
	FireOffset=(X=0,Y=4,Z=-3)

    AttachmentClass = class'Rx_Attachment_Railgun'
	
	ArmsAnimSet=AnimSet'RX_WP_Railgun.Anims.AS_Railgun_Arms'
	
	LeftHandIK_Offset=(X=1,Y=3,Z=1)
	RightHandIK_Offset=(X=3,Y=0,Z=-0)
	
	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.1
	MinRecoil = 400.0
	MaxRecoil = 600.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 10.0
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

    InstantHitDamageTypes(0)=class'Rx_DmgType_Railgun'
    InstantHitDamageTypes(1)=None

    InstantHitMomentum(0)=30000
    InstantHitMomentum(1)=0

	Spread(0)=0.01
	IronSightAndScopedSpread(0)= 0.0
  
    ClipSize = 4
    InitalNumClips = 12
    MaxClips = 12
	
//	FireDelayTime = 1.29
//    bCharge = true
	bAutoFire = false
	BoltActionReload=true
	BoltReloadTime(0) = 2.5f
	BoltReloadTime(1) = 2.5f

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
    ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
	
	BoltReloadAnimName(0) = "WeaponBoltReload"
	BoltReloadAnimName(1) = "WeaponBoltReload"
	BoltReloadArmAnimName(0) = "WeaponBoltReload"
	BoltReloadArmAnimName(1) = "WeaponBoltReload"

	RefireBoltReloadInterrupt(0) = 1.1f
	RefireBoltReloadInterrupt(1) = 1.1f

    WeaponFireSnd[0]=SoundCue'RX_WP_Railgun.Sounds.Railgun_FireCue'
    WeaponFireSnd[1]=None

	WeaponDistantFireSnd=SoundCue'RX_WP_Railgun.Sounds.SC_Railgun_DistantFire'

    WeaponPutDownSnd=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_PutDownCue'
    WeaponEquipSnd=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_EquipCue'
	
    ReloadSound(0)=SoundCue'RX_WP_Railgun.Sounds.SC_Railgun_Reload'
    ReloadSound(1)=SoundCue'RX_WP_Railgun.Sounds.SC_Railgun_Reload'
	
	BoltReloadSound(0)=SoundCue'RX_WP_Railgun.Sounds.SC_Railgun_BoltPull'
	BoltReloadSound(1)=SoundCue'RX_WP_Railgun.Sounds.SC_Railgun_BoltPull'

    PickupSound=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'

    FireSocket="MuzzleFlashSocket"

    MuzzleFlashSocket="MuzzleFlashSocket"
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_1P'
    MuzzleFlashDuration=3.3667
    MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'
  
	CrosshairWidth = 256
	CrosshairHeight = 256
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'

    InventoryGroup=2.1
    GroupWeight=1
    InventoryMovieGroup=12

	WeaponIconTexture=Texture2D'RX_WP_Railgun.UI.T_WeaponIcon_Railgun'
    
    // AI Hints:
    // MaxDesireability=0.7
    AIRating=+0.3
    CurrentRating=+0.3
    bFastRepeater=false
    bInstantHit=true
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=true
	bOkAgainstBuildings=true	
	bOkAgainstVehicles=true	
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	bDisplayCrosshairInIronsight = false
	IronSightViewOffset=(X=-4.0,Y=-7.275,Z=0.4)
	IronSightFireOffset=(X=0,Y=0,Z=-5)
	IronSightBobDamping=12
	IronSightPostAnimDurationModifier=0.2
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
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Railgun'
}
