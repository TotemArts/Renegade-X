class Rx_Projectile_TimedC4 extends Rx_Projectile;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(30.0+FRand()*0.5,false);                  //Grenade begins unarmed
    RandSpin(0);
}

function Init(vector Direction)
{
    super.Init(Direction);

    TossZ = TossZ + (FRand() * TossZ / 2.0) - (TossZ / 4.0);
    Velocity.Z += TossZ;
    Acceleration = AccelRate * Normal(Velocity);
	
//	Velocity = Speed * Direction;
//    TossZ = TossZ + (FRand() * TossZ / 2.0) - (TossZ / 4.0);
//    Velocity.Z += TossZ;
//    Acceleration = AccelRate * Normal(Velocity);
}

/**
 * Explode
 */
simulated function Timer()
{
    Explode(Location, vect(0,0,0));
}

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
    bBlockedByInstigator = true;

    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        PlaySound(ImpactSound, true);
    }

    // check to make sure we didn't hit a pawn

    if ( Pawn(Wall) == none )
    {
        ImpactedActor = Wall;
        SetPhysics(PHYS_None);
    }
    else if ( Wall != Instigator )
    {
        ImpactedActor = Wall;
        SetPhysics(PHYS_None);
    }
}


DefaultProperties
{

    ImpactSound=SoundCue'RX_WP_TimedC4.Sounds.SC_Beep_Single'
	
    ProjFlightTemplate=ParticleSystem'RX_WP_TimedC4.Effects.P_TimedC4_Projectile'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Water',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_WhiteSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Dirt',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_YellowSand',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Snow',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4')

	
	
    DrawScale= 1.0
    
    Physics=PHYS_Falling
    
    MyDamageType=class'Rx_DmgType_TimedC4'
    
    TossZ=50.0
    Speed=500 //1300
    MaxSpeed=800
    AccelRate=0
    LifeSpan=40.0
    Damage=400
    DamageRadius=360
    MomentumTransfer=50000

    bCollideComplex=true
    bCollideWorld=true
    bBounce=true
    bNetTemporary=false
    bRotationFollowsVelocity=true
    bBlockedByInstigator=true
    bSuppressExplosionFX=false // Do not spawn hit effect in mid air
}
