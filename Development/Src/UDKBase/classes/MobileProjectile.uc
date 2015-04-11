/**
 * This is our base mobile projectile class.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class MobileProjectile extends Projectile;

/** Acceleration magnitude. By default, acceleration is in the same direction as velocity. */
var(Projectile) float AccelRate;

/** if true, the shutdown function has been called and 'new' effects shouldn't happen */
var bool bShuttingDown;

/** 
 * If TRUE, initializes the projectile immediately when spawned using it rotation.
 * This is required if you use an Actor Factory in Kismet to spawn the projectile.
 */
var(Projectile) bool bInitOnSpawnWithRotation;

/** Effects */
/** This is the effect that is played while in flight */
var ParticleSystemComponent	ProjEffects;

/** Effects Template */
/** Effect template for the projectile while it is in flight. */
var(Projectile) ParticleSystem ProjFlightTemplate;
/** Effect template when the projectile explodes.  Projectile only explodes if Damage Radius is non-zero. */
var(Projectile) ParticleSystem ProjExplosionTemplate;

/** This value sets the cap how far away the explosion effect of this projectile can be seen */
var(Projectile) float MaxEffectDistance;

/**  The sound that is played when it explodes.  Projectile only explodes if Damage Radius is non-zero. */
var(Projectile) SoundCue	ExplosionSound;

/** Actor types to ignore if the projectile hits them */
var(Projectile) array<class<Actor> >	ActorsToIgnoreWhenHit;

/** used to prevent effects when projectiles are destroyed (see LimitationVolume) */
var bool bSuppressExplosionFX;

/**
 * Explode when the projectile comes to rest on the floor.  It's called from the native physics processing functions.  By default,
 * when we hit the floor, we just explode.
 */
simulated event Landed( vector HitNormal, actor FloorActor )
{
	HitWall(HitNormal, FloorActor, None);
}

/**
 * When this actor begins its life, play any ambient sounds attached to it
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bDeleteMe || bShuttingDown)
		return;

	// Spawn any effects needed for flight
	SpawnFlightEffects();

	if (bInitOnSpawnWithRotation)
	{
		Init( vector(Rotation) );
	}
}

simulated event SetInitialState()
{
	bScriptInitialized = true;
	if (Role < ROLE_Authority && AccelRate != 0.f)
	{
		GotoState('WaitingForVelocity');
	}
	else
	{
		GotoState((InitialState != 'None') ? InitialState : 'Auto');
	}
}

/**
 * Initialize the Projectile
 */
function Init(vector Direction)
{
	SetRotation(rotator(Direction));

	Velocity = Speed * Direction;
	Acceleration = AccelRate * Normal(Velocity);
}

/**
 *
 */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{

	if( ActorsToIgnoreWhenHit.Find(Other.Class) != INDEX_NONE )
	{
		// The hit actor is one that should be ignored
		return;
	}


	if (DamageRadius > 0.0)
	{
		Explode(HitLocation, HitNormal);
	}
	else
	{
		PlaySound(ImpactSound);
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		Shutdown();
	}
}

/**
 * Explode this Projectile
 */
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (Damage>0 && DamageRadius>0)
	{
		if ( Role == ROLE_Authority )
			MakeNoise(1.0);
		if ( !bShuttingDown )
		{
			ProjectileHurtRadius(HitLocation, HitNormal);
		}
		SpawnExplosionEffects(HitLocation, HitNormal);
	}
	else 
	{
		PlaySound(ImpactSound);
	}

	ShutDown();
}


/**
 * Spawns any effects needed for the flight of this projectile
 */
simulated function SpawnFlightEffects()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjFlightTemplate != None)
	{
		ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate, true);
		ProjEffects.SetAbsolute(false, false, false);
		ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
		ProjEffects.bUpdateComponentInTick = true;
		ProjEffects.SetTickGroup(TG_EffectsUpdateWork);
		AttachComponent(ProjEffects);
		ProjEffects.ActivateSystem(true);
	}

	if (SpawnSound != None)
	{
		PlaySound(SpawnSound);
	}
}

/** sets any additional particle parameters on the explosion effect required by subclasses */
simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion);

/**
 * Spawn Explosion Effects
 */
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ParticleSystemComponent ProjExplosion;
	local Actor EffectAttachActor;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (EffectIsRelevant(Location, false, MaxEffectDistance))
		{
			if (ProjExplosionTemplate != None)
			{
				EffectAttachActor = ImpactedActor;
				ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(HitNormal), EffectAttachActor);
				SetExplosionEffectParameters(ProjExplosion);
			}

			if (ExplosionSound != None)
			{
				PlaySound(ExplosionSound, true);
			}
		}

		bSuppressExplosionFX = true; // so we don't get called again
	}
}

/**
 * Clean up
 */
simulated function Shutdown()
{
	local vector HitLocation, HitNormal;

	bShuttingDown=true;
	HitNormal = normal(Velocity * -1);
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));

	SetPhysics(PHYS_None);

	if (ProjEffects!=None)
	{
		ProjEffects.DeactivateSystem();
	}

	HideProjectile();
	SetCollision(false,false);

	Destroy();
}

// If this actor

event TornOff()
{
	ShutDown();
	Super.TornOff();
}

/**
 * Hide any meshes/etc.
 */
simulated function HideProjectile()
{
	local MeshComponent ComponentIt;
	foreach ComponentList(class'MeshComponent',ComponentIt)
	{
		ComponentIt.SetHidden(true);
	}
}

simulated function Destroyed()
{
	if (ProjEffects != None)
	{
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects = None;
	}

	super.Destroyed();
}

simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC == ProjEffects)
	{
		// clear component and return to pool
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects = None;
	}
}

/** state used only on the client for projectiles with AccelRate > 0 to wait for Velocity to be replicated so we can use it to set Acceleration
 *	the alternative would be to make Velocity repnotify in Actor.uc, but since many Actors (such as Pawns) change their
 *	velocity very frequently, that would have a greater performance hit
 */
state WaitingForVelocity
{
	simulated function Tick(float DeltaTime)
	{
		if (!IsZero(Velocity))
		{
			Acceleration = AccelRate * Normal(Velocity);
			GotoState((InitialState != 'None') ? InitialState : 'Auto');
		}
	}
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	out_CamLoc = Location + (CylinderComponent.CollisionHeight * Vect(0,0,1));
	return true;
}

/** called when this Projectile is the ViewTarget of a local player
 * @return the Pawn to use for rendering HUD displays
 */
simulated function Pawn GetPawnOwner();


defaultproperties
{
	Speed=2000
	MaxSpeed=5000
	AccelRate=15000

	Damage=10
	DamageRadius=0
	MomentumTransfer=500
	LifeSpan=2.0

	bCollideWorld=true
	DrawScale=2.0

	bInitOnSpawnWithRotation=true
	bShuttingDown=false
}