/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class MobilePlaceablePawn extends GamePawn
	placeable;

var	bool bFixedView;
var vector FixedViewLoc;
var rotator FixedViewRot;

var() const editconst LightEnvironmentComponent LightEnvironment;

exec function FixedView()
{
	if (!bFixedView)
	{
		FixedViewLoc = Location;
		FixedViewRot = Controller.Rotation;
	}
	bFixedView = !bFixedView;
}

// overwrite this function to avoid animsets to be be overwritten by default
simulated event bool RestoreAnimSetsToDefault()
{
	return FALSE;
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	// Override camera FOV for first person castle player
	out_FOV = 65.0;

	// Handle the fixed camera
	if (bFixedView)
	{
		out_CamLoc = FixedViewLoc;
		out_CamRot = FixedViewRot;
	}
	else
	{
		return Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}

	return true;
}


/**
 * GetPawnViewLocation()
 *
 * Called by PlayerController to determine camera position in first person view.  Returns
 * the location at which to place the camera
 */
simulated function Vector GetPawnViewLocation()
{
	return Location + EyeHeight * vect(0,0,1);
}


defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	ViewPitchMin=-10000
	ViewPitchMax=12000

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

 	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		ModShadowFadeoutTime=0.75f
		bIsCharacterLightEnvironment=TRUE
		bAllowDynamicShadowsOnTranslucency=TRUE
 	End Object
 	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Physics = PHYS_Falling

	bDontPossess = TRUE
	bRunPhysicsWithNoController = TRUE

 	Begin Object Class=SkeletalMeshComponent Name=PawnMesh
		LightEnvironment=MyLightEnvironment
 	End Object
 	Mesh=PawnMesh
 	Components.Add(PawnMesh)
}

