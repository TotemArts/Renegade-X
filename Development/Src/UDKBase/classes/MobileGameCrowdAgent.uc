/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class MobileGameCrowdAgent extends GameCrowdAgentSkeletal
	ShowCategories(Collision);

/** Stop agent moving and pay death anim */
function PlayDeath(vector KillMomentum)
{
	Super.PlayDeath(KillMomentum);

	if ( WorldInfo.TimeSeconds - LastRenderTime > 1 )
	{
		LifeSpan = 0.01;
	}
	else
	{
		LifeSpan = DeadBodyDuration;
	}

}

/** Called by the Kismet "SetMaterial" node */
function OnSetMaterial(SeqAct_SetMaterial Action)
{
	if( SkeletalMeshComponent != None )
	{
		SkeletalMeshComponent.SetMaterial( Action.MaterialIndex, Action.NewMaterial );
	}
}

defaultproperties
{
	Health=20
	bProjTarget=true
	
	// Create a cylinder component to serve as the collision bounds for crowd actors
	Begin Object Class=CylinderComponent Name=CollisionCylinder
	CollisionRadius=+0034.000000
	CollisionHeight=+0078.000000
	BlockNonZeroExtent=true
	BlockZeroExtent=true
	BlockActors=true
	CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	RotateToTargetSpeed=60000.0
	MaxWalkingSpeed=200.0
}

