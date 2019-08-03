class Rx_Weapon_SniperRifle_UnSilenced extends Rx_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

simulated function bool IsInstantHit()
{
	return true; 
}

DefaultProperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_DSR50_UnSilenced_1P'
		AnimSets(0)=AnimSet'RX_WP_SniperRifle.Anims.AS_DSR50_Unsilenced_1P'
		Animations=MeshSequenceA
		Scale=3.0
		FOV=55
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_DSR50_Back'		// SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_WP_SniperRifle_Back'
		// Translation=(X=-12)
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_SniperRifle_UnSilenced'

	ArmsAnimSet=AnimSet'RX_WP_SniperRifle.Anims.AS_DSR50_UnSilenced_Arms'
	
	PlayerViewOffset=(X=2.0,Y=0.0,Z=-1.0)		// (X=-5.0,Y=-3.0,Z=-0.5)
	
	LeftHandIK_Offset=(X=0.0,Y=0.0,Z=0.0)
	RightHandIK_Offset=(X=3.0,Y=-1.0,Z=-2.0)

	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 200.0
	MaxRecoil = 300.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.75 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 40.0
	RecoilDeclinePct = 0.8
	RecoilDeclineSpeed = 5.0
	MaxSpread = 0.3
	RecoilSpreadIncreasePerShot = 0.1
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadDecreaseDelay = 0.3
	RecoilSpreadCrosshairScaling = 500;	// 2500
	
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	GroupWeight=1
	AimError=600

	InventoryGroup=2

	ShotCost(0)=1
	ShotCost(1)=1
	FireInterval(0)=+1.0
	FireInterval(1)=+0.0
	ReloadTime(0) = 4.0
	ReloadTime(1) = 4.0
	
	EquipTime=0.75
//	PutDownTime=0.5
	
	Spread(0)=0.1
	IronSightAndScopedSpread(0)= 0.0
	
	InstantHitDamage(0)=100
	InstantHitDamage(1)=0
	InstantHitMomentum(0)=10000.0
	
	HeadShotDamageMult=3.0

//	BotDamagePercentage = 0.4;

	WeaponFireTypes(0)=EWFT_InstantHit

	FiringStatesArray(1)=Active

	InstantHitDamageTypes(0)=class'Rx_DmgType_SniperRifle'
	InstantHitDamageTypes(1)=None

	ClipSize = 4
	InitalNumClips = 9
	MaxClips = 9
	
	bAutoFire = false
	BoltActionReload=true
	BoltReloadTime(0) = 1.75 //2.0f (Factor in RefireBoltReloadInterrupt) 
	BoltReloadTime(1) = 1.75 //2.0f

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"
	
	BoltReloadAnimName(0) = "WeaponBolt"
	BoltReloadAnimName(1) = "WeaponBolt"
	BoltReloadArmAnimName(0) = "WeaponBolt"
	BoltReloadArmAnimName(1) = "WeaponBolt"

	WeaponFireSnd[0]=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Fire_Unsilenced'
	WeaponFireSnd[1]=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Fire_Unsilenced'
	
	WeaponDistantFireSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_DistantFire'

	WeaponPutDownSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Equip'
	ReloadSound(0)=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Reload'
	ReloadSound(1)=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Reload'
	BoltReloadSound(0)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_BoltPull'
	BoltReloadSound(1)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_BoltPull'

	PickupSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TacticalRifle.Effects.P_MuzzleFlash_3P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	// Configure the zoom

	bZoomedFireMode(0)=0
	bZoomedFireMode(1)=1

//	FadeTime=0.3

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	CrosshairWidth = 180
	CrosshairHeight = 180

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)

	bDisplaycrosshair = true;
	InventoryMovieGroup=5
	// DroppedPickupClass = class'RxDroppedPickup_SniperRifle'
	
	WeaponIconTexture=Texture2D'RX_WP_SniperRifle.UI.T_WeaponIcon_SniperRifle_UnSilenced'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-17.0,Y=-9.661,Z=1.28)		// (X=-15.0,Y=-11.675,Z=0.27)
	IronSightFireOffset=(X=10,Y=0,Z=-2)
	IronSightBobDamping=30
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=80.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=160.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	bUnzoomDuringBoltActionReloading = True


	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_SniperRifle_UnSilenced'
	
	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.10 
	Vet_DamageModifier(2)=1.25 
	Vet_DamageModifier(3)=1.50 
	
	Vet_ROFModifier(0) = 1
	Vet_ROFModifier(1) = 1 
	Vet_ROFModifier(2) = 1  
	Vet_ROFModifier(3) = 1  
	
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)	
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=1 //Elite
	Vet_ClipSizeModifier(3)=2 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	bLocSync = true; 
}