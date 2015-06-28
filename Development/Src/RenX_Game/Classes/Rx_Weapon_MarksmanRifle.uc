class Rx_Weapon_MarksmanRifle extends Rx_Weapon_Reloadable
	abstract;


var MaterialInstanceConstant    MCounterTens, MCounterOnes;
var MaterialInterface TeamSkin;
var byte TeamIndex;

var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MCounterOnes = Mesh.CreateAndSetMaterialInstanceConstant(1);
	MCounterTens = Mesh.CreateAndSetMaterialInstanceConstant(2);
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

simulated function SetSkin(Material NewMaterial)
{
	if( ( Instigator != none ) && ( NewMaterial == none ) ) // Clear the materials
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

function ConsumeAmmo( byte FireModeNum )
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


simulated function FireAmmunition()
{
	super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}




defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	bAutoFire = false
	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_MarksmanRifle_1P'
		AnimSets(0)=AnimSet'RX_WP_SniperRifle.Anims.AS_MarksmanRifle_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_MarksmanRifle_Back'
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_MarksmanRifle'
	
	PlayerViewOffset=(X=5.0,Y=1.0,Z=-1.0)
	
	LeftHandIK_Offset=(X=0.5,Y=-1,Z=3)
	RightHandIK_Offset=(X=0,Y=0,Z=0)

	ArmsAnimSet = AnimSet'RX_WP_SniperRifle.Anims.AS_MarksmanRifle_Arms'
	
	FireOffset=(X=10,Y=7,Z=-5)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 100.0
	MaxRecoil = 120.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 42.0
	RecoilDeclinePct = 1.0
	RecoilDeclineSpeed = 5.0
	MaxSpread = 0.05
	RecoilSpreadIncreasePerShot = 0.004
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadDecreaseDelay = 0.3
	RecoilSpreadCrosshairScaling = 3000;

	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	GroupWeight=5
	AimError=600

	InventoryGroup=2

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.2
	FireInterval(1)=+0.0
	ReloadTime(0) = 2.75
	ReloadTime(1) = 2.75
	
	EquipTime=0.5
//	PutDownTime=0.5
	
	Spread(0)=0.01
	IronSightAndScopedSpread(0)= 0.0001
	
	WeaponRange=30000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=30
	InstantHitDamage(1)=30
	
	HeadShotDamageMult=2.0

	InstantHitDamageTypes(0)=class'Rx_DmgType_MarksmanRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_MarksmanRifle'

	InstantHitMomentum(0)=20000
	InstantHitMomentum(1)=20000
	
	bInstantHit=true

//	WeaponFireTypes(0)=EWFT_Projectile
	
//	WeaponProjectiles(0)=class'Rx_Projectile_MarksmanRifle'

	FiringStatesArray(1)=Active


	ClipSize = 10
	InitalNumClips = 8
	MaxClips = 8

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"

	WeaponFireSnd[0]=SoundCue'RX_WP_SniperRifle.Sounds.SC_SniperRifle_Fire'
	WeaponFireSnd[1]=SoundCue'RX_WP_SniperRifle.Sounds.SC_SniperRifle_Fire'
	
	WeaponDistantFireSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_SniperRifle_DistantFire'

	WeaponPutDownSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Equip'
	ReloadSound(0)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'
	ReloadSound(1)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'

	PickupSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TacticalRifle.Effects.P_MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	CrosshairWidth = 180
	CrosshairHeight = 180

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)
	InventoryMovieGroup=28

	WeaponIconTexture=Texture2D'RX_WP_SniperRifle.UI.T_WeaponIcon_MarksmanRifle'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-6,Y=-7.7925,Z=0.75)		// (X=-15.0,Y=-11.675,Z=0.27)
	IronSightFireOffset=(X=10,Y=0,Z=-2)
	IronSightBobDamping=30
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=70.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=160.0
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
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_MarksmanRifle'
}