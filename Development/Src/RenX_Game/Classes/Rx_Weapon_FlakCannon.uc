class Rx_Weapon_FlakCannon extends Rx_Weapon_Reloadable;

var int NumPellets, ShotLayer, NumSpreadLayers;
var bool bUseConstantSpread;

var float LayerDensity; //Used to change spread per shot/Create rediculous patterns

var float Additive; //Circular additive used in predictable spread pattern  

simulated function CustomFire()
{
    local int i;
    Rx_Pawn(Owner).ShotgunPelletCount = 0;
    for (i=0; i < NumPellets; i++)
    {
	if(i>0 && Rx_Controller(Instigator.Controller) != none) Rx_Controller(Instigator.Controller).AddShot(); //One gets called in FireAmmunition already 
        //super.InstantFire();
		super.ProjectileFire();
        CurrentAmmoInClipClientside++;
    }
    CurrentAmmoInClipClientside--;
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
	return false; //CurrentFireMode == 0; 
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
	
	LeftHandIK_Offset=(X=0,Y=0,Z=0)
	RightHandIK_Offset=(X=6,Y=-6,Z=-2)
	LeftHandIK_Relaxed_Offset = (X=1.000000,Y=-2.000000,Z=3.000000)
	
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
        
	WeaponProjectiles(0)=class'Rx_Projectile_FlakCannon_Alt'
	WeaponProjectiles(1)=class'Rx_Projectile_FlakCannon'
	WeaponProjectiles_Heroic(0)=class'Rx_Projectile_FlakCannon_Alt_Heroic'
	WeaponProjectiles_Heroic(1)=class'Rx_Projectile_FlakCannon_Heroic'
	
	WeaponRange=2500.0
	
	InstantHitDamage(0)=15 //12
	
	HeadShotDamageMult=2.0
	
	InstantHitDamageRadius(0)=32

	InstantHitDamageTypes(0)=class'Rx_DmgType_FlakCannon_Alt'

	InstantHitMomentum(0)=4000

    Spread(0)=0.01//0.075
    Spread(1)=0.005
 
    ClipSize = 8//12
    InitalNumClips = 8
    MaxClips = 8
    NumPellets = 10//8

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
	Vet_ClipSizeModifier(1)=2 //Veteran 
	Vet_ClipSizeModifier(2)=4 //Elite
	Vet_ClipSizeModifier(3)=6 //Heroic

	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.85 //Heroic
	/**********************/
	
	bLocSync = true; 
	LocSyncIncrement = 4; 
	
	//For more consistent spread
	bUseConstantSpread = true
	
	NumSpreadLayers = 2 //5
	LayerDensity = 0.025
	
	ROFTurnover = 4 
}
