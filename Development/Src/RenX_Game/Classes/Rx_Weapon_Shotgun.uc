class Rx_Weapon_Shotgun extends Rx_Weapon_Reloadable;

var MaterialImpactEffect DefaultImpactEffect;
var int NumPellets, ShotLayer, NumSpreadLayers;
var bool bUseConstantSpread;

var float LayerDensity;

var float Additive; //Circular additive used in predictable spread pattern  

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function CustomFire()
{
    local int i;
    Rx_Pawn(Owner).ShotgunPelletCount = 0;
    for (i=0; i < NumPellets; i++)
    {
		if(i>0 && Rx_Controller(Instigator.Controller) != none) Rx_Controller(Instigator.Controller).AddShot(); //One gets called in FireAmmunition already 
        super.InstantFire();
        CurrentAmmoInClipClientside++;
    }
    CurrentAmmoInClipClientside--;
	WeaponPlaySound( WeaponDistantFireSnd );
}

/** Modified version of Rx_Weapon::TryHeadshot(...) that allows Shotgun headshots to work. */
simulated function bool TryHeadshot(byte FiringMode, ImpactInfo Impact, optional float DmgReduction = 1.0) 
{
	local float Scaling;
	local int HeadDamage;
    	
	if(FiringMode == 0)
	{
		if (Instigator == None || VSizeSq(Instigator.Velocity) < Square(Instigator.GroundSpeed * Instigator.CrouchedPct))
		{
			Scaling = SlowHeadshotScale;
		}
		else
		{
			Scaling = RunningHeadshotScale;
		}

		HeadDamage = InstantHitDamage[FiringMode]* HeadShotDamageMult;
		if ( (Rx_Pawn(Impact.HitActor) != None && Rx_Pawn(Impact.HitActor).TakeHeadShot(Impact, HeadShotDamageType, HeadDamage, Scaling, Instigator.Controller, false)))
		{
			SetFlashLocation(Impact.HitLocation);
			return true;
		}
	}
	return false;
}

simulated function bool IsInstantHit()
{
	return true; 
}

simulated function rotator AddSpread(rotator BaseAim)
{
	if(bUseConstantSpread) return ShotgunAddSpread(BaseAim); 
	else
	return super.AddSpread(BaseAim);
}

simulated function rotator ShotgunAddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float CurrentSpreadX, RandY, RandZ;
	
	CurrentSpreadX = Spread[CurrentFireMode] + (ShotLayer*1.0*LayerDensity) ;
	

	ShotLayer++;
	if (CurrentSpreadX == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in consistent, circular spread
		GetAxes(BaseAim, X, Y, Z);
		RandY = sin(Additive * DegToRad);
		RandZ = cos(DegToRad*Additive);
		
		Additive += (360.0/NumPellets) ;
		
		if(Additive >= 360) Additive=0; 
		if(ShotLayer >= NumSpreadLayers) ShotLayer=0;
		
		return rotator(X + RandY * CurrentSpreadX * Y + RandZ * CurrentSpreadX * Z);
	}
}

defaultproperties
{
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
        bCauseActorAnimEnd=true
    End Object

    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_Shotgun.Mesh.SK_WP_Shotgun_1P' //SkeletalMesh'RX_WP_Shotgun.Mesh.WP_RenX_Shotgun_1P'
        AnimSets(0)=AnimSet'RX_WP_Shotgun.Anims.AS_Shotgun_1P' //AnimSet'RX_WP_Shotgun.Anims.AS_Shotgun_Weapon'
        Animations=MeshSequenceA
		Scale=2.0
        FOV=50.0
    End Object

    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_Shotgun.Mesh.SK_WP_Shotgun_Back'
        //Translation=(X=-10)
        Scale=1.0
    End Object
	
    ArmsAnimSet = AnimSet'RX_WP_Shotgun.Anims.AS_Shotgun_Arms_Alternative' //AnimSet'RX_WP_Shotgun.Anims.AS_Shotgun_Arms'

    AttachmentClass=class'Rx_Attachment_Shotgun'
	
    PlayerViewOffset=(X=5.0,Y=-3.0,Z=1.5) //(X=7.0,Y=2.5,Z=14.0)
	
	LeftHandIK_Offset=(X=0,Y=0,Z=0)
	RightHandIK_Offset=(X=6,Y=-1,Z=-2)
	
	LeftHandIK_Relaxed_Offset = (X=0.000000,Y=-2.000000,Z=4.000000)

	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 500.0
	MaxRecoil = 550.0
	MaxTotalRecoil = 3000.0
	RecoilYawModifier = 1.0 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 15.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 3.0
	MaxSpread = 0.35
	RecoilSpreadIncreasePerShot = 0.002
	RecoilSpreadDeclineSpeed = 0.05
	RecoilSpreadDecreaseDelay = 0.2

    ShotCost(0)=1
    ShotCost(1)=1
    Spread(0)=0.15
//    Spread(1)=0.3

	IronSightAndScopedSpread(0)= 0.115
    
    EquipTime=0.55
//	PutDownTime=0.4

    NumPellets = 12
    ClipSize = 8
    InitalNumClips = 8
    MaxClips = 8
 
    FireInterval(0)=1.2 //1.5
//    FireInterval(1)=0.65
    
    WeaponFireAnim(0)=WeaponFire
//    WeaponFireAnim(1)=WeaponAltFire
    ArmFireAnim(0)=WeaponFire
//    ArmFireAnim(1)=WeaponAltFire

    WeaponFireTypes(0)=EWFT_Custom
    WeaponFireTypes(1)=EWFT_None
    WeaponRange=1600 //800.0

    InstantHitDamage(0)=13 //10 //12//16
//    InstantHitDamage(1)=16
	
	HeadShotDamageMult=1.25//1.5 //1.25 //1.5
	
    InstantHitDamageTypes(0)=class'Rx_DmgType_Shotgun'
//    InstantHitDamageTypes(1)=class'Rx_DmgType_Shotgun'
	
    InstantHitMomentum(0)=5000
//    InstantHitMomentum(1)=5000


    WeaponFireSnd[0]=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Fire'
//    WeaponFireSnd[1]=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_AltFire'
	
	WeaponDistantFireSnd=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_DistantFire'

    WeaponPutDownSnd=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_PutDown'
    WeaponEquipSnd=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
    PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'

    ShouldFireOnRelease(0)=0
//    ShouldFireOnRelease(1)=0

    AimError=600

    MuzzleFlashSocket=MuzzleFlashSocket
    FireSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_GrenadeLauncher.Effects.MuzzleFlash_1P'
    MuzzleFlashDuration=0.1
    MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'

    PerBulletReload = True
    /** Shotgun uses a 3-state reloading system **/
    ReloadAnimName(2) = "WeaponReloadStart"
    ReloadArmAnimName(2) = "WeaponReloadStart"
    ReloadAnim3PName(2) = "H_M_Shotgun_Reload_Start"
    ReloadSound(2)=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Reload_Start'
    ReloadTime(2) = 0.5
    ReloadAnimName(1) = "WeaponReloadLoop"
    ReloadArmAnimName(1) = "WeaponReloadLoop"
    ReloadAnim3PName(1) = "H_M_Shotgun_Reload_Loop"
    ReloadSound(1)=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Reload_Loop'
    ReloadTime(1) = 0.5
    ReloadAnimName(0) = "WeaponReloadEnd"
    ReloadArmAnimName(0) = "WeaponReloadEnd"
    ReloadAnim3PName(0) = "H_M_Shotgun_Reload_Stop"
    ReloadSound(0)=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Reload_End'
    ReloadTime(0) = 0.5
    
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Shotgun'
	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_None'

    InventoryGroup=2
    GroupWeight=3
    InventoryMovieGroup=7

	WeaponIconTexture=Texture2D'RX_WP_Shotgun.UI.T_WeaponIcon_Shotgun'
    
    // AI Hints:
    // MaxDesireability=0.7
    AIRating=+0.4
    CurrentRating=+0.4
    bFastRepeater=false
    bInstantHit=true
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=false  

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Shotgun'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=10,Y=-7.72,Z=3.73)
	IronSightFireOffset=(X=0,Y=0,Z=0)
	IronSightBobDamping=30
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=35.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=150.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 2					// 2		1.5
	IronSightMaxRecoilDamping = 2					// 2		1.5
	IronSightMaxTotalRecoilDamping = 2				// 2		1.5
	IronSightRecoilYawDamping = 1					// 1		1.0
	IronSightMaxSpreadDamping = 2					// 2		1.5
	IronSightSpreadIncreasePerShotDamping = 50		// 4		1.7
	
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
	Vet_ClipSizeModifier(1)=1 //Veteran 
	Vet_ClipSizeModifier(2)=2 //Elite
	Vet_ClipSizeModifier(3)=4 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	bLocSync = true; 
	LocSyncIncrement = 4; 
	
	bUseConstantSpread = false
	
	NumSpreadLayers = 4//2 //6 
	LayerDensity = 0.02//0.03
	ROFTurnover = 4
}
