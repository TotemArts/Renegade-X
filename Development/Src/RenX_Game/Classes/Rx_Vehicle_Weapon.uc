/*********************************************************
*
* File: RxVehicle_Weapon.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
* 	
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/
class Rx_Vehicle_Weapon extends UTVehicleWeapon
	abstract;

var MaterialInstanceConstant CrosshairMIC;
var MaterialInstanceConstant LockedOnCrosshairMIC;
var MaterialInstanceConstant HitIndicatorCrosshairMIC,HitIndicatorCrosshairMIC2,CrosshairMIC2;
var float CrosshairWidth, CrosshairHeight;

var name FireSocket;
var ParticleSystem BeamTemplates[2];

var bool bDebugWeapon;
var float CloseRangeAimAdjustRange;


//-------------------- Recoil
var float RecoilImpulse;
var float recoiltime;
var float DeltaPitchX;
var float DeltaPitchXOld;
var int RecoilUps;
var bool bWasNegativeRecoil;
var bool bWasPositiveRecoilSecondTime;
var float RandRecoilIncrease;
var bool bHasRecoil;

// ---------------------------------  Targeting/Lock on vars. -------------------------------------- //
var bool                   bLockedOnTarget;           /* When true, this weapon is locked on target */
var bool                   bTargetLockingActive;      /* If true, weapon will try to lock onto targets */
var Actor                  LastPendingTarget;         /* What last tick test "target" is current pending to be locked on to */
var Actor                  PendingLockedTarget;       /* What "target" is current pending to be locked on to */
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
var bool                   SecondaryLockingDisabled;  /* If true, secondary fire does not lock onto targets */
var bool 		           bCheckIfBarrelInsideWorldGeomBeforeFiring;
var bool 		           bCheckIfFireStartLocInsideOtherVehicle;
var bool 				   CurrentlyReloadingClientside;
var bool				   bReloadAfterEveryShot;
/**
 * For reload capable weapons. Reload time and Reload Anim name's 
 * 
 *  0 = Primary Fire - No Ammo in the clip
 *  1 = Secondary Fire - No Ammo in the clip
 *  2 = Primary Fire - 1 or more rounds left in the clip
 *  3 = Secondary Fire - 1 or more rounds left in the clip
 */
var() float ReloadTime[4];
var bool bCanReplicationFire;

var() class<UTDamageType> HeadShotDamageType;
var() float HeadShotDamageMult;

var array<float> InstantHitDamageRadius;
var array<bool> InstantHitDamageRadiusDoFull;
var array<bool> InstantHitDamageRadiusIgnoreTeam;

var byte ClientHitFiringMode;
var vector ClientHitHurtOrigin;

/** headshot scale factor when moving slowly or stopped */
var() float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var() float RunningHeadshotScale;

replication
{
    if (Role == ROLE_Authority && bNetDirty)
        bLockedOnTarget, LockedTarget;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	CrosshairMIC2.SetParent(CrosshairMIC);	
	HitIndicatorCrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	HitIndicatorCrosshairMIC2.SetParent(HitIndicatorCrosshairMIC);	
	bCanReplicationFire = true;										
}

simulated function ConsumeClientsideAmmo( byte FireModeNum );

simulated function DrawCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y;	
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam, rectColor;	
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;

 	CrosshairSize.Y = CrosshairHeight;
	CrosshairSize.X = CrosshairWidth;

	X = H.Canvas.ClipX * 0.5 - (CrosshairSize.X * 0.5);
	Y = H.Canvas.ClipY * 0.5 - (CrosshairSize.Y * 0.5);

	
	MyPawnOwner = Pawn(Owner);

	//determines what we are looking at and what color we should use based on that.
	if (MyPawnOwner != None)
	{
		TargetActor = Rx_Hud(HUD).GetActorWeaponIsAimingAt();
		
		if(TargetActor != None)
		{
			targetTeam = TargetActor.GetTeamNum();
			
			if (targetTeam == 0 || targetTeam == 1) //has to be gdi or nod player
			{
				if (targetTeam != MyPawnOwner.GetTeamNum())
				{
					if (!TargetActor.IsInState('Stealthed') && !TargetActor.IsInState('BeenShot'))
						rectColor = 1; //enemy, go red, except if stealthed (else would be cheating ;] )
				}
				else
					rectColor = 2; //Friendly
			}
		}
	}
	
	if (!HasAnyAmmo()) //no ammo, go yellow
		rectColor = 3;
	else
	{
		if (Rx_Vehicle_Weapon_Reloadable(self) != None 
				&& Rx_Vehicle_Weapon_Reloadable(self).CurrentlyReloading 
				&& !Rx_Vehicle_Weapon_Reloadable(self).bReloadAfterEveryShot) //reloading, go yellow
			rectColor = 3;
	}

	CrosshairMIC2.SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	if ( CrosshairMIC2 != none )
	{
		//H.Canvas.SetPos( X+1, Y+1 );
		H.Canvas.SetPos( X, Y );
		H.Canvas.DrawMaterialTile(CrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
		DrawHitIndicator(H,x,y);
	}
	
}

simulated function DrawLockedOn( HUD H )
{
    local vector2d CrosshairSize;
    local float x, y;

   	if (H == none || H.Canvas == none)
      	return;

    CrosshairSize.Y = CrosshairHeight;
    CrosshairSize.X = CrosshairWidth;


	X = H.Canvas.ClipX * 0.5 - (CrosshairSize.X * 0.5);
	Y = H.Canvas.ClipY * 0.5 - (CrosshairSize.Y * 0.5);
    if ( LockedOnCrosshairMIC != none )
    {
        H.Canvas.SetPos(x, y);
        H.Canvas.DrawMaterialTile(CrosshairMIC,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
        H.Canvas.SetPos(x, y);
        H.Canvas.DrawMaterialTile(LockedOnCrosshairMIC,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
        DrawHitIndicator(H,x,y);
    }
}

simulated function DrawHitIndicator(HUD H, float x, float y)
{
	local vector2d CrosshairSize;
	
	if(Rx_Hud(H).GetHitEffectAplha() <= 0.0) {
		return;
	}	
    CrosshairSize.Y = default.CrosshairHeight;
    CrosshairSize.X = default.CrosshairWidth;
    H.Canvas.SetPos(x, y);
    HitIndicatorCrosshairMIC2.SetScalarParameterValue('Reticle_Opacity', Rx_Hud(H).GetHitEffectAplha()/100.0);
    H.Canvas.DrawMaterialTile(HitIndicatorCrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
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

function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo( FireModeNum );
}

simulated function FireAmmunition()
{
	if(WorldInfo.NetMode == NM_Client && bReloadAfterEveryShot)
	{
		if(!bCanReplicationFire)
		{
			return;
		}
		else
		{
			bCanReplicationFire = false;
			SetTimer(FireInterval[0],false,'resetCanReplicationFire');
		}
	}		
	super.FireAmmunition();
	if(bHasRecoil) {
		SetWeaponRecoil();
	}
}

simulated function resetCanReplicationFire()
{
	bCanReplicationFire = true;	
}

simulated function bool CanReplicationFire()
{
	return bCanReplicationFire && bReloadAfterEveryShot;
}


simulated function SetWeaponRecoil() {
	DeltaPitchX = 50.0;
	recoiltime = 1.2;
	bWasNegativeRecoil = false;
	bWasPositiveRecoilSecondTime = false;
	RandRecoilIncrease = Rand(4);
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local float DeltaPitch;
	
	if(recoiltime > 0) {
		recoiltime -= Deltatime;
		DeltaPitchXOld = DeltaPitchX;
		DeltaPitchX += (Deltatime*(23.3 - RandRecoilIncrease/2.0));
		DeltaPitch = (sin(1.0/2.0*DeltaPitchX)*120.0)/(DeltaPitchX/2.0)^1.2;

		if(DeltaPitch>0) {		
			if(bWasNegativeRecoil) {
				DeltaPitch = DeltaPitch*2.4;
				bWasPositiveRecoilSecondTime = true;
			} else {
				DeltaPitch = Deltapitch*2.0;
			}
		}
		if(DeltaPitch<0) {
			if(bWasPositiveRecoilSecondTime) {
				return;
			}
			DeltaPitchX -= (Deltatime*10.0)/1.4;
			DeltaPitch = (sin(1.0/2.0*DeltaPitchX)*100.0)/(DeltaPitchX/2.0)^1.2;	
			bWasNegativeRecoil = true;
			DeltaPitch = Deltapitch*4.0;	
		}
		if(DeltaPitch<0) {
			DeltaPitch -= RandRecoilIncrease;
		} else {
			DeltaPitch += RandRecoilIncrease;
		}
		out_DeltaRot.Pitch += DeltaPitch;
		//loginternal("DeltaPitchX"$DeltaPitchX-DeltaPitchXOld);
		//loginternal("DeltaPitch"$DeltaPitch);
	}
}

simulated function Projectile ProjectileFire()	// Add impulse on the vehicle everytime the vehicle fires
{
    local UDKProjectile SpawnedProjectile;
    local vector ForceLoc;

	if(!UsesClientSideProjectiles(CurrentFireMode)) {
		return ProjectileFireOld();
	}
	
	IncrementFlashCount();

	SpawnedProjectile = UDKProjectile(Spawn(GetProjectileClassSimulated(),,, MyVehicle.GetPhysicalFireStartLoc(self)));

	if ( SpawnedProjectile != None )
	{
		SpawnedProjectile.Init( vector(AddSpread(MyVehicle.GetWeaponAim(self))) );

		if ( Role==ROLE_Authority && MyVehicle != none && MyVehicle.Mesh != none)
		{
			// apply force to vehicle
			ForceLoc = MyVehicle.GetTargetLocation();
			ForceLoc.Z += 100;
			MyVehicle.Mesh.AddImpulse(RecoilImpulse*SpawnedProjectile.Velocity, ForceLoc);    
		} 

		if(WorldInfo.Netmode == NM_Client)
			ConsumeClientsideAmmo(CurrentFireMode);
	}

	
    if (bTargetLockingActive && Rx_Projectile_Rocket(SpawnedProjectile) != None)
    {
		SetRocketTarget(Rx_Projectile_Rocket(SpawnedProjectile));
    }    
    return SpawnedProjectile;
}

simulated function class<Projectile> GetProjectileClassSimulated()
{
	return (CurrentFireMode < WeaponProjectiles.length) ? WeaponProjectiles[CurrentFireMode] : None;
}

simulated function Projectile ProjectileFireOld()
{
    local UDKProjectile SpawnedProjectile;
    local vector ForceLoc;

    SpawnedProjectile = UDKProjectile(Super.ProjectileFire());
    if ( (Role==ROLE_Authority) && (SpawnedProjectile != None) && MyVehicle != none && MyVehicle.Mesh != none)
    {
        // apply force to vehicle
        ForceLoc = MyVehicle.GetTargetLocation();
        ForceLoc.Z += 100;
        MyVehicle.Mesh.AddImpulse(RecoilImpulse*SpawnedProjectile.Velocity, ForceLoc);
    }  
    if (bTargetLockingActive && Rx_Projectile_Rocket(SpawnedProjectile) != None)
    {
		SetRocketTarget(Rx_Projectile_Rocket(SpawnedProjectile));
    }    
    return SpawnedProjectile;
}

simulated function SetRocketTarget(Rx_Projectile_Rocket Rocket)
{
	if (bLockedOnTarget && (!SecondaryLockingDisabled || CurrentFireMode != 1 || AIController(UTVehicle(Owner).Controller) != None ))
	{
		Rocket.SeekTarget = LockedTarget;
		Rocket.GotoState('Homing');
	}
	else
	{
		Rocket.Target = GetDesiredAimPoint();
		Rocket.GotoState('Homing');
	}
}

function float GetOptimalRangeFor(Actor Target)
{
	if(!bSniping) {
		if(Vehicle(Target) != None) {
			return MaxRange() / 2;
		}
		if(Pawn(Target) != None) {
			return MaxRange() / 3;
		}		
	}
	return MaxRange();
}

function float SuggestAttackStyle()
{
	local float EnemyDist;

	if (Instigator.Controller.Enemy != None)
	{
		// recommend backing off if target is too close
		EnemyDist = VSize(Instigator.Controller.Enemy.Location - Owner.Location);
		if ( EnemyDist < GetOptimalRangeFor(Instigator.Controller.Enemy) )
		{
			return -1.5;
		} 
		else
		{
			return 0.5;
		}
	}

	return -0.1;
}

function float GetAO_OkDist() {
	return 800;
}


/*********************************************************************************************
 * Target Locking
 *********************************************************************************************/

simulated function GetWeaponDebug( out Array<String> DebugInfo )
{
    Super.GetWeaponDebug(DebugInfo);

    DebugInfo[DebugInfo.Length] = "Locked: "@bLockedOnTarget@LockedTarget@LastLockedontime@(WorldInfo.TimeSeconds-LastLockedOnTime);
    DebugInfo[DebugInfo.Length] = "Pending:"@PendingLockedTarget@PendingLockedTargetTime@WorldInfo.TimeSeconds;
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
    if ( (TA == None) || !TA.bProjTarget || TA.bDeleteMe || (Pawn(TA) == None) || (TA == Instigator) || (Pawn(TA).Health <= 0)
    		|| TA.IsInState('Stealthed') || TA.IsInState('BeenShot') )
    {
        return false;
    }

    return ( (WorldInfo.Game == None) || !WorldInfo.Game.bTeamGame || (WorldInfo.GRI == None) || !WorldInfo.GRI.OnSameTeam(Instigator,TA) );
}


/**
  * Check target locking - server-side only
  */
event Tick( FLOAT DeltaTime )
{
    if ( bTargetLockingActive && ( WorldInfo.TimeSeconds > LastTargetLockCheckTime + LockCheckTime ) )
    {
        LastTargetLockCheckTime = WorldInfo.TimeSeconds;
        CheckTargetLock();
    }
}


/**
* This function checks to see if we are locked on a target
*/
function CheckTargetLock()
{
    local Pawn P, LockedPawn;
    local Actor BestTarget, HitActor, TA;
    local AIController BotController;
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
    BotController = AIController(Instigator.Controller);
    if ( BotController != None )
    {
        // only try locking onto bot's target
        if ( (BotController.Focus != None) && CanLockOnTo(BotController.Focus) )
        {
        	if(VSize(BotController.Focus.Velocity) < 150) {
				BestTarget = BotController.Focus;
			} else {
				if(Rx_Bot(BotController) != None) {
					if(BotController.Skill < 4) {
						if(FRand() < 0.3)
							BestTarget = BotController.Focus;
					} else if(BotController.Skill == 4) { 
						if(FRand() < 0.5)
							BestTarget = BotController.Focus;
					} else if(BotController.Skill <=6) { 
						if(FRand() < 0.7)
							BestTarget = BotController.Focus;
					} else {
						BestTarget = BotController.Focus;
					}
				} else {
					BestTarget = BotController.Focus;
				}
			}
        }
    }
    else
    {
        // Begin by tracing the shot to see if it hits anyone
        Instigator.Controller.GetPlayerViewPoint( StartTrace, AimRot );
        Aim = vector(AimRot);
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

simulated function ActiveRenderOverlays( HUD H )
{
   local PlayerController PC;
   PC = PlayerController(Instigator.Controller);
   
   if ( bLockedOnTarget && (LockedTarget != None) && (Instigator != None) && WorldInfo.NetMode != NM_DedicatedServer ) {
      if ( ((LocalPlayer(PC.Player) == None) || !LocalPlayer(PC.Player).GetActorVisibility(LockedTarget))) {
          DrawCrosshair(H);
          return;
      }
      else {
         DrawLockedOn( H );
      }
   }
   else {
   	  DrawCrosshair(H);
      bWasLocked = false;
   }
}

simulated event Destroyed()
{
    AdjustLockTarget(none);
    super.Destroyed();
}

/*
 * Dist
 * Distance function, returns the range between 2 vectors
 *
 * @param V1      - Location Point1
 * @param V2      - Location Point2
*/
function float Dist (vector V1, vector V2)
{
   return vSize(V1 - V2);
}

simulated function InstantFire()
{
	local vector StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact;
	local int i;
	
	if(WorldInfo.NetMode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		return;	
	} else if(WorldInfo.Netmode == NM_Client ) {
		ConsumeClientsideAmmo(CurrentFireMode);
	}
	
	//This code is basically just going to find what the crosshairs are on, to set the end point of our direction vector
	StartTrace = InstantFireStartTrace();
	EndTrace = InstantFireEndTrace(StartTrace);
	bUsingAimingHelp = false;
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	for (i = 0; i < ImpactList.length; i++)
	{
		if(WorldInfo.NetMode != NM_DedicatedServer && Instigator.Controller.IsLocalPlayerController()) {
			
			if(WorldInfo.NetMode == NM_Client && FracturedStaticMeshActor(RealImpact.HitActor) != None) {
				ProcessInstantHit(CurrentFireMode, ImpactList[i]);
			}
			
			if(Pawn(ImpactList[i].HitActor) != None && Pawn(ImpactList[i].HitActor).Health > 0 && Pawn(ImpactList[i].HitActor).GetTeamNum() != Instigator.GetTeamNum()) {
				Rx_Hud(Rx_Controller(Instigator.Controller).myHud).ShowHitMarker();
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
		MyVehicle.WeaponFired(self,false,RealImpact.HitLocation);
	}
}

simulated function bool TryHeadshot(byte FiringMode, ImpactInfo Impact) 
{
	local float Scaling;
	local int HeadDamage;
    	
	if(WeaponFireTypes[FiringMode] == EWFT_InstantHit)
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

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local bool bFixMomentum;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
	
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
				HitEnemy++;
				LastHitEnemyTime = WorldInfo.TimeSeconds;
			}
			if ( (UTPawn(Impact.HitActor) == None) && (InstantHitMomentum[FiringMode] == 0) )
			{
				InstantHitMomentum[FiringMode] = 1;
				bFixMomentum = true;
			}
			Super(UDKWeapon).ProcessInstantHit(FiringMode, Impact, NumHits);
			if (bFixMomentum)
			{
				InstantHitMomentum[FiringMode] = 0;
			}
		}
	}

}

reliable server function ServerALInstanthitHit( byte FiringMode, ImpactInfo Impact, vector RealImpactLocation)
{
	ProcessInstantHit(FiringMode, Impact);
	SetFlashLocation(RealImpactLocation);
}

reliable server function ServerALHeadshotHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Vehicle			Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage;

	Shooter = Rx_Vehicle(Owner);
	ProjectileClass = class<Rx_Projectile>(GetProjectileClass());

	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(UTPlayercontroller(Instigator.Controller) == None || Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}	

	// If we don't have a projectile class, and are not an instant hit weapon
	if (ProjectileClass == none && !self.bInstantHit)
	{
		return;
	}
	if (Shooter == none || Target == none)
	{
		return;  
	}
	if (Target != none && VSize(Target.Location - HitLocation) > 250 )
	{
		return;
	}
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	if (!self.bInstantHit)
	{
		Damage  = ProjectileClass.default.Damage * ProjectileClass.default.HeadShotDamageMult;
    
		FireDir = Normal(Target.Location - Instigator.Location);
		Momentum = ProjectileClass.default.MomentumTransfer * FireDir;

		if(ProjectileClass.default.HeadShotDamageType != None) 
		{
			DamageType = ProjectileClass.default.HeadShotDamageType; 
		} 
		else 
		{
			DamageType = ProjectileClass.default.MyDamageType; 
		}
	} else {
		Damage  = self.InstantHitDamage[CurrentFireMode] * self.HeadShotDamageMult;
    
		FireDir = Normal(Target.Location - Instigator.Location);
		Momentum = self.InstantHitMomentum[CurrentFireMode] * FireDir;

		if(self.HeadShotDamageType != None) 
		{
			DamageType = self.HeadShotDamageType;
		} 
		else 
		{
			DamageType = self.InstantHitDamageTypes[CurrentFireMode];
		}
	}

	if(Rx_Pawn(Target) != None) 
	{
		Rx_Pawn(Target).setbHeadshot(true);	
	}
	
	if(WorldInfo.Netmode == NM_DedicatedServer)
	{
		SetFlashLocation(HitLocation);
	}		
	
	Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);	
}

reliable server function ServerALHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo, bool mctDamage)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Vehicle			Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HitDistDiff;

	Shooter = Rx_Vehicle(Owner);
	if(Shooter == None && UTWeaponPawn(Owner) != None)
		Shooter = Rx_Vehicle(UTWeaponPawn(Owner).MyVehicle); 

	ProjectileClass = class<Rx_Projectile>(GetProjectileClass());
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(UTPlayercontroller(Instigator.Controller) == None || Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}

	if (Shooter == none || Target == none || ProjectileClass == none)
	{
		return;  
	}
	if (Target != none)
	{
		HitDistDiff = VSize(Target.Location - HitLocation);
		if(Rx_Building(Target) != None) {
			if(HitDistDiff > 3000) {
				return;
			}
		} else if(HitDistDiff > 800) {
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
	Damage = ProjectileClass.default.Damage;
	if(mctDamage) {
		Damage = Damage * class<Rx_DmgType>(DamageType).static.MCTDamageScalingFor();
	}
		
	//SetFlashLocation(HitLocation);
	//SetReplicatedImpact(HitLocation, FireDir, Shooter.Location, class, 0.0, true );

	Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);
}

reliable server function ServerALRadiusDamage(Actor Target, vector HurtOrigin, bool bFullDamage)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Vehicle			Shooter;
	local float					Momentum;
	local float 				Damage,DamageRadius;

	Shooter = Rx_Vehicle(Owner);

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
	if (Target != none && VSize(Target.Location - HurtOrigin) > 400 )
	{
		return;
	}
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	Momentum = ProjectileClass.default.MomentumTransfer;
	DamageType = ProjectileClass.default.MyDamageType;
	Damage = ProjectileClass.default.Damage;
	DamageRadius = ProjectileClass.default.DamageRadius;
	
	Target.TakeRadiusDamage(Instigator.Controller,Damage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,self);
}


/*****************************
 * Instant Hit Radius Damage *  This section is an exact copy of what is in Rx_Weapon, so update accordingly.
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
	RxIfc_ClientSideInstantHitRadius(HitActor).TakeDamageFromDistance(FMax(Distance, 0), Instigator.Controller, InstantHitDamage[ClientHitFiringMode], InstantHitDamageRadius[ClientHitFiringMode], 
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
			Victim.TakeRadiusDamage(Instigator.Controller, InstantHitDamage[FiringMode], InstantHitDamageRadius[FiringMode], 
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
		
	DiedTime = Rx_Controller(Instigator.Controller).GetLastDiedTime();
	
	if (DiedTime + FlightTime + 0.075 > WorldInfo.TimeSeconds)
		return true;
		
	return false;
}

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return true;
}

simulated function bool ShouldRefire()
{
 	local vector FireStartLoc;
 	local Rx_Vehicle veh;
 	
 	if(CurrentlyReloadingClientside)
 	{
 		return false;
 	}
 		
 	if(bCheckIfBarrelInsideWorldGeomBeforeFiring) {
	 	FireStartLoc = MyVehicle.GetEffectLocation(SeatIndex);
	 	if(!FastTrace(FireStartLoc,MyVehicle.location)) {
			ClearPendingFire(CurrentFireMode);
			return false;
		}
	} 
	
 	if(bCheckIfFireStartLocInsideOtherVehicle)
 	{
 	    foreach CollidingActors(class'Rx_Vehicle', veh, 3, Owner.location, true)
   		{
			if(veh == Pawn(Owner))
				continue;
			ClearPendingFire(CurrentFireMode);
			return false;
		}
	} 	
	
	return super.ShouldRefire();
}

simulated function SetCurrentlyReloadingClientside(bool NewValue)	
{
	CurrentlyReloadingClientside = NewValue;	
}

simulated function SetCurrentlyReloadingClientsideToFalseTimer()	
{
	CurrentlyReloadingClientside = false;	
}


DefaultProperties
{
	InventoryGroup=0
	FireOffset=(X=0,Y=0,Z=0)

	bDebugWeapon = false
	BobDamping=0.7
	JumpDamping=1.0

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_Default_NoDot'
	LockedOnCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_MissileLock'
	HitIndicatorCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_HitMarker'

	SecondaryLockingDisabled = true
	
	CrosshairWidth = 256
	CrosshairHeight = 256
	CloseRangeAimAdjustRange = 0.0
	
	RecoilImpulse = -0.3f

	HeadShotDamageType=class'Rx_DmgType_Headshot'
	HeadShotDamageMult=5.0
	SlowHeadshotScale=1.75
	RunningHeadshotScale=1.5

	InstantHitDamageRadius(0) = 0
	InstantHitDamageRadius(1) = 0
	InstantHitDamageRadiusDoFull(0) = false
	InstantHitDamageRadiusDoFull(1) = false
	InstantHitDamageRadiusIgnoreTeam(0) = false
	InstantHitDamageRadiusIgnoreTeam(1) = false
}
