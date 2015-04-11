class Rx_Weapon_Chaingun extends Rx_Weapon_Charged		// Rx_Weapon_Charged
    abstract;
	
DefaultProperties
{
    // Weapon SkeletalMesh
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_ChainGun.Mesh.SK_Chaingun_1P'
        AnimSets(0)=AnimSet'RX_WP_ChainGun.Anims.AS_Chaingun_1P_Alternative'
        Animations=MeshSequenceA
        FOV=55
		Scale=2.0
    End Object
	
	ArmsAnimSet = AnimSet'RX_WP_ChainGun.Anims.AS_Chaingun_Arms_New'

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_ChainGun.Mesh.SK_WP_ChainGun_Back'
        // Translation=(X=-15)
        Scale=1.0
    End Object

    AttachmentClass = class'Rx_Attachment_Chaingun'
	
	PlayerViewOffset=(X=-5.0,Y=-2.0,Z=-2.0)
	
	FireOffset=(X=35,Y=25,Z=-40)
	
	LeftHandIK_Offset=(X=3,Y=-2.5,Z=-1)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 40.0
	MaxRecoil = 60.0
	MaxTotalRecoil = 1000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilYawMultiplier = 2.0
	RecoilInterpSpeed = 38.0
	RecoilDeclinePct = 0.85
	RecoilDeclineSpeed = 6.0
	MaxSpread = 0.05
	RecoilSpreadIncreasePerShot = 0.001
	RecoilSpreadDeclineSpeed = 0.2
	RecoilSpreadDecreaseDelay = 0.2

    ShotCost(0)=1
    ShotCost(1)=1
    FireInterval(0)=+0.08
    FireInterval(1)=+0.0
    ReloadTime(0) = 3.8667
    ReloadTime(1) = 3.8667
   
    EquipTime=0.75
	PutDownTime=0.5
	
	WeaponRange=6000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=12
	InstantHitDamage(1)=12
	
	HeadShotDamageMult=2.5

	InstantHitDamageTypes(0)=class'Rx_DmgType_Chaingun'
	InstantHitDamageTypes(1)=class'Rx_DmgType_Chaingun'

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=10000
	
	bInstantHit=true

//	WeaponFireTypes(0)=EWFT_Projectile
//	WeaponFireTypes(1)=EWFT_None

    Spread(0)=0.03
    Spread(1)=0.03
 
    ClipSize = 200
    InitalNumClips = 3
    MaxClips = 3

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_RocketLauncher_Reload"
    ReloadAnim3PName(1) = "H_M_RocketLauncher_Reload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"

	WeaponPreFireAnim[0]="WeaponFireStart"
    WeaponPreFireAnim[1]="WeaponFireStart"
    WeaponFireAnim[0]="WeaponFireloop"
    WeaponFireAnim[1]="WeaponFireloop"
    WeaponPostFireAnim[0]="WeaponFireEnd"
    WeaponPostFireAnim[1]="WeaponFireEnd"

    ArmPreFireAnim[0]="WeaponFireStart"
    ArmPreFireAnim[1]="WeaponFireStart"
    ArmFireAnim[0]="WeaponFireloop"
    ArmFireAnim[1]="WeaponFireloop"
    ArmPostFireAnim[0]="WeaponFireEnd"
    ArmPostFireAnim[1]="WeaponFireEnd"
 
    WeaponEquipSnd=SoundCue'RX_WP_ChainGun.Sounds.SC_Chaingun_Equip'
    WeaponPutDownSnd=SoundCue'RX_WP_ChainGun.Sounds.SC_Chaingun_PutDown'

    WeaponPreFireSnd[0]=none	// SoundCue'RX_WP_ChainGun.Sounds.SC_ChainGun_Start'
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_ChainGun.Sounds.SC_ChainGun_Fire_Loop'
    WeaponFireSnd[1]=none
    WeaponPostFireSnd[0]=SoundCue'RX_WP_ChainGun.Sounds.SC_ChainGun_Stop'
    WeaponPostFireSnd[1]=none
 
    ReloadSound(0)=SoundCue'RX_WP_ChainGun.Sounds.SC_Chaingun_Reload'
    ReloadSound(1)=SoundCue'RX_WP_ChainGun.Sounds.SC_Chaingun_Reload'

    PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'

    MuzzleFlashSocket=MuzzleFlashSocket
    FireSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_ChainGun.Effects.P_MuzzleFlash_1P'
    MuzzleFlashDuration=0.1
    MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'

    CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_Chaingun'
	CrosshairWidth = 180 	// 256
	CrosshairHeight = 180 	// 256

    InventoryGroup=2.1
    GroupWeight=1
    InventoryMovieGroup=4

    
    // AI Hints:
    // MaxDesireability=0.7
    AIRating=+0.3
    CurrentRating=+0.3
    bFastRepeater=true
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=false

    FireDelayTime = 0.01
    bCharge = true
	
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = false	
	bDisplayCrosshairInIronsight = true
	IronSightViewOffset=(X=-7.5,Y=-3.0,Z=-1.0)
	IronSightFireOffset=(X=35,Y=12,Z=-15)
	IronSightBobDamping=2
	IronSightPostAnimDurationModifier=1.0
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=40.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=100
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 4
	IronSightMaxRecoilDamping = 4
	IronSightMaxTotalRecoilDamping = 2
	IronSightRecoilYawDamping = 2
	IronSightMaxSpreadDamping = 2
	IronSightSpreadIncreasePerShotDamping = 4

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Chaingun'
}
