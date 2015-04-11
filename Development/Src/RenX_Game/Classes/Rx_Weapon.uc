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

/** one1: Added. */
var class<Rx_BackWeaponAttachment> BackWeaponAttachmentClass;

/** Secondary Left Hand IK Translation Offset - adjust for any specific weapon. */
var() Vector LeftHandIK_Offset;

/** Secondary Right Hand IK Translation Offset - adjust for any specific weapon. */
var() Vector RightHandIK_Offset;

/** The GFX weapon/inventory set, 0-15. */
var byte InventoryMovieGroup;

var() class<UTDamageType> HeadShotDamageType;
var() float HeadShotDamageMult;

/** headshot scale factor when moving slowly or stopped */
var() float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var() float RunningHeadshotScale;

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

var bool bOkAgainstVehicles; // Hint for AI
var bool bOkAgainstBuildings; // Hint for AI

//-------------------- Recoil
var float Recoil;
var float MinRecoil;
var float MaxRecoil;
var float MaxTotalRecoil;
var rotator RecoilOffset;
var rotator RecoilDecline;
var rotator TotalRecoil;
var float RecoilInterpSpeed;
var float RecoilDeclinePct;
var float RecoilDeclineSpeed;
var float RecoilDelay;
var float RecoilSpreadDecreaseDelay;
var float RecoilSpread;
var float CurrentSpread;
var float MaxSpread;
var float RecoilSpreadIncreasePerShot;
var float RecoilSpreadDeclineSpeed;
var float RecoilYawModifier;
var float RecoilYawMultiplier;
var int RecoilSpreadCrosshairScaling;

var bool bAutoFire;
var bool bLogRecoilTemp;

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
												
	HitIndicatorCrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	HitIndicatorCrosshairMIC2.SetParent(HitIndicatorCrosshairMIC);		
	
	if(Rx_Game(WorldInfo.Game) != None)
		bCanThrow = Rx_Game(WorldInfo.Game).bAllowWeaponDrop;									
}

simulated function bool CanThrow()
{
	return false; // reactivate when we know more clearly how we want weapondrop to work
	/**
	if(!bCanThrow)
		return false;
	else	
		return FRand() < 0.5;
	*/	
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
	local int targetTeam, rectColor;
	
	// rectColor is an integer representing what we will pass to the texture's parameter(ReticleColourSwitcher):
	// 0=Default, 1=Red, 2=Green, 3=Yellow
	rectColor = 0;	
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;
		
	CrosshairWidth = default.CrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling;	
	CrosshairHeight = default.CrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling;
		
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
		if (Rx_Weapon_Reloadable(self) != None && (Rx_Weapon_Reloadable(self).CurrentlyReloading 
				|| (Rx_Weapon_Reloadable(self).CurrentlyBoltReloading || (Rx_Weapon_Reloadable(self).BoltActionReload && HasAmmo(CurrentFireMode) && IsTimerActive('BoltActionReloadTimer'))))) //reloading, go yellow
			rectColor = 3;
	}

	CrosshairMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	CrosshairDotMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	
	H.Canvas.SetPos( CrosshairLinesX, CrosshairLinesY );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
	}

	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5);
	GetCrosshairDotLoc(x, y, H);
	H.Canvas.SetPos( X, Y );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairDotMIC2, default.CrosshairWidth, default.CrosshairHeight);
	}
	DrawHitIndicator(H,x,y);
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

simulated function GetCrosshairDotLoc( out float x, out float y, Hud H )
{
	CrosshairDotDrawX = CrosshairLinesX;
	CrosshairDotDrawY = CrosshairLinesY;
	bCrosshairDotCentered = true;
	x = CrosshairDotDrawX;
	y = CrosshairDotDrawY;
}

/**
 * Draw the locked on symbol
 */
simulated function DrawLockedOn( HUD H )
{
	local vector2d CrosshairSize;
	local float x, y, ScreenX, ScreenY, LockedOnTime, TargetDist;
	
	TargetDist = GetTargetDistance();

	if ( !bWasLocked )
	{
		LockedStartTime = WorldInfo.TimeSeconds;
		CurrentLockedScale = StartLockedScale;
		bWasLocked = true;
	}
	else
	{
		LockedOnTime = WorldInfo.TimeSeconds - LockedStartTime;
		CurrentLockedScale = (LockedOnTime > LockedScaleTime) ? FinalLockedScale : (StartLockedScale * (LockedScaleTime - LockedOnTime) + FinalLockedScale * LockedOnTime)/LockedScaleTime;
	}
	
 	CrosshairSize.Y = UTHUDBase(H).ConfiguredCrosshairScaling * CurrentLockedScale * CrosshairScaling * LockedCrossHairCoordinates.VL * H.Canvas.ClipY/720;
  	CrosshairSize.X = CrosshairSize.Y * ( LockedCrossHairCoordinates.UL / LockedCrossHairCoordinates.VL );

	X = H.Canvas.ClipX * 0.5;
	Y = H.Canvas.ClipY * 0.5;
	ScreenX = X - (CrosshairSize.X * 0.5);
	ScreenY = Y - (CrosshairSize.Y * 0.5);
	
	if ( CrosshairImage != none )
	{
		// crosshair drop shadow
		H.Canvas.DrawColor = class'UTHUD'.default.BlackColor;
		H.Canvas.SetPos( ScreenX+1, ScreenY+1, TargetDist );
		H.Canvas.DrawMaterialTile(CrosshairMIC,CrosshairSize.X, CrosshairSize.Y);

		H.Canvas.DrawColor = CrosshairColor;
		H.Canvas.SetPos(ScreenX, ScreenY, TargetDist);
		H.Canvas.DrawMaterialTile(CrosshairMIC,CrosshairSize.X, CrosshairSize.Y);
	}
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
	AmmoCount = MaxAmmoCount;
}

simulated function PlayWeaponPutDown()
{
	super.PlayWeaponPutDown();
	
	if(Owner != None) {
		Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration( ThirdPersonWeaponPutDownAnim, PutDownTime,0.1f,0.1f,false,true);
	}
}



simulated function PlayWeaponEquip()
{
	PlayWeaponEquipWithOptionalAnim(true);
}

simulated function PlayWeaponEquipWithOptionalAnim(bool bWithEquipAnim)
{
	super.PlayWeaponEquip();
	if(bWithEquipAnim)
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
	
    if( Rx_Controller(Instigator.Controller) != None && Rx_Controller(Instigator.Controller).bBehindView)
    {
        Instigator.Controller.GetPlayerViewPoint(ViewLocation, ViewRotation);
        
		if(WorldInfo.NetMode == NM_DedicatedServer) {
			ViewLocation.z += 6;	
		}        
		return ViewLocation;
    }

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
	
	// Spawn projectile	
	SpawnedProjectile = Spawn(GetProjectileClassSimulated(),,, RealStartLoc);
	if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
	{
		if(Rx_Bot(instigator.Controller) != None) {
			SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc ) ) );
		} else {
			SpawnedProjectile.Init( Vector(GetAdjustedWeaponAim( RealStartLoc )) );
		}
		
		if(WorldInfo.Netmode == NM_Client && Rx_Weapon_Reloadable(self) != None) {
			Rx_Weapon_Reloadable(self).CurrentAmmoInClipClientside -= default.ShotCost[CurrentFireMode];
		}
	}
	
	// Return it up the line
	return SpawnedProjectile;
}

simulated function Projectile ProjectileFireOld()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( ROLE == Role_Authority) {
		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();
		
		// Spawn projectile	
		SpawnedProjectile = Spawn(GetProjectileClassSimulated(),,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector(GetAdjustedWeaponAim( RealStartLoc )) );
		}
		
		// Return it up the line
		return SpawnedProjectile;
	} else {
		AddSpread(Instigator.GetBaseAimRotation());
	}
}

simulated function class<Projectile> GetProjectileClassSimulated()
{
	return (CurrentFireMode < WeaponProjectiles.length) ? WeaponProjectiles[CurrentFireMode] : None;
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
	GetTraceOwner().Trace(HitLocation, HitNormal, EndTrace, StartTrace, TRUE, , HitInfo, TRACEFLAG_Bullet);
	
	if(HitLocation != vect(0,0,0))
	{
		EndTrace = HitLocation;
		EndTrace = EndTrace + (100 * Normal(EndTrace - Instigator.GetWeaponStartTraceLocation()));
	}
	//DrawDebugLine(Instigator.GetWeaponStartTraceLocation(),EndTrace,0,0,255,true);
	RealImpact = CalcWeaponFire(Instigator.GetWeaponStartTraceLocation(), EndTrace, ImpactList);

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
		Rx_Pawn(Owner).WeaponFired(self,true,RealImpact.HitLocation);
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
			Super(UDKWeapon).ProcessInstantHit(FiringMode, Impact, NumHits);
			if (bFixMomentum)
			{
				InstantHitMomentum[FiringMode] = 0;
			}
		}
	}

}

simulated function FireAmmunition()
{
	super.FireAmmunition();
	RecoilDelay = default.RecoilDelay;
	RecoilSpreadDecreaseDelay = default.RecoilSpreadDecreaseDelay;
	SetWeaponRecoil(RandRange(MinRecoil,MaxRecoil));
	bLogRecoilTemp = true;
}

simulated function SetWeaponRecoil(int PitchRecoil) {
	local int YawRecoil;
	YawRecoil = (RecoilYawModifier - FRand()) * PitchRecoil * RecoilYawMultiplier;
	RecoilOffset.Pitch += PitchRecoil;
	RecoilOffset.Yaw += YawRecoil;	
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
	Dist = VSize(Instigator.Location - Other.Location);
	if (Dist > MaxRange())
	{
		if(Rx_Building(Other) != None || Rx_BuildingObjective(Other) != None) {
			if(Rx_BuildingObjective(Other) != None) {
				RealTarget = Rx_BuildingObjective(Other).myBuilding;
			}
			if(RealTarget != Trace( out_HitLocation, out_HitNormal, RealTarget.GetTargetLocation(), Instigator.Location)) {
				return false;
			}
			Dist = VSize(Instigator.Location - out_HitLocation);
			if(Dist <= MaxRange() - 50) {
				CachedMaxRange = 20000;		
			} else {
	            //DrawDebugLine(Instigator.Location,Other.location,0,0,255,true);
	            //DrawDebugLine(Instigator.Location,out_HitLocation,0,255,0,true);
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
	Dist = VSize(TestLocation - Other.Location);
	if (Dist > MaxRange())
	{
		if(Rx_Building(Other) != None || Rx_BuildingObjective(Other) != None) {
			if(Rx_BuildingObjective(Other) != None) {
				RealTarget = Rx_BuildingObjective(Other).myBuilding;
			}
			if(RealTarget != Trace( out_HitLocation, out_HitNormal, Other.location, TestLocation)) {
				return false;
			}
			Dist = VSize(TestLocation - out_HitLocation);
			if(Dist <= MaxRange() - 50) {
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
	if(UTVehicle(P) != None && !bOkAgainstVehicles) {
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
		if(RecoilSpreadIncreasePerShot != 0.0 && RecoilSpread == 0.0 && Rx_Bot(Pawn(owner).controller) == None) {
			ret = BaseAim;
		} else {
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
	if(bAutoFire) {
		if(GetZoomedState() != ZST_NotZoomed && CurrentFireMode != 0)
		{
			return false;
		}
		return super.ShouldRefire();
	} else {
		ClearPendingFire(0);
		ClearPendingFire(1);
		return false;
	}
}

event Tick( float DeltaTime ) {
	super.Tick(DeltaTime);
	if(WorldInfo.NetMode == NM_DedicatedServer || (Instigator != None && Rx_Bot(Instigator.Controller) != None)) {
		DecreaseRecoilSpread(DeltaTime);
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
    	P.GroundSpeed = Default.ZoomGroundSpeed;
    	P.AirSpeed = Default.ZoomAirSpeed;
    	P.WaterSpeed = Default.ZoomWaterSpeed;
    	P.JumpZ = Default.ZoomJumpZ;
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
		if(!Rx_Pawn(Instigator).bSprinting && !Rx_Pawn(Instigator).bSprintingServer && !Rx_Pawn(Instigator).bDodging) {
    		P.GroundSpeed = class'Rx_Pawn'.Default.GroundSpeed;
	    	P.AirSpeed = class'Rx_Pawn'.Default.AirSpeed;
		}
    	P.WaterSpeed = class'Rx_Pawn'.Default.WaterSpeed;
    	P.JumpZ = class'Rx_Pawn'.Default.JumpZ;

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
	ProcessInstantHit(FiringMode, Impact);
	SetFlashLocation(RealImpactLocation);
	if(Rx_Weapon_Shotgun(self) != None) {
		if(Rx_Pawn(Owner).ShotgunPelletCount <= 10) { 
			Rx_Pawn(Owner).ShotgunPelletHitLocations[Rx_Pawn(Owner).ShotgunPelletCount++] = RealImpactLocation;
		}
	}	
}

reliable server function ServerALHeadshotHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo)
{
	local class<UTProjectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Pawn				Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HeadShotDamageMultLocal;

	Shooter = Rx_Pawn(Owner);
	ProjectileClass = class<UTProjectile>(GetProjectileClass());

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
		if(class<Rx_Projectile>(ProjectileClass) != None) {
			HeadShotDamageMultLocal = class<Rx_Projectile>(ProjectileClass).default.HeadShotDamageMult;
			HeadShotDamageType = class<Rx_Projectile>(ProjectileClass).default.HeadShotDamageType;
		} else {
			HeadShotDamageMultLocal = class<Rx_Projectile_Rocket>(ProjectileClass).default.HeadShotDamageMult;
			HeadShotDamageType = class<Rx_Projectile_Rocket>(ProjectileClass).default.HeadShotDamageType;
		}
		Damage  = ProjectileClass.default.Damage * HeadShotDamageMultLocal;
    
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
	}
	// Then we are an instant hit weapon
	else
	{
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
		Rx_Pawn(Target).bHeadshot = true;	
	}
	
	if(WorldInfo.Netmode == NM_DedicatedServer)
	{
		SetFlashLocation(HitLocation);
	}	
	
	if(Rx_Pawn(Instigator) != None)
		Rx_Pawn(Instigator).HitEnemyWithHeadshotForDemoRec++;	
	
	Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);	
}

reliable server function ServerALHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo, bool mctDamage)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Pawn				Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HitDistDiff;

	Shooter = Rx_Pawn(Owner);

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
	HitDistDiff = VSize(Target.Location - HitLocation);
	if (Target != none)
	{
		if(Rx_Building(Target) != None) {
			if(HitDistDiff > 3000) {
				return;
			}
		} else if(HitDistDiff > 250) {
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
	local Rx_Pawn				Shooter;
	local float					Momentum;
	local float 				Damage,DamageRadius;

	Shooter = Rx_Pawn(Owner);

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
		
	DiedTime = Rx_Controller(Instigator.Controller).LastDiedTime;
	
	if (DiedTime + FlightTime + 0.075 > WorldInfo.TimeSeconds)
		return true;
		
	return false;
}

simulated function ActiveRenderOverlays( HUD H )
{
	DrawCrosshair(H);
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

simulated event SetPosition(UDKPawn Holder)
{
	local rotator NewRotation;

	super.SetPosition(Holder);
	if ( bIronsightActivated)
	{
		NewRotation = Holder.GetViewRotation();
		SetRotation(NewRotation);
		Holder.ArmsMesh[0].SetRotation(NewRotation);
		Holder.ArmsMesh[1].SetRotation(NewRotation);
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

simulated function ChangeVisibility(bool bIsVisible)
{
	super.ChangeVisibility(bIsVisible);
	if(bIsVisible && !bChangedTo1stPersonOnce && (IsInState('WeaponFiring') || IsInState('WeaponBeamFiring')))
	{
		SetTimer(0.01,false,'GotoActiveTimer');	// this is to fix a weapondisplaybug upon first switch from 3rd to 1stperson
		bChangedTo1stPersonOnce = true;
	}
	else if(bIsVisible && IsTimerActive('WeaponEquipped',self))
	{
		PlayIdleAnims();
	}
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


DefaultProperties
{
	LeftHandIK_Offset=(X=0,Y=0,Z=0)
	RightHandIK_Offset=(X=0,Y=0,Z=0)

	Begin Object Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=true
		CastShadow=true
		bAllowAmbientOcclusion=true
		bCastDynamicShadow=true
		bSelfShadowOnly=true
	End Object
	Mesh=FirstPersonMesh
	
    FireOffset=(X=0,Y=0,Z=0)
    
	bDebugWeapon = false
	bAutoFire = true
	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_Default'
	CrosshairDotMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_Dot'
	CrosshairWidth = 210 	// 256
	CrosshairHeight = 210 	// 256
	HitIndicatorCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_HitMarker'

	ThirdPersonWeaponPutDownAnim="H_M_Weapon_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_Weapon_Equip"

	WidescreenRotationOffset=(Pitch=-3,Yaw=0,Roll=0)
	WideScreenOffsetScaling=0.0
	PivotTranslation=(Y=-10.0)

	BobDamping=0.75 //0.7
	JumpDamping=2.0 //1.0

	HeadShotDamageType=class'Rx_DmgType_Headshot'
	HeadShotDamageMult=5.0
	SlowHeadshotScale=1.75
	RunningHeadshotScale=1.5
	bOkAgainstVehicles=false
	bOkAgainstBuildings=false

	EquipTime=0.5 
	PutDownTime=0.05

	InventoryMovieGroup=0
	InventoryGroup=2
	
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
	RecoilSpreadCrosshairScaling = 2000;
	
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
}
