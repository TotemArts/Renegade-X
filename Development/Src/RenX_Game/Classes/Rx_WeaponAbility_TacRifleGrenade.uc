class Rx_WeaponAbility_TacRifleGrenade extends Rx_WeaponAbility_Attached;

var MaterialInstanceConstant    MCounterTens, MCounterOnes;
var MaterialInterface TeamSkin;
var byte TeamIndex;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MCounterOnes = Mesh.CreateAndSetMaterialInstanceConstant(2);
	MCounterTens = Mesh.CreateAndSetMaterialInstanceConstant(1);
}

simulated function UpdateAmmoCounter(Rx_Weapon_TacticalRifle ParentRifle)
{
	local int Ones, Tens;
	if ( WorldInfo.NetMode != NM_DedicatedServer)
	{
		Ones = ParentRifle.CurrentAmmoInClip%10;
		Tens = ((ParentRifle.CurrentAmmoInClip - Ones)/10)%10;

		MCounterOnes.SetScalarParameterValue('OnesClamp', Float(Ones));
		MCounterTens.SetScalarParameterValue('TensClamp', Float(Tens));
	}
}

simulated function PerformRefill()
{
	Super.PerformRefill();

	if(Rx_Weapon_TacticalRifle(Pawn(Owner).Weapon) != none) 
		UpdateAmmoCounter(Rx_Weapon_TacticalRifle(Pawn(Owner).Weapon));
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

simulated function bool bCanBeSelected()
	{
		if(Rx_Weapon_TacticalRifle(Pawn(Owner).Weapon) != none) 
		{
			UpdateAmmoCounter(Rx_Weapon_TacticalRifle(Pawn(Owner).Weapon));
			return (!bCurrentlyRecharging || (bFireWhileRecharging && HasAnyAmmo()))  ; 	
		}
		return false ; 
	}

DefaultProperties
{
	
	/***************************************************/
	/***************RX_WeaponAbility Details******************/
	/***************************************************/

	ParentWeaponClass = class'Rx_Weapon_TacticalRifle'
	
	FlashMovieIconNumber	= 4
		
	MaxCharges 		= 1 
	CurrentCharges 	= 1
	//RechargeTime 	=  5.0
	RechargeRate 	= 15.0 //Seconds between re-adding charges
	RechargeDelay   = 0.1 // Delay after firing before recharging occurs
	bAlwaysRecharge = false
	bCurrentlyRecharging = false 
	bFireWhileRecharging = false
	bCurrentlyFiring = false 
	bSwitchWeapAfterFire = true ; 	
	EmptySwapDelay = 0.25

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
	
	bByPassHandIK = false
	
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
	RecoilDelay = 0.01
	MinRecoil = 200.0
	MaxRecoil = 200.0
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
	GroupWeight=5
	AimError=600

	

	
	ShotCost(0)=1
	ShotCost(1)=1
	FireInterval(0)=+0.14
	FireInterval(1)=+0.0
	EquipTime=0.5
	PutDownTime=0.25
	
	Spread(0)=0.001
	
	WeaponRange= 10000 //16000 //10000.0 Pretty sure I was sober when I put these numbers... There's your problem.
	
	
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile //Used as the secondary when UsingGrenade is true 
	
	WeaponProjectiles(0)=class'Rx_Projectile_TacticalRifleGrenade'
	WeaponProjectiles(1)=class'Rx_Projectile_TacticalRifleGrenade' // Again, for the grenade

	FiringStatesArray(1)=Active
	
    WeaponFireAnim[0]="WeaponAltFire"
    WeaponFireAnim[1]="WeaponAltFire"

    
    ArmFireAnim[0]="WeaponFireloop"
    ArmFireAnim[1]="WeaponAltFire"
	
	WeaponADSFireAnim[0]="WeaponFireADS"
	ArmADSFireAnim[0]="WeaponFireADS"
	
	WeaponEquipAnim ="WeaponRestToAim"
	ArmsEquipAnim = "WeaponRestToAim"
	
    WeaponFireSnd[0]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_GrenadeLauncher_Fire'
    WeaponFireSnd[1]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_GrenadeLauncher_Fire'
 

	WeaponPutDownSnd=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Reload_Loop'//SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'
	
	ThirdPersonWeaponPutDownAnim=none
	ThirdPersonWeaponEquipAnim=none

	PickupSound=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TacticalRifle.Effects.P_MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_GrenadeLauncher'
	
	
	CrosshairWidth = 256
	CrosshairHeight = 256

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)
	InventoryMovieGroup=3
	WeaponIconTexture=Texture2D'RX_WP_TacticalRifle.UI.T_WeaponIcon_TacticalRifle'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = false	
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
	BackWeaponAttachmentClass = none //class'Rx_BackWeaponAttachment_TacticalRifle'
	
	
}
