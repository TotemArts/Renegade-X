/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class Rx_SkelControl_OrcaEngine extends SkelControlSingleBone
	hidecategories(Translation, Rotation, Adjustment);

/** This holds the max. amount the engine can pitch */
var() float ForwardPitch;

/** This holds the min. amount the engine can pitch */
var() float BackPitch;

/** How fast does it change direction */
var() float PitchRate;

/** This will add degrees to the Forward/Back Pitch angles when sprinting */
var() float SprintAngleIncrease;

/** Velocity Range */

var() float MaxVelocity;
var() float MinVelocity;

var() float MaxVelocityPitchRateMultiplier;

/** Used to time the change */
var transient float PitchTime;

/** Holds the last thrust value */
var transient float LastThrust;

/** This holds the desired pitches for a given engine */
var transient int DesiredPitch;



event TickSkelControl(float DeltaTime, SkeletalMeshComponent SkelComp)
{
	local Rx_Vehicle OwnerVehicle;
	local float Speed, Pct;

	OwnerVehicle = Rx_Vehicle(SkelComp.Owner);

	PitchTime = PitchRate;
	if (OwnerVehicle != None && OwnerVehicle.bDriving && SkelComp.LastRenderTime > OwnerVehicle.WorldInfo.TimeSeconds - 0.2)
	{
		if ( OwnerVehicle.OutputGas != LastThrust )
		{
			if ( OwnerVehicle.OutputGas > 0 )
			{
				if ( OwnerVehicle.bSprinting )
				{
					DesiredPitch = int((ForwardPitch - SprintAngleIncrease) * 182.0444);
				}
				else
				{
					DesiredPitch = int(ForwardPitch * 182.0444);
				}
			}
			else if ( OwnerVehicle.OutputGas < 0 )
			{
				if ( OwnerVehicle.bSprinting )
				{
					DesiredPitch = int((BackPitch + SprintAngleIncrease) * 182.0444);
				}
				else
				{
					DesiredPitch = int(BackPitch * 182.0444);
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
		LastThrust = OwnerVehicle.OutputGas;
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
	ForwardPitch=-60
	BackPitch=35
	SprintAngleIncrease=10
	PitchRate=0.65
	MaxVelocity=2100
	MinVelocity=100
	MaxVelocityPitchRateMultiplier=0.15
	bIgnoreWhenNotRendered=true
}
