class Rx_WeaponAbility_Grenade extends Rx_WeaponAbility;

var() name WeaponThrowGrenadeAnimName[4];
var array<float> DelayFireTime; 

simulated state Active
{
simulated function bool bReadyToFire()
	{
		return  !bCurrentlyRecharging || (bFireWhileRecharging && HasAnyAmmo())  ; 
	}

}

simulated state WeaponFiring
{
	simulated event bool IsFiring()
	{
		return true;
	}

	simulated function RefireCheckTimer()
	{
		// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}

		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			// Hamad: If we have delay, refire according to our delay logic
			if (DelayFireTime[CurrentFireMode] > 0) 
			{
				ClearTimer('DelayFire');
				PlayFireEffects( CurrentFireMode );
			}
			else
				FireAmmunition(); // Else, follow the default implementation

			return;
		}

		// Otherwise we're done firing
		HandleFinishedFiring();
	}

	simulated event BeginState( Name PreviousStateName )
	{

		// If we don't have delays, resume with default implementation
		if (DelayFireTime[CurrentFireMode] <= 0) 
		{
			FireAmmunition();
			TimeWeaponFiring( CurrentFireMode );
		}
		else
			PlayFireEffects( CurrentFireMode ); //Otherwise, use ours

	}
	
}

//Did not add support to allow this behaviour with bolt action reloading. 



simulated function TimeWeaponFiring( byte FireModeNum )
{
	// if weapon is not firing, then start timer. Firing state is responsible to stopping the timer.
	if( !IsTimerActive('RefireCheckTimer') )
	{
		SetTimer( GetFireInterval(FireModeNum) , true, nameof(RefireCheckTimer) );
	}
}

// Hamad: This is the delay timer function. It'll fire the default implementation and clear itself.
simulated function DelayFire()
{
	FireAmmunition();
	TimeWeaponFiring( CurrentFireMode );
	ClearTimer('DelayFire');
}


// Hamad: Play the animation and activate the delay timer if we are in delay mode
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (DelayFireTime[FireModeNum] > 0) // Do we have delay?
	{
		if( !IsTimerActive('DelayFire') ) 
		{
			if(Rx_Pawn(Owner) != None)
			{
				Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnim(WeaponThrowGrenadeAnimName[0], 1.0, 0.25, 0.25, false, true);
			}

			SetTimer( DelayFireTime[FireModeNum] , true, 'DelayFire' );
			super.PlayFireEffects(FireModeNum, HitLocation);
		}

	}
	else
	{
		// No delay. Resume default implementation.
		super.PlayFireEffects(FireModeNum, HitLocation);
	}

}

simulated state WeaponPuttingDown //Edit to clear delay fire
{
	simulated function BeginState( Name PreviousStateName )
	{
		if(IsTimerActive('DelayFire')) ClearTimer('DelayFire'); 
		super.BeginState(PreviousStateName);
	}
}

simulated function RestartWeaponFiringAfterReload(); //Force the individual to click at the right time.

simulated function bool HasAnyAmmo()
{
	return !bCurrentlyRecharging; 
}



DefaultProperties
{
	
	/***************************************************/
	/***************RX_WeaponAbility Details******************/
	/***************************************************/
	
MaxCharges 		= 1 
CurrentCharges 	= 1
//RechargeTime 	=  5.0
RechargeRate 	= 25.0 //Seconds between re-adding charges
RechargeDelay   = 0.1 // Delay after firing before recharging occurs
bAlwaysRecharge = false
bCurrentlyRecharging = false 
bFireWhileRecharging = false
bCurrentlyFiring = false 
bSwitchWeapAfterFire = true ; 	
	
	/***************************************************/
	/***************RX_Weapon Details******************/
	/***************************************************/
	
	
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_Grenade_1P'
		AnimSets(0)=AnimSet'RX_WP_Grenade.Anims.AS_Grenade_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=55.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Grenade.Mesh.SK_Grenade_1P'
		Scale=2.5
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_Grenade.Anims.AS_Grenade_Arms'

	AttachmentClass = class'Rx_Attachment_Grenade'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Greande'
	
	PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)
	
	FireOffset=(X=0,Y=10,Z=0)
	
	bUseHandIKWhenRelax=false
	bByPassHandIK=true
	
	//-------------- Recoil
	RecoilDelay = 0.0
	MinRecoil = 0.0
	MaxRecoil = 0.0
	MaxTotalRecoil = 0.0
	RecoilYawModifier = 0.0 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 0.0
	RecoilDeclinePct = 0.0
	RecoilDeclineSpeed = 0.0
	MaxSpread = 0.0
	RecoilSpreadIncreasePerShot = 0.0
	RecoilSpreadDeclineSpeed = 0.0
	RecoilSpreadDecreaseDelay = 0.0
	RecoilSpreadCrosshairScaling = 10000;

	ShotCost(0)=1
	ShotCost(1)=1
	FireInterval(0)=+0.75
	FireInterval(1)=+0.75
	DelayFireTime(0) = 0.54375;
	DelayFireTime(1) = 0.54375;
	
	
	EquipTime=0.6
//	PutDownTime=0.35
	
	WeaponRange=2800.0

    LockerRotation=(pitch=0,yaw=0,roll=-16384)

	WeaponFireTypes(0)=EWFT_Projectile
    WeaponFireTypes(1)=EWFT_Projectile
    
    WeaponProjectiles(0)=class'Rx_Projectile_Grenade'
    WeaponProjectiles(1)=class'Rx_Projectile_Grenade_Alt'

    Spread(0)=0.0
    Spread(1)=0.0

//	AmmoCount=2
//	LockerAmmoCount=2
//	MaxAmmoCount=2

	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	WeaponThrowGrenadeAnimName(0) = "H_M_Grenade_Toss"
	WeaponThrowGrenadeAnimName(1) = "H_M_Grenade_Toss"

	WeaponFireSnd[0]=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Throw'
	WeaponFireSnd[1]=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Throw'

	WeaponPutDownSnd=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'

	PickupSound=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=none
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=none

    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_GrenadeLauncher'
	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.Null_Material.MI_Null_Glass' // MaterialInstanceConstant'RenXHud.MI_Reticle_Dot'
	
	CrosshairWidth = 256
	CrosshairHeight = 256

	InventoryGroup=12 //5 
	InventoryMovieGroup=27

	
	WeaponIconTexture=Texture2D'RX_WP_Grenade.UI.T_WeaponIcon_Grenade'
	
	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.10 
	Vet_DamageModifier(2)=1.25 
	Vet_DamageModifier(3)=1.50 
	
	Vet_RechargeSpeedMult(0) = 1.0 
	Vet_RechargeSpeedMult(1) = 0.95
	Vet_RechargeSpeedMult(2) = 0.85 
	Vet_RechargeSpeedMult(3) = 0.75 	
	
	/**********************/
}
