//=============================================================================
// Contains functionality that is potentially useful across many classes,
// including determining if a given type of Sentinel can be spawned, and
// actually spawning one.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_Sentinel_Utils extends Object
	abstract;

const URotToRad = 0.000095873799; //2.0 * Pi / 65536.0

struct SentinelInfo
{
	var() class<Rx_Sentinel> SentinelClass;
	var() float DeployRange;
	var() int CeilingNormalPitchLimit;
};

/**
 * A colour in the HSL colour space. Components assumed to be between 0.0 and 1.0.
 * Bloom is a multiplier used when converting to RGB, with 1.0 being normal, >1.0 increases brightness.
 */
struct immutable HSLColour
{
	var() float H, S, L, A, Bloom;

	structdefaultproperties
	{
		A=1.0
	}
};

/**
 * Deploys a Floor Sentinel in front of the spawner, if possible.
 *
 * @param	TraceOwner	actor to use for tracing
 * @param	Start		location to trace from
 * @param	Aim			the direction to spawn in
 * @return	the Sentinel spawned, if any
 */
static final function Rx_Sentinel DeployFloor(SentinelInfo SInfo, Actor TraceOwner, Vector Start, Vector Aim)
{
	local Vector FloorLocation;
	local Rx_Sentinel S;
	local Rotator SpawnRotation;

	if(static.FindFloorSpot(SInfo, TraceOwner, Start, Aim, FloorLocation))
	{
		SpawnRotation.Yaw = Rotator(Aim).Yaw;
		S = TraceOwner.Spawn(SInfo.SentinelClass,,, FloorLocation, SpawnRotation);

		if(S != none)
		{
			S.bCollideWorld = true;
			S.SetPhysics(PHYS_Falling);
		}
	}

	return S;
}

/**
 * Tries to find a place within range where a Floor Sentinel will fit.
 *
 * @param	SInfo				info of the type of Sentinel to test with
 * @param	TraceOwner			actor to use for tracing
 * @param	Start				location to start tracing from
 * @param	Aim					direction to trace in
 * @param	FloorLocation		set to the location where a Sentinel can be spawned
 * @return	true if a spot was found, false if a Sentinel cannot be spawned this way
 */
static final function bool FindFloorSpot(SentinelInfo SInfo, Actor TraceOwner, Vector Start, Vector Aim, out Vector FloorLocation)
{
	local Vector FloorNormal;
	local Vector End;
	local Vector Extent;
	local bool bCanSpawn;

	End = Start + (Aim * SInfo.DeployRange);

	//See if there's anything in the way, which would require spawning closer than normal.
	if(TraceOwner.Trace(FloorLocation, FloorNormal, End, Start, true,,, TraceOwner.TRACEFLAG_Bullet) == none)
		FloorLocation = End;
	else
		FloorLocation += FloorNormal * SInfo.SentinelClass.default.CylinderComponent.CollisionRadius;

	//Try to fit a box the size of the Sentinel where the trace hit.
	Extent.X = SInfo.SentinelClass.default.CylinderComponent.CollisionRadius;
	Extent.Y = Extent.X;
	Extent.Z = SInfo.SentinelClass.default.CylinderComponent.CollisionHeight;

	//FindSpot moves the location to where the Sentinel would fit, if possible.
	bCanSpawn = TraceOwner.FindSpot(Extent, FloorLocation);

	return bCanSpawn;
}

/**
 * Deploys a Ceiling Sentinel on the nearest surface, if possible.
 *
 * @param	TraceOwner	actor to use for tracing
 * @param	Start		location to trace from
 * @param	Aim			the direction to spawn in. Must be a unit vector
 * @return	the Sentinel spawned, if any
 */
static final function Rx_Sentinel DeployCeiling(SentinelInfo SInfo, Actor TraceOwner, Vector Start, Vector Aim)
{
	local Actor CeilingActor;
	local Vector CeilingLocation, CeilingNormal;
	local Rx_Sentinel S;
	local Rotator SpawnRotation;
	local Vector X, Y, Z;

	if(static.FindCeilingSpot(SInfo, TraceOwner, Start, Aim, CeilingLocation, CeilingNormal, CeilingActor))
	{
		//Calculate appropriate rotation to spawn at, so it's flat against the surface and pointing in the way the player was aiming.
		Z = CeilingNormal;
		Y = Z cross Aim;
		X = Y cross Z;
		SpawnRotation = OrthoRotation(X, Y, Z);

		S = TraceOwner.Spawn(SInfo.SentinelClass,,, CeilingLocation, SpawnRotation);

		if(S != none)
		{
			S.bCollideWorld = false; //Turn off collision and translate, because collision may move the Sentinel away from the ceiling when it's spawned.
			S.SetLocation(CeilingLocation);
			S.SetPhysics(PHYS_None);
			S.Landed(CeilingNormal, CeilingActor); //Causes Sentinel to align itself to the ceiling properly.
			S.SetBase(CeilingActor);
		}
	}

	return S;
}

/**
 * Tries to find a place on a surface within range suitable for attaching a Ceiling Sentinel to.
 *
 * @param	SInfo				info of the type of Sentinel to test with
 * @param	TraceOwner			actor to use for tracing
 * @param	Start				location to start tracing from
 * @param	Aim					direction to trace in. Must be a unit vector
 * @param	CeilingLocation		set to the location where a Sentinel can be spawned
 * @param	CeilingNormal		set to the normal of the surface where a Sentinel can be spawned
 * @param	CeilingActor		actor that a Sentinel can be spawned on
 * @return	true if a spot was found, false if a Sentinel cannot be spawned this way
 */
static final function bool FindCeilingSpot(SentinelInfo SInfo, Actor TraceOwner, Vector Start, Vector Aim, out Vector CeilingLocation, out Vector CeilingNormal, out Actor CeilingActor)
{
	local Vector End;
	local Vector Extent;
	local bool bCanSpawn;

	End = Start + (Aim * SInfo.DeployRange);
	CeilingActor = TraceOwner.Trace(CeilingLocation, CeilingNormal, End, Start, true,,, TraceOwner.TRACEFLAG_Bullet);

	//TODO: Do some more tracing "down" to make sure the Sentinel is not spawned only hanging on by a sliver.
	if(CeilingActor != none)
	{
		if(Rotator(CeilingNormal).Pitch < SInfo.CeilingNormalPitchLimit)
		{
			Extent.X = SInfo.SentinelClass.default.CylinderComponent.CollisionRadius;
			Extent.Y = Extent.X;
			Extent.Z = SInfo.SentinelClass.default.CylinderComponent.CollisionHeight;
			CeilingLocation += CeilingNormal * SInfo.SentinelClass.default.CylinderComponent.CollisionHeight;

			if(TraceOwner.FindSpot(Extent, CeilingLocation))
			{
				if(CeilingActor.bWorldGeometry)
				{
					bCanSpawn = true;
				}
				else if(Vehicle(CeilingActor) != none) //Can always deploy on vehicles, 'cos it's fun.
				{
					bCanSpawn = true;
				}
				else if(Pawn(CeilingActor) != none && Rx_Sentinel(CeilingActor) == none && Pawn(CeilingActor).bCanBeBaseForPawns)
				{
					bCanSpawn = true;
				}
			}
		}
	}
	else
	{
		CeilingLocation = End;
	}

	return bCanSpawn;
}

///**
// * Spawns a dropped ammo crate of the largest size possible for the given ammo amount.
// *
// * @param	A				actor to spawn from
// * @param	SpawnLocation	location to spawn crate at
// * @param	SpawnSpeed		maximum speed to throw the crate out at
// * @param	AmmoAmount		maximum amount of ammo to spawn. Size of crate actually spawned is subtracted from this
// * @param	LRIClass		class to read allowed ammo classes from
// * @return	true if a crate was spawned
// */
//static final function bool SpawnAmmoFor(Actor A, Vector SpawnLocation, float SpawnSpeed, out float AmmoAmount, class<UTLRI_Sentinel> LRIClass)
//{
//	local UTDropped_SentinelAmmo P;
//	local class<UTAmmo_SentinelDeployer> AnAmmoClass, DroppedAmmoClass;
//	local bool bSpawnedAmmo;
//
//	//Find largest possible class of ammo that can be dropped.
//	foreach LRIClass.default.AmmoClasses(AnAmmoClass)
//	{
//		if(AmmoAmount >= AnAmmoClass.default.AmmoAmount)
//		{
//			if(DroppedAmmoClass == none || DroppedAmmoClass.default.AmmoAmount < AnAmmoClass.default.AmmoAmount)
//			{
//				DroppedAmmoClass = AnAmmoClass;
//			}
//		}
//	}
//
//	if(DroppedAmmoClass != none)
//	{
//		P = A.Spawn(class'UTDropped_SentinelAmmo',,, SpawnLocation);
//
//		if(P != none)
//		{
//			P.SetPhysics(PHYS_Falling);
//			P.Velocity = VRand() * SpawnSpeed;
//
//			P.InitializeFromAmmoClass(DroppedAmmoClass);
//			AmmoAmount -= DroppedAmmoClass.default.AmmoAmount;
//
//			bSpawnedAmmo = true;
//		}
//	}
//
//	return bSpawnedAmmo;
//}

/*********************************************************************************************
 * Rotator/Vector related functions
 *********************************************************************************************/

//From Object.PointDistToPlane, altered a bit to return normalized closest point directly and swap some axes.
static final function Vector ClosestPointToPlane(Vector Point, Rotator Orientation)
{
	local Vector AxisX, AxisY, AxisZ, PointNoZ, ClosestPoint;
	local float fPointZ, fProjDistToAxis;

	GetAxes(Orientation, AxisX, AxisZ, AxisY);

	fPointZ = Point dot AxisZ;
	PointNoZ = Point - fPointZ * AxisZ;

	fProjDistToAxis = PointNoZ Dot AxisX;
	ClosestPoint = fProjDistToAxis * AxisX + fPointZ * AxisZ;

	return Normal(ClosestPoint);
}

/**
 * Rotates a rotator by the given rotations relative to its own coordinate system.
 *
 * @param	R		the rotator to apply the rotation to
 * @param	Pitch	amount to pitch R by
 * @param	Yaw		amount to yaw R by
 * @param	Roll	amount to roll R by
 * @return	the transformed rotation
 */
static final function Rotator RotateRelative(Rotator R, float Pitch, float Yaw, float Roll)
{
	local Quat PitchQuat, YawQuat, RollQuat;
	local Vector X, Y, Z;

	GetAxes(R, X, Y, Z);
	PitchQuat = QuatFromAxisAndAngle(Y, -Pitch * URotToRad);
	YawQuat = QuatFromAxisAndAngle(Z, Yaw * URotToRad);
	RollQuat = QuatFromAxisAndAngle(X, -Roll * URotToRad);

	X = QuatRotateVector(YawQuat, X);
	Y = QuatRotateVector(YawQuat, Y);

	X = QuatRotateVector(PitchQuat, X);
	Z = QuatRotateVector(PitchQuat, Z);

	Y = QuatRotateVector(RollQuat, Y);
	Z = QuatRotateVector(RollQuat, Z);

	return OrthoRotation(X, Y, Z);
}

/**
 * Finds the time at which two actors are closest, and their locations and the distance between them at that time.
 *
 * @param	A1				first actor
 * @param	A2				second actor
 * @param	ClosestTime		time in seconds from present at which the actors will be closest
 * @param	ClosestPoint1	position of A1 at ClosestTime
 * @param	ClosestPoint2	position of A2 at ClosestTime
 * @param	ClosestDistance	distance between A1 and A2 at ClosestTime
 */
static final function ClosestPointOfApproach(Actor A1, Actor A2, optional out float ClosestTime, optional out Vector ClosestPoint1, optional out Vector ClosestPoint2, optional out float ClosestDistance)
{
	if(IsZero(A1.Velocity - A2.Velocity))
	{
		//Actors travelling in same direction at same speed, so the distance between them never changes.
		ClosestTime = 0;
	}
	else
	{
		ClosestTime = ((A2.Location - A1.Location) dot (A1.Velocity - A2.Velocity)) / VSizeSq(A1.Velocity - A2.Velocity);
	}

	ClosestPoint1 = A1.Location + (A1.Velocity * ClosestTime);
	ClosestPoint2 = A2.Location + (A2.Velocity * ClosestTime);
	ClosestDistance = VSize(ClosestPoint1 - ClosestPoint2);
}

/*********************************************************************************************
 * String functions.
 *********************************************************************************************/

 /**
  * Returns a string of hex characters prefixed with "0x" that is unique in this level for the given actor.
  *
  * @param	A			the actor to generate a UID for
  * @param	NumDigits	the length of the UID to generate, minus the "0x" prefix. If 0 or not specified, use the optimum length. If this is not 0, then uniqueness is not guaranteed
  */
static final function string GenerateHexUIDFor(Actor A, optional int NumDigits)
{
	local string NameString;
	local string UID;
	local int i;

	NameString = String(A.Name);

	for(i = 0; i < Len(NameString); i++)
	{
		UID $= Right(ToHex(Asc(Mid(NameString, i, 1))), 2);
	}

	if(NumDigits > 0)
	{
		if(Len(UID) > NumDigits)
		{
			UID = Right(UID, NumDigits);
		}
		else
		{
			while(Len(UID) < NumDigits)
			{
				UID $= " ";
			}
		}
	}

	return "0x"$UID;
}

 /**
  * Adds spaces to the end of the string so it is at least MinLength long. If the string is already Minlength or longer, then it does nothing.
  */
static final function PadWithSpaces(out string S, int MinLength)
{
	while(Len(S) < MinLength)
	{
		S $= " ";
	}
}

 /**
  * Generates markup to set the desired colour.
  */
static final function string TextColourMarkup(float R, float G, float B)
{
	return "<color:R="$R$",G="$G$",B="$B$">";
}

/**
 * Generates markup to set the colour from green if Condition == MaxCondition, to red if Condition == 0.0
 *
 * @param	Condition		current condition
 * @param	MaxCondition	highest value that Condition could possibly be
 */
static final function string RedGreenTextColourMarkup(float Condition, float MaxCondition)
{
	local float Ratio;

	Ratio = FClamp(Condition / MaxCondition, 0.0, 1.0);

	return TextColourMarkup(1.0 - Ratio, Ratio, 0.0);
}

/*********************************************************************************************
 * Colour manipulation.
 *********************************************************************************************/

/**
 * Normalizes a LinearColor and converts it to a Color.
 */
static final function Color LinearColorToColor(LinearColor LC)
{
	LC = NormalizeLinearColor(LC) * 255.0;
	LC.A *= 255.0;

	return MakeColor(LC.R, LC.G, LC.B, LC.A);
}

/**
 * Scales a LinearColour so that R, G and B are between 0.0 and 1.0, and clamps alpha to the same range.
 */
static final function LinearColor NormalizeLinearColor(LinearColor LC)
{
	local float Max;

	Max = FMax(LC.R, LC.G);
	Max = FMax(Max, LC.B);

	if(Max > 1.0)
	{
		LC.R /= Max;
		LC.G /= Max;
		LC.B /= Max;
	}

	LC.A = FClamp(LC.A, 0.0, 1.0);

	return LC;
}

static final function LinearColor RENXIFY(LinearColor poop, float S, float L, float B)
{
	local HSLColour HSLTeamColour;
	
	HSLTeamColour = RGBToHSL(poop);
	HSLTeamColour.S = S;
	HSLTeamColour.L = L;
	HSLTeamColour.Bloom = B;

	return HSLToRGB(HSLTeamColour);
}

/**
 * Converts an RGB LinearColour to HSL. See http://en.wikipedia.org/wiki/HSL_color_space
 */
static final function HSLColour RGBToHSL(LinearColor RGB)
{
	local float Max, Min, Delta;
	local HSLColour HSL;

	//In case any values are > 1.0
	Max = FMax(RGB.R, RGB.G);
	Max = FMax(Max, RGB.B);
	HSL.Bloom = FMin(1.0, Max);

	//Normalize because conversion only works if values are between 0.0 and 1.0
	RGB = NormalizeLinearColor(RGB);

	Max = FMax(RGB.R, RGB.G);
	Max = FMax(Max, RGB.B);
	Min = FMin(RGB.R, RGB.G);
	Min = FMin(Min, RGB.B);

	//Lightness
	HSL.L = (Max + Min) * 0.5;

	if(Max != Min)
	{
		Delta = Max - Min;

		//Hue
		if(RGB.R == Max)
		{
			HSL.H = ((RGB.G - RGB.B) / Delta) + (RGB.G < RGB.B ? 6.0 : 0.0);
		}
		else if(RGB.G == Max)
		{
			HSL.H = ((RGB.B - RGB.R) / Delta) + 2.0;
		}
		else //B == Max
		{
			HSL.H = ((RGB.R - RGB.G) / Delta) + 4.0;
		}

		HSL.H /= 6.0;

		//Saturation
		HSL.S = (HSL.L > 0.5) ? (Delta / (2.0 - (Max + Min))) : (Delta / (Max + Min));
	}

	//Alpha
	HSL.A = RGB.A;

	return HSL;
}

/**
 * Converts an HSLColour to an RGB LinearColour. See http://en.wikipedia.org/wiki/HSL_color_space
 */
static final function LinearColor HSLToRGB(HSLColour HSL)
{
	local LinearColor RGB;
	local float Q, P;

	if(HSL.S == 0.0)
	{
		RGB.R = HSL.L;
		RGB.G = HSL.L;
		RGB.B = HSL.L;
	}
	else
	{
		Q = (HSL.L < 0.5) ? (HSL.L * (1.0 + HSL.S)) : ((HSL.L + HSL.S) - (HSL.L * HSL.S));
		P = (2.0 * HSL.L) - Q;

		RGB.R = HueToRGB(Q, P, HSL.H + (1.0 / 3.0)) * HSL.Bloom;
		RGB.G = HueToRGB(Q, P, HSL.H) * HSL.Bloom;
		RGB.B = HueToRGB(Q, P, HSL.H - (1.0 / 3.0)) * HSL.Bloom;
	}

	//Alpha
	RGB.A = HSL.A;

	return RGB;
}

/**
 * Used internally in HSLToRGB.
 */
private static final function float HueToRGB(float Q, float P, float C)
{
	local float Component;

	if(C < 0.0)
	{
		C += 1.0;
	}
	else if(C > 1.0)
	{
		C -= 1.0;
	}

	if(C < (1.0 / 6.0))
	{
		Component = P + ((Q - P) * 6.0 * C);
	}
	else if(C < 0.5)
	{
		Component = Q;
	}
	else if(C < (2.0 / 3.0))
	{
		Component = P + ((Q - P) * 6.0 * ((2.0 / 3.0) - C));
	}
	else
	{
		Component = P;
	}

	return Component;
}

/*********************************************************************************************
 * Misc.
 *********************************************************************************************/

 /**
  * Scales the times of the curve points so the length of the curve is equal to the new time.
  */
 static final function AdjustCurveTime(out InterpCurveFloat Curve, float CurveTime)
 {
	local int i;

	for(i = 0; i < Curve.Points.length; i++)
	{
		Curve.Points[i].InVal /= Curve.Points[Curve.Points.length - 1].InVal;
		Curve.Points[i].InVal *= CurveTime;
	}
 }

/**
 * For debugging. Draws a visible cylinder where the collision cylinder is.
 */
static final function DrawCollisionCylinderFor(Actor A)
{
	local CylinderComponent CylinderComponent;
	local Vector Start, End;
	local float Radius;

	CylinderComponent = CylinderComponent(A.CollisionComponent);

	Start = CylinderComponent.GetPosition();
	End = Start;
	End.Z += CylinderComponent.CollisionHeight;
	Start.Z -= CylinderComponent.CollisionHeight;
	Radius = CylinderComponent.CollisionRadius;

	A.DrawDebugCylinder(Start, End, Radius, 16, 0, 255, 0, false);
}

/**
 * For debugging. Spawns an emitter at an actor's location to draw attention to it.
 */
static final function SpawnEmitterAt(Actor A)
{
	if(A != none)
	{
		A.WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'Envy_Effects.Particles.P_Player_Spawn_Blue', A.Location, A.Rotation);
	}
}

defaultproperties
{
}
