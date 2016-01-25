class Rx_Projectile_Grenade extends Rx_Projectile;

var float ArmTime;
var float BounceDamping;
var float BounceDampingZ;
var bool bExplodeOnPawnImpact;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(ArmTime+FRand()*0.5,false);                  // Grenade begins unarmed
	RandSpin(100000);
}

function Init(vector Direction)
{
    super.Init(Direction);

    TossZ = TossZ + (FRand() * TossZ / 2.0) - (TossZ / 4.0);
    Velocity.Z += TossZ;
    Acceleration = AccelRate * Normal(Velocity);
}

/** to make sure final location gets replicated : Testing to see if there is indeed a disconnect here that is the reason EMP nades don't always hit mines.
function ReplicatePositionAfterLanded()
{
	ForceNetRelevant();
	bUpdateSimulatedPosition = true;
	bNetDirty = true;   
}
*/

/**
 * Explode
 */
simulated function Timer()
{
	//ReplicatePositionAfterLanded();
	
	local vector ZOffsetLocation;
	
	ZOffsetLocation=location;
	
	ZOffsetLocation.z+=40; 

		
    Explode(ZOffsetLocation,vect(0,0,10)) ;// vect(0,0,1));
}


/**
 * When a grenade enters the water, kill effects/velocity and let it sink
 */
simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
    if ( WaterVolume(NewVolume) != none )
    {
        Velocity *= 0.15;
    }

    Super.PhysicsVolumeChange(NewVolume);
}


/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = false;

    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        PlaySound(ImpactSound, true);
    }

    // check to make sure we didn't hit a pawn

    if ( bExplodeOnPawnImpact && Pawn(Wall) != none && Wall != Instigator )
    {
		
		Explode(Location, HitNormal);
    }
	else
    {
        Velocity = BounceDamping*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
        Speed = VSize(Velocity);

        if (Velocity.Z > 400)
        {
            Velocity.Z = BounceDampingZ * (400 + Velocity.Z);
        }
        // If we hit a pawn or we are moving too slowly, explod

       /** if ( Speed < 20  )
        {
            ImpactedActor = Wall;
            SetPhysics(PHYS_None);
        }
		*/
    }
}

// Damage thru walls like C4
simulated function bool HurtRadius
(
	float				DamageAmount,
	float				InDamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	optional Actor		IgnoredActor,
	optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
	optional bool       bDoFullDamage
)
{
	local Pawn Victim;
	local bool bCausedDamage;
	//local TraceHitInfo HitInfo;

	// Prevent HurtRadius() from being reentrant.
	if ( bHurtEntry )
		return false;

	bHurtEntry = true;
	bCausedDamage = false;

	if ( (ImpactedActor != None) && (ImpactedActor != self) && Rx_Building(ImpactedActor) == None )
	{
		if(!TryHeadshot(ImpactedActor, HurtOrigin, Velocity, Damage)) {
			ImpactedActor.TakeRadiusDamage(InstigatedByController, DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, true, self);
		}
		bCausedDamage = ImpactedActor.bProjTarget;
	}

	foreach OverlappingActors( class'Pawn', Victim, DamageRadius, HurtOrigin, true) //foreach OverlappingActors( class'Pawn', Victim, DamageRadius, HurtOrigin, true)
	{
		if(Victim == ImpactedActor || GetTeamNum() == Victim.GetTeamNum() ) {
			continue;
		}
		if ( (Victim != IgnoredActor) && (Victim.bCanBeDamaged || Victim.bProjTarget) )
		{
			Victim.TakeRadiusDamage(InstigatedByController, DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, bDoFullDamage, self);
			bCausedDamage = bCausedDamage || Victim.bProjTarget;
		}
	}
	bHurtEntry = false;
	return bCausedDamage;
}

// Uncomment this if we don't want to projectile translate the hurt origin seeing as it hits thru walls.

simulated function bool ProjectileHurtRadius( vector HurtOrigin, vector HitNormal)
{
	//`log("PHR" @ HurtOrigin) ; 
	
	
	return super.ProjectileHurtRadius(HurtOrigin, HitNormal);
	
	//HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, AltOrigin);
}


DefaultProperties
{

    ImpactSound=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Bounce'

    ProjFlightTemplate=ParticleSystem'RX_WP_Grenade.Effects.P_Grenade_Frag'
	AmbientSound=SoundCue'RX_WP_Grenade.Sounds.SC_Grenade_Ambient'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Grenade',Sound=SoundCue'RX_WP_Grenade.Sounds.SC_Explosion_Grenade')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Grenade')

		
    DrawScale= 1.0
    
    Physics=PHYS_Falling
	
	CustomGravityScaling=1.0
    
    MyDamageType=class'Rx_DmgType_Grenade'
    
	bExplodeOnPawnImpact=false
	ArmTime=1.5
	BounceDamping=0.35
	BounceDampingZ=0.15
    TossZ=50
    Speed=1500
    MaxSpeed=1500
    AccelRate=0
    LifeSpan=2.0
    Damage=200
    DamageRadius=350
    MomentumTransfer=50000

    bCollideComplex=true
    bCollideWorld=true
    bBounce=true
    bNetTemporary=false
    bRotationFollowsVelocity=false
    bBlockedByInstigator=false
    bSuppressExplosionFX=false // Do not spawn hit effect in mid air
	bWaitForEffectsAtEndOfLifetime=true

	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
}
