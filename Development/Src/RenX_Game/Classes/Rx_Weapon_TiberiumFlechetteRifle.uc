class Rx_Weapon_TiberiumFlechetteRifle extends Rx_Weapon_Charged;	

DefaultProperties
{
	bAutoFire = true
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumFlechetteRifle.Mesh.SK_WP_TiberiumFlechetteRifle_1P'
		AnimSets(0)=AnimSet'RX_WP_TiberiumFlechetteRifle.Anims.AS_TFR_1P'
		Animations=MeshSequenceA
		Scale=2.5
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumFlechetteRifle.Mesh.SK_WP_TiberiumFlechetteRifle_Back'
		Scale=1.0
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_TiberiumFlechetteRifle.Anims.AS_TFR_Arms'

	AttachmentClass = class'Rx_Attachment_TiberiumFlechetteRifle'
	
	PlayerViewOffset=(X=5.0,Y=-3,Z=2.0)
	
	LeftHandIK_Offset=(X=1,Y=8,Z=1)
	RightHandIK_Offset=(X=2,Y=-2,Z=-5)
	
	FireOffset=(X=20,Y=8,Z=-8)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 50.0
	MaxRecoil = 60.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 
	RecoilInterpSpeed = 40.0
	RecoilDeclinePct = 0.25
	RecoilDeclineSpeed = 4.0
	MaxSpread = 0.1
	RecoilSpreadIncreasePerShot = 0.0005	
	RecoilSpreadDeclineSpeed = 0.8
	RecoilSpreadDecreaseDelay = 0.15
	RecoilSpreadCrosshairScaling = 1000;
	
	CrosshairWidth = 210 	// 256
	CrosshairHeight = 210 	// 256

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.1
	FireInterval(1)=+0.0
	ReloadTime(0) = 2.9
	ReloadTime(1) = 2.9
	
	EquipTime=0.45
//	PutDownTime=0.35

    LockerRotation=(pitch=0,yaw=0,roll=-16384)
	
	WeaponRange=5000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=14
	InstantHitDamage(1)=14
	
	HeadShotDamageMult=2.5

	InstantHitDamageTypes(0)=class'Rx_DmgType_TiberiumFlechetteRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_TiberiumFlechetteRifle'

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=10000
	
	bInstantHit=true
/*
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None
	
	WeaponProjectiles(0)=class'RenX_Game.Rx_Projectile_TiberiumFlechetteRifle'
	WeaponProjectiles(1)=class'RenX_Game.Rx_Projectile_TiberiumFlechetteRifle'
*/
	Spread(0)=0.003
	Spread(1)=0.0
	
	ClipSize = 50
	InitalNumClips = 5
	MaxClips = 5
	
	FireDelayTime = 0.01
	bCharge = true
	bHasInfiniteAmmo = false;

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
    WeaponPostFireAnim[0]="WeaponFireEnd"
    WeaponPostFireAnim[1]="WeaponFireEnd"

    ArmPreFireAnim[0]="WeaponFireStart"
    ArmPreFireAnim[1]="WeaponFireStart"
    ArmFireAnim[0]="WeaponFireloop"
    ArmFireAnim[1]="WeaponFireloop"
    ArmPostFireAnim[0]="WeaponFireEnd"
    ArmPostFireAnim[1]="WeaponFireEnd"	
	
	WeaponPreFireSnd[0]=none
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_TiberiumFlechetteRifle.Sounds.SC_TiberiumFlechetteRifle_FireLoop'
    WeaponFireSnd[1]=none
    WeaponPostFireSnd[0]=SoundCue'RX_WP_TiberiumFlechetteRifle.Sounds.SC_TiberiumFlechetteRifle_FireStop'
    WeaponPostFireSnd[1]=none


//	WeaponFireSnd[0]=SoundCue'RX_WP_TiberiumFlechetteRifle.Sounds.SC_TiberiumFlechetteRifle_Fire'
//    WeaponFireSnd[1]=none
	
	WeaponPutDownSnd=SoundCue'RX_WP_TiberiumFlechetteRifle.Sounds.SC_TiberiumFlechetteRifle_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TiberiumFlechetteRifle.Sounds.SC_TiberiumFlechetteRifle_Equip'
	ReloadSound(0)=SoundCue'RX_WP_TiberiumFlechetteRifle.Sounds.SC_TiberiumFlechetteRifle_Reload'
	ReloadSound(1)=SoundCue'RX_WP_TiberiumFlechetteRifle.Sounds.SC_TiberiumFlechetteRifle_Reload'

	PickupSound=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TiberiumFlechetteRifle.Effects.P_MuzzleFlash_1P'
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=class'Rx_Light_TiberiumFlechetteRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'	// MaterialInstanceConstant'RenXHud.MI_Reticle_Pistol'

	InventoryGroup=1
	InventoryMovieGroup=34
	
	WeaponIconTexture=Texture2D'RX_WP_TiberiumFlechetteRifle.UI.T_WeaponIcon_TiberiumFlechetteRifle'

	// AI Hints:
	//MaxDesireability=0.3
	AIRating=+0.1
	CurrentRating=+0.1	
	bFastRepeater=true
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=5,Y=-12.0,Z=3.9)
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
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_TiberiumFlechetteRifle'
}
