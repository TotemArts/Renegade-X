/**
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTDecalManager extends DecalManager;

function bool CanSpawnDecals()
{
	return (!class'Engine'.static.IsSplitScreen() && Super.CanSpawnDecals());
}

defaultproperties
{
	DecalDepthBias=-0.00012
}