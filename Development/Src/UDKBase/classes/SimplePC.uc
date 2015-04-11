/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class SimplePC extends GamePlayerController;


/** How fast to increase the rate of rotation toward the target */
var float AutoRotationAccelRate;

/** How quickly to decelerate when no rotation is applied */
var float AutoRotationBrakeDecelRate;

/** Maximum auto rotation velocity */
var float MaxAutoRotationVelocity;

/** How fast to increase the rate of rotation toward the target */
var float BreathAutoRotationAccelRate;

/** How quickly to decelerate when no rotation is applied */
var float BreathAutoRotationBrakeDecelRate;

/** Maximum auto rotation velocity */
var float MaxBreathAutoRotationVelocity;

/** When rotating to a touch-to-move target, how much to increase yaw acceleration when the target is nearby */
var float RangeBasedYawAccelStrength;

/** Distance at which we start to change rotation acceleration rate based on distance to touch-to-move target */
var float RangeBasedAccelMaxDistance;

/** True if we should look at our click-to-move destination. */
var bool bLookAtDestination;

/** Holds the location we are looking at */
var vector LookAtDestination;

var float LookAtDestAutoPitchAmount;

/** Is camera breathing engaged yet*/
var bool bCameraBreathing;
/** The location that the camera was approximately looking at when breathing began*/
var vector CameraBreathCenterLocation;
/** Delta from the desired rotation*/
var Rotator CameraBreathRotator;
/** Last location where breathing began */
var vector CameraBreathSampleLocation;
/** Time of the last random breath rotator sampling */
var float LastCameraBreathDeltaSelectTime;
/** Time between direction changes*/
var float TimeBetweenCameraBreathChanges;

/** How fast we're currently rotating toward the target (yaw, pitch) */
var vector2d AutoRotationVelocity;

/** Holds the dimensions of the viewport */
var vector2D ViewportSize;

/** List of footstep sounds, chosen at random to play while the player is walking */
var array<SoundCue> FootstepSounds;

/** How far we should move before playing the next footstep sound */
var float DistanceUntilNextFootstepSound;

/** Commandline to run when being a server */
var config string ServerCommandline;

/** Used for turn smoothing */
var float OldTurn, OldLookup;

/** How much to smooth rotation. */ 
var config float RotationSmoothingFactor;

/** Whether to use rotation smoothing */
var config bool bSmoothRotation;

var config int DefaultInputGroup;

/** Cache a reference to the MobilePlayerInput */
var MobilePlayerInput MPI;

/** Cache a reference to various zones */
var MobileInputZone SliderZone;
var MobileInputZone StickMoveZone;
var MobileInputZone StickLookZone;
var MobileInputZone FreeLookZone;

/** Used for stats tracking */
var int NoTapToMoves;

/** Used for stats tracking */
var float LastEnteredTapToMove;

/** Used for stats tracking */
var float TotalTimeInTapToMove;

/** Holds the time of the last movement/look change */
var float TimeOfLastUserViewChange;


/** If true, apply an offset to the view target during a matinee */
var bool bApplyBackTouchToViewOffset;
var bool bFingerIsDown;

var Vector2D TouchCenter;
var Rotator LastOffset;
var Rotator MatineeOffset;

/**
 * When we init the input system, find the TapToMove zone and hook up the delegate                                                                      
 */
event InitInputSystem()
{
	Super.InitInputSystem();

	SetupZones();
}

/** 
 * Kismet hook to trigger console events 
 */
function OnConsoleCommand( SeqAct_ConsoleCommand inAction )
{
	local string Command;

	foreach inAction.Commands(Command)
	{
		// don't allow music before startmatch
		if ( WorldInfo.Game.bWaitingToStartMatch && (Left(Command,15) ~= "mobile playsong") )
		{
			continue;
		}
		// prevent "set" commands from ever working in Kismet as they are e.g. disabled in netplay
		if (!(Left(Command, 4) ~= "set ") && !(Left(Command, 9) ~= "setnopec "))
		{
			ConsoleCommand(Command);
		}
	}
}

/**
 * Zones have to be setup on both sides of the network pond.  This function is a good place to do that from.
 *
 * @param GameClass holds the class that's being setup.
 */
simulated function ReceivedGameClass(class<GameInfo> GameClass)
{
	Super.ReceivedGameClass(GameClass);
	
	// Setup the zones
	SetupZones();
}

/**
 * The main purpose of this function is to size and reset zones.  There's a lot of specific code in
 * here to reposition zones based on if it's an phone vs pad.
 */
function SetupZones()
{
	// Cache the MPI
	MPI = MobilePlayerInput(PlayerInput);

	LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);

	StickMoveZone = MPI.FindZone("UberStickMoveZone");
	StickLookZone = MPI.FindZone("UberStickLookZone");
	FreeLookZone  = MPI.FindZone("UberLookZone");
}

/**
 * Setup the in world indicator for Touch to move and some other subsystems
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Time of the last target sampling
	LastCameraBreathDeltaSelectTime = 0;

	// Setup footstep sounds 
	SetNextFootstepDistance();
}

/** 
 * Checks to see if we are moving via the virtual stick
 *
 * @returns true if the virtual stick is being used to move the player
 */
function bool IsStickMoveActive()
{
	return StickMoveZone.State != ZoneState_Inactive;
}


/** Sets the distance until the next footstep sound plays */
function SetNextFootstepDistance()
{
	// Determine how far to go until the next foot step (with a bit of randomness!)
	DistanceUntilNextFootstepSound = 200 + FRand() * 32;
}

/**
 * PlayerMove is called each frame to manage the input.  We will use it to hook in and
 * see if the player has changed their view.  If they do, then stop auto-rotating
 */
function PlayerMove( float DeltaTime )
{
	Super.PlayerMove(DeltaTime);

	// @todo: Is this needed?
	UpdateRotation( DeltaTime );
}

/** 
  * Optionally smooth rotation
  */
function UpdateRotation( float DeltaTime )
{
	local float Smooth;

	if ( bSmoothRotation )
	{
		Smooth = 1.0 - FMin(0.9, RotationSmoothingFactor*DeltaTime);

		OldTurn = PlayerInput.aTurn * (1.0 - Smooth) + OldTurn * Smooth;
		OldLookup = PlayerInput.aLookup * (1.0 - Smooth) + OldLookup * Smooth;

		PlayerInput.aLookup = OldLookup;
		PlayerInput.aTurn = OldTurn;
	}
	Super.UpdateRotation(DeltaTime);
}


/**
 * Called from PlayerMove, it's here that we adjust the viewport                                                                     
 */
function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
	// Accumulate a desired new rotation.
	local float DistToDestination;
	local Vector2D MaxVelocityScalar;
	local float YawRotationSign;
	local float PitchRotationSign;
	local float FinalYawAccelRate;
	local float FinalPitchAccelRate;
	local vector VectorToTarget;
	local vector TargetDirection;
	local Rotator NewRotation;
	local Rotator CameraRotationYawOnly;
	local Rotator CameraRotationPitchOnly;
	local Rotator TargetRotationYawOnly;
	local Rotator TargetRotationPitchOnly;

	//values to use during calculation
	local float RotationAccelRate;
	local float RotationBreakDecelRate;
	local float MaxRotationVelocity;

	//Using a fixed time delta to avoid stutters on device
	DeltaTime = FMin(DeltaTime, 1/25.0);

	Super.ProcessViewRotation(DeltaTime, out_ViewRotation, DeltaRot);

	if (PlayerInput.aTurn != 0.0 || PlayerInput.aLookUp != 0.0)
	{
		TimeOfLastUserViewChange = WorldInfo.RealTimeSeconds;
	}

	// If the player has moved the camera recently, then forcibly disable auto-rotation
	if ( WorldInfo.RealTimeSeconds - TimeOfLastUserViewChange < 0.1 )
	{
		bLookAtDestination = false;
		//reset camera breath
		bCameraBreathing = false;
		LastCameraBreathDeltaSelectTime = 0;
	}

	//Update camera breathing
	UpdateCameraBreathing();

	if (bLookAtDestination || !bCameraBreathing)
	{
		RotationAccelRate = AutoRotationAccelRate;
		RotationBreakDecelRate = AutoRotationBrakeDecelRate;
		MaxRotationVelocity = MaxAutoRotationVelocity;
	}
	else
	{
		RotationAccelRate = BreathAutoRotationAccelRate;
		RotationBreakDecelRate = BreathAutoRotationBrakeDecelRate;
		MaxRotationVelocity = MaxBreathAutoRotationVelocity;
	}


	MaxVelocityScalar.X = 1.0;
	MaxVelocityScalar.Y = 1.0;

	if( bLookAtDestination || bCameraBreathing)
	{
		CameraRotationYawOnly = out_ViewRotation;
		CameraRotationYawOnly.Pitch = 0;
		CameraRotationYawOnly.Roll = 0;
		CameraRotationPitchOnly = out_ViewRotation;
		CameraRotationPitchOnly.Yaw = 0;
		CameraRotationPitchOnly.Roll = 0;

		if( bLookAtDestination )
		{
			VectorToTarget = LookAtDestination; 
		}
		else	//breathing
		{
			VectorToTarget = CameraBreathCenterLocation - Pawn.Location;
		}
		TargetDirection = Normal( VectorToTarget );

		TargetRotationYawOnly = Rotator( TargetDirection ) + CameraBreathRotator;
		TargetRotationPitchOnly = TargetRotationYawOnly;
		TargetRotationYawOnly.Pitch = 0;
		TargetRotationYawOnly.Roll = 0;
		TargetRotationPitchOnly.Yaw = 0;
		TargetRotationPitchOnly.Roll = 0;

		if( bLookAtDestination )
		{
			// For click to move, we limit the amount of pitching the camera will do since usually the height
			// of the target isn't that interesting, however sometimes a bit of pitching helps with slope-alignment
			TargetRotationPitchOnly = RLerp( CameraRotationPitchOnly, TargetRotationPitchOnly, LookAtDestAutoPitchAmount, true /* Take shortest route? */ );
		}

		// How close is the current camera rotation to the target orientation?  We'll rotate more quickly if
		// we're further off course, and more slowly as we approach the desired angle.  This makes the rotation
		// appear to ease-out as we approach the desired orientation.
		if (!bCameraBreathing)
		{
			MaxVelocityScalar.x *= 1.0 - FMax( 0.0, Vector( CameraRotationYawOnly ) dot Vector( TargetRotationYawOnly ) );
			MaxVelocityScalar.y *= 1.0 - FMax( 0.0, Vector( CameraRotationPitchOnly ) dot Vector( TargetRotationPitchOnly ) );
		}

		DistToDestination = VSize2D( VectorToTarget );

		// For destination-look at, allow distance to affect speed. (Note, we take the 2D distance here)
		FinalYawAccelRate = RotationAccelRate;
		FinalPitchAccelRate = RotationAccelRate;
		if( bLookAtDestination )
		{
			// Increase the yaw rate as we get closer to the target (up to 1.0 + RangeBasedYawAccelStrength).
			// This is because the yaw angle relative to the target may still be very wide as we approach 
			// (especially if the user touched a location near the player) we want to get most of the horizontal
			// turning out of the way early so the player can see where they're going
			FinalYawAccelRate *= 1.0 + ( 1.0 - FMin( DistToDestination, RangeBasedAccelMaxDistance ) / RangeBasedAccelMaxDistance ) * RangeBasedYawAccelStrength;

			// Decrease the pitch rate as we get closed to the target.  This is because the pitch angle relative
			// to the target will usually become steeper as we approach the target and we won't want to pitch
			// up and down erratically as we're arriving
			FinalPitchAccelRate *= FMin( DistToDestination, RangeBasedAccelMaxDistance ) / RangeBasedAccelMaxDistance;
		}

		CheckDistanceToDestination(DistToDestination);

		// Accelerate yaw
		YawRotationSign = ( out_ViewRotation.Yaw ClockwiseFrom TargetRotationYawOnly.Yaw ) ? -1.0 : 1.0;
		AutoRotationVelocity.x += YawRotationSign * FinalYawAccelRate * DeltaTime;

		// Accelerate pitch
		PitchRotationSign = ( out_ViewRotation.Pitch ClockwiseFrom TargetRotationPitchOnly.Pitch ) ? -1.0 : 1.0;
		AutoRotationVelocity.y += PitchRotationSign * FinalPitchAccelRate * DeltaTime;
	}
	else
	{
		// Yaw brake
		if( AutoRotationVelocity.x > 0.01 )
		{
			AutoRotationVelocity.x = FMax( 0.0, AutoRotationVelocity.x - RotationBreakDecelRate * DeltaTime );
		}
		else if( AutoRotationVelocity.x < -0.01 )
		{
			AutoRotationVelocity.x = FMin( 0.0, AutoRotationVelocity.x + RotationBreakDecelRate * DeltaTime );
		}
		else
		{
			AutoRotationVelocity.x = 0.0;
		}

		// Pitch brake
		if( AutoRotationVelocity.y > 0.01 )
		{
			AutoRotationVelocity.y = FMax( 0.0, AutoRotationVelocity.y - RotationBreakDecelRate * DeltaTime );
		}
		else if( AutoRotationVelocity.y < -0.01 )
		{
			AutoRotationVelocity.y = FMin( 0.0, AutoRotationVelocity.y + RotationBreakDecelRate * DeltaTime );
		}
		else
		{
			AutoRotationVelocity.y = 0.0;
		}
	}


	// Clamp max velocity
	if( AutoRotationVelocity.x > MaxRotationVelocity * MaxVelocityScalar.x )
	{
		AutoRotationVelocity.x = MaxRotationVelocity * MaxVelocityScalar.x;
	}
	else if( AutoRotationVelocity.x < -MaxRotationVelocity * MaxVelocityScalar.x )
	{
		AutoRotationVelocity.x = -MaxRotationVelocity * MaxVelocityScalar.x;
	}

	if( AutoRotationVelocity.y > MaxRotationVelocity * MaxVelocityScalar.y )
	{
		AutoRotationVelocity.y = MaxRotationVelocity * MaxVelocityScalar.y;
	}
	else if( AutoRotationVelocity.y < -MaxRotationVelocity * MaxVelocityScalar.y )
	{
		AutoRotationVelocity.y = -MaxRotationVelocity * MaxVelocityScalar.y;
	}

	if( Abs( AutoRotationVelocity.X ) > 0.01 || Abs( AutoRotationVelocity.Y ) > 0.01 )
	{
		// Rotate!
		NewRotation.Yaw = fixedTurn(out_ViewRotation.Yaw, out_ViewRotation.Yaw + AutoRotationVelocity.x * DeltaTime, Abs( AutoRotationVelocity.x * DeltaTime ));
		NewRotation.Pitch = fixedTurn(out_ViewRotation.Pitch, out_ViewRotation.Pitch + AutoRotationVelocity.y * DeltaTime, Abs( AutoRotationVelocity.y * DeltaTime ));
		NewRotation.Roll = out_ViewRotation.Roll;

		// Set new rotation
		out_ViewRotation = NewRotation;
	}
}

/**
 * Stub Function.  It get's called by ProcessViewRotation and allows children to perform actions based on the
 * distance to a destination.
 */
simulated function CheckDistanceToDestination(float DistToDestination)
{
}

/**Function that selects a slightly offset direction to look and will trend the camera towards that*/
simulated function UpdateCameraBreathing()
{
	local Vector PawnX, PawnY, PawnZ;
	local float DegreeDelta;
	local float YawSign;
	local float PitchDegrees;
	local float YawDegrees;

	if ( Pawn == None )
	{
		bCameraBreathing = false;
		LastCameraBreathDeltaSelectTime = 0;
		return;
	}

	//if we've just moved
	if (IsInState('PlayerClickToMove') || (CameraBreathSampleLocation != Pawn.Location))
	{
		bCameraBreathing = false;
		LastCameraBreathDeltaSelectTime = 0;
		CameraBreathSampleLocation = Pawn.Location;
		return;
	}

	//if it's time to try to breath again
	if (WorldInfo.TimeSeconds - LastCameraBreathDeltaSelectTime >= TimeBetweenCameraBreathChanges)
	{
		DegreeDelta = 0.5;
		PitchDegrees = ((FRand() * 2.f) - 1.f);
		YawSign = (FRand() >= 0.5f) ? 1.0f : -1.0f;
		YawDegrees = YawSign * (Sqrt(1.0f - PitchDegrees*PitchDegrees));
		//+ or - DegreeDeltas

		CameraBreathRotator.Pitch = (PitchDegrees*DegreeDelta*65536/360);
		CameraBreathRotator.Yaw = (YawDegrees*DegreeDelta*65536/360);
		CameraBreathRotator.Roll = 0.0;


		//if we're not actively tracking something, set a new desired look location relative to where we are already looking
		if (!bLookAtDestination && !bCameraBreathing)
		{
			//`log("NOTE: Chosen a new look at dest"@CameraBreathRotator);
			GetAxes(Rotation, PawnX, PawnY, PawnZ);

			CameraBreathCenterLocation = Pawn.Location + PawnX*1000.0;
			bCameraBreathing = true;
		}

		LastCameraBreathDeltaSelectTime = WorldInfo.TimeSeconds;
	}
}

function ActivateControlGroup()
{
	MPI.ActivateInputGroup("UberGroup");
}

/** Offset matinee via back touch */
function OffsetMatineeTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
{
	// only first finger on back panel
 	if (Handle != 0 || TouchpadIndex != 1)
 	{
 		return;
 	}

	if (Type == Touch_Began)
	{
		TouchCenter = TouchLocation;
		bFingerIsDown = true;
	}
	else if (Type == Touch_Ended)
	{
		LastOffset = MatineeOffset;
		bFingerIsDown = false;
	}
	else if (bFingerIsDown)
	{
		MatineeOffset.Yaw = LastOffset.Yaw + 60 * (TouchLocation.X - TouchCenter.X);
		MatineeOffset.Pitch = LastOffset.Pitch + -60 * (TouchLocation.Y - TouchCenter.Y);
	}
}

event NotifyDirectorControl(bool bNowControlling, SeqAct_Interp CurrentMatinee)
{
	super.NotifyDirectorControl(bNowControlling, CurrentMatinee);

	if (bNowControlling)
	{
		MPI.OnInputTouch = OffsetMatineeTouch;
	}
	else
	{
		MPI.OnInputTouch = none;
		LastOffset.Yaw = 0;
		LastOffset.Pitch = 0;
		MatineeOffset.Yaw = 0;
		MatineeOffset.Pitch = 0;
		bFingerIsDown = false;
	}

	// remember if we are controlling or not
	bApplyBackTouchToViewOffset = bNowControlling;
}

simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
{
	super.GetPlayerViewPoint(out_Location, out_Rotation);

	if (bApplyBackTouchToViewOffset)
	{
		out_Rotation += MatineeOffset;
	}
}


/**
 * Handle footsteps
 */
function PlayerTick(float DeltaTime)
{
	local float CurrentWalkSpeed;
	local int FootstepSoundIndex;
	local TraceHitInfo HitInfo;
	local Vector TraceStart;
	local Vector TraceEnd;
	local Vector TraceExtent;
	local Vector OutHitLocation, OutHitNormal;
	local Actor TraceActor;

	if (bApplyBackTouchToViewOffset && !bFingerIsDown)
	{
		MatineeOffset.Yaw *= 0.99;
		MatineeOffset.Pitch *= 0.99;
		LastOffset.Yaw *= 0.99;
		LastOffset.Pitch *= 0.99;
	}

	// Only play footsteps if we're actually walking at a decent speed
	if ( Pawn != None )
	{
		CurrentWalkSpeed = VSize2D( Pawn.Velocity );
	}
	if ( CurrentWalkSpeed > 32.0 )
	{
		// Update distance until the next foot step
		DistanceUntilNextFootstepSound -= CurrentWalkSpeed * DeltaTime;
		if( DistanceUntilNextFootstepSound < 0.0 )
		{
			TraceStart = Pawn.Location;

			// @todo probably need a better way to get the end location instead of a magic number
			TraceEnd = Pawn.Location;
			TraceEnd.Z -= 100.0f;

			// trace down and see what we are standing on.  
			TraceActor = Trace(OutHitLocation, OutHitNormal, TraceEnd, TraceStart, TRUE, TraceExtent, HitInfo, TRACEFLAG_Bullet|TRACEFLAG_Blocking|TRACEFLAG_SkipMovers);
			if( TraceActor != None && HitInfo.PhysMaterial != None && HitInfo.PhysMaterial.ImpactSound != None )
			{
				// Play the sound from the hit physical material if it exists
				PlaySound( HitInfo.PhysMaterial.ImpactSound );
			}
			else if (FootstepSounds.Length > 0)
			{
				// Play a random footstep sound if we couldnt find a physical material to get a sound from.
				FootstepSoundIndex = Rand( FootstepSounds.Length );
				PlaySound( FootstepSounds[ FootstepSoundIndex ] );
			}
			
			// Queue up the next footstep
			SetNextFootstepDistance();
		}
	}
	else
	{
		// We stopped walking so reset time until next footstep
		SetNextFootstepDistance();
	}

	Super.PlayerTick(DeltaTime);
}


exec function SetFootstepsToStone();

exec function SetFootstepsToSnow();


defaultproperties
{
	InputClass=class'GameFramework.MobilePlayerInput'

	AutoRotationAccelRate=10000.0
	AutoRotationBrakeDecelRate=10000.0
	MaxAutoRotationVelocity=300000
	
	BreathAutoRotationAccelRate=250.0
	BreathAutoRotationBrakeDecelRate=1.0
	MaxBreathAutoRotationVelocity=75

	TimeBetweenCameraBreathChanges = 2.0
	
	RangeBasedYawAccelStrength=8.0
	RangeBasedAccelMaxDistance=512.0

}