class Rx_Weapon_FlakCannon extends Rx_Weapon_Reloadable;


var int NumPellets;

simulated function CustomFire()
{
    local int i;
    Rx_Pawn(Owner).ShotgunPelletCount = 0;
    for (i=0; i < NumPellets; i++)
    {
        super.InstantFire();
        CurrentAmmoInClipClientside++;
    }
    CurrentAmmoInClipClientside--;
}

/** Modified version of Rx_Weapon::TryHeadshot(...) that allows Shotgun headshots to work. */
simulated function bool TryHeadshot(byte FiringMode, ImpactInfo Impact) 
{
	local float Scaling;
	local int HeadDamage;
    	
	if(FiringMode == 0)
	{
		if (Instigator == None || VSize(Instigator.Velocity) < Instigator.GroundSpeed * Instigator.CrouchedPct)
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


DefaultProperties
{
    // Weapon SkeletalMesh
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_FlakCannon.Mesh.SK_FlakCannon_1P'
        AnimSets(0)=AnimSet'RX_WP_FlakCannon.Anims.AS_FlakCannon_Weapon'
        Animations=MeshSequenceA
		Scale=2.5
        FOV=50.0
    End Object

    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_FlakCannon.Mesh.SK_FlakCannon_Back'
        // Translation=(X=-10)
        Scale=1.0
    End Object
	
    ArmsAnimSet = AnimSet'RX_WP_FlakCannon.Anims.AS_FlakCannon_Arms'

    AttachmentClass = class'Rx_Attachment_FlakCannon'
	
	PlayerViewOffset=(X=14.0,Y=-1.0,Z=-2.0)
	
	LeftHandIK_Offset=(X=0,Y=-6,Z=0.5)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	
	FireOffset=(X=20,Y=8,Z=-10)
	
	//-------------- Recoil
	RecoilDelay = 0.05
	RecoilSpreadDecreaseDelay = 0.7
	MinRecoil = 350.0
	MaxRecoil = 500.0
	MaxTotalRecoil = 1000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 20.0
	RecoilDeclinePct = 0.75
	RecoilDeclineSpeed = 3.0
	RecoilSpread = 0.0
	MaxSpread = 0.15
	RecoilSpreadIncreasePerShot = 0.003
	RecoilSpreadDeclineSpeed = 0.05
	RecoilSpreadCrosshairScaling = 1000;

    ShotCost(0)=1
    ShotCost(1)=2
    FireInterval(0)=+0.9
    FireInterval(1)=+0.9
    ReloadTime(0) = 3.0 //3.3667
    ReloadTime(1) = 3.0 //3.3667
    
    EquipTime=0.75
//	PutDownTime=0.5

    
//	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Projectile
        
//	WeaponProjectiles(0)=class'Rx_Projectile_FlakCannon_Alt'
	WeaponProjectiles(1)=class'Rx_Projectile_FlakCannon'
	
	WeaponRange=2500.0
	
	InstantHitDamage(0)=12
	
	HeadShotDamageMult=2.0
	
	InstantHitDamageRadius(0)=32

	InstantHitDamageTypes(0)=class'Rx_DmgType_FlakCannon_Alt'

	InstantHitMomentum(0)=4000

    Spread(0)=0.075
    Spread(1)=0.005
 
    ClipSize = 12
    InitalNumClips = 5
    MaxClips = 5
    NumPellets = 8

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
    ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"

    WeaponFireSnd[0]=SoundCue'RX_WP_FlakCannon.Sounds.SC_FlakCannon_Fire'
    WeaponFireSnd[1]=SoundCue'RX_WP_FlakCannon.Sounds.SC_FlakCannon_Fire'

    WeaponPutDownSnd=SoundCue'RX_WP_FlakCannon.Sounds.SC_FlakCannon_Equip'
    WeaponEquipSnd=SoundCue'RX_WP_FlakCannon.Sounds.SC_FlakCannon_PutDown'
    ReloadSound(0)=SoundCue'RX_WP_FlakCannon.Sounds.SC_FlakCannon_Reload'
    ReloadSound(1)=SoundCue'RX_WP_FlakCannon.Sounds.SC_FlakCannon_Reload'

    PickupSound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Equip'

    MuzzleFlashSocket="MuzzleFlashSocket"
    FireSocket = "MuzzleFlashSocket"
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_GrenadeLauncher.Effects.MuzzleFlash_1P'
    MuzzleFlashDuration=3.3667
    MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
    
    CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_RocketLauncher'

    InventoryGroup=2
    InventoryMovieGroup=22

	WeaponIconTexture=Texture2D'RX_WP_FlakCannon.UI.T_WeaponIcon_FlakCannon'
    
    // AI Hints:
    // MaxDesireability=0.7
    AIRating=+0.3
    CurrentRating=+0.3
    bFastRepeater=false
    bInstantHit=true
    bSplashJump=false
    bRecommendSplashDamage=true
    bSniping=false 

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_FlakCannon'
}
