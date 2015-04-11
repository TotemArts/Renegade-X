/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackInstDirector extends InterpTrackInst
	native(Interpolation);


var	Actor	OldViewTarget;

/** Rendering overrides that were active on the player camera, used to restore settings when the director track ends in game. */
var RenderingPerformanceOverrides OldRenderingOverrides;

/** In the process of transitioning to another director track */
var bool bTransitioningToOtherDirector;

cpptext
{
	/** Initialise this Track instance. Called in-game before doing any interpolation. */
	virtual void InitTrackInst(UInterpTrack* Track);
	/** Called when interpolation is done. Should not do anything else with this TrackInst after this. */
	virtual void TermTrackInst(UInterpTrack* Track);
}

defaultproperties
{
}
