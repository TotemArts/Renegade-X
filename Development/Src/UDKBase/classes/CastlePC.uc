/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class CastlePC extends SimplePC;

/** Set to true to suppress the splash screen */
var config bool bSuppressSplash;

/** will be true once the splash screen has been shown */
var bool bSplashHasBeenShown;

/** If True then we are in attract mode */
var bool bIsInAttractMode;

/** If True then we are in benchmark mode */
var bool bIsInBenchmarkMode;

/** If True, then a full flythrough loop has been completed in benchmark mode */
var bool bBenchmarkLoopCompleted;

/** Track the number of frames and the elapsed time while in benchmark mode to get average frame rate */
var int BenchmarkNumFrames;
var float BenchmarkElapsedTime;

/** Have we triggered the initial fading out of the Controls Help Menu */
var bool bDoneInitialFade;

var MobileMenuPause PauseMenu;	// The Pause menu
var MobileMenuDebug DebugMenu;  // The Debug menu

var bool bPauseMenuOpen;
var bool bAutoSlide;

var float SliderStart, SliderEnd;
var float SliderTravelTime;
var float SliderTravelDuration;

var float AutoAttractTime;

var SoundCue OpenMenuSound;
var SoundCue CloseMenuSound;

var MobileMenuControls TutMenu;


/*************************************
 Tap to Move
 ************************************/

/** How far the player must have moved within the last 0.5 seconds before we consider them 'stuck' and
    abort automatic movement */
var float StuckThreshHold;

/** Scalar that sets how much the camera should pitch up and down to match the tap-to-move target */
var float TapToMoveAutoPitchAmount;

/** Mesh to use for 'tap to move' visual cue in the world */
var StaticMesh TapToMoveVisualMesh;

/** Minimum distance from destination before visual cue will vanish */
var float TapToMoveVisualMinDist;

/** How fast the visual cue should rotate every frame */
var float TapToMoveVisualRotateSpeed;

/** Length of visual cue animation effect */
var float TapToMoveVisualAnimDuration;

/** Holds the destination we are moving towards */
var vector TapToMoveDestination;

/** We use this to see if we are stuck */
var float LastDistToDestination;

/** Time that tap to move visual effect started */
var float TapToMoveVisualEffectStartTime;

/** Time that tap to move visual effect ended */
var float TapToMoveVisualEffectEndTime;

var SoundCue TapToMoveSound;
var SoundCue InvalidTapToMoveSound;
var SoundCue TapToMoveStopSound;

/** Spawned actor for 'tap to move' visual cue */
var KActorSpawnable TapToMoveVisualActor;

/*************************************
 Tutorial
 ************************************/

enum ETutorialStage
{
	ETS_None,
	ETS_Tap,
	ETS_Swipe,
	ETS_Sticks,
	ETS_Done,
};

var ETutorialStage TutorialStage;

/** Cached reference to the Tutorial Look Zone */
var MobileInputzone TutorialLookZone;


/**
 * Setup the in world indicator for tap to move and some other subsystems
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Kill existing 'tap to move' actor, if any
	if( TapToMoveVisualActor != None )
	{
		TapToMoveVisualActor.Destroy();
	}

	// Spawn our 'tap to move' visual cue actor
	TapToMoveVisualActor = Spawn( class'KActorSpawnable',self,,,,,true);
	TapToMoveVisualActor.SetCollision( false, false, true );	// Disable collision
	TapToMoveVisualActor.SetHidden( true );
	TapToMoveVisualActor.SetDrawScale3D( vect( 1, 1, 5 ) );
	TapToMoveVisualActor.StaticMeshComponent.SetStaticMesh( TapToMoveVisualMesh );
	TapToMoveVisualActor.SetPhysics( PHYS_None );
}

/**
 * Make sure we destory the visual tap actor
 */
event Destroyed()
{
	// Kill existing 'tap to move' actor, if any
	if( TapToMoveVisualActor != None )
	{
		TapToMoveVisualActor.Destroy();
	}

	super.Destroyed();
}


/** 
 * An event that is called after the first tick of GEngine.  We are going to hijack this for 
 * initialization purposes.
 */
event OnEngineInitialTick()
{
	// If we are in preview mode, then skip the flyby, splash and tutorial
	if (WorldInfo.IsPlayInPreview() || WorldInfo.IsPlayInEditor())
	{
		// Setup some of the default states
		TutorialStage = ETS_Done;
		ActivateControlGroup();
		ResetMenu();
	}
	else
	{
		// trigger Epic Citadel map stuff (see Kismet in EpicCitadel map)
		CauseEvent('IntroCam');
		ConsoleCommand("mobile playsong town_render");

		// set up handling of Android back button (does nothing on non-Android)
		MobileHudExt(myHUD).NotifyEngineOfBackButtonHandling();
	}
}


/**
 * The main purpose of this function is to size and reset zones.  There's a lot of specific code in
 * here to reposition zones based on if it's an phone vs pad.
 */
function SetupZones()
{
	local MobileInputZone Zone;
	local float Ratio;

	Super.SetupZones();

	// If we have a game class, configure the zones
	if (MPI != None && WorldInfo.GRI.GameClass != none) 
	{
		// Find the button zone that exits attract mode.
		Zone = MPI.FindZone("ExitAttractModeZone");
		if (Zone != none)
		{
			Zone.OnTapDelegate = ExitAttractTap;
		}
		
		// Find the tap to move zone and setup the tutorial
		Zone = MPI.FindZone("TapTutorialZone");
		if (Zone != none)
		{
			Zone.OnTapDelegate = TapToMoveTap;
		}
		else
		{
			`log("!!!WARNING!!!  Tutorial will be broken due to Tap");
		}

		// Find the look zone and setup the tutorial
		TutorialLookZone = MPI.FindZone("SwipeTutorialZone");
		if (TutorialLookZone == none)
		{
			`log("!!!WARNING!!!  Tutorial will be broken due to Swipe");
		}

		// If we aren't supressing the splash screen, setup the pause menu
		if (!bSuppressSplash)
		{
			PauseMenu = MobileMenuPause(MPI.OpenMenuScene(class'MobileMenuPause'));
			SliderZone = MPI.FindZone("MenuSlider");
			if (SliderZone != none)
			{
				SliderZone.OnTapDelegate = MenuSliderTap;
				SliderZone.OnProcessSlide = ProcessMenuSlide;
				SliderZone.SizeY = PauseMenu.Height;
			}
		}

	
		Ratio = ViewportSize.Y / ViewportSize.X;

		// Find the zone and hook up the delegate so we can perform tap to move
		Zone = MPI.FindZone("TapToMoveZone");
		if (Zone != none)
		{
			Zone.OnTapDelegate = TapToMoveTap;
		}

		if (FreeLookZone != none)
		{
			FreeLookZone.OnTapDelegate = TapToMoveTap;
			if (Ratio == 0.75 || ViewportSize.X <= 480)
			{
				FreeLookZone.VertMultiplier *= 1.75;
				FreeLookZone.HorizMultiplier *= 3.25;
				FreeLookZone.Acceleration *= 0.5;
			}
		}

		// Setup the timer to check for inactivity / attract mode
		//SetTimer(1.0,true,'CheckInactivity');

		// Setup a timer that will write out controller stats every 60 seconds.
		SetTimer(60.0,true,'SaveControllerStats');

		// Activate the input group for the flyby (ie: no input)
		if (MPI != none)
		{
			MPI.ActivateInputGroup("InitialFlybyGroup");
		}
	}
}

/** 
 * Saves out the controller stats for processing
 */
function SaveControllerStats()
{
	if ((StickLookZone != none) && (StickMoveZone != none) && (FreeLookZone != none))
	{
		ConsoleCommand("mobile recordcontrolstats" @ StickMoveZone.TotalActiveTime @ StickLookZone.TotalActiveTime @ FreeLookZone.TotalActiveTime @ TotalTimeInTapToMove @ NoTapToMoves);
		
		StickMoveZone.TotalActiveTime = 0;
		StickLookZone.TotalActiveTime = 0;
		FreeLookZone.TotalActiveTime = 0;
	}

	TotalTimeInTapToMove = 0;
	NoTapToMoves = 0;
}

/**
 * Every second, we look at various metrics to see if the player has been active.  If they haven't been, then
 * we want switch to attract mode 
 */
function CheckInactivity()
{
	// Quick out if we don't allow attract mode
	if (CastleGame(WorldInfo.Game) == none || CastleGame(WorldInfo.Game).bAllowAttractMode == false)
	{
		return;
	}

	//if the pause menu is open, or a submenu is open
	if ( LocalPlayer(Player).ViewportClient.bDisableWorldRendering || (PauseMenu != none && bPauseMenuOpen) || bIsInAttractMode || bCinematicMode || (MPI.MobileMenuStack.Length>1 && TutMenu == none))
	{
		MPI.MobileInactiveTime = 0;
	}

	// Make the call...
	if (MPI.MobileInactiveTime > AutoAttractTime && !bIsInAttractMode && !bCinematicMode)
	{
		EnterAttractMode();
	}
}

/** 
 * Trace, but ignore volumes and triggers unless they are blockers (i.e. BlockingVolume) 
 *
 * @param TraceOwner is the player's pawn
 * @param HitLocation holds the location were the trace ends
 * @param HitNormal holds the orientation of the surface normal where it hit
 * @param End is where we would like the trace to end
 * @param Start is where the trace is starting from
 */
simulated function Actor TraceForTapToMove(Pawn TraceOwner, out vector HitLocation, out vector HitNormal, vector End, vector Start)
{
	local Actor HitActor;
	local vector HitLoc, HitNorm;
	local TraceHitInfo HitInfo;

	// Iterate over each actor along trace...
	foreach TraceOwner.TraceActors(class'Actor', HitActor, HitLoc, HitNorm, End, Start, , HitInfo,TRACEFLAG_Bullet)
	{
		// if it's not a trigger or a volume, use it!
		if ( (HitActor.bBlockActors || HitActor.bWorldGeometry) && (Volume(HitActor) == None && Trigger(HitActor)==None))
		{
			HitLocation = HitLoc;
			HitNormal  =HitNorm;
			return HitActor;
		}
	}

	// Found nothing non-volume or -trigger like :(
	return None;
}


/**
 * This is our event handler for taps.
 *
 * @param Zone			The Zone we are managing
 * @param EventType		The type of event that occurred
 * @param TouchLocation	Where was the touch
 */
function bool TapToMoveTap(MobileInputZone Zone, ETouchType EventType, Vector2D TouchLocation)
{
	local Vector2D RelLocation;
	local Vector Origin, Direction, Destination;
	local Vector HitLocation, HitNormal;
	local Actor HitActor;
	local bool bWantReverse;
	local bool bValidDestination;
	
	// Don't perform these traces if if are in attract mode, playing a cinematic or if the movement stick is
	// currently active.
	if( !bIsInAttractMode && !bCinematicMode && StickMoveZone.State == ZoneState_Inactive )
	{
		// Figure out the location relative to the current viewport
		RelLocation.X = TouchLocation.X / ViewportSize.X;
		RelLocation.Y = TouchLocation.Y / ViewportSize.Y;

		// Check to see if the user touched near the very bottom of the viewport
		bWantReverse = false; //( RelLocation.Y >= 0.85 );

		// If the user clicked near the bottom of the viewport and is already moving toward a destination,
		// then cancel the movement in progress.  Basically, clicking near the bottom of the viewport is
		// used to stop moving.
		if( bWantReverse && IsInState('PlayerTapToMove') )
		{
			// Draw an effect on the HUD
			MobileHudExt( MyHud ).StartTapToMoveEffect( TouchLocation.X, TouchLocation.Y );

			// Play a 'move stopped' sound effect
			PlaySound( TapToMoveStopSound );

			// Cancel touch to move
			GotoState('PlayerWalking');
		}
		else
		{
			NoTapToMoves++;

			// If we're reversing then flip the touch point along the horizontal axis so we'll walk backwards
			// in the expected direction
			if( bWantReverse )
			{
				RelLocation.x = 1.0 - RelLocation.x;
			}

			// Deproject and get the world location
			LocalPlayer(Player).Deproject(RelLocation, Origin, Direction);

			// If we're reversing then choose a location behind the player a little bit
			if( bWantReverse )
			{
				Direction.Z = 0.0f;
				Destination = Origin - Direction * 512;
			}
			else
			{
				// Moving forward, so cast a way straight out far into the scene
				Destination = Origin + (Direction * 10240);
			}

			// Now trace in to the world and get where to go.
			HitActor = TraceForTapToMove(Pawn, HitLocation, HitNormal, Destination, Origin);
			if (HitActor != none)
			{
				Destination = HitLocation + (HitNormal * Pawn.GetCollisionHeight() * 2);
			}
			if (!PointReachable(Destination))
			{
				// Still not reachable.  Then find the ground and see if we can move there.
				Origin = Destination;
				Destination.Z = -65535;
				
				HitActor = TraceForTapToMove(Pawn, HitLocation, HitNormal, Destination, Origin);
				if (HitActor != none)
				{
					// We hit the ground, step back the collision Height;
					Destination = HitLocation;
					Destination.Z += Pawn.GetCollisionHeight();
				}
			}

			// Unless we're reversing, if the desired location is somehow behind the player then fail the movement
			if( bWantReverse )
			{
				bValidDestination = true;
			}
			else
			{
				bValidDestination = ( ( Normal( Destination - Pawn.Location ) dot Vector( Pawn.Rotation ) ) > 0.25 );
			}

			// If the desired location is very close to the player then fail the movement
			if( ( VSize2D( Destination - Pawn.Location ) < 128.0 ) )
			{
				bValidDestination = false;
			}

			
			if( bValidDestination )
			{
				// Play a 'move succeeded' sound effect
				PlaySound( TapToMoveSound );

				// Draw an effect on the HUD
				MobileHudExt( MyHud ).StartTapToMoveEffect( TouchLocation.X, TouchLocation.Y );

				// Start moving to the new destination!
				DoTapToMove( Destination, !bWantReverse );	// Don't auto-look at destination when reversing
			}
			else
			{
				// Play a 'move failed' sound effect
				PlaySound( InvalidTapToMoveSound );

				// Cancel an existing tap-to-move action, if there is one in progress
				if( IsInState('PlayerTapToMove') )
				{
					GotoState('PlayerWalking');
				}
			}
		}
	}

	return true;
}

/**
 * The player has clicked on a spot.  Start the move
 *
 * @param NewDestination			Where do we want to move to
 * @param bShouldLookAtDestination	True if we should also automatically look toward the destination
 */
function DoTapToMove( vector NewDestination, bool bShouldLookAtDestination )
{
	// Update position of tap to move visual cue
	TapToMoveVisualActor.SetLocation( NewDestination + vect( 0, 0, 6 ) );	// Raise up a bit
	TapToMoveVisualActor.SetHidden( false );
	TapToMoveVisualEffectStartTime = WorldInfo.RealTimeSeconds;

	TapToMoveDestination = NewDestination;
	LastDistToDestination = VSize(Pawn.Location - TapToMoveDestination);

	if( bShouldLookAtDestination )
	{
		// Start automatically orientating toward the target point
		PlayerLookAtDestination();
	}
	
	GotoState('PlayerTapToMove');
}

/**
 * Initialize the look at system to point to the destination.                                                                     
 */
function PlayerLookAtDestination()
{
	if( !bLookAtDestination )
	{
		// Start rotating!
		bLookAtDestination = true;
	}

	// Reset the time of last view change so that we're guaranteed to start looking toward the destination,
	// even if the user dragged the view right before touching to move
	TimeOfLastUserViewChange = 0;
}

/** 
 * Tap to Move requires it's own special state for the player controller
 */
state PlayerTapToMove
{
	/**
	 * Setup the auto-rotate towards the destination                                                                     
	 */
	event BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		LastEnteredTapToMove = WorldInfo.RealTimeSeconds;

		// If we are in the tutorial, skip to the next step
		if (TutorialStage == ETS_Tap)
		{
			TutMenu.FadeOut();
			TutMenu = MobileMenuControls(MPI.OpenMenuScene(class'UDKBase.MobileMenuControls'));
			TutMenu.Setup(false);
			MPI.ActivateInputGroup("SwipeTutorialGroup");
			TutorialStage = ETS_Swipe;
		}

	}

	/**
	 * Close everything down.                                                                     
	 */
	event EndState(Name NextStateName)
	{
		// Track Stats
		TotalTimeInTapToMove += WorldInfo.RealTimeSeconds - LastEnteredTapToMove;

		Super.EndState(NextStateName);

		// Turn off the check to see if we are stuck
		Cleartimer('CheckIfStuck');

		// Stop automatically orientating toward the target point
		bLookAtDestination = false;

		// Start hiding the visual cue if we haven't already
		if( TapToMoveVisualEffectEndTime < TapToMoveVisualEffectStartTime )
		{
			TapToMoveVisualEffectEndTime = WorldInfo.RealTimeSeconds;
		}
	}

	/**
	 * Check to see if the player is stuck.  This is called every 1/2 second.  It just looks to see if you have most past a threshold since
	 * the last check and if not, considers you stuck.
	 * 
	 * We also use this event to determine if enough time has passed that we should start auto-rotating again
	 */
	event CheckIfStuck()
	{
		local Float DistToDestination;

		DistToDestination = VSize(Pawn.Location - TapToMoveDestination);
		if (LastDistToDestination - DistToDestination < StuckThreshHold)
		{
			GotoState('PlayerWalking');
		}
		else
		{
			LastDistToDestination = DistToDestination;
		}
	}

	/**
	 * Each frame, look to see if the player has decided to use the virtual stick to move.  If they have,
	 * we want to abort tap to move.
	 */
	function PlayerTick(float DeltaTime)
	{

		if (IsStickMoveActive())
		{
			GotoState('PlayerWalking');
		}
		Global.PlayerTick(DeltaTime);
	}

Begin:
	// Check to see if we're not making progress every so often
	SetTimer( 0.5, true, 'CheckIfStuck' );

	// while we have a valid pawn and move target, and
	// we haven't reached the target yet
	while (Pawn != None && !Pawn.ReachedPoint(TapToMoveDestination,none))
	{
		MoveToDirectNonPathPos(TapToMoveDestination,,1,true);
	}

	GotoState('PlayerWalking');
}


/**
 * Called from PlayerMove, it's here that we adjust the viewport                                                                     
 */
function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
	local float AnimProgress;
	local vector NewDrawScale;

	// If we are looking at a desintation, preset it for the super to manage
	if( bLookAtDestination )
	{
		LookAtDestination = TapToMoveDestination - Pawn.Location;
		LookAtDestAutoPitchAmount = TapToMoveAutoPitchAmount;
	}

	Super.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot);

	// Animate the tap-to-move visual cue
	if( TapToMoveVisualEffectEndTime < TapToMoveVisualEffectStartTime )
	{
		// We're fading in!
		AnimProgress = 1.0 - FMin( ( WorldInfo.RealTimeSeconds - TapToMoveVisualEffectStartTime ) / TapToMoveVisualAnimDuration, 1.0 );
		AnimProgress = FInterpEaseInOut( 0.0, 1.0, AnimProgress, 1.5 );

		TapToMoveVisualActor.SetRotation( TapToMoveVisualActor.Rotation + MakeRotator( 0, DeltaTime * ( TapToMoveVisualRotateSpeed + 8.0 * AnimProgress * TapToMoveVisualRotateSpeed ), 0 ) );
	}
	else
	{
		// We're fading out!
		AnimProgress = FMin( ( WorldInfo.RealTimeSeconds - TapToMoveVisualEffectEndTime ) / TapToMoveVisualAnimDuration, 1.0 );
		AnimProgress = FInterpEaseInOut( 0.0, 1.0, AnimProgress, 1.5 );

		TapToMoveVisualActor.SetRotation( TapToMoveVisualActor.Rotation + MakeRotator( 0, DeltaTime * ( 1.0 - AnimProgress ) * TapToMoveVisualRotateSpeed, 0 ) );

		if( AnimProgress >= 1.0 )
		{
			// Hide the actor now that we're finished transitioning
			TapToMoveVisualActor.SetHidden( true );
		}
	}
	NewDrawScale.X = 1.0 - AnimProgress * 1.0;			// Squash to zero from normal size
	NewDrawScale.Y = 1.0 + AnimProgress * 0.5;			// Grow to slightly bigger size
	NewDrawScale.Z = 1.25 - AnimProgress * 1.25;		// Squash to zero from bigger size
	TapToMoveVisualActor.SetDrawScale3D( NewDrawScale );
}

/**
 * If we're very close to the target, then go ahead and hide the visual cue
 */
simulated function CheckDistanceToDestination(float DistToDestination)
{
	
	if( DistToDestination < TapToMoveVisualMinDist )
	{
		if( TapToMoveVisualEffectEndTime < TapToMoveVisualEffectStartTime )
		{
			TapToMoveVisualEffectEndTime = WorldInfo.RealTimeSeconds;
		}
	}
}


/** 
 * notification when a matinee director track starts or stops controlling the ViewTarget of this PlayerController 
 * 
 * @param bNowControlling will be true if we are back in control
 */
event NotifyDirectorControl(bool bNowControlling, SeqAct_Interp CurrentMatinee)
{
	super.NotifyDirectorControl(bNowControlling, CurrentMatinee);
	if( bNowControlling )
	{
		// Make sure our tap-to-move actor is hidden
		TapToMoveVisualActor.SetHidden( true );
	}
}

/**
 * Enter attrack mode.  We need to make sure we kill any active menus/etc.
 */
exec function EnterAttractMode( bool BeginBenchmarking = false )
{
	// Make sure we're not currently auto-moving to a destination
	if( IsInState('PlayerTapToMove') )
	{
		GotoState('PlayerWalking');
	}

	// Kill the tutorial menu
	if (TutMenu != none)
	{
		TutMenu.FadeOut();
		TutMenu = none;
		MPI.ActivateInputGroup("UberGroup");
		MobileHudExt(myHUD).FlashSticks();
		TutorialStage = ETS_Done;
	}

	// Hide the on screen help if it's there
	if (PauseMenu != none)
	{
		PauseMenu.ReleaseHelp();
	}

	// Go in to attract mode
	CauseEvent('PlayMatinee');
	bIsInAttractMode = true;

	bIsInBenchmarkMode = BeginBenchmarking;
	bBenchmarkLoopCompleted = false;
	BenchmarkNumFrames = 0;
	BenchmarkElapsedTime = 0.0;

	ResetMenu();
	MPI.ActivateInputGroup("AttractGroup");
}

exec function OnFlyThroughLoopCompleted()
{
	// Set the benchmark loop completed flag so that we can calculate and display the results of the benchmark fly through
	bBenchmarkLoopCompleted = true;
}

/**
 * Leave attract mode 
 */
exec function ExitAttractMode()
{
	if (bIsInBenchmarkMode)
	{
		PauseMenu.InputOwner.Outer.ConsoleCommand("mobile benchmark end");
	}
	bIsInAttractMode = false;
	bIsInBenchmarkMode = false;
	bBenchmarkLoopCompleted = false;
	MPI.MobileInactiveTime = 0;
	CauseEvent('StopMatinee');
	ActivateControlGroup();
	ResetMenu();
}

/**
 * Delegate that gets called when the exit attact mode button is tapped
 */
function bool ExitAttractTap(MobileInputZone Zone, ETouchType EventType, Vector2D TouchLocation)
{
	ExitAttractMode();
	PauseMenu.SetDefaultUI(); // set the correct UI
	return true;
}

/**
 * Automatically slide to a new location                                                                     
 */
function AutoSlide(float Destination)
{
	SliderStart = SliderZone.CurrentLocation.Y;
	SliderEnd = Destination;
	SliderTravelTime = 0;
	bAutoSlide = true;
}

/**
 * Reset the pause menu
 */
function ResetMenu()
{
	if (bPauseMenuOpen)
	{
		PauseMenu.OnResetMenu();	
		AutoSlide(SliderZone.Y);
		bPauseMenuOpen = false;
		PlaySound( CloseMenuSound );
	}
}

/**
 * Force the Pause Menu to open                                                                     
 */
function OpenMenu()
{
	if (!bPauseMenuOpen)
	{
		bPauseMenuOpen = true;
		AutoSlide(PauseMenu.ShownSize);
		PlaySound( OpenMenuSound );
	}
}

/**
 * Depending on the state of the pause menu, a tap on it's nub will either auto-open or auto-close it. 
 * This delegate manages the tap.
 */
function bool MenuSliderTap(MobileInputZone Zone, ETouchType EventType, Vector2D TouchLocation)
{
	if (bPauseMenuOpen)
	{
		ResetMenu();
	}
	else
	{
		OpenMenu();
	}

	return true;
}

/** 
 * When you touch and drag on the nub, this code determines what to do.
 */
function bool ProcessMenuSlide(MobileInputZone Zone, ETouchType EventType, int SlideValue, Vector2D ViewportSizes)
{
	// Align the menu to the touch.
	PauseMenu.Top = Zone.CurrentLocation.Y - PauseMenu.Height;
	// somehow the zone size is being reset (on device, but not PC), so this just fixes it. mildly hacky, but no real penalty.
	Zone.SizeY = PauseMenu.Height;

	// If we are releasing the menu, see if we need to reset, or if we need to open
	if (EventType == Touch_Ended && !bPauseMenuOpen)
	{
		if (Zone.CurrentLocation.Y >= PauseMenu.ShownSize)
		{
			OpenMenu();
		}
		else
		{
			AutoSlide(SliderZone.Y);
		}
	}

	return true;
}

/**
 * Handle any animations and time criticl code
 */
function PlayerTick(float DeltaTime)
{
	local int SettingsLocationX;

	Super.PlayerTick(DeltaTime);

	if (TutorialStage == ETS_Swipe)
	{
		if (TutorialLookZone.State != ZoneState_Inactive)
		{
			TutMenu.FadeOut();
			TutMenu = none;
			MPI.ActivateInputGroup("UberGroup");
			MobileHudExt(myHUD).FlashSticks();
			TutorialStage = ETS_Done;
		}
	}

	// Trigger the fading of the Controls Help screen that we bring up on map load
	if ( !bDoneInitialFade )
	{
		// @todo: Disabled this for intermediate demo; Consider re-enabling later.
		// PauseMenu.FadeOutControlsMenu();
		bDoneInitialFade = TRUE;
	}

	// Handle the menu sliding back in to place
	if (bAutoSlide)
	{
		SliderZone.CurrentLocation.Y = FInterpEaseInOut(SliderStart,SliderEnd, SliderTravelTime/SliderTravelDuration,3.0);
		SliderTravelTime += DeltaTime;
		if (SliderTravelTime >= SliderTravelDuration)
		{
			SliderZone.CurrentLocation.Y = SliderEnd;
			bAutoSlide = false;

			if (!bPauseMenuOpen)
			{
				if (bIsInAttractMode)
				{
					PauseMenu.SetAttractModeUI(bIsInBenchmarkMode);
				}
				else
				{
					PauseMenu.SetDefaultUI();
				}
			}
		}
		PauseMenu.Top = SliderZone.CurrentLocation.Y - PauseMenu.Height;
	}

	// Only pull out the settings menu if it's available (only Android)
	if (PauseMenu.MenuObjects.length >= 5)
	{
		SettingsLocationX = FInterpEaseInOut(MyHUD.SizeX, PauseMenu.Width - PauseMenu.MenuObjects[4].Width + 2, FClamp(SliderZone.CurrentLocation.Y / (PauseMenu.ShownSize - SliderZone.Y), 0.0, 1.0), 3.0);
		PauseMenu.MenuObjects[4].Left = SettingsLocationX;
	}

	// If we are currently benchmarking, track the number of frames and elapsed time.  
	// Note that this assumes a TimeDilation of 1.0 and doesn't properly handle the cases where DeltaTime is clamped because it was super long or super short, but in EpicCitadel benchmark mode these shouldn't be problems in practice.
	if( bIsInBenchmarkMode && !bBenchmarkLoopCompleted )
	{
		BenchmarkNumFrames += 1;
		BenchmarkElapsedTime += DeltaTime;
	}

	// Check to handle back button on Android
	if (MobileHudExt(myHUD).HandleBackButtonPressed())
	{
		// Exit flythrough if in it
		if (bIsInBenchmarkMode || bIsInAttractMode)
		{
			ExitAttractMode();
			PauseMenu.SetDefaultUI(); // set the correct UI
		}
		else // else revert to calling back to engine for exit prompt
		{
			MobileHudExt(myHUD).RequestExitDialog();
		}
	}
}

/**
 * Show the splash screen 
 */
exec function ShowSplash()
{
	// Activate the tutorial input group then show the splash
	MPI.ActivateInputGroup("TapTutorialGroup");
	if (!bSplashHasBeenShown && !bSuppressSplash && MPI != none)
	{
		bSplashHasBeenShown = true;
		MPI.OpenMenuScene(class'UDKBase.MobileMenuSplash');
	}
}

/**
 * Display the control help on the screen 
 */
exec function FlashHelp(float Duration)
{
	if (!bPauseMenuOpen)
	{
		PauseMenu.FlashHelp(Duration);
	}
}

/**
 * Start the tutorials 
 */
function StartTutorials()
{
	TutMenu = MobileMenuControls(MPI.OpenMenuScene(class'UDKBase.MobileMenuControls'));
	TutMenu.Setup(true);
	TutorialStage = ETS_Tap;
}

exec function SetFootstepsToStone()
{
	FootstepSounds[0]=none;	// SoundCue'CastleAudio.Player.Footstep_Walk_01_Cue';
	FootstepSounds[1]=none;	// SoundCue'CastleAudio.Player.Footstep_Walk_02_Cue';
	FootstepSounds[2]=none;	// SoundCue'CastleAudio.Player.Footstep_Walk_03_Cue';
	FootstepSounds[3]=none;	// SoundCue'CastleAudio.Player.Footstep_Walk_04_Cue';
	FootstepSounds[4]=none;	// SoundCue'CastleAudio.Player.Footstep_Walk_05_Cue';
	FootstepSounds[5]=none;	// SoundCue'CastleAudio.Player.Footstep_Walk_06_Cue';
}

exec function SetFootstepsToSnow()
{
	FootstepSounds[0]=none;	// SoundCue'CastleAudio.Player.Footstep_Snow01_Cue';
	FootstepSounds[1]=none;	// SoundCue'CastleAudio.Player.Footstep_Snow02_Cue';
	FootstepSounds[2]=none;	// SoundCue'CastleAudio.Player.Footstep_Snow03_Cue';
	FootstepSounds[3]=none;	// SoundCue'CastleAudio.Player.Footstep_Snow04_Cue';
	FootstepSounds[4]=none;	// SoundCue'CastleAudio.Player.Footstep_Snow05_Cue';
	FootstepSounds[5]=none;	// SoundCue'CastleAudio.Player.Footstep_Snow06_Cue';
}




defaultproperties
{
	StuckThreshHold=25
	TapToMoveAutoPitchAmount=0.25
	TapToMoveVisualMesh=none	// StaticMesh'CastleEffects.TouchToMoveArrow'
	TapToMoveVisualMinDist=230
	TapToMoveVisualRotateSpeed=100000
	TapToMoveVisualAnimDuration=0.3

	AutoAttractTime=45
	TapToMoveSound=none	// SoundCue'CastleAudio.UI.UI_TouchToMove_Cue'
	InvalidTapToMoveSound=none	// SoundCue'CastleAudio.UI.UI_InvalidTouchToMove_Cue'
	TapToMoveStopSound=none	// SoundCue'CastleAudio.UI.UI_StopTouchToMove_Cue'
	OpenMenuSound=none	// SoundCue'CastleAudio.UI.UI_MainMenu_Cue'
	CloseMenuSound=none	// SoundCue'CastleAudio.UI.UI_OK_Cue'
	bSplashHasBeenShown=false
	
	SliderTravelDuration=0.3
	TutorialStage=ETS_None

	FootstepSounds(0)=none	// SoundCue'CastleAudio.Player.Footstep_Walk_01_Cue'
	FootstepSounds(1)=none	// SoundCue'CastleAudio.Player.Footstep_Walk_02_Cue'
	FootstepSounds(2)=none	// SoundCue'CastleAudio.Player.Footstep_Walk_03_Cue'
	FootstepSounds(3)=none	// SoundCue'CastleAudio.Player.Footstep_Walk_04_Cue'
	FootstepSounds(4)=none	// SoundCue'CastleAudio.Player.Footstep_Walk_05_Cue'
	FootstepSounds(5)=none	// SoundCue'CastleAudio.Player.Footstep_Walk_06_Cue'
}
