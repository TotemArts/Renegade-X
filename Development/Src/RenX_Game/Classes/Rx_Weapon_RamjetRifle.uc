class Rx_Weapon_RamjetRifle extends Rx_Weapon_Scoped;

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

defaultproperties
{
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

	// Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_Ramjet.Mesh.SK_RamjetRifle_1P'
        AnimSets(0)=AnimSet'RX_WP_Ramjet.Anims.AS_RamjetRifle_1P'
        Animations=MeshSequenceA
        FOV=55//50
		Scale=2.0
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_Ramjet.Mesh.SK_WP_Ramjet_Back'
        //Translation=(X=-5)
        Scale=1.0
    End Object

    AttachmentClass=class'Rx_Attachment_RamjetRifle'
	
	LeftHandIK_Offset=(X=0.0,Y=0.0,Z=0.0)
	RightHandIK_Offset=(X=2.0,Y=2.0,Z=-1.0)
	
	LeftHandIK_Relaxed_Offset = (X=0.000000,Y=-0.500000,Z=0.000000)
	LeftHandIK_Relaxed_Rotation = (Pitch=-3640,Yaw=0,Roll=0)
	RightHandIK_Relaxed_Offset = (X=0.000000,Y=2.000000,Z=-4.000000)
	RightHandIK_Relaxed_Rotation = (Pitch=-2730,Yaw=2730,Roll=5461)

    ArmsAnimSet=AnimSet'RX_WP_Ramjet.Anims.AS_RamjetRifle_Arms'
	
	FireOffset=(X=0,Y=0,Z=-3)	//(X=0,Y=7,Z=-5)
	
	//-------------- Recoil
	RecoilDelay = 0.05
	MinRecoil = 300.0
	MaxRecoil = 400.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 40.0
	RecoilDeclinePct = 0.8
	RecoilDeclineSpeed = 5.0
	MaxSpread = 0.12
	RecoilSpreadIncreasePerShot = 0.0
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadDecreaseDelay = 0.3
	RecoilSpreadCrosshairScaling = 4000;	// 2500

    bAutoFire = false
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	GroupWeight=1
	AimError=600

    PlayerViewOffset=(X=12.0,Y=1.0,Z=-2.75)

    InventoryGroup=2

    ShotCost(0)=1
    ShotCost(1)=0
    FireInterval(0)=+1.0
    FireInterval(1)=+1.0
    
    EquipTime=1.0
//	PutDownTime=0.75
    
    Spread(0)=0.15 //0.08 //0.0
	IronSightAndScopedSpread(0)= 0.0
 
	WeaponFireTypes(0)=EWFT_InstantHit
//    WeaponFireTypes(0)=EWFT_Projectile
    
	InstantHitDamageTypes(0)=class'Rx_DmgType_RamjetRifle'
	InstantHitDamage(0)=180
	InstantHitMomentum(0)=10000.0
    
//    WeaponProjectiles(0)=class'Rx_Projectile_RamjetRifle'

    FiringStatesArray(1)=Active


    ClipSize = 4
    InitalNumClips = 9
    MaxClips = 9
    
    PerBulletReload = true
    /** Shotgun uses a 3-state reloading system **/
    ReloadAnimName(2) = "WeaponReloadStart"
    ReloadArmAnimName(2) = "WeaponReloadStart"
    ReloadAnim3PName(2) = "H_M_Shotgun_Reload_Start"
    ReloadSound(2)=SoundCue'RX_WP_Ramjet.Sounds.SC_Ramjet_Reload_Start'
    ReloadTime(2) = 0.6
    ReloadAnimName(1) = "WeaponReloadLoop"
    ReloadArmAnimName(1) = "WeaponReloadLoop"
    ReloadAnim3PName(1) = "H_M_Shotgun_Reload_Loop"
    ReloadSound(1)=SoundCue'RX_WP_Ramjet.Sounds.SC_Ramjet_Reload_Loop'
    ReloadTime(1) = 0.7
    ReloadAnimName(0) = "WeaponReloadStop"
    ReloadArmAnimName(0) = "WeaponReloadStop"
    ReloadAnim3PName(0) = "H_M_Shotgun_Reload_Stop"
    ReloadSound(0)=SoundCue'RX_WP_Ramjet.Sounds.SC_Ramjet_Reload_Stop'
    ReloadTime(0) = 1.7

    WeaponFireSnd[0]=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_FireCue'
    WeaponFireSnd[1]=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_FireCue'
	
	WeaponDistantFireSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_SniperRifle_DistantFire'

    WeaponPutDownSnd=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_PutDownCue'
    WeaponEquipSnd=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_EquipCue'

    PickupSound=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'

    MuzzleFlashSocket=MuzzleFlashSocket
    FireSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_Ramjet.Effects.P_MuzzleFlash_1P'
    MuzzleFlashDuration=0.1
    MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

    // Configure the zoom
    HudMaterial=Material'RenX_AssetBase.PostProcess.M_SniperScope_2'

    bZoomedFireMode(0)=0
    bZoomedFireMode(1)=1
    
	CrosshairWidth = 256
	CrosshairHeight = 256
	
	//CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'
	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_SniperRifle'
//  CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_None'
	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_None'

    CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
    IconCoordinates=(U=726,V=532,UL=165,VL=51)
    InventoryMovieGroup=14

	WeaponIconTexture=Texture2D'RX_WP_Ramjet.UI.T_WeaponIcon_Ramjet'

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_RamjetRifle'
	
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
	Vet_ClipSizeModifier(3)=1 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	bLocSync = true; 
	ROFTurnover = 2;
	
	//Bolt Stuff
	BoltActionReload=true
	BoltReloadTime(0) = 1.75 //2.0f (Factor in RefireBoltReloadInterrupt) 
	BoltReloadTime(1) = 1.75 //2.0f

	BoltReloadAnimName(0) = "WeaponBolt"
	BoltReloadAnimName(1) = "WeaponBolt"
	BoltReloadArmAnimName(0) = "WeaponBolt"
	BoltReloadArmAnimName(1) = "WeaponBolt"
	
	BoltReloadSound(0)=SoundCue'RX_WP_Ramjet.Sounds.SC_Ramjet_Reload_Stop'
	BoltReloadSound(1)=SoundCue'RX_WP_Ramjet.Sounds.SC_Ramjet_Reload_Stop'
	
	//For instant hit weapons 
	bPierceInfantry = true
	bPierceVehicles = false
	MaximumPiercingAbility  = 32
	CurrentPiercingPower	= 32

	IronSightViewOffset=(X=4,Y=-6.45,Z=0.0)

    ZoomRecoilMaxIntensity = 0.45
    ZoomRecoilRecoveryRate = 5
    ZoomRecoilRate = 90
}