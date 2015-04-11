//=============================================================================
// Calculates aim for a Sentinel.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelControllerComponent_Aiming extends Component
	within Rx_SentinelController;

/** Prediction will never see target as moving faster than this. */
var() float MaxPredictionSpeed;
/** If true, prediction will use trace(s) to check if predicted path is blocked. */
var() bool bPredictionUsesTrace;
/** Relative locations within target's bounding cylinder to try to aim at when failed to aim at the target's location. */
var() array<float> AimTestLocations;

/**
 * Determines the best place to shoot at to hit the target.
 */
function FindAimToHit(Actor A, out Vector AimSpot, out Rotator AimRotation)
{
	local vector Origin;

	Origin = Cannon.GetPawnViewLocation();

	//If the enemy is not visible, point at where they were last detected.
	if(!bEnemyIsVisible && !bForceTarget)
	{
		AimSpot = LastDetectedLocation;
	}
	//If using an instant-hit weapon or the target doesn't move, just aim straight at it.
	else if(Cannon.SWeapon.GetProjectileClass() == none || A.IsStationary())
	{
		AimSpot = A.GetTargetLocation();
		TraceCheckAim(A, Origin, AimSpot);
	}
	//For moving targets, try to aim where they will be when the shot reaches them.
	else
	{
		PredictTargetLocation(A, Origin, AimSpot);

		if(!TraceCheckAim(A, Origin, AimSpot))
		{
			//If the predicted location cannot be shot at, try half way.
			AimSpot = AimSpot - ((AimSpot - A.GetTargetLocation()) / 2.0);

			if(!TraceCheckAim(A, Origin, AimSpot))
			{
				//Still can't hit? Try not aiming ahead at all.
				AimSpot = A.GetTargetLocation();
				TraceCheckAim(A, Origin, AimSpot);
			}
		}
	}

	AimRotation = Rotator(AimSpot - Origin);
	Cannon.SWeapon.AdjustAimToHit(A, AimSpot, AimRotation);
}

/**
 * Tests to see if there is a clear shot to the target, and tries adjusting the aim if not.
 */
function bool TraceCheckAim(Actor A, Vector Origin, out Vector AimSpot)
{
	local bool bSuccess;
	local Vector TestSpot;
	local float TargetRadius, TargetHeight;
	local float f;

	TestSpot = AimSpot;
	
	if(FastTrace(TestSpot, Origin,,true))
	{
		return true;	
	}
	
	A.GetBoundingCylinder(TargetRadius, TargetHeight);

	foreach AimTestLocations(f)
	{
		TestSpot.X = AimSpot.X + (TargetHeight * f);

		foreach AimTestLocations(f)
		{
			TestSpot.Y = AimSpot.Y + (TargetHeight * f);

			foreach AimTestLocations(f)
			{
				TestSpot.Z = AimSpot.Z + (TargetHeight * f);

				//DrawDebugLine(TestSpot,Origin,0,0,255,true);
				if(FastTrace(TestSpot, Origin,,true))
				{
					AimSpot = TestSpot;
					bSuccess = true;
					break;
				}
			}

			if(bSuccess)
				break;
		}

		if(bSuccess)
			break;
	}

	return bSuccess;
}

/**
 * Predicts where the target will be based on its velocity. Only call this if the Sentinel is using a projectile weapon.
 */
function PredictTargetLocation(Actor A, Vector Origin, out Vector AimSpot)
{
	local float PredictionTime;
	local Vector PredictionVelocity;
	local Vector Extent;
	local Vector TraceStart, TraceEnd;
	local Vector HitLocation, HitNormal;

	AimSpot = A.GetTargetLocation();

	//How long it will take for projectile to reach target.
	PredictionTime = Cannon.SWeapon.GetProjectileTimeToLocation(AimSpot, Origin, Cannon.SController);

	//Where the target will probably be by then.
	if(VSize(A.Velocity) > MaxPredictionSpeed)
		PredictionVelocity = Normal(A.Velocity) * MaxPredictionSpeed;
	else
		PredictionVelocity = A.Velocity;

	if(bPredictionUsesTrace)
	{
		//Trace from target's current location to predicted location and assume they will stop if there is an obstacle.
		TraceStart = AimSpot;
		TraceEnd = TraceStart + (PredictionVelocity * PredictionTime * Cannon.AimAhead);
		A.GetBoundingCylinder(Extent.X, Extent.Z);
		Extent.Y = Extent.X;

		if(Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, Extent,, TRACEFLAG_Blocking) == none)
		{
			AimSpot = TraceEnd;
		}
		else
		{
			AimSpot = HitLocation;
		}
	}
	else
	{
		AimSpot += PredictionVelocity * PredictionTime * Cannon.AimAhead;
	}
}

defaultproperties
{
	MaxPredictionSpeed=500.0

	AimTestLocations[0]=0.0
	AimTestLocations[1]=0.9
	AimTestLocations[2]=-0.9

	
	/**
	AimTestLocations[0]=0.0
	AimTestLocations[1]=0.4
	AimTestLocations[2]=-0.4
	AimTestLocations[3]=0.6
	AimTestLocations[4]=-0.6
	*/
	/**
	AimTestLocations[5]=0.8
	AimTestLocations[6]=-0.9
	AimTestLocations[7]=0.99
	AimTestLocations[8]=-0.99
	*/
}