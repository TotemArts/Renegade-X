class Rx_Weapon_TiberiumAutoRifle_Blue extends Rx_Weapon_Reloadable;


defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumAutoRifle.Mesh.SK_TiberiumAutoRifle_1P'
		AnimSets(0)=AnimSet'RX_WP_TiberiumAutoRifle.Anims.AS_TiberiumAutoRifle_1P'
		Animations=MeshSequenceA
		Materials(0)=MaterialInstanceConstant'RX_WP_TiberiumAutoRifle.Materials.MI_TiberiumAutoRifle_Blue_1P'
		Scale=2.0
		FOV=55
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumAutoRifle.Mesh.SK_TiberiumAutolRifle_3P'
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_TiberiumAutoRifle_Blue'
	
	PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)
	
	LeftHandIK_Offset=(X=0.5,Y=-1,Z=3)
	RightHandIK_Offset=(X=0,Y=0,Z=0)

	ArmsAnimSet = AnimSet'RX_WP_TiberiumAutoRifle.Anims.AS_TiberiumAutoRifle_Arms'
	
	FireOffset=(X=10,Y=15,Z=-15)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 45.0
	MaxRecoil = 60.0
	MaxTotalRecoil = 2000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilYawMultiplier = 2.0
	RecoilInterpSpeed = 30.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 6.0
	MaxSpread = 0.2
	RecoilSpreadIncreasePerShot = 0.00025
	RecoilSpreadDeclineSpeed = 0.3
	RecoilSpreadDecreaseDelay = 0.2
	RecoilSpreadCrosshairScaling = 1000

    bInstantHit=true
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=false
    GroupWeight=1
    AimError=600

	InventoryGroup=2

    ShotCost(0)=1
    ShotCost(1)=2
	
    FireInterval(0)=+0.12
    FireInterval(1)=+0.25
    ReloadTime(0) = 3.0
    ReloadTime(1) = 3.0
    
    EquipTime=1.0
//	PutDownTime=0.7

    Spread(0)=0.01
    Spread(1)=0.01
    
    WeaponRange=3000.0

    InstantHitDamage(0)=24 //20
	
	HeadShotDamageMult=2.0
	
    InstantHitMomentum(0)=10000.0

    WeaponFireTypes(0)=EWFT_InstantHit
    WeaponFireTypes(1)=EWFT_Projectile

	WeaponProjectiles(0)=class'Rx_Projectile_TiberiumAutoRifle_Blue'
    WeaponProjectiles(1)=class'Rx_Projectile_TiberiumAutoRifle_Blue'

    InstantHitDamageTypes(0)=class'Rx_DmgType_TiberiumAutoRifle_Flechette_Blue'
	InstantHitDamageTypes(1)=class'Rx_DmgType_TiberiumAutoRifle_Blue' //Stand in to make headshots still able to track damage types. 

    ClipSize = 50
    InitalNumClips = 7
    MaxClips = 7

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
	ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"

    WeaponFireSnd[0]=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Fire_Pirmary'
    WeaponFireSnd[1]=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Fire'
	
	WeaponPutDownSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_PutDownCue'
	WeaponEquipSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_EquipCue'
	ReloadSound(0)=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Reload'
	ReloadSound(1)=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_TiberiumAutoRifle_Reload'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
	
	
	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_MuzzleFlash_1P_Blue'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_Blue_MuzzleFlash'

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
	bIronSightCapable = false	
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
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_TiberiumAutoRifle_Blue'
}