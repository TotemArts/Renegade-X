class Rx_Vehicle_Walker extends Rx_Vehicle
	abstract;


enum EWalkerStance
{
	WalkerStance_None,
	WalkerStance_Standing,
	WalkerStance_Parked,
	WalkerStance_Crouched
};

var transient EWalkerStance CurrentStance;
var transient EWalkerStance PreviousStance;		// stance last frame

/** Suspension settings for each stance */
var() protected float WheelSuspensionTravel[EWalkerStance.EnumCount];

var array<MaterialInterface> PowerOrbTeamMaterials;
var array<MaterialInterface> PowerOrbBurnoutTeamMaterials;


var() RB_Handle BodyHandle;
var() protected const Name BodyAttachSocketName;

/** Offset to make sure leg traces start inside the walker collision volume */
var() vector LegTraceOffset;
/** How far up in Z should we start the FindGround check */
var() float LegTraceZUpAmount;

/** Interpolation speed (for RInterpTo) used for interpolating the rotation of the body handle */
var() float BodyHandleOrientInterpSpeed;

var		bool							bWasOnGround;
var		bool							bPreviousInAir;
var     bool                            bHoldingDuck;
var		bool							bAnimateDeadLegs;
var()   float   DuckForceMag;

var		float	InAirStart;
var		float	LandingFinishTime;

var()	vector	BaseBodyOffset;

/** Specifies offset to suspension travel to use for determining approximate distance to ground (takes into account suspension being loaded) */
var		float	HoverAdjust[EWalkerStance.EnumCount];

/** controls how fast to interpolate between various suspension heights */
var() protected float SuspensionTravelAdjustSpeed;

/** current Eyeheight desired offset because of stepping */
var float EyeStepOffset;

/** Max offset due to a step */
var() float MaxEyeStepOffset;

var() float EyeStepFadeRate;

var() float EyeStepBlendRate;

var transient bool bCurrentlyVisible;

var transient vector StoppedBeingVisibleLocation;

var Actor bEncroachingVehicle;

var float SprintSpeed, BaseSpeed;



simulated function PostBeginPlay()
{
	local vector X, Y, Z;

	Super.PostBeginPlay();

	// no spider body on server
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		GetAxes(Rotation, X,Y,Z);
//		BodyActor = Spawn(BodyType, self,, Location+BaseBodyOffset.X*X+BaseBodyOffset.Y*Y+BaseBodyOffset.Z*Z);
//		BodyActor.SetWalkerVehicle(self);
	}
}



function analysePhysics() {

    local int i;

    for(i=0; i<Wheels.length; i++) 
    {
      if(UDKVehicleWheel(Wheels[i]) != None)
      {
        //loginternal("Wheel"@i);
        //loginternal(Wheels[i].LongSlipFactor);
        //loginternal(Wheels[i].LatSlipFactor);
      }
    }
}

event EncroachedBy( actor Other )
{
	SetPhysics(PHYS_RigidBody);
	bEncroachingVehicle=Other;

	super.EncroachedBy(Other);
	
	//loginternal("encroached");
	//setTimer(0.5, true, 'checkStillEncroached');
}


simulated function Tick( FLOAT DeltaSeconds )
{

//    DrawDebugLine(location, location + vector(rotation) * 400,0,0,255,false);

	if(Throttle == 0.0 && Steering == 0.0)
	{
		if(PHYSICS != PHYS_None)
		{
			bCollideAsEncroacher = true;
			SetPhysics(PHYS_None);
		}
	} else if(PHYSICS != PHYS_RigidBody)
	{
		SetPhysics(PHYS_RigidBody);
	} 	

	super.Tick(DeltaSeconds);
}

reliable server function IncreaseSprintSpeed()
{
	AirSpeed = BaseSpeed;
	MaxSpeed = SprintSpeed;
	super.IncreaseSprintSpeed();
}

reliable server function DecreaseSprintSpeed()
{
	AirSpeed = SprintSpeed;
	MaxSpeed = BaseSpeed;	
	super.DecreaseSprintSpeed();
}


defaultproperties
{
	bCanBeBaseForPawns=false
	CollisionDamageMult=0.0

	Begin Object Class=RB_Handle Name=RB_BodyHandle
		LinearDamping=100.0
		LinearStiffness=4000.0
		AngularDamping=200.0
		AngularStiffness=4000.0
	End Object
	BodyHandle=RB_BodyHandle
	Components.Add(RB_BodyHandle)

	BodyHandleOrientInterpSpeed=5.f
	bAnimateDeadLegs=false

	bCurrentlyVisible=true

	bStayUpright=true
	StayUprightRollResistAngle=0.0			// will be "locked"
	StayUprightPitchResistAngle=0.0
	StayUprightStiffness=2000
	StayUprightDamping=25
	
	UprightLiftStrength=50.0
	UprightTorqueStrength=50.0

	SprintSpeed = 500
	BaseSpeed = 300
}
