/*
 * DynamicCameraActor
 * A CameraActor that can be spawned/deleted dynamically in-game.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class DynamicCameraActor extends CameraActor
	native(Camera)
	notplaceable;

defaultproperties
{
	bNoDelete=FALSE
}
