class Rx_Weapon_LaserChainGun extends Rx_Weapon_Charged;


var MaterialInstanceConstant	MCounterHundreds, MCounterTens, MCounterOnes;
var MaterialInterface TeamSkin;
var byte TeamIndex;



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MCounterOnes = Mesh.CreateAndSetMaterialInstanceConstant(1);
	MCounterTens = Mesh.CreateAndSetMaterialInstanceConstant(2);
	MCounterHundreds = Mesh.CreateAndSetMaterialInstanceConstant(3);
}

simulated function UpdateAmmoCounter()
{
	local int Ones, Tens, Hundreds;
	if ( WorldInfo.NetMode != NM_DedicatedServer)
	{
		Ones = CurrentAmmoInClip%10;
		Tens = ((CurrentAmmoInClip - Ones)/10)%10;
		Hundreds = (CurrentAmmoInClip > 99 ? 1 : 0); // right way to go, it's never bigger then 100 (should be)
		MCounterOnes.SetScalarParameterValue('OnesClamp', Float(Ones));
		MCounterTens.SetScalarParameterValue('TensClamp', Float(Tens));
		MCounterHundreds.SetScalarParameterValue('HundredsClamp', Float(Hundreds));
	}
}

simulated function SetSkin(Material NewMaterial)
{
	if( ( Instigator != none ) && ( NewMaterial == none ) ) 	// Clear the materials
	{

		Mesh.SetMaterial(0,TeamSkin);

        MCounterOnes.SetScalarParameterValue('TeamColour', TeamIndex);
        MCounterTens.SetScalarParameterValue('TeamColour', TeamIndex);
        MCounterHundreds.SetScalarParameterValue('TeamColour', TeamIndex);
	}
	else
	{
		Super.SetSkin(NewMaterial);
	}
}

simulated function PerformRefill()
{
	Super.PerformRefill();

	UpdateAmmoCounter();
} 

simulated function ConsumeAmmo( byte FireModeNum )
{
    super.ConsumeAmmo(FireModeNum);
    UpdateAmmoCounter();
}

simulated function Activate()
{
    UpdateAmmoCounter();
    super.Activate();
}

simulated function PostReloadUpdate()
{
    UpdateAmmoCounter();
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
        SkeletalMesh=SkeletalMesh'RX_WP_LaserChaingun.Meshes.SK_LaserChainGun_1P'
        AnimSets(0)=AnimSet'RX_WP_LaserChaingun.Anims.AS_LCG_1P'
        Animations=MeshSequenceA
		Scale=2.0
        FOV=55.0
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_LaserChaingun.Meshes.SK_WP_LaserChaingun_Back'
        Scale=1.0
    End Object

    AttachmentClass = class'Rx_Attachment_LaserChainGun'
	
	ArmsAnimSet = AnimSet'RX_WP_LaserChaingun.Anims.AS_LCG_Arms'
	
	PlayerViewOffset=(X=-4.0,Y=-2.0,Z=-2.0)
	
	LeftHandIK_Offset=(X=-6.102400,Y=-2.950000,Z=4.731000)
	LeftHandIK_Rotation=(Pitch=3458,Yaw=-364,Roll=-2730)
	RightHandIK_Offset=(X=-2,Y=-8,Z=-1)
	
	LeftHandIK_Relaxed_Offset = (X=-0.110000,Y=-5.445000,Z=5.880000)
	LeftHandIK_Relaxed_Rotation = (Pitch=4733,Yaw=3640,Roll=4915)

	
	TeamIndex = 1 
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 30.0
	MaxRecoil = 40.0
	MaxTotalRecoil = 2000.0
	RecoilYawModifier = 0.5
	RecoilYawMultiplier = 4.0
	RecoilInterpSpeed = 15.0
	RecoilDeclinePct = 0.8
	RecoilDeclineSpeed = 2.0
	MaxSpread = 0.08//0.06
	RecoilSpreadIncreasePerShot = 0.001
	RecoilSpreadDeclineSpeed = 0.075
	RecoilSpreadDecreaseDelay = 0.15
	RecoilSpreadCrosshairScaling = 1500;

    ShotCost(0)=1
    ShotCost(1)=0
    FireInterval(0)=+0.1
    FireInterval(1)=+0.0
    ReloadTime(0) = 3.5
    ReloadTime(1) = 3.5
    
    EquipTime=1.0
//	PutDownTime=0.75
    
    WeaponRange=6000.0

    LockerRotation=(pitch=0,yaw=0,roll=-16384)

    WeaponFireTypes(0)=EWFT_InstantHit
    WeaponFireTypes(1)=EWFT_None

    InstantHitDamage(0)=16
    InstantHitDamage(1)=0
	
	HeadShotDamageMult= 1.25 //1.4 //2.0 I cry 
    
//	BotDamagePercentage = 0.6;

    InstantHitDamageTypes(0)=class'Rx_DmgType_LaserChainGun'
    InstantHitDamageTypes(1)=none

    InstantHitMomentum(0)=10000
    InstantHitMomentum(1)=0

    Spread(0)=0.0045
    Spread(1)=0.0
 
    ClipSize = 100 //120
    InitalNumClips = 5
    MaxClips = 5
	bHasInfiniteAmmo=true
	
	FireDelayTime = 1.0 //0.01
	bCharge = true

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_RocketLauncher_Reload"
    ReloadAnim3PName(1) = "H_M_RocketLauncher_Reload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
   
    WeaponPreFireAnim[0]="WeaponFireStart"
    WeaponPreFireAnim[1]="WeaponFireStart"
    WeaponFireAnim[0]="WeaponFireLoop"
    WeaponFireAnim[1]="WeaponFireLoop"
    WeaponPostFireAnim[0]="WeaponFireEnd"
    WeaponPostFireAnim[1]="WeaponFireEnd"

    ArmPreFireAnim[0]="WeaponFireStart"
    ArmPreFireAnim[1]="WeaponFireStart"
    ArmFireAnim[0]="WeaponFireLoop"
    ArmFireAnim[1]="WeaponFireLoop"
    ArmPostFireAnim[0]="WeaponFireEnd"
    ArmPostFireAnim[1]="WeaponFireEnd"
    
    WeaponPreFireSnd[0]= SoundCue'RX_WP_LaserChaingun.Sounds.SC_LaserChainGun_Fire_Start' //none 
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_LaserChaingun.Sounds.SC_LaserChainGun_Fire_Loop'
    WeaponFireSnd[1]=none
    WeaponPostFireSnd[0]=SoundCue'RX_WP_LaserChaingun.Sounds.SC_LaserChainGun_Fire_Stop'
    WeaponPostFireSnd[1]=none


    WeaponPutDownSnd=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_PutDown'
    WeaponEquipSnd=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Equip'
    ReloadSound(0)=SoundCue'RX_WP_LaserChaingun.Sounds.SC_LaserChainGun_Reload'
    ReloadSound(1)=SoundCue'RX_WP_LaserChaingun.Sounds.SC_LaserChainGun_Reload'

    PickupSound=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_Equip'

    FireSocket="MuzzleFlashSocket"

    MuzzleFlashSocket="MuzzleFlashSocket"
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_LaserChaingun.Effects.P_LaserChainGun_MuzzleFlash_1P'
	MuzzleFlashPSCTemplate_Heroic=ParticleSystem'RX_WP_LaserChaingun.Effects.P_LaserChainGun_MuzzleFlash_1P_Blue'
    MuzzleFlashDuration=3.3667
    MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'
	
	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_RocketLauncher'
	CrosshairWidth = 180 	// 256
	CrosshairHeight = 180 	// 256

    InventoryGroup=2.1
    GroupWeight=1
    InventoryMovieGroup=15

	WeaponIconTexture=Texture2D'RX_WP_LaserChaingun.UI.T_WeaponIcon_LaserChainGun'
    
    // AI Hints:
    // MaxDesireability=0.7
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
	bIronSightCapable = false
	bDisplayCrosshairInIronsight = true
	IronSightViewOffset=(X=-12.0,Y=-6.0,Z=0.0)
	IronSightFireOffset=(X=0,Y=0,Z=-5)
	IronSightBobDamping=1
	IronSightPostAnimDurationModifier=1.0
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=25.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=60
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 2
	IronSightMaxRecoilDamping = 2
	IronSightMaxTotalRecoilDamping = 2
	IronSightRecoilYawDamping = 1
	IronSightMaxSpreadDamping = 2
	IronSightSpreadIncreasePerShotDamping = 4

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_LaserChainGun'
	
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
	Vet_ROFModifier(3) = 0.85  
	
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)	
	Vet_ClipSizeModifier(1)=10 //Veteran 
	Vet_ClipSizeModifier(2)=25 //Elite
	Vet_ClipSizeModifier(3)=50 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	bLocSync = true; 
	LocSyncIncrement = 30; 
	
	Vet_ChargeRateModifier(0) = 1.0
	Vet_ChargeRateModifier(1) = 0.75 
	Vet_ChargeRateModifier(2) = 0.50  
	Vet_ChargeRateModifier(3) = 0.25  
}
	