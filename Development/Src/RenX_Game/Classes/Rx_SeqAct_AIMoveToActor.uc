/**
 * Copyright 2007-2012 Totem Arts, All Rights Reserved.
 */
class Rx_SeqAct_AIMoveToActor extends SeqAct_AIMoveToActor;

function Actor PickDestination(Actor Requestor)
{
	local Pawn P;

	P = Pawn(Requestor);
	P.MovementSpeedModifier = MovementSpeedModifier;

	return Super.PickDestination(Requestor);
}

defaultproperties
{
	ObjName="Renegade X - Move To Actor"
	ObjCategory="AI"
	ObjRemoveInProject(0)="Gear"

	OutputLinks(2)=(LinkDesc="Out")

	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Destination",PropertyName=Destination)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Look At",PropertyName=LookAt)

	MovementSpeedModifier=1.0
}
