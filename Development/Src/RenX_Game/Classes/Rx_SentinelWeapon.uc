//=============================================================================
// Weapon for a Sentinel.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeapon extends Rx_SentinelUpgrade
	abstract;

/** Fire mode properties. If a weapon has multiple fire modes, change this in SetFireMode, making sure to call super afterwards. */
var() Rx_SentinelWeaponComponent_FireInfo FireInfo;
/** Muzzle flash. */
var() Rx_SentinelWeaponComponent_MuzzleFlash MuzzleFlash;
/** Muzzle flash light. */
var() Rx_SentinelWeaponComponent_MuzzleFlashLight MuzzleFlashLight;

/** Mesh for Sentinel to apply to its WeaponComponent. */
var() SkeletalMesh WeaponMesh;
/** Physics asset used for "gibbing". If none, then the Sentinel will not fall appart when destroyed. */
var() PhysicsAsset PhysicsAsset;
/** Used for weapon mesh animations, if any. */
var() AnimTree AnimTreeTemplate;
/** */
var() AnimSet AnimSet;
/** Material to apply to WeaponMesh. */
var() MaterialInstance WeaponMaterial;
/** Material to apply to WeaponMesh when spawning. */
var() MaterialInstance WeaponSpawnMaterial;
/** Material to apply to WeaponMesh when destroyed. */
var() MaterialInstance WeaponDeadMaterial;
/** Scale to apply to WeaponMesh. */
var() float WeaponScale;
/** Name of root bone in mesh. */
var() name RootBone;
/** Name of the socket at the muzzle, for attaching effects to. */
var() name MuzzleSocketName;
/** Name of socket to use when viewing from the Sentinel. */
var() name CameraSocketName;

/** If true, then the weapon is suitable for firing at targets that the Sentinel cannot see. Such a weapon will continue to receive FireAt events, even when the target is not visible (at the target's LastDetectedLocation in that case), it is up to the weapon to decide whether it cn actually fire or not. The Sentinel will cease attempting to fire a while after the first time FireAt returns false.*/
var() bool bCanFireBlind;

/** Set false for FireInterval seconds when the weapon fires. */
var bool bCanFire;
/** Set false for a while after firing to tell the Sentinel to stop rotating momentarily. */
var bool bCanRotate;
var repnotify byte FlashCount;

replication
{
	if(Role == ROLE_Authority && bNetDirty)
		FlashCount, bCanRotate;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'FlashCount')
	{
		if(FlashCount > 0)
		{
			FlashMuzzleFlash();
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetFireMode();
}

/** Changes fire mode and initializes it. */
simulated function SetFireMode()
{
	FireInfo.Initialize();
}

/**
 * Does anything that might be needed to make the weapon work for a particular Sentinel.
 */
function InitializeFor(Rx_Sentinel S)
{
	super.InitializeFor(S);

	//Prevent firing immediately on spawning.
	bCanFire = false;
	SetTimer(FireInfo.FireInterval, false, 'FireTimer');
}

/**
 * Sets mesh and other properties of the component and attaches self to it.
 */
simulated function InitializeWeaponComponent(Rx_SentinelComponent_Mesh WeaponComponent)
{
	WeaponComponent.SetSkeletalMesh(WeaponMesh);
	WeaponComponent.SetScale(WeaponScale);
	WeaponComponent.SetPhysicsAsset(PhysicsAsset);
	WeaponComponent.SetAnimTreeTemplate(AnimTreeTemplate);
	WeaponComponent.AnimSets[0] = AnimSet; //TODO: Support for multiple AnimSets needed?

	WeaponComponent.SpawnMaterial = WeaponSpawnMaterial;
	WeaponComponent.DeadMaterial = WeaponDeadMaterial;
	WeaponComponent.SetMaterial(0, WeaponMaterial);
	WeaponComponent.ComponentMaterialInstance = WeaponComponent.CreateAndSetMaterialInstanceConstant(0);

	if(Rx_SentinelWeapon_Obelisk(self) == None) {
		WeaponComponent.RootBone = RootBone;
		SetBase(WeaponComponent.Owner,, WeaponComponent, WeaponComponent.RootBone);
	}

	InitMuzzleFlash();
}

simulated function class<Projectile> GetProjectileClass()
{
	return FireInfo.ProjectileClass;
}

simulated function float GetMaxAimError()
{
	return FireInfo.MaxAimError;
}

/**
 * Opportunity for the weapon to affect aim prediction. Only used if there is a projectile class of course.
 */
simulated function float GetProjectileTimeToLocation(Vector TargetLoc, Vector StartLoc, Controller RequestedBy)
{
	return GetProjectileClass().static.StaticGetTimeToLocation(TargetLoc, StartLoc, RequestedBy);
}

/**
 * Allows the muzzle flash and light to set themselves up.
 */
simulated function InitMuzzleFlash()
{
	if(Cannon != none)
	{
		if(MuzzleFlash != none)
		{
			MuzzleFlash.Initialize(Cannon.WeaponComponent, MuzzleSocketName);
		}

		if(MuzzleFlashLight != none)
		{
			MuzzleFlashLight.Initialize(Cannon.WeaponComponent, MuzzleSocketName);
		}
	}
}

/**
 * Turn muzzle flash/light on, and play firing sound.
 */
simulated function FlashMuzzleFlash()
{
	if(Cannon != none)
	{
		if(FireInfo.FireSound != none)
		{
			PlaySound(FireInfo.FireSound, true);
		}

		if(MuzzleFlash != none)
		{
			MuzzleFlash.Flash();

			//Hack: Ensures particles spawn at the PSC's location, not between the PSC's location and the Sentinel's location.
			//Note that the Disturber detaches its muzzle flash frequently and assumes it will be reattached here, so it will need to be altered if this is ever fixed properly.
			MuzzleFlash.Initialize(Cannon.WeaponComponent, MuzzleSocketName); 
		}

		if(MuzzleFlashLight != none)
		{
			MuzzleFlashLight.Flash();
		}
	}
}

/**
 * Provides an opportunity to adjust the direction the Sentinel is aiming in. Useful for any weapon that doesn't fire directly at the target (MultiMortar).
 *
 * @param	A			the actor being targeted
 * @param	AimSpot		the location being aimed at
 * @param	AimRotation	the current aim
 */
function AdjustAimToHit(Actor A, out Vector AimSpot, out Rotator AimRotation){}

/**
 * Fires at something. n.b. BarrelDir and Aim can be different to let the Sentinel fire perfectly even if it's not quite perfectly aimed.
 * Individual weapons need to implement this.
 *
 * @param	Start		location to fire from
 * @param	BarrelDir	direction barrel is pointed in
 * @param	End			location to fire at
 * @return	true if the weapon fired
 */
function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
{
	bCanFire = false;
	SetTimer(FireInfo.FireInterval, false, 'FireTimer');

	if(FireInfo.RotationStopTime > 0.0)
	{
		bCanRotate = false;
		SetTimer(FireInfo.RotationStopTime, false, 'RotationStopTimer');
	}

	return true;
}

/**
 * Allows access to projectiles as they are spawned. Projectile-firing subclasses should call this from FireAt.
 *
 * @param	Proj			the projectile
 * @param	ProjDir			passed to Proj.Init
 * @param	TargetLocation	location that the projectile was fired towards
 */
function InitializeProjectile(Projectile Proj, Vector ProjDir, optional Vector TargetLocation)
{
	Proj.Init(ProjDir);
}

/**
 * Marks the weapon as being ready to fire again.
 */
function FireTimer()
{
	bCanFire = true;
}

/**
 * Allows the Sentinel to rotate the weapon again.
 */
function RotationStopTimer()
{
	bCanRotate = true;
	bForceNetupdate = true;
}

function NotifyFired()
{
	//It may seem a bit weird doing this here, but it ensures that the muzzleflash only comes on if the weapon actually fired, not every time it's asked to fire.
	FlashCount = Max(1, FlashCount + 1);
	bForceNetupdate = true;

	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		FlashMuzzleFlash();
	}

	Cannon.MakeNoise(FireInfo.FireLoudness);

	super.NotifyFired();
}

function NotifyWaiting()
{
	FlashCount = 0;
	bForceNetupdate = true;

	super.NotifyWaiting();
}

function AdjustStrength(out float Strength)
{
	super.AdjustStrength(Strength);

	Strength += ExtraStrength;
}

simulated function NotifyTeamChanged(){}

/**
 * Weapons may have effects that need to be hidden when the Sentinel becomes invisible. That is handled here.
 */
simulated function NotifyInvisible(bool bInvisible){}

function bool CanHit(Pawn PotentialTarget) {
	return true;
}


defaultproperties
{
	bCanRotate=true
	WeaponScale=1.0
	RootBone=Weapon
	MuzzleSocketName=Muzzle
	CameraSocketName=Camera
}
