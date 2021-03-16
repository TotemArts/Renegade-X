/*********************************************************
*
* File: RxWeapon.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
//class Rx_Weapon extends UTWeapon implements (Rx_Weapon);
class Rx_Weapon extends AimingWeaponClass;

`include(RenX_Game\RenXStats.uci);

/** one1: Added. */
var class<Rx_BackWeaponAttachment> BackWeaponAttachmentClass;

/** Secondary Left Hand IK Translation Offset - adjust for any specific weapon. */
var() Vector LeftHandIK_Offset;

/** Secondary Left Hand IK Rotation Offset - adjust for any specific weapon. */
var() Rotator LeftHandIK_Rotation;

/** Secondary Left Hand IK Translation Offset when relaxed - adjust for any specific weapon. */
var() Vector LeftHandIK_Relaxed_Offset;

/** Secondary Left Hand IK Rotation Offset when relaxed - adjust for any specific weapon. */
var() Rotator LeftHandIK_Relaxed_Rotation;

/** Secondary Right Hand IK Translation Offset - adjust for any specific weapon. */
var() Vector RightHandIK_Offset;

/** Secondary Right Hand IK Translation Offset when relaxed - adjust for any specific weapon. */
var() Vector RightHandIK_Relaxed_Offset;

/** Secondary Right Hand IK Rotation Offset when relaxed - adjust for any specific weapon. */
var() Rotator RightHandIK_Relaxed_Rotation;

/** Overrides left hand animation to a different pose. */
var() bool bOverrideLeftHandAnim;

/** Left Hand Animation if OverrideLeftHandAnim is enabled. */
var() name LeftHandAnim;

/** Keeps Left and Right hand IKs enabled when in relaxed state. */
var() bool bUseHandIKWhenRelax;

/** Disables the use of IK Hand positioning for the weapon */
var() bool bByPassHandIK;

/** The GFX weapon/inventory set, 0-15. */
var byte InventoryMovieGroup;

var() class<UTDamageType> HeadShotDamageType;
var() float HeadShotDamageMult;
var() float HeadShotDamageBurnMultiplier;

/** headshot scale factor when moving slowly or stopped */
var() float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var() float RunningHeadshotScale;

// Purchase Terminal Setup
var(Purchase) Texture PTIconTexture;
var(Purchase) int Price;
var localized string PurchaseDesc;

var array<float> InstantHitDamageRadius;
var array<bool> InstantHitDamageRadiusDoFull;
var array<bool> InstantHitDamageRadiusIgnoreTeam;

var byte ClientHitFiringMode;
var vector ClientHitHurtOrigin;

// Rx_Vehicle_Weapon knows about ClientSideHit defined in RxIfc_ClientSideHitRadius, but for some unknown reason this class doesn't... so copied the decleration into here
struct ClientSideHit {
	var Actor Actor;
	var float Distance;
};

var MaterialInstanceConstant CrosshairMIC, CrosshairDotMIC, CrosshairMIC2, CrosshairDotMIC2;
var MaterialInstanceConstant ADSCrosshairMIC, ADSCrosshairMIC2;
var MaterialInstanceConstant HitIndicatorCrosshairMIC,HitIndicatorCrosshairMIC2;
var float CrosshairWidth, CrosshairHeight;
var float CrosshairLinesX, CrosshairLinesY;
var float CrosshairDotDrawX, CrosshairDotDrawY;
var float CurrentClipX, CurrentClipY;
var bool  bCrosshairDotCentered;

var name FireSocket;

var bool bDebugWeapon;

var() name ThirdPersonWeaponEquipAnim;
var() name ThirdPersonWeaponPutDownAnim;

var bool bHasInfiniteAmmo;

//Burst Fire Variables//
var bool bBurstFire; //If true, the weapon will use burst fire mechanics
var float 	TimeBetweenBursts;
var bool  	bIsInBurstFire;
var bool  	bCurrentlyFireing;
var bool  	bConstantFire; 
var int	  	BurstNum, CurrentBurst; 
var float	Burst_Cooldown[2]; //After burst, use this number instead of Fire_Interval

var bool bOkAgainstVehicles; // Hint for AI
var bool bOkAgainstBuildings; // Hint for AI

//-------------------- Recoil
var float 	Recoil;
var float 	MinRecoil;
var float 	MaxRecoil;
var float 	MaxTotalRecoil;
var rotator RecoilOffset;
var rotator RecoilDecline;
var rotator TotalRecoil;
var float 	RecoilInterpSpeed;
var float 	RecoilDeclinePct;
var float 	RecoilDeclineSpeed;
var float 	RecoilDelay;
var float 	RecoilSpreadDecreaseDelay;
var float 	RecoilSpread;
var float 	CurrentSpread;
var float 	MaxSpread;
var float 	RecoilSpreadIncreasePerShot;
var float 	RecoilSpreadDeclineSpeed;
var float 	RecoilYawModifier;
var float 	RecoilYawMultiplier;
var int 	RecoilSpreadCrosshairScaling;

var bool bAutoFire;
var bool bLogRecoilTemp;
var array<bool> ClientPendingFire;
var bool bUseClientAmmo; 

var float IronSightMinRecoilDamping;
var float IronSightMaxRecoilDamping;
var float IronSightMaxTotalRecoilDamping;
var float IronSightRecoilYawDamping;
var float IronSightMaxSpreadDamping;
var float IronSightSpreadIncreasePerShotDamping; 
var float IronsightMouseSensitivityModifier;
var() Array<float> IronSightAndScopedSpread;
var bool bChangedTo1stPersonOnce;

var(Animations)	array<name>	WeaponADSFireAnim;
var(Animations) array<name> ArmADSFireAnim;

/** reference to the texture to use for the Hud */
var() Texture WeaponIconTexture;

//Veterancy 
var repnotify byte VRank;
var float Vet_DamageModifier[4]; //*X
var float Vet_ROFModifier[4];   //*X
var float Elite_Building_DamageMod; /* *X Used after elite for some weapons to have a noticeable increase in building damage without being too much crazier vs. everything else. */
var float Vet_RangeModifier[4] ; //*X  Used to keep projectile ranges from getting totally out of hand. 

var bool bROFChanged; //Used to determine if our rate of fire changes amidst shooting so we can update that 

//Checks location synchronization when shooting 
var bool	bLocSync;
var int	LocSyncIncrement;

var float ROF_Check; //How fast are we firin' ?  

var array< class<Projectile> > WeaponProjectilesAir;

//Heroic systems
var ParticleSystem MuzzleFlashPSCTemplate_Heroic, MuzzleFlashAltPSCTemplate_Heroic;
var array< class<Projectile> > WeaponProjectiles_Heroic;
var class<UDKExplosionLight> MuzzleFlashLightClass_Heroic;
var array<SoundCue>	WeaponFireSnd_Heroic;

/**This is the minimum Vrank necessary to achieve instant-fire projectiles. PS. MAKE SURE INSTANT FIRE VET STATS, AND Damage etc sync up with the projectiles. A value of 255 should be used to say this weapon is NEVER hit-scan**/
struct VetFireType
{
	var EWeaponFireType FireType; 
	var byte MinRank; //Minimum rank to change to this fire type
}; 

var array<VetFireType> VeterancyFireTypes; 

//ROF Tracking
var int LastFireTime;
var byte ROFTicker, ROFTurnover; //Iterator | How many shots until it takes an average and moves on.    Should never be more than 9 (Which will make it 10 shots averaged together)
var int ROFAvgs[10]; //10 though may not ever make it to ten. Saves AVG#
var int PrevAVG; 
var string AVGString; //String to send to controller when requested 

//Optional ability weapon stuff to link to this weapon 
var class<Rx_WeaponAbility> AttachedWeaponAbilityClass;
var Rx_WeaponAbility AttachedWeaponAbility;  

//For HUD stuff, should only be used by mods/mutators
var string CustomWeaponName;

//When coming back from using our weapon ability use these animation
var name SwapFromAbilityAnim;
var name SwapFromAbilityArmAnim;

//Pawn piercing 
var bool bPierceInfantry;
var bool bPierceVehicles; 

/**
* This controls how much piercing power the shot has. 
* Infantry hitting infantry subtracts '1' from its piercing ability
* Where as vehicles subtract 3
* So if the Max pierce rating is 5, you could fire through 5 infantry before stopping  
*/  
var int MaximumPiercingAbility;
var int	CurrentPiercingPower;  

var bool bIgnoreHitDist; //Ignore the distance from which you hit a target (Used for volumetric projectiles)

//Weapon speed modifier for Pawns carrying it (Unused currently)
var float WeaponSpeedModifier; 

var float ActionToReadyTime; //Time (if any) that this weapon becomes fire-able/reloadable after finished an action (Sprinting/Dodging/Vaulting)
var bool  bRecoveringFromAction;

// Muzzle heat
var float MuzzleHeatClamp, MuzzleHeatPerShot, MuzzleHeatCooldownTimeInterval, MuzzleHeatCooldownAmount, MinMuzzleHeatRequired, MuzzleHeatCooldownWaitTime, MuzzleHeat;
var MaterialInstanceConstant MuzzleHeatMIC, MuzzleHeatMICAttachment;

var bool bCloaked; //Move to TS only weapon architecture

var Name TeamColourParameterName;
var repnotify byte bUseNodEffects;
var class<Projectile> WeaponProjectiles_Nod[2];

/*********************************************************************************************
 * Weapon lock on support
 ********************************************************************************************* */

/** Class of the rocket to use when seeking */
var class<UTProjectile> SeekingRocketClass;

// ---------------------------------  Targeting/Lock on vars. -------------------------------------- //

var bool                   bCanLock;
var bool                   bLockedOnTarget;           /* When true, this weapon is locked on target */
var bool                   bTargetLockingActive;      /* If true, weapon will try to lock onto targets */
var Actor                  LastPendingTarget;         /* What last tick test "target" is current pending to be locked on to */
var repnotify Actor        PendingLockedTarget;       /* What "target" is current pending to be locked on to */
var Actor                  LockedTarget;              /* What "target" is this weapon locked on to */
var PlayerReplicationInfo  LockedTargetPRI;           /* if player is targeted then his PRI will be stored here */
var(Locking) float         LockTolerance;
var protected float        LastLockedOnTime;          /* How long since the Lock Target has been valid */
var protected float        LastTargetLockCheckTime;   /* Last time target lock was checked */
var() float                LockCheckTime;             /* The frequency with which we will check for a lock */
var() float                LockAcquireTime;           /* How long does the player need to target an actor to lock on to it*/
var() float                LockRange;                 /* How far out should we be considering actors for a lock */
var() float                StayLocked;                /* How long target stay locked before losing it*/
var float                  PendingLockedTargetTime;   /* When did the pending Target become valid */
var float                  LastValidTargetTime;       /* When was the last time we had a valid target */
var float                  LockAim;                   /* angle for locking for lock targets */
var float                  ConsoleLockAim;            /* angle for locking for lock targets when on Console */
var SoundCue               LockLostSound;             /* Sound Effects to play when Lock lost*/
var Soundcue               LockAcquiredSound;         /* Sound Effects to play when Locking */
var bool                   LockingStart;              /* if true then locking state was started */
var() bool				   bPersistentLock;

var MaterialInstanceConstant LockedOnCrosshairMIC,LockedOnCrosshairMIC2;
var MaterialInstanceConstant TargetMIC,TargetMIC2;
var float LockOnSize;

var bool bCanGetAmmo; // related to picking up ammo boxes
var bool bIsCrateWeapon; //If TRUE weapon is not refillable


replication
{
    if (Role == ROLE_Authority && bNetDirty)
        VRank, AttachedWeaponAbility, bLockedOnTarget, LockedTarget, PendingLockedTarget;

    if (bNetDirty)
    	bUseNodEffects;
}

function PreBeginPlay()
{
	super.PreBeginPlay();
}

/**
 * Initialize the weapon
 */
simulated function PostBeginPlay() 
{
	local array< class<Projectile> > WeaponProjectilesTemp;	
	
	/**
	*	Need to set WeaponProjectiles to None before calling super. 
	*   Because otherwise there would be a Cast to UTProjectile in super, which would fail
	*/
	WeaponProjectilesTemp[0] = WeaponProjectiles[0];
	WeaponProjectilesTemp[1] = WeaponProjectiles[1];
	
	WeaponProjectiles[0] = None;
	WeaponProjectiles[1] = None;
	
	super.PostBeginPlay(); 
	
	WeaponProjectiles[0] = WeaponProjectilesTemp[0];
	WeaponProjectiles[1] = WeaponProjectilesTemp[1];	
	
	bConsiderProjectileAcceleration = bConsiderProjectileAcceleration
										&& (((WeaponProjectiles[0] != None) && (class<UDKProjectile>(WeaponProjectiles[0]).Default.AccelRate > 0))
											|| ((WeaponProjectiles[1] != None) && (class<UDKProjectile>(WeaponProjectiles[1]).Default.AccelRate > 0)) );	
											
	//Create our instances of the crosshair parts so we can set their parameters later.
	//Otherwise we will get reference issues ingame that are not caught by the compiler.
	CrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	CrosshairMIC2.SetParent(CrosshairMIC);
	
	CrosshairDotMIC2 = new(Outer) class'MaterialInstanceConstant';
	CrosshairDotMIC2.SetParent(CrosshairDotMIC);

	if(ADSCrosshairMIC != None)
	{
		ADSCrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
		ADSCrosshairMIC2.SetParent(ADSCrosshairMIC2);
	}
												
	HitIndicatorCrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	HitIndicatorCrosshairMIC2.SetParent(HitIndicatorCrosshairMIC);		
	
	//ENABLE 1 for DropWeapon
	bCanThrow = false;	

	if(TargetMIC != None)
	{
		TargetMIC2 = new(Outer) class'MaterialInstanceConstant';
		TargetMIC2.SetParent(TargetMIC);
	}

	if(LockedOnCrosshairMIC != None)
	{
		LockedOnCrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
		LockedOnCrosshairMIC2.SetParent(LockedOnCrosshairMIC);
	}									
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'VRank')
	{
		ReplicateVRank();
	}
	else if(VarName == 'AttachedWeaponAbility')
	{
		
	}
	else if(VarName == 'PendingLockedTarget')
	{
		if(PendingLockedTarget != None)
			PendingLockedTargetTime = ((Vehicle(PendingLockedTarget) != None) && (UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer)
									? WorldInfo.TimeSeconds + 0.5*LockAcquireTime
									: WorldInfo.TimeSeconds + LockAcquireTime;
		else
			PendingLockedTargetTime = 0.0;

	}
	else
		super.ReplicatedEvent(VarName);
}

simulated function bool CanThrow()
{
	//ENABLE 2 for DropWeapon
	return false; // reactivate when we know more clearly how we want weapondrop to work
	
	if(!bCanThrow)
		return false;
	else	
		return true ; //FRand() < 0.5;
		
}

auto simulated state Inactive
{
	ignores Tick;

	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if ( Role == ROLE_Authority && bCanLock)
		{
			bTargetLockingActive = false;
			AdjustLockTarget(None);
		}
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		if ( Role == ROLE_Authority && bCanLock)
		{
			bTargetLockingActive = true;
		}
	}
}

/**
* This function checks to see if we are locked on a target
*/
function CheckTargetLock()
{
	local Pawn P, LockedPawn;
	local Actor BestTarget, HitActor, TA;
	local UDKBot BotController;
	local vector StartTrace, EndTrace, Aim, HitLocation, HitNormal;
	local rotator AimRot;
	local float BestAim, BestDist;

	if ( (Instigator == None) || (Instigator.Controller == None) || (self != Instigator.Weapon) )
	{
		return;
	}

	if ( Instigator.bNoWeaponFiring )
	{
		AdjustLockTarget(None);
		PendingLockedTarget = None;
		return;
	}

	// support keeping lock as players get onto hoverboard
	if ( LockedTarget != None )
	{
		if ( LockedTarget.bDeleteMe )
		{
			if ( (LockedTargetPRI != None) && (UTVehicle_Hoverboard(LockedTarget) != None) )
			{
				// find the appropriate pawn
				for ( P=WorldInfo.PawnList; P!=None; P=P.NextPawn )
				{
					if ( P.PlayerReplicationInfo == LockedTargetPRI )
					{
						AdjustLockTarget((Vehicle(P) != None) ? None : P);
						break;
					}
				}
			}
			else
			{
				AdjustLockTarget(None);
			}
		}
		else 
		{
			LockedPawn = Pawn(LockedTarget);
			if ( (LockedPawn != None) && (LockedPawn.DrivenVehicle != None) )
			{
				AdjustLockTarget(UTVehicle_Hoverboard(LockedPawn.DrivenVehicle));
			}
		}
	}

	BestTarget = None;
	BotController = UDKBot(Instigator.Controller);
	if ( BotController != None )
	{
		// only try locking onto bot's target
		if ( (BotController.Focus != None) && CanLockOnTo(BotController.Focus) )
		{
			BestTarget = BotController.Focus;
		}
	}
	else
	{
		// Begin by tracing the shot to see if it hits anyone
		Instigator.Controller.GetPlayerViewPoint( StartTrace, AimRot );
		Aim = vector(AimRot);
		StartTrace=StartTrace+Aim*150; 
		EndTrace = StartTrace + Aim * LockRange;
		HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true,,, TRACEFLAG_Bullet);

		// Check for a hit
		if ( (HitActor == None) || !CanLockOnTo(HitActor) )
		{
			// We didn't hit a valid target, have the controller attempt to pick a good target
			BestAim = ((UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer) ? ConsoleLockAim : LockAim;
			BestDist = 0.0;
			TA = Instigator.Controller.PickTarget(class'Pawn', BestAim, BestDist, Aim, StartTrace, LockRange); 
			if ( TA != None && CanLockOnTo(TA) )
			{
				BestTarget = TA;
			}
		}
		else    // We hit a valid target
		{
			BestTarget = HitActor;
		}
	}

	// If we have a "possible" target, note its time mark
	if ( BestTarget != None )
	{
		LastValidTargetTime = WorldInfo.TimeSeconds;

		if ( BestTarget == LockedTarget )
		{
			LastLockedOnTime = WorldInfo.TimeSeconds;
		}
		else
		{
			if ( LockedTarget != None && ((WorldInfo.TimeSeconds - LastLockedOnTime > LockTolerance) || !CanLockOnTo(LockedTarget)) )
			{
				// Invalidate the current locked Target
				AdjustLockTarget(None);
			}

			// We have our best target, see if they should become our current target.
			// Check for a new Pending Lock
			if (PendingLockedTarget != BestTarget)
			{
				PendingLockedTarget = BestTarget;
				PendingLockedTargetTime = ((Vehicle(PendingLockedTarget) != None) && (UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer)
										? WorldInfo.TimeSeconds + 0.5*LockAcquireTime
										: WorldInfo.TimeSeconds + LockAcquireTime;
			}

			// Otherwise check to see if we have been tracking the pending lock long enough
			else if (PendingLockedTarget == BestTarget && WorldInfo.TimeSeconds >= PendingLockedTargetTime )
			{
				AdjustLockTarget(PendingLockedTarget);
				LastLockedOnTime = WorldInfo.TimeSeconds;
				PendingLockedTarget = None;
				PendingLockedTargetTime = 0.0;
			}
		}
	}
	else 
	{
		if ( LockedTarget != None && ((WorldInfo.TimeSeconds - LastLockedOnTime > LockTolerance) || !CanLockOnTo(LockedTarget)) )
		{
			// Invalidate the current locked Target
			AdjustLockTarget(None);
		}

		// Next attempt to invalidate the Pending Target
		if ( PendingLockedTarget != None && ((WorldInfo.TimeSeconds - LastValidTargetTime > LockTolerance) || !CanLockOnTo(PendingLockedTarget)) )
		{
			PendingLockedTarget = None;
		}
	}
}

/**
 * Draw the Crosshairs
 * halo2pac - implemented code that changes crosshair color based on whats targeted.
 **/
simulated function DrawCrosshair( Hud HUD )
{
	local float x,y;
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam;
	local LinearColor LC; //nBab
	local float XResScale, MinDotScale;

	local vector ScreenLoc; 

	local bool bTargetBehindUs;
	
	local float TweenPercentage;

	local Rotator LockOnRotation;
	local Vector LockPosNormal;
	local Vector LockPos[4];
	local int i;	
	
	if(PendingLockedTargetTime == 0.0)
		TweenPercentage = 0.f;
	else
	{
		TweenPercentage = 1.f - FClamp(((PendingLockedTargetTime - WorldInfo.TimeSeconds) / LockAcquireTime), 0.0, 1.0);

	}

	//set initial color based on settings (nBab)
	LC.A = 1.f;
	switch (Rx_HUD(Rx_Controller(Instigator.Controller).myHUD).SystemSettingsHandler.GetCrosshairColor())
	{
		//white
		case 0:
			LC.R = 1.f;
			LC.G = 1.f;
			LC.B = 1.f;
			break;
		//orange
		case 1:
			LC.R = 2.f;
			LC.G = 0.5f;
			LC.B = 0.f;
			break;
		//violet
		case 2:
			LC.R = 2.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//blue
		case 3:
			LC.R = 0.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//cyan
		case 4:
			LC.R = 0.f;
			LC.G = 2.f;
			LC.B = 2.f;
			break;	
	}	

	H = UTHUDBase(HUD);
	if ( H == None )
		return;
		
	XResScale = H.Canvas.SizeX/1920.0;
	MinDotScale = Fmax(XResScale, 0.73); //Under this, the dot will not render 
		
	CrosshairWidth = (default.CrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling) * XResScale;	
	CrosshairHeight = (default.CrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling) * XResScale;
		
	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (CrosshairHeight * 0.5);	
	
	MyPawnOwner = Pawn(Owner);

	//determines what we are looking at and what color we should use based on that.
	if (MyPawnOwner != None)
	{
		TargetActor = Rx_Hud(HUD).GetActorWeaponIsAimingAt();
		if (Pawn(TargetActor) == None && Rx_Weapon_DeployedActor(TargetActor) == None && 
			Rx_Building(TargetActor) == None && Rx_BuildingAttachment(TargetActor) == None)
		{
			TargetActor = (TargetActor == None) ? None : Pawn(TargetActor.Base);
		}
		
		if(TargetActor != None)
		{
			targetTeam = TargetActor.GetTeamNum();
			
			if (targetTeam == 0 || targetTeam == 1) //has to be gdi or nod player
			{
				if (targetTeam != MyPawnOwner.GetTeamNum())
				{
					if (!TargetActor.IsInState('Stealthed') && !TargetActor.IsInState('BeenShot'))
					{
						//enemy, go red, except if stealthed (else would be cheating ;] )
						//nBab
						LC.R = 10.f;
						LC.G = 0.f;
						LC.B = 0.f;
					}
				}
				else
				{
					//Friendly
					//nBab
					LC.R = 0.f;
					LC.G = 10.f;
					LC.B = 0.f;
				}
			}
		}
	}
	
	if (!HasAnyAmmo()) //no ammo, go yellow
	{
		//nBab
		LC.R = 10.f;
		LC.G = 8.f;
		LC.B = 0.f;
	}
	else
	{
		if (Rx_Weapon_Reloadable(self) != None && (Rx_Weapon_Reloadable(self).CurrentlyReloading 
				|| (Rx_Weapon_Reloadable(self).CurrentlyBoltReloading || (Rx_Weapon_Reloadable(self).BoltActionReload && HasAmmo(CurrentFireMode) && IsTimerActive('BoltActionReloadTimer'))))) //reloading, go yellow
		{
			//nBab
			LC.R = 10.f;
			LC.G = 8.f;
			LC.B = 0.f;
		}

	}

	//nBab
	CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	CrosshairDotMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	if(ADSCrosshairMIC2 != None)
		ADSCrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	
	H.Canvas.SetPos( CrosshairLinesX, CrosshairLinesY );
	if(bDisplayCrosshair) 
	{
		if(bIronsightActivated && ADSCrosshairMIC2 != None)
			H.Canvas.DrawMaterialTile(ADSCrosshairMIC2, CrosshairWidth, CrosshairHeight);
					
		else
			H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);

		if(PendingLockedTarget != none)
		{
			bTargetBehindUs = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Rx_Controller(Instigator.Controller).ViewTarget.Location,Instigator.Controller.Rotation,PendingLockedTarget.location) < -0.5;
				
			if(!bTargetBehindUs && TargetMIC2 != None)
			{
				LC.R = 1.f;
				LC.G = 10.f;
				LC.B = 1.f;
				CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);

				LC.G = 1.f;
				TargetMIC2.SetVectorParameterValue('Reticle_Colour', LC);
				ScreenLoc = PendingLockedTarget.GetTargetLocation(); 
				ScreenLoc = H.Canvas.Project(ScreenLoc);
				for(i=0;i<4;i++)
				{
					LockOnRotation.Pitch = 0.f;
					LockOnRotation.Roll = 0.f;
					LockOnRotation.Yaw = ((45.f + (90.f * i)) * DegToUnrRot) + (Lerp(-90.0 * DegToUnrRot, 0, TweenPercentage));
					LockPosNormal = Vector(LockOnRotation);


					LockPos[i].X = ScreenLoc.X + (-1 * LockOnSize/2) + (-0.72 * LockOnSize * LockPosNormal.X) + (-1 * (LockOnSize * (1.0 - TweenPercentage)) * LockPosNormal.X);
					LockPos[i].Y = ScreenLoc.Y + (-1 * LockOnSize/2) + (-0.72 * LockOnSize * LockPosNormal.Y) + (-1 * (LockOnSize * (1.0 - TweenPercentage)) * LockPosNormal.Y);

					LockOnRotation.Yaw -= (45.f * DegToUnrRot);

					H.Canvas.SetPos( LockPos[i].X, LockPos[i].Y );
					H.Canvas.DrawRotatedMaterialTile(TargetMIC2, LockOnRotation,LockOnSize, LockOnSize);	
				}				
			}
		}
				
	}

	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5 * MinDotScale);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5 * MinDotScale);
	GetCrosshairDotLoc(x, y, H);
	H.Canvas.SetPos( X, Y );
	if(bDisplayCrosshair) 
	{
		H.Canvas.DrawMaterialTile(CrosshairDotMIC2, default.CrosshairWidth*MinDotScale, default.CrosshairHeight*MinDotScale);
		
	}
	DrawHitIndicator(H,x,y);
	
}


simulated function DrawLockedOn( HUD H )
{
	local float XResScale, MinDotScale;
    local float x, y;
    local LinearColor LC; //nBab
	local vector ScreenLoc; 
	local bool bTargetBehindUs;
	local float TweenPercentage;

	local Rotator LockOnRotation;
	local Vector LockPosNormal;
	local Vector LockPos[4];
	local int i;

	if(PendingLockedTargetTime == 0.0)
		TweenPercentage = 1.f;
	else
	{
		TweenPercentage = 1.f - FClamp(((PendingLockedTargetTime - WorldInfo.TimeSeconds) / LockAcquireTime), 0.0, 1.0);
	}
	
	//set initial color based on settings (nBab)
	LC.A = 1.f;
	switch (Rx_HUD(Rx_Controller(Instigator.Controller).myHUD).SystemSettingsHandler.GetCrosshairColor())
	{
		//white
		case 0:
			LC.R = 1.f;
			LC.G = 1.f;
			LC.B = 1.f;
			break;
		//orange
		case 1:
			LC.R = 2.f;
			LC.G = 0.5f;
			LC.B = 0.f;
			break;
		//violet
		case 2:
			LC.R = 2.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//blue
		case 3:
			LC.R = 0.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//cyan
		case 4:
			LC.R = 0.f;
			LC.G = 2.f;
			LC.B = 2.f;
			break;	
	}
	CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	LockedOnCrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	if(ADSCrosshairMIC2 != None)
		ADSCrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);

   	if (H == none || H.Canvas == none)
      	return;

	XResScale = H.Canvas.SizeX/1920.0;
	MinDotScale = Fmax(XResScale, 0.73); //Under this, the dot will not render 
		
	CrosshairWidth = (default.CrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling) * XResScale;	
	CrosshairHeight = (default.CrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling) * XResScale;
	X = H.Canvas.ClipX * 0.5 - (CrosshairWidth * 0.5);
	Y = H.Canvas.ClipY * 0.5 - (CrosshairHeight * 0.5);

    H.Canvas.SetPos(x, y);

	if(bIronsightActivated && ADSCrosshairMIC2 != None)
		H.Canvas.DrawMaterialTile(ADSCrosshairMIC2, CrosshairWidth, CrosshairHeight);
					
	else
		H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
 
    if ( LockedOnCrosshairMIC2 != none )
    {
        H.Canvas.SetPos(x, y);
        H.Canvas.DrawMaterialTile(LockedOnCrosshairMIC2,CrosshairWidth, CrosshairHeight,0.0,0.0,1.0,1.0);
		if(LockedTarget != none)
		{
			bTargetBehindUs = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Rx_Controller(Instigator.Controller).ViewTarget.Location,Instigator.Controller.Rotation,LockedTarget.location) < -0.5;
			
			if(!bTargetBehindUs && TargetMIC2 != None)
			{
				LC.R = 10.f;
				LC.G = 0.f;
				LC.B = 0.f;
				CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
				TargetMIC2.SetVectorParameterValue('Reticle_Colour', LC);
				ScreenLoc = LockedTarget.GetTargetLocation(); 
				ScreenLoc = H.Canvas.Project(ScreenLoc);

				for(i=0;i<4;i++)
				{
					LockOnRotation.Pitch = 0.f;
					LockOnRotation.Roll = 0.f;
					LockOnRotation.Yaw = ((45.f + (90.f * i)) * DegToUnrRot) + (Lerp(-90.0 * DegToUnrRot, 0, TweenPercentage));
					LockPosNormal = Vector(LockOnRotation);

					LockPos[i].X = ScreenLoc.X + (-1 * LockOnSize/2) + (-0.72 * LockOnSize * LockPosNormal.X) + (-1 * (LockOnSize * (1.0 - TweenPercentage)) * LockPosNormal.X);
					LockPos[i].Y = ScreenLoc.Y + (-1 * LockOnSize/2) + (-0.72 * LockOnSize * LockPosNormal.Y) + (-1 * (LockOnSize * (1.0 - TweenPercentage)) * LockPosNormal.Y);

					LockOnRotation.Yaw -= (45 * DegToUnrRot);

					H.Canvas.SetPos( LockPos[i].X, LockPos[i].Y );
					H.Canvas.DrawRotatedMaterialTile(TargetMIC2, LockOnRotation,LockOnSize, LockOnSize);	
				}
			}
		}
        DrawHitIndicator(H,x,y);
    }

	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5 * MinDotScale);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5 * MinDotScale);
	GetCrosshairDotLoc(x, y, H);
	H.Canvas.SetPos( X, Y );
	if(bDisplayCrosshair) 
	{
		H.Canvas.DrawMaterialTile(CrosshairDotMIC2, default.CrosshairWidth*MinDotScale, default.CrosshairHeight*MinDotScale);	
	}
}

simulated function DrawHitIndicator(HUD H, float x, float y)
{
	local vector2d CrosshairSize;
	local float XResScale, MinDotScale;
	local LinearColor LC; 
	
	if(Rx_Hud(H).GetHitEffectAplha() <= 0.0) {
		return;
	}	
	
	LC=Rx_Hud(H).HitMarker_Color;
	
	XResScale = H.Canvas.SizeX/1920.0;
	MinDotScale = Fmax(XResScale, 0.73);
	
    CrosshairSize.Y = default.CrosshairHeight*MinDotScale;
    CrosshairSize.X = default.CrosshairWidth*MinDotScale;
    H.Canvas.SetPos(x, y);
	
	HitIndicatorCrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
    HitIndicatorCrosshairMIC2.SetScalarParameterValue('Reticle_Opacity', Rx_Hud(H).GetHitEffectAplha()/100.0);
    H.Canvas.DrawMaterialTile(HitIndicatorCrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
}

simulated function GetCrosshairDotLoc( out float x, out float y, Hud H )
{
	CrosshairDotDrawX = CrosshairLinesX;
	CrosshairDotDrawY = CrosshairLinesY;
	bCrosshairDotCentered = true;
	x = CrosshairDotDrawX;
	y = CrosshairDotDrawY;
}

simulated function int GetUseableAmmo()
{
	return 1;
}

simulated function int GetMaxAmmoInClip()
{
	return 1;
}

simulated function int GetReserveAmmo()
{
	return AmmoCount - 1;
}

simulated function PerformRefill()
{
	if(bIsCrateWeapon)
		return;

	AmmoCount = MaxAmmoCount;
}

simulated function PlayWeaponPutDown()
{	
	if(AttachedWeaponAbilityClass != none && Rx_Pawn(Instigator).PreviousWeaponClass == AttachedWeaponAbilityClass)
	{
		if ( WeaponPutDownAnim != '' )
			PlayWeaponAnimation( WeaponPutDownAnim, PutDownTime );
		if ( ArmsPutDownAnim != '' && ArmsAnimSet != none)
		{
			PlayArmAnimation( ArmsPutDownAnim, PutDownTime );
		}

	// play any associated sound
	if ( WeaponPutDownSnd != None )
		WeaponPlaySound( WeaponPutDownSnd );
	}
	else {
		super.PlayWeaponPutDown();
		if(Owner != None && ThirdPersonWeaponPutDownAnim != '') {
			Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration( ThirdPersonWeaponPutDownAnim, PutDownTime,0.1f,0.1f,false,true);
		}
	}	

}

//Edit to WeaponPutdown (We actually have put down animations for 3rd person....)
/**
 * Sets the timing for putting a weapon down.  The WeaponIsDown event is trigged when expired
*/
simulated function TimeWeaponPutDown()
{
	if(PutDownTime > 0.0)
		PlayWeaponPutDown();

	super(UDKWeapon).TimeWeaponPutDown();
}

simulated function PlayWeaponEquip()
{
	PlayWeaponEquipWithOptionalAnim(true);
	//`log("Play Weapon Equip" @ VRank);
	if(VRank == 3) 
		UpdateHeroicEffects(true);
}

simulated function PlayWeaponEquipWithOptionalAnim(bool bWithEquipAnim)
{
	/*super call inject to handle swapping to particular weapons like abilities*/
	//`log(Rx_Pawn(Instigator).PreviousWeaponClass );
	// Play the animation for the weapon being put down
	if(AttachedWeaponAbilityClass != none && Rx_Pawn(Instigator).PreviousWeaponClass == AttachedWeaponAbilityClass){
		if ( SwapFromAbilityAnim != '' )
		PlayWeaponAnimation( SwapFromAbilityAnim, EquipTime );
	if ( SwapFromAbilityArmAnim != '' && ArmsAnimSet != none)
	{
		PlayArmAnimation(SwapFromAbilityArmAnim, EquipTime);
	}
	// play any assoicated sound
	if ( WeaponEquipSnd != None )
		WeaponPlaySound( WeaponEquipSnd );
	} else {
		super.PlayWeaponEquip();
		if(bWithEquipAnim && ThirdPersonWeaponEquipAnim != '')
		{
			if(Owner != None && Rx_Pawn(Owner).TopHalfAnimSlot != None && !Rx_Pawn(Owner).bIsPtPawn) {
				//Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration(ThirdPersonWeaponEquipAnim,EquipTime,0.1,0.1,false,true);
				Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnim( ThirdPersonWeaponEquipAnim, 1.0, 0.25, 0.6, false, true);
			} else if(Owner != None && Rx_Pawn(Owner).TopHalfAnimSlot != None && Rx_Pawn(Owner).bIsPtPawn) {
				Rx_Pawn(Owner).sethidden(false);
				Rx_Pawn(Owner).SetHandIKEnabled(false);
			}
		}
	}
}

// Modfied version of UTWeapon::PlayFireEffects. Plays ADS animations if applicable.
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	// Play Weapon fire animation
	if (bIronsightActivated && FireModeNum < WeaponADSFireAnim.Length && WeaponADSFireAnim[FireModeNum] != '')
		PlayWeaponAnimation( WeaponADSFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
	else if (FireModeNum < WeaponFireAnim.Length && WeaponFireAnim[FireModeNum] != '')
		PlayWeaponAnimation( WeaponFireAnim[FireModeNum], GetFireInterval(FireModeNum) );

	if ( ArmsAnimSet != none )
	{
		if (bIronsightActivated && FireModeNum < ArmADSFireAnim.Length && ArmADSFireAnim[FireModeNum] != '')
			PlayArmAnimation( ArmADSFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
		else if ( FireModeNum < ArmFireAnim.Length && ArmFireAnim[FireModeNum] != '')
			PlayArmAnimation( ArmFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
	}

	// Start muzzle flash effect
	CauseMuzzleFlash();

	ShakeView();
}

simulated function vector InstantFireStartTrace()
{
	local Vector ViewLocation;
	local Rotator ViewRotation;
	local vector AdjustedCameraLocation; 
	//local vector AdjustedPlayerLocation;
	
    if( Rx_Controller(Instigator.Controller) != None && Rx_Controller(Instigator.Controller).bBehindView)
    {
		Instigator.Controller.GetPlayerViewPoint(ViewLocation, ViewRotation);	
		//AdjustedCameraLocation = ViewLocation; 
		AdjustedCameraLocation = ViewLocation + vector(ViewRotation) * 150 ;//150 ;
		
		//AdjustedPlayerLocation=Instigator.location; 
		//AdjustedPlayerLocation.z += 50; 
		
		/*if(Trace(TempLoc, TempNormal, AdjustedPlayerLocation, ViewLocation, TRUE,,, TRACEFLAG_Bullet) != none)
		{
		
		}*/			
        
        
	
		//`log("Trace blocked by: " @ Trace(TempLoc, TempNormal, AdjustedPlayerLocation, ViewLocation, TRUE,,, TRACEFLAG_Bullet) @ "Adjusted Viewpoint: " @ AdjustedCameraLocation);
		
		if(WorldInfo.NetMode == NM_DedicatedServer) {
			ViewLocation.z += 6;	
		}        
		//`log("View Location: " @ ViewLocation );
		return AdjustedCameraLocation; //ViewLocation;
			
	}

	//`log("GetWeaponStartTraceLocation: " @ Instigator.GetWeaponStartTraceLocation() );
	return Instigator.GetWeaponStartTraceLocation();
}

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */
simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	if(!UsesClientSideProjectiles(CurrentFireMode)) {
		return ProjectileFireOld();
	}
	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	// this is the location where the projectile is spawned.
	RealStartLoc = GetPhysicalFireStartLoc();
	
	//`log("Start Location: " @ RealStartLoc);
	
	// Spawn projectile	
	SpawnedProjectile = Spawn(GetProjectileClassSimulated(),,, RealStartLoc);
	if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
	{
		if(Rx_Projectile(SpawnedProjectile) != none) 
			Rx_Projectile(SpawnedProjectile).SetWeaponInstigator(self);
		
		if(Rx_Bot(instigator.Controller) != None) {
			SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc ) ) );
		} else {
			SpawnedProjectile.Init( Vector(GetAdjustedWeaponAim( RealStartLoc )) );
		}
		
		if(WorldInfo.Netmode == NM_Client && Rx_Weapon_Reloadable(self) != None) {
			Rx_Weapon_Reloadable(self).CurrentAmmoInClipClientside -= default.ShotCost[CurrentFireMode];
			
		}

    	if (bLockedOnTarget && Rx_Projectile_Rocket(SpawnedProjectile) != None)
    	{
       		Rx_Projectile_Rocket(SpawnedProjectile).FinalSeekTarget = LockedTarget;
       		Rx_Projectile_Rocket(SpawnedProjectile).GotoState('Homing');
    	}  
	}
	
	// Return it up the line
	return SpawnedProjectile;
}

simulated function Projectile ProjectileFireOld()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;
	local Rx_Projectile_Rocket SpawnedRocket;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( ROLE == Role_Authority) 
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();
		
		// Spawn projectile	
		SpawnedProjectile = Spawn(GetProjectileClassSimulated(),,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{

			if(Rx_Projectile(SpawnedProjectile) != none) 
				Rx_Projectile(SpawnedProjectile).SetWeaponInstigator(self);
			
			SpawnedProjectile.Init( Vector(GetAdjustedWeaponAim( RealStartLoc )) );
		
			SpawnedRocket = Rx_Projectile_Rocket(SpawnedProjectile);

			if(SpawnedRocket != none)
			{
	
				/*Set the target to an Actor if there is one.*/
				if (bLockedOnTarget)
    			{
					if(SpawnedRocket.RocketStages.Length > 0 &&  SpawnedRocket.RocketStages[0].bIgnoreHoming )
					{
						SpawnedRocket.FinalSeekTarget = LockedTarget;
					}
					else
						SpawnedRocket.SeekTarget = LockedTarget;
	   				//SpawnedRocket.Target = LockedTarget.GetTargetLocation();
       				SpawnedRocket.GotoState('Homing');
    			}
				else //No Actor targeted, get a vector location instead
				{
					SetRocketTargetLocation(SpawnedRocket); 
				}
			}
		}
		
		// Return it up the line
		return SpawnedProjectile;
	} 
	else 
	{
		AddSpread(Instigator.GetBaseAimRotation());
		return none; 
	}
}

/*Used if we couldn't just set the target to an Actor*/
simulated function SetRocketTargetLocation(Rx_Projectile_Rocket Rocket)
{
	local vector CameraLocation, HitLocation, HitNormal, DesiredAimPoint;
	local rotator CameraRotation;	
	local Controller C;
	local Rx_Pawn PawnOwner;
	//`log("Set Rocket Target"); 
		//Rocket.Target = GetDesiredAimPoint() // The Trace in GetDesiredAimPoint() sometimes wasent accurate enough in all situations and has been modified below
		
		PawnOwner = Rx_Pawn(Owner);
		
		C = (PawnOwner != None) ? PawnOwner.Controller : None;
		if(PlayerController(C) != None)
		{
			PlayerController(Instigator.Controller).GetPlayerViewPoint(CameraLocation, CameraRotation);
			
			if(Rx_Controller(Instigator.Controller).bBehindView && Rx_Controller(Instigator.Controller).ViewTarget != none) CameraLocation = CameraLocation + vector(CameraRotation) * VSize(CameraLocation - PawnOwner.Location);// GetWeaponStartTraceLocation(self) );//Rx_Controller(Instigator.Controller).ViewTarget.location); //Again, the camera is capable of getting stuck in both geometry and behind vehicles. Scan up closer to the actual vehicle so we don't shoot behind ourselves.
			//`log(VSize(CameraLocation -  MyVehicle.GetEffectLocation(SeatIndex)));//Rx_Controller(Instigator.Controller).ViewTarget.location));
			DesiredAimPoint = CameraLocation + Vector(CameraRotation) * GetTraceRange(); 
			if (GetTraceOwner().Trace(HitLocation, HitNormal, DesiredAimPoint, CameraLocation, true, vect(0,0,0),,TRACEFLAG_Bullet) != None)
			{
				DesiredAimPoint = HitLocation;
			}
		}
		else if ( C != None )
		{
			DesiredAimPoint = C.GetFocalPoint();
		}	
		Rocket.Target = DesiredAimPoint;	
		
		Rocket.GotoState('Homing');
}

simulated function class<Projectile> GetProjectileClassSimulated(optional byte FMTag = 255)
{
	if (FMTag == 255)
		return (CurrentFireMode < WeaponProjectiles.length) ? WeaponProjectiles[CurrentFireMode] : None;
	else
		return (CurrentFireMode < WeaponProjectiles.length) ? WeaponProjectiles[FMTag] : None;
}

function class<Projectile> GetProjectileClass()
{
	if (bLockedOnTarget)
	{
		return SeekingRocketClass;
	}
	else
	{
		return WeaponProjectiles[CurrentFireMode];
	}
}

/**
 * Changes the tracer to originate from the gun barrel
 */
simulated function Rotator GetAdjustedWeaponAim( Vector FireStartLoc )
{
	local Vector TempStart, TempEnd, NewLoc;//, HitNormal;
	//local Actor Hit;
	local ImpactInfo	TestImpact;
	
	if (Rx_Bot(Instigator.Controller) != none)
	{
		// This is needed for bots to aim up or down
		TempStart = super.InstantFireStartTrace();
		TempEnd = TempStart + Vector(AddSpread(Instigator.GetViewRotation())) * GetTraceRange();
	}
	else
	{
		TempStart = InstantFireStartTrace();
		TempEnd = TempStart + Vector(AddSpread(Instigator.GetBaseAimRotation())) * GetTraceRange();
	}
	
	//Collision fix by triggerhippy.
	//Now tests for 1st real hit, rather than simply 1st object hit by a simple trace.
	TestImpact = CalcWeaponFire( TempStart, TempEnd );
	NewLoc = TestImpact.HitLocation;

	//Original Code:
	//Hit = GetTraceOwner().Trace(NewLoc, HitNormal, TempEnd, TempStart, true); // new end		
	//if (Hit == none)
	//	NewLoc = TempEnd;

	return Rotator(NewLoc + Normal(Vector(Instigator.GetViewRotation())) * 30 + (FireStartLoc * -1) ); // small bugfix to shift forward, to really hit the aim
}

simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local UTPlayerController PC;
	local vector FireStartLoc, HitLocation, HitNormal, FireDir, FireEnd, ProjBox;
	local Actor HitActor;
	local rotator FireRot;
	local class<Projectile> FiredProjectileClass;
	local int TraceFlags;

	if( Instigator != none )
	{
		PC = UTPlayerController(Instigator.Controller);

		FireRot = Instigator.GetViewRotation();
		FireDir = vector(FireRot);
		if (PC == none || PC.bCenteredWeaponFire || PC.WeaponHand == HAND_Centered || PC.WeaponHand == HAND_Hidden)
		{
			FireStartLoc = Instigator.GetPawnViewLocation() + (FireDir * FireOffset.X);
		}
		else if (PC.WeaponHand == HAND_Left)
		{
			FireStartLoc = Instigator.GetPawnViewLocation() + ((FireOffset * vect(1,-1,1)) >> FireRot);
		}
		else
		{
			FireStartLoc = Instigator.GetPawnViewLocation() + (FireOffset >> FireRot);
		}

		if ( (PC != None) || (CustomTimeDilation < 1.0) )
		{
			FiredProjectileClass = GetProjectileClass();
			if ( FiredProjectileClass != None )
			{
				FireEnd = FireStartLoc + FireDir * ProjectileSpawnOffset;
				TraceFlags = bCollideComplex ? TRACEFLAG_Bullet : 0;
				if (FiredProjectileClass.default.CylinderComponent != none && FiredProjectileClass.default.CylinderComponent.CollisionRadius > 0 )
				{
					FireEnd += FireDir * FiredProjectileClass.default.CylinderComponent.Translation.X;
					ProjBox = FiredProjectileClass.default.CylinderComponent.CollisionRadius * vect(1,1,0);
					ProjBox.Z = FiredProjectileClass.default.CylinderComponent.CollisionHeight;
					HitActor = Trace(HitLocation, HitNormal, FireEnd, Instigator.Location, true, ProjBox,,TraceFlags);
					if ( HitActor == None )
					{
						HitActor = Trace(HitLocation, HitNormal, FireEnd, FireStartLoc, true, ProjBox,,TraceFlags);
					}
					else
					{
						FireStartLoc = Instigator.Location - FireDir*FiredProjectileClass.default.CylinderComponent.Translation.X;
						FireStartLoc.Z = FireStartLoc.Z + FMin(Instigator.EyeHeight, Instigator.CylinderComponent.CollisionHeight - FiredProjectileClass.default.CylinderComponent.CollisionHeight - 1.0);
						return FireStartLoc;
					}
				}
				else
				{
					HitActor = Trace(HitLocation, HitNormal, FireEnd, FireStartLoc, true, vect(0,0,0),,TraceFlags);
				}
				return (HitActor == None) ? FireEnd : HitLocation - 3*FireDir;
			}
		}
		return FireStartLoc;
	}

	return Location;
}

/**
 * More weapon collision fixes
 * Copied over from UTWeapon, modified to fire from barrel.
 */
simulated function InstantFire()
{
	local vector StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact;
	local int i;
	
	local vector			HitLocation, HitNormal;
	local TraceHitInfo		HitInfo;	
	
	if(WorldInfo.NetMode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		return;	
	} else if(WorldInfo.Netmode == NM_Client && Rx_Weapon_Reloadable(self) != None) {
		Rx_Weapon_Reloadable(self).CurrentAmmoInClipClientside -= default.ShotCost[CurrentFireMode];
	}
	
	//This code is basically just going to find what the crosshairs are on, to set the end point of our direction vector
	StartTrace = InstantFireStartTrace();
	
	EndTrace = InstantFireEndTrace(StartTrace);
	bUsingAimingHelp = false;
	
	if(!bPierceInfantry && !bPierceVehicles)
		GetTraceOwner().Trace(HitLocation, HitNormal, EndTrace, StartTrace, TRUE, , HitInfo, TRACEFLAG_Bullet);
	else
		GetTraceOwner().Trace(HitLocation, HitNormal, EndTrace, StartTrace, FALSE, , HitInfo, TRACEFLAG_Bullet);
	
	if(HitLocation != vect(0,0,0))
	{
		EndTrace = HitLocation;
		EndTrace = EndTrace + (100 * Normal(EndTrace - Instigator.GetWeaponStartTraceLocation()));
	}
	//DrawDebugLine(Instigator.GetWeaponStartTraceLocation(),EndTrace,0,0,255,true);
	
	//Add any possible modifiers to CurrentPiercingPower
	CurrentPiercingPower = (CurrentPiercingPower*1.0)*GetPierceModifier(); 
	//`log(CurrentPiercingPower);
	
	RealImpact = CalcWeaponFire(Instigator.GetWeaponStartTraceLocation(), EndTrace, ImpactList);
	
	//Reset Piercing ability after calculating weapon fire
	CurrentPiercingPower = default.CurrentPiercingPower; 
	
	for (i = 0; i < ImpactList.length; i++)
	{
		if(WorldInfo.NetMode != NM_DedicatedServer && Instigator.Controller.IsLocalPlayerController()) {
			
			if(WorldInfo.NetMode == NM_Client && FracturedStaticMeshActor(RealImpact.HitActor) != None) {
				ProcessInstantHit(CurrentFireMode, ImpactList[i]);
			}
			
			if(Pawn(ImpactList[i].HitActor) != None && Pawn(ImpactList[i].HitActor).Health > 0 && Pawn(ImpactList[i].HitActor).GetTeamNum() != Instigator.GetTeamNum()) {
				Rx_Hud(Rx_Controller(Instigator.Controller).myHud).ShowHitMarker();
				if(Rx_Pawn(Pawn(ImpactList[i].HitActor)) != None) Rx_Controller(Instigator.Controller).AddHit() ;
			}
			if(!TryHeadshot(CurrentFireMode,ImpactList[i])) {
				ServerALInstanthitHit(CurrentFireMode, ImpactList[i], RealImpact.HitLocation);
			}
		} else if(ROLE == ROLE_Authority && AIController(Instigator.Controller) != None) {
			ProcessInstantHit(CurrentFireMode, ImpactList[i]);
		}
	}

	if (Role == ROLE_Authority && (AIController(Instigator.Controller) != None || WorldInfo.NetMode == NM_StandAlone))
	{
		// Set flash location to trigger client side effects.
		// if HitActor == None, then HitLocation represents the end of the trace (maxrange)
		// Remote clients perform another trace to retrieve the remaining Hit Information (HitActor, HitNormal, HitInfo...)
		// Here, The final impact is replicated. More complex bullet physics (bounce, penetration...)
		// would probably have to run a full simulation on remote clients.
		SetFlashLocation(RealImpact.HitLocation);
	} 
	if (InstantHitDamageRadius[CurrentFireMode] > 0)
		InstantFireRadiusDamage(CurrentFireMode, RealImpact.HitLocation, RealImpact.HitNormal, RealImpact.HitActor);
	
	if(Role < ROLE_Authority) {
		Rx_Pawn(Owner).WeaponFired(self,true,RealImpact.HitLocation);
	}
}


//DmgReduction is only setup for projectiles to use. 
simulated function bool TryHeadshot(byte FiringMode, ImpactInfo Impact, optional float DmgReduction = 1.0) 
{
	local float Scaling;
	local int HeadDamage;
    	
	if(WeaponFireTypes[FiringMode] == EWFT_InstantHit)
	{
		if (Instigator == None || VSizeSq(Instigator.Velocity) < Square(Instigator.GroundSpeed * Instigator.CrouchedPct))
		{
			Scaling = SlowHeadshotScale;
		}
		else
		{
			Scaling = RunningHeadshotScale;
		}

		HeadDamage = InstantHitDamage[FiringMode]* HeadShotDamageMult * GetDamageModifier();
		if ( (Rx_Pawn(Impact.HitActor) != None && Rx_Pawn(Impact.HitActor).TakeHeadShot(Impact, HeadShotDamageType, HeadDamage, Scaling, Instigator.Controller, false,,DmgReduction,class<Rx_DmgType_Special>(InstantHitDamageTypes[FiringMode]))))
		{
			SetFlashLocation(Impact.HitLocation);
			return true;
		}
	}
	return false;
}

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local bool bFixMomentum;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
	//We need all of this, as calling super doesn't account for veterancy.
	local int TotalDamage;
	
	if(WorldInfo.NetMode != NM_DedicatedServer && TryHeadshot(FiringMode, Impact)) { // cause Headshotsphere detection is done clientside and then send as a ServerALHeadshotHit()
		return;
	}
	
	if ( Impact.HitActor != None )
	{
		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}
		if ( (Rx_Building(Impact.HitActor) != None || !Impact.HitActor.bStatic) && (Impact.HitActor != Instigator) )
		{
			if ( Impact.HitActor.Role == ROLE_Authority && Impact.HitActor.bProjTarget
				&& !WorldInfo.GRI.OnSameTeam(Instigator, Impact.HitActor)
				&& Impact.HitActor.Instigator != Instigator
				&& PhysicsVolume(Impact.HitActor) == None )
			{
				if(Rx_Pawn(Instigator) != None)
					Rx_Pawn(Instigator).HitEnemyForDemoRec++;	
				HitEnemy++;
				LastHitEnemyTime = WorldInfo.TimeSeconds;
			}
			if ( (UTPawn(Impact.HitActor) == None) && (InstantHitMomentum[FiringMode] == 0) ) 
			{
				InstantHitMomentum[FiringMode] = 1;
				bFixMomentum = true;
			}
			//Super(UDKWeapon).ProcessInstantHit(FiringMode, Impact, NumHits);
			//Copied from SUPER(Weapon) Adjusted to include Veterancy multipliers
				if (Impact.HitActor != None)
			{
			// default damage model is just hits * base damage
			NumHits = Max(NumHits, 1);
			TotalDamage = InstantHitDamage[CurrentFireMode] * GetDamageModifier() * NumHits;

			if ( Impact.HitActor.bWorldGeometry )
			{
				HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
				if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
				{
					NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
					if ( NewKActor != None )
					{
						Impact.HitActor = NewKActor;
					}
				}
			}
			Impact.HitActor.TakeDamage( TotalDamage, Instigator.Controller,
							Impact.HitLocation, InstantHitMomentum[FiringMode] * Impact.RayDir,
							InstantHitDamageTypes[FiringMode], Impact.HitInfo, self );
			}
			//End super call
			
			if (bFixMomentum)
			{
				InstantHitMomentum[FiringMode] = 0;
			}
		}
	}

}

//Burst fire code//

simulated function BurstNextShot()
{
	if(HasAmmo(CurrentFireMode) && CurrentBurst < BurstNum-1)
	{
		FireAmmunition();
		//WeaponPlaySound( WeaponDistantFireSnd );
		if(IsTimerActive('RefireCheckTimer'))
			ClearTimer('RefireCheckTimer');
		SetTimer(TimeBetweenBursts,False,'BurstNextShot');
		CurrentBurst++; 
	}
	else
	{
		CurrentBurst = 0; 
		bIsInBurstFire = false;
		SetTimer( GetBurstCooldown(CurrentFireMode), false, nameof(RefireCheckTimer) );
	}
}


simulated function FireButtonPressed( optional byte FireMode )
{
	bCurrentlyFireing = false;
}

simulated function FireButtonReleased( optional byte FireMode )
{
	bCurrentlyFireing = false;
}

//END Burst fire code

simulated function FireAmmunition()
{
	local int Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec, i ; 
	local float ROFTotal; 
	
	if (MuzzleHeatPerShot > 0.0)
	{
		UpdateMuzzleHeat(MuzzleHeatPerShot);
		SetTimer(MuzzleHeatCooldownWaitTime, false, nameof(StartMuzzleHeatCooldownTick));
	}
	
	if(Rx_Controller(Instigator.Controller) != none) 
	if(Rx_Controller(Instigator.Controller) != none) 
		Rx_Controller(Instigator.Controller).AddShot();
	
	
	GetSystemTime(Year, Month,DayOfWeek, Day, Hour,Min, Sec, MSec ) ;
	
	//Only record FM0 for now, as they're the firemodes prone to exploitation
	if(CurrentFireMode == 0 && (Sec*1000+MSec) - LastFireTime <= FireInterval[CurrentFireMode]*GetROFModifier()*1000 && (Sec*1000+MSec) - LastFireTime > 0) //Vet_ROFModifier[VRank]*1000 && (Sec*1000+MSec) - LastFireTime > 0) 
	{
	ROFAvgs[ROFTicker] = (Sec*1000+MSec) - LastFireTime ;
	
	if(ROFTicker >= ROFTurnover) 
		{
			for(i=0;i<ROFTicker;i++)
				ROFTotal += ROFAvgs[i];
			ROFTicker = 0; 
			ROFTotal=ROFTotal/ROFTurnover;
			
			//`log(ROFTotal @ "/" @ FireInterval[CurrentFireMode]*1000);
			
			if(PrevAVG==0) 
				PrevAVG=FireInterval[CurrentFireMode]*GetROFModifier()*1000; //*Vet_ROFModifier[VRank]*1000;
			
			PrevAVG = (PrevAVG+ROFTotal)/2;
			
			//96 
			
			
			AVGString = PrevAVG @ "/" @ FireInterval[CurrentFireMode]*GetROFModifier()*1000; 
			//`log("["$self.class $"]" @ AVGString);
			}
			ROFTicker+=1;
			 
		
	}
	else
	{
		ROFAvgs[ROFTicker] = FireInterval[CurrentFireMode]*GetROFModifier()*1000;
		
		if(ROFTicker >= ROFTurnover) 
		{
			for(i=0;i<ROFTicker;i++)
				ROFTotal += ROFAvgs[i];
				ROFTicker = 0;
				ROFTotal=ROFTotal/ROFTurnover;
				//`log(ROFTotal @ "/" @ FireInterval[CurrentFireMode]*1000); 
				
				if(PrevAVG==0) 
					PrevAVG=FireInterval[CurrentFireMode]*GetROFModifier()*1000;
				
				PrevAVG = (PrevAVG+ROFTotal)/2;
				
				
				AVGString = PrevAVG @ "/" @ FireInterval[CurrentFireMode]*GetROFModifier()*1000; 
				//`log("["$self.class $"]" @ AVGString);
		}
		ROFTicker +=1; 
		
		
	}	
	
	LastFireTime = Sec*1000+MSec;
	
	if (GetIsBurstFire() && (!bCurrentlyFireing || bConstantFire))
	{
		super.FireAmmunition();
		SetTimer(TimeBetweenBursts,false,'BurstNextShot');
		bCurrentlyFireing = true;
	}
	else
	{
		super.FireAmmunition();
	}
	
	if(bLocSync && WorldInfo.NetMode == NM_Client) 
	{
	LocSyncIncrement--;	
	
	if(LocSyncIncrement <= 0) 
		{
			ServerSendLocSync(Instigator.location); 
			LocSyncIncrement = default.LocSyncIncrement;
		}
	}
	
	RecoilDelay = default.RecoilDelay;
	RecoilSpreadDecreaseDelay = default.RecoilSpreadDecreaseDelay;
	SetWeaponRecoil(RandRange(MinRecoil,MaxRecoil));
	bLogRecoilTemp = true;

	if(Instigator.Controller != none)
	{
		`RecordWeaponIntStat(WEAPON_FIRED,Instigator.Controller,class,1);
		`RecordProjectileIntStat(WEAPON_FIRED,Instigator.Controller,GetProjectileClass(),1);
	}
	else
	{
		`RecordWeaponIntStat(WEAPON_FIRED,none,class,1);
		`RecordProjectileIntStat(WEAPON_FIRED,none,GetProjectileClass(),1);
	}

	if ( Role == ROLE_Authority && !bPersistentLock)
	{
		AdjustLockTarget( none );
		LastValidTargetTime = 0;
		PendingLockedTarget = None;
		LastLockedOnTime = 0;
		PendingLockedTargetTime = 0;
	}
}

simulated function SetWeaponRecoil(int PitchRecoil) {
	local int YawRecoil;
	YawRecoil = (RecoilYawModifier - FRand()) * PitchRecoil * RecoilYawMultiplier;
	RecoilOffset.Pitch += PitchRecoil;
	RecoilOffset.Yaw += YawRecoil;	
}

simulated function string GetROFAVG()
{
	return "["$self.class $"]:" @ AVGString ; 
}

/**
 * Draw the Crosshairs
 */
simulated function DrawWeaponCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y,PickupScale, ScreenX, ScreenY;
	local UTHUDBase	H;
	
	local float TargetDist;

	H = UTHUDBase(HUD);
	if ( H == None )
		return;

	TargetDist = GetTargetDistance();

	// Apply pickup scaling
	if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.3 )
	{
		if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.15 )
		{
			PickupScale = (1 + 5 * (WorldInfo.TimeSeconds - H.LastPickupTime));
		}
		else
		{
			PickupScale = (1 + 5 * (H.LastPickupTime + 0.3 - WorldInfo.TimeSeconds));
		}
	}
	else
	{
		PickupScale = 1.0;
	}

 	CrosshairSize.Y = H.ConfiguredCrosshairScaling * CrosshairScaling * CrossHairCoordinates.VL * PickupScale * H.Canvas.ClipY/720;
  	CrosshairSize.X = CrosshairSize.Y * ( CrossHairCoordinates.UL / CrossHairCoordinates.VL );

	X = H.Canvas.ClipX * 0.5;
	Y = H.Canvas.ClipY * 0.5;
	ScreenX = X - (CrosshairSize.X * 0.5);
	ScreenY = Y - (CrosshairSize.Y * 0.5);
	if ( CrosshairImage != none )
	{
		// crosshair drop shadow
		H.Canvas.DrawColor = H.BlackColor;
		H.Canvas.SetPos( ScreenX+1, ScreenY+1, TargetDist );
		H.Canvas.DrawTexture(CrosshairImage, CrosshairScaling);

		CrosshairColor = H.bGreenCrosshair ? H.Default.LightGreenColor : Default.CrosshairColor;
		H.Canvas.DrawColor = (WorldInfo.TimeSeconds - LastHitEnemyTime < 0.3) ? H.RedColor : CrosshairColor;
		H.Canvas.SetPos(ScreenX, ScreenY, TargetDist);
		H.Canvas.DrawTexture(CrosshairImage, CrosshairScaling);
	}
}

simulated function bool HasInfiniteAmmo() {
	return bHasInfiniteAmmo;
}

function float GetOptimalRangeFor(Actor Target)
{
	if(!bSniping) {
		return MaxRange() / 2;
	}
	return MaxRange();
}

simulated function byte GetInventoryMovieGroup() {
	return InventoryMovieGroup;
}

/** Modified version of super.CanAttack() because Rx_BuildingObjective´s need special treatment */
function bool CanAttack(Actor Other)
{
	local float Dist;
	local vector out_HitLocation;
	local vector out_HitNormal;
	local vector projStart;
	local float CachedMaxRangeTemp;
	local bool ret;
	local Actor RealTarget;

	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}	

	projStart = bInstantHit ? InstantFireStartTrace() : GetPhysicalFireStartLoc();
	
	RealTarget = Other;
	CachedMaxRangeTemp = CachedMaxRange;
	// check that target is within range
	Dist = VSizeSq(Instigator.Location - Other.Location);
	if (Dist > Square(MaxRange()))
	{
		if(Rx_Building(Other) != None || Rx_BuildingObjective(Other) != None || Rx_BuildingAttachment(Other) != None) 
		{
			if(Rx_BuildingObjective(Other) != None && Rx_BuildingObjective(Other).myBuilding != None) 
				RealTarget = Rx_BuildingObjective(Other).myBuilding;

			if(RealTarget != GetTraceOwner().Trace( out_HitLocation, out_HitNormal, RealTarget.GetTargetLocation(), projStart,TRUE,,,TRACEFLAG_Bullet)) 
			{
				if(Rx_Bot(Instigator.Controller) != None)
				{
					Rx_Bot(Instigator.Controller).FireAssessment = "CANNOT ATTACK"@Other@"- LOS obstructed";
				}
				return false;
			}
			Dist = VSizeSq(Instigator.Location - out_HitLocation);
			if(Dist <= Square(MaxRange() - 50))
			{
				CachedMaxRange = 20000;		
			} 
			else 
			{
	            //DrawDebugLine(Instigator.Location,Other.location,0,0,255,true);
	            //DrawDebugLine(Instigator.Location,out_HitLocation,0,255,0,true);
            	//DebugFreezeGame();   
            	if(Rx_Bot(Instigator.Controller) != None)
				{
					Rx_Bot(Instigator.Controller).FireAssessment = "CANNOT ATTACK"@Other@"- Out of Range";
				}
				return false;
			} 
		} 
		else 
		{
			return false;
		}
	}
	ret = Super.CanAttack(RealTarget);
	CachedMaxRange = CachedMaxRangeTemp;
	return ret;
}

function bool CanAttackFromPosition(vector TestLocation, Actor Other)
{
	local float Dist;
	local vector out_HitLocation;
	local vector out_HitNormal;
	local float CachedMaxRangeTemp;
	local bool ret;
	local Actor RealTarget;
	
	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}	
	
	RealTarget = Other;
	CachedMaxRangeTemp = CachedMaxRange;
	// check that target is within range
	Dist = VSizeSq(TestLocation - Other.Location);
	if (Dist > Square(MaxRange()))
	{
		if(Rx_Building(Other) != None || Rx_BuildingObjective(Other) != None) {
			if(Rx_BuildingObjective(Other) != None) {
				RealTarget = Rx_BuildingObjective(Other).myBuilding;
			}
			if(RealTarget != Trace( out_HitLocation, out_HitNormal, Other.location, TestLocation,,,,TRACEFLAG_Bullet)) {
				return false;
			}
			Dist = VSizeSq(TestLocation - out_HitLocation);
			if(Dist <= Square(MaxRange() - 50)) {
				//CachedMaxRange = VSize(TestLocation - Other.Location);		
				CachedMaxRange = 20000;		
			} else {
	            //DrawDebugLine(TestLocation,Other.location,0,0,255,true);
	            //DrawDebugLine(TestLocation,out_HitLocation,0,255,0,true);
            	//DebugFreezeGame();   
				return false;
			} 
		} else {
			return false;
		}
	}
	ret = super.CanAttack(RealTarget);
	CachedMaxRange = CachedMaxRangeTemp;
	return ret;
}

function float RelativeStrengthVersus(Pawn P, float Dist)
{
	if(Rx_Vehicle(P) != None && !Rx_Vehicle(P).bLightArmor && !Rx_Vehicle(P).bIsAircraft && !bOkAgainstVehicles) {
		return -5;
	} else {
		return super.RelativeStrengthVersus(P, Dist);
	}
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local rotator DeltaRecoil;
	local float DeltaPitch, DeltaYaw;
	
	RecoilDelay -= DeltaTime;
	
	if(RecoilDelay <= 0 && RecoilOffset != rot(0,0,0)) {
		DeltaRecoil.Pitch = RecoilOffset.Pitch - FInterpTo(RecoilOffset.Pitch, 0, DeltaTime, RecoilInterpSpeed);
		DeltaRecoil.Yaw = RecoilOffset.Yaw - FInterpTo(RecoilOffset.Yaw, 0, DeltaTime, RecoilInterpSpeed);
		
		TotalRecoil.Pitch += DeltaRecoil.Pitch;
		
		if(TotalRecoil.Pitch > MaxTotalRecoil) {
			if(DeltaRecoil.Pitch > 0) {
				RecoilOffset -= DeltaRecoil;
				out_DeltaRot.Pitch += 1;
				out_DeltaRot.Yaw += DeltaRecoil.Yaw;
			}
		} else {
			RecoilDecline += DeltaRecoil;
			RecoilOffset -= DeltaRecoil;
			out_DeltaRot += DeltaRecoil;
		}
		
		if(DeltaRecoil == rot(0,0,0)) {
			RecoilOffset = rot(0,0,0);
		}
		if(bLogRecoilTemp && PlayerController(Instigator.Controller) != None) {
			//loginternal("recoil: "@RecoilDecline.Pitch);
			//loginternal("spreadincrease: "@RecoilSpread);
			bLogRecoilTemp = false;
		}	
	} else {
		if(RecoilDeclinePct != 0.0 && RecoilDecline != rot(0,0,0)) {
			TotalRecoil = rot(0,0,0);
			DeltaPitch = RecoilDecline.Pitch - FInterpTo(RecoilDecline.Pitch, 0, DeltaTime, RecoilDeclineSpeed);
			DeltaYaw = RecoilDecline.Yaw - FInterpTo(RecoilDecline.Yaw, 0, DeltaTime, RecoilDeclineSpeed);
			
			out_DeltaRot.Pitch -= DeltaPitch * RecoilDeclinePct;
			out_DeltaRot.Yaw -= DeltaYaw * RecoilDeclinePct;
			
			RecoilDecline.Pitch -= DeltaPitch;
			RecoilDecline.Yaw -= DeltaYaw;
			
			if(Abs(DeltaPitch) < 1.0) {
				RecoilDecline = rot(0,0,0);
			}
		}
	}	
	DecreaseRecoilSpread(DeltaTime);
}

simulated function rotator AddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local rotator ret;
	local float RecoilSpreadTemp, RandY, RandZ;

	if(IronSightAndScopedSpread.Length > 0 && (bIronsightActivated || GetZoomedState() != ZST_NotZoomed)) 
	{
		CurrentSpread = IronSightAndScopedSpread[CurrentFireMode];
	} else 
	{
		CurrentSpread = Spread[CurrentFireMode];
	}
	if (CurrentSpread == 0 )
	{
		return BaseAim;
	}
	else
	{
		if(RecoilSpreadIncreasePerShot == 0.0 && Spread[CurrentFireMode] == 0.0 && Rx_Bot(Pawn(owner).controller) == None) 
		{
			ret = BaseAim;
		} 
		else 
		{
			GetAxes(BaseAim, X, Y, Z);
			RandY = FRand() - 0.5;
			RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
			CurrentSpread += RecoilSpread;
			ret = rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
		}
		
		if(RecoilSpreadDecreaseDelay != default.RecoilSpreadDecreaseDelay && RecoilSpreadIncreasePerShot != 0.0) {
			RecoilSpreadTemp = RecoilSpread;
			RecoilSpread += RecoilSpreadIncreasePerShot;
			if(CurrentSpread + RecoilSpread >= MaxSpread) {
				RecoilSpread = RecoilSpreadTemp;
			}
		}
		return ret;
	}
}

simulated function bool ShouldRefire()
{
	if(bAutoFire) 
	{
		if(GetZoomedState() != ZST_NotZoomed && CurrentFireMode != 0)
		{
			ClearPendingFire(0);
			ClearPendingFire(1);
			return false;
		}
		
		if(bROFChanged && IsTimerActive('RefireCheckTimer')) 
			UpdateRateofFire() ;
		
		return super.ShouldRefire();
	} 
		else {
		ClearPendingFire(0);
		ClearPendingFire(1);
		return false;
	}
}


simulated function UpdateRateofFire()
{
	SetTimer(GetFireInterval(CurrentFireMode),true,'RefireCheckTimer');
	SetROFChanged(false); //Reset 
}

simulated function SetROFChanged(bool SetTo)
{
	bROFChanged = SetTo;
}

event Tick( float DeltaTime ) 
{
	super.Tick(DeltaTime);
	if(WorldInfo.NetMode == NM_DedicatedServer || (Instigator != None && Rx_Bot(Instigator.Controller) != None)) 
	{
		DecreaseRecoilSpread(DeltaTime);
	}

	if (bCanLock && bTargetLockingActive && ( WorldInfo.TimeSeconds > LastTargetLockCheckTime + LockCheckTime ) )
	{
		LastTargetLockCheckTime = WorldInfo.TimeSeconds;
		CheckTargetLock();
	}	
}

simulated function DecreaseRecoilSpread(float DeltaTime) {
	local float SpreadModifier;
	
	if(RecoilSpreadDecreaseDelay > 0.0)
		RecoilSpreadDecreaseDelay -= DeltaTime;
	if(RecoilSpreadDecreaseDelay <= 0.0 && RecoilSpread > 0.0) {
		SpreadModifier = RecoilSpreadDeclineSpeed * DeltaTime;
		if(RecoilSpread - SpreadModifier >= 0.0) {
			RecoilSpread -= SpreadModifier;
		} else {
			RecoilSpread = 0.0;	
		}
	}	
}

function float GetAO_OkDist() {
	return 600;
}

/** Function to run when zooming in or out, checks the bIronsightActivated boolean and decides which set of properties to use */
simulated function CheckMyZoom()
{
    Local Pawn P;
    
    P = Pawn(Owner);
    if(P == None) {
    	return;
    }
	if (bIronsightActivated == true)
	{
		//`log("Ironsights activated"); //Yosh Log
    	P.GroundSpeed = Default.ZoomGroundSpeed;
    	/**P.AirSpeed = Default.ZoomAirSpeed;
    	P.WaterSpeed = Default.ZoomWaterSpeed;
    	P.JumpZ = Default.ZoomJumpZ;*/
		if(!UTPlayerController(Instigator.Controller).bBehindView)
			FireOffset=IronSightFireOffset;
		MinRecoil = default.MinRecoil/IronSightMinRecoilDamping;
		MaxRecoil = default.MaxRecoil/IronSightMaxRecoilDamping;
		MaxTotalRecoil = default.MaxTotalRecoil/IronSightMaxTotalRecoilDamping;
		RecoilYawModifier = default.RecoilYawModifier/IronSightRecoilYawDamping;
		MaxSpread = default.MaxSpread/IronSightMaxSpreadDamping;
		RecoilSpreadIncreasePerShot = default.RecoilSpreadIncreasePerShot/IronSightSpreadIncreasePerShotDamping;  	    	
    	/**
		Spread[CurrentFireMode] = Default.SpreadScoped;
		FireInterval[CurrentFireMode] = Default.FireInterval[CurrentFireMode]/1.25;
		*/
	}
	else
	{
		//`log("Ironsights deactivated"); //Yosh Log
		if(!Rx_Pawn(Instigator).bSprinting && !Rx_Pawn(Instigator).bSprintingServer && !Rx_Pawn(Instigator).bDodging) {
    		P.GroundSpeed = class'Rx_Pawn'.Default.GroundSpeed*Rx_Pawn(Instigator).GetSpeedModifier();
	    	//P.AirSpeed = class'Rx_Pawn'.Default.AirSpeed*Rx_Pawn(Instigator).GetSpeedModifier();
		}
    	/**P.WaterSpeed = class'Rx_Pawn'.Default.WaterSpeed*Rx_Pawn(Instigator).GetSpeedModifier();
    	P.JumpZ = class'Rx_Pawn'.Default.JumpZ;
		*/
		
    	FireOffset=default.FireOffset;
		MinRecoil = default.MinRecoil;
		MaxRecoil = default.MaxRecoil;
		MaxTotalRecoil = default.MaxTotalRecoil;
		RecoilYawModifier = default.RecoilYawModifier;
		MaxSpread = default.MaxSpread;
		RecoilSpreadIncreasePerShot = default.RecoilSpreadIncreasePerShot;  	
    	
    	/**
		Spread[CurrentFireMode] = Default.SpreadNoScoped;
		FireInterval[CurrentFireMode] = Default.FireInterval[CurrentFireMode];
		*/
	}
}

reliable server function ServerALInstanthitHit( byte FiringMode, ImpactInfo Impact, vector RealImpactLocation)
{
	if(WorldInfo.Netmode == NM_DedicatedServer){
		SetFlashLocation(RealImpactLocation);
	}
	
	ProcessInstantHit(FiringMode, Impact);
	
	if(Rx_Weapon_Shotgun(self) != None) {
		if(Rx_Pawn(Owner).ShotgunPelletCount <= 10) { 
			Rx_Pawn(Owner).ShotgunPelletHitLocations[Rx_Pawn(Owner).ShotgunPelletCount++] = RealImpactLocation;
		}
	}	
}

reliable server function ServerALHeadshotHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo, optional float DmgReduction = 1.0, optional byte FMTag = 255)
{
	local class<UTProjectile>	ProjectileClass;
	local class<DamageType> 	DamageType, TempDamageType; //TempDamageType Holds the REAL damage type for a weapon
	local Rx_Pawn				Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HeadShotDamageMultLocal, ArmorMultiplier;
	local class<Rx_DmgType_Special> SpecialClass;

	ArmorMultiplier=1; //Used for infantry armour, so it will also apply to headshots
	
	//`log("ServerALHeadshot called");
	if(FMTag != 255)
		ProjectileClass = class<UTProjectile>(WeaponProjectiles[FMTag]);
	else
		ProjectileClass = class<UTProjectile>(GetProjectileClass());
	//`log("PType: " @ ProjectileClass); 
	
	Shooter = Rx_Pawn(Owner);
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(UTPlayercontroller(Instigator.Controller) == None || Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}	

	// If we don't have a projectile class, and are not an instant hit weapon
	if (ProjectileClass == none && WeaponFireTypes[CurrentFireMode] != EWFT_InstantHit && !IsInstantHit() ) 
	{
		//`log("Return with no bullet" @ ProjectileClass @ WeaponFireTypes[CurrentFireMode] @ IsInstantHit() );
		return;
	}

	if (Shooter == none || Target == none)
	{
		return;  
	}
	if (Target != none && VSizeSq(Target.Location - HitLocation) > 62500 )
	{
		return;
	}
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	//if (!self.bInstantHit)
		//Several weapons use instant hit and projectiles.
	if(WeaponFireTypes[CurrentFireMode] != EWFT_InstantHit && !IsInstantHit() )
	{
		if(class<Rx_Projectile>(ProjectileClass) != None) {
			HeadShotDamageMultLocal = class<Rx_Projectile>(ProjectileClass).default.HeadShotDamageMult;
			HeadShotDamageType = class<Rx_Projectile>(ProjectileClass).default.HeadShotDamageType;
			TempDamageType = class<Rx_Projectile>(ProjectileClass).default.MyDamageType;
		//	`log("With Class " @ TempDamageType);
		} else {
			HeadShotDamageMultLocal = class<Rx_Projectile_Rocket>(ProjectileClass).default.HeadShotDamageMult;
			HeadShotDamageType = class<Rx_Projectile_Rocket>(ProjectileClass).default.HeadShotDamageType;
			TempDamageType = class<Rx_Projectile_Rocket>(ProjectileClass).default.MyDamageType;
			//`log("No class:" @ TempDamageType);
		}
		
		
		
		if(class<Rx_Projectile_Rocket>(ProjectileClass) == none) Damage = ProjectileClass.default.Damage * class<Rx_Projectile>(ProjectileClass).static.GetDamageModifier(VRank, Instigator.Controller) * HeadShotDamageMultLocal; //class<Rx_Projectile>(ProjectileClass).default.Vet_DamageIncrease[VRank] * HeadShotDamageMultLocal;
		else
		Damage = ProjectileClass.default.Damage * class<Rx_Projectile>(ProjectileClass).static.GetDamageModifier(VRank, Instigator.Controller) * HeadShotDamageMultLocal;
	
		FireDir = Normal(Target.Location - Instigator.Location);
		Momentum = ProjectileClass.default.MomentumTransfer * FireDir;

		if(HeadShotDamageType != None) 
		{
			DamageType = HeadShotDamageType; 
		} 
		else 
		{
			DamageType = ProjectileClass.default.MyDamageType; 
		}
		//`log("Projectile hit mods vs. " @ TempDamageType);
	}
	// Then we are an instant hit weapon
	else
		if( IsInstantHit() )
	{
		Damage  = self.InstantHitDamage[CurrentFireMode] * GetDamageModifier() * self.HeadShotDamageMult;
    
		FireDir = Normal(Target.Location - Instigator.Location);
		Momentum = self.InstantHitMomentum[CurrentFireMode] * FireDir;
		TempDamageType = self.InstantHitDamageTypes[CurrentFireMode];
		
		if(TempDamageType == none)	
		{
			TempDamageType = class<Rx_Projectile>(ProjectileClass).default.MyDamageType;
		
		}
		//`log("Instant hit mods vs. " @ TempDamageType);
		
		if(self.HeadShotDamageType != None) 
		{
			DamageType = self.HeadShotDamageType;
			
		} 
		else 
		{
			DamageType = self.InstantHitDamageTypes[CurrentFireMode]; 
		}
	}

	if(Rx_Pawn(Target) != None && Rx_Pawn(Target).Armor > 0) 
	{
		//Rx_Pawn(Target).bHeadshot = true;	
		Rx_Pawn(Target).setbHeadshot(true);
		//`log("Armor mods vs. " @ TempDamageType);
		//Adjust for armour, as Rx_Pawn does not inherently adjust damage if it is a headshot 
		if(Rx_Pawn(Target).GetArmor() == A_KEVLAR) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.KevlarDamageScalingFor(); 
		else
		if(Rx_Pawn(Target).GetArmor() == A_FLAK) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.FlakDamageScalingFor(); 
		else
		if(Rx_Pawn(Target).GetArmor() == A_LAZARUS) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.LazarusDamageScalingFor(); 
		else
		ArmorMultiplier=1;
	//`log("Armor Mult" @ ArmorMultiplier @Damage); 
	}
	
	Damage*=ArmorMultiplier;
	
	if(DmgReduction <= 1.0)
		Damage*=DmgReduction; //Used for effective range manipulation. Should never be higher than 1 
	
	if(WorldInfo.Netmode == NM_DedicatedServer)
	{
		SetFlashLocation(HitLocation);
	}	
	
	//`log("ServerALHeadshot Armor Multiplier: " @ ArmorMultiplier @ Damage);
	
	if(Rx_Pawn(Instigator) != None)
		Rx_Pawn(Instigator).HitEnemyWithHeadshotForDemoRec++;	
	
	Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);

	SpecialClass = class<Rx_DmgType_Special>(TempDamageType);

	if (SpecialClass != None && SpecialClass.default.bCausesBleed && Rx_Pawn(Target) != None)
		Rx_Pawn(Target).AddBleed(SpecialClass.default.BleedDamageFactor*Damage*HeadShotDamageBurnMultiplier, SpecialClass.default.BleedCount, Instigator.Controller, SpecialClass.default.BleedType);
}

//DmgReduction 
reliable server function ServerALHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo, bool mctDamage, optional byte FireTag, optional float DmgReduction = 1.0) 
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Pawn				Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HitDistDiff;
	
	Shooter = Rx_Pawn(Owner);


	ProjectileClass = class<Rx_Projectile>(GetProjectileClassSimulated(FireTag));

	if(ProjectileClass == None)
		ProjectileClass = class<Rx_Projectile>(GetProjectileClass());
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}		
	//loginternal(target);
	if (Shooter == none || Target == none || ProjectileClass == none)
	{
		return;  
	}
	HitDistDiff = VSizeSq(Target.Location - HitLocation);
	if (Target != none && !default.bIgnoreHitDist)
	{
		if(Rx_Building(Target) != None) {
			if(HitDistDiff > 9000000) {
				return;
			} 
		} else if(HitDistDiff > 250000 ) {
			return;
		}
	}
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	FireDir = Normal(Target.Location - Instigator.Location);

	Momentum = ProjectileClass.default.MomentumTransfer * FireDir;
	DamageType = ProjectileClass.default.MyDamageType;
	Damage = ProjectileClass.default.Damage * ProjectileClass.static.GetDamageModifier(VRank, Instigator.Controller);

	if(DmgReduction <= 1.0)
		Damage*=DmgReduction; //Used for effective range manipulation. Should never be higher than 1 
	
	/**if(VRank >= 2 && (Rx_Building(Target) != none)) 
	{
		
		Damage = Damage * Elite_Building_DamageMod ; //At elite, allow weapons to have a separate damage modifier for buildings
	}*/
	if(mctDamage) {
		Damage = Damage * class<Rx_DmgType>(DamageType).static.MCTDamageScalingFor();
	}	
		
	//SetFlashLocation(HitLocation);
	//SetReplicatedImpact(HitLocation, FireDir, Shooter.Location, class, 0.0, true );

	Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);		
}

reliable server function ServerALRadiusDamage(Actor Target, vector HurtOrigin, bool bFullDamage, optional byte FMTag = 255)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Pawn				Shooter;
	local float					Momentum;
	local float 				Damage,DamageRadius;

	Shooter = Rx_Pawn(Owner);

	ProjectileClass = class<Rx_Projectile>(GetProjectileClassSimulated(FMTag));


	if(ProjectileClass == None)
		ProjectileClass = class<Rx_Projectile>(GetProjectileClass());

	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}		

	if (Shooter == none || Target == none || ProjectileClass == none)
	{
		return;  
	}
	/** Pointless ?
	if (Target != none && VSizeSq(Target.Location - HurtOrigin) > 160000 )
	{
		return;
	}*/
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	Momentum = ProjectileClass.default.MomentumTransfer;
	
	if(ProjectileClass.default.ExplosionDamageType != none && !bFullDamage) //Full damage IMPLIES this is actually the impacted actor
		DamageType = ProjectileClass.default.ExplosionDamageType;
	else
		DamageType = ProjectileClass.default.MyDamageType;
	
	Damage = ProjectileClass.default.Damage * ProjectileClass.static.GetDamageModifier(VRank, Instigator.Controller);
	DamageRadius = ProjectileClass.default.DamageRadius;
	
	Target.TakeRadiusDamage(Instigator.Controller,Damage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,self);
}


/*****************************
 * Instant Hit Radius Damage *  This section is an exact copy of what is in Rx_Vehicle_Weapon, so update accordingly.
 *****************************/

/** Based on Rx_Projectile::ProjectileHurtRadius - update accordingly. */
simulated function InstantFireRadiusDamage(byte FiringMode, vector HurtOrigin, vector HitNormal, Actor ImpactedActor)
{
	local vector AltOrigin, TraceHitLocation, TraceHitNormal;
	local Actor TraceHitActor;

	// early out if already in the middle of hurt radius
	if ( bHurtEntry )
		return;

	AltOrigin = HurtOrigin;

	if ( (ImpactedActor != None) && ImpactedActor.bWorldGeometry )
	{
		// try to adjust hit position out from hit location if hit world geometry
		AltOrigin = HurtOrigin + 2.0 * class'Pawn'.Default.MaxStepHeight * HitNormal;
		//AltOrigin.Z += AddedZTranslate;
		TraceHitActor = Trace(TraceHitLocation, TraceHitNormal, AltOrigin, HurtOrigin, false,,,TRACEFLAG_Bullet);
		if ( TraceHitActor == None )
		{
			// go half way if hit nothing
			AltOrigin = HurtOrigin + class'Pawn'.Default.MaxStepHeight * HitNormal;
			//AltOrigin.Z += AddedZTranslate;
		}
		else
		{
			AltOrigin = HurtOrigin + 0.5*(TraceHitLocation - HurtOrigin);
		}
	}

	if (WorldInfo.NetMode == NM_Client)
	{
		InstantFireClientRadiusCheck(FiringMode, AltOrigin, ImpactedActor);
	}
	else if (AIController(Instigator.Controller) != None || WorldInfo.NetMode != NM_DedicatedServer)
	{
		InstantFireHurtRadius(FiringMode, AltOrigin, ImpactedActor, false);
	}
}

simulated function InstantFireClientRadiusCheck(byte FiringMode, vector HurtOrigin, Actor ImpactedActor)
{
	local Actor A;
	local array<ClientSideHit> Hits;
	local ClientSideHit Temp;
	// client radius check
	foreach VisibleCollidingActors( class'Actor', A, InstantHitDamageRadius[FiringMode], HurtOrigin,,,,class'RxIfc_ClientSideInstantHitRadius' )
	{
		if (A == ImpactedActor || RxIfc_ClientSideInstantHitRadius(A).ClientHitIsNotRelevantForServer() || (!InstantHitDamageRadiusIgnoreTeam[FiringMode] && Instigator.GetTeamNum() == A.GetTeamNum()) )
			continue;
		Temp.Distance = RxIfc_ClientSideInstantHitRadius(A).CalcRadiusDmgDistance(HurtOrigin);
		Temp.Actor = A;
		Hits[Hits.Length] = Temp;
	}
	
	if (Hits.Length > 0)
		Rx_Hud(Rx_Controller(Instigator.Controller).myHud).ShowHitMarker();

	ServerInstantFireRadiusStart(FiringMode, HurtOrigin, ImpactedActor);
	foreach Hits(Temp)
	{
		ServerInstantFireRadiusHit(Temp.Actor, Temp.Distance);
	}
}

reliable server function ServerInstantFireRadiusStart(byte FiringMode, vector HurtOrigin, Actor ImpactedActor)
{
	ClientHitFiringMode = FiringMode;
	ClientHitHurtOrigin = HurtOrigin;
	InstantFireHurtRadius(FiringMode, HurtOrigin, ImpactedActor, true);
}

reliable server function ServerInstantFireRadiusHit(Actor HitActor, float Distance)
{
	// Redo this check on the server due to lag consideration. ie a vehicle may have changed teams but that has yet to be replicated to the client
	if (!InstantHitDamageRadiusIgnoreTeam[ClientHitFiringMode] && Instigator.GetTeamNum() == HitActor.GetTeamNum())
		return;
	RxIfc_ClientSideInstantHitRadius(HitActor).TakeDamageFromDistance(FMax(Distance, 0), Instigator.Controller, InstantHitDamage[ClientHitFiringMode]*GetDamageModifier(), InstantHitDamageRadius[ClientHitFiringMode], 
			InstantHitDamageTypes[ClientHitFiringMode], InstantHitMomentum[ClientHitFiringMode], ClientHitHurtOrigin, InstantHitDamageRadiusDoFull[ClientHitFiringMode], self );
}

function InstantFireHurtRadius(byte FiringMode, vector HurtOrigin, Actor ImpactedActor, bool bSkipClientSideCalculated)
{
	local Actor	Victim;
	local TraceHitInfo HitInfo;
	local StaticMeshComponent HitComponent;
	local KActorFromStatic NewKActor;
	local bool bShowHit;

	// Prevent HurtRadius() from being reentrant.
	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class'Actor', Victim, InstantHitDamageRadius[FiringMode], HurtOrigin,,,,, HitInfo )
	{
		if ( (bSkipClientSideCalculated && RxIfc_ClientSideInstantHitRadius(Victim) != None) || ImpactedActor == Victim )
			continue;
		if ( Victim.bWorldGeometry )
		{
			// check if it can become dynamic
			// @TODO note that if using StaticMeshCollectionActor (e.g. on Consoles), only one component is returned.  Would need to do additional octree radius check to find more components, if desired
			HitComponent = StaticMeshComponent(HitInfo.HitComponent);
			if ( (HitComponent != None) && HitComponent.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
				if ( NewKActor != None )
				{
					Victim = NewKActor;
				}
			}
		}
		if ( !Victim.bWorldGeometry && (Victim != self) && (Victim.bCanBeDamaged || Victim.bProjTarget) )
		{
			Victim.TakeRadiusDamage(Instigator.Controller, InstantHitDamage[FiringMode]*GetDamageModifier(), InstantHitDamageRadius[FiringMode], 
				InstantHitDamageTypes[FiringMode], InstantHitMomentum[FiringMode], HurtOrigin, InstantHitDamageRadiusDoFull[FiringMode], self);

			if (!bSkipClientSideCalculated && !bShowHit && PlayerController(Instigator.Controller) != None && Pawn(Victim) != None && (InstantHitDamageRadiusIgnoreTeam[ClientHitFiringMode] || Instigator.GetTeamNum() != Victim.GetTeamNum()) )
				bShowHit = true;
		}
	}
	if (bShowHit)
		Rx_Hud(Rx_Controller(Instigator.Controller).myHud).ShowHitMarker();

	bHurtEntry = false;
}
/*****************************/

function bool IsInsideGracePeriod(float ShotDistance)
{
	local float DiedTime, FlightTime;
	local class<Projectile> ProjClass;

	ProjClass = GetProjectileClass();
	if (ProjClass != none )		
		FlightTime = ShotDistance / ProjClass.default.Speed;
	else
		FlightTime = 0.075 ; 
		
	DiedTime = Rx_Controller(Instigator.Controller).LastDiedTime;
	
	if (DiedTime + FlightTime + 0.075 > WorldInfo.TimeSeconds)
		return true;
		
	return false;
}

simulated function ActiveRenderOverlays( HUD H )
{
   local PlayerController PC;
   PC = PlayerController(Instigator.Controller);
   
   if (bCanLock && bLockedOnTarget && (LockedTarget != None) && (Instigator != None) && WorldInfo.NetMode != NM_DedicatedServer) 
   {
      if ( ((LocalPlayer(PC.Player) == None) || !LocalPlayer(PC.Player).GetActorVisibility(LockedTarget))) 
      {
          DrawCrosshair(H);
          return;
      }
      else 
      {
         DrawLockedOn( H );
      }
   }
   else 
   {
   	  DrawCrosshair(H);
      bWasLocked = false;
   }
}

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return true;
}

simulated function WeaponPlaySound(SoundCue Sound, optional float NoiseLoudness)
{
	//ScriptTrace();
	if( Sound != None && Instigator != None && !bSuppressSounds  )
	{
		//loginternal(Instigator.owner);
		Instigator.PlaySound(Sound, false, true);
	}
}

simulated function bool IsIronsightActivated()
{
	return bIronsightActivated;
}

simulated function float GetIronsightMouseSensitivityModifier()
{
	return IronsightMouseSensitivityModifier;
}


/**
 *  This function is used to adjust the LockTarget.
 */
function AdjustLockTarget(actor NewLockTarget)
{
	if ( LockedTarget == NewLockTarget )
	{
		// no need to update
		return;
	}

	if (NewLockTarget == None)
	{
		// Clear the lock
		if (bLockedOnTarget)
		{
			LockedTarget = None;

			bLockedOnTarget = false;

			if (LockLostSound != None && Instigator != None && Instigator.IsHumanControlled() )
			{
				PlayerController(Instigator.Controller).ClientPlaySound(LockLostSound);
			}
		}
	}
	else
	{
		// Set the lcok
		bLockedOnTarget = true;
		LockedTarget = NewLockTarget;
		LockedTargetPRI = (Pawn(NewLockTarget) != None) ? Pawn(NewLockTarget).PlayerReplicationInfo : None;
		if ( LockAcquiredSound != None && Instigator != None  && Instigator.IsHumanControlled() )
		{
			PlayerController(Instigator.Controller).ClientPlaySound(LockAcquiredSound);
		}
	}
}

/**
* Given an potential target TA determine if we can lock on to it.  By default only allow locking on
* to pawns.  
*/
simulated function bool CanLockOnTo(Actor TA)
{
	if(!bCanLock)
		return false;

	if ( (TA == None) || !TA.bProjTarget || TA.bDeleteMe || (Pawn(TA) == None) || (TA == Instigator) || (Pawn(TA).Health <= 0) 
			|| TA.IsInState('Stealthed') || TA.IsInState('BeenShot') || Rx_Pawn(TA) != none || Rx_Sentinel(TA) != None || Rx_Sentinel_Obelisk_Laser_Base(TA) != None) //|| Rx_SupportVehicle(TA) != none ) //Because the dropoff Chinook is a mess. 
	{
		return false;
	}

	return ( (WorldInfo.Game == None) || !WorldInfo.Game.bTeamGame || (WorldInfo.GRI == None) || Instigator.GetTeamNum() != TA.GetTeamNum() );
}

simulated event Destroyed()
{
	AdjustLockTarget(none);
	super.Destroyed();
}


/**
 * This function is called from the pawn when the visibility of the weapon changes [Pulled to add support for arm overlays without adding extra local variables to the function]
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	local Rx_Pawn UTP;
	local SkeletalMeshComponent SkelMesh;
	local PrimitiveComponent Primitive;

	if (Mesh != None)
	{
		if (bIsVisible && !Mesh.bAttached)
		{
			AttachComponent(Mesh);
			EnsureWeaponOverlayComponentLast();
		}
		SetHidden(!bIsVisible);
		SkelMesh = SkeletalMeshComponent(Mesh);
		if (SkelMesh != None)
		{
			foreach SkelMesh.AttachedComponents(class'PrimitiveComponent', Primitive)
			{
				Primitive.SetHidden(!bIsVisible);
			}
		}
	}
	if (ArmsAnimSet != None && GetHand() != HAND_Hidden)
	{
		UTP = Rx_Pawn(Instigator);
		if (UTP != None && UTP.ArmsMesh[0] != None)
		{
			UTP.ArmsMesh[0].SetHidden(!bIsVisible);
			UTP.ArmsOverlayMesh[0].SetHidden(!bIsVisible);
			UTP.ArmsOverlayMesh[1].SetHidden(!bIsVisible);
		}
	}

	if ( OverlayMesh != none )
	{
		OverlayMesh.SetHidden(!bIsVisible || (GetHand() == HAND_Hidden));
	}
	
	if(bIsVisible && IsTimerActive('WeaponEquipped',self))
	{
		PlayIdleAnims();
	}
}

/**
 * This function aligns the gun model in the world [From UTPawn(Add support for )]
 */
simulated event SetPosition(UDKPawn Holder)
{
	local vector DrawOffset, ViewOffset, FinalSmallWeaponsOffset, FinalLocation;
	local EWeaponHand CurrentHand;
	local rotator NewRotation, FinalRotation, SpecRotation;
	local PlayerController PC;
	local vector2D ViewportSize;
	local bool bIsWideScreen;
	local vector SpecViewLoc;
	local Rx_Pawn RxPHolder; 

	if ( !Holder.IsFirstPerson() )
		return;

	RxPHolder = Rx_Pawn(Holder);
	
	// Hide the weapon if hidden
	CurrentHand = GetHand();
	if ( bForceHidden || CurrentHand == HAND_Hidden)
	{
		Mesh.SetHidden(True);
		Holder.ArmsMesh[0].SetHidden(true);
		Holder.ArmsMesh[1].SetHidden(true);
		RxPHolder.ArmsOverlayMesh[0].SetHidden(true);
		RxPHolder.ArmsOverlayMesh[1].SetHidden(true);
		NewRotation = Holder.GetViewRotation();
		SetLocation(Instigator.GetPawnViewLocation() + (HiddenWeaponsOffset >> NewRotation));
		SetRotation(NewRotation);
		SetBase(Instigator);
		return;
	}

	if(bPendingShow)
	{
		SetHidden(False);
		bPendingShow = FALSE;
	}

	Mesh.SetHidden(False);

	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
		break;
	}
	bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.7);

	// Adjust for the current hand
	ViewOffset = PlayerViewOffset;
	FinalSmallWeaponsOffset = SmallWeaponsOffset;

	if (class'Engine'.static.IsRealDStereoEnabled())
	{
		ViewOffset.X -= 30;
	}

	switch ( CurrentHand )
	{
		case HAND_Left:
			Mesh.SetScale3D(default.Mesh.Scale3D * vect(1,-1,1));
			Mesh.SetRotation(rot(0,0,0) - default.Mesh.Rotation);
			if (ArmsAnimSet != None)
			{
				Holder.ArmsMesh[0].SetScale3D(Holder.default.ArmsMesh[0].Scale3D * vect(1,-1,1));
				Holder.ArmsMesh[1].SetScale3D(Holder.default.ArmsMesh[1].Scale3D * vect(1,-1,1));
				RxPHolder.ArmsOverlayMesh[0].SetScale3D(Holder.default.ArmsMesh[0].Scale3D * vect(1,-1,1));
				RxPHolder.ArmsOverlayMesh[1].SetScale3D(Holder.default.ArmsMesh[1].Scale3D * vect(1,-1,1));
			}
			ViewOffset.Y *= -1.0;
			FinalSmallWeaponsOffset.Y *= -1.0;
			break;

		case HAND_Centered:
			ViewOffset.Y = 0.0;
			FinalSmallWeaponsOffset.Y = 0.0;
			break;

		case HAND_Right:
			Mesh.SetScale3D(default.Mesh.Scale3D);
			Mesh.SetRotation(default.Mesh.Rotation);
			if (ArmsAnimSet != None)
			{
				Holder.ArmsMesh[0].SetScale3D(Holder.default.ArmsMesh[0].Scale3D);
				Holder.ArmsMesh[1].SetScale3D(Holder.default.ArmsMesh[1].Scale3D);
				RxPHolder.ArmsOverlayMesh[0].SetScale3D(Holder.default.ArmsMesh[0].Scale3D);
				RxPHolder.ArmsOverlayMesh[1].SetScale3D(Holder.default.ArmsMesh[1].Scale3D);
			}
			break;
		default:
			break;
	}

	if ( bIsWideScreen )
	{
		ViewOffset += WideScreenOffsetScaling * FinalSmallWeaponsOffset;
		if ( bSmallWeapons )
		{
			ViewOffset += 0.7 * FinalSmallWeaponsOffset;
		}
	}
	else if ( bSmallWeapons )
	{
		ViewOffset += FinalSmallWeaponsOffset;
	}

	// Calculate the draw offset
	if ( Holder.Controller == None )
	{
		if ( DemoRecSpectator(PC) != None )
		{
			PC.GetPlayerViewPoint(SpecViewLoc, SpecRotation);
			DrawOffset = ViewOffset >> SpecRotation;
			DrawOffset += UTPawn(Holder).WeaponBob(BobDamping, JumpDamping);
			FinalLocation = SpecViewLoc + DrawOffset;
			SetLocation(FinalLocation);
			SetBase(Holder);

			// Add some rotation leading
			SpecRotation.Yaw = LagRot(SpecRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
			SpecRotation.Pitch = LagRot(SpecRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
			LastRotUpdate = WorldInfo.TimeSeconds;
			LastRotation = SpecRotation;

			if ( bIsWideScreen )
			{
				SpecRotation += WidescreenRotationOffset;
			}
			SetRotation(SpecRotation);
			return;
		}
		else
		{
		DrawOffset = (ViewOffset >> Holder.GetBaseAimRotation()) + UTPawn(Holder).GetEyeHeight() * vect(0,0,1);
	}
	}
	else
	{
		DrawOffset.Z = UTPawn(Holder).GetEyeHeight();
		DrawOffset += UTPawn(Holder).WeaponBob(BobDamping, JumpDamping);

		if ( UTPlayerController(Holder.Controller) != None )
		{
			DrawOffset += UTPlayerController(Holder.Controller).ShakeOffset >> Holder.Controller.Rotation;
		}

		DrawOffset = DrawOffset + ( ViewOffset >> Holder.Controller.Rotation );
	}

	// Adjust it in the world
	FinalLocation = Holder.Location + DrawOffset;
	SetLocation(FinalLocation);
	SetBase(Holder);

	if (ArmsAnimSet != None)
	{
		Holder.ArmsMesh[0].SetTranslation(DrawOffset);
		Holder.ArmsMesh[1].SetTranslation(DrawOffset);
		RxPHolder.ArmsOverlayMesh[0].SetTranslation(DrawOffset);
		RxPHolder.ArmsOverlayMesh[1].SetTranslation(DrawOffset);
	}

	NewRotation = (Holder.Controller == None) ? Holder.GetBaseAimRotation() : Holder.Controller.Rotation;

	// Add some rotation leading
	if (Holder.Controller != None)
	{
		FinalRotation.Yaw = LagRot(NewRotation.Yaw & 65535, LastRotation.Yaw & 65535, MaxYawLag, 0);
		FinalRotation.Pitch = LagRot(NewRotation.Pitch & 65535, LastRotation.Pitch & 65535, MaxPitchLag, 1);
		FinalRotation.Roll = NewRotation.Roll;
	}
	else
	{
		FinalRotation = NewRotation;
	}
	LastRotUpdate = WorldInfo.TimeSeconds;
	LastRotation = NewRotation;

	if ( bIsWideScreen )
	{
		FinalRotation += WidescreenRotationOffset;
	}
	SetRotation(FinalRotation);
	if (ArmsAnimSet != None)
	{
		Holder.ArmsMesh[0].SetRotation(FinalRotation);
		Holder.ArmsMesh[1].SetRotation(FinalRotation);
		RxPHolder.ArmsOverlayMesh[0].SetRotation(FinalRotation);
		RxPHolder.ArmsOverlayMesh[1].SetRotation(FinalRotation);
	}
}

/*UTWeapon [Again... adding support for Arm overlays]*/
simulated function SetupArmsAnim()
{
	local Rx_Pawn UTP;
	UTP = Rx_Pawn(Instigator);
	
	if (UTP != None)
	{
		UTP.ArmsMesh[0].StopAnim(); // let's stop anything already going.
		UTP.ArmsOverlayMesh[0].StopAnim(); // let's stop anything already going.
		
		if (ArmsAnimSet != None)
		{
			UTP.ArmsMesh[0].AnimSets[1] = ArmsAnimSet;
			UTP.ArmsMesh[0].SetHidden(false);
			UTP.ArmsMesh[0].SetLightEnvironment(UTP.LightEnvironment);
			
			UTP.ArmsOverlayMesh[0].AnimSets[1] = ArmsAnimSet;
			
			/**if(UTP.UseArmOverlay())
				UTP.ArmsOverlayMesh[0].SetHidden(false);*/
		}
		else
		{
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
			UTP.ArmsOverlayMesh[0].SetHidden(true);
			UTP.ArmsOverlayMesh[1].SetHidden(true);
		}
	}
}
	
simulated function CycleVisibility()
{
	ChangeVisibility(true);
	ChangeVisibility(false);
	//SetTimer(0.01,false,'SetVisibilityFalse');
}

simulated function GotoActiveTimer()
{
	GotoState('Active');
}

simulated function StartZoom(UTPlayerController PC)
{
	super.StartZoom(PC);
	ClearTimer('RestartCrosshair');
}

simulated state Active
{
	simulated function BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);
		
		if (Rx_Pawn(Owner) != None && Rx_Pawn(Owner).bSprinting)
			Rx_Pawn(Owner).BeginSprintAnims();
	}
}

simulated function StartFire(byte FireModeNum)
{
	if(Rx_Bot(instigator.Controller) != None) 
	{
		super.StartFire(FireModeNum); 
		return; 
	}
	
	if( Instigator == None || !Instigator.bNoWeaponFiring )
	{
		
		//if(Rx_Weapon_Reloadable(self) !=none && Rx_Weapon_Reloadable(self).CurrentlyBoltReloading) return; //Don't accept Startfire commands when bolt reloading
		
		ClientPendingFire[FireModeNum]=true; 
		
		if(bReadyToFire() && !bRecoveringFromAction && (Role < Role_Authority || WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_ListenServer))
		{
			// if we're a client, synchronize server
			//`log("Sending Fire Request"); 
			ServerStartFire(FireModeNum);
			BeginFire(FireModeNum);
			return;
		}

		// Start fire locally
		//if(ROLE == Role_Authority) BeginFire(FireModeNum);
	}
}

simulated function StopFire(byte FireModeNum)
{
	super.StopFire(FireModeNum); 
	ClientPendingFire[FireModeNum]=false; 
}


simulated function bool IsInstantHit() //Use this to determine if a weapon firing mode is actually instant hit. 
{
	if(WeaponFireTypes[CurrentFireMode] == EWFT_InstantHit) 
		return true;
	else
		return false; 
}

function PromoteWeapon(byte rank) /*Covers most of what needs to be done(Damage,ROF,ClipSize,etc.) Special things obviously need to be added for special weapons*/
{

	VRank = rank; 
	CachedMaxRange = 0 ; //Ensure if the range changes after being promoted.

	if(VeterancyFireTypes.Length > 0) 
		UpdateFireTypes(rank); 

	if(rank == 3)
		{
			UpdateHeroicEffects(true);
		}	
		else
			UpdateHeroicEffects(false);
}

simulated function UpdateHeroicEffects(bool bHeroic)
{
	local UTPawn UTP;

	UTP=UTPawn(Instigator);

	//Update weapon attachments

	if(MuzzleFlashLightClass_Heroic != none && bHeroic)
	{
		MuzzleFlashLight = new(Outer) MuzzleFlashLightClass_Heroic;
		SkeletalMeshComponent(Mesh).AttachComponentToSocket(MuzzleFlashLight,MuzzleFlashSocket);
	}
	
	if(MuzzleFlashPSCTemplate_Heroic != none && bHeroic) MuzzleFlashPSCTemplate = MuzzleFlashPSCTemplate_Heroic;
	else
	if(!bHeroic) MuzzleFlashPSCTemplate = default.MuzzleFlashPSCTemplate;
	
	if(ROLE == ROLE_Authority && Rx_WeaponAttachment_Varying(UTP.CurrentWeaponAttachment) != none ) Rx_WeaponAttachment_Varying(UTP.CurrentWeaponAttachment).SetHeroic(bHeroic); 

	if(bHeroic)
	{ 
		//If we have Heroic projectiles, switch to them
		if(WeaponProjectiles_Heroic.Length > 0) WeaponProjectiles[0]=WeaponProjectiles_Heroic[0];
		if(WeaponProjectiles_Heroic.Length > 1) WeaponProjectiles[1]=WeaponProjectiles_Heroic[1];
		if(WeaponFireSnd_Heroic.Length > 0) WeaponFireSnd[0]=WeaponFireSnd_Heroic[0];
		if(WeaponFireSnd_Heroic.Length > 1) WeaponFireSnd[1]=WeaponFireSnd_Heroic[1];
	}
	else
	{
		WeaponProjectiles[0] = default.WeaponProjectiles[0];
		WeaponProjectiles[1] = default.WeaponProjectiles[1];	
	}
}

simulated function UpdateFireTypes(byte rank)
{
	local int i; 
	
	for(i=0;i<VeterancyFireTypes.Length;i++)
	{
		if(rank >= VeterancyFireTypes[i].MinRank)
		{
		WeaponFireTypes[i]=VeterancyFireTypes[i].FireType;
		}
		else
		WeaponFireTypes[i]=default.WeaponFireTypes[i];
		
	}
}

/**
 * Returns interval in seconds between each shot, for the firing state of FireModeNum firing mode.
 *
 * @param	FireModeNum	fire mode
 * @return	Period in seconds of firing mode
 */
simulated function float GetFireInterval( byte FireModeNum )
{
	if(GetIsBurstFire()) 
		return GetBurstCooldown(FireModeNum);
	else
		return FireInterval[FireModeNum] > 0 ? FireInterval[FireModeNum]*GetROFModifier() : 0.01;
}

/**
 * Returns the Maximum Range for this weapon
 */
simulated function float MaxRange()
{
	local int i;
	local class<Rx_Projectile> RxProj;
	
	if ( CachedMaxRange > 0 )
	{
		return CachedMaxRange;
	}

	// return the range of the fire mode that fires farthest
	if (IsInstantHit())
	{
		CachedMaxRange = WeaponRange*Vet_RangeModifier[VRank];
		return CachedMaxRange;
	}

	for (i = 0; i < WeaponProjectiles.length; i++)
	{
		if(WeaponProjectiles[i] == none) continue;
		if (class<Rx_Projectile>(WeaponProjectiles[i]) != None)
		{
			RxProj=class<Rx_Projectile>(WeaponProjectiles[i]);
			//CachedMaxRange = FMax(CachedMaxRange, class<Rx_Projectile>(WeaponProjectiles[i]).static.RxGetRange()*class<Rx_Projectile>(WeaponProjectiles[i]).default.Vet_SpeedIncrease[VRank] );
			CachedMaxRange = FMax(CachedMaxRange, RxProj.static.RxGetRange(VRank)); //*RxProj.default.Vet_SpeedIncrease[VRank] );

		}
		else
		CachedMaxRange = FMax(CachedMaxRange,WeaponProjectiles[i].static.GetRange());
	}
	return CachedMaxRange;
}

simulated event float GetTraceRange()
{
	return WeaponRange*Vet_RangeModifier[VRank];
}

unreliable server function ServerSendLocSync(vector ClientLoc)
{
if(VSizeSq(Instigator.location-ClientLoc) >= 562500) `LogRx("PLAYER" `s "LocationDesync;" `s `PlayerLog(Instigator.PlayerReplicationInfo));	
} 

//Not vehicles, so don't have to worry about harv/defence controllers
simulated function float GetROFModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) 
		return Vet_ROFModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_RateOfFireMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) 
		return Vet_ROFModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_RateOfFireMod; 
	else
		return 1.0; 
}

simulated function float GetDamageModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) 
		return Vet_DamageModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_DamageBoostMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) 
		return Vet_DamageModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_DamageBoostMod; 
	else
		return 1.0; 
}

simulated function float GetPierceModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) 
		return 1.0; 
	else
	if(Rx_Bot(Instigator.Controller) != none) 
		return 1.0; 
	else
		return 1.0; 
}

/**Add check statements here for whether or not the back attachment for this weapon should be drawn at this time. 
*For instance, the Tac Rifle should not draw on the player's back if the Tac Rifle's grenade ability is being used. */

simulated function bool bDrawBackAttachment() 
{
	return true; 
}

simulated function ReplicateVRank()
{
	if(VRank == 3) //Heroic
		{
			UpdateHeroicEffects(true);
		}
		else
		UpdateHeroicEffects(false);

		if(VeterancyFireTypes.Length > 0) UpdateFireTypes(VRank); 
		
		CachedMaxRange = 0 ; //Recache range
}

function CreateAttachedAbility()
{
	local Rx_InventoryManager RxInv; 

	if(AttachedWeaponAbilityClass == none || Rx_InventoryManager(Instigator.InvManager) == none) 
		return; 
	//Clear any weapon ability we may be linked to
	AttachedWeaponAbility = none; 
	
	RxInv = Rx_InventoryManager(Instigator.InvManager);
	
	AttachedWeaponAbility = RxInv.AddAbilityFromWeapon(AttachedWeaponAbilityClass);
	//`log("Create Attached Ability: " @ AttachedWeaponAbility);
}

//From Weapon.uc//
//Edited for Penetration power//
 
/**
 * CalcWeaponFire: Simulate an instant hit shot.
 * This doesn't deal any damage nor trigger any effect. It just simulates a shot and returns
 * the hit information, to be post-processed later.
 *
 * ImpactList returns a list of ImpactInfo containing all listed impacts during the simulation.
 * CalcWeaponFire however returns one impact (return variable) being the first geometry impact
 * straight, with no direction change. If you were to do refraction, reflection, bullet penetration
 * or something like that, this would return exactly when the crosshair sees:
 * The first 'real geometry' impact, skipping invisible triggers and volumes.
 *
 * @param	StartTrace	world location to start trace from
 * @param	EndTrace	world location to end trace at
 * @param	Extent		extent of trace performed
 * @output	ImpactList	list of all impacts that occured during simulation
 * @return	first 'real geometry' impact that occured.
 *
 * @note if an impact didn't occur, and impact is still returned, with its HitLocation being the EndTrace value.
 */
simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local vector			HitLocation, HitNormal, Dir;
	local Actor				HitActor;
	local TraceHitInfo		HitInfo;
	local ImpactInfo		CurrentImpact;
	local PortalTeleporter	Portal;
	local float				HitDist;
	local bool				bOldBlockActors, bOldCollideActors;

	// Perform trace to retrieve hit info
	HitActor = GetTraceOwner().Trace(HitLocation, HitNormal, EndTrace, StartTrace, TRUE, Extent, HitInfo, TRACEFLAG_Bullet);

	// If we didn't hit anything, then set the HitLocation as being the EndTrace location
	if( HitActor == None)
	{
		HitLocation	= EndTrace;
	}

	// Convert Trace Information to ImpactInfo type.
	CurrentImpact.HitActor		= HitActor;
	CurrentImpact.HitLocation	= HitLocation;
	CurrentImpact.HitNormal		= HitNormal;
	CurrentImpact.RayDir		= Normal(EndTrace-StartTrace);
	CurrentImpact.StartTrace	= StartTrace;
	CurrentImpact.HitInfo		= HitInfo;
	
	if(default.MaximumPiercingAbility > 0)
	{
		if(HitActor == None)
		CurrentPiercingPower = 0; //Blocked 
	else if(HitActor.IsA('Rx_Pawn') && CurrentPiercingPower > 0) 
		CurrentPiercingPower-=1;
	else if(HitActor.IsA('Rx_Vehicle') && CurrentPiercingPower >= 3)  
			CurrentPiercingPower-=3;
	else 
		CurrentPiercingPower = 0; //Blocked 
	}
	
	// Add this hit to the ImpactList
	ImpactList[ImpactList.Length] = CurrentImpact;
	// check to see if we've hit a trigger.
	// In this case, we want to add this actor to the list so we can give it damage, and then continue tracing through.
	if( HitActor != None )
	{		
		if (PassThroughDamage(HitActor) && CurrentPiercingPower > 0) 
		{
			// disable collision temporarily for the actor we can pass-through
			HitActor.bProjTarget = false;
			bOldCollideActors = HitActor.bCollideActors;
			bOldBlockActors = HitActor.bBlockActors;
			if (HitActor.IsA('Pawn'))
			{
				// For pawns, we need to disable bCollideActors as well
				HitActor.SetCollision(false, false);

				// recurse another trace
				CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}
			else
			{
				if( bOldBlockActors )
				{
					HitActor.SetCollision(bOldCollideActors, false);
				}
				// recurse another trace and override CurrentImpact
				CurrentImpact = CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}

			// and reenable collision for the trigger
			HitActor.bProjTarget = true;
			HitActor.SetCollision(bOldCollideActors, bOldBlockActors);
		}
		else
		{
			// if we hit a PortalTeleporter, recurse through
			Portal = PortalTeleporter(HitActor);
			if( Portal != None && Portal.SisterPortal != None )
			{
				Dir = EndTrace - StartTrace;
				HitDist = VSize(HitLocation - StartTrace);
				// calculate new start and end points on the other side of the portal
				StartTrace = Portal.TransformHitLocation(HitLocation);
				EndTrace = StartTrace + Portal.TransformVectorDir(Normal(Dir) * (VSize(Dir) - HitDist));
				//@note: intentionally ignoring return value so our hit of the portal is used for effects
				//@todo: need to figure out how to replicate that there should be effects on the other side as well
				CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);
			}
		}
	}
	//Need the last impact info if it was piercing targets/First if it doesn't pierce 
	if(default.MaximumPiercingAbility == 0)
		return CurrentImpact;
	else
		return ImpactList[ImpactList.Length-1];
}

/**
  * Rx_Weapon (Edit to check if we can pass infantry/vehicles )
  * returns true if should pass trace through this hitactor
  */
simulated static function bool PassThroughDamage(Actor HitActor)
{
	return (!HitActor.bBlockActors && (HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume')))
		|| HitActor.IsA('InteractiveFoliageActor')
		|| (default.bPierceInfantry && HitActor.isA('Rx_Pawn'))
		|| (default.bPierceVehicles && HitActor.isA('Rx_Vehicle'));
}

//Don't ignore bDoNotActivate, and make sure you don't swap to the weapon anyway on pick-up//
reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	Super(Inventory).ClientGivenTo(NewOwner, bDoNotActivate);
	
	// Evaluate if we should switch to this weapon
	if(!bDoNotActivate)
		ClientWeaponSet(TRUE, bDoNotActivate);
}

/*Override with certain weapons if they have special cases for burst firing only. Usually a weapon just is or isn't*/
simulated function bool GetIsBurstFire(){
	return bBurstFire; 
}

simulated function float GetBurstCooldown(byte FireModeNum){
	return Burst_Cooldown[FireModeNum] > 0 ? Burst_Cooldown[FireModeNum]*GetROFModifier() : 0.01;
}

simulated function bool GetHolderCanSprint()
{
	return  !bIronsightActivated || GetZoomedState() == ZST_NotZoomed;
}

//Any particular logic to be played when our Owner begins/ends an action
simulated function OnActionStart()
{
	StopFire(0);
	StopFire(1);
	StopFire(2);
	
	ClearTimer('RecoverFromActionTimer');
	//bDisplayCrosshair = false; 
}

simulated function OnActionStop()
{
	if(default.ActionToReadyTime > 0.0){
		bRecoveringFromAction = true; 
		SetTimer(default.ActionToReadyTime, false, 'RecoverFromActionTimer');
	}
	
	//bDisplayCrosshair = true; 
}

simulated function RecoverFromActionTimer(){
	bRecoveringFromAction = false;
	bDisplayCrosshair = true;
	
	//Start fire if we had the button held down 
	if((ClientPendingFire[0] && CurrentFireMode == 0) || (ClientPendingFire[1] && CurrentFireMode == 1))
	{
		if(ROLE < ROLE_Authority || WorldInfo.Netmode == NM_Standalone) 
		{
			StartFire(CurrentFireMode);  	
		}
	}
}

simulated function SetMuzzleMICs()
{
	if (`WorldInfoObject.NetMode == NM_DedicatedServer) return;

	if (MuzzleHeatMIC == None)
		MuzzleHeatMIC = Mesh.CreateAndSetMaterialInstanceConstant(0);

	if (MuzzleHeatMICAttachment == None)
		MuzzleHeatMICAttachment = Rx_Pawn(Instigator).CurrentWeaponAttachment.Mesh.CreateAndSetMaterialInstanceConstant(0);
}

simulated function UpdateMuzzleHeatParameter(float NewHeat)
{
	if (`WorldInfoObject.NetMode == NM_DedicatedServer) return;
	if (MuzzleHeatMIC == None || MuzzleHeatMICAttachment == None)
		SetMuzzleMICs();

	MuzzleHeatMIC.SetScalarParameterValue('GunBarrelGlowFactor', NewHeat);
	MuzzleHeatMICAttachment.SetScalarParameterValue('GunBarrelGlowFactor', NewHeat);
}

simulated function StartMuzzleHeatCooldownTick()
{
	if (`WorldInfoObject.NetMode == NM_DedicatedServer) return;
	SetTimer(MuzzleHeatCooldownTimeInterval, true, nameof(MuzzleHeatCooldownTick));
}

simulated function MuzzleHeatCooldownTick()
{
	if (`WorldInfoObject.NetMode == NM_DedicatedServer) return;
	if (MuzzleHeatCooldownAmount > GetMuzzleHeat() || GetMuzzleHeat() == 0)
	{
		ResetMuzzleHeat();
		ClearTimer(nameof(MuzzleHeatCooldownTick));
	}

	else
	{
		UpdateMuzzleHeat(MuzzleHeatCooldownAmount);
	}
}

simulated function UpdateMuzzleHeat(float AmountToAdd)
{
	MuzzleHeat += AmountToAdd;
	if (`WorldInfoObject.NetMode == NM_DedicatedServer) return;

	if (MuzzleHeat < MinMuzzleHeatRequired && AmountToAdd > 0) return;

	UpdateMuzzleHeatParameter(FClamp(MuzzleHeat - MinMuzzleHeatRequired, 0, 1));
}

simulated function float GetMuzzleHeat()
{
	local float OutVal;

	if (MuzzleHeatMIC != None)
		MuzzleHeatMIC.GetScalarParameterValue('GunBarrelGlowFactor', OutVal);

	return OutVal;
}

simulated function ResetMuzzleHeat()
{
	MuzzleHeat = 0;

	UpdateMuzzleHeatParameter(0);
}

simulated function string GetWeaponTips()
{
	return "";
}

simulated function string GetWeaponSecondaryTips()
{
	return "";
}

simulated function LinearColor GetTipsColor()
{
	return MakeLinearColor(1.0, 1.0, 1.0, 1.0);
}

simulated function LinearColor GetSecondTipsColor()
{
	return MakeLinearColor(1.0, 1.0, 1.0, 1.0);
}
//PT stuff

simulated static function bool IsBuyable(Rx_Controller C)
{
	return true;
}

simulated static function int GetPrice(byte TeamID)
{
	return default.Price;
}

simulated static function string GetPurchaseTitle()
{
	return Caps(default.ItemName);
}

simulated static function string GetPurchaseDescription()
{
	return default.PurchaseDesc;
}

//PT stuff ends here

/*Some projectiles (Rockets) may need to adjust their initial yaw depending on what barrel they're spawned at.*/ 
simulated function int GetRProjectileYaw(){
	return 1.0; //Modifier... usually 1.0 or -1.0 
}

/*Needs moved to just TS stuff*/

simulated function SetSkin(Material NewMaterial)
{
	if(bCloaked)
		return; //Don't need to edit skins when cloaked
	else
		super.SetSkin(NewMaterial);
}


/*Bunch of stuff for first-person stealth compatability*/
simulated function SetCloaked(bool bCloak)
{
	bCloaked = bCloak; 
}

/*Better overlay interface [Easily seen on SSs if tampered with]*/
simulated function MeshComponent GetOverlayMesh()
{
	
	return OverlayMesh;
}

simulated function MaterialInstanceConstant CreateAndSetWeaponOverlayMIC(optional int num = 0)
{
	local MaterialInstanceConstant NewOverlayMesh;
	
	if(OverlayMesh != none)
	{
		NewOverlayMesh = OverlayMesh.CreateAndSetMaterialInstanceConstant(num);
		//`log("New Overlay Mesh is:" @ NewOverlayMesh @ self);
	}
	
	return NewOverlayMesh;
}

simulated function AttachOverlayMesh()
{
	if (!OverlayMesh.bAttached)
	{
		OverlayMesh.SetHidden(Mesh.HiddenGame);
		AttachComponent(OverlayMesh);
	}
}

simulated function MaterialInterface GetOverlayMaterial(optional byte num = 0)
{
	local int i; 
	
	if(OverlayMesh == none)
	{
		//`log("WAS NO OVERLAY MESH");
		return none;
	}
			
	for(i=0;i<OverlayMesh.GetNumElements(); i++)
	{
		//`log("WEAPON: Overlay Mesh material:" @ i $ ":" @ OverlayMesh.GetMaterial(i));
	}
	return OverlayMesh.GetMaterial(num);
}

simulated function SetOverlayMaterial(MaterialInterface NewMIC, optional byte num = 0)
{
	if(OverlayMesh != none)
	{
		OverlayMesh.SetMaterial(num,NewMIC); 
	}
		
}

simulated function SetWeaponOverlayFlags(UTPawn OwnerPawn)
{
	//`log("----------SET WEAPON OVERLAY FLAGS HERE------");
	//ScriptTrace();
	super.SetWeaponOverlayFlags(OwnerPawn);
}

/*Used for telling things like stealth not to mess with this material in 1st person (Useful for holosights + LED screens)*/
simulated function bool GetIsImmutableMaterial(byte MatNumber)
{
	return false;
}

/*Added support for arm overlays.... (Thanks for just... not including those, Epic)*/
simulated function PlayArmAnimation( Name Sequence, float fDesiredDuration, optional bool OffHand, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	local Rx_Pawn UTP;
	local SkeletalMeshComponent ArmMeshComp, ArmOverlayComp;
	local AnimNodeSequence WeapNode, ArmOverlayNode;

	// do not play on a dedicated server or if they aren't being seen
	if( WorldInfo.NetMode == NM_DedicatedServer || Instigator == None || !Instigator.IsFirstPerson())
	{
		return;
	}
	UTP = Rx_Pawn(Instigator);
	if(UTP == none)
	{
		return;
	}
	if(UTP.bArmsAttached)
	{
		// Choose the right arm
		if(!OffHand)
		{
			ArmMeshComp = UTP.ArmsMesh[0];
			ArmOverlayComp =  UTP.ArmsOverlayMesh[0];
		}
		else
		{
			ArmMeshComp = UTP.ArmsMesh[1];
			ArmOverlayComp =  UTP.ArmsOverlayMesh[1];
		}

		// Check we have access to mesh and animations
		if( ArmMeshComp == None || ArmsAnimSet == none || GetArmAnimNodeSeq() == None )
		{
			return;
		}

		// If we are not specifying a duration, use the default play rate.
		if(fDesiredDuration > 0.0)
		{
			// @todo - this should call GetWeaponAnimNodeSeq, move 'duration' code into AnimNodeSequence and use that.
			ArmMeshComp.PlayAnim(Sequence, fDesiredDuration, bLoop);
			ArmOverlayComp.PlayAnim(Sequence, fDesiredDuration, bLoop);
			
		}
		else
		{
			WeapNode = AnimNodeSequence(ArmMeshComp.Animations);
			ArmOverlayNode = AnimNodeSequence(ArmOverlayComp.Animations);
			WeapNode.SetAnim(Sequence);
			ArmOverlayNode.SetAnim(Sequence);
			WeapNode.PlayAnim(bLoop, DefaultAnimSpeed);
			ArmOverlayNode.PlayAnim(bLoop, DefaultAnimSpeed);
		}
	}
}

 /**
 * Attach Weapon Mesh, Weapon MuzzleFlash and Muzzle Flash Dynamic Light to a SkeletalMesh
 *
 * @param	who is the pawn to attach to
 */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local Rx_Pawn UTP;

	UTP = Rx_Pawn(Instigator);
	// Attach 1st Person Muzzle Flashes, etc,
	if ( Instigator.IsFirstPerson() )
	{
		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		SetHidden(True);
		bPendingShow = TRUE;
		Mesh.SetLightEnvironment(UTP.LightEnvironment);
		if (GetHand() == HAND_Hidden)
		{
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
			UTP.ArmsOverlayMesh[0].SetHidden(true);
			UTP.ArmsOverlayMesh[1].SetHidden(true);
		}
	}
	else
	{
		SetHidden(True);
		if (UTP != None)
		{
			Mesh.SetLightEnvironment(UTP.LightEnvironment);
			UTP.ArmsMesh[0].SetHidden(true);
			UTP.ArmsMesh[1].SetHidden(true);
			UTP.ArmsOverlayMesh[0].SetHidden(true);
			UTP.ArmsOverlayMesh[1].SetHidden(true);
		}
	}

	SetWeaponOverlayFlags(UTP);

	// Spawn the 3rd Person Attachment
	if (Role == ROLE_Authority && UTP != None)
	{
		UTP.CurrentWeaponAttachmentClass = AttachmentClass;
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			UTP.WeaponAttachmentChanged();
		}
	}

	SetSkin(UTPawn(Instigator).ReplicatedBodyMaterial);
}

DefaultProperties
{
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	RightHandIK_Relaxed_Offset=(X=0,Y=0,Z=0)
	RightHandIK_Relaxed_Rotation=(Pitch=0,Roll=0,Yaw=0)

	bCanGetAmmo=true
	
	LeftHandIK_Offset=(X=0,Y=0,Z=0)
	LeftHandIK_Rotation=(Pitch=0,Roll=0,Yaw=0)
	LeftHandIK_Relaxed_Offset=(X=0,Y=0,Z=0)
	LeftHandIK_Relaxed_Rotation=(Pitch=0,Roll=0,Yaw=0)
	
	bOverrideLeftHandAnim=false
	bUseHandIKWhenRelax=true
	bByPassHandIK=false
	LeftHandAnim=H_M_Hands_Closed

	Begin Object Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=true
		CastShadow=true
		bAllowAmbientOcclusion=true
		bCastDynamicShadow=true
		bSelfShadowOnly=true
	End Object
	Mesh=FirstPersonMesh
	
	bLocSync = false; 
	LocSyncIncrement = 1; 
	
    FireOffset=(X=0,Y=0,Z=0)
    
	bDebugWeapon = false
	bAutoFire = true
	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_Default'
	CrosshairDotMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_Dot'
	CrosshairWidth = 210 	// 256
	CrosshairHeight = 210 	// 256
	HitIndicatorCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_HitMarker'
	MuzzleFlashLightClass_Heroic = none

	ThirdPersonWeaponPutDownAnim="H_M_Weapon_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_Weapon_Equip"
	
	SwapFromAbilityAnim = none
	SwapFromAbilityArmAnim = none 

	WidescreenRotationOffset=(Pitch=-3,Yaw=0,Roll=0)
	WideScreenOffsetScaling=0.0
	PivotTranslation=(Y=-10.0)

	BobDamping=0.75 //0.7
	JumpDamping=2.0 //1.0

	HeadShotDamageType=class'Rx_DmgType_Headshot'
	HeadShotDamageMult=5.0
	HeadShotDamageBurnMultiplier=1.5 // X*
	SlowHeadshotScale=1.75
	RunningHeadshotScale=1.5
	bOkAgainstVehicles=false
	bOkAgainstBuildings=false

	EquipTime=0.5 
	PutDownTime=0.05

	InventoryMovieGroup=0
	InventoryGroup=2
	WeaponIconTexture = Texture2D'RenxHud.T_WeaponIcon_MissingCameo'
	
	//==========================================
	// LOCKING PROPERTIES
	//==========================================
	LockedOnCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_MissileLock'
	TargetMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_LockOnStripe'

	LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
	LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

	ConsoleLockAim=0.99
	LockRange=7500
	LockAim=0.99//0.999999
	LockChecktime=0.25
	LockAcquireTime=1.25//0.75
	LockTolerance=1.5 //3.0   
    bTargetLockingActive = true

	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.1
	MinRecoil = 250.0
	MaxRecoil = 250.0
	MaxTotalRecoil = 1000.0
	RecoilYawModifier = 0.5 // defines yaw-recoil direction preference. value between 0 and 1. 0.5 means left and right equally. 1 mean only right 
	RecoilYawMultiplier = 1.0
	RecoilInterpSpeed = 10.0
	RecoilDeclinePct = 1.0
	RecoilDeclineSpeed = 10.0
	RecoilSpread = 0.0
	MaxSpread = 0.1
	RecoilSpreadIncreasePerShot = 0.015
	RecoilSpreadDeclineSpeed = 0.25
	RecoilSpreadCrosshairScaling = 2000
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 2
	IronSightMaxRecoilDamping = 2
	IronSightMaxTotalRecoilDamping = 2
	IronSightRecoilYawDamping = 1
	IronSightMaxSpreadDamping = 2
	IronSightSpreadIncreasePerShotDamping = 1 
	IronsightMouseSensitivityModifier = 0.5
	 		
	ZoomInSound=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_EquipCue'
	ZoomOutSound=SoundCue'RX_WP_Ramjet.Sounds.Ramjet_PutDownCue'
	
	InstantHitDamageRadius(0) = 0
	InstantHitDamageRadius(1) = 0
	InstantHitDamageRadiusDoFull(0) = false
	InstantHitDamageRadiusDoFull(1) = false
	InstantHitDamageRadiusIgnoreTeam(0) = false
	InstantHitDamageRadiusIgnoreTeam(1) = false
	ClientPendingFire(0)=false
	ClientPendingFire(1)=false

	WeaponProjectiles_Nod(0)=None
	WeaponProjectiles_Nod(1)=None

	//Veterancy
	
	VRank = 0 

	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.10 
	Vet_DamageModifier(2)=1.25 
	Vet_DamageModifier(3)=1.50 
	
	Vet_ROFModifier(0) = 1
	Vet_ROFModifier(1) = 1  
	Vet_ROFModifier(2) = 1  
	Vet_ROFModifier(3) = 1  
	
	Vet_RangeModifier(0) = 1.0 //Also applied to instant hits only
	Vet_RangeModifier(1) = 1.0  
	Vet_RangeModifier(2) = 1.0  
	Vet_RangeModifier(3) = 1.0  
	
	Elite_Building_DamageMod = 1 /* Should only be used on Anti-building weapons, most notably for infantry, as infantry vs. infantry can get very hopeless with AFK repairs */
	
	ROFTurnover = 9; //9 for most automatics. Single shot weapons should be more, except the shotgun
	
	AVGString = "X/X"
	
	CustomWeaponName = "" //The HUD will use this if it does not == "". This should only be used by mods/mutators.
	
	//For instant hit weapons 
	bPierceInfantry = false
	bPierceVehicles = false
	MaximumPiercingAbility	= 5 
	CurrentPiercingPower	= 5
	
	//Burst Fire Variables//
	bBurstFire = false  //If true, the weapon will use burst fire mechanics
	TimeBetweenBursts = 0.06
	bConstantFire = true 
	BurstNum = 3
	Burst_Cooldown(0) = 0.5
	Burst_Cooldown(1) = 0.5
	
	// Carry weight 
	WeaponSpeedModifier = 0.0 //Negatives lower speed. 

	// Muzzle heat
	MuzzleHeatClamp = 1.0f					// Max heat
	MuzzleHeatPerShot = 0.0f				// Heat increase per shot
	MuzzleHeatCooldownTimeInterval = 0.025f	// Time between each decrease tick
	MuzzleHeatCooldownAmount = -0.010f		// Amount to decrease per cooldown tick
	MinMuzzleHeatRequired = 0.8f			// Minimum heat required for it to be shown
	MuzzleHeatCooldownWaitTime = 0.5f		// Time between firing and starting decrease ticks
	MuzzleHeat = 0f							// Current heat. (Don't touch this)
}


