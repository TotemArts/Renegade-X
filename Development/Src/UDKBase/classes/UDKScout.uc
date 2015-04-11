/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKScout extends Scout
	native
	transient;

/** Set during path calculation if double jump is required to traverse this path */
var bool bRequiresDoubleJump;

/** Should be set in Scout's default properties to specify max height off ground reached at apex of double jump */
var float MaxDoubleJumpHeight;

/* UDKScout uses the properties from this class (jump height etc.) to override UDKScout default settings */
var class<UDKPawn> PrototypePawnClass;

/** Name (in PathSizes[] array) associated with size that should be used for calculating JumpPad paths */
var name SizePersonFindName;

cpptext
{
	virtual ETestMoveResult FindJumpUp(FVector Direction, FVector &CurrentPosition);
	virtual UBOOL SetHighJumpFlag();
	virtual void SetPrototype();
	virtual ETestMoveResult FindBestJump(FVector Dest, FVector &CurrentPosition);

	virtual void SetPathColor(UReachSpec* ReachSpec)
	{
		FVector CommonSize = GetSize(FName(TEXT("Common"),FNAME_Find));
		if ( ReachSpec->CollisionRadius >= CommonSize.X )
		{
			FVector MaxSize = GetSize(FName(TEXT("Vehicle"),FNAME_Find));
			ReachSpec->PathColorIndex = ( ReachSpec->CollisionRadius >= MaxSize.X ) ? 2 : 1;
		}
		else
		{
			ReachSpec->PathColorIndex = 0;
		}
	}
}

/**
SuggestJumpVelocity()
returns true if succesful jump from start to destination is possible
returns a suggested initial falling velocity in JumpVelocity
Uses GroundSpeed and JumpZ as limits
*/
native function bool SuggestJumpVelocity(out vector JumpVelocity, vector Destination, vector Start, optional bool bRequireFallLanding);

defaultproperties
{
}
