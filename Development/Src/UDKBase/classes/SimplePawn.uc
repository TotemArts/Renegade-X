/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class SimplePawn extends GamePawn;

var	bool bFixedView;
var vector FixedViewLoc;
var rotator FixedViewRot;


/** view bob properties */
var	float Bob;
var	float AppliedBob;
var	float BobTime;
var	vector WalkBob;
var float OldZ;

/** Speed modifier for castle pawn */
var config float CastlePawnSpeed;
var config float CastlePawnAccel;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	OldZ = Location.Z;
}

exec function FixedView()
{
	if (!bFixedView)
	{
		FixedViewLoc = Location;
		FixedViewRot = Controller.Rotation;
	}
	bFixedView = !bFixedView;
}

	
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local float Radius, Height;

	// Override camera FOV for first person castle player
	out_FOV = 65.0;

	// Handle the fixed camera
	if (bFixedView)
	{
		out_CamLoc = FixedViewLoc;
		out_CamRot = FixedViewRot;
		return true;
	}

	GetBoundingCylinder(Radius, Height);
	out_CamLoc = Location - vector(out_CamRot) * Radius * 20;

	return false;
}



/**
 * Updates the player's eye height using BaseEyeHeight and (head) Bob settings; called every tick 
 */
event TickSpecial( float DeltaTime )
{
	// NOTE: The following was pulled from UT's head bobbing features

	local bool bAllowBob;
	local float smooth, Speed2D;
	local vector X, Y, Z;

	// Set ground speed
	GroundSpeed = CastlePawnSpeed;
	AccelRate = CastlePawnAccel;

	bAllowBob = true;
	if ( abs(Location.Z - OldZ) > 15 )
	{
		// if position difference too great, don't do head bob
		bAllowBob = false;
		BobTime = 0;
		WalkBob = Vect(0,0,0);
	}

	if ( bAllowBob )
	{
		// normal walking around
		// smooth eye position changes while going up/down stairs
		smooth = FMin(0.9, 10.0 * DeltaTime/CustomTimeDilation);
		if( Physics == PHYS_Walking || Controller.IsInState('PlayerClickToMove') )
		{
			EyeHeight = FMax((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
								-0.5 * CylinderComponent.CollisionHeight);
		}
		else
		{
			EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
		}

		// Add walk bob to movement
		Bob = FClamp(Bob, -0.15, 0.15);

		if (Physics == PHYS_Walking )
		{
			GetAxes(Rotation,X,Y,Z);
			Speed2D = VSize(Velocity);
			if ( Speed2D < 10 )
			{
			  BobTime += 0.2 * DeltaTime;
			}
			else
			{
				BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
			}
			WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
			AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
			WalkBob.Z = AppliedBob;
			if ( Speed2D > 10 )
			{
				WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
			}
		}
		else if ( Physics == PHYS_Swimming )
		{
			GetAxes(Rotation,X,Y,Z);
			BobTime += DeltaTime;
			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * BobTime);
			WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * BobTime);
		}
		else
		{
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		WalkBob *= 0.1;
	}

	OldZ = Location.Z;
}


/**
 * GetPawnViewLocation()
 *
 * Called by PlayerController to determine camera position in first person view.  Returns
 * the location at which to place the camera
 */
simulated function Vector GetPawnViewLocation()
{
	return Location + EyeHeight * vect(0,0,1) + WalkBob;
}


defaultproperties
{
	Components.Remove(Sprite)


	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	ViewPitchMin=-10000
	ViewPitchMax=12000

	// How much to bob the camera when walking
	Bob=0.12

	// @todo: When touching to move while already moving, walking physics may be applied for a single frame.
	//   This means that if WalkingPct is not 1.0, brakes will be applied and movement will appear to stutter.
	//	 Until we can figure out how to avoid the state transition glitch, we're forcing WalkingPct to 1.0
	WalkingPct=+1.0
	CrouchedPct=+0.4
	BaseEyeHeight=60.0 // 38.0
	EyeHeight=60.0 // 38.0
	GroundSpeed=440.0
	AirSpeed=440.0
	WaterSpeed=220.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=0.78

	AlwaysRelevantDistanceSquared=+1960000.0

	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	AirControl=+0.35
	bCanCrouch=true
	bCanClimbLadders=True
	bCanPickupInventory=True
	SightRadius=+12000.0

	MaxStepHeight=26.0
	MaxJumpHeight=49.0

	bScriptTickSpecial=true
}

