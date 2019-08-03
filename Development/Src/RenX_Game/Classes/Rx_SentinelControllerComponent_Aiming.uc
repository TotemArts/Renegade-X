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
//var() array<float> AimTestLocations;
var() array<Vector> AimTestLocations;

/**
 * Determines the best place to shoot at to hit the target.
 */
function bool FindAimToHit(Actor A, out Vector AimSpot, out Rotator AimRotation)
{
	local Vector Origin;
	local Vector TargetLocation;
	local bool bCanHit;

	Origin = Cannon.GetPawnViewLocation();

	//If the enemy is not visible, point at where they were last detected.
	if(!bEnemyIsVisible && !bForceTarget)
	{
		AimSpot = LastDetectedLocation;
	}
	
	AimSpot = A.GetTargetLocation();
	TargetLocation = AimSpot;
	bCanHit = TraceCheckAim(A, Origin, TargetLocation, AimSpot);

	if(!bCanHit && A.bHasAlternateTargetLocation)
	{
		AimSpot = A.GetTargetLocation(, true);
		TargetLocation = AimSpot;
		bCanHit = TraceCheckAim(A, Origin, TargetLocation, AimSpot);
	}

	AimRotation = Rotator(AimSpot - Origin);
	Cannon.SWeapon.AdjustAimToHit(A, AimSpot, AimRotation);

	return bCanHit;
}

/**
 * Tests to see if there is a clear shot to the target, and tries adjusting the aim if not.
 */
function bool TraceCheckAim(Actor A, Vector Origin, Vector TargetLocation, out Vector AimSpot)
{
	local bool bSuccess;
	local Vector Offset;
	local Vector TestSpot;
	local float TargetRadius, TargetHeight;
	local float CheckRadius, CheckHeight;
	local Vector V;

	TestSpot = AimSpot;
	if(FastTrace(TestSpot, Origin,,true))
	{
		return true;	
	}

	A.GetBoundingCylinder(TargetRadius, TargetHeight);
	CheckRadius = TargetRadius - VSize2D(A.Location - TargetLocation);
	CheckHeight = TargetHeight - Abs(A.Location.Z - TargetLocation.Z);

	foreach AimTestLocations(V)
	{
		
		if(Rx_Vehicle(A) != None)
		{
			TestSpot = AimSpot + (vector(A.rotation) * CheckRadius * (V.X * 0.7));
			TestSpot.Z = TestSpot.Z + CheckHeight * (V.Z * 0.7);			
		} else 
		{
			Offset.X = CheckRadius * V.X;
			Offset.Y = CheckRadius * V.Y;
			Offset.Z = CheckHeight * V.Z;
			TestSpot = AimSpot + Offset;
		}	

		if(A.ContainsPoint(TestSpot) && FastTrace(TestSpot, Origin,,true))
		{
			AimSpot = TestSpot;
			bSuccess = true;
			//DrawDebugLine(TestSpot,Origin,0,0,255,true);
			break;
		} else 
		{
			/**
			if(A.ContainsPoint(TestSpot))
			  DrawDebugLine(TestSpot,Origin,0,255,0,true);
			else
			  DrawDebugLine(TestSpot,Origin,255,0,0,true);
			*/  
			  
		}
	}

	return bSuccess;
}


defaultproperties
{
	MaxPredictionSpeed=500.0
	
	AimTestLocations.Add((X=0.0,Y=0.0,Z=0.0))
	AimTestLocations.Add((X=0.2,Y=0.0,Z=0.0))
	AimTestLocations.Add((X=-0.2,Y=0.0,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=0.2,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=-0.2,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=0.0,Z=0.2))
	AimTestLocations.Add((X=0.0,Y=0.0,Z=-0.2))
	AimTestLocations.Add((X=0.4,Y=0.0,Z=0.0))
	AimTestLocations.Add((X=-0.4,Y=0.0,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=0.4,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=-0.4,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=0.0,Z=0.4))
	AimTestLocations.Add((X=0.0,Y=0.0,Z=-0.4))
	AimTestLocations.Add((X=0.7,Y=0.0,Z=0.0))
	AimTestLocations.Add((X=-0.7,Y=0.0,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=0.7,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=-0.7,Z=0.0))
	AimTestLocations.Add((X=0.0,Y=0.0,Z=0.7))
	AimTestLocations.Add((X=0.0,Y=0.0,Z=-0.7))
	AimTestLocations.Add((X=0.7,Y=0.0,Z=0.7))
	AimTestLocations.Add((X=-0.7,Y=0.0,Z=0.7))
	AimTestLocations.Add((X=0.0,Y=0.7,Z=0.7))
	AimTestLocations.Add((X=0.0,Y=-0.7,Z=0.7))
	AimTestLocations.Add((X=0.7,Y=0.0,Z=-0.7))
	AimTestLocations.Add((X=-0.7,Y=0.0,Z=-0.7))
	AimTestLocations.Add((X=0.0,Y=0.7,Z=-0.7))
	AimTestLocations.Add((X=0.0,Y=-0.7,Z=-0.7))	
	
}