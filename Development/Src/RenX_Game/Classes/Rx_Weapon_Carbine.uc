class Rx_Weapon_Carbine extends Rx_Weapon_Charged;

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Carbine.Mesh.SK_Carbine_1P'
		AnimSets(0)=AnimSet'RX_WP_Carbine.Anims.AS_Carbine_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Carbine.Mesh.SK_Carbine_3P'
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_Carbine'
	
	PlayerViewOffset=(X=5.0,Y=1.0,Z=-1.0)
	
	LeftHandIK_Offset=(X=0.723,Y=-5.72,Z=0.5)
	RightHandIK_Offset=(X=0,Y=0,Z=0)

	ArmsAnimSet = AnimSet'RX_WP_Carbine.Anims.AS_Carbine_Arms'
	
	FireOffset=(X=10,Y=7,Z=-8)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 50.0						// 50.0			120
	MaxRecoil = 55.0						// 45.0			150
	MaxTotalRecoil = 5000.0					// 1000.0
	RecoilYawModifier = 0.5 				// will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 15.0				// 37.0			50
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 6.0				// 4.0
	MaxSpread = 0.075						// 0.06			0.08
	RecoilSpreadIncreasePerShot = 0.002
	RecoilSpreadDeclineSpeed = 0.2			// 0.1
	RecoilSpreadDecreaseDelay = 0.15
	RecoilSpreadCrosshairScaling = 1000;	// 2500

	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	GroupWeight=5
	AimError=600

	InventoryGroup=1

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.11
	FireInterval(1)=+0.0
	ReloadTime(0) = 3.0
	ReloadTime(1) = 3.0
	
	EquipTime=0.5
//	PutDownTime=0.5
	
	Spread(0)=0.0055

	FiringStatesArray(1)=Active
/*	
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None
	
	WeaponProjectiles(0)=class'Rx_Projectile_Carbine'	
*/	
	
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=16
	InstantHitDamage(1)=16
	
	HeadShotDamageMult=2.0

	InstantHitDamageTypes(0)=class'Rx_DmgType_Carbine'
	InstantHitDamageTypes(1)=class'Rx_DmgType_Carbine'

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=10000
	
	WeaponRange=3200.0

	ClipSize = 30
	InitalNumClips = 6
	MaxClips = 6
	
	FireDelayTime = 0.01
    bCharge = true

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload2"
	ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
	ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload2"
	
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
	
	WeaponADSFireAnim[0]="WeaponFireADS"
	ArmADSFireAnim[0]="WeaponFireADS"

//	WeaponFireSnd[0]=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_FireCue'
//	WeaponFireSnd[1]=none
	
	WeaponPreFireSnd[0]=none
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_Carbine.Sounds.SC_Carbine_FireLoop'
    WeaponFireSnd[1]=none
    WeaponPostFireSnd[0]=SoundCue'RX_WP_Carbine.Sounds.SC_Carbine_FireStop'
    WeaponPostFireSnd[1]=none

	WeaponPutDownSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_PutDownCue'
	WeaponEquipSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_EquipCue'
	ReloadSound(0)=SoundCue'RX_WP_Carbine.Sounds.SC_Carbine_Reload'
	ReloadSound(1)=SoundCue'RX_WP_Carbine.Sounds.SC_Carbine_Reload'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	CrosshairWidth = 205
	CrosshairHeight = 205

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)
	InventoryMovieGroup=29

	WeaponIconTexture=Texture2D'RX_WP_Carbine.UI.T_WeaponIcon_Carbine'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-5.0,Y=-6.9,Z=0.84)		// (X=-15.0,Y=-11.675,Z=0.27)
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
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Carbine'
}