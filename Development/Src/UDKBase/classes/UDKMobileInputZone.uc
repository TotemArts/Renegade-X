/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKMobileInputZone extends MobileInputZone;

/** Range around player that is considered a player touch */
var const float HoldPlayerDistance;

/** touches that are still being pressed down */
struct ActivePress
{
	var int Handle;
	var vector2d TouchLocation;
	var float TouchTime;
};
var array<ActivePress> CurrentPresses;

/** The location that was traced to when deprojecting the screen position to the world */
var transient Vector TraceHitLocation;

/** last thing we tapped (for detecting double tap) */
var transient Actor LastTappedActor;

/** The time in seconds of the last time we performed an untouch event */
var transient float TimeOfLastUntouch;

/** Amount of time that a touch has been held on the player pawn */
var transient float PlayerTouchStartTime;

/** Returns true if we are touching the player pawn */
function bool IsTouchingPlayerPawn()
{
	// HACK to check if we've touched the player pawn
	return (InputOwner.Outer.Pawn != None && VSize2D(TraceHitLocation - InputOwner.Outer.Pawn.Location) < HoldPlayerDistance);
}

/** Returns the actor that was traced to from projecting to the world */
function TraceFromScreenToWorld(Vector2D ScreenPos, out Actor outHitActor, out vector OutHitLocation, optional vector Extent = vect(32,32,32))
{
	local Actor HitActor, TestHitActor;
	local vector CameraLoc, CameraDir, HitLocation, TestHitLocation, HitNormal;

	LocalPlayer(InputOwner.Outer.Player).DeProject(ScreenPos, CameraLoc, CameraDir);

	// see what is underneath the tap location in the world
	foreach InputOwner.Outer.TraceActors(class'Actor', TestHitActor, TestHitLocation, HitNormal, CameraLoc + CameraDir * 8000.0, CameraLoc, Extent)
	{
		if (((!TestHitActor.bWorldGeometry && BlockingVolume(TestHitActor) == None) || HitActor == None) &&
			(TestHitActor.bBlockActors || TestHitActor.bProjTarget || TouchableElement3D(TestHitActor) != None) &&
			(Trigger(TestHitActor) == None) &&
			(Pawn(TestHitActor) == None || Pawn(TestHitActor).Health > 0))
		{
			HitActor = TestHitActor;
			HitLocation = TestHitLocation;
			if (!HitActor.bWorldGeometry && BlockingVolume(TestHitActor) == None)
			{
				break;
			}
		}
	}

	outHitActor = HitActor;
	OutHitLocation = HitLocation;
}

/** Handler for touch input */
function bool ProcessGameplayInput(MobileInputZone Zone, float DeltaTime, int Handle, ETouchType EventType, Vector2D TouchLocation)
{
	local Vector2D RelLocation, ViewportSize;
	local Actor TraceHitActor;
	local int PressIndex;
	local bool bRedundantInput;

	LocalPlayer(InputOwner.Outer.Player).ViewportClient.GetViewportSize(ViewportSize);

	// Get the screen space in terms of 0 to 1
	RelLocation.X = TouchLocation.X / ViewportSize.X;
	RelLocation.Y = TouchLocation.Y / ViewportSize.Y;
	// Project and trace to see what we hit
	TraceFromScreenToWorld(RelLocation, TraceHitActor, TraceHitLocation);

	// If this is a touch we don't want to do anything except do some bookkeeping
	// for delayed movement or double tapping
	if (EventType == Touch_Began)
	{
		PressIndex = CurrentPresses.Add(1);
		CurrentPresses[PressIndex].Handle = Handle;
		CurrentPresses[PressIndex].TouchLocation = TouchLocation;
		CurrentPresses[PressIndex].TouchTime = InputOwner.Outer.WorldInfo.TimeSeconds;
		if (CurrentPresses.length > 1)
		{
			PlayerTouchStartTime = -1.f;
		}
		else
		{
			// Check if we are touching the player pawn
			if (IsTouchingPlayerPawn())
			{
				PlayerTouchStartTime = InputOwner.Outer.WorldInfo.TimeSeconds;
			}
			else
			{
				PlayerTouchStartTime = -1.f;
			}
		}
	}
	else if (EventType == Touch_Ended || EventType == Touch_Cancelled)
	{
		PressIndex = CurrentPresses.Find('Handle', Handle);
		`Log(LastTappedActor @ TraceHitActor @ TimeOfLastUntouch @ InputOwner.MobileDoubleTapTime @ PressIndex);
		if (PressIndex != INDEX_NONE)
		{
			CurrentPresses.Remove(PressIndex, 1);
			// See if we tapped on something we can interact with
			if ( TraceHitActor != None && (TraceHitActor.bBlockActors || TraceHitActor.bProjTarget || TouchableElement3D(TraceHitActor) != None) &&
				Trigger(TraceHitActor) == None && (Pawn(TraceHitActor) == None || Pawn(TraceHitActor).Health > 0) )
			{
				// send double tap on world geometry for area skills but not single tap
				if ( LastTappedActor == TraceHitActor &&
						InputOwner.Outer.WorldInfo.TimeSeconds < TimeOfLastUntouch + InputOwner.MobileDoubleTapTime )
				{
					if (TouchableElement3D(TraceHitActor) != None)
					{
						TouchableElement3D(TraceHitActor).HandleDoubleClick();
					}
				}
				else if (!TraceHitActor.bWorldGeometry && BlockingVolume(TraceHitActor) == None)
				{
					if (PlayerTouchStartTime < 0.f)
					{
						if (TouchableElement3D(TraceHitActor) != None)
						{
							TouchableElement3D(TraceHitActor).HandleClick();
						}
					}
				}
			}

			PlayerTouchStartTime = -1.f;
		}

		TimeOfLastUntouch = InputOwner.Outer.WorldInfo.TimeSeconds;
	}
	else if (EventType == Touch_Moved || EventType == Touch_Stationary)
	{
		PressIndex = CurrentPresses.Find('Handle', Handle);
		if (PressIndex != INDEX_NONE)
		{
			// if this is a duplicate input, ignore it
			if (CurrentPresses[PressIndex].TouchLocation == TouchLocation && CurrentPresses[PressIndex].TouchTime == InputOwner.Outer.WorldInfo.TimeSeconds)
			{
				bRedundantInput = true;
			}
			else
			{
				CurrentPresses[PressIndex].TouchLocation = TouchLocation;
				CurrentPresses[PressIndex].TouchTime = InputOwner.Outer.WorldInfo.TimeSeconds;
			}
		}

		if (!bRedundantInput)
		{
			// Next see if we tapped on something we can interact with
			if ( EventType == Touch_Moved && TouchableElement3D(TraceHitActor) != None )
			{
				TouchableElement3D(TraceHitActor).HandleDragOver();
			}
		}
	}
	LastTappedActor = TraceHitActor;

	// If we aren't touching the player pawn, clear PlayerTouchStartTime
	if ( !IsTouchingPlayerPawn() )
	{
		PlayerTouchStartTime = -1.f;
	}

	return false;
}

defaultproperties
{
	OnProcessInputDelegate=ProcessGameplayInput

	HoldPlayerDistance=150.f
}