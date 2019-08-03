class Rx_Weapon_Grenade_Rechargeable extends Rx_Weapon_RechargeableGrenade;

// EMP Grenades are non-refillable, players must purchase more. EDIT: Rechargeable Grenades are also non-refillable. 
simulated function PerformRefill();

simulated function ReloadWeapon();

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_Grenade_1P'
		AnimSets(0)=AnimSet'RX_WP_Grenade.Anims.AS_Grenade_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_Grenade_1P'
		Scale=2.5
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_Grenade.Anims.AS_Grenade_Arms'

	AttachmentClass = class'Rx_Attachment_Grenade'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Greande'
	
	PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)
	
	FireOffset=(X=0,Y=10,Z=0)
	
	bUseHandIKWhenRelax=false
	bByPassHandIK=true
	
	//-------------- Recoil
	RecoilDelay = 0.0
	MinRecoil = 0.0
	MaxRecoil = 0.0
	MaxTotalRecoil = 0.0
	RecoilYawModifier = 0.0 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 0.0
	RecoilDeclinePct = 0.0
	RecoilDeclineSpeed = 0.0
	MaxSpread = 0.0
	RecoilSpreadIncreasePerShot = 0.0
	RecoilSpreadDeclineSpeed = 0.0
	RecoilSpreadDecreaseDelay = 0.0
	RecoilSpreadCrosshairScaling = 10000;

	ShotCost(0)=1
	ShotCost(1)=1
	FireInterval(0)=+0.75
	FireInterval(1)=+0.75
	ReloadTime(0) = 25
	ReloadTime(1) = 25
	DelayFireTime(0) = 0.54375;
	DelayFireTime(1) = 0.54375;
	
	EquipTime=0.6
//	PutDownTime=0.35
	
	WeaponRange=2800.0

    LockerRotation=(pitch=0,yaw=0,roll=-16384)

	WeaponFireTypes(0)=EWFT_Projectile
    WeaponFireTypes(1)=EWFT_Projectile
    
    WeaponProjectiles(0)=class'Rx_Projectile_Grenade'
    WeaponProjectiles(1)=class'Rx_Projectile_Grenade_Alt'

    Spread(0)=0.0
    Spread(1)=0.0
	
	ClipSize = 1
	InitalNumClips = 3
	MaxClips = 3

//	AmmoCount=2
//	LockerAmmoCount=2
//	MaxAmmoCount=2

	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	ReloadAnimName(0) = "weaponequip"
	ReloadAnimName(1) = "weaponequip"
	ReloadAnim3PName(0) = "H_M_C4_Equip"
	ReloadAnim3PName(1) = "H_M_C4_Equip"
	ReloadArmAnimName(0) = "weaponequip"
	ReloadArmAnimName(1) = "weaponequip"

	WeaponThrowGrenadeAnimName(0) = "H_M_Grenade_Toss"
	WeaponThrowGrenadeAnimName(1) = "H_M_Grenade_Toss"

	WeaponFireSnd[0]=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Throw'
	WeaponFireSnd[1]=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Throw'

	WeaponPutDownSnd=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'
	ReloadSound(0)=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'
	ReloadSound(1)=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'

	PickupSound=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=none
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=none

    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_GrenadeLauncher'
	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.Null_Material.MI_Null_Glass' // MaterialInstanceConstant'RenXHud.MI_Reticle_Dot'
	
	CrosshairWidth = 256
	CrosshairHeight = 256

	InventoryGroup=5
	InventoryMovieGroup=27

	WeaponIconTexture=Texture2D'RX_WP_Grenade.UI.T_WeaponIcon_Grenade'
	
	// AI Hints:
	// MaxDesireability=0.3
	AIRating=+0.3
    CurrentRating=+0.3
    bFastRepeater=false
    bInstantHit=false
    bSplashJump=false
    bRecommendSplashDamage=true
    bSniping=false   	
	
	// IronSight:
	bIronSightCapable = false	
	IronSightViewOffset=(X=-5,Y=-4.5,Z=2.85)
	IronSightBobDamping=6
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=35.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=180.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
}
