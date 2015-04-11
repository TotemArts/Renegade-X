/**
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTConsolePlayerController extends UTPlayerController
	config(Game);

/** Whether TargetAdhesion is enabled or not **/
var() config bool bTargetAdhesionEnabled;

var config protected bool bDebugTargetAdhesion;

// @todo amitt update this to work with version 2 of the controller UI mapping system
struct native ProfileSettingToUE3BindingDatum
{
	var name ProfileSettingName;
	var name UE3BindingName;

};

var array<ProfileSettingToUE3BindingDatum> ProfileSettingToUE3BindingMapping360;
var array<ProfileSettingToUE3BindingDatum> ProfileSettingToUE3BindingMappingPS3;

/**
 * We need to override this function so we can do our adhesion code.
 *
 * Would be nice to have have a function or something be able to be inserted between the set up
 * and processing.
 **/
function UpdateRotation( float DeltaTime )
{
	local Rotator	DeltaRot, NewRotation, ViewRotation;

	ViewRotation	= Rotation;
	if (Pawn!=none)
	{
		Pawn.SetDesiredRotation(ViewRotation); //save old rotation
	}

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw	= PlayerInput.aTurn;
	DeltaRot.Pitch	= PlayerInput.aLookUp;


	// NOTE:  we probably only want to ApplyTargetAdhesion when we are moving as it hides the Adhesion a lot better
	if( ( bTargetAdhesionEnabled )
		&& ( Pawn != none )
		&& ( PlayerInput.aForward != 0 )
		)
	{
		UTConsolePlayerInput(PlayerInput).ApplyTargetAdhesion( DeltaTime, UTWeapon(Pawn.Weapon), DeltaRot.Yaw, DeltaRot.Pitch );
	}


	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );

	SetRotation( ViewRotation );

	ViewShake( DeltaTime );

	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if( Pawn != None )
	{
		Pawn.FaceRotation(NewRotation, DeltaTime);
	}
}

function bool AimingHelp(bool bInstantHit)
{
	// bUsingGamepad is updated every time we do an input based on what was used to make that input
	//return PlayerInput.bUsingGamepad;
	// @fixme this needs to eventually use the above line and also have some client to server communication where
	// the client tells the server if they have ever used a keyboard/mouse.  The idea being:  once they have "cheated" then
	// they never will get aiming help again.  Doing it this way reduces the amount of server messages we need to have
	return true;
}

/**
* @returns the distance from the collision box of the target to accept aiming help (for instant hit shots)
*/
function float AimHelpModifier()
{
	return (FOVAngle < DefaultFOV - 8) ? 0.75 : 1.0;
}

simulated function bool PerformedUseAction()
{
	if ( Super.PerformedUseAction() )
	{
		return true;
	}
	else if ( (Role == ROLE_Authority) && !bJustFoundVehicle )
	{
		// console smart use - bring out hoverboard if no other use possible
		ClientSmartUse();
		return true;
	}
	return false;
}

unreliable client function ClientSmartUse()
{
	ToggleTranslocator();
}

reliable client function ClientRestart(Pawn NewPawn)
{
	Super.ClientRestart(NewPawn);

	// we never want the tilt thing on when using UTPawns

	if (UTPawn(NewPawn) != None)
	{
		SetOnlyUseControllerTiltInput(false);
		SetUseTiltForwardAndBack(true);
		SetControllerTiltActive(false);
	}
}

exec function PrevWeapon()
{
	if (Pawn == None || Vehicle(Pawn) != None)
	{
		if ( UDKVehicleBase(Pawn) != None )
		{
			UDKVehicleBase(Pawn).AdjacentSeat(-1, self);
		}
	}
	else if (!Pawn.IsInState('FeigningDeath'))
	{
		Super.PrevWeapon();
	}
}

exec function NextWeapon()
{
	if (Pawn == None || Vehicle(Pawn) != None)
	{
		if ( UDKVehicleBase(Pawn) != None )
		{
			UDKVehicleBase(Pawn).AdjacentSeat(1, self);
		}
	}
	else if (!Pawn.IsInState('FeigningDeath'))
	{
		Super.NextWeapon();
	}
}

function ResetPlayerMovementInput()
{
	local UTConsolePlayerInput ConsoleInput;

	Super.ResetPlayerMovementInput();

	ConsoleInput = UTConsolePlayerInput(PlayerInput);
	if (ConsoleInput != None)
	{
		ConsoleInput.ForcedDoubleClick = DCLICK_None;
	}
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
	ignores SeePlayer, HearNoise, Bump;

	/**
	  * needs to support switching from wall dodge attempt to double jump with air control
	  */
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UTPawn(Pawn).Dodge(DoubleClickMove) )
			{
				DoubleClickDir = DCLICK_Active;
			}
			else if ( Pawn.Physics == PHYS_Falling )
			{
				// allow double jump while air controlling
				bPressedJump = true;
			}
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}
}

defaultproperties
{
	InputClass=class'UTGame.UTConsolePlayerInput'
	VehicleCheckRadiusScaling=1.5

	// @todo amitt update this to work with version 2 of the controller UI mapping system
	ProfileSettingToUE3BindingMapping360(0)=(ProfileSettingName="GamepadBinding_ButtonA",UE3BindingName="XboxTypeS_A")
	ProfileSettingToUE3BindingMapping360(1)=(ProfileSettingName="GamepadBinding_ButtonB",UE3BindingName="XboxTypeS_B")
	ProfileSettingToUE3BindingMapping360(2)=(ProfileSettingName="GamepadBinding_ButtonX",UE3BindingName="XboxTypeS_X")
	ProfileSettingToUE3BindingMapping360(3)=(ProfileSettingName="GamepadBinding_ButtonY",UE3BindingName="XboxTypeS_Y")
	ProfileSettingToUE3BindingMapping360(4)=(ProfileSettingName="GamepadBinding_Back",UE3BindingName="XboxTypeS_Back")
	ProfileSettingToUE3BindingMapping360(5)=(ProfileSettingName="GamepadBinding_Start",UE3BindingName="XboxTypeS_Start")

	ProfileSettingToUE3BindingMapping360(6)=(ProfileSettingName="GamepadBinding_RightBumper",UE3BindingName="XboxTypeS_RightTrigger")
	ProfileSettingToUE3BindingMapping360(7)=(ProfileSettingName="GamepadBinding_LeftBumper",UE3BindingName="XboxTypeS_LeftTrigger")

	ProfileSettingToUE3BindingMapping360(8)=(ProfileSettingName="GamepadBinding_RightTrigger",UE3BindingName="XboxTypeS_RightShoulder")
	ProfileSettingToUE3BindingMapping360(9)=(ProfileSettingName="GamepadBinding_LeftTrigger",UE3BindingName="XboxTypeS_LeftShoulder")

	ProfileSettingToUE3BindingMapping360(10)=(ProfileSettingName="GamepadBinding_RightThumbstickPressed",UE3BindingName="XboxTypeS_RightThumbstick")
	ProfileSettingToUE3BindingMapping360(11)=(ProfileSettingName="GamepadBinding_LeftThumbstickPressed",UE3BindingName="XboxTypeS_LeftThumbstick")
	ProfileSettingToUE3BindingMapping360(12)=(ProfileSettingName="GamepadBinding_DPadUp",UE3BindingName="XboxTypeS_DPad_Up")
	ProfileSettingToUE3BindingMapping360(13)=(ProfileSettingName="GamepadBinding_DPadDown",UE3BindingName="XboxTypeS_DPad_Down")
	ProfileSettingToUE3BindingMapping360(14)=(ProfileSettingName="GamepadBinding_DPadLeft",UE3BindingName="XboxTypeS_DPad_Left")
	ProfileSettingToUE3BindingMapping360(15)=(ProfileSettingName="GamepadBinding_DPadRight",UE3BindingName="XboxTypeS_DPad_Right")


	ProfileSettingToUE3BindingMappingPS3(0)=(ProfileSettingName="GamepadBinding_ButtonA",UE3BindingName="XboxTypeS_A")
	ProfileSettingToUE3BindingMappingPS3(1)=(ProfileSettingName="GamepadBinding_ButtonB",UE3BindingName="XboxTypeS_B")
	ProfileSettingToUE3BindingMappingPS3(2)=(ProfileSettingName="GamepadBinding_ButtonX",UE3BindingName="XboxTypeS_X")
	ProfileSettingToUE3BindingMappingPS3(3)=(ProfileSettingName="GamepadBinding_ButtonY",UE3BindingName="XboxTypeS_Y")
	ProfileSettingToUE3BindingMappingPS3(4)=(ProfileSettingName="GamepadBinding_Back",UE3BindingName="XboxTypeS_Back")
	ProfileSettingToUE3BindingMappingPS3(5)=(ProfileSettingName="GamepadBinding_Start",UE3BindingName="XboxTypeS_Start")


	ProfileSettingToUE3BindingMappingPS3(6)=(ProfileSettingName="GamepadBinding_RightBumper",UE3BindingName="XboxTypeS_RightShoulder")
	ProfileSettingToUE3BindingMappingPS3(7)=(ProfileSettingName="GamepadBinding_LeftBumper",UE3BindingName="XboxTypeS_LeftShoulder")
	ProfileSettingToUE3BindingMappingPS3(8)=(ProfileSettingName="GamepadBinding_RightTrigger",UE3BindingName="XboxTypeS_RightTrigger")
	ProfileSettingToUE3BindingMappingPS3(9)=(ProfileSettingName="GamepadBinding_LeftTrigger",UE3BindingName="XboxTypeS_LeftTrigger")

	ProfileSettingToUE3BindingMappingPS3(10)=(ProfileSettingName="GamepadBinding_RightThumbstickPressed",UE3BindingName="XboxTypeS_RightThumbstick")
	ProfileSettingToUE3BindingMappingPS3(11)=(ProfileSettingName="GamepadBinding_LeftThumbstickPressed",UE3BindingName="XboxTypeS_LeftThumbstick")
	ProfileSettingToUE3BindingMappingPS3(12)=(ProfileSettingName="GamepadBinding_DPadUp",UE3BindingName="XboxTypeS_DPad_Up")
	ProfileSettingToUE3BindingMappingPS3(13)=(ProfileSettingName="GamepadBinding_DPadDown",UE3BindingName="XboxTypeS_DPad_Down")
	ProfileSettingToUE3BindingMappingPS3(14)=(ProfileSettingName="GamepadBinding_DPadLeft",UE3BindingName="XboxTypeS_DPad_Left")
	ProfileSettingToUE3BindingMappingPS3(15)=(ProfileSettingName="GamepadBinding_DPadRight",UE3BindingName="XboxTypeS_DPad_Right")
	
	bConsolePlayer=true
}



