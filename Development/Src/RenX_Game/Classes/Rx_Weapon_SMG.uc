class Rx_Weapon_SMG extends Rx_Weapon_Charged;		// Rx_Weapon_Reloadable;

simulated function bool IsInstantHit()
{
	return true; 
}

DefaultProperties
{
	bAutoFire = true
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Pistol.Mesh.SK_MachinePistol_1P'
		AnimSets(0)=AnimSet'RX_WP_Pistol.Anims.AS_MachinePistol_1P'
		Animations=MeshSequenceA
		Scale=2.5
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Pistol.Mesh.SK_MachinePistol_Back'
		Scale=1.0
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_Pistol.Anims.AS_MachinePistol_Arms'

	AttachmentClass = class'Rx_Attachment_SMG'
	
	PlayerViewOffset=(X=4.5,Y=-1.5,Z=-1.5)

	LeftHandIK_Offset=(X=-4.704200,Y=-2.984400,Z=0.071600)
	LeftHandIK_Rotation=(Pitch=-2730,Yaw=-4915,Roll=3640)
	RightHandIK_Offset=(X=2,Y=-2,Z=-5)
	bUseHandIKWhenRelax=False
	bOverrideLeftHandAnim=true
	LeftHandAnim=H_M_Hands_Closed
	
	FireOffset=(X=20,Y=8,Z=-10)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 120.0
	MaxRecoil = 150.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 
	RecoilInterpSpeed = 40.0
	RecoilDeclinePct = 0.25
	RecoilDeclineSpeed = 4.0
	MaxSpread = 0.04
	RecoilSpreadIncreasePerShot = 0.0025	
	RecoilSpreadDeclineSpeed = 0.8
	RecoilSpreadDecreaseDelay = 0.15
	RecoilSpreadCrosshairScaling = 1000;

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=0.10 //+0.08
	FireInterval(1)=+0.0
	ReloadTime(0) = 3.0
	ReloadTime(1) = 3.0
	
	EquipTime=0.45
//	PutDownTime=0.35

    WeaponRange=3600.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=14//8
	InstantHitDamage(1)=14 //8
	
	HeadShotDamageMult=1.5 //3

	InstantHitDamageTypes(0)=class'Rx_DmgType_SMG'
	InstantHitDamageTypes(1)=class'Rx_DmgType_SMG'

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=10000
	
	bInstantHit=true

//	WeaponFireTypes(0)=EWFT_Projectile
//	WeaponFireTypes(1)=EWFT_None
	
//	WeaponProjectiles(0)=class'RenX_Game.Rx_Projectile_SMG'
//	WeaponProjectiles(1)=class'RenX_Game.Rx_Projectile_SMG'

	Spread(0)=0.001 //0.002
	Spread(1)=0.0
	
	ClipSize = 30
	InitalNumClips = 7
	MaxClips = 7
	
	FireDelayTime = 0.01
	bCharge = true
	bHasInfiniteAmmo = true;

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
	ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"
	
	WeaponPreFireAnim[0]="WeaponFireStart"
    WeaponPreFireAnim[1]="WeaponFireStart"
    WeaponFireAnim[0]="WeaponFireloop"
    WeaponFireAnim[1]="WeaponFireloop"
    WeaponPostFireAnim[0]="WeaponFireStop"
    WeaponPostFireAnim[1]="WeaponFireStop"

    ArmPreFireAnim[0]="WeaponFireStart"
    ArmPreFireAnim[1]="WeaponFireStart"
    ArmFireAnim[0]="WeaponFireloop"
    ArmFireAnim[1]="WeaponFireloop"
    ArmPostFireAnim[0]="WeaponFireStop"
    ArmPostFireAnim[1]="WeaponFireStop"	
	
	WeaponPreFireSnd[0]=none
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_Pistol.Sounds.SC_SMG_FireLoop'
    WeaponFireSnd[1]=none
    WeaponPostFireSnd[0]=SoundCue'RX_WP_Pistol.Sounds.SC_SMG_FireStop'
    WeaponPostFireSnd[1]=none


//	WeaponFireSnd[0]=SoundCue'RX_WP_Pistol.Sounds.SC_SMG_Fire'
//    WeaponFireSnd[1]=none
	
	WeaponPutDownSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'
	ReloadSound(0)=SoundCue'RX_WP_Pistol.Sounds.SC_MachinePistol_Reload'
	ReloadSound(1)=SoundCue'RX_WP_Pistol.Sounds.SC_MachinePistol_Reload'

	PickupSound=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash_1P'	// ParticleSystem'RX_WP_Pistol.Effects.MuzzleFlash_1P'
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	CrosshairWidth = 195
	CrosshairHeight = 195
	
	InventoryGroup=1
	InventoryMovieGroup=26

	WeaponIconTexture=Texture2D'RX_WP_Pistol.UI.T_WeaponIcon_SMG'
	
	// AI Hints:
	//MaxDesireability=0.3
	AIRating=+0.1
	CurrentRating=+0.1	
	bFastRepeater=true
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-4,Y=-6.113,Z=1.0)
	IronSightFireOffset=(X=0,Y=0,Z=-4)
	IronSightBobDamping=6
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=35.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=180.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_SMG'
	
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
	Vet_ClipSizeModifier(1)=5 //Veteran 
	Vet_ClipSizeModifier(2)=10 //Elite
	Vet_ClipSizeModifier(3)=15 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
}
