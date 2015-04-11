/**
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_PlayMusicTrack extends SequenceAction
	native(Sequence)
	dependson(MusicTrackDataStructures);

var() MusicTrackStruct MusicTrack;

cpptext
{
	virtual void Activated();
	virtual void StripData(UE3::EPlatformType PlatformsToKeep, UBOOL bStripLargeEditorData);
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
}

defaultproperties
{
	ObjName="Play Music Track"
	ObjCategory="Sound"

	VariableLinks.Empty
}