/**
 *
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */


class Rx_SeqAct_GetCredits extends SequenceAction;

var float Credits;

event Activated()
{
	local Rx_Pawn A;

	if (Targets.length == 0)
	{
		ScriptLog("WARNING: Missing Target for Get Team Number"); 
	}
	else
	{
		A = Rx_Pawn(Targets[0]); 
	}

	Credits = Rx_PRI(A.PlayerReplicationInfo).GetCredits(); 
}

defaultproperties
{
	bCallHandler=false
	ObjCategory="Ren X"
	ObjName="Get Credits"
	VariableLinks(0)=(MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Credits",PropertyName=Credits,MaxVars=1,bWriteable=true)
}