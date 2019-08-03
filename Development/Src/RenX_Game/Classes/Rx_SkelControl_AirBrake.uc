/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class Rx_SkelControl_AirBrake extends SkelControlSingleBone
	hidecategories(Translation, Rotation, Adjustment);

/** This holds the max. amount the engine can pitch */
var() float PitchAngle;

/** How fast does it change direction */
var() float PitchRate;

/** Velocity Range */

var() float MaxVelocity;
var() float MinVelocity;
var() float MinBreakVelocity;
var() float MinBreakTurningFactor;

var() float MaxVelocityPitchRateMultiplier;

/** Used to time the change */
var transient float PitchTime;

/** Holds the last thrust value */
var transient float LastThrust;

/** This holds the desired pitches for a given engine */
var transient int DesiredPitch;

var() enum AirBreakSide {
	SIDE_Centre,
	SIDE_Left,
	SIDE_Right,
}	BreakLocation;



event TickSkelControl(float DeltaTime, SkeletalMeshComponent SkelComp)
{
	local Rx_Vehicle OwnerVehicle;
	local float Speed, Pct;

	OwnerVehicle = Rx_Vehicle(SkelComp.Owner);

	PitchTime = PitchRate;
	if (OwnerVehicle != None && OwnerVehicle.bDriving && SkelComp.LastRenderTime > OwnerVehicle.WorldInfo.TimeSeconds - 0.2)
	{
		if ( VSize2D(OwnerVehicle.Velocity) != LastThrust )
		{
			if ( Abs(VSize2D(OwnerVehicle.Velocity)) > MinBreakVelocity && Abs(VSize2D(OwnerVehicle.Velocity)) < ( Abs(LastThrust) - 0.0) )
			{
				if	( BreakLocation == SIDE_Right )
				{
					if ( OwnerVehicle.AngularVelocity.Z > MinBreakTurningFactor )
					{
						DesiredPitch = int(PitchAngle * 182.0444);
					}
					else if  ( Abs(OwnerVehicle.AngularVelocity.Z) < MinBreakTurningFactor * 3.0 )
					{
						DesiredPitch = int(PitchAngle * 182.0444);
					}
					else
					{
						DesiredPitch = 0;
					}				
				}
				else if	( BreakLocation == SIDE_Left )
				{
					if ( OwnerVehicle.AngularVelocity.Z < -MinBreakTurningFactor )
					{
						DesiredPitch = int(PitchAngle * 182.0444);
					}
					else if  ( Abs(OwnerVehicle.AngularVelocity.Z) < MinBreakTurningFactor * 3.0 )
					{
						DesiredPitch = int(PitchAngle * 182.0444);
					}
					else
					{
						DesiredPitch = 0;
					}				
				}
				else
				{
					DesiredPitch = int(PitchAngle * 182.0444);
				}						
			}
			else
			{
				DesiredPitch = 0;
			}

			// Use the Speed to determine the rate at which it moves
			Speed = FClamp( VSize2D(OwnerVehicle.Velocity), MinVelocity, MaxVelocity );
			Pct = (Speed - MinVelocity)/(MaxVelocity - MinVelocity);
			PitchTime *= (1 + ( (MaxVelocityPitchRateMultiplier - 1) * Pct));
		}
		LastThrust = VSize2D(OwnerVehicle.Velocity);
	}
	else
	{
		DesiredPitch = 0;
	}

	if ( BoneRotation.Pitch != DesiredPitch )
	{
		BoneRotation.Pitch += int((DesiredPitch - BoneRotation.Pitch) * DeltaTime/PitchTime);
		PitchTime -= DeltaTime;
		if ( PitchTime <= 0 || DesiredPitch == BoneRotation.Pitch )
		{
			PitchTime = 0.0;
			BoneRotation.Pitch = DesiredPitch;
		}
	}
}

defaultproperties
{
	bShouldTickInScript=true
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_BoneSpace
	ControlStrength=1.0
	PitchAngle=-75
	BreakLocation=SIDE_Centre
	PitchRate=0.5
	MaxVelocity=2100
	MinVelocity=100
	MinBreakVelocity=200
	MinBreakTurningFactor=0.065
	MaxVelocityPitchRateMultiplier=0.15
	bIgnoreWhenNotRendered=true	
}

