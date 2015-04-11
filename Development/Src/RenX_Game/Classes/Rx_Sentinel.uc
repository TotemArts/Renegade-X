//=============================================================================
// Base class for actual Sentinel turrets.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_Sentinel extends Pawn
	abstract
	placeable;

//Components handle quite a lot of the Sentinel's functionality.
var() const Rx_SentinelComponent_Mesh BaseComponent;
var() const Rx_SentinelComponent_Mesh RotatorComponent;
var() const Rx_SentinelComponent_Mesh WeaponComponent;
var() const LightEnvironmentComponent LightEnvironment;
var() Rx_SentinelComponent_RotationSound PitchSoundComponent;
var() Rx_SentinelComponent_RotationSound YawSoundComponent;
var() array<Rx_SentinelComponent_ParticleSystem_Damage> DamageParticleComponents;
var() Rx_SentinelComponent_ExplosionEffects ExplosionEffectComponent;

/** Abbreviated version of MenuName, used for the Telemeter beacon. */
var() localized string ShortMenuName;

/** Texture to use when drawing icon on the HUD. */
var() Texture2D IconHudTexture;
var() TextureCoordinates IconCoords;
var() float IconScale;

/** Spawn effect duration. */
var() float SpawnInTime;
/** Time to hang around after dying */
var() float DeadLifeSpan;
/** Amount of time it takes to "burn out". Note that collision is disabled DeadLifeSpan-BurnTime seconds after dying. */
var() float BurnTime;

struct SentinelTakeHitInfo
{
	var int Damage;
	var Vector HitLocation;
	var class<DamageType> DamageType;
};
var repnotify SentinelTakeHitInfo LastTakeHitInfo;

/** Damage taken is multiplied by this, as Sentinels have thick armour. */
var() float SentinelDamageScaling;
/** Sound to play when damaged. */
var() SoundCue DamageSound;
/** Minimum time between damage effects. */
var() float MinDamageEffectInterval;
/** Time that a damage effect was last played */
var float LastDamageEffectTime;

/** Damage to cause when exploding. */
var() float DiedDamage;
/** Size of explosion when exploding. */
var() float DiedDamageRadius;
/** Momentum of explosion when exploding. */
var() float DiedMomentum;
/** DamageType to inflict when exploding. */
var() class<DamageType> DiedDamageType;

/** Sound to play when entering water. */
var() SoundCue SplashSound;

/** Deployment cost. */
var() int AmmoCost;
/** Set to false to prevent the Sentinel Deployer from opening an upgrade menu for this Sentinel. */
var() bool bUpgradeable;
/** Set to false to prevent the owner's team-mates from opening an upgrade menu for this Sentinel. */
var() bool bTeamUpgradeable;
/** Starting weapon class. */
var() class<Rx_SentinelWeapon> DefaultWeaponClass;
/** Upgrades to spawn by default. */
var() array< class<Rx_SentinelUpgrade> > DefaultUpgradeClasses;
/** Current weapon. */
var repnotify Rx_SentinelWeapon SWeapon;
/** Class of UpgradeManager to spawn. */
var() class<Rx_SentinelUpgradeManager> UpgradeManagerClass;
var Rx_SentinelUpgradeManager UpgradeManager;

/** Controller of owning player. */
var Controller InstigatorController;


/** Just to avoid repetetive casting when accessing controller. */
var Rx_SentinelController SController;

/** What this Sentinel is currently interested in. */
var Actor Target;
/** Target.GetHumanReadableName, stored for replication. */
var string TargetName;
/** True when Sentinel has a target and is tracking it. */
var bool bTracking;

/** Colour for various effects. */
var repnotify LinearColor TeamColour;
/** A string identifying this Sentinel. */
var string UID;

/** Maximum rotation speed. */
var() Rotator MaxRotationSpeed;
/** Rotation will slow down when closer than this to the desired rotation. */
var() float RotationDampingThreshold;
/** Speed that Sentinel will rotate when it has no target. */
var() int AutoRotateRate;
/** Auto rotate direction will reverse when AutoRotateYaw exceeds this value in either direction. */
var() int AutoRotateHalfRange;
/** Offset applied to AutoRotateHalfRange so the Sentinel can look in a particular direction when idle. */
var() int AutoRotateCentre;
/** Limits for field of fire. */
var() int MaxPitch, MinPitch;

/** Rotation that Sentinel is trying to attain. */
var Rotator DesiredAim;
/** Rotation that Sentinel is currently pointing in. */
var Rotator CurrentAim;
/** Holds the value of the last change in rotation. */
var Rotator DeltaRotation;
/** Holds rotation of aim relative to base rotation after last rotation calculation. */
var Rotator BoneSpaceLastAim;

/** Proportion of targets velocity to take into account when predicting where to fire. */
var() float AimAhead;
/** Whether this Sentinel is capable of detecting invisible pawns. */
var() bool bSeeInvisible;
/** Fraction of SightRadius that invisible pawns must be closer than to be seen. */
var() float SeeInvisibleRange;

/** Played when target acquired. */
var() SoundCue TargetingSound;
/** Played when entering idle state. */
var() SoundCue WaitingSound;

/** Health replicated for client-side damage skin effects. */
var repnotify int RepHealth;

/** Rotation of base when Sentinel landed on it. */
var Rotator OriginalBaseRotation;
/** Rotation of Sentinel when it landed. */
var Rotator OriginalRotation;
/** Keeps track of yaw when idle. Stored as a float to avoid rounding errors from adding small increments to a Rotator. */
var float AutoRotateYaw;
/** Set to true if AutoRotateRate should be subtracted instead of added. */
var bool bAutoRotateYawReversed;

/** Set to false to stop this Sentinel being counted for MaxCannon checks.*/
var bool bCountsTowardLimit;

/** Set to true if this Sentinel is invisible. */
var bool bIsInvisible;

var bool bTrackingCloseRange;

var	repnotify byte Team;

///** Class containing ammo classes to use. */
//var() class<UTLRI_Sentinel> LRIClass;

replication
{
	if(Role == ROLE_Authority && InstigatorController.bNetOwner && bNetDirty)
		InstigatorController;

	if(Role == ROLE_Authority && bNetDirty)
		UpgradeManager, SWeapon, Team, TeamColour, RepHealth, LastTakeHitInfo;

	if(Role == ROLE_Authority && bNetDirty)
		bUpgradeable, bTeamUpgradeable, OriginalBaseRotation, OriginalRotation;

	if(Role == ROLE_Authority && bNetDirty)
		TargetName, bTracking, DesiredAim, MaxRotationSpeed, RotationDampingThreshold;

	if(Role == ROLE_Authority && bNetDirty && !bTracking)
		AutoRotateRate, AutoRotateHalfRange, AutoRotateCentre, bAutoRotateYawReversed, AutoRotateYaw;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'SWeapon')
	{
		if(SWeapon != none)
		{
			SetWeapon(SWeapon);
		}
	}
	else if(VarName == 'TeamColour')
	{
		NotifyTeamChanged();
	}
	else if(VarName == 'RepHealth')
	{
		UpdateDamageEffects();
	}
	else if(VarName == 'LastTakeHitInfo')
	{
		PlayTakeHitEffects();
	}
}

simulated function PostBeginPlay()
{
	if(Role == ROLE_Authority)
	{
		SpawnTime = WorldInfo.TimeSeconds;
		RepHealth = Health;
		DesiredAim = Rotation;
		OriginalRotation = Rotation;
	}

	CurrentAim = Rotation;

	BaseComponent.SetRotation(Rotation);
	RotatorComponent.SetRotation(Rotation);
	WeaponComponent.SetRotation(Rotation);

	RotatorComponent.SetShadowParent(BaseComponent);
	WeaponComponent.SetShadowParent(BaseComponent);

	PitchSoundComponent.Initialize();
	YawSoundComponent.Initialize();

	UID = class'Rx_Sentinel_Utils'.static.GenerateHexUIDFor(self, 8);

	self.Initialize();
}

/**
 * Plays spawning effects.
 */
simulated function PlaySpawnEffect()
{
	if(SController != none)
	{
		SController.CannonSpawning();
	}

	AutoRotateRate = 0; //Don't start rotating until finished spawning.

	BaseComponent.PlaySpawnEffect();
	RotatorComponent.PlaySpawnEffect();
	WeaponComponent.PlaySpawnEffect();
}

/**
 * Called when BaseComponent finished spawning
 */
simulated function BaseSpawned()
{
	AutoRotateRate = default.AutoRotateRate; //Start rotating.

	if(SController != none)
	{
		SController.CannonSpawned();
		InstigatorController = SController;
	}
}


function Initialize()
{
	local class<Rx_SentinelUpgrade> DefaultUpgradeClass;

	if(Controller == none)
	{
		SpawnDefaultController();
	}
	else
	{
		Controller.Possess(self, false);
	}

	SController = Rx_SentinelController(Controller);

	if(UpgradeManager == none)
	{
		UpgradeManager = Spawn(UpgradeManagerClass);
		UpgradeManager.InitializeFor(self);

		UpgradeManager.CreateUpgrade(DefaultWeaponClass);

		foreach DefaultUpgradeClasses(DefaultUpgradeClass)
		{
			UpgradeManager.CreateUpgrade(DefaultUpgradeClass);
		}
	}


//   	if(SController != none)
//	{
//		SController.CannonSpawning();
//	}
//
//	AutoRotateRate = 0; //Don't start rotating until finished spawning.

    NotifyTeamChanged();    // leads to SController.CannonSpawning();
    bForceNetUpdate = true;
}


/**
 * Makes any needed changes to conform to the current team.
 */
simulated function NotifyTeamChanged()
{
	BaseComponent.SetTeamColour();
	RotatorComponent.SetTeamColour();
	WeaponComponent.SetTeamColour();

	if(SWeapon != none)
	{
		SWeapon.NotifyTeamChanged();
	}

	PlaySpawnEffect();
}

/**
 * Sets up WeaponComponent according to properties of NewWeapon.
 */
simulated function SetWeapon(Rx_SentinelWeapon NewWeapon)
{
	SWeapon = NewWeapon;

	SWeapon.InitializeWeaponComponent(WeaponComponent);

	UpdateDamageEffects();
	WeaponComponent.SetTeamColour();
	WeaponComponent.PlaySpawnEffect();
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	Controller = C;
	bForceNetUpdate = true;

	PlayerReplicationInfo = C.PlayerReplicationInfo;
	Controller.SetRotation(CurrentAim);
	Eyeheight = BaseEyeHeight;
}

function PawnBaseDied()
{
	SetBase(none);
	JumpOffPawn();
}

function BaseChange()
{
	local Pawn P;
	local DynamicSMActor Dyn;
	//local SkeletalMeshComponent SMC;
	//local name SMCBoneName;

	if(Base != none)
	{
		P = Pawn(Base);

		if(P != none && Vehicle(P) == none && !P.CanBeBaseForPawn(self))
		{
			P.CrushedBy(self);
			JumpOffPawn();
		}
		else
		{
			Dyn = DynamicSMActor(Base);

			if(Dyn != none && !Dyn.CanBasePawn(self))
			{
				JumpOffPawn();
			}
			else
			{
				SetPhysics(PHYS_None);
				bCollideWorld = false;
				OriginalBaseRotation = Base.Rotation;

				//Set bBlockActors to false so bHardAttach works as expected.
				if(!Base.bStatic)
				{
					SetCollision(default.bCollideActors, false, default.bIgnoreEncroachers);
				}

				/*SMC = SkeletalMeshComponent(Base.CollisionComponent);

				if(SMC != none && BaseSkelComponent != SMC)
				{
					SMCBoneName = SMC.FindClosestBone(Location);

					if(SMCBoneName != '')
					{
						SetBase(Base,, SMC, SMCBoneName);
					}
				}*/
			}
		}
	}
	else
	{
		bCollideWorld = default.bCollideWorld;
		SetCollision(default.bCollideActors, default.bBlockActors, default.bIgnoreEncroachers);
		SetPhysics(PHYS_Falling);
	}
}

/**
 * Remember the relative angle that the Sentinel landed on something, so it can later be rotated to appear fixed to it.
 */
simulated function Landed(Vector HitNormal, Actor FloorActor)
{
	local Rotator R;
	local Vector X, Y, Z;

	super.Landed(HitNormal, FloorActor);

	//TODO: Translate down so base is visually sitting on the ground.
	Z = HitNormal;
	X = Vector(Rotator(HitNormal) + rot(-16384, 0, 0));
	Y = Z cross X;
	R = OrthoRotation(X, Y, Z);

	if(Z.Z != 0.0)
	{
		R = class'Rx_Sentinel_Utils'.static.RotateRelative(R, 0.0, (BaseComponent.Rotation.Yaw - R.Yaw) * (Abs(Z.Z) / Z.Z), 0.0);
	}

	OriginalBaseRotation = FloorActor.Rotation; //Note that this doesn't always work, so it's set in BaseChange. That means that it probably doesn't actually need to be set here too, I just can't be arsed to test it.
	OriginalRotation = R;
	InitializeAutoRotateYaw();

	bForceNetUpdate = true;
}

simulated function bool CanBeBaseForPawn(Pawn APawn)
{
	//Never allow Sentinels to stack.
	if(Rx_Sentinel(APawn) != none)
		return false;

	return bCanBeBaseForPawns;
}

function JumpOffPawn()
{
	//Don't jump off vehicles.
	if(Vehicle(Base) != none)
		return;

	Velocity += (100 + CylinderComponent.CollisionRadius) * VRand();
	Velocity.Z = 200 + CylinderComponent.CollisionHeight;
	SetPhysics(PHYS_Falling);
}

function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	//Sentinels and water do not mix.
	if(NewVolume.bWaterVolume)
	{
		PlaySound(SplashSound);

		//If no controller, destroy immediately (happens if initially spawned in water).
		if(Controller == none)
			Destroy();
		else
			Died(none, none, Location);
	}
}

//No movement physics
function SetMovementPhysics(){}

simulated function Rotator GetViewRotation()
{
	return CurrentAim;
}

simulated function Vector GetPawnViewLocation()
{
	return Location;
}

//Find camera location and rotation for when viewing this Sentinel.
simulated function bool CalcCamera(float DeltaTime, out Vector CamLoc, out Rotator CamRot, out float FOV)
{
	local Vector DesiredCamLoc;
	local Rotator DesiredCamRot;
	local Vector HitLocation, HitNormal;
	local bool bResult;

	WeaponComponent.GetSocketWorldLocationAndRotation(SWeapon.CameraSocketName, CamLoc, CamRot);
	DesiredCamLoc = CamLoc;
	DesiredCamRot = CamRot;

	if(Trace(HitLocation, HitNormal, DesiredCamLoc, CamLoc, false, vect(12.0, 12.0, 12.0)) != none)
	{
		DesiredCamLoc = HitLocation;
		bResult = false;
	}
	else
	{
		bResult = true;
	}

	CamLoc = DesiredCamLoc;
	CamRot = DesiredCamRot;

	return bResult;
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if(super.HealDamage(Amount, Healer, DamageType))
	{
		RepHealth = Health;
		UpdateDamageEffects();

		return true;
	}

	return false;
}

function TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int OriginalDamage;

	if(Role < ROLE_Authority || Health <= 0 || Controller.IsInState('Spawning') || bDeleteMe)
		return;

	OriginalDamage = Damage;

	//Treat Sentinel as a vehicle for damage scaling.
	Damage *= DamageType.default.VehicleDamageScaling;
	//A fraction of damage is absorbed by the Sentinel's standard armour.
	Damage *= SentinelDamageScaling;

//	//Prevent owner from causing damage in non-team games.
//	if(InstigatorController != none && InstigatedBy == InstigatorController)
//		Damage = 0;

	//Let upgrades modify damage, or spawn effects.
	UpgradeManager.NotifyTakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	if((WorldInfo.TimeSeconds - LastDamageEffectTime) > MinDamageEffectInterval && OriginalDamage > 0)
	{
		LastTakeHitInfo.Damage = Damage;
		LastTakeHitInfo.HitLocation = HitLocation;
		LastTakeHitInfo.DamageType = DamageType;
		LastDamageEffectTime = WorldInfo.TimeSeconds;

		PlayTakeHitEffects();
	}

	RepHealth = Health;
	UpdateDamageEffects();
}

//Overriden to make HitLocation more meaningful.
simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
)
{
	local float		ColRadius, ColHeight;
	local float		DamageScale, Dist;
	local Vector	Dir;
	local Vector	HitLocation, HitNormal;


	GetBoundingCylinder(ColRadius, ColHeight);

	Dir	= Location - HurtOrigin;
	Dist = VSize(Dir);
	Dir	= Normal(Dir);

	if ( bFullDamage )
	{
		DamageScale = 1;
	}
	else
	{
		Dist = FClamp(Dist - ColRadius, 0.f, DamageRadius);
		DamageScale = 1 - Dist/DamageRadius;
	}

	if (DamageScale > 0.f)
	{
		if(WorldInfo.Trace(HitLocation, HitNormal, Location, HurtOrigin, true,,, TRACEFLAG_Bullet) == none)
		{
			HitLocation = Location - 0.5 * (ColHeight + ColRadius) * Dir;
		}

		TakeDamage
		(
			DamageScale * BaseDamage,
			InstigatedBy,
			HitLocation,
			(DamageScale * Momentum * Dir),
			DamageType,,
			DamageCauser
		);
	}
}

simulated function PlayTakeHitEffects()
{
	if(EffectIsRelevant(LastTakeHitInfo.HitLocation, false, 4000.0))
	{
		PlaySound(DamageSound, true,,, LastTakeHitInfo.HitLocation);
		//TODO: Fix hard-coded template.
		//WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'KismetExamples.PS_HitEffect', LastTakeHitInfo.HitLocation, Rotator(LastTakeHitInfo.HitLocation - Location));
	}
}

/**
 * Applies appropriate amount of damage effect to the skins.
 */
simulated function UpdateDamageEffects()
{
	local float DamageScale;
	local Rx_SentinelComponent_ParticleSystem_Damage DamagePSC;

	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		DamageScale = RepHealth;
		DamageScale /= default.Health;
		DamageScale = 1.0 - DamageScale;

		BaseComponent.UpdateDamageEffects(DamageScale);
		RotatorComponent.UpdateDamageEffects(DamageScale);
		WeaponComponent.UpdateDamageEffects(DamageScale);

		foreach DamageParticleComponents(DamagePSC)
		{
			DamagePSC.CheckDamage();
		}
	}
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if(bDeleteMe || WorldInfo.Game == none || WorldInfo.Game.bLevelChange)
	{
		return false;
	}

	if(Killer != none)
	{
		Killer = Killer;//.GetKillerController(); // I don't understand this...
	}

	SetTarget(none);

	if(UpgradeManager != none)
	{
		UpgradeManager.NotifyDied(Killer, DamageType, HitLocation);
		UpgradeManager.Destroy();
	}

//	if(Killer != none && DamageType != class'DmgType_Suicided')
//	{
//		HurtRadius(DiedDamage, DiedDamageRadius, DiedDamageType, DiedMomentum, GetPawnViewLocation(),, InstigatorController);
//	}

	Health = Min(0, Health);

	PlayDying(DamageType, HitLocation);

	return true;
}

/** Return false because... I can't remember, lol. */
simulated function bool IsPlayerPawn()
{
	return false;
}

//Includes not only pawns on the same team, but also this Sentinel's owner and their other Sentinels, and unnocupied UTVehicles assigned to the same team.
simulated function bool IsSameTeam(Pawn Other)
{
	local bool bSameTeam;
//	local Rx_Sentinel S;
//	local UTVehicle UTV;

	bSameTeam = super.IsSameTeam(Other);

//	if(!bSameTeam)
//	{
//	//	bSameTeam = Other.Controller == InstigatorController;
//
//		if(!bSameTeam)
//		{
//			S = Sentinel(Other);
//
//			if(S != none)
//			{
//				bSameTeam = S.InstigatorController == InstigatorController;
//			}
//			else
//			{
//				UTV = UTVehicle(Other);
//
//				if(UTV != none && UTV.Team != 255)
//				{
//					bSameTeam = UTV.Team == GetTeamNum();
//				}
//			}
//		}
//	}

	return bSameTeam;
}

//Return false otherwise bots always aim at origin, which is on the floor or ceiling.
function bool IsStationary()
{
	return false;
}

function bool IsInvisible()
{
	return bIsInvisible;
}

function float AdjustedStrength()
{
	local float Strength;

	//Bots overestimate Sentinel strength due to high health, so reduce it here.
	Strength = (-0.005 * float(Health + HealthMax)) + 2.0;

	if(Target == none)
	{
		Strength -= 0.5;
	}

	UpgradeManager.AdjustStrength(Strength);

	return Strength;
}

/**
 * Passes on to the weapon to allow it to handle weapon mesh animations.
 */
simulated function PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	if(SkelComp == WeaponComponent)
	{
		SWeapon.PostInitAnimTree(SkelComp);
	}
}

/**
 * Passes on to the weapon to allow it to handle weapon mesh animations.
 */
simulated function OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	if(SeqNode != None)
	{
		if(SeqNode.SkelComponent == WeaponComponent)
		{
			SWeapon.OnAnimEnd(SeqNode, PlayedTime, ExcessTime);
		}
	}
}

simulated function Tick(float DeltaTime)
{
//	if(Role == ROLE_Authority && (InstigatorController == none || (WorldInfo.GRI.GameClass.default.bTeamGame && !WorldInfo.GRI.OnSameTeam(self, InstigatorController))))
//	{
//		//Don't hang around if owner gone or changed team.
//		RemoveFromGame();
//	}
//	else if(Base != none)
//	{
	if(target != none) {	
		CalculateRotation(DeltaTime);
		DoRotation();
		AdjustRotationSounds(DeltaTime);
	}
//	}
}



/**
 * Sets pitch and volume of rotation sounds based on rotation speed.
 */
simulated function AdjustRotationSounds(float DeltaTime)
{
	PitchSoundComponent.AdjustRotationSounds(DeltaTime, DeltaRotation.Pitch);
	YawSoundComponent.AdjustRotationSounds(DeltaTime, DeltaRotation.Yaw);
}

/**
 * Calculates rotation needed to reach desired rotation, with damping, and applies it to CurrentAim.
 * Also sets BoneSpaceLastAim and DeltaRotation.
 *
 * @param	DeltaTime	time in seconds since rotation last calculated
 */
simulated function CalculateRotation(float DeltaTime)
{
	local Vector WorldSpaceLocation, BoneSpaceLocation; //Dummy variables, don't use.
	local Rotator BoneSpaceDesiredAim, BoneSpaceCurrentAim;
	local Rotator BoneSpaceDelta;
	local Vector X, Y, Z;
	/*local Vector DebugLineStart;

	DebugLineStart = GetPawnViewLocation();
	DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(Rotation) * 128), 0, 0, 255);
	DebugLineStart += vect(0.0, 0.0, 2.0) >> Rotation;
	DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(CurrentAim) * 128), 255, 0, 0);
	DebugLineStart += vect(0.0, 0.0, 2.0) >> Rotation;
	DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(DesiredAim) * 128), 0, 255, 0);*/

	if(SWeapon == none || !SWeapon.bCanRotate)
	{
		DesiredAim = CurrentAim;
	}
	else if(!bTracking)
	{
		CalculateAutoRotateYaw(DeltaTime);
		DesiredAim = class'Rx_Sentinel_Utils'.static.RotateRelative(BaseComponent.Rotation, 0, AutoRotateYaw, 0);
	}

	DesiredAim = Normalize(DesiredAim);

	//Calculate actual change in rotation in Sentinel's local space, then convert back to world space rotation.
	BaseComponent.TransformToBoneSpace(BaseComponent.RootBone, WorldSpaceLocation, DesiredAim, BoneSpaceLocation, BoneSpaceDesiredAim);
	BoneSpaceDelta = Normalize(BoneSpaceDesiredAim - BoneSpaceLastAim); //Use rotation from last tick to account for any change in base rotation since then.
	BoneSpaceDelta.Pitch = MaxRotationSpeed.Pitch * FClamp(BoneSpaceDelta.Pitch / RotationDampingThreshold, -1.0, 1.0) * DeltaTime;
	BoneSpaceDelta.Yaw = MaxRotationSpeed.Yaw * FClamp(BoneSpaceDelta.Yaw / RotationDampingThreshold, -1.0, 1.0) * DeltaTime;
	BoneSpaceCurrentAim = Normalize(BoneSpaceLastAim + BoneSpaceDelta);
	BoneSpaceCurrentAim.Pitch = Clamp(BoneSpaceCurrentAim.Pitch, MinPitch, MaxPitch); //Limit pitch.
	BaseComponent.TransformFromBoneSpace(BaseComponent.RootBone, BoneSpaceLocation, BoneSpaceCurrentAim, WorldSpaceLocation, CurrentAim);

	//Make DeltaRotation be equal to the change in rotation in the Sentinel's local space (used for rotation sounds).
	DeltaRotation = Normalize(BoneSpaceCurrentAim - BoneSpaceLastAim);

	BoneSpaceLastAim = BoneSpaceCurrentAim;

	//Add roll to current aim.
	X = Vector(CurrentAim);
	Z = vect(0.0, 0.0, 1.0) >> BaseComponent.Rotation;
	Y = Z cross X;
	CurrentAim = OrthoRotation(X, Y, Z);
}

/**
 * Sets AutoRotateYaw to whatever value is needed to yaw the current aim.
 */
simulated function InitializeAutoRotateYaw()
{
	local Vector BoneSpaceLocation; //Dummy variable, don't use.
	local Rotator AutoRotateRotation;

	BaseComponent.TransformToBoneSpace(BaseComponent.RootBone, vect(0.0, 0.0, 0.0), DesiredAim, BoneSpaceLocation, AutoRotateRotation);
	AutoRotateYaw = AutoRotateRotation.Yaw;
}

/**
 * Determines yaw while idle. By default it just rotates clockwise continuously, but limits can be set so it pans back and forth across a specific range.
 */
simulated function CalculateAutoRotateYaw(float DeltaTime)
{
	AutoRotateYaw += (bAutoRotateYawReversed ? -AutoRotateRate : AutoRotateRate) * DeltaTime;

	if(NormalizeRotAxis(AutoRotateYaw - AutoRotateCentre) < -AutoRotateHalfRange)
	{
		AutoRotateYaw = -AutoRotateHalfRange + AutoRotateCentre;
		bAutoRotateYawReversed = false;
	}
	else if(NormalizeRotAxis(AutoRotateYaw - AutoRotateCentre) > AutoRotateHalfRange)
	{
		AutoRotateYaw = AutoRotateHalfRange + AutoRotateCentre;
		bAutoRotateYawReversed = true;
	}
}

/**
 * Rotates various components to visually match actual aim.
 * Controller's view is somehow locked to pawn's rotation, so rotate whole pawn, and rotate components separately so they appears to stay still.
 */
simulated function DoRotation()
{
	local Rotator R;
	local Vector X, Y, Z;

	//Set pawn's rotation.
	SetRelativeRotation(CurrentAim - Base.Rotation);

	//Set BaseComponent rotation so that it is fixed relative to the current Base.
	//Note that all of these Components are set to absolute rotation.
	R = Base.Rotation - OriginalBaseRotation;
	R = class'Rx_Sentinel_Utils'.static.RotateRelative(R, 0, OriginalRotation.Yaw - OriginalBaseRotation.Yaw, 0);
	R.Yaw -= OriginalRotation.Yaw - OriginalBaseRotation.Yaw;
	R += OriginalRotation;
	BaseComponent.SetRotation(R);
	BaseComponent.SetTranslation(BaseComponent.default.Translation >> R);

	X = class'Rx_Sentinel_Utils'.static.ClosestPointToPlane(Vector(CurrentAim), BaseComponent.Rotation);
	Z = vect(0.0, 0.0, 1.0) >> BaseComponent.Rotation;
	Y = Z cross X;
	RotatorComponent.SetRotation(OrthoRotation(X, Y, Z));
	RotatorComponent.SetTranslation(RotatorComponent.default.Translation >> R);

	//WeaponComponent simply pointed in direction of CurrentAim.
	WeaponComponent.SetRotation(CurrentAim);
	WeaponComponent.SetTranslation(WeaponComponent.default.Translation >> R);
}

/**
 * Sets which actor the Sentinel is currently interested in.
 *
 * @param	NewTarget		actor this Sentinel is considered to be attacking
 * @param	NewTargetName	human readable name for the new target
 */
function SetTarget(Actor NewTarget, optional string NewTargetName)
{
	local Actor OldTarget;

	OldTarget = Target;
	Target = NewTarget;
	TargetName = NewTargetName;

	if(NewTarget != none)
	{
		bTracking = true;

		if(NewTarget != OldTarget)
		{
			UpgradeManager.NotifyNewTarget(NewTarget);

			if(TargetingSound != none)
			{
				PlaySound(TargetingSound,,,, GetPawnViewLocation());
				MakeNoise(0.3);
			}

			NetUpdateFrequency = 50;
			bForceNetUpdate = true;
		}
	}
	else
	{
		NetUpdateFrequency = default.NetUpdateFrequency;
		InitializeAutoRotateYaw();
		DesiredAim = CurrentAim;
		bTracking = false;
	}
}

/**
 * Sets Sentinel to idle.
 */
function SetWaiting()
{
	SetTarget(none);
	UpgradeManager.NotifyWaiting();

	if(WaitingSound != none)
	{
		PlaySound(WaitingSound,,,, GetPawnViewLocation());
		MakeNoise(0.3);
	}
}

/**
 * Determines if the pawn can be detected by current senses.
 *
 * @param	P	pawn to check
 * @return	true if pawn is visible, or upgrades can detect it.
 */
function bool CanDetect(Pawn P)
{
	//return !P.IsInvisible() || UpgradeManager.CanDetect(P);
	return true;
}

/**
 * Fire weapon at something.
 *
 * @param	Spot	location to attempt to fire at
 * @return	false if target outside cone of fire or out of range, true otherwise
 */
function bool FireAt(Vector Spot)
{
	local Vector Origin;
	local bool bFired;
	local Rotator CurrentAimNoRoll;

	//Roll removed because RDiff counts it as a rotation difference, for which roll is not important here.
	//If weapon doesn't pitch, assume it can hit no matter what the pitch difference (Grenade Launcher, Multi-Mortar).
	CurrentAimNoRoll.Pitch = (MinPitch == MaxPitch) ? DesiredAim.Pitch : CurrentAim.Pitch;
	CurrentAimNoRoll.Yaw = CurrentAim.Yaw;
	if(RDiff(DesiredAim, CurrentAimNoRoll) <= SWeapon.GetMaxAimError())
	{
        Origin = GetPawnViewLocation();

		if(VSize(Spot - Origin) <= GetRange())
		{
			if(SWeapon.FireAt(Origin, CurrentAim, Spot))
			{
				UpgradeManager.NotifyFired();
				bForceNetUpdate = true;
				bFired = true;
			} else {
				bFired = false;
			}			
		}
	}

	return bFired;
}

/**
 * Returns the largest distance that a target could possibly be attacked at.
 */
function float GetRange()
{
	return SWeapon.bCanFireBlind ? SWeapon.FireInfo.MaxRange : FMin(SightRadius, SWeapon.FireInfo.MaxRange);
}

/**
 * Returns the minimal distance to owner that a target could possibly be attacked at.
 */
function bool IsOutsideMinimalDistToOwner(Pawn possibleTarget)
{
	return true;
}

function bool IsVisibleFromGuns(Pawn possibleTarget)
{
	return true;
}


/**
 * Determines how much ammo this Sentinel might yield if recycled.
 *
 * @return	the proportion of remaining health times Sentinel cost, plus the value of all upgrades, minus the cost of the default weapon, minus the cost of any default upgrades still applied.
 */
function int AmmoValue()
{
	local int value;
	local class<Rx_SentinelUpgrade> UpgradeClass;

	value = AmmoCost * Health / default.Health;
	value += UpgradeManager.AmmoValue();
	value -= DefaultWeaponClass.default.AmmoCost;

	foreach DefaultUpgradeClasses(UpgradeClass)
	{
		if(UpgradeManager.HasUpgrade(UpgradeClass))
		{
			value -= UpgradeClass.default.AmmoCost;
		}
	}

	return value;
}

/**
 * Draws an icon on the map. The icon has a light background when drawn for the owner, and a dark background when drawn for anyone else.
 */
simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner)
{
	local LinearColor DrawColour;
	local Vector HUDLocation;

	HUDLocation = MP.UpdateHUDLocation(Location);

	//DrawColour = (PlayerOwner == InstigatorController) ? MakeLinearColor(1.0, 1.0, 1.0, 0.6) : MakeLinearColor(0.0, 0.0, 0.0, 0.6);
	MP.DrawRotatedTile(Canvas, IconHudTexture, HUDLocation, CurrentAim.Yaw + 16384, IconScale * 1.05, IconCoords, DrawColour);

	DrawColour = TeamColour;
	DrawColour.A = 0.6;
	MP.DrawRotatedTile(Canvas, IconHudTexture, HUDLocation, CurrentAim.Yaw + 16384, IconScale, IconCoords, DrawColour);
}

/**
 * Generates text giving status of the Sentinel and its upgrades.
 *
 * @param	StatusStrings	status
 */
simulated function array<String> GetStatusText()
{
	local array<string> StatusStrings;
	local string StatusLine;

	//Sentinel type.
	StatusLine = class'Rx_Sentinel_UIStrings'.default.SentinelClass$": ";
	class'Rx_Sentinel_Utils'.static.PadWithSpaces(StatusLine, 15);
	StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(0.0, 0.8, 1.0);
	StatusLine $= MenuName;
	StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 1.0, 1.0);
	StatusStrings[StatusStrings.Length] = StatusLine;

	//UID.
	StatusLine = class'Rx_Sentinel_UIStrings'.default.UID$": ";
	class'Rx_Sentinel_Utils'.static.PadWithSpaces(StatusLine, 15);
	StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(0.0, 0.8, 1.0);
	StatusLine $= UID;
	StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 1.0, 1.0);
	StatusStrings[StatusStrings.Length] = StatusLine;

	//Owning player's name.
	StatusLine = class'Rx_Sentinel_UIStrings'.default.Owner$": ";
	class'Rx_Sentinel_Utils'.static.PadWithSpaces(StatusLine, 15);

	StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 0.0, 0.0);
	StatusLine $= "<Strings:UTGameUI.Generic.None>";

	StatusLine = StatusLine$class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 1.0, 1.0);
	StatusStrings[StatusStrings.Length] = StatusLine;

	//Health.
	StatusLine = class'Rx_Sentinel_UIStrings'.default.Condition$": ";
	class'Rx_Sentinel_Utils'.static.PadWithSpaces(StatusLine, 15);
	StatusLine $= class'Rx_Sentinel_Utils'.static.RedGreenTextColourMarkup(Health, HealthMax);
	StatusLine $= int((float(Health) / float(HealthMax)) * 100.0)$"%";
	StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 1.0, 1.0);
	StatusStrings[StatusStrings.Length] = StatusLine;

	//Current target.
	StatusLine = class'Rx_Sentinel_UIStrings'.default.Target$": ";
	class'Rx_Sentinel_Utils'.static.PadWithSpaces(StatusLine, 15);

	if(bTracking)
	{
		if(TargetName != "")
		{
			StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 0.0, 0.0);
			StatusLine $= TargetName;
		}
		else
		{
			StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 0.5, 0.0);
			StatusLine $= class'Rx_Sentinel_UIStrings'.default.Scanning$": ";
		}
	}
	else
	{
		StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(0.0, 1.0, 0.0);
		StatusLine $= "<Strings:UTGameUI.Generic.None>";
	}

	StatusLine $= class'Rx_Sentinel_Utils'.static.TextColourMarkup(1.0, 1.0, 1.0);
	StatusStrings[StatusStrings.Length] = StatusLine;

	//Allow upgrades to add lines.
	if(UpgradeManager != none)
	{
		UpgradeManager.GetStatusText(StatusStrings);
	}

	return StatusStrings;
}

simulated function TornOff()
{
	if(!bPlayedDeath)
	{
		PlayDying(HitDamageType, TakeHitLocation);
	}
}

simulated function PlayDying(class<DamageType> DamageType, Vector HitLoc)
{
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	HitDamageType = DamageType;
	TakeHitLocation = HitLoc;

	if(ExplosionEffectComponent != none && ExplosionEffectComponent.Explode(DamageType))
	{
		//Break off components as gibs only if the one "above" has broken off, so no parts are left floating.
		if(WeaponComponent.TurnToGib(BaseComponent.Rotation))
		{
			if(RotatorComponent.TurnToGib(BaseComponent.Rotation))
			{
				BaseComponent.TurnToGib(BaseComponent.Rotation);
			}
		}
	}
	else
	{
		DeadLifeSpan = BurnTime; //Burn out immediately if didn't explode.
	}

	PitchSoundComponent.Stop();
	YawSoundComponent.Stop();
	GotoState('Dying');
}

simulated State Dying
{
ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		SetPhysics(PHYS_None); //Physics set in super, reset it here.
		LifeSpan = DeadLifeSpan;
		PlayBurnEffect();
	}

	//Overriden to prevent physics from being set.
	function TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){}

	//Don't need to do anything once dead.
	simulated function Tick(float DeltaTime){}
	function InitializeFor(Pawn Placer){}
	simulated event SetInitialState(){}

	/**
	 * Applies "burn out" skin.
	 */
	simulated function PlayBurnEffect()
	{
		local float BurnStartTime;

		BaseComponent.PlayBurnEffect();
		RotatorComponent.PlayBurnEffect();
		WeaponComponent.PlayBurnEffect();

		BurnStartTime = DeadLifeSpan - BurnTime;

		if(BurnStartTime > 0)
			SetTimer(BurnStartTime, false, 'DisableCollision');
		else
			DisableCollision();
	}

	/**
	 * Disables collision and starts components burning out.
	 */
	simulated function DisableCollision()
	{
		SetCollision(false);
		BaseComponent.StartBurn();
		RotatorComponent.StartBurn();
		WeaponComponent.StartBurn();
	}
}

simulated function Destroyed()
{
	loginternal("Sentinel destroyed...");
	if(UpgradeManager != none)
	{
		UpgradeManager.Destroy();
	}

	super.Destroyed();
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	super.DisplayDebug(HUD, out_YL, out_YPos);

	HUD.Canvas.SetDrawColor(255, 255, 0);
	HUD.Canvas.SetPos(4, out_YPos);

	HUD.Canvas.DrawText("Rotation:"@Rotation);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("OriginalRotation:"@OriginalRotation);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("Base.Rotation:"@Base.Rotation);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("OriginalBaseRotation:"@OriginalBaseRotation);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("DesiredAim:"@DesiredAim);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("CurrentAim:"@CurrentAim);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("BaseComponent:"@BaseComponent.Rotation);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("AutoRotateYaw:"@AutoRotateYaw);
	out_YPos += out_YL;

	HUD.Canvas.DrawText("Physics:"@Physics);
	out_YPos += out_YL;

	UpgradeManager.DisplayDebug(HUD, out_YL, out_YPos);
}

defaultproperties
{
	bAmbientCreature=true // So AIs will ignore me. Instead they will attack/repair the Building i´m attached to
	
	//IconHudTexture=Texture2D'Sentinel_Resources.Textures.UI.T_Icon_Sentinel_Floor'
	IconCoords=(U=0,V=0,UL=128,VL=128)
	IconScale=0.2

	SpawnInTime=2.0
	DeadLifeSpan=7.0
	BurnTime=3.5

	SentinelDamageScaling=1.0 //TODO: Probably want a fairly substantial reduction in damage. Needs experimentation.
	DamageSound=SoundCue'A_Gameplay.Gameplay.A_Gameplay_ArmorHitCue'
	MinDamageEffectInterval=0.15

	MaxRotationSpeed=(Pitch=20000,Yaw=20000)
	RotationDampingThreshold=2048
	AutoRotateRate=3000
	AutoRotateHalfRange=32768
	AutoRotateCentre=0
	MaxPitch=8192
	MinPitch=-8192

	SightRadius=7000.0
	PeripheralVision=0.71 //90 degree FOV
	HearingThreshold=1500.0
	//Alertness=0.0 //TODO: Find out if this is something useful to set.

	DiedDamage=0
	DiedDamageRadius=0
	DiedMomentum=0
	DiedDamageType=None

	// Sound of turret hitting water
	SplashSound=SoundCue'RX_SoundEffects.FootSteps.Water.SC_Land_Water'

	AmmoCost=100
	bUpgradeable=true
	bTeamUpgradeable=true
	UpgradeManagerClass=class'Rx_SentinelUpgradeManager'
	ControllerClass=class'Rx_SentinelController'

	TargetingSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_WarningCue' // SENTINELFIXME
	WaitingSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_EjectReadyBeep_Cue' // SENTINELFIXME

	bCountsTowardLimit=true

	//LRIClass=class'UTLRI_Sentinel'

	Physics=PHYS_None //Physics should be set by whatever spawns the Sentinel.
	Mass=1000.0

	bHardAttach=true
	bPushedByEncroachers=false
	bStationary=true
	bDestroyInPainVolume=false
	bIgnoreForces=true
	bJumpCapable=false
	bCanJump=false
	bCanWalk=false
	bCanSwim=false
	bCanFly=false
	bCanClimbLadders=false
	bCanStrafe=false
	//bCanUse=false
	bMuffledHearing=false
	bCanBeBaseForPawns=true
	bBlocksTeleport=true

	NetUpdateFrequency=10
	bNetInitialRotation=true
	bOnlyDirtyReplication=true
	bAlwaysRelevant=true //Costs a little bandwidth, but saves a lot of headaches.

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		AmbientGlow=(R=0.1,G=0.1,B=0.1,A=1.0)
		bDynamic=false
		bForceNonCompositeDynamicLights=True
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Name=CollisionCylinder
		CollisionRadius=34.0
		CollisionHeight=32.0
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=false
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object

	Begin Object Class=Rx_SentinelComponent_Mesh Name=BaseComponent0
		SpawnEffectCompleted=BaseSpawned
		LightEnvironment=MyLightEnvironment
	End Object
	BaseComponent=BaseComponent0
	Mesh=BaseComponent0 //Mesh needs to be set to something otherwise the Fury crashes when it locks its weapon (BeamLockOn assumes mesh is not none).
	Components.Add(BaseComponent0)

	Begin Object Class=Rx_SentinelComponent_Mesh Name=RotatorComponent0
		DeadExplodeForce=(X=32.0,Y=32.0,Z=64.0)
		DeadExplodeAngular=32.0
		LightEnvironment=MyLightEnvironment
	End Object
	RotatorComponent=RotatorComponent0
	Components.Add(RotatorComponent0)

	Begin Object Class=Rx_SentinelComponent_Mesh Name=WeaponComponent0
		RootBone=Weapon
		DeadExplodeForce=(X=256.0,Y=256.0,Z=1024.0)
		DeadExplodeAngular=128.0
		LightEnvironment=MyLightEnvironment
	End Object
	WeaponComponent=WeaponComponent0
	Components.Add(WeaponComponent0)

	Begin Object Class=Rx_SentinelComponent_RotationSound Name=RotationSoundComponent0
	End Object
	PitchSoundComponent=RotationSoundComponent0
	Components.Add(RotationSoundComponent0)

	Begin Object Class=Rx_SentinelComponent_RotationSound Name=RotationSoundComponent1
	End Object
	YawSoundComponent=RotationSoundComponent1
	Components.Add(RotationSoundComponent1)

	Begin Object Class=Rx_SentinelComponent_ExplosionEffects Name=ExplosionEffectComponent0		
	End Object
	ExplosionEffectComponent=ExplosionEffectComponent0
	Components.Add(ExplosionEffectComponent0)

	Components.Remove(Sprite)
}
