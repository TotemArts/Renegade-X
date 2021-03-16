class Rx_Weapon_TiberiumAutoRifle extends Rx_Weapon_Reloadable;


var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}


defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumAutoRifle.Mesh.SK_TiberiumAutoRifle_1P'
		AnimSets(0)=AnimSet'RX_WP_TiberiumAutoRifle.Anims.AS_TiberiumAutoRifle_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumAutoRifle.Mesh.SK_TiberiumAutolRifle_3P'
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_TiberiumAutoRifle'
	
	PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)
	
	LeftHandIK_Offset=(X=0.0,Y=0.0,Z=0.0)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	
	LeftHandIK_Relaxed_Offset = (X=0.0,Y=0.0,Z=0.0)
	LeftHandIK_Relaxed_Rotation = (Pitch=-1456,Yaw=-3458,Roll=-2366)
	RightHandIK_Relaxed_Offset = (X=-2.0,Y=2.0,Z=-5.0)
	RightHandIK_Relaxed_Rotation = (Pitch=-3822,Yaw=182,Roll=9284)

	ArmsAnimSet = AnimSet'RX_WP_TiberiumAutoRifle.Anims.AS_TiberiumAutoRifle_Arms'
	
	FireOffset=(X=10,Y=15,Z=-15)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 90.0
	MaxRecoil = 140.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 15.0
	RecoilDeclinePct = 0.4
	RecoilDeclineSpeed = 3.0
	MaxSpread = 0.1
	RecoilSpreadIncreasePerShot = 0.00075
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadDecreaseDelay = 0.3
	RecoilSpreadCrosshairScaling = 2000;

	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	GroupWeight=5
	AimError=600

	InventoryGroup=1

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.25
	FireInterval(1)=+0.0
	ReloadTime(0) = 3.0
	ReloadTime(1) = 3.0
	
	EquipTime=0.5
//	PutDownTime=0.5
	
	Spread(0)=0.001

	WeaponFireTypes(0)=EWFT_Projectile
	
	WeaponProjectiles(0)=class'Rx_Projectile_TiberiumAutoRifle'
	WeaponProjectiles_Heroic(0)=class'Rx_Projectile_TiberiumAutoRifle_Heroic'

	FiringStatesArray(1)=Active

	ClipSize = 20
	InitalNumClips = 7
	MaxClips = 7
	bHasInfiniteAmmo = true
	
	
	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload2"
	ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
	ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload2"

	WeaponFireSnd[0]=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Fire'
	WeaponFireSnd[1]=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Fire'
	
	WeaponDistantFireSnd=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_DistantFire'

	WeaponPutDownSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_PutDownCue'
	WeaponEquipSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_EquipCue'
	ReloadSound(0)=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Reload'
	ReloadSound(1)=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Reload'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TiberiumFlechetteRifle.Effects.P_MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_TiberiumFlechetteRifle_MuzzleFlash'

	MuzzleFlashLightClass_Heroic=class'Rx_Light_TiberiumFlechetteRifle_MuzzleFlashRed'
	MuzzleFlashPSCTemplate_Heroic=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_MuzzleFlash_1P_Red'

    // CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	CrosshairWidth = 195
	CrosshairHeight = 195

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)
	InventoryMovieGroup=33

	WeaponIconTexture=Texture2D'RX_WP_TiberiumAutoRifle.UI.T_WeaponIcon_TiberiumAutoRifle'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-5.0,Y=-7.42,Z=0.67)		// (X=-15.0,Y=-11.675,Z=0.27)
	IronSightFireOffset=(X=0,Y=0,Z=0)
	IronSightBobDamping=10
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=55.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=220.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 5					// 2		1.5
	IronSightMaxRecoilDamping = 5					// 2		1.5
	IronSightMaxTotalRecoilDamping = 2				// 2		1.5
	IronSightRecoilYawDamping = 2					// 1		1.0
	IronSightMaxSpreadDamping = 2					// 2		1.5
	IronSightSpreadIncreasePerShotDamping = 100		// 4		1.7

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_TiberiumAutoRifle'
	
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
	Vet_ClipSizeModifier(3)=20 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=1 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.8 //Heroic
	/**********************/
}