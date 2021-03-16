class Rx_Weapon_RocketLauncher extends Rx_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return true; //false;
}

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RocketLauncher.Mesh.SK_RocketLauncher_1P'
		AnimSets(0)=AnimSet'RX_WP_RocketLauncher.Anims.AS_RocketLauncher_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_Back'
		//Translation=(X=-25)
		Scale=1.0
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_RocketLauncher.Anims.AS_RocketLauncher_Arms'

	AttachmentClass = class'Rx_Attachment_RocketLauncher'
	
	FireOffset=(X=35,Y=17,Z=-20)
	
	PlayerViewOffset=(X=10.0,Y=-6.0,Z=-4.0)
	
	LeftHandIK_Offset=(X=-3.801600,Y=-3.320000,Z=1.830000)
	LeftHandIK_Rotation = (Pitch=-1638,Yaw=-9466,Roll=4004)
	RightHandIK_Offset=(X=0,Y=0,Z=0) //(X=-3,Y=-4,Z=-2)
	
	LeftHandIK_Relaxed_Offset = (X=-2.314000,Y=-4.319300,Z=3.443500)
	LeftHandIK_Relaxed_Rotation = (Pitch=5643,Yaw=-1092,Roll=-1456)
	
	bOverrideLeftHandAnim=true
	LeftHandAnim=H_M_Hands_Closed
	
	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.5
	MinRecoil = -100.0
	MaxRecoil = -150.0
	MaxTotalRecoil = 1000.0
	RecoilYawModifier = 0.1 // will be a random value between 0 and this value for every shot
	RecoilYawMultiplier = 2.0
	RecoilInterpSpeed = 45.0
	RecoilDeclinePct = 1.0
	RecoilDeclineSpeed = 10.0
	RecoilSpread = 0.0
	MaxSpread = 0.1
	RecoilSpreadIncreasePerShot = 0.01
	RecoilSpreadDeclineSpeed = 0.025
	RecoilSpreadCrosshairScaling = 3000;

	ShotCost(0)=1
	ShotCost(1)=1
	FireInterval(0)=+1.0
	FireInterval(1)=+0.0
	ReloadTime(0) = 4.0 //3.3667
	ReloadTime(1) = 4.0 //3.3667
	
	EquipTime=0.75
//	PutDownTime=0.75

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None
	
	WeaponProjectiles(0)=class'Rx_Projectile_RocketLauncher'
	WeaponProjectiles_Heroic(0)=class'Rx_Projectile_RocketLauncher_Heroic'

	Spread(0)=0.001
	Spread(1)=0.0

	ClipSize = 6
	InitalNumClips = 11
	MaxClips = 11

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadAnim3PName(0) = "H_M_RocketLauncher_Reload"
	ReloadAnim3PName(1) = "H_M_RocketLauncher_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"

	WeaponFireSnd[0]=SoundCue'RX_WP_RocketLauncher.Sounds.RocketLauncher_FireCue'
	WeaponFireSnd[1]=SoundCue'RX_WP_RocketLauncher.Sounds.RocketLauncher_FireCue'


	WeaponFireSnd_Heroic[0]=SoundCue'RX_WP_RocketLauncher.Sounds.RocketLauncher_FireCue_Heroic'
	
	WeaponDistantFireSnd=SoundCue'RX_WP_RocketLauncher.Sounds.SC_RocketLauncher_DistantFire'

	WeaponPutDownSnd=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Lower_Cue'
	WeaponEquipSnd=SoundCue'RX_WP_RocketLauncher.Sounds.RocketLauncher_EquipCue'
	ReloadSound(0)=SoundCue'RX_WP_RocketLauncher.Sounds.RocketLauncher_ReloadCue'
	ReloadSound(1)=SoundCue'RX_WP_RocketLauncher.Sounds.RocketLauncher_ReloadCue'

	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Link_Cue'

	MuzzleFlashSocket="MuzzleFlashSocket"
	FireSocket = "MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_ChainGun.Effects.P_MuzzleFlash_1P'
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_RocketLauncher'

	InventoryGroup=2
	InventoryMovieGroup=8

	WeaponIconTexture=Texture2D'RX_WP_RocketLauncher.UI.T_WeaponIcon_RocketLauncher'
	
	// AI Hints:
	//MaxDesireability=0.7
	AIRating=+0.4
	CurrentRating=+0.4
	bFastRepeater=false
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=true
	bSniping=false	
	bOkAgainstBuildings=true	
	bOkAgainstVehicles=true	
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = false	
	bDisplayCrosshairInIronsight = true
	IronSightViewOffset=(X=-12,Y=-4,Z=6)
	IronSightFireOffset=(X=35,Y=10,Z=-10)
	IronSightBobDamping=1
	IronSightPostAnimDurationModifier=1.0
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=45.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=180
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 2
	IronSightMaxRecoilDamping = 2
	IronSightMaxTotalRecoilDamping = 2
	IronSightRecoilYawDamping = 1
	IronSightMaxSpreadDamping = 4
	IronSightSpreadIncreasePerShotDamping = 4

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_RocketLauncher'
	
	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.10 
	Vet_DamageModifier(2)=1.25 
	Vet_DamageModifier(3)=1.50 
	
	Vet_ROFModifier(0) = 1
	Vet_ROFModifier(1) = 0.95  
	Vet_ROFModifier(2) = 0.90  
	Vet_ROFModifier(3) = 0.8  
	
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)	
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=0 //Elite
	Vet_ClipSizeModifier(3)=0 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	Elite_Building_DamageMod = 1.25 //15//1.33
}
