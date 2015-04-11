class Rx_Weapon_FlameThrower extends Rx_Weapon_Charged;

DefaultProperties
{
    // Weapon SkeletalMesh
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_FlameThrower.Mesh.SK_FlameThrower_1P'
        AnimSets(0)=AnimSet'RX_WP_FlameThrower.Anims.AS_FlameThrower_Weapon'
        Animations=MeshSequenceA
		Scale=2.0
        FOV=55.0
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_FlameThrower.Mesh.SK_WP_FlameThrower_Back'
        //Translation=(X=-15)
        Scale=1.0
    End Object
	
	ArmsAnimSet = AnimSet'RX_WP_FlameThrower.Anims.AS_FlameThrower_Arms'

    AttachmentClass = class'Rx_Attachment_FlameThrower'
	
	LeftHandIK_Offset=(X=-0.75,Y=-8,Z=-5)
	RightHandIK_Offset=(X=3,Y=-2,Z=-2)
	
	PlayerViewOffset=(X=2.0,Y=-1.5,Z=-1.5)
	
	FireOffset=(X=20,Y=17,Z=-15)
	
	//-------------- Recoil
	RecoilDelay = 0.0
	MinRecoil = 30.0
	MaxRecoil = 50.0
	MaxTotalRecoil = 5000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilYawMultiplier = 2.0
	RecoilInterpSpeed = 15.0
	RecoilDeclinePct = 0.3
	RecoilDeclineSpeed = 2.0
	MaxSpread = 0.055
	RecoilSpreadIncreasePerShot = 0.001
	RecoilSpreadDeclineSpeed = 0.15
	RecoilSpreadDecreaseDelay = 0.2

    ShotCost(0)=1
    ShotCost(1)=0
    FireInterval(0)=+0.1
    FireInterval(1)=+0.0
    ReloadTime(0) = 2.75
    ReloadTime(1) = 2.75
    
    EquipTime=0.5
//	PutDownTime=0.5

    WeaponFireTypes(0)=EWFT_Projectile
    WeaponFireTypes(1)=EWFT_None
    
    WeaponProjectiles(0)=class'Rx_Projectile_FlameThrower'
    WeaponProjectiles(1)=class'Rx_Projectile_FlameThrower'

    Spread(0)=0.01
    Spread(1)=0.0
    
    FireDelayTime = 0.01
    bCharge = true

    ClipSize = 50
    InitalNumClips = 10
    MaxClips = 10

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
    ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
    
    WeaponPreFireAnim[0]="WeaponFireStart"
    WeaponPreFireAnim[1]="WeaponFireStart"
    WeaponFireAnim[0]="WeaponFireIdle"
    WeaponFireAnim[1]="WeaponFireIdle"
    WeaponPostFireAnim[0]="WeaponFireStop"
    WeaponPostFireAnim[1]="WeaponFireStop"

    ArmPreFireAnim[0]="WeaponFireStart"
    ArmPreFireAnim[1]="WeaponFireStart"
    ArmFireAnim[0]="WeaponFireIdle"
    ArmFireAnim[1]="WeaponFireIdle"
    ArmPostFireAnim[0]="WeaponFireStop"
    ArmPostFireAnim[1]="WeaponFireStop"

//    WeaponFireSnd[0]=SoundCue'RX_WP_FlameThrower.Sounds.SC_FlameThrower_Fire'
//    WeaponFireSnd[1]=SoundCue'RX_WP_FlameThrower.Sounds.SC_FlameThrower_Fire'

    WeaponPreFireSnd[0]=SoundCue'RX_WP_FlameThrower.Sounds.FlameThrower_FireIgniteCue'
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_FlameThrower.Sounds.FlameThrower_FireCue'
    WeaponFireSnd[1]=none
    WeaponPostFireSnd[0]=SoundCue'RX_WP_FlameThrower.Sounds.FlameThrower_FireEndCue'
    WeaponPostFireSnd[1]=none

    WeaponPutDownSnd=SoundCue'RX_WP_FlameThrower.Sounds.FlameThrower_PutDownCue'
    WeaponEquipSnd=SoundCue'RX_WP_FlameThrower.Sounds.FlameThrower_EquipCue'
    ReloadSound(0)=SoundCue'RX_WP_FlameThrower.Sounds.FlameThrower_ReloadCue'
    ReloadSound(1)=SoundCue'RX_WP_FlameThrower.Sounds.FlameThrower_ReloadCue'

    PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
 
    MuzzleFlashSocket=MuzzleFlashSocket
    FireSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.FX_FireThrower_MuzzleFlash' //none
//    MuzzleFlashDuration=0.1
//    MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'

    InventoryGroup=2.1
    GroupWeight=1
    InventoryMovieGroup=6
    
    // AI Hints:
    //MaxDesireability=0.7
    AIRating=+0.3
    CurrentRating=+0.3
    bFastRepeater=true
    bInstantHit=false
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=false        

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_FlameThrower'
}
