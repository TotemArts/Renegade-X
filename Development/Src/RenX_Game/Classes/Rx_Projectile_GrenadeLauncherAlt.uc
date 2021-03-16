class Rx_Projectile_GrenadeLauncherAlt extends Rx_Projectile_GrenadeLauncher;


simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(4.0+FRand()*0.5,false);                  // Grenade begins unarmed
    RandSpin(100000);
}

/**
 * Explode
 */
simulated function Timer()
{
	local vector ZOffsetLocation;
	
	 //Explode(Location, vect(0,0,1));

	//ReplicatePositionAfterLanded();
	ZOffsetLocation=location;
	
	ZOffsetLocation.z+=40; 

		
    Explode(ZOffsetLocation,vect(0,0,10)) ;// vect(0,0,1));

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
        Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
        Speed = VSize(Velocity);

        if (Velocity.Z > 400)
        {
            Velocity.Z = 0.5 * (400 + Velocity.Z);
        }
        // If we hit a pawn or we are moving too slowly, explod

        if ( Speed < 20 || Pawn(Wall) != none )
        {
		Explode(location, HitNormal);

		  /* ImpactedActor = Wall;
            SetPhysics(PHYS_None);
        */
		}
    }
    else if ( Wall != Instigator )     // Hit a different pawn, just explode
    {
        Explode(Location, HitNormal);
    }
}



DefaultProperties
{
//	TossZ=150.0
	Speed=2000
    MaxSpeed=2000
    TerminalVelocity=2000.0
	LifeSpan=2.0

// Damage = 40
// DamageRadius = 400
}
