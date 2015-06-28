class Rx_Weapon_HeavyPistol extends Rx_Weapon_Reloadable;		// Rx_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

DefaultProperties
{
	bAutoFire = false
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Pistol.Mesh.SK_HeavyPistol_1P'
		AnimSets(0)=AnimSet'RX_WP_Pistol.Anims.AS_SilencedPistol_Weapon'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Pistol.Mesh.SK_HeavyPistol_Back'
		Scale=1.0
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_Pistol.Anims.AS_SilencedPistol_Arms'

	AttachmentClass = class'Rx_Attachment_HeavyPistol'
	
	PlayerViewOffset=(X=-2.5,Y=-2.0,Z=-0.5)
	
	LeftHandIK_Offset=(X=0,Y=0,Z=0)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	
	FireOffset=(X=20,Y=8,Z=-5)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 80.0
	MaxRecoil = 100.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 
	RecoilInterpSpeed = 50.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 6.0
	MaxSpread = 0.15
	RecoilSpreadIncreasePerShot = 0.01	
	RecoilSpreadDeclineSpeed = 0.8
	RecoilSpreadDecreaseDelay = 0.15
	RecoilSpreadCrosshairScaling = 1000;
	
	CrosshairWidth = 210 	// 256
	CrosshairHeight = 210 	// 256

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.25
	FireInterval(1)=+0.0
	ReloadTime(0) = 2.2333
	ReloadTime(1) = 2.2333
	
	EquipTime=0.45
//	PutDownTime=0.35
	
	WeaponRange=6000.0

    LockerRotation=(pitch=0,yaw=0,roll=-16384)

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None
	
	WeaponProjectiles(0)=class'RenX_Game.Rx_Projectile_HeavyPistol'
	WeaponProjectiles(1)=none

/*
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=30
	InstantHitDamage(1)=0
	
	HeadShotDamageMult=2.0
	
	InstantHitDamageRadius(0)=80

	InstantHitDamageTypes(0)=class'Rx_DmgType_HeavyPistol'
	InstantHitDamageTypes(1)=None

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=0
*/	
	Spread(0)=0.005
	Spread(1)=0.0
	
	ClipSize = 8
	InitalNumClips = 7
	MaxClips = 7

	bHasInfiniteAmmo = false;

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadAnim3PName(0) = "H_M_Pistol_Reload"
	ReloadAnim3PName(1) = "H_M_Pistol_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"
	
	WeaponFireAnim[0]="WeaponFireLong"
    WeaponFireAnim[1]="WeaponFireLong"

    ArmFireAnim[0]="WeaponFireLong"
    ArmFireAnim[1]="WeaponFireLong"

    WeaponFireSnd[0]=SoundCue'RX_WP_Pistol.Sounds.SC_HeavyPistol_Fire'
    WeaponFireSnd[1]=none
	
	WeaponDistantFireSnd=SoundCue'RX_WP_Pistol.Sounds.SC_HeavyPistol_DistantFire'
	
	WeaponPutDownSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'
	ReloadSound(0)=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Reload'
	ReloadSound(1)=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Reload'

	PickupSound=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash_1P'	// ParticleSystem'RX_WP_Pistol.Effects.MuzzleFlash_1P'
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'	// MaterialInstanceConstant'RenXHud.MI_Reticle_Pistol'

	InventoryGroup=1
	InventoryMovieGroup=30

	WeaponIconTexture=Texture2D'RX_WP_Pistol.UI.T_WeaponIcon_HeavyPistol'
	
	// AI Hints:
	//MaxDesireability=0.3
	AIRating=+0.1
	CurrentRating=+0.1	
	bFastRepeater=true
	bInstantHit=false	
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-10,Y=-6.215,Z=1.1)
	IronSightFireOffset=(X=0,Y=0,Z=-2)
	IronSightBobDamping=6
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=30.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=180.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_HeavyPistol'
}
