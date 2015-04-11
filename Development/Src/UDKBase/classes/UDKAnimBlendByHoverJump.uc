/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UDKAnimBlendByHoverJump extends UDKAnimBlendByFall
	Native(Animation);

var const transient Pawn	OwnerP;
var const transient UDKVehicle OwnerHV;

cpptext
{
	virtual void InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent );
	virtual	void TickAnim(FLOAT DeltaSeconds);
}


defaultproperties
{
	bIgnoreDoubleJumps=true
}
