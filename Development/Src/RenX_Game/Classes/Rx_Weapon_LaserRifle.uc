class Rx_Weapon_LaserRifle extends Rx_Weapon_Reloadable;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function BurstSecondShot()
{
	if(HasAmmo(CurrentFireMode))
	{
		Super.FireAmmunition();
		WeaponPlaySound( WeaponDistantFireSnd );
		SetTimer(TimeBetweenBursts,False,'BurstThirdFire');
	}
	else
	{
		bIsInBurstFire = false;
	}
}

simulated function BurstThirdFire()
{
	if (HasAmmo(CurrentFireMode))
	{
		Super.FireAmmunition();
		WeaponPlaySound( WeaponDistantFireSnd );
	}

	bIsInBurstFire = false;
}

simulated function FireButtonPressed( optional byte FireMode )
{
	bCurrentlyFireing = false;
}

simulated function FireButtonReleased( optional byte FireMode )
{
	bCurrentlyFireing = false;
}


/* Overriding FireAmmuntion to implement the different fire modes */
simulated function FireAmmunition()
{

	if ( !bCurrentlyFireing || bConstantFire)
	{
		Super.FireAmmunition();
		WeaponPlaySound( WeaponDistantFireSnd );

		/**SetTimer(TimeBetweenBursts,false,'BurstSecondShot');
		bCurrentlyFireing = true;*/
	}

}

simulated function bool IsInstantHit()
{
	return true; 
}

DefaultProperties
{
    // Weapon SkeletalMesh
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_LaserRifle.Mesh.SK_WP_LaserRifle_1P'
        AnimSets(0)=AnimSet'RX_WP_LaserRifle.Anims.AS_WP_LaserRifle_1P'
        Animations=MeshSequenceA
        FOV=55.0
		Scale=2.0
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_LaserRifle.Mesh.SK_WP_LaserRifle_Back'
        Scale=1.0
    End Object

    AttachmentClass = class'Rx_Attachment_LaserRifle'
	
	ArmsAnimSet = AnimSet'RX_WP_LaserRifle.Anims.AS_WP_LaserRifle_Arms'
	
	PlayerViewOffset=(X=-5.0,Y=-1.0,Z=2.0)
	JumpDamping = 1.0
	
	LeftHandIK_Relaxed_Offset = (X=2.250000,Y=0.720000,Z=0.000000)
	LeftHandIK_Relaxed_Rotation = (Pitch=-2912,Yaw=0,Roll=364)
	RightHandIK_Relaxed_Offset = (X=-2.000000,Y=2.000000,Z=-5.000000)
	RightHandIK_Relaxed_Rotation = (Pitch=-3822,Yaw=910,Roll=8192)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 35.0
	MaxRecoil = 40.0
	MaxTotalRecoil = 2000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 20.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 5.0
	MaxSpread = 0.03
	RecoilSpreadIncreasePerShot = 0.0010
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadDecreaseDelay = 0.45
	RecoilSpreadCrosshairScaling = 1000;
	
	CrosshairWidth = 195
	CrosshairHeight = 195

    ShotCost(0)=1
    ShotCost(1)=0
	
	bBurstFire = true 
	TimeBetweenBursts=0.06f
	bConstantFire = true
	Burst_Cooldown(0) = 0.3
	Burst_Cooldown(1) = 0.3
	

    FireInterval(0)=+0.5f
    FireInterval(1)=+0.5f
	
    ReloadTime(0) = 3.667
    ReloadTime(1) = 3.667
    
    EquipTime=0.75
//	PutDownTime=0.5
    
    WeaponRange=6000.0
  
    LockerRotation=(pitch=0,yaw=0,roll=-16384)

    WeaponFireTypes(0)=EWFT_InstantHit
    WeaponFireTypes(1)=EWFT_None

    InstantHitDamage(0)=15
    InstantHitDamage(1)=0
	
	HeadShotDamageMult=2.0
   
//    BotDamagePercentage = 0.6;

    InstantHitDamageTypes(0)=class'Rx_DmgType_LaserRifle'
    InstantHitDamageTypes(1)=None

    InstantHitMomentum(0)=10000
    InstantHitMomentum(1)=0

    Spread(0)=0.002
    Spread(1)=0.0
 
    ClipSize = 30
    InitalNumClips = 7
    MaxClips = 7
	bHasInfiniteAmmo=true

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
    ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
    
    WeaponADSFireAnim[0]="WeaponFireADS"
	ArmADSFireAnim[0]="WeaponFireADS"

    WeaponFireSnd[0]=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Fire'
    WeaponFireSnd[1]=none
	
	WeaponDistantFireSnd=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_DistantFire'

    WeaponPutDownSnd=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_PutDown'
    WeaponEquipSnd=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Equip'
    ReloadSound(0)=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Reload'
    ReloadSound(1)=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Reload'

    PickupSound=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Equip'

    FireSocket="MuzzleFlashSocket"

    MuzzleFlashSocket="MuzzleFlashSocket"
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_1P'
	MuzzleFlashPSCTemplate_Heroic=ParticleSystem'RX_WP_LaserRifle.Effects.P_LaserRifle_MuzzleFlash_1P_Blue'
    MuzzleFlashDuration=3.3667
    MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

    CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'

    InventoryGroup=2.1
    GroupWeight=1
    InventoryMovieGroup=10

	WeaponIconTexture=Texture2D'RX_WP_LaserRifle.UI.T_WeaponIcon_LaserRifle'
    
    // AI Hints:
    //MaxDesireability=0.7
    AIRating=+0.4
    CurrentRating=+0.4
    bFastRepeater=true
    bInstantHit=true
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=false 
    bOkAgainstBuildings=true	
	bOkAgainstVehicles=true	
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	bDisplayCrosshairInIronsight = false
	IronSightViewOffset=(X=-5.0,Y=-7.36,Z=2.425)
	IronSightFireOffset=(X=-8,Y=0,Z=-5)
	IronSightBobDamping=30
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=55.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=220.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 2					// 2		1.5
	IronSightMaxRecoilDamping = 2					// 2		1.5
	IronSightMaxTotalRecoilDamping = 2				// 2		1.5
	IronSightRecoilYawDamping = 1					// 1		1.0
	IronSightMaxSpreadDamping = 2					// 2		1.5
	IronSightSpreadIncreasePerShotDamping = 50		// 4		1.7
    
	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_LaserRifle'
	
	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.10 
	Vet_DamageModifier(2)=1.25 
	Vet_DamageModifier(3)=1.50 
	
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)	
	Vet_ClipSizeModifier(1)=6 //Veteran 
	Vet_ClipSizeModifier(2)=12 //Elite
	Vet_ClipSizeModifier(3)=18 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	bLocSync = true; 
	LocSyncIncrement = 12; 
}
