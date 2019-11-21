class Rx_Weapon_TacticalRifle extends Rx_Weapon_Charged;


var MaterialInstanceConstant    MCounterTens, MCounterOnes;
var MaterialInterface TeamSkin;
var byte TeamIndex;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MCounterOnes = Mesh.CreateAndSetMaterialInstanceConstant(2);
	MCounterTens = Mesh.CreateAndSetMaterialInstanceConstant(1);
}

simulated function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo(FireModeNum);
	UpdateAmmoCounter();
}

simulated function UpdateAmmoCounter()
{
	local int Ones, Tens;
	if ( WorldInfo.NetMode != NM_DedicatedServer)
	{
		Ones = CurrentAmmoInClip%10;
		Tens = ((CurrentAmmoInClip - Ones)/10)%10;

		MCounterOnes.SetScalarParameterValue('OnesClamp', Float(Ones));
		MCounterTens.SetScalarParameterValue('TensClamp', Float(Tens));
	}
}

simulated function PerformRefill()
{
	Super.PerformRefill();

	UpdateAmmoCounter();
} 

simulated function SetSkin(Material NewMaterial)
{
	if( ( Instigator != none ) && ( NewMaterial == none ) )     // Clear the materials
	{

		Mesh.SetMaterial(0,TeamSkin);

		MCounterOnes.SetScalarParameterValue('TeamColour', TeamIndex);
		MCounterTens.SetScalarParameterValue('TeamColour', TeamIndex);
	}
	else
	{
		Super.SetSkin(NewMaterial);
	}
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

simulated function bool bDrawBackAttachment() 
{
	return Rx_WeaponAbility_TacRifleGrenade(Pawn(Owner).Weapon) == none ; 
}

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TacticalRifle.Mesh.SK_TacticalRifle_1P'
		AnimSets(0)=AnimSet'RX_WP_TacticalRifle.Anims.AS_TacticalRifle_1P'
		Animations=MeshSequenceA
		FOV=55
		Scale=2.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TacticalRifle.Mesh.SK_WP_TacticalRifle_Back'
		// Translation=(X=-5)
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_TacticalRifle'
	
	LeftHandIK_Offset=(X=0.0,Y=0.0,Z=0.0)
	RightHandIK_Offset=(X=-1,Y=2.5,Z=0.0)
	
	LeftHandIK_Relaxed_Offset = (X=2.000000,Y=0.000000,Z=1.000000)
	LeftHandIK_Relaxed_Rotation = (Pitch=-2548,Yaw=-2730,Roll=-1820)
	RightHandIK_Relaxed_Offset = (X=0.000000,Y=2.000000,Z=-5.000000)
	RightHandIK_Relaxed_Rotation = (Pitch=-3094,Yaw=1820,Roll=7099)


	ArmsAnimSet=AnimSet'RX_WP_TacticalRifle.Anims.AS_TacticalRifle_Arms'
	
	FireOffset=(X=10,Y=7,Z=-5)
	
	PlayerViewOffset=(X=2.0,Y=1.0,Z=-1.0)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 70.0
	MaxRecoil = 90.0
	MaxTotalRecoil = 7000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 20.0
	RecoilDeclinePct = 0.4
	RecoilDeclineSpeed = 4.0
	MaxSpread = 0.02 ;//0.04
	RecoilSpreadIncreasePerShot = 0.001
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadDecreaseDelay = 0.3
	RecoilSpreadCrosshairScaling = 1000;	// 2500

	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	GroupWeight=5
	AimError=600

	InventoryGroup=2
	
	//Class of separate weapon ability granted by holding this gun
	AttachedWeaponAbilityClass = class'Rx_WeaponAbility_TacRifleGrenade' 
	
	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.14
	FireInterval(1)=+0.0
	ReloadTime(0) = 3.0
	ReloadTime(1) = 15.0 //Grenade Reload time 
	
	EquipTime=0.5
	PutDownTime=0.25 // 0.05
	
	Spread(0)=0.001
	
	WeaponRange= 10000 //16000 //10000.0 Pretty sure I was sober when I put these numbers... There's your problem.
	
	InstantHitDamage(0)=16
	InstantHitDamage(1)=16

	InstantHitDamageRadius(0)=80
	
	HeadShotDamageMult=2.5

	InstantHitDamageTypes(0)=class'Rx_DmgType_TacticalRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_TacticalRifle'

	InstantHitMomentum(0)=20000
	InstantHitMomentum(1)=20000
	

	/*	
	

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=20 //16
	InstantHitDamage(1)=20 //16

	InstantHitDamageRadius(0)=40 //80
	
	HeadShotDamageMult=1.6 //1.5 //2.5

	InstantHitDamageTypes(0)=class'Rx_DmgType_TacticalRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_TacticalRifle'

	InstantHitMomentum(0)=20000
	InstantHitMomentum(1)=20000
	
	bInstantHit=false

	*/
	
	WeaponFireTypes(0)=EWFT_Projectile
	//WeaponFireTypes(1)=EWFT_Projectile 
	
	WeaponProjectiles(0)=class'Rx_Projectile_TacticalRifle'
	//WeaponProjectiles(1)=class'Rx_Projectile_TacticalRifle' 

	FiringStatesArray(1)=Active
	
	ClipSize = 50
	InitalNumClips = 8
	MaxClips = 8
	
	FireDelayTime = 0.01
    bCharge = true

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponaltreload"
	ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
	ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponaltreload"
	
	WeaponPreFireAnim[0]="WeaponFireStart"
    WeaponPreFireAnim[1]="WeaponAltFire"
    WeaponFireAnim[0]="WeaponFireloop"
    WeaponFireAnim[1]="WeaponAltFire"
    WeaponPostFireAnim[0]="WeaponFireStop"
    WeaponPostFireAnim[1]="WeaponAltFire"

    ArmPreFireAnim[0]="WeaponFireStart"
    ArmPreFireAnim[1]="WeaponAltFire"
    ArmFireAnim[0]="WeaponFireloop"
    ArmFireAnim[1]="WeaponAltFire"
    ArmPostFireAnim[0]="WeaponFireStop"
    ArmPostFireAnim[1]="WeaponAltFire"	
	
	WeaponADSFireAnim[0]="WeaponFireADS"
	ArmADSFireAnim[0]="WeaponFireADS"
	
	SwapFromAbilityAnim = "WeaponRestToAim"
	SwapFromAbilityArmAnim = "WeaponRestToAim" 
	
	WeaponPreFireSnd[0]=none
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_FireLoop'
    WeaponFireSnd[1]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_GrenadeLauncher_Fire'
    WeaponPostFireSnd[0]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_FireStop'
    WeaponPostFireSnd[1]=none

	WeaponPutDownSnd=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'
	ReloadSound(0)=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Reload'
	ReloadSound(1)=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Reload'

	PickupSound=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TacticalRifle.Effects.P_MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	
	CrosshairWidth = 195
	CrosshairHeight = 195

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)
	InventoryMovieGroup=3
	WeaponIconTexture=Texture2D'RX_WP_TacticalRifle.UI.T_WeaponIcon_TacticalRifle'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-12.0,Y=-6.08,Z=0.08)
	IronSightFireOffset=(X=10,Y=0,Z=-1)
	IronSightBobDamping=20
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=60.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=130.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 1.5					// 2		1.5
	IronSightMaxRecoilDamping = 1.5					// 2		1.5
	IronSightMaxTotalRecoilDamping = 1.5			// 2		1.5
	IronSightRecoilYawDamping = 1					// 1		1.0
	IronSightMaxSpreadDamping = 2					// 2		1.5
	IronSightSpreadIncreasePerShotDamping = 100		// 4		1.7

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_TacticalRifle'
	
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
	Vet_ClipSizeModifier(1)=5 //Veteran 
	Vet_ClipSizeModifier(2)=10 //Elite
	Vet_ClipSizeModifier(3)=15 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.90 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	
	Vet_RangeModifier(0) = 1.0 //Also applied to instant hits only
	Vet_RangeModifier(1) = 1.0  
	Vet_RangeModifier(2) = 1.0  
	Vet_RangeModifier(3) = 1.1  
	
	VeterancyFireTypes(0) = (Firetype = EWFT_InstantHit, MinRank = 3) //2)
	/**********************/

	//AI Hints
	AIRating=+0.3
	CurrentRating=+0.3
	bFastRepeater=true
	bOkAgainstBuildings=true
	bOkAgainstVehicles=true
}