class Rx_Weapon_SniperRifle extends Rx_Weapon_Scoped;


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


DefaultProperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_DSR50_1P'
		AnimSets(0)=AnimSet'RX_WP_SniperRifle.Anims.AS_DSR50_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_DSR50_Back'		// SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_WP_SniperRifle_Back'
		// Translation=(X=-12)
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_SniperRifle'

	ArmsAnimSet=AnimSet'RX_WP_SniperRifle.Anims.AS_DSR50_Arms'
	
	PlayerViewOffset=(X=2.0,Y=0.0,Z=-1.0)		// (X=-5.0,Y=-3.0,Z=-0.5)
	
	LeftHandIK_Offset=(X=1.0,Y=-1,Z=1)
	RightHandIK_Offset=(X=-2.0,Y=-2.0,Z=0)

	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 200.0
	MaxRecoil = 300.0
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
	
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	GroupWeight=1
	AimError=600

	InventoryGroup=2

	ShotCost(0)=1
	ShotCost(1)=1
	FireInterval(0)=+1.0
	FireInterval(1)=+0.0
	ReloadTime(0) = 3.5
	ReloadTime(1) = 3.5
	
	EquipTime=0.75
//	PutDownTime=0.5
	
	Spread(0)=0.015
	IronSightAndScopedSpread(0)= 0.0
	
	InstantHitDamage(0)=100
	InstantHitDamage(1)=0
	InstantHitMomentum(0)=10000.0

//	BotDamagePercentage = 0.4;

	WeaponFireTypes(0)=EWFT_InstantHit

	FiringStatesArray(1)=Active

	InstantHitDamageTypes(0)=class'Rx_DmgType_SniperRifle'
	InstantHitDamageTypes(1)=None

	ClipSize = 4
	InitalNumClips = 9
	MaxClips = 9
	
	bAutoFire = false
	BoltActionReload=true
	BoltReloadTime(0) = 1.3f
	BoltReloadTime(1) = 1.3f

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"
	
	BoltReloadAnimName(0) = "WeaponBolt"
	BoltReloadAnimName(1) = "WeaponBolt"
	BoltReloadArmAnimName(0) = "WeaponBolt"
	BoltReloadArmAnimName(1) = "WeaponBolt"

	WeaponFireSnd[0]=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Fire'
	WeaponFireSnd[1]=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Fire'
	
	WeaponDistantFireSnd=none

	WeaponPutDownSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Equip'
	ReloadSound(0)=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Reload'
	ReloadSound(1)=SoundCue'RX_WP_SniperRifle.Sounds.SC_DSR50_Reload'
	BoltReloadSound(0)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_BoltPull'
	BoltReloadSound(1)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_BoltPull'

	PickupSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	// Configure the zoom

	bZoomedFireMode(0)=0
	bZoomedFireMode(1)=1

	FadeTime=0.3

	CrosshairWidth = 256
	CrosshairHeight = 256
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'
//	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_SniperRifle'
//  CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_None'
//	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_None'

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)

	bDisplaycrosshair = true;
	InventoryMovieGroup=5
	// DroppedPickupClass = class'RxDroppedPickup_SniperRifle'

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_SniperRifle'
}