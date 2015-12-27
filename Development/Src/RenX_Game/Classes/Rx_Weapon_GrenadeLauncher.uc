class Rx_Weapon_GrenadeLauncher extends Rx_Weapon_Reloadable;

DefaultProperties
{
    // Weapon SkeletalMesh
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_GrenadeLauncher.Mesh.SK_GrenadeLauncher_1P'
		AnimSets(0)=AnimSet'RX_WP_GrenadeLauncher.Anims.AS_GrenadeLauncher_1P'
		Animations=MeshSequenceA
		Scale=2.5
		FOV=50.0
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_GrenadeLauncher.Mesh.SK_GrenadeLauncher_Back'
        Scale=1.0
    End Object

    AttachmentClass = class'Rx_Attachment_GrenadeLauncher'

	ArmsAnimSet = AnimSet'RX_WP_GrenadeLauncher.Anims.AS_GrenadeLauncher_Arms'

	PlayerViewOffset=(X=6.0,Y=1.0,Z=-3.0)
	
	LeftHandIK_Offset=(X=0,Y=-3,Z=1.5)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	
	FireOffset=(X=20,Y=17,Z=-20)
	
	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.6
	MinRecoil = 250.0
	MaxRecoil = 300.0
	MaxTotalRecoil = 2000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 25.0
	RecoilDeclinePct = 1.0
	RecoilDeclineSpeed = 3.0
	RecoilSpread = 0.0
	MaxSpread = 0.1
	RecoilSpreadIncreasePerShot = 0.025
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadCrosshairScaling = 0;

    ShotCost(0)=1
    ShotCost(1)=1
    FireInterval(0)=+1.0
    FireInterval(1)=+1.0
    ReloadTime(0) = 3.0
    ReloadTime(1) = 3.0
    
    EquipTime=0.75
//	PutDownTime=0.5

    WeaponFireTypes(0)=EWFT_Projectile
    WeaponFireTypes(1)=EWFT_Projectile
    
    WeaponProjectiles(0)=class'Rx_Projectile_GrenadeLauncher'
    WeaponProjectiles(1)=class'Rx_Projectile_GrenadeLauncherAlt'

    Spread(0)=0.025
    Spread(1)=0.025
   
    ClipSize = 8
    InitalNumClips = 8
    MaxClips = 8

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
    ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"

    WeaponFireSnd[0]=SoundCue'RX_WP_GrenadeLauncher.Sounds.GrenadeLauncher_FireCue'
    WeaponFireSnd[1]=SoundCue'RX_WP_GrenadeLauncher.Sounds.GrenadeLauncher_FireCue'

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
 
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_GrenadeLauncher'
	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.Null_Material.MI_Null_Glass' // MaterialInstanceConstant'RenXHud.MI_Reticle_Dot'
	
	CrosshairWidth = 256
	CrosshairHeight = 256

    InventoryGroup=2
    InventoryMovieGroup=9

	WeaponIconTexture=Texture2D'RX_WP_GrenadeLauncher.UI.T_WeaponIcon_GrenadeLauncher'
    
    // AI Hints:
    //MaxDesireability=0.7
    AIRating=+0.3
    CurrentRating=+0.3
    bFastRepeater=false
    bInstantHit=false
    bSplashJump=false
    bRecommendSplashDamage=true
    bSniping=false

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_GrenadeLauncher'
}
