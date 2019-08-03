class Rx_Weapon_AutoRifle extends Rx_Weapon_Charged // Rx_Weapon_Reloadable
	abstract;

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


DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_AutoRifle.Mesh.SK_AutoRifle_1P_NewRig'
		AnimSets(0)=AnimSet'RX_WP_AutoRifle.Anims.AS_Autorifle_Alternative'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=50.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_AutoRifle.Mesh.SK_WP_AR_Back'
		// Translation=(X=-15)
		Scale=1.0
	End Object

	AttachmentClass = class'Rx_Attachment_AutoRifle'
	
	ArmsAnimSet = AnimSet'RX_WP_AutoRifle.Anims.AS_Autorifle_Arms_Alternative'
	
	PlayerViewOffset=(X=6.0,Y=1.0,Z=-1.0)
	
	FireOffset=(X=10,Y=7,Z=-7)
	
	LeftHandIK_Relaxed_Offset = (X=3.0,Y=-1.0,Z=4.0)

	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 65.0						// 50.0			120
	MaxRecoil = 70.0						// 45.0			150
	MaxTotalRecoil = 5000.0					// 1000.0
	RecoilYawModifier = 0.5 				// will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 15.0				// 37.0			50
	RecoilDeclinePct = 0.6
	RecoilDeclineSpeed = 6.0				// 4.0
	MaxSpread = 0.03						// 0.06			0.08
	RecoilSpreadIncreasePerShot = 0.0005	// 0.002		0.006
	RecoilSpreadDeclineSpeed = 0.2			// 0.1
	RecoilSpreadDecreaseDelay = 0.15
	RecoilSpreadCrosshairScaling = 1500;	// 2500

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.1
	FireInterval(1)=+0
	ReloadTime(0) = 2.5
	ReloadTime(1) = 1.5
	
	EquipTime=0.5
//	PutDownTime=0.35

	WeaponRange=9000 //12000//6000.0
	
	InstantHitDamage(0)=8
	InstantHitDamage(1)=8
	
	HeadShotDamageMult=4.0 //3.0

	InstantHitDamageTypes(0)=class'Rx_DmgType_AutoRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_AutoRifle'

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=10000
	
/*
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=8
	InstantHitDamage(1)=8
	
	HeadShotDamageMult=3.0

	InstantHitDamageTypes(0)=class'Rx_DmgType_AutoRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_AutoRifle'

	InstantHitMomentum(0)=10000
	InstantHitMomentum(1)=10000
	
	bInstantHit=true
*/
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None

    Spread(0)=0.0015
	Spread(1)=0.0015
	
	ClipSize = 100
	InitalNumClips = 8
	MaxClips = 8
	
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

//	WeaponFireSnd[0]=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_FireCue'
//	WeaponFireSnd[1]=none
	
	WeaponPreFireSnd[0]=none
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_AutoRifle.Sounds.SC_AutoRifle_FireLoop'
    WeaponFireSnd[1]=none
    WeaponPostFireSnd[0]=SoundCue'RX_WP_AutoRifle.Sounds.SC_AutoRifle_FireStop'
    WeaponPostFireSnd[1]=none

	WeaponPutDownSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_PutDownCue'
	WeaponEquipSnd=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_EquipCue'
	ReloadSound(0)=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_ReloadCue'
	ReloadSound(1)=SoundCue'RX_WP_AutoRifle.Sounds.AutoRifle_ReloadCue'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
 
	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	CrosshairWidth = 195
	CrosshairHeight = 195

	InventoryGroup=2.1
	GroupWeight=1
	InventoryMovieGroup=2

	WeaponIconTexture=Texture2D'RX_WP_AutoRifle.UI.T_WeaponIcon_AutoRifle'

	// DroppedPickupClass = class'RxDroppedPickup_AutoRifle'
	
	// AI Hints:
	//MaxDesireability=0.7
	AIRating=+0.3
	CurrentRating=+0.3
	bFastRepeater=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false	
	
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-3,Y=-6.475,Z=0.58)		//(X=-5,Y=-6.5145,Z=0.58)
	IronSightFireOffset=(X=10,Y=0,Z=0)
	IronSightBobDamping=30
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	//ZoomedFOVSub=35.0 
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
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_AutoRifle'
	
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
	Vet_ClipSizeModifier(1)=10 //Veteran 
	Vet_ClipSizeModifier(2)=25 //Elite
	Vet_ClipSizeModifier(3)=50 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=1 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.8 //Heroic
	
	VeterancyFireTypes(0) = (Firetype = EWFT_InstantHit, MinRank = 3)
	/**********************/
}
